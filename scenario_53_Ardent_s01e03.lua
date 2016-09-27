-- Name: Ardent_S01_E03
-- Description: The Ardent is assigned to defend TSN outposts.
-- Type: Mission
--
require("utils.lua")
require("utils_ardent.lua")
-- Init is run when the scenario is started. Create your initial world
function init()
timeout=5
TIME1 = 0
fleet={}
-- Player
 globalMessage("Episode Three:     Through The Looking Glass\nBy Andrew Lacey\nfox_glos@hotmail.com \n \n Ported by Manuel Bravo \n manu161@hotmail.com");
  tto = SpaceStation():setTemplate("Small Station"):setPosition(-1000000, -1000000):setCallSign("TSN Command")
  tto:setCommsFunction(tto_calls)
  Ardent = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setCallSign("TSN Ardent"):setPosition(-30000.0, -50000.0):setJumpDrive(false):setWarpDrive(true)
-- Artifact
ModelData():setName("artifactrift"):setScale(30):setRadius(500):setMesh("Artifact1.obj"):setTexture("electric_sphere_texture.png")
-- Tractor beam
Beamtic=1
Artitic=0.1
locked = 0
Ardent:addCustomButton("engineering", "Tractor", "Tractor beam", function()
beam={}
bobj={}
-- Send Message
local ax, ay = Ardent:getPosition()
for _, obj in ipairs(getObjectsInRadius(ax, ay, 1000)) do
   if obj.typeName == "SpaceStation" or obj.typeName == "CpuShip" then
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
         if value == "Verran" then
         Ardent:addCustomButton("engineering", "UNBEAM", "Unlock tractor beam", nobeam)
         Ardent:addCustomButton("engineering", "BEAM"..key , "Tractor beam "..value, function()
           Ardent:addCustomMessage("engineering","INFO2","Tractor beam locked")
           locked = 1
           Ardent:removeCustom("BEAM"..key)
           end)
         else
           Ardent:addCustomMessage("engineering","INFO1","It's impossible to lock the tractor beam on "..value)
         end
       end
    end
end)




-- Space
        tmp_count = 10.0
        for tmp_counter=1,tmp_count do
            tmp_x = 10000.0 + (10000.0 - 10000.0) * (tmp_counter - 1) / tmp_count
            tmp_y = -100000.0 + (0.0 - -100000.0) * (tmp_counter - 1) / tmp_count
            Mine():setPosition(tmp_x, tmp_y)
        end
tmp_count = 100.0
        for tmp_counter=1,tmp_count do
            tmp_x, tmp_y = vectorFromAngle(210.0 + (50.0 - 210.0) * (tmp_counter - 1) / tmp_count, 50000.0)
            tmp_x, tmp_y = tmp_x + -21811.0, tmp_y + -48754.0
            tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 10000.0))
            tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
            Asteroid():setPosition(tmp_x, tmp_y)
        end
tmp_count = 100.0
        for tmp_counter=1,tmp_count do
            tmp_x, tmp_y = vectorFromAngle(210.0 + (50.0 - 210.0) * (tmp_counter - 1) / tmp_count, 50000.0)
            tmp_x, tmp_y = tmp_x + -21811.0, tmp_y + -48754.0
            tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 10000.0))
            tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
            VisualAsteroid():setPosition(tmp_x, tmp_y)
        end
tmp_count = 10
        for tmp_counter=1,tmp_count do
            tmp_x, tmp_y = vectorFromAngle(-90.0 + (270.0 - -90.0) * (tmp_counter - 1) / tmp_count, 10000.0)
            tmp_x, tmp_y = tmp_x + -69348.0, tmp_y + -92552.0
            tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 5000.0))
            tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
            Asteroid():setPosition(tmp_x, tmp_y)
        end
tmp_count = 10
        for tmp_counter=1,tmp_count do
		       tmp_x, tmp_y = vectorFromAngle(-90.0 + (270.0 - -90.0) * (tmp_counter - 1) / tmp_count, 10000.0)
            tmp_x, tmp_y = tmp_x + -69348.0, tmp_y + -92552.0
            tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 5000.0))
            tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
            VisualAsteroid():setPosition(tmp_x, tmp_y)
        end
-- Stations
DS1 = SpaceStation():setTemplate("Small Station"):setCallSign("DS1"):setFaction("Human Navy"):setPosition(-50000.0, -78000.0)
DS2 = SpaceStation():setTemplate("Small Station"):setCallSign("DS2"):setFaction("Human Navy"):setPosition(-50000.0, -42000.0)
--
mission_state = missionStartState
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

-- Communications with command
function tto_calls()
  if mission_state == missionStartState then
     setCommsMessage([[Your grim discovery of the fate of the missing Albatross crewmen confirms reports that it has become fashionable, amongst the Navien aristocracy, to inject their lave into sentient hosts. We couldn\'t prove it until now. When our diplomatic envoy confronted the Navien high queen she had them executed for their insolence. In the early hours of this morning she officially declared war against the USFP and the Drenni. Drenni membership in the USFP has been rushed through so that we can face the coming conflict united.]])
        addCommsReply("Accept", function()
            setCommsMessage([["Defend all TSN assets and provide aid to any USFP citizens in your quadrant should the Navien attack here.]])
NV01 = CpuShip():setTemplate("Phobos T3"):setCallSign("NV01"):setFaction("Kraylor"):setPosition(3471.0, -77063.0)
NV01:setDescription("A light but powerful warship."):orderAttack(Ardent)
if fleet[1] == nil then fleet[1] = {} end
        table.insert(fleet[1], NV01)
NV02 = CpuShip():setTemplate("Starhammer II"):setCallSign("NV02"):setFaction("Kraylor"):setPosition(1157.0, -74214.0)
NV02:setDescription("One of the most heavily armed starship in the Navien fleet."):orderAttack(Ardent)
NV03 = CpuShip():setTemplate("Atlantis X23"):setCallSign("NV03"):setFaction("Kraylor"):setPosition(2581.0, -68339.0)
        table.insert(fleet[1], NV03)
NV03:setDescription("A well shielded ship used to ensnare and destroy enemies."):orderAttack(Ardent):setJumpDrive(True)
NV04 = CpuShip():setTemplate("Phobos T3"):setCallSign("NV04"):setFaction("Kraylor"):setPosition(0.0, -30000.0)
if fleet[2] == nil then fleet[2] = {} end
table.insert(fleet[2], NV04)
NV04:setDescription("A light but powerful warship."):orderAttack(Ardent)
NV05 = CpuShip():setTemplate("Phobos T3"):setCallSign("NV05"):setFaction("Kraylor"):setPosition(1000.0, -30000.0)
table.insert(fleet[2], NV05)
NV05:setDescription("A light but powerful warship."):orderAttack(Ardent)

           mission_state = missionDefend
        end)
  end
end

function nobeam()
             locked = 0
             Ardent:addCustomMessage("engineering","INFO3","Tractor beam unlocked")
             Ardent:removeCustom("UNBEAM")
             return
end

function Alien_calls()
setCommsMessage("Strange noises come from the Alien ship :\n\n" ..random(1,999999999))

end
-- Begin mission
function missionStartState()
    tto:openCommsTo(Ardent)
end
-- Defend waves
function missionDefend()
if countFleet(1) == 0.000000 and countFleet(2) == 0.000000  then
Discovery = CpuShip():setTemplate("Tug"):setCallSign("Discovery"):setFaction("Human Navy"):setPosition(-11128.0, -50713.0):orderRoaming():setCommsFunction(Discovery_calls)
Discovery:setDescription("The ship is registered to Dr Jennings.  Dr Jennings was a leading theoretical physicist until he was ostracised from the scientific community because of his more eccentric multidimensional theories.")
 mission_state = missionCivilian
 TIME1 = 15.
end
end

function Verran_calls()

if mission_state == missionAlienchase then
  if locked == 0 then
setCommsMessage([[Our ship is secured. Pull us back to the opening you came through so we can get to normal space]])
  else
setCommsMessage([[Let's get fast to the opening, I think that we have attracted the attention of those things...]])
  end
end

if mission_state == missionBack then
setCommsMessage([[Thank you! I thought that you were going to let us die as you did last time]])
end

end


function Discovery_calls()

if mission_state == missionDefend then
     setCommsMessage([[No reply]])
end

if mission_state == missionCivilian then
     setCommsMessage([[I need to search for the exact location of the space-continuum tear]])
end

if mission_state == missionExperiment then
     setCommsMessage([[I'm performing a delicate and dangerous experiment. Please don't disturb it]])
end


end

function missionCivilian()

if Discovery:isScannedBy(Ardent) then
Ardent:addCustomMessage("science", "DIS_MESSAGE", "Dr Jennings was a leading theoretical physicist until he was ostracised from the scientific community because of his more eccentric multidimensional theories.")
end

if TIME1 < 0.0 and dit1 == nil then
Ardent:addCustomMessage("relay","DIS_CONV","INTERCEPTED COMMUNICATIONS \n\n\n TSN Command TO Discovery \n\n This is TSN Command to Civilian vessel. You are in great danger! Withdraw from the conflict zone immediately!\n\n\nDiscovery TO TSN Command\n\nI will not comply. I am on an urgent humanitarian mission. Jennings out!")
dit1=1
TIME1=10
tmp_x,tmp_y = Discovery:getPosition()
tmp_x = tmp_x + 2230
tmp_y = tmp_y - 4000
NV06 = CpuShip():setTemplate("Phobos T3"):setCallSign("NV06"):setFaction("Kraylor"):setPosition(tmp_x,tmp_y)
if fleet[3] == nil then fleet[3] = {} end
table.insert(fleet[3], NV06)
NV06:setDescription("A light but powerful warship."):orderAttack(Ardent)
end
if TIME1 < 0.0 and dit1 == 1 then
Discovery:sendCommsMessage(Ardent,"My ship is under attack! My name is Dr Jennings. My wife was the Comms officer aboard the Verran. You left her to die but I can save her. I can save all of them. Please I need your help!")
dit1 = 2
end

if dit1 == 2 and Ardent:isCommsInactive() then
tto:sendCommsMessage(Ardent,"Defend Dr Jennings ship. He might be a bit unstable but he is one of the USFP greatest minds.")
dit1 = 3
end

if dit1 == 3 and not NV06:isValid() and Ardent:isCommsInactive()  then
Discovery:sendCommsMessage(Ardent,"I know that no one believes me but the shield harmonics of the Verran and the singularities resonance were at identical frequencies. I theorise that rather than being destroyed in its wake the Verran instead slipped through the cracks between dimensions. They could still be alive, trapped in some kind of multidimensional buffer.I have tracked the locations of interdimensional filaments that if exposed to sufficient Warp energy should rupture and allow access to where I have calculated the Verran to be stranded")
dit1 = 4
tmp_x,tmp_y = Discovery:getPosition()
tmp_x = tmp_x + 4000
tmp_y = tmp_y - 2230
NV07 = CpuShip():setTemplate("Phobos T3"):setCallSign("NV07"):setFaction("Kraylor"):setPosition(tmp_x,tmp_y)
table.insert(fleet[3], NV07)
NV07:setDescription("A light but powerful warship."):orderAttack(Ardent)
end

if dit1 == 4 and Ardent:isCommsInactive() then
Discovery:sendCommsMessage(Ardent,"I need you to defend my ship as I channel my warp energy into the filament at this exact location.")
dit2 = 0
Discovery:orderIdle()
mission_state = missionExperiment
end
end

function missionExperiment()

if countFleet(3) == 0 and dit2 == 0 then
tmp_x,tmp_y = Discovery:getPosition()
tmp_x = tmp_x + 5000
NV08 = CpuShip():setTemplate("Starhammer II"):setCallSign("NV08"):setFaction("Kraylor"):setPosition(tmp_x, tmp_y)
NV08:setDescription("One of the most heavily armed starship in the Navien fleet."):orderAttack(Ardent)
        if fleet[4] == nil then fleet[4] = {} end
table.insert(fleet[4], NV08)
TIME1=30
Discovery:sendCommsMessage(Ardent,"It didn't work. I don't understand it.")
dit2 = 1
end

if dit2 == 1 and TIME1 < 0.0 then
Discovery:sendCommsMessage(Ardent,"I see now. My calculations were off. Well off. It would take a veritable warp core overload to rupture a filament.")
dit2 = 2
end

if dit2 == 2 and countFleet(4) == 0.0 then
Discovery:sendCommsMessage(Ardent,"There is only one thing for it. Keep your distance, I am setting my warp core to overload in less than thirty seconds.")
TIME1=15
dit2 = 3
end

if dit2 == 3 and TIME1 < 0.0 then
Ardent:addCustomMessage("relay", "DIDIE","Please, save her. She's all that matters.")
dit2 = 4
TIME1 = 5
end

if dit2 == 4 and TIME1 < 0.0 then
    if Discovery ~= nil and Discovery:isValid() then Discovery:destroy() end
        tmp_count = 10
        for tmp_counter=1,tmp_count do
            tmp_x, tmp_y = vectorFromAngle(-90.0 + (270.0 - -90.0) * (tmp_counter - 1) / tmp_count, 2000.0)
            tmp_x, tmp_y = tmp_x + -11128.0, tmp_y + -50713.0
            Nebula():setPosition(tmp_x, tmp_y)
        end
Ardent:addCustomMessage("science", "Tear","Some kind of subspace tear is opening in Sector C4.")
dit3 = 0
TIME=10
mission_state=missionVerran
end
end

function missionVerran()


if dit2 == nil and TIME1 < 0.0 then
    if Discovery ~= nil and Discovery:isValid() then Discovery:destroy() end
        tmp_count = 10
        for tmp_counter=1,tmp_count do
            tmp_x, tmp_y = vectorFromAngle(-90.0 + (270.0 - -90.0) * (tmp_counter - 1) / tmp_count, 2500.0)
            tmp_x, tmp_y = tmp_x + -11128.0, tmp_y + -50713.0
            Nebula():setPosition(tmp_x, tmp_y)
        end
Ardent:addCustomMessage("science", "Tear","Some kind of subspace tear is opening in Sector C4.")
dit3 = 0
dit2 = 1
end


if dit3 == 0 and TIME1 < 0.0 then
Ardent:addCustomMessage("relay","MA1","Mayday... To... Please... We... Detect...")
TIME1 = 5
dit3 = 1
end

if dit3 == 1 and TIME1 < 0.0 then
Ardent:addCustomMessage("relay","MA2","Mayday! To any vessel! We are on the other side of the rift. Engines damaged. Life support failing. Please enter the rift and assist.")
dit3 = 2
end

if ifInsideSphere(Ardent, -11128.0, -50713.0, 3800.000000) then

        for _, obj in ipairs(getObjectsInRadius(-30000.0, -50000.0, 100000.000000)) do
            if obj.typeName == "Mine" then obj:destroy() end
        end
        for _, obj in ipairs(getObjectsInRadius(-30000.0, -50000.0, 100000.000000)) do
            if obj.typeName == "Asteroid" then obj:destroy() end
        end
        for _, obj in ipairs(getObjectsInRadius(-30000.0, -50000.0, 100000.000000)) do
            if obj.typeName == "Nebula" then obj:destroy() end
        end
        if DS1 ~= nil and DS1:isValid() then DS1:destroy() end
        if DS2 ~= nil and DS2:isValid() then DS2:destroy() end

        if Ardent ~= nil and Ardent:isValid() then
            local x, y = Ardent:getPosition()
            Ardent:setPosition(-30000.0, y)
        end
        tmp_count = 10
        for tmp_counter=1,tmp_count do
            tmp_x, tmp_y = vectorFromAngle(-90.0 + (270.0 - -90.0) * (tmp_counter - 1) / tmp_count, 1000.0)
            tmp_x, tmp_y = tmp_x + -30000.0, tmp_y + -50000.0
            Nebula():setPosition(tmp_x, tmp_y)
        end
   Verran = CpuShip():setTemplate("Flavia"):setCallSign("Verran"):setFaction("Human Navy"):setPosition(10000.0, -88000.0):orderRoaming():setCommsFunction(Verran_calls)
   Verran:setDescription("The luxury liner is badly damaged but there are multiple lifesigns through the ship.")
Verran:sendCommsMessage(Ardent,"Thank you! I don't know how much longer we can hold out. I am Sarah. I was the Comms officer but most of the command crew did not make it so now I am acting Captain. We are in a bad way. If you can tractor beam us out of here we would all be forever in your debt.")
Ardent:addCustomMessage("engineering","MA2","Come to within 1U to lock a tractor beam onto the Verran")
mission_state = missionAlienchase
end
end

function missionAlienchase()
if Acreat == nil then
UN01 = CpuShip():setTemplate("Ktlitan Destroyer"):setCallSign("UN01"):setFaction("Ghosts"):setPosition(-7000.0, -70000.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN02 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("UN02"):setFaction("Ghosts"):setPosition(-5787.0, -53917.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN03 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("UN03"):setFaction("Ghosts"):setPosition(-18579.0, -65668.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN04 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("UN04"):setFaction("Ghosts"):setPosition(-18374.0, -82775.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN05 = CpuShip():setTemplate("Ktlitan Destroyer"):setCallSign("UN05"):setFaction("Ghosts"):setPosition(-44000.0, -68000.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN06 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("UN06"):setFaction("Ghosts"):setPosition(-46431.0, -54956.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN07 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("UN07"):setFaction("Ghosts"):setPosition(-70579.0, -65668.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN08 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("UN08"):setFaction("Ghosts"):setPosition(-52374.0, -87775.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN09 = CpuShip():setTemplate("Ktlitan Feeder"):setCallSign("UN09"):setFaction("Ghosts"):setPosition(-63472.0, -88457.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN10 = CpuShip():setTemplate("Ktlitan Feeder"):setCallSign("UN10"):setFaction("Ghosts"):setPosition(10949.0, -73146.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN11 = CpuShip():setTemplate("Ktlitan Destroyer"):setCallSign("UN11"):setFaction("Ghosts"):setPosition(-6338.0, -27082.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN12 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("UN12"):setFaction("Ghosts"):setPosition(1231.0, -14038.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN13 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("UN13"):setFaction("Ghosts"):setPosition(-25728.0, -24897.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN14 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("UN14"):setFaction("Ghosts"):setPosition(-17712.0, -39857.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN15 = CpuShip():setTemplate("Ktlitan DestroyeR"):setCallSign("UN15"):setFaction("Ghosts"):setPosition(-49941.0, -25965.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN16 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("UN16"):setFaction("Ghosts"):setPosition(-33917.0, -14392.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN17 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("UN17"):setFaction("Ghosts"):setPosition(-69917.0, -22750.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN18 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("UN18"):setFaction("Ghosts"):setPosition(-66499.0, -45906.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN19 = CpuShip():setTemplate("Ktlitan Feeder"):setCallSign("UN19"):setFaction("Ghosts"):setPosition(-51365.0, -35757.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
UN20 = CpuShip():setTemplate("Ktlitan Feeder"):setCallSign("UN20"):setFaction("Ghosts"):setPosition(11611.0, -30228.0):orderAttack(Ardent):setCommsFunction(Alien_calls)
Acreat=1
end
--
if locked == 1 and ifInsideSphere(Ardent, -30000.0, -50000.0, 1800.000000) then
mission_state = missionBack
dit4 = 0

        if UN01 ~= nil and UN01:isValid() then UN01:destroy() end
        if UN02 ~= nil and UN02:isValid() then UN02:destroy() end
        if UN03 ~= nil and UN03:isValid() then UN03:destroy() end
        if UN04 ~= nil and UN04:isValid() then UN04:destroy() end
        if UN05 ~= nil and UN05:isValid() then UN05:destroy() end
        if UN06 ~= nil and UN06:isValid() then UN06:destroy() end
        if UN07 ~= nil and UN07:isValid() then UN07:destroy() end
        if UN08 ~= nil and UN08:isValid() then UN08:destroy() end
        if UN09 ~= nil and UN09:isValid() then UN09:destroy() end
        if UN10 ~= nil and UN10:isValid() then UN10:destroy() end
        if UN11 ~= nil and UN11:isValid() then UN11:destroy() end
        if UN12 ~= nil and UN12:isValid() then UN12:destroy() end
        if UN13 ~= nil and UN13:isValid() then UN13:destroy() end
        if UN14 ~= nil and UN14:isValid() then UN14:destroy() end
        if UN15 ~= nil and UN15:isValid() then UN15:destroy() end
        if UN16 ~= nil and UN16:isValid() then UN16:destroy() end
        if UN17 ~= nil and UN17:isValid() then UN17:destroy() end
        if UN18 ~= nil and UN18:isValid() then UN18:destroy() end
        if UN19 ~= nil and UN19:isValid() then UN19:destroy() end
        if UN20 ~= nil and UN20:isValid() then UN20:destroy() end
        for _, obj in ipairs(getObjectsInRadius(-30000.0, -50000.0, 3000.000000)) do
            if obj.typeName == "Nebula" then obj:destroy() end
        end
        tmp_count = 10
        for tmp_counter=1,tmp_count do
            tmp_x, tmp_y = vectorFromAngle(-90.0 + (270.0 - -90.0) * (tmp_counter - 1) / tmp_count, 1000.0)
            tmp_x, tmp_y = tmp_x + -11128.0, tmp_y + -50713.0
            Nebula():setPosition(tmp_x, tmp_y)
        end
        if Ardent ~= nil and Ardent:isValid() then
            local x, y = Ardent:getPosition()
            Ardent:setPosition(-11128.0, y)
        end
        if Verran ~= nil and Verran:isValid() then
            local x, y = Verran:getPosition()
            Verran:setPosition(-10900.0, y)
        end
end
end

function missionBack()

if dit4 == 0 then 
Verran:sendCommsMessage(Ardent,"You did it, we are out! I never thought we would actually make it. I get to see my family again and it's all because of you.")
dit4 = 1
TIME1 = 11
end

if dit4 == 1 and TIME1 < 0.0 then
Ardent:addCustomMessage("science","OUT","An unknown object is coming through the rift.")
RIFTA = Artifact():setModel("artifactrift"):setPosition(-11128.0,-50713.0):setDescription("Unknown object")
acx = 3
acy = 1
dit4 = 2
end

end
	--
function update(delta)

    if not Ardent:isValid() then
        timeout = timeout - delta
        if timeout < 0.0 then
            victory("Kraylor")
            return
        end
    end

    if mission_state == missionExperiment or mission_state == missionCivilian then
    if not Discovery:isValid() then
        timeout = timeout - delta
        if timeout < 0.0 then
            victory("Kraylor")
            return
        end
    end
    end
    if mission_state == missionAlienchase then
    if not Verran:isValid() then
        timeout = timeout - delta
        if timeout < 0.0 then
            victory("Independent")
            return
        end
    end
    end


if RIFTA ~= nil and RIFTA:isValid() then
Artitic= Artitic - delta
if Artitic < 0.0 then
tmp_x, tmp_y = RIFTA:getPosition()
acx = acx + 2
acy = acy + 1
RIFTA:setPosition( tmp_x + acx, tmp_y + acy)
Artitic=0.1
end
  if tmp_x > 20000 then
    globalMessage("The object has left the quadrant.\n\n\n Mission Completed\n\nThanks for playing.")
    timeout = timeout - delta
         if timeout < 0.0 then
            victory("Human Navy")
            return
         end
  end
end

if locked == 1 then
    AH=Ardent:getSystemHealth("Reactor")
    AV=Ardent:getVelocity()
    if AH <= 0.0 or AV >= 900 then
      nobeam()
    end
    if distance(Ardent, Verran) > 500 then
        tmp_x, tmp_y = Ardent:getPosition()
        tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 180.000000, 500.)
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
        Verran:setPosition(tmp_x, tmp_y)
    end
   Beamtic = Beamtic - delta
   if Beamtic < 0.0 then
       local newh = Ardent:getSystemHeat("Reactor") + 0.01
       Ardent:setSystemHeat("Reactor", newh)
       local newe = Ardent:getEnergyLevel()
       Ardent:setEnergyLevel(newe - 1)
       Beamtic = 1
   end
end



	TIME1 = TIME1 - delta
    if mission_state ~= nil then
        mission_state(delta)
    end

	end
