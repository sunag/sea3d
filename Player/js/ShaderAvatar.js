
THREE.ShaderAvatar = {
    uniforms: Object.assign( {},
        THREE.UniformsLib.common,
        THREE.UniformsLib.aomap,
        THREE.UniformsLib.lightmap,
        THREE.UniformsLib.emissivemap,
        THREE.UniformsLib.bumpmap,
        THREE.UniformsLib.normalmap,
        THREE.UniformsLib.displacementmap,
        THREE.UniformsLib.roughnessmap,
        THREE.UniformsLib.metalnessmap,
        THREE.UniformsLib.fog,
        THREE.UniformsLib.lights,
        {
            emissive : { value: new THREE.Color( 0x000000 ) },
            roughness: { value: 0.5 },
            metalness: { value: 0 },
            envMapIntensity : { value: 1 }, // temporary
            skin: { value: null },
            skinAlpha: { value: 0.8 },
            normalMap2: { value: null },
        }
    ),

    vertexShader: [

    '#define PHYSICAL',

    'varying vec3 vViewPosition;',

    '#ifndef FLAT_SHADED',

    '    varying vec3 vNormal;',

    '#endif',

    '#include <common>',
    '#include <uv_pars_vertex>',
    '#include <uv2_pars_vertex>',
    '#include <displacementmap_pars_vertex>',
    '#include <color_pars_vertex>',
    '#include <morphtarget_pars_vertex>',
    '#include <skinning_pars_vertex>',
    '#include <shadowmap_pars_vertex>',
    '#include <specularmap_pars_fragment>',
    '#include <logdepthbuf_pars_vertex>',
    '#include <clipping_planes_pars_vertex>',

    'void main() {',

    '    #include <uv_vertex>',
    '    #include <uv2_vertex>',
    '    #include <color_vertex>',

    '    #include <beginnormal_vertex>',
    '    #include <morphnormal_vertex>',
    '    #include <skinbase_vertex>',
    '    #include <skinnormal_vertex>',
    '    #include <defaultnormal_vertex>',

    '#ifndef FLAT_SHADED', // Normal computed with derivatives when FLAT_SHADED

    '    vNormal = normalize( transformedNormal );',

    '#endif',

    '    #include <begin_vertex>',
    '    #include <displacementmap_vertex>',
    '    #include <morphtarget_vertex>',
    '    #include <skinning_vertex>',
    '    #include <project_vertex>',
    '    #include <logdepthbuf_vertex>',
    '    #include <clipping_planes_vertex>',

    '    vViewPosition = - mvPosition.xyz;',

    '    #include <worldpos_vertex>',
    '    #include <shadowmap_vertex>',

    '}',

    ].join( "\n" ),
    fragmentShader:[
    '#define PHYSICAL',

    'uniform vec3 diffuse;',
    'uniform vec3 emissive;',
    'uniform float roughness;',
    'uniform float metalness;',
    'uniform float opacity;',

    '#ifndef STANDARD',
    '    uniform float clearCoat;',
    '    uniform float clearCoatRoughness;',
    '#endif',

    'uniform float envMapIntensity;', // temporary

    'uniform sampler2D skin;',
    'uniform float skinAlpha;',

    'varying vec3 vViewPosition;',

    '#ifndef FLAT_SHADED',

    '    varying vec3 vNormal;',

    '#endif',

    '#include <common>',
    '#include <packing>',
    '#include <color_pars_fragment>',
    '#include <uv_pars_fragment>',
    '#include <uv2_pars_fragment>',
    '#include <map_pars_fragment>',
    '#include <alphamap_pars_fragment>',
    '#include <aomap_pars_fragment>',
    '#include <lightmap_pars_fragment>',
    '#include <emissivemap_pars_fragment>',
    '#include <envmap_pars_fragment>',
    '#include <fog_pars_fragment>',
    '#include <bsdfs>',
    '#include <cube_uv_reflection_fragment>',
    '#include <lights_pars>',
    '#include <lights_physical_pars_fragment>',
    '#include <shadowmap_pars_fragment>',
    '#include <bumpmap_pars_fragment>',
    //'#include <normalmap_pars_fragment>',

    'uniform sampler2D normalMap;',
    'uniform sampler2D normalMap2;',
    'uniform vec2 normalScale;',

    // Per-Pixel Tangent Space Normal Mapping
    // http://hacksoflife.blogspot.ch/2009/11/per-pixel-tangent-space-normal-mapping.html

    'vec3 perturbNormal2Arb( vec3 eye_pos, vec3 surf_norm ) {',

    '    vec3 q0 = dFdx( eye_pos.xyz );',
    '    vec3 q1 = dFdy( eye_pos.xyz );',
    '    vec2 st0 = dFdx( vUv.st );',
    '    vec2 st1 = dFdy( vUv.st );',

    '    vec3 S = normalize( q0 * st1.t - q1 * st0.t );',
    '    vec3 T = normalize( -q0 * st1.s + q1 * st0.s );',
    '    vec3 N = normalize( surf_norm );',

    '    vec3 mapN = texture2D( normalMap, vUv ).xyz * 2.0 - 1.0;',
    '    vec3 mapN2 = texture2D( normalMap2, vUv ).xyz * 2.0 - 1.0;',
    '    mapN = mix(mapN2 , mapN, skinAlpha );',
    '    mapN.xy = normalScale * mapN.xy;',
    '    mat3 tsn = mat3( S, T, N );',
    '    return normalize( tsn * mapN );',

    '}',


    '#include <roughnessmap_pars_fragment>',
    '#include <metalnessmap_pars_fragment>',
    '#include <logdepthbuf_pars_fragment>',
    '#include <clipping_planes_pars_fragment>',

    'void main() {',

    '    #include <clipping_planes_fragment>',

    '    vec4 diffuseColor = vec4( diffuse, opacity );',
    '    ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );',
    '    vec3 totalEmissiveRadiance = emissive;',

    '    #include <logdepthbuf_fragment>',
    //'    #include <map_fragment>',
    '    #ifdef USE_MAP',
    '        vec4 texelColor = texture2D( map, vUv );',
    '        vec4 texelColor2 = texture2D( skin, vUv );',
    '        texelColor = mapTexelToLinear( texelColor );',
    '        texelColor2 = mapTexelToLinear( texelColor2 ) * vec4(diffuse, 1.0);',
    '        diffuseColor = mix(texelColor , texelColor2, skinAlpha );',
    '    #endif',
    '    #include <color_fragment>',
    '    #include <alphamap_fragment>',
    '    #include <alphatest_fragment>',
    '    #include <specularmap_fragment>',
    '    #include <roughnessmap_fragment>',
    '    #include <metalnessmap_fragment>',
    '    #include <normal_flip>',
    //'    #include <normal_fragment>',

    '    vec3 normal = normalize( vNormal );',
    '    normal = perturbNormal2Arb( -vViewPosition, normal );',


    '    #include <emissivemap_fragment>',

        // accumulation
    '    #include <lights_physical_fragment>',
    '    #include <lights_template>',

        // modulation
    '    #include <aomap_fragment>',

    '    vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + reflectedLight.directSpecular + reflectedLight.indirectSpecular + totalEmissiveRadiance;',

    '    gl_FragColor = vec4( outgoingLight, diffuseColor.a );',

    '    #include <premultiplied_alpha_fragment>',
    '    #include <tonemapping_fragment>',
    '    #include <encodings_fragment>',
    '    #include <fog_fragment>',

    '}',
    ].join( "\n" )

}


THREE.AvatarMaterial = function ( parameters ) {

    THREE.ShaderMaterial.call( this );

    this.defines = { 'STANDARD': '' };
    this.uniforms = THREE.ShaderAvatar.uniforms;
    this.vertexShader = THREE.ShaderAvatar.vertexShader;
    this.fragmentShader = THREE.ShaderAvatar.fragmentShader;

    


    this.skin = parameters.skin || null;
    this.skinAlpha = parameters.skinAlpha || 0.8;

    this.uniforms.skin.value = this.skin;
    this.uniforms.skinAlpha.value = this.skinAlpha;

    //this.type = 'MeshStandardMaterial';

    this.color = new THREE.Color( 0xffffff ); // diffuse
    this.roughness = 0.5;
    this.metalness = 0.5;

    this.map = null;
    

    this.lightMap = null;
    this.lightMapIntensity = 1.0;

    this.aoMap = null;
    this.aoMapIntensity = 1.0;

    this.emissive = new THREE.Color( 0x000000 );
    this.emissiveIntensity = 1.0;
    this.emissiveMap = null;

    this.bumpMap = null;
    this.bumpScale = 1;

    this.normalMap = null;
    this.normalScale = new THREE.Vector2( 1, 1 );

    this.displacementMap = null;
    this.displacementScale = 1;
    this.displacementBias = 0;

    this.roughnessMap = null;

    this.metalnessMap = null;

    this.alphaMap = null;

    this.envMap = null;
    this.envMapIntensity = 1.0;

    this.refractionRatio = 0.98;

    this.wireframe = false;
    this.wireframeLinewidth = 1;
    this.wireframeLinecap = 'round';
    this.wireframeLinejoin = 'round';

    this.skinning = false;
    this.morphTargets = false;
    this.morphNormals = false;

    this.setValues( parameters );

    //this.uniforms.skin.value = this.skin;

}

THREE.AvatarMaterial.prototype = Object.create( THREE.ShaderMaterial.prototype );
THREE.AvatarMaterial.prototype.constructor = THREE.AvatarMaterial;

THREE.AvatarMaterial.prototype.isMeshStandardMaterial = true;