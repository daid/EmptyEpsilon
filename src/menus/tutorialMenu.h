#ifndef TUTORIAL_MENU_H
#define TUTORIAL_MENU_H

#include "gui/gui2_canvas.h"
#include "Updatable.h"

class GuiElement;
class GuiSlider;
class GuiLabel;
class GuiScrollText;
class GuiButton;

class TutorialMenu : public GuiCanvas, public Updatable
{
    string selected_tutorial_filename;

    GuiElement* container;
    GuiElement* bottom_row;
    GuiScrollText* tutorial_description;
    GuiButton* start_tutorial_button;

private:
    void selectTutorial(string filename);

public:
    TutorialMenu();

    virtual void update(float delta) override;
};
#endif//TUTORIAL_MENU_H
