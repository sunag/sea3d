/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeMaterial = function( vertex, fragment ) {
	
	THREE.ShaderMaterial.call( this );
	
	this.vertex = vertex || new THREE.NodeGL( new THREE.NodeProjectPosition() );
	this.fragment = fragment || new THREE.NodeGL( new THREE.NodeColor( 0xFF0000 ) );
	
};

THREE.NodeMaterial.prototype = Object.create( THREE.ShaderMaterial.prototype );
THREE.NodeMaterial.prototype.constructor = THREE.NodeMaterial;

THREE.NodeMaterial.Type = {
	t : 'sampler2D',
	tc : 'samplerCube',
	bv1 : 'bool',
	iv1 : 'int',
	fv1 : 'float',
	c : 'vec3',
	v2 : 'vec2',
	v3 : 'vec3',
	v4 : 'vec4'
};

THREE.NodeMaterial.GetShortcuts = function( prop, name ) {
	
	return {
		get: function () { return this[prop][name]; },
		set: function ( val ) { this[prop][name] = val; }
	};

};

THREE.NodeMaterial.Shortcuts = function( proto, prop, list ) {
	
	var shortcuts = {};
	
	for(var i = 0; i < list.length; ++i) {
		
		var name = list[i];
		
		shortcuts[name] =  this.GetShortcuts( prop, name );
	
	}
	
	Object.defineProperties( proto, shortcuts );

};

THREE.NodeMaterial.prototype.updateAnimation = function( delta ) {
	
	for(var i = 0; i < this.requestUpdate.length; ++i) {

		this.requestUpdate[i].updateAnimation( delta );
	
	}
	
};

THREE.NodeMaterial.prototype.build = function() {
	
	var vertex, fragment;
	
	this.defines = {};
	this.uniforms = {}; 
	
	this.nodeData = {};	
	
	this.vertexUniform = [];
	this.fragmentUniform = [];
	
	this.vertexTemps = [];
	this.fragmentTemps = [];
	
	this.uniformList = [];
	
	this.includes = [];
	
	this.requestUpdate = [];
	
	this.needsUv = false;
	this.needsUv2 = false;
	this.needsColor = false;
	this.needsLight = false;
	this.needsDerivatives = false;
	this.needsPosition = false;
	this.needsTransparent = false;
	this.needsWorldPosition = false;
	
	this.vertexPars = '';
	this.fragmentPars = '';
	
	this.vertexCode = '';
	this.fragmentCode = '';
	
	this.vertexNode = '';
	this.fragmentNode = '';
	
	var builder = new THREE.NodeBuilder(this);
	
	vertex = this.vertex.build( builder.setShader('vertex'), 'v4' );
	fragment = this.fragment.build( builder.setShader('fragment'), 'v4' );
	
	if (this.needsUv) {
		
		this.addVertexPars( 'varying vec2 vUv;' );
		this.addFragmentPars( 'varying vec2 vUv;' );
		
		this.addVertexCode( 'vUv = uv;' );
		
	}
	
	if (this.needsUv2) {
		
		this.addVertexPars( 'varying vec2 vUv2; attribute vec2 uv2;' );
		this.addFragmentPars( 'varying vec2 vUv2;' );
		
		this.addVertexCode( 'vUv2 = uv2;' );
		
	}
	
	if (this.needsColor) {

		this.addVertexPars( 'varying vec4 vColor; attribute vec4 color;' );
		this.addFragmentPars( 'varying vec4 vColor;' );
		
		this.addVertexCode( 'vColor = color;' );
		
	}
	
	if (this.needsPosition) {

		this.addVertexPars( 'varying vec3 vPosition;' );
		this.addFragmentPars( 'varying vec3 vPosition;' );
		
		this.addVertexCode( 'vPosition = transformed;' );
		
	}
	
	if (this.needsWorldPosition) {
		
		// for future update replace from a native "varying vec3 vWorldPosition" for optimization
		
		this.addVertexPars( 'varying vec3 vWPosition;' );
-		this.addFragmentPars( 'varying vec3 vWPosition;' );
-		
-		this.addVertexCode( 'vWPosition = worldPosition.xyz;' );

	}
	
	if (this.needsTransformedNormal) {

		this.addVertexPars( 'varying vec3 vTransformedNormal;' );
		this.addFragmentPars( 'varying vec3 vTransformedNormal;' );
		
		this.addVertexCode( 'vTransformedNormal = transformedNormal;' );
		
	}
	
	this.extensions.derivatives = this.needsDerivatives;
	this.lights = this.needsLight;
	this.transparent = this.needsTransparent;
	
	this.vertexShader = [
		this.vertexPars,
		this.getCodePars( this.vertexUniform, 'uniform' ),
		this.getIncludes('vertex'),
		'void main(){',
		this.getCodePars( this.vertexTemps ),
		vertex,
		this.vertexCode,
		'}'
	].join( "\n" );
	
	this.fragmentShader = [
		this.fragmentPars,
		this.getCodePars( this.fragmentUniform, 'uniform' ),
		this.getIncludes('fragment'),
		'void main(){',
		this.getCodePars( this.fragmentTemps ),
		this.fragmentCode,
		fragment,
		'}'
	].join( "\n" );
	
	this.needsUpdate = true;
	this.dispose(); // force update
	
	return this;
};

THREE.NodeMaterial.prototype.define = function(name, value) {

	this.defines[name] = value == undefined ? 1 : value;

};

THREE.NodeMaterial.prototype.isDefined = function(name) {

	return this.defines[name] != undefined;

};

THREE.NodeMaterial.prototype.mergeUniform = function( uniforms ) {
	
	for (var name in uniforms) {
		
		this.uniforms[ name ] = uniforms[ name ];
	
	}
	
};

THREE.NodeMaterial.prototype.createUniform = function( value, type, needsUpdate ) {
	
	var index = this.uniformList.length;
	
	var uniform = {
		type : type,
		value : value,
		needsUpdate : needsUpdate,
		name : 'nVu' + index
	};
	
	this.uniformList.push(uniform);
	
	return uniform;
	
};

THREE.NodeMaterial.prototype.getVertexTemp = function( uuid, type ) {
	
	if (!this.vertexTemps[ uuid ]) {
		
		var index = this.vertexTemps.length,
			name = 'nVt' + index,
			data = { name : name, type : type };
		
		this.vertexTemps.push( data );
		this.vertexTemps[uuid] = data;
		
	}
	
	return this.vertexTemps[uuid];
	
};

THREE.NodeMaterial.prototype.getIncludes = function( shader ) {
	
	function sortByPosition(a, b){
		return b.deps - a.deps;
	}
	
	return function( shader ) {
		
		var incs = this.includes[shader];
		
		if (!incs) return '';
		
		var code = '';
		var incs = incs.sort(sortByPosition);
		
		for(var i = 0; i < incs.length; i++) {
			
			code += THREE.NodeLib.nodes[incs[i].name].src + '\n';
		
		}
		
		return code;
	}
}();

THREE.NodeMaterial.prototype.getFragmentTemp = function( uuid, type ) {
	
	if (!this.fragmentTemps[ uuid ]) {
		
		var index = this.fragmentTemps.length,
			name = 'nVt' + index,
			data = { name : name, type : type };
		
		this.fragmentTemps.push( data );
		this.fragmentTemps[uuid] = data;
		
	}
	
	return this.fragmentTemps[uuid];
	
};

THREE.NodeMaterial.prototype.addVertexPars = function( code ) {

	this.vertexPars += code + '\n';

};

THREE.NodeMaterial.prototype.addFragmentPars = function( code ) {

	this.fragmentPars += code + '\n';

};

THREE.NodeMaterial.prototype.addVertexCode = function( code ) {

	this.vertexCode += code + '\n';

};

THREE.NodeMaterial.prototype.addFragmentCode = function( code ) {

	this.fragmentCode += code + '\n';

};

THREE.NodeMaterial.prototype.addVertexNode = function( code ) {

	this.vertexNode += code + '\n';

};

THREE.NodeMaterial.prototype.clearVertexNode = function() {

	var code = this.fragmentNode;
	
	this.fragmentNode = '';
	
	return code;

};

THREE.NodeMaterial.prototype.addFragmentNode = function( code ) {

	this.fragmentNode += code + '\n';

};

THREE.NodeMaterial.prototype.clearFragmentNode = function() {

	var code = this.fragmentNode;
	
	this.fragmentNode = '';
	
	return code;

};

THREE.NodeMaterial.prototype.getCodePars = function( pars, prefix ) {

	prefix = prefix || '';

	var code = '';
	
	for (var i = 0, l = pars.length; i < l; ++i) {
		
		var parsType = pars[i].type;
		var parsName = pars[i].name;
		var parsValue = pars[i].value;
		
		if (parsType == 't' && parsValue instanceof THREE.CubeTexture) parsType = 'tc';
		
		var type = THREE.NodeMaterial.Type[ parsType ];
		
		if (type == undefined) throw new Error( "Node pars " + parsType + " not found." );
		
		code += prefix + ' ' + type + ' ' + parsName + ';\n';
	}

	return code;

};

THREE.NodeMaterial.prototype.getVertexUniform = function( value, type, needsUpdate ) {

	var uniform = this.createUniform( value, type, needsUpdate );
	
	this.vertexUniform.push(uniform);
	this.vertexUniform[uniform.name] = uniform;
	
	this.uniforms[ uniform.name ] = uniform;
	
	return uniform;

};

THREE.NodeMaterial.prototype.getFragmentUniform = function( value, type, needsUpdate ) {

	var uniform = this.createUniform( value, type, needsUpdate );
	
	this.fragmentUniform.push(uniform);
	this.fragmentUniform[uniform.name] = uniform;
	
	this.uniforms[ uniform.name ] = uniform;
	
	return uniform;

};

THREE.NodeMaterial.prototype.getNodeData = function( uuid ) {

	return this.nodeData[uuid] = this.nodeData[uuid] || {};

};

THREE.NodeMaterial.prototype.include = function( shader, func ) {
	
	var includes = this.includes[shader] = this.includes[shader] || [];
	
	if (includes[func] === undefined) {
		
		var node = THREE.NodeLib.nodes[func];
		
		this.needsDerivatives = node.needsDerivatives || this.needsDerivatives;
		
		if (!node) throw new Error("Library " + func + " not found!");
		
		includes[func] = { 
			name : func,
			deps : 1
		};
			
		includes.push(includes[func]);
	}
	else ++includes[func].deps;

};