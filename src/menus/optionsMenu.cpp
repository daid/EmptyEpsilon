#include <i18n.h>
#include "engine.h"
#include "optionsMenu.h"
#include "hotkeyMenu.h"
#include "main.h"
#include "preferenceManager.h"
#include "soundManager.h"
#include "windowManager.h"

#include "gui/gui2_overlay.h"
#include "gui/gui2_button.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_keyvaluedisplay.h"


OptionsMenu::OptionsMenu()
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    // Initialize autolayout columns.
    auto main_panel = new GuiPanel(this, "");
    main_panel->setPosition(0, 0, sp::Alignment::Center)->setSize(800, 700);
    container = new GuiElement(main_panel, "CONTAINER");
    container->setMargins(20, 70, 20, 20)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Options pager
    options_pager = new GuiSelector(main_panel, "OPTIONS_PAGER", [this](int index, string value)
    {
        graphics_page->setVisible(index == 0);
        audio_page->setVisible(index == 1);
        interface_page->setVisible(index == 2);
    });
    options_pager->setOptions({tr("Graphics options"), tr("Audio options"), tr("Interface options")})->setSelectionIndex(0)->setSize(GuiElement::GuiSizeMax, 50);

    graphics_page = new GuiElement(container, "OPTIONS_GRAPHICS");
    graphics_page->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->show()->setAttribute("layout", "vertical");
    audio_page = new GuiElement(container, "OPTIONS_AUDIO");
    audio_page->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->hide();
    interface_page = new GuiElement(container, "OPTIONS_INTERFACE");
    interface_page->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->hide()->setAttribute("layout", "vertical");

    setupGraphicsOptions();
    setupAudioOptions();

    // Interface options
    (new GuiLabel(interface_page, "CONTROL_OPTIONS_LABEL", tr("Radar Rotation"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    // Helms rotation lock.
    (new GuiToggleButton(interface_page, "HEMS_RADAR_LOCK", tr("Helms Radar Lock"), [](bool value)
    {
        PreferencesManager::set("helms_radar_lock", value ? "1" : "");
        PreferencesManager::set("tactical_radar_lock", value ? "1" : "");
        PreferencesManager::set("single_pilot_radar_lock", value ? "1" : "");
    }))->setValue(PreferencesManager::get("helms_radar_lock", "0") == "1")->setSize(GuiElement::GuiSizeMax, 50);

    // Weapons rotation lock.
    (new GuiToggleButton(interface_page, "WEAPONS_RADAR_LOCK", tr("Weapons Radar Lock"), [](bool value)
    {
        PreferencesManager::set("weapons_radar_lock", value ? "1" : "");
    }))->setValue(PreferencesManager::get("weapons_radar_lock", "0") == "1")->setSize(GuiElement::GuiSizeMax, 50);

    // Science rotation lock.
    (new GuiToggleButton(interface_page, "SCIENCE_RADAR_LOCK", tr("Science Radar Lock"), [](bool value)
    {
        PreferencesManager::set("science_radar_lock", value ? "1" : "");
        PreferencesManager::set("operations_radar_lock", value ? "1" : "");
    }))->setValue(PreferencesManager::get("science_radar_lock", "0") == "1")->setSize(GuiElement::GuiSizeMax, 50);

    // Control configuration
    (new GuiLabel(interface_page, "CONTROL_OPTIONS_LABEL", tr("Control Options"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Keyboard config (hotkeys/keybindings)
    (new GuiButton(interface_page, "CONFIGURE_KEYBOARD", tr("Configure Keyboard"), [this]()
    {
        new HotkeyMenu();
        destroy();
    }))->setSize(GuiElement::GuiSizeMax, 50);

    //Select the language
    (new GuiLabel(interface_page, "LANGUAGE_OPTIONS_LABEL", tr("Language (applies on back)"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    
    std::vector<string> languages = findResources("locale/main.*.po");
    
    for(string &language : languages) 
    {
        //strip extension
        language = language.substr(language.find(".") + 1, language.rfind("."));
    }
    std::sort(languages.begin(), languages.end());

    int default_index = 0;
    auto default_elem = std::find(languages.begin(), languages.end(), PreferencesManager::get("language", "en"));
    if(default_elem != languages.end())
    {
        default_index =  static_cast<int>(default_elem - languages.begin());
    }
    
    (new GuiSelector(interface_page, "LANGUAGE_SELECTOR", [](int index, string value)
    {
        i18n::reset();
        i18n::load("locale/main." + value + ".po");
        PreferencesManager::set("language", value);
    }))->setOptions(languages)->setSelectionIndex(default_index)->setSize(GuiElement::GuiSizeMax, 50);
    
    // Bottom GUI.
    // Back button.
    (new GuiButton(this, "BACK", tr("button", "Back"), [this]()
    {
        // Close this menu, stop the music, and return to the main menu.
        destroy();
        soundManager->stopMusic();
        returnToMainMenu(getRenderLayer());
    }))->setPosition(50, -50, sp::Alignment::BottomLeft)->setSize(150, 50);
    // Save options button.
    (new GuiButton(this, "SAVE_OPTIONS", tr("options", "Save"), []()
    {
        if (getenv("HOME"))
            PreferencesManager::save(string(getenv("HOME")) + "/.emptyepsilon/options.ini");
        else
            PreferencesManager::save("options.ini");
    }))->setPosition(200, -50, sp::Alignment::BottomLeft)->setSize(150, 50);
}

void OptionsMenu::update(float delta)
{
    if (keys.escape.getDown())
    {
        destroy();
        soundManager->stopMusic();
        returnToMainMenu(getRenderLayer());
    }
}

void OptionsMenu::setupGraphicsOptions()
{
    // Fullscreen toggle.
    (new GuiButton(graphics_page, "FULLSCREEN_TOGGLE", tr("Fullscreen toggle"), []() {
        foreach(Window, window, windows) {
            window->setFullscreen(!window->isFullscreen());
        }
    }))->setSize(GuiElement::GuiSizeMax, 50);

    // FSAA configuration.
    int fsaa = std::max(1, windows[0]->getFSAA());
    int fsaa_index = 0;

    // Convert selector index to an FSAA amount.
    switch (fsaa)
    {
    case 8: fsaa_index = 3; break;
    case 4: fsaa_index = 2; break;
    case 2: fsaa_index = 1; break;
    default: fsaa_index = 0; break;
    }

    // FSAA selector.
    (new GuiSelector(graphics_page, "FSAA", [](int index, string value) {
        static const int fsaa[] = { 0, 2, 4, 8 };
        foreach(Window, window, windows) {
            window->setFSAA(fsaa[index]);
        }
    }))->setOptions({ "FSAA: off", "FSAA: 2x", "FSAA: 4x", "FSAA: 8x" })->setSelectionIndex(fsaa_index)->setSize(GuiElement::GuiSizeMax, 50);

    // FoV slider.
    auto initial_fov = PreferencesManager::get("main_screen_camera_fov", "60").toFloat();
    graphics_fov_slider = new GuiBasicSlider(graphics_page, "GRAPHICS_FOV_SLIDER", 30.f, 140.0f, initial_fov, [this](float fov) {
        fov = std::round(fov);
        graphics_fov_slider->setValue(fov);
        PreferencesManager::set("main_screen_camera_fov", fov);
        graphics_fov_overlay_label->setText(tr("FoV: {fov}").format({ {"fov", string(fov, 0)} }));
    });
    graphics_fov_slider->setSize(GuiElement::GuiSizeMax, 50);

    // Override overlay label.
    graphics_fov_overlay_label = new GuiLabel(graphics_fov_slider, "GRAPHICS_FOV_SLIDER_LABEL", tr("FoV: {fov}").format({ {"fov", string(initial_fov, 0)} }), 30);
    graphics_fov_overlay_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void OptionsMenu::setupAudioOptions()
{
    audio_page->setAttribute("layout", "horizontal");
    auto left = new GuiElement(audio_page, "");
    left->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
    auto right = new GuiElement(audio_page, "");
    right->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setMargins(20, 0, 0, 0)->setAttribute("layout", "vertical");

    // Sound volume slider.
    sound_volume_slider = new GuiSlider(left, "SOUND_VOLUME_SLIDER", 0.0f, 100.0f, soundManager->getMasterSoundVolume(), [this](float volume)
    {
        soundManager->setMasterSoundVolume(volume);
        sound_volume_overlay_label->setText(tr("Sound Volume: {volume}%").format({{"volume", string(int(soundManager->getMasterSoundVolume()))}}));
    });
    sound_volume_slider->setSize(GuiElement::GuiSizeMax, 50);

    // Override overlay label.
    sound_volume_overlay_label = new GuiLabel(sound_volume_slider, "SOUND_VOLUME_SLIDER_LABEL", tr("Sound Volume: {volume}%").format({{"volume", string(int(soundManager->getMasterSoundVolume()))}}), 30);
    sound_volume_overlay_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Music playback state.
    (new GuiLabel(left, "MUSIC_PLAYBACK_LABEL", tr("Music Playback"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Determine when music is enabled.
    int music_enabled_index = PreferencesManager::get("music_enabled", "2").toInt();
    (new GuiSelector(left, "MUSIC_ENABLED", [](int index, string value)
    {
        // 0: Always off
        // 1: Always on
        // 2: On if main screen, off otherwise (default)
        PreferencesManager::set("music_enabled", string(index));
    }))->setOptions({tr("Disabled"), tr("Enabled"), tr("Main Screen only")})->setSelectionIndex(music_enabled_index)->setSize(GuiElement::GuiSizeMax, 50);

    // Music volume slider.
    music_volume_slider = new GuiSlider(left, "MUSIC_VOLUME_SLIDER", 0.0f, 100.0f, soundManager->getMusicVolume(), [this](float volume)
    {
        soundManager->setMusicVolume(volume);
        music_volume_overlay_label->setText(tr("Music Volume: {volume}%").format({{"volume", string(int(soundManager->getMusicVolume()))}}));
    });
    music_volume_slider->setSize(GuiElement::GuiSizeMax, 50);

    // Override overlay label.
    music_volume_overlay_label = new GuiLabel(music_volume_slider, "MUSIC_VOLUME_SLIDER_LABEL", tr("Music Volume: {volume}%").format({{"volume", string(int(soundManager->getMusicVolume()))}}), 30);
    music_volume_overlay_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Engine playback state.
    (new GuiLabel(left, "IMPULSE_SOUND_LABEL", tr("Impulse Engine sound"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Determine when engine sound effects are enabled.
    int impulse_enabled_index = PreferencesManager::get("impulse_sound_enabled", "2").toInt();
    (new GuiSelector(left, "ENGINE_ENABLED", [](int index, string value)
    {
        // 0: Always off
        // 1: Always on
        // 2: On if main screen, off otherwise (default)
        PreferencesManager::set("impulse_sound_enabled", string(index));
    }))->setOptions({tr("Disabled"), tr("Enabled"), tr("Main Screen only")})->setSelectionIndex(impulse_enabled_index)->setSize(GuiElement::GuiSizeMax, 50);

    // Impulse engine volume slider.
    impulse_volume_slider = new GuiSlider(left, "IMPULSE_VOLUME_SLIDER", 0.0f, 100.0f, static_cast<float>(PreferencesManager::get("impulse_sound_volume", "50").toInt()), [this](float volume)
    {
        PreferencesManager::set("impulse_sound_volume", volume);
        impulse_volume_overlay_label->setText(tr("Impulse Volume: {volume}%").format({{"volume", string(PreferencesManager::get("impulse_sound_volume", "50").toInt())}}));
    });
    impulse_volume_slider->setSize(GuiElement::GuiSizeMax, 50);

    // Override overlay label.
    impulse_volume_overlay_label = new GuiLabel(impulse_volume_slider, "IMPULSE_VOLUME_SLIDER_LABEL", tr("Impulse Volume: {volume}%").format({{"volume", string(PreferencesManager::get("impulse_sound_volume", "50").toInt())}}), 30);
    impulse_volume_overlay_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Music preview jukebox.

    // Draw list of available music. Grabs every ogg file in the
    // resources/music folder and lists them by filename.
    std::vector<string> ambient_music_filenames = findResources("music/ambient/*.ogg");
    std::sort(ambient_music_filenames.begin(), ambient_music_filenames.end());
    std::vector<string> combat_music_filenames = findResources("music/combat/*.ogg");
    std::sort(combat_music_filenames.begin(), combat_music_filenames.end());

    (new GuiLabel(right, "PREVIEW_LABEL", tr("Preview Soundtracks"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    GuiListbox* music_list = new GuiListbox(right, "MUSIC_PLAY", [](int index, string value)
    {
        soundManager->playMusic(value);
    });

    for(string filename : ambient_music_filenames)
        music_list->addEntry(filename.substr(filename.rfind("/") + 1, filename.rfind(".")), filename);
    for(string filename : combat_music_filenames)
        music_list->addEntry(filename.substr(filename.rfind("/") + 1, filename.rfind(".")), filename);

    music_list->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}
