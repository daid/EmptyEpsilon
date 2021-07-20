-- Name: STAR01 Children_Of_Carnage
-- Description: Converted Artemis mission

function init()
    timers = {}
    fleet = {}
	temp_transmission_object = SpaceStation():setTemplate("Small Station"):setPosition(-1000000, -1000000)
    tmp_count = 35
    for tmp_counter=1,tmp_count do
        tmp_x, tmp_y = vectorFromAngle(90.0 + (-10.0 - 90.0) * (tmp_counter - 1) / tmp_count, 45000.0)
        tmp_x, tmp_y = tmp_x + -35000.0, tmp_y + -90000.0
        tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 8000.0))
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
        Asteroid():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 35
    for tmp_counter=1,tmp_count do
        tmp_x, tmp_y = vectorFromAngle(260.0 + (170.0 - 260.0) * (tmp_counter - 1) / tmp_count, 45000.0)
        tmp_x, tmp_y = tmp_x + -25000.0, tmp_y + 0.0
        tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 8000.0))
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
        Asteroid():setPosition(tmp_x, tmp_y)
    end
    Ardent = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Player Cruiser"):setCallSign("Ardent"):setPosition(11000.0, -9000.0)
    globalMessage("An Ardent Adventure:          Children Of Carnage\nBy Andrew Lacey\nfox_glos@hotmail.com");
    timers["start_mission_timer_1"] = 10.000000
    Polaris = SpaceStation():setTemplate("Small Station"):setCallSign("Polaris"):setFaction("Human Navy"):setPosition(10000.0, -10000.0)
    --WARNING: Ignore <set_ship_text> {'class': 'Support Ship', 'name': 'Polaris', 'desc': 'A long range resupply vessel.'} 
    variable_areaone = 1.0
    Cryo_Ship = CpuShip():setTemplate("Tug"):setCallSign("Cryo Ship"):setFaction("Independent"):setPosition(-8000.0, -69000.0):orderRoaming()
    --WARNING: Ignore <set_ship_text> {'class': 'Cryogenic Transport Ship', 'race': 'Unknown', 'name': 'Cryo Ship', 'desc': 'There are four faint life readings aboard this vessel.'} 
    if Cryo_Ship ~= nil and Cryo_Ship:isValid() then
    --WARNING: Ignore <set_object_property> {'property': 'throttle', 'name': 'Cryo Ship', 'value': '0.0'} 
    end
    if Cryo_Ship ~= nil and Cryo_Ship:isValid() then
    --WARNING: Ignore <set_object_property> {'property': 'topSpeed', 'name': 'Cryo Ship', 'value': '0.0'} 
    end
    if Cryo_Ship ~= nil and Cryo_Ship:isValid() then
    Cryo_Ship:setSystemHealth("FrontShieldMax", 0.000000)
    end
    if Cryo_Ship ~= nil and Cryo_Ship:isValid() then
    Cryo_Ship:setSystemHealth("RearShieldMax", 0.000000)
    end
    variable_ON = 1.0
    timers["ALWAYSON"] = 1.000000
    --WARNING: Unknown AI: Polaris: {'DIR_THROTTLE': {'type': 'DIR_THROTTLE', 'value2': '0.0', 'value1': '270.0', 'name': 'Polaris'}} 
    Cryo_Ship:orderIdle()
    addGMFunction("Kill all enemy ships", function()
    variable_KILL = 1.0
    end)
    
end

function update(delta)
    for key, value in pairs(timers) do
        timers[key] = timers[key] - delta
    end
    if variable_KILL == (1.0) then
        if KR01 ~= nil and KR01:isValid() then KR01:destroy() end
        if KR02 ~= nil and KR02:isValid() then KR02:destroy() end
        if KR03 ~= nil and KR03:isValid() then KR03:destroy() end
        if KR04 ~= nil and KR04:isValid() then KR04:destroy() end
        if KR05 ~= nil and KR05:isValid() then KR05:destroy() end
        if KR06 ~= nil and KR06:isValid() then KR06:destroy() end
        if KR07 ~= nil and KR07:isValid() then KR07:destroy() end
        if KR08 ~= nil and KR08:isValid() then KR08:destroy() end
        if KR09 ~= nil and KR09:isValid() then KR09:destroy() end
        if Rabin_ ~= nil and Rabin_:isValid() then Rabin_:destroy() end
        if Akira_ ~= nil and Akira_:isValid() then Akira_:destroy() end
        if Devore_ ~= nil and Devore_:isValid() then Devore_:destroy() end
        if Summit_ ~= nil and Summit_:isValid() then Summit_:destroy() end
        if Horatio_ ~= nil and Horatio_:isValid() then Horatio_:destroy() end
        if Dakota_ ~= nil and Dakota_:isValid() then Dakota_:destroy() end
        if Exeter_ ~= nil and Exeter_:isValid() then Exeter_:destroy() end
        if TG02 ~= nil and TG02:isValid() then TG02:destroy() end
        if TG01 ~= nil and TG01:isValid() then TG01:destroy() end
        variable_KILL = 2.0
    end

        if variable_ON == (1.0) and (timers["ALWAYSON"] ~= nil and timers["ALWAYSON"] < 0.0) then
        if Cryo_Ship ~= nil and Cryo_Ship:isValid() then
        Cryo_Ship:setSystemHealth("RearShieldMax", 0.000000)
        end
        if Cryo_Ship ~= nil and Cryo_Ship:isValid() then
        Cryo_Ship:setSystemHealth("FrontShieldMax", 0.000000)
        end
        if Cryo_Ship ~= nil and Cryo_Ship:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'topSpeed', 'name': 'Cryo Ship', 'value': '0.0'} 
        end
        if Cryo_Ship ~= nil and Cryo_Ship:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'throttle', 'name': 'Cryo Ship', 'value': '0.0'} 
        end
        if Exeter_ ~= nil and Exeter_:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'surrenderChance', 'name': 'Exeter ', 'value': '0.0'} 
        end
        if Dakota_ ~= nil and Dakota_:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'surrenderChance', 'name': 'Dakota ', 'value': '0.0'} 
        end
        if Horatio_ ~= nil and Horatio_:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'surrenderChance', 'name': 'Horatio ', 'value': '0.0'} 
        end
        if Summit_ ~= nil and Summit_:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'surrenderChance', 'name': 'Summit ', 'value': '0.0'} 
        end
        if Devore_ ~= nil and Devore_:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'surrenderChance', 'name': 'Devore ', 'value': '0.0'} 
        end
        if Akira_ ~= nil and Akira_:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'surrenderChance', 'name': 'Akira ', 'value': '0.0'} 
        end
        if Rabin_ ~= nil and Rabin_:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'surrenderChance', 'name': 'Rabin ', 'value': '0.0'} 
        end
        timers["ALWAYSON"] = 15.000000
        --WARNING: Unknown AI: Cryo_Ship: {'DIR_THROTTLE': {'type': 'DIR_THROTTLE', 'value2': '0.0', 'value1': '115.0', 'name': 'Cryo Ship'}, 'CLEAR': True} 
    end
    if (timers["start_mission_timer_1"] ~= nil and timers["start_mission_timer_1"] < 0.0) and variable_instructions ~= (1.0) then
        variable_instructions = 1.0
        temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "This Sector needs to be scouted and surveyed. Conduct an initial patrol and investigate any abnormalities or discoveries of interest. Be on your guard too, this region is near to the Torgoth Neutral Zone. Not that we are expecting trouble. But be ready to enforce USFP territorial boundaries and protect USFP citizen and assets in any event.")
    end
    if (Ardent ~= nil and Cryo_Ship ~= nil and Ardent:isValid() and Cryo_Ship:isValid() and distance(Ardent, Cryo_Ship) < 30000.000000) and variable_AT1 ~= (1.0) then
        Ardent:addCustomMessage("scienceOfficer", "warning", "4 Life Signs Aboard The Cyro Ship")
        temp_transmission_object:setCallSign("Internal Comms - Security"):sendCommsMessage(getPlayerShip(-1), "This is Lieutenant Commander Hail. I have an away team prepped and ready on the pad to beam over to the Cryo Ship, as soon as we\'re in transporter range.")
        variable_AT1 = 1.0
    end
    if (Ardent ~= nil and Cryo_Ship ~= nil and Ardent:isValid() and Cryo_Ship:isValid() and distance(Ardent, Cryo_Ship) < 3500.000000) and variable_AT2 ~= (1.0) then
        Ardent:addCustomMessage("scienceOfficer", "warning", "Away Team Transported To The Cryo Ship.")
        temp_transmission_object:setCallSign("Away Team"):sendCommsMessage(getPlayerShip(-1), "We\'re aboard the Cryo Ship. Beginning our sweep.")
        variable_AT2 = 1.0
        timers["AT3timer"] = 10.000000
    end
    if (timers["AT3timer"] ~= nil and timers["AT3timer"] < 0.0) and variable_AT3 ~= (1.0) then
        variable_AT3 = 1.0
        timers["AT4timer"] = 10.000000
        temp_transmission_object:setCallSign("Away Team"):sendCommsMessage(getPlayerShip(-1), "It\'s not Terran, but it looks like it was designed for humanoids. No signs of any crew.")
    end
    if (timers["AT4timer"] ~= nil and timers["AT4timer"] < 0.0) and variable_AT4 ~= (1.0) then
        variable_AT4 = 1.0
        timers["AT5timer"] = 10.000000
        temp_transmission_object:setCallSign("Away Team"):sendCommsMessage(getPlayerShip(-1), "It looks old and in pretty bad shape. Most of the systems are either powered down or damaged.")
    end
    if (timers["AT5timer"] ~= nil and timers["AT5timer"] < 0.0) and variable_AT5 ~= (1.0) then
        temp_transmission_object:setCallSign("Away Team"):sendCommsMessage(getPlayerShip(-1), "There\'s some kind of command console. It looks almost organic. Long hanging tendrils are connecting it to several of the ship\'s other systems.")
        variable_AT5 = 1.0
        timers["AT6timer"] = 10.000000
    end
    if (timers["AT6timer"] ~= nil and timers["AT6timer"] < 0.0) and variable_AT6 ~= (1.0) then
        temp_transmission_object:setCallSign("Away Team"):sendCommsMessage(getPlayerShip(-1), "There are four cryogenic units. They\'re still operational.")
        variable_AT6 = 1.0
        timers["AT7timer"] = 10.000000
    end
    if (timers["AT7timer"] ~= nil and timers["AT7timer"] < 0.0) and variable_AT7 ~= (1.0) then
        temp_transmission_object:setCallSign("Away Team"):sendCommsMessage(getPlayerShip(-1), "They\'re kids! The four life signs are four Terran children.")
        variable_AT7 = 1.0
        timers["AT8timer"] = 7.000000
    end
    if (timers["AT8timer"] ~= nil and timers["AT8timer"] < 0.0) and variable_AT8 ~= (1.0) then
        variable_AT8 = 1.0
        timers["AT9timer"] = 5.000000
        temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "The Exeter has been cataloguing gaseous planetary anomalies in a nearby Sector. Their scientific and medical bays are better equipped to deal with the Cryo Ship, so they will rendezvous with you and will take custody of it. Until then secure the ship and the children.")
    end
    if (timers["AT9timer"] ~= nil and timers["AT9timer"] < 0.0) and variable_AT9 ~= (1.0) then
        variable_AT9 = 1.0
        temp_transmission_object:setCallSign("Internal Comms - Security"):sendCommsMessage(getPlayerShip(-1), "Away team to bridge. We\'re back aboard.")
        Ardent:addCustomMessage("scienceOfficer", "warning", "Enemy Contacts")
        TG01 = CpuShip():setTemplate("Cruiser"):setCallSign("TG01"):setFaction("Kraylor"):setPosition(-5000.0, -99500.0):orderRoaming()
        if fleet[1] == nil then fleet[1] = {} end
        table.insert(fleet[1], TG01)
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], TG01)
        TG02 = CpuShip():setTemplate("Cruiser"):setCallSign("TG02"):setFaction("Kraylor"):setPosition(-5500.0, -99500.0):orderRoaming()
        table.insert(fleet[1], TG02)
        table.insert(fleet[0], TG02)
        timers["ATenemymessage"] = 6.000000
        --WARNING: Unknown AI: TG02: {'CHASE_ANGER': {'type': 'CHASE_ANGER', 'name': 'TG02'}, 'ATTACK': {'type': 'ATTACK', 'targetName': 'Ardent', 'name': 'TG02', 'value1': '1.0'}} 
        --WARNING: Unknown AI: TG01: {'CHASE_ANGER': {'type': 'CHASE_ANGER', 'name': 'TG01'}, 'ATTACK': {'type': 'ATTACK', 'targetName': 'Ardent', 'name': 'TG01', 'value1': '1.0'}} 
    end
    if (timers["ATenemymessage"] ~= nil and timers["ATenemymessage"] < 0.0) and variable_warn2c ~= (1.0) then
        --WARNING: Ignore <start_getting_keypresses_from> {'consoles': 'C'} 
        variable_warn2c = 1.0
        temp_transmission_object:setCallSign("TG01"):sendCommsMessage(getPlayerShip(-1), "The cargo is ours. You will back away from the transport and surrender it to us!\n------------------------------\n   (Comms Officer Reply Using The Numbers On Your Keyboard)\n7.   Under the TAK Treaty of 2191 this Sector is in USFP Territory. You will withdraw back to Torgoth space immediately. \n8.   Cargo! They\'re children! And they\'re USFP citizens and under our protection.\n9.   Take it. The cargo is yours.")
        timers["LAG"] = 2.000000
    end
    if variable_warn2c == (1.0) and variable_object_2Canswer ~= (1.0) and 0 and (timers["LAG"] ~= nil and timers["LAG"] < 0.0) then
        --WARNING: Ignore <if_client_key> {'keyText': '7'} 
        variable_object_2Canswer = 1.0
        --WARNING: Ignore <end_getting_keypresses_from> {'consoles': 'C'} 
        temp_transmission_object:setCallSign("TG01"):sendCommsMessage(getPlayerShip(-1), "The cargo is ours!")
        TG02:orderAttack(Ardent)
        TG01:orderAttack(Ardent)
    end
    if variable_warn2c == (1.0) and variable_object_2Canswer ~= (1.0) and 0 and (timers["LAG"] ~= nil and timers["LAG"] < 0.0) then
        --WARNING: Ignore <if_client_key> {'keyText': '8'} 
        variable_object_2Canswer = 1.0
        --WARNING: Ignore <end_getting_keypresses_from> {'consoles': 'C'} 
        temp_transmission_object:setCallSign("TG01"):sendCommsMessage(getPlayerShip(-1), "Your protection? Don\'t make me laugh.")
        TG02:orderAttack(Ardent)
        TG01:orderAttack(Ardent)
    end
    if variable_warn2c == (1.0) and variable_object_2Canswer ~= (1.0) and 0 and (timers["LAG"] ~= nil and timers["LAG"] < 0.0) then
        --WARNING: Ignore <if_client_key> {'keyText': '9'} 
        variable_object_2Canswer = 1.0
        --WARNING: Ignore <end_getting_keypresses_from> {'consoles': 'C'} 
        temp_transmission_object:setCallSign("TG01"):sendCommsMessage(getPlayerShip(-1), "Excellent.")
        globalMessage("Mission Failed\n\n");
        timers["endgame"] = 10.000000
        TG02:orderAttack(Ardent)
        TG01:orderAttack(Ardent)
    end
    if variable_object_2Canswer == (1.0) and countFleet(1) == 0.000000 and variable_exe1 ~= (1.0) then
        variable_exe1 = 1.0
        timers["exe2timer"] = 4.000000
    end
    if (timers["exe2timer"] ~= nil and timers["exe2timer"] < 0.0) and variable_exe2 ~= (1.0) then
        Exeter = CpuShip():setTemplate("Tug"):setCallSign("Exeter"):setFaction("Independent"):setPosition(18000.0, -70000.0):orderRoaming()
        Dakota = CpuShip():setTemplate("Tug"):setCallSign("Dakota"):setFaction("Independent"):setPosition(18500.0, -71500.0):orderRoaming()
        Horatio = CpuShip():setTemplate("Tug"):setCallSign("Horatio"):setFaction("Independent"):setPosition(18500.0, -70000.0):orderRoaming()
        Summit = CpuShip():setTemplate("Tug"):setCallSign("Summit"):setFaction("Independent"):setPosition(18500.0, -70000.0):orderRoaming()
        Devore = CpuShip():setTemplate("Tug"):setCallSign("Devore"):setFaction("Independent"):setPosition(18500.0, -68500.0):orderRoaming()
        if Exeter ~= nil and Exeter:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'topSpeed', 'name': 'Exeter', 'value': '9.0'} 
        end
        if Horatio ~= nil and Horatio:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'topSpeed', 'name': 'Horatio', 'value': '5.0'} 
        end
        if Summit ~= nil and Summit:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'topSpeed', 'name': 'Summit', 'value': '5.0'} 
        end
        if Exeter ~= nil and Exeter:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'throttle', 'name': 'Exeter', 'value': '1.0'} 
        end
        if Horatio ~= nil and Horatio:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'throttle', 'name': 'Horatio', 'value': '1.0'} 
        end
        if Summit ~= nil and Summit:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'throttle', 'name': 'Summit', 'value': '1.0'} 
        end
        variable_exe2 = 1.0
        temp_transmission_object:setCallSign("Exeter"):sendCommsMessage(getPlayerShip(-1), "Standby Ardent, we are on approach.")
        --WARNING: Unknown AI: Dakota: {'DIR_THROTTLE': {'type': 'DIR_THROTTLE', 'value2': '1.0', 'value1': '270.0', 'name': 'Dakota'}} 
        --WARNING: Unknown AI: Summit: {'DIR_THROTTLE': {'type': 'DIR_THROTTLE', 'value2': '1.0', 'value1': '270.0', 'name': 'Summit'}} 
        --WARNING: Unknown AI: Horatio: {'DIR_THROTTLE': {'type': 'DIR_THROTTLE', 'value2': '1.0', 'value1': '270.0', 'name': 'Horatio'}} 
        --WARNING: Unknown AI: Devore: {'DIR_THROTTLE': {'type': 'DIR_THROTTLE', 'value2': '1.0', 'value1': '270.0', 'name': 'Devore'}} 
        --WARNING: Unknown AI: Exeter: {'TARGET_THROTTLE': {'type': 'TARGET_THROTTLE', 'targetName': 'Cryo Ship', 'name': 'Exeter', 'value1': '1.0'}} 
    end
    if (Cryo_Ship ~= nil and Exeter ~= nil and Cryo_Ship:isValid() and Exeter:isValid() and distance(Cryo_Ship, Exeter) < 5000.000000) then
        if Exeter ~= nil and Exeter:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'throttle', 'name': 'Exeter', 'value': '0.0'} 
        end
        variable_summitstopped = 1.0
    end
    if (Cryo_Ship ~= nil and Dakota ~= nil and Cryo_Ship:isValid() and Dakota:isValid() and distance(Cryo_Ship, Dakota) < 5000.000000) then
        if Dakota ~= nil and Dakota:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'throttle', 'name': 'Dakota', 'value': '0.0'} 
        end
    end
    if (Cryo_Ship ~= nil and Horatio ~= nil and Cryo_Ship:isValid() and Horatio:isValid() and distance(Cryo_Ship, Horatio) < 5000.000000) then
        if Horatio ~= nil and Horatio:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'throttle', 'name': 'Horatio', 'value': '0.0'} 
        end
    end
    if (Cryo_Ship ~= nil and Devore ~= nil and Cryo_Ship:isValid() and Devore:isValid() and distance(Cryo_Ship, Devore) < 5000.000000) then
        if Devore ~= nil and Devore:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'throttle', 'name': 'Devore', 'value': '0.0'} 
        end
    end
    if (Cryo_Ship ~= nil and Summit ~= nil and Cryo_Ship:isValid() and Summit:isValid() and distance(Cryo_Ship, Summit) < 5000.000000) then
        if Summit ~= nil and Summit:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'throttle', 'name': 'Summit', 'value': '0.0'} 
        end
    end
    if variable_summitstopped == (1.0) and variable_exe3 ~= (1.0) then
        TG01 = CpuShip():setTemplate("Cruiser"):setCallSign("TG01"):setFaction("Kraylor"):setPosition(-52000.0, -2000.0):orderRoaming()
        if fleet[2] == nil then fleet[2] = {} end
        table.insert(fleet[2], TG01)
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], TG01)
        variable_exe3 = 1.0
        temp_transmission_object:setCallSign("Exeter"):sendCommsMessage(getPlayerShip(-1), "Torgoth vessel detected! We\'ll secure the ship and beam the children aboard.")
        timers["exe4timer"] = 8.000000
        temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "While the Exeter attempts to retrieve and revive the children, Ardent, you are to engage the Torgoth ship in grid E2.")
        --WARNING: Unknown AI: TG01: {'TARGET_THROTTLE': {'type': 'TARGET_THROTTLE', 'targetName': 'Cryo Ship', 'name': 'TG01', 'value1': '0.5'}} 
    end
    if variable_exe4 ~= (1.0) and (timers["exe4timer"] ~= nil and timers["exe4timer"] < 0.0) then
        Akira = CpuShip():setTemplate("Tug"):setCallSign("Akira"):setFaction("Independent"):setPosition(-50000.0, -98000.0):orderRoaming()
        Rabin = CpuShip():setTemplate("Tug"):setCallSign("Rabin"):setFaction("Independent"):setPosition(-51000.0, -99000.0):orderRoaming()
        variable_exe4 = 1.0
        temp_transmission_object:setCallSign("Akira"):sendCommsMessage(getPlayerShip(-1), "We detected hostiles. May we provide any assistance?")
        timers["exe5timer"] = 4.000000
        --WARNING: Unknown AI: Akira: {'DIR_THROTTLE': {'type': 'DIR_THROTTLE', 'value2': '1.0', 'value1': '180.0', 'name': 'Akira'}} 
        --WARNING: Unknown AI: Rabin: {'DIR_THROTTLE': {'type': 'DIR_THROTTLE', 'value2': '1.0', 'value1': '180.0', 'name': 'Rabin'}} 
    end
    if variable_exe5 ~= (1.0) and (timers["exe5timer"] ~= nil and timers["exe5timer"] < 0.0) then
        variable_exe5 = 1.0
        temp_transmission_object:setCallSign("Exeter"):sendCommsMessage(getPlayerShip(-1), "There\'s still a Torgoth Goliath in the Sector.")
        temp_transmission_object:setCallSign("Akira"):sendCommsMessage(getPlayerShip(-1), "Affirmative. Moving to intercept.")
    end
    if (Ardent ~= nil and TG01 ~= nil and Ardent:isValid() and TG01:isValid() and distance(Ardent, TG01) < 20000.000000) and variable_exe5 == (1.0) and variable_exe6 ~= (1.0) then
        if TG01 ~= nil and TG01:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'hasSurrendered', 'name': 'TG01', 'value': '1'} 
        end
        variable_exe6 = 1.0
        temp_transmission_object:setCallSign("Exeter"):sendCommsMessage(getPlayerShip(-1), "Help! Help! They...")
        temp_transmission_object:setCallSign("TG01"):sendCommsMessage(getPlayerShip(-1), "It\'s too late. The cargo has been compromised.")
        timers["exe7timer"] = 4.000000
        TG01:orderIdle()
    end
    if (timers["exe7timer"] ~= nil and timers["exe7timer"] < 0.0) and variable_exe7 ~= (1.0) then
        temp_transmission_object:setCallSign("Summit"):sendCommsMessage(getPlayerShip(-1), "Augh!!!")
        variable_exe7 = 1.0
        timers["exe8timer"] = 3.000000
    end
    if (timers["exe8timer"] ~= nil and timers["exe8timer"] < 0.0) and variable_exe8 ~= (1.0) then
        variable_exe8 = 1.0
        temp_transmission_object:setCallSign("Horatio"):sendCommsMessage(getPlayerShip(-1), "Help!")
        timers["exe9timer"] = 2.000000
    end
    if (timers["exe9timer"] ~= nil and timers["exe9timer"] < 0.0) and variable_exe9 ~= (1.0) then
        variable_exe9 = 1.0
        Exeter_ = CpuShip():setTemplate("Cruiser"):setCallSign("Exeter "):setFaction("Kraylor"):setPosition(18000.0, -70000.0):orderRoaming()
        if fleet[3] == nil then fleet[3] = {} end
        table.insert(fleet[3], Exeter_)
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], Exeter_)
        Dakota_ = CpuShip():setTemplate("Cruiser"):setCallSign("Dakota "):setFaction("Kraylor"):setPosition(18500.0, -71500.0):orderRoaming()
        if fleet[4] == nil then fleet[4] = {} end
        table.insert(fleet[4], Dakota_)
        table.insert(fleet[0], Dakota_)
        Horatio_ = CpuShip():setTemplate("Cruiser"):setCallSign("Horatio "):setFaction("Kraylor"):setPosition(18500.0, -70000.0):orderRoaming()
        table.insert(fleet[4], Horatio_)
        table.insert(fleet[0], Horatio_)
        Summit_ = CpuShip():setTemplate("Cruiser"):setCallSign("Summit "):setFaction("Kraylor"):setPosition(18500.0, -70000.0):orderRoaming()
        table.insert(fleet[4], Summit_)
        table.insert(fleet[0], Summit_)
        Devore_ = CpuShip():setTemplate("Cruiser"):setCallSign("Devore "):setFaction("Kraylor"):setPosition(18500.0, -68500.0):orderRoaming()
        table.insert(fleet[4], Devore_)
        table.insert(fleet[0], Devore_)
        tmp_x, tmp_y = Exeter:getPosition()
        tmp_x2, tmp_y2 = vectorFromAngle(Exeter:getRotation() + 0.000000, 200.000000)
        Exeter_:setPosition(x, y);
        if Exeter ~= nil and Exeter:isValid() then Exeter:destroy() end
        tmp_x, tmp_y = Dakota:getPosition()
        tmp_x2, tmp_y2 = vectorFromAngle(Dakota:getRotation() + 0.000000, 200.000000)
        Dakota_:setPosition(x, y);
        if Dakota ~= nil and Dakota:isValid() then Dakota:destroy() end
        tmp_x, tmp_y = Horatio:getPosition()
        tmp_x2, tmp_y2 = vectorFromAngle(Horatio:getRotation() + 0.000000, 200.000000)
        Horatio_:setPosition(x, y);
        if Horatio ~= nil and Horatio:isValid() then Horatio:destroy() end
        tmp_x, tmp_y = Summit:getPosition()
        tmp_x2, tmp_y2 = vectorFromAngle(Summit:getRotation() + 0.000000, 200.000000)
        Summit_:setPosition(x, y);
        if Summit ~= nil and Summit:isValid() then Summit:destroy() end
        tmp_x, tmp_y = Devore:getPosition()
        tmp_x2, tmp_y2 = vectorFromAngle(Devore:getRotation() + 0.000000, 200.000000)
        Devore_:setPosition(x, y);
        if Devore ~= nil and Devore:isValid() then Devore:destroy() end
        timers["SPECIAL_ONE"] = 3.000000
        --WARNING: Unknown AI: Exeter_: {'CLEAR': True, 'TARGET_THROTTLE': {'type': 'TARGET_THROTTLE', 'targetName': 'Akira', 'name': 'Exeter ', 'value1': '1.0'}} 
    end
    if (timers["SPECIAL_ONE"] ~= nil and timers["SPECIAL_ONE"] < 0.0) and variable_spone ~= (1.0) then
        variable_spone = 1.0
        if Exeter_ ~= nil and Exeter_:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'topSpeed', 'name': 'Exeter ', 'value': '5.0'} 
        end
        if Horatio_ ~= nil and Horatio_:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'topSpeed', 'name': 'Horatio ', 'value': '2.0'} 
        end
        if Summit_ ~= nil and Summit_:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'topSpeed', 'name': 'Summit ', 'value': '2.0'} 
        end
        if Dakota_ ~= nil and Dakota_:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'topSpeed', 'name': 'Dakota ', 'value': '2.0'} 
        end
        if Devore_ ~= nil and Devore_:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'topSpeed', 'name': 'Devore ', 'value': '2.0'} 
        end
        if Exeter_ ~= nil and Exeter_:isValid() then
        Exeter_:setSystemHealth("RearShieldMax", 1.500000)
        end
        if Exeter_ ~= nil and Exeter_:isValid() then
        Exeter_:setSystemHealth("FrontShieldMax", 0.750000)
        end
        if Horatio_ ~= nil and Horatio_:isValid() then
        Horatio_:setSystemHealth("FrontShieldMax", 0.000000)
        end
        if Horatio_ ~= nil and Horatio_:isValid() then
        Horatio_:setSystemHealth("RearShieldMax", 0.000000)
        end
        if Summit_ ~= nil and Summit_:isValid() then
        Summit_:setSystemHealth("FrontShieldMax", 0.000000)
        end
        if Summit_ ~= nil and Summit_:isValid() then
        Summit_:setSystemHealth("RearShieldMax", 0.000000)
        end
        if Dakota_ ~= nil and Dakota_:isValid() then
        Dakota_:setSystemHealth("FrontShieldMax", 0.000000)
        end
        if Dakota_ ~= nil and Dakota_:isValid() then
        Dakota_:setSystemHealth("RearShieldMax", 0.000000)
        end
        if Devore_ ~= nil and Devore_:isValid() then
        Devore_:setSystemHealth("FrontShieldMax", 0.000000)
        end
        if Devore_ ~= nil and Devore_:isValid() then
        Devore_:setSystemHealth("RearShieldMax", 0.000000)
        end
    end
    if (Exeter_ ~= nil and Akira ~= nil and Exeter_:isValid() and Akira:isValid() and distance(Exeter_, Akira) < 20000.000000) and variable_akiracomms ~= (1.0) then
        variable_akiracomms = 1.0
        temp_transmission_object:setCallSign("Akira"):sendCommsMessage(getPlayerShip(-1), "Exeter please respond?")
    end
    if (Exeter_ ~= nil and Akira ~= nil and Exeter_:isValid() and Akira:isValid() and distance(Exeter_, Akira) < 10000.000000) and variable_exe10 ~= (1.0) then
        variable_exe10 = 1.0
        Akira_ = CpuShip():setTemplate("Cruiser"):setCallSign("Akira "):setFaction("Kraylor"):setPosition(-50000.0, -98000.0):orderRoaming()
        if fleet[5] == nil then fleet[5] = {} end
        table.insert(fleet[5], Akira_)
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], Akira_)
        Rabin_ = CpuShip():setTemplate("Cruiser"):setCallSign("Rabin "):setFaction("Kraylor"):setPosition(-51000.0, -99000.0):orderRoaming()
        table.insert(fleet[5], Rabin_)
        table.insert(fleet[0], Rabin_)
        tmp_x, tmp_y = Akira:getPosition()
        tmp_x2, tmp_y2 = vectorFromAngle(Akira:getRotation() + 0.000000, 200.000000)
        Akira_:setPosition(x, y);
        if Akira ~= nil and Akira:isValid() then Akira:destroy() end
        tmp_x, tmp_y = Rabin:getPosition()
        tmp_x2, tmp_y2 = vectorFromAngle(Rabin:getRotation() + 0.000000, 200.000000)
        Rabin_:setPosition(x, y);
        if Rabin ~= nil and Rabin:isValid() then Rabin:destroy() end
        timers["exe11timer"] = 10.000000
        Dakota_:orderAttack(Ardent)
        Summit_:orderAttack(Ardent)
        Devore_:orderAttack(Ardent)
        Horatio_:orderAttack(Ardent)
        Exeter_:orderAttack(Ardent)
        Rabin_:orderAttack(Ardent)
        Akira_:orderAttack(Ardent)
    end
    if variable_tsncomms ~= (1.0) and countFleet(5) == 0.000000 and countFleet(4) == 0.000000 and countFleet(3) == 0.000000 and variable_exe9 == (1.0) and variable_threatpassed == (1.0) then
        variable_tsncomms = 1.0
        temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "This is a tragedy, but many more lives would have been lost if you hadn\'t managed to contain the situation and end it here and now. We\'ll quarantine the Sector until a follow up team can investigate and discover what exactly happened here today, and who or what those children were. Return to DS1 for debriefing.")
        globalMessage("Mission Completed\nThank you for playing.\n");
        timers["endgame"] = 15.000000
    end
    if (timers["endgame"] ~= nil and timers["endgame"] < 0.0) then
        victory("Independent")
    end
    if (Ardent ~= nil and Exeter_ ~= nil and Ardent:isValid() and Exeter_:isValid() and distance(Ardent, Exeter_) < 10000.000000) and variable_board1 ~= (1.0) then
        variable_board1 = 1.0
        temp_transmission_object:setCallSign("Internal Comms - Engineering"):sendCommsMessage(getPlayerShip(-1), "Bridge... Some kid\'s appeared in the... Augh!")
        timers["boardchoicetimer"] = 5.000000
    end
    if variable_board1 == (1.0) and variable_MESp1 ~= (1.0) and (timers["boardchoicetimer"] ~= nil and timers["boardchoicetimer"] < 0.0) then
        timers["MELAG"] = 2.000000
        temp_transmission_object:setCallSign("Internal Comms - Security"):sendCommsMessage(getPlayerShip(-1), "The crew on the lower decks have gone crazy! They\'re attacking each other and destroying the ships systems. What are your orders?\n------------------------------\n   (Comms Officer Relay Orders Using The Numbers On Your Keyboard)\n6. Send a security team down there to restore order. \n7. Vent anesthesia gas into the affected decks to render the crew unconscious.\n8. Seal off the infected decks, deactivate the gravity and blow the bulkhead seals.\n9. Wait a moment...")
        variable_MESp1 = 1.0
        variable_sabengines = 1.0
        --WARNING: Ignore <start_getting_keypresses_from> {'consoles': 'C'} 
    end
    if variable_MESp1 == (1.0) and 0 and variable_MEfv1a ~= (1.0) and (timers["MELAG"] ~= nil and timers["MELAG"] < 0.0) then
        --WARNING: Ignore <if_client_key> {'keyText': '6'} 
        --WARNING: Ignore <end_getting_keypresses_from> {'consoles': 'C'} 
        timers["MEsaba"] = 20.000000
        variable_MEfv1a = 1.0
        temp_transmission_object:setCallSign("Internal Comms - Security"):sendCommsMessage(getPlayerShip(-1), "We\'re on it, Sir.")
        variable_MEfv1aa = 0.0
    end
    if variable_MESp1 == (1.0) and variable_MEfv1aa ~= (1.0) and (timers["MEsaba"] ~= nil and timers["MEsaba"] < 0.0) then
        --WARNING: Ignore <start_getting_keypresses_from> {'consoles': 'C'} 
        timers["MELAG"] = 2.000000
        temp_transmission_object:setCallSign("Internal Comms - Security"):sendCommsMessage(getPlayerShip(-1), "Half of my security team just turned on the other half, for no reason. They set their phasers to kill and just attacked! It was a blood bath. We barely got out alive. What now?\n------------------------------\n7. Vent anesthesia gas into the affected decks to render the crew unconscious.\n8. Seal off the infected decks, deactivate the gravity and blow the bulkhead seals.\n9. Wait a moment...")
        variable_MEfv1aa = 1.0
        variable_MEfv1d = 0.0
        variable_MEfv1b = 0.0
        variable_MEfv1c = 0.0
        variable_sabsheilds2 = 1.0
        --WARNING: Ignore <set_damcon_members> {'team_index': '0', 'value': '0.0'} 
    end
    if variable_MESp1 == (1.0) and 0 and variable_MEfv1b ~= (1.0) and (timers["MELAG"] ~= nil and timers["MELAG"] < 0.0) then
        --WARNING: Ignore <if_client_key> {'keyText': '7'} 
        --WARNING: Ignore <end_getting_keypresses_from> {'consoles': 'C'} 
        timers["MEsabb"] = 10.000000
        variable_MEfv1b = 1.0
        temp_transmission_object:setCallSign("Internal Comms - Security"):sendCommsMessage(getPlayerShip(-1), "Yes Sir, making the appropriate adjustments to life support now.")
        variable_MEfv1bb = 0.0
    end
    if variable_MESp1 == (1.0) and variable_MEfv1bb ~= (1.0) and (timers["MEsabb"] ~= nil and timers["MEsabb"] < 0.0) then
        --WARNING: Ignore <start_getting_keypresses_from> {'consoles': 'C'} 
        timers["MELAG"] = 2.000000
        temp_transmission_object:setCallSign("Internal Comms - Security"):sendCommsMessage(getPlayerShip(-1), "The gas had no effect. Didn\'t even slow them down. The homicidal crewman just took control  of another deck!\n------------------------------\n6. Send a security team down there to restore order.\n8. Seal off the infected decks, deactivate the gravity and blow the bulkhead seals.\n9. Wait a moment...")
        variable_MEfv1bb = 1.0
        variable_MEfv1a = 0.0
        variable_MEfv1d = 0.0
        variable_MEfv1c = 0.0
        variable_sabsheilds1 = 1.0
        --WARNING: Ignore <set_damcon_members> {'team_index': '1', 'value': '0.0'} 
    end
    if variable_MESp1 == (1.0) and 0 and variable_MEfv1c ~= (1.0) and (timers["MELAG"] ~= nil and timers["MELAG"] < 0.0) then
        --WARNING: Ignore <if_client_key> {'keyText': '8'} 
        --WARNING: Ignore <end_getting_keypresses_from> {'consoles': 'C'} 
        timers["MEsabc"] = 10.000000
        variable_MEfv1c = 1.0
        temp_transmission_object:setCallSign("Internal Comms - Security"):sendCommsMessage(getPlayerShip(-1), "But that\'ll blow everyone on those decks into hard vacuum... I see. Getting it done, Sir.")
        variable_MEfv1cc = 0.0
    end
    if variable_MESp1 == (1.0) and variable_MEfv1cc ~= (1.0) and (timers["MEsabc"] ~= nil and timers["MEsabc"] < 0.0) then
        --WARNING: Ignore <start_getting_keypresses_from> {'consoles': 'C'} 
        timers["MELAG"] = 2.000000
        temp_transmission_object:setCallSign("Internal Comms - Security"):sendCommsMessage(getPlayerShip(-1), "The threat to the ship has been neutralized. Restoring the bulkhead seals, atmosphere and pressure to affected decks.")
        variable_MEfv1cc = 1.0
        variable_MEfv1a = 0.0
        variable_MEfv1b = 0.0
        variable_MEfv1d = 0.0
        variable_sabengines = 0.0
        variable_sabimpulse = 0.0
        variable_sabsheilds1 = 0.0
        variable_sabsheilds2 = 0.0
        variable_threatpassed = 1.0
    end
    if variable_MESp1 == (1.0) and 0 and variable_MEfv1d ~= (1.0) and (timers["MELAG"] ~= nil and timers["MELAG"] < 0.0) then
        --WARNING: Ignore <if_client_key> {'keyText': '9'} 
        --WARNING: Ignore <end_getting_keypresses_from> {'consoles': 'C'} 
        timers["MEsabd"] = 5.000000
        variable_MEfv1d = 1.0
        temp_transmission_object:setCallSign("Internal Comms - Security"):sendCommsMessage(getPlayerShip(-1), "Sir, we\'re waiting for your instructions?")
        variable_MEfv1dd = 0.0
    end
    if variable_MESp1 == (1.0) and variable_MEfv1dd ~= (1.0) and (timers["MEsabd"] ~= nil and timers["MEsabd"] < 0.0) then
        --WARNING: Ignore <start_getting_keypresses_from> {'consoles': 'C'} 
        timers["MELAG"] = 2.000000
        temp_transmission_object:setCallSign("Internal Comms - Security"):sendCommsMessage(getPlayerShip(-1), "We just lost two more decks! If we don\'t do something we\'re going to lose the whole ship!\n------------------------------\n6. Send a security team down there to restore order.\n7. Vent anesthesia gas into the affected decks to render the crew unconscious.\n8. Seal off the infected decks, deactivate the gravity and blow the bulkhead seals.")
        variable_MEfv1dd = 1.0
        variable_MEfv1a = 0.0
        variable_MEfv1b = 0.0
        variable_MEfv1c = 0.0
        variable_sabimpulse = 1.0
        --WARNING: Ignore <set_damcon_members> {'team_index': '2', 'value': '0.0'} 
    end
    if variable_sabengines == (1.0) then
        getPlayerShip(-1):setSystemHealth("jumpdrive", 0.500000)
        getPlayerShip(-1):setSystemHealth("warp", 0.500000)
        getPlayerShip(-1):setSystemHealth("jumpdrive", 0.000000)
        getPlayerShip(-1):setSystemHealth("warp", 0.000000)
    end
    if variable_sabsheilds1 == (1.0) then
        getPlayerShip(-1):setSystemHealth("rearshield", 0.000000)
        getPlayerShip(-1):setSystemHealth("rearshield", 0.000000)
    end
    if variable_sabsheilds2 == (1.0) then
        getPlayerShip(-1):setSystemHealth("rearshield", 0.500000)
    end
    if variable_sabimpulse == (1.0) then
        getPlayerShip(-1):setSystemHealth("impulse", 0.500000)
        getPlayerShip(-1):setSystemHealth("impulse", 0.500000)
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
