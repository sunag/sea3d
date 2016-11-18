/**
 * 	SEA3D Node Material for Three.JS
 * 	@author Sunag / http://www.sunag.com.br/
 */

'use strict';

//
//	Material Builder
//

THREE.SEA3D.MaterialBuilder = {

	apply : function( scope ) {

		Object.defineProperties( this, {
			enabledRim: {
				enumerable: true,
				get: function() {

					return this.rimColor != null;

				},
				set: function( value ) {

					if ( this.enabledRim == !! value ) return;

					if ( value ) {

						this.rimColor = new THREE.ColorNode( 0xFF );
						this.rimPower = new THREE.FloatNode( 3 );
						this.rimIntensityValue = 1.3;

						this.rimViewZ = new THREE.Math2Node(
							new THREE.NormalNode( THREE.NormalNode.VIEW ),
							new THREE.Vector3Node( 0, 0, - this.rimIntensityValue ),
							THREE.Math2Node.DOT
						);

						this.rimMath = new THREE.OperatorNode(
							this.rimViewZ,
							new THREE.FloatNode( this.rimIntensityValue ),
							THREE.OperatorNode.ADD
						);

						this.rimPowerMath = new THREE.Math2Node(
							this.rimMath,
							this.rimPower,
							THREE.Math2Node.POW
						);

						this.rim = new THREE.OperatorNode(
							this.rimPowerMath,
							this.rimColor,
							THREE.OperatorNode.MUL
						);

					} else {

						delete this.rimColor;
						delete this.rimPower;
						delete this.rimIntensityValue;
						delete this.rimViewZ;
						delete this.rimMath;
						delete this.rimPowerMath;
						delete this.rim;

					}

				}
			},
			enabledWrapLighting: {
				enumerable: true,
				get: function() {

					return this.wrapColor != null;

				},
				set: function( val ) {

					if ( this.enabledWrapLighting == !! val ) return;

					if (val) {
						
						this.wrapColor = new THREE.ColorNode( 0x6b0602 );
						this.wrapLight = new THREE.FloatNode( 1.5 );
						this.wrapShadow = new THREE.FloatNode( 0 );
						
					} else {
						
						delete this.wrapColor;
						delete this.wrapLight;
						delete this.wrapShadow;
						
					}

				}
			},
			rimIntensity: {
				enumerable: true,
				get: function() {

					return this.rimIntensityValue;

				},
				set: function( val ) {

					this.rimIntensityValue = val;

					this.rimViewZ.b.z = - val;
					this.rimMath.b.number = val;

				}
			},
			enabledFresnel: {
				enumerable: true,
				get: function() {

					return this.fresnel != null;

				},
				set: function( value ) {

					if ( this.enabledFresnel == !! value ) return;

					if ( value ) {

						this.fresnelReflectance = new THREE.FloatNode( 1.3 );
						this.fresnelPower = new THREE.FloatNode( 1 );

						this.fresnelViewZ = new THREE.Math2Node(
							new THREE.NormalNode( THREE.NormalNode.VIEW ),
							new THREE.Vector3Node( 0, 0, - 1 ),
							THREE.Math2Node.DOT
						);

						this.fresnelTheta = new THREE.OperatorNode(
							this.fresnelViewZ,
							new THREE.FloatNode( 1 ),
							THREE.OperatorNode.ADD
						);

						this.fresnelThetaPower = new THREE.Math2Node(
							this.fresnelTheta,
							this.fresnelPower,
							THREE.Math2Node.POW
						);

						this.fresnel = new THREE.OperatorNode(
							this.fresnelReflectance,
							this.fresnelThetaPower,
							THREE.OperatorNode.MUL
						);

					}
					else {

						delete this.fresnelReflectance;
						delete this.fresnelPower;
						delete this.fresnelViewZ;
						delete this.fresnelTheta;
						delete this.fresnelThetaPower;
						delete this.fresnel;

					}

				}
			},
		} );

		this.build = THREE.SEA3D.MaterialBuilder.build.bind( this );

	},

	build : function() {

		// DIFFUSE

		var diffuse = this.diffuse;
		
		// COLOR_REPLACE
		
		if (diffuse && this.enabledColorReplace) {
		
			var red = new THREE.OperatorNode( new THREE.SwitchNode( diffuse, 'r' ), this.red, THREE.OperatorNode.MUL );
			var green = new THREE.OperatorNode( new THREE.SwitchNode( diffuse, 'g' ), this.green, THREE.OperatorNode.MUL );
			var blue = new THREE.OperatorNode( new THREE.SwitchNode( diffuse, 'b' ), this.blue, THREE.OperatorNode.MUL );
			
			var colors = new THREE.OperatorNode( red, new THREE.OperatorNode(green, blue, THREE.OperatorNode.ADD), THREE.OperatorNode.ADD );
			
			diffuse = new THREE.JoinNode( 
				new THREE.SwitchNode( colors, 'r' ),
				new THREE.SwitchNode( colors, 'g' ),
				new THREE.SwitchNode( colors, 'b' ),
				new THREE.SwitchNode( diffuse, 'a' )
			);
		
		}
		
		// DIFFUSE_OPACITY
		
		var alpha = this.opacity < 1 ? new THREE.FloatNode( this.opacity ) : undefined;

		if ( diffuse && this.diffuseTransparent ) {

			var diffuseAlpha = new THREE.SwitchNode( diffuse, 'a' );

			if ( alpha ) alpha = new THREE.OperatorNode( alpha, diffuseAlpha, THREE.OperatorNode.MUL );
			else alpha = diffuseAlpha;

		}
		
		// ALPHA
		
		if ( this.alphaDiffuse ) {

			var alphaDiffuse = new THREE.SwitchNode( this.alphaDiffuse, 'r' );

			if ( alpha ) alpha = new THREE.OperatorNode( alpha, alphaDiffuse, THREE.OperatorNode.MUL );
			else alpha = alphaDiffuse;

		}

		// DETAIL

		var detailDiffuse = this.detailDiffuse;

		if ( detailDiffuse ) {

			detailDiffuse.coord = new THREE.OperatorNode( new THREE.UVNode(), this.detailScale, THREE.OperatorNode.MUL );
		
			if (diffuse) {
			
				switch (this.detailBlendMode) {
				
					case "multiply":
						diffuse = new THREE.OperatorNode( diffuse, detailDiffuse, THREE.OperatorNode.MUL );
						break;
				
				}
				
			} else {
			
				diffuse = detailDiffuse;
			
			}

		}
		
		this.color = diffuse || new THREE.ColorNode( 0xEEEEEE );

		if ( alpha ) this.alpha = alpha;

		// SPECULAR

		var specular = this.specularColor;

		if ( this.specularMap ) {

			specular = new THREE.OperatorNode(
				specular,
				this.specularMap,
				THREE.OperatorNode.MUL
			);

		}

		this.specular = specular;

		// LIGHT/SHADOW

		var light, shadow;

		if ( this.lightDiffuse ) {

			if ( this.lightBlendMode == "add" ) light = lightDiffuse;
			else shadow = lightDiffuse;

		}
		
		// WRAP LIGHT
		
		var wrapColor = new THREE.ColorNode( 0x6b0602 );
					var wrapLight = new THREE.FloatNode( 1.5 );
					var wrapShadow = new THREE.FloatNode( 0 );
		
		if (this.wrapColor) {
			
			var wrapDirectLight = new THREE.LightNode();
			var wrapLightLuminance = new THREE.LuminanceNode( wrapDirectLight );
			
			var lightWrap = new THREE.Math3Node(
				this.wrapShadow,
				this.wrapLight,
				wrapLightLuminance,
				THREE.Math3Node.SMOOTHSTEP
			);
			var lightTransition = new THREE.OperatorNode(
				lightWrap,
				new THREE.ConstNode( THREE.ConstNode.PI2 ),
				THREE.OperatorNode.MUL
			);
			
			var wrappedLight = new THREE.Math1Node( lightTransition, THREE.Math1Node.SIN );
			
			var wrappedLightColor = new THREE.OperatorNode(
				wrappedLight,
				this.wrapColor,
				THREE.OperatorNode.MUL
			);
			
			var wrappedArea = new THREE.Math1Node( wrappedLightColor, THREE.Math1Node.SAT );
			
			var wrappedTotalLight = new THREE.OperatorNode(
				wrapDirectLight,
				wrappedArea,
				THREE.OperatorNode.ADD
			);
			
			if (light) light = new THREE.OperatorNode( light, wrappedTotalLight, THREE.OperatorNode.ADD );
			else light = wrappedTotalLight;
			
		}
		
		this.light = light;
		this.shadow = shadow;
		
		// AMBIENT

		var ambient;
		
		if ( this.ambientColor ) {

			ambient = new THREE.OperatorNode(
				diffuse,
				this.ambientColor,
				THREE.OperatorNode.MUL
			);
			
		}
		
		this.ambient = ambient;

		// ENVIRONMENT ( PHONG )

		var environment, environmentAlpha;

		//-- ADD REFLECT 
		
		if (this.reflection) {

			environment = this.reflection;
			environmentAlpha = this.reflectionAlpha;

		}
		
		if ( this.enabledRim ) {

			if (this.emissive) this.emissive = new THREE.OperatorNode(this.emissive, this.rim, THREE.OperatorNode.ADD);
			else this.emissive = this.rim;

		} else if (this.enabledFresnel) {
		
			var fresnel = new THREE.Math1Node( this.fresnel, THREE.Math1Node.SAT );

			if ( environmentAlpha ) {

				fresnel = new THREE.OperatorNode(
					fresnel,
					environmentAlpha,
					THREE.OperatorNode.MUL
				);

			}

			environmentAlpha = fresnel;
		
		}
		
		this.environment = environment;
		this.environmentAlpha = environmentAlpha;
		
		// COMPLETE

		THREE.NodeMaterial.prototype.build.call( this );

	}
};

//
//	Phong Material
//

THREE.SEA3D.PhongMaterial = function() {

	THREE.PhongNodeMaterial.call( this );

	THREE.SEA3D.MaterialBuilder.apply.call( this );

};

THREE.SEA3D.PhongMaterial.prototype = Object.assign( Object.create( THREE.PhongNodeMaterial.prototype ), {

	constructor : THREE.SEA3D.PhongMaterial

} );

//
//	Standard Material
//

THREE.SEA3D.StandardMaterial = function() {

	THREE.StandardNodeMaterial.call( this );

	THREE.SEA3D.MaterialBuilder.apply.call( this );

};

THREE.SEA3D.StandardMaterial.prototype = Object.assign( Object.create( THREE.StandardNodeMaterial.prototype ), {

	constructor : THREE.SEA3D.StandardMaterial

} );

//
//	Standard Material
//

THREE.SEA3D.prototype.applyEnvironment = function(envMap) {
	
	for ( var j = 0, l = this.materials.length; j < l; ++ j ) {

		var mat = this.materials[ j ];

		if ( mat instanceof THREE.SEA3D.StandardMaterial ) {

			if ( mat.reflection ) continue;

			mat.reflection = new THREE.CubeTextureNode( envMap );

			mat.build();

		}

	}
	
};


THREE.SEA3D.prototype.createMaterial = function( sea ) {

	if (sea.tecniquesDict[ SEA3D.Material.PHYSICAL ]) {

		return new THREE.SEA3D.StandardMaterial();

	}

	return new THREE.SEA3D.PhongMaterial();

};

THREE.SEA3D.prototype.defaultMaterialTechnique = THREE.SEA3D.prototype.materialTechnique;

THREE.SEA3D.prototype.materialTechnique =
( function() {

	var techniques = {}

	// FINAL
	techniques.onComplete = function( mat, sea ) {

		this.defaultMaterialTechnique.onComplete( mat, sea );

		mat.build();

	};

	// PHYSICAL
	techniques[ SEA3D.Material.PHYSICAL ] =
	function( mat, tech ) {

		mat.diffuse = new THREE.ColorNode( tech.color );
		mat.roughness.number = tech.roughness;
		mat.metalness.number = tech.metalness;

	};

	// REFLECTIVITY
	techniques[ SEA3D.Material.REFLECTIVITY ] =
	function( mat, tech ) {

		mat.reflectivity = new THREE.FloatNode( tech.strength );

	};

	// CLEAR_COAT
	techniques[ SEA3D.Material.CLEAR_COAT ] =
	function( mat, tech ) {

		mat.clearCoat = new THREE.FloatNode( tech.strength );
		mat.clearCoatRoughness = new THREE.FloatNode( tech.roughness );

	};

	// PHONG
	techniques[ SEA3D.Material.PHONG ] =
	function( mat, tech ) {

		mat.ambientColor = new THREE.ColorNode( tech.ambientColor );
		mat.diffuse = new THREE.ColorNode( tech.diffuseColor );
		mat.specularColor = new THREE.ColorNode( tech.specularColor );
		mat.specularColor.value.multiplyScalar( tech.specular );
		mat.shininess.number = tech.gloss;

	};

	// DIFFUSE_MAP
	techniques[ SEA3D.Material.DIFFUSE_MAP ] =
	function( mat, tech ) {

		mat.diffuse = new THREE.TextureNode( tech.texture.tag );
		mat.diffuseTransparent = tech.texture.transparent;

	};

	// ROUGHNESS_MAP
	techniques[ SEA3D.Material.ROUGHNESS_MAP ] =
	function( mat, tech ) {

		mat.roughness = new THREE.TextureNode( tech.texture.tag );

	};

	// METALNESS_MAP
	techniques[ SEA3D.Material.METALNESS_MAP ] =
	function( mat, tech ) {

		mat.metalness = new THREE.TextureNode( tech.texture.tag );

	};

	// SPECULAR_MAP
	techniques[ SEA3D.Material.SPECULAR_MAP ] =
	function( mat, tech ) {

		mat.specularMap = new THREE.TextureNode( tech.texture.tag );

	};

	// NORMAL_MAP
	techniques[ SEA3D.Material.NORMAL_MAP ] =
	function( mat, tech ) {

		mat.normal = new THREE.TextureNode( tech.texture.tag );

	};

	// REFLECTION
	techniques[ SEA3D.Material.REFLECTION ] =
	techniques[ SEA3D.Material.FRESNEL_REFLECTION ] =
	function( mat, tech ) {

		mat.reflection = new THREE.CubeTextureNode( tech.texture.tag );
		mat.reflectionAlpha = new THREE.FloatNode( tech.alpha );

		if ( tech.kind == SEA3D.Material.FRESNEL_REFLECTION ) {

			mat.enabledFresnel = true;
			mat.fresnelPower.number = tech.power;
			mat.fresnelReflectance.number = tech.normal + 1;

		}

	};

	// REFLECTION_SPHERICAL
	techniques[ SEA3D.Material.REFLECTION_SPHERICAL ] =
	function( mat, tech ) {

		mat.reflection = new THREE.TextureNode( tech.texture.tag, new THREE.ReflectNode( THREE.ReflectNode.SPHERE ) );
		mat.reflectionAlpha = new THREE.FloatNode( tech.alpha );

	};
	
	// COLOR_REPLACE
	techniques[ SEA3D.Material.COLOR_REPLACE ] =
	function( mat, tech ) {

		mat.enabledColorReplace = true;
		mat.red = new THREE.ColorNode( tech.red ); 
		mat.green = new THREE.ColorNode( tech.green ); 
		mat.blue = new THREE.ColorNode( tech.blue ); 

	};
	
	// RIM
	techniques[ SEA3D.Material.RIM ] =
	function( mat, tech ) {

		mat.enabledRim = true;
		mat.rimColor.value.setHex( tech.color );
		mat.rimIntensity = tech.strength;
		mat.rimPower.number = tech.power;

	};

	// WRAP_LIGHTING
	techniques[ SEA3D.Material.WRAP_LIGHTING ] =
	function( mat, tech ) {

		mat.enabledWrapLighting = true;
		mat.wrapColor.value.setHex( tech.color );
		mat.wrapShadow.number = 1.0 - tech.strength;

	};
	
	// LIGHT_MAP
	techniques[ SEA3D.Material.LIGHT_MAP ] =
	function( mat, tech ) {

		mat.lightDiffuse = new THREE.TextureNode( tech.texture.tag, new THREE.UVNode( tech.channel ) );
		mat.lightBlendMode = tech.blendMode;

	};
	
	// DETAIL_MAP
	techniques[ SEA3D.Material.DETAIL_MAP ] =
	function( mat, tech ) {

		mat.detailDiffuse = new THREE.TextureNode( tech.texture.tag );
		mat.detailBlendMode = tech.blendMode;
		mat.detailScale = new THREE.FloatNode( tech.scale );

	};
	
	// ALPHA_MAP
	techniques[ SEA3D.Material.ALPHA_MAP ] =
	function( mat, tech ) {

		mat.alphaDiffuse = new THREE.TextureNode( tech.texture.tag );

	};

	return techniques;

} )();
