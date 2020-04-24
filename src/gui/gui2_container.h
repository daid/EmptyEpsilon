#ifndef GUI2_CONTAINER_H
#define GUI2_CONTAINER_H

#include <list>
#include <SFML/System.hpp>
#include <SFML/Graphics.hpp>
#include "gui/joystickConfig.h"

class GuiElement;
class HotkeyResult;
class AxisAction;
class GuiContainer
{
protected:
    std::list<GuiElement*> elements;

public:
    GuiContainer() = default;
    virtual ~GuiContainer();

protected:
    virtual void drawElements(sf::FloatRect parent_rect, sf::RenderTarget& window);
    virtual void drawDebugElements(sf::FloatRect parent_rect, sf::RenderTarget& window);
    GuiElement* getClickElement(sf::Vector2f mouse_position);
    void forwardKeypressToElements(const HotkeyResult& key);
    bool forwardJoystickAxisToElements(const AxisAction& axisAction);

    friend class GuiElement;
};

#endif//GUI2_CONTAINER_H
