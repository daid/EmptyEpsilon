#ifndef GUI2_TEXTENTRY_H
#define GUI2_TEXTENTRY_H

#include "gui2_element.h"

class GuiTextEntry : public GuiElement
{
public:
    typedef std::function<void(string text)> func_t;
    typedef std::function<bool(string text)> Validator;

protected:
    string text;
    float text_size;
    func_t func;
    func_t enter_func;
    sf::Clock blink_clock;
    bool valid;
    Validator validator_func;
public:
    GuiTextEntry(GuiContainer* owner, string id, string text);

    virtual void onDraw(sf::RenderTarget& window) override;
    virtual bool onMouseDown(sf::Vector2f position) override;
    virtual bool onKey(sf::Event::KeyEvent key, int unicode) override;
    
    string getText();
    bool isValid();
    GuiTextEntry* setText(string text);
    GuiTextEntry* setTextSize(float size);
    GuiTextEntry* callback(func_t func);
    GuiTextEntry* enterCallback(func_t func);
    GuiTextEntry* validator(Validator func);
};

#endif//GUI2_TEXTENTRY_H
