#ifndef TUTORIAL_MENU_H
#define TUTORIAL_MENU_H

#include "gui/gui2_canvas.h"

class GuiSlider;
class GuiLabel;
class GuiScrollText;

class TutorialMenu : public GuiCanvas
{
    string selected_tutorial_filename;
    GuiScrollText* tutorial_description;
private:

    void selectTutorial(string filename);
public:
    TutorialMenu();

    void onKey(sf::Event::KeyEvent key, int unicode);
};
#endif//TUTORIAL_MENU_H
