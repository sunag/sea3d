/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeCamera = function( scope ) {
	
	THREE.NodeReference.call( this, 'v3' );
	
	this.scope = scope || THREE.NodeCamera.POSITION;
	
};

THREE.NodeCamera.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeCamera.prototype.constructor = THREE.NodeCamera;

THREE.NodeCamera.POSITION = 'position';

THREE.NodeCamera.prototype.generate = function( builder, output ) {
	
	switch (this.scope) {
	
		case THREE.NodeCamera.POSITION:
	
			if (builder.isShader('vertex')) this.name = 'cameraPosition';
			else this.name = 'cameraPosition';
			
			break;
			
	}
	
	return THREE.NodeReference.prototype.generate.call( this, builder, output );

};