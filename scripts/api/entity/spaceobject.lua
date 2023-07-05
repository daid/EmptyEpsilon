local Entity = getLuaEntityFunctionTable()

----- Old SpaceObject API -----

--- Sets this SpaceObject's position on the map, in meters from the origin.
--- Example: obj:setPosition(x,y)
function Entity:setPosition(x, y)
    if self.transform then self.transform.position = {x, y} end
    return self
end
--- Returns this object's position on the map.
--- Example: x,y = obj:getPosition()
function Entity:getPosition()
    if self.transform then return table.unpack(self.transform.position) end
end
--- Sets this SpaceObject's absolute rotation, in degrees.
--- Unlike SpaceObject:setHeading(), a value of 0 points to the right of the map ("east").
--- The value can also be unbounded; it can be negative, or greater than 360 degrees.
--- SpaceObject:setHeading() and SpaceObject:setRotation() do not change the helm's target heading on PlayerSpaceships. To do that, use PlayerSpaceship:commandTargetRotation().
--- Example: obj:setRotation(270)
function Entity:setRotation(rotation)
    if self.transform then self.transform.rotation = rotation end
    return self
end
--- Returns this SpaceObject's absolute rotation, in degrees.
--- Example: local rotation = obj:getRotation()
function Entity:getRotation()
    if self.transform then return self.transform.rotation end
end
--- Sets this SpaceObject's heading, in degrees ranging from 0 to 360.
--- Unlike SpaceObject:setRotation(), a value of 0 points to the top of the map ("north").
--- Values that are negative or greater than 360 are converted to values within that range.
--- SpaceObject:setHeading() and SpaceObject:setRotation() do not change the helm's target heading on PlayerSpaceships. To do that, use PlayerSpaceship:commandTargetRotation().
--- Example: obj:setHeading(0)
function Entity:setHeading(heading)
    if self.transform then self.transform.rotation = heading - 90 end
    return self
end
--- Returns this SpaceObject's heading, in degrees ranging from 0 to 360.
--- Example: heading = obj:getHeading(0)
function Entity:getHeading()
    if self.transform then return self.transform.rotation + 90 end
end
--- Returns this SpaceObject's directional velocity within 2D space as an x/y vector.
--- The values are relative x/y coordinates from the SpaceObject's current position (a 2D velocity vector).
--- Example: vx,vy = obj:getVelocity()
function Entity:getVelocity()
    if self.physics then return table.unpack(self.physics.velocity) end
end
--- Returns this SpaceObject's rotational velocity within 2D space, in degrees per second.
--- Example: obj:getAngularVelocity()
function Entity:getAngularVelocity()
    if self.physics then return self.physics.angular_velocity end
end
--- Sets the faction to which this SpaceObject belongs, by faction name.
--- Factions are defined by the FactionInfo class, and default factions are defined in scripts/factionInfo.lua.
--- Requires a faction name string.
--- Example: obj:setFaction("Human Navy")
function Entity:setFaction(faction_name)
    local faction = getFactionInfo(faction_name)
    if faction == nil then
        print("Failed to find faction: " .. faction_name)
        self.faction = nil
    else
        self.faction = {entity=faction}
    end
    return self
end
--- Returns the name of the faction to which this SpaceObject belongs.
--- Example: obj:getFaction()
function Entity:getFaction()
    local f = self.faction
    if f and f.faction_info then
        return f.faction_info.name
    end
end
--- Returns the localized name of the faction to which this SpaceObject belongs.
--- Example: obj:getLocaleFaction()
function Entity:getLocaleFaction()
    local f = self.faction
    if f and f.faction_info then
        return f.faction_info.locale_name
    end
end
--- Returns the faction to which this SpaceObject belongs, by the faction's index in the faction list.
--- Use with SpaceObject:getFactionId() to ensure that two objects belong to the same faction.
--- Example: local faction_id = obj:getFactionId()
function Entity:setFactionId(faction_id)
    if faction_id == nil then
        self.faction = nil
    else
        self.faction = {entity=faction_id}
    end
    return self
end
--- Returns the faction list index for the faction to which this SpaceObject belongs.
--- Use with SpaceObject:setFactionId() to ensure that two objects belong to the same faction.
--- Example: obj:setFactionId(target:getFactionId())
function Entity:getFactionId()
    if self.faction then
        return self.faction.entity
    end
end
--- Returns the friend-or-foe status of the given faction relative to this SpaceObject's faction.
--- Returns true if the given SpaceObject's faction is hostile to this object's.
--- Example: obj:isEnemy(target)
function Entity:isEnemy(target)
    if target == nil then return false end
    local my_faction = self:getFactionId()
    if my_faction == nil then return false end
    local my_faction_info = my_faction.faction_info
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
--- Returns the friend-or-foe status of the given faction relative to this SpaceObject's faction.
--- Returns true if the given SpaceObject's faction is friendly to this object's.
--- If an object is neither friendly nor enemy, it is neutral.
--- Example: obj:isFriendly(target)
function Entity:isFriendly(target)
    if target == nil then return false end
    local my_faction = self:getFactionId()
    if my_faction == nil then return false end
    local my_faction_info = my_faction.faction_info
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
--- Sets the communications script used when this SpaceObject is hailed.
--- Accepts the filename of a Lua script relative to the scripts/ directory.
--- If set to an empty string, comms with this object are disabled.
--- The globals comms_source (PlayerSpaceship) and comms_target (SpaceObject) are made available in the scenario script.
--- Subclasses set their own default comms scripts.
--- For object types without defaults, or when creating custom comms scripts, use setCommsMessage() to define the message and addCommsReply() to provide player response options.
--- See also SpaceObject:setCommsFunction().
--- Examples:
--- obj:setCommsScript("comms_custom_script.lua") -- sets scripts/comms_custom_script.lua as this object's comms script
--- obj:setCommsScript("") -- disables comms with this object
function Entity:setCommsScript(script_name)
    --TODO
    return self
end
--- Defines a function to call when this SpaceObject is hailed, in lieu of any current or default comms script.
--- For a detailed example, see scripts/scenario_53_escape.lua.
--- TODO: Confirm this: The globals comms_source (PlayerSpaceship) and comms_target (SpaceObject) are made available in the scenario script.
--- They remain as globals. As usual, such globals are not accessible in required files.
--- Instead of using the globals, the callback can optionally take two equivalent parameters.
--- See also SpaceObject:setCommsScript().
--- Examples:
--- obj:setCommsFunction(function(comms_source, comms_target) ... end)
--- Example: obj:setCommsFunction(commsStation) -- where commsStation is a function that calls setCommsMessage() at least once, and uses addCommsReply() to let players respond
function Entity:setCommsFunction(callback)
    --TODO
    return self
end
--- Sets this SpaceObject's callsign.
--- EmptyEpsilon generates random callsigns for objects upon creation, and this function overrides that default.
--- Example: obj:setCallSign("Epsilon")
function Entity:setCallSign(callsign)
    self.callsign = {callsign=callsign}
    return self
end
--- Hails a PlayerSpaceship from this SpaceObject.
--- The PlayerSpaceship's comms position is notified and can accept or refuse the hail.
--- If the PlayerSpaceship accepts the hail, this displays the given message.
--- Returns true when the hail is accepted.
--- Returns false if the hail is refused, or when the target player cannot be hailed right now, for example because it's already communicating with something else.
--- This logs a message in the target's comms log. To avoid logging, use SpaceObject:sendCommsMessageNoLog().
--- Requires a target PlayerShip and message, though the message can be an empty string.
--- Example: obj:sendCommsMessage(player, "Prepare to die")
function Entity:sendCommsMessage(target, message)
    --TODO
end
--- As SpaceObject:sendCommsMessage(), but does not log a failed hail to the target ship's comms log.
--- Example: obj:sendCommsMessageNoLog(player, "Prepare to die")
function Entity:sendCommsMessageNoLog(target, message)
    --TODO
end
--- As SpaceObject:sendCommsMessage(), but sends an empty string as the message.
--- This calls the SpaceObject's comms function.
--- Example: obj:openCommsTo(player)
function Entity:openCommsTo(target)
    --TODO
end
--- Returns this SpaceObject's callsign.
--- Example: obj:getCallSign()
function Entity:getCallSign()
    if self.callsign then return self.callsign.callsign end
end
--- Returns whether any SpaceObject from a hostile faction are within a given radius of this SpaceObject, in (unit?).
--- Example: obj:areEnemiesInRange(5000) -- returns true if hostiles are within 5U of this object
function Entity:areEnemiesInRange(range)
    --TODO
end
--- Returns any SpaceObject within a specific radius, in (unit?), of this SpaceObject.
--- Returns a list of all SpaceObjects within range.
--- Example: obj:getObjectsInRange(5000) -- returns all objects within 5U of this SpaceObject.
function Entity:getObjectsInRange(range)
    --TODO
end
--- Returns this SpaceObject's faction reputation points.
--- Example: obj:getReputationPoints()
function Entity:getReputationPoints()
    if self.faction and self.faction.entity and self.faction.entity.faction_info then
        return self.self.faction.entity.faction_info.reputation_points
    end
end
--- Sets this SpaceObject's faction reputation points to the given amount.
--- Example: obj:setReputationPoints(1000)
function Entity:setReputationPoints(amount)
    if self.faction and self.faction.entity and self.faction.entity.faction_info then
        self.self.faction.entity.faction_info.reputation_points = amount
    end
end
--- Deducts a given number of faction reputation points from this SpaceObject.
--- Returns true if there are enough points to deduct the specified amount, then does so.
--- Returns false if there are not enough points, then does not deduct any.
--- Example: obj:takeReputationPoints(1000) -- returns false if `obj` has fewer than 1000 reputation points, otherwise returns true and deducts the points
function Entity:takeReputationPoints(amount)
    if self.faction and self.faction.entity and self.faction.entity.faction_info then
        local points = self.self.faction.entity.faction_info.reputation_points
        if points >= amount then
            self.self.faction.entity.faction_info.reputation_points = points - amount
            return true
        end
    end
    return false
end
--- Adds a given number of faction reputation points to this SpaceObject.
--- Example: obj:addReputationPoints(1000)
function Entity:addReputationPoints(amount)
    if self.faction and self.faction.entity and self.faction.entity.faction_info then
        local points = self.self.faction.entity.faction_info.reputation_points
        if points >= -amount then
            self.self.faction.entity.faction_info.reputation_points = points + amount
        end
    end
end
--- Returns the name of the map sector, such as "A4", where this SpaceObject is located.
--- Example: obj:getSectorName()
function Entity:getSectorName()
    local x, y = self:getPosition()
    return getSectorName(x, y)
end
--- Deals a specific amount of a specific type of damage to this SpaceObject.
--- Requires a numeric value for the damage amount, and accepts an optional DamageInfo type.
--- The optional DamageInfo parameter can be empty, which deals "energy" damage, or a string that indicates which type of damage to deal.
--- Valid damage types are "energy", "kinetic", and "emp".
--- If you specify a damage type, you can also optionally specify the location of the damage's origin, for instance to damage a specific shield segment on the target.
--- SpaceObjects by default do not implement damage, instead leaving it to be overridden by specialized subclasses.
--- Examples:
--- obj:takeDamage(20, "emp", 1000, 0) -- deals 20 EMP damage as if it had originated from coordinates 1000,0
--- obj:takeDamage(20) -- deals 20 energy damage
function Entity:takeDamage(amount, type, originx, originy)
    --TODO
end
--- Sets this SpaceObject's description in unscanned and scanned states.
--- The science screen displays these descriptions when targeting a scanned object.
--- Requires two string values, one for the descriptions when unscanned and another for when it has been scanned.
--- Example:
---   obj:setDescriptions("A refitted Atlantis X23...", "It's a trap!")
function Entity:setDescriptions(unscanned_description, scanned_description)
    --TODO
end
--- As setDescriptions, but sets the same description for both unscanned and scanned states.
--- Example: obj:setDescription("A refitted Atlantis X23 for more ...")
function Entity:setDescription(description)
    --TODO
end
--- Sets a description for a given EScannedState on this SpaceObject.
--- Only SpaceShip objects are created in an unscanned state. Other SpaceObjects are created as fully scanned.
--- - "notscanned" or "not": The object has not been scanned.
--- - "friendorfoeidentified": The object has been identified as hostile or friendly, but has not been scanned.
--- - "simplescan" or "simple": The object has been scanned once under default server settings, displaying only basic information about the object.
--- - "fullscan" or "full": The object is fully scanned.
--- Example: obj:setDescriptionForScanState("friendorfoeidentified", "A refitted...")
function Entity:setDescriptionForScanState(state, description)
    --TODO
end
--- Returns this SpaceObject's description for the given EScannedState.
--- Accepts an optional string-equivalent EScannedState, which determines which description to return.
--- Defaults to returning the "fullscan" description.
--- Examples:
--- obj:getDescription() -- returns the "fullscan" description
--- obj:getDescription("friendorfoeidentified") -- returns the "friendorfoeidentified" description
function Entity:getDescription(state)
    --TODO
end
--- Sets this SpaceObject's radar signature, which creates noise on the science screen's raw radar signal ring.
--- The raw signal ring contains red, green, and blue bands of waveform noise.
--- Certain SpaceObject subclasses might set their own defaults or dynamically modify their signatures using this value as a baseline.
--- Requires numeric values ranging from 0.0 to 1.0 for the gravitational, electrical, and biological radar bands, in that order.
--- Larger and negative values are possible, but currently have no visual effect on the bands.
--- - Gravitational signatures amplify noise on all bands, particularly the green and blue bands.
--- - Electrical signatures amplify noise on the red and blue bands.
--- - Biological signatures amplify noise on the red and green bands.
--- Example: obj:setRadarSignatureInfo(0.0, 0.5, 1.0) -- a radar signature of 0 gravitational, 0.5 electrical, and 1.0 biological
function Entity:setRadarSignatureInfo(gravity, electrical, biological)
    --TODO
end
--- Returns this SpaceObject's gravitational radar signature value.
--- Example: obj:getRadarSignatureGravity()
function Entity:getRadarSignatureGravity()
    --TODO
end
--- Returns this SpaceObject's electical radar signature value.
--- Example: obj:getRadarSignatureElectrical()
function Entity:getRadarSignatureElectrical()
    --TODO
end
--- Returns this SpaceObject's biological radar signature value.
--- Example: obj:getRadarSignatureBiological()
function Entity:getRadarSignatureBiological()
    --TODO
end
--- Sets this SpaceObject's scanning complexity (number of bars in the scanning minigame) and depth (number of scanning minigames to complete until fully scanned), respectively.
--- Setting this also clears the object's scanned state.
--- Example: obj:setScanningParameters(2, 3)
function Entity:setScanningParameters(complexity, depth)
    --TODO
end
--- Returns the scanning complexity for the given SpaceObject.
--- Example: obj:scanningComplexity(obj)
function Entity:scanningComplexity()
    --TODO
end
--- Returns the maximum scanning depth for the given SpaceObject.
--- Example: obj:scanningChannelDepth(obj)
function Entity:scanningChannelDepth()
    --TODO
end
--- Defines whether all factions consider this SpaceObject as having been scanned.
--- Only SpaceShip objects are created in an unscanned state. Other SpaceObjects are created as fully scanned.
--- If false, all factions treat this object as unscanned.
--- If true, all factions treat this object as fully scanned.
--- Example: obj:setScanned(true)
function Entity:setScanned(is_scanned)
    --TODO
end
--- [DEPRECATED]
--- Returns whether this SpaceObject has been scanned.
--- Use SpaceObject:isScannedBy() or SpaceObject:isScannedByFaction() instead.
function Entity:isScanned()
    --TODO
end
--- Returns whether the given SpaceObject has successfully scanned this SpaceObject.
--- Example: obj:isScannedBy(other)
function Entity:isScannedBy()
    --TODO
end
--- Defines whether a given faction considers this SpaceObject as having been scanned.
--- Requires a faction name string value as defined by its FactionInfo, and a Boolean value.
--- Example: obj:setScannedByFaction("Human Navy", false)
function Entity:setScannedByFaction(faction_name, is_scanned)
    --TODO
end
--- Returns whether the given faction has successfully scanned this SpaceObject.
--- Requires a faction name string value as defined by its FactionInfo.
--- Example: obj:isScannedByFaction("Human Navy")
function Entity:isScannedByFaction(faction_name)
    --TODO
end
--- Defines a function to call when this SpaceObject is destroyed by any means.
--- Example:
--- -- Prints to the console window or logging file when this SpaceObject is destroyed
--- obj:onDestroyed(function() print("Object destroyed!") end)
function Entity:onDestroyed(callback)
    --TODO
end
