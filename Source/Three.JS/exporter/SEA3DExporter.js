/**
 * 	SEA3D Exporter
 * 	@author Sunag / http://www.sunag.com.br/
 */

'use strict';

//
//	BUILDER
//

THREE.SEA3D.Exporter = function ( params ) {

	this.objects = [];

	this.drops = [];
	this.drop = {};

	this.sign = "TJS"; // THREE.JS
	this.version = 18110;

	this.frameRate = 30;

	this.step = 0;
	this.progress = 0;

	this.protectionAlgorithm = 0;
	this.compressionAlgorithm = 0;

	for ( var name in params ) {

		this[ name ] = params[ name ];

	}

};

THREE.SEA3D.Exporter.BIG_GEOMETRY = 0xFFFE;

THREE.SEA3D.Exporter.compressionAlgorithms = {};

THREE.SEA3D.Exporter.setCompressionAlgorithm = function ( id, callback ) {

	this.compressionAlgorithms[ id ] = callback;

};

THREE.SEA3D.Exporter.prototype = Object.assign( Object.create( THREE.EventDispatcher.prototype ), {

	constructor: THREE.SEA3D.Exporter,

	add: function () {

		for ( var i = 0; i < arguments.length; i ++ ) {

			var obj = arguments[ i ];

			this.objects.push( obj );

		}

		return this;

	},

	addDrop: function ( drop, type, name, data ) {

		if ( type ) drop.type = type;
		if ( name ) drop.name = name;
		if ( data ) drop.data = data;

		drop.index = this.drops.length;

		this.drops.push( drop );

		return drop;

	},

	regDrop: function ( uuid ) {

		return this.drop[ uuid ] = { id: uuid };

	},

	getDrop: function ( uuid ) {

		return this.drop[ uuid ];

	},

	getIndexedDrop: function ( uuid ) {

		if ( this.drop[ uuid ].index !== undefined ) {

			return this.drop[ uuid ];

		}

	},

	getSorted: function ( objects, sorted ) {

		var i, obj;

		objects = objects || this.objects;
		sorted = sorted || [];

		for ( i = 0; i < objects.length; i ++ ) {

			obj = objects[ i ];

			if ( obj instanceof THREE.Object3D ) {

				this.getSorted( obj.children, sorted );

			}

			sorted.push( {
				object: obj,
				depth: this.getDepth( obj )
			} );

		}

		sorted.sort( function ( a, b ) {

			return a.depth - b.depth;

		} );

		var sortedObjects = [];

		for ( i = 0; i < sorted.length; i ++ ) {

			var object = sorted[ i ].object;

			if ( this.onCandidate ) {

				if ( this.onCandidate( object ) ) {

					sortedObjects.push( object );

				}

			} else {

				sortedObjects.push( object );

			}

		}

		return sortedObjects;

	},

	getDepth: function ( obj ) {

		var depth = 0;

		if ( obj instanceof THREE.Object3D ) {

			depth = 1;

			for ( var obj3d = obj; obj3d = obj3d.parent; ++ depth );

		}

		return depth;

	},

	getImageFormat: function ( buffer ) {

		var data = new Uint8Array( buffer );

		if ( data.length > 3 ) {

			if ( data[ 0 ] === 255 && data[ 1 ] === 216 && data[ 2 ] === 255 ) {

				return SEA3D.JPEG.prototype.type;

			} else if ( data[ 0 ] === 137 && data[ 1 ] === 80 && data[ 2 ] === 78 ) {

				return SEA3D.PNG.prototype.type;

			} else if ( data[ 0 ] === 73 && data[ 1 ] === 73 && data[ 2 ] === 188 ) {

				return SEA3D.JPEG_XR.prototype.type;

			} else if ( data[ 0 ] === 71 && data[ 1 ] === 73 && data[ 2 ] === 70 ) {

				return SEA3D.GIF.prototype.type;

			}

		}

	},

	writeMatrix3D: function ( data, matrix ) {

		var v = matrix.elements;

		data.writeFloat( v[ 0 ] );
		data.writeFloat( v[ 1 ] );
		data.writeFloat( v[ 2 ] );

		data.writeFloat( v[ 4 ] );
		data.writeFloat( v[ 5 ] );
		data.writeFloat( v[ 6 ] );

		data.writeFloat( v[ 8 ] );
		data.writeFloat( v[ 9 ] );
		data.writeFloat( v[ 10 ] );

		data.writeFloat( v[ 12 ] );
		data.writeFloat( v[ 13 ] );
		data.writeFloat( v[ 14 ] );

	},

	writeObject3D: function ( obj3d, header, parent ) {

		const PARENT = 1, ANIMATION = 2;

		var attrib = 0,
			i;

		// HIERARCHY

		if ( parent && ! ( parent instanceof THREE.Scene ) ) {

			var parentDrop = this.serialize( parent );

			if ( parentDrop ) {

				attrib |= PARENT;
				header.writeUInt( parentDrop.index );

			}

		}

		// ANIMATIONS

		var animations = [];

		if ( obj3d instanceof THREE.Mesh ) {

			if ( obj3d.skeleton ) {

			} else if ( obj3d.geometry.animations ) {

				animations.push( this.serializeVertexAnimation( obj3d.geometry ) );

			}

		}

		if ( animations.length > 0 ) {

			attrib |= ANIMATION;

			header.writeByte( animations.length );

			for ( i = 0; i < animations.length; i ++ ) {

				header.writeByte( 0 ); // flags

				header.writeUInt( animations[ i ].index );

			}

		}

		return attrib;

	},

	writeAnimationSequence: function ( animations, header ) {

		const SEQUENCES = 1, SEQUENCE_REPEAT = 1;

		var attrib = 0,
			numFrames = 0;

		if ( animations.length > 0 ) {

			attrib |= SEQUENCES;

			header.writeUShort( animations.length );

			for ( var i = 0; i < animations.length; i ++ ) {

				var anm = animations[ i ],
					anmNumFrames = Math.floor( anm.duration / ( 1 / this.frameRate ) );

				var flags = 0;

				if ( anm.repeat ) flags |= SEQUENCE_REPEAT;

				header.writeByte( flags );

				header.writeUTF8Tiny( anm.name );
				header.writeUInt( numFrames );
				header.writeUInt( anmNumFrames );

				numFrames += anmNumFrames;

			}

		}

		header.writeByte( this.frameRate );
		header.writeUInt( numFrames );

		return { attrib: attrib, numFrames: numFrames };

	},

	write: function ( callback, priority ) {

		const NAME = 1, COMPRESSED = 2, STREAMING = 4;

		priority = priority || 100;

		var sea = new SEA3D.Stream(),
			objects = this.getSorted(),
			position = 0;

		var time = performance.now();

		var onDrop = function () {

			this.step = 1;
			this.progress = position / this.drops.length;

			if ( position < this.drops.length ) {

				// ASYNC

				var now = performance.now();

				if ( ( callback && ( now - time ) > priority ) || ! this.drops[ position ].data ) {

					time = now;

					requestAnimationFrame( onDrop );

					if ( this.onProgress ) this.onProgress( this.progress, this.step );

					return;

				}

				// HEADER

				var drop = this.drops[ position ++ ],
					header = new SEA3D.Stream(),
					flags = 0;

				if ( drop.name ) flags |= NAME;
				if ( drop.compressed || drop.compressed === undefined ) flags |= COMPRESSED;
				if ( drop.streaming || drop.streaming === undefined ) flags |= STREAMING;

				function onWrite() {

					// WRITE

					header.writeByte( flags );
					header.writeExt( drop.type );

					if ( flags & NAME ) header.writeUTF8Tiny( drop.name );

					// DROP

					sea.writeUInt( header.length + drop.data.length );

					sea.writeBytes( header.buffer );

					sea.writeBytes( drop.data.buffer );

					onDrop();

				}

				// COMPRESSED

				if ( flags & COMPRESSED && this.compressionAlgorithm > 0 ) {

					THREE.SEA3D.Exporter.compressionAlgorithms[ this.compressionAlgorithm ]( drop.data.buffer, function ( buffer ) {

						drop.data = new SEA3D.Stream( buffer );

						onWrite();

					} );

				} else {

					onWrite();

				}

			} else {

				sea.writeUInt24( 0x5EA3D1 ); // FINAL

				if ( this.onProgress ) this.onProgress( this.progress, this.step );

				if ( callback ) callback( sea );

			}

		}.bind( this );

		var onSerialize = function () {

			this.step = 0;
			this.progress = position / objects.length;

			var now = performance.now();

			if ( callback && ( now - time ) > priority ) {

				time = now;

				requestAnimationFrame( onSerialize );

				if ( this.onProgress ) this.onProgress( this.progress, this.step );

				return;

			}

			if ( position < objects.length ) {

				this.serialize( objects[ position ++ ] );

				onSerialize();

			} else {

				position = 0;

				sea.writeUTF8( "SEA" );

				sea.writeUTF8( this.sign );
				sea.writeUInt24( this.version );

				sea.writeByte( this.protectionAlgorithm );
				sea.writeByte( this.compressionAlgorithm );

				sea.writeUInt( this.drops.length );

				onDrop();

			}

		}.bind( this );

		onSerialize();

		return sea;

	},

	serialize: function ( obj ) {

		if ( obj instanceof THREE.Bone ) {

			return this.serializeBone( obj );

		} else if ( obj instanceof THREE.Skeleton ) {

			return this.serializeSkeleton( obj );

		} else if ( obj instanceof THREE.Mesh ) {

			return this.serializeMesh( obj );

		} if ( obj instanceof THREE.Geometry ) {

			return this.serializeGeometry( obj );

		} if ( obj instanceof THREE.BufferGeometry ) {

			return this.serializeBufferGeometry( obj );

		} if ( obj instanceof THREE.MeshStandardMaterial || obj instanceof THREE.MeshPhongMaterial ) {

			return this.serializeMaterial( obj );

		} if ( obj instanceof THREE.Texture ) {

			return this.serializeTexture( obj );

		}

	},

	serializeTexture: function ( tex ) {

		var url = tex.image.currentSrc || tex.image.src || tex.uuid;

		var drop = this.getDrop( url );

		if ( drop ) return this.getIndexedDrop( url );

		drop = this.regDrop( url );

		// SEA/DROP

		new THREE.FileLoader().setResponseType( "arraybuffer" ).load( url, function ( buffer ) {

			drop.type = this.getImageFormat( buffer );
			drop.data = new SEA3D.Stream( buffer );

		}.bind( this ) );

		return this.addDrop( drop, null, tex.name );

	},

	serializeMaterial: function ( mat ) {

		var drop = this.getDrop( mat.uuid );

		if ( drop ) return this.getIndexedDrop( mat.uuid );

		drop = this.regDrop( mat.uuid );

		var data = new SEA3D.Stream(),
			header = new SEA3D.Stream(),
			attrib = 0;

		if ( mat.side === THREE.DoubleSide ) attrib |= 1;

		if ( mat.lights === false ) attrib |= 2;
		if ( mat.shadows === false ) attrib |= 4;
		if ( mat.fog === false ) attrib |= 8;

		if ( mat.map && mat.map.wrapS === THREE.ClampToEdgeWrapping ) {

			attrib |= 16;

		}

		if ( mat.opacity != 1 ) {

			attrib |= 32;
			header.writeFloat( mat.opacity );

		}

		if ( mat.blending != THREE.NoBlending ) {

			var blendMode = "normal";

			if ( mat.blending === THREE.AdditiveBlending ) blendMode = "add";
			else if ( mat.blending === THREE.SubtractiveBlending ) blendMode = "subtract";
			else if ( mat.blending === THREE.MultiplyBlending ) blendMode = "multiply";
			else if ( mat.blending === THREE.CustomBlending &&
				mat.blendSrc === THREE.OneFactor &&
				mat.blendDst === THREE.OneMinusSrcColorFactor &&
				mat.blendEquation === THREE.AddEquation ) blendMode = "screen";

			attrib |= 64;
			header.writeBlendMode( blendMode );

		}

		if ( mat.depthWrite === false ) attrib |= 256;
		if ( mat.depthTest === false ) attrib |= 512;

		if ( mat.premultipliedAlpha ) attrib |= 1024;

		// TECHNIQUES

		var techniques = [],
			map, tech;

		if ( mat instanceof THREE.MeshPhongMaterial ) {

			tech = new SEA3D.Stream();
			tech.writeUInt24( 0 );
			tech.writeUInt24( mat.color.getHex() );
			tech.writeUInt24( mat.specular.getHex() );
			tech.writeFloat( mat.specular.getHex() > 0 ? 1 : 0 );
			tech.writeFloat( mat.shininess );

			techniques.push( {
				kind: SEA3D.Material.PHONG,
				data: tech
			} );

		} else if ( mat instanceof THREE.MeshStandardMaterial ) {

			tech = new SEA3D.Stream();
			tech.writeUInt24( mat.color.getHex() );
			tech.writeFloat( mat.roughness );
			tech.writeFloat( mat.metalness );

			techniques.push( {
				kind: SEA3D.Material.PHYSICAL,
				data: tech
			} );

			if ( mat instanceof THREE.MeshPhysicalMaterial ) {

				tech = new SEA3D.Stream();
				tech.writeFloat( mat.strength );
				tech.writeFloat( mat.roughness );

				techniques.push( {
					kind: SEA3D.Material.CLEAR_COAT,
					data: tech
				} );

			}

		}

		if ( mat.map ) {

			map = this.serialize( mat.map );

			tech = new SEA3D.Stream();
			tech.writeUInt( map.index );

			techniques.push( {
				kind: SEA3D.Material.DIFFUSE_MAP,
				data: tech
			} );

		}

		// MATERIAL

		data.writeUShort( attrib );
		data.writeBytes( header.buffer );

		data.writeByte( techniques.length );

		for ( var i = 0; i < techniques.length; i ++ ) {

			tech = techniques[ i ];

			data.writeUShort( tech.kind );
			data.writeUShort( tech.data.length );
			data.writeBytes( tech.data.buffer );

		}

		// SEA/DROP

		return this.addDrop( drop, SEA3D.Material.prototype.type, mat.name, data );

	},

	serializeBone: function ( bone ) {

		var drop = this.getDrop( bone.uuid );

		if ( drop ) return this.getIndexedDrop( bone.uuid );

		drop = this.regDrop( bone.uuid );

		var childCount = 0;

		for ( var i = 0; i < bone.children.length; i ++ ) {

			if ( ! ( bone.children[ i ] instanceof THREE.Bone ) ) {

				++ childCount;

			}

		}

		if ( childCount > 0 ) {

			for ( var target = bone; target instanceof THREE.Bone; target = target.parent );

			var data = new SEA3D.Stream(),
				header = new SEA3D.Stream(),
				attrib = this.writeObject3D( bone, header, target ),
				boneIndex = target.skeleton.bones.indexOf( bone );

			data.writeUShort( attrib );
			data.writeBytes( header.buffer );

			data.writeUInt( this.serialize( target ).index );
			data.writeUShort( boneIndex );

			data.writeByte( 0 );

			return this.addDrop( drop, SEA3D.JointObject.prototype.type, bone.name, data );

		}

	},

	serializeVertexAnimation: function ( geo ) {

		var uuid = geo.uuid + "-vertex-animation";

		var drop = this.getDrop( uuid );

		if ( drop ) return this.getIndexedDrop( uuid );

		drop = this.regDrop( uuid );

		const POSITION = 2, NORMAL = 4;

		var data = new SEA3D.Stream(),
			header = new SEA3D.Stream(),
			numVertex = ( geo.morphAttributes.position || geo.morphAttributes.normal )[ 0 ].count,
			isBig = numVertex >= THREE.SEA3D.Exporter.BIG_GEOMETRY,
			animation = this.writeAnimationSequence( geo.animations, header ),
			attrib = 0;

		if ( geo.morphAttributes.position ) attrib |= POSITION;
		if ( geo.morphAttributes.normal ) attrib |= NORMAL;

		data.writeVInt = isBig ? data.writeUInt : data.writeUShort;

		// ANIMATION

		data.writeByte( animation.attrib );

		data.writeBytes( header.buffer );

		// HEADER

		data.writeByte( attrib );

		data.writeVInt( numVertex );

		// VERTEX ANIMATION

		for ( var i = 0; i < animation.numFrames; i ++ ) {

			if ( attrib & POSITION ) data.writeBytes( geo.morphAttributes.position[ i ].array.buffer );
			if ( attrib & NORMAL ) data.writeBytes( geo.morphAttributes.normal[ i ].array.buffer );

		}

		// SEA/DROP

		return this.addDrop( drop, SEA3D.VertexAnimation.prototype.type, geo.name, data );

	},

	serializeMorph: function ( geo ) {

		var uuid = geo.uuid + "-morph";

		var drop = this.getDrop( uuid );

		if ( drop ) return this.getIndexedDrop( uuid );

		drop = this.regDrop( uuid );

		const POSITION = 2, NORMAL = 4;

		var data = new SEA3D.Stream(),
			ref = geo.morphAttributes.position || geo.morphAttributes.normal,
			numVertex = ref[ 0 ].count,
			isBig = numVertex >= THREE.SEA3D.Exporter.BIG_GEOMETRY,
			attrib = 0;

		if ( geo.morphAttributes.position ) attrib |= POSITION;
		if ( geo.morphAttributes.normal ) attrib |= NORMAL;

		data.writeVInt = isBig ? data.writeUInt : data.writeUShort;

		// HEADER

		data.writeUShort( attrib );

		data.writeVInt( numVertex );

		// MORPH

		data.writeUShort( ref.length );

		for ( var i = 0; i < ref.length; i ++ ) {

			data.writeUTF8Tiny( geo.morphTargets[ i ].name );

			if ( attrib & POSITION ) data.writeBytes( geo.morphAttributes.position[ i ].array.buffer );
			if ( attrib & NORMAL ) data.writeBytes( geo.morphAttributes.normal[ i ].array.buffer );

		}

		// SEA/DROP

		return this.addDrop( drop, SEA3D.Morph.prototype.type, geo.name, data );

	},

	serializeSkeleton: function ( skl, name ) {

		var drop = this.getDrop( skl.uuid );

		if ( drop ) return this.getIndexedDrop( skl.uuid );

		drop = this.regDrop( skl.uuid );

		var data = new SEA3D.Stream(),
			bones = skl.bones;

		data.writeUShort( bones.length );

		for ( var i = 0; i < bones.length; i ++ ) {

			var bone = bones[ i ],
				index = bones.indexOf( bone.parent );

			// BONE

			data.writeUTF8Tiny( bone.name );
			data.writeUShort( index + 1 );

			// POSITION XYZ

			data.writeVec3( bone.position );

			// QUATERNION XYZW

			data.writeVec4( bone.quaternion );

		}

		// SEA/DROP

		return this.addDrop( drop, SEA3D.SkeletonLocal.prototype.type, name || skl.name, data );

	},

	serializeMesh: function ( mesh ) {

		var drop = this.getDrop( mesh.uuid );

		if ( drop ) return this.getIndexedDrop( mesh.uuid );

		drop = this.regDrop( mesh.uuid );

		var data = new SEA3D.Stream(),
			header = new SEA3D.Stream(),
			attrib = this.writeObject3D( mesh, header, mesh.parent ),
			lightType = 0,
			i;

		if ( ! mesh.castShadow ) lightType = 1;

		if ( ! lightType ) {

			attrib |= 64;
			header.writeByte( lightType );

		}

		if ( mesh.material ) {

			attrib |= 256;

			var material;

			if ( mesh.material instanceof THREE.MultiMaterial ) {



			} else {

				material = this.serialize( mesh.material );

				if ( material ) {

					header.writeByte( 1 );
					header.writeUInt( material.index );

				}

			}

		}

		// MODIFIERS

		var modifiers = [];

		if ( mesh.skeleton ) {

			modifiers.push( this.serializeSkeleton( mesh.skeleton, mesh.name ) );

		}

		if ( ! mesh.geometry.animations && mesh.geometry.morphAttributes && ( mesh.geometry.morphAttributes.position || mesh.geometry.morphAttributes.normal ) ) {

			modifiers.push( this.serializeMorph( mesh.geometry ) );

		}

		if ( modifiers.length > 0 ) {

			attrib |= 512;

			header.writeByte( modifiers.length );

			for ( i = 0; i < modifiers.length; i ++ ) {

				header.writeUInt( modifiers[ i ].index );

			}

		}

		// MESH

		data.writeUShort( attrib );
		data.writeBytes( header.buffer );

		this.writeMatrix3D( data, mesh.matrix );

		data.writeUInt( this.serialize( mesh.geometry ).index );

		data.writeByte( 0 ); // TAGS

		// SEA/DROP

		return this.addDrop( drop, SEA3D.Mesh.prototype.type, mesh.name, data );

	},

	serializeGeometry: function ( geo ) {

		var buffer = new THREE.BufferGeometry().fromGeometry( geo );
		buffer.name = geo.name;

		return this.serializeBufferGeometry( buffer );

	},

	serializeSEAGeometry: function ( geo ) {

		var sea = {},
			i;

		sea.numVertex = geo.attributes.position ? geo.attributes.position.count : 0;
		sea.isBig = sea.numVertex >= THREE.SEA3D.Exporter.BIG_GEOMETRY;

		sea.uv = [];

		if ( geo.attributes.uv ) sea.uv.push( geo.attributes.uv.array );
		if ( geo.attributes.uv2 ) sea.uv.push( geo.attributes.uv2.array );

		sea.normal = geo.attributes.normal.array;
		sea.vertex = geo.attributes.position.array;

		sea.groups = geo.groups;

		if ( geo.indexes ) geo.index.array.buffer;

		return this.serializeBufferGeometry( sea );

	},

	serializeBufferGeometry: function ( geo ) {

		// DROP

		var drop = this.getDrop( geo.uuid );

		if ( drop ) return this.getIndexedDrop( geo.uuid );

		drop = this.regDrop( geo.uuid );

		if ( this.onGeometry ) {

			drop.type = SEA3D.Geometry.prototype.type;
			drop.name = geo.name;
			drop.data = this.onGeometry( geo, drop );

			if ( drop.data ) return this.addDrop( drop );

		}

		// SERIALIZE

		const IS_BIG = 1, NORMAL = 4, UV = 32, JOINTS = 64, GROUP = 1024, TRIANGLE_SOUP = 2048;

		var data = new SEA3D.Stream(),
			attrib = GROUP,
			numVertex = geo.attributes.position ? geo.attributes.position.count : 0,
			isBig = numVertex >= THREE.SEA3D.Exporter.BIG_GEOMETRY,
			i;

		data.writeVInt = isBig ? data.writeUInt : data.writeUShort;

		if ( geo.attributes.normal ) attrib |= NORMAL;
		if ( geo.attributes.uv ) attrib |= UV;
		if ( geo.attributes.skinIndex ) attrib |= JOINTS;
		if ( ! geo.index ) attrib |= TRIANGLE_SOUP;

		// HEADER

		data.writeUShort( attrib );

		data.writeVInt( numVertex );

		// NORMAL

		if ( attrib & NORMAL ) data.writeBytes( geo.attributes.normal.array.buffer );

		// UV

		if ( attrib & UV ) {

			var uvCount = 1;

			if ( geo.attributes.uv2 ) ++ uvCount;

			data.writeByte( uvCount );

			data.writeBytes( geo.attributes.uv.array.buffer );

			if ( geo.attributes.uv2 ) data.writeBytes( geo.attributes.uv2.array.buffer );

		}

		// JOINTS

		if ( attrib & JOINTS ) {

			data.writeByte( geo.attributes.skinIndex.itemSize );

			var skinIndexesArray = geo.attributes.skinIndex.array,
				skinIndexes = new Uint16Array( skinIndexesArray.length );

			for ( i = 0; i < skinIndexesArray.length; i ++ ) {

				skinIndexes[ i ] = skinIndexesArray[ i ];

			}

			data.writeBytes( skinIndexes.buffer );
			data.writeBytes( geo.attributes.skinWeight.array.buffer );

		}

		// VERTEX/POSITION

		if ( numVertex > 0 ) {

			data.writeBytes( geo.attributes.position.array.buffer );

		}

		// GROUP

		data.writeByte( geo.groups.length );

		for ( i = 0; i < geo.groups.length; i ++ ) {

			data.writeVInt( geo.groups[ i ].count );

		}

		// INDEXES

		if ( ! ( attrib & TRIANGLE_SOUP ) ) {

			data.writeBytes( geo.index.array.buffer );

		}

		// SEA/DROP

		return this.addDrop( drop, SEA3D.Geometry.prototype.type, geo.name, data );

	},

	build: function () {

		var data = this.write();



		return data;

	}

} );

//
//	STREAM WRITER
//

SEA3D.Stream.concat = function ( buffer1, buffer2 ) {

	var tmp = new Uint8Array( buffer1.byteLength + buffer2.byteLength );

	tmp.set( new Uint8Array( buffer1 ), 0 );
	tmp.set( new Uint8Array( buffer2 ), buffer1.byteLength );

	return tmp.buffer;

};

SEA3D.Stream.stringToBuffer = function ( str ) {

	if ( window.TextEncoder ) {

		return new TextEncoder().encode( str ).buffer;

	} else {

		str = unescape( encodeURIComponent( str ) );

		var bytes = new Uint8Array( str.length );

		for ( var i = 0, len = str.length; i < len; i ++ ) {

			bytes[ i ] = str.charCodeAt( i ) & 0xFF;

		}

		return bytes.buffer;

	}

};

SEA3D.Stream.prototype.appendBuffer = function ( data ) {

	this.buf = SEA3D.Stream.concat( this.buf, data.buffer );

};

SEA3D.Stream.prototype.writeBytes = function ( buffer ) {

	this.buf = SEA3D.Stream.concat( this.buf, buffer );
	this.position += buffer.byteLength;

};

SEA3D.Stream.prototype.writeByte = function ( val ) {

	return this.writeBytes( new Uint8Array( [ val ] ).buffer );

};

SEA3D.Stream.prototype.writeBool = function ( val ) {

	return this.writeByte( val ? 1 : 0 );

};

SEA3D.Stream.prototype.writeUShort = function ( val ) {

	return this.writeBytes( new Uint16Array( [ val ] ).buffer );

};

SEA3D.Stream.prototype.writeUInt24 = function ( val ) {

	this.writeUShort( val & 0xFFFF );
	return this.writeByte( 0xFF & ( val >> 16 ) );

};

SEA3D.Stream.prototype.writeUInt = function ( val ) {

	return this.writeBytes( new Uint32Array( [ val ] ).buffer );

};

SEA3D.Stream.prototype.writeUTF8 = function ( str ) {

	return this.writeBytes( SEA3D.Stream.stringToBuffer( str ) );

};

SEA3D.Stream.prototype.writeVec3 = function ( val ) {

	this.writeFloat( val.x );
	this.writeFloat( val.y );
	this.writeFloat( val.z );

};

SEA3D.Stream.prototype.writeVec4 = function ( val ) {

	this.writeFloat( val.x );
	this.writeFloat( val.y );
	this.writeFloat( val.z );
	this.writeFloat( val.q );

};

SEA3D.Stream.prototype.writeFloat = function ( val ) {

	return this.writeBytes( new Float32Array( [ val ] ).buffer );

};

SEA3D.Stream.prototype.writeBlendMode = function ( blendMode ) {

	this.writeByte( SEA3D.Stream.BLEND_MODE.indexOf( blendMode ) );

};

SEA3D.Stream.prototype.writeExt = function ( str ) {

	str = str.substr( 0, 4 );

	while ( str.length < 4 ) str += "\0";

	return this.writeBytes( SEA3D.Stream.stringToBuffer( str ) );

};

SEA3D.Stream.prototype.writeUTF8Tiny = function ( str ) {

	var buffer = SEA3D.Stream.stringToBuffer( str );

	this.writeByte( buffer.byteLength );

	return this.writeBytes( buffer );

};

SEA3D.Stream.prototype.writeUTF8Long = function ( str ) {

	var buffer = SEA3D.Stream.stringToBuffer( str );

	this.writeUInt( buffer.byteLength );

	return this.writeBytes( buffer );

};
