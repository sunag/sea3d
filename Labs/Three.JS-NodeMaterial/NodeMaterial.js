
// File:GLNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.GLNode = function( type ) {

	this.uuid = THREE.Math.generateUUID();

	this.allow = {};
	this.requestUpdate = false;

	this.type = type;

};

THREE.GLNode.prototype.verify = function( builder, cache, requires ) {

	builder.isVerify = true;

	var material = builder.material;

	this.build( builder.addCache( cache, requires ), 'v4' );

	material.clearVertexNode();
	material.clearFragmentNode();

	builder.removeCache();

	builder.isVerify = false;

};

THREE.GLNode.prototype.verifyAndBuildCode = function( builder, output, cache, requires ) {

	this.verify( builder, cache, requires );

	return this.buildCode( builder, output, cache, requires );

};

THREE.GLNode.prototype.buildCode = function( builder, output, cache, requires ) {

	var material = builder.material;

	var data = { result : this.build( builder.addCache( cache, requires ), output ) };

	if ( builder.isShader( 'vertex' ) ) data.code = material.clearVertexNode();
	else data.code = material.clearFragmentNode();

	builder.removeCache();

	return data;

};

THREE.GLNode.prototype.verifyDepsNode = function( builder, data, output ) {

	data.deps = ( data.deps || 0 ) + 1;

	var outputLen = builder.getFormatLength( output );

	if ( outputLen > (data.outputMax || 0) || this.getType( builder ) ) {

		data.outputMax = outputLen;
		data.output = output;

	}

};

THREE.GLNode.prototype.build = function( builder, output, uuid ) {

	var material = builder.material;
	var data = material.getDataNode( uuid || this.uuid );

	if ( builder.isShader( 'verify' ) ) this.verifyDepsNode( builder, data, output );

	if ( this.allow[ builder.shader ] === false ) {

		throw new Error( 'Shader ' + shader + ' is not compatible with this node.' );

	}

	if ( this.requestUpdate && ! data.requestUpdate ) {

		material.requestUpdate.push( this );
		data.requestUpdate = true;

	}

	return this.generate( builder, output, uuid );

};

THREE.GLNode.prototype.getType = function( builder ) {

	return this.type;

};

// File:--materials/PhongNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.PhongNode = function() {

	THREE.GLNode.call( this );

	this.color = new THREE.ColorNode( 0xEEEEEE );
	this.specular = new THREE.ColorNode( 0x111111 );
	this.shininess = new THREE.FloatNode( 30 );

};

THREE.PhongNode.prototype = Object.create( THREE.GLNode.prototype );
THREE.PhongNode.prototype.constructor = THREE.PhongNode;

THREE.PhongNode.prototype.build = function( builder ) {

	var material = builder.material;
	var code;

	material.define( 'PHONG' );
	material.define( 'ALPHATEST', '0.0' );

	material.requestAttrib.light = true;

	if ( builder.isShader( 'vertex' ) ) {

		var transform = this.transform ? this.transform.verifyAndBuildCode( builder, 'v3', 'transform' ) : undefined;

		material.mergeUniform( THREE.UniformsUtils.merge( [

			THREE.UniformsLib[ "fog" ],
			THREE.UniformsLib[ "lights" ]

		] ) );

		material.addVertexPars( [
			"varying vec3 vViewPosition;",

			"#ifndef FLAT_SHADED",

			"	varying vec3 vNormal;",

			"#endif",

			THREE.ShaderChunk[ "common" ],
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

			"	vNormal = normalize( transformedNormal );",

			"#endif",

				THREE.ShaderChunk[ "begin_vertex" ]
		];

		if ( transform ) {

			output.push(
				transform.code,
				"transformed = " + transform.result + ";"
			);

		}

		output.push(
				THREE.ShaderChunk[ "morphtarget_vertex" ],
				THREE.ShaderChunk[ "skinning_vertex" ],
				THREE.ShaderChunk[ "project_vertex" ],
				THREE.ShaderChunk[ "logdepthbuf_vertex" ],

			"	vViewPosition = - mvPosition.xyz;",

				THREE.ShaderChunk[ "worldpos_vertex" ],
				THREE.ShaderChunk[ "shadowmap_vertex" ]
		);

		code = output.join( "\n" );

	}
	else {

		// verify all nodes to reuse generate codes

		this.color.verify( builder );
		this.specular.verify( builder );
		this.shininess.verify( builder );

		if ( this.alpha ) this.alpha.verify( builder );

		if ( this.light ) this.light.verify( builder, 'light' );

		if ( this.ao ) this.ao.verify( builder );
		if ( this.ambient ) this.ambient.verify( builder );
		if ( this.shadow ) this.shadow.verify( builder );
		if ( this.emissive ) this.emissive.verify( builder );

		if ( this.normal ) this.normal.verify( builder );
		if ( this.normalScale && this.normal ) this.normalScale.verify( builder );

		if ( this.environment ) this.environment.verify( builder );
		if ( this.environmentAlpha && this.environment ) this.environmentAlpha.verify( builder );

		// build code

		var color = this.color.buildCode( builder, 'c' );
		var specular = this.specular.buildCode( builder, 'c' );
		var shininess = this.shininess.buildCode( builder, 'fv1' );

		var alpha = this.alpha ? this.alpha.buildCode( builder, 'fv1' ) : undefined;

		var light = this.light ? this.light.buildCode( builder, 'v3', 'light' ) : undefined;

		var ao = this.ao ? this.ao.buildCode( builder, 'fv1' ) : undefined;
		var ambient = this.ambient ? this.ambient.buildCode( builder, 'c' ) : undefined;
		var shadow = this.shadow ? this.shadow.buildCode( builder, 'c' ) : undefined;
		var emissive = this.emissive ? this.emissive.buildCode( builder, 'c' ) : undefined;

		var normal = this.normal ? this.normal.buildCode( builder, 'v3' ) : undefined;
		var normalScale = this.normalScale && this.normal ? this.normalScale.buildCode( builder, 'v2' ) : undefined;

		var environment = this.environment ? this.environment.buildCode( builder, 'c' ) : undefined;
		var environmentAlpha = this.environmentAlpha && this.environment ? this.environmentAlpha.buildCode( builder, 'fv1' ) : undefined;

		material.requestAttrib.transparent = alpha != undefined;

		material.addFragmentPars( [
			THREE.ShaderChunk[ "common" ],
			THREE.ShaderChunk[ "fog_pars_fragment" ],
			THREE.ShaderChunk[ "bsdfs" ],
			THREE.ShaderChunk[ "lights_pars" ],
			THREE.ShaderChunk[ "lights_phong_pars_fragment" ],
			THREE.ShaderChunk[ "shadowmap_pars_fragment" ],
			THREE.ShaderChunk[ "logdepthbuf_pars_fragment" ]
		].join( "\n" ) );

		var output = [
				// prevent undeclared normal
				THREE.ShaderChunk[ "normal_fragment" ],

				// prevent undeclared material
			"	BlinnPhongMaterial material;",

				color.code,
			"	vec3 diffuseColor = " + color.result + ";",
			"	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );",

				THREE.ShaderChunk[ "logdepthbuf_fragment" ],

			specular.code,
			"	vec3 specular = " + specular.result + ";",

			shininess.code,
			"	float shininess = max(0.0001," + shininess.result + ");",

			"	float specularStrength = 1.0;" // Ignored in MaterialNode ( replace to specular )
		];

		if ( alpha ) {

			output.push(
				alpha.code,
				'if ( ' + alpha.result + ' <= ALPHATEST ) discard;'
			);

		}

		if ( normal ) {

			builder.include( 'perturbNormal2Arb' );

			output.push( normal.code );

			if ( normalScale ) output.push( normalScale.code );

			output.push(
				'normal = perturbNormal2Arb(-vViewPosition,normal,' +
				normal.result + ',' +
				new THREE.UVNode().build( builder, 'v2' ) + ',' +
				( normalScale ? normalScale.result : 'vec2( 1.0 )' ) + ');'
			);

		}

		// optimization for now

		output.push( 'material.diffuseColor = ' + ( light ? 'vec3( 1.0 )' : 'diffuseColor' ) + ';' );

		output.push(
			// accumulation
			'material.specularColor = specular;',
			'material.specularShininess = shininess;',
			'material.specularStrength = specularStrength;',

			THREE.ShaderChunk[ "lights_template" ]
		);

		if ( light ) {

			output.push(
				light.code,
				"reflectedLight.directDiffuse = " + light.result + ";"
			);

			// apply color

			output.push(
				"reflectedLight.directDiffuse *= diffuseColor;",
				"reflectedLight.indirectDiffuse *= diffuseColor;"
			);

		}

		if ( ao ) {

			output.push(
				ao.code,
				"reflectedLight.indirectDiffuse *= " + ao.result + ";"
			);

		}

		if ( ambient ) {

			output.push(
				ambient.code,
				"reflectedLight.indirectDiffuse += " + ambient.result + ";"
			);

		}

		if ( shadow ) {

			output.push(
				shadow.code,
				"reflectedLight.directDiffuse *= " + shadow.result + ";",
				"reflectedLight.directSpecular *= " + shadow.result + ";"
			);

		}

		if ( emissive ) {

			output.push(
				emissive.code,
				"reflectedLight.directDiffuse += " + emissive.result + ";"
			);

		}

		output.push( "vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + reflectedLight.directSpecular;" );

		if ( environment ) {

			output.push( environment.code );

			if ( environmentAlpha ) {

				output.push(
					environmentAlpha.code,
					"outgoingLight = mix(" + 'outgoingLight' + "," + environment.result + "," + environmentAlpha.result + ");"
				);

			}
			else {

				output.push( "outgoingLight = " + environment.result + ";" );

			}

		}

		output.push(
			THREE.ShaderChunk[ "linear_to_gamma_fragment" ],
			THREE.ShaderChunk[ "fog_fragment" ]
		);

		if ( alpha ) {

			output.push( "gl_FragColor = vec4( outgoingLight, " + alpha.result + " );" );

		}
		else {

			output.push( "gl_FragColor = vec4( outgoingLight, 1.0 );" );

		}

		code = output.join( "\n" );

	}

	return code;

};

// File:NodeMaterial.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeMaterial = function( vertex, fragment ) {

	THREE.ShaderMaterial.call( this );

	this.vertex = vertex || new THREE.RawNode( new THREE.PositionNode( THREE.PositionNode.PROJECTION ) );
	this.fragment = fragment || new THREE.RawNode( new THREE.ColorNode( 0xFF0000 ) );

};

THREE.NodeMaterial.types = {
	t : 'sampler2D',
	tc : 'samplerCube',
	bv1 : 'bool',
	iv1 : 'int',
	fv1 : 'float',
	c : 'vec3',
	v2 : 'vec2',
	v3 : 'vec3',
	v4 : 'vec4',
	m4 : 'mat4'
};

THREE.NodeMaterial.addShortcuts = function( proto, prop, list ) {

	function applyShortcut( prop, name ) {

		return {
			get: function() {

				return this[ prop ][ name ];

			},
			set: function( val ) {

				this[ prop ][ name ] = val;

			}
		};

	};

	return (function() {

		var shortcuts = {};

		for ( var i = 0; i < list.length; ++ i ) {

			var name = list[ i ];

			shortcuts[ name ] = applyShortcut( prop, name );

		}

		Object.defineProperties( proto, shortcuts );

	})();

};

THREE.NodeMaterial.prototype = Object.create( THREE.ShaderMaterial.prototype );
THREE.NodeMaterial.prototype.constructor = THREE.NodeMaterial;

THREE.NodeMaterial.prototype.updateAnimation = function( delta ) {

	for ( var i = 0; i < this.requestUpdate.length; ++ i ) {

		this.requestUpdate[ i ].updateAnimation( delta );

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

	this.consts = [];
	this.functions = [];

	this.requestUpdate = [];

	this.requestAttrib = {
		uv: [],
		color: []
	};

	this.vertexPars = '';
	this.fragmentPars = '';

	this.vertexCode = '';
	this.fragmentCode = '';

	this.vertexNode = '';
	this.fragmentNode = '';
	
	this.prefixCode = [
	"#ifdef GL_EXT_shader_texture_lod",

		"#define texCube(a, b) textureCube(a, b)",
		"#define texCubeBias(a, b, c) textureCubeLodEXT(a, b, c)",
		
		"#define tex2D(a, b) texture2D(a, b)",
		"#define tex2DBias(a, b, c) texture2DLodEXT(a, b, c)",
		
	"#else",
	
		"#define texCube(a, b) textureCube(a, b)",
		"#define texCubeBias(a, b, c) textureCube(a, b, c)",
		
		"#define tex2D(a, b) texture2D(a, b)",
		"#define tex2DBias(a, b, c) texture2D(a, b, c)",
		
	"#endif"
	].join( "\n" );

	var builder = new THREE.BuilderNode( this );

	vertex = this.vertex.build( builder.setShader( 'vertex' ), 'v4' );
	fragment = this.fragment.build( builder.setShader( 'fragment' ), 'v4' );

	if ( this.requestAttrib.uv[ 0 ] ) {

		this.addVertexPars( 'varying vec2 vUv;' );
		this.addFragmentPars( 'varying vec2 vUv;' );

		this.addVertexCode( 'vUv = uv;' );

	}

	if ( this.requestAttrib.uv[ 1 ] ) {

		this.addVertexPars( 'varying vec2 vUv2; attribute vec2 uv2;' );
		this.addFragmentPars( 'varying vec2 vUv2;' );

		this.addVertexCode( 'vUv2 = uv2;' );

	}

	if ( this.requestAttrib.color[ 0 ] ) {

		this.addVertexPars( 'varying vec4 vColor; attribute vec4 color;' );
		this.addFragmentPars( 'varying vec4 vColor;' );

		this.addVertexCode( 'vColor = color;' );

	}

	if ( this.requestAttrib.color[ 1 ] ) {

		this.addVertexPars( 'varying vec4 vColor2; attribute vec4 color2;' );
		this.addFragmentPars( 'varying vec4 vColor2;' );

		this.addVertexCode( 'vColor2 = color2;' );

	}

	if ( this.requestAttrib.position ) {

		this.addVertexPars( 'varying vec3 vPosition;' );
		this.addFragmentPars( 'varying vec3 vPosition;' );

		this.addVertexCode( 'vPosition = transformed;' );

	}

	if ( this.requestAttrib.worldPosition ) {

		// for future update replace from the native "varying vec3 vWorldPosition" for optimization

		this.addVertexPars( 'varying vec3 vWPosition;' );
		this.addFragmentPars( 'varying vec3 vWPosition;' );

		this.addVertexCode( 'vWPosition = worldPosition.xyz;' );

	}

	if ( this.requestAttrib.normal ) {

		this.addVertexPars( 'varying vec3 vObjectNormal;' );
		this.addFragmentPars( 'varying vec3 vObjectNormal;' );

		this.addVertexCode( 'vObjectNormal = normal;' );

	}

	if ( this.requestAttrib.worldNormal ) {

		this.addVertexPars( 'varying vec3 vWNormal;' );
		this.addFragmentPars( 'varying vec3 vWNormal;' );

		this.addVertexCode( 'vWNormal = ( modelMatrix * vec4( objectNormal, 0.0 ) ).xyz;' );

	}

	this.lights = this.requestAttrib.light;
	this.transparent = this.requestAttrib.transparent;

	this.vertexShader = [
		this.prefixCode,
		this.vertexPars,
		this.getCodePars( this.vertexUniform, 'uniform' ),
		this.getIncludes( this.consts[ 'vertex' ] ),
		this.getIncludes( this.functions[ 'vertex' ] ),
		'void main(){',
		this.getCodePars( this.vertexTemps ),
		vertex,
		this.vertexCode,
		'}'
	].join( "\n" );

	this.fragmentShader = [
		this.prefixCode,
		this.fragmentPars,
		this.getCodePars( this.fragmentUniform, 'uniform' ),
		this.getIncludes( this.consts[ 'fragment' ] ),
		this.getIncludes( this.functions[ 'fragment' ] ),
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

THREE.NodeMaterial.prototype.define = function( name, value ) {

	this.defines[ name ] = value == undefined ? 1 : value;

};

THREE.NodeMaterial.prototype.isDefined = function( name ) {

	return this.defines[ name ] != undefined;

};

THREE.NodeMaterial.prototype.mergeUniform = function( uniforms ) {

	for ( var name in uniforms ) {

		this.uniforms[ name ] = uniforms[ name ];

	}

};

THREE.NodeMaterial.prototype.createUniform = function( type, value, ns, needsUpdate ) {

	var index = this.uniformList.length;

	var uniform = {
		type : type,
		value : value,
		name : ns ? ns : 'nVu' + index,
		needsUpdate : needsUpdate
	};

	this.uniformList.push( uniform );

	return uniform;

};

THREE.NodeMaterial.prototype.getVertexTemp = function( uuid, type, ns ) {

	if ( ! this.vertexTemps[ uuid ] ) {

		var index = this.vertexTemps.length,
			name = ns ? ns : 'nVt' + index,
			data = { name : name, type : type };

		this.vertexTemps.push( data );
		this.vertexTemps[ uuid ] = data;

	}

	return this.vertexTemps[ uuid ];

};

THREE.NodeMaterial.prototype.getFragmentTemp = function( uuid, type, ns ) {

	if ( ! this.fragmentTemps[ uuid ] ) {

		var index = this.fragmentTemps.length,
			name = ns ? ns : 'nVt' + index,
			data = { name : name, type : type };

		this.fragmentTemps.push( data );
		this.fragmentTemps[ uuid ] = data;

	}

	return this.fragmentTemps[ uuid ];

};

THREE.NodeMaterial.prototype.getIncludes = function( incs ) {

	function sortByPosition( a, b ) {

		return b.deps - a.deps;

	}

	return function( incs ) {

		if ( ! incs ) return '';

		var code = '';
		var incs = incs.sort( sortByPosition );

		for ( var i = 0; i < incs.length; i ++ ) {

			code += incs[ i ].node.src + '\n';

		}

		return code;

	}

}();

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

	for ( var i = 0, l = pars.length; i < l; ++ i ) {

		var parsType = pars[ i ].type;
		var parsName = pars[ i ].name;
		var parsValue = pars[ i ].value;

		if ( parsType == 't' && parsValue instanceof THREE.CubeTexture ) parsType = 'tc';

		var type = THREE.NodeMaterial.types[ parsType ];

		if ( type == undefined ) throw new Error( "Node pars " + parsType + " not found." );

		code += prefix + ' ' + type + ' ' + parsName + ';\n';

	}

	return code;

};

THREE.NodeMaterial.prototype.createVertexUniform = function( type, value, ns, needsUpdate ) {

	var uniform = this.createUniform( type, value, ns, needsUpdate );

	this.vertexUniform.push( uniform );
	this.vertexUniform[ uniform.name ] = uniform;

	this.uniforms[ uniform.name ] = uniform;

	return uniform;

};

THREE.NodeMaterial.prototype.createFragmentUniform = function( type, value, ns, needsUpdate ) {

	var uniform = this.createUniform( type, value, ns, needsUpdate );

	this.fragmentUniform.push( uniform );
	this.fragmentUniform[ uniform.name ] = uniform;

	this.uniforms[ uniform.name ] = uniform;

	return uniform;

};

THREE.NodeMaterial.prototype.getDataNode = function( uuid ) {

	return this.nodeData[ uuid ] = this.nodeData[ uuid ] || {};

};

THREE.NodeMaterial.prototype.include = function( shader, node ) {

	var includes;

	node = typeof node === 'string' ? THREE.NodeLib.get( node ) : node;

	if ( node instanceof THREE.FunctionNode ) {

		for ( var i = 0; i < node.includes.length; i ++ ) {

			this.include( shader, node.includes[ i ] );

		}

		includes = this.functions[ shader ] = this.functions[ shader ] || [];

	}
	else if ( node instanceof THREE.ConstNode ) {

		includes = this.consts[ shader ] = this.consts[ shader ] || [];

	}

	if ( includes[ node.name ] === undefined ) {

		for ( var ext in node.extensions ) {

			this.extensions[ ext ] = true;

		}

		includes[ node.name ] = {
			node : node,
			deps : 1
		};

		includes.push( includes[ node.name ] );

	}
	else ++ includes[ node.name ].deps;

};

// File:--materials/PhongNodeMaterial.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.PhongNodeMaterial = function() {

	this.node = new THREE.PhongNode();

	THREE.NodeMaterial.call( this, this.node, this.node );

};

THREE.PhongNodeMaterial.prototype = Object.create( THREE.NodeMaterial.prototype );
THREE.PhongNodeMaterial.prototype.constructor = THREE.PhongNodeMaterial;

THREE.NodeMaterial.addShortcuts( THREE.PhongNodeMaterial.prototype, 'node',
[ 'color', 'alpha', 'specular', 'shininess', 'normal', 'normalScale', 'emissive', 'ambient', 'light', 'shadow', 'ao', 'environment', 'environmentAlpha', 'transform' ] );

// File:--materials/StandardNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.StandardNode = function() {

	THREE.GLNode.call( this );

	this.color = new THREE.ColorNode( 0xEEEEEE );
	this.roughness = new THREE.FloatNode( 0.5 );
	this.metalness = new THREE.FloatNode( 0.5 );

};

THREE.StandardNode.prototype = Object.create( THREE.GLNode.prototype );
THREE.StandardNode.prototype.constructor = THREE.StandardNode;

THREE.StandardNode.prototype.build = function( builder ) {

	var material = builder.material;
	var code;

	material.define( 'STANDARD' );
	material.define( 'ALPHATEST', '0.0' );

	material.requestAttrib.light = true;

	if ( builder.isShader( 'vertex' ) ) {

		var transform = this.transform ? this.transform.verifyAndBuildCode( builder, 'v3', 'transform' ) : undefined;

		material.mergeUniform( THREE.UniformsUtils.merge( [

			THREE.UniformsLib[ "fog" ],
			THREE.UniformsLib[ "lights" ]

		] ) );

		material.addVertexPars( [
			"varying vec3 vViewPosition;",

			"#ifndef FLAT_SHADED",

			"	varying vec3 vNormal;",

			"#endif",

			THREE.ShaderChunk[ "common" ],
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

			"	vNormal = normalize( transformedNormal );",

			"#endif",

				THREE.ShaderChunk[ "begin_vertex" ]
		];

		if ( transform ) {

			output.push(
				transform.code,
				"transformed = " + transform.result + ";"
			);

		}

		output.push(
				THREE.ShaderChunk[ "morphtarget_vertex" ],
				THREE.ShaderChunk[ "skinning_vertex" ],
				THREE.ShaderChunk[ "project_vertex" ],
				THREE.ShaderChunk[ "logdepthbuf_vertex" ],

			"	vViewPosition = - mvPosition.xyz;",

				THREE.ShaderChunk[ "worldpos_vertex" ],
				THREE.ShaderChunk[ "shadowmap_vertex" ]
		);

		code = output.join( "\n" );

	}
	else {

		// autoblur textures for PBR Material effect

		var requires = {
			bias : new THREE.RoughnessToBlinnExponentNode()
		};

		// verify all nodes to reuse generate codes

		this.color.verify( builder );
		this.roughness.verify( builder );
		this.metalness.verify( builder );

		if ( this.alpha ) this.alpha.verify( builder );

		if ( this.light ) this.light.verify( builder, 'light' );

		if ( this.ao ) this.ao.verify( builder );
		if ( this.ambient ) this.ambient.verify( builder );
		if ( this.shadow ) this.shadow.verify( builder );
		if ( this.emissive ) this.emissive.verify( builder );

		if ( this.normal ) this.normal.verify( builder );
		if ( this.normalScale && this.normal ) this.normalScale.verify( builder );

		if ( this.environment ) this.environment.verify( builder, 'env', requires ); // isolate environment from others inputs ( see TextureNode, CubeTextureNode )

		// build code

		var color = this.color.buildCode( builder, 'c' );
		var roughness = this.roughness.buildCode( builder, 'fv1' );
		var metalness = this.metalness.buildCode( builder, 'fv1' );

		var alpha = this.alpha ? this.alpha.buildCode( builder, 'fv1' ) : undefined;

		var light = this.light ? this.light.buildCode( builder, 'v3', 'light' ) : undefined;

		var ao = this.ao ? this.ao.buildCode( builder, 'fv1' ) : undefined;
		var ambient = this.ambient ? this.ambient.buildCode( builder, 'c' ) : undefined;
		var shadow = this.shadow ? this.shadow.buildCode( builder, 'c' ) : undefined;
		var emissive = this.emissive ? this.emissive.buildCode( builder, 'c' ) : undefined;

		var normal = this.normal ? this.normal.buildCode( builder, 'v3' ) : undefined;
		var normalScale = this.normalScale && this.normal ? this.normalScale.buildCode( builder, 'v2' ) : undefined;

		var environment = this.environment ? this.environment.buildCode( builder, 'c', 'env', requires ) : undefined;

		material.requestAttrib.transparent = alpha != undefined;

		material.addFragmentPars( [

			"varying vec3 vViewPosition;",

			"#ifndef FLAT_SHADED",

			"	varying vec3 vNormal;",

			"#endif",

			THREE.ShaderChunk[ "common" ],
			THREE.ShaderChunk[ "fog_pars_fragment" ],
			THREE.ShaderChunk[ "bsdfs" ],
			THREE.ShaderChunk[ "lights_pars" ],
			THREE.ShaderChunk[ "lights_physical_pars_fragment" ],
			THREE.ShaderChunk[ "shadowmap_pars_fragment" ],
			THREE.ShaderChunk[ "logdepthbuf_pars_fragment" ],
		].join( "\n" ) );

		var output = [
				// prevent undeclared normal
				THREE.ShaderChunk[ "normal_fragment" ],

				// prevent undeclared material
			"	PhysicalMaterial material;",
			"	material.diffuseColor = vec3( 1.0 );",

				color.code,
			"	vec3 diffuseColor = " + color.result + ";",
			"	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );",

				THREE.ShaderChunk[ "logdepthbuf_fragment" ],

			roughness.code,
			"	float roughnessFactor = " + roughness.result + ";",

			metalness.code,
			"	float metalnessFactor = " + metalness.result + ";"
		];

		if ( alpha ) {

			output.push(
				alpha.code,
				'if ( ' + alpha.result + ' <= ALPHATEST ) discard;'
			);

		}

		if ( normal ) {

			builder.include( 'perturbNormal2Arb' );

			output.push( normal.code );

			if ( normalScale ) output.push( normalScale.code );

			output.push(
				'normal = perturbNormal2Arb(-vViewPosition,normal,' +
				normal.result + ',' +
				new THREE.UVNode().build( builder, 'v2' ) + ',' +
				( normalScale ? normalScale.result : 'vec2( 1.0 )' ) + ');'
			);

		}

		// optimization for now

		output.push( 'material.diffuseColor = ' + ( light ? 'vec3( 1.0 )' : 'diffuseColor * (1.0 - metalnessFactor)' ) + ';' );

		output.push(
			// accumulation
			'material.specularRoughness = clamp( roughnessFactor, 0.001, 1.0 );', // disney's remapping of [ 0, 1 ] roughness to [ 0.001, 1 ]
			'material.specularColor = mix( vec3( 0.001 ), diffuseColor, metalnessFactor );',

			THREE.ShaderChunk[ "lights_template" ]
		);

		if ( light ) {

			output.push(
				light.code,
				"reflectedLight.directDiffuse = " + light.result + ";"
			);

			// apply color

			output.push(
				"diffuseColor *= 1.0 - metalnessFactor;",

				"reflectedLight.directDiffuse *= diffuseColor;",
				"reflectedLight.indirectDiffuse *= diffuseColor;"
			);

		}

		if ( ao ) {

			output.push(
				ao.code,
				"reflectedLight.indirectDiffuse *= " + ao.result + ";"
			);

		}

		if ( ambient ) {

			output.push(
				ambient.code,
				"reflectedLight.indirectDiffuse += " + ambient.result + ";"
			);

		}

		if ( shadow ) {

			output.push(
				shadow.code,
				"reflectedLight.directDiffuse *= " + shadow.result + ";",
				"reflectedLight.directSpecular *= " + shadow.result + ";"
			);

		}

		if ( emissive ) {

			output.push(
				emissive.code,
				"reflectedLight.directDiffuse += " + emissive.result + ";"
			);

		}

		if ( environment ) {

			output.push(
				environment.code,
				"RE_IndirectSpecular(" + environment.result + ", geometry, material, reflectedLight );"
			);

		}

		output.push( "vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + reflectedLight.directSpecular + reflectedLight.indirectSpecular;" );

		output.push(
			THREE.ShaderChunk[ "linear_to_gamma_fragment" ],
			THREE.ShaderChunk[ "fog_fragment" ]
		);

		if ( alpha ) {

			output.push( "gl_FragColor = vec4( outgoingLight, " + alpha.result + " );" );

		}
		else {

			output.push( "gl_FragColor = vec4( outgoingLight, 1.0 );" );

		}

		code = output.join( "\n" );

	}

	return code;

};

// File:--materials/StandardNodeMaterial.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.StandardNodeMaterial = function() {

	this.node = new THREE.StandardNode();

	THREE.NodeMaterial.call( this, this.node, this.node );

};

THREE.StandardNodeMaterial.prototype = Object.create( THREE.NodeMaterial.prototype );
THREE.StandardNodeMaterial.prototype.constructor = THREE.StandardNodeMaterial;

THREE.NodeMaterial.addShortcuts( THREE.StandardNodeMaterial.prototype, 'node',
[ 'color', 'alpha', 'roughness', 'metalness', 'normal', 'normalScale', 'emissive', 'ambient', 'light', 'shadow', 'ao', 'environment', 'transform' ] );

// File:TempNode.js

/**
 * Automatic node cache
 * @author sunag / http://www.sunag.com.br/
 */

THREE.TempNode = function( type, params ) {

	THREE.GLNode.call( this, type );

	params = params || {};

	this.shared = params.shared !== undefined ? params.shared : true;
	this.unique = params.unique !== undefined ? params.unique : false;

};

THREE.TempNode.prototype = Object.create( THREE.GLNode.prototype );
THREE.TempNode.prototype.constructor = THREE.TempNode;

THREE.TempNode.prototype.build = function( builder, output, uuid, ns ) {

	var material = builder.material;

	if ( this.isShared() ) {

		var isUnique = this.isUnique();

		if ( isUnique && this.constructor.uuid === undefined ) {

			this.constructor.uuid = THREE.Math.generateUUID();

		}

		uuid = builder.getUuid( uuid || this.getUuid(), ! isUnique );

		var data = material.getDataNode( uuid );

		if ( builder.isShader( 'verify' ) ) {

			if ( data.deps || 0 > 0 ) {

				this.verifyDepsNode( builder, data, output );
				return '';

			}

			return THREE.GLNode.prototype.build.call( this, builder, output, uuid );

		}
		else if ( data.deps == 1 ) {

			return THREE.GLNode.prototype.build.call( this, builder, output, uuid );

		}

		var name = this.getTemp( builder, uuid );
		var type = data.output || this.getType( builder );

		if ( name ) {

			return builder.format( name, type, output );

		}
		else {

			name = THREE.TempNode.prototype.generate.call( this, builder, output, uuid, data.output, ns );

			var code = this.generate( builder, type, uuid );

			if ( builder.isShader( 'vertex' ) ) material.addVertexNode( name + '=' + code + ';' );
			else material.addFragmentNode( name + '=' + code + ';' );

			return builder.format( name, type, output );

		}

	}
	else {

		return builder.format( this.generate( builder, this.getType( builder ), uuid ), this.getType( builder ), output );

	}

};

THREE.TempNode.prototype.isShared = function() {

	return this.shared;

};

THREE.TempNode.prototype.isUnique = function() {

	return this.unique;

};

THREE.TempNode.prototype.getUuid = function() {

	var uuid = this.constructor.uuid || this.uuid;

	if (typeof this.scope == "string") uuid = this.scope + '-' + uuid;

	return uuid;

};

THREE.TempNode.prototype.getTemp = function( builder, uuid ) {

	uuid = uuid || this.uuid;

	var material = builder.material;

	if ( builder.isShader( 'vertex' ) && material.vertexTemps[ uuid ] ) return material.vertexTemps[ uuid ].name;
	else if ( material.fragmentTemps[ uuid ] ) return material.fragmentTemps[ uuid ].name;

};

THREE.TempNode.prototype.generate = function( builder, output, uuid, type, ns ) {

	if ( ! this.isShared() ) console.error( "THREE.TempNode is not shared!" );

	uuid = uuid || this.uuid;

	if ( builder.isShader( 'vertex' ) ) return builder.material.getVertexTemp( uuid, type || this.getType( builder ), ns ).name;
	else return builder.material.getFragmentTemp( uuid, type || this.getType( builder ), ns ).name;

};

// File:accessors/CameraNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.CameraNode = function( scope, camera ) {

	THREE.TempNode.call( this, 'v3' );

	this.setScope( scope || THREE.CameraNode.POSITION );
	this.setCamera( camera );

};

THREE.CameraNode.POSITION = 'position';
THREE.CameraNode.DEPTH = 'depth';
THREE.CameraNode.TO_VERTEX = 'toVertex';

THREE.CameraNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.CameraNode.prototype.constructor = THREE.CameraNode;

THREE.CameraNode.prototype.setCamera = function( camera ) {

	this.camera = camera;
	this.requestUpdate = camera !== undefined;

};

THREE.CameraNode.prototype.setScope = function( scope ) {

	switch ( this.scope ) {

		case THREE.CameraNode.DEPTH:

			delete this.near;
			delete this.far;

			break;

	}

	this.scope = scope;

	switch ( scope ) {

		case THREE.CameraNode.DEPTH:

			this.near = new THREE.FloatNode( camera ? camera.near : 1 );
			this.far = new THREE.FloatNode( camera ? camera.far : 1200 );

			break;

	}

};

THREE.CameraNode.prototype.getType = function( builder ) {

	switch ( this.scope ) {
		case THREE.CameraNode.DEPTH:
			return 'fv1';
	}

	return this.type;

};

THREE.CameraNode.prototype.isUnique = function( builder ) {

	switch ( this.scope ) {
		case THREE.CameraNode.DEPTH:
		case THREE.CameraNode.TO_VERTEX:
			return true;
	}

	return false;

};

THREE.CameraNode.prototype.isShared = function( builder ) {

	switch ( this.scope ) {
		case THREE.CameraNode.POSITION:
			return false;
	}

	return true;

};

THREE.CameraNode.prototype.generate = function( builder, output ) {

	var material = builder.material;
	var result;

	switch ( this.scope ) {

		case THREE.CameraNode.POSITION:

			result = 'cameraPosition';

			break;

		case THREE.CameraNode.DEPTH:

			builder.include( 'depthcolor' );

			result = 'depthcolor(' + this.near.build( builder, 'fv1' ) + ',' + this.far.build( builder, 'fv1' ) + ')';

			break;

		case THREE.CameraNode.TO_VERTEX:

			result = 'normalize( ' + new THREE.PositionNode( THREE.PositionNode.WORLD ).build( builder, 'v3' ) + ' - cameraPosition )';

			break;

	}

	return builder.format( result, this.getType( builder ), output );

};

THREE.CameraNode.prototype.updateAnimation = function( delta ) {

	switch ( this.scope ) {

		case THREE.CameraNode.DEPTH:

			this.near.number = camera.near;
			this.far.number = camera.far;

			break;

	}

};

// File:accessors/ColorsNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.ColorsNode = function( index ) {

	THREE.TempNode.call( this, 'v4', { share: false } );

	this.index = index || 0;

};

THREE.ColorsNode.vertexDict = [ 'color', 'color2' ];
THREE.ColorsNode.fragmentDict = [ 'vColor', 'vColor2' ];

THREE.ColorsNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.ColorsNode.prototype.constructor = THREE.ColorsNode;

THREE.ColorsNode.prototype.generate = function( builder, output ) {

	var material = builder.material;
	var result;

	material.requestAttrib.color[ this.index ] = true;

	if ( builder.isShader( 'vertex' ) ) result = THREE.ColorsNode.vertexDict[ this.index ];
	else result = THREE.ColorsNode.fragmentDict[ this.index ];

	return builder.format( result, this.getType( builder ), output );

};

// File:accessors/LightNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.LightNode = function() {

	THREE.TempNode.call( this, 'v3', { shared: false } );

};

THREE.LightNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.LightNode.prototype.constructor = THREE.LightNode;

THREE.LightNode.prototype.generate = function( builder, output ) {

	if ( builder.isCache( 'light' ) ) {

		return builder.format( 'reflectedLight.directDiffuse', this.getType( builder ), output )

	}
	else {

		console.warn( "THREE.LightNode is only compatible in \"light\" channel." );

		return builder.format( 'vec3( 0.0 )', this.getType( builder ), output );

	}

};

// File:accessors/NormalNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NormalNode = function( scope ) {

	THREE.TempNode.call( this, 'v3' );

	this.scope = scope || THREE.NormalNode.LOCAL;

};

THREE.NormalNode.LOCAL = 'local';
THREE.NormalNode.WORLD = 'world';
THREE.NormalNode.VIEW = 'view';

THREE.NormalNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.NormalNode.prototype.constructor = THREE.NormalNode;

THREE.NormalNode.prototype.isShared = function( builder ) {

	switch ( this.scope ) {
		case THREE.NormalNode.WORLD:
			return true;
	}

	return false;

};

THREE.NormalNode.prototype.generate = function( builder, output ) {

	var material = builder.material;
	var result;

	switch ( this.scope ) {

		case THREE.NormalNode.LOCAL:

			material.requestAttrib.normal = true;

			if ( builder.isShader( 'vertex' ) ) result = 'normal';
			else result = 'vObjectNormal';

			break;

		case THREE.NormalNode.WORLD:

			material.requestAttrib.worldNormal = true;

			if ( builder.isShader( 'vertex' ) ) result = '( modelMatrix * vec4( objectNormal, 0.0 ) ).xyz';
			else result = 'vWNormal';

			break;

		case THREE.NormalNode.VIEW:

			result = 'vNormal';

			break;

	}

	return builder.format( result, this.getType( builder ), output );

};

// File:accessors/PositionNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.PositionNode = function( scope ) {

	THREE.TempNode.call( this, 'v3' );

	this.scope = scope || THREE.PositionNode.LOCAL;

};

THREE.PositionNode.LOCAL = 'local';
THREE.PositionNode.WORLD = 'world';
THREE.PositionNode.VIEW = 'view';
THREE.PositionNode.PROJECTION = 'projection';

THREE.PositionNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.PositionNode.prototype.constructor = THREE.PositionNode;

THREE.PositionNode.prototype.getType = function( builder ) {

	switch ( this.scope ) {
		case THREE.PositionNode.PROJECTION:
			return 'v4';
	}

	return this.type;

};

THREE.PositionNode.prototype.isShared = function( builder ) {

	switch ( this.scope ) {
		case THREE.PositionNode.LOCAL:
		case THREE.PositionNode.WORLD:
			return false;
	}

	return true;

};

THREE.PositionNode.prototype.generate = function( builder, output ) {

	var material = builder.material;
	var result;

	switch ( this.scope ) {

		case THREE.PositionNode.LOCAL:

			material.requestAttrib.position = true;

			if ( builder.isShader( 'vertex' ) ) result = 'transformed';
			else result = 'vPosition';

		break;

		case THREE.PositionNode.WORLD:

			material.requestAttrib.worldPosition = true;

			if ( builder.isShader( 'vertex' ) ) result = 'vWPosition';
			else result = 'vWPosition';

		break;

		case THREE.PositionNode.VIEW:

			if ( builder.isShader( 'vertex' ) ) result = '-mvPosition.xyz';
			else result = 'vViewPosition';

		break;

		case THREE.PositionNode.PROJECTION:

			if ( builder.isShader( 'vertex' ) ) result = '(projectionMatrix * modelViewMatrix * vec4( position, 1.0 ))';
			else result = 'vec4( 0.0 )';

		break;

	}

	return builder.format( result, this.getType( builder ), output );

};

// File:accessors/ReflectNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.ReflectNode = function( scope ) {

	THREE.TempNode.call( this, 'v3', { unique: true } );

	this.scope = scope || THREE.ReflectNode.CUBE;

};

THREE.ReflectNode.CUBE = 'cube';
THREE.ReflectNode.SPHERE = 'sphere';
THREE.ReflectNode.VECTOR = 'vector';

THREE.ReflectNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.ReflectNode.prototype.constructor = THREE.ReflectNode;

THREE.ReflectNode.prototype.getType = function( builder ) {

	switch ( this.scope ) {
		case THREE.CameraNode.SPHERE:
			return 'v2';
	}

	return this.type;

};

THREE.ReflectNode.prototype.generate = function( builder, output ) {

	var result;

	switch ( this.scope ) {
		
		case THREE.ReflectNode.VECTOR:
		
			builder.material.addFragmentNode( 'vec3 reflectVec = inverseTransformDirection( reflect( -geometry.viewDir, geometry.normal ), viewMatrix );' );
			
			result = 'reflectVec';
			
			break;
		
		case THREE.ReflectNode.CUBE:
			
			var reflectVec = new THREE.ReflectNode( THREE.ReflectNode.VECTOR ).build( builder, 'v3' );
			
			builder.material.addFragmentNode( 'vec3 reflectCubeVec = vec3( -1.0 * ' + reflectVec + '.x, ' + reflectVec + '.yz );' );
			
			result = 'reflectCubeVec';
			
			break;

		case THREE.ReflectNode.SPHERE:
		
			var reflectVec = new THREE.ReflectNode( THREE.ReflectNode.VECTOR ).build( builder, 'v3' );
		
			builder.material.addFragmentNode( 'vec3 reflectSphereVec = normalize((viewMatrix * vec4(' + reflectVec + ', 0.0 )).xyz + vec3(0.0,0.0,1.0)).xy * 0.5 + 0.5;' );
		
			result = 'reflectSphereVec';
			
			break;
	}

	return builder.format( result, this.getType( this.type ), output );

};

// File:accessors/ScreenUVNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.ScreenUVNode = function( resolution ) {

	THREE.TempNode.call( this, 'v2' );

	this.resolution = resolution;

};

THREE.ScreenUVNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.ScreenUVNode.prototype.constructor = THREE.ScreenUVNode;

THREE.ScreenUVNode.prototype.generate = function( builder, output ) {

	var material = builder.material;
	var result;

	if ( builder.isShader( 'fragment' ) ) {

		result = '(gl_FragCoord.xy/' + this.resolution.build( builder, 'v2' ) + ')';

	}
	else {

		console.warn( "THREE.ScreenUVNode is not compatible with " + builder.shader + " shader." );

		result = 'vec2( 0.0 )';

	}

	return builder.format( result, this.getType( builder ), output );

};

// File:accessors/UVNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.UVNode = function( index ) {

	THREE.TempNode.call( this, 'v2', { shared: false } );

	this.index = index || 0;

};

THREE.UVNode.vertexDict = [ 'uv', 'uv2' ];
THREE.UVNode.fragmentDict = [ 'vUv', 'vUv2' ];

THREE.UVNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.UVNode.prototype.constructor = THREE.UVNode;

THREE.UVNode.prototype.generate = function( builder, output ) {

	var material = builder.material;
	var result;

	material.requestAttrib.uv[ this.index ] = true;

	if ( builder.isShader( 'vertex' ) ) result = THREE.UVNode.vertexDict[ this.index ];
	else result = THREE.UVNode.fragmentDict[ this.index ];

	return builder.format( result, this.getType( builder ), output );

};

// File:BuilderNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.BuilderNode = function( material ) {

	this.material = material;

	this.caches = [];
	this.isVerify = false;

	this.addCache();

};

THREE.BuilderNode.prototype = {
	constructor: THREE.BuilderNode,

	addCache : function( name, requires ) {

		this.caches.push( {
			name : name || '',
			requires : requires || {}
		} );

		return this.updateCache();

	},

	removeCache : function() {

		this.caches.pop();

		return this.updateCache();

	},

	isCache : function( name ) {

		var i = this.caches.length;

		while ( i -- ) {

			if ( this.caches[ i ].name == name ) return true;

		}

		return false;

	},

	updateCache : function() {

		var cache = this.caches[ this.caches.length - 1 ];

		this.cache = cache.name;
		this.requires = cache.requires;

		return this;

	},

	require : function( name, node ) {

		this.requires[ name ] = node;

		return this;

	},

	include : function( func ) {

		this.material.include( this.shader, func );

		return this;

	},

	colorToVector : function( color ) {

		return color.replace( 'r', 'x' ).replace( 'g', 'y' ).replace( 'b', 'z' ).replace( 'a', 'w' );

	},

	getFormatConstructor : function( len ) {

		return THREE.BuilderNode.constructors[ len - 1 ];

	},

	getFormatName : function( format ) {

		return format.replace( /c/g, 'v3' ).replace( /fv1|iv1/g, 'v1' );

	},

	isFormatMatrix : function( format ) {

		return /^m/.test( format );

	},
	
	getFormatLength : function( format ) {

		return parseInt( this.getFormatName( format ).substr( 1 ) );

	},

	getFormatByLength : function( len ) {

		if ( len == 1 ) return 'fv1';

		return 'v' + len;

	},

	format : function( code, from, to ) {

		var format = this.getFormatName( from + '=' + to );

		switch ( format ) {
			case 'v1=v2': return 'vec2(' + code + ')';
			case 'v1=v3': return 'vec3(' + code + ')';
			case 'v1=v4': return 'vec4(' + code + ')';

			case 'v2=v1': return code + '.x';
			case 'v2=v3': return 'vec3(' + code + ',0.0)';
			case 'v2=v4': return 'vec4(' + code + ',0.0,1.0)';

			case 'v3=v1': return code + '.x';
			case 'v3=v2': return code + '.xy';
			case 'v3=v4': return 'vec4(' + code + ',1.0)';

			case 'v4=v1': return code + '.x';
			case 'v4=v2': return code + '.xy';
			case 'v4=v3': return code + '.xyz';
		}

		return code;

	},

	getTypeByFormat : function( format ) {

		return THREE.BuilderNode.type[ format ];

	},

	getUuid : function( uuid, useCache ) {

		useCache = useCache !== undefined ? useCache : true;

		if ( useCache && this.cache ) uuid = this.cache + '-' + uuid;

		return uuid;

	},

	getElementByIndex : function( index ) {

		return THREE.BuilderNode.elements[ index ];

	},

	getIndexByElement : function( elm ) {

		return THREE.BuilderNode.elements.indexOf( elm );

	},

	isShader : function( shader ) {

		return this.shader == shader || this.isVerify;

	},

	setShader : function( shader ) {

		this.shader = shader;

		return this;

	}
};

THREE.BuilderNode.type = {
	'float' : 'fv1',
	vec2 : 'v2',
	vec3 : 'v3',
	vec4 : 'v4',
	mat4 : 'v4'
};

THREE.BuilderNode.constructors = [
	'',
	'vec2',
	'vec3',
	'vec4'
];

THREE.BuilderNode.elements = [
	'x',
	'y',
	'z',
	'w'
];

// File:ConstNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.ConstNode = function( name, useDefine ) {

	THREE.TempNode.call( this );

	this.parse( name || THREE.ConstNode.PI, useDefine );

};

THREE.ConstNode.PI = 'PI';
THREE.ConstNode.PI2 = 'PI2';
THREE.ConstNode.RECIPROCAL_PI = 'RECIPROCAL_PI';
THREE.ConstNode.RECIPROCAL_PI2 = 'RECIPROCAL_PI2';
THREE.ConstNode.LOG2 = 'LOG2';
THREE.ConstNode.EPSILON = 'EPSILON';

THREE.ConstNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.ConstNode.prototype.constructor = THREE.ConstNode;

THREE.ConstNode.prototype.parse = function( src, useDefine ) {

	var name, type;

	var rDeclaration = /^([a-z_0-9]+)\s([a-z_0-9]+)\s?\=(.*?)\;/i;
	var match = src.match( rDeclaration );

	if ( match && match.length > 1 ) {

		type = match[ 1 ];
		name = match[ 2 ];

		if ( useDefine ) {

			this.src = '#define ' + name + ' ' + match[ 3 ];

		}
		else {

			this.src = 'const ' + type + ' ' + name + ' = ' + match[ 3 ] + ';';

		}

	}
	else {

		name = src;
		type = 'fv1';

	}

	this.name = name;
	this.type = type;

};

THREE.ConstNode.prototype.generate = function( builder, output ) {

	return builder.format( this.name, this.getType( builder ), output );

};

// File:FunctionCallNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.FunctionCallNode = function( value ) {

	THREE.TempNode.call( this );

	this.setFunction( value );

};

THREE.FunctionCallNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.FunctionCallNode.prototype.constructor = THREE.FunctionCallNode;

THREE.FunctionCallNode.prototype.setFunction = function( val ) {

	this.inputs = [];
	this.value = val;

};

THREE.FunctionCallNode.prototype.getFunction = function() {

	return this.value;

};

THREE.FunctionCallNode.prototype.getType = function( builder ) {

	return this.value.getType( builder );

};

THREE.FunctionCallNode.prototype.generate = function( builder, output ) {

	var material = builder.material;

	var type = this.getType( builder );
	var func = this.value;

	builder.include( func );

	var code = func.name + '(';
	var params = [];

	for ( var i = 0; i < func.inputs.length; i ++ ) {

		var inpt = func.inputs[ i ];
		var param = this.inputs[ i ] || this.inputs[ inpt.name ];

		params.push( param.build( builder, builder.getTypeByFormat( inpt.type ) ) );

	}

	code += params.join( ',' ) + ')';

	return builder.format( code, type, output );

};

// File:FunctionNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 * @thanks bhouston / https://clara.io/
 */

THREE.FunctionNode = function( src, includes, extensions ) {

	THREE.GLNode.call( this );

	this.parse( src || '', includes, extensions );

};

THREE.FunctionNode.prototype = Object.create( THREE.GLNode.prototype );
THREE.FunctionNode.prototype.constructor = THREE.FunctionNode;

THREE.FunctionNode.prototype.parseReference = function( name ) {

	switch ( name ) {
		case 'uv': return new THREE.UVNode().name;
		case 'uv2': return new THREE.UVNode( 1 ).name;
		case 'position': return new THREE.PositionNode().name;
		case 'worldPosition': return new THREE.PositionNode( THREE.PositionNode.WORLD ).name;
		case 'normal': return new THREE.NormalNode().name;
		case 'normalPosition': return new THREE.NormalNode( THREE.NormalNode.WORLD ).name;
		case 'viewPosition': return new THREE.PositionNode( THREE.NormalNode.VIEW ).name;
		case 'viewNormal': return new THREE.NormalNode( THREE.NormalNode.VIEW ).name;
	}

	return name;

};

THREE.FunctionNode.prototype.getTypeNode = function( builder, type ) {

	return builder.getTypeByFormat( type ) || type;

};

THREE.FunctionNode.prototype.getInputByName = function( name ) {

	var i = this.inputs.length;

	while ( i -- ) {

		if ( this.inputs[ i ].name === name )
			return this.inputs[ i ];

	}

};

THREE.FunctionNode.prototype.getType = function( builder ) {

	return this.getTypeNode( builder, this.type );

};

THREE.FunctionNode.prototype.getInclude = function( name ) {

	var i = this.includes.length;

	while ( i -- ) {

		if ( this.includes[ i ].name === name )
			return this.includes[ i ];

	}

	return undefined;

};

THREE.FunctionNode.prototype.parse = function( src, includes, extensions ) {

	var rDeclaration = /^([a-z_0-9]+)\s([a-z_0-9]+)\s?\((.*?)\)/i;
	var rProperties = /[a-z_0-9]+/ig;

	this.includes = includes || [];
	this.extensions = extensions || {};

	var match = src.match( rDeclaration );

	this.inputs = [];

	if ( match && match.length == 4 ) {

		this.type = match[ 1 ];
		this.name = match[ 2 ];

		var inputs = match[ 3 ].match( rProperties );

		if ( inputs ) {

			var i = 0;

			while ( i < inputs.length ) {

				var qualifier = inputs[ i ++ ];
				var type, name;

				if ( qualifier == 'in' || qualifier == 'out' || qualifier == 'inout' ) {

					type = inputs[ i ++ ];

				}
				else {

					type = qualifier;
					qualifier = '';

				}

				name = inputs[ i ++ ];

				this.inputs.push( {
					name : name,
					type : type,
					qualifier : qualifier
				} );

			}

		}

		var match, offset = 0;

		while ( match = rProperties.exec( src ) ) {

			var prop = match[ 0 ];
			var reference = this.parseReference( prop );

			if ( prop != reference ) {

				src = src.substring( 0, match.index + offset ) + reference + src.substring( match.index + prop.length + offset );

				offset += reference.length - prop.length;

			}

			if ( this.getInclude( reference ) === undefined && THREE.NodeLib.contains( reference ) ) {

				this.includes.push( THREE.NodeLib.get( reference ) );

			}

		}

		this.src = src;

	}
	else {

		this.type = '';
		this.name = '';

	}

};

// File:InputNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.InputNode = function( type, params ) {

	THREE.TempNode.call( this, type, params );

};

THREE.InputNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.InputNode.prototype.constructor = THREE.InputNode;

THREE.InputNode.prototype.generate = function( builder, output, uuid, type, ns, needsUpdate ) {

	var material = builder.material;

	uuid = builder.getUuid( uuid || this.getUuid() );
	type = type || this.getType( builder );

	var data = material.getDataNode( uuid );

	if ( builder.isShader( 'vertex' ) ) {

		if ( ! data.vertex ) {

			data.vertex = material.createVertexUniform( type, this.value, ns, needsUpdate );

		}

		return builder.format( data.vertex.name, type, output );

	}
	else {

		if ( ! data.fragment ) {

			data.fragment = material.createFragmentUniform( type, this.value, ns, needsUpdate );

		}

		return builder.format( data.fragment.name, type, output );

	}

};

// File:inputs/ColorNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.ColorNode = function( color ) {

	THREE.InputNode.call( this, 'c', { share: false } );

	this.value = new THREE.Color( color || 0 );

};

THREE.ColorNode.prototype = Object.create( THREE.InputNode.prototype );
THREE.ColorNode.prototype.constructor = THREE.ColorNode;

THREE.NodeMaterial.addShortcuts( THREE.ColorNode.prototype, 'value', [ 'r', 'g', 'b' ] );

// File:inputs/CubeTextureNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.CubeTextureNode = function( value, coord, bias ) {

	THREE.InputNode.call( this, 'v4' );

	this.value = value;
	this.coord = coord || new THREE.ReflectNode();
	this.bias = bias;

};

THREE.CubeTextureNode.prototype = Object.create( THREE.InputNode.prototype );
THREE.CubeTextureNode.prototype.constructor = THREE.CubeTextureNode;

THREE.CubeTextureNode.prototype.getTexture = function( builder, output ) {

	return THREE.InputNode.prototype.generate.call( this, builder, output, this.value.uuid, 't' );

};

THREE.CubeTextureNode.prototype.generate = function( builder, output ) {

	var cubetex = this.getTexture( builder, output );
	var coord = this.coord.build( builder, 'v3' );
	var bias = this.bias ? this.bias.build( builder, 'fv1' ) : undefined;

	if ( bias == undefined && builder.requires.bias ) {

		bias = builder.requires.bias.build( builder, 'fv1' );

	}

	var code;

	if ( bias ) code = 'texCubeBias(' + cubetex + ',' + coord + ',' + bias + ')';
	else code = 'texCube(' + cubetex + ',' + coord + ')';

	return builder.format( code, this.type, output );

};

// File:inputs/FloatNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.FloatNode = function( value ) {

	THREE.InputNode.call( this, 'fv1', { share: false } );

	this.value = [ value || 0 ];

};

THREE.FloatNode.prototype = Object.create( THREE.InputNode.prototype );
THREE.FloatNode.prototype.constructor = THREE.FloatNode;

Object.defineProperties( THREE.FloatNode.prototype, {
	number: {
		get: function() {

			return this.value[ 0 ];

		},
		set: function( val ) {

			this.value[ 0 ] = val;

		}
	}
} );

// File:inputs/IntNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.IntNode = function( value ) {

	THREE.InputNode.call( this, 'fv1', { share: false } );

	this.value = [ Math.floor( value || 0 ) ];

};

THREE.IntNode.prototype = Object.create( THREE.InputNode.prototype );
THREE.IntNode.prototype.constructor = THREE.IntNode;

Object.defineProperties( THREE.IntNode.prototype, {
	number: {
		get: function() {

			return this.value[ 0 ];

		},
		set: function( val ) {

			this.value[ 0 ] = Math.floor( val );

		}
	}
} );

// File:inputs/Matrix4Node.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.Matrix4Node = function( matrix ) {

	THREE.InputNode.call( this, 'm4', { share: false } );

	this.value = matrix || new THREE.Matrix4();

};

THREE.Matrix4Node.prototype = Object.create( THREE.InputNode.prototype );
THREE.Matrix4Node.prototype.constructor = THREE.Matrix4Node;

// File:inputs/MirrorNode.js

THREE.MirrorNode = function( renderer, camera, options ) {
	
	THREE.TempNode.call( this, 'v4' );
	
	this.mirror = renderer instanceof THREE.Mirror ? renderer : new THREE.Mirror( renderer, camera, options );
	
	this.textureMatrix = new THREE.Matrix4Node( this.mirror.textureMatrix );

	this.worldPosition = new THREE.PositionNode( THREE.PositionNode.WORLD );
	
	this.coord = new THREE.OperatorNode( this.textureMatrix, this.worldPosition, THREE.OperatorNode.MUL );
	this.coordResult = new THREE.OperatorNode( null, this.coord, THREE.OperatorNode.ADD );
	
	this.texture = new THREE.TextureNode( this.mirror.texture, this.coord, null, true );
	
};

THREE.MirrorNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.MirrorNode.prototype.constructor = THREE.MirrorNode;

THREE.MirrorNode.prototype.generate = function( builder, output ) {

	var material = builder.material;

	if ( builder.isShader( 'fragment' ) ) {
		
		this.coordResult.a = this.offset;
		this.texture.coord = this.offset ? this.coordResult : this.coord;
		
		var coord = this.texture.build( builder, this.type );
		
		//console.log( coord );
		
		//var mirrorCoords = data.textureMatrix.name + '*' + worldPos;
		
		//this.addVertexPars( 'varying vec4 vColor; attribute vec4 color;' );
		
		//console.log( mirrorCoords, data.textureMatrix.name, worldPos );
		
		return builder.format( coord, this.type, output );

	}
	else {

		console.warn( "THREE.MirrorNode is not compatible with " + builder.shader + " shader." );

		return builder.format( 'vec4(0.0)', this.type, output );

	}

};
// File:inputs/TextureNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.TextureNode = function( value, coord, bias, project ) {

	THREE.InputNode.call( this, 'v4' );

	this.value = value;
	this.coord = coord || new THREE.UVNode();
	this.bias = bias;
	this.project = project !== undefined ? project : false;

};

THREE.TextureNode.prototype = Object.create( THREE.InputNode.prototype );
THREE.TextureNode.prototype.constructor = THREE.TextureNode;

THREE.TextureNode.prototype.getTexture = function( builder, output ) {

	return THREE.InputNode.prototype.generate.call( this, builder, output, this.value.uuid, 't' );

};

THREE.TextureNode.prototype.generate = function( builder, output ) {

	var tex = this.getTexture( builder, output );
	var coord = this.coord.build( builder, this.project ? 'v4' : 'v2' );
	var bias = this.bias ? this.bias.build( builder, 'fv1' ) : undefined;

	if ( bias == undefined && builder.requires.bias ) {

		bias = builder.requires.bias.build( builder, 'fv1' );

	}

	var method, code;
	
	if ( this.project ) method = 'texture2DProj';
	else method = bias ? 'tex2DBias' : 'tex2D';

	if ( bias ) code = method + '(' + tex + ',' + coord + ',' + bias + ')';
	else code = method + '(' + tex + ',' + coord + ')';

	return builder.format( code, this.type, output );

};

// File:inputs/ScreenNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.ScreenNode = function( coord ) {

	THREE.TextureNode.call( this, undefined, coord );

};

THREE.ScreenNode.prototype = Object.create( THREE.TextureNode.prototype );
THREE.ScreenNode.prototype.constructor = THREE.ScreenNode;

THREE.ScreenNode.prototype.isUnique = function() {

	return true;

};

THREE.ScreenNode.prototype.getTexture = function( builder, output ) {

	return THREE.InputNode.prototype.generate.call( this, builder, output, this.getUuid(), 't', 'renderTexture' );

};

// File:inputs/Vector2Node.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.Vector2Node = function( x, y ) {

	THREE.InputNode.call( this, 'v2', { share: false } );

	this.value = new THREE.Vector2( x, y );

};

THREE.Vector2Node.prototype = Object.create( THREE.InputNode.prototype );
THREE.Vector2Node.prototype.constructor = THREE.Vector2Node;

THREE.NodeMaterial.addShortcuts( THREE.Vector2Node.prototype, 'value', [ 'x', 'y' ] );

// File:inputs/Vector3Node.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.Vector3Node = function( x, y, z ) {

	THREE.InputNode.call( this, 'v3', { share: false } );

	this.type = 'v3';
	this.value = new THREE.Vector3( x, y, z );

};

THREE.Vector3Node.prototype = Object.create( THREE.InputNode.prototype );
THREE.Vector3Node.prototype.constructor = THREE.Vector3Node;

THREE.NodeMaterial.addShortcuts( THREE.Vector3Node.prototype, 'value', [ 'x', 'y', 'z' ] );

// File:inputs/Vector4Node.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.Vector4Node = function( x, y, z, w ) {

	THREE.InputNode.call( this, 'v4', { share: false } );

	this.value = new THREE.Vector4( x, y, z, w );

};

THREE.Vector4Node.prototype = Object.create( THREE.InputNode.prototype );
THREE.Vector4Node.prototype.constructor = THREE.Vector4Node;

THREE.NodeMaterial.addShortcuts( THREE.Vector4Node.prototype, 'value', [ 'x', 'y', 'z', 'w' ] );

// File:materials/PhongNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.PhongNode = function() {

	THREE.GLNode.call( this );

	this.color = new THREE.ColorNode( 0xEEEEEE );
	this.specular = new THREE.ColorNode( 0x111111 );
	this.shininess = new THREE.FloatNode( 30 );

};

THREE.PhongNode.prototype = Object.create( THREE.GLNode.prototype );
THREE.PhongNode.prototype.constructor = THREE.PhongNode;

THREE.PhongNode.prototype.build = function( builder ) {

	var material = builder.material;
	var code;

	material.define( 'PHONG' );
	material.define( 'ALPHATEST', '0.0' );

	material.requestAttrib.light = true;

	if ( builder.isShader( 'vertex' ) ) {

		var transform = this.transform ? this.transform.verifyAndBuildCode( builder, 'v3', 'transform' ) : undefined;

		material.mergeUniform( THREE.UniformsUtils.merge( [

			THREE.UniformsLib[ "fog" ],
			THREE.UniformsLib[ "ambient" ],
			THREE.UniformsLib[ "lights" ]

		] ) );

		material.addVertexPars( [
			"varying vec3 vViewPosition;",

			"#ifndef FLAT_SHADED",

			"	varying vec3 vNormal;",

			"#endif",

			THREE.ShaderChunk[ "common" ],
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

			"	vNormal = normalize( transformedNormal );",

			"#endif",

				THREE.ShaderChunk[ "begin_vertex" ]
		];

		if ( transform ) {

			output.push(
				transform.code,
				"transformed = " + transform.result + ";"
			);

		}

		output.push(
				THREE.ShaderChunk[ "morphtarget_vertex" ],
				THREE.ShaderChunk[ "skinning_vertex" ],
				THREE.ShaderChunk[ "project_vertex" ],
				THREE.ShaderChunk[ "logdepthbuf_vertex" ],

			"	vViewPosition = - mvPosition.xyz;",

				THREE.ShaderChunk[ "worldpos_vertex" ],
				THREE.ShaderChunk[ "shadowmap_vertex" ]
		);

		code = output.join( "\n" );

	}
	else {

		// verify all nodes to reuse generate codes

		this.color.verify( builder );
		this.specular.verify( builder );
		this.shininess.verify( builder );

		if ( this.alpha ) this.alpha.verify( builder );

		if ( this.light ) this.light.verify( builder, 'light' );

		if ( this.ao ) this.ao.verify( builder );
		if ( this.ambient ) this.ambient.verify( builder );
		if ( this.shadow ) this.shadow.verify( builder );
		if ( this.emissive ) this.emissive.verify( builder );

		if ( this.normal ) this.normal.verify( builder );
		if ( this.normalScale && this.normal ) this.normalScale.verify( builder );

		if ( this.environment ) this.environment.verify( builder );
		if ( this.environmentAlpha && this.environment ) this.environmentAlpha.verify( builder );

		// build code

		var color = this.color.buildCode( builder, 'c' );
		var specular = this.specular.buildCode( builder, 'c' );
		var shininess = this.shininess.buildCode( builder, 'fv1' );

		var alpha = this.alpha ? this.alpha.buildCode( builder, 'fv1' ) : undefined;

		var light = this.light ? this.light.buildCode( builder, 'v3', 'light' ) : undefined;

		var ao = this.ao ? this.ao.buildCode( builder, 'fv1' ) : undefined;
		var ambient = this.ambient ? this.ambient.buildCode( builder, 'c' ) : undefined;
		var shadow = this.shadow ? this.shadow.buildCode( builder, 'c' ) : undefined;
		var emissive = this.emissive ? this.emissive.buildCode( builder, 'c' ) : undefined;

		var normal = this.normal ? this.normal.buildCode( builder, 'v3' ) : undefined;
		var normalScale = this.normalScale && this.normal ? this.normalScale.buildCode( builder, 'v2' ) : undefined;

		var environment = this.environment ? this.environment.buildCode( builder, 'c' ) : undefined;
		var environmentAlpha = this.environmentAlpha && this.environment ? this.environmentAlpha.buildCode( builder, 'fv1' ) : undefined;

		material.requestAttrib.transparent = alpha != undefined;

		material.addFragmentPars( [
			THREE.ShaderChunk[ "common" ],
			THREE.ShaderChunk[ "fog_pars_fragment" ],
			THREE.ShaderChunk[ "bsdfs" ],
			THREE.ShaderChunk[ "ambient_pars" ],
			THREE.ShaderChunk[ "lights_pars" ],
			THREE.ShaderChunk[ "lights_phong_pars_fragment" ],
			THREE.ShaderChunk[ "shadowmap_pars_fragment" ],
			THREE.ShaderChunk[ "logdepthbuf_pars_fragment" ]
		].join( "\n" ) );

		var output = [
				// prevent undeclared normal
				THREE.ShaderChunk[ "normal_fragment" ],

				// prevent undeclared material
			"	BlinnPhongMaterial material;",

				color.code,
			"	vec3 diffuseColor = " + color.result + ";",
			"	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );",

				THREE.ShaderChunk[ "logdepthbuf_fragment" ],

			specular.code,
			"	vec3 specular = " + specular.result + ";",

			shininess.code,
			"	float shininess = max(0.0001," + shininess.result + ");",

			"	float specularStrength = 1.0;" // Ignored in MaterialNode ( replace to specular )
		];

		if ( alpha ) {

			output.push(
				alpha.code,
				'if ( ' + alpha.result + ' <= ALPHATEST ) discard;'
			);

		}

		if ( normal ) {

			builder.include( 'perturbNormal2Arb' );

			output.push( normal.code );

			if ( normalScale ) output.push( normalScale.code );

			output.push(
				'normal = perturbNormal2Arb(-vViewPosition,normal,' +
				normal.result + ',' +
				new THREE.UVNode().build( builder, 'v2' ) + ',' +
				( normalScale ? normalScale.result : 'vec2( 1.0 )' ) + ');'
			);

		}

		// optimization for now

		output.push( 'material.diffuseColor = ' + ( light ? 'vec3( 1.0 )' : 'diffuseColor' ) + ';' );

		output.push(
			// accumulation
			'material.specularColor = specular;',
			'material.specularShininess = shininess;',
			'material.specularStrength = specularStrength;',

			THREE.ShaderChunk[ "lights_template" ]
		);

		if ( light ) {

			output.push(
				light.code,
				"reflectedLight.directDiffuse = " + light.result + ";"
			);

			// apply color

			output.push(
				"reflectedLight.directDiffuse *= diffuseColor;",
				"reflectedLight.indirectDiffuse *= diffuseColor;"
			);

		}

		if ( ao ) {

			output.push(
				ao.code,
				"reflectedLight.indirectDiffuse *= " + ao.result + ";"
			);

		}

		if ( ambient ) {

			output.push(
				ambient.code,
				"reflectedLight.indirectDiffuse += " + ambient.result + ";"
			);

		}

		if ( shadow ) {

			output.push(
				shadow.code,
				"reflectedLight.directDiffuse *= " + shadow.result + ";",
				"reflectedLight.directSpecular *= " + shadow.result + ";"
			);

		}

		if ( emissive ) {

			output.push(
				emissive.code,
				"reflectedLight.directDiffuse += " + emissive.result + ";"
			);

		}

		output.push( "vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + reflectedLight.directSpecular;" );

		if ( environment ) {

			output.push( environment.code );

			if ( environmentAlpha ) {

				output.push(
					environmentAlpha.code,
					"outgoingLight = mix(" + 'outgoingLight' + "," + environment.result + "," + environmentAlpha.result + ");"
				);

			}
			else {

				output.push( "outgoingLight = " + environment.result + ";" );

			}

		}

		output.push(
			THREE.ShaderChunk[ "linear_to_gamma_fragment" ],
			THREE.ShaderChunk[ "fog_fragment" ]
		);

		if ( alpha ) {

			output.push( "gl_FragColor = vec4( outgoingLight, " + alpha.result + " );" );

		}
		else {

			output.push( "gl_FragColor = vec4( outgoingLight, 1.0 );" );

		}

		code = output.join( "\n" );

	}

	return code;

};

// File:materials/PhongNodeMaterial.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.PhongNodeMaterial = function() {

	this.node = new THREE.PhongNode();

	THREE.NodeMaterial.call( this, this.node, this.node );

};

THREE.PhongNodeMaterial.prototype = Object.create( THREE.NodeMaterial.prototype );
THREE.PhongNodeMaterial.prototype.constructor = THREE.PhongNodeMaterial;

THREE.NodeMaterial.addShortcuts( THREE.PhongNodeMaterial.prototype, 'node',
[ 'color', 'alpha', 'specular', 'shininess', 'normal', 'normalScale', 'emissive', 'ambient', 'light', 'shadow', 'ao', 'environment', 'environmentAlpha', 'transform' ] );

// File:materials/StandardNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.StandardNode = function() {

	THREE.GLNode.call( this );

	this.color = new THREE.ColorNode( 0xEEEEEE );
	this.roughness = new THREE.FloatNode( 0.5 );
	this.metalness = new THREE.FloatNode( 0.5 );

};

THREE.StandardNode.prototype = Object.create( THREE.GLNode.prototype );
THREE.StandardNode.prototype.constructor = THREE.StandardNode;

THREE.StandardNode.prototype.build = function( builder ) {

	var material = builder.material;
	var code;

	material.define( 'PHYSICAL' );
	material.define( 'ALPHATEST', '0.0' );

	material.requestAttrib.light = true;

	if ( builder.isShader( 'vertex' ) ) {

		var transform = this.transform ? this.transform.verifyAndBuildCode( builder, 'v3', 'transform' ) : undefined;

		material.mergeUniform( THREE.UniformsUtils.merge( [

			THREE.UniformsLib[ "fog" ],
			THREE.UniformsLib[ "ambient" ],
			THREE.UniformsLib[ "lights" ]

		] ) );

		material.addVertexPars( [
			"varying vec3 vViewPosition;",

			"#ifndef FLAT_SHADED",

			"	varying vec3 vNormal;",

			"#endif",

			THREE.ShaderChunk[ "common" ],
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

			"	vNormal = normalize( transformedNormal );",

			"#endif",

				THREE.ShaderChunk[ "begin_vertex" ]
		];

		if ( transform ) {

			output.push(
				transform.code,
				"transformed = " + transform.result + ";"
			);

		}

		output.push(
				THREE.ShaderChunk[ "morphtarget_vertex" ],
				THREE.ShaderChunk[ "skinning_vertex" ],
				THREE.ShaderChunk[ "project_vertex" ],
				THREE.ShaderChunk[ "logdepthbuf_vertex" ],

			"	vViewPosition = - mvPosition.xyz;",

				THREE.ShaderChunk[ "worldpos_vertex" ],
				THREE.ShaderChunk[ "shadowmap_vertex" ]
		);

		code = output.join( "\n" );

	}
	else {

		// blur textures for PBR effect

		var requires = {
			bias : new THREE.RoughnessToBlinnExponentNode()
		};

		// verify all nodes to reuse generate codes

		this.color.verify( builder );
		this.roughness.verify( builder );
		this.metalness.verify( builder );

		if ( this.alpha ) this.alpha.verify( builder );

		if ( this.light ) this.light.verify( builder, 'light' );

		if ( this.ao ) this.ao.verify( builder );
		if ( this.ambient ) this.ambient.verify( builder );
		if ( this.shadow ) this.shadow.verify( builder );
		if ( this.emissive ) this.emissive.verify( builder );

		if ( this.normal ) this.normal.verify( builder );
		if ( this.normalScale && this.normal ) this.normalScale.verify( builder );

		if ( this.environment ) this.environment.verify( builder, 'env', requires ); // isolate environment from others inputs ( see TextureNode, CubeTextureNode )

		// build code

		var color = this.color.buildCode( builder, 'c' );
		var roughness = this.roughness.buildCode( builder, 'fv1' );
		var metalness = this.metalness.buildCode( builder, 'fv1' );
		
		var reflectivity = this.reflectivity ? this.reflectivity.buildCode( builder, 'fv1' ) : undefined;
		
		var alpha = this.alpha ? this.alpha.buildCode( builder, 'fv1' ) : undefined;

		var light = this.light ? this.light.buildCode( builder, 'v3', 'light' ) : undefined;

		var ao = this.ao ? this.ao.buildCode( builder, 'fv1' ) : undefined;
		var ambient = this.ambient ? this.ambient.buildCode( builder, 'c' ) : undefined;
		var shadow = this.shadow ? this.shadow.buildCode( builder, 'c' ) : undefined;
		var emissive = this.emissive ? this.emissive.buildCode( builder, 'c' ) : undefined;

		var normal = this.normal ? this.normal.buildCode( builder, 'v3' ) : undefined;
		var normalScale = this.normalScale && this.normal ? this.normalScale.buildCode( builder, 'v2' ) : undefined;

		var environment = this.environment ? this.environment.buildCode( builder, 'c', 'env', requires ) : undefined;

		material.requestAttrib.transparent = alpha != undefined;

		material.addFragmentPars( [

			"varying vec3 vViewPosition;",

			"#ifndef FLAT_SHADED",

			"	varying vec3 vNormal;",

			"#endif",

			THREE.ShaderChunk[ "common" ],
			THREE.ShaderChunk[ "fog_pars_fragment" ],
			THREE.ShaderChunk[ "bsdfs" ],
			THREE.ShaderChunk[ "lights_pars" ],
			THREE.ShaderChunk[ "lights_physical_pars_fragment" ],
			THREE.ShaderChunk[ "shadowmap_pars_fragment" ],
			THREE.ShaderChunk[ "logdepthbuf_pars_fragment" ],
		].join( "\n" ) );

		var output = [
				// prevent undeclared normal
				THREE.ShaderChunk[ "normal_fragment" ],

				// prevent undeclared material
			"	PhysicalMaterial material;",
			"	material.diffuseColor = vec3( 1.0 );",

				color.code,
			"	vec3 diffuseColor = " + color.result + ";",
			"	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );",

				THREE.ShaderChunk[ "logdepthbuf_fragment" ],

			roughness.code,
			"	float roughnessFactor = " + roughness.result + ";",

			metalness.code,
			"	float metalnessFactor = " + metalness.result + ";"
		];

		if ( alpha ) {

			output.push(
				alpha.code,
				'if ( ' + alpha.result + ' <= ALPHATEST ) discard;'
			);

		}

		if ( normal ) {

			builder.include( 'perturbNormal2Arb' );

			output.push( normal.code );

			if ( normalScale ) output.push( normalScale.code );

			output.push(
				'normal = perturbNormal2Arb(-vViewPosition,normal,' +
				normal.result + ',' +
				new THREE.UVNode().build( builder, 'v2' ) + ',' +
				( normalScale ? normalScale.result : 'vec2( 1.0 )' ) + ');'
			);

		}

		// optimization for now

		output.push( 'material.diffuseColor = ' + ( light ? 'vec3( 1.0 )' : 'diffuseColor * (1.0 - metalnessFactor)' ) + ';' );

		output.push(
			// accumulation
			'material.specularRoughness = clamp( roughnessFactor, 0.04, 1.0 );' // disney's remapping of [ 0, 1 ] roughness to [ 0.001, 1 ]
		);
		
		if (reflectivity) {
		
			output.push(
				'material.specularColor = mix( vec3( 0.16 * pow2( ' + reflectivity.builder( builder, 'fv1' ) + ' ) ), diffuseColor, metalnessFactor );'
			);
			
		}
		else {
			
			output.push(
				'material.specularColor = mix( vec3( 0.04 ), diffuseColor, metalnessFactor );'
			);
		
		}
		
		output.push(
			THREE.ShaderChunk[ "lights_template" ]
		);

		if ( light ) {

			output.push(
				light.code,
				"reflectedLight.directDiffuse = " + light.result + ";"
			);

			// apply color

			output.push(
				"diffuseColor *= 1.0 - metalnessFactor;",

				"reflectedLight.directDiffuse *= diffuseColor;",
				"reflectedLight.indirectDiffuse *= diffuseColor;"
			);

		}

		if ( ao ) {

			output.push(
				ao.code,
				"reflectedLight.indirectDiffuse *= " + ao.result + ";"
			);

		}

		if ( ambient ) {

			output.push(
				ambient.code,
				"reflectedLight.indirectDiffuse += " + ambient.result + ";"
			);

		}

		if ( shadow ) {

			output.push(
				shadow.code,
				"reflectedLight.directDiffuse *= " + shadow.result + ";",
				"reflectedLight.directSpecular *= " + shadow.result + ";"
			);

		}

		if ( emissive ) {

			output.push(
				emissive.code,
				"reflectedLight.directDiffuse += " + emissive.result + ";"
			);

		}

		if ( environment ) {

			output.push(
				environment.code,
				"RE_IndirectSpecular(" + environment.result + ", geometry, material, reflectedLight );"
			);

		}

		output.push( "vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + reflectedLight.directSpecular + reflectedLight.indirectSpecular;" );

		output.push(
			THREE.ShaderChunk[ "linear_to_gamma_fragment" ],
			THREE.ShaderChunk[ "fog_fragment" ]
		);

		if ( alpha ) {

			output.push( "gl_FragColor = vec4( outgoingLight, " + alpha.result + " );" );

		}
		else {

			output.push( "gl_FragColor = vec4( outgoingLight, 1.0 );" );

		}

		code = output.join( "\n" );

	}

	return code;

};

// File:materials/StandardNodeMaterial.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.StandardNodeMaterial = function() {

	this.node = new THREE.StandardNode();

	THREE.NodeMaterial.call( this, this.node, this.node );

};

THREE.StandardNodeMaterial.prototype = Object.create( THREE.NodeMaterial.prototype );
THREE.StandardNodeMaterial.prototype.constructor = THREE.StandardNodeMaterial;

THREE.NodeMaterial.addShortcuts( THREE.StandardNodeMaterial.prototype, 'node',
[ 'color', 'alpha', 'roughness', 'metalness', 'normal', 'normalScale', 'emissive', 'ambient', 'light', 'shadow', 'ao', 'environment', 'transform' ] );

// File:math/Math1Node.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.Math1Node = function( a, method ) {

	THREE.TempNode.call( this );

	this.a = a;

	this.method = method || THREE.Math1Node.SIN;

};

THREE.Math1Node.RAD = 'radians';
THREE.Math1Node.DEG = 'degrees';
THREE.Math1Node.EXP = 'exp';
THREE.Math1Node.EXP2 = 'exp2';
THREE.Math1Node.LOG = 'log';
THREE.Math1Node.LOG2 = 'log2';
THREE.Math1Node.SQRT = 'sqrt';
THREE.Math1Node.INV_SQRT = 'inversesqrt';
THREE.Math1Node.FLOOR = 'floor';
THREE.Math1Node.CEIL = 'ceil';
THREE.Math1Node.NORMALIZE = 'normalize';
THREE.Math1Node.FRACT = 'fract';
THREE.Math1Node.SAT = 'saturate';
THREE.Math1Node.SIN = 'sin';
THREE.Math1Node.COS = 'cos';
THREE.Math1Node.TAN = 'tan';
THREE.Math1Node.ASIN = 'asin';
THREE.Math1Node.ACOS = 'acos';
THREE.Math1Node.ARCTAN = 'atan';
THREE.Math1Node.ABS = 'abs';
THREE.Math1Node.SIGN = 'sign';
THREE.Math1Node.LENGTH = 'length';
THREE.Math1Node.NEGATE = 'negate';
THREE.Math1Node.INVERT = 'invert';

THREE.Math1Node.prototype = Object.create( THREE.TempNode.prototype );
THREE.Math1Node.prototype.constructor = THREE.Math1Node;

THREE.Math1Node.prototype.getType = function( builder ) {

	switch ( this.method ) {
		case THREE.Math1Node.LENGTH:
			return 'fv1';
	}

	return this.a.getType( builder );

};

THREE.Math1Node.prototype.generate = function( builder, output ) {

	var material = builder.material;

	var type = this.getType( builder );

	var result = this.a.build( builder, type );

	switch ( this.method ) {

		case THREE.Math1Node.NEGATE:
			result = '(-' + result + ')';
			break;

		case THREE.Math1Node.INVERT:
			result = '(1.0-' + result + ')';
			break;

		default:
			result = this.method + '(' + result + ')';
			break;
	}

	return builder.format( result, type, output );

};

// File:math/Math2Node.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.Math2Node = function( a, b, method ) {

	THREE.TempNode.call( this );

	this.a = a;
	this.b = b;

	this.method = method || THREE.Math2Node.DISTANCE;

};

THREE.Math2Node.MIN = 'min';
THREE.Math2Node.MAX = 'max';
THREE.Math2Node.MOD = 'mod';
THREE.Math2Node.STEP = 'step';
THREE.Math2Node.REFLECT = 'reflect';
THREE.Math2Node.DISTANCE = 'distance';
THREE.Math2Node.DOT = 'dot';
THREE.Math2Node.CROSS = 'cross';
THREE.Math2Node.POW = 'pow';

THREE.Math2Node.prototype = Object.create( THREE.TempNode.prototype );
THREE.Math2Node.prototype.constructor = THREE.Math2Node;

THREE.Math2Node.prototype.getInputType = function( builder ) {

	// use the greater length vector
	if ( builder.getFormatLength( this.b.getType( builder ) ) > builder.getFormatLength( this.a.getType( builder ) ) ) {

		return this.b.getType( builder );

	}

	return this.a.getType( builder );

};

THREE.Math2Node.prototype.getType = function( builder ) {

	switch ( this.method ) {
		case THREE.Math2Node.DISTANCE:
		case THREE.Math2Node.DOT:
			return 'fv1';

		case THREE.Math2Node.CROSS:
			return 'v3';
	}

	return this.getInputType( builder );

};

THREE.Math2Node.prototype.generate = function( builder, output ) {

	var material = builder.material;

	var type = this.getInputType( builder );

	var a, b,
		al = builder.getFormatLength( this.a.getType( builder ) ),
		bl = builder.getFormatLength( this.b.getType( builder ) );

	// optimzer

	switch ( this.method ) {
		case THREE.Math2Node.CROSS:
			a = this.a.build( builder, 'v3' );
			b = this.b.build( builder, 'v3' );
			break;

		case THREE.Math2Node.STEP:
			a = this.a.build( builder, al == 1 ? 'fv1' : type );
			b = this.b.build( builder, type );
			break;

		case THREE.Math2Node.MIN:
		case THREE.Math2Node.MAX:
		case THREE.Math2Node.MOD:
			a = this.a.build( builder, type );
			b = this.b.build( builder, bl == 1 ? 'fv1' : type );
			break;

		default:
			a = this.a.build( builder, type );
			b = this.b.build( builder, type );
			break;

	}

	return builder.format( this.method + '(' + a + ',' + b + ')', this.getType( builder ), output );

};

// File:math/Math3Node.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.Math3Node = function( a, b, c, method ) {

	THREE.TempNode.call( this );

	this.a = a;
	this.b = b;
	this.c = c;

	this.method = method || THREE.Math3Node.MIX;

};

THREE.Math3Node.MIX = 'mix';
THREE.Math3Node.REFRACT = 'refract';
THREE.Math3Node.SMOOTHSTEP = 'smoothstep';
THREE.Math3Node.FACEFORWARD = 'faceforward';

THREE.Math3Node.prototype = Object.create( THREE.TempNode.prototype );
THREE.Math3Node.prototype.constructor = THREE.Math3Node;

THREE.Math3Node.prototype.getType = function( builder ) {

	var a = builder.getFormatLength( this.a.getType( builder ) );
	var b = builder.getFormatLength( this.b.getType( builder ) );
	var c = builder.getFormatLength( this.c.getType( builder ) );

	if ( a > b ) {

		if ( a > c ) return this.a.getType( builder );
		return this.c.getType( builder );

	}
	else {

		if ( b > c ) return this.b.getType( builder );

		return this.c.getType( builder );

	}

};

THREE.Math3Node.prototype.generate = function( builder, output ) {

	var material = builder.material;

	var type = this.getType( builder );

	var a, b, c,
		al = builder.getFormatLength( this.a.getType( builder ) ),
		bl = builder.getFormatLength( this.b.getType( builder ) ),
		cl = builder.getFormatLength( this.c.getType( builder ) )

	// optimzer

	switch ( this.method ) {
		case THREE.Math3Node.REFRACT:
			a = this.a.build( builder, type );
			b = this.b.build( builder, type );
			c = this.c.build( builder, 'fv1' );
			break;

		case THREE.Math3Node.MIX:
			a = this.a.build( builder, type );
			b = this.b.build( builder, type );
			c = this.c.build( builder, cl == 1 ? 'fv1' : type );
			break;

		default:
			a = this.a.build( builder, type );
			b = this.b.build( builder, type );
			c = this.c.build( builder, type );
			break;

	}

	return builder.format( this.method + '(' + a + ',' + b + ',' + c + ')', type, output );

};

// File:math/OperatorNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.OperatorNode = function( a, b, op ) {

	THREE.TempNode.call( this );

	this.a = a;
	this.b = b;
	this.op = op || THREE.OperatorNode.ADD;

};

THREE.OperatorNode.ADD = '+';
THREE.OperatorNode.SUB = '-';
THREE.OperatorNode.MUL = '*';
THREE.OperatorNode.DIV = '/';

THREE.OperatorNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.OperatorNode.prototype.constructor = THREE.OperatorNode;

THREE.OperatorNode.prototype.getType = function( builder ) {

	var a = this.a.getType( builder );
	var b = this.b.getType( builder );
	
	if ( builder.isFormatMatrix( a ) ) {
	
		return 'v4';
		
	}
	// use the greater length vector
	else if ( builder.getFormatLength( b ) > builder.getFormatLength( a ) ) {

		return b;

	}

	return a;

};

THREE.OperatorNode.prototype.generate = function( builder, output ) {

	var material = builder.material, 
		data = material.getDataNode( this.uuid );

	var type = this.getType( builder );
	
	var a = this.a.build( builder, type );
	var b = this.b.build( builder, type );

	return builder.format( '(' + a + this.op + b + ')', type, output );

};

// File:NodeLib.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeLib = {
	nodes: {},
	add: function( node ) {

		this.nodes[ node.name ] = node;

	},
	remove: function( node ) {

		delete this.nodes[ node.name ];

	},
	get: function( name ) {

		return this.nodes[ name ];

	},
	contains: function( name ) {

		return this.nodes[ name ] != undefined;

	}
};

//
//	Luma
//

THREE.NodeLib.add( new THREE.ConstNode( "vec3 LUMA = vec3(0.2125, 0.7154, 0.0721);" ) );

//
//	DepthColor
//

THREE.NodeLib.add( new THREE.FunctionNode( [
"float depthcolor( float mNear, float mFar ) {",

	"#ifdef USE_LOGDEPTHBUF_EXT",
		"float depth = gl_FragDepthEXT / gl_FragCoord.w;",
	"#else",
		"float depth = gl_FragCoord.z / gl_FragCoord.w;",
	"#endif",

	"return 1.0 - smoothstep( mNear, mFar, depth );",
"}"
].join( "\n" ) ) );

//
//	NormalMap
//

THREE.NodeLib.add( new THREE.FunctionNode( [
// Per-Pixel Tangent Space Normal Mapping
// http://hacksoflife.blogspot.ch/2009/11/per-pixel-tangent-space-normal-mapping.html
"vec3 perturbNormal2Arb( vec3 eye_pos, vec3 surf_norm, vec3 map, vec2 mUv, vec2 scale ) {",
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
].join( "\n" ), null, { derivatives: true } ) );

//
//	Noise
//

THREE.NodeLib.add( new THREE.FunctionNode( [
"float snoise(vec2 co) {",
	"return fract( sin( dot(co.xy, vec2(12.9898,78.233) ) ) * 43758.5453 );",
"}"
].join( "\n" ) ) );

//
//	Hue
//

THREE.NodeLib.add( new THREE.FunctionNode( [
"vec3 hue_rgb(vec3 rgb, float adjustment) {",
	"const mat3 RGBtoYIQ = mat3(0.299, 0.587, 0.114, 0.595716, -0.274453, -0.321263, 0.211456, -0.522591, 0.311135);",
	"const mat3 YIQtoRGB = mat3(1.0, 0.9563, 0.6210, 1.0, -0.2721, -0.6474, 1.0, -1.107, 1.7046);",
	"vec3 yiq = RGBtoYIQ * rgb;",
	"float hue = atan(yiq.z, yiq.y) + adjustment;",
	"float chroma = sqrt(yiq.z * yiq.z + yiq.y * yiq.y);",
	"return YIQtoRGB * vec3(yiq.x, chroma * cos(hue), chroma * sin(hue));",
"}"
].join( "\n" ) ) );

//
//	Saturation
//

THREE.NodeLib.add( new THREE.FunctionNode( [
// Algorithm from Chapter 16 of OpenGL Shading Language
"vec3 saturation_rgb(vec3 rgb, float adjustment) {",
	"vec3 intensity = vec3(dot(rgb, LUMA));",
	"return mix(intensity, rgb, adjustment);",
"}"
].join( "\n" ) ) );

//
//	Luminance
//

THREE.NodeLib.add( new THREE.FunctionNode( [
// Algorithm from Chapter 10 of Graphics Shaders
"float luminance_rgb(vec3 rgb) {",
	"return dot(rgb, LUMA);",
"}"
].join( "\n" ) ) );

//
//	Vibrance
//

THREE.NodeLib.add( new THREE.FunctionNode( [
// Shader by Evan Wallace adapted by @lo-th
"vec3 vibrance_rgb(vec3 rgb, float adjustment) {",
	"float average = (rgb.r + rgb.g + rgb.b) / 3.0;",
	"float mx = max(rgb.r, max(rgb.g, rgb.b));",
	"float amt = (mx - average) * (-3.0 * adjustment);",
	"return mix(rgb.rgb, vec3(mx), amt);",
"}"
].join( "\n" ) ) );

// File:postprocessing/NodePass.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

 if (THREE.ShaderPass) {
 
	THREE.NodePass = function() {

		THREE.ShaderPass.call( this );

		this.textureID = 'renderTexture';

		this.fragment = new THREE.RawNode( new THREE.ScreenNode() );

		this.node = new THREE.NodeMaterial();
		this.node.fragment = this.fragment;

		this.build();

	};

	THREE.NodePass.prototype = Object.create( THREE.ShaderPass.prototype );
	THREE.NodePass.prototype.constructor = THREE.NodePass;

	THREE.NodeMaterial.addShortcuts( THREE.NodePass.prototype, 'fragment', [ 'value' ] );

	THREE.NodePass.prototype.build = function() {

		this.node.build();

		this.uniforms = this.node.uniforms;
		this.material = this.node;

	};

}
	
// File:RawNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.RawNode = function( value ) {

	THREE.GLNode.call( this, 'v4' );

	this.value = value;

};

THREE.RawNode.prototype = Object.create( THREE.GLNode.prototype );
THREE.RawNode.prototype.constructor = THREE.RawNode;

THREE.GLNode.prototype.generate = function( builder ) {

	var material = builder.material;

	var data = this.value.verifyAndBuildCode( builder, this.type );

	var code = data.code + '\n';

	if ( builder.shader == 'vertex' ) {

		code += 'gl_Position = ' + data.result + ';';

	}
	else {

		code += 'gl_FragColor = ' + data.result + ';';

	}

	return code;

};

// File:utils/ColorAdjustmentNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.ColorAdjustmentNode = function( rgb, adjustment, method ) {

	THREE.TempNode.call( this, 'v3' );

	this.rgb = rgb;
	this.adjustment = adjustment;

	this.method = method || THREE.ColorAdjustmentNode.SATURATION;

};

THREE.ColorAdjustmentNode.SATURATION = 'saturation';
THREE.ColorAdjustmentNode.HUE = 'hue';
THREE.ColorAdjustmentNode.VIBRANCE = 'vibrance';
THREE.ColorAdjustmentNode.BRIGHTNESS = 'brightness';
THREE.ColorAdjustmentNode.CONTRAST = 'contrast';

THREE.ColorAdjustmentNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.ColorAdjustmentNode.prototype.constructor = THREE.ColorAdjustmentNode;

THREE.ColorAdjustmentNode.prototype.generate = function( builder, output ) {

	var rgb = this.rgb.build( builder, 'v3' );
	var adjustment = this.adjustment.build( builder, 'fv1' );

	var name;

	switch ( this.method ) {

		case THREE.ColorAdjustmentNode.SATURATION:

			name = 'saturation_rgb';

			break;

		case THREE.ColorAdjustmentNode.HUE:

			name = 'hue_rgb';

			break;

		case THREE.ColorAdjustmentNode.VIBRANCE:

			name = 'vibrance_rgb';

			break;

		case THREE.ColorAdjustmentNode.BRIGHTNESS:

			return builder.format( '(' + rgb + '+' + adjustment + ')', this.getType( builder ), output );

			break;

		case THREE.ColorAdjustmentNode.CONTRAST:

			return builder.format( '(' + rgb + '*' + adjustment + ')', this.getType( builder ), output );

			break;

	}

	builder.include( name );

	return builder.format( name + '(' + rgb + ',' + adjustment + ')', this.getType( builder ), output );

};

// File:utils/JoinNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.JoinNode = function( x, y, z, w ) {

	THREE.TempNode.call( this, 'fv1' );

	this.x = x;
	this.y = y;
	this.z = z;
	this.w = w;

};

THREE.JoinNode.inputs = [ 'x', 'y', 'z', 'w' ];

THREE.JoinNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.JoinNode.prototype.constructor = THREE.JoinNode;

THREE.JoinNode.prototype.getNumElements = function() {

	var inputs = THREE.JoinNode.inputs;
	var i = inputs.length;

	while ( i -- ) {

		if ( this[ inputs[ i ] ] !== undefined ) {

			++ i;
			break;

		}

	}

	return Math.max( i, 2 );

};

THREE.JoinNode.prototype.getType = function( builder ) {

	return builder.getFormatByLength( this.getNumElements() );

};

THREE.JoinNode.prototype.generate = function( builder, output ) {

	var material = builder.material;

	var type = this.getType( builder );
	var length = this.getNumElements();

	var inputs = THREE.JoinNode.inputs;
	var outputs = [];

	for ( var i = 0; i < length; i ++ ) {

		var elm = this[ inputs[ i ]];

		outputs.push( elm ? elm.build( builder, 'fv1' ) : '0.' );

	}

	var code = builder.getFormatConstructor( length ) + '(' + outputs.join( ',' ) + ')';

	return builder.format( code, type, output );

};

// File:utils/LuminanceNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.LuminanceNode = function( rgb ) {

	THREE.TempNode.call( this, 'fv1' );

	this.rgb = rgb;

};

THREE.LuminanceNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.LuminanceNode.prototype.constructor = THREE.LuminanceNode;

THREE.LuminanceNode.prototype.generate = function( builder, output ) {

	builder.include( 'luminance_rgb' );

	return builder.format( 'luminance_rgb(' + this.rgb.build( builder, 'v3' ) + ')', this.getType( builder ), output );

};

// File:utils/NoiseNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NoiseNode = function( coord ) {

	THREE.TempNode.call( this, 'fv1' );

	this.coord = coord;

};

THREE.NoiseNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.NoiseNode.prototype.constructor = THREE.NoiseNode;

THREE.NoiseNode.prototype.generate = function( builder, output ) {

	builder.include( 'snoise' );

	return builder.format( 'snoise(' + this.coord.build( builder, 'v2' ) + ')', this.getType( builder ), output );

};

// File:utils/NormalMapNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NormalMapNode = function( value, uv, scale, normal, position ) {

	THREE.TempNode.call( this, 'v3' );

	this.value = value;
	this.scale = scale || new THREE.FloatNode( 1 );

	this.normal = normal || new THREE.NormalNode( THREE.NormalNode.LOCAL );
	this.position = position || new THREE.PositionNode( THREE.NormalNode.VIEW );

};

THREE.NormalMapNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.NormalMapNode.prototype.constructor = THREE.NormalMapNode;

THREE.NormalMapNode.prototype.generate = function( builder, output ) {

	var material = builder.material;

	builder.include( 'perturbNormal2Arb' );

	if ( builder.isShader( 'fragment' ) ) {

		return builder.format( 'perturbNormal2Arb(-' + this.position.build( builder, 'v3' ) + ',' +
			this.normal.build( builder, 'v3' ) + ',' +
			this.value.build( builder, 'v3' ) + ',' +
			this.value.coord.build( builder, 'v2' ) + ',' +
			this.scale.build( builder, 'v2' ) + ')', this.getType( builder ), output );

	}
	else {

		console.warn( "THREE.NormalMapNode is not compatible with " + builder.shader + " shader." );

		return builder.format( 'vec3( 0.0 )', this.getType( builder ), output );

	}

};

// File:utils/ResolutionNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.ResolutionNode = function( renderer ) {

	THREE.Vector2Node.call( this );

	this.requestUpdate = true;

	this.renderer = renderer;

};

THREE.ResolutionNode.prototype = Object.create( THREE.Vector2Node.prototype );
THREE.ResolutionNode.prototype.constructor = THREE.ResolutionNode;

THREE.ResolutionNode.prototype.updateAnimation = function( delta ) {

	var size = this.renderer.getSize();

	this.x = size.width;
	this.y = size.height;

};

// File:utils/RoughnessToBlinnExponentNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.RoughnessToBlinnExponentNode = function() {

	THREE.TempNode.call( this, 'fv1' );

};

THREE.RoughnessToBlinnExponentNode.getSpecularMIPLevel = new THREE.FunctionNode( [
// taken from here: http://casual-effects.blogspot.ca/2011/08/plausible-environment-lighting-in-two.html
"float getSpecularMIPLevel( const in float blinnShininessExponent, const in int maxMIPLevel ) {",

	//float envMapWidth = pow( 2.0, maxMIPLevelScalar );
	//float desiredMIPLevel = log2( envMapWidth * sqrt( 3.0 ) ) - 0.5 * log2( pow2( blinnShininessExponent ) + 1.0 );
	"float maxMIPLevelScalar = float( maxMIPLevel );",
	"float desiredMIPLevel = maxMIPLevelScalar - 0.79248 - 0.5 * log2( pow2( blinnShininessExponent ) + 1.0 );",
	
	// clamp to allowable LOD ranges.
	"return clamp( desiredMIPLevel, 0.0, maxMIPLevelScalar );",
"}"
].join( "\n" ) );

THREE.RoughnessToBlinnExponentNode.prototype = Object.create( THREE.TempNode.prototype );
THREE.RoughnessToBlinnExponentNode.prototype.constructor = THREE.RoughnessToBlinnExponentNode;

THREE.RoughnessToBlinnExponentNode.prototype.generate = function( builder, output ) {

	var material = builder.material;

	if ( builder.isShader( 'fragment' ) ) {

		if ( material.isDefined( 'PHYSICAL' ) ) {

			builder.include( THREE.RoughnessToBlinnExponentNode.getSpecularMIPLevel );
			
			return builder.format( 'getSpecularMIPLevel( Material_BlinnShininessExponent( material ), 8 )', this.type, output );

		}
		else {

			console.warn( "THREE.RoughnessToBlinnExponentNode is only compatible with PhysicalMaterial." );
			
			return builder.format( '0.0', this.type, output );
			
		}

	}
	else {

		console.warn( "THREE.RoughnessToBlinnExponentNode is not compatible with " + builder.shader + " shader." );

		return builder.format( '0.0', this.type, output );

	}

};

// File:utils/SwitchNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.SwitchNode = function( node, components ) {

	THREE.GLNode.call( this );

	this.node = node;
	this.components = components || 'x';

};

THREE.SwitchNode.prototype = Object.create( THREE.GLNode.prototype );
THREE.SwitchNode.prototype.constructor = THREE.SwitchNode;

THREE.SwitchNode.prototype.getType = function( builder ) {

	return builder.getFormatByLength( this.components.length );

};

THREE.SwitchNode.prototype.generate = function( builder, output ) {

	var type = this.node.getType( builder );
	var inputLength = builder.getFormatLength( type ) - 1;

	var node = this.node.build( builder, type );

	if ( inputLength > 0 ) {

		// get max length

		var outputLength = 0;
		var components = builder.colorToVector( this.components );

		var i, len = components.length;

		for ( i = 0; i < len; i ++ ) {

			outputLength = Math.max( outputLength, builder.getIndexByElement( components.charAt( i ) ) );

		}

		if ( outputLength > inputLength ) outputLength = inputLength;

		// split

		node += '.';

		for ( i = 0; i < len; i ++ ) {

			var elm = components.charAt( i );
			var idx = builder.getIndexByElement( components.charAt( i ) );

			if ( idx > outputLength ) idx = outputLength;

			node += builder.getElementByIndex( idx );

		}

		return builder.format( node, this.getType( builder ), output );

	} else {

		// join

		return builder.format( node, type, output )

	}

};

// File:utils/TimerNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.TimerNode = function( value, scale ) {

	THREE.FloatNode.call( this, value );

	this.requestUpdate = true;

	this.scale = scale !== undefined ? scale : 1;

};

THREE.TimerNode.prototype = Object.create( THREE.FloatNode.prototype );
THREE.TimerNode.prototype.constructor = THREE.TimerNode;

THREE.TimerNode.prototype.updateAnimation = function( delta ) {

	this.number += delta * this.scale;

};

// File:utils/VelocityNode.js

/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.VelocityNode = function( target, params ) {

	THREE.Vector3Node.call( this );

	this.requestUpdate = true;

	this.target = target;

	this.position = this.target.position.clone();
	this.velocity = new THREE.Vector3();
	this.moment = new THREE.Vector3();

	this.params = params || {};

};

THREE.VelocityNode.prototype = Object.create( THREE.Vector3Node.prototype );
THREE.VelocityNode.prototype.constructor = THREE.VelocityNode;

THREE.VelocityNode.prototype.updateAnimation = function( delta ) {

	this.velocity.subVectors( this.target.position, this.position );
	this.position.copy( this.target.position );

	switch ( this.params.type ) {

		case "elastic":

			delta *= this.params.fps || 60;

			var spring = Math.pow( this.params.spring, delta );
			var friction = Math.pow( this.params.friction, delta );

			// spring
			this.moment.x += this.velocity.x * spring;
			this.moment.y += this.velocity.y * spring;
			this.moment.z += this.velocity.z * spring;

			// friction
			this.moment.x *= friction;
			this.moment.y *= friction;
			this.moment.z *= friction;

			this.value.copy( this.moment );

			break;

		default:

			this.value.copy( this.velocity );

			break;
	}

};
