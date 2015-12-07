/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeSpecularMIPLevel = function() {
	
	THREE.NodeTemp.call( this, 'fv1' );
	
	this.allow.vertex = false;
	
};

THREE.NodeSpecularMIPLevel.prototype = Object.create( THREE.NodeTemp.prototype );
THREE.NodeSpecularMIPLevel.prototype.constructor = THREE.NodeSpecularMIPLevel;

THREE.NodeSpecularMIPLevel.prototype.generate = function( builder, output ) {
	
	var material = builder.material;
	var data = material.getNodeData( this.uuid );
	
	material.needsWorldPosition = true;
	
	if (builder.isShader('fragment')) {
		
		if (material.isDefined('STANDARD')) {
		
			material.addFragmentNode([
				'float specularMIPLevel = GGXRoughnessToBlinnExponent( 1.0 - material.specularRoughness );'
				//'float specularMIPLevel = getSpecularMIPLevel( material.specularRoughness, 8 );'
			].join( "\n" ) );
			
		}
		else {
		
			material.addFragmentNode([
				'float specularMIPLevel = 0.0;'
			].join( "\n" ) );
		
		}
		
		return this.format( 'specularMIPLevel', this.type, output );
		
	}

};