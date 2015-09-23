-- SEA3D Exporter
-- Copyright (C) 2013 Sunag Entertainment

fileIn "SEA3D.inc" 
if (LoadSEADLL() == false) then exit

global sea_mat_read = undefined

rollout _SEABlend "Blend"
(
	radiobuttons blendType "Type" pos:[7,4] default:0 labels:#("Normal", "Add", "Multiply", "Alpha")	
	
	fn readObjects =
	(
		local list = GetCurrentSelection()		
		
		if list.count == 0 then
		(
			blendType.state = 0
			return undefined
		)
		
		local userprop = getUserProp list[1] DEF_MATERIAL_BLEND_TYPE
		
		if list.count > 1 then
		(
			for i = 2 to list.count do
			(
				if userprop != (getUserProp list[i] DEF_MATERIAL_BLEND_TYPE) then
				(
					userprop = undefined
					exit
				)
			)
		)
		
		local state = 0
		
		if userprop == "normal" then state = 1
		else if userprop == "add" then state = 2
		else if userprop == "multiply" then state = 3
		else if userprop == "alpha" then state = 4
		
		blendType.state = state
	)
	
	fn writeObjects =
	(
		local list = GetCurrentSelection()		
		
		local blendValue = undefined
		local state = blendType.state
		
		if state == 1 then blendValue = "normal"
		else if state == 2 then blendValue = "add"
		else if state == 3 then blendValue = "multiply"
		else if state == 4 then blendValue = "alpha"
		
		for i = 1 to list.count do
		(
			setUserProp list[i] DEF_MATERIAL_BLEND_TYPE blendValue
		)		
	)
	
	on blendType changed s do
	(
		writeObjects()
	)
	
	on _SEABlend open do
	(
		readObjects()
		
		sea_mat_read = readObjects
		
		callbacks.removeScripts id:#SEAMaterialBlend
		callbacks.addScript #selectionSetChanged "sea_mat_read()" id:#SEAMaterialBlend
	)	
	
	on _SEABlend close do
	(
		sea_mat_read = undefined
		callbacks.removeScripts id:#SEAMaterialBlend
	)
)

--
--	Init
--

if seamaterialfloater != undefined do
(
	closerolloutfloater seamaterialfloater 
)

seamaterialfloater = newRolloutFloater "SEA3D Material" 230 115

addRollout _SEABlend seamaterialfloater rolledUp:false