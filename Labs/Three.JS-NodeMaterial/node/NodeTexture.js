/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeTexture = function( value, coords ) {
	
	THREE.NodeInput.call( this, 'v4' );
	
	this.value = value;
	this.coords = coords || new THREE.NodeUV();
	
};

THREE.NodeTexture.prototype = Object.create( THREE.NodeInput.prototype );
THREE.NodeTexture.prototype.constructor = THREE.NodeTexture;

THREE.NodeTexture.prototype.getTemp = THREE.NodeTemp.prototype.getTemp;

THREE.NodeTexture.prototype.build = function( material, shader, output, uuid ) {
	
	return THREE.NodeTemp.prototype.build.call( this, material, shader, output, uuid );
	
};

THREE.NodeTexture.prototype.generate = function( material, shader, output ) {

	var tex = THREE.NodeInput.prototype.generate.call( this, material, shader, output, this.value.uuid, 't' );
	var coords = this.coords.build( material, shader, 'v2' );
	
	return this.format( 'texture2D(' + tex + ',' + coords + ')', this.type, output );

};
