#include "gui2_textentry.h"
#include "input.h"

GuiTextEntry::GuiTextEntry(GuiContainer* owner, string id, string text)
: GuiElement(owner, id), text(text), text_size(30), func(nullptr)
{
    blink_timer.repeat(blink_rate);
}

void GuiTextEntry::onDraw(sp::RenderTarget& renderer)
{
    if (focus)
        renderer.drawStretched(rect, "gui/widget/TextEntryBackground.focused.png", selectColor(colorConfig.text_entry.background));
    else
        renderer.drawStretched(rect, "gui/widget/TextEntryBackground.png", selectColor(colorConfig.text_entry.background));
    if (blink_timer.isExpired())
        typing_indicator = !typing_indicator;
    renderer.drawText(sp::Rect(rect.position.x + 16, rect.position.y, rect.size.x, rect.size.y), text + (typing_indicator && focus ? "_" : ""), sp::Alignment::CenterLeft, text_size, main_font, selectColor(colorConfig.text_entry.forground));
}

bool GuiTextEntry::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, int id)
{
    return true;
}

bool GuiTextEntry::onKey(const SDL_KeyboardEvent& key, int unicode)
{
    if (key.keysym.sym == SDLK_BACKSPACE && text.length() > 0)
    {
        text = text.substr(0, -1);
        if (func)
        {
            func_t f = func;
            f(text);
        }
        return true;
    }
    if (key.keysym.sym == SDLK_RETURN)
    {
        if (enter_func)
        {
            func_t f = enter_func;
            f(text);
        }
        return true;
    }
    if (key.keysym.sym == SDLK_v && (key.keysym.mod & KMOD_CTRL))
    {
        for(int unicode : Clipboard::readClipboard())
        {
            if (unicode > 31 && unicode < 128)
                text += string(char(unicode));
        }
        if (func)
        {
            func_t f = func;
            f(text);
        }
        return true;
    }
    if (unicode > 31 && unicode < 128)
    {
        text += string(char(unicode));
        if (func)
        {
            func_t f = func;
            f(text);
        }
        return true;
    }
    return true;
}

void GuiTextEntry::onFocusGained()
{
    typing_indicator = true;
    blink_timer.repeat(blink_rate);
    SDL_StartTextInput();
}

void GuiTextEntry::onFocusLost()
{
    SDL_StopTextInput();
}

string GuiTextEntry::getText() const
{
    return text;
}

GuiTextEntry* GuiTextEntry::setText(string text)
{
    this->text = text;
    return this;
}

GuiTextEntry* GuiTextEntry::setTextSize(float size)
{
    this->text_size = size;
    return this;
}

GuiTextEntry* GuiTextEntry::callback(func_t func)
{
    this->func = func;
    return this;
}

GuiTextEntry* GuiTextEntry::enterCallback(func_t func)
{
    this->enter_func = func;
    return this;
}
