#ifndef GUI2_CONTAINER_H
#define GUI2_CONTAINER_H

#include <list>
#include <SFML/System.hpp>
#include <SFML/Graphics.hpp>

class GuiElement;
class GuiContainer
{
protected:
    std::list<GuiElement*> elements;

public:
    GuiContainer();
    virtual ~GuiContainer();

protected:
    virtual void drawElements(sf::FloatRect window_rect, sf::RenderTarget& window);
    virtual void drawDebugElements(sf::FloatRect window_rect, sf::RenderTarget& window);
    GuiElement* getClickElement(sf::Vector2f mouse_position);
    bool forwardKeypressToElements(sf::Keyboard::Key key, int unicode);
    bool forwardJoystickXYMoveToElements(sf::Vector2f position);
    
    friend class GuiElement;
};

#endif//GUI2_CONTAINER_H
