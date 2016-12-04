/**
 * 	SEA3D Builder
 * 	@author Sunag / http://www.sunag.com.br/
 */

'use strict';

//
//	BUILDER
//

THREE.SEA3D.Builder = function() {
	
	
	
};

//
//	STREAM WRITER
//

SEA3D.Stream.concat = function(buffer1, buffer2) {

	var tmp = new Uint8Array(buffer1.byteLength + buffer2.byteLength);

	tmp.set(new Uint8Array(buffer1), 0);
	tmp.set(new Uint8Array(buffer2), buffer1.byteLength);

	return tmp.buffer;
};

SEA3D.Stream.stringToBuffer = function( str ) {

	if (window.TextEncoder) {
		
		return new TextEncoder().encode( str ).buffer;
		
	} else {

		str = unescape( encodeURIComponent( str ) );
		
		var bytes = new Uint8Array( str.length );

		for (var i = 0, len = str.length; i < len; i++) {

			bytes[i] = str.charCodeAt( i ) & 0xFF;

		}

		return bytes.buffer;

	}

};

SEA3D.Stream.prototype.appendBuffer = function( data ) {

	this.buf = SEA3D.Stream.concat( this.buf, data.buffer );

};

SEA3D.Stream.prototype.writeBytes = function( buffer ) {

	this.buf = SEA3D.Stream.concat( this.buf, buffer );
	this.position += buffer.byteLength;

};

SEA3D.Stream.prototype.writeByte = function( val ) {

	return this.writeBytes( new Uint8Array([ val ]).buffer );

};

SEA3D.Stream.prototype.writeBool = function( val ) {

	return this.writeByte( val ? 1 : 0 );

};

SEA3D.Stream.prototype.writeUInt = function( val ) {
	
	return this.writeBytes( new Uint32Array([ val ]).buffer );

};

SEA3D.Stream.prototype.writeUTF8 = function( str ) {

	return this.writeBytes( SEA3D.Stream.stringToBuffer( str ) );

};

SEA3D.Stream.prototype.writeUTF8Tiny = function( str ) {
	
	var buffer = SEA3D.Stream.stringToBuffer( str );
	
	this.writeByte( buffer.byteLength );
	
	return this.writeBytes( buffer );

};

SEA3D.Stream.prototype.writeUTF8Long = function( str ) {
	
	var buffer = SEA3D.Stream.stringToBuffer( str );
	
	this.writeUInt( buffer.byteLength );
	
	return this.writeBytes( buffer );

};
