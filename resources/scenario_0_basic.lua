-- Name: Basic
-- Description: Basic scenarios, a few random stations, with random stuff around them are under attack by enemies.

function vectorFromAngle(angle)
	return math.sin(angle / 180 * math.pi), -math.cos(angle / 180 * math.pi)
end
function setCirclePos(obj, x, y, angle, distance)
	dx, dy = vectorFromAngle(angle)
	return obj:setPosition(x + dx * distance, y + dy * distance)
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
end

function update(delta)
	--No victory condition
end
