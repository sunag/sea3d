/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeConst = function(name) {
	
	THREE.NodeReference.call( this, 'fv1', name || THREE.NodeConst.PI );
	
};

THREE.NodeConst.PI = 'PI';

THREE.NodeConst.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeConst.prototype.constructor = THREE.NodeConst;