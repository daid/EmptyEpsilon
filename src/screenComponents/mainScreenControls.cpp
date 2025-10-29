#include "mainScreenControls.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "i18n.h"

#include "gui/gui2_panel.h"
#include "gui/gui2_togglebutton.h"

GuiMainScreenControls::GuiMainScreenControls(GuiContainer* owner)
: GuiElement(owner, "MAIN_SCREEN_CONTROLS"), open_button(nullptr), target_lock_button(nullptr), tactical_button(nullptr),
  long_range_button(nullptr), show_comms_button(nullptr), onscreen_comms_active(false)
{
    setSize(250.0f, GuiElement::GuiSizeMax);
    setPosition(-20.0f, 70.0f, sp::Alignment::TopRight);

    button_strip = new GuiPanel(this, "MAIN_SCREEN_CONTROLS_STRIP");
    button_strip->setPosition(0.0f, 0.0f, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 0.0f)->hide();
    // button_strip->setAttribute("padding", "0, 0, 50, 0");
    button_strip->setAttribute("layout", "vertical");

    // Set which buttons appear when opening the main screen controls.
    open_button = new GuiToggleButton(this, "MAIN_SCREEN_CONTROLS_SHOW", tr("controlbutton", "Main screen"),
    [this](bool value)
    {
        auto active_mode = MainScreenSetting::Front;
        if (!my_spaceship) return;
        if (auto pc = my_spaceship.getComponent<PlayerControl>()) active_mode = pc->main_screen_setting;

        // 3D controls
        if (front_button)
            front_button->setValue(active_mode == MainScreenSetting::Front);
        if (back_button)
            back_button->setValue(active_mode == MainScreenSetting::Back);
        if (left_button)
            left_button->setValue(active_mode == MainScreenSetting::Left);
        if (right_button)
            right_button->setValue(active_mode == MainScreenSetting::Right);
        if (target_lock_button)
            target_lock_button->setValue(active_mode == MainScreenSetting::Target);

        // Radar controls
        if (tactical_button)
        {
            tactical_button->setValue(active_mode == MainScreenSetting::Tactical);
            tactical_button->setVisible(gameGlobalInfo->allow_main_screen_tactical_radar);
        }
        if (long_range_button)
        {
            long_range_button->setValue(active_mode == MainScreenSetting::LongRange);
            long_range_button->setVisible(gameGlobalInfo->allow_main_screen_long_range_radar);
        }

        // Overlay controls
        if (show_comms_button)
            show_comms_button->setValue(onscreen_comms_active);

        if (value)
        {
            // Resize background strip to match number of buttons.
            float strip_size = 0.0f;

            for (GuiButton* button : buttons)
                if (button->isVisible()) strip_size += 50.0f;

            button_strip->setSize(GuiElement::GuiSizeMax, strip_size);
        }

        button_strip->setVisible(value)->moveToFront();
    });
    open_button->setValue(false)->setSize(GuiElement::GuiSizeMax, 50.0f);

    // Front, back, left, and right view buttons.
    buttons.push_back(new GuiToggleButton(button_strip, "MAIN_SCREEN_FRONT_BUTTON", tr("mainscreen", "Front"),
    [this](bool value)
    {
        if (my_spaceship)
            my_player_info->commandMainScreenSetting(MainScreenSetting::Front);

        closePopup();
    }));
    front_button = buttons.back();

    buttons.push_back(new GuiToggleButton(button_strip, "MAIN_SCREEN_BACK_BUTTON", tr("mainscreen", "Back"),
    [this](bool value)
    {
        if (my_spaceship)
            my_player_info->commandMainScreenSetting(MainScreenSetting::Back);

        closePopup();
    }));
    back_button = buttons.back();

    buttons.push_back(new GuiToggleButton(button_strip, "MAIN_SCREEN_LEFT_BUTTON", tr("mainscreen", "Left"),
    [this](bool value)
    {
        if (my_spaceship)
            my_player_info->commandMainScreenSetting(MainScreenSetting::Left);

        closePopup();
    }));
    left_button = buttons.back();

    buttons.push_back(new GuiToggleButton(button_strip, "MAIN_SCREEN_RIGHT_BUTTON", tr("mainscreen", "Right"),
    [this](bool value)
    {
        if (my_spaceship)
            my_player_info->commandMainScreenSetting(MainScreenSetting::Right);

        closePopup();
    }));
    right_button = buttons.back();

    // If the player has control over weapons targeting, they can enable the
    // target view on the main screen.
    if (my_player_info->hasPosition(CrewPosition::weaponsOfficer)
       || my_player_info->hasPosition(CrewPosition::tacticalOfficer)
       || my_player_info->hasPosition(CrewPosition::singlePilot))
    {
        buttons.push_back(new GuiToggleButton(button_strip, "MAIN_SCREEN_TARGET_BUTTON", tr("mainscreen", "Target lock"),
        [this](bool value)
        {
            if (my_spaceship)
                my_player_info->commandMainScreenSetting(MainScreenSetting::Target);

            closePopup();
        }));
        target_lock_button = buttons.back();
    }

    // Tactical radar button.
    buttons.push_back(new GuiToggleButton(button_strip, "MAIN_SCREEN_TACTICAL_BUTTON", tr("mainscreen", "Tactical radar"),
    [this](bool value)
    {
        if (my_spaceship)
            my_player_info->commandMainScreenSetting(MainScreenSetting::Tactical);

        closePopup();
    }));
    tactical_button = buttons.back();

    // Long-range radar button.
    buttons.push_back(new GuiToggleButton(button_strip, "MAIN_SCREEN_LONG_RANGE_BUTTON", tr("mainscreen", "Long-range radar"),
    [this](bool value)
    {
        if (my_spaceship)
            my_player_info->commandMainScreenSetting(MainScreenSetting::LongRange);

        closePopup();
    }));
    long_range_button = buttons.back();

    // If the player has control over comms, they can toggle the comms overlay
    // on the main screen.
    if (my_player_info->hasPosition(CrewPosition::relayOfficer)
       || my_player_info->hasPosition(CrewPosition::operationsOfficer)
       || my_player_info->hasPosition(CrewPosition::singlePilot)
       || my_player_info->hasPosition(CrewPosition::commsOnly))
    {
        buttons.push_back(new GuiToggleButton(button_strip, "MAIN_SCREEN_SHOW_COMMS_BUTTON", tr("mainscreen", "Comms overlay"),
        [this](bool value)
        {
            if (my_spaceship)
            {
                my_player_info->commandMainScreenOverlay(value ? MainScreenOverlay::ShowComms: MainScreenOverlay::HideComms);
                onscreen_comms_active = value;
            }

            closePopup();
        }));
        show_comms_button = buttons.back();
    }

    for (GuiButton* button : buttons) button->setSize(GuiElement::GuiSizeMax, 50);

    button_strip->hide();
}

void GuiMainScreenControls::closePopup()
{
    button_strip->hide();
    open_button->setValue(false)->show();
}
