#pragma once

#include "playerInfo.h"
#include "gui/gui2_scrollcontainer.h"

class GuiCustomShipFunctions : public GuiScrollContainer
{
public:
    GuiCustomShipFunctions(GuiContainer* owner, CrewPosition position, string id);

    virtual void onUpdate() override;

    bool hasEntries();
private:
    class Entry
    {
    public:
        string name;
        GuiElement* element;
    };

    const float ROW_HEIGHT = 50.0f;
    GuiScrollContainer* container;
    CrewPosition position;
    std::vector<Entry> entries;

    void checkEntries();
    void createEntries();
};
