--------	Control code scenario utility
--	This utility adds a set of buttons to the GM screen allowing for the viewing and 
--	setting of player ship control codes
--
--	In addition to requiring this file, you will need to add a line to call these buttons:
--		addGMFunction("+Control Codes",manageControlCodes)
--	Further, you should put this call line in function mainGMButtons that can be returned to:
--		function mainGMButtons()
--			clearGMFunctions()
--			addGMFunction("+Control Codes",manageControlCodes)
--		end
--
--	The plus sign at the start of the button label indicates that another set of 
--	buttons comes up when clicking the button. Similarly, the minus sign at the start of 
--	the button label indicates that the GM will return to a previous set of buttons when
--	clicking the button.
function manageControlCodes()
	setControlCodeGlobals()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main From Ctl Codes"),mainGMButtons)
	local active_player_ships = getActivePlayerShips()
	if #active_player_ships == 0 then
		addGMMessage(_("msgGM","There are no active player ships for you to view or set the control codes for."))
		mainGMButtons()
	else
		viewControlCodes()
		addGMFunction(_("buttonGM","View Control Codes"),viewControlCodes)
		addGMFunction(_("buttonGM","+Set Control Codes"),setControlCodes)
	end
end
function setControlCodeGlobals()
	--	code_object is set and used in this utility
	
--	This is where you set default codes based on the ship names you are using. Example:
--	default_player_ship_control_code = {
--		["Phoenix"] =	"BURN265",
--		["Callisto"] =	"MOON558",
--		["Charybdis"] =	"JACKPOT777",
--		["Sentinel"] =	"FERENGI432",
--		["Omnivore"] =	"EQUILATERAL180",
--		["Tarquin"] =	"TIME909",
--	}
end
function viewControlCodes()
	local code_count = 0
	local name_code_faction = {}
	local active_player_ships = getActivePlayerShips()
	for i,p in ipairs(active_player_ships) do
		if p.control_code ~= nil then
			table.insert(name_code_faction,{name = p:getCallSign(), control_code = p.control_code, faction = p:getFaction()})
			code_count = code_count + 1
		else
			table.insert(name_code_faction,{name = p:getCallSign(), faction = p:getFaction()})
		end
	end
	if code_count > 0 then
		table.sort(name_code_faction)
		local out = _("msgGM","Player ships and some of their control codes:")
		if code_count == #active_player_ships then
			out = _("msgGM","Player ships and their control codes:")
		end
		for i,ship in ipairs(name_code_faction) do
			if ship.control_code == nil then
				out = string.format(_("msgGM","%s\n%s: <none> (%s)"),out,ship.name,ship.faction)
			else
				out = string.format(_("msgGM","%s\n%s: %s (%s)"),out,ship.name,ship.control_code,ship.faction)
			end
		end
		addGMMessage(out)
	else
		addGMMessage(_("msgGM","None of the active player ships have a control code set for you to view."))
	end
end
function setControlCodes()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main From Set Codes"),mainGMButtons)
	addGMFunction(_("buttonGM","-Control Codes"),manageControlCodes)
	local button_label = _("buttonGM","Change Code Object")
	if code_object == nil then
		button_label = _("buttonGM","+Select Code Object")
	end
	addGMFunction(button_label,changeCodeObject)
	if code_object ~= nil then
		local p = playerShipSelected()
		if p ~= nil then
			addGMFunction(_("buttonGM","+Set Control Code"),function()
				local dcp = playerShipSelected()	--double check player ship selected
				if dcp ~= nil then
					dcp.control_code = code_object:getDescription()
					dcp:setControlCode(code_object:getDescription())
					addGMMessage(string.format(_("msgGM","%s now has a control code of %s"),dcp:getCallSign(),dcp.control_code))
				else
					addGMMessage(_("msgGM","Player ship not selected. No action taken"))
				end
				setControlCodes()
			end)
		else
			addGMFunction(_("buttonGM","+Select Player"),setControlCodes)
		end
	end
	if default_player_ship_control_code ~= nil then
		addGMFunction(_("buttonGM","+Default Control Codes"),setDefaultControlCodes)
	end
end
function changeCodeObject()
	local object_list = getGMSelection()
	if object_list ~= nil then
		if #object_list == 1 then
			code_object = object_list[1]
			addGMMessage(string.format(_("msgGM","Object in %s selected to set control code.\nPlace control code in unscanned description field via tweak button"),code_object:getSectorName()))
			setControlCodes()
		else
			addGMMessage(_("msgGM","Select only one object to use to set control code via its unscanned description field. No action taken"))
			setControlCodes()
		end
	else
		addGMMessage(_("msgGM","Select an object to use to set control code via its unscanned description field. No action taken"))
		setControlCodes()
	end 
end
function playerShipSelected()
	local selected_player = getPlayerShip(-1)
	local object_list = getGMSelection()
	local selected_matches_player = false
	for i=1,#object_list do
		local current_selected_object = object_list[i]
		for pidx, p in ipairs(getActivePlayerShips()) do
			if p == current_selected_object then
				selected_matches_player = true
				selected_player = p
				break
			end
		end
		if selected_matches_player then
			break
		end
	end
	if selected_matches_player then
		return selected_player
	end
	return nil
end
function setDefaultControlCodes()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main From Defaults"),mainGMButtons)
	addGMFunction(_("buttonGM","-Control Codes"),manageControlCodes)
	addGMFunction(_("buttonGM","-Set Codes"),setControlCodes)
	viewPlayersMatchesDefaults()
	addGMFunction(_("buttonGM","View Defaults"),viewPlayersMatchesDefaults)
	addGMFunction(_("buttonGM","Set Defaults"),function()
		local codes_set = {}
		for name,code in pairs(default_player_ship_control_code) do
			for i,p in ipairs(getActivePlayerShips()) do
				if name == p:getCallSign() then
					p.control_code = code
					p:setControlCode(code)
					table.insert(codes_set,{name = name,code = code})
				end
			end
		end
		local out = _("msgGM","No matches found. No codes set.")
		if #codes_set > 0 then
			out = _("msgGM","The following player ships have their control codes set:")
			table.sort(codes_set)
			for i,ship in ipairs(codes_set) do
				out = string.format(_("msgGM","%s\n%s: %s"),out,ship.name,ship.code)
			end
		end
		addGMMessage(out)
	end)
end
function viewPlayersMatchesDefaults()
	local matches = {}
	local active_player_ships = getActivePlayerShips()
	for name,code in pairs(default_player_ship_control_code) do
		for i,p in ipairs(active_player_ships) do
			if name == p:getCallSign() then
				table.insert(matches,name)
			end
		end
	end
	local matches_out = _("msgGM","No matches between player ships and defaults.")
	table.sort(matches)
	if #matches > 0 then
		matches_out = _("msgGM","Matches between active player ships and defaults:")
		for i,ship in ipairs(matches) do
			matches_out = string.format(_("msgGM","%s\n%s"),matches_out,ship)
		end
	end
	local player_ship_names = {}
	for i,p in ipairs(active_player_ships) do
		table.insert(player_ship_names,p:getCallSign())
	end
	table.sort(player_ship_names)
	local player_ships_out = _("msgGM","Active player ships:")
	for i,name in ipairs(player_ship_names) do
		player_ships_out = string.format(_("msgGM","%s\n%s"),player_ships_out,name)
	end
	local ship_codes = {}
	for name,code in pairs(default_player_ship_control_code) do
		table.insert(ship_codes,string.format(_("msgGM","%s: %s"),name,code))
	end
	table.sort(ship_codes)
	local ship_code_out = _("msgGM","Default ship control codes:")
	for i,ship_code in ipairs(ship_codes) do
		ship_code_out = string.format(_("msgGM","%s\n%s"),ship_code_out,ship_code)
	end
	local out = ""
	if #matches == #active_player_ships then
		out = _("msgGM","All active player ships have matches in the list of defaults.\n")
		if #matches == #ship_codes then
			out = string.format(_("msgGM","%s\nAll defaults have matching player ships.\n"),out)
		end
	end
	addGMMessage(string.format(_("msgGM","%s%s\n%s\n%s"),out,player_ships_out,matches_out,ship_code_out))
end

