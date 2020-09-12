#ifndef SELF_DESTRUCT_ENTRY_H
#define SELF_DESTRUCT_ENTRY_H

#include "gui/gui2_element.h"
#include "spaceObjects/playerSpaceship.h"

class GuiPanel;
class GuiLabel;

class GuiSelfDestructEntry : public GuiElement
{
private:
    GuiPanel* box;
    GuiLabel* code_label;
    GuiElement* code_entry;
    GuiLabel* code_entry_code_label;
    GuiLabel* code_entry_label;
    int code_entry_position;

    bool has_position[max_crew_positions];
public:
    GuiSelfDestructEntry(GuiContainer* owner, string id);

    virtual void onDraw(sf::RenderTarget& window);

    void enablePosition(ECrewPosition position) { has_position[position] = true; }
};

#endif//SELF_DESTRUCT_ENTRY_H
