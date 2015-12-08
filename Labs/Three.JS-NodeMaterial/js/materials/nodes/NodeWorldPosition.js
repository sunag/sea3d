/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeWorldPosition = function() {
	
	THREE.NodeReference.call( this, 'v3' );
	
};

THREE.NodeWorldPosition.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeWorldPosition.prototype.constructor = THREE.NodeWorldPosition;

THREE.NodeWorldPosition.prototype.generate = function( builder, output ) {
	
	builder.material.needsWorldPosition = true;
	
	if (builder.isShader('vertex')) this.name = 'worldPosition.xyz';
	else this.name = 'vWPosition';
	
	return THREE.NodeReference.prototype.generate.call( this, builder, output );

};