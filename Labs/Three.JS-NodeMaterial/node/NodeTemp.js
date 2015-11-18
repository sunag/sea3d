/**
 * Automatic node cache
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeTemp = function( type ) {
	
	THREE.NodeGL.call( this, type );
	
};

THREE.NodeTemp.prototype = Object.create( THREE.NodeGL.prototype );
THREE.NodeTemp.prototype.constructor = THREE.NodeTemp;

THREE.NodeTemp.prototype.build = function( material, shader, output, uuid ) {
	
	var data = material.getNodeData( uuid || this.uuid );
	
	if (shader == 'verify') {
		if (data.deps || 0 > 0) {
			this.verifyNodeDeps( data, output );
			return '';
		}
		return THREE.NodeGL.prototype.build.call( this, material, shader, output, uuid );
	}
	else if (data.deps == 1) {
		return THREE.NodeGL.prototype.build.call( this, material, shader, output, uuid );
	}
	
	var name = this.getTemp( material, shader, uuid );
	var type = data.output || this.getType();
	
	if (name) {
	
		return this.format( name, type, output );
		
	}
	else {
		
		name = THREE.NodeTemp.prototype.generate.call( this, material, shader, output, uuid, data.output );
		
		var code = this.generate( material, shader, type, uuid );
		
		if (shader == 'vertex') material.addVertexNode(name + '=' + code + ';');
		else material.addFragmentNode(name + '=' + code + ';');
		
		return this.format( name, type, output );
	
	}
	
};

THREE.NodeTemp.prototype.getTemp = function( material, shader, uuid ) {
	
	uuid = uuid || this.uuid;
	
	if (shader == 'vertex' && material.vertexTemps[ uuid ]) return material.vertexTemps[ uuid ].name;
	else if (material.fragmentTemps[ uuid ]) return material.fragmentTemps[ uuid ].name;

};

THREE.NodeTemp.prototype.generate = function( material, shader, output, uuid, type ) {
	
	uuid = uuid || this.uuid;
	
	if (shader == 'vertex') return material.getVertexTemp( uuid, type || this.getType() ).name;
	else return material.getFragmentTemp( uuid, type || this.getType() ).name;

};