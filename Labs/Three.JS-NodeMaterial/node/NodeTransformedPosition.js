/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeTransformedPosition = function() {
	
	THREE.NodeReference.call( this, 'v3' );
	
};

THREE.NodeTransformedPosition.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeTransformedPosition.prototype.constructor = THREE.NodeTransformedPosition;

THREE.NodeTransformedPosition.prototype.generate = function( material, shader, output ) {
	
	material.needsPosition = true;
	
	if (shader == 'vertex') this.name = 'transformed';
	else this.name = 'vPosition';
	
	return THREE.NodeReference.prototype.generate.call( this, material, shader, output );

};