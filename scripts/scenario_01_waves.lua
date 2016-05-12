-- Name: Waves
-- Description: Waves of increasing difficult enemies.
-- Variation[Hard]: Effectively starts at difficulty of wave 5, and increases by 1.5 every defeated wave. (Players are quicker overwhelmed, leading to shorter games)
-- Variation[Easy]: Decreases the amount of ships in each progressing wave, making for easier progress and easier waves. (Takes longer for the players to be overwhelmed, good for new players)

function vectorFromAngle(angle, length)
	return math.cos(angle / 180 * math.pi) * length, math.sin(angle / 180 * math.pi) * length
end
function setCirclePos(obj, x, y, angle, distance)
	dx, dy = vectorFromAngle(angle, distance)
	return obj:setPosition(x + dx, y + dy)
end

function randomStationTemplate()
	if random(0, 100) < 10 then
		return 'Huge Station'
	end
	if random(0, 100) < 20 then
		return 'Large Station'
	end
	if random(0, 100) < 50 then
		return 'Medium Station'
	end
	return 'Small Station'
end

function init()
	waveNumber = 0
	spawnWaveDelay = nil
	enemyList = {}
	friendlyList = {}
	
	PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis")

	for n=1, 2 do
		table.insert(friendlyList, SpaceStation():setTemplate(randomStationTemplate()):setFaction("Human Navy"):setPosition(random(-5000, 5000), random(-5000, 5000)))
	end
	friendlyList[1]:addReputationPoints(150.0)

	local x, y = vectorFromAngle(random(0, 360), 15000)
	for n=1, 5 do
		local xx, yy = vectorFromAngle(random(0, 360), random(2500, 10000))
		Nebula():setPosition(x + xx, y + yy)
	end

	for cnt=1,random(2, 7) do
		a = random(0, 360)
		a2 = random(0, 360)
		d = random(3000, 15000 + cnt * 5000)
		x, y = vectorFromAngle(a, d)
		for acnt=1,25 do
			dx1, dy1 = vectorFromAngle(a2, random(-1000, 1000))
			dx2, dy2 = vectorFromAngle(a2 + 90, random(-10000, 10000))
			Asteroid():setPosition(x + dx1 + dx2, y + dy1 + dy2)
		end
		for acnt=1,50 do
			dx1, dy1 = vectorFromAngle(a2, random(-1500, 1500))
			dx2, dy2 = vectorFromAngle(a2 + 90, random(-10000, 10000))
			VisualAsteroid():setPosition(x + dx1 + dx2, y + dy1 + dy2)
		end
	end
	
	spawnWave()

	for n=1, 6 do
		setCirclePos(SpaceStation():setTemplate(randomStationTemplate()):setFaction("Independent"), 0, 0, random(0, 360), random(15000, 30000))
	end
	Script():run("util_random_transports.lua")
end

function randomSpawnPointInfo(distance)
	if random(0, 100) < 50 then
		if random(0, 100) < 50 then
			x = -distance
		else
			x = distance
		end
		rx = 2500
		y = 0
		ry = 5000 + 1000 * waveNumber
	else
		x = 0
		rx = 5000 + 1000 * waveNumber
		if random(0, 100) < 50 then
			y = -distance
		else
			y = distance
		end
		ry = 2500
	end
	return x, y, rx, ry
end

function spawnWave()
	waveNumber = waveNumber + 1
	friendlyList[1]:addReputationPoints(150 + waveNumber * 15)
	
	enemyList = {}
	if getScenarioVariation() == "Hard" then
		totalScoreRequirement = math.pow(waveNumber * 1.5 + 4, 1.3) * 10;
	elseif getScenarioVariation() == "Easy" then
		totalScoreRequirement = math.pow(waveNumber * 0.8, 1.3) * 9;
	else
		totalScoreRequirement = math.pow(waveNumber, 1.3) * 10;
	end
	
	scoreInSpawnPoint = 0
	spawnDistance = 20000
	spawnPointLeader = nil
	spawn_x, spawn_y, spawn_range_x, spawn_range_y = randomSpawnPointInfo(spawnDistance)
	while totalScoreRequirement > 0 do
		ship = CpuShip():setFaction("Ghosts");
		ship:setPosition(random(-spawn_range_x, spawn_range_x) + spawn_x, random(-spawn_range_y, spawn_range_y) + spawn_y);
		if spawnPointLeader == nil then
			ship:orderRoaming()
			spawnPointLeader = ship
		else
			ship:orderDefendTarget(spawnPointLeader)
		end

		type = random(0, 10)
		score = 9999
		if type < 2 then
            if irandom(1, 100) < 80 then
                ship:setTemplate("MT52 Hornet");
            else
                ship:setTemplate("MU52 Hornet");
            end
			score = 5
        elseif type < 3 then
            if irandom(1, 100) < 80 then
                ship:setTemplate("Adder MK5")
            else
                ship:setTemplate("WX-Lindworm")
            end
            score = 7
		elseif type < 6 then
            if irandom(1, 100) < 80 then
                ship:setTemplate("Phobos T3");
            else
                ship:setTemplate("Piranha F12");
            end
			score = 15
		elseif type < 7 then
			ship:setTemplate("Ranus U");
			score = 25
		elseif type < 8 then
            if irandom(1, 100) < 50 then
                ship:setTemplate("Stalker Q7");
            else
                ship:setTemplate("Stalker R7");
            end
			score = 25
		elseif type < 9 then
			ship:setTemplate("Atlantis X23");
			score = 50
		else
			ship:setTemplate("Odin");
			score = 250
		end
		
		if score > totalScoreRequirement * 1.1 + 5 then
			ship:destroy()
		else
			table.insert(enemyList, ship);
			totalScoreRequirement = totalScoreRequirement - score
			scoreInSpawnPoint = scoreInSpawnPoint + score
		end
		if scoreInSpawnPoint > totalScoreRequirement * 2.0 then
			spawnDistance = spawnDistance + 5000
			spawn_x, spawn_y, spawn_range_x, spawn_range_y = randomSpawnPointInfo(spawnDistance)
			scoreInSpawnPoint = 0
			spawnPointLeader = nil
		end
	end
	
	globalMessage("Wave " .. waveNumber);
end

function update(delta)
	if spawnWaveDelay ~= nil then
		spawnWaveDelay = spawnWaveDelay - delta
		if spawnWaveDelay < 5 then
			globalMessage(math.ceil(spawnWaveDelay));
		end
		if spawnWaveDelay < 0 then
			spawnWave();
			spawnWaveDelay = nil;
		end
		return
	end
	enemy_count = 0
	friendly_count = 0
	for _, enemy in ipairs(enemyList) do
		if enemy:isValid() then
			enemy_count = enemy_count + 1
		end
	end
	for _, friendly in ipairs(friendlyList) do
		if friendly:isValid() then
			friendly_count = friendly_count + 1
		end
	end
	if enemy_count == 0 then
		spawnWaveDelay = 15.0;
		globalMessage("Wave cleared!");
	end
	if friendly_count == 0 then
		victory("Ghosts");	--Victory for the Ghosts (== defeat for the players)
	end
end
