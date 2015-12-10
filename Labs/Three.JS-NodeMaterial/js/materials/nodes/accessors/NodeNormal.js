/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeNormal = function( scope ) {
	
	THREE.NodeReference.call( this, 'v3' );
	
	this.scope = scope || THREE.NodeNormal.LOCAL;
	
};

THREE.NodeNormal.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeNormal.prototype.constructor = THREE.NodeNormal;

THREE.NodeNormal.LOCAL = 'local';
THREE.NodeNormal.WORLD = 'world';
THREE.NodeNormal.VIEW = 'view';

THREE.NodeNormal.prototype.generate = function( builder, output ) {
	
	var material = builder.material;
	
	switch (this.scope) {
	
		case THREE.NodeNormal.LOCAL:
	
			material.requestAttrib.normal = true;
	
			if (builder.isShader('vertex')) this.name = 'normal';
			else this.name = 'vObjectNormal';
			
			break;
			
		case THREE.NodeNormal.WORLD:
	
			material.requestAttrib.worldNormal = true;
			
			if (builder.isShader('vertex')) this.name = '( modelMatrix * vec4( objectNormal, 0.0 ) ).xyz';
			else this.name = 'vWNormal';
			
			break;
			
		case THREE.NodeNormal.VIEW:
	
			this.name = 'vNormal';
			
			break;
			
	}
	
	return THREE.NodeReference.prototype.generate.call( this, builder, output );

};
