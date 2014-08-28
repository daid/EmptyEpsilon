-- Name: Empty space
-- Description: Empty scenario, no enemies, no friendlies, only a lonely station. Can be used by a GM player to setup a scenario in the GM screen.

function init()
	SpaceStation():setPosition(500, 500):setFaction("Human Navy")
end

function update(delta)
	--No victory condition
end
