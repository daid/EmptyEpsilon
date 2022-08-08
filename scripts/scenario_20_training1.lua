-- Name: Training: Cruiser
-- Type: Basic
-- Description: Basic Training Cource
---
--- Objective: Destroy all enemy ships in the area.
---
--- Description:
--- During this training your will learn to coordinate the actions of your crew and destoy an Exuari training ground.
---
--- Your ship is a Phobos light cruiser - the most common vessel in the navy.
---
--- This is a short mission for inexperienced players.


require("utils.lua")


--- Ship creation functions
function createExuariWeakInterceptor()
	return CpuShip():setFaction("Exuari"):setTemplate("Dagger"):setBeamWeapon(0, 0, 0, 0, 0.1, 0.1)
end

function createExuariWeakBomber()
	return CpuShip():setFaction("Exuari"):setTemplate("Gunner"):setWeaponTubeCount(0):setWeaponStorageMax("HVLI", 0):setWeaponStorage("HVLI", 0):setBeamWeapon(0, 0, 0, 0, 0.1, 0.1)
end

function createExuariInterceptor()
	return CpuShip():setFaction("Exuari"):setTemplate("Dagger")
end

function createExuariBomber()
	return CpuShip():setFaction("Exuari"):setTemplate("Gunner"):setBeamWeapon(0, 0, 0, 0, 0.1, 0.1)
end

function createExuariTransport()
	return CpuShip():setFaction("Exuari"):setTemplate("Personnel Freighter 1"):setTypeName("Exuari transport")
end

function createExuariFreighter()
	return CpuShip():setFaction("Exuari"):setTemplate("Goods Freighter 5"):setTypeName("Exuari freighter")
end

function createExuariShuttle()
	return CpuShip():setFaction("Exuari"):setTemplate("Racer"):setTypeName("Exuari shuttle"):setWarpDrive(false):setBeamWeapon(0, 0, 355, 0, 0.1, 0.1):setBeamWeapon(1, 0, 355, 0, 0.1, 0.1)
end


-- init
function init()
    enemyList = {}
    timer = 0
    finishedTimer = 5
    finishedFlag = false
    instr1 = false

    bonusAvail = true
    bonus = createExuariShuttle():setCallSign("bonus"):setPosition(-2341, -17052):orderFlyTowardsBlind(-80000, -40000):setHeading(-60)

    table.insert(enemyList, createExuariWeakInterceptor():setCallSign("Fgt1"):setPosition(2341, -5191):setHeading(60))
    table.insert(enemyList, createExuariWeakInterceptor():setCallSign("Fgt2"):setPosition(2933, -6555):setHeading(60))
    table.insert(enemyList, createExuariWeakBomber():setCallSign("B2"):setPosition(-8866, -9002):orderDefendLocation(-9798, -9869):setHeading(60))
    table.insert(enemyList, createExuariWeakBomber():setCallSign("B1"):setPosition(-12407, -9067):orderDefendLocation(-11433, -9887):setHeading(60))
    table.insert(enemyList, createExuariInterceptor():setCallSign("A1"):setPosition(-24113, -12830):orderDefendLocation(-25570, -13055):setHeading(60))
    table.insert(enemyList, createExuariInterceptor():setCallSign("A2"):setPosition(-26813, -12025):orderDefendLocation(-26425, -13447):setHeading(60))
    table.insert(enemyList, createExuariBomber():setCallSign("BR2"):setPosition(-39545, -16424):orderStandGround():setHeading(60))
    table.insert(enemyList, createExuariBomber():setCallSign("BR1"):setPosition(-41365, -15584):orderStandGround():setHeading(60))
    table.insert(enemyList, createExuariTransport():setCallSign("Omega1"):setPosition(-34120, -6629):setHeading(60))
    table.insert(enemyList, createExuariTransport():setCallSign("Omega2"):setPosition(-31698, -4868):setHeading(60))
    table.insert(enemyList, createExuariTransport():setCallSign("Omega3"):setPosition(-29270, -2853):setHeading(60))
    table.insert(enemyList, createExuariFreighter():setCallSign("FTR1"):setPosition(2787, -1822):orderFlyTowards(-42873, -13865):setHeading(-60))

    player = PlayerSpaceship():setTemplate("Phobos M3P"):setPosition(18, -48):setCallSign("Rookie 1"):setJumpDrive(false):setLongRangeRadarRange(20000)
    command = CpuShip():setFaction("Human Navy"):setTemplate("Phobos M3"):setCallSign("Command"):setPosition(-100000, -100000):orderIdle()
end

function commsInstr()
    if not instr1 and timer > 8.0 then
        instr1 = true
        command:sendCommsMessage(player, _("goal-incCall", [[This is Commander Saberhagen.

In this training mission you will practice the basic controls of a Phobos light cruiser.
Since this is not a tutorial, you will be on your own to decide how to destroy all enemy targets in an Exuari training ground.
There will be not much resistance, so you can try different approaches and tactics savely.

Here's your chance to beat up some helpless opponents.
Commander Saberhagen out.]]))
    end
end

function finished(delta)
    finishedTimer = finishedTimer - delta
    if finishedTimer < 0 then
        victory("Human Navy")
    end
    if finishedFlag == false then
        finishedFlag = true
        local bonusString = _("msgMainscreen-bonusTarget", "escaped.")
        if not bonus:isValid() then
            bonusString = _("msgMainscreen-bonusTarget", "destroyed.")
        end
        globalMessage(string.format(_("msgMainscreen", [[Mission Complete.
Your Time: %d
Bonus target %s

If you feel ready for combat, play scenario 'Basic Battle'.
If you want to try another ship, play the next training mission.

If you need more practice, play this training again
with different stations assigned to your crew members.]]), formatTime(timer), bonusString))
    end
end

function update(delta)
    timer = timer + delta

    -- Count all surviving enemies.
    for i, enemy in ipairs(enemyList) do
        if not enemy:isValid() then
            table.remove(enemyList, i)
        -- Note: table.remove() inside iteration causes the next element to be skipped.
        -- This means in each update-cycle max half of the elements are removed.
        -- It does not matter here, since update is called regulary.
        end
    end
    if #enemyList == 0 then
        if not bonusAvail then
            finished(delta)
        else
            if not bonus:isValid() then
                finished(delta)
            end
        end

    end

    if bonus:isValid() then
        local x, y = bonus:getPosition()
        if x < -40000 then
            bonus:setWarpDrive(true)
        end
        if x < -50000 then
            bonusAvail = false
        end
    end

    commsInstr()
end

