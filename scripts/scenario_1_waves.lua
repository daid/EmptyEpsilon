-- Name: Waves
-- Description: Waves of increasing difficult enemies.

function vectorFromAngle(angle, length)
	return math.cos(angle / 180 * math.pi) * length, math.sin(angle / 180 * math.pi) * length
end
function setCirclePos(obj, x, y, angle, distance)
	dx, dy = vectorFromAngle(angle, distance)
	return obj:setPosition(x + dx, y + dy)
end

function init()
	waveNumber = 0
	spawnWaveDelay = nil
	enemyList = {}
	friendlyList = {}

	for n=1, 2 do
		table.insert(friendlyList, SpaceStation():setFaction("Human Navy"):setPosition(random(-5000, 5000), random(-5000, 5000)))
	end
	friendlyList[1]:addReputationPoints(150.0)
	
	spawnWave()
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
	totalScoreRequirement = math.pow(waveNumber, 1.3) * 10;
	
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
			ship:setShipTemplate("Fighter");
			score = 5
		elseif type < 6 then
			ship:setShipTemplate("Cruiser");
			score = 15
		elseif type < 7 then
			ship:setShipTemplate("Adv. Gunship");
			score = 25
		elseif type < 8 then
			ship:setShipTemplate("Strikeship");
			score = 25
		elseif type < 9 then
			ship:setShipTemplate("Dreadnought");
			score = 50
		else
			ship:setShipTemplate("Battlestation");
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
