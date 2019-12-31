#ifndef OBJECT_CREATION_VIEW_H
#define OBJECT_CREATION_VIEW_H

#include "gui/gui2_overlay.h"

class GuiSelector;
class GuiContainer;

class GuiObjectCreationView : public GuiOverlay
{
    typedef std::function<void()> func_t;
private:
    string create_script;
    GuiSelector* faction_selector;
    func_t enterCreateMode;
public:
    GuiObjectCreationView(GuiContainer* owner, func_t enterCreateMode);
    
    virtual bool onMouseDown(sf::Vector2f position);
    
    void setCreateScript(string script);
    
    void createObject(sf::Vector2f position);
};

#endif//OBJECT_CREATION_VIEW_H
