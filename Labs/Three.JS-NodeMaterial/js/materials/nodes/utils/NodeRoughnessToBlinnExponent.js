/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeRoughnessToBlinnExponent = function() {
	
	THREE.NodeTemp.call( this, 'fv1' );
	
	this.allow.vertex = false;
	
};

THREE.NodeRoughnessToBlinnExponent.prototype = Object.create( THREE.NodeTemp.prototype );
THREE.NodeRoughnessToBlinnExponent.prototype.constructor = THREE.NodeRoughnessToBlinnExponent;

THREE.NodeRoughnessToBlinnExponent.prototype.generate = function( builder, output ) {
	
	var material = builder.material;
	var data = material.getNodeData( this.uuid );
	
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
		
		return builder.format( 'specularMIPLevel', this.type, output );
		
	}

};