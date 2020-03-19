#include <i18n.h>
#include "engine.h"
#include "optionsMenu.h"
#include "main.h"
#include "preferenceManager.h"

#include "gui/gui2_overlay.h"
#include "gui/gui2_button.h"
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

    // Left column, manual layout. Draw first element at 50px from top.
    int top = 50;

    // Graphics options.
    (new GuiLabel(this, "GRAPHICS_OPTIONS_LABEL", tr("Graphics Options"), 30))->addBackground()->setPosition(50, top, ATopLeft)->setSize(300, 50);

    // Fullscreen toggle.
    top += 50;
    (new GuiButton(this, "FULLSCREEN_TOGGLE", tr("Fullscreen toggle"), []()
    {
        P<WindowManager> windowManager = engine->getObject("windowManager");
        windowManager->setFullscreen(!windowManager->isFullscreen());
    }))->setPosition(50, top, ATopLeft)->setSize(300, 50);

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
    top += 50;
    (new GuiSelector(this, "FSAA", [](int index, string value)
    {
        P<WindowManager> windowManager = engine->getObject("windowManager");
        static const int fsaa[] = { 0, 2, 4, 8 };
        windowManager->setFSAA(fsaa[index]);
    }))->setOptions({"FSAA: off", "FSAA: 2x", "FSAA: 4x", "FSAA: 8x"})->setSelectionIndex(fsaa_index)->setPosition(50, top, ATopLeft)->setSize(300, 50);

    // Sound options.
    top += 60;
    (new GuiLabel(this, "SOUND_OPTIONS_LABEL", tr("Sound Options"), 30))->addBackground()->setPosition(50, top, ATopLeft)->setSize(300, 50);

    // Sound volume slider.
    top += 50;
    sound_volume_slider = new GuiSlider(this, "SOUND_VOLUME_SLIDER", 0.0f, 100.0f, soundManager->getMasterSoundVolume(), [this](float volume)
    {
        soundManager->setMasterSoundVolume(volume);
        sound_volume_overlay_label->setText(tr("Sound Volume: {volume}%").format({{"volume", string(int(soundManager->getMasterSoundVolume()))}}));
    });
    sound_volume_slider->setPosition(50, top, ATopLeft)->setSize(300, 50);

    // Override overlay label.
    sound_volume_overlay_label = new GuiLabel(sound_volume_slider, "SOUND_VOLUME_SLIDER_LABEL", tr("Sound Volume: {volume}%").format({{"volume", string(int(soundManager->getMasterSoundVolume()))}}), 30);
    sound_volume_overlay_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Music volume slider.
    top += 50;
    music_volume_slider = new GuiSlider(this, "MUSIC_VOLUME_SLIDER", 0.0f, 100.0f, soundManager->getMusicVolume(), [this](float volume)
    {
        soundManager->setMusicVolume(volume);
        music_volume_overlay_label->setText(tr("Music Volume: {volume}%").format({{"volume", string(int(soundManager->getMusicVolume()))}}));
    });
    music_volume_slider->setPosition(50, top, ATopLeft)->setSize(300, 50);

    // Override overlay label.
    music_volume_overlay_label = new GuiLabel(music_volume_slider, "MUSIC_VOLUME_SLIDER_LABEL", tr("Music Volume: {volume}%").format({{"volume", string(int(soundManager->getMusicVolume()))}}), 30);
    music_volume_overlay_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Engine volume slider.
    top += 50;
    engine_volume_slider = new GuiSlider(this, "ENGINE_VOLUME_SLIDER", 0.0f, 100.0f, PreferencesManager::get("engine_volume", "50").toInt(), [this](float volume)
    {
        PreferencesManager::set("engine_volume", volume);
        engine_volume_overlay_label->setText(tr("Engine Volume: {volume}%").format({{"volume", string(PreferencesManager::get("engine_volume", "50").toInt())}}));
    });
    engine_volume_slider->setPosition(50, top, ATopLeft)->setSize(300, 50);

    // Override overlay label.
    engine_volume_overlay_label = new GuiLabel(engine_volume_slider, "ENGINE_VOLUME_SLIDER_LABEL", tr("Engine Volume: {volume}%").format({{"volume", string(PreferencesManager::get("engine_volume", "50").toInt())}}), 30);
    engine_volume_overlay_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Music playback state.
    top += 60;
    (new GuiLabel(this, "MUSIC_PLAYBACK_LABEL", tr("Music Playback"), 30))->addBackground()->setPosition(50, top, ATopLeft)->setSize(300, 50);

    // Determine when music is enabled.
    int music_enabled_index = PreferencesManager::get("music_enabled", "2").toInt();
    top += 50;
    (new GuiSelector(this, "MUSIC_ENABLED", [](int index, string value)
    {
        // 0: Always off
        // 1: Always on
        // 2: On if main screen, off otherwise (default)
        PreferencesManager::set("music_enabled", string(index));
    }))->setOptions({tr("Disabled"), tr("Enabled"), tr("Main Screen only")})->setSelectionIndex(music_enabled_index)->setPosition(50, top, ATopLeft)->setSize(300, 50);

    // Engine playback state.
    top += 60;
    (new GuiLabel(this, "ENGINE_SFX_LABEL", tr("Engine SFX"), 30))->addBackground()->setPosition(50, top, ATopLeft)->setSize(300, 50);

    // Determine when engine sound effects are enabled.
    int engine_enabled_index = PreferencesManager::get("engine_enabled", "2").toInt();
    top += 50;
    (new GuiSelector(this, "ENGINE_ENABLED", [](int index, string value)
    {
        // 0: Always off
        // 1: Always on
        // 2: On if main screen, off otherwise (default)
        PreferencesManager::set("engine_enabled", string(index));
    }))->setOptions({tr("Disabled"), tr("Enabled"), tr("Main Screen only")})->setSelectionIndex(engine_enabled_index)->setPosition(50, top, ATopLeft)->setSize(300, 50);

    // Right column, manual layout. Draw first element 50px from top.
    top = 50;

    // Music preview jukebox.
    (new GuiLabel(this, "MUSIC_PREVIEW_LABEL", "Preview Soundtrack", 30))->addBackground()->setPosition(-50, top, ATopRight)->setSize(600, 50);

    // Draw list of available music. Grabs every ogg file in the music folder
    // and lists them by filename.
    // TODO: Associate ambient and combat music within the list.
    top += 50;
    GuiListbox* music_list = new GuiListbox(this, "MUSIC_PLAY", [this](int index, string value)
    {
        soundManager->playMusic(value);
    });
    music_list->setPosition(-50, top, ATopRight)->setSize(600, 800);

    std::vector<string> music_filenames = findResources("music/*.ogg");
    std::sort(music_filenames.begin(), music_filenames.end());
    for(string filename : music_filenames)
    {
        music_list->addEntry(filename.substr(filename.rfind("/") + 1, filename.rfind(".")), filename);
    }

    // Bottom GUI.
    // Back button.
    (new GuiButton(this, "BACK", "Back", [this]()
    {
        // Close this menu, stop the music, and return to the main menu.
        destroy();
        soundManager->stopMusic();
        returnToMainMenu();
    }))->setPosition(50, -50, ABottomLeft)->setSize(300, 50);
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
