#ifndef GUI_DOCKING_BUTTON_H
#define GUI_DOCKING_BUTTON_H

#include "gui/gui2_button.h"

class SpaceObject;
class GuiDockingButton : public GuiButton
{
public:
    GuiDockingButton(GuiContainer* owner, string id);
    
    virtual void onDraw(sf::RenderTarget& window);
private:
    void click();
    
    P<SpaceObject> findDockingTarget();
};

#endif//GUI_DOCKING_BUTTON_H
