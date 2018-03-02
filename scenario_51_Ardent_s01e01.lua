-- Name: Ardent_S01_E01
-- Description: Ardent series Episode 1
--- The human want to mediate in the war between the allied Drenni and the Navi. Bring a diplomat to a secret meeting.
-- Type: Mission
require("utils.lua")
require("utils_ardent.lua")
-- Init is run when the scenario is started. Create your initial world
function init()
   fleet={}
   sabo={}
-- Inicia tiempo
    globalMessage("Episode One:     Cause And Effect \n By Andrew Lacey fox_glos@hotmail.com \n Ported by Manuel Bravo manu161@hotmail.com");
-- Crea nave
  Ardent = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setCallSign("TSN Ardent"):setPosition(15000.0, -95000.0):setJumpDrive(false):setWarpDrive(true):setWarpSpeed(500)
    Sec = Nebula():setPosition(-40728.0,-59161.0):setCommsFunction(Security)
-- Crea Comando
   tto = SpaceStation():setTemplate("Small Station"):setPosition(-1000000, -1000000):setCallSign("TSN Command")
   temp_transmission_object = SpaceStation():setTemplate("Small Station"):setPosition(-1000000, -1000000)
-- Crea asteroides
placeRandomsphere(Asteroid, 50, 9075, -71750, 6500)
placeRandomsphere(VisualAsteroid, 50, 9075, -71750, 6500)
placeRandomline(Asteroid, 8, -79745, -78272, -68745, -76272, 3000)
placeRandomline(VisualAsteroid, 8, -79745, -78272, -68745, -76272, 3000)
placeRandomline(Asteroid,11, -57942.0, -84056.0, -67000.0, -76056.0, 3000)
placeRandomline(VisualAsteroid,11, -57942.0, -84056.0, -67000.0, -76056.0, 3000)
placeRandomline(Asteroid, 6, -56041.0, -85738.0, -50041.0, -93138.0, 3000)
placeRandomline(VisualAsteroid, 6, -56041.0, -85738.0, -50041.0, -93138.0, 3000)
placeRandomline(Asteroid, 4, -54546.0, -99420.0, -48146.0, -95520.0, 3000)
placeRandomline(VisualAsteroid, 4, -54546.0, -99420.0, -48146.0, -95520.0, 3000)
placeRandomsphere(Asteroid, 8, -70000, -91000, 6500)
placeRandomsphere(VisualAsteroid, 8, -70000, -91000, 6500)
placeRandomsphere(Asteroid,15, -30385.0, -77581.0, 15000)
placeRandomsphere(VisualAsteroid,15, -30385.0, -77581.0, 15000)
-- Crea Nebulas
    tmp_count = 10
    for tmp_counter=1,tmp_count do
        tmp_x, tmp_y = vectorFromAngle(20.0 + (90.0 - 20.0) * (tmp_counter - 1) / tmp_count, 50711.0)
        tmp_x, tmp_y = tmp_x + -40728.0, tmp_y + -59161.0
        tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 13044.0))
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
        Nebula():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 11
    for tmp_counter=1,tmp_count do
        tmp_x, tmp_y = vectorFromAngle(30.0 + (100.0 - 30.0) * (tmp_counter - 1) / tmp_count, 35711.0)
        tmp_x, tmp_y = tmp_x + -30728.0, tmp_y + -59161.0
        tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 13044.0))
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
        Nebula():setPosition(tmp_x, tmp_y)
    end
-- Crea Neutrales
   Verran = CpuShip():setTemplate("Flavia"):setCallSign("Verran"):setFaction("Human Navy"):setPosition(-70000.0, -91000.0):orderRoaming():setCommsScript("")
   CIV_TR = CpuShip():setTemplate("Personnel Freighter 1"):setCallSign("CIV TR"):setFaction("Human Navy"):setPosition(15000.0, -57500.0):orderRoaming():setCommsScript("")
   CIV_TR:setDescriptions("A Drenni civillian transport. ID: 487G3","Official Manifest lists 46 Passangers, 8 Eggs and 6 Crew.")
-- Crea estaciones
   Outpost_12 = SpaceStation():setTemplate("Small Station"):setCallSign("Outpost 12"):setFaction("Human Navy"):setPosition(-30000.0, -75000.0)
   Outpost_12:setCommsFunction(O12_calls)
   Outpost_12:setDescription("One of 13 Drenni space stations in this star system.")
   Science_Facility_4 = SpaceStation():setTemplate("Small Station"):setCallSign("Science Facility 4"):setFaction("Human Navy"):setPosition(-70000.0, -10000.0)
   Science_Facility_4:setCommsFunction(SF4_calls)
-- Variables de la mision
mission_state = missionStartState
  defeat_timeout=1.0
  victory_timeout=1.0
  realtime = 0.
  nexto = 0
  tto:setCommsFunction(tto_calls)
end

function O12_calls()
 setCommsMessage("This is a Drenni outpost but we welcome our USFP brothers. We are different eggs of one nest. Dock whenever you have need.")
 
 if mission_state == missionEvacuation then
 setCommsMessage("The personnel at this station has families and eggs, please, Help, Save us! " )
 end
 
end

function tto_calls()
  if mission_state == missionStartState then
     setCommsMessage([[Welcome to Drenni territory. The Drenni that populate this region of space are a scientifically advanced bipedal lizard race that have developed a number of unique technologies. They have colonised half a dozen of the nearby star systems and are considering membership to the USFP. But the Drenni are currently at war with the neighbouring space fairing race, an arachnid species called the Navien. If we could end the conflict it would bring stability to this part of the galaxy. After exhausting negotiation the Navien have finally agreed to send a single diplomat to the Drenni, for top secret peace talks.]])
        addCommsReply("Accept", function()
            setCommsMessage([[Good. The Navien ambassador is already aboard your ship. Deliver her to the luxury liner called the Verran for the clandestine meeting.]])
           mission_state = ambushComms
           REenvoy1 = 1
           entregat = 0
        end)
  end

 if mission_state == missionBH and disaster < 0.0 and expo == 1 then
 setCommsMessage([[It s a disaster! Science Facility 4 has been destroyed and the classified singularity experiment it was working on is now completely out of control. The space-continuum has been ripped and the tear will continue to expand at an ever increasing rate. We predict that the quadrant will be destroyed in less than an hour with the whole star system destroyed in less than three. Try to Evacuate as many as possible !!.]])
        addCommsReply("Accept", function()
            setCommsMessage([[Travel to within 1 UA to start beaming whoever you choose to evacuate and then escaping the quadrant at maximum warp by going to sector A5. Hurry! There isn't much time!.]])
  Rift = BlackHole():setPosition(-70000.0, -10000.0)
  nextbh=15
  mission_state = missionEvacuation
 end)
end
end

function missionStartState()
    tto:openCommsTo(Ardent)
end

function ambushComms(delta)
    if ifOutsideBox(Ardent, 20000.0, -100000.0, -20000.0, -70000.0) then
        temp_transmission_object:setCallSign("Unsecured...Ch@nnel"):setCommsMessage("The loc@tion of the diplom@tic meeting has ch@nged and is now on @ need to know b@sis... Proceed immedi@tely to the middle of the @steroid field in Sector B5 and @w@it your next n@v co-ordin@tes...")
    end

    mission_state = missionDiplomat
end

function missionDiplomat(delta)

    if entregado4 ~= nil and entregado4 == 1 then
      realtime = realtime + delta
      if realtime > 15.0 and entregat3 == nil then
            Verran:sendCommsMessage(Ardent, [[Ardent, our ..... signal is .... ..... !Please ..... to 1000m of our ..... location ..... we will beam ..... diplomat aboard.]])
            entregat3 = 1
      end
    end
  
    distance_ardent_verra = distance(Ardent, Verran)
    
    if distance_ardent_verra < (40000.0) and REenvoy2 ~= (1) then
      Verran:sendCommsMessage(Ardent, [[Ardent, our ..... signal is being ..... !Please ..... to 1000m of our ..... location ..... we will beam ..... diplomat aboard.]])
      REenvoy2 = 1
    end

    if REenvoy1 == (1) and distance_ardent_verra < (15000.0) and entregat2 == nil then
 Verran:sendCommsMessage(Ardent, [[Ardent, our comms signal is being hacked! Please come to 1000m of our current location and we will beam the diplomat aboard. Thank you.]])
 entregat2 = 1
    end

    if REenvoy1 == (1) and distance_ardent_verra < (1000.0) and Ardent:getShieldsActive() then
    if Ardent:isCommsInactive() then
      Verran:sendCommsMessage(Ardent, [[Please, switch off the shields so we can beam aboard the diplomat.]])
    end
    end

    if REenvoy1 == (1) and distance_ardent_verra < (1000.0) and not Ardent:getShieldsActive() then
    if Ardent:isCommsInactive() then
      Verran:sendCommsMessage(Ardent, [[The diplomat has successfully been beamed aboard. Diplomatic negotiations will begin shortly. Thank you Ardent. Verran out.]])
      REenvoy1 = 0
      mission_state = missionEntregado 
    end
    end
    
    if variable_igetya == (1) and entregado4 == nil then
    if Ardent:isCommsInactive() then
    CV02:sendCommsMessage(Ardent, [[Our fake transmission brought you right into our ambush! There will be no peace and you will die here!]])
    Ardent:addCustomMessage("scienceOfficer", "warning", "Enemy Ships Decloaking")
    entregado4 = 1
    end
    end

    if REenvoy1 == (1) and variable_igetya ~= (1) and ifInsideSphere(Ardent, 10000.0, -71000.0, 4500.0) then

    CV02 = CpuShip():setTemplate("Phobos T3"):setCallSign("CV02"):setFaction("Kraylor"):setPosition(-55000.0, -49900.0):orderAttack(Ardent)
    if fleet[1] == nil then fleet[1] = {} end
    table.insert(fleet[1], CV02)
        tmp_x, tmp_y = Ardent:getPosition()
        tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 270.000000, 1000.0)
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
        CV02:setPosition(tmp_x, tmp_y);
        CV01 = CpuShip():setTemplate("Phobos T3"):setCallSign("CV01"):setFaction("Kraylor"):setPosition(-55000.0, -49900.0):orderAttack(Ardent)
        table.insert(fleet[1], CV01)
        tmp_x, tmp_y = Ardent:getPosition()
        tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 0.0, 1000.0)
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
        CV01:setPosition(tmp_x, tmp_y);
        CV03 = CpuShip():setTemplate("Phobos T3"):setCallSign("CV03"):setFaction("Kraylor"):setPosition(-55000.0, -49900.0):orderAttack(Ardent)
        table.insert(fleet[1], CV03)
        tmp_x, tmp_y = Ardent:getPosition()
        tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 90.0, 1000.0)
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
        CV03:setPosition(tmp_x, tmp_y);
        variable_igetya = 1
    end
end

function missionEntregado(delta)

if Ardent:isCommsInactive() then
   tto:sendCommsMessage(Ardent, [[At least they have a chance at peace. Please report for resupply and new orders at Science Facility 4.]])
  mission_state = missionSF4
end

end

function missionSF4()

  if Ardent:isDocked(Science_Facility_4) and variable_SF4dock == nil then
    Science_Facility_4:setCommsMessage("This facility is a joint USFP and Drenni operation, attempting to collaboratively develop some of the more powerful Drenni technologies. TSN Command considers this a top priority. Our latest test probe in C4 isn't responding. We'de like you to retrieve it and return it to us.")
    probe = SupplyDrop():setPosition(-46638.0, -58319.0):setDescription("Probe")
    variable_SF4dock = 1
    skaraansattack = 1
  end

  if skaraansattack ~= nil and skaraansattack == 1 then
    CV01 = CpuShip():setTemplate("Phobos T3"):setCallSign("CV01"):setFaction("Kraylor"):setPosition(6603.0, -81820.0):orderAttack(Verran):setJumpDrive(false)
    if fleet[1] == nil then fleet[1] = {} end
    table.insert(fleet[1], CV01)
    CV02 = CpuShip():setTemplate("Phobos T3"):setCallSign("CV02"):setFaction("Kraylor"):setPosition(883.0, -67782.0):orderAttack(Ardent):setJumpDrive(false)
    if fleet[2] == nil then fleet[2] = {} end
    table.insert(fleet[2], CV02)
    skaraansattack = 2
  end

  if variable_SF4dock ~= nil and variable_SF4dock == 1 and distance(Ardent, Probe) < 251.0 then
    Ardent:addCustomMessage("scienceOfficer", "warning", "Probe Collected")
    variable_SF4dock = 2
    gotprobe = 1
  end

  if gotprobe ~= nil and gotprobe = 1 then
    if docked_again == nil and Ardent:isDocked(Science_Facility_4) then
      Science_Facility_4:setCommsMessage("We're detected unussual signals in the nearby nebular. Enter the nebula and investigate.")
      docked_again = 1
    end
  end

  if  then
    Science_Facility_4:openCommsTo(Ardent)
        KR07 = CpuShip():setTemplate("Phobos T3"):setCallSign("KR07"):setFaction("Kraylor"):setPosition(4000.0, -35900.0):orderAttack(Ardent):setJumpDrive(false)
        if fleet[6] == nil then fleet[6] = {} end
        table.insert(fleet[6], KR07)
        KR08 = CpuShip():setTemplate("Phobos T3"):setCallSign("KR08"):setFaction("Kraylor"):setPosition(3800.0, -35800.0):orderAttack(Ardent):setJumpDrive(false)
        table.insert(fleet[6], KR08)
        KR09 = CpuShip():setTemplate("Atlantis X23"):setCallSign("KR09"):setFaction("Kraylor"):setPosition(3600.0, -35700.0):orderAttack(Ardent):setJumpDrive(false)
        table.insert(fleet[6], KR09)
        KR04 = CpuShip():setTemplate("Phobos T3"):setCallSign("KR04"):setFaction("Kraylor"):setPosition(-7033.0, -26188.0):orderAttack(Ardent):setJumpDrive(false)
        table.insert(fleet[6], KR04)
        KR05 = CpuShip():setTemplate("Phobos T3"):setCallSign("KR05"):setFaction("Kraylor"):setPosition(-7033.0, -25988.0):orderAttack(Ardent):setJumpDrive(false)
        table.insert(fleet[6], KR05)
        KR06 = CpuShip():setTemplate("Atlantis X23"):setCallSign("KR06"):setFaction("Kraylor"):setPosition(-7033.0, -26788.0):orderAttack(Ardent):setJumpDrive(false)
        table.insert(fleet[6], KR06)
        KR01 = CpuShip():setTemplate("Phobos T3"):setCallSign("KR01"):setFaction("Kraylor"):setPosition(-35000.0, -14900.0):orderAttack(Ardent):setJumpDrive(false)
        table.insert(fleet[6], KR01)
        KR02 = CpuShip():setTemplate("Phobos T3"):setCallSign("KR02"):setFaction("Kraylor"):setPosition(-35000.0, -14700.0):orderAttack(Ardent):setJumpDrive(false)
        table.insert(fleet[6], KR02)
        KR03 = CpuShip():setTemplate("Atlantis X23"):setCallSign("KR03"):setFaction("Kraylor"):setPosition(-35000.0, -14600.0):orderAttack(Ardent):setJumpDrive(false)
        table.insert(fleet[6], KR03)
--        REstartsab=45
        REstartsab=10
        finalValue=irandom(1,4)
        variable_SF4dock= 1
  end
end

function Security()

        setCommsMessage("How do you want us to proceed Captain?")
        addCommsReply("Post security at each crossroads and access point", function()
            setCommsMessage("Yes Sir!")
        AV = 1
        dicho = 2
        systems ={"shield", "beam", "missile", "maneuver", "impulse", "warp"}
        end)
        addCommsReply("Secure the defensive systems.", function()
            setCommsMessage("Yes Sir!")
        AV = 2
        dicho = 2
        systems ={"beam", "missile", "maneuver", "impulse", "warp"}
        end)
        addCommsReply("Secure the weapons systems.", function()
            setCommsMessage("Yes Sir!")
        AV = 3
        dicho = 2
        systems ={"shield", "maneuver", "impulse", "warp"}
        end)
        addCommsReply("Secure the primary systems", function()
            setCommsMessage("Yes Sir!")
        AV = 4
        dicho = 2
        systems ={"shield", "beam", "missile"}
        end)
end

function missionDistance()

  for key, value in pairs(fleet[6]) do
    if distance(Ardent, value) < 5000 then
mission_state=missionKill
    end
  end
end
function missionKill(delta)
     REstartsab = REstartsab - delta

if Ardent:isCommsInactive() and dicho == nil then
Sec:setCallSign("Internal Comms - Security"):sendCommsMessage(Ardent,[[This is Lieutenant Commander Hail of Security. Sir, we just found an undetonated thermite explosive on one of the EPS conduits of the port stabilizers. Luckily we managed to deactivate the device before it could cause any damage. Sir, it would seem we have a saboteur aboard. The internal sensors aren\'t picking anything up and my security teams did a sweep of the whole ship and came up empty handed.]])
Sec:setCallSign("")
   dicho=1
   REstartsab=120
end

if dicho == 1 and Ardent:isCommsInactive() then
Sec:setCallSign("Internal Comms - Security"):openCommsTo(Ardent)
Sec:setCallSign("")
end
   if dicho == 2 and AV == finalValue and REstartsab < 0.0 and  Ardent:isCommsInactive() or countFleet(6) <= 2 then
     Sec:sendCommsMessage(Ardent,[[We have found and are engaging the saboteur. It looks like an Arvonian.]])
   mission_state = missionSAhuida
   end   
-- do some sabotaging
if REstartsab < 0.0 and dicho == 2 then
removeVtable(systems,sabo)
local n=#systems
if n == 0 then
  dicho = 1
  REstartsab = 120
  AV = finalValue
else
falla=systems[irandom(1,n)]
if falla == "shield" then
Sec:sendCommsMessage(Ardent, [[The saboteur slipped past us and installed a virus in the shield control matrix.]])
        Ardent:setSystemHealth("rearshield", -1.0)
        getPlayerShip(-1):setSystemHealth("frontshield", -1.0)
sabo["shield"]=true
elseif falla == "beam" then
Sec:sendCommsMessage(Ardent, [[While we were waiting in ambush the saboteur bypassed us completely and took out the primary beam emitters.]])
        getPlayerShip(-1):setSystemHealth("beamweapons", -1.0)
sabo["beam"]=true
elseif falla == "maneuver" then
Sec:sendCommsMessage(Ardent, [[As we were standing guard the saboteur detonated a small thermite bomb in the navigational relays that have completely crippled the relays.]])
        getPlayerShip(-1):setSystemHealth("maneuver", -1.0)
sabo["maneuver"]=true
elseif falla == "missile" then
Sec:sendCommsMessage(Ardent, [[My two sentries outside the torpedo tube loading area are dead. Looks like the saboteur murdered them with some kind of disruptor weapon before jamming the tube hatches closed.]])
        getPlayerShip(-1):setSystemHealth("missilesystem", -1.0)
sabo["missile"]=true
elseif falla == "impulse" then
Sec:sendCommsMessage(Ardent, [[The saboteur detonated a small bomb in the engine room.]])
        getPlayerShip(-1):setSystemHealth("impulse", -1.0)
sabo["impulse"]=true
elseif falla == "warp" then
Sec:sendCommsMessage(Ardent,[[The saboteur has locked the Emergency shutdown trips of the warp core]])
        getPlayerShip(-1):setSystemHealth("warp", -1.0)
sabo["warp"]=true
end
-- next sabotage
end
   dicho = 1
   REstartsab=120
end

end


function missionSAhuida(delta)
    if llegit == 1 then
   tllegit = tllegit - delta
    end

    if Ardent:isCommsInactive() and llegit == nil then
Sec:setCallSign("Internal Comms - Security"):sendCommsMessage(Ardent,[[The saboteur has retreated to Cargo Bay 2. There is some kind of stealth vessel attached to the outside of the hull.]])
Sec:setCallSign("")
        TG01 = CpuShip():setTemplate("Starhammer II"):setCallSign("TG01"):setFaction("Kraylor"):setPosition(-30000.0, -45000.0):orderAttack(Ardent)
        if fleet[7] == nil then fleet[7] = {} end
        table.insert(fleet[7], TG01)
    tllegit = 30
    llegit = 1
    end

   if tllegit ~= nil and tllegit < 0.0 and llegit == 1 then
        tmp_x, tmp_y = Ardent:getPosition()
        tmp_x2, tmp_y2 = vectorFromAngle(Ardent:getRotation() + 180.0, 50.0)
        tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
  Saboteur = CpuShip():setTemplate("MU52 Hornet"):setCallSign("Saboteur"):setFaction("Kraylor"):setPosition(tmp_x, tmp_y):orderRoaming()
        if fleet[4] == nil then fleet[4] = {} end
        table.insert(fleet[4], Saboteur)
    llegit = 2
   end 
   if llegit == 2 then
        Saboteur:orderFlyTowardsBlind(TG01:getPosition())
   end

    if Ardent:isCommsInactive() and tllegit < 0.0 and tllegit ~= nil and llegit6 == nil then
Sec:setCallSign("Internal Comms - Security"):sendCommsMessage(Ardent,[[The saboteur is escaping in a small Arvonian ship.]])
Sec:setCallSign("")
    tllegit=20
    llegit6=1
    end
    if Ardent:isCommsInactive() and llegit6 == 1 and tllegit < 0.0 then
TG01:sendCommsMessage(Ardent,"&&%%%213·57890%23¡¡|30ndRD921º \n \n We are receiving a number of encrypted signals. \n Some are intended for the saboteur \n and others are directed towards Science Facility 4.")
  mission_state=missionBH
    end
end

function missionBH(delta)

if byebye == 1 then
 jumpin = jumpin - delta
end

 if jumpin ~= nil and jumpin < 0.0 then
  TG01:sendCommsMessage(Ardent,[[This is what happens when you mess with us !!]])
  TG01:destroy()
 end

 if byebye == nil and Saboteur ~= nil and TG01 ~= nil and Saboteur:isValid() and TG01:isValid() and distance(Saboteur, TG01) < 1000. then
  byebye = 1
  Saboteur:destroy()
  jumpin = 20
end


 if countFleet(7) < 1.0 and countFleet(6) < 2.0 and variable_workonce ~= (1.0) then
        disaster = 10.0
        variable_workonce = 1.0
 end
 if variable_workonce == (1.0) then 
  disaster = disaster - delta
 end

 if Ardent:isCommsInactive() and disaster < 0.0 and disaster ~= nil and expo == nil then
 Science_Facility_4:openCommsTo(Ardent)
 disaster = 10
 expo = 1
 end
if Ardent:isCommsInactive() and disaster < 0.0 and expo == 1 then
globalMessage("A growing quantum singularity has erupted  \n into space destroying Science Facility 4.")
Verran:setCommsFunction(sVerran)
CIV_TR:setCommsFunction(sCIV)
tto:openCommsTo(Ardent)
end
end


function missionEvacuation(delta)

nextbh = nextbh - delta 

MYsector = Ardent:getSectorName()

if MYsector == "A5" then
mission_state = missionFinal
end

if sayo5 == nil then
if sayo3 == 1 and distance(Ardent,CIV_TR) < 25000 then
        tmp_x, tmp_y = CIV_TR:getPosition()
    BlackHole():setPosition(tmp_x, tmp_y)
     sayo5=1
  end
if sayo4 == 1 and distance(Ardent,Verran) < 25000 then
        tmp_x, tmp_y = Verran:getPosition()
    BlackHole():setPosition(tmp_x, tmp_y)
     sayo5=1
 end
end

if sayo6 == nil then
if distance(Ardent,Outpost_12) < 20000 then
        tmp_x, tmp_y = Outpost_12:getPosition()
    BlackHole():setPosition(tmp_x, tmp_y)
     sayo6=1
  end
end


-- crea BH
if nextbh < 0.0 then
tmp_x = irandom(-100000,100000)
tmp_y = irandom(-100000,100000)
d2 = distance(tmp_x, tmp_y, 10000, -90000)
diver = distance(Verran, tmp_x, tmp_y)
diciv = distance(CIV_TR, tmp_x, tmp_y)
diard = distance(Ardent, tmp_x, tmp_y)
if sayo3 == 1 then diver = 11111 end
if sayo4 == 1 then diciv = 11111 end

if d2 > 20000 and diver > 10000 and diciv > 10000 and diard > 15000 then
BlackHole():setPosition(tmp_x, tmp_y)
nextbh=15
end
end

if Ardent:isCommsInactive() and sayo1 == nil then
   Verran:sendCommsMessage(Ardent, "We must be evacuated! We are government appointed diplomats of the Drenni and Navien. We are commandeering your ship. Come and beam us up immediately! If you don t save us the war will go on and untold millions will die and their blood will be on your hands too.")
sayo1 = 1
end
if Ardent:isCommsInactive() and sayo2 == nil then
  CIV_TR:sendCommsMessage(Ardent, "Please save us! This is a civilian transport! We have women, children and eggs aboard! You can t leave us to die! We are of one nest! I beg you!")
sayo2 = 1
end

if distance(Ardent, Verran) < 1000 and Ardent:isCommsInactive() and sayo3 == nil then
  Verran:sendCommsMessage(Ardent, "This is Captain Hobs of the Verran. The diplomats, their entourages and my crew have all been beamed aboard. I m the last one. We re good to get out of here!")
sayo3 = 1
end

if distance(Ardent, CIV_TR) < 1000 and Ardent:isCommsInactive() and sayo4 == nil then
CIV_TR:sendCommsMessage(Ardent, "This is Captain Hobs of Civillian Transport 487G3. A thousand thank yous. All of the crew and passangers down to the last egg have been beamed aboard the Ardent.  I m the last one. We re good to get out of here!")
sayo4 = 1
end



end

function sVerran()
setCommsMessage("I m Sarah Jennings, the Verran s Comms Officer. The crew and our passengers all have families. Please, don t abandon us all to die!")
end

function sCIV()
setCommsMessage("I m Lucas Leggings, the transport s Comms Officer. I m begging you, at least come and save the eggs and children! Please!")
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

-- Eventos temporales
function update(delta)

    if not Ardent:isValid() then
        defeat_timeout = defeat_timeout - delta
        if defeat_timeout < 0.0 then
            victory("Kraylor")
            return
        end
    end
    
    if mission_state == missionFinal then
    victory_timeout = victory_timeout - delta
         if victory_timeout < 0.0 then
            victory("Human Navy")
            return
         end
    end
    
 

    if mission_state ~= nil then
        mission_state(delta)
    end

end

