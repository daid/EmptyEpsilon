#include "main.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "singlePilotScreen.h"
#include "preferenceManager.h"
#include "singlePilotView.h"
#include "gui/gui2_element.h"

#include "screenComponents/viewport3d.h"

#include "screenComponents/alertOverlay.h"

SinglePilotScreen::SinglePilotScreen(GuiContainer* owner)
: GuiOverlay(owner, "SINGLEPILOT_SCREEN", colorConfig.background)
{
    // Create a 3D viewport behind everything, to serve as the right-side panel
    viewport = new GuiViewport3D(this, "3D_VIEW");
    viewport->setPosition(1000, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Create left panel for controls.
    left_panel = new GuiElement(this, "LEFT_PANEL");
    left_panel->setPosition(0, 0, ATopLeft)->setSize(1000, GuiElement::GuiSizeMax);
    
    // single pilot
    single_pilot_view = new SinglePilotView(left_panel, my_spaceship);
    single_pilot_view->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", sf::Color::White);
    background_crosses->setTextureTiled("gui/BackgroundCrosses");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));
}

void SinglePilotScreen::onDraw(sf::RenderTarget& window)
{
    GuiOverlay::onDraw(window);
}

