/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeReflect = function() {
	
	THREE.NodeTemp.call( this, 'v3' );
	
	this.allow.vertex = false;
	
};

THREE.NodeReflect.prototype = Object.create( THREE.NodeTemp.prototype );
THREE.NodeReflect.prototype.constructor = THREE.NodeReflect;

THREE.NodeReflect.prototype.generate = function( builder, output ) {
	
	var material = builder.material;
	var data = material.getNodeData( this.uuid );
	
	material.needsWorldPosition = true;
	
	if (builder.isShader('fragment')) {
		
		material.addFragmentNode( [
			'vec3 cameraToVertex = normalize( vWPosition.xyz - cameraPosition );',
			'vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );',
			'vec3 vReflect = reflect( cameraToVertex, worldNormal );'
		].join( "\n" ) );
		
		return builder.format( 'vReflect', this.type, output );
		
	}

};