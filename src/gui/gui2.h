#ifndef GUI2_H
#define GUI2_H

#include "engine.h"

enum EGuiAlign
{
    ATopLeft,
    ATopRight,
    ATopCenter,
    ACenterLeft,
    ACenterRight,
    ACenter,
    ABottomLeft,
    ABottomRight,
    ABottomCenter
};


class GuiElement;
class GuiContainer
{
private:
    std::list<GuiElement*> elements;

public:
    GuiContainer();
    virtual ~GuiContainer();

    virtual void drawElements(sf::FloatRect window_rect, sf::RenderTarget& window);
    virtual GuiElement* getClickElement(sf::Vector2f mouse_position);
    
    friend class GuiElement;
};

class GuiCanvas : public Renderable, public GuiContainer
{
private:
    GuiElement* click_element;
public:
    GuiCanvas();
    virtual ~GuiCanvas();

    virtual void render(sf::RenderTarget& window);
};

class GuiElement
{
protected:
    sf::Vector2f position;
    sf::Vector2f size;
    EGuiAlign position_alignment;
    GuiContainer* owner;
    sf::FloatRect rect;
    bool visible;
    bool enabled;
    bool has_focus;
    string id;
public:
    GuiElement(GuiContainer* owner, string id);
    virtual ~GuiElement();

    virtual void onDraw(sf::RenderTarget& window) = 0;
    virtual GuiElement* onMouseDown(sf::Vector2f position);
    virtual void onMouseDrag(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
    
    GuiElement* setSize(sf::Vector2f size);
    GuiElement* setSize(float x, float y);
    GuiElement* setPosition(float x, float y, EGuiAlign alignment = ATopLeft);
    GuiElement* setPosition(sf::Vector2f position, EGuiAlign alignment = ATopLeft);
    GuiElement* setVisible(bool visible);
    GuiElement* hide();
    GuiElement* show();
    GuiElement* setEnable(bool enable);
    GuiElement* enable();
    GuiElement* disable();
    
    friend class GuiContainer;
private:
    void updateRect(sf::FloatRect window_rect);
protected:
    /*!
     * Draw a certain text on the screen with horizontal orientation.
     * \param rect Area to draw in
     * \param align Alighment of text.
     * \param text_size Size of the text
     * \param color Color of text
     */
    void drawText(sf::RenderTarget& window, sf::FloatRect rect, string text, EGuiAlign align = ATopLeft, float text_size = 30, sf::Color color=sf::Color::White);

    /*!
     * Draw a certain text on the screen with vertical orientation
     * \param rect Area to draw in
     * \param align Alighment of text.
     * \param text_size Size of the text
     * \param color Color of text
     */
    void drawVerticalText(sf::RenderTarget& window, sf::FloatRect rect, string text, EGuiAlign align = ATopLeft, float text_size = 30, sf::Color color=sf::Color::White);

    void draw9Cut(sf::RenderTarget& window, sf::FloatRect rect, string texture, sf::Color color=sf::Color::White, float width_factor = 1.0);
    
    void drawArrow(sf::RenderTarget& window, sf::FloatRect rect, sf::Color=sf::Color::White, float rotation=0);
};

#endif//GUI2_H
