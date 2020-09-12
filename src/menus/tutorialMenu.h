#ifndef TUTORIAL_MENU_H
#define TUTORIAL_MENU_H

#include "gui/gui2_canvas.h"

class GuiAutoLayout;
class GuiElement;
class GuiSlider;
class GuiLabel;
class GuiScrollText;
class GuiButton;

class TutorialMenu : public GuiCanvas
{
    string selected_tutorial_filename;

    GuiAutoLayout* container;
    GuiElement* bottom_row;
    GuiScrollText* tutorial_description;
    GuiButton* start_tutorial_button;

private:
    void selectTutorial(string filename);

public:
    TutorialMenu();

    void onKey(sf::Event::KeyEvent key, int unicode);
};
#endif//TUTORIAL_MENU_H
