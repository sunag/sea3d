/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodePosition = function( scope ) {
	
	THREE.NodeReference.call( this, 'v3' );
	
	this.scope = scope || THREE.NodePosition.LOCAL;
	
};

THREE.NodePosition.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodePosition.prototype.constructor = THREE.NodePosition;

THREE.NodePosition.LOCAL = 'local';
THREE.NodePosition.WORLD = 'world';
THREE.NodePosition.VIEW = 'view';
THREE.NodePosition.PROJECTION = 'projection';

THREE.NodePosition.prototype.getType = function( builder ) {
	
	switch(this.method) {
		case THREE.NodePosition.PROJECTION:
			return 'v4';
	}
	
	return this.type;
	
};

THREE.NodePosition.prototype.generate = function( builder, output ) {
	
	var material = builder.material;
	
	switch (this.scope) {
	
		case THREE.NodePosition.LOCAL:
	
			material.requestAttrib.position = true;
			
			if (builder.isShader('vertex')) this.name = 'transformed';
			else this.name = 'vPosition';
			
			break;
			
		case THREE.NodePosition.WORLD:
	
			material.requestAttrib.worldPosition = true;
			
			if (builder.isShader('vertex')) this.name = 'vWPosition';
			else this.name = 'vWPosition';
			
			break;
			
		case THREE.NodePosition.VIEW:
	
			if (builder.isShader('vertex')) this.name = '-mvPosition.xyz';
			else this.name = 'vViewPosition';
			
			break;
			
		case THREE.NodePosition.PROJECTION:
	
			if (builder.isShader('vertex')) this.name = '(projectionMatrix * modelViewMatrix * vec4( position, 1.0 ))';
			else this.name = 'vec4( 0.0 )';
			
			break;
			
	}
	
	return THREE.NodeReference.prototype.generate.call( this, builder, output );

};