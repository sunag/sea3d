/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeViewPosition = function() {
	
	THREE.NodeReference.call( this, 'v3' );
	
};

THREE.NodeViewPosition.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeViewPosition.prototype.constructor = THREE.NodeViewPosition;

THREE.NodeViewPosition.prototype.generate = function( material, shader, output ) {
	
	if (shader == 'vertex') this.name = 'vec3(0)';
	else this.name = 'vViewPosition';
	
	return THREE.NodeReference.prototype.generate.call( this, material, shader, output );

};