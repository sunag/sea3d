var seaPlayer = ( function () {
    
    'use strict';

    var loader = null;
    var scene = null;
    var clearCallback = null;
    var completeCallback = null;

    seaPlayer = {

        init: function ( Scene, CompleteCallback, ClearCallback ) {

            scene = Scene;
            completeCallback = CompleteCallback || function(){};
            clearCallback = ClearCallback || function(){};      

        },

        load: function ( url ) {

            clearCallback();

            loader = new THREE.SEA3D( {
                autoPlay : true, // Auto play animations
                container : scene // Container to add models
            });

            loader.onComplete = completeCallback;
            loader.load( url );

        },

        read: function ( response, fname, type ) {

            if( type !== 'sea' ) return;//{ info.innerHTML = "is not SEA3D file ?!"; return; }

            clearCallback();

            loader = new THREE.SEA3D( {
                autoPlay : true, // Auto play animations
                container : scene // Container to add models
            });

            loader.onComplete = completeCallback;
            loader.load();
            loader.file.read( response );

        },

        getLoader: function (){
            return loader;
        } 





    }

    return seaPlayer;

})();





/*


'use strict';

var seaPlayer = {
    loader:null,

    loadSea:function () {

        this.loader = new THREE.SEA3D( {
            autoPlay : true, // Auto play animations
            container : scene // Container to add models
        });

        this.loader.onComplete = seaEndLoad;
        this.loader.load( url );

    }

}*/