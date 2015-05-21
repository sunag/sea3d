SEA3D.Animator = function(mesh, name){
    this.mesh = mesh;
    this.name = name;
    this.current = "";//{};
    //this.current.name = "";
    //this.animation = [];

    this.animations = {};
    this.weightSchedule = [];
    this.warpSchedule = [];
}

SEA3D.Animator.prototype = {
    constructor: SEA3D.Animator,
    addAnimations:function(a){
        var j = a[0].length;
        while(j--){
            this.add( a[0][j], a[1][j] );
        }
    },
    add:function(name, loop){
        this.animations[ name ] = new THREE.Animation( this.mesh, this.name+"/"+name );
        this.animations[ name ].loop = loop || false;
    },
    play:function(name, weight){
            this.animations[ name ].play( 0, weight );
            this.current = name;
    },
    crossfade:function( fromAnimName, toAnimName, duration ) {
        var fromAnim = this.animations[ fromAnimName ];
        var toAnim = this.animations[ toAnimName ];
        fromAnim.play( 0, 1 );
        toAnim.play( 0, 0 );
        this.weightSchedule.push( { anim:fromAnim, startWeight:1, endWeight:0, timeElapsed:0, duration:duration } );
        this.weightSchedule.push( { anim:toAnim, startWeight:0, endWeight:1, timeElapsed:0, duration:duration } );

    },
    warp:function( fromAnimName, toAnimName, duration ) {
        var fromAnim = this.animations[ fromAnimName ];
        var toAnim = this.animations[ toAnimName ];
        fromAnim.play( 0, 1 );
        toAnim.play( 0, 0 );
        this.warpSchedule.push( { from:fromAnim, to:toAnim, timeElapsed: 0, duration: duration } );
    },
    applyWeight:function(animName, weight) {
        this.animations[ animName ].weight = weight;
    },
    update:function( dt ) {
        for ( var i = this.weightSchedule.length - 1; i >= 0; --i ) {
            var data = this.weightSchedule[ i ];
            data.timeElapsed += dt;
            // If the transition is complete, remove it from the schedule
            if ( data.timeElapsed > data.duration ) {
                data.anim.weight = data.endWeight;
                this.weightSchedule.splice( i, 1 );
                // If we've faded out completely, stop the animation
                if ( data.anim.weight == 0 ) data.anim.stop( 0 );
            } else {
                // interpolate the weight for the current time
                data.anim.weight = data.startWeight + (data.endWeight - data.startWeight) * data.timeElapsed / data.duration;
            }
        }
        this.updateWarps( dt );
    },
    updateWarps:function( dt ) {

        // Warping modifies the time scale over time to make 2 animations of different
        // lengths match. This is useful for smoothing out transitions that get out of
        // phase such as between a walk and run cycle

        for ( var i = this.warpSchedule.length - 1; i >= 0; --i ) {

            var data = this.warpSchedule[ i ];
            data.timeElapsed += dt;
            if ( data.timeElapsed > data.duration ) {

                data.to.weight = 1;
                data.to.timeScale = 1;
                data.from.weight = 0;
                data.from.timeScale = 1;
                data.from.stop( 0 );

                this.warpSchedule.splice( i, 1 );

            } else {

                var alpha = data.timeElapsed / data.duration;

                var fromLength = data.from.data.length;
                var toLength = data.to.data.length;

                var fromToRatio = fromLength / toLength;
                var toFromRatio = toLength / fromLength;

                // scale from each time proportionally to the other animation
                data.from.timeScale = ( 1 - alpha ) + fromToRatio * alpha;
                data.to.timeScale = alpha + toFromRatio * ( 1 - alpha );

                data.from.weight = 1 - alpha;
                data.to.weight = alpha;
            }
        }
    },
    pauseAll:function() {
        for ( var a in this.animations ) {
            if ( this.animations[ a ].isPlaying ) this.animations[ a ].pause();
        }
    },
    unPauseAll:function() {
        for ( var a in this.animations ) {
            if ( this.animations[ a ].isPlaying && this.animations[ a ].isPaused ) this.animations[ a ].pause();
        }
    },
    stopAll:function() {
        for ( var a in this.animations ) {
            if ( this.animations[ a ].isPlaying ) this.animations[ a ].stop(0);
            this.animations[ a ].weight = 0;
        }
        this.weightSchedule.length = 0;
        this.warpSchedule.length = 0;
    },

    playFrame:function(name, n){
       /* for(var i=0, l=this.animation.length; i<l; i++ ){
                if(this.animation[i].name === name){
                    this.animation[i].play( n );
                    this.animation[i].stop();
                } 
            }*/
      //  this.current.play(n);
       // this.current.pause();
    },
    pause:function(){
        this.current.pause();
    },
    stop:function(){

         this.animations[ this.current ].stop();
       /* if(this.current.name!==""){
         this.current.stop();
         this.current = {};
         this.current.name = "";
         
     }*/
    },
    
    clear:function(){
        //this.current.stop();
        /*for(var i=0, l=this.animation.length; i<l; i++ ){
            this.animation[i].reset();
        }*/

        this.animation.length = 0;
        this.current ="";// null;
        this.mesh = null;
        this.name = "";
    }
}