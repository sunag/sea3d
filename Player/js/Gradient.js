/*
Dan Gries
rectangleworld.com
Nov 19 2012

Uses Floyd-Steinberg dither algorithm.
*/

var Grad = {};


Grad.fix = function ( n ) {

    //return Math.floor(n);
    //return Math.round(n);
    return ~~n;

};

// BUFFER

Grad.buffer = function ( n ) {
    this.r = [];
    this.g = [];
    this.b = [];
    this.a = [];
}

Grad.buffer.prototype.floyd = function( len, w ) {

    var n, q, lng = len/4;
    
    //While converting floats to integer valued color values, apply Floyd-Steinberg dither.
    for (var i = 0; i<lng; i++) {

        n = Grad.fix( this.r[i] );

        q = this.r[i] - n;
        this.r[i+1] += 7/16*q;
        this.r[i-1+w] += 3/16*q;
        this.r[i + w] += 5/16*q;
        this.r[i+1 + w] += 1/16*q;
        
        n = Grad.fix( this.g[i] );

        q = this.g[i] - n;
        this.g[i+1] += 7/16*q;
        this.g[i-1+w] += 3/16*q;
        this.g[i + w] += 5/16*q;
        this.g[i+1 + w] += 1/16*q;
        
        n = Grad.fix( this.b[i] );

        q = this.b[i] - n;
        this.b[i+1] += 7/16*q;
        this.b[i-1+w] += 3/16*q;
        this.b[i + w] += 5/16*q;
        this.b[i+1 + w] += 1/16*q;

        n = Grad.fix( this.a[i] );

        q = this.a[i] - n;
        this.a[i+1] += 7/16*q;
        this.a[i-1+w] += 3/16*q;
        this.a[i + w] += 5/16*q;
        this.a[i+1 + w] += 1/16*q;

    }

}

Grad.buffer.prototype.getPixel = function( n ) {

    return [ Grad.fix( this.r[n] ), Grad.fix( this.g[n] ), Grad.fix( this.b[n] ), Grad.fix( this.a[n] ) ];

}


Grad.buffer.prototype.clear = function() {

    this.r = [];
    this.g = [];
    this.b = [];
    this.a = [];

}

// LINEAR

Grad.Linear = function ( _x0,_y0,_x1,_y1 ) {

    this.x0 = _x0;
    this.y0 = _y0;
    this.x1 = _x1;
    this.y1 = _y1;
    this.colorStops = [];
    this.buffer = new Grad.buffer();

}

Grad.Linear.prototype.addColorStop = function( ratio, r, g, b, a ) {

    if ((ratio < 0) || (ratio > 1)) return;

    var n;
    if(a === undefined) a = 255;
    var newStop = { ratio:ratio, r:r, g:g, b:b, a:a  };
    if ((ratio >= 0) && (ratio <= 1)) {
        if (this.colorStops.length == 0) {
            this.colorStops.push(newStop);
        }
        else {
            var i = 0;
            var found = false;
            var len = this.colorStops.length;
            //search for proper place to put stop in order.
            while ((!found) && (i<len)) {
                found = (ratio <= this.colorStops[i].ratio);
                if (!found) {
                    i++;
                }
            }
            //add stop - remove next one if duplicate ratio
            if (!found) {
                //place at end
                this.colorStops.push(newStop);
            }
            else {
                //replace
                if (ratio == this.colorStops[i].ratio) this.colorStops.splice(i, 1, newStop);
                else this.colorStops.splice(i, 0, newStop);
            }
        }
    }
}

Grad.Linear.prototype.fillRect = function(ctx, rectX0, rectY0, rectW, rectH) {
    
    if (this.colorStops.length == 0) return;
    
    var px;
    var image = ctx.getImageData( rectX0, rectY0, rectW, rectH );
    var pixelData = image.data;
    var len = pixelData.length;
    var oldpixel, newpixel, nearestValue;
    var quantError;
    var x;
    var y;
    
    var vx = this.x1 - this.x0;
    var vy = this.y1 - this.y0;
    var vMagSquareRecip = 1/(vx*vx+vy*vy);
    var ratio;
    
    var r,g,b,a;
    var r0,g0,b0,r1,g1,b1, a0, a1;
    var ratio0,ratio1;
    var f;
    var stopNumber;
    var found;
    var q;
    
    //first complete color stops with 0 and 1 ratios if not already present
    if (this.colorStops[0].ratio != 0) {
        var newStop = { ratio:0,
                        r: this.colorStops[0].r,
                        g: this.colorStops[0].g,
                        b: this.colorStops[0].b,
                        a: this.colorStops[0].a
                    }
        this.colorStops.splice(0,0,newStop);
    }
    if (this.colorStops[this.colorStops.length-1].ratio != 1) {
        var newStop = { ratio:1,
                        r: this.colorStops[this.colorStops.length-1].r,
                        g: this.colorStops[this.colorStops.length-1].g,
                        b: this.colorStops[this.colorStops.length-1].b,
                        a: this.colorStops[this.colorStops.length-1].a
                    }
        this.colorStops.push(newStop);
    }

    var lng = len/4;

    //create float valued gradient
    for (i = 0; i<lng; i++) {
        
        x = rectX0 + (i % rectW);
        y = rectY0 + Math.floor(i/rectW);
        
        ratio = (vx*(x - this.x0) + vy*(y - this.y0))*vMagSquareRecip;
        if (ratio < 0) {
            ratio = 0;
        }
        else if (ratio > 1) {
            ratio = 1;
        }
        
        //find out what two stops this is between
        if (ratio == 1) {
            stopNumber = this.colorStops.length-1;
        }
        else {
            stopNumber = 0;
            found = false;
            while (!found) {
                found = (ratio < this.colorStops[stopNumber].ratio);
                if (!found) {
                    stopNumber++;
                }
            }
        }
        
        //calculate color.
        r0 = this.colorStops[stopNumber-1].r;
        g0 = this.colorStops[stopNumber-1].g;
        b0 = this.colorStops[stopNumber-1].b;
        a0 = this.colorStops[stopNumber-1].a;
        r1 = this.colorStops[stopNumber].r;
        g1 = this.colorStops[stopNumber].g;
        b1 = this.colorStops[stopNumber].b;
        a1 = this.colorStops[stopNumber].a;
        ratio0 = this.colorStops[stopNumber-1].ratio;
        ratio1 = this.colorStops[stopNumber].ratio;
            
        f = (ratio-ratio0)/(ratio1-ratio0);
        r = r0 + (r1 - r0)*f;
        g = g0 + (g1 - g0)*f;
        b = b0 + (b1 - b0)*f;
        a = a0 + (a1 - a0)*f;
        
        //set color as float values in buffer arrays
        this.buffer.r.push(r);
        this.buffer.g.push(g);
        this.buffer.b.push(b);
        this.buffer.a.push(a);
    }

    this.buffer.floyd( len, rectW );

    lng = len-4*rectW;
        
    //copy to pixel data
    for (i=0; i<lng; i += 4) {

        px = this.buffer.getPixel( i * 0.25 );
        pixelData[i] = px[0];
        pixelData[i+1] = px[1];
        pixelData[i+2] = px[2];
        pixelData[i+3] = px[3];

        console.log(pixelData[i+3])

    }
    
    ctx.putImageData(image,0,0);

    this.buffer.clear();

}




// RADIAL

Grad.Radial = function ( _x0,_y0,_rad0,_x1,_y1,_rad1 ) {

    Grad.Linear.call( this, _x0,_y0,_x1,_y1 );

	this.rad0 = _rad0;
	this.rad1 = _rad1;

}

Grad.Radial.prototype = Object.create( Grad.Linear.prototype );	
	
Grad.Radial.prototype.fillRect = function(ctx, rectX0, rectY0, rectW, rectH) {
	
	if (this.colorStops.length == 0) return;
	
    var px;
	var image = ctx.getImageData( rectX0, rectY0, rectW, rectH );
	var pixelData = image.data;
	var len = pixelData.length;
	var oldpixel, newpixel, nearestValue;
	var quantError;
	var x;
	var y;
	
	var vx = this.x1 - this.x0;
	var vy = this.y1 - this.y0;
	var vMagSquareRecip = 1/(vx*vx+vy*vy);
	var ratio;
	
	var r,g,b,a;
	var r0, g0, b0, r1, g1, b1, a0, a1;
	var ratio0,ratio1;
	var f;
	var stopNumber;
	var found;
	var q;

	
	var az,bz,cz,discrim;
	var dx,dy;
	
	var xDiff = this.x1 - this.x0;
	var yDiff = this.y1 - this.y0;
	var rDiff = this.rad1 - this.rad0;
	az = rDiff*rDiff - xDiff*xDiff - yDiff*yDiff;
	var rConst1 = 2*this.rad0*(this.rad1-this.rad0);
	var r0Square = this.rad0*this.rad0;

 	//first complete color stops with 0 and 1 ratios if not already present
	if (this.colorStops[0].ratio != 0) {
		var newStop = {	ratio:0,
						r: this.colorStops[0].r,
						g: this.colorStops[0].g,
						b: this.colorStops[0].b,
                        a: this.colorStops[0].a
                    }
		this.colorStops.splice(0,0,newStop);
	}
	if (this.colorStops[this.colorStops.length-1].ratio != 1) {
		var newStop = {	ratio:1,
						r: this.colorStops[this.colorStops.length-1].r,
						g: this.colorStops[this.colorStops.length-1].g,
						b: this.colorStops[this.colorStops.length-1].b,
                        a: this.colorStops[this.colorStops.length-1].a
                    }
		this.colorStops.push(newStop);
	}

    var lng = len/4;

	//create float valued gradient
	for (i = 0; i<lng; i++) {
		
		x = rectX0 + (i % rectW);
		y = rectY0 + Math.floor(i/rectW);
		
		dx = x - this.x0;
		dy = y - this.y0;
		bz = rConst1 + 2*(dx*xDiff + dy*yDiff);
		cz = r0Square - dx*dx - dy*dy;
		discrim = bz*bz-4*az*cz;
		
		if (discrim >= 0) {
			ratio = (-bz + Math.sqrt(discrim))/(2*az);
		
			if (ratio < 0) {
				ratio = 0;
			}
			else if (ratio > 1) {
				ratio = 1;
			}
			
			//find out what two stops this is between
			if (ratio == 1) {
				stopNumber = this.colorStops.length-1;
			}
			else {
				stopNumber = 0;
				found = false;
				while (!found) {
					found = (ratio < this.colorStops[stopNumber].ratio);
					if (!found) {
						stopNumber++;
					}
				}
			}
			
			//calculate color.
			r0 = this.colorStops[stopNumber-1].r;
			g0 = this.colorStops[stopNumber-1].g;
			b0 = this.colorStops[stopNumber-1].b;
            a0 = this.colorStops[stopNumber-1].a;
			r1 = this.colorStops[stopNumber].r;
			g1 = this.colorStops[stopNumber].g;
			b1 = this.colorStops[stopNumber].b;
            a1 = this.colorStops[stopNumber].a;
			ratio0 = this.colorStops[stopNumber-1].ratio;
			ratio1 = this.colorStops[stopNumber].ratio;
				
			f = ( ratio-ratio0 )/( ratio1-ratio0 );
			r = r0 + (r1 - r0)*f;
			g = g0 + (g1 - g0)*f;
			b = b0 + (b1 - b0)*f;
            a = a0 + (a1 - a0)*f;
		}
		
		else {
			r = r0;
			g = g0;
			b = b0;
            a = a0;
		}
		
		//set color as float values in buffer arrays
		this.buffer.r.push(r);
		this.buffer.g.push(g);
		this.buffer.b.push(b);
        this.buffer.a.push(a);
	}


    this.buffer.floyd( len, rectW );
		
	//copy to pixel data
	for (i=0; i<len; i += 4) {

        px = this.buffer.getPixel( i * 0.25 );
		pixelData[i] = px[0];
		pixelData[i+1] = px[1];
		pixelData[i+2] = px[2];
		pixelData[i+3] = px[3];

	}
	
	ctx.putImageData( image, rectX0, rectY0 );

    this.buffer.clear();
	
}
