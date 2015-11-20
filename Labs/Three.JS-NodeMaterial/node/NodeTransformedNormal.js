/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeTransformedNormal = function() {
	
	THREE.NodeReference.call( this, 'v3' );
	
};

THREE.NodeTransformedNormal.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeTransformedNormal.prototype.constructor = THREE.NodeTransformedNormal;

THREE.NodeTransformedNormal.prototype.generate = function( builder, output ) {
	
	var material = builder.material;
	
	material.needsTransformedNormal = true;
	
	if (builder.isShader('vertex')) this.name = 'normal';
	else this.name = 'vTransformedNormal';
	
	return THREE.NodeReference.prototype.generate.call( this, builder, output );

};
