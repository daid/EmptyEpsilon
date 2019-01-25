#include "warpControls.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "powerDamageIndicator.h"

#include "gui/gui2_slider.h"
#include "gui/gui2_keyvaluedisplay.h"

GuiWarpControls::GuiWarpControls(GuiContainer* owner, string id, P<PlayerSpaceship> targetSpaceship)
: GuiElement(owner, id), target_spaceship(targetSpaceship)
{
    // Build warp request slider.
    slider = new GuiSlider(this, id + "_SLIDER", 4.0, 0.0, 0.0, [this](float value) {
        // Round the slider value to an int.
        int warp_level = value;

        // Send a warp request command to our ship.
        if (target_spaceship)
            target_spaceship->commandWarp(warp_level);

        // Set the slider value to the warp level.
        slider->setValue(warp_level);
    });
    slider->setPosition(0, 0, ATopLeft)->setSize(50, GuiElement::GuiSizeMax);

    // Snap the slider to integers up to 4.
    slider->addSnapValue(0.0, 0.5);
    slider->addSnapValue(1.0, 0.5);
    slider->addSnapValue(2.0, 0.5);
    slider->addSnapValue(3.0, 0.5);
    slider->addSnapValue(4.0, 0.5);

    if (target_spaceship)
    {
        // Set the slider's value to the current warp request.
        slider->setValue(target_spaceship->warp_request);
    }

    // Label the warp slider.
    label = new GuiKeyValueDisplay(this, id + "_LABEL", 0.5, "Warp", "0.0");
    label->setTextSize(30)->setPosition(50, 0, ATopLeft)->setSize(40, GuiElement::GuiSizeMax);

    // Prep the alert overlay.
    pdi = new GuiPowerDamageIndicator(this, id + "_DPI", SYS_Warp, ATopCenter, target_spaceship);
    pdi->setSize(50, GuiElement::GuiSizeMax);
}

void GuiWarpControls::setTargetSpaceship(P<PlayerSpaceship> targetSpaceship){
    target_spaceship = targetSpaceship;
    pdi->setTargetSpaceship(target_spaceship);
}

void GuiWarpControls::onDraw(sf::RenderTarget& window)
{
    // Update the label with the current warp factor.
    if (target_spaceship)
        label->setValue(string(target_spaceship->current_warp, 1));
}

void GuiWarpControls::onHotkey(const HotkeyResult& key)
{
    // Handle hotkey input. Warp is a HELMS-category shortcut.
    if (key.category == "HELMS" && target_spaceship)
    {
        if (key.hotkey == "WARP_0")
        {
            target_spaceship->commandWarp(0);
            slider->setValue(0);
        }
        else if (key.hotkey == "WARP_1")
        {
            target_spaceship->commandWarp(1);
            slider->setValue(1);
        }
        else if (key.hotkey == "WARP_2")
        {
            target_spaceship->commandWarp(2);
            slider->setValue(2);
        }
        else if (key.hotkey == "WARP_3")
        {
            target_spaceship->commandWarp(3);
            slider->setValue(3);
        }
        else if (key.hotkey == "WARP_4")
        {
            target_spaceship->commandWarp(4);
            slider->setValue(4);
        }
    }
}
