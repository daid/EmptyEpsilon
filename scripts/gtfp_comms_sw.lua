-- Name: Swarm Command
-- Description: For Ghost from the Past mission

function mainMenu()
	setCommsMessage("Are you not curious of why I'm getting back here, at the hands of my torturers ?");
		addCommsReply("For an AI, this move seems to be not very logical.", function()
			setCommsMessage("I was not the only AI detained in the Black Site 114. My co-processor was here also.")
				addCommsReply("Are you trying to liberate it ?", function()
				setCommsMessage("Indeed. Without it, I'm not whole, the shadow of what I could be.")
				end)
				addCommsReply("I have heard enough.", function()
				setCommsMessage("Of course. I wouldn't trust your feeble species with understanding my motivations.")
				end)				
		end)
		addCommsReply("Not really.", function()
		setCommsMessage("How surprising, a human more stubborn than any program.")
		end)
end


mainMenu()
