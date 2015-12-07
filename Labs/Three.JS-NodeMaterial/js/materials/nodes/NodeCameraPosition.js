/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeCameraPosition = function() {
	
	THREE.NodeReference.call( this, 'v3', 'cameraPosition' );
	
	this.allow.vertex = false;
	
};

THREE.NodeCameraPosition.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeCameraPosition.prototype.constructor = THREE.NodeCameraPosition;