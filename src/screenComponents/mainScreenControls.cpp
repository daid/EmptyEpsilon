#include "mainScreenControls.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"

#include "gui/gui2_togglebutton.h"

GuiMainScreenControls::GuiMainScreenControls(GuiContainer* owner)
: GuiAutoLayout(owner, "MAIN_SCREEN_CONTROLS", GuiAutoLayout::LayoutVerticalTopToBottom)
{
    setSize(250, GuiElement::GuiSizeMax);
    setPosition(-20, 70, ATopRight);

    // Set which buttons appear when opening the main screen controls.
    open_button = new GuiToggleButton(this, "MAIN_SCREEN_CONTROLS_SHOW", "Main screen", [this](bool value)
    {
        for(GuiButton* button : buttons)
            button->setVisible(value);
        if (!gameGlobalInfo->allow_main_screen_tactical_radar)
            tactical_button->setVisible(false);
        if (!gameGlobalInfo->allow_main_screen_long_range_radar)
            long_range_button->setVisible(false);
        if (show_comms_button && onscreen_comms_active)
            show_comms_button->setVisible(false);
        if (hide_comms_button && !onscreen_comms_active)
            hide_comms_button->setVisible(false);
    });
    open_button->setValue(false);
    open_button->setSize(GuiElement::GuiSizeMax, 50);

    // Front, back, left, and right view buttons.
    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_FRONT_BUTTON", "Front", [this]()
    {
        if (my_spaceship)
        {
            my_spaceship->commandMainScreenSetting(MSS_Front);
        }
        closePopup();
    }));
    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_BACK_BUTTON", "Back", [this]()
    {
        if (my_spaceship)
        {
            my_spaceship->commandMainScreenSetting(MSS_Back);
        }
        closePopup();
    }));
    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_LEFT_BUTTON", "Left", [this]()
    {
        if (my_spaceship)
        {
            my_spaceship->commandMainScreenSetting(MSS_Left);
        }
        closePopup();
    }));
    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_RIGHT_BUTTON", "Right", [this]()
    {
        if (my_spaceship)
        {
            my_spaceship->commandMainScreenSetting(MSS_Right);
        }
        closePopup();
    }));

    // If the player has control over weapons targeting, enable the target view
    // option in the main screen controls.
    if (my_player_info->crew_position[weaponsOfficer] || my_player_info->crew_position[tacticalOfficer] || my_player_info->crew_position[singlePilot])
    {
        buttons.push_back(new GuiButton(this, "MAIN_SCREEN_TARGET_BUTTON", "Target lock", [this]()
        {
            if (my_spaceship)
            {
                my_spaceship->commandMainScreenSetting(MSS_Target);
            }
            closePopup();
        }));
        target_lock_button = buttons.back();
    }

    // Tactical radar button.
    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_TACTICAL_BUTTON", "Tactical", [this]()
    {
        if (my_spaceship)
        {
            my_spaceship->commandMainScreenSetting(MSS_Tactical);
        }
        closePopup();
    }));
    tactical_button = buttons.back();

    // Long-range radar button.
    buttons.push_back(new GuiButton(this, "MAIN_SCREEN_LONG_RANGE_BUTTON", "Long Range", [this]()
    {
        if (my_spaceship)
        {
            my_spaceship->commandMainScreenSetting(MSS_LongRange);
        }
        closePopup();
    }));
    long_range_button = buttons.back();

     // If the player has control over database, enable the database view option in the main screen controls.
    if (my_player_info->crew_position[scienceOfficer] || my_player_info->crew_position[operationsOfficer] || my_player_info->crew_position[singlePilot] || my_player_info->crew_position[databaseView])
    {
        buttons.push_back(new GuiButton(this, "MAIN_SCREEN_DATABASE_BUTTON", "Database", [this]()
        {
            if (my_spaceship)
            {
                my_spaceship->commandMainScreenSetting(MSS_Database);
            }
            closePopup();
        }));
        database_button = buttons.back();
    }

    // If the player has control over comms, they can toggle the comms overlay
    // on the main screen.
    if (my_player_info->crew_position[relayOfficer] || my_player_info->crew_position[operationsOfficer] || my_player_info->crew_position[singlePilot])
    {
        buttons.push_back(new GuiButton(this, "MAIN_SCREEN_SHOW_COMMS_BUTTON", "Show comms", [this]()
        {
            if (my_spaceship)
            {
                my_spaceship->commandMainScreenOverlay(MSO_ShowComms);
                onscreen_comms_active = true;
            }
            closePopup();
        }));
        show_comms_button = buttons.back();

        buttons.push_back(new GuiButton(this, "MAIN_SCREEN_HIDE_COMMS_BUTTON", "Hide comms", [this]()
        {
            if (my_spaceship)
            {
                my_spaceship->commandMainScreenOverlay(MSO_HideComms);
                onscreen_comms_active = false;
            }
            closePopup();
        }));
        hide_comms_button = buttons.back();
    }

    for(GuiButton* button : buttons)
        button->setSize(GuiElement::GuiSizeMax, 50)->setVisible(false);
}

void GuiMainScreenControls::closePopup()
{
    open_button->setValue(false);
    for (GuiButton* button : buttons)
        button->setVisible(false);
}
