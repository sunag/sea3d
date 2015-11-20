/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeMath1 = function( a, method ) {
	
	THREE.NodeTemp.call( this );
	
	this.a = a;
	
	this.method = method || THREE.NodeMath1.SINE;
	
};

THREE.NodeMath1.prototype = Object.create( THREE.NodeGL.prototype );
THREE.NodeMath1.prototype.constructor = THREE.NodeMath1;

THREE.NodeMath1.RADIANS = 'radians';
THREE.NodeMath1.DEGREES = 'degrees';
THREE.NodeMath1.EXPONENTIAL = 'exp';
THREE.NodeMath1.EXPONENTIAL2 = 'exp2';
THREE.NodeMath1.LOGARITHM = 'log';
THREE.NodeMath1.LOGARITHM2 = 'log2';
THREE.NodeMath1.INVERSE_SQUARE = 'inversesqrt';
THREE.NodeMath1.FLOOR = 'floor';
THREE.NodeMath1.CEILING = 'ceil';
THREE.NodeMath1.NORMALIZE = 'normalize';
THREE.NodeMath1.FRACTIONAL = 'fract';
THREE.NodeMath1.SINE = 'sin';
THREE.NodeMath1.COSINE = 'cos';
THREE.NodeMath1.TANGENT = 'tan';
THREE.NodeMath1.ARCSINE = 'asin';
THREE.NodeMath1.ARCCOSINE = 'acos';
THREE.NodeMath1.ARCTANGENT = 'atan';
THREE.NodeMath1.ABSOLUTE = 'abc';
THREE.NodeMath1.SIGN = 'sign';
THREE.NodeMath1.LENGTH = 'length';

THREE.NodeMath1.prototype.getType = function() {
	
	switch(this.method) {
		case THREE.NodeMath1.DISTANCE:
			return 'fv1';
			break;
	}
	
	return this.a.getType();
	
};

THREE.NodeMath1.prototype.generate = function( builder, output ) {
	
	var material = builder.material;
	
	var type = this.getType();
	
	var a = this.a.build( builder, type );
	
	return this.format( this.method + '(' + a + ')', type, output );

};