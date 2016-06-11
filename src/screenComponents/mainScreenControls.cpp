#include "mainScreenControls.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"

#include "gui/gui2_togglebutton.h"

GuiMainScreenControls::GuiMainScreenControls(GuiContainer* owner)
: GuiAutoLayout(owner, "MAIN_SCREEN_CONTROLS", GuiAutoLayout::LayoutVerticalTopToBottom)
{
    setSize(250, GuiElement::GuiSizeMax);
    setPosition(-20, 70, ATopRight);
    
    open_button = new GuiToggleButton(this, "MAIN_SCREEN_CONTROLS_SHOW", "Main screen", [this](bool value)
    {
        for(GuiButton* button : buttons)
            button->setVisible(value);
        if (!gameGlobalInfo->allow_main_screen_tactical_radar)
            tactical_button->setVisible(false);
        if (!gameGlobalInfo->allow_main_screen_long_range_radar)
            long_range_button->setVisible(false);
        if (onscreen_comms_active)
            show_comms_button->setVisible(false);
        if (!onscreen_comms_active)
            hide_comms_button->setVisible(false);
    });
    open_button->setValue(false);
    open_button->setSize(GuiElement::GuiSizeMax, 50);
    
    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_FRONT_BUTTON", "Front", [this]()
    {
        if (my_spaceship)
        {
            my_spaceship->commandMainScreenSetting(MSS_Front);
        }
        open_button->setValue(false);
        for(GuiButton* button : buttons)
            button->setVisible(false);
    }));
    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_BACK_BUTTON", "Back", [this]()
    {
        if (my_spaceship)
        {
            my_spaceship->commandMainScreenSetting(MSS_Back);
        }
        open_button->setValue(false);
        for(GuiButton* button : buttons)
            button->setVisible(false);
    }));
    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_LEFT_BUTTON", "Left", [this]()
    {
        if (my_spaceship)
        {
            my_spaceship->commandMainScreenSetting(MSS_Left);
        }
        open_button->setValue(false);
        for(GuiButton* button : buttons)
            button->setVisible(false);
    }));
    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_RIGHT_BUTTON", "Right", [this]()
    {
        if (my_spaceship)
        {
            my_spaceship->commandMainScreenSetting(MSS_Right);
        }
        open_button->setValue(false);
        for(GuiButton* button : buttons)
            button->setVisible(false);
    }));
    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_TACTICAL_BUTTON", "Tactical", [this]()
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
    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_LONG_RANGE_BUTTON", "Long Range", [this]()
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
    if (my_player_info->crew_position[relayOfficer] || my_player_info->crew_position[operationsOfficer] || my_player_info->crew_position[singlePilot])
    {
        buttons.push_back(new GuiButton(this, "MAIN_SCREEN_SHOW_COMMS_BUTTON", "Show comms", [this]()
        {
            if (my_spaceship)
            {
                my_spaceship->commandMainScreenSetting(MSS_ShowComms);
                onscreen_comms_active = true;
            }
            open_button->setValue(false);
            for (GuiButton* button : buttons)
                button->setVisible(false);
        }));
        show_comms_button = buttons.back();

        buttons.push_back(new GuiButton(this, "MAIN_SCREEN_HIDE_COMMS_BUTTON", "Hide comms", [this]()
        {
            if (my_spaceship)
            {
                my_spaceship->commandMainScreenSetting(MSS_HideComms);
                onscreen_comms_active = false;
            }
            open_button->setValue(false);
            for (GuiButton* button : buttons)
                button->setVisible(false);
        }));
        hide_comms_button = buttons.back();
    }

    for(GuiButton* button : buttons)
        button->setSize(GuiElement::GuiSizeMax, 50)->setVisible(false);
}
