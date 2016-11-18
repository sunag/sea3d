SEA3D.js

3030 __ while ( this.state() ) continue;
3048 throw is miss __ if ( ! buffer ) throw new Error( "No data found." );

SEA3DLegacy.js

185 Suspicious code __ if ( rotate ){ ? }


SEA3DLoader.js

Redeclared variable :
1468 var obj3d*

t, k, times, values, in THREE.SEA3D.prototype.readAnimation

2468 techniques[ SEA3D.Material.ALPHA_MAP ] sea is miss __ function( mat, tech, sea ) {

////////////// ADD

SEA3DLoader.js

on THREE.SEA3D.Mesh setWeight for both animation and morpher

setWeight : function( name, val ) {

    if( this.animations && this.animations[ name ] ) this.mixer.clipAction( name ).setEffectiveWeight( val );
    if( this.morphTargetInfluences && this.morphTargetDictionary[ name ] !== undefined ) this.morphTargetInfluences[ this.morphTargetDictionary[ name ] ] = val;

},

getWeight : function( name ) {

    if( this.animations && this.animations[ name ] ) return this.mixer.clipAction( name ).getEffectiveWeight();
    if( this.morphTargetDictionary && this.morphTargetDictionary[ name ] !== undefined ) return this.morphTargetInfluences[ this.morphTargetDictionary[ name ] ];

},

updateAnimations : function( mixer ) {
    ...
    this.animations = {};
    this.animationsIndex = [];
    this.animationsData = {};
    // if no geometry animation
    if( this.geometry && this.geometry.animations === undefined ) return;

playw must return clip not mixer 
