/**
 * @author sunag / http://www.sunag.com.br/
 * @thanks bhouston / https://clara.io/
 */

THREE.NodeFunction = function( src, includes, extensions ) {
	
	THREE.NodeGL.call( this );
	
	this.parse( src || '', includes, extensions );
	
};

THREE.NodeFunction.prototype = Object.create( THREE.NodeGL.prototype );
THREE.NodeFunction.prototype.constructor = THREE.NodeFunction;

THREE.NodeFunction.prototype.parseReference = function( name ) {
	
	switch(name) {
		case 'uv': return new THREE.NodeUV().name;
		case 'uv2': return new THREE.NodeUV(true).name;
		case 'position': return new THREE.NodeTransformedPosition().name;
		case 'normal': return new THREE.NodeTransformedPosition().name;
	}
	
	return name;
	
};

THREE.NodeFunction.prototype.getNodeType = function( builder, type ) {

	return builder.getType( type ) || type;

};

THREE.NodeFunction.prototype.getInputByName = function( name ) {
	
	var i = this.input.length;
	
	while(i--) {
	
		if (this.input[i].name === name)
			return this.input[i];
		
	}
	
};

THREE.NodeFunction.prototype.getType = function( builder ) {
	
	return this.getNodeType( builder, this.type );
	
};

THREE.NodeFunction.prototype.parse = function( src, includes, extensions ) {
	
	var rDeclaration = /^([a-z_0-9]+)\s([a-z_0-9]+)\s?\((.*?)\)/i;
	var rProperties = /[a-z_0-9]+/ig;
	
	this.src = src;
	this.includes = includes || [];
	this.extensions = extensions || {};
	
	var match = src.match( rDeclaration );
	
	this.input = [];
	
	if (match && match.length == 4) {
	
		this.type = match[1];
		this.name = match[2];
		
		var inputs = match[3].match( rProperties );
		
		if (inputs) {
		
			var i = 0;
			
			while(i < inputs.length) {
			
				var qualifier = inputs[i++];
				var type, name;
				
				if (qualifier == 'in' || qualifier == 'out' || qualifier == 'inout') {
				
					type = inputs[i++];
					
				}
				else {
					
					type = qualifier;
					qualifier = '';
				
				}
				
				name = inputs[i++];
				
				this.input.push({
					name : name,
					type : type,
					qualifier : qualifier
				});
			}
			
		}

		var match;
		
		while (match = rProperties.exec(src)) {
			
			var prop = match[0];
			var reference = this.parseReference( prop );
			
			
			//console.log(prop, reference);
			
		}

	}
	else {
		
		this.type = '';
		this.name = '';
	
	}
};