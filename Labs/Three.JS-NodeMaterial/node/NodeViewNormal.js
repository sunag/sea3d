/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeViewNormal = function() {
	
	THREE.NodeReference.call( this, 'v3' );
	
};

THREE.NodeViewNormal.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeViewNormal.prototype.constructor = THREE.NodeViewNormal;

THREE.NodeViewNormal.prototype.generate = function( material, shader, output ) {
	
	if (shader == 'vertex') this.name = 'normal';
	else this.name = 'vNormal';
	
	return THREE.NodeReference.prototype.generate.call( this, material, shader, output );

};