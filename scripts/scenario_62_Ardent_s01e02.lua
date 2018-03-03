-- Name: Ardent_S01_E02
-- Description: Ardent series Episode 2: The Drenni-Navi war continues, although TSN remains neutral, we lost contact with the TSN Albatross near the Drenni-Navien frontier.
--- 
require("utils.lua")
require("utils_ardent.lua")
-- Init is run when the scenario is started. Create your initial world
function init()
   globalMessage("Episode Two:     Lost Souls \n By Andrew Lacey fox_glos@hotmail.com \n Ported by Manuel Bravo manu161@hotmail.com");
-- Variables start
   fleet={}
   VT_TEP=10
-- Time variables
 timeout = 3.0

-- Space Objects
-- Nebula
    tmp_count = 30.0
    for tmp_counter=1,tmp_count do
        tmp_x, tmp_y = vectorFromAngle(-90.0 + (270.0 - -90.0) * (tmp_counter - 1) / tmp_count, 10000.0)
        tmp_x, tmp_y = tmp_x + -60268.0, tmp_y + -20090.0
        tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 7500.0))
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
        Nebula():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 9.0
    for tmp_counter=1,tmp_count do
        tmp_x = -70000.0 + (20000.0 - -70000.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -47000.0 + (-47000.0 - -47000.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 45.0
    for tmp_counter=1,tmp_count do
        tmp_x = 20000.0 + (-80000.0 - 20000.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -70000.0 + (-82000.0 - -70000.0) * (tmp_counter - 1) / tmp_count
        tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 20000.0))
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
        Asteroid():setPosition(tmp_x, tmp_y):setSize(irandom(100,500))
    end
    for tmp_counter=1,tmp_count do
        tmp_x = 20000.0 + (-80000.0 - 20000.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -70000.0 + (-82000.0 - -70000.0) * (tmp_counter - 1) / tmp_count
        tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 20000.0))
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
        VisualAsteroid():setPosition(tmp_x, tmp_y):setSize(irandom(100,500))
    end

-- Stations and ships
   tto = SpaceStation():setTemplate("Small Station"):setPosition(-1000000, -1000000):setCallSign("TSN Command")
  tto:setCommsFunction(tto_calls)
  Ardent = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setCallSign("TSN Ardent"):setPosition(-30000.0, -5000.0):setJumpDrive(false):setWarpDrive(true)
  Albatross = CpuShip():setTemplate("Phobos T3"):setCallSign("Albatross"):setFaction("Human Navy"):setPosition(-5000.0, -10119.0):orderIdle():setCommsScript("")
  Albatross:setDescription("The ship seems to be powered down and adrift. A closer inspection is required to learn more.")
  Albatross:setFrontShieldMax(0.000000):setRearShieldMax(0.000000):setSystemHealth("beamweapons", -1.000000):setSystemHealth("impulse", -1.000000):setSystemHealth("frontshield", -1.000000):setSystemHealth("frontshield", -1.000000):setSystemHealth("rearshield", -1.000000)
  Albatross:setScanningParameters(1, 1)
  SupplyDrop():setFaction("Human Navy"):setPosition(-23591.0, -36647.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0):setCallSign("Energy supplies")
  SupplyDrop():setFaction("Human Navy"):setPosition(9347.0, -30950.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0):setCallSign("Energy supplies")
-- Beam button
Ardent:addCustomButton("engineering", "BEAM", "Beam away team", function()    
                beam={}
                bobj={}
		-- Send Message
                local ax, ay = Ardent:getPosition()
                  for _, obj in ipairs(getObjectsInRadius(ax, ay, 5000)) do
                    if obj.typeName == "SpaceStation" or obj.typeName == "CpuShip" or obj.typeName == "Planet" then
                    local misig = obj:getCallSign()
                    table.insert(beam, misig)
                    bobj[misig]=obj
                    end
                  end
                local n = #beam
                if n == 0 then
                Ardent:addCustomMessage("engineering","Info1","No objects nearby")
                else
                  for key, value in pairs(beam) do
                    Ardent:addCustomButton("engineering", "BEAM"..key , "Beam to "..value, function()
                    Ardent:addCustomMessage("engineering","INFO", func_beam(bobj[value]))
                      for key,value in pairs(beam) do
                    Ardent:removeCustom("BEAM"..key)
                      end
                    if value == "Albatross" and ditt == nil then
                    Ardent:addCustomMessage("relay","INFO2", "This is the away team aboard the Albatross. \n\n Most systems are heavily damaged, probably due to some starship battle. \n There are some bodies and some scape pods have been used. Has science officer not told you? Beam us and the bodies back." )
                    ditt = 1
                    end

                    if value == "Covert Installation" and away_team == 0 then
                   Ardent:removeCustom("BEA")
                   Ardent:addCustomMessage("relay","INFO3","We are aboard the station. We will do this quietly. With any luck well be in and out before they know we were ever here. Hail out.")
                   VT_TEP=20
                   away_team = 1
                    end

                    if value == "Covert Installation" and away_team == 6 then
                   Ardent:addCustomMessage("relay","INFO13","We are back aboard the Ardent. We have to get back to Drenni space and let Command know what happened.")
                   away_team = 7
                    end


                    end) 
                   end
                end
    end) 
away_team = 0
mission_state = missionStartState
end

function func_beam(obj1)
local dis = distance(Ardent,obj1)
local nshield = obj1:getShieldMax(1)
local valid = 0
 if nshield == 0 then  valid = 1 end 

if dis > 4500 then
  return ("Target too far away")
else
    if Ardent:getShieldsActive() then
      return ("We can't beam with our shields active")
    elseif valid == 0 then
      return ("We can't beam. Target shields are active")
    else
local newh = Ardent:getSystemHeat("Reactor") + 0.1 + dis/5000
       Ardent:setSystemHeat("Reactor", newh)
       return ("Away team has been beamed.")
    end
end
end
--Communication scripts
function tto_calls()
  if mission_state == missionStartState then
setCommsMessage([[After the failed peace talks the Navien have been increasingly hostile  towards the TSN. While it hasn t escalated to open conflict yet, eight hours ago,  we lost contact with the TSN Albatross near the Drenni-Navien border.]])
        addCommsReply("Accept", function()
            setCommsMessage([[Find the Albatross, secure her crew and find out what happened.]])
           mission_state = missionAlbatros
        end)
  end
end

-- Start by calling the player
function missionStartState()
    tto:openCommsTo(Ardent)
end
-- Find the Albatros
function missionAlbatros()

if Albatross:isFullyScannedBy(Ardent) and distance(Ardent, Albatross) >= 5001 then
Albatross:setScanned(false)
Ardent:addCustomMessage("science", "FAR_MESSAGE", "Our sensors don't have enough power \n Please approach the target.")
end

if distance(Ardent, Albatross) < 5001.000000 and Albatross:isFullyScannedBy(Ardent) then
 Ardent:addCustomMessage("science", "NEAR_MESSAGE", "There are no lifesigns aboard the Albatross and eight short ranged escape pods have been jettisoned. \n We have lost their trace in the nebulosa. \n Approach each pod to get its contents")
 fleet[1]={}
 EP1 = SupplyDrop():setDescription("'A small evacuation craft with life support but minimal manoeuvring and no weapons."):setCallSign("EP1"):setFaction("Human Navy"):setPosition(-69882.0, -23431.0):setRadarSignatureInfo(0.0, 0.2, 0.3)
 table.insert(fleet[1], EP1)
 EP2 = SupplyDrop():setDescription("'A small evacuation craft with life support but minimal manoeuvring and no weapons."):setCallSign("EP2"):setFaction("Human Navy"):setPosition(-60609.0, -29909.0):setRadarSignatureInfo(0.0, 0.2, 0.3)
 table.insert(fleet[1], EP2)
 EP3 = SupplyDrop():setDescription("'A small evacuation craft with life support but minimal manoeuvring and no weapons."):setCallSign("EP3"):setFaction("Human Navy"):setPosition(-73977.0, -9763.0):setRadarSignatureInfo(0.0, 0.2, 0.3)
 table.insert(fleet[1], EP3)
 EP4 = SupplyDrop():setDescription("'A small evacuation craft with life support but minimal manoeuvring and no weapons."):setCallSign("EP4"):setFaction("Human Navy"):setPosition(-48873.0, -12256.0):setRadarSignatureInfo(0.0, 0.2, 0.3)
 table.insert(fleet[1], EP4)
 EP5 = SupplyDrop():setDescription("'A small evacuation craft with life support but minimal manoeuvring and no weapons."):setCallSign("EP5"):setFaction("Human Navy"):setPosition(-57953.0, -6914.0):setRadarSignatureInfo(0.0, 0.2, 0.3)
 table.insert(fleet[1], EP5)
mission_state = missionEP
VT_TEP=60
end
end

function missionEP()

-- tell the players each minute where to search
if EP1:isValid() and VT_TEP < 0.0 then
EP1:sendCommsMessage(Ardent," ... _ _ _ ... \n ... _ _ _ ...\n\n Seems to come from heading  " .. angleFromVector(Ardent, EP1))
VT_TEP=30
end
if EP2:isValid() and VT_TEP < 0.0 then
EP2:sendCommsMessage(Ardent," ... _ _ _ ... \n ... _ _ _ ...\n\n Seems to come from heading  " .. angleFromVector(Ardent, EP2))
VT_TEP=30
end
if EP3:isValid() and VT_TEP < 0.0 then
EP3:sendCommsMessage(Ardent," ... _ _ _ ... \n ... _ _ _ ...\n\n Seems to come from heading  " .. angleFromVector(Ardent, EP3))
VT_TEP=30
end
if EP4:isValid() and VT_TEP < 0.0 then
EP4:sendCommsMessage(Ardent," ... _ _ _ ... \n ... _ _ _ ...\n\n Seems to come from heading  " .. angleFromVector(Ardent, EP4))
VT_TEP=30
end
if EP5:isValid() and VT_TEP < 0.0 then
EP5:sendCommsMessage(Ardent," ... _ _ _ ... \n ... _ _ _ ...\n\n Seems to come from heading  " .. angleFromVector(Ardent, EP5))
VT_TEP=30
end

if not EP1:isValid() and not EP2:isValid() and not EP3:isValid() and not EP4:isValid() and not EP5:isValid() then

Ardent:addCustomMessage("relay","DOCTOR",[[This is Doctor Xiao in sick bay. The crewmen we recovered from the pods have a lot of lacerations, broken bones and a few plasma burns, but nothing we can't handle. \n\n They say they were attacked by Navien ships and that they took the three other missing escape pods across the border into Navien space. Not sure why but it can't be good.]])

VT_TEP = 10
Hidden = Asteroid():setPosition(-10000.0, -90000.0):setSize(400)
mission_state = missionTAC
end

end


function missionTAC(delta)

if kk == nil then
Hidden = Asteroid():setPosition(-10000.0, -90000.0):setSize(400)
kk = 1
end

if BIP_TP ~= nil then
BIP_TP = BIP_TP - delta
end

if VT_TEP < 0.0 and told1 == nil then
ttime=0
Ardent:addCustomMessage("engineering","TAC",[[The subprocessors of the main sensor array could be recalibrated to detect the residual tachyon trail of the Navien warp engines  near the Albatross and show us where they went.]])
VT_TEP=3
told1 = 7
end

if VT_TEP < 0.0 and told1 == 7 then
Ardent:addCustomButton("engineering", "RECALIBRATE", "Sensor recalibration", function()
          if distance(Ardent, Albatross) >= 5001 then
                Ardent:addCustomMessage("engineering", "RE1", "Too far from target.")
          else
                Ardent:addCustomMessage("engineering", "RE2", "Sensors recalibrated.")
                pl_x, pl_y = vectorFromAngle(angleFromVector(Ardent, Hidden)-90, 20000)
                tmp_x, tmp_y = Ardent:getPosition()
                tmp_x = tmp_x + pl_x
                tmp_y = tmp_y + pl_y
                BIP = VisualAsteroid():setPosition(tmp_x,tmp_y):setSize(5):setRadarSignatureInfo(1., 1., 1.)
                local newh = Ardent:getSystemHeat("Reactor") + 0.7
                Ardent:setSystemHeat("Reactor", newh)
                Ardent:removeCustom("RECALIBRATE")
                told1=2
                BIP_TP = 10
          end
    end)
told1 = 1
VT_TEP=5
end

if told1 == 2 and BIP_TP < 0.0 then
Ardent:addCustomMessage("science","TAC2",[[The tachyons are dissipating quickly]])
BIP:destroy()
pl_x, pl_y = vectorFromAngle(angleFromVector(Ardent, Hidden)-90, 20000)
tmp_x, tmp_y = Ardent:getPosition()
tmp_x = tmp_x + pl_x
tmp_y = tmp_y + pl_y
BIP2 = VisualAsteroid():setPosition(tmp_x,tmp_y):setSize(5):setRadarSignatureInfo(0.8, 0.8, 0.8)
BIP_TP=9
told1 = 3
end

if told1 == 3 and BIP_TP < 0.0 then
BIP2:destroy()
pl_x, pl_y = vectorFromAngle(angleFromVector(Ardent, Hidden)-90, 20000)
tmp_x, tmp_y = Ardent:getPosition()
tmp_x = tmp_x + pl_x
tmp_y = tmp_y + pl_y
BIP3 = VisualAsteroid():setPosition(tmp_x,tmp_y):setSize(5):setRadarSignatureInfo(0.6, 0.6, 0.6)
told1 = 4
BIP_TP=8
end

if told1 == 4 and BIP_TP < 0.0 then

BIP3:destroy()
pl_x, pl_y = vectorFromAngle(angleFromVector(Ardent, Hidden)-90, 20000)
tmp_x, tmp_y = Ardent:getPosition()
tmp_x = tmp_x + pl_x
tmp_y = tmp_y + pl_y
BIP4 = VisualAsteroid():setPosition(tmp_x,tmp_y):setSize(5):setRadarSignatureInfo(0.4, 0.4, 0.4)
BIP_TP=7
told1 = 5
end

if told1 == 5 and BIP_TP < 0.0 then
BIP4:destroy()
told1 = 6
end

    if ifInsideBox(Ardent, 20000.0, -47000.0, -80000.0, -35000.0) and VT_TEP < 0.0 and ttime < 2 then
ttime = ttime + 1
Ardent:addCustomMessage("helms","WARNING","WARNING \n\n You are approaching Navien territory.")
VT_TEP = 10 
    end

    if ifInsideBox(Ardent, 20000.0, -60000.0, -80000.0, -47000.0) and told2 == nil then
Ardent:addCustomMessage("relay","INT1","Intercepted Navien Transmission \n\n DECRYPTED ENCRYPTED MESSAGE \n\n All Warships Report To Stealth Observation Post In Sector A4.\n\n MESSAGE END")
    told2 = 1
    end

    if ifInsideBox(Ardent, 20000.0, -78000.0, -80000.0, -60000.0) and told3 == nil then
Ardent:addCustomMessage("relay","INT2","Intercepted Navien Transmission \n\n DECRYPTED ENCRYPTED MESSAGE \n\n All Warships Report To Stealth Observation Post In Sector A4.\n\n MESSAGE END")
    told3 = 1
    end

    if ifInsideBox(Ardent, 20000.0, -82000.0, -80000.0, -78000.0) and told4 == nil then
Ardent:addCustomMessage("relay","INT3","Intercepted Navien Transmission \n\n DECRYPTED ENCRYPTED MESSAGE \n\n All Warships Report To Stealth Observation Post In Sector A4.\n\n MESSAGE END")
    told4 = 1
    end

    if distance(Ardent, Hidden) < 8000 and told5 == nil then
Ardent:addCustomMessage("relay","INT4","Intercepted Navien Transmission \n\n DECRYPTED ENCRYPTED MESSAGE \n\n All Warships Report To Stealth Observation Post In Sector A4.\n\n MESSAGE END")
    told5 = 1
    end

    if distance(Ardent, Hidden) < 4000 and told6 == nil then
Ardent:addCustomMessage("relay","INT5","Intercepted Navien Transmission \n\n DECRYPTED ENCRYPTED MESSAGE \n\n All Warships Report To Stealth Observation Post In Sector A4.\n\n MESSAGE END")
    told6 = 1
Hidden:destroy()
SBase = SpaceStation():setTemplate("Medium Station"):setCallSign("Covert Installation"):setFaction("Kraylor"):setPosition(-10000.0, -90000.0)
SBase:setDescription("An array of holographic projectors on the exterior of this structure obscure its existence from a distance."):setCommsScript("") 
SBase:setShieldsMax(0)
SBase:setShields(0)
        if fleet[2] == nil then fleet[2] = {} end
        table.insert(fleet[2], Base)
VT_TEP = 10
mission_state = missionBase
    end
end

function missionBase()

if VT_TEP < 0.0 and told7 == nil then
Ardent:removeCustom("INT5")
Ardent:addCustomMessage("relay","BEA","Lieutenant Commander Hail of Security. \n\n This is our chance while their shields are down. I already have an away team prepped and ready to go. Just get us to within 2500km and we ll beam over to the enemy station and search for the missing survivors of the Albatross.")
told7 = 1
end

if VT_TEP < 0.0 and away_team == 1 then
SBase:setShieldsMax(400)
SBase:setShields(400)
Ardent:addCustomMessage("relay","INFO8","Lieutenant Commander Hail of Security. \n\n We ve been detected. Meeting armed resistance. Their shields are up. We can't beam back.")
away_team = 2
VT_TEP = 2
end
-- first wave
if VT_TEP < 0.0 and away_team == 2 then
SBase:sendCommsMessage(Ardent,"ENCRYPTED MESSAGE\n\n466-05830\n51-491-98319-400414\n\nEND MESSAGE")

NV01 = CpuShip():setTemplate("Phobos T3"):setCallSign("NV01"):setFaction("Kraylor"):setPosition(-10000.0, -99950.0):orderAttack(Ardent):setJumpDrive(false):setWarpDrive(true)
        if fleet[8] == nil then fleet[8] = {} end
        table.insert(fleet[8], NV01)
NV02 = CpuShip():setTemplate("Phobos T3"):setCallSign("NV02"):setFaction("Kraylor"):setPosition(-10500.0, -99950.0):orderAttack(Ardent):setJumpDrive(false):setWarpDrive(true)
        table.insert(fleet[8], NV02)
        tmp_x, tmp_y = Ardent:getPosition()
        tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 0.000000, 1000.000000)
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
NV00 = CpuShip():setTemplate("Phobos T3"):setCallSign("NV00"):setFaction("Kraylor"):setPosition(tmp_x, tmp_y):orderAttack(Ardent):setJumpDrive(false):setWarpDrive(true)
        table.insert(fleet[8], NV00)
away_team = 3
VT_TEP = 60
end
-- second wave
if VT_TEP < 0.0 and away_team == 3 then
NV03 = CpuShip():setTemplate("Atlantis X23"):setCallSign("NV03"):setFaction("Kraylor"):setPosition(-15000.0, -99950.0):orderAttack(Ardent):setJumpDrive(false):setWarpDrive(true)
NV04 = CpuShip():setTemplate("Phobos T3"):setCallSign("NV04"):setFaction("Kraylor"):setPosition(-15500.0, -99950.0):orderAttack(Ardent):setJumpDrive(false):setWarpDrive(true)
        table.insert(fleet[8], NV03)
        table.insert(fleet[8], NV04)
away_team = 4
VT_TEP = 60
end

if VT_TEP < 0.0 and away_team == 4 then
Ardent:addCustomMessage("relay","INFO8","Lieutenant Commander Hail of Security. \n\n We ve found the lost Albatross crewmen. They're dead. All dead. The Navien implanted their lave into them and it looks like they ve been eaten alive from the inside out! Wait for us while we take down the shields")
NV05 = CpuShip():setTemplate("Atlantis X23"):setCallSign("NV05"):setFaction("Kraylor"):setPosition(-12000.0, -99950.0):orderAttack(Ardent):setJumpDrive(false):setWarpDrive(true)
NV06 = CpuShip():setTemplate("Atlantis X23"):setCallSign("NV06"):setFaction("Kraylor"):setPosition(-12500.0, -99950.0):orderAttack(Ardent):setJumpDrive(false):setWarpDrive(true)
        table.insert(fleet[8], NV05)
        table.insert(fleet[8], NV06)
VT_TEP = 120
away_team = 5
end

if VT_TEP < 0.0 and away_team == 5 then
Ardent:addCustomMessage("relay","INFO10","Lieutenant Commander Hail of Security. \n\n We ve taken out their shield generators. Beam us back!")
SBase:setShieldsMax(0)
SBase:setShields(0)
away_team = 6
end

if away_team < 7 and not SBase:isValid() then
Ardent:addCustomMessage("relay","INFO15","The away team aboard the station has been killed. \n\n Our Federation may not be happy about proofs of an attack to a neutral faction\n\n Return to Drenni space to contact TSN Command.")
   if away_team == 3 then
NV03 = CpuShip():setTemplate("Phobos T3"):setCallSign("NV03"):setFaction("Kraylor"):setPosition(-15000.0, -99950.0):orderAttack(Ardent):setJumpDrive(false):setWarpDrive(true)
NV04 = CpuShip():setTemplate("Phobos T3"):setCallSign("NV04"):setFaction("Kraylor"):setPosition(-15500.0, -99950.0):orderAttack(Ardent):setJumpDrive(false):setWarpDrive(true)
NV05 = CpuShip():setTemplate("Phobos T3"):setCallSign("NV05"):setFaction("Kraylor"):setPosition(-12000.0, -99950.0):orderAttack(Ardent):setJumpDrive(false):setWarpDrive(true)
NV06 = CpuShip():setTemplate("Phobos T3"):setCallSign("NV06"):setFaction("Kraylor"):setPosition(-12500.0, -99950.0):orderAttack(Ardent):setJumpDrive(false):setWarpDrive(true)
        table.insert(fleet[8], NV03)
        table.insert(fleet[8], NV04)
        table.insert(fleet[8], NV05)
        table.insert(fleet[8], NV06)
   elseif away_team == 4 then
NV05 = CpuShip():setTemplate("Phobos T3"):setCallSign("NV05"):setFaction("Kraylor"):setPosition(-12000.0, -99950.0):orderAttack(Ardent):setJumpDrive(false):setWarpDrive(true)
NV06 = CpuShip():setTemplate("Phobos T3"):setCallSign("NV06"):setFaction("Kraylor"):setPosition(-12500.0, -99950.0):orderAttack(Ardent):setJumpDrive(false):setWarpDrive(true)
        table.insert(fleet[8], NV05)
        table.insert(fleet[8], NV06)
    end
away_team = 7
end


if away_team == 7 and ifInsideBox(Ardent, 20000.0, -47000.0, -80000.0, 0.0) then
   globalMessage("TSN COMMAND: \n Our Federation would be noticed \n of this Navi offense inmediatly")
mission_state = missionFINAL
end

if away_team < 7 and ifInsideBox(Ardent, 20000.0, -47000.0, -80000.0, 0.0) then
   globalMessage("TSN COMMAND: \n Our Federation may not be happy about \n proofs of an attack to a neutral faction")
mission_state = missionFINAL
end


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

function update(delta)

VT_TEP = VT_TEP - delta

    if not Ardent:isValid() then
        timeout = timeout - delta
        if timeout < 0.0 then
            victory("Kraylor")
            return
        end
    end

    if mission_state == missionFINAL and away_team < 7 then
        timeout = timeout - delta
        if timeout < 0.0 then
            victory("Kraylor")
            return
        end
    end

    if mission_state == missionFINAL and away_team == 7 then
    timeout = timeout - delta
         if timeout < 0.0 then
            victory("Human Navy")
            return
         end
    end

    if mission_state ~= nil then
        mission_state(delta)
    end

end
