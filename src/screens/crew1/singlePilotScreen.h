#ifndef SINGLE_PILOT_SCREEN_H
#define SINGLE_PILOT_SCREEN_H

#include "gui/gui2_overlay.h"
#include "gui/gui2_element.h"
#include "singlePilotView.h"
#include "screenComponents/targetsContainer.h"
#include "gui/joystickConfig.h"

class GuiViewport3D;
class SinglePilotScreen : public GuiOverlay
{
private:
    GuiOverlay* background_crosses;
    SinglePilotView* single_pilot_view;
    GuiViewport3D* viewport;
    GuiElement* left_panel;
public:
    SinglePilotScreen(GuiContainer* owner);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//SINGLE_PILOT_SCREEN_H
