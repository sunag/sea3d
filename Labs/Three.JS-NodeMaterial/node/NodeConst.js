/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeConst = function(name) {
	
	THREE.NodeReference.call( this, 'fv1', name || THREE.NodeConst.PI );
	
};

THREE.NodeConst.PI = 'PI';
THREE.NodeConst.PI2 = 'PI2';
THREE.NodeConst.RECIPROCAL_PI = 'RECIPROCAL_PI';
THREE.NodeConst.RECIPROCAL_PI2 = 'RECIPROCAL_PI2';
THREE.NodeConst.LOG2 = 'LOG2';
THREE.NodeConst.EPSILON = 'EPSILON';

THREE.NodeConst.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeConst.prototype.constructor = THREE.NodeConst;