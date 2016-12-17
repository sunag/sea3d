-- SEA3D Exporter (Sunag Entertainment Assets 3D)
-- Copyright (C) Sunag Entertainment

-- SEA3D - A file format for games
-- https://github.com/sunag/sea3d

-- developed by Jean Carlo Deconto (Brazil)
-- never give up without trying...

fileIn "SEA3D.inc" 
if (LoadSEADLL() == false) then exit

--
--	Global
--

global
-- Extensions (Max 4chars ASCII Compatible 32bit)
	EXT_INFO = ".info",
	EXT_GEOMETRY = ".geo",
	EXT_GEOMETRY_DELTA = ".geDL",
	EXT_SCENE_OBJECT = ".o3d",
	EXT_MESH = ".m3d",
	EXT_SPRITE3D = ".m2d",	
	--EXT_CONTAINER3D = ".c3d",	
	EXT_JOINT_OBJECT = ".jnt",	
	EXT_ANIMATION = ".anm", -- Generic SEA3D Animation (Lights, Meshes, Helpers, Textures and others)	
	EXT_ANIMATION_UVW = ".auvw",
	EXT_GIF = ".gif",
	EXT_PNG = ".png",
	EXT_JPEG = ".jpg",	
	EXT_JPEG_XR = ".wdp",
	EXT_DDS = ".dds",		
	EXT_DDS_CUBE = ".ddsc",
	EXT_ATF = ".atf",	
	EXT_ATF_CUBE = ".atfc",	
	EXT_TEXTURE = ".tex",		
	EXT_MORPH = ".mph",
	EXT_MORPH_ANIMATION = ".mpha",
	EXT_VERTEX_COLOR = ".vtc", 
	EXT_VERTEX_ANIMATION = ".vtxa",
	EXT_POINT_LIGHT = ".plht",
	EXT_DIRECTIONAL_LIGHT = ".dlht",
	EXT_SKELETON = ".skl",	
	EXT_SKELETON_LOCAL = ".sklq",	
	EXT_SKELETON_ANIMATION = ".skla",	
	EXT_MATERIAL = ".mat",
	EXT_COMPOSITE = ".ctex",
	EXT_CUBE_MAPPING = ".cmap",
	EXT_SINGLE_CUBE_MAPPING = ".smap",
	EXT_PERSPECTIVE_CAMERA = ".cam",
	EXT_PROPERTIES = ".prop",	
	EXT_OGG = ".ogg",
	EXT_MP3 = ".mp3",	
	EXT_SOUND_POINT = ".sp",
	EXT_SOUND_MIXER = ".smix",
	--EXT_DATA = ".data", -- CUSTOM BYTEARRAY	
	--EXT_SCRIPT = ".src", -- SCRIPT	
	EXT_LINE = ".line",	
	EXT_DUMMY = ".dmy",
	EXT_RTT_CUBE = ".rttc",
	EXT_RTT_PLANAR = ".rttp",	
	EXT_ACTIONS = ".act"

global
	DT_NONE = "none",
	DT_UINT = "uint",
	DT_FLOAT = "float",
	DT_STRING = "string",
	DT_COLOR = "color",
	DT_BYTE = "byte",
	DT_BITMAP = "bitmap",
	DT_TEXTURE = "texture",
	DT_COMPOSITE = "composite",	
	DT_CUBE = "cube",
	DT_CUBE_RTT = "cube_rtt",
	DT_PLANAR_RTT = "planar_rtt"

global
	SH_DIFFUSE_MAP = "DiffuseMap",
	SH_LIGHT_MAP = "LightMap",
	SH_DETAIL_MAP = "DetailMap"

global
	BAKE_COMPLETE_MAP = "completemap",
	BAKE_DIFFUSE_MAP = "diffusemap",		
	BAKE_LIGHT_MAP = "lightmap",
	BAKE_AO = "ao"

global
-- READER --
	
	-- GEOMETRY	
	HEADER_BIGMESH = 1,		
	HEADER_VERTEX = 2,
	HEADER_NORMAL = 4,
	HEADER_TANGENT = 8,
	HEADER_BINORMAL = 16,
	HEADER_UV = 32,	
	HEADER_JOINTS = 64,
	HEADER_COLOR = 128,
	
	-- GEOMETRY COLOR4
	HEADER_COLOR1 = 0,
	HEADER_COLOR2 = 64,
	HEADER_COLOR3 = 128,
	HEADER_COLOR4 = 192,
	
	-- ANIMATION
	HEADER_ANIMATION_SEQUENCE = 1,
	
	-- OBJECT3D
	HEADER_PARENT = 1,
	HEADER_ANIMATION = 2,
	HEADER_SCRIPT = 4,
	HEADER_CLASS = 8,
	HEADER_PROPERTIES = 16,	
	HEADER_OBJECT_CONFIG = 32,
	
	-- OBJECT3D -> LINE
	HEADER_BIG_SPLINE = 64,
	HEADER_CLOSED = 128,	
	
	-- OBJECT3D -> SOUND3D
	HEADER_AUTO_PLAY = 64,
	HEADER_SOUND_MIXER = 128,
	
	-- OBJECT3D -> LIGHT
	HEADER_SHADOW = 64,	
	HEADER_ATTENUATION = 128,
	
	-- OBJECT3D -> ENITY3D
	HEADER_LIGHT_CONFIG = 64,	
	
	-- OBJECT3D -> ENITY3D -> MESH
	HEADER_MATERIAL = 256,		
	HEADER_MODIFIERS = 512,
	
-- SUB-READER --
	
	-- HEADER_OBJECT_CONFIG
	HEADER_STATIC = 1,
	
	-- HEADER_LIGHT_CONFIG
	HEADER_NOCAST_SHADOWS = 1,
	
	-- HEADER_ANIMATION_SEQUENCE
	HEADER_REPEAT = 1,
	HEADER_NOINTERPOLATION = 2
	
global
	TAG_LOOK_AT = 0x0001

global
	SEA_INDEX = 0,
	SEA_JOINT_INDEX = 1

global	
	ACT_ENVIRONMENT = 2,
	ACT_FOG = 3,
	ACT_LOOK_AT = 7,
	ACT_RTT_TARGET = 8
	
global 
	C_BIG = 0xFFFF --65535

global
	MAT_DEFAULT = 0x0000,
	MAT_COMPOSITE_TEXTURE = 0x0001,
	MAT_DIFFUSE_MAP = 0x0002,
	MAT_SPECULAR_MAP = 0x0003,
	MAT_REFLECTION_MAP = 0x0004,
	MAT_REFRACTION_MAP = 0x0005,
	MAT_NORMAL_MAP = 0x0006,
	MAT_FRESNEL_REFLECTION = 0x0007,
	MAT_RIM = 0x0008,	
	MAT_LIGHT_MAP = 0x0009,
	MAT_DETAIL_MAP = 0x000A,
	MAT_CEL = 0x000B,
	MAT_TRANSLUCENT = 0x000C,
	MAT_BLEND_NORMAL_MAP = 0x000D,
	MAT_MIRROR_REFLECTION = 0x000E,
	MAT_AMBIENT_MAP = 0x000F,	
	MAT_ALPHA_MAP = 0x0010,
	MAT_EMISSIVE_MAP = 0x0011,	
	MAT_VERTEX_COLOR = 0x0012

global
	ANM_POSITION = 0x0000,
	ANM_ROTATION = 0x0001,
	ANM_SCALE = 0x0002,
	ANM_COLOR = 0x0003,
	ANM_MULTIPLIER = 0x0004,
	ANM_ATTENUATION_START = 0x0005,
	ANM_ATTENUATION_END = 0x0006,
	ANM_FOV = 0x0007,
	ANM_OFFSET_U = 0x0008,
	ANM_OFFSET_V = 0x0009,
	ANM_SCALE_U = 0x000A,
	ANM_SCALE_V = 0x000B,
	ANM_ANGLE = 0x000C,
	ANM_ALPHA = 0x000D,
	ANM_VOLUME = 0x000E

global
	SEA_QUATERNION = 0,
	SEA_INV_MATRIX = 1

global
	UISIZE = 0

--
--	ATF Extension
--

global
	ENC_ALL = "all",
	ENC_DXT = "dxt",
	ENC_ETC1 = "etc1",
	ENC_PVRTC = "pvrtc",
	ATF_EXTENSION_PATH =  getSourceFolder() + "atf-extension\\",
	ATF_PNG_TO_ATF = ATF_EXTENSION_PATH + "png2atf.exe",
	ATF_DDS_TO_ATF = ATF_EXTENSION_PATH + "dds2atf.exe",
	ATF_SUPPORTS = dirExist (ATF_EXTENSION_PATH) and fileExist (ATF_PNG_TO_ATF) and fileExist (ATF_DDS_TO_ATF)

--
--	3ds Max Fixes
--

global skinops_getBoneNameByListID = skinops.getBoneName

if (hasProperty skinops #getBoneNameByListID) do
	skinops_getBoneNameByListID = skinops.getBoneNameByListID

-- DisableProcessWindowsGhosting
-- @Source: http://forums.cgsociety.org/archive/index.php?t-1045092.html

fn getDisplayTopologyDependenceWarning =
(
	local enabled = (getIniSetting (getMAXIniFile()) #performance #TopoMessage)
	
	if enabled == "" do return true
	
	return (enabled as integer) != 0
)

fn setDisplayTopologyDependenceWarning enabled =
(
	global seaSetDisplayTopologyDependenceWarning = enabled
	
	fn PreferenceCallback =
	(
		-- http://forums.cgsociety.org/showpost.php?p=6973531&postcount=13
		fn setCheckBoxState hwnd state =
		(
			local BN_CLICKED = 0
			local BM_SETCHECK = 241
			local WM_COMMAND = 273

			local parent = UIAccessor.getParentWindow hwnd
			local id = UIAccessor.getWindowResourceID hwnd

			windows.sendMessage hwnd BM_SETCHECK (if state then 1 else 0) 0
			windows.sendMessage parent WM_COMMAND ((bit.shift BN_CLICKED 16) + id) hwnd
			
			ok
		)
		
		local hWND = DialogMonitorOPS.GetWindowHandle()

		if (UIAccessor.GetWindowText hWND) != "Preference Settings" do return true
		
		local bt = windows.getchildhwnd hWND "Display Topology-Dependence Warning"
		
		global seaSetDisplayTopologyDependenceWarning
		
		setCheckBoxState bt[1] seaSetDisplayTopologyDependenceWarning

		UIAccessor.SendMessageID hWND #IDOK
		
		true
	)

	DialogMonitorOPS.RegisterNotification PreferenceCallback id:#preferencesConfigure
	DialogMonitorOPS.Enabled = true
	
	max file preferences
	
	DialogMonitorOPS.unRegisterNotification id:#preferencesConfigure
	DialogMonitorOPS.Enabled = false
)

try 
(
	if getDisplayTopologyDependenceWarning() do setDisplayTopologyDependenceWarning false
)
catch()

-- DisableProcessWindowsGhosting
-- @Source: http://aarondabelow.com/wp/2014/01/08/3ds-max-ui-freezing-during-scripts-disable-window-ghosting/

fn DisableProcessWindowsGhosting =
(
	local source = StringStream ("using System.Runtime.InteropServices; public class DisableWindowsGhosting{ [DllImport(\"user32.dll\")]  public static extern bool DisableProcessWindowsGhosting();  }")

	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
	compilerParams.ReferencedAssemblies.Add("System.dll");
	compilerParams.GenerateInMemory = on
	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
	compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source as String)
	flush source
	close source
	if (compilerResults.Errors.Count > 0 ) then
	(
		local errs = stringstream ""
		for i = 0 to (compilerResults.Errors.Count-1) do
		(
			local err = compilerResults.Errors.Item[i]
			format "Error:% Line:% Column:% %\n" err.ErrorNumber err.Line err.Column err.ErrorText to:errs
		)
		format "%\n" errs
		undefined
	)
	else
	(
		compilerResults.CompiledAssembly.CreateInstance "DisableWindowsGhosting"
	)
)

try 
(
	global DisableWindowsGhosting
	
	if DisableWindowsGhosting == undefined do
	(
		DisableWindowsGhosting = DisableProcessWindowsGhosting()
		DisableWindowsGhosting.DisableProcessWindowsGhosting()
	)
)
catch()

--
--	Config
--

fn CreateSEAConfig =
(
	local seaconfig = dotNetObject "Poonya.Utils.Hashmap"	
	
	seaconfig.AddString "compress" "deflate"	
	seaconfig.AddString "export" "visible"
	seaconfig.AddFloat "mindiff" 0.01
	seaconfig.AddBoolean "exceptionprotection" true
	seaconfig.AddBoolean "sprite" true
	seaconfig.AddBoolean "sounds" true
	seaconfig.AddBoolean "all_sounds" false
	seaconfig.AddBoolean "attrib" true
	seaconfig.AddBoolean "animation" true	
	seaconfig.AddBoolean "force_animation" false
	seaconfig.AddBoolean "geometry" true
	seaconfig.AddBoolean "skeleton" true
	seaconfig.AddBoolean "material" true
	seaconfig.AddBoolean "rtt" true
	seaconfig.AddBoolean "rtt_target" true
	seaconfig.AddBoolean "atf" false
	seaconfig.AddBoolean "atf_auto" true
	seaconfig.AddBoolean "atf_force" false
	seaconfig.AddBoolean "atf_jpegxr" false	
	seaconfig.AddString "atf_compress" "dxt"
	seaconfig.AddBoolean "materialcolor" true
	seaconfig.AddBoolean "texture" true
	seaconfig.AddBoolean "compress_texture" true
	seaconfig.AddBoolean "textureanimationtakes" true
	seaconfig.AddBoolean "camera" true
	seaconfig.AddBoolean "cameratarget"false
	seaconfig.AddBoolean "light" true
	seaconfig.AddBoolean "lighttarget" false
	seaconfig.AddBoolean "shape" false
	seaconfig.AddBoolean "dummy" false
	seaconfig.AddBoolean "multiplechannel" true
	seaconfig.AddBoolean "uv" true
	seaconfig.AddBoolean "normal" true
	seaconfig.AddBoolean "tangent" false
	seaconfig.AddBoolean "sg" true
	seaconfig.AddBoolean "vertexcolor" false
	seaconfig.AddBoolean "env" false
	seaconfig.AddBoolean "morph" true
	seaconfig.AddInteger "lossygeometry" 1
	seaconfig.AddBoolean "vertexanimation" true
	seaconfig.AddBoolean "warning" false
	seaconfig.AddBoolean "auto_rename" true
	seaconfig.AddBoolean "positive_scale" true
	seaconfig.AddBoolean "parent" true
	seaconfig.AddBoolean "bindoffset" true
	seaconfig.AddBoolean "snapshot" false
	seaconfig.AddBoolean "instanceanimation" true
	seaconfig.AddInteger "bindframe" 0
	seaconfig.AddInteger "splinestep" 100
	seaconfig.AddInteger "animationtype" 2
	seaconfig.AddBoolean "envtex" false
	seaconfig.AddBoolean "instances" true
	seaconfig.AddBoolean "sharematerials" false
	seaconfig.AddBoolean "allstatic" false
	seaconfig.AddBoolean "baketextures" true
	seaconfig.AddBoolean "renderall" false
	seaconfig.AddInteger "bakesize" 8
	seaconfig.AddInteger "minbakesize" 8	
	seaconfig.AddInteger "bakequality" 80
	seaconfig.AddString "bakeext" EXT_PNG
	seaconfig.AddString "bakeoutput" "completemap"
	seaconfig.AddBoolean "relativesize" false
	seaconfig.AddBoolean "meshoptimizer" false	
	seaconfig.AddBoolean "joinvertices" false	
	seaconfig.AddBoolean "forcelights" false
	seaconfig.AddBoolean "fileinfo" false
	seaconfig.AddString "fileinfo-name" ""
	seaconfig.AddString "fileinfo-author" ""
	seaconfig.AddString "fileinfo-website" "http://"
	seaconfig.AddBoolean "fog" false
	seaconfig.AddFloat "fog-min" 100.0
	seaconfig.AddFloat "fog-max" 6000.0
	seaconfig.AddColor "fog-color" 0 0 255	
	
	return seaconfig
)

fn SetSEAConfig seaconfig =
(
	seaconfig.AddString "compress" seaconfig_compress	
	seaconfig.AddString "export" seaconfig_export
	seaconfig.AddFloat "mindiff" seaconfig_mindiff
	seaconfig.AddBoolean "exceptionprotection" seaconfig_exceptionprotection
	seaconfig.AddBoolean "sprite" seaconfig_sprite
	seaconfig.AddBoolean "sounds" seaconfig_sounds
	seaconfig.AddBoolean "all_sounds" seaconfig_all_sounds
	seaconfig.AddBoolean "attrib" seaconfig_attrib
	seaconfig.AddBoolean "animation" seaconfig_animation	
	seaconfig.AddBoolean "force_animation" seaconfig_force_animation
	seaconfig.AddBoolean "geometry" seaconfig_geometry
	seaconfig.AddBoolean "skeleton" seaconfig_skeleton
	seaconfig.AddBoolean "material" seaconfig_material
	seaconfig.AddBoolean "rtt" seaconfig_rtt
	seaconfig.AddBoolean "rtt_target" seaconfig_rtt_target
	seaconfig.AddBoolean "atf" seaconfig_atf
	seaconfig.AddBoolean "atf_auto" seaconfig_atf_auto
	seaconfig.AddBoolean "atf_force" seaconfig_atf_force
	seaconfig.AddBoolean "atf_jpegxr" seaconfig_atf_jpegxr
	seaconfig.AddString "atf_compress" seaconfig_atf_compress
	seaconfig.AddBoolean "materialcolor" seaconfig_materialcolor
	seaconfig.AddBoolean "texture" seaconfig_texture
	seaconfig.AddBoolean "textureanimationtakes" seaconfig_textureanimationtakes
	seaconfig.AddBoolean "camera" seaconfig_camera
	seaconfig.AddBoolean "cameratarget" seaconfig_cameratarget
	seaconfig.AddBoolean "light" seaconfig_light
	seaconfig.AddBoolean "lighttarget" seaconfig_lighttarget
	seaconfig.AddBoolean "spline" seaconfig_spline
	seaconfig.AddBoolean "dummy" seaconfig_dummy
	seaconfig.AddBoolean "multiplechannel" seaconfig_multiplechannel
	seaconfig.AddBoolean "uv" seaconfig_uv
	seaconfig.AddBoolean "normal" seaconfig_normal
	seaconfig.AddBoolean "tangent" seaconfig_tangent
	seaconfig.AddBoolean "sg" seaconfig_sg
	seaconfig.AddBoolean "vertexcolor" seaconfig_vertexcolor
	seaconfig.AddBoolean "env" seaconfig_env
	seaconfig.AddBoolean "morph" seaconfig_morph
	seaconfig.AddBoolean "vertexanimation" seaconfig_vertexanimation
	seaconfig.AddBoolean "warning" seaconfig_warning
	seaconfig.AddBoolean "auto_rename" seaconfig_auto_rename
	seaconfig.AddBoolean "positive_scale" seaconfig_positive_scale
	seaconfig.AddBoolean "parent" seaconfig_parent
	seaconfig.AddBoolean "bindoffset" seaconfig_bindoffset
	seaconfig.AddBoolean "snapshot" seaconfig_snapshot
	seaconfig.AddBoolean "instanceanimation" seaconfig_instanceanimation
	seaconfig.AddInteger "bindframe" seaconfig_bindframe
	seaconfig.AddInteger "splinestep" seaconfig_splinestep
	seaconfig.AddBoolean "envmap" seaconfig_envmap
	seaconfig.AddBoolean "instances" seaconfig_instances
	seaconfig.AddBoolean "sharematerials" seaconfig_sharematerials
	seaconfig.AddBoolean "allstatic" seaconfig_allstatic
	seaconfig.AddBoolean "baketextures" seaconfig_baketextures
	seaconfig.AddBoolean "renderall" seaconfig_renderall
	seaconfig.AddBoolean "newmapping" seaconfig_newmapping
	seaconfig.AddInteger "bakesize" seaconfig_bakesize
	seaconfig.AddString "bakeoutput" seaconfig_bakeoutput	 
	seaconfig.AddInteger "minbakesize" seaconfig_minbakesize
	seaconfig.AddInteger "bakequality" seaconfig_bakequality
	seaconfig.AddString "bakeext" seaconfig_bakeext
	seaconfig.AddBoolean "relativesize" seaconfig_relativesize	
	seaconfig.AddBoolean "meshoptimizer" seaconfig_meshoptimizer
	seaconfig.AddBoolean "joinvertices" seaconfig_joinvertices
	seaconfig.AddBoolean "fileinfo" seaconfig_fileinfo[1]
	seaconfig.AddString "fileinfo-name" seaconfig_fileinfo[2]
	seaconfig.AddString "fileinfo-author" seaconfig_fileinfo[3]
	seaconfig.AddString "fileinfo-website" seaconfig_fileinfo[4]
	seaconfig.AddBoolean "fog" seaconfig_fog[1]
	seaconfig.AddColor "fog-color" seaconfig_fog[2].r seaconfig_fog[2].g seaconfig_fog[2].b				
	seaconfig.AddFloat "fog-min" seaconfig_fog[3]
	seaconfig.AddFloat "fog-max" seaconfig_fog[4]	
)

fn GetSEAConfig seaconfig =
(
	global
	seaconfig_compress = seaconfig.GetString "compress", 
	seaconfig_export = seaconfig.GetString "export", 
	seaconfig_mindiff = seaconfig.GetFloat "mindiff",
	seaconfig_exceptionprotection = seaconfig.GetBoolean "exceptionprotection",
	seaconfig_sprite = seaconfig.GetBoolean "sprite",
	seaconfig_sounds = seaconfig.GetBoolean "sounds",
	seaconfig_all_sounds = seaconfig.GetBoolean "all_sounds",
	seaconfig_attrib = seaconfig.GetBoolean "attrib",
	seaconfig_animation = seaconfig.GetBoolean "animation",		
	seaconfig_force_animation = seaconfig.GetBoolean "force_animation",	
	seaconfig_geometry = seaconfig.GetBoolean "geometry",	
	seaconfig_skeleton = seaconfig.GetBoolean "skeleton",	
	seaconfig_material = seaconfig.GetBoolean "material",
	seaconfig_rtt = seaconfig.GetBoolean "rtt",
	seaconfig_rtt_target = seaconfig.GetBoolean "rtt_target",
	seaconfig_atf = seaconfig.GetBoolean "atf",
	seaconfig_atf_auto = seaconfig.GetBoolean "atf_auto",
	seaconfig_atf_force = seaconfig.GetBoolean "atf_force",
	seaconfig_atf_jpegxr = seaconfig.GetBoolean "atf_jpegxr",
	seaconfig_atf_compress = seaconfig.GetString "atf_compress",
	seaconfig_materialcolor = seaconfig.GetBoolean "materialcolor",
	seaconfig_texture = seaconfig.GetBoolean "texture",
	seaconfig_compress_texture = seaconfig.GetBoolean "compress_texture",
	seaconfig_textureAnimationTakes = seaconfig.GetBoolean "textureanimationtakes",
	seaconfig_camera = seaconfig.GetBoolean "camera",
	seaconfig_cameratarget = seaconfig.GetBoolean "cameratarget",
	seaconfig_light = seaconfig.GetBoolean "light",
	seaconfig_lighttarget = seaconfig.GetBoolean "lighttarget",
	seaconfig_spline = seaconfig.GetBoolean "spline",
	seaconfig_dummy = seaconfig.GetBoolean "dummy",
	seaconfig_multiplechannel = seaconfig.GetBoolean "multiplechannel",
	seaconfig_uv = seaconfig.GetBoolean "uv",
	seaconfig_normal = seaconfig.GetBoolean "normal",
	seaconfig_tangent = seaconfig.GetBoolean "tangent",
	seaconfig_sg = seaconfig.GetBoolean "sg", -- smoothing group
	seaconfig_vertexcolor = seaconfig.GetBoolean "vertexcolor",
	seaconfig_env = seaconfig.GetBoolean "env",
	seaconfig_morph = seaconfig.GetBoolean "morph",
	seaconfig_vertexanimation = seaconfig.GetBoolean "vertexanimation",
	seaconfig_warning = seaconfig.GetBoolean "warning",
	seaconfig_auto_rename = seaconfig.GetBoolean "auto_rename",
	seaconfig_positive_scale = seaconfig.GetBoolean "positive_scale",
	seaconfig_parent = seaconfig.GetBoolean "parent",	
	seaconfig_bindoffset = seaconfig.GetBoolean "bindoffset",
	seaconfig_snapshot = seaconfig.GetBoolean "snapshot",
	seaconfig_instanceanimation = seaconfig.GetBoolean "instanceanimation",
	seaconfig_bindframe = seaconfig.GetInteger "bindframe",	
	seaconfig_splinestep = seaconfig.GetInteger "splinestep",
	seaconfig_envmap = seaconfig.GetBoolean "envmap",
	seaconfig_instances = seaconfig.GetBoolean "instances",
	seaconfig_sharematerials = seaconfig.GetBoolean "sharematerials",
	seaconfig_allstatic = seaconfig.GetBoolean "allstatic",
	seaconfig_baketextures =  seaconfig.GetBoolean "baketextures",
	seaconfig_renderall =  seaconfig.GetBoolean "renderall",
	seaconfig_newmapping =  seaconfig.GetBoolean "newmapping",
	seaconfig_bakesize =  seaconfig.GetInteger "bakesize",
	seaconfig_bakeoutput = seaconfig.GetString "bakeoutput",
	seaconfig_minbakesize =  seaconfig.GetInteger "minbakesize",
	seaconfig_bakequality =  seaconfig.GetInteger "bakequality",
	seaconfig_bakeext =  seaconfig.GetString "bakeext",
	seaconfig_relativesize =  seaconfig.GetBoolean "relativesize",
	seaconfig_meshoptimizer = seaconfig.GetBoolean "meshoptimizer",
	seaconfig_joinvertices = seaconfig.GetBoolean "joinvertices",
	seaconfig_fileinfo = #(seaconfig.getBoolean "fileinfo",seaconfig.GetString "fileinfo-name",seaconfig.GetString "fileinfo-author",seaconfig.GetString "fileinfo-website"),
	seaconfig_fog = #(seaconfig.getBoolean "fog", color (seaconfig.GetRed "fog-color") (seaconfig.GetGreen "fog-color") (seaconfig.GetBlue "fog-color"), seaconfig.GetFloat "fog-min", seaconfig.GetFloat "fog-max")
)

fn LoadSEA3DExporterConfigFromDummy target: =
(
	if (target == unsupplied) do 
		target = getnodebyname NODE_CONFIG
	
	if target != undefined then
	(			
		local cfgdata = getUserProp target DEF_ANIMATION_CONFIG 	
		
		if cfgdata != undefined then
		(
			try
			(
				local cfg = dotNetObject "Poonya.Utils.Hashmap"	
				cfg.ReadBase64 cfgdata
				LoadSEA3DExporterConfig cfg
			)
			catch()
		)			
	)
)

fn ReadSEAConfig filename =
(
	local seapath = getSourceFolder() + filename
	local seaconfig = dotNetObject "Poonya.Utils.Hashmap"	
	
	if (seaconfig.ContainsFile seapath) do
	(
		seaconfig.Load seapath
		
		return seaconfig
	)
	
	return undefined
)

fn WriteSEAConfig seaconfig filename =
(
	local seapath = getSourceFolder() + filename
	
	seaconfig.Save seapath
)

fn GetSEAConfigList =
(
	return ( getFiles (getSourceFolder() + "*.config") )
)

--
--	Create Config
--

global seaconfig, seaconfig_selected

seaconfig = ReadSEAConfig "Default.config"

if seaconfig == undefined then seaconfig = CreateSEAConfig()
else seaconfig_selected = "Default"

GetSEAConfig seaconfig

if sea_sounds == undefined or sea_sounds_names == undefined then
(
	global sea_sounds = #(), sea_sounds_names = #()
)

--
--	Exporter
--

global sea_floater, 
sea_listeners = #(),
sea_changes = #(),
seaTimeRange = #(animationRange.start.frame as integer,animationRange.end.frame as integer,0 as integer,framerate),
seaUnits = #(#Generic, #Centimeters),
seaao = #(32,color 255 255 255,color 0 0 0,1.0,50.0,0.5),
sea3d = undefined,	
seabuild = false,
seaAssetNames = #(),
seaErrors = #(),
seaWarning = #(),
seaMaterials = #(),
seaTBakes = undefined,
seaListenerText = "",
seaBitmapList = #(),
seaCubeList = #(),
seaTextureList = #(),
seaMaterialList = #(),
seaObjectList = #(),
seaTempFileList = #(),
seaModifierList = #(),
seaError = undefined,
seaObjectTemp = undefined,
seauseparent = false,
seauseboneparent = false,
seanames = undefined,
seamats = undefined,
seamatnames = undefined,
seasceneobject = undefined,
seaboneobject = undefined,	
seaboneinobject = undefined,	
seabonelist = undefined,
seaprogressbar = undefined,
seaactions = undefined,
seadefaultsequence = undefined,
seasingleuv = false,
seablendpalette = #("normal","add","subtract","multiply","dividing","mix","alpha","screen","darken",
"overlay","colorburn","linearburn","lighten","colordodge","lineardodge",
"softlight","hardlight","pinlight","spotlight","spotlightblend","hardmix",
"average","difference","exclusion","hue","saturation","color","value"),
seacompositepalette = #("normal","average","add","subtract","darken","multiply",
"colorburn","linearburn","lighten","screen","colordodge","lineardodge","spotlight",
"spotlightblend","overlay","softlight","hardlight","pinlight",
"hardmix","difference","exclusion","hue","saturation","color","value"),
seaProceduralList = #(
	Cellular,
	Dent,
	Marble,
	Noise,
	Perlin_Marble,
	Smoke,
	Speckle,
	Splat,
	Stucco,
	Swirl,
	Tiles,
	Vertex_Color,
	Waves,
	Wood
),
seaCompatibleLightList = #(
	OmniLight,
	FreeSpot,
	TargetSpot,	
	Directionallight,
	TargetDirectionallight
),
seaCompatibleMeshList = #(
	Editable_Mesh, 
	PolyMeshObject, 
	Editable_Poly, 
	Box, 
	Cone, 
	Sphere, 
	GeoSphere, 
	Cylinder, 
	Tube, 
	Torus,
	Pyramid, 
	Teapot, 
	Plane, 
	Hedra, 
	Torus_Knot, 
	ChamferBox, 
	ChamferCyl, 
	OilTank, 
	Capsule, 
	Spindle, 
	L_Ext, 
	Gengon, 
	C_Ext, 
	RingWave, 
	Hose, 
	Prism	
	)

global seaevent_anm = undefined

rollout _SEAListener "SEA3D Listener" width:500 height:300
(
    dotNetControl dncText "System.Windows.Forms.Textbox" width:490 height:290 align:#center

    on _SEAListener open do
    (
        dncText.Font = dotNetObject "System.Drawing.Font" "MS Sans Serif" 8 ((dotNetClass "System.Drawing.FontStyle").Regular)
		dncText.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
		dncText.BackColor = (dotNetClass "System.Drawing.Color").fromARGB (((colorMan.getColor #background) * 255)[1] as integer) (((colorMan.getColor #background) * 255)[2] as integer) (((colorMan.getColor #background) * 255)[3] as integer)
		dncText.ForeColor = (dotNetClass "System.Drawing.Color").fromARGB (((colorMan.getColor #text) * 255)[1] as integer) (((colorMan.getColor #text) * 255)[2] as integer) (((colorMan.getColor #text) * 255)[3] as integer)
		dncText.MultiLine = true
		dncText.WordWrap = true
		dncText.ReadOnly = true
		dncText.ScrollBars = (dotNetClass "System.Windows.Forms.ScrollBars").Vertical
		dncText.Text = seaListenerText
    )
)

function openSEAListener =
(
	if (seaWarning.count > 0 or seaErrors.count > 0) do
	(
		seaListenerText = ""
		
		for i=1 to seaWarning.count do
		(
			seaListenerText = ("• Warning " + (seaWarning[i]) + "\r\n") + seaListenerText
		)
		
		for i=1 to seaErrors.count do
		(
			seaListenerText = ("• Error " + (seaErrors[i]) + "\r\n") + seaListenerText
		)
		
		createDialog _SEAListener
	)
)

--
--	Alerts
--

function errorValidMaterialName n =
(
	if n != undefined then return "in the material \"" + n + "\""
	return ""
)	

function error1001 n = 
(
	append seaErrors ("#1001: Conflicted name. More than one object with the name \"" + n + "\" was found.")
)

function error1002 n = 
(
	append seaErrors ("#1002: Conflicted name. More than one material with the name \"" + n + "\" was found.")
)

function error1003 n = 
(
	append seaErrors ("#1003: Conflicted name. More than one texture with the name \"" + n + "\" was found.")
)

function error1004 n nobj = 
(
	append seaErrors ("#1004: Conflicted name. More than one bone with the name \"" + n + "\" was found on the model \"" + nobj + "\".")
)

function error1005 n nobj = 
(
	append seaErrors ("#1005: Conflicted name. More than one morph with the name \"" + n + "\" was found on the model \"" + nobj + "\".")
)

function error1012 t n = 
(
	append seaErrors ("#1012: " + t + " shader in the \"" + n + "\" is not compatible.")
)

function error1013 t n = 
(
	append seaErrors ("#1013: Slot \"" + t + "\" in the material \"" + n + "\" is not compatible.")
)

function error1014 t n = 
(
	append seaErrors ("#1014: Texture \"" + t + "\" in the material \"" + n + "\" is not compatible. Only DDS, PNG, JPEG, JPEG_XR and GIF.")
)

function error1015 n = 
(
	append seaErrors ("#1015: Skin from the object \"" + n + "\" will not be exported. Convert to Editable Mesh object.")
)

function error1016 t n = 
(
	append seaErrors ("#1016: Texture \"" + t + "\" in the material \"" + n + "\" was not found. Reselect the texture in Material Editor.")
)

function error1017 c t n = 
(
	append seaErrors ("#1017: Composite layer \"" + c + "\" of slot " + (toLowerString t) + " in the material \"" + n + "\" is not compatible. Select a bitmap texture.")
)

function error1018 c t n = 
(
	n = errorValidMaterialName n	
	append seaErrors ("#1018: Cube Mapping \"" + c + "\" of slot \"" + (toLowerString t) + "\"" + n + " is undefined. Select a bitmap texture.")
)

function error1019 c t n f = 
(	
	n = errorValidMaterialName n
	append seaErrors ("#1019: Cube Mapping \"" + c + "\" of slot \"" + (toLowerString t) + "\"" + n + " of the face name \"" + f +"\"  is not compatible. Place faces of names: Left(-x), Right(+x), Bottom(-y), Top(+y), Back(-z) and Front(+z).")
)

function error1020 t n = 
(	
	n = errorValidMaterialName n
	append seaErrors ("#1020: Cube Mapping of slot \"" + t + "\"" + n + " must have 6 face names: Left(-x), Right(+x), Bottom(-y), Top(+y), Back(-z) and Front(+z).")
)

function error1021 t n = 
(
	n = errorValidMaterialName n
	append seaErrors ("#1021: Cube Mapping \"" + t + "\"" + n + " must be have faces with the same file extension.")
)

function error1025 n = 
(
	append seaErrors ("#1025: Invalid Environment Map \"" + n + "\". Select a Cube Mapping texture.")
)

function error1030 n = 
(
	append seaErrors ("#1030: Frames values of Animation Sequence in the object \"" + n + "\" do not match the timeline.")
)

function error1031 n nobj = 
(
	append seaErrors ("#1031: Conflicted name in Animation Sequence. More than one sequence with the name \"" + n + "\" was found on the model \"" + nobj + "\".")
)

function error1060 n t = 
(	
	append seaErrors ("#1060: Sound with the name \"" + t+ "\"  in the object  \"" + n + "\" was not found in the Sound List.")
)

function error1090 n t = 
(	
	append seaErrors ("#1090: Line \"" + t+ "\" can not be exported.")
)

function error1201 n = 
(
	append seaErrors ("#1201: File \"" + n + "\" was not found.")
)

function error1301 = 
(
	append seaErrors ("#1301: It is necessary Mental Ray Renderer to create Ambient Occlusion baking.")
)

function error1302 n = 
(
	append seaErrors ("#1302: Invalid material in the object \"" + n + "\" to apply a LightMap, select a Standard Material.")
)

function error1401 n = 
(
	append seaErrors ("#1401: Error creating ATF \"" + n + "\". Make sure the size is a Power of 2.")
)

function customError error = 
(	
	append seaErrors ("#unknown:" + error)
)

function warning2001 n = 
(
	append seaWarning ("#2001: Object \"" + n + "\" will not be exported.")
)

function warning2002 n = 
(
	append seaWarning ("#2002: Invalid geometry. Object \"" + n + "\" will not be exported.")
)

function warning2003 n = 
(
	append seaWarning ("#2003: Skin from the object \"" + n + "\" will not be exported.")
)

function warning2004 n = 
(
	append seaWarning ("#2004: Morpher from the object \"" + n + "\" will not be exported.")
)

function warning2005 n = 
(
	append seaWarning ("#2005: Additional Bump in the material \"" + n + "\" will not be exported.")
)

function warning2006 n = 
(
	append seaWarning ("#2006: Invalid light, \"" + n + "\" will not be exported.")
)

function warning2007 n = 
(
	append seaWarning ("#2007: Found a vertex in mesh \"" + n + "\" without skin attachment.")
)

function warning2008 n = 
(
	append seaWarning ("#2008: Skin can not be exported the object \"" + n + "\". Convert to Editable Mesh object.")
)

function warning2009 t n = 
(	
	append seaWarning ("#2009: Falloff parameters \"" + t + "\" in the material \"" + n + "\" is not compatible.")
)

function warning2010 n = 
(	
	append seaWarning ("#2010:  \"" + n + "\" is not compatible with Stream Loader Type.")
)

function warning2011 n = 
(	
	append seaWarning ("#2011:  \"" + n + "\" instance invalid. The instance may not contain modifiers different order.")
)

function warning2012 t n = 
(
	append seaWarning ("#2012: Material \"" + t + "\" is not compatible in \"" + n + "\".")
)

function warning2401 n = 
(
	append seaWarning ("#2401: ATF Texture \"" + n + "\" can not be created.")
)

function warning2501 n = 
(
	append seaWarning ("#2501 : Animation Key \"" + n + "\" was not found.")
)

--
--	Structs
--

--	SceneObject

struct SEAIndex
(
	type, index, joint
)

struct SEAHashTable
(
	keys = #()
	, values = #()
	, function add key value =
	(
		append keys key
		append values value
	)
	, function contains key =
	(
		return ((findItem keys key) > 0)
	)
	, function get key =
	(
		return values[ (findItem keys key) ]
	)
)

struct SEAMod
(
	obj, m
)

struct SEAAction
(
	type, value
)

struct SEASplines
(	
	obj
	, animation, instanceOf, frame_rate, attribs
	, asset
)

struct SEAAnimator
(
	index, relative = false
)

struct SEADummy
(	
	obj, type="dummy"
	, animation, instanceOf, frame_rate, attribs
	, asset
	, fn dist =
	(
		return (distance [0,0,0] obj.transform.position)
	)
)

struct SEACamera
(	
	obj, target
	, animation, instanceOf, frame_rate, attribs
	, asset
)

struct SEALight
(	
	obj, target
	, animation, instanceOf, frame_rate, attribs
	, asset
)

struct SEASound
(	
	obj, s_sound, soundMod
	, sound_index
	, animation, instanceOf, frame_rate, attribs
	, asset
)

struct SEASprite
(	
	obj, spriteMode, mats, tag
	, mats_index
	, animation, instanceOf, frame_rate, attribs
	, asset
	, fn dist =
	(
		return (distance [0,0,0] obj.transform.position)
	)
	, fn isStatic = 
	(
		if tag != undefined then return tag.enabledstaticparam
		else return (seaconfig_animation == false and seaconfig_allstatic)
	)
	, fn castShadows = 
	(
		if tag != undefined then return tag.m_castshadows
		else return obj.castshadows	
	)
	, fn receiveShadows = 
	(
		if tag != undefined then return tag.m_receiveshadows
		else return obj.receiveshadows			
	)
	, fn receiveLights = 
	(
		if tag != undefined then return tag.m_receivelights
		else return true			
	)
)

struct SEAMesh
(	
	obj, temp, tag, mats, meshObj, normalNObj, normalObj, smoothing_group, skinObj, morphObj, morphAnmObj, vertexAnm, boneList, boneParentList, bindpos, mchs, mchsValue, instances=#(), skeleton, skeletonAnimation, morphAnimation, vertexAnimation, uvwAnimation
	, geo_index = -1, mats_index, morph_index
	, e_index, e_normal, c_vertex, c_index, c_weights, c_normal, c_uv, c_color, c_tangent, maxweight
	, animation, instanceOf, frame_rate, attribs
	, asset
	, fn dist =
	(
		return (distance [0,0,0] obj.transform.position)
	)
	, fn useVertexColor = 
	(
		if tag != undefined then return tag.m_vertexcolorparam
		else return seaconfig_vertexcolor	
	)
	, fn useNormal = 
	(
		if tag != undefined then return tag.m_normalparam
		else return seaconfig_normal	
	)
	, fn isStatic = 
	(
		if tag != undefined then return tag.enabledstaticparam
		else return (seaconfig_animation == false and seaconfig_allstatic)
	)
	, fn castShadows = 
	(
		if tag != undefined then return tag.m_castshadows
		else return obj.castshadows	
	)
	, fn receiveShadows = 
	(
		if tag != undefined then return tag.m_receiveshadows
		else return obj.receiveshadows			
	)
	, fn receiveLights = 
	(
		if tag != undefined then return tag.m_receivelights
		else return true			
	)
)

-- dependências

struct SEABitmap
(
	filename, bake = undefined
	, asset
)

struct SEABitmapComposite
(
	obj, blendMode, data
)

struct SEATexture
(	
	obj, name=#(),textures=#(), masks=#(), masksID=#(), blendMode=#(), opacity=#(), bitmaps=#(), animation=#(), animationMask=#(), color
	, asset
	, lightMapTexture, detailMapTexture
	, fn type = 
	(
		if textures.count == 1 then return DT_TEXTURE
		else if textures.count > 1 then return DT_COMPOSITE
		else DT_NONE
	)
	, fn diffuseType =
	(
		local texType = type()
		if texType == DT_TEXTURE then MAT_DIFFUSE_MAP
		else if texType == DT_COMPOSITE then MAT_COMPOSITE_TEXTURE
		else -1
	)
	, fn getBitmap =
	(
		return bitmaps[1].asset
	)	
	, fn isValid = 
	(
		return type() != DT_NONE
	)
)

struct SEACube
(	
	obj, textures, bitmaps=#()
	, asset
	, fn isValid = 
	(
		return bitmaps.count == 1 or bitmaps.count == 6
	)
)

struct SEAMaterial
(	
	obj, tech=#(), maps=#()
	, twoSided = false, smoothMat = true, containsAlpha = false, opacity = 1.0
	, uvwAnimation
	, rttCube = false, rttPlanar = false, rttCubeAsset, rttPlanarAsset
	, asset
)

SEA3DSpriteDef = attributes SEA3DSpriteDef 
(
	parameters main rollout:SEA3DSpriteParams
	(
		enabledparam type:#boolean ui:enabledparam default:true
		widthparam type:#float ui:widthparam default:50.0
		heightparam type:#float ui:heightparam default:50.0		
	)
	
	rollout SEA3DSpriteParams "Parameters"
	(
		checkbox enabledparam "Enabled" type:#boolean		
		spinner widthparam "Width:" type:#float range:[0,10000,0]	
		spinner heightparam "Height:" type:#float range:[0,10000,0]	
		dropdownlist _blend "Blend Type" items:#("Normal", "Add", "Multiply", "Alpha") 
		button _update "Active Display" align:#left
		local obj = undefined
		
		-- Align to View [2010-03-13] by Anubis [project3d.narod.ru]
		fn alignObjToView = (			
			if obj != undefined then
			(
				local o_pos = obj.pos
				obj.transform = inverse (viewport.getTM())
				obj.pos = o_pos
			)
			else unRegisterRedrawViewsCallback alignObjToView
		)
		
		on _update pressed do
		(
			if obj == undefined then
			(
				_update.text = "Deactive Display"
				obj = $				
				registerRedrawViewsCallback alignObjToView				
			)
			else
			(
				_update.text = "Active Display"
				obj = undefined
				unRegisterRedrawViewsCallback alignObjToView
			)
			
			alignObjToView()
		)
		
		fn getBlend =
		(
			local state = 0
		
			local userprop = getUserProp $ DEF_MATERIAL_BLEND_TYPE
			
			if userprop == "normal" then state = 1
			else if userprop == "add" then state = 2
			else if userprop == "multiply" then state = 3
			else if userprop == "alpha" then state = 4
				
			return state
		)
		
		fn setBlend state =
		(
			local blendValue = undefined
			
			if state == 1 then blendValue = "normal"
			else if state == 2 then blendValue = "add"
			else if state == 3 then blendValue = "multiply"
			else if state == 4 then blendValue = "alpha"
			
			setUserProp $ DEF_MATERIAL_BLEND_TYPE blendValue
		)
		
		on SEA3DSpriteParams open do		
		(			
			_blend.selection = (getBlend())
		)
		
		on _blend selected i do 
		(			
			setBlend i
		)
		
		on widthparam changed  v do 
		(
			$.width = v
		)
		
		on heightparam changed  v do 
		(
			$.length = v
		)
	)		
)

SEA3DSoundDef = attributes SEA3DSoundDef 
(
	parameters main rollout:SEA3DSoundParams
	(
		enabledparam type:#boolean ui:enabledparam default:true
		volumeparam type:#float ui:volumeparam default:1.0 
		distanceparam type:#float ui:distanceparam default:300.0 		
		namespaceparam type:#string ui:namespaceparam
		autoplayparam type:#boolean ui:autoplayparam default:true
		soundparam type:#string 
		tagversion type:#float default:1.0
	)
	
	rollout SEA3DSoundParams "Parameters"
	( 	
		checkbox enabledparam "Enabled" type:#boolean		
		spinner volumeparam "Volume:" type:#float range:[0,1000000,0]
		spinner distanceparam "Distance:" type:#float range:[0,1000000,0]		
		checkbox autoplayparam "Auto Play" type:#boolean		
		edittext namespaceparam "Mixer:"
		dropdownlist _sound "Sound"
		button _updateList "Update List"		
		
		fn updateList =
		(									
			if sea_sounds_names != undefined then
			(
				local selectedName = undefined				
				
				if _sound.selection > 0 then				
				(
					selectedName = _sound.items[_sound.selection]
				)
				
				_sound.items = sea_sounds_names
				
				if selectedName != undefined then
				(					
					_sound.selection = findItem sea_sounds_names selectedName
				)
			)
			else _sound.items = #()
			
			if soundparam != undefined then
			(
				_sound.selection = findItem sea_sounds_names soundparam
			)
		)				
		
		on distanceparam changed  v do 
		(
			$.size = v
		)
		
		on _sound selected i do 
		(
			soundparam = _sound.items[i]
		)
		
		on _updateList pressed do
		(
			updateList()
		)
		
		on SEA3DSoundParams open do
		(			
			updateList()			
		)
	)
)

SEA3DTagDef = attributes SEA3DTagDef
(
	parameters mainGlobal rollout:SEA3DTagGlobal
	(
		enabledstaticparam type:#boolean ui:enabledstaticparam default:false
		tagversion type:#float default:1.1
	)
	
	parameters mainAnimation rollout:SEA3DTagAnimation
	(
		a_framerateparam type:#integer ui:a_framerateparam default:framerate
	)
	
	parameters mainMesh rollout:SEA3DTagMesh
	(
		m_normalparam type:#boolean ui:m_normalparam default:true
		m_sgparam type:#boolean ui:m_sgparam default:true
		m_vertexanmparam type:#boolean ui:m_vertexanmparam default:false
		m_vertexcolorparam type:#boolean ui:m_vertexcolorparam default:false
		m_castshadows type:#boolean ui:m_castshadows default:true
		m_receiveshadows type:#boolean ui:m_receiveshadows default:true
		m_receivelights type:#boolean ui:m_receivelights default:true
	)
	
	rollout SEA3DTagGlobal "Global"
	( 	
		checkbox enabledstaticparam "Static Object" type:#boolean
	)
	
	rollout SEA3DTagAnimation "Animation"
	(
		spinner a_framerateparam "Frame rate:" range:[1,256,framerate] type:#integer
	)
	
	rollout SEA3DTagMesh "Mesh"
	(
		checkbox m_normalparam "Normal" type:#boolean
		checkbox m_sgparam "Smoothing Group" type:#boolean
		checkbox m_vertexanmparam "Vertex Animation" type:#boolean
		checkbox m_vertexcolorparam "Vertex Color" type:#boolean
		checkbox m_castshadows "Cast Shadows" type:#boolean
		checkbox m_receiveshadows "Receive Shadows" type:#boolean
		checkbox m_receivelights "Receive Lights" type:#boolean
	)
)

--
-- System
--

global 
	seastarttime = undefined,
	seaupdatetime = undefined

fn seatime t =
(
	set time t
	sliderTime = t
)

fn seaupdatewindow = 
(
	windows.processPostedMessages()
)

fn seadispatchChange changes: dispatch: = 
(
	seabuild = false
	
	if changes != false then
	(
		for i=1 to sea_changes.count do
		(
			sea_changes[i]()
		)
	)
	
	if dispatch == true then
	(
		for i=1 to sea_listeners.count do
		(
			sea_listeners[i]()
		)
	)
)

fn seaprogressStart c name: =
(
	seastarttime = timeStamp()
	seaupdatetime = timeStamp()
	
	seaprogressbar.value = 0
	seaprogressbar.color = c
)

fn seaprogressUpdate p =
(
	local actime = timeStamp()
	
	seaprogressbar.value = p
	
	if seabuild do seabuild = keyboard.escPressed == false
	
	if actime - seastarttime > 5000 and actime - seaupdatetime > 1000 then
	(
		seaupdatewindow()
		
		seaupdatetime = actime
	)
)

fn seaprogressEnd =
(
	seaprogressbar.value = 0
)

--
-- Utils
--

fn roundNum n = 
(
	if n > 0 then (n+0.5) as integer
	else (n-0.5) as integer
)

fn getValidName name list =
(		
	local regexp = dotnetObject "System.Text.RegularExpressions.Regex" "[0-9]+$"
	
	if regexp.IsMatch name then
	(
		local match = regexp.Match name	
		local length = match.Length - 1
		
		local num = (substring name (match.Index+1) match.Length) as integer
		name = substring name 1 match.Index
		
		local newname = undefined
		
		local i = 0
		while true do
		(
			num += 1
			
			local numstr = num as string
			
			for i=numstr.count to length do
			(
				numstr = "0" + numstr
			)
			
			newname = name + numstr
			
			if (findItem list newname) == 0 then
			(
				exit
			)			
		)
		
		return newname
	)
	
	return name + "1"
)

-- selectMod from: http://forums.cgsociety.org/archive/index.php/t-972272.html
fn selectMod obj modObj =
(
	-- Select @_pNode if needed.
	if not obj.IsSelected do 
	(
		Select obj
	)
	
	-- Set Modify Panel active if needed.
	if obj.IsFrozen do 
	(
		Unfreeze obj DoLayer:true
	)
	
	-- Set Modify Panel active if needed.
	if GetCommandPanelTaskMode() != #modify do 
	(
		SetCommandPanelTaskMode mode:#modify
	)
	
	-- Set @_pNode skin modifier as current object in modpanel if needed.
	if modObj != undefined and ModPanel.GetCurrentObject() != modObj do 
	(
		ModPanel.SetCurrentObject modObj
	)
)

fn getUVCount obj force: =
(
	selectMod obj undefined
	
	local m = Edit_Mesh ()
	
	if obj.modifiers.count > 0 then
		modPanel.setCurrentObject obj.modifiers[1]
	else modPanel.setCurrentObject obj
	
	local channelcount = (nummapsused obj) - 1
	
	if force == true do channelcount = 9
	
	modPanel.addModToSelection m
	
	local uvs = #()
	local index = 1
	for c = 1 to channelcount do
	(		
		try
		(
			meshop.getMapVert obj c 1
			uvs[index] = c
			index += 1
		)
		catch ()	
	)
	
	deleteModifier obj m
	
	uvs
)

fn isValidInstancing = 
(
	return seaconfig_instances and ((seaconfig_renderall and seaconfig_newmapping) == false)
)

fn classOfList n list =
(
	local cof = ClassOf n
	for i=1 to list.count do
	(
		if list[i] == cof do
		(
			return true
		)
	)
	
	return false
)

-- http://tech-artists.org/wiki/Common_functions
fn isPowerOf2 n =
(
	-- Can't be a power of two if it's not an integer
	if classOf n != integer then return false
	bit.and n (n-1) == 0
)

fn getPowerOf2 v =
(
	if v < 0 do return 0
	bit.set 0 (v+1) true
)

fn getLowerPowerOf2 v =
(
	ceil ((log v) / (log 2)) 	
)

fn getUpperPowerOf2 v =
(
	(getLowestPowerOf2 v) - 1
)

fn getNearestPowerOf2 v =
(
	if (isPowerOf2 v) == false then
	(
		local upper = getPowerOf2 (getUpperPowerOf2 v)
		local lower = getPowerOf2 (getLowerPowerOf2 v)		
				
		if (v - lower) > (upper - v) then return upper
		else return lower
	)
	v
)

fn removeTempObject =
(
	if seaObjectTemp != undefined do
	(
		delete seaObjectTemp
		seaObjectTemp = undefined
	)
)

fn creatTempFile ext =
(
	local id = seaTempFileList.count
	local filename = (getDir #image) + "\\SEA3D_TEMP" + (id as String) + ext
	append seaTempFileList filename
	return filename
)

fn loadBakeConfig =
(
	JPEGIO.setQuality seaconfig_bakequality
	JPEGIO.setSmoothing 0
	
	PNGIO.setAlpha false
	PNGIO.setType #true24
)	

fn appendLightMap mat tex =
(	
	if classof mat.diffuseMap == CompositeTexturemap then
	(
		local ctex = mat.diffuseMap		
		local lightMapIndex = findItem ctex.layerName SH_LIGHT_MAP
		
		if lightMapIndex == 0 then
		(
			for i=1 to ctex.mapList.count do
			(
				if classof ctex.mapList[i] == BitmapTexture then
				(
					if ctex.mapList[i].filename == tex.filename then
					(
						lightMapIndex = i
						exit
					)
				)
			)
		)
		
		if lightMapIndex == 0 then
		(
			ctex.add()
			lightMapIndex = ctex.mapList.count
			ctex.layerName[lightMapIndex] = SH_LIGHT_MAP
		)
		
		ctex.mapList[lightMapIndex] = tex
	)
	else
	(
		local dmap = mat.diffuseMap
		
		local ctex = CompositeTexturemap()
		ctex.name = tex.name
		
		ctex.add()
		
		ctex.layerName[1] = SH_DIFFUSE_MAP
		ctex.mapList[1] = mat.diffuseMap
		
		ctex.layerName[2] = SH_LIGHT_MAP
		ctex.mapList[2] = tex
		ctex.blendMode[2] = 5														
		
		mat.diffuseMap = ctex		
	)
	
	mat.showInViewport = true
)

fn bakeTexture tex filename: size: =
(
	if seaTBakes.contains tex then
	(
		return (seaTBakes.get tex)
	)
		
	if filename == unsupplied do 
	(
		filename = creatTempFile seaconfig_bakeext
	)
	
	if size == unsupplied do 
	(
		if classof tex == BitmapTexture and (openBitMap tex.filename) != undefined then		
		(
			local _bmp = openBitMap tex.filename
			
			size = [_bmp.width,_bmp.height]
			
			close _bmp
			free _bmp
		)
		else
		(
			local tex_size = getPowerOf2 seaconfig_bakesize
			size = [tex_size,tex_size]
		)
	)
	
	loadBakeConfig()
		
	local scl = 1.0
	
	if (classOfList tex seaProceduralList) then
	(
		scl = 100
	)
	
	local rm = renderMap tex filename:filename scale:scl size:size filter:true display:false time:seaTimeRange[1]
	save rm
	close rm
	free rm
	
	seaTBakes.add tex filename
	
	return filename
)

fn appendBakeMaterial mat =
(
	if (finditem seaMaterials mat) == 0 then
	(
		append seaMaterials mat
		return false
	)
	true
)

fn bakeMesh obj temp: filename: size: =
(	
	select obj
	
	obj.renderable = true
	obj.visibility = true
	
	if temp == unsupplied do temp = true
	
	if filename == unsupplied do 
	(
		if temp == false or seaconfig_bakeoutput == BAKE_LIGHT_MAP or seaconfig_bakeoutput == BAKE_AO then
		(
			filename = ((getDir #image) + "\\SEA3D_BAKE_" + obj.name + seaconfig_bakeext)
		)
		else
		(
			filename = creatTempFile seaconfig_bakeext			
		)
	)
	
	if size == unsupplied do 
	(
		size = getPowerOf2 seaconfig_bakesize
	)
	
	local bk = undefined	
	local singleuv = (classof obj.material) != StandardMaterial and (classof obj.material) != MultiMaterial		
	
	if seaconfig_bakeoutput == BAKE_COMPLETE_MAP then
	(
		bk = CompleteMap()		
		bk.shadowsOn = true
		
		singleuv = true
	)
	else if seaconfig_bakeoutput == BAKE_DIFFUSE_MAP then
	(
		bk = DiffuseMap()
		bk.shadowsOn = true
		bk.lightingOn = true
		
		singleuv = true
	)
	else if seaconfig_bakeoutput == BAKE_LIGHT_MAP then
	(
		bk = LightingMap()
		bk.directOn = true
		bk.indirectOn = true
		bk.shadowsOn = true
	)
	else if seaconfig_bakeoutput == BAKE_AO then
	(
		if classof renderers.current != mental_ray_renderer then
		(
			error1301()
		)
		
		bk = AmbientOcclusionBakeElement()
		bk.samples = seaao[1]
		bk.bright = seaao[2]
		bk.dark = seaao[3]
		bk.spread = seaao[4]
		bk.maxDistance = seaao[5]
		bk.falloff = seaao[6]				
	)
	
	if bk == undefined then
		return undefined
	
	bk.outputSzX = bk.outputSzY = size
	bk.fileType = filename
	
	bgColor = backgroundColor
	backgroundColor = color 128 128 128
	
	try
	(		
		local uv = getUVCount obj force:true
		
		local uv_bake = 1		
				
		if uv.count > 0 then
		(
			if uv.count > 1 then 
			(
				if singleuv then uv_bake = uv[uv.count] + 1
				else uv_bake = uv[2]
			)			
			else 
			(
				uv_bake = uv[1] + 1
			)
		)
		else
		(
			singleuv = true
		)
		
		if seaconfig_newmapping or singleuv then
		(
			local uvw = Unwrap_UVW ()
			uvw.name = "SEA3D UVW"	
			
			modPanel.addModToSelection uvw
			
			uvw.setMapChannel uv_bake
			
			uvw.flattenMap 60.0 [0,0,1] 0.01 true 0 true true
		)
		
		obj.iNodeBakeProperties.removeAllBakeElements() 
		
		obj.INodeBakeProperties.addBakeElement bk 
		
		obj.INodeBakeProperties.bakeEnabled = true 
		obj.INodeBakeProperties.bakeChannel = uv_bake
		
		loadBakeConfig()
		
		render rendertype:#bakeSelected vfb:false progressBar:true outputSize:[size,size]
		
		local tex = BitmapTexture()
		tex.name = getName (filenameFromPath filename)
		tex.filename = filename	
		tex.coords.mapChannel = uv_bake
		
		if singleuv then
		(
			uvw.setMapChannel uv_bake
				
			local mat = StandardMaterial()
			mat.name = obj.name						
			
			if classof obj.material == StandardMaterial then
			(
				mat.diffuse = obj.material.diffuse
				mat.specular = obj.material.specular
				mat.specularLevel = obj.material.specularLevel
				mat.glossiness = obj.material.glossiness	
				mat.selfIllumAmount = obj.material.selfIllumAmount		
			)			
			else
			(
				mat.diffuse = obj.wirecolor
				--mat.selfIllumAmount = 100.0	
			)
			
			if seaconfig_bakeoutput == BAKE_LIGHT_MAP or seaconfig_bakeoutput == BAKE_AO then
			(
				appendLightMap mat tex
			)
			else 
			(				
				mat.diffuseMap = tex			
			)
			
			mat.showInViewport = true
			
			obj.material = mat
		)
		else
		(
			tex.coords.mapChannel = uv_bake
			
			if classof obj.material == StandardMaterial then
			(
				if temp or (appendBakeMaterial obj.material) do
				(				
					local diffMap = obj.material.diffuseMap		
					
					obj.material = copy obj.material						
					
					if (classof diffMap == CompositeTexture) or (classof diffMap == BitmapTexture) then					
						diffMap = copy diffMap
					
					obj.material.diffuseMap = diffMap
				)
				
				appendLightMap obj.material tex				
			)
			else if classof obj.material == MultiMaterial then
			(
				if temp do obj.material = copy obj.material
				
				for m=1 to obj.material.materiallist.count do
				(
					if classof obj.material.materiallist[m] == StandardMaterial then
					(
						local diffMap = obj.material.materiallist[m].diffuseMap
						
						if temp or (appendBakeMaterial obj.material.materiallist[m]) do
							obj.material.materiallist[m] = copy obj.material.materiallist[m]						
					
						if (classof diffMap == CompositeTexture) or (classof diffMap == BitmapTexture) do
							diffMap = copy diffMap
						
						obj.material.materiallist[m].diffuseMap = diffMap
						
						appendLightMap obj.material.materiallist[m] tex
					)
					else
					(
						error1302 obj.name
					)
				)
			)
			else
			(
				error1302 obj.name
			)
		)
	)
	catch()
	
	backgroundColor = bgColor
)

fn creatSEA3DTag m =
(
	local tag = EmptyModifier()
	tag.name = "SEA3D Tag"		
	custattributes.add tag SEA3DTagDef
	
	addModifier m tag
)

fn creatSEA3DSound snd =
(
	p = PointHelperObj()
	p.cross = false
	p.box = true
	p.size = 300

	sc = EmptyModifier()
	sc.name = "SEA3D Sound"
	custattributes.add sc SEA3DSoundDef
	
	local ca = custattributes.get sc 1
	ca.soundparam = snd

	addModifier p sc
	
	return p
)

fn creatSEA3DSprite =
(
	p = Plane()
	p.length = 50
	p.lengthsegs = 1
	p.width = 50
	p.widthsegs = 1
		
	setUserProp p "material-blendtype" "add"
	
	sc = EmptyModifier()
	sc.name = "SEA3D Sprite"
	custattributes.add sc SEA3DSpriteDef
	
	local ca = custattributes.get sc 1
	
	ca.widthparam = 50
	ca.heightparam = 50
	
	local o_pos = p.pos
	p.transform = inverse (viewport.getTM())
	p.pos = o_pos
	
	addModifier p sc
	
	return p
)

fn rotateMatrix t offset =
(
	local r = t.rotation as eulerangles
	
	r.x += offset.x
	r.y += offset.y
	r.z += offset.z
	
	r = (r as matrix3) * (scaleMatrix t.scale)
	r.position = t.position
	
	return r	
)

fn getInstanceIndex n returnnode: =
(
	InstanceMgr.GetInstances n &instances	
	
	for j=1 to instances.count do		
	(
		local inst = instances[j]
		
		for i=1 to seaObjectList.count do				
		(
			local obj = seaObjectList[i].obj			
			
			if obj == inst do
			(
				if obj.modifiers.count == inst.modifiers.count then
				(
					local validInst = true
					
					for m=1 to obj.modifiers.count do				
					(
						if obj.modifiers[m] != inst.modifiers[m] then
						(
							validInst = false
						)
					)
					
					if validInst and seaconfig_positive_scale then
					(
						local objS = obj.scale.x < 0 or obj.scale.y < 0 or obj.scale.z < 0	
						local instS = inst.scale.x < 0 or inst.scale.y < 0 or inst.scale.z < 0	
						
						validInst = (objS == instS)
					)
					
					if validInst then 
					(
						if returnnode == unsupplied then return i
						else return obj
					)
					else
					(
						warning2011 n.name
					)
				)
				else				
				(
					warning2011 n.name
				)
			)							
		)
	)
	
	return 0
)

function getSEATag obj =
(
	for m=1 to obj.modifiers.count do				
	(
		if (ClassOf obj.modifiers[m] == EmptyModifier and obj.modifiers[m].enabled) then 
		(
			try
			(
				local md = custAttributes.get obj.modifiers[m] 1								
				if md.name == "SEA3DTagDef" then
				(
					return obj.modifiers[m]
				)
			)
			catch()	
		)
	)
	
	return undefined
)

function getCompositeAnimationTokenList obj =
(
	local tokenList = #()
	
	if obj.coords.U_Offset.isAnimated do (
		append tokenList #(ANM_OFFSET_U,10) --  offsetU, float
	)
	
	if obj.coords.V_Offset.isAnimated do (
		append tokenList #(ANM_OFFSET_V,10) --  offsetV, float
	)
		
	if obj.coords.U_Tiling.isAnimated do (
		append tokenList #(ANM_SCALE_U,10) --  scaleU, float
	)
	
	if obj.coords.V_Tiling.isAnimated do (
		append tokenList #(ANM_SCALE_V,10) --  scaleV, float
	)
	
	if obj.coords.W_Angle.isAnimated do (
		append tokenList #(ANM_ANGLE,10) --  rotationUV, float
	)
	
	return tokenList
)

fn getDepthList list =
(
	local pcount = #()	
	
	for i = 1 to list.count do 
	(
		local c = 0
		local p = list[i].parent
		
		while (p != undefined) do
		(
			p = p.parent
			c += 1
		)
		
		pcount[i] = c
	)
	
	return pcount
)

-- source: md5 exporter by der_ton, tom-(at)gmx.de
fn righthand_mat mat =
(
	-- convert the matrix to a righthanded one, by flipping its Z axis if it's lefthanded
	if dot (cross mat.row1 mat.row2) mat.row3 > 0 then
	(
		md5mat = copy mat
	)
	else
	(
		md5mat = copy mat
		md5mat.row3 = - md5mat.row3
	)
	return md5mat
)

fn normalToTangent normal = 
(
	return cross normal (point3 0 1 0)
)

fn sortHierarchyFN v1 v2 dep: =
(
	local dp1 = dep[v1]
	local dp2 = dep[v2]
	
	case of
	(
		(dp1 > dp2):  1
		(dp1 < dp2):  -1		
		default:0
	)	
)

fn sortHierarchy list dep =
(
	local indexArray = for i = 1 to list.count collect i	
	
	qsort indexArray sortHierarchyFN dep:dep
	
	local nlist = for i = 1 to list.count collect list[i]
	local nindex = #()	
	
	for i = 1 to list.count do
	(
		list[i] = nlist[indexArray[i]]
		nindex[indexArray[i]] = i
	)
	
	return nindex
)

fn getDepth obj =
(
	local c = 0
	local p = obj.parent
	
	while (p != undefined) do
	(
		p = p.parent
		c += 1
	)
	
	InstanceMgr.GetInstances obj &instances		
	
	if instances.count > 1 then
	(
		local skinAt = 0
		
		for m=1 to obj.modifiers.count do
		(
			if (ClassOf obj.modifiers[m] == Skin and obj.modifiers[m].enabled) then 
			(
				skinAt = m
			)
		)
		
		if skinAt > 0 then
		(						
			local skinObj = obj.modifiers[skinAt]
		
			selectMod obj skinObj	
			
			-- skeleton				
			local numbones = skinops.getnumberbones skinObj
			
			-- sort dependencies
			local boneList =  #()						
			for i=1 to numbones do
			(
				local boneobjname = skinops_getBoneNameByListID skinObj i 0
				boneList[i] = getnodebyname boneobjname				
			)
			
			sortHierarchy boneList (getDepthList boneList)
			
			local posRelative = boneList[1].transform.position
			local actDistance = 0xFFFFFFFF
			local rootObj = instances[1]

			for i=1 to instances.count do
			(	
				local dist = distance instances[i].center boneList[1].center
				if dist < actDistance then
				(
					rootObj = instances[i]
					actDistance = dist
				)
			)	

			if rootObj != obj then
			(
				c += 1
			)
		)
	)
	
	return c
)

fn getDependenceList list =
(
	local sel = GetCurrentSelection()
	
	local pcount = #()	
	
	for i = 1 to list.count do 
	(
		pcount[i] = getDepth list[i]
	)
	
	selectMore sel
	
	return pcount
)

fn getMassList list =
(
	local sel = GetCurrentSelection()
	
	local pcount = #()	
	local minValue = 0xFFFFFFFF
	local maxValue = 0x00
	
	for i = 1 to list.count do 
	(
		local bb = list[i].max - list[i].min
		local liter = (bb.x + bb.y + bb.z) / 3
		
		if liter > maxValue then
		(
			maxValue = liter
		)
		else if liter < minValue then
		(
			minValue = liter
		)				
		
		pcount[i] = liter
	)
	
	maxValue -= minValue
	
	for i = 1 to list.count do 
	(
		pcount[i] = (pcount[i] - minValue) / maxValue
	)
	
	selectMore sel
	
	return pcount	
)

function removeObjectTransform object =
(
	object.position.controller = Position_XYZ()
	object.position = [0,0,0]
		
	object.rotation.controller = Euler_XYZ()
	object.rotation = eulerangles 0 0 0 --quat 0 0 0 1	
	
	object.scale.controller = Bezier_Scale()
	object.scale = [1,1,1]	
)

function colorNotEqual c v =
(
	return (ceil c.r != v or ceil c.g != v or ceil c.b != v)
)

function newAsset = 
(
	return (dotNetObject "Poonya.SEA3D.Objects.SEAData")
)

function newNode = 
(
	return (dotNetObject "Poonya.Utils.ByteArray")
)

function realParent obj =
(
	obj = obj.parent
	
	while obj != undefined do
	(
		local id = finditem seasceneobject obj
		
		if id == 0 then		
		(
			local id = finditem seaboneobject obj
			
			if id == 0 then		
			(
				obj = obj.parent
			)
			else return obj
		)
		else return obj		
	)
	
	return undefined		
)

function containsSEA3DTag obj =
(
	for i = 1 to obj.modifiers.count do
	(
		local m = obj.modifiers[i]
				
		if (classof m) == EmptyModifier then
		(
			try
			(
				local _mod = custAttributes.get n.modifiers[1] 1
				
				if _mod.name == "SEA3DTagDef" then
				(
					return true
				)
			)
			catch()			
		)
	)	
	return false
)

function realTransform obj useparent: p: t: tp: =
(
	local matRelative = obj.transform

	if useparent == unsupplied then 
		useparent = seauseparent

	if classof t == Matrix3 then 
	(
		-- bind matrix
		matRelative *= inverse (righthand_mat t)
	)

	if useparent then
	(
		if p == unsupplied then 
			p = realParent obj
		
		if p != undefined then
		(
			local trans = p.transform
			
			if classof tp == Matrix3 do
			(
				-- bind parent matrix
				trans *= inverse (righthand_mat tp)
			)
			
			matRelative *= inverse (righthand_mat trans)
		)
	)
	
	return (righthand_mat matRelative)
)

function containsDifference val0 val1 =
(
	return ((distance val0 val1) > seaconfig_mindiff)
)

function containsPosition obj =
(
	seatime seaTimeRange[1]		
	
	local p = undefined
	
	if seauseparent do p = realParent obj
		
	local value = obj.transform
	
	if p != undefined then
		value *= inverse p.transform
	
	for t = seaTimeRange[1] to seaTimeRange[2] do
	(
		seatime t		
		
		local trans = obj.transform
		
		if p != undefined then
			trans *= inverse p.transform
		
		if (containsDifference value.position trans.position) then
			return true			
	)
	
	return false
)

function containsRotation obj =
(
	seatime seaTimeRange[1]		
	
	local p = undefined 
	
	if seauseparent do p = realParent obj
	
	local value = obj.transform
	
	if p != undefined then
		value *= inverse p.transform
	
	for t = seaTimeRange[1] to seaTimeRange[2] do
	(
		seatime t		
		
		local trans = obj.transform
		
		if p != undefined then
			trans *= inverse p.transform
		
		if value.rotation != trans.rotation then
			return true			
	)
	
	return false
)

function containsScale obj =
(
	seatime seaTimeRange[1]		
	
	local p = undefined 
	
	if seauseparent do p = realParent obj
		
	local value = obj.transform
	
	if p != undefined then
		value *= inverse p.transform
	
	for t = seaTimeRange[1] to seaTimeRange[2] do
	(
		seatime t		
		
		local trans = obj.transform
		
		if p != undefined then
			trans *= inverse p.transform
		
		if (containsDifference value.scale trans.scale) then
			return true			
	)
	
	return false
)

function containsInvalidParentAnimation obj =
(
	try
	(
		obj = obj.parent
		
		if obj == undefined then
			return false
			
		while obj != undefined do
		(
			local id = finditem seasceneobject obj
			
			if id == 0 then		
			(
				local id = finditem seaboneobject obj
				
				if id == 0 then		
				(
					local _containsPos = ps and (containsPosition obj)
					local _containsRot = rt and (containsRotation obj)
					local _containsScl = sc and (containsScale obj)
					
					if _containsPos or _containsRot or _containsScl then
						return true
					
					obj = obj.parent
				)
				else return false
			)
			else return false
		)
	)
	catch ()
	
	return false	
)

function getBlendIndex name =
(
	local index = findItem seablendpalette name
	if index > 0 do index -= 1
	return index
)

function getSEAIndex obj type =
(	
	if obj != undefined do
	(
		local objName = obj.name + type
		
		if (finditem seaAssetNames objName) > 0 then	
		(
			local index = (finditem seaAssetNames objName) - 1
			
			-- object3d parent
			return (SEAIndex SEA_INDEX index)
		)
		else if (finditem seaboneobject obj) > 0 then	
		(
			local globalBoneIndex = finditem seaboneobject obj 
			
			objName = seaboneinobject[globalBoneIndex].name + type
			
			local index = (finditem seaAssetNames objName) - 1
			local boneIndex = (finditem seabonelist[globalBoneIndex] obj) - 1
			
			-- joint parent
			return (SEAIndex SEA_JOINT_INDEX index boneIndex)
		)	
	)
	
	undefined
)

function getAssetIndex obj type =
(
	return (getSEAIndex obj type).index
)

function seaDispose =
(
	function disposeMesh obj =
	(
		while obj.modifiers.count > 0 do
		(
			if (substring obj.modifiers[1].name 1 5) == "SEA3D" then
			(
				deleteModifier obj obj.modifiers[1]
			)
			else exit
		)
		
		delete obj
	)

	removeTempObject()
	
	for file in seaTempFileList do
	(
		deleteFile file
	)
	
	seaTempFileList = #()
	
	for m in seaModifierList do
	(
		deleteModifier m.obj m.m
	)
	
	for sea in seaObjectList do
	(
		if classof sea == SEAMesh do
		(
			if sea.temp != undefined do
			(
				disposeMesh sea.temp
				sea.temp = undefined
			)
			
			if sea.normalNObj != undefined do
			(
				disposeMesh sea.normalNObj
				sea.normalNObj = undefined
			)									
		)
	)
	
	seamats = 
	seamatnames = 		
	seaactions = 
	
	seanames = 
	seasceneobject = 
	seaboneobject = 
	seaboneinobject = 
	seabonelist = 
	
	seaErrors = 
	seaWarning = 
	seaMaterials =
	seaTBakes =
	
	seaBitmapList = 
	seaCubeList = 
	seaTextureList = 
	seaMaterialList = 
	seaObjectList = 
	seaAssetList = 
	seaAssetNames = 
	seaModifierList = undefined
	
	gc()
)

--
-- Append
--

function appendSceneObject obj =
(
	append seasceneobject obj
)

function appendBones obj boneList =
(
	for i=1 to boneList.count do
	(
		append seaboneobject boneList[i]
		append seaboneinobject obj
		append seabonelist boneList
	)
)

function appendAsset asset share: type: =
(
	local index = undefined
	
	if share == unsupplied do
		share = isValidInstancing()
	
	if share then index = sea3d.AddSharedObject asset	
	else index = sea3d.AddObject asset		
	
	if type == unsupplied then	
		seaAssetNames[index+1] = asset.Filename	
	else	
		seaAssetNames[index+1] = asset.Name + type
		
	return index
)

function appendToken list token value type =
(
	append list (#(token,value,type))
)

function getTexture filename =
(
	for i=1 to seaBitmapList.count do
	(
		if (seaBitmapList[i].filename == filename) do
		(
			return seaBitmapList[i]
		)				
	)
	
	return undefined
)

function appendBitmap filename n map: =
(	
	f = toLowerString filename	
	
	local seaBmp = getTexture filename		
	if seaBmp != undefined do return seaBmp
	
	local ext = getExtension f
	
	local _bitmap = undefined
	
	if ext == EXT_JPEG or ext == EXT_PNG or ext == EXT_GIF or ext == EXT_JPEG_XR then
	(				
		if fileExist filename then
		(
			_bitmap = SEABitmap filename			
		)
		else if seaconfig_baketextures then
		(
			_bitmap = SEABitmap filename (bakeTexture map)		
		)
		else
		(
			error1016 f n
		)			
	)
	else if seaconfig_baketextures then
	(
		_bitmap = SEABitmap filename (bakeTexture map)		
	)
	
	if _bitmap != undefined then
	(
		append seaBitmapList _bitmap			
		return _bitmap
	)		
	else
	(						
		error1014 (getName filename) n
	)															
)

function appendCube map textures n =
(
	for i=1 to seaCubeList.count do
	(
		local equal = textures.count == seaCubeList[i].textures.count
		
		if equal then
		(
			for j=1 to textures.count do
			(
				if textures[j].filename != seaCubeList[i].textures[j].filename then
				(
					equal = false
					exit
				)
			)
		)
		
		if equal do return seaCubeList[i]
	)
	
	local cube = SEACube map textures
	
	append seaCubeList cube
	
	if cube.textures.count > 0 then
	(
		local filename = textures[1].filename
		local ext = getExtension filename
		
		if ext == EXT_JPEG or ext == EXT_PNG or ext == EXT_GIF or EXT_JPEG_XR then
		(
			for i=1 to cube.textures.count do
			(
				filename = textures[i].filename
				
				if (ext == (getExtension filename)) then
				(
					cube.bitmaps[i] = filename
				)
				else
				(
					error1021 (getName filename) matName
				)			
			)
		)			
		else
		(
			error1014 (getName filename) n
		)
	)
	
	return cube
)

function appendCubeTexture map type matName singleCube =
(
	local names = #()
	
	for i=1 to seaCubeList.count do
	(
		names[i] = seaCubeList[i].obj.name
		
		if seaCubeList[i].obj.name == map.name do
		(
			if seaCubeList[i].obj == map then
			(
				return seaCubeList[i]
			)
			else
			(
				if seaconfig_auto_rename then map.name = getValidName map.name names
				else error1003 map.name
			)
		)				
	)
	
	if (singleCube and classof map == BitmapTexture) then
	(
		return (appendCube map #(map) matName)
	)
	else if (classof map == CompositeTexturemap) then
	(
		local successfully = true
		local textures = #()
		
		for i=1 to map.mapList.count do
		(
			local dm = map.mapList[i]
			local nm = map.layerName[i]
			
			if (map.mapEnabled[i] == false) do continue
			
			if (dm != undefined) then
			(
				if (classof dm == BitmapTexture) then
				(
					nm = toLowerString nm
					
					if nm == "left" then textures[1] = dm
					else if nm == "right" then textures[2] = dm
					else if nm == "bottom" then textures[3] = dm	
					else if nm == "top" then textures[4] = dm
					else if nm == "back" then textures[5] = dm
					else if nm == "front" then textures[6] = dm
					else
					(						
						error1019 ("Map "+(i as string)) type matName map.layerName[i]
						successfully = false
					)
				)
				else
				(					
					error1017 ("Map "+(i as string)) type matName
					successfully = false
				)
			)
			else
			(				
				error1018 ("Map "+(i as string)) type matName
				successfully = false
			)
		)	
		
		if textures.count != 6 then
		(
			error1020 type matName
			return undefined
		)
		else
		(
			for i=1 to textures.count do
			(
				if (textures[i] == undefined) then
				(
					error1020 type matName
					return undefined
				)
			)
		)
		
		if successfully then
		(
			return (appendCube map textures matName)		
		)
	)	
	else
	(
		error1013 type matName	
	)			
	
	return undefined
)

function appendTexture map n type enabledComposite =
(
	local names = #()
	
	for i=1 to seaTextureList.count do
	(
		names[i] = seaTextureList[i].obj.name
		
		if seaTextureList[i].obj.name == map.name do
		(
			if seaTextureList[i].obj == map then
			(
				return seaTextureList[i]
			)
			else
			(
				if seaconfig_auto_rename then map.name = getValidName map.name names
				else error1003 map.name
			)
		)				
	)
	
	local sea = SEATexture map	
	
	append seaTextureList sea
	
	if classof map == BitmapTexture then
	(	
		local bmpTex = appendBitmap map.filename n map:map
		
		sea.textures[1] = map
		sea.blendMode[1] = "normal"
		sea.opacity[1] = 100.0
		
		if seaconfig_animation and (getCompositeAnimationTokenList map).count > 0 then
			sea.animation[1] =  map.name
		
		append sea.bitmaps bmpTex
	)
	else if enabledComposite and classof map == CompositeTexturemap then
	(		
		local c = 1
		
		for i=1 to map.mapList.count do
		(
			local en = map.mapEnabled[i]
			local dm = map.mapList[i]
			local mm = map.mask[i]
			local emm = map.maskEnabled[i]
			local blendMode =  seacompositepalette[ map.blendMode[i] + 1 ]
			local opacity = map.opacity[i]
			local nm = map.layerName[i]
			
			if en and dm != undefined then
			(
				local diffuseTexture = undefined
				
				if classof dm == BitmapTexture then
				(
					diffuseTexture = dm
				)
				else if seaconfig_baketextures then
				(
					-- Bake Texture
					diffuseTexture = BitmapTexture()
					diffuseTexture.name = dm.name
					diffuseTexture.filename = bakeTexture dm
				)
				else
				(
					error1017 ("Map "+(i as string)) type n
					continue
				)
				
				local diffuseBitmap = appendBitmap diffuseTexture.filename n map:dm
				
				append sea.bitmaps diffuseBitmap
				
				if nm == SH_LIGHT_MAP then
				(
					local uvChannel = undefined
								
					if seaconfig_multiplechannel and seaconfig_uv then
					(
						uvChannel = diffuseTexture.coords.mapChannel - 1
					)
					else 
					(
						uvChannel = 0
					)					
					
					sea.lightMapTexture = SEABitmapComposite diffuseBitmap blendMode uvChannel
				)
				else if nm == SH_DETAIL_MAP then
				(
					local tiling = undefined
					
					if diffuseTexture.coords.U_Tile == true and diffuseTexture.coords.V_Tile == true then
					(
						tiling = (diffuseTexture.coords.U_Tiling + diffuseTexture.coords.V_Tiling) / 2
					)
					else
					(
						tiling = 1
					)
					
					sea.detailMapTexture = SEABitmapComposite diffuseBitmap blendMode tiling
				)
				else
				(
					sea.textures[c] = diffuseTexture
					sea.opacity[c] = opacity
					sea.blendMode[c] = blendMode
					sea.name[c] = nm																			
						
					if seaconfig_animation and (getCompositeAnimationTokenList diffuseTexture).count > 0 then
						sea.animation[c] = diffuseTexture.name + ":texture" + ((i-1) as string)
					
					if emm and mm != undefined do
					(
						if classof mm == BitmapTexture then
						(
							sea.masks[c] = mm
							
							if seaconfig_animation and (getCompositeAnimationTokenList mm).count > 0 then
								sea.animationMask[c] = mm.name + ":mask" + ((i-1) as string)
							
							append sea.bitmaps (appendBitmap mm.filename n map:mm)										
						)
						else if seaconfig_baketextures then
						(
							local bakeBitmap = BitmapTexture()
							bakeBitmap.name = mm.name
							bakeBitmap.filename = bakeTexture mm	
							
							sea.masks[c] = bakeBitmap				
							
							append sea.bitmaps (appendBitmap bakeBitmap.filename n)		
						)
						else
						(
							error1017 ("Mask "+(i as string)) type n
						)
					)
					
					c += 1
				)
			)						
		)		
	)
	else if seaconfig_baketextures then
	(
		local bakeBitmap = BitmapTexture()
		bakeBitmap.name = map.name
		bakeBitmap.filename = bakeTexture map	
		
		sea.textures[1] = bakeBitmap
		sea.blendMode[1] = "normal"
		sea.opacity[1] = 100.0
		
		append sea.bitmaps (appendBitmap bakeBitmap.filename n)
	)
	else
	(
		error1013 type n					
	)
	
	return sea
)

--
--	Writers
--		

function writeTag data n kind =
(	
	data.WriteUInt16 kind
	data.WriteDataObject n
)

function writeTags data count nodeData: =
(
	data.WriteByte count			
	if count > 0 do (
		data.WriteData nodeData
	)
)

function writeStr data t =
(
	if t != undefined and t != unsupplied then data.WriteUTF8 t
	else data.WriteByte 0
)

function write3D data t =
(
	data.WriteFloat t.x
	data.WriteFloat t.z
	data.WriteFloat t.y
)

function writeQuat data t =
(
	data.WriteFloat t.x
	data.WriteFloat t.z
	data.WriteFloat t.y
	data.WriteFloat t.w
)

function writeColor data t =
(
	data.WriteByte t.b
	data.WriteByte t.g
	data.WriteByte t.r		
)

function writePosition data obj useparent: p: t: tp: =
(
	local trans = realTransform obj useparent:useparent p:p t:t tp:tp
	write3D data trans.position
)

function writeRotation data obj useparent: p: t: tp: offset: =
(
	local trans = realTransform obj useparent:useparent p:p t:t tp:tp
	
	if offset != unsupplied do 
	(
		trans = rotateMatrix trans offset
	)
		
	writeQuat data trans.rotation
)

function writeScale data obj useparent: p: t: tp: =
(
	local trans = realTransform obj useparent:useparent p:p t:t tp:tp
	write3D data trans.scale
)

function positiveMatrixScale &t =
(
	local x = t.scale.x,
			y = t.scale.y,
			z = t.scale.z
		
	if x < 0 do t.scale.x = -x
	if y < 0 do t.scale.y = -y
	if z < 0 do t.scale.z = -z
)

function writeMatrix3x4 data t =
(
	local r = t.row1
	
	data.WriteFloat r.x
	data.WriteFloat r.z
	data.WriteFloat r.y
	
	r = t.row3
	
	data.WriteFloat r.x
	data.WriteFloat r.z
	data.WriteFloat r.y
	
	r = t.row2
	
	data.WriteFloat r.x
	data.WriteFloat r.z
	data.WriteFloat r.y
	
	r = t.row4
	
	data.WriteFloat r.x
	data.WriteFloat r.z
	data.WriteFloat r.y
)

function writeMatrix data obj useparent: p: position: offset: ignoreRotation: =
(
	local t = realTransform obj useparent:useparent p:p	
	
	if offset != unsupplied then 
	(
		t = rotateMatrix t offset
	)
	else if ignoreRotation == true then
	(
		local r = scaleMatrix t.scale
		r.position = t.position
		t = r
	)
	
	if position != unsupplied do
	(
		t.position = position
	)
	
	if seaconfig_positive_scale do 
		positiveMatrixScale &t
	
	writeMatrix3x4 data t
)

function writeBone data obj type parent: bindpos: =
(
	local matRelative = righthand_mat obj.transform
	
	if (parent == undefined or parent == unsupplied) and bindpos != unsupplied then			
		matRelative.position = matRelative.position - bindpos
	
	if seauseboneparent and (parent != undefined and parent != unsupplied) do
	(
		matRelative.position *= matRelative.scale
		
		local parentTrans = righthand_mat parent.transform
		
		parentTrans.position *= parentTrans.scale
		
		parentTrans = righthand_mat parentTrans
		matRelative *= inverse parentTrans
	)
		
	matRelative = righthand_mat matRelative
	
	if type == SEA_QUATERNION then
	(
		write3D data matRelative.position
		writeQuat data matRelative.rotation
	)
	else if type == SEA_INV_MATRIX then
	(
		writeMatrix3x4 data (inverse matRelative)
	)
)

function writeAnimationList data list =	
(
	data.WriteByte list.count
	
	for i = 1 to list.count do
	(
		local anm = list[i]		
		local attrib = 0x00
		
		if anm.relative do
			attrib = bit.set attrib 1 true
		
		data.WriteByte attrib
		data.WriteInt32 anm.index
	)
)

function writeAnimationHead data sequence: =
(
	local containsSequence = sequence != undefined and sequence != unsupplied
	
	local flag = 0x00
	
	if containsSequence do 
		flag += HEADER_ANIMATION_SEQUENCE	
	
	data.WriteByte flag
	
	if containsSequence do
		data.WriteData sequence
	
	data.WriteByte framerate
	data.WriteInt32 ((seaTimeRange[2] - seaTimeRange[1])+1)
)

function writeCompositeLayer data tex anm =
(
	local useMapChannel = tex.coords.mapChannel > 1 and (seaconfig_multiplechannel and seaconfig_uv)
	local useCustomRepeat = tex.coords.U_Tile == false and tex.coords.V_Tile == false
	local useOffsetU = tex.coords.U_Offset != 0
	local useOffsetV = tex.coords.V_Offset != 0
	local useScaleU = tex.coords.U_Tiling != 1
	local useScaleV = tex.coords.V_Tiling != 1
	local useRotation = tex.coords.W_Angle != 0	
	local useAnimation = anm != undefined
	
	local ext_attrib = 0
	
	if useMapChannel do
		ext_attrib = bit.set ext_attrib 1 true
	
	if useCustomRepeat do
		ext_attrib = bit.set ext_attrib 2 true
		
	if useOffsetU do
		ext_attrib = bit.set ext_attrib 3 true
	
	if useOffsetV do
		ext_attrib = bit.set ext_attrib 4 true
	
	if useScaleU do
		ext_attrib = bit.set ext_attrib 5 true
	
	if useScaleV do
		ext_attrib = bit.set ext_attrib 6 true
	
	if useRotation do
		ext_attrib = bit.set ext_attrib 7 true
	
	if useAnimation do
		ext_attrib = bit.set ext_attrib 8 true
	
	data.WriteInt32 (getTexture tex.filename).asset
	data.WriteUInt16 ext_attrib
	
	if useMapChannel do
		data.WriteByte (tex.coords.mapChannel-1)

	if useOffsetU do
		data.WriteFloat tex.coords.U_Offset
	
	if useOffsetV do
		data.WriteFloat tex.coords.V_Offset
	
	if useScaleU do
		data.WriteFloat tex.coords.U_Tiling
	
	if useScaleV do
		data.WriteFloat tex.coords.V_Tiling
	
	if useRotation do
		data.WriteFloat tex.coords.W_Angle
	
	if useAnimation do
		writeAnimationList data #( SEAAnimator anm )		
)

function writeAppendJointObject obj =
(
	local asset = newAsset()
	local data = asset.Data			
	
	asset.Filename = obj.name + EXT_JOINT_OBJECT
	
	-- HEADER
	local header = 0x0000
	local body = newNode()
	
	local indexData = getSEAIndex obj EXT_SCENE_OBJECT
	
	-- PARENT
	header += HEADER_PARENT
	body.WriteInt32 indexData.index
	
	-- TARGET | JOINT OBJECT	
	body.WriteInt32 indexData.index
	body.WriteUInt16 indexData.joint
	
	-- HEADER | BODY
	data.WriteUInt16 header
	data.WriteData body	
	
	-- TAGS
	writeTags data 0
	
	return (appendAsset asset)
)

function writeAppendSoundMixer ns =
(
	local filename = ns + EXT_SOUND_MIXER	
	local index = findItem seaAssetNames filename
	
	if index == 0 then
	(
		local asset = newAsset()
		local data = asset.Data			
		
		asset.Filename = filename
		
		-- ATTRIB
		data.WriteByte 0x00
	
		index = appendAsset asset share:false
	)
	
	return index
)

function writeObject3D data sea &header animation: =
(
	-- HEADER
	local parent = realParent sea.obj		
	local useInstance = sea.instanceof != undefined
	local useAttribs = sea.attribs != undefined
	
	if seaconfig_instanceanimation and sea.animation == undefined and useInstance and sea.instanceof.animation != undefined then
	(		
		sea.animation = sea.instanceof.animation
	)
	
	if animation == unsupplied or animation == undefined then
	(
		animation = #()
	)
	
	if sea.animation != undefined then
	(
		append animation ( SEAAnimator sea.animation (seaconfig_bindoffset and parent == undefined) )	
	)
	
	-- WRITER
	if seauseparent and parent != undefined then
	(
		header += HEADER_PARENT
		
		local indexData = getSEAIndex parent EXT_SCENE_OBJECT
		
		if indexData.type == SEA_INDEX then
		(
			-- 	SEA3D ASSET INDEX
			data.WriteInt32 indexData.index
		)
		else if indexData.type == SEA_JOINT_INDEX then
		(
			data.WriteInt32 (writeAppendJointObject parent)
		)
	)
	
	if animation.count > 0 then	
	(		
		header += HEADER_ANIMATION
		writeAnimationList data animation		
	)
	
	if useAttribs then	
	(		
		header += HEADER_PROPERTIES
		data.WriteInt32 sea.attribs
	)
)

function writeDataList data list =
(
	for i=1 to list.count do
	(
		local type = list[i][1]
		local value = list[i][2]
				
		if type == DT_UINT then data.WriteInt32 value
		else if type == DT_FLOAT then data.WriteFloat value
		else if type == DT_STRING then data.WriteUTF8 value					
		else if type == DT_COLOR then WriteColor data value
		else if type == DT_BYTE then data.WriteByte value		
		else if type == DT_BITMAP then data.WriteInt32 value.obj.asset
		else if type == DT_TEXTURE then data.WriteInt32 (value.getBitmap())
		else if type == DT_COMPOSITE then data.WriteInt32 (getAssetIndex value.obj EXT_COMPOSITE)				
		else if type == DT_CUBE then data.WriteInt32 (getAssetIndex value.obj EXT_CUBE_MAPPING)			
		else if type == DT_CUBE_RTT then data.WriteInt32 value.rttCubeAsset
		else if type == DT_PLANAR_RTT then data.WriteInt32 value.rttPlanarAsset
	)
)

function writeMaterialTechs data tech =
(
	data.WriteByte tech.count
	
	for i = 1 to tech.count do
	(			
		local attrib = tech[i]		
		local type = attrib[1]
		
		deleteItem attrib 1
		
		local nodeData = newNode()		
		
		writeDataList nodeData attrib
		
		data.WriteUInt16 type
		data.WriteUInt16 nodeData.Length
		
		data.WriteData nodeData
	) 
)

--
-- Compiler
--

fn compileStandardMaterial mat =
(
	local sea = SEAMaterial mat
	
	local t = undefined
	if (mat.shaderType == 0) then t = "Anisotropic"
	else if (mat.shaderType == 2) then t = "Metal"
	else if (mat.shaderType == 3) then t = "Multi-Layer"
	else if (mat.shaderType == 4) then t = "Oren-Nayar-Blinn"
	else if (mat.shaderType == 6) then t = "Strauss"
	
	if (t != undefined) then
	(						
		error1012 t mat.name
		return undefined
	)
	
	sea.twoSided = mat.twoSided
	sea.smoothMat = mat.faceted == false
	sea.containsAlpha = mat.opacity != 100.0	
	sea.opacity = mat.opacity / 100.0
	
	local tech = sea.tech
	
	local _ambient = undefined
	
	if (mat.useSelfIllumColor) then 		
		_ambient = mat.selfIllumColor
	else 
	(
		local _color = ((mat.selfIllumAmount/100.0) * 255.0)		
		_ambient = color _color _color _color
	)
	
	append tech #(		
		MAT_DEFAULT,				
		#(DT_COLOR, _ambient),
		#(DT_COLOR, mat.diffuse),
		#(DT_COLOR, mat.specular),
		#(DT_FLOAT, mat.specularLevel/100.0),
		#(DT_FLOAT, mat.glossiness)
	)
	
	if mat.shaderType == 7 then 
	(
		append tech #(		
			MAT_TRANSLUCENT,				
			#(DT_COLOR, mat.translucentColor),
			#(DT_FLOAT, mat.translucentColorMapAmount/100.0),
			#(DT_FLOAT, .5)
		)
	)		
					
	if (seaconfig_texture and mat.diffuseMapEnable and mat.diffuseMap != undefined) then
	(
		local tex = appendTexture mat.diffusemap mat.name "Diffuse Map" true
		
		append sea.maps tex
		
		if tex.isValid() then
		(						
			append tech #(		
				tex.diffuseType(),				
				#(tex.type(),tex)
			)
		)

		if tex.lightMapTexture != undefined then
		(
			append tech #(		
				MAT_LIGHT_MAP,				
				#(DT_BITMAP, tex.lightMapTexture),
				#(DT_BYTE, tex.lightMapTexture.data),
				#(DT_BYTE, (getBlendIndex tex.lightMapTexture.blendMode)) 
			)
		)
		
		if tex.detailMapTexture != undefined then
		(
			append tech #(		
				MAT_DETAIL_MAP,				
				#(DT_BITMAP, tex.detailMapTexture),
				#(DT_FLOAT, tex.detailMapTexture.data),
				#(DT_BYTE, (getBlendIndex tex.detailMapTexture.blendMode)) 
			)
		)
	)
	
	if (seaconfig_texture and mat.specularMapEnable and mat.specularMap  != undefined) then
	(
		local tex = appendTexture mat.specularMap mat.name "Specular Map" false
		
		if tex.isValid() then
		(
			append sea.maps tex
			
			append tech #(		
				MAT_SPECULAR_MAP,			
				#(tex.type(),tex)
			)
		)
	)		
	
	if (seaconfig_texture and mat.refractionMapEnable and mat.refractionMap  != undefined) do
	(
		local tex = appendCubeTexture mat.refractionMap "Refraction Map" mat.name false
		
		if tex.isValid() then
		(
			append sea.maps tex
			
			append tech #(		
				MAT_REFRACTION_MAP,
				#(DT_CUBE, tex),
				#(DT_FLOAT, (mat.refractionMapAmount/100.0)),-- alpha
				#(DT_FLOAT, 0.9)-- ior				
			)
		)
	)
			
	if (seaconfig_texture and mat.bumpMap  != undefined and mat.bumpMapEnable) do
	(
		if (classof mat.bumpMap == Normal_Bump) then
		(
			if (mat.bumpMap.normal_map != undefined) do
			(
				local tex = appendTexture mat.bumpMap.normal_map mat.name "Normal Map" false
				
				if tex.isValid() then
				(
					append sea.maps tex
					
					append tech #(		
						MAT_NORMAL_MAP,
						#(tex.type(),tex)
					)
				)
			)			
			if (mat.bumpMap.bump_map != undefined) do
			(
				warning2005 mat.name
			)			
		)
		else
		(
			local tex = appendTexture mat.bumpMap mat.name "Bump Map" false
			
			if tex.isValid() then
			(
				append sea.maps tex
				
				append tech #(		
					MAT_NORMAL_MAP,
					#(tex.type(),tex)
				)
			)
		)
	)
	
	if (mat.reflectionMapEnable and mat.reflectionMap  != undefined) do
	(
		if classof mat.reflectionMap == Falloff then
		(
			if mat.reflectionMap.type == 2 then
			(
				if mat.reflectionMap.map2On == true and mat.reflectionMap.map2 != undefined then
				(
					if seaconfig_texture then
					(
						local tex_type = undefined
						
						if classof mat.reflectionMap.map2 == ReflectRefract and seaconfig_rtt then
						(
							-- Environment Reflection
							sea.rttCube = true
							tex_type = #(DT_CUBE_RTT, sea)							
						)
						else if seaconfig_texture then
						(
							local tex = appendCubeTexture mat.reflectionMap.map2 "Reflection Map" mat.name false				
							
							if tex.isValid() then
							(
								append sea.maps tex
								
								tex_type = #(DT_CUBE, tex)
							)
						)
						
						if tex_type != undefined then
						(
							append tech #(		
								MAT_FRESNEL_REFLECTION,
								tex_type,
								#(DT_FLOAT, mat.reflectionMapAmount/100.0),-- alpha								
								#(DT_FLOAT, 2),-- fresnelPower
								#(DT_FLOAT, 0) -- normalReflectance
							)
						)
					)
				)
				else
				(
					append tech #(		
						MAT_RIM,												
						#(DT_COLOR, mat.reflectionMap.color2),-- color
						#(DT_FLOAT, mat.reflectionMapAmount/100.0),-- strength
						#(DT_FLOAT, 2),-- power							
						#(DT_BYTE, 5)-- 5 = mix (blend mode)
					)									
				)
			)
			else if seaconfig_texture then
			(
				warning2008 "Reflection Map" mat.name
			)
		)
		else if classof mat.reflectionMap == FlatMirror and seaconfig_rtt then
		(			
			-- Planar Reflection
			sea.rttPlanar = true
			append tech #(		
				MAT_MIRROR_REFLECTION,
				#(DT_PLANAR_RTT, sea), 
				#(DT_FLOAT, mat.reflectionMapAmount/100.0)
			)
		)
		else if classof mat.reflectionMap == ReflectRefract and seaconfig_rtt then
		(
			-- Environment Reflection
			sea.rttCube = true
			append tech #(		
				MAT_REFLECTION_MAP,
				#(DT_CUBE_RTT, sea), 
				#(DT_FLOAT, mat.reflectionMapAmount/100.0)		
			)
		)	
		else if seaconfig_texture then
		(
			local tex = appendCubeTexture mat.reflectionMap "Reflection Map" mat.name true
			
			if tex.isValid() then
			(
				append sea.maps tex
				
				append tech #(		
					MAT_REFLECTION_MAP,
					#(DT_CUBE, tex),
					#(DT_FLOAT, mat.reflectionMapAmount/100.0)
				)
			)
		)
	)
	
--
--	if (seaconfig_texture and mat.opacityMapEnable and mat.opacityMap != undefined) then
--	(
--		local tex = appendTexture mat.opacityMap mat.name "Opacity Map" false
--		
--		if tex.isValid() then
--		(
--			append sea.maps tex
--			
--			append tech #(		
--				MAT_OPACITY_MAP,			
--				#(tex.type(),tex)
--			)
--		)
--	)
			
	return sea
)

fn compileInkMaterial mat =
(
	local sea = SEAMaterial mat
	
	sea.twoSided = mat.two_side_on
	sea.smoothMat = mat.faceted_on == false
	sea.containsAlpha = mat.paint_map_amt != 100.0
	
	local tech = sea.tech
	
	append tech #(		
		MAT_CEL,						
		#(DT_COLOR, mat.color1),
		#(DT_BYTE, mat.paint_levels),
		#(DT_FLOAT, mat.min_ink_width),
		#(DT_FLOAT, .5),
		#(DT_FLOAT,.1)
	)
	
	append tech #(		
		MAT_DEFAULT,				
		#(DT_COLOR, (color 50 50 50)),-- ambient
		#(DT_COLOR, mat.paint_color), -- diffuse
		#(DT_COLOR, (color 255 255 255)), -- specular
		#(DT_FLOAT, 0.30),
		#(DT_FLOAT, 10.0)
	)
		
	if (seaconfig_texture and mat.bump_map_on and mat.bump_map != undefined) then
	(
		local tex = appendTexture mat.bump_map mat.name "Paint Map" false
		
		if tex.isValid() then
		(
			append sea.maps tex
			
			append tech #(		
				MAT_NORMAL_MAP,				
				#(tex.type(),tex)
			)
		)
	)
	
	if (seaconfig_texture and mat.paint_map_on and mat.paint_map != undefined) then
	(
		local tex = appendTexture mat.paint_map mat.name "Paint Map" false
		
		if tex.isValid() then
		(
			append sea.maps tex
			
			append tech #(		
				tex.diffuseType(),				
				#(tex.type(),tex)
			)
		)
	)
	
	return sea
)

fn compileVRayMaterial mat =
(
	local sea = SEAMaterial mat	
	local opacity = mat.refraction.value
	local spec = mat.reflection.value
	
	if spec > 0 do spec = 1.0
	
	sea.twoSided = mat.option_doubleSided
	sea.containsAlpha = opacity != 255.0
	sea.opacity = opacity/255.0
	
	local tech = sea.tech
		
	append tech #(		
		MAT_DEFAULT,				
		#(DT_COLOR, (color 50 50 50)),
		#(DT_COLOR, mat.diffuse),
		#(DT_COLOR, mat.reflection),
		#(DT_FLOAT, spec),-- specular level
		#(DT_FLOAT, mat.reflection_glossiness)
	)
	
	if (seaconfig_texture and mat.texmap_diffuse_on and texmap_diffuse != undefined) then
	(
		local tex = appendTexture mat.texmap_diffuse mat.name "Diffuse Map" true
		
		if tex.isValid() then
		(
			append sea.maps tex
			
			append tech #(		
				tex.diffuseType(),				
				#(tex.type(),tex)
			)
		)
	)		
	
	return sea
)

fn compileVRayLightMaterial mat =
(
	local sea = SEAMaterial mat	
	local opacity = mat.refraction.value
	local mult = mat.multiplier * 255
	
	if mult > 255 do mult = 255
	
	sea.twoSided = mat.twoSided
	
	local tech = sea.tech
		
	append tech #(		
		MAT_DEFAULT,				
		#(DT_COLOR, (color mult mult mult)),
		#(DT_COLOR, mat.color),
		#(DT_COLOR, mat.reflection),
		#(DT_FLOAT, 0.0),-- specular level
		#(DT_FLOAT, 10)
	)
	
	if (seaconfig_texture and mat.texmap_on and texmap != undefined) then
	(
		local tex = appendTexture mat.texmap mat.name "Diffuse Map" true
		
		if tex.isValid() then
		(
			append sea.maps tex
			
			append tech #(		
				tex.diffuseType(),				
				#(tex.type(),tex)
			)
		)
	)		
	
	return sea
)

fn compileMaterial mat names mats =
(	
	if mat == undefined do return undefined
	
	local matat = (findItem names mat.name)	
		
	if (matat > 0) do 
	( 						
		if (isValidInstancing()) == false or mats[matat].obj != mat then
		(
			if seaconfig_auto_rename then 
			(
				mat.name = getValidName mat.name names
			)
			else 
			(
				error1002 mat.name
				return undefined
			)
		)
		else
		(
			return mats[matat]
		)
	)
	
	local sea = undefined
	
	if classof mat == StandardMaterial then sea = compileStandardMaterial mat
	else if classof mat == InkNPaint then sea = compileInkMaterial mat
	else if classof mat == VRayMtl then sea = compileVRayMaterial mat
	else if classof mat == VRayLightMtl then sea = compileVRayLightMaterial mat	
	
	if sea != undefined then
	(
		append seaMaterialList sea
		append names sea.obj.name
		append mats sea
	)
	
	return sea
)

fn compileObject n =
(
	local seaobj = undefined
	
	if SuperClassOf n == GeometryClass then
	(			
		if classof n == Editable_Mesh then
		(
			if classof n.modifiers[1] == EmptyModifier then
			(
				local spriteMode = undefined
				
				try
				(
					local _mod = custAttributes.get n.modifiers[1] 1
					
					if _mod.name == "SEA3DSpriteDef" then
					(
						spriteMode = _mod
					)
				)
				catch()
				
				if spriteMode != undefined and spriteMode.enabledparam then
				(
					local mats = #(undefined)
					
					if n.material != undefined then
					(
						mats[1] = compileMaterial n.material seamatnames seamats
						
						if mats[1] == undefined then
						(
							warning2012 n.material.name n.name
						)
					)
					
					appendSceneObject n
					
					append seaObjectList (seaobj = (SEASprite n spriteMode mats))
					
					continue
				)
			)	
		)
		
		if (classOfList n seaCompatibleMeshList) then
		(
			appendSceneObject n
			
			local instanceIndex = undefined
			
			if (isValidInstancing()) and seaconfig_snapshot == false then
				instanceIndex = getInstanceIndex n
			else
				instanceIndex = 0
			 
			local skinAt = 0
			local morphAt = 0					
			local smoothAt = 0
			local editNormalsAt = 0
			local colorAt = 0
			
			local attribs = undefined
			local tag = undefined
			
			if seaconfig_joinvertices do
			(
				local joinVertices = undefined
				
				for m=1 to n.modifiers.count do				
				(
					if classof n.modifiers[m] == VertexWeld then
					(
						joinVertices = n.modifiers[m]
						exit
					)
				)
				
				if joinVertices == undefined then
				(
					joinVertices = VertexWeld()
					joinVertices.Name = "SEA3D Joint Identical Vertices"
					
					with animate off
					(
						joinVertices.threshold = .001
					)
				
					addModifier n joinVertices					
					
					append seaModifierList (SEAMod n joinVertices)										
				)
			)						
			
			local obj = seaObjectTemp = copy n
			
			obj.wirecolor = n.wirecolor
			
			-- Bake Textures
			if seaconfig_renderall then
			(
				n.renderable = false
				
				if seaconfig_relativesize then
				(
					local bakeSize = ceil (seaconfig_minbakesize + ((seaconfig_bakesize - seaconfig_minbakesize) * seamasslist[i]))
					bakeMesh obj size:(getPowerOf2 bakeSize)
				)
				else
				(
					bakeMesh obj
				)
				
				obj.renderable = false				
				n.renderable = true
			)
			
			-- Modifiers
			if instanceIndex == 0 do
			(
				for m=1 to obj.modifiers.count do				
				(
					if (ClassOf obj.modifiers[m] == EmptyModifier and obj.modifiers[m].enabled) then 
					(
						local modType = 0
						
						try
						(
							local md = custAttributes.get obj.modifiers[m] 1								
							if md.name == "SEA3DTagDef" then
							(
								if tag == undefined then
								(
									tag = obj.modifiers[m]
									modType = 1
								)
							)
						)
						catch()	
						
						if modType == 0 then 
						( 
							try
							(
								-- contains attribs
								for objDef in (custAttributes.getDefs obj.modifiers[m]) do ()									
								attribs = obj.modifiers[m]
							)
							catch()																		
						)
					)
					else if (ClassOf obj.modifiers[m] == Skin and obj.modifiers[m].enabled) then 
					(
						skinAt = m
						--warning2003 n.name
					)
					else if (ClassOf obj.modifiers[m] == Morpher and obj.modifiers[m].enabled) then 
					(
						morphAt = m
						--warning2004 n.name				
					)
					else if (ClassOf obj.modifiers[m] == VertexPaint and obj.modifiers[m].enabled) then 
					(
						colorAt = m
						--warning2004 n.name				
					)
					else if (ClassOf obj.modifiers[m] == EditNormals and obj.modifiers[m].enabled) then 
					(
						editNormalsAt = m
						--warning2004 n.name				
					)
					else if (ClassOf obj.modifiers[m] == VertexWeld and obj.modifiers[m].enabled and joinVertices != undefined) then 
					(
						with animate off
						(
							obj.modifiers[m].threshold = joinVertices.threshold			
						)						
					)
					else if 
						(
						(classof obj.modifiers[m] == MeshSmooth or
						classof obj.modifiers[m] == TurboSmooth) and obj.modifiers[m].enabled
						) then
					(
						smoothAt = m
					)							
				)
			)
			
			-- Convert to Mesh				
			local smoothObj = undefined
			local skinObj = undefined
			local colorObj = undefined
			local morphObj = undefined			
			local morphAnmObj = undefined
			local vertexAnm = false
			local boneList = undefined
			local boneNames = undefined
			local boneParentList = undefined
			local boneIndexList = undefined
			local bindpos = undefined	
			local smoothing_group = seaconfig_sg
			
			if tag != undefined then
			(					
				if seaconfig_vertexanimation and tag.m_vertexanmparam then
				(
					skinAt = 0
					morphAt = 0
					vertexAnm = true										
				)
				
				smoothing_group = tag.m_sgparam			
			)
			else
			(
				if seaconfig_skeleton == false then ( skinAt = 0 )
				if seaconfig_morph == false then ( morphAt = 0 )
				if seaconfig_attrib == false then ( attribs = undefined )
			)
			
			if colorAt > 0 do
				colorObj = obj.modifiers[colorAt]
			
			if seaconfig_snapshot == false do
			(
				if skinAt > 0 then
					skinObj = obj.modifiers[skinAt]
				
				if morphAt > 0 then
				(
					morphObj = obj.modifiers[morphAt]
					morphAnmObj = n.modifiers[morphAt]
				)
				
				if smoothAt > 0 then
					smoothObj = obj.modifiers[smoothAt]
			)
			
			-- Morph							
			local mchs = #()
			local mchsValue = #()
			local mchsName = #()
			
			if morphObj != undefined then
			(										
				selectMod obj morphObj				
				
				for ch=1 to 100 do
				(					
					if ((WM3_MC_HasData morphObj ch) and
					(WM3_MC_IsActive morphObj ch)) then
					(																	
						local morphName = WM3_MC_GetName morphObj ch
						
						local validMorphName = (findItem mchsName morphName) == 0
						
						if seaconfig_auto_rename and validMorphName == false do
						(
							WM3_MC_SetName morphObj ch (getValidName morphName mchsName)
							morphName = WM3_MC_GetName morphObj ch
							validMorphName = true
						)
						
						if validMorphName then
						(
							append mchs ch																	
							append mchsValue (WM3_MC_GetValue morphObj ch)
							append mchsName morphName
						)
						else
						(
							error1005 n.name
						)
					)
				)
				
				if mchs.count == 0 then		
					morphObj = undefined
				
				morphObj.enabled = false
			)
			
			-- Initial config
			seatime seaTimeRange[1]		
			
			-- Convert to compatible format
			local isMeshAnimated = skinObj != undefined or morphObj != undefined or vertexAnm
			
			selectMod obj undefined
			
			if isMeshAnimated and smoothAt > 0 then
				deleteModifier obj smoothAt											
			
			if obj.modifiers.count > 0 then
				modPanel.setCurrentObject obj.modifiers[1]
			else modPanel.setCurrentObject obj
			
			local meshObj = undefined
			
			local invertedScale = obj.scale.x < 0 or obj.scale.y < 0 or obj.scale.z < 0
			local invertNormal = (seaconfig_snapshot or seaconfig_positive_scale) and invertedScale
			
			if invertNormal do
			(
				local flipNormal = NormalModifier flip:true
				flipNormal.name = "SEA3D Invert Normal"
				
				addmodifier obj flipNormal
			)
			
			if classof obj != Editable_Mesh then
			(
				meshObj = Edit_Mesh()
				meshObj.name = "SEA3D Mesh"
				
				modPanel.addModToSelection meshObj		
			)
			
			if isMeshAnimated and smoothAt > 0 then
				addModifier obj smoothObj before:obj.modifiers.count			
			
			-- Normals
			local normalObj = undefined
			local removeTrans = seaconfig_snapshot == false and skinObj == undefined
				
			if smoothing_group then
			(
				normalNObj = copy obj
				normalNObj.renderable = false
				
				if removeTrans do 
				(
					normalNObj.parent = undefined
					removeObjectTransform normalNObj					
				)
				
				normalObj = Edit_Normals()
				normalObj.name = "SEA3D Normals"	
				
				addModifier normalNObj normalObj
				
				selectMod normalNObj normalObj	

				if editNormalsAt > 0 or (getnumverts obj) != (normalObj.GetNumNormals()) then
				(
					local nA = (GetNormal obj 1) as point3
					nA.x = roundNum nA.x
					nA.y = roundNum nA.y
					nA.z = roundNum nA.z
					
					local nB = (normalObj.EditNormalsMod.GetNormal 1) as point3
					nB.x = roundNum nB.x
					nB.y = roundNum nB.y
					nB.z = roundNum nB.z
					
					local needXForm = nA.x != nB.x or nA.y != nB.y or nA.z != nB.z
					
					if needXForm and skinObj == undefined and vertexAnm == false then
					(
						deleteModifier normalNObj normalObj
						resetXForm normalNObj			
						addModifier normalNObj normalObj					
					)
				)
				else
				(
					delete normalNObj
					
					normalNObj = undefined
					normalObj = undefined
					
					smoothing_group = false
				)
			)
			
			-- Get Bones
			if skinObj != undefined do
			(
				selectMod obj skinObj													
				
				-- skeleton
				numbones = skinops.getnumberbones skinObj
				
				-- sort dependencies
				boneList =  #()		
				boneNames = #()
				for i=1 to numbones do
				(
					local boneobjname = skinops_getBoneNameByListID skinObj i 0					
					local bonenode = getnodebyname boneobjname
					
					if (findItem boneNames boneobjname) > 0 do 
					(
						if seaconfig_auto_rename then bonenode.name = getValidName boneobjname boneNames
						else error1004 boneobjname
					)
					
					boneList[i] = bonenode
					boneNames[i] = bonenode.name
				)
				
				boneIndexList = sortHierarchy boneList (getDepthList boneList)						
				
				appendBones n boneList
				
				boneParentList = #()
				for i=1 to numbones do
				(
					local pr = boneList[i].parent
						
					-- get real parent bone
					if pr != undefined then (												
						while pr != undefined and (findItem boneList pr) == 0 do (
							pr = pr.parent
						)								
					)
					
					if (findItem boneList pr) == 0 do
						pr = undefined
					
					boneParentList[i] = pr
				)		

				-- bind position
				if seaconfig_bindoffset then 
				(
					seatime seaconfig_bindframe
					
					local matRelative = boneList[1].transform

					if seauseboneparent and boneParentList[1] != undefined do
						matRelative *= inverse boneParentList[1].transform
					
					bindpos = matRelative.position
				)		
				else bindpos = [0,0,0]
			)
			
			selectMod obj meshObj
			
			-- Separate Material			
			local polymats = #()		
			local mats = #()										
			
			local numfaces = getnumfaces obj	
			for f = 1 to numfaces do
			(
				local m = getfacematid obj f								
				if polymats[m] == undefined do polymats[m] = #()		
				append polymats[m] f
			)
			
			-- get materials
			if seaconfig_material and obj.material != undefined do
			(
				local cmat = compileMaterial obj.material seamatnames seamats
				
				if cmat != undefined then
				(					
					for m=1 to polymats.count do
					(
						if polymats[m] != undefined do 
						(								
							mats[m] = cmat
						)
					)
				)
				else if classof obj.material == MultiMaterial then
				(
					for m=1 to obj.material.materiallist.count do
					(
						local matID = obj.material.materialIDList[m]
						
						if (polymats[matID] != undefined) do
						(
							local mat = obj.material.materiallist[m]
							
							mats[matID] = compileMaterial mat seamatnames seamats
							
							if mats[matID] == undefined then
							(
								warning2012 mat.name obj.name
							)
						)
					)
				)
				else
				(
					warning2012 obj.material.name obj.name
				)
			)							
			
			-- Organize Material				
			local r_polymats = #()		
			local r_mats = #()
			
			for m = 1 to polymats.count do
			(		
				if polymats[m] != undefined do 
				(												
					append r_polymats polymats[m]							
					append r_mats mats[m]
				)
			)
			
			polymats = r_polymats				
			mats = r_mats
			
			local sMesh = (seaobj = (SEAMesh n obj tag mats meshObj normalNObj normalObj smoothing_group skinObj morphObj morphAnmObj vertexAnm boneList boneParentList bindpos mchs mchsValue))
			
			sMesh.attribs = attribs			
			
			if instanceIndex > 0 then
			(
				if n != obj do delete obj
				if normalNObj != undefined do delete normalNObj
				local hmesh = seaObjectList[instanceIndex]
				sMesh.instanceOf = hmesh
				append hmesh.instances sMesh
			)
			else
			(
				local usenormal = sMesh.useNormal()
				local usevertexcolor = sMesh.useVertexColor() and n.mesh.numCPVVerts > 0
				local useskin = seaconfig_skeleton and skinObj != undefined
				
				if removeTrans do removeObjectTransform obj																	
				
				-- Get Struct
				local vertexcount = getnumverts obj
				local channelcount = (nummapsused obj) - 1
				
				if seaconfig_uv == false then channelcount = 0
				
				-- Organize UVs
				index = 1
				local uvs = #()		
				local uvsLength = #()
				for c = 1 to channelcount do
				(		
					try
					(
						meshop.getMapVert obj c 1
						uvs[index] = c
						index += 1
					)
					catch ()
					
					if (seaconfig_multiplechannel == false or seasingleuv) and index == 2 then			
						exit			
				)
				
				-- Get Real UV
				if uvs.count > 0 then
				(
					for c = 1 to uvs.count do
					(
						local uvCount = 1
						local uvCh = uvs[c]
						
						try
						(
							while true do
							(
								meshop.getMapVert obj uvCh uvCount
								uvCount+=1
							)
						)
						catch()
						
						append uvsLength (uvCount - 1)
					)
				)
				
				-- SEA3D - MESH 2.0
				
				local __vertex = #()		
				local __uv = #()		
				local __uvIndex = #()
				local __index = #()
				local __normal = #()
				local __normalIndex = #()					
				local __weights = #()
				local __color = #()
				local __colorIndex = #()				
				
				local maxweight = 0
				
				-- Get Vertex				
				if bindpos == undefined then
				(
					for v=1 to vertexcount do
					(								
						local vert = (GetVert obj v)
						append __vertex #(vert.x, vert.z, vert.y)
					)
				)
				else
				(
					for v=1 to vertexcount do
					(								
						local vert = (GetVert obj v)
						append __vertex #(vert.x - bindpos.x, vert.z - bindpos.z, vert.y - bindpos.y)
					)
				)
				
				-- Get VertexColor
				if usevertexcolor do
				(	
					local vcolor_count = (getnumfaces n.mesh)*3
					
					setNumCPVVerts n.mesh vcolor_count true
					
					for v=1 to vcolor_count do
					(						
						local vc = ((meshop.getMapVert n.mesh 0 v) * 255) as color
						--local vc = ((getVertColor n.mesh v) * 255) as color
						append __color #(vc.r, vc.g, vc.b)
					)
				)
				
				-- Get UV
				if uvs.count > 0 then
				(
					for c=1 to uvs.count do
					(		
						local channelID = uvs[c]
						local uvLength = uvsLength[c]		
						__uv[c] = #()
						for v=1 to uvLength do
						(	
							local uv = (meshop.getMapVert obj channelID v)								
							append __uv[c] #(uv.x, 1.0 - uv.y)
						)
					)
				)
				
				-- Get SubMeshes
				for m = 1 to polymats.count do
				(				
					local faces = polymats[m]
					
					__index[m] = #()
					__uvIndex[m] = #()
					
					for f = 1 to faces.count do 
					(				
						local poly = GetFace obj faces[f]				
						append __index[m] poly.x	
						append __index[m] poly.z
						append __index[m] poly.y
					)
					
					for c = 1 to uvs.count do
					(
						__uvIndex[m][c] = #()
						
						for f = 1 to faces.count do 
						(	
							local channelID = uvs[c]
							local vface = meshop.getMapFace obj channelID faces[f]
							
							append __uvIndex[m][c] vface.x				
							append __uvIndex[m][c] vface.z				
							append __uvIndex[m][c] vface.y			
						)
					)
					
					if usevertexcolor do
					(							
						for f = 1 to faces.count do 
						(										
							local vface = meshop.getMapFace obj 0 faces[f]
							
							append __colorIndex vface.x				
							append __colorIndex vface.z				
							append __colorIndex vface.y			
						)
					)
				)
				
				-- Get Normal		
				if smoothing_group then
				(
					selectMod normalNObj normalObj	
					
					local numNorms = normalObj.GetNumNormals()
					
					for v = 1 to numNorms do
					(							 												
						local normal = normalize (normalObj.EditNormalsMod.GetNormal v) as point3					
						append __normal #(normal.x, normal.z, normal.y)					
					)
					
					for m = 1 to polymats.count do
					(				
						local faces = polymats[m]
						local normalIndex = __normalIndex[m] = #()
						
						for f = 1 to faces.count do 
						(				
							local faceID = faces[f]				
							
							append normalIndex (normalObj.EditNormalsMod.GetNormalID faceID 1)
							append normalIndex (normalObj.EditNormalsMod.GetNormalID faceID 3)
							append normalIndex (normalObj.EditNormalsMod.GetNormalID faceID 2)
						)														
					)
					
					selectMod obj undefined
				)
				else if usenormal then
				(
					for v=1 to vertexcount do
					(
						local normal = GetNormal obj v													
						normal = normalize normal as point3
						append __normal #(normal.x,normal.z,normal.y)
					)
				)		
				
				-- Get Weights
				if useskin then (
					selectMod obj skinObj	
					
					for v = 1 to vertexcount do
					(
						local numweights = skinops.getvertexweightcount skinObj v
						local weights = #()
						
						for i = 1 to numweights do 
						(
							local boneid = skinops.getvertexweightboneid skinObj v i
							local weightval = skinops.getvertexweight skinObj v i						
							
							if weightval > 0 do
							(
								append weights #(boneIndexList[boneid]-1, weightval)
							)														
						)
						
						__weights[v] = weights
						
						if weights.count > maxweight then
							maxweight = weights.count
					)
				)
				
				-- CompileMesh :: Optimizer Mesh Process
				
				local HT = undefined 
				local indexAt = 1
				
				if seaconfig_meshoptimizer do 
				(
					HT = dotNetObject "Poonya.Utils.DictSN"					
				)
				
				local c_vertex = sMesh.c_vertex = #()
				local c_index = sMesh.c_index = #()
				local c_weights = sMesh.c_weights = #()
				local c_normal = sMesh.c_normal = #()
				local c_uv = sMesh.c_uv = #()
				local c_color = sMesh.c_color = #()
				local c_tangent = sMesh.c_tangent = #()
				
				-- e_ used for vertex and morph indexes
				local e_index = sMesh.e_index = #()
				local e_normal = sMesh.e_normal = #()
				
				sMesh.maxweight = maxweight
				
				for c = 1 to uvs.count do
					c_uv[c] = #()		
				
				for m = 1 to __index.count do
				(
					local _index = __index[m]
					local _uvIndex = __uvIndex[m]
					local _normalIndex = __normalIndex[m]
					
					c_index[m] = #()
					
					for f = 1 to _index.count do 
					(					
						-- Generate UniqueID
						local sharedIndex = _index[f] as string
						
						for c = 1 to _uvIndex.count do
							sharedIndex += "/" + (_uvIndex[c][f] as string)				
						
						if smoothing_group then
							sharedIndex += "/" + (_normalIndex[f] as string)				
						
						-- Creat Index or Shared
						if HT == undefined or (HT.contains sharedIndex) == false then
						(
							if HT != undefined do HT.add sharedIndex indexAt
							
							append c_index[m] indexAt
							
							e_index[indexAt] = _index[f]
							c_vertex[indexAt] = __vertex[_index[f]]
							
							for c = 1 to _uvIndex.count do
								c_uv[c][indexAt] = __uv[c][_uvIndex[c][f]]					
							
							if usevertexcolor then								
								c_color[indexAt] = __color[__colorIndex[f]]
							
							if usenormal then 
							(
								if smoothing_group then
								(																				
									e_normal[indexAt] = _normalIndex[f]
									c_normal[indexAt] = __normal[_normalIndex[f]]
								)
								else
								(
									e_normal[indexAt] = _index[f]
									c_normal[indexAt] = __normal[_index[f]]						
								)
								
								if seaconfig_tangent do							
									c_tangent[indexAt] = normalToTangent c_normal[indexAt]	
							)
							
							if useskin do							
								c_weights[indexAt] = __weights[_index[f]]							
							
							indexAt += 1
						)
						else
						(
							append c_index[m] (HT.get sharedIndex)
						)				
					)					
				)
				
				append seaObjectList sMesh
			)
			
			seaObjectTemp = undefined
		)
		else
		(
			warning2002 n.name
		)
	)		
	else if classof n == PointHelperObj then
	(										
		if classof n.modifiers[1] == EmptyModifier then
		(
			local soundMod = undefined
			
			try
			(
				local _mod = custAttributes.get n.modifiers[1] 1
				
				if _mod.name == "SEA3DSoundDef" then
				(
					soundMod = _mod
				)
			)
			catch()
			
			if soundMod != undefined and soundMod.enabledparam then
			(
				appendSceneObject n
				
				local soundName = soundMod.soundparam
						
				if soundName != undefined and soundName.count > 0 and (findItem sea_sounds_names soundName) > 0 then
				(
					append seaObjectList (seaobj = (SEASound n soundName soundMod))
				)
				else							
				(
					error1060 n.name soundName
				)															
			)
		)	
	)
	else if SuperClassOf n == Camera then
	(
		local tar = undefined
		
		if seaconfig_camera do
		(
			appendSceneObject n
			
			if seaconfig_cameratarget and n.type == #target then
			(			
				tar = SEADummy n.target "target"
				append seaObjectList tar
				appendSceneObject n.target
			)
		)				
		
		append seaObjectList (seaobj = (SEACamera n tar))
	)
	else if ClassOf n == Dummy then
	(
		if seaconfig_dummy do
			appendSceneObject n
		
		append seaObjectList (seaobj = (SEADummy n))
	)
	else if SuperClassOf n == Light then
	(
		if (classOfList n seaCompatibleLightList) then
		(
			if n.enabled do 
			(
				local tar = undefined
				
				if seaconfig_light do
				(
					appendSceneObject n
					
					if seaconfig_lighttarget and (n.type == #targetspot or n.type == #targetdirect) then
					(
						tar = SEADummy n.target "target"
						append seaObjectList tar
						appendSceneObject n.target																			
					)
				)
				
				append seaObjectList (seaobj = (SEALight n tar))
			)
		)
		else
		(
			warning2006 n.name
		)
	)
	else if SuperClassOf n == Shape then
	(
		append seaObjectList (seaobj = (SEASplines n))				
	)
	else
	(			
		warning2001 n.name
	)
					
	if seaobj != undefined then
	(
		local sea3dtag = getSEATag n		
		
		if sea3dtag != undefined then
		(
			local tagversion = 1.0
					
			try
			(			
				tagversion = sea3dtag.tagversion												
			)
			catch()
			
			if tagversion >= 1.1 then
			(
				seaobj.frame_rate = sea3dtag.a_framerateparam
			)
		)
	)
)

fn compileObjects list =
(
	seaprogressStart (color 0 119 212)
	
	-- Colleted Names
	seanames = #()
	seasceneobject = #()
	seaboneobject = #()
	seaboneinobject = #()
	seabonelist = #()
	
	sortHierarchy list (getDependenceList list)	
	
	local seamasslist = undefined
	
	if seaconfig_relativesize then
	(
		seamasslist = getMassList list
	)
	
	for i=1 to list.count do
	(
		local n = list[i]		
		if (findItem seanames n.name) > 0 do (
			if seaconfig_auto_rename then n.name = getValidName n.name seanames
			else error1001 n.name
		)		
		append seanames n.name
	)
		
	if (seaErrors.count>0) do 
		return seaErrors.count
	
	-- Compile Data
	seamats = #()		
	seamatnames = #()				
	seaactions = #()
	seadefaultsequence = undefined
	
	-- ENVIRONMENT
	if seaconfig_env then
	(	
		if seaconfig_envmap and useEnvironmentMap then
		(
			if classof environmentMap == CompositeTexturemap then
			(	
				local envmap = appendCubeTexture environmentMap "Environment" undefined false
				
				if envmap != undefined then
				(
					append seaObjectList envmap
					append seaactions (SEAAction ACT_ENVIRONMENT envmap)
				)			
			)
			else if environmentMap != undefined then
			(
				error1025 environmentMap.name
			)
		)
		
		if seaconfig_fog[1] then
		(
			local fogData = #(seaconfig_fog[2], seaconfig_fog[3], seaconfig_fog[4])			
			append seaactions (SEAAction ACT_FOG fogData)
		)
	)
	
	for i=1 to list.count do
	(
		seaprogressUpdate (((float i) / (float list.count)) * 100.0)
		
		if seabuild == false do return 0
		
		local n =  list[i]
		
		if seaconfig_exceptionprotection then
		(
			try
			(
				compileObject n 
			)
			catch
			(
				removeTempObject()
				warning2001 n.name
			)
		)
		else
		(
			compileObject n
		)
	)
	
	return seaErrors.count
)

--
--	Animation
--

function getAnimationSequence obj =
(
	local anmcfg = getUserProp obj DEF_ANIMATION_CONFIG
	if anmcfg == undefined then return undefined
	
	try
	(		
		anmseq = dotNetObject "Poonya.Utils.Hashtable"			
		anmseq.ReadBase64 anmcfg				
		
		if (anmseq.Contains "sequences") then
		(
			return (anmseq.Get "sequences")
		)
	)
	catch()
	
	return undefined
)

function getSequenceBounds obj sequence: =
(		
	if sequence == unsupplied do
	(
		sequence = getAnimationSequence obj
	)
	
	if sequence == undefined or sequence == unsupplied do return undefined
	
	local found = false
	
	local m_start = 0
	local m_end = 0		
	
	for i = 1 to sequence.Length do
	(
		local seq = sequence.Get (i-1)
		local enabled = seq.GetDef "enabled" true
		
		if enabled then
		(
			local start = (seq.GetDef "start" seaTimeRange[1]) as integer
			local end = (seq.GetDef "end" seaTimeRange[2]) as integer
			
			if found then
			(
				if (start < m_start) do
					m_start = start				
				
				if (end > m_end) do
					m_end = end	
			)
			else					
			(
				m_start = start
				m_end = end
				
				found = true
			)
		)
	)	
	
	if found then
	(
		return #(m_start, m_end)
	)
	
	return undefined
)

function openAnimation fr bounds: =
(
	seaTimeRange[3] = seaTimeRange[1]
	seaTimeRange[4] = seaTimeRange[2]
	seaTimeRange[5] = framerate	
	
	if bounds != undefined and bounds != unsupplied then 
	(
		seaTimeRange[1] = bounds[1] as integer
		seaTimeRange[2] = bounds[2] as integer
	)
	
	if fr != undefined and fr != unsupplied then 
	(
		framerate = fr
	)
)

function closeAnimation = 
(
	seaTimeRange[1] = seaTimeRange[3]
	seaTimeRange[2] = seaTimeRange[4]
	
	framerate = seaTimeRange[5]
)

function getSequenceData obj =
(
	local sequence = getAnimationSequence obj	 
	local bounds = getSequenceBounds obj sequence:sequence
	
	if sequence == undefined do return undefined
		
	local body = newNode()
	local names = #()
	
	for i = 1 to sequence.Length do
	(
		local seq = sequence.Get (i-1)				
		local enabled = seq.GetDef "enabled" true
		
		if enabled then
		(
			local name = replaceChar (seq.GetDef "name" "") "\n" ""
			local start = ((seq.GetDef "start" seaTimeRange[1]) as integer) - bounds[1]
			local end = ((seq.GetDef "end" seaTimeRange[2]) as integer) - bounds[1]
			local count = (end - start) + 1
			local repeat = seq.GetDef "repeat" true
			local intrpl = seq.GetDef "intrpl" true
			
			if (findItem names name) > 0 then
			(
				error1031 name obj.name
				return undefined
			)		
			
			local flag = 0x00			
			
			if repeat do
				flag += HEADER_REPEAT
			
			if intrpl == false do
				flag += HEADER_NOINTERPOLATION
			
			append names name
			
			body.WriteByte flag
			body.WriteUTF8 name
			body.WriteInt32 start
			body.WriteInt32 count
		)
	)	
	
	if names.count > 0 then 
	(			
		local data = newNode()
		
		data.WriteUInt16 names.count
		data.WriteData body
		
		return data
	)
	else undefined
)

function getMorphAnimationAsset sea =
(		
	openAnimation sea.frame_rate bounds:(getSequenceBounds sea.obj)
	
	local list = #()	
	local mchsAnim = #()
	local mchsAnimIndex = #()
	local obj = sea.morphAnmObj	
	local mchs = sea.mchs
	
	for ch=1 to mchs.count do
	(
		local m = mchs[ch]
		
		seatime seaTimeRange[1]		
		
		local f_value = (WM3_MC_GetValue obj m)
		
		for t = seaTimeRange[1] to seaTimeRange[2] do
		(
			seatime t				 			
			
			if f_value != (WM3_MC_GetValue obj m) do
			(			
				append mchsAnim mchs[ch]
				append mchsAnimIndex mchs[ch]				
				exit
			)
		)		
	)
	
	if mchsAnim.count == 0 do 
	(
		closeAnimation()
		return undefined
	)
		
	local asset = newAsset()
	local data = asset.Data

	-- MORPH
	asset.Filename = sea.obj.name + EXT_MORPH_ANIMATION
	
	writeAnimationHead data sequence:(getSequenceData sea.obj)
	
	data.WriteByte mchsAnim.count
	
	for ch=1 to mchsAnim.count do
	(
		local m = mchsAnim[ch]
		
		data.WriteUTF8 (WM3_MC_GetName obj m)
		
		for t = seaTimeRange[1] to seaTimeRange[2] do
		(
			seatime t
			
			data.WriteFloat ((WM3_MC_GetValue obj m) / 100.0)
		)		
	)
	
	closeAnimation()
	
	return asset
)

function getMorphAsset sea =
(
	local asset = newAsset()
	local data = asset.Data
	local obj = sea.temp		
	
	asset.Filename = sea.obj.name + EXT_MORPH
	
	-- GEOMETRY
		
	local c_vertex = sea.c_vertex
	local c_normal = sea.c_normal
	
	local e_index = sea.e_index
	local e_normal = sea.e_normal
	
	local __vertexBase = #()
	
	local bigMesh = c_vertex.count	> C_BIG		
	local WriteUInt = undefined
	
	if bigMesh then WriteUInt = data.WriteInt32
	else WriteUInt = data.WriteUInt16	
	
	local header = 0			
	if bigMesh do header += HEADER_BIGMESH
	
	local containsNormal = sea.c_normal.count > 0
	
	header += HEADER_VERTEX
	
	if containsNormal do header += HEADER_NORMAL
	
	-- MORPH
	
	local mchs = sea.mchs
	local mchsValue = sea.mchsValue
	
	if sea.skinObj != undefined do sea.skinObj.enabled = false		
	sea.morphObj.enabled = true
	
	selectMod obj sea.morphObj	
	
	for ch=1 to mchs.count do
	(	
		WM3_MC_SetValue sea.morphObj mchs[ch] 0.0
	)
	
	selectMod obj sea.meshObj	
	
	local usenormal = sea.useNormal()
	local vertexcount = getnumverts obj
	local normalNObj = sea.normalNObj
	local normalObj = sea.normalObj
	
	-- VERTEX BASE
	for v=1 to vertexcount do
	(
		append __vertexBase (GetVert obj v)
	)
	
	-- NORMAL BASE
	if containsNormal do 
	(
		local  __normalBase = #()
		
		if sea.smoothing_group then
		(							
			selectMod normalNObj normalObj	
			
			local numNorms = normalObj.GetNumNormals()
			
			for v = 1 to numNorms do
			(
				local normal = normalObj.EditNormalsMod.GetNormal v				
				append __normalBase (normalize normal as point3)
			)
		)
		else
		(
			for v=1 to vertexcount do
			(
				local normal =  GetNormal obj v																	
				append __normalBase (normalize normal as point3)
			)
		)
	)
	
	-- HEADER
	data.WriteUInt16 header
	
	-- VERTEX COUNT
	WriteUInt c_vertex.count	
	
	-- MORPH COUNT
	data.WriteUInt16 mchs.count	
	
	for ch=1 to mchs.count do
	(	
		selectMod obj sea.meshObj
		
		data.WriteUTF8 (WM3_MC_GetName sea.morphObj mchs[ch])
		
		WM3_MC_SetValue sea.morphObj mchs[ch] 100.0
		
		local __vertex = #()
		
		for v=1 to vertexcount do
		(
			local vert = GetVert obj v
			
			append __vertex #(
				vert.x - __vertexBase[v].x, 
				vert.z - __vertexBase[v].z, 
				vert.y - __vertexBase[v].y
			)
		)
		
		for v=1 to e_index.count do
		(
			data.WriteFloat __vertex[e_index[v]][1]
			data.WriteFloat __vertex[e_index[v]][2]
			data.WriteFloat __vertex[e_index[v]][3]
		)
		
		if containsNormal do 
		(					
			local  __normal = #()
			
			if sea.smoothing_group then
			(							
				selectMod normalNObj normalObj	
				
				local numNorms = normalObj.GetNumNormals()
				
				for v = 1 to numNorms do
				(
					local normal = normalObj.EditNormalsMod.GetNormal v
					normal = normalize normal as point3					
					append __normal #(
						normal.x - __normalBase[v].x, 
						normal.z - __normalBase[v].z, 
						normal.y - __normalBase[v].y
					)						
				)								
			)
			else
			(
				for v=1 to vertexcount do
				(
					local normal =  GetNormal obj v													
					normal = normalize normal as point3
					append __normal #(
						normal.x - __normalBase[v].x,
						normal.z - __normalBase[v].z,
						normal.y - __normalBase[v].y
					)
				)
			)

			for v=1 to e_normal.count do
			(							
				data.WriteFloat __normal[e_normal[v]][1] 
				data.WriteFloat __normal[e_normal[v]][2]
				data.WriteFloat __normal[e_normal[v]][3]
			)						
		)
		
		WM3_MC_SetValue sea.morphObj mchs[ch] 0.0
	)
	
	-- Restore Default
	for ch=1 to mchs.count do
	(	
		WM3_MC_SetValue sea.morphObj mchs[ch] mchsValue[ch]
	)			
	
	if sea.skinObj != undefined do sea.skinObj.enabled = true	
	sea.morphObj.enabled = false	
	
	return asset
)

function getVertexAnimationAsset sea =
(
	openAnimation sea.frame_rate bounds:(getSequenceBounds sea.obj)
	
	local obj = sea.temp	
	local c_vertex = sea.c_vertex
	local e_index = sea.e_index
	local e_normal = sea.e_normal
	local useNormal = sea.useNormal()
	local vertexcount = getnumverts obj
	local normalObj = sea.normalObj
	local normalNObj = sea.normalNObj
	local normalObjAnm = undefined
	
	if seaconfig_snapshot == false then
		removeObjectTransform obj
	
	if useNormal and sea.smoothing_group do
	(
		normalObjAnm = Edit_Normals()
		normalObjAnm.name = "SEA3D Normals Animated"	
		
		addModifier obj normalObjAnm
	)
	
	selectMod obj undefined
	
	-- VERTEX ANIMATION
	seatime seaTimeRange[1]
	
	local asset = newAsset()
	local data = asset.Data	
	
	asset.Filename = sea.obj.name + EXT_VERTEX_ANIMATION	
	
	writeAnimationHead data sequence:(getSequenceData sea.obj)
	
	local bigMesh = c_vertex.count	> C_BIG		
	local WriteUInt = undefined
	
	if bigMesh then WriteUInt = data.WriteInt32
	else WriteUInt = data.WriteUInt16	
	
	local header = 0x00
	
	header += HEADER_VERTEX
	
	if bigMesh do header += HEADER_BIGMESH	
	if useNormal do header += HEADER_NORMAL
	
	data.WriteByte header
	WriteUInt c_vertex.count
	
	local c = 0
	
	for t = seaTimeRange[1] to seaTimeRange[2] do
	(
		seatime t
		
		local __vertex = #()
		
		for v=1 to vertexcount do
		(
			local vert = GetVert obj v
			append __vertex #(
				vert.x, 
				vert.z, 
				vert.y
			)
		)
		
		for v=1 to e_index.count do
		(
			data.WriteFloat __vertex[e_index[v]][1]
			data.WriteFloat __vertex[e_index[v]][2]
			data.WriteFloat __vertex[e_index[v]][3]
		)
		
		if useNormal do 
		(
			local  __normal = #()
			
			if normalObjAnm != undefined then
			(
				selectMod obj normalObjAnm	
				
				local numNorms = normalObjAnm.GetNumNormals()
				
				for v = 1 to numNorms do
				(
					local normal = normalObjAnm.EditNormalsMod.GetNormal v
					normal = normalize normal as point3					
					append __normal #(
						normal.x, 
						normal.z, 
						normal.y
					)						
				)
			)
			else
			(
				for v=1 to vertexcount do
				(
					local normal =  GetNormal obj v													
					normal = normalize normal as point3
					append __normal #(
						normal.x,
						normal.z,
						normal.y
					)
				)
			)

			for v=1 to e_normal.count do
			(							
				data.WriteFloat __normal[e_normal[v]][1] 
				data.WriteFloat __normal[e_normal[v]][2]
				data.WriteFloat __normal[e_normal[v]][3]
			)						
		)		
	)
	
	closeAnimation()
	
	if normalObjAnm != undefined do
	(
		deleteModifier obj normalObjAnm
	)
	
	return asset
)

function getSkeletonAnimationAsset sea =
(
	openAnimation sea.frame_rate bounds:(getSequenceBounds sea.obj)
	
	local asset = newAsset()
	local data = asset.Data	
	
	asset.Filename = sea.obj.name + EXT_SKELETON_ANIMATION
	
	-- SKELETON ANIMATION
	seatime seaTimeRange[1]
	
	writeAnimationHead data sequence:(getSequenceData sea.obj)			
	
	local numbones = sea.boneList.count
	
	data.WriteUInt16 numbones
	
	for t = seaTimeRange[1] to seaTimeRange[2] do
	(
		seatime t
		
		for i = 1 to numbones do
		(
			writeBone data sea.boneList[i] SEA_QUATERNION parent:sea.boneParentList[i] bindpos:sea.bindpos 
		)		
	)
	
	closeAnimation()
	
	return asset
)

function processToken data obj token p: t: tp: offsetRotation: =
(
	local key = token[1]
	
	if key == ANM_POSITION then (
		writePosition data obj p:p t:t tp:tp
	)
	else if key == ANM_ROTATION then (
		writeRotation data obj p:p t:t tp:tp offset:offsetRotation
	)
	else if key == ANM_SCALE then (
		writeScale data obj p:p t:t tp:tp
	)
	
	else if key == ANM_FOV then (
		data.WriteFloat obj.fov
	)
	
	else if key == ANM_COLOR then (
		writeColor data obj.rgb
	)
	else if key == ANM_MULTIPLIER then (
		data.WriteFloat obj.multiplier
	)
	
	else if key == ANM_ATTENUATION_START then (
		data.WriteFloat obj.farAttenStart
	)
	else if key == ANM_ATTENUATION_END then (
		data.WriteFloat obj.farAttenEnd
	)
	
	else if key == ANM_OFFSET_U then (
		data.WriteFloat -obj.coords.U_Offset
	) 
	else if key == ANM_OFFSET_V then (
		data.WriteFloat obj.coords.V_Offset
	) 
	else if key == ANM_SCALE_U then (
		data.WriteFloat obj.coords.U_Tiling
	)
	else if key == ANM_SCALE_V then (
		data.WriteFloat obj.coords.V_Tiling
	)				
	else if key == ANM_ANGLE then (
		data.WriteFloat obj.coords.W_Angle
	) 
	
	else if key == ANM_VOLUME then (
		data.WriteFloat obj.volumeParam
	) 
	
	else  (
		warning2501 key
	)
)

function processAnimation obj data tokenList offsetRotation: loader: type: =
(
	local parent = undefined, transform = undefined, transform_parent = undefined
	
	if type == EXT_SCENE_OBJECT then
	(				
		parent = realParent obj
		
		if seaconfig_bindoffset then
		(
			if parent == undefined then 
			(	
				seatime seaconfig_bindframe							
				
				transform = obj.transform
				
				if offsetRotation != unsupplied do 
				(
					transform = rotateMatrix transform offsetRotation
				)
			)
			else
			(
				--relative for all
				--transform_parent = obj.transform
			)
		)
	)
	
	if seauseparent == false do parent = undefined
	
	if loader == unsupplied then 
		loader = "block"
	
	-- count
	data.WriteByte tokenList.count
	
	if loader == "block" then
	(
		-- Block
		for i=1 to tokenList.count do
		(
			local token = tokenList[i]
			data.WriteUInt16 token[1]		
			data.WriteByte token[2]
			
			for t = seaTimeRange[1] to seaTimeRange[2] do
			(
				seatime t
				
				processToken data obj token p:parent t:transform tp:transform_parent offsetRotation:offsetRotation
			)
		)
	)
	else if loader == "stream" then
	(
		-- Head
		for i=1 to tokenList.count do
		(
			local token = tokenList[i]
			data.WriteUInt16 token[1]	
			data.WriteByte token[2]
		)
		
		-- Body
		for t = seaTimeRange[1] to seaTimeRange[2] do
		(
			seatime t
			
			for i=1 to tokenList.count do
			(
				processToken data obj tokenList[i] p:parent t:transform tp:transform_parent offsetRotation:offsetRotation 
			)			
		)
	)
)

function getMeshAnimationAsset obj frame_rate: =
(
	openAnimation frame_rate bounds:(getSequenceBounds obj)
	
	local tokenList = #()
	
	if (containsInvalidParentAnimation obj) then
	(
		append tokenList #(ANM_POSITION,74) -- position, vector3D
		append tokenList #(ANM_ROTATION,106)  -- rotation, vector4D
		append tokenList #(ANM_SCALE,74) -- scale, vector3D
	)
	else
	(
		if containsPosition obj do 
			append tokenList #(ANM_POSITION,74) -- position, vector3D
		
		if containsRotation obj do 
			append tokenList #(ANM_ROTATION,106) -- rotation, vector4D
		
		if containsScale obj do 
			append tokenList #(ANM_SCALE,74) -- scale, vector3D
	)
	
	if tokenList.count == 0 do 
	(
		closeAnimation()
		return undefined
	)
	
	-- MESH ANIMATION
	local asset = newAsset()
	local data = asset.Data		
	
	asset.Filename = obj.name + EXT_ANIMATION
	
	writeAnimationHead data sequence:(getSequenceData obj)
	
	processAnimation obj data tokenList type:EXT_SCENE_OBJECT
	
	closeAnimation()
	
	return asset
)

function getCompositeAnimationAsset obj nm model: frame_rate: type: =
(		
	openAnimation frame_rate bounds:(getSequenceBounds model)
	
	local tokenList = getCompositeAnimationTokenList obj

	if tokenList.count == 0 do 
	(
		closeAnimation()
		return undefined
	)
	
	-- TEXTURE ANIMATION
	local asset = newAsset()
	local data = asset.Data	
	
	if type == unsupplied or type == undefined do
		type = EXT_ANIMATION
	
	asset.Filename = nm + type
	
	writeAnimationHead data sequence:(getSequenceData model)
	
	processAnimation obj data tokenList
		
	closeAnimation()
	
	return asset
)

function getDummyAnimationAsset obj frame_rate: =
(	
	openAnimation frame_rate bounds:(getSequenceBounds obj)
	
	local tokenList = #()
	
	if (containsInvalidParentAnimation obj) then
	(
		append tokenList #(ANM_POSITION,74) -- position, vector3D
		append tokenList #(ANM_ROTATION,106) -- rotation, euler_vector4d
		append tokenList #(ANM_SCALE,74) -- scale, vector3D
	)
	else
	(
		if containsPosition obj do 
			append tokenList #(ANM_POSITION,74) -- position, vector3D
		
		if containsRotation obj do 
			append tokenList #(ANM_ROTATION,106) -- rotation, euler_vector4d
		
		if containsScale obj do 
			append tokenList #(ANM_SCALE,74) -- scale, vector3D
	)
	
	if tokenList.count == 0 do 
	(
		closeAnimation()
		return undefined
	)
	
	local asset = newAsset()
	local data = asset.Data
	
	asset.Filename = obj.name + EXT_ANIMATION
	
	writeAnimationHead data sequence:(getSequenceData obj)
	
	processAnimation obj data tokenList type:EXT_SCENE_OBJECT
	
	closeAnimation()
	
	return asset
)

function getCameraAnimationAsset obj frame_rate: =
(	
	openAnimation frame_rate bounds:(getSequenceBounds obj)
	
	local tokenList = #()
	
	local userotation = obj.type != #target or (seaconfig_cameratarget == false)
	
	if (containsInvalidParentAnimation obj) then
	(
		append tokenList #(ANM_POSITION,74) -- position, vector3D
		append tokenList #(ANM_ROTATION,106) -- rotation, euler_vector4d
	)
	else
	(
		if containsPosition obj do 
			append tokenList #(ANM_POSITION,74) -- position, vector3D
		
		if userotation and (containsRotation obj) do 
			append tokenList #(ANM_ROTATION,106) -- rotation, euler_vector4d
	)
	
	if obj.fov.isAnimated do 
		append tokenList #(ANM_FOV,10) --  fov, rgb
	
	if tokenList.count == 0 do 
	(
		closeAnimation()
		return undefined
	)
	
	local asset = newAsset()
	local data = asset.Data		
	
	asset.Filename = obj.name + EXT_ANIMATION
	
	writeAnimationHead data sequence:(getSequenceData obj)
	
	processAnimation obj data tokenList offsetRotation:[-90,0,0] type:EXT_SCENE_OBJECT
	
	closeAnimation()
	
	return asset
)

function getLightAnimationAsset obj frame_rate: =
(		
	openAnimation frame_rate bounds:(getSequenceBounds obj)
	
	local tokenList = #()
	
	local userotation = obj.type != #target or (seaconfig_lighttarget == false)

	if (containsInvalidParentAnimation obj) then
	(
		append tokenList #(ANM_POSITION,74) -- position, vector3D
		append tokenList #(ANM_ROTATION,106) -- rotation, vector4d
	)
	else
	(
		if containsPosition obj do 
			append tokenList #(ANM_POSITION,74) -- position, vector3D
		
		if userotation and (containsRotation obj) do 
			append tokenList #(ANM_ROTATION,106) -- rotation, vector4d
	)
	
	if obj.rgb.isAnimated do 
		append tokenList #(ANM_COLOR,7) -- color, uint24
	
	if obj.multiplier.isAnimated do 
		append tokenList #(ANM_MULTIPLIER,10) -- multiplier, float	
	
	if obj.useFarAtten and obj.farAttenStart.isAnimated do 
		append tokenList #(ANM_ATTENUATION_START,10) -- attenStart, float
	
	if obj.useFarAtten and obj.farAttenEnd.isAnimated do 
		append tokenList #(ANM_ATTENUATION_END,10) -- attenEnd, float
	
	if tokenList.count == 0 do 
	(
		closeAnimation()
		return undefined
	)
	
	local asset = newAsset()
	local data = asset.Data		
	
	asset.Filename = obj.name + EXT_ANIMATION
	
	writeAnimationHead data sequence:(getSequenceData obj)
	
	local offsetRotation = unsupplied 
	
	if obj.type != #omni do 
		offsetRotation = [-90,0,0]
	
	processAnimation obj data tokenList offsetRotation:offsetRotation type:EXT_SCENE_OBJECT
	
	closeAnimation()
	
	return asset
)

function getSound3DAnimationAsset obj soundMod frame_rate: =
(	
	openAnimation frame_rate bounds:(getSequenceBounds obj)
	
	local tokenList = #()
		
	if soundMod.volumeParam.isAnimated do 
		append tokenList #(ANM_VOLUME,10) -- volume, float
	
	if tokenList.count == 0 do 
	(
		closeAnimation()
		return undefined
	)
	
	-- SOUND
	local asset = newAsset()
	local data = asset.Data		
	
	asset.Filename = obj.name + EXT_ANIMATION
	
	writeAnimationHead data sequence:(getSequenceData obj)
	
	processAnimation soundMod data tokenList type:EXT_SCENE_OBJECT
	
	closeAnimation()
	
	return asset
)

--
-- Tags
--

function getLookAtTag n =
(
	local data = newNode()
	data.WriteInt32 (getAssetIndex n EXT_SCENE_OBJECT)
)

--
-- SceneObject
--

function getSoundAsset name =
(
	local soundAt = (findItem sea_sounds_names name)
	local filename = sea_sounds[soundAt][1]	
	
	if (fileExist filename) == false then
	(
		error1201 sea.obj.name
		return undefined
	)
	
	local asset = newAsset()
	local data = asset.Data	
		
	asset.Filename = name + (getExtension filename)
		
	data.ReadFile filename
		
	return asset
)

function getTextureAsset sea =
(
	local asset = newAsset()
	local data = asset.Data
	
	local filename = undefined
	
	if sea.bake != undefined then
	(
		filename = sea.bake
	)
	else filename = sea.filename
	
	local extension = getExtension filename
	
	if ATF_SUPPORTS and seaconfig_atf then
	(
		local atf_filename = (getCleanFilename filename) + EXT_ATF
		
		if extension == EXT_PNG or extension == EXT_DDS then
		(			
			local FileClass = dotNetClass "System.IO.File"			
			local invalidate = fileExist (atf_filename) == false
			
			if invalidate == false and seaconfig_atf_auto then
			(			
				local fileDate = FileClass.GetLastWriteTime filename
							
				local dateA = FileClass.GetLastWriteTime filename
				local dateB = FileClass.GetLastWriteTime atf_filename
				
				invalidate = ((dateA.Equals dateB) == false) or seaconfig_atf_force
			)
			
			if invalidate then
			(
				local cmd = ""			
				
				cmd += " -i \"" + filename + "\"" -- input
				cmd += " -o \"" + atf_filename + "\"" -- output
				
				local ProcessClass = dotNetClass "System.Diagnostics.Process"						
				
				if extension == EXT_PNG then
				(
					if seaconfig_atf_compress == ENC_ALL then cmd += " -c -"
					else if seaconfig_atf_compress == ENC_DXT then cmd += " -c d"
					else if seaconfig_atf_compress == ENC_ETC1 then cmd += " -c e"
					else if seaconfig_atf_compress == ENC_PVRTC then cmd += " -c p"
					
					if seaconfig_atf_jpegxr do cmd += " -r"
					
					local process = ProcessClass.Start ATF_PNG_TO_ATF cmd							
					process.WaitForExit()				
					
					if process.ExitCode == 0 then
					(
						FileClass.SetLastWriteTime atf_filename (FileClass.GetLastWriteTime filename)
					)
					else
					(
						error1401 ((getName filename) + (getExtension filename))
					)								
				)
				else if extension == EXT_DDS then
				(
					local process = ProcessClass.Start ATF_DDS_TO_ATF cmd				
					process.WaitForExit()				
					
					if process.ExitCode == 0 then
					(
						FileClass.SetLastWriteTime atf_filename (FileClass.GetLastWriteTime filename)
					)
					else
					(
						error1401 ((getName filename) + (getExtension filename))
					)	
				)			
			)						
		)
		
		if fileExist (atf_filename) then
		(
			filename = atf_filename
		)
		else
		(
			warning2401 (getName filename)
		)
	)
		
	asset.Filename = (getName filename) + (getExtension filename)
	assetCompressed = seaconfig_compress_texture
	
	data.ReadFile filename	
	
	return asset
)

function getSingleCubeAsset sea =
(
	local asset = newAsset()
	local data = asset.Data	
	
	local filename = sea.bitmaps[1]
	
	local name = getName sea.obj.name
	local extension = getExtension filename
	
	if ATF_SUPPORTS and seaconfig_atf then
	(
		local atf_filename = (getCleanFilename filename) + EXT_ATF
		
		if extension == EXT_DDS then
		(			
			local FileClass = dotNetClass "System.IO.File"
			
			local invalidate = fileExist (atf_filename) == false
			
			if invalidate == false and seaconfig_atf_auto then
			(
				local fileDate = FileClass.GetLastWriteTime filename
							
				local dateA = FileClass.GetLastWriteTime filename
				local dateB = FileClass.GetLastWriteTime atf_filename
				
				invalidate = ((dateA.Equals dateB) == false) or seaconfig_atf_force
			)
			
			if invalidate then
			(
				local cmd = ""			
				
				cmd += " -i \"" + filename + "\"" -- input
				cmd += " -o \"" + atf_filename + "\"" -- output
				
				local ProcessClass = dotNetClass "System.Diagnostics.Process"						
				
				local process = ProcessClass.Start ATF_DDS_TO_ATF cmd				
				process.WaitForExit()				
				
				if process.ExitCode == 0 then
				(
					FileClass.SetLastWriteTime atf_filename (FileClass.GetLastWriteTime filename)
				)
				else
				(
					error1401 ((getName filename) + (getExtension filename))
				)			
			)
		)
		
		if fileExist (atf_filename) then
		(
			filename = atf_filename
		)
		else
		(
			warning2401 (getName filename)
		)
	)
	
	if (getExtension filename) == EXT_ATF then
	(
		asset.Filename = name + EXT_ATF_CUBE
	)
	else
	(
		asset.Filename = name + EXT_SINGLE_CUBE_MAPPING			
		data.WriteTypeCode (getCleanExtension sea.bitmaps[1])
	)
	
	asset.Compressed = seaconfig_compress_texture		
	
	data.ReadFile filename
	
	return asset
)

function getCubeAsset sea =
(
	local asset = newAsset()
	local data = asset.Data	
	
	local filename = sea.bitmaps[1]
	
	local name = getName sea.obj.name
	local extension = getExtension filename
	
	if ATF_SUPPORTS and seaconfig_atf then
	(
		local atf_filename = (getCleanFilename sea.bitmaps[1]) + EXT_ATF
		
		if extension == EXT_PNG then
		(			
			local tex_path = (getDir #image) + "\\SEA3D_CUBE_TEMP"
			
			local ProcessClass = dotNetClass "System.Diagnostics.Process"				
			local FileClass = dotNetClass "System.IO.File"			
			
			local invalidate = fileExist (atf_filename) == false
			
			if invalidate == false and seaconfig_atf_auto then
			(			
				local fileDate = FileClass.GetLastWriteTime filename
							
				local dateA = FileClass.GetLastWriteTime filename
				local dateB = FileClass.GetLastWriteTime atf_filename
				
				invalidate = ((dateA.Equals dateB) == false) or seaconfig_atf_force
			)
			
			if invalidate then
			(
				-- Create Temp's
				for i=1 to 6 do
				(
					HiddenDosCommand ("copy \"" + sea.bitmaps[i] + "\" \"" + tex_path + ((i-1) as string) + extension + "\"")
				)								
				
				local cmd = " -m"
				
				if seaconfig_atf_compress == ENC_ALL then cmd += " -c"
				else if seaconfig_atf_compress == ENC_DXT then cmd += " -c d"
				else if seaconfig_atf_compress == ENC_ETC1 then cmd += " -c e"
				else if seaconfig_atf_compress == ENC_PVRTC then cmd += " -c p"
				
				cmd += " -i \"" + (tex_path + "0" + extension) + "\"" -- input
				cmd += " -o \"" + atf_filename + "\"" -- output
				
				if seaconfig_atf_jpegxr do cmd += " -r"
				
				local process = ProcessClass.Start ATF_PNG_TO_ATF cmd							
				process.WaitForExit()
				
				if process.ExitCode == 0 then
				(
					FileClass.SetLastWriteTime atf_filename (FileClass.GetLastWriteTime filename)
				)
				else
				(
					error1401 ((getName filename) + (getExtension filename))
				)
				
				-- Delete Temp's
				for i=1 to 6 do
				(
					HiddenDosCommand ("del \"" + tex_path + ((i-1) as string) + extension + "\"")
				)
			)
		)
		
		if fileExist (atf_filename) then
		(
			filename = atf_filename
		)
		else
		(
			warning2401 (getName filename)
		)
	)
	
	if (getExtension filename) == EXT_ATF then
	(
		asset.Filename = name + EXT_ATF_CUBE
		data.ReadFile filename
	)
	else
	(
		asset.Filename = name + EXT_CUBE_MAPPING	
		
		data.WriteTypeCode (getCleanExtension extension)
		
		for i=1 to 6 do
		(
			local faceData = newNode()
			
			faceData.ReadFile sea.bitmaps[i]	
			
			data.WriteDataObject faceData
		)
	)
		
	asset.Compressed = seaconfig_compress_texture			
	
	return asset
)

function getCompositeAsset sea =
(
	local asset = newAsset()
	local data = asset.Data				
	local count = sea.textures.count			

	-- TEXTURE
	asset.Filename = sea.obj.name + EXT_COMPOSITE
	
	data.WriteByte count
	
	for i=1 to count do
	(
		local tex = sea.textures[i]
		local mak = sea.masks[i]
		local blendMode = sea.blendMode[i]
		local opacity = (sea.opacity[i]/100.0)
		local nm = sea.name[i]									
		
		seatime seaTimeRange[1]
		
		local useName = nm != undefined
		local useTexture = tex != undefined
		local useMask = mak != undefined
		local useBlendMode = blendMode != "normal"
		local useOpacity = opacity != 1
		
		local ext_attrib = 0
			
		if useTexture do
			ext_attrib = (bit.set ext_attrib 1 true)	
		
		if useMask do
			ext_attrib = (bit.set ext_attrib 2 true)
		
		if useName do 
			ext_attrib = (bit.set ext_attrib 3 true)
		
		if useBlendMode do
			ext_attrib = (bit.set ext_attrib 4 true)
		
		if useOpacity do
			ext_attrib = (bit.set ext_attrib 5 true)
		
		data.WriteUInt16 ext_attrib
		
		if useTexture then writeCompositeLayer data tex sea.animation[i]
		else writeColor data sea.color
		
		if useMask do					
			writeCompositeLayer data mak sea.animationMask[i]		
		
		if useName do		
			data.WriteUTF8 nm			
		
		if useBlendMode do
			data.WriteByte (getBlendIndex blendMode)
		
		if useOpacity do
			data.WriteFloat opacity							
	)
	
	return asset
)

function getRTTAsset sea type =
(
	local asset = newAsset()
	local data = asset.Data
	
	local obj = sea.obj
	
	asset.Filename = sea.obj.name + type
	
	data.WriteByte 0x01 -- Normal Quality

	if type == EXT_RTT_CUBE then
	(
		write3D data obj.center
	)
	else if type == EXT_RTT_PLANAR then
	(
		local t = obj.transform
		t.position = obj.center
		
		if seaconfig_positive_scale do 
			positiveMatrixScale &t
		
		writeMatrix3x4 data t
	)
		
	return asset
)

function getMaterialAsset sea blendtype: receiveShadows: receiveLights: =
(	
	local asset = newAsset()
	local data = asset.Data
	local tech = sea.tech
	
	if receiveShadows == unsupplied or receiveShadows == undefined do receiveShadows = true
	if receiveLights == unsupplied or receiveLights == undefined do receiveLights = true
	
	-- MATERIAL
	asset.Filename = sea.obj.name + EXT_MATERIAL
	
	seatime seaTimeRange[1]
	
	local ext_attrib = 0
	
	local containsBlend = (blendtype != unsupplied or blendtype != undefined) and blendtype != "normal"
	
	ext_attrib = (bit.set ext_attrib 1 sea.twoSided)
	ext_attrib = (bit.set ext_attrib 2 (receiveLights == false)) -- no receive lights
	ext_attrib = (bit.set ext_attrib 3 (receiveShadows == false)) -- no receive shadows						
	ext_attrib = (bit.set ext_attrib 4 false) -- no receive fog
	ext_attrib = (bit.set ext_attrib 5 (sea.smoothMat == false)) -- faceted material
	ext_attrib = (bit.set ext_attrib 6 sea.containsAlpha) -- alpha	
	ext_attrib = (bit.set ext_attrib 7 containsBlend) -- blend mode
	ext_attrib = (bit.set ext_attrib 8 false) -- animations	
	
	data.WriteUInt16 ext_attrib
	
	if sea.containsAlpha do data.WriteFloat sea.opacity			
	if containsBlend do data.WriteByte (getBlendIndex blendtype)
	
	writeMaterialTechs data tech	
	
	return asset
)

function getMaterialColorAsset nm clr blendtype: receiveShadows: receiveLights: =
(
	local asset = newAsset()
	local data = asset.Data
	
	if receiveShadows == unsupplied or receiveShadows == undefined do receiveShadows = true
	if receiveLights == unsupplied or receiveLights == undefined do receiveLights = true
	
	-- MATERIAL
	asset.Filename = nm + EXT_MATERIAL
	
	local ext_attrib = 0
	
	local containsBlend = (blendtype != unsupplied or blendtype != undefined) and blendtype != "normal"
	
	ext_attrib = (bit.set ext_attrib 2 (receiveLights == false)) -- no receive lights
	ext_attrib = (bit.set ext_attrib 3 (receiveShadows == false)) -- no receive shadows
	ext_attrib = (bit.set ext_attrib 7 containsBlend) -- blend mode
	
	data.WriteUInt16 ext_attrib
	
	if containsBlend do data.WriteByte (getBlendIndex blendtype)
	
	local tech = #()
	
	append tech #(		
		MAT_DEFAULT,				
		#(DT_COLOR,color 0 0 0),--ambient
		#(DT_COLOR,clr), -- color
		#(DT_COLOR,color 255 255 255), --specular
		#(DT_FLOAT,1), -- specularLevel
		#(DT_FLOAT,50) -- glossiness
	)
	
	writeMaterialTechs data tech
	
	return asset
)

function getSplineAsset sea =
(	
	local obj = copy sea.obj
	local asset = undefined
	
	try 
	(
		convertToSplineShape obj
		
		asset = newAsset()		
		asset.Filename = sea.obj.name + EXT_LINE		
		
		local data = asset.Data				
		
		-- HEADER
		local header = 0x00								
		local body = newNode()
		
		-- OBJECT3D
		writeObject3D body sea &header
		
		if seaconfig_splinestep > C_BIG then 
		(			
			header += HEADER_BIG_SPLINE
			body.WriteInt32 seaconfig_splinestep
		)
		else body.WriteUInt16 seaconfig_splinestep
		
		if (isClosed obj 1) do header += HEADER_CLOSED
		
		if seaconfig_snapshot then writeMatrix3x4 body (matrix3 1)
		else writeMatrix body obj
		
		if seaconfig_snapshot == false then
			removeObjectTransform obj
		
		local splinestep = seaconfig_splinestep as float		
		
		local c = 0
		
		for i = 1 to seaconfig_splinestep do
		(			
			Write3D body (interpCurve3D obj 1 (i / splinestep)) 
		)
		
		data.WriteUInt16 header
		data.WriteData body
		
		writeTags data 0						
	)
	catch 
	( 
		asset = undefined 
		
		error1060 sea.obj.name
	)
	
	delete obj
	
	return asset
)

function getPropertiesAsset attrib name =
(
	local names = #()
	local values = #()
	local count = 0
	
	-- All Params
	for objDef in (custAttributes.getDefs attrib) do
	(
		pbArray = custAttributes.getPBlockDefs objdef
		for a = 1 to pbArray.count do 
		(
			itms = pbArray[a] 
			
			for c = 1 to itms.count do 
			(
				p = itms[c]
				if classof p == array and p.count > 1 and classof p[2] == array then
				(	
					local v = p[2][6]						
					
					if v != undefined then
					(
						local n = p[1] as string
						
						if findItem names n == 0 then
						(
							count += 1
							
							names[count] = n
							values[count] = getProperty attrib n						
						)
					)
				)
			)				
		)
	)
	
-- Animated Params
--	for i = 1 to count do
--	(
--		local a = custAttributes.get attrib i
--		local j = 1
--		
--		while a[j] != undefined do
--		(
--			append names a[j].name
--			append values a[j].value
--			j+=1
--		)
--	)
	
	if count == 0 then return undefined
		
	-- PROPERTIES
	local asset = newAsset()
	local data = asset.Data
	
	asset.Filename = name + EXT_PROPERTIES	
	
	data.WriteByte count
	
	for i = 1 to count do
	(
		local n = names[i]
		local v = values[i]
		local c = classof v
				
		data.WriteUTF8 n
		
		if c == BooleanClass then
		(
			data.WriteByte 1
			data.WriteBoolean v
		)
		else if c == Color then
		(
			data.WriteByte 7
			WriteColor data v
		)
		else if c == Integer then
		(
			data.WriteByte 8
			data.WriteInt v
		)	
		else if c == Float then
		(
			data.WriteByte 10
			data.WriteFloat v
		)		
		else if c == String then
		(
			data.WriteByte 128
			WriteStr data v
		)			
		else
		(
			data.WriteByte 0
		)
	)
	
	return asset
)

function getSkeletonLocalAsset sea =
(
	local asset = newAsset()
	local data = asset.Data
	
	asset.Filename = sea.obj.name + EXT_SKELETON_LOCAL
	
	-- SKELETON
	local oldTime = currentTime.frame
	
	seatime seaconfig_bindframe
	
	local numbones = sea.boneList.count					
	
	data.WriteUInt16 numbones
	
	for i=1 to numbones do
	(
		data.WriteUTF8 sea.boneList[i].name 						
		data.WriteUInt16 (findItem sea.boneList sea.boneParentList[i])		
		
		writeBone data sea.boneList[i] SEA_QUATERNION parent:sea.boneParentList[i] bindpos:sea.bindpos
		
		Write3D data [1,1,1]
	)
	
	seatime oldTime
	
	returnasset
)

function getSkeletonAsset sea =
(
	local asset = newAsset()
	local data = asset.Data
	
	asset.Filename = sea.obj.name + EXT_SKELETON
	
	-- SKELETON
	local oldTime = currentTime.frame
	
	seatime seaconfig_bindframe
	
	local numbones = sea.boneList.count					
	
	data.WriteUInt16 numbones
	
	for i=1 to numbones do
	(
		data.WriteUTF8 sea.boneList[i].name 						
		data.WriteUInt16 (findItem sea.boneList sea.boneParentList[i])		
		
		if i == 1 then
			writeBone data sea.boneList[i] SEA_INV_MATRIX parent:sea.boneParentList[1] bindpos:sea.bindpos
		else 
			writeBone data sea.boneList[i] SEA_INV_MATRIX parent:sea.boneParentList[1] bindpos:sea.bindpos
	)
	
	seatime oldTime
	
	return asset
)

function getGeometryAsset sea =
(
	local asset = newAsset()
	local data = asset.Data
	local obj = sea.temp
	
	asset.Filename = sea.obj.name + EXT_GEOMETRY
	
	-- GEOMETRY
	
	local c_vertex = sea.c_vertex
	local c_index = sea.c_index
	local c_weights = sea.c_weights
	local c_normal = sea.c_normal
	local c_uv = sea.c_uv
	local c_color = sea.c_color
	local c_tangent = sea.c_tangent
	
	local e_index = sea.e_index
	local e_normal = sea.e_normal
	
	local bigMesh = c_vertex.count	> C_BIG		
	local WriteUInt = undefined
	
	if bigMesh then WriteUInt = data.WriteInt32
	else WriteUInt = data.WriteUInt16	
	
	local header = 0			
	if bigMesh do header += HEADER_BIGMESH
	
	local containsUV = c_uv.count > 0
	local containsNormal = c_normal.count > 0
	local containsTangent = c_tangent.count > 0
	local containsJoints = c_weights.count > 0
	local containsColor = c_color.count > 0
	
	header += HEADER_VERTEX
	
	if containsUV do header += HEADER_UV
	if containsNormal do header += HEADER_NORMAL
	if containsTangent do header += HEADER_TANGENT
	if containsJoints do header += HEADER_JOINTS
	if containsColor do header += HEADER_COLOR
	
	-- HEADER
	data.WriteUInt16 header
	
	-- VERTEX COUNT
	WriteUInt c_vertex.count		
	
	-- NORMAL
	if containsNormal then 
	(
		for v=1 to c_normal.count do
		(
			data.WriteFloat c_normal[v][1]
			data.WriteFloat c_normal[v][2]
			data.WriteFloat c_normal[v][3]
		)
	)
	
	-- TANGENT
	if containsTangent then 
	(
		for v=1 to c_tangent.count do
		(
			data.WriteFloat c_tangent[v][1]
			data.WriteFloat c_tangent[v][2]
			data.WriteFloat c_tangent[v][3]
		)
	)
	
	-- UV'S
	if containsUV then
	(
		data.WriteByte c_uv.count
		for c=1 to c_uv.count do
		(			
			for v=1 to c_uv[c].count do
			(
				data.WriteFloat c_uv[c][v][1]
				data.WriteFloat c_uv[c][v][2]
			)
		)
	)
	
	-- JOINTS / WEIGHTS
	if containsJoints then 
	(
		local maxweight = sea.maxweight
		
		data.WriteByte maxweight
		
		for v = 1 to c_weights.count do
		(
			local w = 0
			
			while w < c_weights[v].count do
			(
				data.WriteUInt16 c_weights[v][w+1][1]					
				w += 1
			)
			
			while w < maxweight do
			(
				data.WriteUInt16 0					
				w += 1
			)											
		)
		
		for v = 1 to c_weights.count do
		(
			local w = 0
			
			while w < c_weights[v].count do
			(
				data.WriteFloat c_weights[v][w+1][2]					
				w += 1
			)
			
			while w < maxweight do
			(
				data.WriteFloat 0					
				w += 1
			)											
		)
	)
	
	-- COLOR
	if containsColor then
	(
		-- CHANNEL COUNT
		local colorAttrib = 1
		
		colorAttrib += HEADER_COLOR3
		
		data.WriteByte colorAttrib
		
		for v=1 to c_color.count do
		(
			data.WriteByte c_color[v][1]
			data.WriteByte c_color[v][2]
			data.WriteByte c_color[v][3]
		)
	)
	
	-- VERTEX
	for v=1 to c_vertex.count do
	(
		data.WriteFloat c_vertex[v][1]
		data.WriteFloat c_vertex[v][2]
		data.WriteFloat c_vertex[v][3]
	)
	
	-- INDEX
	data.WriteByte c_index.count		
	for m = 1 to c_index.count do
	(
		local _index = c_index[m]
		WriteUInt (_index.count/3)
		for f = 1 to _index.count do 
		(
			WriteUInt (_index[f]-1)
		)
	)
	
	return asset
)

function getMeshAsset sea =
(
	local asset = newAsset()
	local data = asset.Data
	local obj = sea.obj
	local inst = sea.instanceOf
	
	asset.Filename = obj.name + EXT_MESH
	
	-- HEADER
	local header = 0x0000
	local body = newNode()
	
	-- MESH
	seatime seaTimeRange[1]
	
	-- GET PROPERTIES
	local isStatic = sea.isStatic()
	local castShadows = sea.castShadows()	
	
	-- INSTANCE	
	if inst != undefined then
	(
		sea.geo_index = inst.geo_index
		
		-- ANIMATION
		if seaconfig_animation and seaconfig_instanceanimation then
		(
			if (sea.skeletonAnimation == undefined and inst.skeletonAnimation != undefined) do
				sea.skeletonAnimation == inst.skeletonAnimation
			
			if (sea.morphAnimation == undefined and inst.morphAnimation != undefined) do
				sea.morphAnimation == inst.morphAnimation
			
			if (sea.vertexAnimation == undefined and inst.vertexAnimation != undefined) do
				sea.vertexAnimation == inst.vertexAnimation
			
			if (sea.uvwAnimation == undefined and inst.uvwAnimation != undefined) do
				sea.uvwAnimation == inst.uvwAnimation
		)
	)
	
	local animationList = #()
	
	-- SEARCH UVW ANIMATION
	if sea.mats != undefined then
	(
		for i = 1 to sea.mats.count do
		(
			if sea.mats[i] != undefined and sea.mats[i].uvwAnimation != undefined then
			(
				sea.uvwAnimation = sea.mats[i].uvwAnimation
				exit
			)
		)
	)
	
	if sea.skeletonAnimation != undefined then
	(
		append animationList ( SEAAnimator sea.skeletonAnimation seaconfig_bindoffset )	
	)
	
	if sea.vertexAnimation != undefined then
	(
		append animationList ( SEAAnimator sea.vertexAnimation true )	
	)
	
	if sea.morphAnimation != undefined then
	(
		append animationList ( SEAAnimator sea.morphAnimation false )	
	)
	
	if sea.uvwAnimation != undefined then
	(
		append animationList ( SEAAnimator sea.uvwAnimation false )	
	)
	
	-- OBJECT3D
	writeObject3D body sea &header animation:animationList
		
	-- OBJECT CONFIG
	local objectConfig = 0x00
	
	if isStatic do objectConfig += HEADER_STATIC
	
	if objectConfig != 0 then
	(
		header += HEADER_OBJECT_CONFIG	
		body.WriteByte objectConfig
	)
	
	-- LIGHT CONFIG
	local lightConfig = 0x00
	
	if castShadows == false do lightConfig += HEADER_NOCAST_SHADOWS
	
	if lightType != 0 then
	(
		header += HEADER_LIGHT_CONFIG
		body.WriteByte lightConfig
	)
	
	-- MATERIALS
	if sea.mats_index != undefined then
	(
		header += HEADER_MATERIAL
		
		body.WriteByte sea.mats_index.count
		
		if sea.mats_index.count == 1 then
		(
			body.WriteInt32 sea.mats_index[1]
		)
		else
		(
			for i = 1 to sea.mats_index.count do
			(
				if sea.mats_index[i] != undefined then
				(
					body.WriteInt32 (sea.mats_index[i]+1)
				)
				else
				(
					body.WriteInt32 0
				)
			)
		)
	)						
	
	-- MODIFIERS
	local mods = #()
	
	if sea.skeleton != undefined do append mods sea.skeleton
	if sea.morph_index != undefined do append mods sea.morph_index
	
	if mods.count > 0 then
	(
		header += HEADER_MODIFIERS
		
		body.WriteByte mods.count
		
		for index in mods do
		(
			body.WriteInt32 index
		)
	)
	
	-- TRANSFORM
	if sea.skinObj != undefined then 
	(
		-- SKELETON MATRIX
		if seaconfig_snapshot then writeMatrix3x4 body (matrix3 1)
		else writeMatrix body obj position:sea.bindpos ignoreRotation:true
	)
	else
	(
		if inst != undefined and inst.skinObj != undefined then
		(
			local t = realTransform inst.obj
			local obj_t = realTransform sea.obj
			
			local pos = obj_t.position			
			pos.x += inst.bindpos.x - t.position.x 
			pos.y += inst.bindpos.y - t.position.y
			pos.z += inst.bindpos.z - t.position.z
			
			local euler = quattoeuler t.rotation					
			euler.x = -euler.x
			euler.y = -euler.y
			euler.z = -euler.z
			
			-- INSTANCED SKELETON MATRIX
			writeMatrix body obj position:pos offset:euler
		)
		else
		(
			-- DEFAULT MATRIX
			if seaconfig_snapshot then writeMatrix3x4 body (matrix3 1)
			else writeMatrix body obj
		)			
	)
		
	-- BODY	
	body.WriteInt32 sea.geo_index		
	
	-- HEADER | BODY
	data.WriteUInt16 header
	data.WriteData body
	
	-- TAGS
	writeTags data 0
	
	return asset
)

function getCameraAsset sea = 
(
	local asset = newAsset()
	local data = asset.Data
	local obj = sea.obj
	
	asset.Filename = obj.name + EXT_PERSPECTIVE_CAMERA
	
	-- HEADER
	local header = 0x0000
	local body = newNode()
	
	-- OBJECT3D
	writeObject3D body sea &header
	
	-- CAMERA
	seatime seaTimeRange[1]
	
	writeMatrix body obj offset:[-90,0,0]
	
	body.WriteFloat obj.fov
	
	-- HEADER | BODY
	data.WriteUInt16 header
	data.WriteData body
			
	-- LOOK_AT USING SEA3D TAG
	--local nodesData = newNode()
	--local nodesCount = 0
		
	--if sea.target != undefined and seaconfig_cameratarget then
	--(
	--	writeTag nodesData (getLookAtTag sea.target.obj) TAG_LOOK_AT		
	--	nodesCount+=1
	--)	
	
	--writeTags data nodesCount nodeData:nodesData
	
	-- LOOK_AT USING ACTION
	if sea.target != undefined and seaconfig_cameratarget then
	(
		append seaactions (SEAAction ACT_LOOK_AT #(sea, sea.target))
	)
	
	writeTags data 0
	
	return asset
)

function getLightAsset sea = 
(
	local asset = newAsset()
	local data = asset.Data
	local obj = sea.obj
	
	-- HEADER
	local header = 0x0000
	local body = newNode()
			
	-- OBJECT3D
	writeObject3D body sea &header
	
	-- LIGHT
	seatime seaTimeRange[1]
	
	-- SHADOW
	if obj.baseObject.castShadows then
	(
		header += HEADER_SHADOW
		
		-- default shadow
		body.WriteByte 0x00
	)
			
	-- COLOR
	WriteColor body obj.rgb	
	
	-- MULTIPLIER
	body.WriteFloat obj.multiplier
	
	-- ATTENUATION
	if obj.useFarAtten do
	(
		header += HEADER_ATTENUATION
		
		body.WriteFloat obj.farAttenStart
		body.WriteFloat obj.farAttenEnd
	)
	
	if obj.type == #omni then
	(
		writePosition body obj
		
		asset.Filename = obj.name + EXT_POINT_LIGHT	
	)	
	else
	(
		writeMatrix body obj offset:[-90,0,0]
		
		asset.Filename = obj.name + EXT_DIRECTIONAL_LIGHT
	)
	
	-- HEADER | BODY
	data.WriteUInt16 header
	data.WriteData body
	
	-- LOOK_AT USING ACTION
	if sea.target != undefined and seaconfig_cameratarget then
	(
		append seaactions (SEAAction ACT_LOOK_AT #(sea, sea.target))
	)
	
	writeTags data 0
	
	return asset
)

function getDummyAsset sea = 
(
	local seaList = undefined
	
	local asset = newAsset()
	local data = asset.Data
	
	local type = sea.type
	local obj = copy sea.obj
	local objName = sea.obj.name
	
	asset.Filename = objName + EXT_DUMMY
	
	-- HEADER
	local header = 0x0000
	local body = newNode()	
	
	-- OBJECT3D
	writeObject3D body sea &header
	
	-- DUMMY
	seatime seaTimeRange[1]
	
	writeMatrix body obj
	
	removeObjectTransform obj
	
	write3D body (obj.max - obj.min)
	
	data.WriteUInt16 header
	data.WriteData body	
	
	writeTags data 0
	
	delete obj
	
	return asset
)

function getSprite3DAsset sea = 
(
	local asset = newAsset()
	local data = asset.Data
	
	asset.Filename = sea.obj.name + EXT_SPRITE3D
	
	-- HEADER
	local header = 0x0000
	local body = newNode()
		
	-- OBJECT3D
	writeObject3D body sea &header
	
	seatime seaTimeRange[1]
	
	if sea.mats_index != undefined do
	(
		header += HEADER_MATERIAL
		body.WriteInt32 sea.mats_index[1]
	)
	
	writePosition body sea.obj
	
	body.WriteFloat sea.spriteMode.widthparam
	body.WriteFloat sea.spriteMode.heightparam		
	
	data.WriteUInt16 header
	data.WriteData body
	
	WriteTags data 0
	
	return asset
)

function getSound3DAsset sea = 
(
	local asset = newAsset()
	local data = asset.Data
	
	asset.Filename = sea.obj.name + EXT_SOUND_POINT
	
	-- SOUND3D
	seatime seaTimeRange[1]
	
	local header = 0x0000	
	local body = newNode()
	
	-- OBJECT3D
	writeObject3D body sea &header
	
	if sea.soundMod.autoplayParam then
	(
		header += HEADER_AUTO_PLAY
	)
	
	if sea.soundMod.namespaceParam != undefined and sea.soundMod.namespaceParam.count > 0 then
	(
		header += HEADER_SOUND_MIXER
		body.WriteInt32 (writeAppendSoundMixer sea.soundMod.namespaceParam)
	)		
	
	body.WriteInt32 sea.sound_index
	body.WriteFloat sea.soundMod.volumeParam
	
	writePosition body sea.obj	
	body.WriteFloat sea.soundMod.distanceParam
	
	data.WriteUInt16 header
	data.WriteData body
	
	writeTags data 0
	
	return asset
)

function getActionsAsset acts =
(
	local asset = newAsset()
	local data = asset.Data
	
	asset.Filename = "Actions" + EXT_ACTIONS
	
	data.WriteInt32 acts.count
	
	for i=1 to acts.count do
	(
		local act = acts[i]		
		local type = act.type	
		local value = act.value
		local attrib = 0x00
		
		local body = newNode()
		
		if type == ACT_ENVIRONMENT then
		(
			local cubeIndex = appendAsset (getCubeAsset value)			
			body.WriteInt32 cubeIndex -- CubeMap
		)
		else if type == ACT_FOG then
		(	
			WriteColor body value[1] -- Color
			body.WriteFloat value[2] -- Min
			body.WriteFloat value[3] -- Max				
		)		
		else if type == ACT_RTT_TARGET or type == ACT_LOOK_AT then
		(
			-- Source
			if (classof value[1] == integer) then
				body.WriteInt32 value[1]
			else
				body.WriteInt32 value[1].asset
			
			-- Target
			if (classof value[2] == integer) then
				body.WriteInt32 value[2]
			else
				body.WriteInt32 value[2].asset
		)
		
		if body.Length > 0 then
		(
			data.WriteByte attrib
			data.WriteUInt16 type		
			data.WriteUInt16 body.Length		
			data.WriteData body
		)
	)	
	
	return asset
)

function getFileInfoAsset =
(
	local asset = newAsset()
	local data = asset.Data
	
	asset.Filename = "Info" + EXT_INFO
	
	local fileInfo = #()
	
	local name = seaconfig_fileinfo[2]
	local author = seaconfig_fileinfo[3] 
	local website = seaconfig_fileinfo[4]
	
	if name.count > 0 then append fileInfo #("name", name, String)
	if author.count > 0 then append fileInfo #("author", author, String)
	if website != "http://" and website.count > 0 then append fileInfo #("website", website, String)
	
	append fileInfo #("datetime", localtime, String)
	append fileInfo #("exporter", sea_rawversion, Integer)
	append fileInfo #("region", (dotNetClass "System.Globalization.RegionInfo").CurrentRegion.Name, String) -- Your Country
	
	data.WriteByte fileInfo.count
	
	for i = 1 to fileInfo.count do
	(
		local c = fileInfo[i][3]	
		
		data.WriteUTF8 fileInfo[i][1]
		
		if c == Integer then
		(
			data.WriteByte 8
			data.WriteInt32 fileInfo[i][2]
		)		
		else if c == String then
		(
			data.WriteByte 128
			WriteStr data fileInfo[i][2]
		)			
		else
		(
			data.WriteByte 0
		)
	)
	
	return asset
)

--
--	Append Files
--

function appendMaterials sea =
(	
	local mats = sea.mats 
	local blendtype = getUserProp sea.obj DEF_MATERIAL_BLEND_TYPE
	local receiveShadows = sea.receiveShadows()	
	local receiveLights = sea.receiveLights()	
	local colorAsset = undefined
	
	for matid=1 to mats.count do
	(
		local mat = mats[matid]		
		
		if mat != undefined then 
		(
			for texid=1 to mat.maps.count do
			(
				local tex = mat.maps[texid]
				
				if classof tex == SEATexture then
				(
					local anmAsset = undefined
					
					for mapid=1 to tex.bitmaps.count do
					(
						local map = tex.bitmaps[mapid]
						
						if (map.asset == undefined) then					
							map.asset = appendAsset (getTextureAsset map) type:EXT_TEXTURE
					)
					
					for layerid=1 to tex.textures.count do
					(
						if (tex.animation[layerid] != undefined) then
						(
							if tex.type() == DT_TEXTURE do 
								type = EXT_ANIMATION_UVW
							
							if (anmAsset = getCompositeAnimationAsset tex.textures[layerid] (tex.textures[layerid].name + ":texture" + (layerid as string) ) model:sea.obj frame_rate:sea.frame_rate type:type) != undefined then
							(
								tex.animation[layerid] = sea.uvwAnimation = appendAsset anmAsset
							)
						)
						
						if tex.animationMask[layerid] != undefined then
						(
							if (anmAsset = getCompositeAnimationAsset tex.mask[layerid] (tex.animationMask[layerid].name + ":mask" + (layerid as string) ) model:sea.obj frame_rate:sea.frame_rate) != undefined then
							(
								tex.animationMask[layerid] = appendAsset anmAsset
							)
						)
					)
					
					if (tex.asset == undefined) then
					(
						local texType = tex.type() 	
						
						if texType == DT_TEXTURE then tex.asset = tex.bitmaps[1]
						else if texType == DT_COMPOSITE then tex.asset = appendAsset (getCompositeAsset tex)
					)
				)
				else if classof tex == SEACube then
				(
					if (tex.asset == undefined) then			
					(				
						if tex.bitmaps.count == 1 then
						(
							tex.asset = appendAsset (getSingleCubeAsset tex) type:EXT_CUBE_MAPPING
						)
						else
						(
							tex.asset = appendAsset (getCubeAsset tex) type:EXT_CUBE_MAPPING
						)					
					)
				)
			)

			if sea.mats_index == undefined do
				sea.mats_index = #()
			
			if (mat.asset == undefined) then		
			(
				if mat.rttCube and mat.rttCubeAsset == undefined then
				(
					mat.rttCubeAsset = appendAsset (getRTTAsset sea EXT_RTT_CUBE)					
					if seaconfig_rtt_target do append seaactions (SEAAction ACT_RTT_TARGET #(mat.rttCubeAsset, sea))
				)
				
				if mat.rttPlanar and mat.rttPlanarAsset == undefined then
				(
					mat.rttPlanarAsset = appendAsset (getRTTAsset sea EXT_RTT_PLANAR)
					if seaconfig_rtt_target do append seaactions (SEAAction ACT_RTT_TARGET #(mat.rttPlanarAsset, sea))
				)
				
				mat.asset = appendAsset (getMaterialAsset mat blendtype:blendtype receiveShadows:receiveShadows receiveLights:receiveLights) share:((isValidInstancing()) and seaconfig_sharematerials)
			)
			
			sea.mats_index[matid] = mat.asset
		)
		else if seaconfig_material and seaconfig_materialcolor then
		(
			if (sea.mats_index == undefined) do
				sea.mats_index = #()
			
			if (colorAsset == undefined) do
				colorAsset = appendAsset (getMaterialColorAsset sea.obj.name sea.obj.wirecolor blendtype:blendtype receiveShadows:receiveShadows receiveLights:receiveLights)	share:((isValidInstancing()) and seaconfig_sharematerials)					
			
			sea.mats_index[matid] = colorAsset
		)
	)
	
	if (sea.mats_index != undefined) then
	(
		local mat = sea.mats_index[1]
		
		for i = 2 to sea.mats_index.count do
		(
			if mat != sea.mats_index[i] do
			(
				mat = undefined
				exit
			)						
		)
		
		if mat != undefined do
		(
			sea.mats_index = #( mat )
		)
	)
)

--
--	Export
--

function exportSEAObjects =
(
	seaprogressStart (color 119 212 212)
	
	local seasounds = #()
	
	-- Get Sounds List
	for i=1 to sea_sounds_names.count do	
		seasounds[i] = sea_sounds_names[i]	
	
	for seaIndex=1 to seaObjectList.count do
	(
		local anmAsset = undefined
		local sea = seaObjectList[seaIndex]
		local obj = sea.obj
		
		seaprogressUpdate (((float seaIndex) / (float seaObjectList.count)) * 100.0)
		
		if seabuild == false do return 0
		
		if classof sea == SEAMesh then
		(
			appendMaterials sea
			
			if sea.attribs != undefined then
			(
				-- convert attributes to file_index
				sea.attribs = appendAsset (getPropertiesAsset sea.attribs sea.obj.name)
			)
			
			if sea.morphObj != undefined then (					
				sea.morph_index = appendAsset (getMorphAsset sea)
			)
			
			if sea.vertexAnm then
			(
				if (seaconfig_geometry or seaconfig_force_animation) and seaconfig_animation and (anmAsset = getVertexAnimationAsset sea)  != undefined do (
					sea.vertexAnimation = appendAsset anmAsset						
				)
			)							
			else if sea.skinObj != undefined then 
			(
				sea.skeleton = appendAsset (getSkeletonAsset sea)
				--sea.skeleton = appendAsset (getSkeletonLocalAsset sea)
				
				if (seaconfig_geometry or seaconfig_force_animation) and seaconfig_animation and (anmAsset = getSkeletonAnimationAsset sea)  != undefined do (
					sea.skeletonAnimation = appendAsset anmAsset						
				)
			)
			
			if sea.morphObj != undefined and (seaconfig_geometry or seaconfig_force_animation) and seaconfig_animation and (anmAsset = getMorphAnimationAsset sea)  != undefined do (
				sea.morphAnimation = appendAsset anmAsset	
			)
			
			if (seaconfig_geometry or seaconfig_force_animation) and seaconfig_animation and (anmAsset = getMeshAnimationAsset obj frame_rate:sea.frame_rate) != undefined then (					
				sea.animation = appendAsset anmAsset			
			)
			
			if seaconfig_geometry then
			(								
				sea.geo_index = appendAsset (getGeometryAsset sea)
				sea.asset = appendAsset (getMeshAsset sea) type:EXT_SCENE_OBJECT
			)
					
			for i=1 to sea.instances.count do
			(										
				local instSEA = sea.instances[i]			
				
				appendMaterials instSEA
				
				if (seaconfig_geometry or seaconfig_force_animation) and seaconfig_animation do 
				(
					if instSEA.vertexAnm then 
					(
						if (anmAsset = getVertexAnimationAsset sea)  != undefined do (
							sea.vertexAnimation = anmAsset.name
							append dependencies anmAsset
						)
					)
					
					if instSEA.skinObj != undefined then 
					(
						if (anmAsset = getMeshAnimationAsset instSEA.obj frame_rate:instSEA.frame_rate) != undefined do (
							sea.animation = anmAsset.name
							append dependencies anmAsset
						)
					)
					
					if (anmAsset = getMeshAnimationAsset instSEA.obj frame_rate:instSEA.frame_rate) != undefined then
					(
						instSEA.animation = appendAsset anmAsset	
					)
				)
				
				if seaconfig_geometry then
					instSEA.asset = appendAsset (getMeshAsset instSEA) type:EXT_SCENE_OBJECT
			)
		)
		else if classof sea == SEASprite then
		(
			if seaconfig_sprite then
			(
				appendMaterials sea
				appendAsset (getSprite3DAsset sea) type:EXT_SCENE_OBJECT
			)
		)	
		else if classof sea == SEALight then
		(
			if (seaconfig_light or seaconfig_force_animation) and seaconfig_animation then
			(
				if (anmAsset = getLightAnimationAsset obj frame_rate:sea.frame_rate) != undefined then
				(
					sea.animation = appendAsset anmAsset
				)
			)
			
			if seaconfig_light then
				sea.asset = appendAsset (getLightAsset sea) type:EXT_SCENE_OBJECT
		)
		else if classof sea == SEACamera then
		(
			if (seaconfig_camera or seaconfig_force_animation) and seaconfig_animation then
			(
				if (anmAsset = getCameraAnimationAsset obj frame_rate:sea.frame_rate) != undefined then
				(
					sea.animation = appendAsset anmAsset						
				)
			)
			
			if seaconfig_camera then
				sea.asset = appendAsset (getCameraAsset sea) type:EXT_SCENE_OBJECT		
		)		
		else if classof sea == SEADummy then
		(		
			local enabledDummy = (sea.type == "dummy" and seaconfig_dummy) or sea.type == "target"
			
			if (enabledDummy or seaconfig_force_animation) and seaconfig_animation then
			(
				if (anmAsset = getDummyAnimationAsset obj frame_rate:sea.frame_rate) != undefined then
				(
					sea.animation = appendAsset anmAsset
				)
			)
			
			if enabledDummy then
				sea.asset = appendAsset (getDummyAsset sea) type:EXT_SCENE_OBJECT 
		)
		else if classof sea == SEASound then
		(
			if (seaconfig_sounds or seaconfig_force_animation) and seaconfig_animation then
			(
				if (anmAsset = getSound3DAnimationAsset sea.obj sea.soundMod frame_rate:sea.frame_rate) != undefined then
				(
					sea.animation = appendAsset anmAsset
				)
			)
			
			if seaconfig_sounds then
			(
				sea.sound_index = appendAsset (getSoundAsset sea.s_sound)		
				appendAsset (getSound3DAsset sea) type:EXT_SCENE_OBJECT
			)
		)
		else if classof sea == SEASplines then
		(
			if seaconfig_spline and ((splineAsset = getSplineAsset sea) != undefined) then	
			(
				appendAsset splineAsset type:EXT_SCENE_OBJECT
			)
		)		
		else if classof sea == SEACube then
		(
			appendAsset (getCubeAsset sea)
		)		
	)
	
	if seaactions.count > 0 then
	(
		appendAsset (getActionsAsset seaactions)
	)		
	
	if seaconfig_all_sounds then
	(
		-- Export Rest Sounds List		
		for i=1 to seasounds.count do	
		(			
			appendAsset (getSoundAsset seasounds[i]) #() (seaObjectList.count + i) 0 0 
		)		
	)
	
	return seaErrors.count
)

fn exportList list =
(
	try destroyDialog _SEAListener catch()
	
	if (list.count == 0 and (seaconfig_env and seaconfig_envmap and useEnvironmentMap) == false ) do
	(
		seaError = "No object selected."
		return undefined
	)
	
	set animate on
	local oc = set coordsys #world
	
	local anm = seaconfig_animation
	
	if seaconfig_animation and (seaTimeRange[1] == seaTimeRange[2] or seaconfig_snapshot) do
	(
		seaconfig_animation = false
	)
	
	if seaconfig_exceptionprotection then
	(
		try (
			if ((compileObjects list) == 0) then
			(
				exportSEAObjects()
			)
		) catch ( customError (getCurrentException()) )
	)	
	else
	(
		if ((compileObjects list) == 0) then
		(
			exportSEAObjects()
		)
	)
	
	seaconfig_animation = anm
	
	if seaconfig_warning == false do
	(
		seaWarning.count = 0
	)
	
	openSEAListener()
	
	seaprogressEnd()
	
	set time off
	set animate off		
	set coordsys oc								
)

fn buildSEA3D = 
(
	seabuild = true
	
	seaBitmapList = #()
	seaCubeList = #()
	seaTextureList = #()
	seaMaterialList = #()
	seaObjectList = #()
	seaAssetList = #()
	seaAssetNames = #()
	seaTempFileList = #()
	seaModifierList = #()
	
	sea3d = (dotNetObject "Poonya.SEA3D.SEA3DWriter" sea_version)
	
	if seaconfig_fileinfo[1] and ((fileInfo = getFileInfoAsset()) != undefined) then
	(
		appendAsset fileInfo
	)
	
	with redraw off
	(
		local sel = GetCurrentSelection()
		
		if (seaconfig_export == "all") then
		(
			exportList (for o in objects where true collect o)
		)
		else if (seaconfig_export == "visible") then
		(
			exportList (for o in objects where not o.isHiddenInVpt collect o)
		)
		else if (seaconfig_export == "selected") then
		(						
			exportList sel			
		)
		
		selectMore sel
	)
	
	if seabuild == false then
	(
		seaError = "Export canceled."
	)
	else 
	(
		if sea3d.Objects.Count > 0 then
		(
			sea3d.CompressAlgorithm = seaconfig_compress				
			
			return sea3d
		)
		else
		(
			seaError = "No object was exported."
		)
	)
	
	return undefined
)

fn exportSEA3D filename =
(
	seaError = undefined
	seaErrors = #()
	seaWarning = #()	
	seaMaterials = #()
	seaTBakes = SEAHashTable()

	seasingleuv = seaconfig_renderall and (seaconfig_bakeoutput == BAKE_COMPLETE_MAP or seaconfig_bakeoutput == BAKE_DIFFUSE_MAP)	
	seauseparent = seaconfig_parent and seaconfig_snapshot == false
	seauseboneparent = true
	
	seaUnits[1] = units.DisplayType
	seaUnits[2] = units.MetricType
	
	local WM_SETREDRAW=0xB
	local commandHWND = windows.getChildHWND #max "Command Panel"
	
	local sea3d = undefined
	
	windows.sendmessage commandHWND[1]  WM_SETREDRAW 0 0
	
	units.DisplayType = #Generic
	units.MetricType = #Centimeters
	
	with redraw off
	(
		if seaconfig_exceptionprotection then
		(
			try (
				sea3d = buildSEA3D()
			)
			catch(seaerror = getCurrentException())
		)
		else
		(
			sea3d = buildSEA3D()
		)
			
		seaDispose()
	)
	
	units.DisplayType = seaUnits[1]
	units.MetricType = seaUnits[2]
	
	windows.sendmessage commandHWND[1]  WM_SETREDRAW 1 0
	
	if sea3d != undefined then
	(
		sea3d.Save filename
	)
	
	if seaError != undefined then
	(
		msgBox seaError
	)
)

--
-- Interface
--

rollout _SEA "SEA3D"
(		
	radiobuttons compressItem "Compression Algorithm" pos:[7,4] default:2 labels:#("None", "Deflate", "Lzma") 		
	radiobuttons exportItem "Export" pos:[7,40] default:2 labels:#("All", "Visible", "Selected")		
	
	label presetSample "Presets" pos:[7,75]	
	dropdownlist presetSettings width:134 pos:[7,92] 
	button presetSave "Save" pos:[157,92] width:50
	button presetFolder ":" pos:[144,92] width:10 caption:"Open presets folder." 
	
	progressBar progress pos:[7,128] width:200 height:14 align:#center
	
	button exportButton "Export" pos:[157,150] width:50
	button cancelButton "Cancel" pos:[157,150] width:50
	--checkbutton  syncButton "Sync" pos:[92,150] width:60
	
	hyperLink __url "sea3d.poonya.com/exporter" address:("http://sea3d.poonya.com/exporter/?p=3dsmax&v="+(sea_rawversion as string)) align:#center visitedColor:(color 255 255 255) pos:[40,180]
	label __copyright "SEA3D 1.8 © Sunag Entertainment" align:#center
	
	fn reload =
	(
		local presets = GetSEAConfigList()
		local items = #()
		
		for i=1 to presets.count do
		(
			append items (getFilenameFile presets[i])
		)
		
		presetSettings.items = items
		
		if (findItem items seaconfig_selected) == 0 do seaconfig_selected = undefined
		
		if seaconfig_selected != undefined do presetSettings.selection = findItem items seaconfig_selected
	)
		
	fn enabledExport val =
	(
		exportButton.visible = val
		
		if val do cancelButton.enabled = true
		
		cancelButton.visible = val == false
		
		seaupdatewindow()
	)
	
	fn onchange =
	(
		if seaconfig_compress == "none" then compressItem.state = 1
		else if seaconfig_compress == "deflate" then compressItem.state = 2
		else if seaconfig_compress == "lzma" then compressItem.state = 3
		
		if seaconfig_export == "all" then exportItem.state = 1
		else if seaconfig_export == "visible" then exportItem.state = 2
		else if seaconfig_export == "selected" then exportItem.state = 3
	)
	
	fn oninvalidate =
	(
		presetSave.enabled = true
	)
	
	on _SEA open do
	(
		append sea_listeners onchange
		append sea_changes oninvalidate
		
		onchange()
		
		reload()
		
		seaprogressbar = progress
		
		enabledExport true
		
		presetSave.enabled = false
	)
	
	on presetSettings selected s do
	(
		local config = ReadSEAConfig (presetSettings.selected + ".config")
		
		if config != undefined do
		(
			seaconfig_selected = presetSettings.selected
			GetSEAConfig (seaconfig = config)
		)
		
		seadispatchChange changes:false dispatch:true
	)
	
	on presetFolder pressed do
	(
		shellLaunch "explorer.exe" (getSourceFolder())
		
		reload()
	)
	
	on presetSave pressed do
	(
		presetSave.enabled = false
		
		if seaconfig_selected == undefined do seaconfig_selected = "Default"

		SetSEAConfig seaconfig
		
		WriteSEAConfig seaconfig (seaconfig_selected + ".config")
		
		reload()
	)
		
	on compressItem changed s do
	(
		if s == 1 then seaconfig_compress = "none"		
		else if s == 2 then seaconfig_compress = "deflate"
		else if s == 3 then seaconfig_compress = "lzma"
		
		seadispatchChange()
	)
	
	on exportItem changed s do
	(
		if s == 1 then seaconfig_export = "all"
		else if s == 2 then seaconfig_export = "visible"
		else if s == 3 then seaconfig_export = "selected"
		
		seadispatchChange()
	)	
	
	on exportButton pressed do
	(
		local presetSaveEnabled = presetSave.enabled
		
		presetSave.enabled = false
		
		enabledExport false
		
		local filename = getSaveFileName caption:"SEA3D File Format" types:"Sunag Entertainment Assets (*.sea)|*|SEA3D for Three.JS (*.tjs.sea)|*.tjs"
		
		if filename != undefined do
		(
			if (getFilenameType (toLower filename)) != ".sea" do
			(
				filename += ".sea"
			)
			
			exportSEA3D filename
		)
		
		enabledExport true
		
		presetSave.enabled = presetSaveEnabled
	)
	
	on cancelButton pressed do
	(
		seadispatchChange()
	)
)

rollout _SEAGlobal "Global"
(
	radiobuttons extMethod "Export Method" labels:#
	(
		"Scene Hierarchy", 
		"Global Transform",
		"Snapshot (not allow animation)"
	) pos:[7,7]	

	fn onchange =
	(
		if seaconfig_parent then extMethod.state = 1
		else if seaconfig_snapshot then extMethod.state = 3
		else extMethod.state = 2
	)
	
	on _SEAGlobal open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on extMethod changed s do
	(	
		seaconfig_snapshot = s == 3
		seaconfig_parent = s == 1
		
		seadispatchChange()
	)
)

rollout _SEAAnimation "Animation"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_animation
	checkbox _static "All Static" pos:[147,7] checked:seaconfig_allstatic tooltip:"Makes all objects as static. Recommended for scenery."
	
	spinner _start "Start:" pos:[17,27] range:[-1000000,1000000,animationRange.start.frame as integer] width:85 type:#integer 
	spinner _end "End:" pos:[117,27] range:[-1000000,1000000,animationRange.end.frame as integer] width:85 type:#integer
	
	checkbox _instance "Instance Animations" pos:[7,49] checked:seaconfig_instanceanimation toolTip:"Add animation mesh for an instantiated object that does not contain animation."
	checkbox _forceAnm "Force Animation Export" pos:[7,69] checked:seaconfig_force_animation toolTip:"Export animation of the objects not enabled."
	
	checkbox _bindoffset "Relative Transform" pos:[7,89] checked:seaconfig_bindoffset tooltip:"Starts from global or local(relative) position of the object. Bind Frame represent the initial frame."
	spinner _bindframe "Bind Frame:" pos:[9,109] range:[-1000000,1000000,seaconfig_bindframe] type:#integer
	
	fn updateAnimationRange =
	(
		seaTimeRange = #(_start.value, _end.value)
	)
	
	fn read = 
	(
		if (getnodebyname NODE_CONFIG) == undefined then
		(
			_start.value = animationRange.start.frame as integer
			_end.value = animationRange.end.frame as integer
			
			updateAnimationRange()
		)
	)
	
	fn updateRollout =
	(
		_static.visible = seaconfig_animation == false
		_start.visible = _end.visible = seaconfig_animation
		
		if seaconfig_animation then
		(
			_SEAAnimation.height = 132
		)
		else _SEAAnimation.height = 27
	)

	fn onchange =
	(
		_enabled.checked = seaconfig_animation
		_static.checked = seaconfig_allstatic
		_instance.checked = seaconfig_instanceanimation
		_forceAnm.checked = seaconfig_force_animation
		_bindoffset.checked = seaconfig_bindoffset
		_bindframe.value = seaconfig_bindframe
		
		updateRollout()
	)
	
	on _SEAAnimation open do
	(
		append sea_listeners onchange
		
		onchange()
		
		read()
		
		seaevent_anm = read
		
		callbacks.removeScripts id:#SEAAnimationTab
		callbacks.addScript #filePostOpen "seaevent_anm()" id:#SEAAnimationTab		
	)
	
	on _SEAAnimation close do
	(
		callbacks.removeScripts id:#SEAAnimationTab
	)
	
	on _static changed s do
	(
		seaconfig_allstatic = s
		
		seadispatchChange()
	)
	
	on _bindoffset changed s do
	(
		seaconfig_bindoffset = s
		
		seadispatchChange()
	)
	
	on _bindframe changed s do
	(
		seaconfig_bindframe = s

		seadispatchChange()
	)
	
	on _bindoffset changed s do
	(
		seaconfig_bindoffset = s
		
		seadispatchChange()
	)	
	
	on _start changed s do
	(
		if (_start.value > _end.value) do _end.value = _start.value
		
		updateAnimationRange()
		seadispatchChange()
	)
	
	on _end changed s do
	(
		if (_end.value < _start.value) do _start.value = _end.value
		
		updateAnimationRange()
		seadispatchChange()
	)
	
	on _instance changed s do
	(
		seaconfig_instanceanimation = s
		
		seadispatchChange()
	)
	
	on _forceAnm changed s do
	(
		seaconfig_force_animation = s
		
		seadispatchChange()
	)
	
	on _enabled changed s do
	(
		seaconfig_animation = s
		
		updateRollout()
		seadispatchChange()
	)
)

rollout _SEAGeometry "Geometry"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_geometry		
	checkbox _uvs "Texture Coordinates" pos:[80,7] checked:seaconfig_uv
	checkbox _multiple "Multiple Channels" pos:[80,27] checked:seaconfig_multiplechannel
	checkbox _normal "Normal" pos:[80,47] checked:seaconfig_normal
	checkbox _smoothingGroup "Smoothing Group" pos:[80,67] checked:seaconfig_sg			
	checkbox _tangent "Tangent" pos:[80,87] checked:seaconfig_tangent
	
	button addTag "Add Tag" pos:[7,27] width:66 height:23 toolTip:"Limits and add parameters that will used in exportation of the object."						
	
	fn updateRollout =
	(	
		_tangent.enabled = _smoothingGroup.enabled = seaconfig_geometry and seaconfig_normal
		_multiple.enabled  = seaconfig_geometry and seaconfig_uv
		_uvs.enabled = _normal.enabled = seaconfig_geometry
		_uvs.visible = seaconfig_geometry
		
		if seaconfig_geometry then
		(			
			_SEAGeometry.height = 108
		)
		else _SEAGeometry.height = 27
	)
	
	fn onchange =
	(
		_enabled.checked = seaconfig_geometry
		_uvs.checked = seaconfig_uv
		_multiple.checked = seaconfig_multiplechannel
		_normal.checked = seaconfig_normal
		_smoothingGroup.checked = seaconfig_sg
		_tangent.checked = seaconfig_tangent
		
		updateRollout()
	)
	
	on _SEAGeometry open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on addTag pressed do
	(
		if $ != undefined then
		(
			if (classof $) == ObjectSet then
			(
				for i = 1 to $.count do
				(
					if (containsSEA3DTag $[i]) == false then (
						creatSEA3DTag $[i]
					)
				)
			)
			else
			(
				if (containsSEA3DTag $) == false then (
					creatSEA3DTag $
				)
			)
		)
		else
		(
			msgBox "Select one or more objects to add a tag."
		)
	)
	
	on _enabled changed s do
	(
		seaconfig_geometry = s
		
		updateRollout()
		seadispatchChange()
	)
	
	on _uvs changed s do
	(
		_multiple.enabled = seaconfig_uv = s
		
		updateRollout()
		seadispatchChange()
	)
	
	on _multiple changed s do
	(
		seaconfig_multiplechannel = s
		
		seadispatchChange()
	)
	
	on _vertexColor changed s do
	(
		seaconfig_vertexcolor = s
		
		seadispatchChange()
	)
	
	on _normal changed s do
	(
		seaconfig_normal = s
		
		updateRollout()
		seadispatchChange()
	)
	
	on _tangent changed s do
	(
		seaconfig_tangent = s
		
		seadispatchChange()
	)
	
	on _smoothingGroup changed s do
	(
		seaconfig_sg = s
		
		seadispatchChange()
	)
)

rollout _SEAMorph "Morpher"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_morph
	
	fn onchange =
	(
		_enabled.checked = seaconfig_morph
	)
	
	on _SEAMorph open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on _enabled changed s do
	(
		seaconfig_morph = s
		
		seadispatchChange()
	)
)

rollout _SEAVA "Vertex Animation"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_vertexanimation
	
	fn onchange =
	(
		_enabled.checked = seaconfig_vertexanimation
	)
	
	on _SEAVA open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on _enabled changed s do
	(
		seaconfig_vertexanimation = s
		
		seadispatchChange()
	)
)

rollout _SEAVC "Vertex Color"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_vertexcolor toolTip:"Export Vertex Color if available."
	
	fn onchange =
	(
		_enabled.checked = seaconfig_vertexcolor
	)
	
	on _SEAVC open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on _enabled changed s do
	(
		seaconfig_vertexcolor = s
		
		seadispatchChange()
	)
)

rollout _SEARTT "RTT"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_rtt toolTip:"Render to Texture."
	checkbox _followTarget "Follow Target" pos:[120,7] checked:seaconfig_rtt_target toolTip:"Render to Texture."
	
	fn updateRollout =
	(
		_followTarget.enabled = seaconfig_rtt
	)
	
	fn onchange =
	(
		_enabled.checked = seaconfig_rtt
		_followTarget.checked = seaconfig_rtt_target
		
		updateRollout()
	)
	
	on _SEARTT open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on _enabled changed s do
	(
		seaconfig_rtt = s
		
		updateRollout()
		seadispatchChange()
	)
	
	on _followTarget changed s do
	(
		seaconfig_rtt_target = s
		
		seadispatchChange()
	)
)

rollout _SEASkeleton "Skeleton"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_skeleton			
	
	fn onchange =
	(
		_enabled.checked = seaconfig_skeleton
	)
	
	on _SEASkeleton open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on _enabled changed s do
	(
		seaconfig_skeleton = s
		
		seadispatchChange()
	)
)

rollout _SEAMaterials "Materials"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_material
	checkbox _share "Shared" pos:[157,7] checked:seaconfig_sharematerials tooltip:"Sharing material that has the same attributes."
	checkbox _enabledTexture "Texture" pos:[7,27] checked:seaconfig_texture
	checkbox _enabledAnimationTakes "Enabled Animation Takes" pos:[7,47] checked:seaconfig_texture
	checkbox _bakeUnkMat "Convert Incompatible Textures" pos:[7,67] checked:seaconfig_baketextures
	
	fn updateRollout =
	(
		_share.enabled = _enabledTexture.enabled = seaconfig_material
		_enabledAnimationTakes.enabled = _bakeUnkMat.enabled = seaconfig_material and seaconfig_texture
		
		if seaconfig_material then
		(
			if seaconfig_texture then
			(
				_SEAMaterials.height = 88
			)
			else
			(
				_SEAMaterials.height = 47
			)
		)
		else _SEAMaterials.height = 27
	)

	fn onchange =
	(
		_enabled.checked = seaconfig_material
		_share.checked = seaconfig_sharematerials
		_enabledTexture.checked = seaconfig_texture
		_enabledAnimationTakes.checked = seaconfig_textureAnimationTakes
		_bakeUnkMat.checked = seaconfig_baketextures
		
		updateRollout()
	)
	
	on _SEAMaterials open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on _enabled changed s do
	(
		seaconfig_material = s
		
		updateRollout()
		seadispatchChange()
	)
	
	on _bakeUnkMat changed s do
	(
		seaconfig_baketextures = s
		
		seadispatchChange()
	)
	
	on _enabledTexture changed s do
	(
		seaconfig_texture = s
		
		updateRollout()
		seadispatchChange()
	)
	
	on _enabledAnimationTakes changed s do
	(
		seaconfig_textureAnimationTakes = s		
		
		seadispatchChange()
	)	
	
	on _share changed s do
	(
		seaconfig_sharematerials = s
		
		seadispatchChange()
	)
)

rollout _SEACameras "Cameras"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_camera
	checkbox _target "Target" pos:[7,27] checked:seaconfig_cameratarget tooltip:"Export Camera Target."
	
	fn updateRollout =
	(	
		_target.enabled = seaconfig_camera
		
		if seaconfig_camera then
		(
			_SEACameras.height = 48
		)
		else _SEACameras.height = 27
	)

	fn onchange =
	(
		_enabled.checked = seaconfig_camera
		_target.checked = seaconfig_cameratarget
		
		updateRollout()
	)
	
	on _SEACameras open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on _target changed s do
	(
		seaconfig_cameratarget = s
		
		seadispatchChange()
	)
	
	on _enabled changed s do
	(
		seaconfig_camera = s
		
		updateRollout()
		seadispatchChange()
	)
)

rollout _SEALights "Lights"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_light
	checkbox _target "Target" pos:[7,27] checked:seaconfig_lighttarget tooltip:"Export Light Target."
	
	fn updateRollout =
	(
		_target.enabled = seaconfig_light
		
		if seaconfig_light then
		(
			_SEALights.height = 48
		)
		else _SEALights.height = 27
	)

	fn onchange =
	(
		_enabled.checked = seaconfig_camera
		_target.checked = seaconfig_cameratarget
		
		updateRollout()
	) 
	
	on _SEALights open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on _target changed s do
	(
		seaconfig_lighttarget = s
		
		seadispatchChange()
	)
	
	on _enabled changed s do
	(
		seaconfig_light = s
		
		updateRollout()
		seadispatchChange()
	)
)

rollout _SEASprite "Sprites"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_sprite
	button newSprite "Add Sprite" pos:[130,7] width:80 height:23
	
	fn updateRollout =
	(	
		newSprite.visible = seaconfig_sprite
		
		if seaconfig_sprite then
		(
			_SEASprite.height = 36
		)
		else _SEASprite.height = 27
	)

	fn onchange =
	(
		_enabled.checked = seaconfig_sprite
		
		updateRollout()
	)
	
	on _SEASprite open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on _enabled changed s do
	(
		seaconfig_sprite = s
		
		updateRollout()
		seadispatchChange()
	)		
	
	on newSprite pressed do
	(
		local s = creatSEA3DSprite()
		
		try ( s.position = $.transform.position )
		catch ()
		
		select s
		
		redrawViews()
	)
)

rollout _SEASounds "Sounds"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_sounds
	checkbox _allsounds "Include all sounds" pos:[7,27] checked:seaconfig_all_sounds	tooltip:"Add sounds not included in the scene."
	listBox _field "Sound List" pos:[9,47] width:200 height:9
	button newSound "Add Sound" pos:[130,37] width:80 height:23
	button uptBtn "Update" pos:[9,190] width:50 height:23 tooltip:"Update Sound List"
	button addBtn "Add" pos:[146,190] width:60 height:23
	button removeBtn "Remove" pos:[80,190] width:60 height:23
	
	fn addSound filename =
	(
		for i=1 to sea_sounds.count do
		( 
			if sea_sounds[i][1] == filename then
			(
				return false
			)						
		)
		
		local name = (GetName filename)
			
		if (findItem sea_sounds name) == 0 then
		(
			append sea_sounds #(filename, name)	
			append sea_sounds_names name
		)
		
		return true
	)
	
	fn updateList upFolder: =
	(				
		local names = #()
		local del_ids = #()
		
		for i=1 to sea_sounds.count do
		( 
			if (fileExist sea_sounds[i][1]) then
			(
				names[i] = sea_sounds[i][2]
			)			
			else			
			(
				append del_ids i
			)
		)
		
		for i=1 to del_ids.count do
		( 
			deleteItem sea_sounds (del_ids[i] - (i-1))
		)
		
		sea_sounds_names = names
		
		if upFolder == true then
		(
			local soundpath = maxFilePath + "sounds\\"
			
			if dirExist soundPath then
			(
				local dirFiles = getFiles (soundpath+"/*")
				
				for f in dirFiles do
				(
					local ext = getExtension f
					
					if (ext == EXT_OGG or ext == EXT_MP3) then
					(
						addSound f
					)
				)
			)
		)
		
		_field.items = sea_sounds_names
	)
	
	fn updateRollout =
	(	
		_allsounds.visible = seaconfig_sounds
		
		if seaconfig_sounds then
		(
			_SEASounds.height = 219
		)
		else _SEASounds.height = 27
	)
	
	fn onchange =
	(
		_enabled.checked = seaconfig_sounds
		_allsounds.checked = seaconfig_all_sounds
		
		updateRollout()
	)

	on _SEASounds open do
	(
		append sea_listeners onchange
		
		updateList upFolder:true
		
		onchange()
	)
	
	on _enabled changed s do
	(
		seaconfig_sounds = s
		
		updateRollout()
		seadispatchChange()
	)
	
	on _allsounds changed s do
	(
		seaconfig_all_sounds = s
		
		seadispatchChange()
	)
	
	on newSound pressed do
	(
		local snd = ""
		
		if _field.selection > 0 then
			snd = _field.items[_field.selection]
		
		local s = creatSEA3DSound snd
		
		try ( s.position = $.transform.position )
		catch ()
		
		select s
		
		redrawViews()
		seadispatchChange()
	)
	
	on addBtn pressed do
	(
		local filename = getOpenFileName caption:"Compressed Audio" types:"Compressed Audio (*.mp3, *.ogg)|*.mp3;*.ogg|All (*.*)|*.*"
		
		if filename != undefined then
		(
			addSound filename
			updateList()
		)
		
		seadispatchChange()
	)
	
	on removeBtn pressed do
	(
		if _field.selection > 0 then
		(		
			deleteItem sea_sounds _field.selection
			updateList()
		)
		
		seadispatchChange()
	)		
	
	on uptBtn pressed do
	(
		local soundPath = maxFilePath + "sounds\\"
		
		if (dirExist soundPath) == false then
		(	
			msgBox ("You can automatically update your audio files placing them in the \"sounds\" folder of your .max file.\n\nExample:\n\"" + soundPath + "audio.mp3\".")
		)
		
		updateList upFolder:true
		seadispatchChange()
	)
)

rollout _SEASplines "Splines"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_spline toolTip:"Convert Line to Path."
	spinner _steps "Steps:" pos:[80,7] range:[1,1000000,seaconfig_splinestep] type:#integer
	
	fn updateRollout =
	(
		_steps.enabled = seaconfig_spline
	)
	
	fn onchange =
	(
		_enabled.checked = seaconfig_spline
		_steps.value = seaconfig_splinestep
		
		updateRollout()
	)
	
	on _SEASplines open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on _enabled changed s do
	(
		seaconfig_spline = s
		
		updateRollout()
		seadispatchChange()
	)
	
	on _steps changed s do
	(
		seaconfig_splinestep = s
		
		seadispatchChange()
	)
)

rollout _SEADummy "Dummy"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_dummy		
	
	fn onchange =
	(
		_enabled.checked = seaconfig_dummy
	)
	
	on _SEADummy open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on _enabled changed s do
	(
		seaconfig_dummy = s
		
		seadispatchChange()
	)
)

rollout _SEAEnvironment "Environment"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_env	
	checkbox _environment "Environment Map" pos:[105,7] checked:seaconfig_envmap
	
	groupbox _fogGroup "Fog" pos:[7,27] width:202 height:90
	checkbox _fogEnabled "Enabled" pos:[13,45] checked:seaconfig_fog[1]
	
	colorpicker _fogColor "Color" pos:[17,90] color:seaconfig_fog[2]
	
	spinner _fogMin "Min:" pos:[27,67] range:[-100000000,100000000,seaconfig_fog[3]] width:70 type:#float 
	spinner _fogMax "Max:" pos:[117,67] range:[-100000000,100000000,seaconfig_fog[4]] width:80 type:#float 	
	
	fn updateRollout =
	(	
		_fogGroup.visible = _environment.enabled = seaconfig_env
		_fogMax.enabled = _fogMin.enabled = _fogColor.enabled = seaconfig_fog[1]
		
		if seaconfig_env then
		(
			_SEAEnvironment.height = 123
		)
		else _SEAEnvironment.height = 27
	)
	
	fn onchange =
	(
		_environment.checked = seaconfig_env
		_enabled.checked = seaconfig_envmap
		_fogEnabled.checked = seaconfig_fog[1]
		_fogColor.color = seaconfig_fog[2]
		_fogMin.value = seaconfig_fog[3]
		_fogMax.value = seaconfig_fog[4]
		
		updateRollout()
	)

	on _SEAEnvironment open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on _fogEnabled changed s do
	(
		seaconfig_fog[1] = s
		
		updateRollout()
		seadispatchChange()
	)
	
	on _fogColor changed s do
	(
		seaconfig_fog[2] = s
		
		seadispatchChange()
	)
	
	on _fogMin changed s do
	(
		seaconfig_fog[3] = s
		
		seadispatchChange()
	)
	
	on _fogMax changed s do
	(
		seaconfig_fog[4] = s
		
		seadispatchChange()
	)
	
	on _environment changed s do
	(
		seaconfig_envmap = s
		
		seadispatchChange()
	)
	
	on _enabled changed s do
	(
		seaconfig_env = s
		
		updateRollout()
		seadispatchChange()
	)
)

rollout _SEAUtils "Utils"
(	
	checkbox _warning "Show Warnings" pos:[7,7] checked:seaconfig_warning	
	checkbox _instances "Enabled Instances" pos:[7,27] checked:seaconfig_instances		
	checkbox _optimizer "Mesh Optimizer" pos:[7,47] checked:seaconfig_meshoptimizer	
	checkbox _joinVertices "Join Identical Vertices" pos:[7,67] checked:seaconfig_joinvertices	
	checkbox _autoRename "Auto Rename" pos:[7,87] checked:seaconfig_auto_rename
	checkbox _positiveScale "Force Positive Scale" pos:[7,107] checked:seaconfig_positive_scale
	checkbox _colorMat "Replace empty Material to Color" pos:[7,127] checked:seaconfig_materialcolor	 
	checkbox _exception "Exception Protection" pos:[7,147] checked:seaconfig_exceptionprotection tooltip:"Protects your scene against unknown errors (disable to debug mode). Use with caution!"	

	fn onchange =
	(
		_warning.checked = seaconfig_warning
		_instances.checked = seaconfig_instances
		_optimizer.checked = seaconfig_meshoptimizer
		_joinVertices.checked = seaconfig_joinvertices
		_autoRename.checked = seaconfig_auto_rename
		_positiveScale.checked = seaconfig_positive_scale
		_colorMat.checked = seaconfig_materialcolor
		_exception.checked = seaconfig_exceptionprotection
	)
	
	on _SEAUtils open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on _instances changed s do
	(
		seaconfig_instances = s
		
		seadispatchChange()
	)
	
	on _warning changed s do
	(
		seaconfig_warning = s
		
		seadispatchChange()
	)
	
	on _autoRename changed s do
	(
		seaconfig_auto_rename = s
		
		seadispatchChange()
	)
	
	on _positiveScale changed s do
	(
		seaconfig_positive_scale = s
		
		seadispatchChange()
	)
	
	on _colorMat changed s do
	(
		seaconfig_materialcolor = s
		
		seadispatchChange()
	)
	
	on _optimizer changed s do
	(
		seaconfig_meshoptimizer = s
		
		seadispatchChange()
	)
	
	on _joinVertices changed s do
	(
		seaconfig_joinvertices = s
		
		seadispatchChange()
	)
	
	on _exception changed s do
	(
		seaconfig_exceptionprotection = s
		
		seadispatchChange()
	)
)

rollout _SEAFileInfo "File Info"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_fileinfo[1]	
	
	groupbox grp1 "Summary" pos:[7,27] width:200 height:140
	
	label _name "Name" pos:[15,41]
	edittext _nameField pos:[15,60] width:180 text:seaconfig_fileinfo[2] 
	
	label _author "Author / Copyright" pos:[15,82] 
	edittext _authorField pos:[15,101] width:180 text:seaconfig_fileinfo[3] 
	
	label _website "Website" pos:[15,123] 
	edittext _websiteField pos:[15,142] width:180 text:seaconfig_fileinfo[4] 
	
	fn updateRollout =
	(	
		grp1.visible = seaconfig_fileinfo[1]
		
		if seaconfig_fileinfo[1] then
		(
			_SEAFileInfo.height = 173
		)
		else _SEAFileInfo.height = 27
	)
	
	fn onchange =
	(
		_enabled.checked = seaconfig_fileinfo[1]	
		_nameField.text = seaconfig_fileinfo[2]	
		_authorField.text = seaconfig_fileinfo[3]	
		_websiteField.text = seaconfig_fileinfo[4]	
		
		updateRollout()
	)

	on _SEAFileInfo open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on _enabled changed s do
	(
		_nameField.enabled = _authorField.enabled = _websiteField.enabled = seaconfig_fileinfo[1] = s
		
		updateRollout()
		seadispatchChange()
	)
	
	on _nameField changed s do 
	(
		seaconfig_fileinfo[2] = s
		
		seadispatchChange()
	)
	
	on _authorField changed s do
	(
		seaconfig_fileinfo[3] = s
		
		seadispatchChange()
	)
	
	on _websiteField changed s do
	(
		seaconfig_fileinfo[4] = s
		
		seadispatchChange()
	)

	on _nameField changed s do seaconfig_fileinfo[2] = s	
	on _authorField changed s do seaconfig_fileinfo[3] = s	
	on _websiteField changed s do seaconfig_fileinfo[4] = s	
)

rollout _SEAttribs "Custom Attributes"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_attrib	
	
	fn onchange =
	(
		_enabled.checked = seaconfig_attrib
	)
	
	on _SEAAttribs open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on _enabled changed s do
	(
		seaconfig_attrib = s
		
		seadispatchChange()
	)
)

rollout _SEABake "Bake"
(
	groupbox _texSizeGroup "Texture Size" pos:[7,7] width:202 height:62
	
	spinner _bakeVal "Power of 2:" pos:[43,27] range:[0,12,seaconfig_bakesize] width:80 type:#integer scale:.1 
	spinner _bakeQuality "Quality:" pos:[25,47] range:[1,100,seaconfig_bakequality] width:98 type:#integer scale:.2
	label _size "" pos:[133,28] width:65
	label _out "" pos:[133,48] width:65
	
	button _bakeOut "T" pos:[185,45] width:18 height:19 tooltip:"Toggle bake output."
	
	button _bakeSelect "Bake Select" pos:[137,75] tooltip:"Bake selected objects (no undo)."
	
	checkbox _renderallObjects "Render all objects" pos:[7,77] checked:seaconfig_renderall tooltip:"That does not export it the UVs settings and original textures (not allow animation)."	
	checkbox _createNewMap "Create new mapping" pos:[7,97] checked:seaconfig_newmapping
	
	radiobuttons _output "Output" pos:[7,(uisize=117)] labels:#("CompleteMap","DiffuseMap", "LightMap", "Ambiente Occlusion (MR)")
	
	-- Ambiente Occlusion Config
	
	groupbox _settingsGroup "Settings" pos:[7,(uisize+=79)] width:202 height:103
	
	dropdownlist _presetSettings items:#("Low", "Medium", "High") width:60 pos:[60,uisize+=18]
	label _presetSample "Presets" pos:[15,uisize+5]	
	
	spinner _samples  pos:[60,uisize+=27] range:[0,9999,32] width:40 type:#integer scale:.3 		
	spinner _spread  pos:[160,uisize] range:[0,9999,1.0] width:40 scale:.01 	
	label _labelSamples "Samples" pos:[15,uisize]
	label _labelSpread "Spread" pos:[110,uisize]
	
	colorpicker _bright  pos:[57,uisize+=18] checked:true fieldWidth:15 height:15 color:[255,255,255] modal:true
	spinner _maxDist  pos:[160,uisize] range:[0,9999,50.0] width:40 scale:.01 
	label _labelBright "Bright" pos:[15,uisize]
	label _labelMaxDist "Max Dist." pos:[110,uisize]
	
	colorpicker _dark  pos:[57,uisize+=18] checked:true fieldWidth:15 height:15 color:[0,0,0] modal:false
	spinner _falloff pos:[160,uisize] range:[0,9999,0.5] width:40 scale:.01 
	label _labelDark "Dark" pos:[15,uisize]
	label _labelFalloff "Falloff" pos:[110,uisize]
	
	checkbox _relativeSize "Relative Size" pos:[7,uisize+=29] checked:seaconfig_relativesize tooltip:"Bake size relative to the object size."		
	groupbox _texSizeGroup2 "Minimum Size" pos:[7,uisize+=20] width:202 height:42
	spinner _bakeVal2 "Power of 2:" pos:[43,uisize+=20] range:[1,13,seaconfig_minbakesize] width:80 type:#integer scale:.1 
	label _size2 pos:[133,uisize+1] width:65
	
	fn enabledAOConfig v =
	(
		_presetSample.enabled = 
		_presetSettings.enabled =
		_labelSamples.enabled = 
		_labelBright.enabled = 
		_labelDark.enabled =
		_labelSpread.enabled = 
		_labelMaxDist.enabled = 
		_labelFalloff.enabled = 		
		_samples.enabled = 
		_bright.enabled = 
		_dark.enabled = 				
		_spread.enabled = 
		_maxDist.enabled = 
		_falloff.enabled = v	
	)
	
	fn setBakeSettings =
	(
		seaao[1] = _samples.value
		seaao[2] = _bright.color
		seaao[3] = _dark.color
		seaao[4] = _spread.value
		seaao[5] = _maxDist.value
		seaao[6] = _falloff.value
	)
		
	fn getBakeSettings =
	(
		_samples.value = seaao[1]
		_bright.color = seaao[2]
		_dark.color = seaao[3]
		_spread.value = seaao[4]
		_maxDist.value = seaao[5]
		_falloff.value = seaao[6]
	)
	
	fn updateTextureSize =
	(
		_size.text = "Size: " + ((getPowerOf2 _bakeVal.value) as String)  + " px"		
		_size2.text = "Size: " + ((getPowerOf2 _bakeVal2.value) as String)  + " px"
	)	
	
	fn updateRelativeSize =
	(
		_texSizeGroup2.visible = _bakeVal2.visible = _size2.visible = seaconfig_relativesize
	)
	
	fn updateBakeOut =
	(
		local out = "Out: "
		
		if seaconfig_bakeext == EXT_JPEG then out += "JPEG"
		else if seaconfig_bakeext == EXT_PNG then out += "PNG"
		
		_bakeQuality.enabled = seaconfig_bakeext == EXT_JPEG
		
		_out.text = out
	)
	
	fn updateOutput =
	(
		if (seaconfig_bakeoutput == BAKE_COMPLETE_MAP) then _output.state = 1
		else if (seaconfig_bakeoutput == BAKE_DIFFUSE_MAP) then _output.state = 2
		else if (seaconfig_bakeoutput == BAKE_LIGHT_MAP) then _output.state = 3
		else if (seaconfig_bakeoutput ==BAKE_AO) then _output.state = 4
		else _output.state = 0
	)
	
	fn updateAOConfigDisplay =
	(
		enabledAOConfig (seaconfig_bakeoutput == BAKE_AO)
	)
	
	fn updateRollout =
	(
		--_output.visible = _createNewMap.visible =  seaconfig_renderall
		
		if _output.visible then
		(
			if seaconfig_relativesize then
			(
				_SEABake.height = 374
			)
			else
			(
				_SEABake.height = 326
			)
		)
		else _SEABake.height = 103
	)
	
	fn onchange =
	(
		updateRelativeSize()
		updateOutput()
		updateBakeOut()
		updateTextureSize()
		updateAOConfigDisplay()
		updateRollout()
		
		getBakeSettings()
	)
	
	on _SEABake open do
	(	
		append sea_listeners onchange		
		
		onchange()
	)
	
	on _bakeSelect pressed do
	(
		local list = GetCurrentSelection()
		
		if list.count > 0 then
		(		
			local seamasslist = undefined
			
			if seaconfig_relativesize then
			(
				seamasslist = getMassList list
			)
			
			seaError = undefined
			seaErrors = #()
			seaWarning = #()	
			seaMaterials = #()			
			seaTBakes = SEAHashTable()
			
			for i=1 to list.count do
			(
				local obj = list[i]
				
				if (classOfList obj seaCompatibleMeshList) then
				(
					if seaconfig_relativesize then
					(
						local bakeSize = ceil (seaconfig_minbakesize + ((seaconfig_bakesize - seaconfig_minbakesize) * seamasslist[i]))
						bakeMesh obj size:(getPowerOf2 bakeSize) temp:false
					)
					else
					(
						bakeMesh obj temp:false
					)
				)
			)
			
			openSEAListener()
		)
		else
		(
			msgBox "Select one or more meshes to bake."
		)
		
		selectMore list
		
		seadispatchChange()
	)	
	
	on _samples changed s do
	(
		setBakeSettings()
		seadispatchChange()
	)
	
	on _bright changed s do
	(
		setBakeSettings()
		seadispatchChange()
	)
	
	on _dark changed s do
	(
		setBakeSettings()
		seadispatchChange()
	)
	
	on _spread changed s do
	(
		setBakeSettings()
		seadispatchChange()
	)
	
	on _maxDist changed s do
	(
		setBakeSettings()
		seadispatchChange()
	)
	
	on _falloff changed s do
	(
		setBakeSettings()
		seadispatchChange()
	)
	
	on _presetSettings selected s do
	(				
		--_bright.color = [255,255,255]
		--_dark.color = [0,0,0]
		
		--_spread.value = 1.0
		--_maxDist.value = 50.0
		--_falloff.value = 0.5		
		
		if (s == 1) then
		(
			_samples.value = 64
		)
		else if (s == 2) then
		(
			_samples.value = 256
		)
		else if (s == 3) then
		(
			_samples.value = 1024
		)
		
		setBakeSettings()
		seadispatchChange()
	)
	
	on _output changed s do
	(				
		if (s == 1) then seaconfig_bakeoutput = BAKE_COMPLETE_MAP
		else if (s == 2) then seaconfig_bakeoutput = BAKE_DIFFUSE_MAP
		else if (s == 3) then seaconfig_bakeoutput = BAKE_LIGHT_MAP
		else seaconfig_bakeoutput = BAKE_AO		
		
		updateAOConfigDisplay()
		seadispatchChange()
	)
	
	on _relativeSize changed s do
	(
		seaconfig_relativesize = s
		
		updateRelativeSize()
		updateRollout()
		seadispatchChange()
	)
	
	on _renderallObjects changed s do
	(
		seaconfig_renderall = s
		
		updateRollout()
		seadispatchChange()
	)
	
	on _createNewMap changed s do
	(
		seaconfig_newmapping = s
		
		seadispatchChange()
	)
	
	on _bakeOut pressed do
	(
		if seaconfig_bakeext == EXT_JPEG then seaconfig_bakeext = EXT_PNG
		else if seaconfig_bakeext == EXT_PNG then seaconfig_bakeext = EXT_JPEG
		
		updateBakeOut()
		seadispatchChange()
	)
	
	on _bakeQuality changed s do
	(
		seaconfig_bakequality = s
		
		seadispatchChange()
	)	
		
	on _bakeVal changed s do
	(
		seaconfig_bakesize = s
		
		if seaconfig_bakesize < seaconfig_minbakesize then
		(
			_bakeVal2.value = seaconfig_minbakesize = seaconfig_bakesize
		)
		
		updateTextureSize()
		seadispatchChange()
	)
	
	on _bakeVal2 changed s do
	(
		seaconfig_minbakesize = s
		
		if seaconfig_minbakesize > seaconfig_bakesize then
		(
			_bakeVal.value = seaconfig_bakesize = seaconfig_minbakesize
		)
		
		updateTextureSize()
		seadispatchChange()
	)
)

rollout _ATFExtension "ATF Extension"
(
	checkbox _enabled "Enabled" pos:[7,7] checked:seaconfig_atf		
	checkbox _enabledAutoUpdate "Auto Update" pos:[130,7] checked:seaconfig_atf_auto tooltip:"Automatically updates ATF textures if modified."
	checkbox _enabledJpegXr "JPEG-XR + LZMA" pos:[7,27] checked:seaconfig_atf_jpegxr tooltip:"Compress block compressed textures using JPEG-XR+LZMA to reduce file."
	checkbox _enabledForce "Force" pos:[130,27] checked:seaconfig_atf_force tooltip:"Force auto update."
	radiobuttons compressItem "Texture Compression Algorithm" pos:[7,47] default:1 labels:#("All", "DXT", "ETC1", "PVRTC")
	
	fn updateRollout =
	(
		_enabledAutoUpdate.enabled = compressItem.enabled = seaconfig_atf
		_enabledJpegXr.enabled = _enabledForce.enabled = seaconfig_atf and seaconfig_atf_auto
		
		if seaconfig_atf_compress == ENC_ALL then compressItem.state = 1
		else if seaconfig_atf_compress == ENC_DXT then compressItem.state = 2
		else if seaconfig_atf_compress == ENC_ETC1 then compressItem.state = 3
		else if seaconfig_atf_compress == ENC_PVRTC then compressItem.state = 4
		
		if seaconfig_atf then
		(
			_ATFExtension.height = 83
		)
		else _ATFExtension.height = 27
	)

	fn onchange =
	(
		_enabled.checked = seaconfig_atf_jpegxr
		_enabledAutoUpdate.checked = seaconfig_atf_auto
		_enabledJpegXr.checked = seaconfig_atf_jpegxr
		_enabledForce.checked = seaconfig_atf_force
		
		updateRollout()
	)
	
	on _ATFExtension open do
	(
		append sea_listeners onchange
		
		onchange()
	)
	
	on _enabled changed s do
	(		
		seaconfig_atf = s
		
		updateRollout()
		seadispatchChange()
	)
	
	on _enabledJpegXr changed s do
	(
		seaconfig_atf_jpegxr = s
		
		seadispatchChange()
	)
	
	on _enabledForce changed s do
	(		
		seaconfig_atf_force = s
		
		seadispatchChange()
	)
	
	on _enabledAutoUpdate changed s do
	(
		seaconfig_atf_auto = s
		
		updateRollout()
		seadispatchChange()
	)
	
	on compressItem changed s do
	(
		if s == 1 then seaconfig_atf_compress = ENC_ALL		
		else if s == 2 then seaconfig_atf_compress = ENC_DXT
		else if s == 3 then seaconfig_atf_compress = ENC_ETC1
		else if s == 4 then seaconfig_atf_compress = ENC_PVRTC
		
		seadispatchChange()
	)
)

--
-- Initializer
--

if sea_floater != undefined do
(
	closerolloutfloater sea_floater 
)

sea_floater = newRolloutFloater "SEA3D Exporter" 230 500

addRollout _SEA sea_floater rolledUp:false
addRollout _SEAFileInfo sea_floater rolledUp:false
addRollout _SEAGlobal sea_floater rolledUp:true
addRollout _SEABake sea_floater rolledUp:true
if ATF_SUPPORTS do addRollout _ATFExtension sea_floater rolledUp:false
addRollout _SEAAnimation sea_floater rolledUp:false
addRollout _SEAGeometry sea_floater rolledUp:false
addRollout _SEAVA sea_floater rolledUp:false
addRollout _SEAVC sea_floater rolledUp:false
addRollout _SEARTT sea_floater rolledUp:false
addRollout _SEAMorph sea_floater rolledUp:false
addRollout _SEASkeleton sea_floater rolledUp:false
addRollout _SEAMaterials sea_floater rolledUp:false
addRollout _SEACameras sea_floater rolledUp:false
addRollout _SEALights sea_floater rolledUp:false
addRollout _SEASprite sea_floater rolledUp:false
addRollout _SEASplines sea_floater rolledUp:false
addRollout _SEADummy sea_floater rolledUp:false
addRollout _SEAttribs sea_floater rolledUp:false
addRollout _SEAEnvironment sea_floater rolledUp:false
addRollout _SEASounds sea_floater rolledUp:false
addRollout _SEAUtils sea_floater rolledUp:false

registerViewWindow sea_floater