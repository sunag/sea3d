-- SEA3D Exporter
-- Copyright (C) 2015 Sunag Entertainment

--
-- Global
--

global 	
	sea_rawversion = 18002, --VVSSBB ( Exporter version )
	sea_version = 18000 --VVSSBB

global
	NODE_CONFIG = "sea3d-config"

global
	DEF_ANIMATION_CONFIG = "animation-config",
	DEF_MATERIAL_BLEND_TYPE = "material-blendtype"

fn fileExist str =
(
	return ((dotnetclass "System.IO.File").exists str)
)

fn dirExist str =
(
	return ((dotnetclass "System.IO.Directory").exists str)
)

fn toLowerString str =
(
	return (dotNetObject "System.String" str).ToLower()
)

fn replaceChar str char tostr =
(
	local i = 1, count = str.count+1
	while i < count do	
	(
		if str[i] == char then		
		(
			str = replace str i 1 tostr
			i += tostr.count			
		)
		else i += 1
	)
	
	return str
)

fn getExtension f =
(
	return (toLowerString (substring f (f.count-3) 4))
)

fn getCleanFilename f =
(
	return (substring f 1 (f.count - (getExtension f).count))
)

fn getCleanExtension f =
(
	return (substring (getExtension f) 2 5)
)

fn getName f =
(
	local file = filterString f "\\"	
	local name = file[file.count]
	
	local i = name.count
	
	while i > 1  do
	(
		if name[i] == "." then
		(
			return substring name 1 (i-1)			
		)
		i -= 1
	)
	
	return name
)

fn getSourceFolder = 
(
	local filename = getSourceFileName()
	local i = filename.count	
	
	while i > 1  do
	(
		if filename[i] == "\\" then
		(
			return substring filename 1 i			
		)
		i -= 1
	)
	
	return ""
)	

fn msgBox str = 
(
	(dotnetclass "System.Windows.Forms.MessageBox").Show str	
)

--
--	DLL
--

fn LoadSEADLL =
(
	seaconfigDLLPath = getSourceFolder() + "SEA3D.dll"

	if (fileExist seaconfigDLLPath) then
	(
		dotnet.loadAssembly seaconfigDLLPath
		return true
	)
	else
	(
		msgBox "Can not find the SEA3D.dll.\nPut in the same folder as the script or download at http://code.google.com/p/sea3d/."		
	)

	return false
)