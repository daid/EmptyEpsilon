#ifndef TRACTOR_BEAM_CONTROL_H
#define TRACTOR_BEAM_CONTROL_H

#include "gui/gui2_element.h"
#include "gui/gui2_autolayout.h"
#include "spaceObjects/playerSpaceship.h"

class GuiSelector;
class GuiSlider;

class GuiTractorBeamControl : public GuiAutoLayout
{
private:
    GuiSelector* mode_selector;
    GuiSlider* arc_slider;
    GuiSlider* direction_slider;
    GuiSlider* range_slider;
public:
    GuiTractorBeamControl(GuiContainer* owner, string id);
    virtual void onDraw(sf::RenderTarget& window) override;
};

#endif//TRACTOR_BEAM_CONTROL_H
