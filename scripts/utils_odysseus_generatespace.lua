-- Generating space objects for scenarios
-- Predefined planet list

function setUpPlanet(name, x, y, planeShiftModifier)

    local planetName = name

    if planet_list == nil then
        planetList()
    end

    for key, value in ipairs(planet_list) do
        if value.name == planetName then
            planetIndex = key
            selected_planet = value
        end
      end

    -- Clear other space objects before placing planet
    local planetRadius = selected_planet.radius*4
	local clearRadius = planetRadius*1.2
	for _, obj in ipairs(getObjectsInRadius(x, y, clearRadius)) do
		if obj.typeName == "Nebula" or obj.typeName == "Asteroid" or obj.typeName == "VisualAsteroid" then
			obj:destroy()
		end
	end

    -- Place the planet to correct location
    if planeShiftModifier == nil then
        planeShiftModifier = random(0.4, 0.99)
    end

    planet_fodder = Planet():setCallSign(planetName):setPosition(x, y):setPlanetRadius(planetRadius)
    local distancePlane = math.floor(-planeShiftModifier*planetRadius)
    planet_fodder:setDistanceFromMovementPlane(distancePlane)
    planet_fodder:setPlanetSurfaceTexture(selected_planet.texture.surface)

	if selected_planet.axialrotation ~= nil then
        axialrotation = math.floor(selected_planet.axialrotation*30)
        planet_fodder:setAxialRotationTime(axialrotation)
	end
	if selected_planet.texture.cloud ~= nil then
		planet_fodder:setPlanetCloudTexture(selected_planet.texture.cloud)
	end
	if selected_planet.color ~= nil then
		planet_fodder:setPlanetAtmosphereColor(selected_planet.color.red,selected_planet.color.green,selected_planet.color.blue)
	end

    return planet_fodder

end

function planetList()

    planet_list = {}
    table.insert(planet_list, {
        -- Desert planet, #f2d07f, 
         -- Jump 2
            name = "Sronsh",
            radius = 3695,
            axialrotation = 33,
            texture = {
                surface = "planets/planet-desert-1.png",
                cloud = "planets/clouds-3.png", 
--                atmosphere = "planets/atmosphere.png"
            },
--            color = {
--                red = 0.2,
--                green = 0.2,
--                blue = 0.2,
--            },
        })
    table.insert(planet_list, {
        -- Desert planet, #f2d07f, radius 9491 - rotation 92,3
         -- Landmission 2 - Jump 3
            name = "Velian",
            radius = 9491,
            axialrotation = 92,
            texture = {
                surface = "planets/planet-desert-2.png",
                cloud = "planets/clouds-1.png", 
                atmosphere = "planets/atmosphere.png"
            },
            color = {
                red = random(0.6,1), 
                green = random(0.4,0.6), 
                blue = random(0,0.2)
            },
        })
        table.insert(planet_list, {
            -- P-TE49-HE75, Terrestrial planet #00a599, radius 4841, rotation 23,3
            -- Landmission 3 - Jump 6
            name = "P-TE49-HE75",
            radius = 4841,
            axialrotation = 23,
            texture = {
                surface = "planets/planet-1.png",
                cloud = "planets/clouds-blue.png", 
--                atmosphere = "planets/atmosphere.png"
            },
--            color = {
--                red = 0.2, 
--                green = 0.2, 
--                blue = 0.8,
--            },
        })
        table.insert(planet_list, {
            -- P-TE95-LN71, Terrestrial planet #00a599, radius 7644, rotation 93,6
            -- Landmission 4 - Jump 8
            name = "P-TE95-LN71",
            radius = 7644,
            axialrotation = 93,
            texture = {
                surface = "planets/EE_PLANET_GREEN.png",
                cloud = "planets/clouds-1.png", 
                atmosphere = "planets/atmosphere.png"
            },
        })
        table.insert(planet_list, {
            -- P-OC46-DA97, desrt, #2152ff, radius 9682, rotation 87,6
            -- Landmission 5 - Jump 10
            name = "P-OC46-DA97",
            radius = 9682,
            axialrotation = 87,
            texture = {
                surface = "planets/planet-ice-1.png",
                cloud = "planets/clouds-2.png", 
                atmosphere = "planets/atmosphere.png"
            },
        })
        table.insert(planet_list, {
            -- natural satellite, M12-PI87 #989898, radius 667, rotation 87,6
            -- Landmission 6 - Jump 12
            name = "M12-PI87",
            radius = 667,
            axialrotation = 87,
            texture = {
                surface = "planets/moon-3.png",
--                cloud = "planets/clouds-1.png", 
                atmosphere = "planets/atmosphere.png"
            },
        })
        table.insert(planet_list, {
            -- Ocean planet
            -- Jump 12 - behind land mission moon
            name = "P-OC04-YU08",
            radius = 2867,
            axialrotation = 30,
            texture = {
                surface = "planets/EE_PLANET_WINTER_BLUE.png",
                cloud = "planets/clouds-2.png", 
                atmosphere = "planets/atmosphere.png"
            },
        })
        table.insert(planet_list, {
            -- P-SI14-UX98, Silicate planet, #c5a006, radius 2867, rottion 98,7
            -- Landmission 7 - Jump 14
            name = "P-SI14-UX98",
            radius = 2867,
            axialrotation = 98,
            texture = {
                surface = "planets/EE_PLANET_PURPLE.png",
                cloud = "planets/clouds-3.png", 
                atmosphere = "planets/atmosphere.png"
            },
        })
        table.insert(planet_list, {
            -- asteroid AS-OH108, #88a575 radius 678, rotation 48,7
            -- Landmission 8a - Jump 15
            name = "AS-OH108",
            radius = 678,
            axialrotation = 48,
            texture = {
                surface = "planets/asteroid.png",
            },
        })
        table.insert(planet_list, {
            -- P-LA05-WE50, lava, #a13100, radius 15734, rotation 57,3
            -- Landmission 9 - Jump 17
            name = "P-LA05-WE50",
            radius = 15734,
            axialrotation = 57,
            texture = {
                surface = "planets/planet-2.png",
                cloud = "planets/clouds-1.png", 
                atmosphere = "planets/atmosphere.png"
            },
            color = {
                red = random(0.6,1), 
                green = random(0.4,0.6), 
                blue = random(0,0.2)
            },
        })
end

function generateSpace(fx, fy)
	local x, y = odysseus:getPosition()
	
	local acount = irandom(40, 100)
	for n=1,acount do
		local posx = random(-80000, 80000)
		local posy = random(-80000, 80000)
		if distance(0, 0, posx, posy) > 2000 then
			Asteroid():setPosition(posx, posy):setSize(random(100, 500))
		end
		VisualAsteroid():setPosition(random(-100000, 190000), random(-100000, 100000)):setSize(random(100, 500))
	end
  
	local ncount = irandom(5,10)
	for n=1, ncount do
		local posx = random(-80000, 80000)
		local posy = random(-80000, 80000)
        if distance(0, 0, posx, posy) > 2000 then
            if fx ~= nil and fy ~= nil then
                local sx = fx + x
                local sy = fy + y        
                if distance(sx, sy, posx, posy) > 7000 then
                    Nebula():setPosition(posx, posy)
                end
            else 
                Nebula():setPosition(posx, posy)
            end
		end
	end
end
