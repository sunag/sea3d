/**
 * @author sunag / http://www.sunag.com.br/
 */

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
	
	THREE.NodeGL.call( this, 'v3' );
	
};

THREE.NodeFunction.prototype = Object.create( THREE.NodeGL.prototype );
THREE.NodeFunction.prototype.constructor = THREE.NodeFunction;