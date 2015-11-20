/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeProjectPosition = function() {
	
	THREE.NodeTemp.call( this, 'v4' );
	
};

THREE.NodeProjectPosition.prototype = Object.create( THREE.NodeTemp.prototype );
THREE.NodeProjectPosition.prototype.constructor = THREE.NodeGLPosition;

THREE.NodeProjectPosition.prototype.generate = function( config ) {

	if (builder.isShader('vertex')) {
	
		return '(projectionMatrix * modelViewMatrix * vec4( position, 1.0 ))';
		
	}
	else {
	
		return 'vec4( 0.0 )';
		
	}

};