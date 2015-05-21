fileIn "Setup.inc" 

fn getSEA3DStringVersion =
(
	global sea_rawversion -- VSBB
	
	local s = (sea_rawversion as string)
	local v = (substring s 1 (s.count-4))
	v += "." + (substring s (s.count-3) 1)
	v += "." + (substring s (s.count-2) 1)
	v += "." + (((substring s (s.count-1) 2) as integer) as string)
		
	return v
)

fn getSEA3DPath = 
(
	return (getSEA3DSetupFolder subfolders:2) + "SEA3D\\"
)

fn getSEA3DVersion =
(
	try
	(
		fileIn (getSEA3DFolder() + "SEA3D.inc")		
		return ("SEA3D " + getSEA3DStringVersion())
	)
	catch
	(
		return undefined
	)
)

rollout SEA3DInstaller "" width:830 height:380
(
	local ConvertClass = dotnetclass "system.convert"
	local ImageClass = dotnetclass "system.drawing.image"
	local ColorClass = dotnetclass "system.drawing.color"
	local Align = dotnetclass "System.Drawing.ContentAlignment"
	
	button installBtn "Install" pos:[10,350] width:170 height:20
	button uninstallBtn "Uninstall" pos:[190,350] width:170 height:20 checked:false enabled:false	
	button sea3dFolder "Got to SEA3D folder" pos:[370,350] width:170 height:20 checked:false enabled:false
	
	dotNetControl lab1 "Label" pos:[0,0] width:830 height:341
	
	fn ConvertBase64StringToImage string =
	(
		bytearr = ConvertClass.FromBase64String string
		memstream = dotnetobject "System.IO.MemoryStream" bytearr
		DecodedImg = ImageClass.fromstream memstream
		memstream.close()
		return DecodedImg
	)
	
	fn updateSEA3DStatus = 
	(
		local sea3dversion = getSEA3DVersion()
		
		if sea3dversion != undefined then
		(
			lab1.font = dotNetObject "System.Drawing.Font" "Verdana" 7 
			lab1.text = sea3dversion + " Installed"
			
			sea3dFolder.enabled = uninstallBtn.enabled = true
		)
		else 
		(
			lab1.text = ""
			
			sea3dFolder.enabled = uninstallBtn.enabled = false
		)
	)
		
	fn restart3dsMax =
	(
		msgBox "May make it necessary to restart your 3ds Max to apply the changes."		
	)
	
	fn uninstall show  =
	(
		global sea_floater
			
		if sea_floater != undefined do
		(
			closerolloutfloater sea_floater 
		)
		
		local installedsea3dfolder = getSEA3DFolder()
		
		local dirFiles = getFiles (installedsea3dfolder+"/*")
			
		for i=1 to dirFiles.count do
		(						
			 deleteFile dirFiles[i]
		)
		
		print ("SEA3D: " + installedsea3dfolder)
		
		HiddenDOSCommand ("rd " + "\"" + installedsea3dfolder + "\"")
		
		if show do 
		(
			msgBox ("SEA3D was successfully uninstalled.")	
		)
		
		updateSEA3DStatus()
	)
	
	on uninstallBtn pressed do
	(
		uninstall true
		restart3dsMax()
	)
	
	on installBtn pressed do
	(
		local sea3dversion = getSEA3DVersion()
		
		if sea3dversion != undefined then
		(			
			uninstall false
		)
		
		-- Install
		local sea3dfolder = getSEA3DPath()
		
		if dirExist sea3dfolder then
		(
			local dirFiles = getFiles (sea3dfolder+"/*")
			
			makedir (getSEA3DFolder())
			
			for i=1 to dirFiles.count do
			(						
				local file = filterString dirFiles[i] "\\"					
				copyFile dirFiles[i] (getSEA3DFolder() + file[file.count])
			)
			
			fileIn "Launcher.inc"
			
			local msg = "SEA3D was successfully installed.\n\nTo access use:\n"
			
			msg += "1. Customize -> Customize User Interface...\n"
			msg += "2. Toolbars.\n"
			msg += "3. Select the category \"Sunag Entertainment\".\n"
			msg += "4. Drag SEA3D icons to the toolbar of your choice."
							
			msgBox msg
			
			fileIn (getSEA3DFolder() + "SEA3D.ms")		
			
			if sea3dversion != undefined then
			(
				restart3dsMax()
			)
			
			updateSEA3DStatus()
		)
		else msgBox ("Directory of the SEA3D not found in " + sea3dfolder + ".")		
	)	
	
	on sea3dFolder pressed do
	(		
		shellLaunch "explorer.exe" (getSEA3DFolder())
	)
	
	on SEA3DInstaller open do
	(
		lab1.backcolor = ColorClass.FromArgb 33 33 33	
		lab1.forecolor = ColorClass.white				
		lab1.imagealign = Align.TopLeft		
		
		try
		(
			lab1.image = ConvertBase64StringToImage sea3dlogo	
		)
		catch ()
		
		updateSEA3DStatus()
	)
)

createdialog SEA3DInstaller style:#(#style_toolwindow, #style_sysmenu)