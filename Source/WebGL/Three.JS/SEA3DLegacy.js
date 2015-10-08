/**
 * 	SEA3D Legacy for Three.JS
 * 	@author Sunag / http://www.sunag.com.br/
 */

'use strict';

//
//	Header
//

THREE.SEA3D.prototype._onHead = THREE.SEA3D.prototype.onHead;
THREE.SEA3D.prototype._updateTransform = THREE.SEA3D.prototype.updateTransform;
THREE.SEA3D.prototype._readVertexAnimation = THREE.SEA3D.prototype.readVertexAnimation;
THREE.SEA3D.prototype._readGeometryBuffer = THREE.SEA3D.prototype.readGeometryBuffer;
THREE.SEA3D.prototype._readLine = THREE.SEA3D.prototype.readLine;
THREE.SEA3D.prototype._getSkeletonAnimation = THREE.SEA3D.prototype.getSkeletonAnimation;
THREE.SEA3D.prototype._applyDefaultAnimation = THREE.SEA3D.prototype.applyDefaultAnimation;

//
//	Utils
//

THREE.SEA3D.prototype.isLegacy = function( sea ) {

	var sea3d = sea.sea;

	if ( sea3d.sign == 'S3D' && ! sea._legacy ) {

		sea._legacy = sea3d.typeUnique[ sea.type ] == true;

		return true;

	}

	return false;

};

THREE.SEA3D.prototype.flipZVec3 = function( v ) {

	if ( ! v ) return;

	var i = 2; // z

	while ( i < v.length ) {

		v[ i ] = - v[ i ];

		i += 3;

	}

	return v;

};

THREE.SEA3D.prototype.compressJoints = function( sea ) {

	var numJoints = sea.numVertex * 4;

	var joint = new Uint16Array( numJoints );
	var weight = new Float32Array( numJoints );

	var w = 0;

	for ( var i = 0; i < sea.numVertex; i ++ ) {

		var tjsIndex = i * 4;
		var seaIndex = i * sea.jointPerVertex;

		joint[ tjsIndex ] = sea.joint[ seaIndex ];
		joint[ tjsIndex + 1 ] = sea.joint[ seaIndex + 1 ];
		joint[ tjsIndex + 2 ] = sea.joint[ seaIndex + 2 ];
		joint[ tjsIndex + 3 ] = sea.joint[ seaIndex + 3 ];

		weight[ tjsIndex ] = sea.weight[ seaIndex ];
		weight[ tjsIndex + 1 ] = sea.weight[ seaIndex + 1 ];
		weight[ tjsIndex + 2 ] = sea.weight[ seaIndex + 2 ];
		weight[ tjsIndex + 3 ] = sea.weight[ seaIndex + 3 ];

		w = weight[ tjsIndex ] + weight[ tjsIndex + 1 ] + weight[ tjsIndex + 2 ] + weight[ tjsIndex + 3 ];

		weight[ tjsIndex ] += 1 - w;

	}

	sea.joint = joint;
	sea.weight = weight;

	sea.jointPerVertex = 4;

};

THREE.SEA3D.prototype.flipZIndex = function( v ) {

	var i = 1; // y >-< z

	while ( i < v.length ) {

		var idx = v[ i + 1 ];
		v[ i + 1 ] = v[ i ];
		v[ i ] = idx;

		i += 3;

	}

	return v;

};

THREE.SEA3D.prototype.flipMatrix = function( mtx ) {

	var zero = new THREE.Vector3();
	var buf1 = new THREE.Matrix4();

	return function( mtx ) {

		buf1.copy( mtx );

		mtx.setPosition( zero );
		mtx.multiplyMatrices( THREE.SEA3D.MTXBUF.makeRotationAxis( THREE.SEA3D.VECBUF.set( 0, 0, 1 ), THREE.Math.degToRad( 180 ) ), mtx );
		mtx.makeRotationFromQuaternion( THREE.SEA3D.QUABUF.setFromRotationMatrix( mtx ) );

		var pos = THREE.SEA3D.VECBUF.setFromMatrixPosition( buf1 );
		pos.z = - pos.z;
		mtx.setPosition( pos );

		return mtx;

	};

}();

THREE.SEA3D.prototype.flipMatrixScale = function( mtx, global, parent ) {

	var pos = new THREE.Vector3();
	var qua = new THREE.Quaternion();
	var slc = new THREE.Vector3();

	return function( mtx, global, parent ) {

		if ( parent ) mtx.multiplyMatrices( parent, mtx );

		mtx.decompose( pos, qua, slc );

		slc.z = - slc.z;

		if ( global ) {

			slc.y = - slc.y;
			slc.x = - slc.x;

		}

		mtx.compose( pos, qua, slc );

		if ( parent ) {

			parent = parent.clone();

			this.flipMatrixScale( parent );

			mtx.multiplyMatrices( parent.getInverse( parent ), mtx );

		}

	}

}();

THREE.SEA3D.prototype.applyMatrix = function( obj3d, mtx ) {

	obj3d.position.setFromMatrixPosition( mtx );
	obj3d.scale.setFromMatrixScale( mtx );

	// ignore rotation scale

	mtx.scale( THREE.SEA3D.VECBUF.set( 1 / obj3d.scale.x, 1 / obj3d.scale.y, 1 / obj3d.scale.z ) );
	obj3d.rotation.setFromRotationMatrix( mtx );

	obj3d.updateMatrixWorld();

};

//
//	Legacy
//

THREE.SEA3D.prototype.updateAnimationSet = function( obj3d ) {

	var buf1 = new THREE.Matrix4();

	var pos = new THREE.Vector3();
	var qua = new THREE.Quaternion();
	var slc = new THREE.Vector3();

	return function( obj3d ) {

		var anmSet = obj3d.animation.animationSet;
		var relative = obj3d.animation.relative;
		var anms = anmSet.animations;

		if ( anmSet.flip && ! anms.length )
			return;

		var dataList = anms[ 0 ].dataList,
			t_anm = [];

		for ( var i = 0; i < dataList.length; i ++ ) {

			var data = dataList[ i ];
			var raw = dataList[ i ].data;
			var kind = data.kind;
			var numFrames = raw.length / data.blockLength;

			switch ( kind ) {
				case SEA3D.Animation.POSITION:
				case SEA3D.Animation.ROTATION:
				case SEA3D.Animation.SCALE:
					t_anm.push( {
						kind : kind,
						numFrames : numFrames,
						raw : raw
					} );
					break;
			}

		}

		if ( t_anm.length > 0 ) {

			var numFrames = t_anm[ 0 ].numFrames;

			if ( obj3d.animation.relative ) buf1.identity();
			else buf1.copy( obj3d.matrix );

			buf1.decompose( pos, qua, slc );

			for ( var f = 0, t, c; f < numFrames; f ++ ) {

				for ( t = 0; t < t_anm.length; t ++ ) {

					var raw = t_anm[ t ].raw,
						kind = t_anm[ t ].kind;

					switch ( kind ) {
						case SEA3D.Animation.POSITION:

							c = f * 3;

							pos.set(
								raw[ c ],
								raw[ c + 1 ],
								raw[ c + 2 ]
							);

							break;

						case SEA3D.Animation.ROTATION:

							c = f * 4;

							qua.set(
								raw[ c ],
								raw[ c + 1 ],
								raw[ c + 2 ],
								raw[ c + 3 ]
							);

							break;

						case SEA3D.Animation.SCALE:

							c = f * 3;

							slc.set(
								raw[ c ],
								raw[ c + 1 ],
								raw[ c + 2 ]
							);

							break;
					}

				}

				buf1.compose( pos, qua, slc );

				this.flipMatrixScale(
					buf1, false, obj3d.animation.relative ? obj3d.matrixWorld :
					( obj3d.parent ? obj3d.parent.matrixWorld : undefined )
				);

				buf1.decompose( pos, qua, slc );

				for ( t = 0; t < t_anm.length; t ++ ) {

					var raw = t_anm[ t ].raw,
						kind = t_anm[ t ].kind;

					switch ( kind ) {
						case SEA3D.Animation.POSITION:

							c = f * 3;

							raw[ c ] = pos.x;
							raw[ c + 1 ] = pos.y;
							raw[ c + 2 ] = pos.z;

							break;

						case SEA3D.Animation.ROTATION:

							c = f * 4;

							raw[ c ] = qua.x;
							raw[ c + 1 ] = qua.y;
							raw[ c + 2 ] = qua.z;
							raw[ c + 3 ] = qua.w;

							break;

						case SEA3D.Animation.SCALE:

							c = f * 3;

							raw[ c ] = slc.x;
							raw[ c + 1 ] = slc.y;
							raw[ c + 2 ] = slc.z;

							break;
					}

				}

			}

		}

		anmSet.flip = true;

	}

}();


THREE.SEA3D.prototype.applyDefaultAnimation = function( sea, animatorClass ) {

	this._applyDefaultAnimation( sea, animatorClass );

	if ( this.isLegacy( sea ) && sea.tag.animation ) {

		this.updateAnimationSet( sea.tag );

	}

};

THREE.SEA3D.prototype.updateMatrix = function( obj3d ) {

	var buf1 = new THREE.Matrix4();
	var buf2 = new THREE.Matrix4();

	return function( obj3d ) {

		// convert to global

		buf1.copy( obj3d.matrixWorld );

		// flip matrix

		this.flipMatrixScale( buf1 );

		// convert to local

		buf2.copy( obj3d.parent.matrixWorld );

		this.flipMatrixScale( buf2, obj3d.parent instanceof THREE.Bone );

		buf2.getInverse( buf2 );

		buf1.multiplyMatrices( buf2, buf1 );

		this.applyMatrix( obj3d, buf1 );

	};

}();

THREE.SEA3D.prototype.updateTransform = function( obj3d, sea ) {

	var buf1 = new THREE.Matrix4();

	return function( obj3d, sea ) {

		if ( this.isLegacy( sea ) ) {

			if ( sea.transform ) buf1.elements.set( sea.transform );
			else buf1.makeTranslation( sea.position.x, sea.position.y, sea.position.z );

			this.applyMatrix( obj3d, buf1 );

			this.updateMatrix( obj3d );

		}
		else {

			this._updateTransform( obj3d, sea );

		}

	};

}();

THREE.SEA3D.prototype.readSkeleton = function( sea ) {

	var mtx_inv = new THREE.Matrix4(),
		mtx = new THREE.Matrix4(),
		mtx_loc = new THREE.Matrix4(),
		pos = new THREE.Vector3(),
		quat = new THREE.Quaternion();

	return function( sea ) {

		var bones = [];

		for ( var i = 0; i < sea.joint.length; i ++ ) {

			var bone = sea.joint[ i ]

			// get world inverse matrix

			mtx_inv.elements = bone.inverseBindMatrix;

			// convert to world matrix

			mtx.getInverse( mtx_inv );

			// convert to three.js order

			this.flipMatrix( mtx );

			if ( bone.parentIndex > - 1 ) {

				// to world

				mtx_inv.elements = sea.joint[ bone.parentIndex ].inverseBindMatrix;
				mtx_loc.getInverse( mtx_inv );

				// convert to three.js order

				this.flipMatrix( mtx_loc );

				// to local

				mtx_loc.getInverse( mtx_loc );

				mtx.multiplyMatrices( mtx_loc, mtx );

			}

			// mtx is local matrix

			pos.setFromMatrixPosition( mtx );
			quat.setFromRotationMatrix( mtx );

			bones[ i ] = {
				name: bone.name,
				pos: [ pos.x, pos.y, pos.z ],
				rotq: [ quat.x, quat.y, quat.z, quat.w ],
				parent: bone.parentIndex
			};

		}

		return sea.tag = bones;

	};

}();

THREE.SEA3D.prototype.getSkeletonAnimation = function( sea, skl ) {

	if ( this.isLegacy( sea ) ) return this.getLegacySkeletonAnimation( sea, skl );
	else return this._getSkeletonAnimation( sea, skl );

};

THREE.SEA3D.prototype.getLegacySkeletonAnimation = function( sea, skl ) {

	if ( sea.tag ) return sea.tag;

	var buf1 = new THREE.Matrix4();
	var buf2 = new THREE.Matrix4();

	var animations = [],
		delta = sea.frameRate / 1000,
		scale = [ 1, 1, 1 ],
		mtx_inv = new THREE.Matrix4();

	for ( var i = 0; i < sea.sequence.length; i ++ ) {

		var seq = sea.sequence[ i ];

		var start = seq.start;
		var end = start + seq.count;
		var ns = sea.name + "/" + seq.name;

		var animation = {
			name: ns,
			repeat: seq.repeat,
			fps: sea.frameRate,
			JIT: 0,
			length: delta * ( seq.count - 1 ),
			hierarchy: []
		}

		var numJoints = sea.numJoints,
			raw = sea.raw;

		for ( var j = 0; j < numJoints; j ++ ) {

			var bone = skl.joint[ j ],
				node = { parent: bone.parentIndex, keys: [] },
				keys = node.keys,
				time = 0;

			for ( var frame = start; frame < end; frame ++ ) {

				var idx = ( frame * numJoints * 7 ) + ( j * 7 );

				var mtx_global = buf1.makeRotationFromQuaternion( THREE.SEA3D.QUABUF.set( raw[ idx + 3 ], raw[ idx + 4 ], raw[ idx + 5 ], raw[ idx + 6 ] ) );
				mtx_global.setPosition( THREE.SEA3D.VECBUF.set( raw[ idx ], raw[ idx + 1 ], raw[ idx + 2 ] ) );

				if ( bone.parentIndex > - 1 ) {

					// to global

					mtx_inv.elements = skl.joint[ bone.parentIndex ].inverseBindMatrix;

					var mtx_rect = buf2.getInverse( mtx_inv );

					mtx_global.multiplyMatrices( mtx_rect, mtx_global );

					// convert to three.js matrix

					this.flipMatrix( mtx_global );

					// to local

					mtx_rect.getInverse( mtx_inv );

					this.flipMatrix( mtx_rect ); // flip parent inverse

					mtx_rect.getInverse( mtx_rect ); // reverse to normal direction

					mtx_global.multiplyMatrices( mtx_rect, mtx_global );

				}
				else {

					this.flipMatrix( mtx_global );

				}

				var posQ = THREE.SEA3D.VECBUF.setFromMatrixPosition( mtx_global );
				var newQ = THREE.SEA3D.QUABUF.setFromRotationMatrix( mtx_global );

				keys.push( {
					time: time,
					pos: [ posQ.x, posQ.y, posQ.z ],
					rot: [ newQ.x, newQ.y, newQ.z, newQ.w ],
					scl: scale
				} );

				time += delta;

			}

			animation.hierarchy[ j ] = node;

		}

		animations.push( animation );

	}

	return sea.tag = animations;

};

THREE.SEA3D.prototype.readVertexAnimation = function( sea ) {

	if ( this.isLegacy( sea ) ) {

		for ( var i = 0, l = sea.frame.length; i < l; i ++ ) {

			var frame = sea.frame[ i ];

			this.flipZVec3( frame.vertex );
			this.flipZVec3( frame.normal );

		}

	}

	this._readVertexAnimation( sea );

};

THREE.SEA3D.prototype.readGeometryBuffer = function( sea ) {

	if ( this.isLegacy( sea ) ) {

		this.flipZVec3( sea.vertex );
		this.flipZVec3( sea.normal );
		this.flipZIndex( sea.indexes );

		if ( sea.jointPerVertex > 4 ) this.compressJoints( sea );

	}

	this._readGeometryBuffer( sea );

};

THREE.SEA3D.prototype.readLines = function( sea ) {

	if ( this.isLegacy( sea ) ) {

		this.flipZVec3( sea.vertex );

	}

	this._readLines( sea );

};

THREE.SEA3D.prototype.onHead = function( args ) {

	// TODO: Ignore sign

};

THREE.SEA3D.EXTENSIONS.push( function() {

	this.file.typeRead[ SEA3D.Skeleton.prototype.type ] = this.readSkeleton;

} );
