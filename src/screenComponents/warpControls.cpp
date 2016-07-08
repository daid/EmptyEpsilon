#include "warpControls.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "powerDamageIndicator.h"

#include "gui/gui2_slider.h"
#include "gui/gui2_keyvaluedisplay.h"

GuiWarpControls::GuiWarpControls(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    slider = new GuiSlider(this, id + "_SLIDER", 4.0, 0.0, 0.0, [this](float value) {
        int warp_level = value;
        if (my_spaceship)
            my_spaceship->commandWarp(warp_level);
        slider->setValue(warp_level);
    });
    slider->setPosition(0, 0, ATopLeft)->setSize(50, GuiElement::GuiSizeMax);
    slider->addSnapValue(0.0, 0.5);
    slider->addSnapValue(1.0, 0.5);
    slider->addSnapValue(2.0, 0.5);
    slider->addSnapValue(3.0, 0.5);
    slider->addSnapValue(4.0, 0.5);
    
    label = new GuiKeyValueDisplay(this, id + "_LABEL", 0.5, "Warp", "0.0");
    label->setTextSize(30)->setPosition(50, 0, ATopLeft)->setSize(40, GuiElement::GuiSizeMax);
    
    (new GuiPowerDamageIndicator(this, id + "_DPI", SYS_Warp, ATopCenter))->setSize(50, GuiElement::GuiSizeMax);
}

void GuiWarpControls::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
        label->setValue(string(my_spaceship->current_warp, 1));
}

void GuiWarpControls::onHotkey(const HotkeyResult& key)
{
    if (key.category == "HELMS" && my_spaceship)
    {
        if (key.hotkey == "WARP_0")
        {
            my_spaceship->commandWarp(0);
            slider->setValue(0);
        }
        else if (key.hotkey == "WARP_1")
        {
            my_spaceship->commandWarp(1);
            slider->setValue(1);
        }
        else if (key.hotkey == "WARP_2")
        {
            my_spaceship->commandWarp(2);
            slider->setValue(2);
        }
        else if (key.hotkey == "WARP_3")
        {
            my_spaceship->commandWarp(3);
            slider->setValue(3);
        }
        else if (key.hotkey == "WARP_4")
        {
            my_spaceship->commandWarp(4);
            slider->setValue(4);
        }
    }
}
