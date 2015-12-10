/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeUV = function( index ) {
	
	THREE.NodeReference.call( this, 'v2' );
	
	this.index = index || 0;
	
};

THREE.NodeUV.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeUV.prototype.constructor = THREE.NodeUV;

THREE.NodeUV.vertexDict = ['uv', 'uv2'];
THREE.NodeUV.fragmentDict = ['vUv', 'vUv2'];

THREE.NodeUV.prototype.generate = function( builder, output ) {
	
	var material = builder.material;
	
	material.requestAttrib.uv[this.index] = true; 
	
	if (builder.isShader('vertex')) this.name = THREE.NodeUV.vertexDict[this.index];
	else this.name = THREE.NodeUV.fragmentDict[this.index];
	
	return THREE.NodeReference.prototype.generate.call(this, builder, output);

};
