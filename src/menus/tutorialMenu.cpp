#include <i18n.h>
#include "engine.h"
#include "tutorialMenu.h"
#include "main.h"
#include "preferenceManager.h"
#include "tutorialGame.h"
#include "scenarioInfo.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_autolayout.h"
#include "gui/gui2_button.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_label.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_scrolltext.h"
#include "gui/gui2_panel.h"

TutorialMenu::TutorialMenu()
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    // Draw a one-column autolayout container with margins.
    container = new GuiAutoLayout(this, "TUTORIAL_CONTAINER", GuiAutoLayout::ELayoutMode::LayoutVerticalTopToBottom);
    container->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setMargins(50);

    // Tutorial section.
    (new GuiLabel(container, "TUTORIAL_LABEL", tr("title", "Tutorials"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    // List each scenario derived from scenario_*.lua files in Resources.
    GuiListbox* tutorial_list = new GuiListbox(container, "TUTORIAL_LIST", [this](int index, string value)
    {
        selectTutorial(value);
    });
    tutorial_list->setSize(GuiElement::GuiSizeMax, 350);

    // Fetch and sort all Lua files starting with "tutorial_".
    std::vector<string> tutorial_filenames = findResources("tutorial_*.lua");
    std::sort(tutorial_filenames.begin(), tutorial_filenames.end());

    // For each scenario file, extract its name, then add it to the list.
    for(string filename : tutorial_filenames)
    {
        ScenarioInfo info(filename);
        tutorial_list->addEntry(info.name, filename);
    }

    // Show the scenario description text.
    GuiPanel* panel = new GuiPanel(container, "TUTORIAL_DESCRIPTION_BOX");
    panel->setSize(GuiElement::GuiSizeMax, 350);
    tutorial_description = new GuiScrollText(panel, "TUTORIAL_DESCRIPTION", "");
    tutorial_description->setTextSize(24)->setMargins(15)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Bottom GUI.
    bottom_row = new GuiElement(container, "TUTORIAL_BOTTOM_ROW");
    bottom_row->setSize(GuiElement::GuiSizeMax, 50);

    // Start tutorial button.
    start_tutorial_button = new GuiButton(bottom_row, "START_TUTORIAL", tr("Start Tutorial"), [this]() {
        destroy();
        new TutorialGame(false,selected_tutorial_filename);
    });
    start_tutorial_button->setEnable(false)->setPosition(0, 0, ABottomRight)->setSize(300, GuiElement::GuiSizeMax);

    // Back button.
    (new GuiButton(bottom_row, "BACK", tr("Back"), [this]()
    {
        // Close this menu, stop the music, and return to the main menu.
        destroy();
        returnToMainMenu();
    }))->setPosition(0, 0, ABottomLeft)->setSize(300, GuiElement::GuiSizeMax);

    // Select the first scenario in the list by default.
    if (!tutorial_filenames.empty()) {
        tutorial_list->setSelectionIndex(0);
        selectTutorial(tutorial_filenames.front());
    }
}
void TutorialMenu::selectTutorial(string filename)
{
    selected_tutorial_filename = filename;
    start_tutorial_button->setEnable(true);
    ScenarioInfo info(filename);
    tutorial_description->setText("");
    tutorial_description->setText(info.description);
}

void TutorialMenu::onKey(sf::Event::KeyEvent key, int unicode)
{
    switch(key.code)
    {
    //TODO: This is more generic code and is duplicated.
    case sf::Keyboard::Escape:
    case sf::Keyboard::Home:
        destroy();
        returnToMainMenu();
        break;
    default:
        break;
    }
}
