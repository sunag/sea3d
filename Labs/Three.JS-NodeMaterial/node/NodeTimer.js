/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeTimer = function( value ) {
	
	THREE.NodeFloat.call( this, value );
	
	this.allow.requestUpdate = true;
	
};

THREE.NodeTimer.prototype = Object.create( THREE.NodeFloat.prototype );
THREE.NodeTimer.prototype.constructor = THREE.NodeTimer;

THREE.NodeTimer.prototype.updateAnimation = function( delta ) {
	
	this.number += delta;
	
};