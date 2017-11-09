#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "probeScreen.h"
#include "epsilonServer.h"
#include "main.h"

#include "screenComponents/viewport3d.h"
#include "screenComponents/indicatorOverlays.h"
#include "screenComponents/shipDestroyedPopup.h"

ProbeScreen::ProbeScreen()
{
	rotatetime = 1.0;
	
    viewport = new GuiViewport3D(this, "VIEWPORT");
    viewport->showCallsigns()->showHeadings()->showSpacedust();
    viewport->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    new GuiShipDestroyedPopup(this);
    
    new GuiIndicatorOverlays(this);
}

void ProbeScreen::update(float delta)
{
	
    if (game_client && game_client->getStatus() == GameClient::Disconnected)
    {
        destroy();
        disconnectFromServer();
        returnToMainMenu();
        return;
    }

	P<ScanProbe> probe;
	rotatetime -= delta;
    if (delta <= 0.0)
    {
		rotatetime = 1.0;
		angle += 1.0;
		if (angle >= 359.0)
			angle = 0.0;
	}
	
    if (my_spaceship)
    {
		probe = game_client->getObjectById(my_spaceship->linked_science_probe_id);
	
		if (probe)
		{
			camera_yaw = angle;
			camera_pitch = 0.0f;
			
			sf::Vector2f position = probe->getPosition() + sf::rotateVector(sf::Vector2f(probe->getRadius(), 0), camera_yaw);

			camera_position.x = position.x;
			camera_position.y = position.y;
			camera_position.z = 0.0;
		}
    }
}