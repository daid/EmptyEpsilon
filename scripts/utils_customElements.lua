-- Name: utils_customElements
-- Description: Wrapper upon different stations, so mission author can add button/information to station Operator, 
--- abstracting the position through which the operator fulfills his duties. 
--- This module should remove multiple boilerplate to accomodate 6/5 and 4/3 station categories. 
--- Operator in context of this module means player fulfilling specific duties aboard the ship
--- (for example Engineer can use "Engineering" or "Engineering+"). 

--- Module API description: 
--- * customElements:modifyOperatorPositions(operator_key, position_list) = Modify ECrewPositions for specified station
--- * customElements:closeAllMessagesUponClose(boolean_value) = change closing behavior
--- * customElements:addCustomButton(player_ship, operator, name, caption, callback) = wrapper around PlayerSpaceship:addCustomButton
--- * customElements:addCustomInfo(player_ship, operator, name, caption) = wrapper around PlayerSpaceship:addCustomInfo
--- * customElements:addCustomMessage(player_ship, operator, name, caption) = wrapper around PlayerSpaceship:addCustomMessage
--- * customElements:addCustomMessageWithCallback(player_ship, operator, name, caption, callback) = wrapper around PlayerSpaceship:addCustomMessageWithCallback
--- * customElements:removeCustom(player_ship, name) = wrapper around PlayerSpaceship:removeCustom

--- Functions that might be interesting in specific use-cases:
--- * customElements:operatorPositions(operator_key)
--- * customElements:printOperatorPositions(operator_key)

-- TODO list:
--- * When addCustomMessage is called, it is shown on all positions. Think about adding as addCustomMessageWithCallback where callback will close all messages of the same name.

-- Create Button Wrapper module with default Operator positions
customElements = {
    -- Not assinged ECrewPositions: "DamageControl", "PowerManagement", "Database", "CommsOnly", "ShipLog"
    operators = {
        ["Helms"]={"Helms", "Tactical", "Single"}, 
        ["Weapons"]={"Weapons", "Tactical", "Single"}, 
        ["Engineering"]={"Engineering", "Engineering+"}, 
        ["Science"]={"Science", "Operations"},
        ["Relay"]={"Relay", "Operations", "AltRelay"}
    },
    close_all_messages_upon_close = true   -- When enabled, it will close customMessage or customMessageWithCallback on all stations when clicked on Close.
}

-- -------------------------------------------------------------
-- Public API for the whole module
-- -------------------------------------------------------------

-- Modify Operator position list
-- @param operator_key: String identification of operator (new or existing)
-- @param position_list: Table (list) of ECrewPositions strings to be assigned to this operator
function customElements:modifyOperatorPositions(operator_key, position_list)
    self.operators[operator_key] = position_list
end

function customElements:closeAllMessagesUponClose(value)
    local boolVal = nil
    if value then
        boolVal = true
    else
        boolVal = false
    end
    self.close_all_messages_upon_close = boolVal
end

-- Get Operator position list
-- @param operator_key: String identification of existing operator
-- @returns: Table (list) of ECrewPositions strings for this operator (or empty table if operator does not exists)
function customElements:operatorPositions(operator_key)
    if self.operators[operator_key] ~= nil then
        return self.operators[operator_key]
    end
    return {}
end

-- -------------------------------------------------------------
-- Wrapped functions for work with Custom elements
-- -------------------------------------------------------------

-- Add custom button to all stations for specified operator.
-- @param player_ship: Player ship to which you want to add a custom button
-- @param operator: String identification of operator. 
-- @param name: String identifier of the button (parameter of PlayerShip:addCustomButton)
-- @param caption: Label of the button (parameter of PlayerShip:addCustomButton)
-- @param callback: Callback function to be run when button is pressed (parameter of PlayerShip:addCustomButton)
function customElements:addCustomButton(player_ship, operator, name, caption, callback)
    for _, station in ipairs(self:operatorPositions(operator)) do
        player_ship:addCustomButton(station, name..station, caption, callback)
    end
end

-- Add custom info to all stations for specified operator:
-- @param player_ship: Player ship to which you want to add a custom information field.
-- @param operator: String identification of operator. 
-- @param name: String identifier of the message (parameter of PlayerShip:addCustomInfo)
-- @param caption: Text content of the info field (parameter of PlayerShip:addCustomInfo)
function customElements:addCustomInfo(player_ship, operator, name, caption)
    for _, station in ipairs(self:operatorPositions(operator)) do
        player_ship:addCustomInfo(station, name..station, caption)
    end
end

-- Add custom message to all stations for specified operator.
-- @param player_ship: Player ship to which you want to add a custom message
-- @param operator: String identification of operator. 
-- @param name: String identifier of the message (parameter of PlayerShip:addCustomMessage)
-- @param caption: Text of the message (parameter of PlayerShip:addCustomMessage)
function customElements:addCustomMessage(player_ship, operator, name, caption)
    for _, station in ipairs(self:operatorPositions(operator)) do
        if self.close_all_messages_upon_close then
            player_ship:addCustomMessageWithCallback(station, name..station, caption, function()
                customElements:removeCustom(player_ship, name)
            end)
        else
            player_ship:addCustomMessage(station, name..station, caption)
        end
    end
end

-- Add custom message with callback to all stations for specified operator.
-- @param player_ship: Player ship to which you want to add a custom message
-- @param operator: String identification of operator. 
-- @param name: String identifier of the message (parameter of PlayerShip:addCustomMessageWithCallback)
-- @param caption: Text of the message (parameter of PlayerShip:addCustomMessageWithCallback)
-- @param callback: Callback function to be run when message is closed (parameter of PlayerShip:addCustomMessageWithCallback)
function customElements:addCustomMessageWithCallback(player_ship, operator, name, caption, callback)
    for _, station in ipairs(self:operatorPositions(operator)) do
        if self.close_all_messages_upon_close then
            player_ship:addCustomMessageWithCallback(station, name..station, caption, function()
                customElements:removeCustom(player_ship, name)
                callback()
            end)
        else
            player_ship:addCustomMessageWithCallback(station, name..station, caption, callback)
        end
    end
end

-- Remove custom element from all stations
-- @param player_ship: Player ship from which you want to remove a custom element
-- @param name: String identifier of the element to be removed.
function customElements:removeCustom(player_ship, name)
    local crew_positions = {"Helms", "Weapons", "Engineering", "Science", "Relay", "Tactical", 
                            "Engineering+", "Operations", "Single", "DamageControl", "PowerManagement", 
                            "Database", "AltRelay", "CommsOnly", "ShipLog"}
    for _, station in ipairs(crew_positions) do
        player_ship:removeCustom(name..station)
    end
end

-- -------------------------------------------------------------
-- Debugging / specific use-case functions
-- -------------------------------------------------------------

-- Debugging function which prints ECrewPositions strings for selected operator
-- @param operator_key: String identification of existing operator
function customElements:printOperatorPositions(operator_key)
    print("Stations for "..operator_key..": ")
    for _, station in ipairs(self:operatorPositions(operator_key)) do
        print (station)
    end
    print("=====")
end

--[[
This code can be used to test modification of Operator positions list:

customElements:modifyOperatorPositions("Test", {"Helms", "Tactical", "Single", "Weapons",  "Engineering"})
customElements:printOperatorPositions("Helms")
customElements:printOperatorPositions("Test")
--]]
