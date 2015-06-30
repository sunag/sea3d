-- SEA3D Exporter
-- Copyright (C) 2013 Sunag Entertainment

fileIn "SEA3D.inc" 
if (LoadSEADLL() == false) then exit

global sea_anm_data = undefined, sea_anm_objs = undefined, sea_anm_read = undefined

rollout _SEASE "Sequence Editor"
(
	listBox sequenceField pos:[9,9] width:210 height:9
	checkbox _enabled "Enabled" pos:[7,140]	
	label _start "Start" pos:[8,206] width:84 height:13
	label _end "End" pos:[116,206] width:84 height:13
	label _name "Name" pos:[9,160] width:84 height:13
	editText nameField "" pos:[5,179] width:200 height:22
	spinner startField "" pos:[7,226] width:90 height:16 range:[-100000,100000,0] type:#integer scale:1
	spinner endField "" pos:[115,226] width:90 height:16 range:[-100000,100000,0] type:#integer scale:1		
	button upBtn "Up" pos:[9,248] width:63 height:23
	button downBtn "Down" pos:[9,274] width:63 height:23		
	checkbox intrplBtn "Interpolation" pos:[82,275] width:128 height:16 --visible:false
	checkbox repeatBtn "Repeat" pos:[82,252] width:128 height:16
	button copyBtn "Copy" pos:[9,310] width:30 height:23
	button pasteBtn "Paste" pos:[42,310] width:30 height:23
	button addBtn "Add" pos:[146,310] width:60 height:23
	button removeBtn "Remove" pos:[80,310] width:60 height:23
	--button solo "Solo" pos:[168,140] width:40 height:16
	
	fn writeAnmData =
	(
		for i = 1 to sea_anm_objs.count do
		(
			setUserProp sea_anm_objs[i] DEF_ANIMATION_CONFIG (sea_anm_data.ToBase64())
		)			
	)
	
	fn readValidAnmData = 
	(
		local data = getUserProp sea_anm_objs[1] DEF_ANIMATION_CONFIG
		
		for i = 2 to sea_anm_objs.count do
		(
			local nodeData = getUserProp sea_anm_objs[i] DEF_ANIMATION_CONFIG
			
			if nodeData != data then
			(
				data = undefined
				exit
			)									
		)
		
		data
	)
	
	fn readAnmData = 
	(
		sea_anm_data = undefined		
		
		local data = readValidAnmData()	
		
		if data != undefined then
		(
			local seq = undefined
			
			try
			(
				seq = dotNetObject "Poonya.Utils.Hashtable"			
				seq.ReadBase64 data				
				sea_anm_data = seq
			)
			catch ()
		)
		
		if sea_anm_data == undefined then
		(
			sea_anm_data = dotNetObject "Poonya.Utils.Hashtable"	
			sea_anm_data.Add "version" sea_rawversion
			sea_anm_data.Add "sequences" (dotNetObject "Poonya.Utils.ArrayList")
		)
	)
	
	fn getSequences =
	(
		return (sea_anm_data.Get "sequences")
	)
	
	fn getSequence index: =
	(
		if (getSequences()).Length == 0 then return undefined
		if (index == unsupplied) do index = (sequenceField.selection-1)
		return ((getSequences()).Get index)
	)
	
	fn newSequence name start end repeat: intrpl: enabled: =
	(
		if (repeat == unsupplied) do repeat = true
		if (intrpl == unsupplied) do intrpl = true
		if (enabled == unsupplied) do enabled = true
		
		local seq = dotNetObject "Poonya.Utils.Hashtable"		
		seq.Add "name" name
		seq.Add "start" start
		seq.Add "end" end
		seq.Add "repeat" repeat
		seq.Add "intrpl" intrpl
		seq.Add "enabled" enabled
		
		return seq
	)
	
	fn readSequence seq =
	(
		removeBtn.enabled =
		sequenceField.enabled =
		upBtn.enabled = 
		downBtn.enabled =
		nameField.enabled = 
		startField.enabled = 
		endField.enabled = 
		repeatBtn.enabled = 		
		intrplBtn.enabled =		
		_enabled.enabled = seq != undefined
		
		copyBtn.enabled =
		pasteBtn.enabled =
		addBtn.enabled = $ != undefined
		
		if (seq == undefined) then
			seq = newSequence "" (animationRange.start.frame as integer) (animationRange.end.frame as integer) repeat:false intrpl:false enabled:false					
		
		nameField.text = seq.GetDef "name" ""
		startField.value = seq.GetDef "start" 0
		endField.value = seq.GetDef "end" 0
		repeatBtn.checked = seq.GetDef "repeat" true
		intrplBtn.checked = seq.GetDef "intrpl" true
		
		nameField.enabled = 
		startField.enabled = 
		endField.enabled = 
		repeatBtn.enabled = 
		intrplBtn.enabled =				
		_enabled.checked = seq.GetDef "enabled" true			
	)		
	
	fn readSequences =
	(
		if sea_anm_objs == undefined do 
		(
			sequenceField.items = #()
			readSequence undefined
			return undefined
		)
		
		readAnmData()
		
		local states = #()						
		local length = (getSequences()).Length
		
		for i = 1 to length do
		(
			local seq = getSequence index:(i-1)
			
			local name = seq.GetDef "name" ""
			local start = ((seq.GetDef "start" 0) as integer) as string
			local end = ((seq.GetDef "end" 0) as integer) as string
			local repeat = seq.GetDef "repeat" true
			local intrpl = seq.GetDef "intrpl" true
			local enabled = seq.GetDef "enabled" true
			
			local state = name + ", " + start + ", " + end + ", ["
			
			if enabled then
			(
				if intrplBtn.visible and intrpl do state += "I"
				if repeat do state += "R"				
			)
			else
			(
				state += "OFF"
			)				
			
			states[i] = state + "]"
		)
		
		sequenceField.items = states
		
		if (sequenceField.selection == 0) do
			sequenceField.selection = 1
			
		readSequence (getSequence index:(sequenceField.selection-1))
	)
	
	fn changeItemPos dir =
	(
		local list = getSequences()
		
		local indexSource = (sequenceField.selection-1)
		local indexTarget = indexSource+dir
		
		if indexTarget >= 0 and indexTarget < list.Length then
		(
			list.Swap indexSource indexTarget			
			sequenceField.selection = (indexTarget+1)
			
			writeAnmData()	
			readSequences()	
		)
	)	
	
	fn read =
	(
		sea_anm_objs = GetCurrentSelection()
		if sea_anm_objs.count == 0 do sea_anm_objs = undefined
		readSequences()
	)
	
	on sequenceField selected id do 
	(
		readSequence (getSequence())
	)
			
	on startField changed value do
	(
		if (startField.value > endField.value) do 
		(
			endField.value = startField.value
			(getSequence()).Add "end" endField.value
		)
		
		(getSequence()).Add "start" value
			
		writeAnmData()	
		readSequences()		
	)
	
	on endField changed value do
	(
		if (endField.value < startField.value) do 
		(
			startField.value = endField.value
			(getSequence()).Add "end" startField.value
		)
		
		(getSequence()).Add "end" value
			
		writeAnmData()	
		readSequences()	
	)
	
	on repeatBtn changed value do
	(
		(getSequence()).Add "repeat" value
			
		writeAnmData()	
		readSequences()	
	)
	
	on intrplBtn changed value do
	(
		(getSequence()).Add "intrpl" value
			
		writeAnmData()	
		readSequences()	
	)
	
	on _enabled changed value do
	(
		(getSequence()).Add "enabled" value
			
		writeAnmData()	
		readSequences()		
	)
	
	on nameField changed value do
	(
		(getSequence()).Add "name" value
			
		writeAnmData()	
		readSequences()		
	)
	
	on copyBtn pressed do
	(
		local data = readValidAnmData()

		if data != undefined do
		(
			local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard"
			clipboardClass.SetText data		
		)
	)
	
	on pasteBtn pressed do
	(
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard"		
		local data = undefined 
		
		if clipboardClass.ContainsText() do
		(
			data = clipboardClass.GetText()
		)
		
		if data != undefined do
		(
			try
			(
				seq = dotNetObject "Poonya.Utils.Hashtable"			
				seq.ReadBase64 data				
				sea_anm_data = seq
				
				writeAnmData()	
				readSequences()
			)
			catch ()
		)
	)
	
	on addBtn pressed do
	(		
		(getSequences()).Add (newSequence "new-sequence" (animationRange.start.frame as integer) (animationRange.end.frame as integer))
		
		sequenceField.selection = (getSequences()).Length		
		
		writeAnmData()	
		readSequences()	
	)
	
	on removeBtn pressed do
	(
		local sel = sequenceField.selection-1
		
		(getSequences()).RemoveAt sel
		
		if (sel == (getSequences()).Length) do 
			sequenceField.selection = sel
			
		writeAnmData()	
		readSequences()	
	)
	
	on upBtn pressed do
	(
		changeItemPos -1	
	)
	
	on downBtn pressed do
	(
		changeItemPos 1	
	)
	
	on _SEASE open do
	(
		sea_anm_read = read
		
		read()				
		
		callbacks.removeScripts id:#SEASE
		callbacks.addScript #selectionSetChanged "sea_anm_read()" id:#SEASE
	)	
	
	on _SEASE close do
	(
		sea_anm_data = sea_anm_objs = sea_anm_read = undefined
		callbacks.removeScripts id:#SEASE
	)	
)

--
--	Init
--

if seaanmfloater != undefined do
(
	closerolloutfloater seaanmfloater 
)

seaanmfloater = newRolloutFloater "SEA3D Animation" 230 368

addRollout _SEASE seaanmfloater rolledUp:false