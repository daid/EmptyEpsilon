#include "tractorBeamControl.h"

#include "playerInfo.h"
#include "spaceObjects/shipTemplateBasedObject.h"
#include "spaceObjects/playerSpaceship.h"

#include "gui/gui2_listbox.h"
#include "gui/gui2_autolayout.h"
#include "gui/gui2_element.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_button.h"
#include "gui/gui2_selector.h"
#include "screenComponents/powerDamageIndicator.h"

const int BEAM_PANEL_HEIGHT = 290;

GuiTractorBeamControl::GuiTractorBeamControl(GuiContainer* owner, string id): GuiAutoLayout(owner, id, GuiAutoLayout::LayoutVerticalBottomToTop){
    this->setSize(GuiElement::GuiSizeMax, BEAM_PANEL_HEIGHT);

    arc_slider = new GuiSlider(this, "", 0.0, 90.0, 0.0, [this](float value) {
        if (my_spaceship) my_spaceship->commandSetTractorBeamArc(value);
    });
    arc_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);
    (new GuiPowerDamageIndicator(arc_slider, "", SYS_Docks, ATopCenter, my_spaceship))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    (new GuiLabel(this, "", "Arc:", 20))->setSize(GuiElement::GuiSizeMax, 30);

    direction_slider = new GuiSlider(this, "", -179.9, 180.0, 0.0, [this](float value) {
        if (my_spaceship) my_spaceship->commandSetTractorBeamDirection(value);
    });
    direction_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);
    (new GuiPowerDamageIndicator(direction_slider, "", SYS_Docks, ATopCenter, my_spaceship))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    (new GuiLabel(this, "", "Direction:", 20))->setSize(GuiElement::GuiSizeMax, 30);

    range_slider = new GuiSlider(this, "", 0.0, 2000.0, 0.0, [this](float value) {
        if (my_spaceship) my_spaceship->commandSetTractorBeamRange(value);
    });
    range_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);
    (new GuiPowerDamageIndicator(range_slider, "", SYS_Docks, ATopCenter, my_spaceship))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    (new GuiLabel(this, "", "Range:", 20))->setSize(GuiElement::GuiSizeMax, 30);

    mode_selector = new GuiSelector(this, "MODE_SELECTOR", [this](int index, string value) {
        if (my_spaceship)
            my_spaceship->commandSetTractorBeamMode(ETractorBeamMode(index));
    });
    mode_selector->setOptions({"Off", "Pull", "Push", "Hold"});
    mode_selector->setSelectionIndex(0);
    mode_selector->setSize(GuiElement::GuiSizeMax, 30);
}

void GuiTractorBeamControl::onDraw(sf::RenderTarget& window)
{
    GuiAutoLayout::onDraw(window);
    if (my_spaceship){
        mode_selector->setSelectionIndex(int(my_spaceship->tractor_beam.getMode()));
        arc_slider->setValue(my_spaceship->tractor_beam.getArc());
        direction_slider->setValue(sf::angleDifference(0.0f, my_spaceship->tractor_beam.getDirection()));
        range_slider->setValue(my_spaceship->tractor_beam.getRange());
    }
}

