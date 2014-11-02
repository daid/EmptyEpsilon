function mainMenu()
	if player:isFriendly(comms_target) then
		setCommsMessage("Currently transporting goods.");
		return true
	end
	if player:isEnemy(comms_target) then
		return false
	end
	setCommsMessage("We have nothing for you.\nGood day.");
end
mainMenu()
