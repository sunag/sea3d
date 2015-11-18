/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodePhong = function() {
	
	THREE.NodeGL.call( this, 'phong' );
	
	this.color = new THREE.NodeColor( 0xEEEEEE );
	this.specular = new THREE.NodeColor( 0x111111 );
	this.shininess = new THREE.NodeFloat( 30 );
	
};

THREE.NodePhong.prototype = Object.create( THREE.NodeGL.prototype );
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