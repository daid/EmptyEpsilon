--- Comms with stations for scenario 03.
--
-- @script comms_station_scenario_03_central_command
-- TODO

function commsStationMainMenu()
    if comms_target.comms_data == nil then
        comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
    end
    comms_data = comms_target.comms_data

    if comms_source:isEnemy(comms_target) then
        return false
    end

    if comms_source:isFriendly(comms_target) then
        -----------------------------------------------
        -- Edge of space additions
        if comms_target:getCallSign() == "Central Command" and not comms_source:isDocked(comms_target) then
            if comms_target.mission_state == 1 then
                setCommsMessage("The E.O.S Scope is in sector H8, right on the edge of Kraylor territory.\n \nBe careful out there")
                return true
            end

            if comms_target.mission_state == 2 then
                setCommsMessage("Return to Central Command with your report on the malfunction.")
                return true
            end

            if comms_target.mission_state == 3 then
                setCommsMessage("The Arlenian science station Galileo is in sector C5. Lay in a course bearing 356 from Central Command and deliver the E.O.S Scope data there.")
                return true
            end

            if comms_target.mission_state == 4 then
                setCommsMessage("Save the Galileo station! They're under attack in sector C5, and we need them to analyze that data!")
                return true
            end

            if comms_target.mission_state == 5 then
                setCommsMessage("Dock with Galileo in sector C5 and deliver the E.O.S Scope data.")
                return true
            end

            if comms_target.mission_state == 6 then
                setCommsMessage("Kraylor ships are attacking E.O.S Scope directly! Get down there quick as possible and help it!\n \nIf you need more assistance request it from Midspace Support.")
                return true
            end

            if comms_target.mission_state == 7 then
                setCommsMessage("We've declared war on the Kraylor. Retaliate on their defenseless Endline station!")
                return true
            end

            if comms_target.mission_state == 8 then
                setCommsMessage("Destroy the remaining Kraylor ships threatening our E.O.S Scope!")
                return true
            end

            if comms_target.mission_state == 9 then
                setCommsMessage("Dock at the E.O.S Scope to be refitted for war and standby for orders.")
                return true
            end

            if comms_target.mission_state == 10 then
                setCommsMessage("The Kraylor Super-nebula is hiding a wormhole which we believe is going to be used in an attack on Human space. There is an entrance into the nebula in sector F10, but be careful of traps!")
                return true
            end
        end
        -----------------------------------------------

        if comms_target:areEnemiesInRange(5000) then
            setCommsMessage("We are under attack! No time for chatting!")
            return true
        end
        if not comms_source:isDocked(comms_target) then
            setCommsMessage("Good day officer,\nIf you need supplies please dock with us first.")
            addCommsReply(
                "Can you send a supply drop? (100rep)",
                function()
                    if comms_source:getWaypointCount() < 1 then
                        setCommsMessage("You need to set a waypoint before you can request backup.")
                    else
                        setCommsMessage("Where do we need to drop off your supplies?")
                        for n = 1, comms_source:getWaypointCount() do
                            addCommsReply(
                                "WP" .. n,
                                function()
                                    if comms_source:takeReputationPoints(100) then
                                        local position_x, position_y = comms_target:getPosition()
                                        local target_x, target_y = comms_source:getWaypoint(n)
                                        local script = Script()
                                        script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                                        script:setVariable("target_x", target_x):setVariable("target_y", target_y)
                                        script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
                                        setCommsMessage("We have dispatched a supply ship towards WP" .. n)
                                    else
                                        setCommsMessage("Not enough rep!")
                                    end
                                    addCommsReply("Back", commsStationMainMenu)
                                end
                            )
                        end
                    end
                    addCommsReply("Back", commsStationMainMenu)
                end
            )
            addCommsReply(
                "Please send backup! (150rep)",
                function()
                    if comms_source:getWaypointCount() < 1 then
                        setCommsMessage("You need to set a waypoint before you can request backup.")
                    else
                        setCommsMessage("Where does the backup needs to go?")
                        for n = 1, comms_source:getWaypointCount() do
                            addCommsReply(
                                "WP" .. n,
                                function()
                                    if comms_source:takeReputationPoints(150) then
                                        ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
                                        setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at WP" .. n)
                                    else
                                        setCommsMessage("Not enough rep!")
                                    end
                                    addCommsReply("Back", commsStationMainMenu)
                                end
                            )
                        end
                    end
                    addCommsReply("Back", commsStationMainMenu)
                end
            )
            return true
        end

        -- Friendly station, docked.
        setCommsMessage("Good day officer,\nWhat can we do for you today?")
        addCommsReply(
            "Do you have spare homing missiles for us? (2rep each)",
            function()
                if not comms_source:isDocked(comms_target) then
                    setCommsMessage("You need to stay docked for that action.")
                    return
                end
                if not comms_source:takeReputationPoints(2 * (comms_source:getWeaponStorageMax("Homing") - comms_source:getWeaponStorage("Homing"))) then
                    setCommsMessage("Not enough reputation.")
                    return
                end
                if comms_source:getWeaponStorage("Homing") >= comms_source:getWeaponStorageMax("Homing") then
                    setCommsMessage("Sorry sir, but you are fully stocked with homing missiles.")
                    addCommsReply("Back", commsStationMainMenu)
                else
                    comms_source:setWeaponStorage("Homing", comms_source:getWeaponStorageMax("Homing"))
                    setCommsMessage("Filled up your missile supply.")
                    addCommsReply("Back", commsStationMainMenu)
                end
            end
        )
        addCommsReply(
            "Please re-stock our mines. (2rep each)",
            function()
                if not comms_source:isDocked(comms_target) then
                    setCommsMessage("You need to stay docked for that action.")
                    return
                end
                if not comms_source:takeReputationPoints(2 * (comms_source:getWeaponStorageMax("Mine") - comms_source:getWeaponStorage("Mine"))) then
                    setCommsMessage("Not enough reputation.")
                    return
                end
                if comms_source:getWeaponStorage("Mine") >= comms_source:getWeaponStorageMax("Mine") then
                    setCommsMessage("Captain,\nYou have all the mines you can fit in that ship.")
                    addCommsReply("Back", commsStationMainMenu)
                else
                    comms_source:setWeaponStorage("Mine", comms_source:getWeaponStorageMax("Mine"))
                    setCommsMessage("These mines, are yours.")
                    addCommsReply("Back", commsStationMainMenu)
                end
            end
        )
        addCommsReply(
            "Can you supply us with some nukes. (15rep each)",
            function()
                if not comms_source:isDocked(comms_target) then
                    setCommsMessage("You need to stay docked for that action.")
                    return
                end
                if not comms_source:takeReputationPoints(15 * (comms_source:getWeaponStorageMax("Nuke") - comms_source:getWeaponStorage("Nuke"))) then
                    setCommsMessage("Not enough reputation.")
                    return
                end
                if comms_source:getWeaponStorage("Nuke") >= comms_source:getWeaponStorageMax("Nuke") then
                    setCommsMessage("All nukes are charged and primed for distruction.")
                    addCommsReply("Back", commsStationMainMenu)
                else
                    comms_source:setWeaponStorage("Nuke", comms_source:getWeaponStorageMax("Nuke"))
                    setCommsMessage("You are fully loaded,\nand ready to explode things.")
                    addCommsReply("Back", commsStationMainMenu)
                end
            end
        )
        addCommsReply(
            "Please re-stock our EMP Missiles. (10rep each)",
            function()
                if not comms_source:isDocked(comms_target) then
                    setCommsMessage("You need to stay docked for that action.")
                    return
                end
                if not comms_source:takeReputationPoints(10 * (comms_source:getWeaponStorageMax("EMP") - comms_source:getWeaponStorage("EMP"))) then
                    setCommsMessage("Not enough reputation.")
                    return
                end
                if comms_source:getWeaponStorage("EMP") >= comms_source:getWeaponStorageMax("EMP") then
                    setCommsMessage("All storage for EMP missiles is filled sir.")
                    addCommsReply("Back", commsStationMainMenu)
                else
                    comms_source:setWeaponStorage("EMP", comms_source:getWeaponStorageMax("EMP"))
                    setCommsMessage("Recallibrated the electronics and\nfitted you with all the EMP missiles you can carry.")
                    addCommsReply("Back", commsStationMainMenu)
                end
            end
        )
    else
        -- not friendly (and not enemy)

        if not comms_source:isDocked(comms_target) then
            setCommsMessage("Greetings sir.\nIf you want to do business please dock with us first.")
            return true
        end

        -- Neutral station, docked
        setCommsMessage("Welcome to our lovely station")
        addCommsReply(
            "Do you have spare homing missiles for us? (5rep each)",
            function()
                if not comms_source:isDocked(comms_target) then
                    setCommsMessage("You need to stay docked for that action.")
                    return
                end
                if comms_source:getWeaponStorage("Homing") >= comms_source:getWeaponStorageMax("Homing") / 2 then
                    setCommsMessage("You seem to have more then enough missiles")
                    addCommsReply("Back", commsStationMainMenu)
                else
                    if not comms_source:takeReputationPoints(5 * ((comms_source:getWeaponStorageMax("Homing") / 2) - comms_source:getWeaponStorage("Homing"))) then
                        setCommsMessage("Not enough reputation.")
                        return
                    end
                    comms_source:setWeaponStorage("Homing", comms_source:getWeaponStorageMax("Homing") / 2)
                    setCommsMessage("We generously resupplied you with some free homing missiles.\nPut them to good use.")
                    addCommsReply("Back", commsStationMainMenu)
                end
            end
        )
        addCommsReply(
            "Please re-stock our mines. (5rep each)",
            function()
                if not comms_source:isDocked(comms_target) then
                    setCommsMessage("You need to stay docked for that action.")
                    return
                end
                if comms_source:getWeaponStorage("Mine") >= comms_source:getWeaponStorageMax("Mine") then
                    setCommsMessage("You are fully stocked with mines.")
                    addCommsReply("Back", commsStationMainMenu)
                else
                    if not comms_source:takeReputationPoints(5 * (comms_source:getWeaponStorageMax("Mine") - comms_source:getWeaponStorage("Mine"))) then
                        setCommsMessage("Not enough reputation.")
                        return
                    end
                    comms_source:setWeaponStorage("Mine", comms_source:getWeaponStorageMax("Mine"))
                    setCommsMessage("Here, have some mines.\nMines are good defensive weapons.")
                    addCommsReply("Back", commsStationMainMenu)
                end
            end
        )
        addCommsReply(
            "Can you supply us with some nukes.",
            function()
                setCommsMessage("We do not deal in weapons of mass destruction.")
                addCommsReply("Back", commsStationMainMenu)
            end
        )
        addCommsReply(
            "Please re-stock our EMP Missiles.",
            function()
                setCommsMessage("We do not deal in weapons of mass disruption.")
                addCommsReply("Back", commsStationMainMenu)
            end
        )
    end
end

commsStationMainMenu()
