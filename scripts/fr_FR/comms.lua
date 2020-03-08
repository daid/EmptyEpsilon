-- general communication sentences used in multiple files
function commonComms_opening(sender, receiver)
    return receiver .. " this is " .. sender .. "!"
end

function commonComms_closing(sender, receiver)
    return sender .. " over !"
end

commonComms_back = "Back"

-- comms_station.lua
--- shorts
reputationEachShort = "rep each"
reputationShort = "rep"
waypointShort = "WP"

--- generals
stationComms_prematureUndocking = "You need to stay docked for that action."

--- greetings
stationComms_dockedFriendlyGreetings = "Good day, officer!\nWhat can we do for you today?"
stationComms_dockedNeutralGreetings = "Welcome to our lovely station."
stationComms_undockedFriendlyGreetings = "Good day, officer.\nIf you need supplies, please dock with us first."
stationComms_undockedNeutralGreetings = "Greetings.\nIf you want to do business, please dock with us first."
stationComms_underAttackGreetings = "We are under attack! No time for chatting!"

--- weapons trade
stationComms_askForHoming = "Do you have spare homing missiles for us?"
stationComms_askForHVLI = "Can you restock us with HVLI?"
stationComms_askForMines = "Please re-stock our mines."
stationComms_askForNukes = "Can you supply us with some nukes?"
stationComms_askForEMP = "Please re-stock our EMP missiles."

stationComms_noNukes = "We do not deal in weapons of mass destruction."
stationComms_noEMP = "We do not deal in weapons of mass disruption."
stationComms_noOther = "We do not deal in those weapons."

stationComms_nukesRefilled = "All nukes are charged and primed for destruction."
stationComms_otherFull = "You are fully loaded and ready to explode things."
stationComms_alreadyFull = "Sorry, sir, but you are as fully stocked as I can allow."
stationComms_notEnoughReputation = "Not enough reputation."
stationComms_generouslyRefilled = "We generously resupplied you with some weapon charges.\nPut them to good use."

--- help requesting
stationComms_requireSupplyDrop = "Can you send a supply drop?"
stationComms_waypointRequiredForSupply = "You need to set a waypoint before you can request backup."
stationComms_suppliesWaypoint = "To which waypoint should we deliver your supplies?"

stationComms_requireBackup = "Please send reinforcements!"
stationComms_waypointRequiredForBackup = "You need to set a waypoint before you can request reinforcements."
stationComms_backupWaypoint = "To which waypoint should we dispatch the reinforcements?"

function stationComms_supplyDispatched(waypoint)
    return "We have dispatched a supply ship toward" .. waypointShort .. waypoint
end

function stationComms_backupDispatched(shipCallSign, waypoint)
    return "We have dispatched " .. shipCallSign .. " to assist at " .. waypointShort .. waypoint
end

-- comms_ship.lua
--- greetings
shipComms_friendlyGreetings = "Sir, how can we assist?"
shipComms_neutralGreetings = "What do you want?"

--- help requesting
shipComms_requireWaypointProtection = "Defend a waypoint"
shipComms_waypointRequiredForProtection = "No waypoints set. Please set a waypoint first."
shipComms_protectedWaypoint = "Which waypoint should we defend?"
shipComms_assistMe = "Assist me"
shipComms_headingTowardsYou = "Heading toward you to assist."
shipComms_reportStatus = "Report status"

function shipComms_headingToWaypoint(waypoint)
    return "We are heading to assist at WP" .. waypoint .."."
end

--- status
shipComms_hull = "Hull"
shipComms_shield = "Shield"
shipComms_frontShield = "Front Shield"
shipComms_rearShield = "Rear Shield"

shipComms_homings = "Homing Missiles"
shipComms_nukes = "Nukes"
shipComms_mines = "Mines"
shipComms_emp = emp
shipComms_hvli = hvli

function shipComms_dockAt(callSign)
    return "Dock at " .. callSign
end

function shipComms_dockingAt(callSign)
    return "Docking at " .. callSign
end

--- enemy comms
shipComms_defaultTaunt = "We will see to your destruction!"
shipComms_defaultTauntSuccess = "Your bloodline will end here!"
shipComms_defaultTauntFail = "Your feeble threats are meaningless."
shipComms_kraylor = "Ktzzzsss.\nYou will DIEEee weaklingsss!"
shipComms_arlenians = "We wish you no harm, but will harm you if we must.\nEnd of transmission."
shipComms_exuari = "Stay out of our way, or your death will amuse us extremely!"
shipComms_ghosts = "One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted."
shipComms_ghostsTaunt = "EXECUTE: SELFDESTRUCT"
shipComms_ghostsTauntSuccess = "Rogue command received. Targeting source."
shipComms_ghostsTauntFail = "External command ignored."
shipComms_ktlitans = "The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition."
shipComms_ktlitansTaunt = "<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>"
shipComms_ktlitansTauntSuccess = "We do not need permission to pluck apart such an insignificant threat."
shipComms_ktlitansTauntFail = "The hive has greater priorities than exterminating pests."
shipComms_mindYourBusiness = "Mind your own business!"

--- neutral comms
shipComms_friendlyDismiss = "Sorry, we have no time to chat with you.\nWe are on an important mission."
shipComms_neutralDismiss = "We have nothing for you.\nGood day."

-- comms_supply_drop.lua
shipComms_transportingGoods = "Transporting goods."