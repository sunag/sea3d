macroScript SEA3DExporterLaucher
	category:"Sunag Entertainment"
	toolTip:"SEA3D Exporter"
	buttonText:"SEA3D"
(
	on execute do 
	(
		try ( fileIn ((GetDir #userscripts) + "\\SEA3D\\SEA3D.ms") )
		catch()
	)
)

macroScript SEA3DAnimationLaucher
	category:"Sunag Entertainment"
	toolTip:"SEA3D Animation"
	buttonText:"Animation"
(
	on execute do 
	(
		try ( fileIn ((GetDir #userscripts) + "\\SEA3D\\SEA3DAnimation.ms") )
		catch()
	)
)

macroScript SEA3DMaterialLaucher
	category:"Sunag Entertainment"
	toolTip:"SEA3D Material"
	buttonText:"Material"
(
	on execute do 
	(
		try ( fileIn ((GetDir #userscripts) + "\\SEA3D\\SEA3DMaterial.ms") )
		catch()
	)
)