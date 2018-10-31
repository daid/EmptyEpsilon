#ifndef GUI2_CONTAINER_H
#define GUI2_CONTAINER_H

#include <list>
#include <SFML/System.hpp>
#include <SFML/Graphics.hpp>

class GuiElement;
class HotkeyResult;
class GuiContainer
{
protected:
    std::list<GuiElement*> elements;

public:
    GuiContainer();
    virtual ~GuiContainer();

protected:
    virtual void drawElements(sf::FloatRect parent_rect, sf::RenderTarget& window);
    virtual void drawDebugElements(sf::FloatRect parent_rect, sf::RenderTarget& window);
    GuiElement* getClickElement(sf::Vector2f mouse_position);
    void forwardKeypressToElements(const HotkeyResult& key);
    bool forwardJoystickXYMoveToElements(sf::Vector2f position);
    bool forwardJoystickZMoveToElements(float position);
    bool forwardJoystickRMoveToElements(float position);
    
    friend class GuiElement;
};

#endif//GUI2_CONTAINER_H
