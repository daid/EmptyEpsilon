#include <libintl.h>

#include "mainScreenControls.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "language.h"

GuiMainScreenControls::GuiMainScreenControls(GuiContainer* owner)
: GuiAutoLayout(owner, "MAIN_SCREEN_CONTROLS", GuiAutoLayout::LayoutVerticalTopToBottom)
{
    setSize(300, GuiElement::GuiSizeMax);
    setPosition(0, 0, ATopRight);

    open_button = new GuiToggleButton(this, "MAIN_SCREEN_CONTROLS_SHOW", gettext("Main screen"), [this](bool value)
    {
        for(GuiButton* button : buttons)
            button->setVisible(value);
        if (!gameGlobalInfo->allow_main_screen_tactical_radar)
            tactical_button->setVisible(false);
        if (!gameGlobalInfo->allow_main_screen_long_range_radar)
            long_range_button->setVisible(false);
    });
    open_button->setValue(false);
    open_button->setSize(GuiElement::GuiSizeMax, 50);

    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_FRONT_BUTTON", gettext("Front"), [this]()
    {
        if (my_spaceship)
        {
            my_spaceship->commandMainScreenSetting(MSS_Front);
        }
        open_button->setValue(false);
        for(GuiButton* button : buttons)
            button->setVisible(false);
    }));
    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_BACK_BUTTON", pgettext("Back of the ship", "Back"), [this]()
    {
        if (my_spaceship)
        {
            my_spaceship->commandMainScreenSetting(MSS_Back);
        }
        open_button->setValue(false);
        for(GuiButton* button : buttons)
            button->setVisible(false);
    }));
    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_LEFT_BUTTON", gettext("Left"), [this]()
    {
        if (my_spaceship)
        {
            my_spaceship->commandMainScreenSetting(MSS_Left);
        }
        open_button->setValue(false);
        for(GuiButton* button : buttons)
            button->setVisible(false);
    }));
    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_RIGHT_BUTTON", gettext("Right"), [this]()
    {
        if (my_spaceship)
        {
            my_spaceship->commandMainScreenSetting(MSS_Right);
        }
        open_button->setValue(false);
        for(GuiButton* button : buttons)
            button->setVisible(false);
    }));
    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_TACTICAL_BUTTON", gettext("Tactical"), [this]()
    {
        if (my_spaceship)
        {
            my_spaceship->commandMainScreenSetting(MSS_Tactical);
        }
        open_button->setValue(false);
        for(GuiButton* button : buttons)
            button->setVisible(false);
    }));
    tactical_button = buttons.back();
    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_LONG_RANGE_BUTTON", gettext("Long Range"), [this]()
    {
        if (my_spaceship)
        {
            my_spaceship->commandMainScreenSetting(MSS_LongRange);
        }
        open_button->setValue(false);
        for(GuiButton* button : buttons)
            button->setVisible(false);
    }));
    long_range_button = buttons.back();

    for(GuiButton* button : buttons)
        button->setSize(GuiElement::GuiSizeMax, 50)->setVisible(false);
}
