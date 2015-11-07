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
	
	this.variables = {
		vUv : { type : 'v2' },
		vUv2 : { type : 'v2' },
		uv : { type : 'v2' },
		uv2 : { type : 'v2' },
		vNormal : { type : 'v3' },
		normal : { type : 'v3' },
		transformed : { type : 'v3' },
		reflectVec : { type : 'v3' },
		reflectCoord : { type : 'v3' },
		refractVec : { type : 'v3' },
		refractCoord : { type : 'v3' }
	};
	
	this.nodeData = {};	
	
	this.vertexUniform = [];
	this.fragmentUniform = [];
	
	this.vertexTemps = [];
	this.fragmentTemps = [];
	
	this.uniformList = [];
	
	this.requestUpdate = [];
	
	this.needsUv = false;
	this.needsUv2 = false;
	this.needsNormal = false;
	this.needsTangent = false;
	this.needsColor = false;
	this.needsLight = false;
	this.needsDerivatives = false;
	this.needsTransparent = false;
	
	this.vertexPars = '';
	this.fragmentPars = '';
	
	this.vertexCode = '';
	this.fragmentCode = '';
	
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
	
	this.derivatives = this.needsDerivatives;
	this.lights = this.needsLight;
	this.transparent = this.needsTransparent;
	
	this.vertexShader = [
		this.vertexPars,
		this.getCodePars( this.vertexUniform, 'uniform' ),
		'void main(){',
		this.getCodePars( this.vertexTemps ),
		this.vertexCode,
		vertex,
		'}'
	].join( "\n" );
	
	this.fragmentShader = [
		this.fragmentPars,
		this.getCodePars( this.fragmentUniform, 'uniform' ),
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
			name = 'nVt' + index;
			data = { name : name, type : type };
		
		this.vertexTemps.push( data );
		this.vertexTemps[uuid] = data;
		
	}
	
	return this.vertexTemps[uuid];
	
};

THREE.NodeMaterial.prototype.getFragmentTemp = function( uuid, type ) {
	
	if (!this.fragmentTemps[ uuid ]) {
		
		var index = this.fragmentTemps.length,
			name = 'nVt' + index;
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

THREE.NodeMaterial.prototype.getCodePars = function( pars, prefix ) {

	prefix = prefix || '';

	var code = '';
	
	for (var i = 0, l = pars.length; i < l; ++i) {
		
		var type = THREE.NodeMaterial.Type[ pars[i].type ];
		
		if (type == undefined) throw "node pars " + pars[i].type + " not found."
		
		code += prefix + ' ' + type + ' ' + pars[i].name + ';\n';
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

// ------------------------------------------------------------

THREE.NodePhongMaterial = function() {
	
	this.phong = new THREE.NodePhong();
	
	THREE.NodeMaterial.call( this, this.phong, this.phong );
	
};

THREE.NodePhongMaterial.prototype = Object.create( THREE.NodeMaterial.prototype );
THREE.NodePhongMaterial.prototype.constructor = THREE.NodePhongMaterial;

THREE.NodeMaterial.Shortcuts( THREE.NodePhongMaterial.prototype, 'phong', 
[ 'color',  'alpha', 'specular', 'shininess', 'normal', 'emissive', 'ambient', 'shadow', 'light', 'transform', 'env' ] );

// ------------------------------------------------------------

THREE.Node = function( type ) {
	
	this.uuid = THREE.Math.generateUUID();
	this.allow = {};
	
	this.type = type;
	
};

THREE.Node.prototype.build = function( material, shader, output, uuid ) {

	var data = material.getNodeData( uuid );
	
	if (this.allow[shader] === false) {
		throw new Error( 'Shader ' + shader + ' is not compatible with this node.' );
	}
	
	if (this.allow.requestUpdate && !data.requestUpdate) {
		material.requestUpdate.push( this );
		data.requestUpdate = true;
	}
	
	var code = this.generate( material, shader, output, uuid );
	
	return code;
	
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

THREE.Node.prototype.format = function(code, from, to) {
	
	var format = this.getFormat(from + '=' + to);
	
	switch ( format ) {
		case 'v1=v2': return 'vec2(' + code + ',0)';
		case 'v1=v3': return 'vec3(' + code + ',0,0)';
		case 'v1=v4': return 'vec4(' + code + ',0,0,0)';
		
		case 'v2=v1': return code + '.x';
		case 'v2=v3': return 'vec3(' + code + ',0)';
		case 'v2=v4': return 'vec4(' + code + ',0,0)';
		
		case 'v3=v1': return code + '.x';
		case 'v3=v2': return code + '.xy';
		case 'v3=v4': return 'vec4(' + code + ',0)';
		
		case 'v4=v1': return code + '.x';
		case 'v4=v2': return code + '.xy';
		case 'v4=v3': return code + '.xyz';
	}
	
	return code;

};

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
	this.env = new THREE.NodeEnvironment();
	
};

THREE.NodePhong.prototype = Object.create( THREE.Node.prototype );
THREE.NodePhong.prototype.constructor = THREE.NodePhong;

THREE.NodePhong.prototype.generate = function( material, shader ) {
	
	var code;
	
	material.shadows = material.shadows !== undefined ? material.shadows : true;
	
	material.define( 'PHONG' );
	
	material.needsLight = true;
	
	if (shader == 'vertex') {
		
		var transform = this.transform ? this.transform.build( material, shader, 'v3' ) : undefined;
		
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
		
		if ( transform ) output.push( "transformed = " + transform + ";" );
		
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
		
		var color = this.color.build( material, shader, 'v4' );
		var specular = this.specular.build( material, shader, 'c' );
		var shininess = this.shininess.build( material, shader, 'fv1' );
		
		var alpha = this.alpha ? this.alpha.build( material, shader, 'fv1' ) : undefined;
		
		var env = this.env.input ? this.env.input.build( material, shader, 'c' ) : undefined;
		
		var shadow = this.shadow ? this.shadow.build( material, shader, 'c' ) : undefined;
		var light = this.light ? this.light.build( material, shader, 'c' ) : undefined;
		var emissive = this.emissive ? this.emissive.build( material, shader, 'c' ) : undefined;
		var ambient = this.ambient ? this.ambient.build( material, shader, 'c' ) : undefined;
		
		var normal = this.normal ? this.normal.build( material, shader, 'v3' ) : undefined;
		
		material.needsTransparent = alpha != undefined;
		
		var containsShadow = shadow || material.shadows;
		
		material.addFragmentPars( [
			THREE.ShaderChunk[ "common" ],
			THREE.ShaderChunk[ "fog_pars_fragment" ],
			THREE.ShaderChunk[ "lights_phong_pars_fragment" ],
			THREE.ShaderChunk[ "shadowmap_pars_fragment" ],
			THREE.ShaderChunk[ "bumpmap_pars_fragment" ],
			THREE.ShaderChunk[ "logdepthbuf_pars_fragment" ]
		].join( "\n" ) );
		
		var output = [
			"vec3 outgoingLight = vec3( 0.0 );",
			"vec4 diffuseColor = " + color + ";",
			"vec3 totalAmbientLight = ambientLightColor;",
			"vec3 specular = " + specular + ";",
			"float shininess = " + shininess + ";"
		];
		
		output.push( "vec3 shadowMask = vec3( 1.0 );" );
		
		output.push(
			THREE.ShaderChunk[ "logdepthbuf_fragment" ],
			THREE.ShaderChunk[ "alphatest_fragment" ]
		);
		
		output.push(
			"float specularStrength = 1.0;",
			THREE.ShaderChunk[ "normal_phong_fragment" ]
		);
		
		if (normal) output.push("normal = " + normal + ";");
		
		output.push( 
			THREE.ShaderChunk[ "hemilight_fragment" ],
			THREE.ShaderChunk[ "lights_phong_fragment" ] 
		);
		
		if (light) output.push( "totalDiffuseLight += " + light + ";" );
		
		if (ambient) output.push( "totalAmbientLight += " + ambient + ";" );
		
		output.push( THREE.ShaderChunk[ "shadowmap_fragment" ] );
		
		if (shadow) output.push( "shadowMask *= " + shadow + ";" );
		
		if (containsShadow) {
		
			output.push(
				"totalDiffuseLight *= shadowMask;",
				"totalSpecularLight *= shadowMask;"
			);
			
		}
		
		output.push(
			"#ifdef METAL",

			"outgoingLight += diffuseColor.rgb * ( totalDiffuseLight + totalAmbientLight ) * specular + totalSpecularLight;",

			"#else",

			"outgoingLight += diffuseColor.rgb * ( totalDiffuseLight + totalAmbientLight ) + totalSpecularLight;",

			"#endif"
		);
		
		if (emissive) output.push( "outgoingLight += " + emissive + ";" );
		
		output.push( THREE.ShaderChunk[ "envmap_fragment" ] );
		
		if (this.env.input) output.push( "outgoingLight " + this.env.op + this.env.input + ";" );
		
		output.push(
		
			THREE.ShaderChunk[ "linear_to_gamma_fragment" ],

			THREE.ShaderChunk[ "fog_fragment" ],

			"gl_FragColor = vec4( outgoingLight, " + (alpha ? alpha : 1 ) + " );"
		);
		
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
	
	THREE.Node.prototype.build.call( this, material, shader, uuid );
	
	var name = this.getTemp( material, shader, uuid );
	var type = this.getType();
	
	if (name) {
	
		return this.format( name, type, output );
		
	}
	else {
			
		name = THREE.NodeTemp.prototype.generate.call( this, material, shader );
		
		var code = this.generate( material, shader, type, uuid );
	
		return this.format( '(' + name + '=' + code + ')', type, output );
	
	}
	
};

THREE.NodeTemp.prototype.getTemp = function( material, shader, uuid ) {
	
	uuid = uuid || this.uuid;
	
	if (shader == 'vertex' && material.vertexTemps[ uuid ]) return material.vertexTemps[ uuid ].name;
	else if (material.fragmentTemps[ uuid ]) return material.fragmentTemps[ uuid ].name;

};

THREE.NodeTemp.prototype.generate = function( material, shader, output, uuid ) {
	
	uuid = uuid || this.uuid;
	
	if (shader == 'vertex') return material.getVertexTemp( uuid, this.getType() ).name;
	else return material.getFragmentTemp( uuid, this.getType() ).name;

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

THREE.NodeTexture = function( value, uv ) {
	
	THREE.NodeInput.call( this, 'v4' );
	
	this.value = value;
	this.uv = uv || new THREE.NodeUV();
	
};

THREE.NodeTexture.prototype = Object.create( THREE.NodeInput.prototype );
THREE.NodeTexture.prototype.constructor = THREE.NodeTexture;

THREE.NodeTexture.prototype.generate = function( material, shader, output ) {

	var tex = THREE.NodeInput.prototype.generate.call( this, material, shader, output, this.value.uuid, 't' );
	var uv = this.uv.build( material, shader, 'v2' );
	
	//inputToLinear xyz

	return this.format( 'texture2D(' + tex + ',' + uv + ')', this.type, output );

};

//--------------------------------------------------------

THREE.NodeReflectUVW = function() {
	
	THREE.NodeReference.call( this, 'v3', 'reflectCoord' );
	
};

THREE.NodeReflectUVW.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeReflectUVW.prototype.constructor = THREE.NodeReflectUVW;

THREE.NodeReflectUVW.prototype.generate = function( material, shader, output ) {
	
	var code = 'vec3 reflectVec = reflect( cameraToVertex, worldNormal );\n' +
		'vec3 reflectCoord = vec3( flipEnvMap * reflectVec.x, reflectVec.yz );\n';
	
	return THREE.NodeReference.prototype.generate.call( this, material, shader, output );

};

//--------------------------------------------------------

THREE.NodeRefractVector = function() {
	
	THREE.Node.call( this, 'refractCoord' );
	
};

THREE.NodeRefractVector.prototype = Object.create( THREE.Node.prototype );
THREE.NodeRefractVector.prototype.constructor = THREE.NodeRefractVector;

THREE.NodeReflectUVW.prototype.generate = function( material, shader, output ) {
	
	var code = 'vec3 vt0 = refract( cameraToVertex, worldNormal, refractionRatio );\n' +
		'vec3 refractCoord = vec3( flipEnvMap * refractVec.x, refractVec.yz );\n';
	
	return THREE.NodeReference.prototype.generate.call( this, material, shader, output );

};

//--------------------------------------------------------

THREE.NodeRefractUVW = function() {
	
	THREE.NodeReference.call( this, 'v3', 'refractCoord' );
	
};

THREE.NodeRefractUVW.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeRefractUVW.prototype.constructor = THREE.NodeRefractUVW;

THREE.NodeReflectUVW.prototype.generate = function( material, shader, output ) {
	
	var code = 'vec3 refractVec = refract( cameraToVertex, worldNormal, refractionRatio );\n' +
		'vec3 refractCoord = vec3( flipEnvMap * refractVec.x, refractVec.yz );\n';
	
	return THREE.NodeReference.prototype.generate.call( this, material, shader, output );

};

//---------------------------------------


THREE.NodeCube = function( value, offset ) {
	
	THREE.NodeInput.call( this, 'tc' );
	
	this.allow.vertex = false;
	
	this.value = value;
	this.offset = offset;
	
};

THREE.NodeCube.prototype = Object.create( THREE.NodeInput.prototype );
THREE.NodeCube.prototype.constructor = THREE.NodeTexture;

THREE.NodeCube.prototype.generate = function( material, shader, output ) {
	
	var data = material.getNodeData( this.uuid );
	
	if (shader == 'fragment') {
	
		if (!data.initied) {
		
			material.addFragmentPars( [
				"vec3 cameraToVertex = normalize( vWorldPosition - cameraPosition );",
				
				// Transforming Normal Vectors with the Inverse Transformation
				"vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );",
				
				'#ifdef DOUBLE_SIDED',
				
					'float flipNormal = ( float( gl_FrontFacing ) * 2.0 - 1.0 );',
					
				'#else',
				
					'float flipNormal = 1.0;',
					
				'#endif'
				
			].join( "\n" ) );
			
			data.initied = true;
			
		}
		
		return this.format( 'perturbNormal2Arb(-vViewPosition,normal,' +
			this.value.build( material, shader, 'v3' ) + ',' +
			this.value.uv.build( material, shader, 'v2' ) + ',' +
			this.scale.build( material, shader, 'fv1' ) + ')', this.type, output );
	}

};

THREE.NodeCube.prototype.generate = function( material, shader, output ) {

	var tex = THREE.Node.prototype.generate.call( this, material, shader, output, this.value.uuid, 't' );
	
	return this.format( 'textureCube(' + tex + ',' + uv + ')', 'v4', output );

};

//-----------------------------------------------

THREE.NodeNormal = function() {
	
	THREE.NodeReference.call( this, 'v3' );
	
};

THREE.NodeNormal.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeNormal.prototype.constructor = THREE.NodeNormal;

THREE.NodeNormal.prototype.generate = function( material, shader, output ) {
	
	if (shader == 'vertex') this.name = 'normal';
	else this.name = 'vNormal';
	
	return THREE.NodeReference.prototype.generate.call( this, material, shader, output );

};

//-----------------------------------------------

THREE.NodeTransform = function( value, scale ) {
	
	THREE.NodeReference.call( this, 'v3', 'transformed' );
	
	this.allow.fragment = false;
	
};

THREE.NodeTransform.prototype = Object.create( THREE.NodeReference.prototype );
THREE.NodeTransform.prototype.constructor = THREE.NodeTransform;

//--------------------------------------------------------

THREE.NodeNormalMap = function( value, scale ) {
	
	THREE.Node.call( this, 'v3' );
	
	this.allow.vertex = false;
	
	this.value = value;
	this.scale = scale || new THREE.NodeFloat(1);
	
};

THREE.NodeNormalMap.prototype = Object.create( THREE.Node.prototype );
THREE.NodeNormalMap.prototype.constructor = THREE.NodeNormalMap;

THREE.NodeNormalMap.prototype.generate = function( material, shader, output ) {
	
	var data = material.getNodeData( this.uuid );
	
	if (shader == 'fragment') {
	
		if (!data.initied) {
		
			material.needsDerivatives = true;
			
			// Per-Pixel Tangent Space Normal Mapping
			// http://hacksoflife.blogspot.ch/2009/11/per-pixel-tangent-space-normal-mapping.html
			
			material.addFragmentPars( [
				"vec3 perturbNormal2Arb( vec3 eye_pos, vec3 surf_norm, vec3 map, vec2 mUv, float scale ) {",
					"vec3 q0 = dFdx( eye_pos.xyz );",
					"vec3 q1 = dFdy( eye_pos.xyz );",
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
			].join( "\n" ) );
			
			data.initied = true;
			
		}
		
		return this.format( 'perturbNormal2Arb(-vViewPosition,normal,' +
			this.value.build( material, shader, 'v3' ) + ',' +
			this.value.uv.build( material, shader, 'v2' ) + ',' +
			this.scale.build( material, shader, 'fv1' ) + ')', this.type, output );
	}

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

THREE.NodeTime = function( value ) {
	
	THREE.NodeFloat.call( this, value );
	
	this.allow.requestUpdate = true;
	
};

THREE.NodeTime.prototype = Object.create( THREE.NodeFloat.prototype );
THREE.NodeTime.prototype.constructor = THREE.NodeTime;

THREE.NodeTime.prototype.updateAnimation = function( delta ) {
	
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

THREE.NodeOperator.prototype = Object.create( THREE.Node.prototype );
THREE.NodeOperator.prototype.constructor = THREE.NodeTemp;

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
	
	return '(' + a + this.op + b + ')';

};

//-------------------------

THREE.NodeMathx = function( value, method ) {
	
	THREE.NodeTemp.call( this, 'fv1' );
	
	this.value = value;
	this.method = method || THREE.NodeMathx.FRACT;
	
};

THREE.NodeMathx.prototype = Object.create( THREE.Node.prototype );
THREE.NodeMathx.prototype.constructor = THREE.NodeMathx;

THREE.NodeMathx.FRACT = 'fract';
THREE.NodeMathx.SIN = 'sin';
THREE.NodeMathx.COS = 'cos';

THREE.NodeMathx.prototype.generate = function( material, shader, output ) {
	
	var value = this.value.build( material, shader, this.type );
	
	return this.format( this.method + '(' + value + ')', this.type, output );

};

//-------------------------

THREE.NodeSwitch = function( value, component ) {
	
	THREE.Node.call( this, 'fv1' );
	
	this.value = value;
	this.component = component || 'x';
	
};

THREE.NodeSwitch.prototype = Object.create( THREE.Node.prototype );
THREE.NodeSwitch.prototype.constructor = THREE.NodeSwitch;

THREE.NodeSwitch.elements = ['x','y','z','w'];

THREE.NodeSwitch.prototype.generate = function( material, shader, output ) {
	
	var type = this.value.getType();
	var inputLength = this.getFormatLength(type);
		
	var value = this.value.build( material, shader, type );
	var outputLength = THREE.NodeSwitch.elements.indexOf( this.component ) + 1;
	
	if (inputLength > 1) {
	
		if (inputLength < outputLength) outputLength = inputLength;
		
		value = value + '.' + THREE.NodeSwitch.elements[outputLength-1];
	}
	
	return this.format( value, this.type, output );

};

//-------------------------

THREE.NodeEnvironment = function( input, op ) {
	
	THREE.NodeInput.call( this );
	
	this.op = op || '+';
	
	this.input = input;
	
};

THREE.NodeEnvironment.prototype = Object.create( THREE.NodeInput.prototype );
THREE.NodeEnvironment.prototype.constructor = THREE.NodeEnvironment;

THREE.NodeEnvironment.prototype.generate = function( material, shader, output ) {
	
	material.define( 'USE_ENVMAP' );
	
	return this.input.generate( material, shader, output );

};