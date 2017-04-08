//
//	Extension
//

SEA3D.Math.lerp1x = function ( val, tar, t ) {

	val[ 0 ] += ( tar[ 0 ] - val[ 0 ] ) * t;

};

SEA3D.Math.lerp3x = function ( val, tar, t ) {

	val[ 0 ] += ( tar[ 0 ] - val[ 0 ] ) * t;
	val[ 1 ] += ( tar[ 1 ] - val[ 1 ] ) * t;
	val[ 2 ] += ( tar[ 2 ] - val[ 2 ] ) * t;

};

SEA3D.Math.lerpAng1x = function ( val, tar, t ) {

	val[ 0 ] = SEA3D.Math.lerpAngle( val[ 0 ], tar[ 0 ], t );

};

SEA3D.Math.lerpColor1x = function ( val, tar, t ) {

	val[ 0 ] = SEA3D.Math.lerpColor( val[ 0 ], tar[ 0 ], t );

};

SEA3D.Math.lerpQuat4x = function ( val, tar, t ) {

	var x1 = val[ 0 ],
		y1 = val[ 1 ],
		z1 = val[ 2 ],
		w1 = val[ 3 ];

	var x2 = tar[ 0 ],
		y2 = tar[ 1 ],
		z2 = tar[ 2 ],
		w2 = tar[ 3 ];

	var x, y, z, w, l;

	// shortest direction
	if ( x1 * x2 + y1 * y2 + z1 * z2 + w1 * w2 < 0 ) {

		x2 = - x2;
		y2 = - y2;
		z2 = - z2;
		w2 = - w2;

	}

	x = x1 + t * ( x2 - x1 );
	y = y1 + t * ( y2 - y1 );
	z = z1 + t * ( z2 - z1 );
	w = w1 + t * ( w2 - w1 );

	l = 1.0 / Math.sqrt( w * w + x * x + y * y + z * z );
	val[ 0 ] = x * l;
	val[ 1 ] = y * l;
	val[ 2 ] = z * l;
	val[ 3 ] = w * l;

};

//
//	Blend Method
//

SEA3D.AnimationBlendMethod = {
	LINEAR : 'linear',
	EASING : 'easing'
};

SEA3D.Animation.DefaultLerpFuncs = [
	SEA3D.Math.lerp3x, // POSITION
	SEA3D.Math.lerpQuat4x, // ROTATION
	SEA3D.Math.lerp3x, // SCALE
	SEA3D.Math.lerpColor1x, // COLOR
	SEA3D.Math.lerp1x, // MULTIPLIER
	SEA3D.Math.lerp1x, // ATTENUATION_START
	SEA3D.Math.lerp1x, // ATTENUATION_END
	SEA3D.Math.lerp1x, // FOV
	SEA3D.Math.lerp1x, // OFFSET_U
	SEA3D.Math.lerp1x, // OFFSET_V
	SEA3D.Math.lerp1x, // SCALE_U
	SEA3D.Math.lerp1x, // SCALE_V
	SEA3D.Math.lerpAng1x, // ANGLE
	SEA3D.Math.lerp1x, // ALPHA
	SEA3D.Math.lerp1x // VOLUME
];

//
//	AnimationFrame
//

SEA3D.AnimationFrame = function() {

	this.data = [ 0, 0, 0, 0 ];

};

SEA3D.AnimationFrame.prototype.toVector = function() {

	return { x: this.data[ 0 ], y: this.data[ 1 ], z: this.data[ 2 ], w: this.data[ 3 ] };

};

SEA3D.AnimationFrame.prototype.toAngles = function( d ) {

	var x = this.data[ 0 ],
		y = this.data[ 1 ],
		z = this.data[ 2 ],
		w = this.data[ 3 ];

	var a = 2 * ( w * y - z * x );

	if ( a < - 1 ) a = - 1;
	else if ( a > 1 ) a = 1;

	return {
		x : Math.atan2( 2 * ( w * x + y * z ), 1 - 2 * ( x * x + y * y ) ) * d,
		y : Math.asin( a ) * d,
		z : Math.atan2( 2 * ( w * z + x * y ), 1 - 2 * ( y * y + z * z ) ) * d
	}

};

SEA3D.AnimationFrame.prototype.toEuler = function() {

	return this.toAngles( SEA3D.Math.RAD_TO_DEG );

};

SEA3D.AnimationFrame.prototype.toRadians = function() {

	return this.toAngles( 1 );

};

SEA3D.AnimationFrame.prototype.setX = function( val ) {

	this.data[ 0 ] = val;

};

SEA3D.AnimationFrame.prototype.getX = function() {

	return this.data[ 0 ];

};

SEA3D.AnimationFrame.prototype.setY = function( val ) {

	this.data[ 1 ] = val;

};

SEA3D.AnimationFrame.prototype.getY = function() {

	return this.data[ 1 ];

};

SEA3D.AnimationFrame.prototype.setZ = function( val ) {

	this.data[ 2 ] = val;

};

SEA3D.AnimationFrame.prototype.getZ = function() {

	return this.data[ 2 ];

};

SEA3D.AnimationFrame.prototype.setW = function( val ) {

	this.data[ 3 ] = val;

};

SEA3D.AnimationFrame.prototype.getW = function() {

	return this.data[ 3 ];

};

//
//	AnimationData
//

SEA3D.AnimationData = function( kind, dataType, data, offset ) {

	this.kind = kind;
	this.type = dataType;
	this.blockLength = SEA3D.Stream.sizeOf( dataType );
	this.data = data;
	this.offset = offset == undefined ? 0 : offset;

	switch ( this.blockLength )
	{
		case 1: this.getData = this.getData1x; break;
		case 2: this.getData = this.getData2x; break;
		case 3: this.getData = this.getData3x; break;
		case 4: this.getData = this.getData4x; break;
	}

};

SEA3D.AnimationData.prototype.getData1x = function( frame, data ) {

	frame = this.offset + frame * this.blockLength;

	data[ 0 ] = this.data[ frame ];

};

SEA3D.AnimationData.prototype.getData2x = function( frame, data ) {

	frame = this.offset + frame * this.blockLength;

	data[ 0 ] = this.data[ frame ];
	data[ 1 ] = this.data[ frame + 1 ];

};

SEA3D.AnimationData.prototype.getData3x = function( frame, data ) {

	frame = this.offset + frame * this.blockLength;

	data[ 0 ] = this.data[ frame ];
	data[ 1 ] = this.data[ frame + 1 ];
	data[ 2 ] = this.data[ frame + 2 ];

};

SEA3D.AnimationData.prototype.getData4x = function( frame, data ) {

	frame = this.offset + frame * this.blockLength;

	data[ 0 ] = this.data[ frame ];
	data[ 1 ] = this.data[ frame + 1 ];
	data[ 2 ] = this.data[ frame + 2 ];
	data[ 3 ] = this.data[ frame + 3 ];

};

//
//	AnimationNode
//

SEA3D.AnimationNode = function( name, frameRate, numFrames, repeat, intrpl ) {

	this.name = name;
	this.frameRate = frameRate;
	this.frameMill = 1000 / frameRate;
	this.numFrames = numFrames;
	this.length = numFrames - 1;
	this.time = 0;
	this.duration = this.length * this.frameMill;
	this.repeat = repeat;
	this.intrpl = intrpl;
	this.invalidState = true;
	this.dataList = [];
	this.dataListId = {};
	this.buffer = new SEA3D.AnimationFrame();
	this.percent = 0;
	this.prevFrame = 0;
	this.nextFrame = 0;
	this.frame = 0;

};

SEA3D.AnimationNode.prototype.setTime = function( value ) {

	this.frame = this.validFrame( value / this.frameMill );
	this.time = this.frame * this.frameRate;
	this.invalidState = true;

};

SEA3D.AnimationNode.prototype.getTime = function() {

	return this.time;

};

SEA3D.AnimationNode.prototype.setFrame = function( value ) {

	this.setTime( value * this.frameMill );

};

SEA3D.AnimationNode.prototype.getRealFrame = function() {

	return Math.floor( this.frame );

};

SEA3D.AnimationNode.prototype.getFrame = function() {

	return this.frame;

};

SEA3D.AnimationNode.prototype.setPosition = function( value ) {

	this.setFrame( value * ( this.numFrames - 1 ) );

};

SEA3D.AnimationNode.prototype.getPosition = function() {

	return this.frame / ( this.numFrames - 1 );

};

SEA3D.AnimationNode.prototype.validFrame = function( value ) {

	var inverse = value < 0;

	if ( inverse ) value = - value;

	if ( value > this.length ) {

		value = this.repeat ? value % this.length : this.length;

	}

	if ( inverse ) value = this.length - value;

	return value;

};

SEA3D.AnimationNode.prototype.addData = function( animationData ) {

	this.dataListId[ animationData.kind ] = animationData;
	this.dataList[ this.dataList.length ] = animationData;

};

SEA3D.AnimationNode.prototype.removeData = function( animationData ) {

	delete this.dataListId[ animationData.kind ];
	this.dataList.splice( this.dataList.indexOf( animationData ), 1 );

};

SEA3D.AnimationNode.prototype.getDataByKind = function( kind ) {

	return this.dataListId[ kind ];

};

SEA3D.AnimationNode.prototype.getFrameAt = function( frame, id ) {

	this.dataListId[ id ].getFrameData( frame, this.buffer.data );
	return this.buffer;

};

SEA3D.AnimationNode.prototype.getFrame = function( id ) {

	this.dataListId[ id ].getFrameData( this.getRealFrame(), this.buffer.data );
	return this.buffer;

};

SEA3D.AnimationNode.prototype.getInterpolationFrame = function( animationData, iFunc ) {

	if ( this.numFrames == 0 ) return this.buffer;

	if ( this.invalidState ) {

		this.prevFrame = this.getRealFrame();
		this.nextFrame = this.validFrame( this.prevFrame + 1 );
		this.percent = this.frame - this.prevFrame;
		this.invalidState = false;

	}

	animationData.getData( this.prevFrame, this.buffer.data );

	if ( this.percent > 0 ) {

		animationData.getData( this.nextFrame, SEA3D.AnimationNode.FRAME_BUFFER );

		// interpolation function
		iFunc( this.buffer.data, SEA3D.AnimationNode.FRAME_BUFFER, this.percent );

	}

	return this.buffer;

};

SEA3D.AnimationNode.FRAME_BUFFER = [ 0, 0, 0, 0 ];

//
//	AnimationSet
//

SEA3D.AnimationSet = function() {

	this.animations = [];
	this.dataCount = - 1;

};

SEA3D.AnimationSet.prototype.addAnimation = function( node ) {

	if ( this.dataCount == - 1 ) this.dataCount = node.dataList.length;

	this.animations[ node.name ] = node;
	this.animations.push( node );

};

SEA3D.AnimationSet.prototype.getAnimationByName = function( name ) {

	return this.animations[ name ];

};

//
//	AnimationState
//

SEA3D.AnimationState = function( node ) {

	this.node = node;
	this.offset = 0;
	this.weight = 0;
	this.time = 0;

};

SEA3D.AnimationState.prototype.setTime = function( val ) {

	this.node.time = this.time = val;

};

SEA3D.AnimationState.prototype.getTime = function() {

	return this.time;

};

SEA3D.AnimationState.prototype.setFrame = function( val ) {

	this.node.setFrame( val );

	this.time = this.node.time;

};

SEA3D.AnimationState.prototype.getFrame = function() {

	this.update();

	return this.node.getFrame();

};

SEA3D.AnimationState.prototype.setPosition = function( val ) {

	this.node.setPosition( val );

	this.time = this.node.time;

};

SEA3D.AnimationState.prototype.getPosition = function() {

	this.update();

	return this.node.getPosition();

};

SEA3D.AnimationState.prototype.update = function() {

	if ( this.node.time != this.time )
		this.node.setTime( this.time );

};

//
//	Animation Handler
//

SEA3D.AnimationHandler = function( animationSet ) {

	this.animationSet = animationSet;
	this.states = SEA3D.AnimationHandler.stateFromAnimations( animationSet.animations );
	this.timeScale = 1;
	this.time = 0;
	this.numAnimation = animationSet.animations.length;
	this.relative = false;
	this.playing = false;
	this.delta = 0;
	this.easeSpeed = 2;
	this.crossfade = 0;
	this.updateAllStates = false;
	this.blendMethod = SEA3D.AnimationBlendMethod.LINEAR;

};

SEA3D.AnimationHandler.prototype.update = function( delta ) {

	this.delta = delta;
	this.time += delta * this.timeScale;

	this.updateState();
	this.updateAnimation();

};

SEA3D.AnimationHandler.prototype.updateState = function() {

	var i, l, state;

	this.currentState.node.setTime( this.time - this.currentState.offset );

	if ( this.currentState.weight < 1 && this.crossfade > 0 ) {

		var delta = Math.abs( this.delta ) / ( this.crossfade * 1000 );
		var weight = 1;

		if ( this.blendMethod === SEA3D.AnimationBlendMethod.EASING ) {

			delta *= this.easeSpeed;

		}

		for ( i = 0, l = this.states.length; i < l; ++ i ) {

			state = this.states[ i ];

			if ( state.weight > 0 && state !== this.currentState ) {

				if ( this.blendMethod === SEA3D.AnimationBlendMethod.LINEAR ) {

					state.weight -= delta;

				}
				else if ( this.blendMethod === SEA3D.AnimationBlendMethod.EASING ) {

					state.weight -= state.weight * delta;

				}

				if ( state.weight < 0 ) state.weight = 0;

				weight -= state.weight;

				if ( this.updateAllStates ) {

					state.node.setTime( this.time - state.offset );

				}

			}

		}

		if ( weight < 0 ) weight = 0;

		this.currentState.weight = weight;

	} else {

		for ( i = 0; i < this.states.length; ++ i ) {

			state = this.states[ i ];

			if ( state === this.currentState ) state.weight = 1;
			else {

				state.weight = 0;

				if ( this.updateAllStates ) {

					state.node.setTime( this.time );

				}

			}

		}

	}

};

SEA3D.AnimationHandler.prototype.updateAnimation = function() {

	var dataCount = this.animationSet.dataCount;
	var nodes = this.animationSet.animations;
	var currentNode = this.currentState.node;

	for ( var i = 0; i < dataCount; i ++ ) {

		for ( var n = 0; n < nodes.length; n ++ ) {

			var node = nodes[ n ],
				state = this.states[ n ],
				data = node.dataList[ i ],
				iFunc = SEA3D.Animation.DefaultLerpFuncs[ data.kind ],
				frame;

			if ( n == 0 ) {

				frame = currentNode.getInterpolationFrame( currentNode.dataList[ i ], iFunc );

				if ( ! currentNode.repeat && currentNode.frame == currentNode.numFrames - 1 ) {

					if ( this.onComplete )
						this.onComplete( this );

				}

			}

			if ( node != currentNode ) {

				if ( state.weight > 0 ) {

					iFunc(
						frame.data,
						node.getInterpolationFrame( data, iFunc ).data,
						state.weight
					);

				}

			}

			if ( this.updateAnimationFrame ) {

				this.updateAnimationFrame( frame, data.kind );

			}

		}

	}

};

SEA3D.AnimationHandler.prototype.getStateByName = function( name ) {

	return this.states[ name ];

};

SEA3D.AnimationHandler.prototype.getStateNameByIndex = function( index ) {

	return this.animationSet.animations[ index ].name;

};

SEA3D.AnimationHandler.prototype.play = function( name, crossfade, offset ) {

	this.currentState = this.getStateByName( name );

	if ( ! this.currentState )
		throw new Error( 'Animation "' + name + '" not found.' );

	this.crossfade = crossfade;
	this.currentState.offset = this.time;

	if ( offset !== undefined ) {

		this.currentState.time = offset;

	}

	if ( ! this.playing ) {

		// Add in animation collector

		SEA3D.AnimationHandler.add( this );

		this.playing = true;

	}

};

SEA3D.AnimationHandler.prototype.resume = function() {

	if ( ! this.playing ) {

		SEA3D.AnimationHandler.add( this );
		this.playing = true;

	}

};

SEA3D.AnimationHandler.prototype.pause = function() {

	if ( this.playing ) {

		SEA3D.AnimationHandler.remove( this );
		this.playing = false;

	}

};

SEA3D.AnimationHandler.prototype.stop = function() {

	this.time = 0;

	this.pause();

};

SEA3D.AnimationHandler.prototype.setRelative = function( val ) {

	this.relative = val;

};

SEA3D.AnimationHandler.prototype.getRelative = function() {

	return this.relative;

};

//
//	Manager
//

SEA3D.AnimationHandler.add = function( animation ) {

	SEA3D.AnimationHandler.animations.push( animation );

};

SEA3D.AnimationHandler.remove = function( animation ) {

	SEA3D.AnimationHandler.animations.splice( SEA3D.AnimationHandler.animations.indexOf( animation ), 1 );

};

SEA3D.AnimationHandler.stateFromAnimations = function( anms ) {

	var states = [];
	for ( var i = 0; i < anms.length; i ++ ) {

		states[ anms[ i ].name ] = states[ i ] = new SEA3D.AnimationState( anms[ i ] );

	}
	return states;

};

SEA3D.AnimationHandler.update = function( delta ) {

	for ( var i = 0, len = SEA3D.AnimationHandler.animations.length; i < len; i ++ ) {

		SEA3D.AnimationHandler.animations[ i ].update( delta * 1000 );

	}

};

SEA3D.AnimationHandler.setTime = function( time ) {

	for ( var i = 0, len = SEA3D.AnimationHandler.animations.length; i < len; i ++ ) {

		SEA3D.AnimationHandler.animations[ i ].time = time;

	}

};

SEA3D.AnimationHandler.stop = function() {

	while ( SEA3D.AnimationHandler.animations.length ) {

		SEA3D.AnimationHandler.animations[ 0 ].stop();

	}

};

SEA3D.AnimationHandler.animations = [];
