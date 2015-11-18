/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeCubeTexture = function( value, coords ) {
	
	THREE.NodeInput.call( this, 'v4' );
	
	this.allow.vertex = false;
	
	this.value = value;
	this.coords = coords || new THREE.NodeReflect();
	
};

THREE.NodeCubeTexture.prototype = Object.create( THREE.NodeInput.prototype );
THREE.NodeCubeTexture.prototype.constructor = THREE.NodeCubeTexture;

THREE.NodeCubeTexture.prototype.generate = function( material, shader, output ) {

	var cubetex = THREE.NodeInput.prototype.generate.call( this, material, shader, output, this.value.uuid, 't' );
	var coords = this.coords.build( material, shader, 'v3' );
	
	return this.format('textureCube(' + cubetex + ', ' + coords + ')', this.type, output );

};