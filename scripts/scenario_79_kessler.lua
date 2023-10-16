-- Name: Kessler
-- Description: Save the global satellite network by catching space debris and prevent the Kessler Syndrome! This is a beginner scenario initially created to be played by a crew of school kids. It still assumes general knowledge about operating the stations, so a previous tutorial session or on-site introduction is recommended. The officer(s) on relay&science or on operations should be able to read fluently.
-- Type: Mission
require("utils.lua")

function init()
	interaction_threshold=5 -- number of required interaction with debris, successful or not
	reputation_threshold=30 -- when both thresholds are reached, the second game phase will begin
	debris_interactions=0
	probe_amount=20

    player1 = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setWeaponTubeCount(0):setCallSign("Tidy-1"):setPosition(-5500,0)
    player1:setWeaponStorageMax("Nuke",0):setWeaponStorageMax("Homing",0):setWeaponStorageMax("HVLI",0):setWeaponStorageMax("Mine",0):setWeaponStorageMax("Emp",0)
    player1:onDestroyed(function()
		if player2==nil then
			victory("Ghosts")
		end
    end)

    orbit=35000
    radius=6300
    planet1 = Planet():setPosition(6300+35000, 0):setPlanetRadius(radius):setDistanceFromMovementPlane(-2000):setPlanetSurfaceTexture("planets/planet-earth.png"):setPlanetCloudTexture("planets/clouds-2.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.0,0.0,0.5):setDescriptions(_("Earth"),_("The blue planet")):setCallSign(_("Earth")):setFaction("Independent"):setAxialRotationTime(1000)

    sun1 = Planet():setPosition(5000, 35000):setPlanetRadius(1000):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,1.0)

    geo_1=SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("Geo-1"):setPosition(33064, -49665):setDescription(_("A supply station in geostationary orbit"))
    geo_1:setCommsFunction(geo_comm)

    placeRandomFreq(35, -750, -20000, -1250, 20000, 2000)
    px,py =planet1:getPosition()
    placeRandomAroundPoint(Asteroid,400,orbit+radius,orbit+radius+5000,px,py)
    placeRandomAroundPoint(VisualAsteroid,400,orbit+radius,orbit+radius+5000,px,py)
    placeRandomAroundPoint(Asteroid,50,radius,orbit+radius,px,py)
    placeArtifactsAroundPoint (32,orbit+radius,orbit+radius+500,px,py)

    mission_state=mission_start_state

    dock_message_sent=0

mission_data = ScienceDatabase():setName(_('Mission data'))
item = mission_data:addEntry(_('Kessler Syndrome'))
item:setLongDescription(_([[The Kessler Syndrome is a theoretical Scenario first proposed by NASA Scientist Donald J. Kessler in 1978. It describes the situation where the density of objects in Earth's orbit is high enough to cause a chain reaction of collisions. Each collision will create a huge debris field of multiple objects, and many of them will collide with other objects. Ultimately, the Orbit will be full of tiny objects destroying satellites and making space flight very hard, if not impossible. Also, much of our daily life depends on satellites, like TV, communication, navigation and internet. The Kessler Syndrome would be a serious threat to all of this. This is why clearing space debris, and preventing that kind of scenario is extremely important.
]]))
item:setImage("kessler_syndrome.png")

GMPhase2 = _("buttonGM", "Unusual Readings")
addGMFunction(GMPhase2,triggerPhase2)
GMPhase3 = _("buttonGM", "Order to dock")
addGMFunction(GMPhase3,triggerPhase3)
GMPhase4 = _("buttonGM", "Showdown")
addGMFunction(GMPhase4,triggerPhase4)


geo_1:sendCommsMessage(player1, _([[Greetings!
We are glad to welcome you aboard our new prototype! If it becomes successful, we might soon start assembling a fleet of tidying ships! Hopefully, they will be able to finally solve the problem of space debris in our orbit!
This first prototype will only be able to capture larger space junk. We found several suitable candidates for your first test run, they will appear with a four-digit call sign on your radar.
To capture them, you have to calibrate your shields correctly, so be sure the object will be scanned. A successful scan will reveal the correct capturing frequency. Now, the shields have to be calibrated with the correct frequency. Make sure to activate the shields after calibration. Then you can fly towards the pieces of space junk, and it should successfully be captured.
]]))
end
------------------------ end of initialisation ------------------------

function geo_comm()
    if comms_source:isDocked(comms_target) then
        if comms_source:getHull() < comms_source:getHullMax() -1 or comms_source:getEnergyLevel() < comms_source:getEnergyLevelMax() -1
        then
            setCommsMessage(_("Repairs and refueling in progress."))
        else
            setCommsMessage(_("Your ship is fully refuelled and repaired."))
        end
    else
        setCommsMessage(_('Good day, officer. If you need repairs or to replenish your energy, please dock with us. For more background information about your mission, see the "Mission data" section in the science database.'))
    end
end

function no_reply()
    setCommsMessage()
end

function mission_start_state(delta)
	if player1:getReputationPoints() >= reputation_threshold and debris_interactions>=interaction_threshold then
        mission_state=unusual_readings
	end
	if not areBeamShieldFrequenciesUsed() then
		globalMessage(_("Shield frequencies are required for this scenario. Please enable frequencies in extra settings."))
	end

end

function misson_idle(delta)
    if idle ~= 2 then
        idle = 2
    end
end

function unusual_readings(delta)
    geo_1:sendCommsMessage(player1, _([[We are getting strange readings from sector C7. It looks like the source is an abandoned satellite. Please investigate, but be careful.]]))
    spyprobe = CpuShip():setFaction("Ghosts"):setTemplate("ANT 615"):setCallSign("NC3"):setHullMax(100):setHull(100):setPosition(48885, -45317):orderIdle()
    spyprobe:setDescriptions(_("An abandoned satellite"),_("An old military satellite. Capturing frequency is blocked. Behaviour unknown. Recommendation: Jump not closer than 10U, then advance using the impulse drive."))
    spyprobe:onDestruction(function(art, player)  ;
		mission_state=order_dock
		globalMessage(_("Additional debris created!"))
	end)

    mission_state=spyprobe_spawned
end

function spyprobe_spawned(delta)
    if distance(player1, spyprobe) < 7000 then
        spyprobe:orderRoaming()
        explosion_timer = 0
        mission_state = start_havoc
        state_step = 0
        rx,ry = 0,0
    end
end

function start_havoc(delta)
    explosion_timer=explosion_timer+delta
    if explosion_timer > 12 and state_step == 1 then
        ExplosionEffect():setPosition(rx,ry):setSize(200)
        placeRandomAroundPoint(Asteroid,8,1,500,rx,ry)
        x, y = spyprobe:getPosition()
        rx = x + random(0,1000)-500
        state_step = state_step + 1
    elseif explosion_timer > 5 and state_step == 0 then
        geo_1:sendCommsMessage(player1, _([[The satellite started to attack objects in its proximity! That way, more fragments will be created that may harm other satellites. You must stop it! Try to NOT destroy it, target its impulse drive instead.]]))
        local x, y = spyprobe:getPosition()
        rx = x + random(0,1000)-500
        ry = y + random(0,1000)-500
        ExplosionEffect():setPosition(rx,ry):setSize(200)
        rx=x
        ry=y
        state_step = state_step + 1
    end
    if spyprobe:getSystemHealth("impulse") <= 0.0 then
        spy_x, spy_y = spyprobe:getPosition()
        mission_state=spyprobe_disabled
        player1:setReputationPoints((player1:getReputationPoints()+25))
    end     
end

function spyprobe_disabled(delta)
    mission_state=misson_idle
    local x, y = spyprobe:getPosition()
    local r = spyprobe:getRotation()
    ElectricExplosionEffect():setPosition(x,y):setSize(200)
    spyprobe:destroy()
    local freq = math.floor(random(20, 40)) * 20
    dormant_spyprobe=Artifact():setPosition(x, y):setCallSign("MiSat"):setDescriptions(_("A deactivated military satellite. Scan to get the capturing frequency."),_("Capturing frequency:").." "..freq):setScanningParameters(1, 2)
    dormant_spyprobe:setModel("combatsat"):setRadarTraceIcon("combatsat.png"):setRadarTraceScale(1)
    dormant_spyprobe:setRotation(r)
    dormant_spyprobe.freq=freq
    dormant_spyprobe:onPickUp(function(art, player)
        dock_message_sent=0
        mission_state=order_dock
        shieldfreq= 400+(player1:getShieldsFrequency())*20
        local ax, ay = art:getPosition();
        local x, y = player:getPosition(); 
        if shieldfreq == art.freq and player:getShieldsActive() == true then
            ElectricExplosionEffect():setPosition(x,y):setSize(200)
            player:takeDamage(1, "kinetic",ax, ay)
            player:setReputationPoints((player:getReputationPoints()+25))
        else
            ExplosionEffect():setPosition(x,y):setSize(200)
            player:takeDamage(50, "kinetic",ax, ay)
            globalMessage(_("Additional debris created!"))
        end
    end)    
end

function order_dock(delta)
    if dock_message_sent==0 then        
        init_player2()
        player2:commandDock(geo_1)   
        geo_1:sendCommsMessage(player1, _([[It looks like the old satellite was hit by a piece of space debris and thus reactivated. This also caused it to malfunction. 
Just before its deactivation, it was able to send a signal. We have to investigate this.
But first, please dock with us. If necessary, we can repair the hull, and you can recharge your energy. 
After that, you will receive further orders.]]))
        
        dock_message_sent=dock_message_sent+1
    end
    
    if player1:isDocked(geo_1) and dock_message_sent==1 and player1:isCommsInactive() then
		player2:commandDock(geo_1)
		initSatNetwork()
        message_sat_network=geo_1:sendCommsMessage(player1, _([[Bad news: The satellite woke up a whole group of military satellites that should have been out of service for ages. If we don't do anything against them, they will slowly but surely destroy all objects they can find. The debris will spread all over the orbit, destroying all our communications satellites.
Not only would that be a disaster for science and spaceflight, but everyday things like Internet are in serious danger as well!
We are currently making a plan to stop this. Please stay docked until you get new orders.
]]))
        dock_message_sent=dock_message_sent+1
    end
    if dock_message_sent==2 and player1:getEnergyLevel() > player1:getEnergyLevelMax()-2 and player1:isCommsInactive() then
		if player1:hasPlayerAtPosition("Weapons") then  
			message_sat_deactivate=geo_1:sendCommsMessage(player1, _([[New orders: We have to shut down the rogue satellites somehow. Therefore, you need to get as close as possible to the control node that is commanding the other satellites. Luckily, the satellites are in some kind of sleep mode right now, to recharge their batteries. You need another ship however, to get to them unnoticed. As soon you are getting closer, you should also turn off every system and device that is not necessary. When you are ready, your weapons officer can change the ship at the touch of a button.]]))
        else
			message_sat_deactivate=geo_1:sendCommsMessage(player1, _([[New orders: We have to shut down the rogue satellites somehow. Therefore, you need to get as close as possible to the control node that is commanding the other satellites. Luckily, the satellites are in some kind of sleep mode right now, to recharge their batteries. You need another ship however, to get to them unnoticed. As soon you are getting closer, you should also turn off every system and device that is not necessary. When you are ready, your tactical officer can change the ship at the touch of a button.]]))
        end
        player1:addCustomButton("Weapons","change_ship_btn",_("change ship"),change_ship)
        player1:addCustomButton("Tactical","change_ship_btn_tac",_("change ship"),change_ship)
            dock_message_sent=dock_message_sent+1        
    end    
end

function change_ship()
    player1:transferPlayersToShip(player2)
    player2:setCallSign("Tidy-2")
    geo_1:sendCommsMessage(player2, _([[Welcome to the new ship. It is smaller and more unsuspicious. On the downside, it is also less robust. Instead of a jump drive, it is equipped with a so-called warp drive. 
You can fly much faster with it, but the drive tends to overheat easily. Keep in mind to turn off all non-essential systems and devices as soon you are getting closer to the dangerous satellites.
This ship has a transmitter installed that is strong enough to overwhelm the jammer of the control node and to send a shutdown signal. But you have to be very close for it to work.
We detected the control node at a heading of about 125 degrees from our position, but a newly formed dust cloud prevents us to get more details. We don't know if this cloud was created intentionally to serve as a hiding place. It might as well be a side effect of their destructive activities or just fuel leaking out of their old tanks. Good luck!
    ]]))
    mission_state=towards_commandnode
    cloud_hint=false
end

function towards_commandnode(delta)
	if distance(player2, geo_1) > 10000 and not cloud_hint and player2:hasPlayerAtPosition("Operations") then
		geo_1:sendCommsMessage(player2 ,_([[The dust cloud is causing large electromagnetic interferences. Which means that as soon you are far enough away from the station, you can guess it's direction by looking at the red line at the edge of your radar screen.]]))
		cloud_hint=true
	end
	
	if distance(player2, command_node) < 1001 then
		for n=1,10 do
			probe[n]:orderStandGround():setSystemHealth("Maneuvering",0.5)
		end
        player2:addCustomButton("Engineering","activate_transmitter_btn",_("Activate transmitter"),activate_transmitter)
        player2:addCustomButton("Engineering+","activate_transmitter_btn_plus",_("Activate transmitter"),activate_transmitter)
        player2:removeCustom("out_of_reach_info")
        player2:removeCustom("out_of_reach_info_plus")
        mission_state=misson_idle
   end   
end

function activate_transmitter()
    charge_timer=0
    transmitter_charge=0
    transmitter_txt=0
    transmitter_step = 10
    if player2:hasPlayerAtPosition("Relay") then
		geo_1:sendCommsMessage(player2, _([[As soon as your transmitter is fully charged, the weapons officer has to sync the shields with the transmitter (a Button will appear on the console). Then, you yourself on Relay will have to send the signal. (There will be a button for this as well.) Good luck!]]))
    else
		geo_1:sendCommsMessage(player2, _([[As soon as your transmitter is fully charged, the weapons officer has to sync the shields with the transmitter (a Button will appear on the console). Then, you yourself on Operations will have to send the signal. (You will have to change your sidebar from 'Scanning' to 'Other' by pressing the 'Scanning' headline or the arrows next to it.) Good luck!]]))
    end
    mission_state=boot_transmitter
    player2:removeCustom("activate_transmitter_btn")
    player2:removeCustom("activate_transmitter_btn_plus")
    globalMessage(_("Charging of Transmitter initiated"))
    player2:addCustomInfo("Engineering","activate_transmitter_info",_("Transmitter is charging.."))
    player2:addCustomInfo("Engineering+","activate_transmitter_info_plus",_("Transmitter is charging.."))
    escalation=20
    for n=1,probe_amount do
        probe[n]:orderRoaming():setSystemHealth("Maneuvering",0.85)
    end        
end

function boot_transmitter(delta)
    charge_timer=charge_timer+delta
    transmitter_charge=charge_timer+10
    
    if charge_timer>20 and transmitter_charge > (transmitter_txt + transmitter_step) then 
		transmitter_txt = math.floor(transmitter_txt + transmitter_step)
		player2:addCustomInfo("Engineering","activate_transmitter_info",_("Transmitter charging")..": "..transmitter_txt.."%")
		player2:addCustomInfo("Engineering+","activate_transmitter_info_plus",_("Transmitter charging")..": "..transmitter_txt.."%")
	end
    if charge_timer>20 and escalation==20 then
        for n=1,10 do
            probe[n]:setImpulseMaxSpeed(100):setSystemHealth("Impulse",0.1)
            
        end
        escalation=30
    end
    if charge_timer>30 and escalation==30 then 
        escalation=40
    end
    if charge_timer>40 and escalation==40 then
        probe[probe_amount]:setWeaponStorage("HVLI",1):setWeaponStorageMax("HVLI",1):setWeaponTubeCount(1):setImpulseMaxSpeed(100)
        escalation=60      
    end
    if charge_timer>60 and escalation==60 then 
        escalation=80
        transmitter_step=5
    end
    if charge_timer>80 and escalation==80 then 
                player2:addCustomMessage("Operations", "send_button_message", _("If not done yet, you should now change the headline of your sidebar from 'scan' to 'other', so you can send the signal as soon as it is available."))
        transmitter_step=1.5
        escalation=85
    end
    if charge_timer>90 then
        globalMessage(_("Transmitter is ready to be synced with shields"))
        player2:removeCustom("out_of_reach_info")
        player2:removeCustom("activate_transmitter_btn")
        player2:addCustomInfo("Engineering","activate_transmitter_info",_("Transmitter fully charged"))
        player2:addCustomInfo("Engineering+","activate_transmitter_info_plus",_("Transmitter fully charged"))
        player2:addCustomInfo("Weapons","connect_to_shields_info",_("Transmitter:"))
        player2:addCustomInfo("Tactical","connect_to_shields_info_tactical",_("Transmitter:"))
        player2:addCustomButton("Weapons","connect_to_shields_btn",_("Sync with shields"),connect_to_shields)
        player2:addCustomButton("Tactical","connect_to_shields_btn_tactical",_("Sync with shields"),connect_to_shields)
        mission_state=misson_idle
    end
end

function connect_to_shields()
    globalMessage(_("Syncing shields with transmitter. Please stand by..."))
    player2:removeCustom("connect_to_shields_btn")
    player2:removeCustom("connect_to_shields_btn_tactical")
    player2:addCustomInfo("Weapons","connect_to_shields_info",_("Syncing transmitter..."))
    player2:addCustomInfo("Tactical","connect_to_shields_info_tactical",_("Syncing transmitter..."))
    mission_state= connecting_shields
    connect_timer=0
end

function connecting_shields(delta)
    connect_timer=connect_timer+delta
    if connect_timer > 5 then
        player2:addCustomButton("Relay","send_signal_btn",_("send signal"),send_signal)
        player2:removeCustom("transmitter_unlinked_info")
        player2:addCustomButton("Operations","send_signal_btn_ops",_("send signal"),send_signal)
        player2:addCustomInfo("Weapons","connect_to_shields_info",_("Transmitter is ready"))
        player2:addCustomInfo("Tactical","connect_to_shields_info_tactical",_("Transmitter is ready"))
        mission_state=misson_idle
    end
end

function send_signal()
    local x, y = command_node:getPosition(); 
    ElectricExplosionEffect():setPosition(x,y):setSize(500)
    player2:removeCustom("send_signal_btn")
    player2:removeCustom("send_signal_btn_ops")
    sending_timer=0
    
    BeamEffect():setSource(player2, 0, 0, 0):setTarget(command_node, 0, 0):setDuration(3):setRing(false):setTexture("texture/electric_sphere_texture.png")
    mission_state=sending_signal
    for n=1,probe_amount do
        probe[n]:setFaction("Independent"):setScanned(true):orderIdle()
    end
end

function sending_signal(delta)
    sending_timer=sending_timer+delta
    if sending_timer>3 then
		globalMessage(_("Rogue satellites shut down"))
        geo_1:sendCommsMessage(player2, _([[Congratulations! You saved the global satellite network from destruction. I call this a successful test run and we're gonna initiate the production of our fleet of tidying ships immediately. So eventually, we will get rid of this space junk problem once and for all. You and the rest of your crew did a great job!]]))
        mission_state=mission_victory
    end       
end

function mission_victory(delta)
	if player2:isCommsInactive() then -- wait for the call to be finished
		victory("Human Navy")
	end
end

-- -------------------------------- --

function update(delta)

    if mission_state ~= nil then
        mission_state(delta)
    end

end

--------  GM functions

function triggerPhase2()
	player1:setReputationPoints(reputation_threshold)
	debris_interactions=interaction_threshold
	removeGMFunction(GMPhase2)
end

function triggerPhase3()
    mission_state = order_dock
    player1:setPosition(32000, -50000)
    removeGMFunction(GMPhase2)
    removeGMFunction(GMPhase3)

end

function triggerPhase4()
	if not(player2) then
		init_player2()
	end
    player2:setCallSign("Tidy-2")
	initSatNetwork()
	player2:setPosition(80000, -20000)
    mission_state = towards_commandnode
    removeGMFunction(GMPhase2)
    removeGMFunction(GMPhase3)
    removeGMFunction(GMPhase4)
end

-------- Misc. functions --------

function init_player2()
        player2 = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Flavia P.Falcon"):setWeaponTubeCount(0)
        player2:setCallSign(_("Empty ship")) -- as players might not realise that this is a player ship and could be confused when noone is answering their call
        player2:setWeaponStorageMax("Nuke",0):setWeaponStorageMax("Homing",0):setWeaponStorageMax("HVLI",0):setWeaponStorageMax("Mine",0):setWeaponStorageMax("Emp",0)
        player2:setPosition(32500,-49000)
        player2:addCustomInfo("Engineering","out_of_reach_info",_("Out of reach"))
        player2:addCustomInfo("Engineering+","out_of_reach_info_plus",_("Out of reach"))
        player2:addCustomInfo("Operations","transmitter_unlinked_info",_("Transmitter is not linked yet"))
        player2:onDestroyed(function()
			victory("Ghosts")
        end)
end

function initSatNetwork()
        Nebula():setPosition(86578, -12988)
		Nebula():setPosition(92935, -15086)
		Nebula():setPosition(91476, -8925)
          
        placeProbesAroundPoint(probe_amount,2000,5000,90000,-12000)
        placeRandomAroundPoint(VisualAsteroid,50,1,5000,90000,-12000)
        command_node= WarpJammer():setPosition(90000,-12000):setRange(2500):setCallSign("Control"):setDescription(_("This is the command node that controls the rogue satellites. We have to shut it down!"))
        command_node:onDestruction(function()  -- fallback in case the command node somehow gets destroyed, so the scenario is still winnable
			command_node=Artifact():setPosition(90000,-12000):setCallSign("Control"):setModel("shield_generator"):setDescription(_("This is the command node that controls the rogue satellites. We have to shut it down!"))
	end)
end

function placeRandomFreq(amount, x1, y1, x2, y2, random_amount)
    local callsign_counter =1000
    for n=1,amount do
        local f = random(0, 1)
        local x = x1 + (x2 - x1) * f
        local y = y1 + (y2 - y1) * f
        
        local r = random(0, 360)
        local distance = random(0, random_amount)
        x = x + math.cos(r / 180 * math.pi) * distance
        y = y + math.sin(r / 180 * math.pi) * distance
                
        local freq = math.floor(random(20, 40)) * 20
        
        callsign_counter = callsign_counter + math.floor(random(1,200))
        local callsign = callsign_counter
        debris = Artifact():setPosition(x, y):setDescriptions(_("A piece of space junk. Scan to find out the capturing frequency"), _("Capturing frequency:").." "..freq):setScanningParameters(1, 2)
        debris.freq=freq
        if freq < 595 then 
            debris:setModel("debris-cubesat")
        else
            debris:setModel("debris-blob")
        end
        debris:allowPickup(true)
        debris:setCallSign(callsign):setFaction("Human Navy"):setRadarTraceColor(255,235,170)
        
        debris:onPickUp(function(art, player)  ;
            shieldfreq= 400+(player1:getShieldsFrequency())*20
            local ax, ay = art:getPosition();
            local x, y = player:getPosition(); 
            if shieldfreq == art.freq and player:getShieldsActive() == true then
                ElectricExplosionEffect():setPosition(x,y):setSize(200)
                player:takeDamage(1, "kinetic",ax,ay );
                player:setReputationPoints((player:getReputationPoints()+10))
                if player:getReputationPoints() == 20 then
					geo_1:sendCommsMessage(player1, _([[Very good so far! Don't worry, you don't have to clean up all of the marked space junk in your first test run, but we still need quite a few of them before we call it a day.]]))
					player:setReputationPoints(25)
                end
            else
                ExplosionEffect():setPosition(ax,ay):setSize(200)
                player:takeDamage(50, "kinetic",ax,ay );
            end
            debris_interactions=debris_interactions+1        
        end);
        
    end
end

function placeProbesAroundPoint( amount, dist_min, dist_max, x0, y0)
    probe ={}
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance
        probe[n] = CpuShip():setFaction("Ghosts"):setAI("fighter"):setTemplate("ANT 615"):setHullMax(100):setHull(100):setPosition(x,y):orderIdle():setCallSign("IC"..n+5):setCommsFunction(no_reply)
        probe[n]:setDescriptions(_("An old military satellite"), _("An old military satellite. Capturing frequency is blocked."))
        probe[n]:setImpulseMaxSpeed(0)
    end
end

function placeArtifactsAroundPoint( amount, dist_min, dist_max, x0, y0)
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance
        callsign="TTY"..string.format("%02d",n)
        sat = Artifact():setPosition(x, y):setDescriptions(_("An operational satellite"),_("This satellite is fully operational. Do not capture!")):setScanningParameters(1, 2)
        sat:setModel("cubesat"):setCallSign(callsign):setRadarTraceIcon("satellite.png"):setRadarTraceScale(1)
        sat:allowPickup(true)
        
        sat:onPickUp(function(art, player)  ;
            local ax, ay = art:getPosition();
            local x, y = player:getPosition();
            ExplosionEffect():setPosition(ax,ay):setSize(200)
            player:takeDamage(50, "kinetic",ax,ay );
            player1:setReputationPoints((player1:getReputationPoints()-10))        
        end);                
    end
end
