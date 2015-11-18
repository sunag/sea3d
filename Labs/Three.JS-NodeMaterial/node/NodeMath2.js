/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeMath2 = function( a, b, method ) {
	
	THREE.NodeTemp.call( this );
	
	this.a = a;
	this.b = b;
	
	this.method = method || THREE.NodeMath2.MIN;
	
};

THREE.NodeMath2.prototype = Object.create( THREE.NodeGL.prototype );
THREE.NodeMath2.prototype.constructor = THREE.NodeMath2;

THREE.NodeMath2.MIN = 'min';
THREE.NodeMath2.MAX = 'max';
THREE.NodeMath2.MODULO = 'mod';
THREE.NodeMath2.STEP = 'step';
THREE.NodeMath2.REFLECT = 'reflect';
THREE.NodeMath2.DISTANCE = 'distance';
THREE.NodeMath2.DOT = 'dot';
THREE.NodeMath2.CROSS = 'cross';
THREE.NodeMath2.EXPONENTIATION = 'pow';

THREE.NodeMath2.prototype.getInputType = function() {
	
	// use the greater length vector
	if (this.getFormatLength( this.b.getType() ) > this.getFormatLength( this.a.getType() )) {
		return this.b.getType();
	}
	
	return this.a.getType();
	
};

THREE.NodeMath2.prototype.getType = function() {
	
	switch(this.method) {
		case THREE.NodeMath2.DISTANCE:
		case THREE.NodeMath2.DOT:
			return 'fv1';
			break;
		
		case THREE.NodeMath2.CROSS:
			return 'v3';
			break;
	}
	
	return this.getInputType();
};

THREE.NodeMath2.prototype.generate = function( material, shader, output ) {
	
	var type = this.getInputType();
	
	var a, b, 
		al = this.getFormatLength( this.a.getType() ),
		bl = this.getFormatLength( this.b.getType() );
	
	// optimzer
	
	switch(this.method) {
		case THREE.NodeMath2.CROSS:
			a = this.a.build( material, shader, 'v3' );
			b = this.b.build( material, shader, 'v3' );
			break;
		
		case THREE.NodeMath2.STEP:
			a = this.a.build( material, shader, al == 1 ? 'fv1' : type );
			b = this.b.build( material, shader, type );
			break;
			
		case THREE.NodeMath2.MIN:
		case THREE.NodeMath2.MAX:
		case THREE.NodeMath2.MODULO:
			a = this.a.build( material, shader, type );
			b = this.b.build( material, shader, bl == 1 ? 'fv1' : type );
			break;
			
		default:
			a = this.a.build( material, shader, type );
			b = this.b.build( material, shader, type );
			break;
	
	}
	
	return this.format( this.method + '(' + a + ',' + b + ')', this.getType(), output );

};