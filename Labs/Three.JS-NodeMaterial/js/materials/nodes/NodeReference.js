/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeReference = function( type, name ) {
	
	THREE.NodeGL.call( this, type );
	
	this.name = name;
	
};

THREE.NodeReference.prototype = Object.create( THREE.NodeGL.prototype );
THREE.NodeReference.prototype.constructor = THREE.NodeReference;

THREE.NodeReference.prototype.generate = function( builder, output ) {
	
	return this.format( this.name, this.type, output );

};