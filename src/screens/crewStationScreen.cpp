#include "crewStationScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "preferenceManager.h"
#include "playerInfo.h"
#include "multiplayer_client.h"
#include "soundManager.h"

#include "components/customshipfunction.h"

#include "screenComponents/indicatorOverlays.h"
#include "screenComponents/noiseOverlay.h"
#include "screenComponents/shipDestroyedPopup.h"
#include "screenComponents/helpOverlay.h"
#include "screenComponents/impulseSound.h"
#include "screenComponents/viewportMainScreen.h"

#include "gui/gui2_togglebutton.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_scrolltext.h"
#include "gui/joystickConfig.h"

#include <i18n.h>

CrewStationScreen::CrewStationScreen(RenderLayer* render_layer, bool with_main_screen)
: GuiCanvas(render_layer)
{
    if (with_main_screen)
    {
        // Create a 3D viewport behind everything, to serve as the right-side panel
        viewport = new GuiViewportMainScreen(this, "3D_VIEW");
        viewport->showCallsigns()->showHeadings()->showSpacedust();
        viewport->setPosition(1200, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        viewport->hide();
    }

    main_panel = new GuiElement(this, "MAIN");
    main_panel->setSize(1200, GuiElement::GuiSizeMax);

    select_station_button = new GuiButton(main_panel, "", "", [this]()
    {
        button_strip->show();
    });
    select_station_button->setPosition(-20, 20, sp::Alignment::TopRight)->setSize(250, 50);

    button_strip = new GuiPanel(main_panel, "");
    button_strip->setPosition(-20, 20, sp::Alignment::TopRight)->setSize(250, 50);
    button_strip->hide();

    message_frame = new GuiPanel(main_panel, "");
    message_frame->setPosition(0, 0, sp::Alignment::TopCenter)->setSize(900, 230)->hide();

    message_text = new GuiScrollFormattedText(message_frame, "", "");
    message_text->setTextSize(20)->setPosition(20, 20, sp::Alignment::TopLeft)->setSize(900 - 40, 200 - 40);
    message_close_button = new GuiButton(message_frame, "", tr("button", "Close"), [this]() {
        if (auto csf = my_spaceship.getComponent<CustomShipFunctions>())
        {
            for(auto& f : csf->functions)
            {
                if (f.crew_positions.has(current_position) && f.type == CustomShipFunctions::Function::Type::Message)
                {
                    my_player_info->commandCustomFunction(f.name);
                    break;
                }
            }
        }
    });
    message_close_button->setTextSize(30)->setPosition(-20, -20, sp::Alignment::BottomRight)->setSize(300, 30);

    keyboard_help = new GuiHelpOverlay(main_panel, tr("hotkey_F1", "Keyboard Shortcuts"));

    for (const auto& category : {tr("hotkey_menu", "Console"), tr("hotkey_menu", "Basic"), tr("hotkey_menu", "General")})
    {
        for (auto binding : sp::io::Keybinding::listAllByCategory(category))
            keyboard_general += tr("hotkey_F1", "{label}: {button}\n").format({{"label", binding->getLabel()}, {"button", binding->getHumanReadableKeyName(0)}});
    }

#ifndef __ANDROID__
    if (PreferencesManager::get("music_enabled") == "1")
    {
        threat_estimate = new ThreatLevelEstimate();
        threat_estimate->setCallbacks([]()
        {
            LOG(INFO) << "Switching to ambient music";
            soundManager->playMusicSet(findResources("music/ambient/*.ogg"));
        }, []() {
            LOG(INFO) << "Switching to combat music";
            soundManager->playMusicSet(findResources("music/combat/*.ogg"));
        });
    }
#endif

    // Initialize and play the impulse engine sound.
    impulse_sound = std::unique_ptr<ImpulseSound>( new ImpulseSound(PreferencesManager::get("impulse_sound_enabled", "2") == "1") );
}

void CrewStationScreen::destroy()
{
    if (threat_estimate)
        threat_estimate->destroy();
    PObject::destroy();
}

GuiContainer* CrewStationScreen::getTabContainer()
{
    return main_panel;
}

string CrewStationScreen::populateShortcutsList(CrewPosition position)
{
    string ret = "";

    bool show_additional_shortcuts_string = false;

    // Add shortcuts for this position.
    for (auto binding : sp::io::Keybinding::listAllByCategory(getCrewPositionName(position)))
    {
        if(binding->isBound())
        {
            ret += binding->getLabel() + ": " + binding->getHumanReadableKeyName(0) + "\n";
        }
        else
        {
            show_additional_shortcuts_string = true;
        }
    }

    // Check special positions that include multiple core positions' functions.
    if (position == CrewPosition::tacticalOfficer)
    {
        for (auto binding : sp::io::Keybinding::listAllByCategory(getCrewPositionName(CrewPosition::helmsOfficer)))
        {
            if(binding->isBound())
            {
                ret += binding->getLabel() + ": " + binding->getHumanReadableKeyName(0) + "\n";
            }
            else
            {
                show_additional_shortcuts_string = true;
            }
        }

        for (auto binding : sp::io::Keybinding::listAllByCategory(getCrewPositionName(CrewPosition::weaponsOfficer)))
        {
            if (binding->getLabel() != "Toggle shields")
            {
                if(binding->isBound())
                {
                    ret += binding->getLabel() + ": " + binding->getHumanReadableKeyName(0) + "\n";
                }
                else
                {
                    show_additional_shortcuts_string = true;
                }
            }
        }
    }
    else if (position == CrewPosition::engineeringAdvanced)
    {
        for (auto binding : sp::io::Keybinding::listAllByCategory(getCrewPositionName(CrewPosition::engineering)))
        {
            if(binding->isBound())
            {
                ret += binding->getLabel() + ": " + binding->getHumanReadableKeyName(0) + "\n";
            }
            else
            {
                show_additional_shortcuts_string = true;
            }
        }

        for (auto binding : sp::io::Keybinding::listAllByCategory(getCrewPositionName(CrewPosition::weaponsOfficer)))
        {
            if (binding->getLabel() == "Toggle shields")
            {
                if(binding->isBound())
                {
                    ret += binding->getLabel() + ": " + binding->getHumanReadableKeyName(0) + "\n";
                }
                else
                {
                    show_additional_shortcuts_string = true;
                }
            }
        }
    }
    else if (position == CrewPosition::singlePilot)
    {
        for (auto binding : sp::io::Keybinding::listAllByCategory(getCrewPositionName(CrewPosition::helmsOfficer)))
        {
            if(binding->isBound())
            {
                ret += binding->getLabel() + ": " + binding->getHumanReadableKeyName(0) + "\n";
            }
            else
            {
                show_additional_shortcuts_string = true;
            }
        }

        for (auto binding : sp::io::Keybinding::listAllByCategory(getCrewPositionName(CrewPosition::weaponsOfficer)))
        {
            if(binding->isBound())
            {
                ret += binding->getLabel() + ": " + binding->getHumanReadableKeyName(0) + "\n";
            }
            else
            {
                show_additional_shortcuts_string = true;
            }
        }
    }

    if (show_additional_shortcuts_string)
    {
        ret += "\n" + tr("More shortcuts available in settings") + "\n";
    }

    //    -- not yet used --
    //    else if (station == "Operations")
    //        return ret;
    //    ----

    return ret;
}

void CrewStationScreen::addStationTab(GuiElement* element, CrewPosition position, string name, string icon)
{
    CrewTabInfo info;
    tileViewport();
    element->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    info.position = position;
    info.element = element;

    info.button = new GuiToggleButton(button_strip, "STATION_BUTTON_" + name, name, [this, element](bool value) {
        showTab(element);
        button_strip->hide();
    });
    info.button->setIcon(icon);
    info.button->setPosition(0, tabs.size() * 50, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 50);

    if (tabs.size() == 0)
    {
        current_position = position;
        element->show();
        info.button->setValue(true);
        select_station_button->setText(name);
        select_station_button->setIcon(icon);

        string keyboard_category = "";
        keyboard_category = populateShortcutsList(position);
        keyboard_help->setText(keyboard_general + keyboard_category);
    }
    else
    {
        element->hide();
        info.button->setValue(false);
    }

    tabs.push_back(info);
}

void CrewStationScreen::finishCreation()
{
    select_station_button->moveToFront();
    button_strip->moveToFront();
    button_strip->setSize(button_strip->getSize().x, 50 * tabs.size());

    message_frame->moveToFront();

    new GuiIndicatorOverlays(main_panel);
    new GuiNoiseOverlay(main_panel);
    new GuiShipDestroyedPopup(this);

    if (tabs.size() < 2)
        select_station_button->hide();

    keyboard_help->moveToFront();
}

void CrewStationScreen::update(float delta)
{
    if (game_client && game_client->getStatus() == GameClient::Disconnected)
    {
        destroy();
        soundManager->stopMusic();
        impulse_sound->stop();
        disconnectFromServer();
        returnToMainMenu(getRenderLayer());
        return;
    }

    if (keys.escape.getDown())
    {
        //If we're using autoconnect do nothing on escape, otherwise go back to the ship selection. 
        if (PreferencesManager::get("autoconnect") == "")
        {
            destroy();
            soundManager->stopMusic();
            impulse_sound->stop();
            returnToShipSelection(getRenderLayer());
        }
    }
    if (keys.help.getDown())
    {
        // Toggle keyboard help.
        keyboard_help->frame->setVisible(!keyboard_help->frame->isVisible());
    }
    if (keys.pause.getDown())
    {
        if (game_server)
            engine->setGameSpeed(0.0);
    }

    if (viewport)
    {
        // Responsively show/hide the 3D viewport.
        if (getRect().size.x < 1250)
        {
            viewport->hide();
            main_panel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        }
        else
        {
            viewport->show();
            tileViewport();
        }
    }
    else
    {
        main_panel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    }
    

    message_frame->hide();
    if (auto csf = my_spaceship.getComponent<CustomShipFunctions>())
    {
        // Show custom ship function messages.
        for(auto& f : csf->functions)
        {
            if (f.crew_positions.has(current_position) && f.type == CustomShipFunctions::Function::Type::Message)
            {
                message_frame->show();
                message_text->setText(f.caption);
                break;
            }
        }
    }

    if (my_spaceship) {
        // Update the impulse engine sound.
        impulse_sound->update(delta);
    } 
    else
    {
        // If we're not the player ship (ie. we exploded), stop playing the
        // impulse engine sound.
        impulse_sound->stop();
    }

    if (keys.next_station.getDown())
        showNextTab(1);
    else if (keys.prev_station.getDown())
        showNextTab(-1);
    else if (keys.station_helms.getDown())
        showTab(findTab(getCrewPositionName(CrewPosition::helmsOfficer)));
    else if (keys.station_weapons.getDown())
        showTab(findTab(getCrewPositionName(CrewPosition::weaponsOfficer)));
    else if (keys.station_engineering.getDown())
        showTab(findTab(getCrewPositionName(CrewPosition::engineering)));
    else if (keys.station_science.getDown())
        showTab(findTab(getCrewPositionName(CrewPosition::scienceOfficer)));
    else if (keys.station_relay.getDown())
        showTab(findTab(getCrewPositionName(CrewPosition::relayOfficer)));
}

void CrewStationScreen::showNextTab(int offset)
{
    if (tabs.size() < 1) return;
    int current = 0;

    for(unsigned int n=0; n<tabs.size(); n++)
    {
        if (tabs[n].element->isVisible())
            current = n;
    }

    int next = (current + offset + tabs.size()) % tabs.size();

    showTab(tabs[next].element);
}

void CrewStationScreen::showTab(GuiElement* element)
{
    if (!element)
        return;

    for(CrewTabInfo& info : tabs)
    {
        if (info.element == element)
        {
            current_position = info.position;
            info.element->show();
            info.button->setValue(true);
            select_station_button->setText(info.button->getText());
            select_station_button->setIcon(info.button->getIcon());

            string keyboard_category = "";
            keyboard_category = populateShortcutsList(info.position);
            keyboard_help->setText(keyboard_general + keyboard_category);
        } 
        else 
        {
            info.element->hide();
            info.button->setValue(false);
        }
    }
}

GuiElement* CrewStationScreen::findTab(string name)
{
    for(CrewTabInfo& info : tabs)
    {
        if (info.button->getText() == name)
            return info.element;
    }

    return nullptr;
}

void CrewStationScreen::tileViewport()
{
    if (!viewport)
        return;

    if (current_position == CrewPosition::singlePilot)
    {
        main_panel->setSize(1000, GuiElement::GuiSizeMax);
        main_panel->layout.fill_width = false;
        viewport->setPosition(1000, 0, sp::Alignment::TopLeft);
    }
    else 
    {
        main_panel->setSize(1200, GuiElement::GuiSizeMax);
        main_panel->layout.fill_width = false;
        viewport->setPosition(1200, 0, sp::Alignment::TopLeft);
    }
}
