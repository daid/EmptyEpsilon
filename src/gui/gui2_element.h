#ifndef GUI2_ELEMENT_H
#define GUI2_ELEMENT_H

#include <functional>
#include "stringImproved.h"
#include "colorConfig.h"
#include "hotkeyConfig.h"
#include "gui2_container.h"
#include "main.h"

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

class GuiElement : public GuiContainer
{
private:
    sf::Vector2f position;
    sf::Vector2f size;
    sf::FloatRect margins;
    EGuiAlign position_alignment;
    bool destroyed;
protected:
    GuiContainer* owner;
    sf::FloatRect rect;
    bool visible;
    bool enabled;
    bool hover;
    bool focus;
    bool active;
    string id;
public:
    constexpr static float GuiSizeMatchHeight = -1.0;
    constexpr static float GuiSizeMatchWidth = -1.0;
    constexpr static float GuiSizeMax = -2.0;

    GuiElement(GuiContainer* owner, string id);
    virtual ~GuiElement();

    virtual void onUpdate() {}
    virtual void onDraw(sf::RenderTarget& window) {}
    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseDrag(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
    virtual bool onKey(sf::Event::KeyEvent key, int unicode);
    virtual bool onTextEntered(sf::Event::TextEvent text, int unicode);
    virtual void onHotkey(const HotkeyResult& key);
    virtual bool onJoystickAxis(const AxisAction& axisAction);
    virtual void onFocusGained() {}
    virtual void onFocusLost() {}

    GuiElement* setSize(sf::Vector2f size);
    GuiElement* setSize(float x, float y);
    sf::Vector2f getSize() const;
    GuiElement* setMargins(float n);
    GuiElement* setMargins(float x, float y);
    GuiElement* setMargins(float left, float top, float right, float bottom);
    GuiElement* setPosition(float x, float y, EGuiAlign alignment = ATopLeft);
    GuiElement* setPosition(sf::Vector2f position, EGuiAlign alignment = ATopLeft);
    sf::Vector2f getPositionOffset() const;
    GuiElement* setVisible(bool visible);
    GuiElement* hide();
    GuiElement* show();
    bool isVisible() const;
    GuiElement* setEnable(bool enable);
    GuiElement* enable();
    GuiElement* disable();
    GuiElement* setActive(bool active);
    bool isActive() const;
    sf::FloatRect getRect() const { return rect; }
    bool isEnabled() const;

    void moveToFront();
    void moveToBack();

    sf::Vector2f getCenterPoint() const;

    GuiContainer* getOwner();
    GuiContainer* getTopLevelContainer();

    //Have this GuiElement destroyed, but at a safe point&time in the code. (handled by the container)
    void destroy();

    friend class GuiContainer;
    friend class GuiCanvas;
private:
    void updateRect(sf::FloatRect parent_rect);
protected:
    void adjustRenderTexture(sf::RenderTexture& texture);
    void drawRenderTexture(sf::RenderTexture& texture, sf::RenderTarget& window, sf::Color color = sf::Color::White, const sf::RenderStates& states = sf::RenderStates::Default);

    /*!
     * Draw a certain text on the screen with horizontal orientation.
     * \param rect Area to draw in
     * \param align Alighment of text.
     * \param text_size Size of the text
     * \param color Color of text
     */
    void drawText(sf::RenderTarget& window, sf::FloatRect rect, string text, EGuiAlign align = ATopLeft, float text_size = 30, sf::Font* font = main_font, sf::Color color=sf::Color::White);

    /*!
     * Draw a certain text on the screen with vertical orientation
     * \param rect Area to draw in
     * \param align Alighment of text.
     * \param text_size Size of the text
     * \param color Color of text
     */
    void drawVerticalText(sf::RenderTarget& window, sf::FloatRect rect, string text, EGuiAlign align = ATopLeft, float text_size = 30, sf::Font* font = main_font, sf::Color color=sf::Color::White);

    void draw9Cut(sf::RenderTarget& window, sf::FloatRect rect, string texture, sf::Color color=sf::Color::White, float width_factor = 1.0);
    void draw9CutV(sf::RenderTarget& window, sf::FloatRect rect, string texture, sf::Color color=sf::Color::White, float height_factor = 1.0);

    void drawStretched(sf::RenderTarget& window, sf::FloatRect rect, string texture, sf::Color color=sf::Color::White);
    void drawStretchedH(sf::RenderTarget& window, sf::FloatRect rect, string texture, sf::Color color=sf::Color::White);
    void drawStretchedV(sf::RenderTarget& window, sf::FloatRect rect, string texture, sf::Color color=sf::Color::White);
    void drawStretchedHV(sf::RenderTarget& window, sf::FloatRect rect, float corner_size, string texture, sf::Color color=sf::Color::White);

    void drawArrow(sf::RenderTarget& window, sf::FloatRect rect, sf::Color=sf::Color::White, float rotation=0);

    sf::Color selectColor(ColorSet& color_set) const;

    class LineWrapResult
    {
    public:
        string text;
        int line_count;
    };
    LineWrapResult doLineWrap(string text, float font_size, float width);
};

#endif//GUI2_ELEMENT_H
