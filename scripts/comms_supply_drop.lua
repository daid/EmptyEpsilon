require("options.lua")
require(lang .. "/comms.lua")

-- Name: Supply ship comms
-- Description: Stripped comms that do not allow any interaction. Used for transport ships.

function mainMenu()
	if player:isFriendly(comms_target) then
		setCommsMessage(shipComms_transportingGoods);
		return true
	end
	if player:isEnemy(comms_target) then
		return false
	end
	setCommsMessage(shipComms_neutralDismiss);
end
mainMenu()
