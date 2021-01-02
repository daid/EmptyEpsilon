#include <i18n.h>
#include "engine.h"
#include "optionsMenu.h"
#include "main.h"
#include "preferenceManager.h"

#include "gui/gui2_autolayout.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_button.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_label.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_keyvaluedisplay.h"

OptionsMenu::OptionsMenu()
{
    P<WindowManager> windowManager = engine->getObject("windowManager");

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    // Initialize autolayout columns.
    left_container = new GuiAutoLayout(this, "OPTIONS_LEFT_CONTAINER", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_container->setPosition(50, 50, ATopLeft)->setSize(300, GuiElement::GuiSizeMax);

    right_container = new GuiAutoLayout(this, "OPTIONS_RIGHT_CONTAINER", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_container->setPosition(-50, 50, ATopRight)->setSize(600, GuiElement::GuiSizeMax);

    // Options pager
    options_pager = new GuiSelector(left_container, "OPTIONS_PAGER", [this](int index, string value)
    {
        graphics_page->setVisible(index == 0);
        audio_page->setVisible(index == 1);
        interface_page->setVisible(index == 2);
    });
    options_pager->setOptions({tr("Graphics options"), tr("Audio options"), tr("Interface options")})->setSelectionIndex(0)->setSize(GuiElement::GuiSizeMax, 50);

    graphics_page = new GuiAutoLayout(left_container, "OPTIONS_GRAPHICS", GuiAutoLayout::LayoutVerticalTopToBottom);
    graphics_page->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->show();
    audio_page = new GuiAutoLayout(left_container, "OPTIONS_AUDIO", GuiAutoLayout::LayoutVerticalTopToBottom);
    audio_page->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->hide();
    interface_page = new GuiAutoLayout(left_container, "OPTIONS_INTERFACE", GuiAutoLayout::LayoutVerticalTopToBottom);
    interface_page->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->hide();

    // Graphics options
    // Fullscreen toggle.
    (new GuiButton(graphics_page, "FULLSCREEN_TOGGLE", tr("Fullscreen toggle"), []()
    {
        P<WindowManager> windowManager = engine->getObject("windowManager");
        windowManager->setFullscreen(!windowManager->isFullscreen());
    }))->setSize(GuiElement::GuiSizeMax, 50);

    // FSAA configuration.
    int fsaa = std::max(1, windowManager->getFSAA());
    int fsaa_index = 0;

    // Convert selector index to an FSAA amount.
    switch(fsaa)
    {
        case 8: fsaa_index = 3; break;
        case 4: fsaa_index = 2; break;
        case 2: fsaa_index = 1; break;
        default: fsaa_index = 0; break;
    }

    // FSAA selector.
    (new GuiSelector(graphics_page, "FSAA", [](int index, string value)
    {
        P<WindowManager> windowManager = engine->getObject("windowManager");
        static const int fsaa[] = { 0, 2, 4, 8 };
        windowManager->setFSAA(fsaa[index]);
    }))->setOptions({"FSAA: off", "FSAA: 2x", "FSAA: 4x", "FSAA: 8x"})->setSelectionIndex(fsaa_index)->setSize(GuiElement::GuiSizeMax, 50);

    // Audio optionss
    // Sound volume slider.
    sound_volume_slider = new GuiSlider(audio_page, "SOUND_VOLUME_SLIDER", 0.0f, 100.0f, soundManager->getMasterSoundVolume(), [this](float volume)
    {
        soundManager->setMasterSoundVolume(volume);
        sound_volume_overlay_label->setText(tr("Sound Volume: {volume}%").format({{"volume", string(int(soundManager->getMasterSoundVolume()))}}));
    });
    sound_volume_slider->setSize(GuiElement::GuiSizeMax, 50);

    // Override overlay label.
    sound_volume_overlay_label = new GuiLabel(sound_volume_slider, "SOUND_VOLUME_SLIDER_LABEL", tr("Sound Volume: {volume}%").format({{"volume", string(int(soundManager->getMasterSoundVolume()))}}), 30);
    sound_volume_overlay_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Music playback state.
    (new GuiLabel(audio_page, "MUSIC_PLAYBACK_LABEL", tr("Music Playback"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Determine when music is enabled.
    int music_enabled_index = PreferencesManager::get("music_enabled", "2").toInt();
    (new GuiSelector(audio_page, "MUSIC_ENABLED", [](int index, string value)
    {
        // 0: Always off
        // 1: Always on
        // 2: On if main screen, off otherwise (default)
        PreferencesManager::set("music_enabled", string(index));
    }))->setOptions({tr("Disabled"), tr("Enabled"), tr("Main Screen only")})->setSelectionIndex(music_enabled_index)->setSize(GuiElement::GuiSizeMax, 50);

    // Music volume slider.
    music_volume_slider = new GuiSlider(audio_page, "MUSIC_VOLUME_SLIDER", 0.0f, 100.0f, soundManager->getMusicVolume(), [this](float volume)
    {
        soundManager->setMusicVolume(volume);
        music_volume_overlay_label->setText(tr("Music Volume: {volume}%").format({{"volume", string(int(soundManager->getMusicVolume()))}}));
    });
    music_volume_slider->setSize(GuiElement::GuiSizeMax, 50);

    // Override overlay label.
    music_volume_overlay_label = new GuiLabel(music_volume_slider, "MUSIC_VOLUME_SLIDER_LABEL", tr("Music Volume: {volume}%").format({{"volume", string(int(soundManager->getMusicVolume()))}}), 30);
    music_volume_overlay_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Engine playback state.
    (new GuiLabel(audio_page, "IMPULSE_SOUND_LABEL", tr("Impulse Engine sound"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Determine when engine sound effects are enabled.
    int impulse_enabled_index = PreferencesManager::get("impulse_sound_enabled", "2").toInt();
    (new GuiSelector(audio_page, "ENGINE_ENABLED", [](int index, string value)
    {
        // 0: Always off
        // 1: Always on
        // 2: On if main screen, off otherwise (default)
        PreferencesManager::set("impulse_sound_enabled", string(index));
    }))->setOptions({tr("Disabled"), tr("Enabled"), tr("Main Screen only")})->setSelectionIndex(impulse_enabled_index)->setSize(GuiElement::GuiSizeMax, 50);

    // Impulse engine volume slider.
    impulse_volume_slider = new GuiSlider(audio_page, "IMPULSE_VOLUME_SLIDER", 0.0f, 100.0f, PreferencesManager::get("impulse_sound_volume", "50").toInt(), [this](float volume)
    {
        PreferencesManager::set("impulse_sound_volume", volume);
        impulse_volume_overlay_label->setText(tr("Impulse Volume: {volume}%").format({{"volume", string(PreferencesManager::get("impulse_sound_volume", "50").toInt())}}));
    });
    impulse_volume_slider->setSize(GuiElement::GuiSizeMax, 50);

    // Override overlay label.
    impulse_volume_overlay_label = new GuiLabel(impulse_volume_slider, "IMPULSE_VOLUME_SLIDER_LABEL", tr("Impulse Volume: {volume}%").format({{"volume", string(PreferencesManager::get("impulse_sound_volume", "50").toInt())}}), 30);
    impulse_volume_overlay_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Interface options
    // Radar rotation state.
    (new GuiLabel(interface_page, "RADAR_LOCK", tr("Lock Radar Rotation"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Helms rotation lock.
    (new GuiToggleButton(interface_page, "HEMS_RADAR_LOCK", tr("Helms Radar Lock"), [](bool value)
    {
        PreferencesManager::set("helms_radar_lock", value ? "1" : "");
        PreferencesManager::set("tactical_radar_lock", value ? "1" : "");
        PreferencesManager::set("single_pilot_radar_lock", value ? "1" : "");
    }))->setValue(PreferencesManager::get("helms_radar_lock", "0") == "1")->setSize(GuiElement::GuiSizeMax, 50);

    // Helms rotation lock.
    (new GuiToggleButton(interface_page, "WEAPONS_RADAR_LOCK", tr("Weapons Radar Lock"), [](bool value)
    {
        PreferencesManager::set("weapons_radar_lock", value ? "1" : "");
    }))->setValue(PreferencesManager::get("weapons_radar_lock", "0") == "1")->setSize(GuiElement::GuiSizeMax, 50);

    // Helms rotation lock.
    (new GuiToggleButton(interface_page, "SCIENCE_RADAR_LOCK", tr("Science Radar Lock"), [](bool value)
    {
        PreferencesManager::set("science_radar_lock", value ? "1" : "");
        PreferencesManager::set("operations_radar_lock", value ? "1" : "");
    }))->setValue(PreferencesManager::get("science_radar_lock", "0") == "1")->setSize(GuiElement::GuiSizeMax, 50);

    // Language.
    (new GuiLabel(interface_page, "LANGUAGE", tr("Language"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    language_selection = new GuiSelector(interface_page, "LANGUAGE_SELECTION", [](int index, string value)
    {
        PreferencesManager::set("language", string(value));
        i18n::reset();
        i18n::load("locale/" + PreferencesManager::get("language", "en") + ".po");
    });
    language_selection->setOptions({"cz", "de", "en", "fr", "it"})->setSize(GuiElement::GuiSizeMax, 50);
    language_selection->setSelectionIndex(language_selection->indexByValue(PreferencesManager::get("language", "en")));
    (new GuiLabel(interface_page, "LANGUAGE_INSTRUCTIONS", tr("Exit options to apply"), 30))->setSize(GuiElement::GuiSizeMax, 50);

    // Right column, auto layout. Draw first element 50px from top.
    // Music preview jukebox.

    // Draw list of available music. Grabs every ogg file in the
    // resources/music folder and lists them by filename.
    std::vector<string> ambient_music_filenames = findResources("music/ambient/*.ogg");
    std::sort(ambient_music_filenames.begin(), ambient_music_filenames.end());
    std::vector<string> combat_music_filenames = findResources("music/combat/*.ogg");
    std::sort(combat_music_filenames.begin(), combat_music_filenames.end());

    (new GuiLabel(right_container, "PREVIEW_LABEL", tr("Preview Soundtracks"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    GuiListbox* music_list = new GuiListbox(right_container, "MUSIC_PLAY", [this](int index, string value)
    {
        soundManager->playMusic(value);
    });

    for(string filename : ambient_music_filenames)
        music_list->addEntry(filename.substr(filename.rfind("/") + 1, filename.rfind(".")), filename);
    for(string filename : combat_music_filenames)
        music_list->addEntry(filename.substr(filename.rfind("/") + 1, filename.rfind(".")), filename);

    music_list->setSize(GuiElement::GuiSizeMax, 750);

    // Bottom GUI.
    // Back button.
    (new GuiButton(this, "BACK", tr("options", "Back"), [this]()
    {
        // Close this menu, stop the music, and return to the main menu.
        destroy();
        soundManager->stopMusic();
        returnToMainMenu();
    }))->setPosition(50, -50, ABottomLeft)->setSize(150, 50);
    // Save options button.
    (new GuiButton(this, "SAVE_OPTIONS", tr("options", "Save"), [this]()
    {
        if (getenv("HOME"))
            PreferencesManager::save(string(getenv("HOME")) + "/.emptyepsilon/options.ini");
        else
            PreferencesManager::save("options.ini");
    }))->setPosition(200, -50, ABottomLeft)->setSize(150, 50);
}

void OptionsMenu::onKey(sf::Event::KeyEvent key, int unicode)
{
    switch(key.code)
    {
    //TODO: This is more generic code and is duplicated.
    case sf::Keyboard::Escape:
    case sf::Keyboard::Home:
        destroy();
        soundManager->stopMusic();
        returnToMainMenu();
        break;
    default:
        break;
    }
}
