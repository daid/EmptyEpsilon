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

    (new GuiButton(this, "FULLSCREEN", "Fullscreen toggle", []()
    {
        P<WindowManager> windowManager = engine->getObject("windowManager");
        windowManager->setFullscreen(!windowManager->isFullscreen());
    }))->setPosition(50, 100, ATopLeft)->setSize(300, 50);

    // Add fsaa selector.
    int fsaa = std::max(1, windowManager->getFSAA());
    int fsaa_index = 0;
    switch(fsaa)
    {
        case 8: fsaa_index = 3; break;
        case 4: fsaa_index = 2; break;
        case 2: fsaa_index = 1; break;
        default: fsaa_index = 0; break;
    }
    (new GuiSelector(this, "FSAA", [](int index, string value)
    {
        P<WindowManager> windowManager = engine->getObject("windowManager");
        static const int fsaa[] = { 0, 2, 4, 8 };
        windowManager->setFSAA(fsaa[index]);
    }))->setOptions({"FSAA: off", "FSAA: 2x", "FSAA: 4x", "FSAA: 8x"})->setSelectionIndex(fsaa_index)->setPosition(50, 160, ATopLeft)->setSize(300, 50);

    // Add music selection
    (new GuiLabel(this, "MUSIC_ENABLED_LABEL", "Music", 30))->addBackground()->setPosition(50, 220, ATopLeft)->setSize(300, 50);

    int music_enabled_index = PreferencesManager::get("music_enabled", "2").toInt();
    (new GuiSelector(this, "MUSIC_ENABLED", [](int index, string value)
    {
        // 0: Always off
        // 1: Always on
        // 2: On if main screen, off otherwise (default)
        PreferencesManager::set("music_enabled", string(index));
    }))->setOptions({"Disabled", "Enabled", "Main Screen only"})->setSelectionIndex(music_enabled_index)->setPosition(50, 270, ATopLeft)->setSize(300, 50);

    (new GuiLabel(this, "MUSIC_VOL_LABEL", "Music volume", 30))->addBackground()->setPosition(50, 330, ATopLeft)->setSize(300, 50);

    (new GuiSlider(this, "MUSIC_VOL", 0, 100, soundManager->getMusicVolume(), [](float volume)
    {
        soundManager->setMusicVolume(volume);
    }))->setPosition(50, 380, ATopLeft)->setSize(300, 50);

    (new GuiButton(this, "BACK", "Back", [this]()
    {
        destroy();
        returnToMainMenu();
    }))->setPosition(50, -50, ABottomLeft)->setSize(300, 50);

    (new GuiLabel(this, "MUSIC_SELECT_LABEL", "Select Soundtrack", 30))->addBackground()->setPosition(-50, 50, ATopRight)->setSize(600, 50);
    GuiListbox* music_list = new GuiListbox(this, "MUSIC_PLAY", [this](int index, string value)
    {
        soundManager->playMusic(value);
    });
    music_list->setPosition(-50, 100, ATopRight)->setSize(600, 800);

    std::vector<string> music_filenames = findResources("music/*.ogg");
    std::sort(music_filenames.begin(), music_filenames.end());
    for(string filename : music_filenames)
    {
        music_list->addEntry(filename.substr(filename.rfind("/") + 1, filename.rfind(".")), filename);
    }
}
