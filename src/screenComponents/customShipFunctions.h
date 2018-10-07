#ifndef CUSTOM_SHIP_FUNCTIONS_H
#define CUSTOM_SHIP_FUNCTIONS_H

#include "playerInfo.h"
#include "gui/gui2_autolayout.h"
class PlayerSpaceship;
class GuiCustomShipFunctions : public GuiAutoLayout
{
private:    
    class Entry
    {
    public:
        string name;
        GuiElement* element;
    };
    
    ECrewPosition position;
    std::vector<Entry> entries;
    P<PlayerSpaceship>& target_spaceship;
public:
    GuiCustomShipFunctions(GuiContainer* owner, ECrewPosition position, string id, P<PlayerSpaceship>& targetSpaceship);
    
    virtual void onDraw(sf::RenderTarget& window) override;

    bool hasEntries();
private:    
    void checkEntries();
    void createEntries();
};

#endif//CUSTOM_SHIP_FUNCTIONS_H
