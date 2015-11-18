/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeInput = function(type) {
	
	THREE.NodeGL.call( this, type );
	
};

THREE.NodeInput.prototype = Object.create( THREE.NodeGL.prototype );
THREE.NodeInput.prototype.constructor = THREE.NodeInput;

THREE.NodeInput.prototype.generate = function( material, shader, output, uuid, type ) {

	uuid = uuid || this.uuid;
	type = type || this.type;
	
	var data = material.getNodeData( uuid );
	
	if (shader == 'vertex') {
	
		if (!data.vertex) {
		
			data.vertex = material.getVertexUniform( this.value, type );
			
		}
		
		return this.format( data.vertex.name, type, output );
	}
	else {
		
		if (!data.fragment) { 
			
			data.fragment = material.getFragmentUniform( this.value, type );
			
		}
		
		return this.format( data.fragment.name, type, output );
	}

};