-- Name: Supply ship comms
-- Description: Stripped comms that do not allow any interaction. Used for transport ships.

function mainMenu()
	if player:isFriendly(comms_target) then
		setCommsMessage("Transporting goods.");
		return true
	end
	if player:isEnemy(comms_target) then
		return false
	end
	setCommsMessage("We have nothing for you.\nGood day.");
end
mainMenu()
