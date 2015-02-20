-- Name: Basic
-- Description: Basic scenario. A few random stations, with random stuff around them, are under attack by enemies.

function vectorFromAngle(angle, length)
	return math.cos(angle / 180 * math.pi) * length, math.sin(angle / 180 * math.pi) * length
end
function setCirclePos(obj, x, y, angle, distance)
	dx, dy = vectorFromAngle(angle, distance)
	return obj:setPosition(x + dx, y + dy)
end

function init()
	enemyList = {}
	friendlyList = {}

	for n=1, 3 do
		table.insert(friendlyList, setCirclePos(SpaceStation():setFaction("Human Navy"), 0, 0, n * 360 / 3 + random(-30, 30), random(10000, 22000)))
	end
	friendlyList[1]:addReputationPoints(300.0)

	local x, y = friendlyList[1]:getPosition()
	setCirclePos(Nebula(), x, y, random(0, 360), 6000)

	for n=1, 5 do
		setCirclePos(Nebula(), 0, 0, random(0, 360), random(20000, 45000))
	end
	
	enemy_group_count = 5
	for cnt=1,enemy_group_count do
		a = cnt * 360/enemy_group_count + random(-60, 60)
		d = random(35000, 55000)
		type = random(0, 10)
		if type < 1.0 then
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Strikeship'):setRotation(a + 180):orderRoaming(), 0, 0, a, d))
		elseif type < 2.0 then
			leader = setCirclePos(CpuShip():setShipTemplate('Cruiser'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-1, 1), d + random(-100, 100))
			table.insert(enemyList, leader)
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Fighter'):setRotation(a + 180):orderFlyFormation(leader,-400, 0), 0, 0, a + random(-1, 1), d + random(-100, 100)))
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Fighter'):setRotation(a + 180):orderFlyFormation(leader, 400, 0), 0, 0, a + random(-1, 1), d + random(-100, 100)))
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Fighter'):setRotation(a + 180):orderFlyFormation(leader,-400, 400), 0, 0, a + random(-1, 1), d + random(-100, 100)))
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Fighter'):setRotation(a + 180):orderFlyFormation(leader, 400, 400), 0, 0, a + random(-1, 1), d + random(-100, 100)))
		elseif type < 3.0 then
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Adv. Gunship'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Adv. Gunship'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
		elseif type < 4.0 then
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Cruiser'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Cruiser'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Cruiser'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
		elseif type < 5.0 then
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Dreadnought'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
		elseif type < 6.0 then
			leader = setCirclePos(CpuShip():setShipTemplate('Missile Cruiser'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100))
			table.insert(enemyList, leader)
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Fighter'):setRotation(a + 180):orderFlyFormation(leader,-1500, 400), 0, 0, a + random(-1, 1), d + random(-100, 100)))
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Fighter'):setRotation(a + 180):orderFlyFormation(leader, 1500, 400), 0, 0, a + random(-1, 1), d + random(-100, 100)))
		elseif type < 7.0 then
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Cruiser'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Cruiser'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
		elseif type < 8.0 then
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Cruiser'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
		elseif type < 9.0 then
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Fighter'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
		else
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Adv. Striker'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
			table.insert(enemyList, setCirclePos(CpuShip():setShipTemplate('Adv. Striker'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
		end
	end
	
	for cnt=1,random(2, 5) do
		a = random(0, 360)
		a2 = random(0, 360)
		d = random(3000, 40000)
		x, y = vectorFromAngle(a, d)
		for acnt=1,50 do
			dx1, dy1 = vectorFromAngle(a2, random(-1000, 1000))
			dx2, dy2 = vectorFromAngle(a2 + 90, random(-20000, 20000))
			Asteroid():setPosition(x + dx1 + dx2, y + dy1 + dy2)
		end
	end

	for cnt=1,random(0, 3) do
		a = random(0, 360)
		a2 = random(0, 360)
		d = random(20000, 40000)
		x, y = vectorFromAngle(a, d)
		for nx=-1,1 do
			for ny=-5,5 do
				if random(0, 100) < 90 then
					dx1, dy1 = vectorFromAngle(a2, (nx * 1000) + random(-100, 100))
					dx2, dy2 = vectorFromAngle(a2 + 90, (ny * 1000) + random(-100, 100))
					Mine():setPosition(x + dx1 + dx2, y + dy1 + dy2)
				end
			end
		end
	end

	a = random(0, 360)
	d = random(10000, 45000)
	x, y = vectorFromAngle(a, d)
	BlackHole():setPosition(x, y)
end

function update(delta)
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
		victory("Human Navy");	--Victory for the humans (eg; players). Note that this can happen if the players kill themselves (and then blow up the enemies)
	end
	if friendly_count == 0 then
		victory("Kraylor");	--Victory for the Kraylor (== defeat for the players)
	else
		friendlyList[1]:addReputationPoints(delta * friendly_count * 0.1)
	end
end
