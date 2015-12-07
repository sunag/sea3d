/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeNormal = function() {
	
	THREE.NodeReference.call( this, 'v3' );
	
};

THREE.NodeNormal.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeNormal.prototype.constructor = THREE.NodeNormal;

THREE.NodeNormal.prototype.generate = function( builder, output ) {
	
	var material = builder.material;
	
	material.needsNormal = true;
	
	if (builder.isShader('vertex')) this.name = 'normal';
	else this.name = 'vObjectNormal';
	
	return THREE.NodeReference.prototype.generate.call( this, builder, output );

};
