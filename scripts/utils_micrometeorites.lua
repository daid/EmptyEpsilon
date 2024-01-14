-- Utils for micrometeorite point defense
-----------
-- Usage -- 
-----------
-- Place this line somewhere in the update function:
-- MicroMeteorites:updateAll(delta)

-- To add MicroMeteorites to a ship
-- MicroMeteorites:init([playership])

-- To remove MicroMeteorites from a ship:
-- MicroMeteorites:remove([playership])

require('utils.lua')

MicroMeteorites ={}

function MicroMeteorites:init(player_ship)
	player_ship.micrometeorite_impact_time=5	-- time to react after warning
	player_ship.micrometeorite_delay_min=20		-- minimal...
	player_ship.micrometeorite_delay_max=30		-- ...and maximal delay between two impact warnings
	
	player_ship.micrometeorite_impact_countdown=player_ship.micrometeorite_impact_time
	player_ship.micrometeorite_time=math.random(player_ship.micrometeorite_delay_min,player_ship.micrometeorite_delay_max)
	player_ship.micrometeorite_phase = 1

	player_ship:addCustomInfo("Weapons","point_defense_info",_("MicroMeteorite Defense"),10)
	player_ship:addCustomButton("Weapons","point_defense_btn_left","« ".._("Left"),function () MicroMeteorites:fired(1,player_ship) end,11)
	player_ship:addCustomButton("Weapons","point_defense_btn_right","» ".._("Right"),function () MicroMeteorites:fired(2,player_ship) end,12)
end

function MicroMeteorites:remove(player_ship)
	player_ship:removeCustom("point_defense_info")
	player_ship:removeCustom("point_defense_btn_left")
	player_ship:removeCustom("point_defense_btn_right")
	player_ship.micrometeorite_phase = 0
end


function MicroMeteorites:update(delta,player_ship)
	if player_ship.micrometeorite_phase == 1 then
		MicroMeteorites:timer(delta,player_ship)
	end
	if player_ship.micrometeorite_phase == 2 then
		MicroMeteorites:incoming(delta,player_ship)
	end	
end

function MicroMeteorites:updateAll(delta)
    for _, p in ipairs(getActivePlayerShips()) do
        if p ~= nil then
            MicroMeteorites:update(delta,p)
		end
	end
end

function MicroMeteorites:timer(delta,player_ship)
    if (not player_ship:getShieldsActive()) and player_ship:hasPlayerAtPosition("Weapons") then -- do not bother the player when shields are up or no weapons officer is around (tactical and single pilot are busy enough)
        player_ship.micrometeorite_time = player_ship.micrometeorite_time - delta
        if player_ship.micrometeorite_time <= 0 then
            player_ship.micrometeorite_direction = math.random(1,2)
            player_ship.micrometeorite_phase = 2
            player_ship:addCustomInfo("Weapons","point_defense_info",_("!!! IMPACT IMMINENT !!!"),10)
        end
    end
    
end

function MicroMeteorites:incoming(delta,player_ship)
    
    player_ship.micrometeorite_impact_time=player_ship.micrometeorite_impact_time-delta
    
    if player_ship.micrometeorite_impact_time < player_ship.micrometeorite_impact_countdown-1 then
        player_ship.micrometeorite_impact_countdown=player_ship.micrometeorite_impact_countdown-1
        if player_ship.micrometeorite_direction==1 then
            player_ship:addCustomButton("Weapons","point_defense_btn_left","« ".._("Left in").." "..(player_ship.micrometeorite_impact_countdown),function () MicroMeteorites:fired(1,player_ship) end,11)          			
        else
            player_ship:addCustomButton("Weapons","point_defense_btn_right","« ".._("Right in").." "..(player_ship.micrometeorite_impact_countdown),function () MicroMeteorites:fired(2,player_ship) end,12)
        end
    end    
    
    if player_ship.micrometeorite_impact_time <= 0 then
        player_ship.micrometeorite_impact_time=5
        x, y = player_ship:getPosition()
		if player_ship.micrometeorite_direction==1 then
		 explosion_angle=math.random(315,350)+player_ship:getRotation()
		else if player_ship.micrometeorite_direction==2 then
		 explosion_angle=math.random(10,45)+player_ship:getRotation()
		end
		end
		xx, yy = vectorFromAngle(explosion_angle, 150)
		ExplosionEffect():setPosition(x+xx,y+yy):setSize(10)
		player_ship:takeDamage(5,"kinetic",x+xx,y+yy)
        
        player_ship.micrometeorite_impact_countdown=5
        player_ship.micrometeorite_time=math.random(player_ship.micrometeorite_delay_min,player_ship.micrometeorite_delay_max)
        
        --reset info and buttons
        player_ship:addCustomInfo("Weapons","point_defense_info",_("MicroMeteorite Defense"),10)
        player_ship:addCustomButton("Weapons","point_defense_btn_left","« ".._("Left"),function () MicroMeteorites:fired(1,player_ship) end,11)
        player_ship:addCustomButton("Weapons","point_defense_btn_right","» ".._("Right"),function () MicroMeteorites:fired(2,player_ship) end,12)

        player_ship.micrometeorite_phase=1
    end

end

function MicroMeteorites:fired(button_direction,player_ship)
	if player_ship:getSystemHeat("beamweapons")<0.99 and player_ship:getSystemHealth("beamweapons")>0.0 and player_ship:getSystemPower("beamweapons")>0.1 then
		x, y = player_ship:getPosition()
		if button_direction==1 then
			beam_angle=math.random(315,350)+player_ship:getRotation()
			else if button_direction==2 then
				beam_angle=math.random(10,45)+player_ship:getRotation()
			end
		end
		xx, yy = vectorFromAngle(beam_angle, 200*player_ship.micrometeorite_impact_time+100)
		debris=Artifact():setPosition(x+xx, y+yy):setRadarTraceColor(255,200,100);
		if player_ship.micrometeorite_direction==button_direction then
			player_ship.micrometeorite_impact_time=5
			player_ship.micrometeorite_impact_countdown=5
			player_ship.micrometeorite_time=math.random(player_ship.micrometeorite_delay_min,player_ship.micrometeorite_delay_max)
			
			--reset info and buttons
			player_ship:addCustomInfo("Weapons","point_defense_info",_("MicroMeteorite Defense"),10)
            player_ship:addCustomButton("Weapons","point_defense_btn_left","« ".._("Left"),function () MicroMeteorites:fired(1,player_ship) end,11)
            player_ship:addCustomButton("Weapons","point_defense_btn_right","» ".._("Right"),function () MicroMeteorites:fired(2,player_ship) end,12)
        
			player_ship.micrometeorite_phase=1
			BeamEffect():setSource(player_ship, 0, 0, 0):setTarget(debris, 0, 0):setDuration(0.5):setRing(false):setTexture("texture/beam_blue.png"):setBeamFireSoundPower(0.1)
			ExplosionEffect():setPosition(x+xx,y+yy):setSize(5)
			player_ship.micrometeorite_direction=0
		else
			BeamEffect():setSource(player_ship, 0, 0, 0):setTarget(debris, 0, 0):setDuration(0.5):setRing(false):setTexture("texture/beam_blue.png"):setBeamFireSoundPower(0.1)
			player_ship:setSystemHeat("beamweapons", player_ship:getSystemHeat("beamweapons")+0.1) -- some heat to prevent button spamming
		end
		debris:destroy()
	end
end

