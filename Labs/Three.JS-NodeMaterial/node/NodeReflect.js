/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeReflect = function() {
	
	THREE.NodeTemp.call( this, 'v3' );
	
	this.allow.vertex = false;
	
};

THREE.NodeReflect.prototype = Object.create( THREE.NodeTemp.prototype );
THREE.NodeReflect.prototype.constructor = THREE.NodeReflect;

THREE.NodeReflect.prototype.generate = function( material, shader, output ) {
	
	var data = material.getNodeData( this.uuid );
	
	material.needsWorldPosition = true;
	
	if (shader != 'vertex') {
		
		material.addFragmentNode( [
			'vec3 cameraToVertex = normalize( vWorldPosition2.xyz - cameraPosition );',
			'vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );',
			'vec3 vReflect = reflect( cameraToVertex, worldNormal );'
		].join( "\n" ) );
		
		return this.format( 'vReflect', this.type, output );
		
	}

};