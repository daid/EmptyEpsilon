#ifndef GUI2_TEXTENTRY_H
#define GUI2_TEXTENTRY_H

#include "gui2_element.h"

class GuiTextEntry : public GuiElement
{
public:
    typedef std::function<void(string text)> func_t;

protected:
    string text;
    float text_size;
    func_t func;
    func_t enter_func;
    const float blink_rate = 0.530;
    sp::SystemTimer blink_timer;
    bool typing_indicator{false};
public:
    GuiTextEntry(GuiContainer* owner, string id, string text);

    virtual void onDraw(sp::RenderTarget& window) override;
    virtual bool onMouseDown(glm::vec2 position) override;
    virtual bool onKey(const SDL_KeyboardEvent& key, int unicode) override;
    virtual void onFocusGained() override;
    virtual void onFocusLost() override;

    string getText() const;
    GuiTextEntry* setText(string text);
    GuiTextEntry* setTextSize(float size);
    GuiTextEntry* callback(func_t func);
    GuiTextEntry* enterCallback(func_t func);
};

#endif//GUI2_TEXTENTRY_H
