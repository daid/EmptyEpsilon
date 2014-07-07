-- Name: Basic
-- Description: Basic scenarios, a few random stations, with random stuff around them are under attack by enemies.

function vectorFromAngle(angle, length)
	return math.sin(angle / 180 * math.pi) * length, -math.cos(angle / 180 * math.pi) * length
end
function setCirclePos(obj, x, y, angle, distance)
	dx, dy = vectorFromAngle(angle, distance)
	return obj:setPosition(x + dx, y + dy)
end

function init()
	for n=1, 3 do
		setCirclePos(SpaceStation():setFaction(1), 0, 0, n * 360 / 3 + random(-30, 30), random(15000, 20000))
	end
	
	enemy_group_count = 5
	for cnt=1,enemy_group_count do
		a = cnt * 360/enemy_group_count + random(-60, 60)
		d = random(35000, 55000)
		type = random(0, 10)
		if type < 1.0 then
			setCirclePos(CpuShip():setShipTemplate('Strikeship'):setRotation(a + 180):orderRoaming(), 0, 0, a, d)
		elseif type < 2.0 then
			leader = setCirclePos(CpuShip():setShipTemplate('Cruiser'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-1, 1), d + random(-100, 100))
			setCirclePos(CpuShip():setShipTemplate('Fighter'):setRotation(a + 180):orderFlyFormation(leader,-400, 0), 0, 0, a + random(-1, 1), d + random(-100, 100))
			setCirclePos(CpuShip():setShipTemplate('Fighter'):setRotation(a + 180):orderFlyFormation(leader, 400, 0), 0, 0, a + random(-1, 1), d + random(-100, 100))
			setCirclePos(CpuShip():setShipTemplate('Fighter'):setRotation(a + 180):orderFlyFormation(leader,-400, 400), 0, 0, a + random(-1, 1), d + random(-100, 100))
			setCirclePos(CpuShip():setShipTemplate('Fighter'):setRotation(a + 180):orderFlyFormation(leader, 400, 400), 0, 0, a + random(-1, 1), d + random(-100, 100))
		elseif type < 3.0 then
			setCirclePos(CpuShip():setShipTemplate('Adv. Gunship'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100))
			setCirclePos(CpuShip():setShipTemplate('Adv. Gunship'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100))
		elseif type < 4.0 then
			setCirclePos(CpuShip():setShipTemplate('Cruiser'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100))
			setCirclePos(CpuShip():setShipTemplate('Cruiser'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100))
			setCirclePos(CpuShip():setShipTemplate('Cruiser'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100))
		elseif type < 5.0 then
			setCirclePos(CpuShip():setShipTemplate('Dreadnought'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100))
		elseif type < 6.0 then
			leader = setCirclePos(CpuShip():setShipTemplate('Missile Cruiser'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100))
			setCirclePos(CpuShip():setShipTemplate('Fighter'):setRotation(a + 180):orderFlyFormation(leader,-1500, 400), 0, 0, a + random(-1, 1), d + random(-100, 100))
			setCirclePos(CpuShip():setShipTemplate('Fighter'):setRotation(a + 180):orderFlyFormation(leader, 1500, 400), 0, 0, a + random(-1, 1), d + random(-100, 100))
		elseif type < 7.0 then
			setCirclePos(CpuShip():setShipTemplate('Cruiser'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100))
			setCirclePos(CpuShip():setShipTemplate('Cruiser'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100))
		elseif type < 8.0 then
			setCirclePos(CpuShip():setShipTemplate('Cruiser'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100))
		elseif type < 9.0 then
			setCirclePos(CpuShip():setShipTemplate('Fighter'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100))
		else
			setCirclePos(CpuShip():setShipTemplate('Adv. Striker'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100))
			setCirclePos(CpuShip():setShipTemplate('Adv. Striker'):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100))
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
end

function update(delta)
	--No victory condition
end
