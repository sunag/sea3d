/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodePhongMaterial = function() {
	
	this.phong = new THREE.NodePhong();
	
	THREE.NodeMaterial.call( this, this.phong, this.phong );
	
};

THREE.NodePhongMaterial.prototype = Object.create( THREE.NodeMaterial.prototype );
THREE.NodePhongMaterial.prototype.constructor = THREE.NodePhongMaterial;

THREE.NodeMaterial.Shortcuts( THREE.NodePhongMaterial.prototype, 'phong', 
[ 'color',  'alpha', 'specular', 'shininess', 'normal', 'normalScale', 'emissive', 'ambient', 'shadow', 'ao', 'environment', 'reflectivity', 'transform' ] );