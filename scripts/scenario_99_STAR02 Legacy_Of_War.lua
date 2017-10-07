-- Name: STAR02 Legacy_Of_War
-- Description: Converted Artemis mission

function init()
    timers = {}
    fleet = {}
	temp_transmission_object = SpaceStation():setTemplate("Small Station"):setPosition(-1000000, -1000000)
    tmp_count = 2
    for tmp_counter=1,tmp_count do
        tmp_x, tmp_y = vectorFromAngle(-90.0 + (270.0 - -90.0) * (tmp_counter - 1) / tmp_count, 10000.0)
        tmp_x, tmp_y = tmp_x + -13440.0, tmp_y + -60520.0
        tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 7500.0))
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
        Nebula():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 18
    for tmp_counter=1,tmp_count do
        tmp_x, tmp_y = vectorFromAngle(-90.0 + (270.0 - -90.0) * (tmp_counter - 1) / tmp_count, 10000.0)
        tmp_x, tmp_y = tmp_x + -63360.0, tmp_y + -16280.0
        tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 10000.0))
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
        Asteroid():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 16
    for tmp_counter=1,tmp_count do
        tmp_x = -49415.0 + (585.0 - -49415.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -65420.0 + (-5420.0 - -65420.0) * (tmp_counter - 1) / tmp_count
        tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 10000.0))
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
        Asteroid():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 16
    for tmp_counter=1,tmp_count do
        tmp_x = -36791.0 + (33501.0 - -36791.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -90347.0 + (-21878.0 - -90347.0) * (tmp_counter - 1) / tmp_count
        tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 10000.0))
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
        Asteroid():setPosition(tmp_x, tmp_y)
    end
    Ardent = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Player Cruiser"):setCallSign("Ardent"):setPosition(-70000.0, -70000.0)
    --WARNING: Ignore <create> {'angle': '145', 'name': 'SW1', 'podnumber': '0', 'y': '0.0', 'x': '90826.0', 'z': '9653.0', 'type': 'whale'} 
    --WARNING: Ignore <create> {'angle': '320', 'name': 'SW3', 'podnumber': '0', 'y': '0.0', 'x': '14448.0', 'z': '67976.0', 'type': 'whale'} 
    --WARNING: Ignore <create> {'angle': '145', 'name': 'SW2', 'podnumber': '0', 'y': '0.0', 'x': '88589.0', 'z': '8535.0', 'type': 'whale'} 
    globalMessage("An Ardent Adventure:          Legacy Of War\nBy Andrew Lacey\nfox_glos@hotmail.com");
    timers["start_mission_timer_1"] = 10.000000
    Polaris = SpaceStation():setTemplate("Small Station"):setCallSign("Polaris"):setFaction("Human Navy"):setPosition(-71004.0, -69046.0)
    --WARNING: Ignore <set_ship_text> {'class': 'Support Ship', 'name': 'Polaris', 'desc': 'A long range resupply vessel.'} 
    timers["renametimer"] = 20.000000
    --WARNING: Unknown AI: Polaris: {'DIR_THROTTLE': {'type': 'DIR_THROTTLE', 'value2': '0.0', 'value1': '326.0', 'name': 'Polaris'}}
    addGMFunction("Kill all enemy ships", function()
        variable_KILL = 1.0
    end)
end

function update(delta)
    for key, value in pairs(timers) do
        timers[key] = timers[key] - delta
    end
    if variable_KILL == (1.0) then
        if AC04 ~= nil and AC04:isValid() then AC04:destroy() end
        if AC03 ~= nil and AC03:isValid() then AC03:destroy() end
        if AC02 ~= nil and AC02:isValid() then AC02:destroy() end
        if AC01 ~= nil and AC01:isValid() then AC01:destroy() end
        if AF01 ~= nil and AF01:isValid() then AF01:destroy() end
        if AF02 ~= nil and AF02:isValid() then AF02:destroy() end
        if AF03 ~= nil and AF03:isValid() then AF03:destroy() end
        if AF04 ~= nil and AF04:isValid() then AF04:destroy() end
        if AF05 ~= nil and AF05:isValid() then AF05:destroy() end
        variable_KILL = 2.0
    end
    if (timers["start_mission_timer_1"] ~= nil and timers["start_mission_timer_1"] < 0.0) and variable_instructions ~= (1.0) then
        variable_instructions = 1.0
        temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "This area is completely unexplored. You know the drill. Do an initial patrol of the area, document and follow up any abnormalities or discoveries of note and don\'t forget to smile and make new friends if the situation presents itself.")
    end
    if ifInsideSphere(Ardent, -50137.0, -9932.0, 40000.000000) and variable_makeprobe ~= (1.0) then
        variable_makeprobe = 1.0
        Probe = CpuShip():setTemplate("Tug"):setCallSign("Probe"):setFaction("Independent"):setPosition(-51172.0, -11412.0):orderRoaming()
        if Probe ~= nil and Probe:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'throttle', 'name': 'Probe', 'value': '0.0'} 
        end
        --WARNING: Ignore <set_ship_text> {'class': 'Space Probe', 'race': 'Jonopian', 'name': 'Probe', 'desc': 'A rather primitive automated space probe.'} 
        Ardent:addCustomMessage("scienceOfficer", "warning", "Object detected in grid E2.")
        --WARNING: Unknown AI: Probe: {'DIR_THROTTLE': {'type': 'DIR_THROTTLE', 'value2': '0.0', 'value1': '67.0', 'name': 'Probe'}} 
    end
    if (Ardent ~= nil and Probe ~= nil and Ardent:isValid() and Probe:isValid() and distance(Ardent, Probe) < 11000.000000) and variable_probemessage ~= (1.0) then
        variable_probemessage = 1.0
        temp_transmission_object:setCallSign("Probe"):sendCommsMessage(getPlayerShip(-1), "We cast this message into the cosmos ... Of the 200 billion stars in the galaxy, some, perhaps many, may have inhabited planets and space faring civilizations. If one such civilization intercepts this probe and can understand this recorded content, here is our message: We are trying to survive our time so we may live into yours. We hope someday, having solved the problems we face, to join a community of Galactic Civilizations. This recording represents our hope and our determination and our goodwill in a vast and awesome universe.")
        timers["stelcarcomms"] = 30.000000
    end
    if (timers["stelcarcomms"] ~= nil and timers["stelcarcomms"] < 0.0) and variable_makeanoms ~= (1.0) then
        temp_transmission_object:setCallSign("Internal Comms - Cartography"):sendCommsMessage(getPlayerShip(-1), "This is Dr Maxwell in Cartography. It didn’t take much of a recalibration of the main sensor array to find the ion trail left behind by the probe. Should show up as a faint, but detectable, trail. We should be able to follow it and discover the probes origin.")
        variable_makeanoms = 1.0
        Ion_Trail1 = SupplyDrop():setFaction("Human Navy"):setPosition(-50000.0, -20000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail2 = SupplyDrop():setFaction("Human Navy"):setPosition(-50000.0, -30000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail3 = SupplyDrop():setFaction("Human Navy"):setPosition(-45000.0, -40000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail4 = SupplyDrop():setFaction("Human Navy"):setPosition(-40000.0, -50000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail5 = SupplyDrop():setFaction("Human Navy"):setPosition(-30000.0, -60000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail6 = SupplyDrop():setFaction("Human Navy"):setPosition(-20000.0, -70000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail7 = SupplyDrop():setFaction("Human Navy"):setPosition(-10000.0, -80000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail8 = SupplyDrop():setFaction("Human Navy"):setPosition(-2000.0, -85000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail9 = SupplyDrop():setFaction("Human Navy"):setPosition(4000.0, -90000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail10 = SupplyDrop():setFaction("Human Navy"):setPosition(10000.0, -95000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ardent:addCustomMessage("scienceOfficer", "warning", "The ion trail is displayed as a string of anomalies.")
    end
    if variable_makeanoms == (1.0) and ifInsideBox(Ardent, 20000.0, -100000.0, 0.0, -90000.0) and variable_leaveareaone ~= (1.0) then
        variable_leaveareaone = 1.0
        if Ardent ~= nil and Ardent:isValid() then
            local x, y = Ardent:getPosition()
            Ardent:setPosition(x, -5000.0)
        end
        variable_makeareatwo = 1.0
    end
    if variable_makeanoms == (1.0) and ifInsideSphere(Ardent, 20000.0, -100000.0, 35000.000000) and variable_navwarning ~= (1.0) then
        variable_navwarning = 1.0
        Ardent:addCustomMessage("helmsOfficer", "warning", "WARNING - Continuing on this heading will scroll to the next sector.")
    end
    if variable_makeareatwo == (1.0) and (timers["start_mission_timer_1"] ~= nil and timers["start_mission_timer_1"] < 0.0) then
        for _, obj in ipairs(getObjectsInRadius(-30000.0, -50000.0, 100000.000000)) do
            if obj.typeName == "Asteroid" then obj:destroy() end
        end
        for _, obj in ipairs(getObjectsInRadius(-30000.0, -50000.0, 100000.000000)) do
            if obj.typeName == "Nebula" then obj:destroy() end
        end
        if Polaris ~= nil and Polaris:isValid() then Polaris:destroy() end
        if Fuel1 ~= nil and Fuel1:isValid() then Fuel1:destroy() end
        if Fuel2 ~= nil and Fuel2:isValid() then Fuel2:destroy() end
        if Fuel3 ~= nil and Fuel3:isValid() then Fuel3:destroy() end
        if Ion_Trail1 ~= nil and Ion_Trail1:isValid() then Ion_Trail1:destroy() end
        if Ion_Trail2 ~= nil and Ion_Trail2:isValid() then Ion_Trail2:destroy() end
        if Ion_Trail3 ~= nil and Ion_Trail3:isValid() then Ion_Trail3:destroy() end
        if Ion_Trail4 ~= nil and Ion_Trail4:isValid() then Ion_Trail4:destroy() end
        if Ion_Trail5 ~= nil and Ion_Trail5:isValid() then Ion_Trail5:destroy() end
        if Ion_Trail6 ~= nil and Ion_Trail6:isValid() then Ion_Trail6:destroy() end
        if Ion_Trail7 ~= nil and Ion_Trail7:isValid() then Ion_Trail7:destroy() end
        if Ion_Trail8 ~= nil and Ion_Trail8:isValid() then Ion_Trail8:destroy() end
        if Ion_Trail9 ~= nil and Ion_Trail9:isValid() then Ion_Trail9:destroy() end
        if Ion_Trail10 ~= nil and Ion_Trail10:isValid() then Ion_Trail10:destroy() end
        if SW1 ~= nil and SW1:isValid() then SW1:destroy() end
        if SW3 ~= nil and SW3:isValid() then SW3:destroy() end
        if SW2 ~= nil and SW2:isValid() then SW2:destroy() end
        if Probe ~= nil and Probe:isValid() then Probe:destroy() end
        tmp_count = 45
        for tmp_counter=1,tmp_count do
            tmp_x, tmp_y = vectorFromAngle(-40.0 + (120.0 - -40.0) * (tmp_counter - 1) / tmp_count, 40000.0)
            tmp_x, tmp_y = tmp_x + -29761.0, tmp_y + -50879.0
            tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 5000.0))
            tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
            Asteroid():setPosition(tmp_x, tmp_y)
        end
        tmp_count = 30
        for tmp_counter=1,tmp_count do
            tmp_x, tmp_y = vectorFromAngle(-90.0 + (270.0 - -90.0) * (tmp_counter - 1) / tmp_count, 30000.0)
            tmp_x, tmp_y = tmp_x + -36632.0, tmp_y + -56632.0
            tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 5000.0))
            tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
            Asteroid():setPosition(tmp_x, tmp_y)
        end
        tmp_count = 10
        for tmp_counter=1,tmp_count do
            tmp_x, tmp_y = vectorFromAngle(-90.0 + (270.0 - -90.0) * (tmp_counter - 1) / tmp_count, 10000.0)
            tmp_x, tmp_y = tmp_x + 7629.0, tmp_y + -89500.0
            tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 5000.0))
            tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
            Asteroid():setPosition(tmp_x, tmp_y)
        end
        Jonope_4 = Planet():setPosition(-36951.0, -98070.0):setPlanetAtmosphereColor(0.0, 1.0, 0):setPlanetSurfaceTexture('Gemenon.png'):setDistanceFromMovementPlane(1500.0)
        --WARNING: Ignore <create> {'colorRed': '0.0', 'angle': '0', 'name': 'Jonope 4', 'colorGreen': '1.0', 'y': '-1500.0', 'meshFileName': 'dat\\Missions\\MISS_STAR02 Legacy_Of_War\\msh\\Planet201.dxs', 'colorBlue': '0.0', 'x': '56951.0', 'z': '41930.0', 'type': 'genericMesh', 'textureFileName': 'dat\\Missions\\MISS_STAR02 Legacy_Of_War\\txt\\Gemenon.png'}
        if Jonope_4 ~= nil and Jonope_4:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'rollDelta', 'name': 'Jonope 4', 'value': '0.0'} 
        end
        if Jonope_4 ~= nil and Jonope_4:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'pushRadius', 'name': 'Jonope 4', 'value': '3000.0'} 
        end
        if Jonope_4 ~= nil and Jonope_4:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'angleDelta', 'name': 'Jonope 4', 'value': '0.004'} 
        end
        if Jonope_4 ~= nil and Jonope_4:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'pitchDelta', 'name': 'Jonope 4', 'value': '0.0'} 
        end
        if Jonope_4 ~= nil and Jonope_4:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'artScale', 'name': 'Jonope 4', 'value': '5.5'} 
        end
        Ion_Trail1 = SupplyDrop():setFaction("Human Navy"):setPosition(10000.0, -10000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail2 = SupplyDrop():setFaction("Human Navy"):setPosition(0.0, -20000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail3 = SupplyDrop():setFaction("Human Navy"):setPosition(5000.0, -15000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail4 = SupplyDrop():setFaction("Human Navy"):setPosition(-10000.0, -30000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail5 = SupplyDrop():setFaction("Human Navy"):setPosition(-5000.0, -25000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail6 = SupplyDrop():setFaction("Human Navy"):setPosition(-20000.0, -40000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail7 = SupplyDrop():setFaction("Human Navy"):setPosition(-15000.0, -35000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail8 = SupplyDrop():setFaction("Human Navy"):setPosition(-30000.0, -50000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail9 = SupplyDrop():setFaction("Human Navy"):setPosition(-25000.0, -45000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Ion_Trail10 = SupplyDrop():setFaction("Human Navy"):setPosition(-35000.0, -55000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        variable_makeareatwo = 2.0
        Fuel1 = SupplyDrop():setFaction("Human Navy"):setPosition(14748.0, -70586.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Fuel2 = SupplyDrop():setFaction("Human Navy"):setPosition(-67465.0, -61702.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        Fuel3 = SupplyDrop():setFaction("Human Navy"):setPosition(-47586.0, -11536.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
    end
    if (timers["missles"] ~= nil and timers["missles"] < 0.0) then
        if Planet_ ~= nil and Planet_:isValid() then Planet_:destroy() end
    end
    if (timers["planetdefences"] ~= nil and timers["planetdefences"] < 0.0) and variable_planetattack ~= (1.0) then
        Planet_ = CpuShip():setTemplate("Cruiser"):setCallSign("Planet "):setFaction("Kraylor"):setPosition(-36951.0, -58070.0):orderRoaming()
        if fleet[1] == nil then fleet[1] = {} end
        table.insert(fleet[1], Planet_)
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], Planet_)
        Planet_ = CpuShip():setTemplate("Cruiser"):setCallSign("Planet "):setFaction("Kraylor"):setPosition(-36951.0, -58070.0):orderRoaming()
        table.insert(fleet[1], Planet_)
        table.insert(fleet[0], Planet_)
        Planet_ = CpuShip():setTemplate("Cruiser"):setCallSign("Planet "):setFaction("Kraylor"):setPosition(-36951.0, -58070.0):orderRoaming()
        table.insert(fleet[1], Planet_)
        table.insert(fleet[0], Planet_)
        Planet_ = CpuShip():setTemplate("Cruiser"):setCallSign("Planet "):setFaction("Kraylor"):setPosition(-36951.0, -58070.0):orderRoaming()
        table.insert(fleet[1], Planet_)
        table.insert(fleet[0], Planet_)
        Planet_ = CpuShip():setTemplate("Cruiser"):setCallSign("Planet "):setFaction("Kraylor"):setPosition(-36951.0, -58070.0):orderRoaming()
        table.insert(fleet[1], Planet_)
        table.insert(fleet[0], Planet_)
        AF01 = CpuShip():setTemplate("Cruiser"):setCallSign("AF01"):setFaction("Kraylor"):setPosition(-36951.0, -58070.0):orderRoaming()
        table.insert(fleet[1], AF01)
        table.insert(fleet[0], AF01)
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'AF01', 'desc': 'An old but still functioning automated vessel.'} 
        AF02 = CpuShip():setTemplate("Cruiser"):setCallSign("AF02"):setFaction("Kraylor"):setPosition(-36951.0, -58070.0):orderRoaming()
        table.insert(fleet[1], AF02)
        table.insert(fleet[0], AF02)
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'AF02', 'desc': 'An old but still functioning automated vessel.'} 
        AF03 = CpuShip():setTemplate("Cruiser"):setCallSign("AF03"):setFaction("Kraylor"):setPosition(-36951.0, -58070.0):orderRoaming()
        table.insert(fleet[1], AF03)
        table.insert(fleet[0], AF03)
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'AF03', 'desc': 'An old but still functioning automated vessel.'} 
        AF04 = CpuShip():setTemplate("Cruiser"):setCallSign("AF04"):setFaction("Kraylor"):setPosition(-36951.0, -58070.0):orderRoaming()
        table.insert(fleet[1], AF04)
        table.insert(fleet[0], AF04)
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'AF04', 'desc': 'An old but still functioning automated vessel.'} 
        AF05 = CpuShip():setTemplate("Cruiser"):setCallSign("AF05"):setFaction("Kraylor"):setPosition(-36951.0, -58070.0):orderRoaming()
        table.insert(fleet[1], AF05)
        table.insert(fleet[0], AF05)
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'AF05', 'desc': 'An old but still functioning automated vessel.'} 
        AC01 = CpuShip():setTemplate("Cruiser"):setCallSign("AC01"):setFaction("Kraylor"):setPosition(-54048.0, -74208.0):orderRoaming()
        if fleet[7] == nil then fleet[7] = {} end
        table.insert(fleet[7], AC01)
        table.insert(fleet[0], AC01)
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Carrier', 'race': 'Jonopian', 'name': 'AC01', 'desc': 'An old but still functioning automated vessel.'} 
        AC02 = CpuShip():setTemplate("Cruiser"):setCallSign("AC02"):setFaction("Kraylor"):setPosition(-18736.0, -73889.0):orderRoaming()
        table.insert(fleet[7], AC02)
        table.insert(fleet[0], AC02)
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Carrier', 'race': 'Jonopian', 'name': 'AC02', 'desc': 'An old but still functioning automated vessel.'} 
        AC03 = CpuShip():setTemplate("Cruiser"):setCallSign("AC03"):setFaction("Kraylor"):setPosition(-18256.0, -38256.0):orderRoaming()
        table.insert(fleet[7], AC03)
        table.insert(fleet[0], AC03)
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Carrier', 'race': 'Jonopian', 'name': 'AC03', 'desc': 'An old but still functioning automated vessel.'} 
        AC04 = CpuShip():setTemplate("Cruiser"):setCallSign("AC04"):setFaction("Kraylor"):setPosition(-53889.0, -36818.0):orderRoaming()
        table.insert(fleet[7], AC04)
        table.insert(fleet[0], AC04)
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Carrier', 'race': 'Jonopian', 'name': 'AC04', 'desc': 'An old but still functioning automated vessel.'} 
        timers["missles"] = 1.000000
        variable_planetattack = 1.0
        --WARNING: Unknown AI: AC04: {'TARGET_THROTTLE': {'type': 'TARGET_THROTTLE', 'targetName': 'Ardent', 'name': 'AC04', 'value1': '1.0'}} 
        --WARNING: Unknown AI: Planet_: {'TARGET_THROTTLE': {'type': 'TARGET_THROTTLE', 'targetName': 'Ardent', 'name': 'Planet ', 'value1': '0.0'}} 
        --WARNING: Unknown AI: AC01: {'TARGET_THROTTLE': {'type': 'TARGET_THROTTLE', 'targetName': 'Ardent', 'name': 'AC01', 'value1': '1.0'}} 
        --WARNING: Unknown AI: AC02: {'TARGET_THROTTLE': {'type': 'TARGET_THROTTLE', 'targetName': 'Ardent', 'name': 'AC02', 'value1': '1.0'}} 
        --WARNING: Unknown AI: AC03: {'TARGET_THROTTLE': {'type': 'TARGET_THROTTLE', 'targetName': 'Ardent', 'name': 'AC03', 'value1': '1.0'}} 
    end
    if variable_planetattack == (1.0) and (timers["renametimer"] ~= nil and timers["renametimer"] < 0.0) then
        timers["renametimer"] = 20.000000
        if AC01 ~= nil and AC01:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'surrenderChance', 'name': 'AC01', 'value': '0.0'} 
        end
        if AC02 ~= nil and AC02:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'surrenderChance', 'name': 'AC02', 'value': '0.0'} 
        end
        if AC03 ~= nil and AC03:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'surrenderChance', 'name': 'AC03', 'value': '0.0'} 
        end
        if AC04 ~= nil and AC04:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'surrenderChance', 'name': 'AC04', 'value': '0.0'} 
        end
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'A99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'B99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'C99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'D99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'E99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'F99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'G99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'H99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'I99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'J99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'K99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'L99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'M99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'N99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'O99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'P99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Q99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'R99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'S99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'T99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'U99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'V99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'W99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'X99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Y99', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z01', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z02', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z03', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z04', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z05', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z06', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z07', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z08', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z09', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z10', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z11', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z12', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z13', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z14', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z15', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z16', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z17', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z18', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z19', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z20', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z21', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z22', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z23', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z24', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z25', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z26', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z27', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z28', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z29', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z30', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z31', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z32', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z33', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z34', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z35', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z36', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z37', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z38', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z39', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z40', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z41', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z42', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z43', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z44', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z45', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z46', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z47', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z48', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z49', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z50', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z51', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z52', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z53', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z54', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z55', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z56', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z57', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z58', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z59', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z60', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z61', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z62', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z63', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z64', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z65', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z66', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z67', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z68', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z69', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z70', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z71', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z72', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z73', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z74', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z75', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z76', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z77', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z78', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z79', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z80', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z81', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z82', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z83', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z84', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z85', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z86', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z87', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z88', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z89', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z90', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z91', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z92', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z93', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z94', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z95', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z96', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z97', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z98', 'desc': 'An old but still functioning automated vessel.'} 
        --WARNING: Ignore <set_ship_text> {'class': 'Automated Attack Craft', 'race': 'Jonopian', 'name': 'Z99', 'desc': 'An old but still functioning automated vessel.'} 
    end
    if (Ardent ~= nil and Ion_Trail1 ~= nil and Ardent:isValid() and Ion_Trail1:isValid() and distance(Ardent, Ion_Trail1) < 2500.000000) then
        if Ion_Trail1 ~= nil and Ion_Trail1:isValid() then Ion_Trail1:destroy() end
    end
    if (Ardent ~= nil and Ion_Trail2 ~= nil and Ardent:isValid() and Ion_Trail2:isValid() and distance(Ardent, Ion_Trail2) < 2500.000000) then
        if Ion_Trail2 ~= nil and Ion_Trail2:isValid() then Ion_Trail2:destroy() end
    end
    if (Ardent ~= nil and Ion_Trail3 ~= nil and Ardent:isValid() and Ion_Trail3:isValid() and distance(Ardent, Ion_Trail3) < 2500.000000) then
        if Ion_Trail3 ~= nil and Ion_Trail3:isValid() then Ion_Trail3:destroy() end
    end
    if (Ardent ~= nil and Ion_Trail4 ~= nil and Ardent:isValid() and Ion_Trail4:isValid() and distance(Ardent, Ion_Trail4) < 2500.000000) then
        if Ion_Trail4 ~= nil and Ion_Trail4:isValid() then Ion_Trail4:destroy() end
    end
    if (Ardent ~= nil and Ion_Trail5 ~= nil and Ardent:isValid() and Ion_Trail5:isValid() and distance(Ardent, Ion_Trail5) < 2500.000000) then
        if Ion_Trail5 ~= nil and Ion_Trail5:isValid() then Ion_Trail5:destroy() end
    end
    if (Ardent ~= nil and Ion_Trail6 ~= nil and Ardent:isValid() and Ion_Trail6:isValid() and distance(Ardent, Ion_Trail6) < 2500.000000) then
        if Ion_Trail6 ~= nil and Ion_Trail6:isValid() then Ion_Trail6:destroy() end
    end
    if (Ardent ~= nil and Ion_Trail7 ~= nil and Ardent:isValid() and Ion_Trail7:isValid() and distance(Ardent, Ion_Trail7) < 2500.000000) then
        if Ion_Trail7 ~= nil and Ion_Trail7:isValid() then Ion_Trail7:destroy() end
    end
    if (Ardent ~= nil and Ion_Trail8 ~= nil and Ardent:isValid() and Ion_Trail8:isValid() and distance(Ardent, Ion_Trail8) < 2500.000000) then
        if Ion_Trail8 ~= nil and Ion_Trail8:isValid() then Ion_Trail8:destroy() end
    end
    if (Ardent ~= nil and Ion_Trail9 ~= nil and Ardent:isValid() and Ion_Trail9:isValid() and distance(Ardent, Ion_Trail9) < 2500.000000) then
        if Ion_Trail9 ~= nil and Ion_Trail9:isValid() then Ion_Trail9:destroy() end
    end
    if (Ardent ~= nil and Ion_Trail10 ~= nil and Ardent:isValid() and Ion_Trail10:isValid() and distance(Ardent, Ion_Trail10) < 2500.000000) then
        if Ion_Trail10 ~= nil and Ion_Trail10:isValid() then Ion_Trail10:destroy() end
    end
    if (Jonope_4 ~= nil and Ardent ~= nil and Jonope_4:isValid() and Ardent:isValid() and distance(Jonope_4, Ardent) < 10000.000000) and variable_Escan1 ~= (1.0) then
        Ardent:addCustomMessage("scienceOfficer", "warning", "Scanning the planet.")
        timers["scan2"] = 10.000000
        variable_Escan1 = 1.0
    end
    if (timers["scan2"] ~= nil and timers["scan2"] < 0.0) and variable_Escan2 ~= (1.0) then
        Ardent:addCustomMessage("scienceOfficer", "warning", "High levels of radiation in the atmosphere.")
        timers["scan3"] = 10.000000
        variable_Escan2 = 1.0
    end
    if (timers["scan3"] ~= nil and timers["scan3"] < 0.0) and variable_Escan3 ~= (1.0) then
        Ardent:addCustomMessage("scienceOfficer", "warning", "Approximately 250,000 city sized residential areas. All destroyed.")
        timers["scan4"] = 10.000000
        variable_Escan3 = 1.0
    end
    if (timers["scan4"] ~= nil and timers["scan4"] < 0.0) and variable_Escan4 ~= (1.0) then
        Ardent:addCustomMessage("scienceOfficer", "warning", "Preliminary scans seem to indicate nuclear war as the most likely cause.")
        variable_Escan4 = 1.0
        temp_transmission_object:setCallSign("Jonope 4"):sendCommsMessage(getPlayerShip(-1), "Identify, friend or foe?")
        Ardent:addCustomButton("relayOfficer", "friend_button", "Friend", function()
            variable_friend = 1.0
            Ardent:removeCustom("friend_button")
            Ardent:removeCustom("foe_button")
            Ardent:removeCustom("nothing_button")
        end)
        Ardent:addCustomButton("relayOfficer", "foe_button", "Foe", function()
            variable_foe = 1.0
            Ardent:removeCustom("friend_button")
            Ardent:removeCustom("foe_button")
            Ardent:removeCustom("nothing_button")
        end)
        Ardent:addCustomButton("relayOfficer", "nothing_button", "(Don't repsond)", function()
            variable_nothing = 1.0
            Ardent:removeCustom("friend_button")
            Ardent:removeCustom("foe_button")
            Ardent:removeCustom("nothing_button")
        end)
        timers["LAG"] = 12.000000
    end
    if (timers["LAG"] ~= nil and timers["LAG"] < 0.0) and 0 and variable_Escan4 == (1.0) and variable_comms ~= (1.0) then

        variable_comms = 1.0
        Ardent:addCustomMessage("scienceOfficer", "warning", "Some of the planets weapons systems are still functioning and are powering up.")
        if variable_friend ~= nil and variable_friend == 1 then
            temp_transmission_object:setCallSign("Jonope 4"):sendCommsMessage(getPlayerShip(-1), "Transmit friendly authorization code. You have five seconds to comply.")
            timers["planetdefences"] = 5.000000
        end
        if variable_foe ~= nil and variable_foe == 1 then
            temp_transmission_object:setCallSign("Jonope 4"):sendCommsMessage(getPlayerShip(-1), "All hostiles will be eliminated.")
            Ardent:addCustomMessage("scienceOfficer", "warning", "Some of the planets weapons systems are still functioning and are powering up.")
            timers["planetdefences"] = 1.000000
        end
        if variable_nothing ~= nil and variable_nothing == 1 then
            temp_transmission_object:setCallSign("Jonope 4"):sendCommsMessage(getPlayerShip(-1), "All hostiles will be eliminated.")
            Ardent:addCustomMessage("scienceOfficer", "warning", "Some of the planets weapons systems are still functioning and are powering up.")
            timers["planetdefences"] = 3.000000
        end
        if variable_friend == nil and variable_foe == nil and variable_nothing == nil then
            timers["planetdefences"] = 3.000000
            Ardent:removeCustom("friend_button")
            Ardent:removeCustom("foe_button")
            Ardent:removeCustom("nothing_button")
        end
    end
    if variable_planetattack == (1.0) and variable_win ~= (1.0) and countFleet(7) == 0.000000 then
        temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "If only we had found them sooner. A whole world of people turned into radioactive dust. I would say it\'s a tragedy but the word hardly seems big enough to account for the billions that must have perished. We\'ll dispatch an archaeological team to follow up. Perhaps we can learn more about these Jonopians so they can at least be remembered as the friends they might have been. Good work Ardent.")
        timers["endgame"] = 15.000000
        variable_win = 1.0
        globalMessage("Mission Completed\nThank you for playing.");
    end
    if (timers["endgame"] ~= nil and timers["endgame"] < 0.0) then
        victory("Human Navy")
    end
end

--[[
	Utility functions
--]]
function vectorFromAngle(angle, length)
    return math.cos(angle / 180 * math.pi) * length, math.sin(angle / 180 * math.pi) * length
end

function ifOutsideBox(obj, x1, y1, x2, y2)
	return not ifInsideBox(obj, x1, y1, x2, y2)
end

function ifInsideBox(obj, x1, y1, x2, y2)
	if obj == nil or not obj:isValid() then
		return false
	end
	x, y = obj:getPosition()
	if ((x >= x1 and x <= x2) or (x >= x2 and x <= x1)) and ((y >= y1 and y <= y2) or (y >= y2 and y <= y1)) then
		return true
	end
	return false
end

function ifInsideSphere(obj, x1, y1, r)
	if obj == nil or not obj:isValid() then
		return false
	end
	x, y = obj:getPosition()
	xd, yd = (x1 - x), (y1 - y)
	if math.sqrt(xd * xd + yd * yd) < r then
		return true
	end
	return false
end

function ifOutsideSphere(obj, x1, y1, r)
	if obj == nil or not obj:isValid() then
		return false
	end
	x, y = obj:getPosition()
	xd, yd = (x1 - x), (y1 - y)
	if math.sqrt(xd * xd + yd * yd) < r then
		return false
	end
	return true
end

function ifdocked(obj)
	-- TODO: Only checks the first player ship.
	return getPlayerShip(-1):isDocked(obj)
end

function countFleet(fleetnr)
	count = 0
	if fleet[fleetnr] ~= nil then
		for key, value in pairs(fleet[fleetnr]) do
			if value:isValid() then
				count = count + 1
			end
		end
	end
	return count
end

function distance(obj1, obj2)
	x1, y1 = obj1:getPosition()
	x2, y2 = obj2:getPosition()
	xd, yd = (x1 - x2), (y1 - y2)
	return math.sqrt(xd * xd + yd * yd)
end
