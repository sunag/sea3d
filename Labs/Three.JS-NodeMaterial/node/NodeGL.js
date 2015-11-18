/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeGL = function( type ) {
	
	this.uuid = THREE.Math.generateUUID();
	this.allow = {};
	
	this.type = type;
	
};

THREE.NodeGL.prototype.verify = function( material ) {
	
	this.build( material, 'verify', 'v4' );
	
	material.clearVertexNode();
	material.clearFragmentNode();

};

THREE.NodeGL.prototype.verifyAndBuildCode = function( material, shader, output, uuid ) {

	this.verify( material );
	
	return this.buildCode( material, shader, output, uuid );
	
};

THREE.NodeGL.prototype.buildCode = function( material, shader, output, uuid ) {
	
	var data = { result : this.build( material, shader, output, uuid ) };
	
	if (shader == 'vertex') data.code = material.clearVertexNode();
	else data.code = material.clearFragmentNode();
	
	return data;

};

THREE.NodeGL.prototype.verifyNodeDeps = function( data, output ) {
	
	data.deps = (data.deps || 0) + 1;
	
	var outputLen = this.getFormatLength( this.getFormat(output) );
	
	if (outputLen > data.outputMax || this.getType()) {
		
		data.outputMax = outputLen;
		data.output = output;
		
	}

};

THREE.NodeGL.prototype.build = function( material, shader, output, uuid ) {

	var data = material.getNodeData( uuid || this.uuid );
	
	if (shader == 'verify') this.verifyNodeDeps( data, output );
	
	if (this.allow[shader] === false) {
		throw new Error( 'Shader ' + shader + ' is not compatible with this node.' );
	}
	
	if (this.allow.requestUpdate && !data.requestUpdate) {
		material.requestUpdate.push( this );
		data.requestUpdate = true;
	}
	
	return this.generate( material, shader, output, uuid );
	
};

THREE.NodeGL.prototype.getType = function() {

	return this.type;
	
};

THREE.NodeGL.prototype.getFormat = function(str) {
	
	return str.replace('c','v3').replace(/fv1|iv1/, 'v1');
	
};

THREE.NodeGL.prototype.getFormatLength = function(str) {
	
	return parseInt( this.getFormat(str).substr(1) );

};

THREE.NodeGL.prototype.getFormatByLength = function(len) {
	
	if (len == 1) return 'fv1';
	return 'v' + len;

};

THREE.NodeGL.prototype.getFormatConstructor = function(len) {
	
	return THREE.NodeGL.formatConstructor[len-1];

};

THREE.NodeGL.prototype.format = function(code, from, to) {
	
	var format = this.getFormat(from + '=' + to);
	
	switch ( format ) {
		case 'v1=v2': return 'vec2(' + code + ')';
		case 'v1=v3': return 'vec3(' + code + ')';
		case 'v1=v4': return 'vec4(' + code + ')';
		
		case 'v2=v1': return code + '.x';
		case 'v2=v3': return 'vec3(' + code + ',0.)';
		case 'v2=v4': return 'vec4(' + code + ',0.,0.)';
		
		case 'v3=v1': return code + '.x';
		case 'v3=v2': return code + '.xy';
		case 'v3=v4': return 'vec4(' + code + ',0.)';
		
		case 'v4=v1': return code + '.x';
		case 'v4=v2': return code + '.xy';
		case 'v4=v3': return code + '.xyz';
	}
	
	return code;

};


THREE.NodeGL.prototype.generate = function( material, shader ) {
	
	if (shader == 'vertex') {
		
		return 'gl_Position = ' + this.value.generate( material, shader, output ) + ';';
		
	}
	else {
		
		return 'gl_FragColor = ' + this.value.generate( material, shader, output ) + ';';
	
	}

};

THREE.NodeGL.formatConstructor = ['', 'vec2', 'vec3', 'vec4'];