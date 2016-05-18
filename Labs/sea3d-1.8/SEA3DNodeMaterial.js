/**
 * 	SEA3D Node Material for Three.JS
 * 	@author Sunag / http://www.sunag.com.br/
 */

'use strict';

//
//	Phong Node Material
//

THREE.SEA3D.PhongNodeMaterial = function() {

	THREE.PhongNodeMaterial.call( this );

};

THREE.SEA3D.PhongNodeMaterial.prototype = Object.create( THREE.PhongNodeMaterial.prototype );
THREE.SEA3D.PhongNodeMaterial.prototype.constructor = THREE.SEA3D.PhongNodeMaterial;

//
//	Standard Node Material
//

THREE.SEA3D.StandardNodeMaterial = function() {

	THREE.StandardNodeMaterial.call( this );

};

THREE.SEA3D.StandardNodeMaterial.prototype = Object.create( THREE.StandardNodeMaterial.prototype );
THREE.SEA3D.StandardNodeMaterial.prototype.constructor = THREE.SEA3D.StandardNodeMaterial;

//
//	Phong Material
//

THREE.SEA3D.PhongMaterial = function() {

	THREE.PhongNodeMaterial.call( this );

	THREE.SEA3D.MaterialBuilder.apply.call( this );

};

THREE.SEA3D.PhongMaterial.prototype = Object.create( THREE.PhongNodeMaterial.prototype );
THREE.SEA3D.PhongMaterial.prototype.constructor = THREE.SEA3D.PhongMaterial;

//
//	Standard Material
//

THREE.SEA3D.StandardMaterial = function() {

	THREE.StandardNodeMaterial.call( this );

	THREE.SEA3D.MaterialBuilder.apply.call( this );

};

THREE.SEA3D.StandardMaterial.prototype = Object.create( THREE.StandardNodeMaterial.prototype );
THREE.SEA3D.StandardMaterial.prototype.constructor = THREE.SEA3D.StandardMaterial;

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

					}
					else {

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

		var enabledRim = this.enabledRim;
		var enabledFresnel = this.enabledFresnel;

		if ( enabledRim ) this.ambient = this.rim;

		// DIFFUSE+ALPHA

		var diffuse = this.diffuse;
		var alpha = this.opacity < 1 ? new THREE.FloatNode( this.opacity ) : undefined;

		if ( diffuse && this.diffuseTransparent ) {

			var diffuseAlpha = new THREE.SwitchNode( diffuse, 'a' );

			if ( alpha ) alpha = new THREE.OperatorNode( alpha, diffuseAlpha, THREE.OperatorNode.MUL );
			else alpha = diffuseAlpha;

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

		// LIGHT_MAP

		var lightMap = this.lightMapDiffuse;

		if ( lightMap ) {

			if ( this.lightMapBlendMode == "add" ) this.light = lightMap;
			else this.shadow = lightMap;

		}

		// AMBIENT

		if ( this.ambientColor ) {

			this.ambient = new THREE.OperatorNode(
				this.diffuse,
				this.ambientColor,
				THREE.OperatorNode.MUL
			);

		}

		// ENVIRONMENT

		var reflection = this.reflection;
		var reflectionAlpha = this.reflectionAlpha;

		if ( reflection ) {

			this.environment = reflection;
			this.environmentAlpha = reflectionAlpha;

		}

		// ENVIRONMENT

		if ( enabledFresnel ) {

			var fresnel = new THREE.Math1Node( this.fresnel, THREE.Math1Node.SAT );

			if ( this.environmentAlpha ) {

				fresnel = new THREE.OperatorNode(
					fresnel,
					this.environmentAlpha,
					THREE.OperatorNode.MUL
				);

			}

			this.environmentAlpha = fresnel;

		}

		THREE.NodeMaterial.prototype.build.call( this );

	}
};

//
//	Node Material
//

THREE.SEA3D.prototype.readNodeMaterial = function( sea ) {

	var mat = sea.physical ? new THREE.SEA3D.StandardNodeMaterial() : new THREE.SEA3D.PhongNodeMaterial();



	this.domain.materials = this.materials = this.materials || [];
	this.materials.push( this.objects[ "mat/" + sea.name ] = sea.tag = mat );

};

//
//	Standard Material
//

THREE.SEA3D.prototype.createMaterial = function( sea ) {

	return sea.physical ? new THREE.SEA3D.StandardMaterial() : new THREE.SEA3D.PhongMaterial();

};

THREE.SEA3D.prototype.materialTechnique =
( function() {

	var techniques = {}

	// FINAL
	techniques.onComplete = function( mat, sea ) {

		mat.opacity = sea.alpha;

		mat.build();

	};

	// PHYSICAL
	techniques[ SEA3D.Material.PHYSICAL ] =
	function( mat, tech ) {

		mat.diffuse = new THREE.ColorNode( tech.color );
		mat.roughness.number = tech.roughness;
		mat.metalness.number = tech.metalness;

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

	// RIM
	techniques[ SEA3D.Material.RIM ] =
	function( mat, tech ) {

		mat.enabledRim = true;
		mat.rimColor.value.setHex( tech.power );
		mat.rimIntensity = tech.strength;
		mat.rimPower.number = tech.power;

	};

	// LIGHT_MAP
	techniques[ SEA3D.Material.LIGHT_MAP ] =
	function( mat, tech ) {

		mat.lightMapDiffuse = new THREE.TextureNode( tech.texture.tag, new THREE.UVNode( tech.channel ) );
		mat.lightMapBlendMode = tech.blendMode;

	};

	return techniques;

} )();
