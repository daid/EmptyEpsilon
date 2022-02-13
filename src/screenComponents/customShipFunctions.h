#ifndef CUSTOM_SHIP_FUNCTIONS_H
#define CUSTOM_SHIP_FUNCTIONS_H

#include "playerInfo.h"
#include "gui/gui2_element.h"

class GuiCustomShipFunctions : public GuiElement
{
public:
    GuiCustomShipFunctions(GuiContainer* owner, ECrewPosition position, string id);

    virtual void onUpdate() override;

    bool hasEntries();
private:
    class Entry
    {
    public:
        string name;
        GuiElement* element;
    };

    ECrewPosition position;
    std::vector<Entry> entries;

    void checkEntries();
    void createEntries();
};

#endif//CUSTOM_SHIP_FUNCTIONS_H
