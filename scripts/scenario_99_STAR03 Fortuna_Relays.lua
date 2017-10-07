-- Name: STAR03 Fortuna_Relays
-- Description: Converted Artemis mission

function init()
    timers = {}
    fleet = {}
	temp_transmission_object = SpaceStation():setTemplate("Small Station"):setPosition(-1000000, -1000000)
    tmp_count = 4
    for tmp_counter=1,tmp_count do
        tmp_x, tmp_y = vectorFromAngle(-90.0 + (270.0 - -90.0) * (tmp_counter - 1) / tmp_count, 25000.0)
        tmp_x, tmp_y = tmp_x + -30000.0, tmp_y + -50000.0
        tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 22500.0))
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
        Nebula():setPosition(tmp_x, tmp_y)
    end
    Ardent = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Player Cruiser"):setCallSign("Ardent"):setPosition(10000.0, -10000.0)
    AN01 = SupplyDrop():setFaction("Human Navy"):setPosition(-65074.0, -84594.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
    AN02 = SupplyDrop():setFaction("Human Navy"):setPosition(6830.0, -35540.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
    AN03 = SupplyDrop():setFaction("Human Navy"):setPosition(1000.0, -9000.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
    globalMessage("An Ardent Adventure:          The Fortuna Relays\nBy Andrew Lacey\nfox_glos@hotmail.com");
    timers["start_mission_timer_1"] = 10.000000
    addGMFunction("Kill all enemy ships", function()
        variable_KILL = 1.0
    end)
end

function update(delta)
    for key, value in pairs(timers) do
        timers[key] = timers[key] - delta
    end

    if variable_KILL == (1.0) then
        if SK01 ~= nil and SK01:isValid() then SK01:destroy() end
        if SK02 ~= nil and SK02:isValid() then SK02:destroy() end
        if SK03 ~= nil and SK03:isValid() then SK03:destroy() end
        if SK04 ~= nil and SK04:isValid() then SK04:destroy() end
        if SK05 ~= nil and SK05:isValid() then SK05:destroy() end
        if SK06 ~= nil and SK06:isValid() then SK06:destroy() end
        if SK07 ~= nil and SK07:isValid() then SK07:destroy() end
        variable_KILL = 2.0
    end
    if (timers["start_mission_timer_1"] ~= nil and timers["start_mission_timer_1"] < 0.0) and variable_instructions ~= (1.0) then
        variable_instructions = 1.0
        temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "The Fortuna Expanse is an area of space where subspace is turbulent. This causes significant problems for subspace communications. Recently a well armed group of Skaraans calling themselves The Fortuna Pirates have been marauding around the area, attacking cargo ships that use the Expanse as a short cut. Because of the subspace turbulence the traders have been unable to call for help and we haven’t been able to track the pirates to their main base. So we’re deploying a network of subspace signal relay throughout the Fortuna Expanse. Your ship will be one of six vessels travelling though the Expanse deploying the relay network.")
        temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Go to grid E1 and deploy the first relay.")
        variable_areaone = 1.0
    end
    if ifInsideSphere(Ardent, -70000.0, -10000.0, 40000.000000) and variable_hellomrnewman ~= (1.0) then
        temp_transmission_object:setCallSign("Internal Comms - Cargo Bay"):sendCommsMessage(getPlayerShip(-1), "This is Ensign Newman in cargo bay two. Give the word when we\'re in position and we\'ll deploy the relays.")
        variable_hellomrnewman = 1.0
    end
    if ifInsideBox(Ardent, -60000.0, -20000.0, -80000.0, 0.0) and 0 and (Relay_1 == nil or not Relay_1:isValid()) and variable_areaone == (1.0) then
        if button_relay ~= 1 then
            Ardent:addCustomButton("relayOfficer", "relay_button", "Deploy subspace relay", function()
                Relay_1 = CpuShip():setTemplate("Tug"):setCallSign("Relay 1"):setFaction("Independent"):setPosition(-70000.0, -10000.0):orderRoaming()
                tmp_x, tmp_y = Ardent:getPosition()
                tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 180.000000, 100.000000)
                Relay_1:setPosition(x, y);
                temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Deploy another relay in grid D2.")
                --WARNING: Ignore <set_ship_text> {'class': 'Relay', 'name': 'Relay 1', 'desc': 'A subspace signal relay.'}
                if Relay_1 ~= nil and Relay_1:isValid() then
                    --WARNING: Ignore <set_object_property> {'property': 'pitch', 'name': 'Relay 1', 'value': '5.0'}
                end
                Ardent:addCustomMessage("scienceOfficer", "warning", "Relay operational.")
                Ardent:removeCustom("relay_button")
                button_relay = 0
            end)
            button_relay = 1
        end
    end
    if ifInsideBox(Ardent, -40000.0, -40000.0, -60000.0, -20000.0) and 0 and (Relay_2 == nil or not Relay_2:isValid()) and variable_areaone == (1.0) and (Relay_1 ~= nil and Relay_1:isValid()) then
        if button_relay ~= 1 then
            Ardent:addCustomButton("relayOfficer", "relay_button", "Deploy subspace relay", function()
                Relay_2 = CpuShip():setTemplate("Tug"):setCallSign("Relay 2"):setFaction("Independent"):setPosition(-70000.0, -10000.0):orderRoaming()
                tmp_x, tmp_y = Ardent:getPosition()
                tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 180.000000, 100.000000)
                Relay_2:setPosition(x, y);
                temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Deploy another relay in grid C3.")
                --WARNING: Ignore <set_ship_text> {'class': 'Relay', 'name': 'Relay 2', 'desc': 'A subspace signal relay.'}
                if Relay_2 ~= nil and Relay_2:isValid() then
                --WARNING: Ignore <set_object_property> {'property': 'pitch', 'name': 'Relay 2', 'value': '5.0'}
                end
                Ardent:addCustomMessage("scienceOfficer", "warning", "Relay operational.")
                variable_relay2made = 1.0
                Ardent:removeCustom("relay_button")
                button_relay = 0
            end)
            button_relay = 1
        end
    end
    if ifInsideBox(Ardent, -20000.0, -60000.0, -40000.0, -40000.0) and 0 and (Relay_3 == nil or not Relay_3:isValid()) and variable_areaone == (1.0) and (Relay_1 ~= nil and Relay_1:isValid()) and (Relay_2 ~= nil and Relay_2:isValid()) then
        if button_relay ~= 1 then
            Ardent:addCustomButton("relayOfficer", "relay_button", "Deploy subspace relay", function()
                Relay_3 = CpuShip():setTemplate("Tug"):setCallSign("Relay 3"):setFaction("Independent"):setPosition(-70000.0, -10000.0):orderRoaming()
                tmp_x, tmp_y = Ardent:getPosition()
                tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 180.000000, 100.000000)
                Relay_3:setPosition(x, y);
                temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Deploy another relay in grid B4.")
                --WARNING: Ignore <set_ship_text> {'class': 'Relay', 'name': 'Relay 3', 'desc': 'A subspace signal relay.'}
                if Relay_3 ~= nil and Relay_3:isValid() then
                --WARNING: Ignore <set_object_property> {'property': 'pitch', 'name': 'Relay 3', 'value': '5.0'}
                end
                Ardent:addCustomMessage("scienceOfficer", "warning", "Relay operational.")
                Ardent:removeCustom("relay_button")
                button_relay = 0
            end)
            button_relay = 1
        end
    end
    if ifInsideBox(Ardent, 0.0, -80000.0, -20000.0, -60000.0) and 0 and (Relay_4 == nil or not Relay_4:isValid()) and variable_areaone == (1.0) and (Relay_1 ~= nil and Relay_1:isValid()) and (Relay_2 ~= nil and Relay_2:isValid()) and (Relay_3 ~= nil and Relay_3:isValid()) then
        if button_relay ~= 1 then
            Ardent:addCustomButton("relayOfficer", "relay_button", "Deploy subspace relay", function()
                Relay_4 = CpuShip():setTemplate("Tug"):setCallSign("Relay 4"):setFaction("Independent"):setPosition(-70000.0, -10000.0):orderRoaming()
                tmp_x, tmp_y = Ardent:getPosition()
                tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 180.000000, 100.000000)
                Relay_4:setPosition(x, y);
                temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Deploy another relay in grid A5.")
                --WARNING: Ignore <set_ship_text> {'class': 'Relay', 'name': 'Relay 4', 'desc': 'A subspace signal relay.'}
                if Relay_4 ~= nil and Relay_4:isValid() then
                --WARNING: Ignore <set_object_property> {'property': 'pitch', 'name': 'Relay 4', 'value': '5.0'}
                end
                Ardent:addCustomMessage("scienceOfficer", "warning", "Relay operational.")
                Ardent:removeCustom("relay_button")
                button_relay = 0
            end)
            button_relay = 1
        end
    end
    if ifInsideBox(Ardent, 20000.0, -100000.0, 0.0, -80000.0) and 0 and (Relay_5 == nil or not Relay_5:isValid()) and variable_areaone == (1.0) and (Relay_1 ~= nil and Relay_1:isValid()) and (Relay_2 ~= nil and Relay_2:isValid()) and (Relay_3 ~= nil and Relay_3:isValid()) and (Relay_4 ~= nil and Relay_4:isValid()) then
        if button_relay ~= 1 then
            Ardent:addCustomButton("relayOfficer", "relay_button", "Deploy subspace relay", function()
                Relay_5 = CpuShip():setTemplate("Tug"):setCallSign("Relay 5"):setFaction("Independent"):setPosition(-70000.0, -10000.0):orderRoaming()
                tmp_x, tmp_y = Ardent:getPosition()
                tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 180.000000, 100.000000)
                Relay_5:setPosition(x, y);
                temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Enemy contacts. Defend relay 2.")
                --WARNING: Ignore <set_ship_text> {'class': 'Relay', 'name': 'Relay 5', 'desc': 'A subspace signal relay.'}
                if Relay_5 ~= nil and Relay_5:isValid() then
                --WARNING: Ignore <set_object_property> {'property': 'pitch', 'name': 'Relay 5', 'value': '5.0'}
                end
                variable_onebadguys = 1.0
                SK01 = CpuShip():setTemplate("Cruiser"):setCallSign("SK01"):setFaction("Kraylor"):setPosition(-70000.0, -30000.0):orderAttack(Relay_2)
                if fleet[1] == nil then fleet[1] = {} end
                table.insert(fleet[1], SK01)
                if fleet[0] == nil then fleet[0] = {} end
                table.insert(fleet[0], SK01)
                SK02 = CpuShip():setTemplate("Cruiser"):setCallSign("SK02"):setFaction("Kraylor"):setPosition(-70000.0, -30000.0):orderAttack(Relay_2)
                table.insert(fleet[1], SK02)
                table.insert(fleet[0], SK02)
                --SK03 = CpuShip():setTemplate("Cruiser"):setCallSign("SK03"):setFaction("Kraylor"):setPosition(-70000.0, -30000.0):orderAttack(Relay_2)
                --table.insert(fleet[1], SK03)
                --table.insert(fleet[0], SK03)
                --WARNING: Ignore <set_ship_text> {'race': 'Pirate', 'name': 'SK01'}
                --WARNING: Ignore <set_ship_text> {'race': 'Pirate', 'name': 'SK02'}
                --WARNING: Ignore <set_ship_text> {'race': 'Pirate', 'name': 'SK03'}
                Ardent:addCustomMessage("scienceOfficer", "warning", "Relay operational.")
                Ardent:removeCustom("relay_button")
                button_relay = 0
            end)
            button_relay = 1
        end
    end
    if variable_onebadguys == (1.0) and countFleet(1) == 0.000000 and variable_onesecured ~= (1.0) then
        temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Once relay 1 to 5 are deployed in this sector go to grid A5 to go to the next one.")
        variable_onesecured = 1.0
    end
    if variable_relay2made == (1.0) and variable_twomake ~= (1.0) and (Relay_2 == nil or not Relay_2:isValid()) and variable_relay3remake ~= (1.0) then
        variable_relay3remake = 1.0
        temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Relay 2 has been destroyed. You will need to replace it with a new relay at the same location.")
    end
    if variable_onesecured == (1.0) and variable_areaone == (1.0) and ifInsideBox(Ardent, 20000.0, -100000.0, 0.0, -80000.0) and (Relay_1 ~= nil and Relay_1:isValid()) and (Relay_2 ~= nil and Relay_2:isValid()) and (Relay_3 ~= nil and Relay_3:isValid()) and (Relay_4 ~= nil and Relay_4:isValid()) and (Relay_5 ~= nil and Relay_5:isValid()) then
        variable_areaone = 2.0
    end
    if variable_areaone == (2.0) and variable_twomake ~= (1.0) then
        variable_twomake = 1.0
        for _, obj in ipairs(getObjectsInRadius(-30000.0, -50000.0, 100000.000000)) do
            if obj.typeName == "Nebula" then obj:destroy() end
        end
        if AN01 ~= nil and AN01:isValid() then AN01:destroy() end
        if AN02 ~= nil and AN02:isValid() then AN02:destroy() end
        if AN03 ~= nil and AN03:isValid() then AN03:destroy() end
        if Relay_1 ~= nil and Relay_1:isValid() then Relay_1:destroy() end
        if Relay_2 ~= nil and Relay_2:isValid() then Relay_2:destroy() end
        if Relay_3 ~= nil and Relay_3:isValid() then Relay_3:destroy() end
        if Relay_4 ~= nil and Relay_4:isValid() then Relay_4:destroy() end
        if Relay_5 ~= nil and Relay_5:isValid() then Relay_5:destroy() end
        tmp_count = 4
        for tmp_counter=1,tmp_count do
            tmp_x, tmp_y = vectorFromAngle(-90.0 + (270.0 - -90.0) * (tmp_counter - 1) / tmp_count, 25000.0)
            tmp_x, tmp_y = tmp_x + -30000.0, tmp_y + -50000.0
            tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 22500.0))
            tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
            Nebula():setPosition(tmp_x, tmp_y)
        end
        Trader_5 = CpuShip():setTemplate("Tug"):setCallSign("Trader 5"):setFaction("Independent"):setPosition(5000.0, -37000.0):orderRoaming()
        AN01 = SupplyDrop():setFaction("Human Navy"):setPosition(-68110.0, -48962.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        AN02 = SupplyDrop():setFaction("Human Navy"):setPosition(-6592.0, -76765.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        AN03 = SupplyDrop():setFaction("Human Navy"):setPosition(-30080.0, -13649.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        AN04 = SupplyDrop():setFaction("Human Navy"):setPosition(-61080.0, -18649.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        if Ardent ~= nil and Ardent:isValid() then
            local x, y = Ardent:getPosition()
            Ardent:setPosition(-70000.0, y)
        end
        if Ardent ~= nil and Ardent:isValid() then
            local x, y = Ardent:getPosition()
            Ardent:setPosition(x, -10000.0)
        end
        temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Deploy the first relay in your current grid of E1.")
    end
    if ifInsideBox(Ardent, -60000.0, -20000.0, -80000.0, 0.0) and 0 and (Relay_6 == nil or not Relay_6:isValid()) and variable_areaone == (2.0) then
        if button_relay ~= 1 then
            Ardent:addCustomButton("relayOfficer", "relay_button", "Deploy subspace relay", function()
                Relay_6 = CpuShip():setTemplate("Tug"):setCallSign("Relay 6"):setFaction("Independent"):setPosition(-70000.0, -10000.0):orderRoaming()
                tmp_x, tmp_y = Ardent:getPosition()
                tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 180.000000, 100.000000)
                Relay_6:setPosition(x, y);
                temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Deploy another relay in grid D2.")
                --WARNING: Ignore <set_ship_text> {'class': 'Relay', 'name': 'Relay 6', 'desc': 'A subspace signal relay.'}
                if Relay_6 ~= nil and Relay_6:isValid() then
                --WARNING: Ignore <set_object_property> {'property': 'pitch', 'name': 'Relay 6', 'value': '5.0'}
                end
                Ardent:addCustomMessage("scienceOfficer", "warning", "Relay operational.")
                Ardent:removeCustom("relay_button")
                button_relay = 0
            end)
            button_relay = 1
        end
    end
    if ifInsideBox(Ardent, -40000.0, -40000.0, -60000.0, -20000.0) and 0 and (Relay_7 == nil or not Relay_7:isValid()) and variable_areaone == (2.0) and (Relay_6 ~= nil and Relay_6:isValid()) then
        if button_relay ~= 1 then
            Ardent:addCustomButton("relayOfficer", "relay_button", "Deploy subspace relay", function()
                Relay_7 = CpuShip():setTemplate("Tug"):setCallSign("Relay 7"):setFaction("Independent"):setPosition(-70000.0, -10000.0):orderRoaming()
                tmp_x, tmp_y = Ardent:getPosition()
                tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 180.000000, 100.000000)
                Relay_7:setPosition(x, y);
                temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Deploy another relay in grid C3.")
                --WARNING: Ignore <set_ship_text> {'class': 'Relay', 'name': 'Relay 7', 'desc': 'A subspace signal relay.'}
                if Relay_7 ~= nil and Relay_7:isValid() then
                --WARNING: Ignore <set_object_property> {'property': 'pitch', 'name': 'Relay 7', 'value': '5.0'}
                end
                Ardent:addCustomMessage("scienceOfficer", "warning", "Relay operational.")
                Ardent:removeCustom("relay_button")
                button_relay = 0
            end)
            button_relay = 1
        end
    end
    if ifInsideBox(Ardent, -20000.0, -60000.0, -40000.0, -40000.0) and 0 and (Relay_8 == nil or not Relay_8:isValid()) and variable_areaone == (2.0) and (Relay_6 ~= nil and Relay_6:isValid()) and (Relay_7 ~= nil and Relay_7:isValid()) then
        if button_relay ~= 1 then
            Ardent:addCustomButton("relayOfficer", "relay_button", "Deploy subspace relay", function()
                Relay_8 = CpuShip():setTemplate("Tug"):setCallSign("Relay 8"):setFaction("Independent"):setPosition(-70000.0, -10000.0):orderRoaming()
                tmp_x, tmp_y = Ardent:getPosition()
                tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 180.000000, 100.000000)
                Relay_8:setPosition(x, y);
                temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Deploy another relay in grid B3.")
                --WARNING: Ignore <set_ship_text> {'class': 'Relay', 'name': 'Relay 8', 'desc': 'A subspace signal relay.'}
                if Relay_8 ~= nil and Relay_8:isValid() then
                --WARNING: Ignore <set_object_property> {'property': 'pitch', 'name': 'Relay 8', 'value': '5.0'}
                end
                Ardent:addCustomMessage("scienceOfficer", "warning", "Relay operational.")
                Ardent:removeCustom("relay_button")
                button_relay = 0
            end)
            button_relay = 1
        end
    end
    if ifInsideBox(Ardent, -20000.0, -80000.0, -40000.0, -60000.0) and 0 and (Relay_9 == nil or not Relay_9:isValid()) and variable_areaone == (2.0) and (Relay_6 ~= nil and Relay_6:isValid()) and (Relay_7 ~= nil and Relay_7:isValid()) and (Relay_8 ~= nil and Relay_8:isValid()) then
        if button_relay ~= 1 then
            Ardent:addCustomButton("relayOfficer", "relay_button", "Deploy subspace relay", function()
                Relay_9 = CpuShip():setTemplate("Tug"):setCallSign("Relay 9"):setFaction("Independent"):setPosition(-70000.0, -10000.0):orderRoaming()
                tmp_x, tmp_y = Ardent:getPosition()
                tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 180.000000, 100.000000)
                Relay_9:setPosition(x, y);
                temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Deploy another relay in grid A3.")
                --WARNING: Ignore <set_ship_text> {'class': 'Relay', 'name': 'Relay 9', 'desc': 'A subspace signal relay.'}
                if Relay_9 ~= nil and Relay_9:isValid() then
                --WARNING: Ignore <set_object_property> {'property': 'pitch', 'name': 'Relay 9', 'value': '5.0'}
                end
                Ardent:addCustomMessage("scienceOfficer", "warning", "Relay operational.")
                Ardent:removeCustom("relay_button")
                button_relay = 0
            end)
            button_relay = 1
        end
    end
    if ifInsideBox(Ardent, -20000.0, -100000.0, -40000.0, -80000.0) and 0 and (Relay_5 == nil or not Relay_5:isValid()) and variable_areaone == (2.0) and (Relay_6 ~= nil and Relay_6:isValid()) and (Relay_7 ~= nil and Relay_7:isValid()) and (Relay_8 ~= nil and Relay_8:isValid()) and (Relay_9 ~= nil and Relay_9:isValid()) then
        if button_relay ~= 1 then
            Ardent:addCustomButton("relayOfficer", "relay_button", "Deploy subspace relay", function()
                Relay_10 = CpuShip():setTemplate("Tug"):setCallSign("Relay 10"):setFaction("Independent"):setPosition(-70000.0, -10000.0):orderRoaming()
                tmp_x, tmp_y = Ardent:getPosition()
                tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 180.000000, 100.000000)
                Relay_10:setPosition(x, y);
                Trader_5:setCallSign("Trader 5"):sendCommsMessage(getPlayerShip(-1), "We are under attack! We need immediate assistance!")
                temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Defend the trader from the pirates.")
                --WARNING: Ignore <set_ship_text> {'class': 'Relay', 'name': 'Relay 10', 'desc': 'A subspace signal relay.'}
                if Relay_10 ~= nil and Relay_10:isValid() then
                --WARNING: Ignore <set_object_property> {'property': 'pitch', 'name': 'Relay 10', 'value': '5.0'}
                end
                variable_twobadguys = 1.0
                SK01 = CpuShip():setTemplate("Cruiser"):setCallSign("SK01"):setFaction("Kraylor"):setPosition(4000.0, -45000.0):orderAttack(Trader_5)
                if fleet[1] == nil then fleet[1] = {} end
                table.insert(fleet[1], SK01)
                if fleet[0] == nil then fleet[0] = {} end
                table.insert(fleet[0], SK01)
                SK02 = CpuShip():setTemplate("Cruiser"):setCallSign("SK02"):setFaction("Kraylor"):setPosition(4000.0, -44900.0):orderAttack(Trader_5)
                table.insert(fleet[1], SK02)
                table.insert(fleet[0], SK02)
                SK03 = CpuShip():setTemplate("Cruiser"):setCallSign("SK03"):setFaction("Kraylor"):setPosition(4000.0, -44800.0):orderAttack(Trader_5)
                table.insert(fleet[1], SK03)
                table.insert(fleet[0], SK03)
                --WARNING: Ignore <set_ship_text> {'race': 'Pirate', 'name': 'SK01'}
                --WARNING: Ignore <set_ship_text> {'race': 'Pirate', 'name': 'SK02'}
                --WARNING: Ignore <set_ship_text> {'race': 'Pirate', 'name': 'SK03'}
                Ardent:addCustomMessage("scienceOfficer", "warning", "Relay operational.")
                Ardent:removeCustom("relay_button")
                button_relay = 0
            end)
            button_relay = 1
        end
    end
    if variable_twobadguys == (1.0) and (SK01 ~= nil and Ardent ~= nil and SK01:isValid() and Ardent:isValid() and distance(SK01, Ardent) < 40000.000000) and variable_twosecondwave ~= (1.0) then
        variable_twosecondwave = 1.0
        SK04 = CpuShip():setTemplate("Cruiser"):setCallSign("SK04"):setFaction("Kraylor"):setPosition(19000.0, -50000.0):orderAttack(Trader_5)
        if fleet[2] == nil then fleet[2] = {} end
        table.insert(fleet[2], SK04)
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], SK04)
        SK05 = CpuShip():setTemplate("Cruiser"):setCallSign("SK05"):setFaction("Kraylor"):setPosition(19000.0, -51900.0):orderAttack(Trader_5)
        table.insert(fleet[2], SK05)
        table.insert(fleet[0], SK05)
    end
    if variable_twosecondwave == (1.0) and countFleet(1) == 0.000000 and countFleet(2) == 0.000000 and variable_twosecured ~= (1.0) then
        temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Once relay 6 to 10 are deployed in this sector go to grid A3 to go to the next one.")
        variable_twosecured = 1.0
    end
    if variable_twosecured == (1.0) and variable_areaone == (2.0) and ifInsideBox(Ardent, -20000.0, -100000.0, -40000.0, -80000.0) and (Relay_6 ~= nil and Relay_6:isValid()) and (Relay_7 ~= nil and Relay_7:isValid()) and (Relay_8 ~= nil and Relay_8:isValid()) and (Relay_9 ~= nil and Relay_9:isValid()) and (Relay_10 ~= nil and Relay_10:isValid()) then
        variable_areaone = 3.0
    end
    if variable_areaone == (3.0) and variable_threemake ~= (1.0) then
        variable_threemake = 1.0
        for _, obj in ipairs(getObjectsInRadius(-30000.0, -50000.0, 100000.000000)) do
            if obj.typeName == "Nebula" then obj:destroy() end
        end
        if AN01 ~= nil and AN01:isValid() then AN01:destroy() end
        if AN02 ~= nil and AN02:isValid() then AN02:destroy() end
        if AN03 ~= nil and AN03:isValid() then AN03:destroy() end
        if AN04 ~= nil and AN04:isValid() then AN04:destroy() end
        if Relay_6 ~= nil and Relay_6:isValid() then Relay_6:destroy() end
        if Relay_7 ~= nil and Relay_7:isValid() then Relay_7:destroy() end
        if Relay_8 ~= nil and Relay_8:isValid() then Relay_8:destroy() end
        if Relay_9 ~= nil and Relay_9:isValid() then Relay_9:destroy() end
        if Relay_10 ~= nil and Relay_10:isValid() then Relay_10:destroy() end
        if Trader_5 ~= nil and Trader_5:isValid() then Trader_5:destroy() end
        tmp_count = 4
        for tmp_counter=1,tmp_count do
            tmp_x, tmp_y = vectorFromAngle(-90.0 + (270.0 - -90.0) * (tmp_counter - 1) / tmp_count, 25000.0)
            tmp_x, tmp_y = tmp_x + -30000.0, tmp_y + -50000.0
            tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 22500.0))
            tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
            Nebula():setPosition(tmp_x, tmp_y)
        end
        AN01 = SupplyDrop():setFaction("Human Navy"):setPosition(10186.0, -21958.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        AN02 = SupplyDrop():setFaction("Human Navy"):setPosition(-37495.0, -16305.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        AN03 = SupplyDrop():setFaction("Human Navy"):setPosition(-69068.0, -68616.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        AN04 = SupplyDrop():setFaction("Human Navy"):setPosition(-73986.0, -18134.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        AN05 = SupplyDrop():setFaction("Human Navy"):setPosition(-51332.0, -47364.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
        if Ardent ~= nil and Ardent:isValid() then
            local x, y = Ardent:getPosition()
            Ardent:setPosition(-30000.0, y)
        end
        if Ardent ~= nil and Ardent:isValid() then
            local x, y = Ardent:getPosition()
            Ardent:setPosition(x, -10000.0)
        end
        temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Deploy the first relay in your current grid of E3.")
        timers["piratebaselag"] = 5.000000
    end
    if ifInsideBox(Ardent, -20000.0, -20000.0, -40000.0, 0.0) and 0 and (Relay_11 == nil or not Relay_11:isValid()) and variable_areaone == (3.0) then
        if button_relay ~= 1 then
            Ardent:addCustomButton("relayOfficer", "relay_button", "Deploy subspace relay", function() 
                Relay_11 = CpuShip():setTemplate("Tug"):setCallSign("Relay 11"):setFaction("Independent"):setPosition(-70000.0, -10000.0):orderRoaming()
                tmp_x, tmp_y = Ardent:getPosition()
                tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 180.000000, 100.000000)
                Relay_11:setPosition(x, y);
                temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Deploy another relay in grid D3.")
                --WARNING: Ignore <set_ship_text> {'class': 'Relay', 'name': 'Relay 11', 'desc': 'A subspace signal relay.'} 
                if Relay_11 ~= nil and Relay_11:isValid() then
                --WARNING: Ignore <set_object_property> {'property': 'pitch', 'name': 'Relay 11', 'value': '5.0'} 
                end
                Ardent:addCustomMessage("scienceOfficer", "warning", "Relay operational.")
                Ardent:removeCustom("relay_button")
                button_relay = 0
            end)
            button_relay = 1
        end 
    end
    if ifInsideBox(Ardent, -20000.0, -40000.0, -40000.0, -20000.0) and 0 and (Relay_12 == nil or not Relay_12:isValid()) and variable_areaone == (3.0) and (Relay_11 ~= nil and Relay_11:isValid()) then
        if button_relay ~= 1 then
            Ardent:addCustomButton("relayOfficer", "relay_button", "Deploy subspace relay", function() 
                Relay_12 = CpuShip():setTemplate("Tug"):setCallSign("Relay 12"):setFaction("Independent"):setPosition(-70000.0, -10000.0):orderRoaming()
                tmp_x, tmp_y = Ardent:getPosition()
                tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 180.000000, 100.000000)
                Relay_12:setPosition(x, y);
                temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Deploy another relay in grid C3.")
                --WARNING: Ignore <set_ship_text> {'class': 'Relay', 'name': 'Relay 12', 'desc': 'A subspace signal relay.'} 
                if Relay_12 ~= nil and Relay_12:isValid() then
                --WARNING: Ignore <set_object_property> {'property': 'pitch', 'name': 'Relay 12', 'value': '5.0'} 
                end
                Ardent:addCustomMessage("scienceOfficer", "warning", "Relay operational.")
                Ardent:removeCustom("relay_button")
                button_relay = 0
            end)
            button_relay = 1
        end
    end
    if ifInsideBox(Ardent, -20000.0, -60000.0, -40000.0, -40000.0) and 0 and (Relay_13 == nil or not Relay_13:isValid()) and variable_areaone == (3.0) and (Relay_11 ~= nil and Relay_11:isValid()) and (Relay_12 ~= nil and Relay_12:isValid()) then
        if button_relay ~= 1 then
            Ardent:addCustomButton("relayOfficer", "relay_button", "Deploy subspace relay", function() 
                Relay_13 = CpuShip():setTemplate("Tug"):setCallSign("Relay 13"):setFaction("Independent"):setPosition(-70000.0, -10000.0):orderRoaming()
                tmp_x, tmp_y = Ardent:getPosition()
                tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 180.000000, 100.000000)
                Relay_13:setPosition(x, y);
                temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "Deploy another relay in grid B3.")
                --WARNING: Ignore <set_ship_text> {'class': 'Relay', 'name': 'Relay 13', 'desc': 'A subspace signal relay.'} 
                if Relay_13 ~= nil and Relay_13:isValid() then
                --WARNING: Ignore <set_object_property> {'property': 'pitch', 'name': 'Relay 13', 'value': '5.0'} 
                end
                Ardent:addCustomMessage("scienceOfficer", "warning", "Relay operational.")
                Ardent:removeCustom("relay_button")
                button_relay = 0
            end)
            button_relay = 1
        end 
    end
    if ifInsideBox(Ardent, 20000.0, -100000.0, -80000.0, -60000.0) and variable_areaone == (3.0) and (timers["piratebaselag"] ~= nil and timers["piratebaselag"] < 0.0) and variable_threebadguys ~= (1.0) then
        variable_threebadguys = 1.0
        Pirate_Station = CpuShip():setTemplate("Cruiser"):setCallSign("Pirate Station"):setFaction("Kraylor"):setPosition(-33500.0, -78000.0):orderRoaming()
        if fleet[1] == nil then fleet[1] = {} end
        table.insert(fleet[1], Pirate_Station)
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], Pirate_Station)
        temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "That station is the Fortuna Pirate\'s base of operations. New orders, take it down!")
        --WARNING: Ignore <set_ship_text> {'race': 'Pirate', 'name': 'Pirate Station', 'desc': "This station is the pirate's base of operations within the Fortuna Expanse."} 
        SK11 = CpuShip():setTemplate("Cruiser"):setCallSign("SK11"):setFaction("Kraylor"):setPosition(-34000.0, -79000.0):orderRoaming()
        if fleet[2] == nil then fleet[2] = {} end
        table.insert(fleet[2], SK11)
        table.insert(fleet[0], SK11)
        SK12 = CpuShip():setTemplate("Cruiser"):setCallSign("SK12"):setFaction("Kraylor"):setPosition(-34000.0, -79000.0):orderRoaming()
        table.insert(fleet[2], SK12)
        table.insert(fleet[0], SK12)
        --WARNING: Ignore <set_ship_text> {'race': 'Pirate', 'name': 'SK11'} 
        --WARNING: Ignore <set_ship_text> {'race': 'Pirate', 'name': 'SK12'} 
        --WARNING: Ignore <set_ship_text> {'race': 'Pirate', 'name': 'SK03'} 
        SK24 = CpuShip():setTemplate("Cruiser"):setCallSign("SK24"):setFaction("Kraylor"):setPosition(-33000.0, -79000.0):orderRoaming()
        if fleet[3] == nil then fleet[3] = {} end
        table.insert(fleet[3], SK24)
        table.insert(fleet[0], SK24)
        SK25 = CpuShip():setTemplate("Cruiser"):setCallSign("SK25"):setFaction("Kraylor"):setPosition(-33000.0, -78900.0):orderRoaming()
        table.insert(fleet[3], SK25)
        table.insert(fleet[0], SK25)
        --WARNING: Ignore <set_ship_text> {'race': 'Pirate', 'name': 'SK24'} 
        --WARNING: Ignore <set_ship_text> {'race': 'Pirate', 'name': 'SK25'} 
        --WARNING: Ignore <set_ship_text> {'race': 'Pirate', 'name': 'SK06'} 
        SK07 = CpuShip():setTemplate("Cruiser"):setCallSign("SK07"):setFaction("Kraylor"):setPosition(-33500.0, -80000.0):orderRoaming()
        if fleet[4] == nil then fleet[4] = {} end
        table.insert(fleet[4], SK07)
        table.insert(fleet[0], SK07)
        SK08 = CpuShip():setTemplate("Cruiser"):setCallSign("SK08"):setFaction("Kraylor"):setPosition(-33500.0, -80000.0):orderRoaming()
        table.insert(fleet[4], SK08)
        table.insert(fleet[0], SK08)
        --WARNING: Ignore <set_ship_text> {'race': 'Pirate', 'name': 'SK07'} 
        --WARNING: Ignore <set_ship_text> {'race': 'Pirate', 'name': 'SK08'} 
        --WARNING: Ignore <set_ship_text> {'race': 'Pirate', 'name': 'SK09'} 
        SK06:orderAttack(Ardent)
        SK07:orderAttack(Ardent)
        SK24:orderAttack(Ardent)
        SK25:orderAttack(Ardent)
        SK12:orderAttack(Ardent)
        --SK13:orderAttack(Ardent)
        SK11:orderAttack(Ardent)
        SK08:orderAttack(Ardent)
        SK09:orderAttack(Ardent)
    end
    if variable_threebadguys == (1.0) and (SK11 == nil or not SK11:isValid()) then
        if SK12 ~= nil and SK12:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'hasSurrendered', 'name': 'SK02', 'value': '1'} 
        end
        if SK13 ~= nil and SK13:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'hasSurrendered', 'name': 'SK03', 'value': '1'} 
        end
    end
    if variable_threebadguys == (1.0) and (SK24 == nil or not SK24:isValid()) then
        if SK25 ~= nil and SK25:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'hasSurrendered', 'name': 'SK05', 'value': '1'} 
        end
        if SK26 ~= nil and SK26:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'hasSurrendered', 'name': 'SK06', 'value': '1'} 
        end
    end
    if variable_threebadguys == (1.0) and (SK07 == nil or not SK07:isValid()) then
        if SK08 ~= nil and SK08:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'hasSurrendered', 'name': 'SK08', 'value': '1'} 
        end
        if SK09 ~= nil and SK09:isValid() then
        --WARNING: Ignore <set_object_property> {'property': 'hasSurrendered', 'name': 'SK09', 'value': '1'} 
        end
    end
    if variable_threebadguys == (1.0) and countFleet(1) == 0.000000 and countFleet(2) == 0.000000 and countFleet(3) == 0.000000 and countFleet(4) == 0.000000 and variable_threesecured ~= (1.0) then
        temp_transmission_object:setCallSign("TSN Command"):sendCommsMessage(getPlayerShip(-1), "You dealt a decisive blow to the Fortuna Pirates greater than the relays ever could. Great work Ardent.")
        variable_threesecured = 1.0
        globalMessage("Mission Completed\nThank you for playing.\n");
        timers["endgame"] = 15.000000
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
