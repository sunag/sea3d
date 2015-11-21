/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeRaw = function( value ) {
	
	THREE.NodeGL.call( this, 'v4' );
	
	this.value = value;
	
};

THREE.NodeRaw.prototype = Object.create( THREE.NodeGL.prototype );
THREE.NodeRaw.prototype.constructor = THREE.NodeRaw;

THREE.NodeGL.prototype.generate = function( builder ) {
	
	var material = builder.material;
	var data = this.value.verifyAndBuildCode( builder, this.type );
	
	var code = data.code + '\n';
	
	if (builder.shader == 'vertex') {
		
		return 'gl_Position = ' + data.result + ';';
		
	}
	else {
		
		return 'gl_FragColor = ' + data.result + ';';
	
	}

};