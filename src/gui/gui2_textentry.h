#ifndef GUI2_TEXTENTRY_H
#define GUI2_TEXTENTRY_H

#include "gui2_element.h"
#include "timer.h"


class GuiThemeStyle;
class GuiTextEntry : public GuiElement
{
public:
    typedef std::function<void(string text)> func_t;

protected:
    string text;
    int selection_start = 0;
    int selection_end = 0;

    float text_size;
    bool multiline = false;
    bool select_on_focus = false;
    bool readonly = false;
    bool hide_password = false;
    const GuiThemeStyle* front_style;
    const GuiThemeStyle* back_style;
    func_t func;
    func_t enter_func;
    func_t up_func;
    func_t down_func;

    const float blink_rate = 0.530f;
    sp::SystemTimer blink_timer;
    bool typing_indicator{false};

    glm::vec2 render_offset{0, 0};
public:
    GuiTextEntry(GuiContainer* owner, string id, string text);
    virtual ~GuiTextEntry();

    virtual void onDraw(sp::RenderTarget& renderer) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onTextInput(const string& text) override;
    virtual void onTextInput(sp::TextInputEvent e) override;
    virtual void onFocusGained() override;
    virtual void onFocusLost() override;
    virtual void setAttribute(const string& key, const string& value) override;

    string getText() const;
    GuiTextEntry* setText(string text);
    GuiTextEntry* setTextSize(float size);
    GuiTextEntry* setMultiline(bool enabled=true);
    GuiTextEntry* setSelectOnFocus(bool enabled=true);
    GuiTextEntry* setHidePassword(bool enabled=true);
    GuiTextEntry* callback(func_t func);
    GuiTextEntry* enterCallback(func_t func);
    GuiTextEntry* upCallback(func_t func);
    GuiTextEntry* downCallback(func_t func);

    void setCursorPosition(int offset);
protected:
    int getTextOffsetForPosition(glm::vec2 position);
    void runChangeCallback();
};

#endif//GUI2_TEXTENTRY_H