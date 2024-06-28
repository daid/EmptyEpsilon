-- Ship spawning and docking - Developed by Ville M. and Ria B. for Odysseus 2024


--Buttons
function setFighterSyncButtons()
	--	addGMFunction(_("buttonGM", "Sync fighter status"), function() sync_buttons() end)
		addGMFunction(_("buttonGM", "Show fighter fix"), function() showFighterFix() end)
		addGMFunction(_("buttonGM", "Break launched fighters"), function() breakLaunchedFighters() end)
	end
	
	-- Ship Enabler
	function allow_essody18()
		odysseus:addCustomButton("Relay", "launch_pad_1", "Launch ESSODY-F18", launch_essody18)
		  odysseus:setLandingPadDocked(1)
		removeGMFunction("Fix ESSODY-F18")
		status_essody18 = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
	end
	
	function allow_essody23()
		odysseus:addCustomButton("Relay", "launch_pad_2", "Launch ESSODY-F23", launch_essody23)
		  odysseus:setLandingPadDocked(2)
		removeGMFunction("Fix ESSODY-F23")
		status_essody23 = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
	end
	function allow_essody36()
		odysseus:addCustomButton("Relay", "launch_pad_3", "Launch ESSODY-F36", launch_essody36)
		  odysseus:setLandingPadDocked(3)
		removeGMFunction("Fix ESSODY-F36")
		status_essody36 = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
	end
	function allow_starcaller()
		odysseus:addCustomButton("Relay", "launch_pad_4", "Launch STARCALLER", launch_starcaller)
		  odysseus:setLandingPadDocked(4)
		removeGMFunction("Fix Starcaller")
		status_starcaller = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
	end
	
	-- Ship Launcher
	function launch_essody18()
		odysseus:removeCustom("launch_pad_1")
		spawn_essody18()
	end
	function launch_essody23()
		odysseus:removeCustom("launch_pad_2")
		spawn_essody23()
	end
	function launch_essody36()
		odysseus:removeCustom("launch_pad_3")
		spawn_essody36()
	end
	function launch_starcaller()
		odysseus:removeCustom("launch_pad_4")
		spawn_starcaller()
	end
	
	-- Ship spawner
	function spawn_essody18()
		x, y = odysseus:getPosition()
		essody18 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Comet Starfighter"):setCanSelfDestruct(false):setPosition(x + 200, y + 200):setCallSign("ESSODY-F18"):setAutoCoolant(true):onDestruction(
		function(this, instigator) 
			odysseus:setLandingPadDestroyed(1)
			allow_autodock18 = false
			status_essody18 = 0 	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
			removeGMFunction("Force dock ESSODY-F18")
			addGMFunction("Fix ESSODY-F18", allow_essody18)
		end)
		allow_autodock18 = true
		odysseus:addCustomButton("Relay", "dock_to_odysseus_auto18", "Autodock ESSODY-F18", dock_essody18_auto)
		essody18:addCustomButton("Helms", "dock_to_odysseus", "Dock to Odysseys", dock_essody18)
		addGMFunction("Force dock ESSODY-F18", dock_essody18_force)
		  odysseus:setLandingPadLaunched(1)
		essody18_launched = 1
		status_essody18 = 2	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
	end
	
	function spawn_essody23()
		x, y = odysseus:getPosition()
		essody23 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Comet Starfighter"):setCanSelfDestruct(false):setPosition(x + 250, y + 250):setCallSign("ESSODY-F23"):setAutoCoolant(true):onDestruction(
		function(this, instigator) 
			  odysseus:setLandingPadDestroyed(2)
			  allow_autodock23 = false
			  status_essody23 = 0	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
			removeGMFunction("Force dock ESSODY-F23")
			  addGMFunction("Fix ESSODY-F23", allow_essody23)
		end)
		allow_autodock23 = true
		odysseus:addCustomButton("Relay", "dock_to_odysseus_auto23", "Autodock ESSODY-F23", dock_essody23_auto)
		essody23:addCustomButton("Helms", "dock_to_odysseus", "Dock to Odysseys", dock_essody23)
		addGMFunction("Force dock ESSODY-F23", dock_essody23_force)
		odysseus:setLandingPadLaunched(2)
		essody23_launched = 1
		status_essody23 = 2	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
	end
	function spawn_essody36()
		x, y = odysseus:getPosition()
		essody36 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Comet Starfighter"):setCanSelfDestruct(false):setPosition(x + 300, y + 300):setCallSign("ESSODY-F36"):setAutoCoolant(true):onDestruction(
		function(this, instigator) 
			  odysseus:setLandingPadDestroyed(3)
			  allow_autodock36 = false
			  status_essody36 = 0	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
			removeGMFunction("Force dock ESSODY-F36")
			  addGMFunction("Fix ESSODY-F36", allow_essody36)
		end)
		allow_autodock36 = true
		odysseus:addCustomButton("Relay", "dock_to_odysseus_auto36", "Autodock ESSODY-F36", dock_essody36_auto)
		essody36:addCustomButton("Helms", "dock_to_odysseus", "Dock to Odysseys", dock_essody36)
		addGMFunction("Force dock ESSODY-F36", dock_essody36_force)
		  odysseus:setLandingPadLaunched(3)
		essody36_launched = 1
		status_essody36 = 2	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
	end
	function spawn_starcaller()
		x, y = odysseus:getPosition()
		-- Starcaller has different faction on purpose, EOC_starfleet is neutral with machines.
		starcaller = PlayerSpaceship():setFaction("EOC_Starfleet"):setTemplate("Comet Class Scout"):setCanSelfDestruct(false):setPosition(x - 400, y + 400):setCallSign("ESS Starcaller"):setAutoCoolant(true):onDestruction(
		function(this, instigator)
			removeGMFunction("Force dock Starcaller")
			  odysseus:setLandingPadDestroyed(4)
			  allow_autodocksc = false
			  status_starcaller = 0	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
			  addGMFunction("Fix Starcaller", allow_starcaller)
		end)
		allow_autodocksc = true
		odysseus:addCustomButton("Relay", "dock_to_odysseus_autosc", "Autodock Starcaller", dock_starcaller_auto)
		starcaller:addCustomButton("Helms", "dock_to_odysseus", "Dock to Odysseys", dock_starcaller)
		addGMFunction("Force dock Starcaller", dock_starcaller_force)
		  odysseus:setLandingPadLaunched(4)
		starcaller_launched = 1
		status_starcaller = 2	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
	end
	
	-- Ship docker
	dockingdist = 800   --Set docking distance to 0.8U
	
	function dock_essody18()
		local curDistance = distance(essody18, odysseus)
		if curDistance <= dockingdist then
			essody18_launched = 0
			odysseus:setLandingPadDocked(1)
			odysseus:addCustomButton("Relay", "launch_pad_1", "Launch ESSODY-F18", launch_essody18)
			odysseus:removeCustom("dock_to_odysseus_auto18")
			removeGMFunction("Force dock ESSODY-F18")
			essody18:destroy()
			status_essody18 = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
			allow_autodock18 = false
		else
			essody18:addCustomMessage("Helms", "Distance too far. Docking cancelled.", "Distance too far. Docking cancelled.")
		end
	end
	
	function dock_essody23()
		local curDistance = distance(essody23, odysseus)
		if curDistance <= dockingdist then
			essody23_launched = 0
			odysseus:setLandingPadDocked(2)
			odysseus:addCustomButton("Relay", "launch_pad_2", "Launch ESSODY-F23", launch_essody23)
			removeGMFunction("Force dock ESSODY-F23")
			odysseus:removeCustom("dock_to_odysseus_auto23")
			essody23:destroy()
			status_essody23 = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
			allow_autodock23 = false
		else
			essody23:addCustomMessage("Helms", "Distance too far. Docking cancelled.", "Distance too far. Docking cancelled.")
		end
	end
	
	function dock_essody36()
		local curDistance = distance(essody36, odysseus)
		if curDistance <= dockingdist then
			essody36_launched = 0
			   odysseus:setLandingPadDocked(3)
			odysseus:addCustomButton("Relay", "launch_pad_3", "Launch ESSODY-F36", launch_essody36)
			removeGMFunction("Force dock ESSODY-F36")
			odysseus:removeCustom("dock_to_odysseus_auto36")
			essody36:destroy()
			status_essody36 = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
			allow_autodock36 = false
		else
			essody36:addCustomMessage("Helms", "Distance too far. Docking cancelled.", "Distance too far. Docking cancelled.")
		end
	end
	
	function dock_starcaller()
		local curDistance = distance(starcaller, odysseus)
		if curDistance <= dockingdist then
			starcaller_launched = 0
			   odysseus:setLandingPadDocked(4)
			odysseus:addCustomButton("Relay", "launch_pad_4", "Launch STARCALLER", launch_starcaller)
			odysseus:removeCustom("dock_to_odysseus_autosc")
			removeGMFunction("Force dock Starcaller")
			starcaller:destroy()
			status_starcaller = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
			allow_autodocksc = false
		else
			starcaller:addCustomMessage("Helms", "Distance too far. Docking cancelled.", "Distance too far. Docking cancelled.")
		end
	end
	
	function dock_essody18_auto()
		local curDistance = distance(essody18, odysseus)
		if curDistance <= dockingdist then
			essody18_launched = 0
			   odysseus:setLandingPadDocked(1)
			odysseus:addCustomButton("Relay", "launch_pad_1", "Launch ESSODY-F18", launch_essody18)
			odysseus:removeCustom("dock_to_odysseus_auto18")
			essody18:destroy()
			removeGMFunction("Force dock ESSODY-F18")
			status_essody18 = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
		else
			odysseus:addCustomMessage("Relay", "Distance too far. Docking cancelled.", "Distance too far. Docking cancelled.")
		end
	end
	
	function dock_essody23_auto()
		local curDistance = distance(essody23, odysseus)
		if curDistance <= dockingdist then
			essody23_launched = 0
			   odysseus:setLandingPadDocked(2)
			odysseus:addCustomButton("Relay", "launch_pad_2", "Launch ESSODY-F23", launch_essody23)
			odysseus:removeCustom("dock_to_odysseus_auto23")
			essody23:destroy()
			removeGMFunction("Force dock ESSODY-F23")
			status_essody23 = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
		else
			odysseus:addCustomMessage("Relay", "Distance too far. Docking cancelled.", "Distance too far. Docking cancelled.")
		end
	end
	
	
	function dock_essody36_auto()
		local curDistance = distance(essody36, odysseus)
		if curDistance <= dockingdist then
			essody36_launched = 0
			   odysseus:setLandingPadDocked(3)
			odysseus:addCustomButton("Relay", "launch_pad_3", "Launch ESSODY-F36", launch_essody36)
			odysseus:removeCustom("dock_to_odysseus_auto36")
			essody36:destroy()
			removeGMFunction("Force dock ESSODY-F36")
			status_essody36 = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
		else
			odysseus:addCustomMessage("Relay", "Distance too far. Docking cancelled.", "Distance too far. Docking cancelled.")
		end
	end
	
	
	function dock_starcaller_auto()
		local curDistance = distance(starcaller, odysseus)
		if curDistance <= dockingdist then
			starcaller_launched = 0
			   odysseus:setLandingPadDocked(4)
			odysseus:addCustomButton("Relay", "launch_pad_4", "Launch STARCALLER", launch_starcaller)
			odysseus:removeCustom("dock_to_odysseus_autosc")
			removeGMFunction("Force dock Starcaller")
			starcaller:destroy()
			status_starcaller = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
		else
			odysseus:addCustomMessage("Relay", "Distance too far. Docking cancelled.", "Distance too far. Docking cancelled.")
		end
	end
	
	function remove_autodock18()
		allow_autodock18 = false
		odysseus:removeCustom("dock_to_odysseus_auto18")
	end
	
	function remove_autodock23()
		allow_autodock23 = false
		odysseus:removeCustom("dock_to_odysseus_auto23")
	end
	
	function remove_autodock36()
		allow_autodock36 = false
		odysseus:removeCustom("dock_to_odysseus_auto36")
	end
	
	function remove_autodocksc()
		allow_autodocksc = false
		odysseus:removeCustom("dock_to_odysseus_autosc")
	end
	
	function dock_essody18_force()
		essody18_launched = 0
		odysseus:setLandingPadDocked(1)
		odysseus:addCustomButton("Relay", "launch_pad_1", "Launch ESSODY-F18", launch_essody18)
		removeGMFunction("Force dock ESSODY-F18")
		odysseus:removeCustom("dock_to_odysseus_auto18")
		essody18:destroy()
		status_essody18 = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
	end
	
	function dock_essody23_force()
		essody23_launched = 0
		odysseus:setLandingPadDocked(2)
		odysseus:addCustomButton("Relay", "launch_pad_2", "Launch ESSODY-F23", launch_essody23)
		removeGMFunction("Force dock ESSODY-F23")
		odysseus:removeCustom("dock_to_odysseus_auto23")
		essody23:destroy()
		status_essody23 = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
	end
	
	function dock_essody36_force()
		essody36_launched = 0
		odysseus:setLandingPadDocked(3)
		odysseus:addCustomButton("Relay", "launch_pad_3", "Launch ESSODY-F36", launch_essody36)
		removeGMFunction("Force dock ESSODY-F36")
		odysseus:removeCustom("dock_to_odysseus_auto36")
		essody36:destroy()
		status_essody36 = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
	end
	
	function dock_starcaller_force()
		starcaller_launched = 0
		odysseus:setLandingPadDocked(4)
		odysseus:addCustomButton("Relay", "launch_pad_4", "Launch STARCALLER", launch_starcaller)
	
		removeGMFunction("Force dock Starcaller")
		odysseus:removeCustom("dock_to_odysseus_autosc")
		starcaller:destroy()
		status_starcaller = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
	end
	
	-- Button synchronizer
	function sync_buttons()
		removeGMFunction("Force dock ESSODY-F18")
		removeGMFunction("Force dock ESSODY-F23")
		removeGMFunction("Force dock ESSODY-F36")
		removeGMFunction("Force dock Starcaller")
		odysseus:removeCustom("launch_pad_1")
		odysseus:removeCustom("launch_pad_2")
		odysseus:removeCustom("launch_pad_3")
		odysseus:removeCustom("launch_pad_4")
		odysseus:removeCustom("dock_to_odysseus_auto18")
		odysseus:removeCustom("dock_to_odysseus_auto23")
		odysseus:removeCustom("dock_to_odysseus_auto36")
		odysseus:removeCustom("dock_to_odysseus_autosc")
	
		if odysseus:isLandingPadDestroyed(1) then
			status_essody18 = 0	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
		end
		if odysseus:isLandingPadDestroyed(2) then
			status_essody23 = 0	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
		end
		if odysseus:isLandingPadDestroyed(3) then
			status_essody36 = 0	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
		end
		if odysseus:isLandingPadDestroyed(4) then
			status_starcaller = 0	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
		end
	
		if odysseus:isLandingPadDocked(1) then
			odysseus:addCustomButton("Relay", "launch_pad_1", "Launch ESSODY-F18", launch_essody18)
			status_essody18 = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
		end
		if odysseus:isLandingPadDocked(2) then
			odysseus:addCustomButton("Relay", "launch_pad_2", "Launch ESSODY-F23", launch_essody23)
			status_essody23 = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
		end
		if odysseus:isLandingPadDocked(3) then
			odysseus:addCustomButton("Relay", "launch_pad_3", "Launch ESSODY-F36", launch_essody36)
			status_essody36 = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
		end
		if odysseus:isLandingPadDocked(4) then
			odysseus:addCustomButton("Relay", "launch_pad_4", "Launch STARCALLER", launch_starcaller)
			status_starcaller = 1	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
		end
	end
	
	function breakLaunchedFighters()
		if odysseus:isLandingPadLaunched(1) then
			odysseus:setLandingPadDestroyed(1)
			allow_autodock18 = false
			status_essody18 = 0 	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
			removeGMFunction("Force dock ESSODY-F18")
		end
		if odysseus:isLandingPadLaunched(2) then
			odysseus:setLandingPadDestroyed(2)
			allow_autodock23 = false
			status_essody23 = 0 	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
			removeGMFunction("Force dock ESSODY-F23")
		end
		if odysseus:isLandingPadLaunched(3) then
			odysseus:setLandingPadDestroyed(3)
			allow_autodock36 = false
			status_essody36 = 0 	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
			removeGMFunction("Force dock ESSODY-F36")
		end
		if odysseus:isLandingPadLaunched(4) then
			odysseus:setLandingPadDestroyed(4)
			allow_autodocksc = false
			status_starcaller = 0 	--0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched'
			removeGMFunction("Force dock Starcaller")
		end
		removeGMFunction("Break launched fighters")
	end
	
	function showFighterFix()
		addGMFunction("Hide fighter fix", hideFighterFix)
		if odysseus:isLandingPadDestroyed(1) then
			addGMFunction("Fix ESSODY-F18", allow_essody18)
		end
		if odysseus:isLandingPadDestroyed(2) then
			addGMFunction("Fix ESSODY-F23", allow_essody23)
		end
		if odysseus:isLandingPadDestroyed(3) then
			addGMFunction("Fix ESSODY-F36", allow_essody36)
		end
		if odysseus:isLandingPadDestroyed(4) then
			addGMFunction("Fix Starcaller", allow_starcaller)
		end
	end
	
	function hideFighterFix()
		removeGMFunction("Hide fighter fix")
		removeGMFunction("Fix ESSODY-F18")
		removeGMFunction("Fix ESSODY-F23")
		removeGMFunction("Fix ESSODY-F36")
		removeGMFunction("Fix Starcaller")
	end
	