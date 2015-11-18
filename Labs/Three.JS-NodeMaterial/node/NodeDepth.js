/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeDepth = function( value, near, far ) {
	
	THREE.NodeGL.call( this, 'fv1' );
	
	this.allow.vertex = false;
	
	this.near = near || new THREE.NodeFloat(1);
	this.far = far || new THREE.NodeFloat(500);
	
};

THREE.NodeDepth.prototype = Object.create( THREE.NodeGL.prototype );
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