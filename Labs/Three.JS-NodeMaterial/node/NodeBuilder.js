/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeBuilder = function( material ) {
	
	this.material = material;
	this.isVerify = false;
	this.cache = '';
	
};

THREE.NodeBuilder.prototype = {
	constructor: THREE.NodeBuilder,

	include : function ( name ) {
		
		this.material.include( this.shader, name );

	},
	
	getUuid : function ( uuid ) {
		
		if (this.cache) uuid = this.cache + '-' + uuid;
		
		return uuid;

	},
	
	setCache : function ( name ) {
		
		this.cache = name || '';
		
		return this;

	},
	
	isShader : function ( shader ) {
		
		return this.shader == shader || this.isVerify;

	},
	
	setShader : function ( shader ) {
		
		this.shader = shader;
		
		return this;

	}
};