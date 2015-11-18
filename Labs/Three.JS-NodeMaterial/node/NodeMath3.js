/**
 * @author sunag / http://www.sunag.com.br/
 */

THREE.NodeMath3 = function( a, b, c, method ) {
	
	THREE.NodeTemp.call( this );
	
	this.a = a;
	this.b = b;
	this.c = c;
	
	this.method = method || THREE.NodeMath3.MIX;
	
};

THREE.NodeMath3.prototype = Object.create( THREE.NodeGL.prototype );
THREE.NodeMath3.prototype.constructor = THREE.NodeMath3;

THREE.NodeMath3.MIX = 'mix';
THREE.NodeMath3.REFRACT = 'refract';
THREE.NodeMath3.SMOOTHSTEP = 'smoothstep';
THREE.NodeMath3.FACEFORWARD = 'faceforward';

THREE.NodeMath3.prototype.getType = function() {
	
	var a = this.getFormatLength( this.a.getType() );
	var b = this.getFormatLength( this.b.getType() );
	var c = this.getFormatLength( this.c.getType() );
	
	if (a > b) {
		if (a > c) return this.a.getType();
		return this.c.getType();
	} 
	else {
		if (b > c) return this.b.getType();
	
		return this.c.getType();
	}
	
};

THREE.NodeMath3.prototype.generate = function( material, shader, output ) {
	
	var type = this.getType();
	
	var a, b, c,
		al = this.getFormatLength( this.a.getType() ),
		bl = this.getFormatLength( this.b.getType() ),
		cl = this.getFormatLength( this.b.getType() )
	
	// optimzer
	
	switch(this.method) {
		case THREE.NodeMath3.REFRACT:
			a = this.a.build( material, shader, type );
			b = this.b.build( material, shader, type );
			c = this.c.build( material, shader, 'fv1' );
			break;
		
		case THREE.NodeMath3.MIX:
		case THREE.NodeMath3.SMOOTHSTEP:
			a = this.a.build( material, shader, type );
			b = this.b.build( material, shader, type );
			c = this.c.build( material, shader, cl == 1 ? 'fv1' : type );
			break;
			
		default:
			a = this.a.build( material, shader, type );
			b = this.b.build( material, shader, type );
			c = this.c.build( material, shader, type );
			break;
	
	}
	
	return this.format( this.method + '(' + a + ',' + b + ',' + c + ')', type, output );

};