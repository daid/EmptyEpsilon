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
#include "screenComponents/radarView.h"

const int BEAM_PANEL_HEIGHT = 290;
const int BEAM_PANEL_WIDTH = 290;

GuiTractorBeamControl::GuiTractorBeamControl(GuiContainer* owner, string id): GuiAutoLayout(owner, id, GuiAutoLayout::LayoutVerticalColumns){
    this->setSize(GuiElement::GuiSizeMax, BEAM_PANEL_HEIGHT);

    globalPanel = new GuiAutoLayout(this, "GLOBAL_PANEL", GuiAutoLayout::LayoutVerticalColumns);
    globalPanel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    globalPanel->setPosition(0, 0, ATopLeft);
    
    lateralPanel = new GuiAutoLayout(globalPanel, "LATERAL_PANEL", GuiAutoLayout::LayoutVerticalTopToBottom);
    lateralPanel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    lateralPanel->setPosition(0, 0, ACenterLeft);
    lateralPanel->setMargins(10, 10, 10, 10);
    
    (new GuiLabel(lateralPanel, "TITLE", "Tractor beam control", 30))
        ->addBackground()
        ->setAlignment(ACenter)
        ->setPosition(0, 0, ABottomCenter)
        ->setSize(GuiElement::GuiSizeMax, 50);
    
    mode_selector = new GuiSelector(lateralPanel, "MODE_SELECTOR", [this](int index, string value) {
        if (my_spaceship)
            my_spaceship->commandSetTractorBeamMode(ETractorBeamMode(index));
    });
    mode_selector->setOptions({"Off", "Pull", "Push", "Hold"});
    mode_selector->setSelectionIndex(0);
    mode_selector->setSize(GuiElement::GuiSizeMax, 30);

    (new GuiLabel(lateralPanel, "", "Range:", 20))->setSize(GuiElement::GuiSizeMax, 30);
    range_slider = new GuiSlider(lateralPanel, "", 0.0, 2000.0, 0.0, [this](float value) {
        if (my_spaceship) my_spaceship->commandSetTractorBeamRange(value);
    });
    range_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);
    (new GuiPowerDamageIndicator(range_slider, "", SYS_Docks, ATopCenter, my_spaceship))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiLabel(lateralPanel, "", "Direction:", 20))->setSize(GuiElement::GuiSizeMax, 30);
    direction_slider = new GuiSlider(lateralPanel, "", -179.9, 180.0, 0.0, [this](float value) {
        if (my_spaceship) my_spaceship->commandSetTractorBeamDirection(value);
    });
    direction_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);
    (new GuiPowerDamageIndicator(direction_slider, "", SYS_Docks, ATopCenter, my_spaceship))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiLabel(lateralPanel, "", "Arc:", 20))->setSize(GuiElement::GuiSizeMax, 30);
    arc_slider = new GuiSlider(lateralPanel, "", 0.0, 90.0, 0.0, [this](float value) {
        if (my_spaceship) my_spaceship->commandSetTractorBeamArc(value);
    });
    arc_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);
    (new GuiPowerDamageIndicator(arc_slider, "", SYS_Docks, ATopCenter, my_spaceship))->setSize(GuiElement::GuiSizeMax / 2.0, GuiElement::GuiSizeMax);    
    
    // 5U tactical radar with piloting features.
    radar = new GuiRadarView(globalPanel, "TACTICAL_RADAR", 2000.0, nullptr, my_spaceship);
    radar->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    radar->setPosition(0, 0, ACenterRight);
    radar->setMargins(10, 10, 10, 10);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular);
}

void GuiTractorBeamControl::onDraw(sf::RenderTarget& window)
{
    GuiAutoLayout::onDraw(window);
    if (my_spaceship){
        mode_selector->setSelectionIndex(int(my_spaceship->tractor_beam.getMode()));
        arc_slider->setValue(my_spaceship->tractor_beam.getArc());
        direction_slider->setValue(sf::angleDifference(0.0f, my_spaceship->tractor_beam.getDirection()));
        range_slider->setValue(my_spaceship->tractor_beam.getRange());
        range_slider->setRange(0.0, my_spaceship->tractor_beam.getMaxRange(6.0));
        radar->setDistance(my_spaceship->tractor_beam.getMaxRange(6.0));
    }
}

