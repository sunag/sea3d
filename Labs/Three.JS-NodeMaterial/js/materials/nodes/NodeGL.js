/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeGL = function( type ) {
	
	this.uuid = THREE.Math.generateUUID();
	this.allow = {};
	
	this.type = type;
	
};

THREE.NodeGL.prototype.verify = function( builder ) {
	
	builder.isVerify = true;
	
	var material = builder.material;
	
	this.build( builder, 'v4' );
	
	material.clearVertexNode();
	material.clearFragmentNode();
	
	builder.setCache(); // reset cache
	
	builder.isVerify = false;

};

THREE.NodeGL.prototype.verifyAndBuildCode = function( builder, output, cache ) {
	
	this.verify( builder.setCache(cache) );
	
	return this.buildCode( builder.setCache(cache), output );
	
};

THREE.NodeGL.prototype.buildCode = function( builder, output, uuid ) {
	
	var material = builder.material;
	var data = { result : this.build( builder, output, uuid ) };
	
	if (builder.isShader('vertex')) data.code = material.clearVertexNode();
	else data.code = material.clearFragmentNode();
	
	builder.setCache(); // reset cache
	
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

THREE.NodeGL.prototype.build = function( builder, output, uuid ) {

	var material = builder.material;
	var data = material.getNodeData( uuid || this.uuid );
	
	if (builder.isShader('verify')) this.verifyNodeDeps( data, output );
	
	if (this.allow[builder.shader] === false) {
		throw new Error( 'Shader ' + shader + ' is not compatible with this node.' );
	}
	
	if (this.allow.requestUpdate && !data.requestUpdate) {
		material.requestUpdate.push( this );
		data.requestUpdate = true;
	}
	
	return this.generate( builder, output, uuid );
	
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
		case 'v2=v3': return 'vec3(' + code + ',0.0)';
		case 'v2=v4': return 'vec4(' + code + ',0.0,0.0)';
		
		case 'v3=v1': return code + '.x';
		case 'v3=v2': return code + '.xy';
		case 'v3=v4': return 'vec4(' + code + ',0.0)';
		
		case 'v4=v1': return code + '.x';
		case 'v4=v2': return code + '.xy';
		case 'v4=v3': return code + '.xyz';
	}
	
	return code;

};

THREE.NodeGL.formatConstructor = ['', 'vec2', 'vec3', 'vec4'];