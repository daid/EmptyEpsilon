#ifndef GUI2_ELEMENT_H
#define GUI2_ELEMENT_H

#include <functional>
#include "stringImproved.h"
#include "colorConfig.h"
#include "hotkeyConfig.h"
#include "gui2_container.h"
#include "gui/layout/layout.h"
#include "graphics/font.h"
#include "graphics/renderTarget.h"
#include "io/textinput.h"


class Layout;
class GuiElement : public GuiContainer
{
private:
    bool destroyed;
protected:
    GuiContainer* owner;
    bool visible;
    bool enabled;
    bool hover;
    glm::vec2 hover_coordinates;
    bool focus;
    string id;
public:
    constexpr static float GuiSizeMatchHeight = -1.0;
    constexpr static float GuiSizeMatchWidth = -1.0;
    constexpr static float GuiSizeMax = -2.0;

    enum class State
    {
        Normal,
        Disabled,
        Hover,
        Focus,
        COUNT
    };

    GuiElement(GuiContainer* owner, const string& id);
    virtual ~GuiElement();

    virtual void onUpdate() {}
    virtual void onDraw(sp::RenderTarget& window) {}
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id);
    virtual void onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id);
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id);
    virtual void onTextInput(const string& text);
    virtual void onTextInput(sp::TextInputEvent e);
    virtual void onFocusGained() {}
    virtual void onFocusLost() {}

    virtual void setAttribute(const string& key, const string& value) override;
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

protected:
    glm::u8vec4 selectColor(const ColorSet& color_set) const;
    State getState() const;
};

#endif//GUI2_ELEMENT_H
