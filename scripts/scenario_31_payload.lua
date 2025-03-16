-- Name: Push The Payload
-- Description: Deliver the payload of flowers to the opposing station in order to end the war
---
--- Duration: As little as 30 mins on default settings
--- Player ships: 1
---
--- Author: Chris Sibbitt and Crew
--- Created: Jan2025
--- Feedback: USN Discord: https://discord.gg/7Kr32ezJFF
-- Type: Replayable Mission
-- Setting[WaveRandomNess]: Random variation in wave timing. Default is 0.25
-- WaveRandomNess[0]: Random variation in wave timing.
-- WaveRandomNess[0.1]: Random variation in wave timing.
-- WaveRandomNess[0.25|Default]: Random variation in wave timing. (Default)
-- WaveRandomNess[0.5]: Random variation in wave timing.
-- Setting[WaveTimer]: Display a wave timer in the Science/Ops console. Default is Disabled
-- WaveTimer[Disabled|Default]: No visible wave timer (Default)
-- WaveTimer[Enabled]: Display a wave timer in the Science/Ops console
-- Setting[Resistance]: Resistance level. Default is Normal
-- Resistance[Easy]: Easy
-- Resistance[Normal|Default]: Normal (Default)
-- Resistance[Hard]: Hard
-- Resistance[Nightmare]: Nightmare
-- Setting[TimeLimit]: Time limit before Kraylor victory. Default is 0 (no time limit)
-- TimeLimit[0|Default]: No time limit (Default)
-- TimeLimit[15]: 15 mins
-- TimeLimit[30]: 30 mins
-- TimeLimit[60]: 1 hour
-- TimeLimit[90]: 1.5 hours
-- TimeLimit[120]: 2 hours
-- TimeLimit[180]: 3 hours
-- Setting[FieldSize]: Distance between factions stations. Affects difficulty and time. Default is Medium
-- FieldSize[50000]: Tiny field size
-- FieldSize[75000]: Small field size
-- FieldSize[100000|Default]: Medium field size (Default)
-- FieldSize[150000]: Large field size
-- FieldSize[200000]: Extra Large

require("utils.lua")

Debug = false

---@diagnostic disable-next-line: lowercase-global
function init()
  TimeLimit = tonumber(getScenarioSetting("TimeLimit")) * 60

  SetResistance()
  SetFactionAggro()

  if Debug then
    FieldSize = 20000
  else
    FieldSize = tonumber(getScenarioSetting("FieldSize"))
  end

  -- Create the faction stations
  FactionStation = SpaceStation():setTemplate("Large Station"):setFaction("Human Navy"):setPosition(0, 0):setCallSign(_("mission", "Your Stn"))
  FactionStation.startX, FactionStation.startY = FactionStation:getPosition()
  local kx, ky
  if Debug then
    kx = FieldSize
    ky = FieldSize
  else
    kx, ky = RandPositionInRadius(0, 0, FieldSize, FieldSize, 0, 360)
  end
  KraylorStation = SpaceStation():setTemplate("Large Station"):setFaction("Kraylor"):setPosition(kx, ky):setCallSign(_("mission", "Kraylor Stn"))
  KraylorStation.startX, KraylorStation.startY = KraylorStation:getPosition()

  -- Calculate midpoint between stations
  local fsX, fsY = FactionStation:getPosition()
  local esX, esY = KraylorStation:getPosition()
  MidX = math.floor((fsX + esX) / 2)
  MidY = math.floor((fsY + esY) / 2)

  -- Create the Payload ship
  PayloadDistanceThreshold = 2000
  PayloadShip = CpuShip():setTemplate("Adv. Gunship"):setFaction("Independent"):setPosition(MidX, MidY):setCallSign("Flowers"):setImpulseMaxSpeed(95):setCommsFunction(PayloadCommsHandler)
  PayloadShip.startX, PayloadShip.startY = PayloadShip:getPosition()
  PayloadShip.target = nil
  PayloadShip.scanACKd = false
  PayloadShip.Waypoints = {}
  PayloadShip.controlledBy = nil
  PayloadShip.LastControlledBy = nil

  -- Spawn some asteroids
  local asteroidNum = 200 --200
  if Debug then
    asteroidNum = 0
  end
  placeRandomObjects(Asteroid, asteroidNum, 0.3, MidX, MidY, FieldSize / 10000, FieldSize / 10000)

  -- Spawn some mines
  for __ = 1, Resistance.minesToSpawn do
    local x, y = RandPositionInRadius(MidX, MidY, FieldSize / 2 - 5000, FieldSize / 2 - 40000, 0, 360)
    Mine():setPosition(x, y)
  end

  -- Unspawn some asteroids and mines (moved this to update() as hackaround for a limitation in ECS branch)
  FirstTickClearHazards = true

  -- Spawn some nebulas
  local nebulaNum = 15 --15
  if Debug then
    nebulaNum = 0
  end
  placeRandomObjects(Nebula, nebulaNum, 0.3, MidX, MidY, FieldSize / 10000, FieldSize / 10000)

  -- Spawn Rearm Stations
  HVLIStation = StationFactory("HVLI", 8)
  HomingStation = StationFactory("Homing", 16)
  EMPStation = StationFactory("EMP", 24)
  MineStation = StationFactory("Mine", 32)
  NukeStation = StationFactory("Nuke", 40)

  SpawnObjects(HVLIStation, 1, MidX, MidY, math.floor(FieldSize / 2.25), 15000)
  SpawnObjects(HomingStation, 1, MidX, MidY, math.floor(FieldSize / 2.25), 15000)
  SpawnObjects(EMPStation, 1, MidX, MidY, math.floor(FieldSize / 2.25), 15000)
  SpawnObjects(MineStation, 1, MidX, MidY, math.floor(FieldSize / 2.25), 15000)
  SpawnObjects(NukeStation, 1, MidX, MidY, math.floor(FieldSize / 2.25), 15000)

  -- Random traffic
  InitTraffic()

  -- Spawn some weapon pickup artifacts
  Pickups = {
    artifacts = {},
    hintIndex = 1
  }
  SpawnWeaponPickups()

  -- Initialize wave variables
  WaveSize = 1
  WaveTimer = Resistance.waveInterval
  GMWaveTimerUpdate = 1
  KraylorShips = {}
  HumanShips = {}

  -- Initialize closest enemy tracking
  ClosestEnemies = {
    Kraylor = { ship = nil, distance = math.huge },
    HumanNavy = { ship = nil, distance = math.huge },
    Interval = 5,
    Timer = 5
  }

  -- Create the player ship
  allowNewPlayerShips(false)
  Player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Phobos M3P"):setCallSign("Screamin' Firehawk"):setPosition(fsX + 1000, fsY + 1000)
  Player:setJumpDrive(false)
  Player:setWarpDrive(true)
  Player:setRotation(45):commandTargetRotation(45)
  Player:setWeaponStorageMax("Homing", 4)
  Player:setWeaponStorageMax("Nuke", 4)
  Player:setWeaponStorageMax("Mine", 4)
  Player:setWeaponStorageMax("EMP", 4)
  Player:setWeaponStorageMax("HVLI", 4)
  Player:setWeaponStorage("Homing", 4)
  Player:setWeaponStorage("Nuke", 0)
  Player:setWeaponStorage("Mine", 0)
  Player:setWeaponStorage("EMP", 0)
  Player:setWeaponStorage("HVLI", 4)
  Player:setLongRangeRadarRange(20000)

  -- Send initial comms message
  local payloadStartSector = getSectorName(PayloadShip.startX, PayloadShip.startY)
  FactionStation:sendCommsMessage(Player, _("mission",
[[The war with the Kraylor has been at a standstill for decades.

Our scientists have discovered an alien artifact. Long range scans
indicate that it is a bouquet of ancient flowers.

Bring the flowers to the enemy station as a gesture of good faith
in order to end this war. Scan the alien artifact and stay close to it.

The artifact is located in Sector ]] .. payloadStartSector))

end

function SetResistance()
  local difficulty = getScenarioSetting("Resistance")
  Resistance = {}
  if difficulty == "Easy" then
    Resistance.waveInterval = 180
    Resistance.maxWaveSize = 4
    Resistance.pickupArtifacts = 10
    Resistance.minesToSpawn = 0
    Resistance.turnoverWaveDelay = 180
    Resistance.idleWaveDelay = 180
  elseif difficulty == "Normal" then
    Resistance.waveInterval = 120
    Resistance.maxWaveSize = 5
    Resistance.pickupArtifacts = 5
    Resistance.minesToSpawn = 20
    Resistance.turnoverWaveDelay = 120
    Resistance.idleWaveDelay = 120 
  elseif difficulty == "Hard" then
    Resistance.waveInterval = 120
    Resistance.maxWaveSize = 6
    Resistance.pickupArtifacts = 2
    Resistance.minesToSpawn = 30
    Resistance.turnoverWaveDelay = 90
    Resistance.idleWaveDelay = 90
  elseif difficulty == "Nightmare" then
    Resistance.waveInterval = 60
    Resistance.maxWaveSize = 8
    Resistance.pickupArtifacts = 0
    Resistance.minesToSpawn = 40
    Resistance.turnoverWaveDelay = 30
    Resistance.idleWaveDelay = 45
  else
    print("Unknown difficulty setting: " .. difficulty)
  end
end

-- Keep random traffic from attacking the player
function SetFactionAggro()
  local factions = {"Independent", "Arlenians", "Exuari", "Ghosts", "Ktlitans", "TSN", "USN", "CUF"}
  for __, factionName in ipairs(factions) do
    local faction = getFactionInfo(factionName)
    faction:setNeutral(getFactionInfo("Human Navy"))
    getFactionInfo("Human Navy"):setNeutral(faction)
    faction:setNeutral(getFactionInfo("Kraylor"))
    getFactionInfo("Kraylor"):setNeutral(faction)
  end
end

-- Clear asteroids within radius
function ClearHazardsNear(centerX, centerY, radius, maxRoids, maxMines)
  local maxRoids = maxRoids or 0
  local maxMines = maxMines or 0
  local objects = getObjectsInRadius(centerX, centerY, radius)
  local roidCount = 0
  local mineCount = 0

  -- Shuffle the objects
  if maxRoids > 0 or maxMines > 0 then
    for i = #objects, 2, -1 do
      local j = math.random(i)
      objects[i], objects[j] = objects[j], objects[i]
    end
  end

  -- Destroy any hazards beyond the limits
  for _, potentialHazard in ipairs(objects) do
    if potentialHazard.components.explode_on_touch ~= nil then
      roidCount = roidCount + 1
      if roidCount > maxRoids then
        potentialHazard:destroy()
      end
    end
    if potentialHazard.components.delayed_explode_on_touch ~= nil then
      mineCount = mineCount + 1
      if mineCount > maxMines then
        potentialHazard:destroy()
      end
    end
  end
end

-- Thin the hazards along a path
function ThinPath(start, finish, stepSize, maxAsteroids, maxMines)
  local startX, startY = start:getPosition()
  local finishX, finishY = finish:getPosition()
  local stepSize = stepSize or 10000
  local maxAsteroids = maxAsteroids or 6
  local maxMines = maxMines or 1
  local angleBetween = math.rad(math.floor(CalculateAngle(startX, startY, finishX, finishY)))

  while distance(startX, startY, finishX, finishY) > stepSize do
    local waypointX = startX + stepSize * math.cos(angleBetween)
    local waypointY = startY + stepSize * math.sin(angleBetween)
    waypointX = waypointX + irandom(math.floor(-stepSize / 4), math.floor(stepSize / 4))
    waypointY = waypointY + irandom(math.floor(-stepSize / 4), math.floor(stepSize / 4))
    ClearHazardsNear(waypointX, waypointY, stepSize/1.5, maxAsteroids, maxMines)
    startX = waypointX
    startY = waypointY
  end
end

function InitTraffic()
  Traffic = {}
  Traffic.docked_ships = {}
  Traffic.leaving_ships = {}
  Traffic.new_ships = {}
  Traffic.factions = {"Independent", "Arlenians", "Exuari", "Ghosts", "Ktlitans", "TSN", "USN", "CUF"}
  Traffic.types = {"Atlantis", "Transport1x2", "Maverick", "Kiriya", "Hathcock", "Flavia P.Falcon"}
  Traffic.stations = {HVLIStation, HomingStation, EMPStation, MineStation, NukeStation}
  Traffic.timer = getScenarioTime()
end

-- Spawn weapon pickup artifacts
function SpawnWeaponPickups()
  local weaponTypes = {"Homing", "Nuke", "Mine", "EMP", "HVLI"}
  local edgeDistance = FieldSize / 2

  for __ = 1, Resistance.pickupArtifacts do
    for __, weaponType in ipairs(weaponTypes) do
      local x, y = RandPositionInRadius(MidX, MidY, edgeDistance - 5000, edgeDistance - 30000, 0, 360)
      local artifact = Artifact():setPosition(x, y):setDescriptions(_("artifacts", "Something to salvage"), _("artifacts", "It looks like a " .. weaponType)):setScanningParameters(1, 1)
      artifact:onCollision(function(self, collider)
        -- "Note that the callback function must reference something global, otherwise you get an error like "??[convert<ScriptSimpleCallback>::param] Upvalue 1 of function is not a table..."
        local __ = math.abs(0)
        if collider.components.player_control then
          collider:setWeaponStorage(weaponType, collider:getWeaponStorage(weaponType) + 1)
          self:destroy()
          collider:addToShipLog(_("artifacts", "Picked up a ") .. weaponType, "green")
          RemovePickupArtifact(self)
        end
      end)
      table.insert(Pickups.artifacts, artifact)
    end
  end
end

--
-- End of init
--

-- Calculate the angle between two coordinates
function CalculateAngle(x1, y1, x2, y2)
  local deltaY = y2 - y1
  local deltaX = x2 - x1
  local angle = math.atan(deltaY, deltaX) * (180 / math.pi)
  return angle
end

-- Check who is in control of the payload
-- returns 1 if faction1 is in control, -1 if faction2 is in control, 0 if neither faction is in control
function CheckPayloadControl(target, faction1, faction2)
  local count1 = 0
  local count2 = 0
  local payloadX, payloadY = target:getPosition()
  local allShips = getObjectsInRadius(payloadX, payloadY, PayloadDistanceThreshold)

  for _, ship in ipairs(allShips) do
    if ship.components.ai_controller == nil and ship.components.player_control == nil then
      goto continue
    end
    if ship:isValid() and ship:getFaction() == faction1 then
      count1 = count1 + 1
    elseif ship:isValid() and ship:getFaction() == faction2 then
      count2 = count2 + 1
    end
    ::continue::
  end

  if count1 > 0 and count2 == 0 then
    return 1, count1, count2
  elseif count2 > 0 and count1 == 0 then
    return -1, count1, count2
  else
    return 0, count1, count2
  end
end

function CleanShipLists()
  -- Iterate through KraylorShips and HumanShips and remove any nil or invalid entries
  for i = #KraylorShips, 1, -1 do
    if KraylorShips[i] == nil or not KraylorShips[i]:isValid() then
      table.remove(KraylorShips, i)
    end
  end
  for i = #HumanShips, 1, -1 do
    if HumanShips[i] == nil or not HumanShips[i]:isValid() then
      table.remove(HumanShips, i)
    end
  end
end

function CommsFactory(target, weaponType, price)

  function StationCommsHandler(comms_source, comms_target)
    if not comms_source:isDocked(comms_target) then
      setCommsMessage(string.format(_("station-comms", "We sell %s for %d"), weaponType, price))
      return
    end

    setCommsMessage(_("station-comms", "You need?"))

    addCommsReply(string.format(_("station-comms", "Buy full complement of %s (%d rep)"), weaponType, price), function()
      if comms_source:getReputationPoints() >= price then
        comms_source:setReputationPoints(comms_source:getReputationPoints() - price)
        comms_source:setWeaponStorage(weaponType, comms_source:getWeaponStorageMax(weaponType))
        setCommsMessage(string.format(_("station-comms", "You have purchased a full complement of %s."), weaponType))
      else
        setCommsMessage(_("station-comms", "You do not have enough reputation points."))
      end
    end)

    addCommsReply(_("station-comms", "Gossip with the locals about salvage"), function()
      if #Pickups.artifacts > 0 then
        local artifact = Pickups.artifacts[Pickups.hintIndex]
        local x, y = artifact:getPosition()
        local sector = getSectorName(x, y)
        setCommsMessage(string.format(_("station-comms", "We've heard about some shiny things in sector %s."), sector))
      else
        setCommsMessage(_("station-comms", "No one seems to know of any more salvage to be had."))
      end
    end)
  end

  target:setCommsFunction(StationCommsHandler)
  return target
end

-- Generate a jagged path for the payload
function GeneratePayloadPath(target)
  local waypoints = {}
  local wayPointDistance = FieldSize / 8
  local payloadX, payloadY = PayloadShip:getPosition()
  local targetX, targetY = target:getPosition()
  local distanceBetween = distance(target, PayloadShip)
  local angleBetween = math.floor(CalculateAngle(payloadX, payloadY, targetX, targetY))
  local steps = math.floor(distanceBetween / wayPointDistance)
  local stepX = (targetX - payloadX) / steps
  local stepY = (targetY - payloadY) / steps

  if Debug then
    local points = Player:getWaypointCount()
    for i = points, 1, -1 do
      Player:commandRemoveWaypoint(i)
    end
  end

  for i = 1, steps do
    local waypointX = payloadX + stepX * i + math.random(-wayPointDistance, wayPointDistance) / i
    local waypointY = payloadY + stepY * i + math.random(-wayPointDistance, wayPointDistance) / i

    --RandPositionInRadius(x, y, maxdist, mindist, anglemin, anglemax)
    local startX = payloadX
    local startY = payloadY
    if i > 1 then
      startX = waypoints[i-1].x
      startY = waypoints[i-1].y
      angleBetween = math.floor(CalculateAngle(payloadX, payloadY, targetX, targetY))
    end
    waypointX, waypointY = RandPositionInRadius(startX, startY, wayPointDistance, wayPointDistance, angleBetween - 60, angleBetween + 60)

    table.insert(waypoints, {x = waypointX, y = waypointY})
    if Debug then
      Player:commandAddWaypoint(waypointX, waypointY)
    end
  end

  return waypoints
end

function IssueOrders(shipList, oppShipList, closestEnemy)
  for _, ship in ipairs(shipList) do
    -- Do nothing if we have captain's orders
    if ship:getOrder() ~= "Attack" and ship:getOrder() ~= "Fly in formation" and ship:getOrder() ~= "Idle" then
      return
    end

    -- Clean out stale attack orders
    if ship:getOrder() == "Attack" and (ship:getOrderTarget() == nil or not ship:getOrderTarget():isValid()) then
      ship:orderIdle() --Temporary until overriden below
    end

    -- Have been aggro'd
    if ship.aggroTarget then
      OrdersAggro(ship, closestEnemy, oppShipList)
    -- Close to payload
    elseif distance(ship, PayloadShip) < 2.5 * PayloadDistanceThreshold then
      OrdersCloseToPayload(ship, closestEnemy, oppShipList)
    -- Contested payload
    elseif PayloadShip.controlledBy == nil then
      OrdersContestedPayload(ship, closestEnemy, oppShipList)
    -- In control of payload
    elseif PayloadShip.controlledBy == ship:getFaction() then
      SafeOrder(ship, PayloadShip, "Fly in formation")
    -- Not in control of payload
    elseif PayloadShip.controlledBy ~= ship:getFaction() then
      OrdersNotInControl(ship, closestEnemy, oppShipList)
    -- Debug catch-all
    else
      print('Unknown state in IssueOrder()')
    end
  end
end

-- Handle aggro
function OnDamaged(self, instigator)
  -- "Note that the callback function must reference something global, otherwise you get an error like "??[convert<ScriptSimpleCallback>::param] Upvalue 1 of function is not a table..."
  local __ = math.abs(0)
  if instigator ~= nil
    and ((instigator:getFaction() == "Humany Navy" and self:getFaction() == "Kraylor")
      or (instigator:getFaction() == "Kraylor" and self:getFaction() == "Humany Navy"))
    and (not self.lastAggroSwitch or getScenarioTime() - self.lastAggroSwitch > 20) then
      self.aggroTarget = instigator
      self.lastAggroSwitch = getScenarioTime()
      self:orderAttack(instigator)
  end
end

function OrdersAggro(ship, closestEnemy, oppShipList)
  if not SafeOrder(ship, ship.aggroTarget, "Attack") then
    ship.aggroTarget = nil
    if not SafeAttackRandom(ship, oppShipList) then
      SafeOrder(ship, PayloadShip, "Fly in formation")
    end
  end
end

function OrdersCloseToPayload(ship, closestEnemy, oppShipList)
  -- if enemy player is close to payload, attack player
  if ship:getFaction() ~= Player:getFaction() and distance(Player, PayloadShip) < 2.5 * PayloadDistanceThreshold then
    SafeOrder(ship, Player, "Attack")
  -- if another enemy is close to payload, attack them
  elseif closestEnemy ~= nil and closestEnemy:isValid() and distance(closestEnemy, PayloadShip) < 2.5 * PayloadDistanceThreshold then
    SafeOrder(ship, closestEnemy, "Attack")
  -- otherwise fly with the paylod
  else
    SafeOrder(ship, PayloadShip, "Fly in formation")
  end
end

function OrdersContestedPayload(ship, closestEnemy, oppShipList)
  -- if enemy player is close to payload, attack player
  if ship:getFaction() ~= Player:getFaction() and distance(Player, PayloadShip) < 2.5 * PayloadDistanceThreshold then
    SafeOrder(ship, Player, "Attack")
  -- if ship is closer than closest enemy, fly with payload
  elseif closestEnemy ~= nil and closestEnemy:isValid() and distance(ship, PayloadShip) < distance(closestEnemy, PayloadShip) then
    SafeOrder(ship, PayloadShip, "Fly in formation")
  -- Otherwise attack a random enemy, or fly with payload if there are none
  elseif not SafeAttackRandom(ship, oppShipList) then
    SafeOrder(ship, PayloadShip, "Fly in formation")
  end
end

function OrdersNotInControl(ship, closestEnemy, oppShipList)
  if not SafeOrder(ship, closestEnemy, "Attack") then
    if not SafeAttackRandom(ship, oppShipList) then
      SafeOrder(ship, PayloadShip, "Fly in formation")
    end
  end
end

function PayloadCommsHandler(comms_source, comms_target)
  if PayloadShip.target ~= nil then
    setCommsMessage(_("payload-comms", "What can I do for you?"))
    addCommsReply(_("payload-comms", "Recalculate route"), function()
      PayloadShip.Waypoints = GeneratePayloadPath(PayloadShip.target)
      setCommsMessage(_("payload-comms", "Route recalculated."))
    end)
  else
    setCommsMessage(_("payload-comms", "No target set for the payload ship."))
  end
end

function RandPositionInRadius(x, y, maxdist, mindist, anglemin, anglemax)
  local angle = math.rad(irandom(anglemin, anglemax))
  local distance = irandom(mindist, maxdist)
  local offsetX = distance * math.cos(angle)
  local offsetY = distance * math.sin(angle)
  return x + offsetX, y + offsetY
end

-- Remove an artifact from the list
function RemovePickupArtifact(artifact)
  for i, art in ipairs(Pickups.artifacts) do
    if art == artifact then
      table.remove(Pickups.artifacts, i)
      break
    end
  end
end

function SafeAttackRandom(ship, shipList, changeTarget)
  local changeTarget = changeTarget or false
  local randomEnemy = shipList[irandom(1, #shipList)]
  return SafeOrder(ship, randomEnemy, "Attack", changeTarget)
end

function SafeOrder(ship, target, order, changeTarget)
  local changeTarget = changeTarget or false
  -- Handle invalid args
  if ship == nil or target == nil or not (ship:isValid() and target:isValid()) then
    return false
  end

  -- Handle case when already executing same order & target
  if (ship:getOrder() == order and ship:getOrderTarget() == target) then
    return true
  end

  if order == "Attack" then
    -- Do not override an existing attack order
    if not (ship:getOrder() == "Attack" and ship:getOrderTarget() ~= target) or changeTarget then
      ship:orderAttack(target)
    end
  elseif order == "Fly in formation" then
    ship:orderFlyFormation(target, irandom(-1200, 1200), irandom(-1200, 1200))
  end

  return true
end

-- Spawn any number of a spaceObject distributed around a given position
function SpawnObjects(object, num, x, y, maxdist, mindist)
  mindist = mindist or 0
  for i = 1, num do
    local rx, ry = RandPositionInRadius(x, y, maxdist, mindist, 0, 360)
    if type(object) == "function" then
      object():setPosition(rx, ry)
    else
      object:setPosition(rx, ry)
    end
  end
end

-- Spawn waves
function SpawnWave(faction)
  local faction = faction or "Both"
  local perpendicularOffset = 1000
  local kraylorCount = #KraylorShips
  local humanCount = #HumanShips

  local queenIndex = irandom(1, WaveSize) -- Queen might not spawn in an attenuated wave
  local spawnKraylorCount = WaveSize
  local spawnHumanCount = WaveSize

  -- Attenuate spawn count to equalize the post-spawn size of each faction
  if faction == "Both" then
    if #KraylorShips > #HumanShips then
      spawnKraylorCount = WaveSize - (kraylorCount - humanCount)
    end
    if #HumanShips > #KraylorShips then
      spawnHumanCount = WaveSize - (humanCount - kraylorCount)
    end
  end

  for i = 1, WaveSize do
    local angle = math.rad(PayloadShip:getRotation() + 90)
    local fsX, fsY = FactionStation:getPosition()
    local esX, esY = KraylorStation:getPosition()

    local enemyX = esX + math.cos(angle) * perpendicularOffset * i
    local enemyY = esY + math.sin(angle) * perpendicularOffset * i
    local humanX = fsX - math.cos(angle) * perpendicularOffset * i
    local humanY = fsY - math.sin(angle) * perpendicularOffset * i

    -- Alternate spawning on either side of the station
    if i % 2 == 0 then
      enemyX = esX - math.cos(angle) * perpendicularOffset * i
      enemyY = esY - math.sin(angle) * perpendicularOffset * i
      humanX = fsX + math.cos(angle) * perpendicularOffset * i
      humanY = fsY + math.sin(angle) * perpendicularOffset * i
    end

    if (faction == "Kraylor" or faction == "Both") and spawnKraylorCount > 0 then
      spawnKraylorCount = spawnKraylorCount - 1
      local enemyTemplate = "Adder MK".. irandom(3,8)
      if i == queenIndex and WaveSize > 1 then
        enemyTemplate = "Phobos M3"
      end
      local enemy = CpuShip():setTemplate(enemyTemplate):setFaction("Kraylor"):setPosition(enemyX, enemyY)
      enemy:setWarpDrive(true)
      enemy:setWeaponStorage("Homing", 4)
      enemy:setWeaponStorage("Nuke", 0)
      enemy:setWeaponStorage("Mine", 0)
      enemy:setWeaponStorage("EMP", 0)
      enemy:setWeaponStorage("HVLI", 4)
      enemy:onTakingDamage(OnDamaged)
      table.insert(KraylorShips, enemy)
    end

    if (faction == "Human Navy" or faction == "Both") and spawnHumanCount > 0 then
      spawnHumanCount = spawnHumanCount - 1
      local human = CpuShip():setTemplate("Adder MK".. irandom(3,8)):setFaction("Human Navy"):setPosition(humanX, humanY)
      human:setWarpDrive(true)
      human:setScannedByFaction("Human Navy", true)
      human:onTakingDamage(OnDamaged)
      table.insert(HumanShips, human)
    end
  end
  WaveSize = math.min(WaveSize + 1, Resistance.maxWaveSize)
end

function StationFactory(weaponType, price)
  local ss = SpaceStation():setTemplate("Medium Station")
  CommsFactory(ss, weaponType, price)
  return ss
end

--
-- Main Loop
--

function CheckWinCondition()
  if not (Player:isValid()
    and PayloadShip:isValid()
    and FactionStation:isValid()
    and KraylorStation:isValid())
  then
    victory("Kraylor")
    return true
  end
  if PayloadShip:isDocked(FactionStation) then
    victory("Kraylor")
    return true
  elseif PayloadShip:isDocked(KraylorStation) then
    victory("Human Navy")
    return true
  end
  if TimeLimit > 0 and getScenarioTime() >= TimeLimit then
    globalMessage(_("payload-comms","You are out of time!"))
    Player:addToShipLog(_("payload-comms", "You are out of time!"), "red")
    victory("Kraylor")
    return true
  end
  return false
end

-- Update the Payload's target based on proximities and scan status
function DeterminePayloadTarget()
  local oldTarget = PayloadShip.target
  local inControl, ourCount, oppositionCount = CheckPayloadControl(PayloadShip, "Human Navy", "Kraylor")

  -- Newly scanned
  if PayloadShip:isScannedBy(Player) and PayloadShip.scanACKd == false then
    if distance(PayloadShip, Player) > PayloadDistanceThreshold then
      Player:addToShipLog(_("payload-comms", "You need to be closer to the Payload to guide it."), "red")
      PayloadShip:setScannedByFaction("Human Navy", false)
    elseif inControl == 1 then
      PayloadShip.scanACKd = true
    else
      Player:addToShipLog(string.format(_("payload-comms", "Must be clear of enemies before the Payload can move. The enemy has %d ships nearby."), oppositionCount), "red")
      PayloadShip:setScannedByFaction("Human Navy", false)
    end
  end

  -- Expire the scan if we stray too far
  if distance(PayloadShip, Player) > PayloadDistanceThreshold then
    PayloadShip.scanACKd = false
    PayloadShip:setScannedByFaction("Human Navy", false)
    PayloadShip.target = nil
    PayloadShip.controlledBy = nil
  end

  -- Adjust target
  if inControl == 0 then
    PayloadShip.target = nil
    PayloadShip.controlledBy = nil
  elseif inControl == -1 then
    PayloadShip.target = FactionStation
    PayloadShip.controlledBy = "Kraylor"
    PayloadShip.scanACKd = false
    PayloadShip:setScannedByFaction("Human Navy", false)
  elseif inControl == 1 and PayloadShip.scanACKd then
    PayloadShip.target = KraylorStation
    PayloadShip.controlledBy = "Human Navy"
  end

  -- Target has changed
  if PayloadShip.target ~= nil and PayloadShip.target ~= oldTarget then
    PayloadShip.Waypoints = GeneratePayloadPath(PayloadShip.target)
    if PayloadShip.target == FactionStation then
      Player:addToShipLog(_("payload-comms", "DANGER, The payload is moving towards the Human Navy station!"), "red")
    elseif PayloadShip.target == KraylorStation then
      Player:addToShipLog(_("payload-comms", "Payload is being delivered to the Kraylor station."), "green")
    end
  end
end

-- Handle enemy and human ship interactions
function HandleNPCs(delta)
  CleanShipLists()

---@diagnostic disable-next-line: undefined-field
if (ClosestEnemies.HumanNavy.ship == nil or ClosestEnemies.Kraylor.ship == nil) or not (ClosestEnemies.HumanNavy.ship:isValid() and ClosestEnemies.Kraylor.ship:isValid()) then
  UpdateClosestEnemies(delta)
end

IssueOrders(KraylorShips, HumanShips, ClosestEnemies.HumanNavy.ship)
IssueOrders(HumanShips, KraylorShips, ClosestEnemies.Kraylor.ship)
end

-- Wave timer and spawn control
function HandleNPCWaves(delta)
  WaveTimer = WaveTimer - delta

  local rand = tonumber(getScenarioSetting("WaveRandomNess"))

  -- When capturing payload, give some time before next wave
  if PayloadShip.controlledBy == "Human Navy" and PayloadShip.LastControlledBy ~= "Human Navy" then
    local timer = Resistance.turnoverWaveDelay
    if rand > 0 then
      timer = timer + irandom(math.floor(-timer * rand), math.floor(timer * rand))
    end
    WaveTimer = math.max(WaveTimer, timer)
  end
  PayloadShip.LastControlledBy = PayloadShip.controlledBy

  -- Max time before next wave if no enemies and not pushing payload
  if #KraylorShips == 0 and PayloadShip.controlledBy == nil then
    local timer = Resistance.idleWaveDelay
    if rand > 0 then
      timer = timer + irandom(math.floor(-timer * rand), math.floor(timer * rand))
    end
    WaveTimer = math.min(WaveTimer, timer)
  end

  -- Are conditions right to spawn a wave?
  local willSpawnIfTime = (PayloadShip.controlledBy ~= nil or #KraylorShips == 0)

  -- Display wave timer
  if string.find(getScenarioSetting("WaveTimer"),"Enabled") then
    local waveTimerMsg = _("wave-timer", "Next wave: " .. math.floor(WaveTimer) .. "s")
    if willSpawnIfTime then
      Player:addCustomInfo("Science","wavetimer_sci", waveTimerMsg)
      Player:addCustomInfo("Operations","wavetimer_ops", waveTimerMsg)
    else
      Player:addCustomInfo("Science","wavetimer_sci", _("wave-timer","Next wave:") .. " --")
      Player:addCustomInfo("Operations","wavetimer_ops", _("wave-timer","Next wave:") .. " --")
    end
  end

  -- Spawn wave if timer is up and pushing payload or no enemies
  if WaveTimer <= 0 then
    WaveTimer = 0
    if willSpawnIfTime then
      SpawnWave()
      -- Rotate pickup hint index
      if #Pickups.artifacts > 0 then
        Pickups.hintIndex = (Pickups.hintIndex % #Pickups.artifacts) + 1
      end
    end
    WaveTimer = Resistance.waveInterval
  end
end

-- Function to handle Payload movement
function HandlePayloadMovement()
  local currentOrder = PayloadShip:getOrder()
  if PayloadShip.target == nil then
    if currentOrder ~= "Idle" then
      PayloadShip:orderIdle()
      Player:addToShipLog(_("payload-comms", "Payload has stopped moving."), "red")
    end
  else
    if #PayloadShip.Waypoints > 0 then
      local waypoint = PayloadShip.Waypoints[1]
      if distance(PayloadShip, waypoint.x, waypoint.y) < 500 then
        table.remove(PayloadShip.Waypoints, 1)
      else
        local targetX, targetY = PayloadShip:getOrderTargetLocation()
        if currentOrder ~= "FlyTowards" or (currentOrder == "FlyTowards" and not (waypoint.x == targetX and waypoint.y == targetY)) then
          PayloadShip:orderFlyTowards(waypoint.x, waypoint.y)
        end
      end
    else
      if distance(PayloadShip, PayloadShip.target) < 2000 then
        PayloadShip:orderDock(PayloadShip.target)
      else
        local x, y = PayloadShip.target:getPosition()
        PayloadShip:orderFlyTowards(x,y)
      end
    end
  end
end

-- Function to update closest enemies
function UpdateClosestEnemies(delta)
  -- Update closest enemies every 5 seconds
  ClosestEnemies.Timer = ClosestEnemies.Timer - delta
  if ClosestEnemies.Timer > 0 then
    return
  end
  ClosestEnemies.Timer = ClosestEnemies.Interval

  -- Reset closest enemies
  ClosestEnemies.Kraylor.ship = nil
  ClosestEnemies.Kraylor.distance = math.huge
  ClosestEnemies.HumanNavy.ship = nil
  ClosestEnemies.HumanNavy.distance = math.huge

  -- Find closest Kraylor ship
  for _, ship in ipairs(KraylorShips) do
    if ship:isValid() then
      local dist = distance(PayloadShip, ship)
      if dist < ClosestEnemies.Kraylor.distance then
        ClosestEnemies.Kraylor.ship = ship
        ClosestEnemies.Kraylor.distance = dist
      end
    end
  end

  -- Find closest Human Navy ship
  for _, ship in ipairs(HumanShips) do
    if ship:isValid() then
      local dist = distance(PayloadShip, ship)
      if dist < ClosestEnemies.HumanNavy.distance then
        ClosestEnemies.HumanNavy.ship = ship
        ClosestEnemies.HumanNavy.distance = dist
      end
    end
  end
end

function UpdateGMButtons(delta)
  -- Update GM buttons every 0.25s
  GMWaveTimerUpdate = GMWaveTimerUpdate - delta
  if GMWaveTimerUpdate > 0 then
    return
  end
  GMWaveTimerUpdate = 0.25
  clearGMFunctions()
  addGMFunction(string.format(_("gm-buttons", "Wave Time +15 (%ds)"), math.floor(WaveTimer)), function() WaveTimer = WaveTimer + 15 end)
  addGMFunction(string.format(_("gm-buttons", "Wave Time -15 (%ds)"), math.floor(WaveTimer)), function() WaveTimer = WaveTimer - 15 end)
  addGMFunction(string.format(_("gm-buttons", "Wave Size + (%d)"), WaveSize), function() WaveSize = WaveSize + 1 end)
  addGMFunction(string.format(_("gm-buttons", "Wave Size - (%d)"), WaveSize), function() WaveSize = math.max(1, WaveSize - 1) end)
  addGMFunction(_("gm-buttons", "Kraylor Wave"), function() SpawnWave("Kraylor") end)
  addGMFunction(_("gm-buttons", "Human Wave"), function() SpawnWave("Human Navy") end)
  addGMFunction(_("gm-buttons", "Both Waves"), function() SpawnWave("Both") end)
  addGMFunction(_("gm-buttons", "New Payload Route"), function() PayloadShip.Waypoints = GeneratePayloadPath(PayloadShip.target) end)
end

function UpdateTraffic()
  for i=#Traffic.new_ships,1,-1 do
    local ship = Traffic.new_ships[i]
    if ship:isValid() and ship:getDockingState() == 1 then
      ship.docked_at = getScenarioTime()
      table.remove(Traffic.new_ships, i)
      table.insert(Traffic.docked_ships, ship)
    end
  end

  for i=#Traffic.docked_ships,1,-1 do
    local ship = Traffic.docked_ships[i]
    if ship:isValid() and getScenarioTime() - ship.docked_at >= 60 then
        table.remove(Traffic.docked_ships, i)
        table.insert(Traffic.leaving_ships, ship)
        ship.dx, ship.dy = RandPositionInRadius(MidX, MidY, FieldSize + 5000, FieldSize, 0, 360)
        ship:orderFlyTowards(ship.dx, ship.dy)
    end
  end

  for i=#Traffic.leaving_ships,1,-1 do
    local ship = Traffic.leaving_ships[i]
    if ship:isValid() and distance(ship, ship.dx, ship.dy) <= 5000 then
        table.remove(Traffic.leaving_ships, i)
        ship:destroy()
    end
  end

  -- Spawn code below here
  if getScenarioTime() - Traffic.timer < 30 or (#Traffic.new_ships + #Traffic.docked_ships + #Traffic.leaving_ships) > 12 then return end

  Traffic.timer = getScenarioTime()
  local faction = Traffic.factions[irandom(1,#Traffic.factions)]
  local type = Traffic.types[irandom(1,#Traffic.types)]
  local x, y = RandPositionInRadius(MidX, MidY, FieldSize + 5000, FieldSize, 0, 360)
  local station = Traffic.stations[irandom(1,#Traffic.stations)]
  local new_ship = CpuShip():setFaction(faction):setTemplate(type):setPosition(x, y):orderDock(station)
  table.insert(Traffic.new_ships, new_ship)
end

-- Main update function
---@diagnostic disable-next-line: lowercase-global
function update(delta)

  if(FirstTickClearHazards and #(getObjectsInRadius(FactionStation.startX, FactionStation.startY, 1)) > 0) then
    FirstTickClearHazards = false
    local clearRadius = 5000
    ClearHazardsNear(FactionStation.startX, FactionStation.startY, clearRadius)
    ClearHazardsNear(KraylorStation.startX, KraylorStation.startY, clearRadius)
    ClearHazardsNear(PayloadShip.startX, PayloadShip.startY, clearRadius)
    ThinPath(FactionStation, KraylorStation)
  end

  if CheckWinCondition() then
    return
  end
  DeterminePayloadTarget()
  HandleNPCs(delta)
  HandleNPCWaves(delta)
  HandlePayloadMovement()
  UpdateClosestEnemies(delta)
  UpdateGMButtons(delta)
  UpdateTraffic()
end