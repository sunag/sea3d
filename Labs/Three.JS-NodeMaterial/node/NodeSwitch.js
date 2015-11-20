/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeSwitch = function( a, component ) {
	
	THREE.NodeGL.call( this, 'fv1' );
	
	this.component = component || 'x';
	
	this.a = a;
	
};

THREE.NodeSwitch.prototype = Object.create( THREE.NodeGL.prototype );
THREE.NodeSwitch.prototype.constructor = THREE.NodeSwitch;

THREE.NodeSwitch.elements = ['x','y','z','w'];

THREE.NodeSwitch.prototype.generate = function( builder, output ) {
	
	var type = this.a.getType();
	var inputLength = this.getFormatLength(type);
		
	var a = this.a.build( builder, type );
	
	var outputLength = THREE.NodeSwitch.elements.indexOf( this.component ) + 1;
	
	if (inputLength > 1) {
	
		if (inputLength < outputLength) outputLength = inputLength;
		
		a = a + '.' + THREE.NodeSwitch.elements[outputLength-1];
	}
	
	return this.format( a, this.type, output );

};