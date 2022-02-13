#include "gui2_textentry.h"
#include "theme.h"
#include "clipboard.h"


GuiTextEntry::GuiTextEntry(GuiContainer* owner, string id, string text)
: GuiElement(owner, id), text(text), text_size(30), func(nullptr)
{
    blink_timer.repeat(blink_rate);
    front_style = theme->getStyle("textentry.front");
    back_style = theme->getStyle("textentry.back");
}

GuiTextEntry::~GuiTextEntry()
{
    if (focus)
        SDL_StopTextInput();
}

void GuiTextEntry::onDraw(sp::RenderTarget& renderer)
{
    const auto& back = back_style->get(getState());
    const auto& front = front_style->get(getState());

    renderer.drawStretchedHV(rect, back.size, back.texture, back.color);
    if (blink_timer.isExpired())
        typing_indicator = !typing_indicator;

    sp::Rect text_rect(rect.position.x + 16, rect.position.y, rect.size.x - 32, rect.size.y);
    auto prepared = front.font->prepare(text, 32, text_size, text_rect.size, multiline ? sp::Alignment::TopLeft : sp::Alignment::CenterLeft, sp::Font::FlagClip);
    for(auto& d : prepared.data)
        d.position += render_offset;

    if (focus)
    {
        float start_x = -1;
        int selection_min = std::min(selection_start, selection_end);
        int selection_max = std::max(selection_start, selection_end);
        for(auto d : prepared.data)
        {
            if (d.string_offset == selection_end)
            {
                if (d.position.x > text_rect.size.x)
                    render_offset.x -= d.position.x - text_rect.size.x;
                if (d.position.x < 0.0f)
                    render_offset.x -= d.position.x;
            }
            if (d.string_offset == selection_min)
            {
                start_x = d.position.x;
            }
            if ((d.string_offset == selection_max) || (d.char_code == 0 && start_x > -1.0f))
            {
                float end_x = d.position.x;
                float start_y = d.position.y - text_size;
                float end_y = start_y + text_size * 1.1f;
                if (end_y < 0.0f)
                    continue;
                if (start_y > rect.size.y)
                    continue;
                start_y = std::max(0.0f, start_y);
                end_x = std::min(rect.size.x, end_x);
                end_y = std::min(rect.size.y, end_y);
                if (end_x != start_x)
                {
                    renderer.fillRect(
                        sp::Rect(rect.position + glm::vec2{start_x + 16, start_y},
                        glm::vec2{end_x - start_x, end_y - start_y}),
                        {255, 255, 255, 128});
                }
                if (d.string_offset == selection_max)
                    start_x = -1.0f;
                else
                    start_x = 0.0f;
            }
            if (d.string_offset == selection_end && typing_indicator)
            {
                float start_y = d.position.y - text_size;
                float end_y = start_y + text_size * 1.1f;
                if (end_y < 0.0f)
                    continue;
                if (start_y > rect.size.y)
                    continue;
                start_y = std::max(0.0f, start_y);
                end_y = std::min(rect.size.y, end_y);

                renderer.fillRect(
                    sp::Rect(rect.position + glm::vec2{d.position.x + 16 - text_size * 0.05f, start_y},
                    glm::vec2{text_size * 0.1f, end_y - start_y}),
                    {255, 255, 255, 255});
            }
        }
    }
    renderer.drawText(text_rect, prepared, text_size, glm::u8vec4{255,255,255,255}, sp::Font::FlagClip);
}

bool GuiTextEntry::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    selection_start = getTextOffsetForPosition(position);
    selection_end = selection_start;
    return true;
}

void GuiTextEntry::onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
    selection_end = getTextOffsetForPosition(position);
}

void GuiTextEntry::onTextInput(const string& text)
{
    if (readonly)
        return;
    this->text = this->text.substr(0, std::min(selection_start, selection_end)) + text + this->text.substr(std::max(selection_start, selection_end));
    selection_end = selection_start = std::min(selection_start, selection_end) + text.length();
    runChangeCallback();
}

void GuiTextEntry::onTextInput(sp::TextInputEvent e)
{
    switch(e)
    {
    case sp::TextInputEvent::Left:
    case sp::TextInputEvent::LeftWithSelection:
        if (selection_end > 0)
            selection_end -= 1;
        if (e != sp::TextInputEvent::LeftWithSelection)
            selection_start = selection_end;
        break;
    case sp::TextInputEvent::Right:
    case sp::TextInputEvent::RightWithSelection:
        if (selection_end < int(text.length()))
            selection_end += 1;
        if (e != sp::TextInputEvent::RightWithSelection)
            selection_start = selection_end;
        break;
    case sp::TextInputEvent::WordLeft:
    case sp::TextInputEvent::WordLeftWithSelection:
        if (selection_end > 0)
            selection_end -= 1;
        while (selection_end > 0 && !isspace(text[selection_end - 1]))
            selection_end -= 1;
        if (e != sp::TextInputEvent::WordLeftWithSelection)
            selection_start = selection_end;
        break;
    case sp::TextInputEvent::WordRight:
    case sp::TextInputEvent::WordRightWithSelection:
        while (selection_end < int(text.length()) && !isspace(text[selection_end]))
            selection_end += 1;
        if (selection_end < int(text.length()))
            selection_end += 1;
        if (e != sp::TextInputEvent::WordRightWithSelection)
            selection_start = selection_end;
        break;
    case sp::TextInputEvent::Up:
    case sp::TextInputEvent::UpWithSelection:{
        int end_of_line = text.substr(0, selection_end).rfind("\n");
        if (end_of_line < 0)
            return;
        int start_of_line = text.substr(0, end_of_line).rfind("\n") + 1;
        int offset = selection_end - end_of_line - 1;
        int line_length = end_of_line - start_of_line;
        selection_end = start_of_line + std::min(line_length, offset);
        if (e != sp::TextInputEvent::UpWithSelection)
            selection_start = selection_end;
        }break;
    case sp::TextInputEvent::Down:
    case sp::TextInputEvent::DownWithSelection:{
        int start_of_current_line = text.substr(0, selection_end).rfind("\n") + 1;
        int end_of_current_line = text.find("\n", selection_end);
        if (end_of_current_line < 0)
            return;
        int end_of_end_line = text.find("\n", end_of_current_line + 1);
        if (end_of_end_line == -1)
            end_of_end_line = text.length();
        int offset = selection_end - start_of_current_line;
        selection_end = end_of_current_line + 1 + std::min(offset, end_of_end_line - (end_of_current_line + 1));
        if (e != sp::TextInputEvent::DownWithSelection)
            selection_start = selection_end;
        }break;
    case sp::TextInputEvent::LineStart:
    case sp::TextInputEvent::LineStartWithSelection:
        selection_end = text.substr(0, selection_end).rfind("\n") + 1;
        if (e != sp::TextInputEvent::LineStartWithSelection)
            selection_start = selection_end;
        break;
    case sp::TextInputEvent::LineEnd:
    case sp::TextInputEvent::LineEndWithSelection:
        selection_end = text.find("\n", selection_start);
        if (selection_end == -1)
            selection_end = text.length();
        if (e != sp::TextInputEvent::LineEndWithSelection)
            selection_start = selection_end;
        break;
    case sp::TextInputEvent::TextStart:
    case sp::TextInputEvent::TextStartWithSelection:
        selection_end = 0;
        if (e != sp::TextInputEvent::TextStartWithSelection)
            selection_start = selection_end;
        break;
    case sp::TextInputEvent::TextEnd:
    case sp::TextInputEvent::TextEndWithSelection:
        selection_end = text.length();
        if (e != sp::TextInputEvent::TextEndWithSelection)
            selection_start = selection_end;
        break;
    case sp::TextInputEvent::SelectAll:
        selection_end = 0;
        selection_start = text.length();
        break;
    case sp::TextInputEvent::Delete:
        if (readonly)
            return;
        if (selection_start != selection_end)
            text = text.substr(0, std::min(selection_start, selection_end)) + text.substr(std::max(selection_start, selection_end));
        else
            text = text.substr(0, selection_start) + text.substr(selection_start + 1);
        selection_start = selection_end = std::min(selection_start, selection_end);
        runChangeCallback();
        break;
    case sp::TextInputEvent::Backspace:
        if (readonly)
            return;
        if (selection_start != selection_end)
        {
            onTextInput(sp::TextInputEvent::Delete);
            return;
        }
        else if (selection_start > 0)
        {
            text = text.substr(0, selection_start - 1) + text.substr(selection_start);
            selection_start -= 1;
            selection_end = selection_start;
            runChangeCallback();
        }
        break;
    case sp::TextInputEvent::Indent:
        if (readonly)
            return;
        if (selection_start == selection_end)
        {
            int start_of_line = text.substr(0, selection_end).rfind("\n") + 1;
            int offset = selection_end - start_of_line;
            int add = 4 - (offset % 4);
            onTextInput(string(" ") * add);
        }
        else
        {
            int start_of_line = text.substr(0, std::min(selection_start, selection_end)).rfind("\n") + 1;
            auto data = text.substr(start_of_line, std::max(selection_start, selection_end));
            data = "    " + data.replace("\n", "\n    ");
            int extra_length = data.length() - (std::max(selection_start, selection_end) - start_of_line) - 4;
            text = text.substr(0, start_of_line) + data + text.substr(std::max(selection_start, selection_end));

            if (start_of_line != selection_start)
                selection_start += 4;
            if (start_of_line != selection_end)
                selection_end += 4;
            if (selection_start > selection_end)
                selection_start += extra_length;
            else
                selection_end += extra_length;
            runChangeCallback();
        }
        break;
    case sp::TextInputEvent::Unindent:
        if (readonly)
            return;
        if (selection_start == selection_end)
        {
        }
        else
        {
            int start_of_line = text.substr(0, std::min(selection_start, selection_end)).rfind("\n") + 1;
            auto data = text.substr(start_of_line, std::max(selection_start, selection_end));
            for(int n=0; n<4; n++)
            {
                if (data.startswith(" "))
                    data = data.substr(1);
                data = data.replace("\n ", "\n");
            }
            int removed_length = (std::max(selection_start, selection_end) - start_of_line) - data.length();
            text = text.substr(0, start_of_line) + data + text.substr(std::max(selection_start, selection_end));

            if (selection_start > selection_end)
                selection_start -= removed_length;
            else
                selection_end -= removed_length;
            runChangeCallback();
        }
        break;
    case sp::TextInputEvent::Return:
        if (readonly)
            return;
        if (multiline)
        {
            onTextInput("\n");
        }
        else if (enter_func)
        {
            auto f = enter_func;
            f(text);
        }
        break;
    case sp::TextInputEvent::Copy:
        Clipboard::setClipboard(text.substr(std::min(selection_start, selection_end), std::max(selection_start, selection_end)));
        break;
    case sp::TextInputEvent::Paste:
        if (readonly)
            return;
        onTextInput(Clipboard::readClipboard());
        break;
    case sp::TextInputEvent::Cut:
        Clipboard::setClipboard(text.substr(std::min(selection_start, selection_end), std::max(selection_start, selection_end)));
        if (readonly)
            return;
        if (selection_start != selection_end)
            onTextInput(sp::TextInputEvent::Delete);
        break;
    }
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

GuiTextEntry* GuiTextEntry::setMultiline(bool enabled)
{
    multiline = enabled;
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

int GuiTextEntry::getTextOffsetForPosition(glm::vec2 position)
{
    position -= rect.position;
    position.x -= 16.0f;
    int result = text.size();
    //if (vertical_scroll)
    //    position.y -= vertical_scroll->getValue();

    auto pfs = main_font->prepare(text, 32, text_size, rect.size - glm::vec2(32, 0), multiline ? sp::Alignment::TopLeft : sp::Alignment::CenterLeft);
    unsigned int n;
    for(n=0; n<pfs.data.size(); n++)
    {
        auto& d = pfs.data[n];
        if (d.position.y > position.y)
            break;
    }
    float line_y = pfs.data[n].position.y;
    for(; n<pfs.data.size(); n++)
    {
        auto& d = pfs.data[n];
        if (d.position.x > position.x)
            break;
        if (d.position.y > line_y)
            break;
        result = d.string_offset;
    }
    return result;
}


void GuiTextEntry::runChangeCallback()
{
    if (func)
    {
        func_t f = func;
        f(text);
    }
}