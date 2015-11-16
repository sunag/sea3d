'use strict';

// ------------------------------------------------------------

THREE.NodeMaterial = function( vertex, fragment ) {
	
	THREE.ShaderMaterial.call( this );
	
	this.vertex = vertex || new THREE.NodeGL( new THREE.NodeGLPosition() );
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
	
	vertex = this.vertex.generate( this, 'vertex', 'v4' );
	fragment = this.fragment.generate( this, 'fragment', 'v4' );
	
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

		this.addVertexPars( 'varying vec3 vWorldPosition2;' );
		this.addFragmentPars( 'varying vec3 vWorldPosition2;' );
		
		this.addVertexCode( 'vWorldPosition2 = worldPosition.xyz;' );
		
	}
	
	if (this.needsTransformedNormal) {

		this.addVertexPars( 'varying vec3 vTransformedNormal;' );
		this.addFragmentPars( 'varying vec3 vTransformedNormal;' );
		
		this.addVertexCode( 'vTransformedNormal = transformedNormal;' );
		
	}
	
	this.derivatives = this.needsDerivatives;
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

THREE.NodeMaterial.prototype.define = function(name) {

	this.defines[name] = 1;

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

// ------------------------------------------------------------

THREE.NodePhongMaterial = function() {
	
	this.phong = new THREE.NodePhong();
	
	THREE.NodeMaterial.call( this, this.phong, this.phong );
	
};

THREE.NodePhongMaterial.prototype = Object.create( THREE.NodeMaterial.prototype );
THREE.NodePhongMaterial.prototype.constructor = THREE.NodePhongMaterial;

THREE.NodeMaterial.Shortcuts( THREE.NodePhongMaterial.prototype, 'phong', 
[ 'color',  'alpha', 'specular', 'shininess', 'normal', 'normalScale', 'emissive', 'ambient', 'shadow', 'light', 'environment', 'reflectivity', 'transform' ] );

// ------------------------------------------------------------

THREE.Node = function( type ) {
	
	this.uuid = THREE.Math.generateUUID();
	this.allow = {};
	
	this.type = type;
	
};

THREE.Node.prototype.verify = function( material ) {
	
	this.build( material, 'verify', 'v4' );
	
	material.clearVertexNode();
	material.clearFragmentNode();

};

THREE.Node.prototype.verifyAndBuildCode = function( material, shader, output, uuid ) {

	this.verify( material );
	
	return this.buildCode( material, shader, output, uuid );
	
};

THREE.Node.prototype.buildCode = function( material, shader, output, uuid ) {
	
	var data = { result : this.build( material, shader, output, uuid ) };
	
	if (shader == 'vertex') data.code = material.clearVertexNode();
	else data.code = material.clearFragmentNode();
	
	return data;

};

THREE.Node.prototype.verifyNodeDeps = function( data, output ) {
	
	data.deps = (data.deps || 0) + 1;
	
	var outputLen = this.getFormatLength( this.getFormat(output) );
	
	if (outputLen > data.outputMax || this.getType()) {
		
		data.outputMax = outputLen;
		data.output = output;
		
	}

};

THREE.Node.prototype.build = function( material, shader, output, uuid ) {

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

THREE.Node.prototype.getType = function() {

	return this.type;
	
};

THREE.Node.prototype.getFormat = function(str) {
	
	return str.replace('c','v3').replace(/fv1|iv1/, 'v1');
	
};

THREE.Node.prototype.getFormatLength = function(str) {
	
	return parseInt( this.getFormat(str).substr(1) );

};

THREE.Node.prototype.getFormatByLength = function(len) {
	
	if (len == 1) return 'fv1';
	return 'v' + len;

};

THREE.Node.prototype.getFormatConstructor = function(len) {
	
	return THREE.Node.formatConstructor[len-1];

};

THREE.Node.prototype.format = function(code, from, to) {
	
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

THREE.Node.formatConstructor = ['', 'vec2', 'vec3', 'vec4'];

// ------------------------------------------------------------

THREE.NodeInput = function(type) {
	
	THREE.Node.call( this, type );
	
};

THREE.NodeInput.prototype = Object.create( THREE.Node.prototype );
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

///----------------------------------------------------

THREE.NodePhong = function() {
	
	THREE.Node.call( this, 'phong' );
	
	this.color = new THREE.NodeColor( 0xEEEEEE );
	this.specular = new THREE.NodeColor( 0x111111 );
	this.shininess = new THREE.NodeFloat( 30 );
	
};

THREE.NodePhong.prototype = Object.create( THREE.Node.prototype );
THREE.NodePhong.prototype.constructor = THREE.NodePhong;

THREE.NodePhong.prototype.generate = function( material, shader ) {
	
	var code;
	
	material.define( 'PHONG' );
	
	material.needsLight = true;
	
	if (shader == 'vertex') {
		
		var transform = this.transform ? this.transform.verifyAndBuildCode( material, shader, 'v3' ) : undefined;
		
		material.mergeUniform( THREE.UniformsUtils.merge( [

			THREE.UniformsLib[ "fog" ],
			THREE.UniformsLib[ "lights" ],
			THREE.UniformsLib[ "shadowmap" ],
			{
				"envMap" : { type: "t", value: null },
				"flipEnvMap" : { type: "f", value: - 1 },
				"reflectivity" : { type: "f", value: 1.0 },
				"refractionRatio" : { type: "f", value: 0.98 }
			}

		] ) );
		
		material.addVertexPars( [
			"varying vec3 vViewPosition;",

			"#ifndef FLAT_SHADED",

				"varying vec3 vNormal;",

			"#endif",

			THREE.ShaderChunk[ "common" ],
			THREE.ShaderChunk[ "lights_phong_pars_vertex" ],
			THREE.ShaderChunk[ "morphtarget_pars_vertex" ],
			THREE.ShaderChunk[ "skinning_pars_vertex" ],
			THREE.ShaderChunk[ "shadowmap_pars_vertex" ],
			THREE.ShaderChunk[ "logdepthbuf_pars_vertex" ]

		].join( "\n" ) );

		var output = [
			THREE.ShaderChunk[ "beginnormal_vertex" ],
			THREE.ShaderChunk[ "morphnormal_vertex" ],
			THREE.ShaderChunk[ "skinbase_vertex" ],
			THREE.ShaderChunk[ "skinnormal_vertex" ],
			THREE.ShaderChunk[ "defaultnormal_vertex" ],

			"#ifndef FLAT_SHADED", // Normal computed with derivatives when FLAT_SHADED

				"vNormal = normalize( transformedNormal );",

			"#endif",

			THREE.ShaderChunk[ "begin_vertex" ]
		];
		
		if ( transform ) {
			output.push( transform.code );
			output.push( "transformed = " + transform.result + ";" );
			console.log( transform );
		}
		
		output.push(
			THREE.ShaderChunk[ "morphtarget_vertex" ],
			THREE.ShaderChunk[ "skinning_vertex" ],
			THREE.ShaderChunk[ "project_vertex" ],
			THREE.ShaderChunk[ "logdepthbuf_vertex" ],

			"vViewPosition = - mvPosition.xyz;",

			THREE.ShaderChunk[ "worldpos_vertex" ],
			THREE.ShaderChunk[ "lights_phong_vertex" ],
			THREE.ShaderChunk[ "shadowmap_vertex" ]
		);
		
		code = output.join( "\n" );
		
	}
	else {
		
		// trown and verify all nodes to reuse generate codes
	
		this.color.verify( material );
		this.specular.verify( material );
		this.shininess.verify( material );
		
		if (this.alpha) this.alpha.verify( material );
		
		if (this.environment) this.environment.verify( material );
		if (this.environment && this.reflectivity) this.reflectivity.verify( material );
		
		if (this.shadow) this.shadow.verify( material );
		if (this.light) this.light.verify( material );
		if (this.emissive) this.emissive.verify( material );
		if (this.ambient) this.ambient.verify( material );
		
		if (this.normal) this.normal.verify( material );
		if (this.normal && this.normalScale) this.normalScale.verify( material );
		
		// build code
		
		var color = this.color.buildCode( material, shader, 'v4' );
		var specular = this.specular.buildCode( material, shader, 'c' );
		var shininess = this.shininess.buildCode( material, shader, 'fv1' );
		
		var alpha = this.alpha ? this.alpha.buildCode( material, shader, 'fv1' ) : undefined;
		
		var environment = this.environment ? this.environment.buildCode( material, shader, 'c' ) : undefined;
		var reflectivity = this.environment && this.reflectivity ? this.reflectivity.buildCode( material, shader, 'fv1' ) : undefined;
		
		var shadow = this.shadow ? this.shadow.buildCode( material, shader, 'c' ) : undefined;
		var light = this.light ? this.light.buildCode( material, shader, 'c' ) : undefined;
		var emissive = this.emissive ? this.emissive.buildCode( material, shader, 'c' ) : undefined;
		var ambient = this.ambient ? this.ambient.buildCode( material, shader, 'c' ) : undefined;
		
		var normal = this.normal ? this.normal.buildCode( material, shader, 'v3' ) : undefined;
		var normalScale = this.normal && this.normalScale ? this.normalScale.buildCode( material, shader, 'fv1' ) : undefined;
		
		material.needsTransparent = alpha != undefined;
		
		material.addFragmentPars( [
			THREE.ShaderChunk[ "common" ],
			THREE.ShaderChunk[ "fog_pars_fragment" ],
			THREE.ShaderChunk[ "lights_phong_pars_fragment" ],
			THREE.ShaderChunk[ "shadowmap_pars_fragment" ],
			THREE.ShaderChunk[ "bumpmap_pars_fragment" ],
			THREE.ShaderChunk[ "logdepthbuf_pars_fragment" ]
		].join( "\n" ) );
		
		var output = [
			THREE.ShaderChunk[ "normal_phong_fragment" ],
			"vec3 outgoingLight = vec3( 0.0 );",
			color.code,
			"vec4 diffuseColor = " + color.result + ";",
			"vec3 totalAmbientLight = ambientLightColor;",
			specular.code,
			"vec3 specular = " + specular.result + ";",
			shininess.code,
			"float shininess = max(0.0001," + shininess.result + ");"
		];
		
		if (alpha) {
		
			output.push( 
				alpha.code,
				'if ( ' + alpha.result + ' <= 0.0 ) discard;'
			);
			
		}
		
		output.push( "vec3 shadowMask = vec3( 1.0 );" );
		
		output.push(
			THREE.ShaderChunk[ "logdepthbuf_fragment" ],
			"float specularStrength = 1.0;"
		);
		
		if (normal) {
			
			material.include( shader, 'perturbNormal2Arb' );
			
			output.push(normal.code);
			
			if (normalScale) output.push(normalScale.code);
			
			output.push(
				'normal = perturbNormal2Arb(-vViewPosition,normal,' +
				normal.result + ',' +
				new THREE.NodeUV().build( material, shader, 'v2' ) + ',' +
				(normalScale ? normalScale.result : '1.0') + ');'
			);

		}
		
		output.push( 
			THREE.ShaderChunk[ "hemilight_fragment" ],
			THREE.ShaderChunk[ "lights_phong_fragment" ] 
		);
		
		if (light) {
			output.push( light.code );
			output.push( "totalDiffuseLight += " + light.result + ";" );
		}
		
		if (ambient) { 
			output.push( ambient.code );
			output.push( "totalAmbientLight += " + ambient.result + ";" );
		}
		
		output.push( THREE.ShaderChunk[ "shadowmap_fragment" ] );
		
		if (shadow) {
			output.push( shadow.code );
			output.push( "shadowMask *= " + shadow.result + ";" );
		}
		
		output.push(
			"totalDiffuseLight *= shadowMask;",
			"totalSpecularLight *= shadowMask;"
		);
		
		output.push("outgoingLight += diffuseColor.rgb * ( totalDiffuseLight + totalAmbientLight ) + totalSpecularLight;");
		
		if (emissive) {
			output.push( emissive.code );
			output.push( "outgoingLight += " + emissive.result + ";" );
		}
		
		output.push( THREE.ShaderChunk[ "envmap_fragment" ] );
		
		if (environment) {
			output.push( environment.code );
			
			if (reflectivity) {
				
				output.push( reflectivity.code );
				
				output.push( "outgoingLight = mix(" + 'outgoingLight' + "," + environment.result + "," + reflectivity.result + ");" );
				
			}
			else {
			
				output.push( "outgoingLight = " + environment.result + ";" );
			}
			
		}
		
		output.push(
			THREE.ShaderChunk[ "linear_to_gamma_fragment" ],
			THREE.ShaderChunk[ "fog_fragment" ]
		);
		
		if (alpha) {
			output.push( "gl_FragColor = vec4( outgoingLight, " + alpha.result + " );" );
		}
		else {
			output.push( "gl_FragColor = vec4( outgoingLight, 1.0 );" );
		}
		
		code = output.join( "\n" );
	
	}
	
	return code;

};

//--------------------------------------------------------

THREE.NodeGL = function( value ) {
	
	THREE.Node.call( this, 'gl' );
	
	this.value = value;
	
};

THREE.NodeGL.prototype = Object.create( THREE.Node.prototype );
THREE.NodeGL.prototype.constructor = THREE.NodeGL;

THREE.NodeGL.prototype.generate = function( material, shader ) {
	
	if (shader == 'vertex') {
		
		return 'gl_Position = ' + this.value.generate( material, shader, output ) + ';';
		
	}
	else {
		
		return 'gl_FragColor = ' + this.value.generate( material, shader, output ) + ';';
	
	}

};

//--------------------------------------------------------

THREE.NodeGLPosition = function() {
	
	THREE.Node.call( this );
	
};

THREE.NodeGLPosition.prototype = Object.create( THREE.Node.prototype );
THREE.NodeGLPosition.prototype.constructor = THREE.NodeGLPosition;

THREE.NodeGL.prototype.generate = function( material, shader ) {

	if (shader == 'vertex') {
	
		return '(projectionMatrix * modelViewMatrix * vec4( position, 1.0 ))';
		
	}
	else {
	
		return 'vPosition';
		
	}

};

//--------------------------------------------------------

THREE.NodeReference = function( type, name ) {
	
	THREE.Node.call( this, type );
	
	this.name = name;
	
};

THREE.NodeReference.prototype = Object.create( THREE.Node.prototype );
THREE.NodeReference.prototype.constructor = THREE.NodeReference;

THREE.NodeReference.prototype.generate = function( material, shader, output ) {
	
	return this.format( this.name, this.type, output );

};

//--------------------------------------------------------

THREE.NodeTemp = function( type ) {
	
	THREE.Node.call( this, type );
	
};

THREE.NodeTemp.prototype = Object.create( THREE.Node.prototype );
THREE.NodeTemp.prototype.constructor = THREE.NodeTemp;

THREE.NodeTemp.prototype.build = function( material, shader, output, uuid ) {
	
	var data = material.getNodeData( uuid || this.uuid );
	
	if (shader == 'verify') {
		if (data.deps || 0 > 0) {
			this.verifyNodeDeps( data, output );
			return '';
		}
		return THREE.Node.prototype.build.call( this, material, shader, output, uuid );
	}
	else if (data.deps == 1) {
		return THREE.Node.prototype.build.call( this, material, shader, output, uuid );
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

//--------------------------------------------------------

THREE.NodeUV = function( uv2 ) {
	
	this.uv2 = uv2 || false;
	
	THREE.NodeReference.call( this, 'v2' );
	
};

THREE.NodeUV.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeUV.prototype.constructor = THREE.NodeUV;

THREE.NodeUV.prototype.generate = function( material, shader, output ) {
	
	material.needsUv = material.needsUv || !this.uv2;
	material.needsUv2 = material.needsUv2 || this.uv2;

	if (shader == 'vertex') this.name = this.uv2 ? 'uv2' : 'uv';
	else this.name = this.uv2 ? 'vUv2' : 'vUv';
	
	return THREE.NodeReference.prototype.generate.call(this, material, shader, output);

};

//--------------------------------------------------------

THREE.NodeTexture = function( value, coords ) {
	
	THREE.NodeInput.call( this, 'v4' );
	
	this.value = value;
	this.coords = coords || new THREE.NodeUV();
	
};

THREE.NodeTexture.prototype = Object.create( THREE.NodeInput.prototype );
THREE.NodeTexture.prototype.constructor = THREE.NodeTexture;

THREE.NodeTexture.prototype.getTemp = THREE.NodeTemp.prototype.getTemp;

THREE.NodeTexture.prototype.build = function( material, shader, output, uuid ) {
	
	return THREE.NodeTemp.prototype.build.call( this, material, shader, output, uuid );
	
};

THREE.NodeTexture.prototype.generate = function( material, shader, output ) {

	var tex = THREE.NodeInput.prototype.generate.call( this, material, shader, output, this.value.uuid, 't' );
	var coords = this.coords.build( material, shader, 'v2' );
	
	//inputToLinear xyz

	return this.format( 'texture2D(' + tex + ',' + coords + ')', this.type, output );

};

//--------------------------------------------------------

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

//---------------------------------------


THREE.NodeCubeTexture = function( value, coords ) {
	
	THREE.NodeInput.call( this, 'v4' );
	
	this.allow.vertex = false;
	
	this.value = value;
	this.coords = coords || new THREE.NodeReflect();
	
};

THREE.NodeCubeTexture.prototype = Object.create( THREE.NodeInput.prototype );
THREE.NodeCubeTexture.prototype.constructor = THREE.NodeCubeTexture;

THREE.NodeCubeTexture.prototype.generate = function( material, shader, output ) {

	var cubetex = THREE.NodeInput.prototype.generate.call( this, material, shader, output, this.value.uuid, 't' );
	var coords = this.coords.build( material, shader, 'v3' );
	
	return this.format('textureCube(' + cubetex + ', ' + coords + ')', this.type, output );

};

//-----------------------------------------------

THREE.NodeViewNormal = function() {
	
	THREE.NodeReference.call( this, 'v3' );
	
};

THREE.NodeViewNormal.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeViewNormal.prototype.constructor = THREE.NodeViewNormal;

THREE.NodeViewNormal.prototype.generate = function( material, shader, output ) {
	
	if (shader == 'vertex') this.name = 'normal';
	else this.name = 'vNormal';
	
	return THREE.NodeReference.prototype.generate.call( this, material, shader, output );

};

//-----------------------------------------------

THREE.NodeCameraPosition = function() {
	
	THREE.NodeReference.call( this, 'v3', 'cameraPosition' );
	
	this.allow.vertex = false;
	
};

THREE.NodeCameraPosition.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeCameraPosition.prototype.constructor = THREE.NodeCameraPosition;

//-----------------------------------------------

THREE.NodeTransformedPosition = function() {
	
	THREE.NodeReference.call( this, 'v3' );
	
};

THREE.NodeTransformedPosition.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeTransformedPosition.prototype.constructor = THREE.NodeTransformedPosition;

THREE.NodeTransformedPosition.prototype.generate = function( material, shader, output ) {
	
	material.needsPosition = true;
	
	if (shader == 'vertex') this.name = 'transformed';
	else this.name = 'vPosition';
	
	return THREE.NodeReference.prototype.generate.call( this, material, shader, output );

};

//-----------------------------------------------

THREE.NodeViewPosition = function() {
	
	THREE.NodeReference.call( this, 'v3' );
	
};

THREE.NodeViewPosition.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeViewPosition.prototype.constructor = THREE.NodeViewPosition;

THREE.NodeViewPosition.prototype.generate = function( material, shader, output ) {
	
	if (shader == 'vertex') this.name = 'vec3(0)';
	else this.name = 'vViewPosition';
	
	return THREE.NodeReference.prototype.generate.call( this, material, shader, output );

};

//-----------------------------------------------

THREE.NodeTransformedNormal = function() {
	
	THREE.NodeReference.call( this, 'v3' );
	
};

THREE.NodeTransformedNormal.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeTransformedNormal.prototype.constructor = THREE.NodeTransformedNormal;

THREE.NodeTransformedNormal.prototype.generate = function( material, shader, output ) {
	
	material.needsTransformedNormal = true;
	
	if (shader == 'vertex') this.name = 'normal';
	else this.name = 'vTransformedNormal';
	
	return THREE.NodeReference.prototype.generate.call( this, material, shader, output );

};

//-----------------------------------------------

THREE.NodePI = function() {
	
	THREE.NodeReference.call( this, 'fv1', 'PI' );
	
};

THREE.NodePI.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodePI.prototype.constructor = THREE.NodePI;

//-----------------------------------------------

THREE.NodePI2 = function() {
	
	THREE.NodeReference.call( this, 'fv1', 'PI2' );
	
};

THREE.NodePI2.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodePI2.prototype.constructor = THREE.NodePI2;

//--------------------------------------------------------
/*
THREE.NodeNormalMap = function( value, scale ) {
	
	THREE.NodeTemp.call( this, 'v3' );
	
	this.allow.vertex = false;
	
	this.value = value;
	this.scale = scale || new THREE.NodeFloat(1);
	this.uv = new THREE.NodeUV();
	
};

THREE.NodeNormalMap.prototype = Object.create( THREE.NodeTemp.prototype );
THREE.NodeNormalMap.prototype.constructor = THREE.NodeNormalMap;

THREE.NodeNormalMap.prototype.generate = function( material, shader, output ) {
	
	if (shader != 'vertex') {
	
		material.include( shader, 'perturbNormal2Arb' );
	
		return this.format( 'perturbNormal2Arb(-vViewPosition,normal,' +
			this.value.build( material, shader, 'v3' ) + ',' +
			this.uv.build( material, shader, 'v2' ) + ',' +
			this.scale.build( material, shader, 'fv1' ) + ')', this.type, output );
	}

};
*/
//--------------------------------------------------------

THREE.NodeFunction = function( src, needsDerivatives ) {
	
	var rDeclaration = /^([a-z_0-9]+)\s([a-z_0-9]+)\s?\((.*)\)/i;
	var rParams = /[a-z_0-9]+/ig;
	
	var match = src.match( rDeclaration );
	
	this.output = match[1];
	this.name = match[2];
	
	this.src = src;
	this.needsDerivatives = needsDerivatives !== undefined ? needsDerivatives : false;
	
	this.params = [];
	
	var params = match[3].match( rParams );
	
	for(var i = 0; i < params.length; i+=2) {
	
		var name = params[i];
		var type = params[i+1]
		
		this.params.push({
			name : name,
			type : type
		});
	}
	
	THREE.Node.call( this, 'v3' );
	
};

THREE.NodeFunction.prototype = Object.create( THREE.Node.prototype );
THREE.NodeFunction.prototype.constructor = THREE.NodeFunction;

//--------------------------------------------------------

THREE.NodeLib = {
	nodes:{},
	add:function(node) {
		this.nodes[node.name] = node;
	},
	remove:function(node) {
		delete this.nodes[node.name];
	}
};

//--------------------------------------------------------

//
//	NormalMap
//
			
THREE.NodeLib.add(new THREE.NodeFunction([
// Per-Pixel Tangent Space Normal Mapping
// http://hacksoflife.blogspot.ch/2009/11/per-pixel-tangent-space-normal-mapping.html
"vec3 perturbNormal2Arb( vec3 eye_pos, vec3 surf_norm, vec3 map, vec2 mUv, float scale ) {",
	"vec3 q0 = dFdx( eye_pos );",
	"vec3 q1 = dFdy( eye_pos );",
	"vec2 st0 = dFdx( mUv.st );",
	"vec2 st1 = dFdy( mUv.st );",
	"vec3 S = normalize( q0 * st1.t - q1 * st0.t );",
	"vec3 T = normalize( -q0 * st1.s + q1 * st0.s );",
	"vec3 N = normalize( surf_norm );",
	"vec3 mapN = map * 2.0 - 1.0;",
	"mapN.xy = scale * mapN.xy;",
	"mat3 tsn = mat3( S, T, N );",
	"return normalize( tsn * mapN );",
"}"
].join( "\n" ), true));

//
//	Saturation
//

THREE.NodeLib.add(new THREE.NodeFunction([
// Algorithm from Chapter 16 of OpenGL Shading Language
"vec3 saturation_rgb(vec3 rgb, float adjustment) {",
	"const vec3 W = vec3(0.2125, 0.7154, 0.0721);",
	"vec3 intensity = vec3(dot(rgb, W));",
	"return mix(intensity, rgb, adjustment);",
"}"
].join( "\n" )));

//
//	Luminance
//

THREE.NodeLib.add(new THREE.NodeFunction([
// Algorithm from Chapter 10 of Graphics Shaders.
"float luminance_rgb(vec3 rgb) {",
	"const vec3 W = vec3(0.2125, 0.7154, 0.0721);",
	"return dot(rgb, W);",
"}"
].join( "\n" )));

//--------------------------------------------------------

THREE.NodeDepth = function( value, near, far ) {
	
	THREE.Node.call( this, 'fv1' );
	
	this.allow.vertex = false;
	
	this.near = near || new THREE.NodeFloat(1);
	this.far = far || new THREE.NodeFloat(500);
	
};

THREE.NodeDepth.prototype = Object.create( THREE.Node.prototype );
THREE.NodeDepth.prototype.constructor = THREE.NodeDepth;

THREE.NodeDepth.prototype.generate = function( material, shader, output ) {
	
	var data = material.getNodeData( this.uuid );
	
	if (!data.initied) {
		
		material.addFragmentPars( [
			"float depthcolor( float mNear, float mFar ) {",
			
				"#ifdef USE_LOGDEPTHBUF_EXT",
				
				"float depth = gl_FragDepthEXT / gl_FragCoord.w;",
				
				"#else",
				
				"float depth = gl_FragCoord.z / gl_FragCoord.w;",
				
				"#endif",
				
				"return 1.0 - smoothstep( mNear, mFar, depth );",
				
			"}"
		].join( "\n" ) );
		
		data.initied = true;
		
	}
	
	var near = this.near.build( material, shader, 'fv1' )
	var far = this.far.build( material, shader, 'fv1' )
	
	return this.format( 'depthcolor(' + near + ',' + far + ')', this.type, output );

};

//--------------------------------------------------------

THREE.NodeColor = function( color ) {
	
	THREE.NodeInput.call( this, 'c' );
	
	this.value = new THREE.Color( color || 0 );
	
};

THREE.NodeColor.prototype = Object.create( THREE.NodeInput.prototype );
THREE.NodeColor.prototype.constructor = THREE.NodeColor;

THREE.NodeMaterial.Shortcuts( THREE.NodeColor.prototype, 'value', [ 'r', 'g', 'b' ] );

//--

THREE.NodeFloat = function( value ) {
	
	THREE.NodeInput.call( this, 'fv1' );
	
	this.value = [ value || 0 ];
	
};

THREE.NodeFloat.prototype = Object.create( THREE.NodeInput.prototype );
THREE.NodeFloat.prototype.constructor = THREE.NodeFloat;

Object.defineProperties( THREE.NodeFloat.prototype, {
	number: {
		get: function () { return this.value[0]; },
		set: function ( val ) { this.value[0] = val; }
	}
});

//--

THREE.NodeInt = function( value ) {
	
	THREE.NodeInput.call( this, 'fv1' );
	
	this.value = [ Math.floor(value || 0) ];
	
};

THREE.NodeInt.prototype = Object.create( THREE.NodeInput.prototype );
THREE.NodeInt.prototype.constructor = THREE.NodeInt;

Object.defineProperties( THREE.NodeInt.prototype, {
	number: {
		get: function () { return this.value[0]; },
		set: function ( val ) { this.value[0] = Math.floor(val); }
	}
});

//--

THREE.NodeTimer = function( value ) {
	
	THREE.NodeFloat.call( this, value );
	
	this.allow.requestUpdate = true;
	
};

THREE.NodeTimer.prototype = Object.create( THREE.NodeFloat.prototype );
THREE.NodeTimer.prototype.constructor = THREE.NodeTimer;

THREE.NodeTimer.prototype.updateAnimation = function( delta ) {
	
	this.number += delta;
	
};

//--

THREE.NodeVector2 = function( x, y ) {
	
	THREE.NodeInput.call( this, 'v2' );
	
	this.value = new THREE.Vector2( x, y );
	
};

THREE.NodeVector2.prototype = Object.create( THREE.NodeInput.prototype );
THREE.NodeVector2.prototype.constructor = THREE.NodeVector2;

THREE.NodeMaterial.Shortcuts( THREE.NodeVector2.prototype, 'value', [ 'x', 'y' ] );

//--

THREE.NodeVector3 = function( x, y, z ) {
	
	THREE.NodeInput.call( this, 'v3' );
	
	this.type = 'v3';
	this.value = new THREE.Vector3( x, y, z );
	
};

THREE.NodeVector3.prototype = Object.create( THREE.NodeInput.prototype );
THREE.NodeVector3.prototype.constructor = THREE.NodeVector3;

THREE.NodeMaterial.Shortcuts( THREE.NodeVector3.prototype, 'value', [ 'x', 'y', 'z' ] );

//--

THREE.NodeVector4 = function( x, y, z, w ) {
	
	THREE.NodeInput.call( this, 'v4' );
	
	this.value = new THREE.Vector4( x, y, z, w );
	
};

THREE.NodeVector4.prototype = Object.create( THREE.NodeInput.prototype );
THREE.NodeVector4.prototype.constructor = THREE.NodeVector4;

THREE.NodeMaterial.Shortcuts( THREE.NodeVector4.prototype, 'value', [ 'x', 'y', 'z', 'w' ] );

//-------------------------

THREE.NodeOperator = function( a, b, op ) {
	
	THREE.NodeTemp.call( this );
	
	this.op = op || '+';
	
	this.a = a;
	this.b = b;
	
};

THREE.NodeOperator.prototype = Object.create( THREE.NodeTemp.prototype );
THREE.NodeOperator.prototype.constructor = THREE.NodeOperator;

THREE.NodeOperator.prototype.getType = function() {
	
	// use the greater length vector
	if (this.getFormatLength( this.b.getType() ) > this.getFormatLength( this.a.getType() )) {
		return this.b.getType();
	}
	
	return this.a.getType();

};

THREE.NodeOperator.prototype.generate = function( material, shader, output ) {
	
	var a = this.a.build( material, shader, output );
	var b = this.b.build( material, shader, output );
	
	var data = material.getNodeData( this.uuid );
	
	return '(' + a + this.op + b + ')';

};

//-------------------------

THREE.NodeMath1 = function( a, method ) {
	
	THREE.NodeTemp.call( this );
	
	this.a = a;
	
	this.method = method || THREE.NodeMath1.SINE;
	
};

THREE.NodeMath1.prototype = Object.create( THREE.Node.prototype );
THREE.NodeMath1.prototype.constructor = THREE.NodeMath1;

THREE.NodeMath1.RADIANS = 'radians';
THREE.NodeMath1.DEGREES = 'degrees';
THREE.NodeMath1.EXPONENTIAL = 'exp';
THREE.NodeMath1.EXPONENTIAL2 = 'exp2';
THREE.NodeMath1.LOGARITHM = 'log';
THREE.NodeMath1.LOGARITHM2 = 'log2';
THREE.NodeMath1.INVERSE_SQUARE = 'inversesqrt';
THREE.NodeMath1.FLOOR = 'floor';
THREE.NodeMath1.CEILING = 'ceil';
THREE.NodeMath1.NORMALIZE = 'normalize';
THREE.NodeMath1.FRACTIONAL = 'fract';
THREE.NodeMath1.SINE = 'sin';
THREE.NodeMath1.COSINE = 'cos';
THREE.NodeMath1.TANGENT = 'tan';
THREE.NodeMath1.ARCSINE = 'asin';
THREE.NodeMath1.ARCCOSINE = 'acos';
THREE.NodeMath1.ARCTANGENT = 'atan';
THREE.NodeMath1.ABSOLUTE = 'abc';
THREE.NodeMath1.SIGN = 'sign';
THREE.NodeMath1.LENGTH = 'length';

THREE.NodeMath1.prototype.getType = function() {
	
	switch(this.method) {
		case THREE.NodeMath1.DISTANCE:
			return 'fv1';
			break;
	}
	
	return this.a.getType();
	
};

THREE.NodeMath1.prototype.generate = function( material, shader, output ) {
	
	var type = this.getType();
	
	var a = this.a.build( material, shader, type );
	
	return this.format( this.method + '(' + a + ')', type, output );

};

//-------------------------

THREE.NodeMath2 = function( a, b, method ) {
	
	THREE.NodeTemp.call( this );
	
	this.a = a;
	this.b = b;
	
	this.method = method || THREE.NodeMath2.MIN;
	
};

THREE.NodeMath2.prototype = Object.create( THREE.Node.prototype );
THREE.NodeMath2.prototype.constructor = THREE.NodeMath2;

THREE.NodeMath2.MIN = 'min';
THREE.NodeMath2.MAX = 'max';
THREE.NodeMath2.MODULO = 'mod';
THREE.NodeMath2.STEP = 'step';
THREE.NodeMath2.REFLECT = 'reflect';
THREE.NodeMath2.DISTANCE = 'distance';
THREE.NodeMath2.DOT = 'dot';
THREE.NodeMath2.CROSS = 'cross';
THREE.NodeMath2.EXPONENTIATION = 'pow';

THREE.NodeMath2.prototype.getInputType = function() {
	
	// use the greater length vector
	if (this.getFormatLength( this.b.getType() ) > this.getFormatLength( this.a.getType() )) {
		return this.b.getType();
	}
	
	return this.a.getType();
	
};

THREE.NodeMath2.prototype.getType = function() {
	
	switch(this.method) {
		case THREE.NodeMath2.DISTANCE:
		case THREE.NodeMath2.DOT:
			return 'fv1';
			break;
		
		case THREE.NodeMath2.CROSS:
			return 'v3';
			break;
	}
	
	return this.getInputType();
};

THREE.NodeMath2.prototype.generate = function( material, shader, output ) {
	
	var type = this.getInputType();
	
	var a, b, 
		al = this.getFormatLength( this.a.getType() ),
		bl = this.getFormatLength( this.b.getType() );
	
	// optimzer
	
	switch(this.method) {
		case THREE.NodeMath2.STEP:
			a = this.a.build( material, shader, al == 1 ? 'fv1' : type );
			b = this.b.build( material, shader, type );
			break;
			
		case THREE.NodeMath2.MIN:
		case THREE.NodeMath2.MAX:
		case THREE.NodeMath2.MODULO:
			a = this.a.build( material, shader, type );
			b = this.b.build( material, shader, bl == 1 ? 'fv1' : type );
			break;
			
		default:
			a = this.a.build( material, shader, type );
			b = this.b.build( material, shader, type );
			break;
	
	}
	
	return this.format( this.method + '(' + a + ',' + b + ')', this.getType(), output );

};

//-------------------------

THREE.NodeMath3 = function( a, b, c, method ) {
	
	THREE.NodeTemp.call( this );
	
	this.a = a;
	this.b = b;
	this.c = c;
	
	this.method = method || THREE.NodeMath3.MIX;
	
};

THREE.NodeMath3.prototype = Object.create( THREE.Node.prototype );
THREE.NodeMath3.prototype.constructor = THREE.NodeMath3;

THREE.NodeMath3.MIX = 'mix';
THREE.NodeMath2.REFRACT = 'refract';
THREE.NodeMath2.SMOOTHSTEP = 'smoothstep';
THREE.NodeMath2.FACEFORWARD = 'faceforward';

THREE.NodeMath3.prototype.getType = function() {
	
	var a = this.getFormatLength( this.a.getType() );
	var b = this.getFormatLength( this.b.getType() );
	var c = this.getFormatLength( this.c.getType() );
	
	if (a > b) {
		if (a > c) return this.a.getType();
		return this.c.getType();
	} 
	else {
		if (b > c) return this.b.getType();
	
		return this.c.getType();
	}
	
};

THREE.NodeMath3.prototype.generate = function( material, shader, output ) {
	
	var type = this.getType();
	
	var a, b, c,
		al = this.getFormatLength( this.a.getType() ),
		bl = this.getFormatLength( this.b.getType() ),
		cl = this.getFormatLength( this.b.getType() )
	
	// optimzer
	
	switch(this.method) {
		case THREE.NodeMath2.REFRACT:
			a = this.a.build( material, shader, type );
			b = this.b.build( material, shader, type );
			c = this.c.build( material, shader, 'fv1' );
			break;
		
		case THREE.NodeMath2.MIX:
		case THREE.NodeMath2.SMOOTHSTEP:
			a = this.a.build( material, shader, type );
			b = this.b.build( material, shader, type );
			c = this.c.build( material, shader, cl == 1 ? 'fv1' : type );
			break;
			
		default:
			a = this.a.build( material, shader, type );
			b = this.b.build( material, shader, type );
			c = this.c.build( material, shader, type );
			break;
	
	}
	
	return this.format( this.method + '(' + a + ',' + b + ',' + c + ')', type, output );

};

//-------------------------

THREE.NodeSwitch = function( a, component ) {
	
	THREE.Node.call( this, 'fv1' );
	
	this.component = component || 'x';
	
	this.a = a;
	
};

THREE.NodeSwitch.prototype = Object.create( THREE.Node.prototype );
THREE.NodeSwitch.prototype.constructor = THREE.NodeSwitch;

THREE.NodeSwitch.elements = ['x','y','z','w'];

THREE.NodeSwitch.prototype.generate = function( material, shader, output ) {
	
	var type = this.a.getType();
	var inputLength = this.getFormatLength(type);
		
	var a = this.a.build( material, shader, type );
	
	var outputLength = THREE.NodeSwitch.elements.indexOf( this.component ) + 1;
	
	if (inputLength > 1) {
	
		if (inputLength < outputLength) outputLength = inputLength;
		
		a = a + '.' + THREE.NodeSwitch.elements[outputLength-1];
	}
	
	return this.format( a, this.type, output );

};

//-------------------------

THREE.NodeJoin = function( x, y, w, z ) {
	
	THREE.Node.call( this, 'fv1' );
	
	this.x = x;
	this.y = y;
	this.z = z;
	this.w = w;
	
};

THREE.NodeJoin.prototype = Object.create( THREE.Node.prototype );
THREE.NodeJoin.prototype.constructor = THREE.NodeJoin;

THREE.NodeJoin.inputs = ['x','y','z','w'];

THREE.NodeJoin.prototype.getNumElements = function() {
	
	var inputs = THREE.NodeJoin.inputs;
	var i = inputs.length;
	
	while (i--) {
		if ( this[ inputs[i] ] !== undefined ) {
			++i;
			break;
		}
	}
	
	return Math.max(i, 2);
	
};

THREE.NodeJoin.prototype.getType = function() {
	
	return this.getFormatByLength( this.getNumElements() );
	
};

THREE.NodeJoin.prototype.generate = function( material, shader, output ) {
	
	var type = this.getType();
	var length = this.getNumElements();
	
	var inputs = THREE.NodeJoin.inputs;
	var outputs = [];
	
	for(var i = 0; i < length; i++) {
	
		var elm = this[inputs[i]];
		
		outputs.push( elm ? elm.build( material, shader, 'fv1' ) : '0.' );
	
	}
	
	var code = this.getFormatConstructor(length) + '(' + outputs.join(',') + ')';
	
	return this.format( code, type, output );

};