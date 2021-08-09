#ifndef GUI2_ELEMENT_H
#define GUI2_ELEMENT_H

#include <functional>
#include "stringImproved.h"
#include "colorConfig.h"
#include "hotkeyConfig.h"
#include "gui2_container.h"
#include "main.h"

class GuiElement : public GuiContainer
{
private:
    glm::vec2 position;
    glm::vec2 size;
    struct Margins {
        float left, top, right, bottom;
    } margins;
    sp::Alignment position_alignment;
    bool destroyed;
protected:
    GuiContainer* owner;
    sp::Rect rect;
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

    GuiElement(GuiContainer* owner, const string& id);
    virtual ~GuiElement();

    virtual void onUpdate() {}
    virtual void onDraw(sp::RenderTarget& window) {}
    virtual bool onMouseDown(glm::vec2 position);
    virtual void onMouseDrag(glm::vec2 position);
    virtual void onMouseUp(glm::vec2 position);
    virtual bool onKey(sf::Event::KeyEvent key, int unicode);
    virtual void onHotkey(const HotkeyResult& key);
    virtual bool onJoystickAxis(const AxisAction& axisAction);
    virtual void onFocusGained() {}
    virtual void onFocusLost() {}

    GuiElement* setSize(glm::vec2 size);
    GuiElement* setSize(float x, float y);
    glm::vec2 getSize() const;
    GuiElement* setMargins(float n);
    GuiElement* setMargins(float x, float y);
    GuiElement* setMargins(float left, float top, float right, float bottom);
    GuiElement* setPosition(float x, float y, sp::Alignment alignment = sp::Alignment::TopLeft);
    GuiElement* setPosition(glm::vec2 position, sp::Alignment alignment = sp::Alignment::TopLeft);
    glm::vec2 getPositionOffset() const;
    GuiElement* setVisible(bool visible);
    GuiElement* hide();
    GuiElement* show();
    bool isVisible() const;
    GuiElement* setEnable(bool enable);
    GuiElement* enable();
    GuiElement* disable();
    GuiElement* setActive(bool active);
    bool isActive() const;
    sp::Rect getRect() const { return rect; }
    bool isEnabled() const;

    void moveToFront();
    void moveToBack();

    glm::vec2 getCenterPoint() const;

    GuiContainer* getOwner();
    GuiContainer* getTopLevelContainer();

    //Have this GuiElement destroyed, but at a safe point&time in the code. (handled by the container)
    void destroy();

    bool isDestroyed();

    friend class GuiContainer;
    friend class GuiCanvas;
private:
    void updateRect(sp::Rect parent_rect);
protected:
    /*! Setup (and creates) a RenderTexture with a view that fits this element.
    * \param texture inout The RT target to update
    * \return Whether the texture was successfully created/updated.
    */
    [[nodiscard]]
    bool adjustRenderTexture(sf::RenderTexture& texture);
    void drawRenderTexture(sf::RenderTexture& texture, sf::RenderTarget& window, sf::Color color = sf::Color::White, const sf::RenderStates& states = sf::RenderStates::Default);

    sf::Color selectColor(ColorSet& color_set) const;

    class LineWrapResult
    {
    public:
        string text;
        int line_count;
    };
    LineWrapResult doLineWrap(const string& text, float font_size, float width);
};

#endif//GUI2_ELEMENT_H
