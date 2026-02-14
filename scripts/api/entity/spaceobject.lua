local Entity = getLuaEntityFunctionTable()

----- Entity base functions -----

--- Sets this entity's position on the map, in game units from the origin.
--- Example: entity:setPosition(x,y)
function Entity:setPosition(x, y)
    if self.components.transform then self.components.transform.position = {x, y} end
    return self
end
--- Returns this entity's position on the map, as X/Y coordinates in game units from the origin.
--- Example: x,y = entity:getPosition()
function Entity:getPosition()
    if self.components.transform then return table.unpack(self.components.transform.position) end
end
--- Sets this entity's absolute rotation, in degrees.
--- Unlike setHeading(), a value of 0 points to the right of the map ("east").
--- The value can also be unbounded; it can be negative, or greater than 360 degrees.
--- setHeading() and setRotation() do not change the helm's target heading on player ships. To do that, use commandTargetRotation().
--- Example: entity:setRotation(270)
function Entity:setRotation(rotation)
    if self.components.transform then self.components.transform.rotation = rotation end
    return self
end
--- Returns this entity's absolute rotation, in degrees.
--- Example: rotation = entity:getRotation()
function Entity:getRotation()
    if self.components.transform then return self.components.transform.rotation end
end
--- Sets this entity's heading, in degrees ranging from 0 to 360.
--- Unlike setRotation(), a value of 0 points to the top of the map ("north").
--- Values that are negative or greater than 360 are converted to values within that range.
--- setHeading() and setRotation() do not change the helm's target heading on player ships. To do that, use commandTargetRotation().
--- Example: entity:setHeading(0)
function Entity:setHeading(heading)
    if self.components.transform then self.components.transform.rotation = heading + 270 end
    return self
end
--- Returns this entity's heading, in degrees ranging from 0 to 360.
--- Example: heading = entity:getHeading()
function Entity:getHeading()
    if self.components.transform then
        local heading = self.components.transform.rotation - 270
        while heading < 0 do heading = heading + 360 end
        while heading > 360 do heading = heading - 360 end
        return heading
    end
    return 0
end
--- Returns this entity's directional velocity within 2D space as an x/y vector.
--- The values are relative x/y coordinates from the entity's current position (a 2D velocity vector).
--- Example: vx,vy = entity:getVelocity()
function Entity:getVelocity()
    if self.components.physics then return table.unpack(self.components.physics.velocity) end
end
--- Returns this entity's rotational velocity within 2D space, in degrees per second.
--- Example: entity:getAngularVelocity()
function Entity:getAngularVelocity()
    if self.components.physics then return self.components.physics.angular_velocity end
end
--- Sets the faction to which this entity belongs, by faction name.
--- Factions are defined by the FactionInfo class, and default factions are defined in scripts/factionInfo.lua.
--- Requires a faction name string.
--- Example: entity:setFaction("Human Navy")
function Entity:setFaction(faction_name)
    local faction = getFactionInfo(faction_name)
    if faction == nil then
        print("Failed to find faction: " .. faction_name)
        self.components.faction = nil
    else
        self.components.faction = {entity=faction}
    end
    return self
end
--- Returns the name of the faction to which this entity belongs.
--- Example: entity:getFaction()
function Entity:getFaction()
    local f = self.components.faction
    if f and f.entity and f.entity.components.faction_info then
        return f.entity.components.faction_info.name
    end
end
--- Returns the localized name of the faction to which this entity belongs.
--- Example: entity:getLocaleFaction()
function Entity:getLocaleFaction()
    local f = self.components.faction
    if f and f.entity and f.entity.components.faction_info then
        return f.entity.components.faction_info.locale_name
    end
end
--- Sets the faction to which this entity belongs, by a faction entity reference.
--- Use with getFactionId() to copy one entity's faction to another.
--- Example: entity:setFactionId(other:getFactionId()) -- sets obj's faction to match other's faction
function Entity:setFactionId(faction_id)
    if faction_id == nil then
        self.components.faction = nil
    else
        self.components.faction = {entity=faction_id}
    end
    return self
end
--- Returns the faction list index for the faction to which this entity belongs.
--- Use with setFactionId() to ensure that two entities belong to the same faction.
--- Example: entity:setFactionId(target:getFactionId())
function Entity:getFactionId()
    if self.components.faction then
        return self.components.faction.entity
    end
end
--- Returns the friend-or-foe status of the given faction relative to this entity's faction.
--- Returns true if the given entity's faction is hostile to this entity's.
--- Example: entity:isEnemy(target)
function Entity:isEnemy(target)
    if target == nil then return false end
    local my_faction = self:getFactionId()
    if my_faction == nil then return false end
    local my_faction_info = my_faction.components.faction_info
    if my_faction_info == nil then return false end
    local target_faction = target:getFactionId()
    if target_faction == nil then return false end
    for n=1,#my_faction_info do
        local relation = my_faction_info[n]
        if relation.other_faction == target_faction then
            return relation.relation == "enemy"
        end
    end
    return false
end
--- Returns the friend-or-foe status of the given faction relative to this entity's faction.
--- Returns true if the given entity's faction is friendly to this entity's.
--- If an entity is neither friendly nor enemy, it is neutral.
--- Example: entity:isFriendly(target)
function Entity:isFriendly(target)
    if target == nil then return false end
    local my_faction = self:getFactionId()
    if my_faction == nil then return false end
    local my_faction_info = my_faction.components.faction_info
    if my_faction_info == nil then return false end
    local target_faction = target:getFactionId()
    if target_faction == nil then return false end
    for n=1,#my_faction_info do
        local relation = my_faction_info[n]
        if relation.other_faction == target_faction then
            return relation.relation == "friendly"
        end
    end
    return false
end
--- Sets the communications script used when this entity is hailed.
--- Accepts the filename of a Lua script relative to the scripts/ directory.
--- If set to an empty string, comms with this entity are disabled.
--- The globals comms_source (player ship) and comms_target (entity) are made available in the scenario script.
--- Some entity types set their own default comms scripts.
--- For entity types without defaults, or when creating custom comms scripts, use setCommsMessage() to define the message and addCommsReply() to provide player response options.
--- See also setCommsFunction().
--- Examples:
--- entity:setCommsScript("comms_custom_script.lua") -- sets scripts/comms_custom_script.lua as this entity's comms script
--- entity:setCommsScript("") -- disables comms with this entity
function Entity:setCommsScript(script_name)
    self.components.comms_receiver = {script=script_name}
    self.components.comms_receiver.callback = nil
    return self
end
--- Defines a function to call when this entity is hailed, in lieu of any current or default comms script.
--- For a detailed example, see scripts/scenario_53_escape.lua.
--- TODO: Confirm this: The globals comms_source (player ship) and comms_target (entity) are made available in the scenario script.
--- They remain as globals. As usual, such globals are not accessible in required files.
--- Instead of using the globals, the callback can optionally take two equivalent parameters.
--- See also setCommsScript().
--- Examples:
--- entity:setCommsFunction(function(comms_source, comms_target) ... end)
--- Example: entity:setCommsFunction(commsStation) -- where commsStation is a function that calls setCommsMessage() at least once, and uses addCommsReply() to let players respond
function Entity:setCommsFunction(callback)
    self.components.comms_receiver = {callback=callback}
    self.components.comms_receiver.script = ""
    return self
end
--- Sets this entity's callsign.
--- EmptyEpsilon generates random callsigns for entities upon creation, and this function overrides that default.
--- Example: entity:setCallSign("Epsilon")
function Entity:setCallSign(callsign)
    self.components.callsign = {callsign=callsign}
    return self
end
--- Hails a player ship from this entity.
--- The player ship's comms position is notified and can accept or refuse the hail.
--- If the player ship accepts the hail, this displays the given message.
--- Returns true when the hail is accepted.
--- Returns false if the hail is refused, or when the target player cannot be hailed right now, for example because it's already communicating with something else.
--- This logs a message in the target's comms log. To avoid logging, use sendCommsMessageNoLog().
--- Requires a target player ship and message, though the message can be an empty string.
--- Example: entity:sendCommsMessage(player, "Prepare to die")
function Entity:sendCommsMessage(target, message)
    if self:isFriendly(target) then
        target:addToShipLog(message, "#C0C0FF")
    elseif self:isEnemy(target) then
        target:addToShipLog(message, "#FFC0C0")
    else
        target:addToShipLog(message, "#C0C0FF")
    end
    return self:sendCommsMessageNoLog(target, message)
end
--- As sendCommsMessage(), but does not log a failed hail to the target ship's comms log.
--- Example: entity:sendCommsMessageNoLog(player, "Prepare to die")
function Entity:sendCommsMessageNoLog(target, message)
    if self:openCommsTo(target) then
        target.components.comms_transmitter.incomming_message = message
        return true
    end
    return false
end
--- As sendCommsMessage(), but sends an empty string as the message.
--- This calls the entity's comms function.
--- Example: entity:openCommsTo(player)
function Entity:openCommsTo(target)
    if target and target.components.comms_transmitter then
        if target.components.comms_transmitter.state == "inactive" or target.components.comms_transmitter.state == "broken" then
            target.components.comms_transmitter.state = "hailed"
            target.components.comms_transmitter.incomming_message = ""
            target.components.comms_transmitter.target = self
            target.components.comms_transmitter.target_name = self:getCallSign()
            return true
        end
    end
    return false
end
--- Returns this entity's callsign.
--- Example: entity:getCallSign()
function Entity:getCallSign()
    if self.components.callsign then return self.components.callsign.callsign end
    return "?"
end
--- Returns whether any entity from a hostile faction are within a given radius of this entity, in (unit?).
--- Example: entity:areEnemiesInRange(5000) -- returns true if hostiles are within 5U of this entity
function Entity:areEnemiesInRange(range)
    return #getEnemiesInRadiusFor(self, range) > 0
end
--- Returns any entity within a specific radius, in (unit?), of this entity.
--- Returns a list of all entities within range.
--- Example: entity:getObjectsInRange(5000) -- returns all entities within 5U of this entity.
function Entity:getObjectsInRange(range)
    local x, y = self:getPosition()
    return getObjectsInRadius(x, y, range)
end
--- Returns this entity's faction reputation points.
--- Example: entity:getReputationPoints()
function Entity:getReputationPoints()
    if self.components.faction and self.components.faction.entity and self.components.faction.entity.components.faction_info then
        return self.components.faction.entity.components.faction_info.reputation_points
    end
end
--- Sets this entity's faction reputation points to the given amount.
--- Example: entity:setReputationPoints(1000)
function Entity:setReputationPoints(amount)
    if self.components.faction and self.components.faction.entity and self.components.faction.entity.components.faction_info then
        self.components.faction.entity.components.faction_info.reputation_points = amount
    end
    return self
end
--- Deducts a given number of faction reputation points from this entity.
--- Returns true if there are enough points to deduct the specified amount, then does so.
--- Returns false if there are not enough points, then does not deduct any.
--- Example: entity:takeReputationPoints(1000) -- returns false if `obj` has fewer than 1000 reputation points, otherwise returns true and deducts the points
function Entity:takeReputationPoints(amount)
    if self.components.faction and self.components.faction.entity and self.components.faction.entity.components.faction_info then
        local points = self.components.faction.entity.components.faction_info.reputation_points
        if points >= amount then
            self.components.faction.entity.components.faction_info.reputation_points = points - amount
            return true
        end
    end
    return false
end
--- Adds a given number of faction reputation points to this entity.
--- Example: entity:addReputationPoints(1000)
function Entity:addReputationPoints(amount)
    if self.components.faction and self.components.faction.entity and self.components.faction.entity.components.faction_info then
        local points = self.components.faction.entity.components.faction_info.reputation_points
        if points >= -amount then
            self.components.faction.entity.components.faction_info.reputation_points = points + amount
        end
    end
    return self
end
--- Returns the name of the map sector, such as "A4", where this entity is located.
--- Example: entity:getSectorName()
function Entity:getSectorName()
    local x, y = self:getPosition()
    return getSectorName(x, y)
end
--- Deals a specific amount of a specific type of damage to this entity.
--- Requires a numeric value for the damage amount, and accepts an optional DamageInfo type.
--- The optional DamageInfo parameter can be empty, which deals "energy" damage, or a string that indicates which type of damage to deal.
--- Valid damage types are "energy", "kinetic", and "emp".
--- If you specify a damage type, you can also optionally specify the location of the damage's origin, for instance to damage a specific shield segment on the target.
--- Entities by default do not implement damage, instead leaving it to specific entity types.
--- Examples:
--- entity:takeDamage(20, "emp", 1000, 0) -- deals 20 EMP damage as if it had originated from coordinates 1000,0
--- entity:takeDamage(20) -- deals 20 energy damage
function Entity:takeDamage(amount, type, originx, originy)
    applyDamageToEntity(self, amount, {type=type, x=originx, y=originy})
end
--- Sets this entity's description in unscanned and scanned states.
--- The science screen displays these descriptions when targeting a scanned entity.
--- Requires two string values, one for the descriptions when unscanned and another for when it has been scanned.
--- Example:
--- entity:setDescriptions("A refitted Atlantis X23...", "It's a trap!")
function Entity:setDescriptions(unscanned_description, scanned_description)
    self.components.science_description = {not_scanned=unscanned_description, friend_or_foe_identified=unscanned_description, simple_scan=scanned_description, full_scan=scanned_description}
    return self
end
--- Sets a description for a given EScannedState on this entity.
--- Only ship entities are created in an unscanned state. Other entities are created as fully scanned.
--- - "notscanned" or "not": The entity has not been scanned.
--- - "friendorfoeidentified": The entity has been identified as hostile or friendly, but has not been scanned.
--- - "simplescan" or "simple": The entity has been scanned once under default server settings, displaying only basic information about the entity.
--- - "fullscan" or "full": The entity is fully scanned.
--- Example: entity:setDescriptionForScanState("friendorfoeidentified", "A refitted...")
function Entity:setDescriptionForScanState(state, description)
    if self.components.science_description == nil then self.components.science_description = {} end
    if state == "notscanned" or state == "not" then self.components.science_description.not_scanned = description end
    if state == "friendorfoeidentified" then self.components.science_description.friend_or_foe_identified = description end
    if state == "simplescan" or state == "simple" then self.components.science_description.simple_scan = description end
    if state == "fullscan" or state == "full" then self.components.science_description.full_scan = description end
    return self
end
--- Returns this entity's description for the given EScannedState.
--- Accepts an optional string-equivalent EScannedState, which determines which description to return.
--- Defaults to returning the "fullscan" description.
--- Examples:
--- entity:getDescription() -- returns the "fullscan" description
--- entity:getDescription("friendorfoeidentified") -- returns the "friendorfoeidentified" description
function Entity:getDescription(state)
    if self.components.science_description == nil then return "" end
    if state == "notscanned" or state == "not" then return self.components.science_description.not_scanned end
    if state == "friendorfoeidentified" then return self.components.science_description.friend_or_foe_identified end
    if state == "simplescan" or state == "simple" then return self.components.science_description.simple_scan end
    return self.components.science_description.full_scan
end
--- Sets this entity's radar signature, which creates noise on the science screen's raw radar signal ring.
--- The raw signal ring contains red (electrical), green (biological), and blue (gravitational) bands of waveform noise.
--- Certain entity types might set their own defaults or dynamically modify their signatures using this value as a baseline.
--- Requires numeric values ranging from 0.0 to 1.0 for the gravitational, electrical, and biological radar bands, in that order.
--- Larger and negative values are possible, but currently have no visual effect on the bands.
--- Example: entity:setRadarSignatureInfo(0.0, 0.5, 1.0) -- a radar signature of 0 gravitational, 0.5 electrical, and 1.0 biological
function Entity:setRadarSignatureInfo(gravity, electrical, biological)
    self.components.radar_signature = {gravity=gravity, electrical=electrical, biological=biological}
    return self
end
--- Returns this entity's gravitational radar signature value.
--- Example: entity:getRadarSignatureGravity()
function Entity:getRadarSignatureGravity()
    if self.components.radar_signature then return self.components.radar_signature.gravity end
    return 0.0
end
--- Returns this entity's electrical radar signature value.
--- Example: entity:getRadarSignatureElectrical()
function Entity:getRadarSignatureElectrical()
    if self.components.radar_signature then return self.components.radar_signature.electrical end
    return 0.0
end
--- Returns this entity's biological radar signature value.
--- Example: entity:getRadarSignatureBiological()
function Entity:getRadarSignatureBiological()
    if self.components.radar_signature then return self.components.radar_signature.biological end
    return 0.0
end
--- Sets this entity's scanning complexity (number of bars in the scanning minigame) and depth (number of scanning minigames to complete until fully scanned), respectively.
--- Setting this also clears the entity's scanned state.
--- Example: entity:setScanningParameters(2, 3)
function Entity:setScanningParameters(complexity, depth)
    self.components.scan_state = {complexity=complexity, depth=depth}
    self:setScanned(false)
    return self
end
--- Returns the scanning complexity for this entity.
--- Example: entity:scanningComplexity()
function Entity:scanningComplexity()
    if self.components.scan_state then return self.components.scan_state.complexity end
    return 0
end
--- Returns the maximum scanning depth for this entity.
--- Example: entity:scanningChannelDepth()
function Entity:scanningChannelDepth()
    if self.components.scan_state then return self.components.scan_state.depth end
    return 0
end
--- Defines whether all factions consider this entity as having been scanned.
--- Only ship entities are created in an unscanned state. Other entities are created as fully scanned.
--- If false, all factions treat this entity as unscanned.
--- If true, all factions treat this entity as fully scanned.
--- Example: entity:setScanned(true)
function Entity:setScanned(is_scanned)
    if is_scanned then self:setScanState("full") else self:setScanState("none") end
    return self
end
--- [DEPRECATED]
--- Returns whether this entity has been scanned.
--- Use isScannedBy() or isScannedByFaction() instead.
function Entity:isScanned()
    local ss = self.components.scan_state
    if ss then
        for n=1,#ss do
            if ss[n].state == "full" then return true end
            if ss[n].state == "simple" then return true end
        end
        return false
    end
    return true
end
--- Returns whether the given entity has successfully scanned this entity.
--- Example: entity:isScannedBy(other)
function Entity:isScannedBy(other)
    if not other then return false end
    local f = other:getFactionId()
    if f then
        local ss = self.components.scan_state
        if ss then
            for n=1,#ss do
                if ss[n].faction == f then
                    if ss[n].state == "full" then return true end
                    if ss[n].state == "simple" then return true end
                    return false
                end
            end
            return false
        end
    end
    return true
end
--- Defines whether a given faction considers this entity as having been scanned.
--- Requires a faction name string value as defined by its FactionInfo, and a Boolean value.
--- Example: entity:setScannedByFaction("Human Navy", false)
function Entity:setScannedByFaction(faction_name, is_scanned)
    if is_scanned then
        self:setScanStateByFaction(faction_name, "full")
    else
        self:setScanStateByFaction(faction_name, "none")
    end
    return self
end
--- Returns whether the given faction has successfully scanned this entity.
--- Requires a faction name string value as defined by its FactionInfo.
--- Example: entity:isScannedByFaction("Human Navy")
function Entity:isScannedByFaction(faction_name)
    local ss = self.components.scan_state
    if ss then
        local f = getFactionInfo(faction_name)
        if f ~= nil then
            for n = 1, #ss do
                if ss[n].faction == f then
                    if ss[n].state == "full" then return true end
                    if ss[n].state == "simple" then return true end
                    return false
                end
            end
        end
    end
    return false
end
--- Defines a function to call when this entity is destroyed by any means.
--- Example:
--- -- Prints to the console window or logging file when this entity is destroyed
--- entity:onDestroyed(function() print("Object destroyed!") end)
function Entity:onDestroyed(callback)
    --TODO: Cases where we do not have hull
    if self.components.hull then self.components.hull.on_destruction = callback end
    return self
end
