-- Name: Lightbringer Aurora
-- Description: For Ghost from the Past mission

function mainMenu()
	setCommsMessage("Hello, human lifeform. What help can we provide today ?");
		addCommsReply("You are polluting the frequencies with your research.", function()
			setCommsMessage("How infortunate. Our research is of prime importance to my race and I'm afraid I cannot stop now. However, we can provide you with one of our sensors. If installed on your array, we could both continue our purpose without interference.")
				addCommsReply("We'll do this.", function()
					setCommsMessage("This is most auspicious, thank you for your understanding.")
					player:setDescription("Arlenian Device")
				end)
				addCommsReply("We are not your errand boys, Arlenian.", function()
					setCommsMessage("A most wrong conclusion. If you were to change your mind, come find us.")
				end)
		end)
end

mainMenu()
