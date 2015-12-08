/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodePosition = function() {
	
	THREE.NodeReference.call( this, 'v3' );
	
};

THREE.NodePosition.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodePosition.prototype.constructor = THREE.NodePosition;

THREE.NodePosition.prototype.generate = function( builder, output ) {
	
	builder.material.needsPosition = true;
	
	if (builder.isShader('vertex')) this.name = 'vec3(0)';
	else this.name = 'vPosition';
	
	return THREE.NodeReference.prototype.generate.call( this, builder, output );

};