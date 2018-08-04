//
//	Player
//

function Player() {

	this.clock = new THREE.Clock();

	this.renderer = new THREE.WebGLRenderer( { antialias:false } );

	this.renderer.setClearColor( 0x333333, 1 );

	this.renderer.setSize( window.innerWidth, window.innerHeight );

	this.camera = new THREE.PerspectiveCamera( 45, window.innerWidth / window.innerHeight, 1, 100000 );
	this.camera.position.set( 1000, 1000, 1000 );
	this.camera.lookAt( new THREE.Vector3() );

	this.controls = new THREE.OrbitControls( this.camera );

	this.scene = new THREE.Scene();

	this.container = document.createElement( 'div' );
	document.body.appendChild( this.container );
	this.container.appendChild( this.renderer.domElement );

	window.addEventListener( 'resize', this.resize.bind( this ), false );

	this.update();

}

Player.prototype.resize = function() {

	this.camera.aspect = window.innerWidth / window.innerHeight;
	this.camera.updateProjectionMatrix();

	this.renderer.setSize( window.innerWidth, window.innerHeight );

}

Player.prototype.unload = function() {

	if (this.loader) {

		this.loader.domain.dispose();

	}

	return this;

}

Player.prototype.load = function( data, origin ) {

	origin = origin !== undefined ? origin : true;

	this.unload();

	this.loader = new THREE.SEA3D( {
		//autoPlay : true,
		container : this.scene
	});

	this.loader.onComplete = function(e) {

		if (origin) this.origin = this.loader.file;

	}.bind( this );

	this.loader.load( data );

	return this;

}

Player.prototype.update = function() {

	requestAnimationFrame( this.update.bind( this ) );

	var delta = this.clock.getDelta();

	// Update sea3d Animations
	THREE.SEA3D.AnimationHandler.update( delta );

	this.renderer.render( this.scene, this.camera );

}

//
//	Draco
//

function Draco() {

	this.encoderModule = DracoEncoderModule();

}

Draco.TYPE = "sdrc";

Draco.prototype.fromSEA3DGeometry = function( geo ) {

	var module = this.encoderModule;

	var encoder = new module.Encoder();

	var compressionLevel = 10 - builder.settings.compressionLevel;
	encoder.SetSpeedOptions(compressionLevel, compressionLevel);

	var mesh = new module.Mesh(),
		meshBuilder = new module.MeshBuilder();

	var numFaces = geo.indexes.length / 3,
		numVertex = geo.numVertex;

	const IS_BIG = 1, NORMAL = 4, UV = 32, JOINTS = 64, GROUP = 1024, TRIANGLE_SOUP = 2048;

	var stream = new SEA3D.Stream(),
		isBig = numVertex >= THREE.SEA3D.Exporter.BIG_GEOMETRY,
		flags = 0,
		index = 0,
		id, i;


	if (isBig) flags |= IS_BIG;
	if (geo.groups.length > 1) flags |= GROUP;

	stream.writeVInt = isBig ? stream.writeUInt : stream.writeUShort;

	// POSITION

	id = index++;

	meshBuilder.AddFloatAttribute(mesh, id, numVertex, 3, geo.vertex);
	encoder.SetAttributeQuantization(id, builder.settings.quantBitsPosition);

	// NORMAL

	if ( geo.normal ) {

		flags |= NORMAL;

		id = index++;

		meshBuilder.AddFloatAttribute(mesh, id, numVertex, 3, geo.normal);
		encoder.SetAttributeQuantization(id, builder.settings.quantBitsNormal);

	}

	// UV

	if ( geo.uv ) {

		flags |= UV;

		for(i = 0; i < geo.uv.length; i++) {

			id = index++;

			meshBuilder.AddFloatAttribute(mesh, id, numVertex, 2, geo.uv[i]);
			encoder.SetAttributeQuantization(id, builder.settings.quantBitsTexCoord);

		}

	}

	if ( geo.joint ) {

		flags |= JOINTS;

		id = index++;

		meshBuilder.AddUInt16Attribute(mesh, id, numVertex, geo.jointPerVertex, geo.joint);
		encoder.SetAttributeQuantization(id, 10);

		id = index++;

		meshBuilder.AddFloatAttribute(mesh, id, numVertex, geo.jointPerVertex, geo.weight);
		encoder.SetAttributeQuantization(id, 8);

	}

	// FACES

	meshBuilder.AddFacesToMesh(mesh, numFaces, geo.indexes);

	// BUILD DRACO

	var encodedData = new module.DracoInt8Array(),
		encodedLen = encoder.EncodeMeshToDracoBuffer(mesh, encodedData),
		output = new Int8Array( new ArrayBuffer(encodedLen) );

	for (i = 0; i < encodedLen; ++i) {

		output[i] = encodedData.GetValue(i);

	}

	// BUILD

	stream.writeUShort( flags );

	if (flags & UV) {

		stream.writeByte( geo.uv.length );

	}

	if (flags & GROUP) {

		data.writeByte( geo.groups.length );

		for(i = 0; i < geo.groups.length; i++) {

			data.writeVInt( geo.groups[i].count );

		}

	}

	stream.writeBytes( output.buffer );

	// RELEASE

	module.destroy(encodedData);
	module.destroy(mesh);
	module.destroy(meshBuilder);
	module.destroy(encoder);

	return stream;

}

//
//	Builder
//

function Builder() {

	this.settings = {
		losslessCompression:true,
		losslessCompressionLevel: 10,
		lossyCompression:true,
		lossyCompressionLevel: 10,
		quantBitsPosition: 10,
		quantBitsNormal: 10,
		quantBitsTexCoord: 8
	};

	THREE.SEA3D.Exporter.setCompressionAlgorithm( Builder.LZMA, function( buffer, callback ) {

		// 1 or 9 level

		var compressionLevel = Math.min(Math.max(this.settings.losslessCompressionLevel, 1), 9);

		var bytes = LZMA.compress( new Uint8Array( buffer ), compressionLevel);

		callback( new Uint8Array( bytes ).buffer );

	}.bind( this ) );

}

Builder.LZMA = 2;

Builder.prototype.createBuilder = function() {

	var context = {};

	if (this.settings.losslessCompression) {

		context.compressionAlgorithm = Builder.LZMA;

	}

	var builder = new THREE.SEA3D.Exporter( context );

	gui.setProgress( 0 ).setStatus("Building SEA3D File...").setDownload();

	builder.onProgress = function( progress, step ) {

		gui.setProgress( Math.round( progress * 100 ),  );

	}

	builder.onGeometry = this.onGeometry.bind( this );

	return builder;

}

Builder.prototype.onGeometry = function( geo, drop ) {

	drop.type = Draco.TYPE;

	// For Optimization: Ignore LZMA compression
	drop.compressed = false;

	return draco.fromSEA3DGeometry( geo );

}

Builder.prototype.buildFromFile = function( file ) {

	var builder = this.createBuilder();

	builder.sign = file.sign;

	for(var i = 0; i < file.objects.length; i++) {

		var obj = file.objects[i],
			drop = builder.regDrop( String( i ) );

		drop.type = obj.type;
		drop.name = obj.name;
		drop.data = obj.data;

		if ( obj.type === SEA3D.Geometry.prototype.type ) {

			drop.data = this.onGeometry( obj, drop );
		}

		builder.addDrop( drop );

	}

	builder.write(function(data) {

		this.buffer = data.buffer;

		player.load( this.buffer, false );

		gui.setStatus("SEA3D File Generated").setProgress().setDownload( this.buffer );

	}.bind( this ));

}

Builder.prototype.build = function() {

	var builder = this.createBuilder();




}
//
//	GUI
//

function GUI() {

	this.gui = new UIL.Gui( { css:'top: 0px; left: calc( 100% - 260px );', w: 260, close: false, bg:'rgba( 23, 23, 23, 0.5 )' } );

	this.gui.add('title',  { name:'SEA3D Format'});
	this.gui.add( 'fps', { res:70 } ).show();
	this.gui.add('button', { name:'LOAD', fontColor:'#D4B87B', height:30, drag:true, p:0 }).onChange( function( response, fname, type ) {

		type = type.toLowerCase();

		switch(type) {

			case 'sea':

				player.load( response );

				break;

		}

	} );

	// FILE

	this.guiMain = this.gui.add('group', { name:'File', fontColor:'#D4B87B' });

	this.buildingDescription = this.guiMain.add('title', {});

	this.progress = this.guiMain.add('slide',  { min:0, max:100, value:0, p:0, fontColor:'#B0CC99' });
	this.progress.mousedown = this.progress.mousemove = function() {};
	this.progress.c[0].style['pointer-events'] = 'none';
	this.progress.c[1].style.display = 'none';

	this.guiMain.add('button', { name:'Build', fontColor:'#FFF', p:0 }).onChange( function(n){

		builder.buildFromFile( player.origin );

	} );

	this.download = this.guiMain.add('button', { name:'Download', fontColor:'#FF8800', p:0 });
	this.download.mousedown = this.download.mousemove = this.download.dragover = this.download.dragend = function() {};

	this.download.c[0].style['pointer-events'] = 'auto';

	this.downloadLink = document.createElement("a");

	var downloadLinkParent = this.download.c[0].parentNode;
	downloadLinkParent.appendChild( this.downloadLink );

	this.downloadLink.appendChild( this.download.c[0] );

	this.guiMain.open();

	// LZMA

	this.guiLzma = this.gui.add('group', { name:'Lossless Compression' });

	this.guiLzma.add('bool', { name:'Enabled', value: true }).onChange( function(n){



	} );

	this.guiLzma.add('list', { name:'Algorithm', list: [ 'LZMA' ] } );

	this.guiLzma.add('slide', { name:'Level', min:1, max:10, value:builder.settings.losslessCompressionLevel, step:1, mode:1 }).onChange( function(n){



	} );

	this.guiLzma.open();

	// DRACO

	this.guiDraco = this.gui.add('group', { name:'Lossy Compression' });

	this.guiDraco.add('bool', { name:'Enabled', value: builder.settings.lossyCompression }).onChange( function(v){

		builder.settings.lossyCompression = v;

	} );

	this.guiDraco.add('list', { name:'Algorithm', list: [ 'Draco' ] } );

	this.guiDraco.add('slide', { name:'Level', min:0, max:10, value:builder.settings.lossyCompressionLevel, step:1, mode:1 }).onChange( function(v){

		builder.settings.lossyCompressionLevel = v;

	} );

	this.guiDraco.add('slide', { name:'Q. Position', min:3, max:15, value:builder.settings.quantBitsPosition, step:1, mode:1 }).onChange( function(v){

		builder.settings.quantBitsPosition = v;

	} );

	this.guiDraco.add('slide', { name:'Q. Normal', min:3, max:15, value:builder.settings.quantBitsNormal, step:1, mode:1 }).onChange( function(v){

		builder.settings.quantBitsNormal = v;

	} );

	this.guiDraco.add('slide', { name:'Q. UV', min:3, max:15, value:builder.settings.quantBitsTexCoord, step:1, mode:1 }).onChange( function(v){

		builder.settings.quantBitsTexCoord = v;

	} );

	this.guiDraco.open();

	// INIT

	this.setStatus();
	this.setDownload();
	this.setProgress();

}

GUI.prototype.setStatus = function ( status ) {

	return this.setDescription( "Status: " + ( status || "Idle") )

}

GUI.prototype.setDescription = function ( description ) {

	this.buildingDescription.c[1].innerText = description || "";

	return this;

}

GUI.prototype.setDownload = function ( buffer, name ) {

	if ( buffer ) {

		var file = new Blob([buffer], {type: "sea"});

		this.downloadLink.href = URL.createObjectURL(file);
		this.downloadLink.download = name || "file.sea";
		this.downloadLink.onclick = null;

	} else {

		this.downloadLink.href = "javascript:void(0)";
		this.downloadLink.onclick = function() {

			alert("You need to build your SEA3D file before downloading.")

		}

	}

	return this;

}

GUI.prototype.setProgress = function ( val ) {

	var visible = isFinite( val );

	if (visible) {

		this.progress.value = val;
		this.progress.update( true );

	}

	this.progress.c[2].style.display =
		this.progress.c[4].style.display =
		this.progress.c[5].style.display = visible ? 'block' : 'none';

	return this;

}

//
//	Main
//

var player = new Player();
var draco = new Draco();
var builder = new Builder();
var gui = new GUI();

player.load("../Examples/Programmer/Three.JS/assets/mascot.tjs.sea");