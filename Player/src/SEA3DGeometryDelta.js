/**
 * 	SEA3D - Delta Lossy Compression
 * 	@author Sunag / http://www.sunag.com.br/
 */

'use strict';

//
//	Geometry Delta
//

SEA3D.GeometryDelta = function( name, data, sea3d ) {

	var i, j, start, delta, len, vec;

	this.name = name;
	this.data = data;
	this.sea3d = sea3d;

	this.attrib = data.readUShort();

	this.numVertex = data.readUInteger();

	this.isBig = this.numVertex > 0xFFFE;

	this.length = this.numVertex * 3;

	if ( this.attrib & 1 ) {

		data.readNumber = data.readByte;
		this.numDiv = 0xFF / 2;

	}
	else {

		data.readNumber = data.readShort;
		this.numDiv = 0xFFFF / 2;

	}

	// NORMAL
	if ( this.attrib & 4 ) {

		delta = data.readFloat();
		this.normal = new Float32Array( this.length );

		i = 0;
		while ( i < this.length ) {

			this.normal[ i ++ ] = ( data.readNumber() / this.numDiv ) * delta;

		}

	}

	// TANGENT
	if ( this.attrib & 8 ) {

		delta = data.readFloat();
		this.tangent = new Float32Array( this.length );

		i = 0;
		while ( i < this.length ) {

			this.tangent[ i ++ ] = ( data.readNumber() / this.numDiv ) * delta;

		}

	}

	// UV
	if ( this.attrib & 32 ) {

		this.uv = [];
		this.uv.length = data.readUByte();

		var uvLen = this.numVertex * 2;

		i = 0;
		while ( i < this.uv.length ) {

			// UV VERTEX DATA
			delta = data.readFloat();
			this.uv[ i ++ ] = vec = new Float32Array( uvLen );

			j = 0;
			while ( j < uvLen ) {

				vec[ j ++ ] = ( data.readNumber() / this.numDiv ) * delta;

			}

		}

	}

	// JOINT-INDEXES / WEIGHTS
	if ( this.attrib & 64 ) {

		this.jointPerVertex = data.readUByte();

		var jntLen = this.numVertex * this.jointPerVertex;

		this.joint = new Uint16Array( jntLen );
		this.weight = new Float32Array( jntLen );

		i = 0;
		while ( i < jntLen ) {

			this.joint[ i ++ ] = data.readUInteger();

		}

		i = 0;
		while ( i < jntLen ) {

			this.weight[ i ++ ] = data.readNumber() / this.numDiv;

		}

	}

	// VERTEX_COLOR
	if ( this.attrib & 128 ) {

		var colorAttrib = data.readUByte(),
			numColorData = ( ( ( colorAttrib & 64 ) >> 6 ) | ( ( colorAttrib & 128 ) >> 6 ) ) + 1,
			colorCount = this.numVertex * 4;

		this.color = [];
		this.color.length = colorAttrib & 15;

		this.numColor = 4;

		for ( i = 0; i < this.color.length; i ++ ) {

			var vColor = new Float32Array( colorCount );

			switch ( numColorData )
			{
				case 1:
					j = 0;
					while ( j < colorCount ) {

						vColor[ j ++ ] = data.readUByte() / 0xFF;
						vColor[ j ++ ] = 0;
						vColor[ j ++ ] = 0;
						vColor[ j ++ ] = 1;

					}
					break;

				case 2:
					j = 0;
					while ( j < colorCount ) {

						vColor[ j ++ ] = data.readUByte() / 0xFF;
						vColor[ j ++ ] = data.readUByte() / 0xFF;
						vColor[ j ++ ] = 0;
						vColor[ j ++ ] = 1;

					}
					break;

				case 3:
					j = 0;
					while ( j < colorCount ) {

						vColor[ j ++ ] = data.readUByte() / 0xFF;
						vColor[ j ++ ] = data.readUByte() / 0xFF;
						vColor[ j ++ ] = data.readUByte() / 0xFF;
						vColor[ j ++ ] = 1;

					}
					break;

				case 4:
					j = 0;
					while ( j < colorCount ) {

						vColor[ j ++ ] = data.readUByte() / 0xFF;
						vColor[ j ++ ] = data.readUByte() / 0xFF;
						vColor[ j ++ ] = data.readUByte() / 0xFF;
						vColor[ j ++ ] = data.readUByte() / 0xFF;

					}
					break;
			}

			this.color[ i ] = vColor;

		}

	}

	// VERTEX
	delta = data.readFloat();

	this.vertex = new Float32Array( this.length );

	i = 0;
	while ( i < this.length ) {

		this.vertex[ i ++ ] = ( data.readNumber() / this.numDiv ) * delta;

	}

	// SUB-MESHES
	var count = data.readUByte();

	this.groups = [];

	vec = [];

	// INDEXES
	if ( this.attrib & 2 ) {

		// POLYGON
		for ( i = 0; i < count; i ++ ) {

			len = data.readUInteger();

			start = vec.length;

			for ( j = 0; j < len; j ++ ) {

				var a = data.readUInteger(),
					b = data.readUInteger(),
					c = data.readUInteger(),
					d = data.readUInteger();

				vec.push( a, b, c );

				if ( d > 0 ) vec.push( c, d + 1, a );
				else continue;

			}

			this.groups.push( {
				start : start,
				count : vec.length - start,
			} );

		}

	} else {

		// TRIANGLE
		j = 0;
		for ( i = 0; i < count; i ++ ) {

			len = data.readUInteger() * 3;

			this.groups.push( {
				start : j,
				count : len,
			} );

			len += j;
			while ( j < len ) {

				vec[ j ++ ] = data.readUInteger();

			}

		}

	}

	this.indexes = this.isBig ? new Uint32Array( vec ) : new Uint16Array( vec );

};

SEA3D.GeometryDelta.prototype.type = "geDL";

//
//	Extension
//

THREE.SEA3D.EXTENSIONS_LOADER.push( {

	setTypeRead : function() {

		this.file.addClass( SEA3D.GeometryDelta, true );

		this.file.typeRead[ SEA3D.GeometryDelta.prototype.type ] = this.readGeometryBuffer;

	}

} );
