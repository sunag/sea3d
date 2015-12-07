/**
 * Automatic node cache
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeTemp = function( type ) {
	
	THREE.NodeGL.call( this, type );
	
};

THREE.NodeTemp.prototype = Object.create( THREE.NodeGL.prototype );
THREE.NodeTemp.prototype.constructor = THREE.NodeTemp;

THREE.NodeTemp.prototype.build = function( builder, output, uuid ) {
	
	var material = builder.material;
	
	uuid = builder.getUuid( uuid || this.uuid );
	
	var data = material.getNodeData( uuid );
	
	if (builder.isShader('verify')) {
		if (data.deps || 0 > 0) {
			this.verifyNodeDeps( data, output );
			return '';
		}
		return THREE.NodeGL.prototype.build.call( this, builder, output, uuid );
	}
	else if (data.deps == 1) {
		return THREE.NodeGL.prototype.build.call( this, builder, output, uuid );
	}
	
	var name = this.getTemp( builder, uuid );
	var type = data.output || this.getType();
	
	if (name) {
	
		return this.format( name, type, output );
		
	}
	else {
		
		name = THREE.NodeTemp.prototype.generate.call( this, builder, output, uuid, data.output );
		
		var code = this.generate( builder, type, uuid );
		
		if (builder.isShader('vertex')) material.addVertexNode(name + '=' + code + ';');
		else material.addFragmentNode(name + '=' + code + ';');
		
		return this.format( name, type, output );
	
	}
	
};

THREE.NodeTemp.prototype.getTemp = function( builder, uuid ) {
	
	uuid = uuid || this.uuid;
	
	var material = builder.material;
	
	if (builder.isShader('vertex') && material.vertexTemps[ uuid ]) return material.vertexTemps[ uuid ].name;
	else if (material.fragmentTemps[ uuid ]) return material.fragmentTemps[ uuid ].name;

};

THREE.NodeTemp.prototype.generate = function( builder, output, uuid, type ) {
	
	uuid = uuid || this.uuid;
	
	if (builder.isShader('vertex')) return builder.material.getVertexTemp( uuid, type || this.getType() ).name;
	else return builder.material.getFragmentTemp( uuid, type || this.getType() ).name;

};