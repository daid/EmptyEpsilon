#include "gui2_listbox.h"
#include "soundManager.h"
#include "theme.h"

#include "gui2_scrollbar.h"
#include "gui2_textentry.h"

GuiListbox::GuiListbox(GuiContainer* owner, string id, func_t func)
: GuiEntryList(owner, id, func), text_size(30), button_height(50), text_alignment(sp::Alignment::Center), mouse_scroll_steps(25)
{
    scroll = new GuiScrollbar(this, id + "_SCROLL", 0, 0, 0, [this](int value) {});
    scroll
        ->setClickChange(button_height)
        ->setPosition(0.0f, 0.0f, sp::Alignment::TopRight)
        ->setSize(button_height, GuiSizeMax)
        ->hide();

    back_style = theme->getStyle("listbox.back");
    front_style = theme->getStyle("listbox.front");
    back_selected_style = theme->getStyle("listbox.selected.back");
    front_selected_style = theme->getStyle("listbox.selected.front");
}

GuiListbox* GuiListbox::setTextSize(float size)
{
    text_size = size;
    return this;
}

GuiListbox* GuiListbox::setButtonHeight(float height)
{
    button_height = height;
    scroll
        ->setClickChange(button_height)
        ->setSize(button_height, GuiElement::GuiSizeMax);
    return this;
}

GuiListbox* GuiListbox::scrollTo(int index)
{
    scroll->setValue(index * button_height);
    return this;
}

GuiListbox* GuiListbox::addSearch(search_func_t callback)
{
    if (search_entry) return this;

    // Set the search callback.
    search_callback = callback;
    if (!search_callback)
    {
        all_entries = {};
        for (int i = 0; i < entryCount(); i++)
            all_entries.emplace_back(getEntryName(i), getEntryValue(i), getEntryIcon(i));
    }

    // Build search entry field.
    search_entry = new GuiTextEntry(this, id + "_SEARCH", "");
    search_entry
        ->setTextSize(20.0f)
        ->setSize(GuiElement::GuiSizeMax, search_bar_height)
        ->setPosition(0.0f, 0.0f, sp::Alignment::TopLeft);
    search_entry->callback(
        [this](string value)
        {
            search_text = value.lower();
            if (search_callback) search_callback(search_text);
            else applyFilter();
        }
    );

    // Handle listbox scrollbar.
    scroll->setPosition(0.0f, search_bar_height, sp::Alignment::TopRight);
    return this;
}

GuiListbox* GuiListbox::clearSearch()
{
    if (!search_entry) return this;
    search_text = "";
    search_entry->setText("");
    if (!search_callback) applyFilter();
    return this;
}

int GuiListbox::addEntry(string name, string value)
{
    if (search_entry && !search_filtering && !search_callback)
    {
        all_entries.emplace_back(name, value, "");
        if (name.lower().find(search_text) >= 0)
            return GuiEntryList::addEntry(name, value);
        return -1;
    }
    return GuiEntryList::addEntry(name, value);
}

void GuiListbox::clear()
{
    if (search_entry && !search_filtering && !search_callback)
    {
        all_entries.clear();
        search_text = "";
        search_entry->setText("");
    }
    GuiEntryList::clear();
}

void GuiListbox::setEntryIcon(int index, string icon_name)
{
    if (search_entry && !search_filtering && !search_callback && index >= 0)
    {
        string val = getEntryValue(index);
        for (auto& e : all_entries)
        {
            if (e.value == val)
            {
                e.icon_name = icon_name;
                break;
            }
        }
    }
    GuiEntryList::setEntryIcon(index, icon_name);
}

void GuiListbox::setEntryName(int index, string name)
{
    if (search_entry && !search_filtering && !search_callback && index >= 0)
    {
        string val = getEntryValue(index);
        for (auto& e : all_entries)
        {
            if (e.value == val)
            {
                e.name = name;
                break;
            }
        }
    }
    GuiEntryList::setEntryName(index, name);
}

void GuiListbox::setEntryValue(int index, string value)
{
    if (search_entry && !search_filtering && !search_callback && index >= 0)
    {
        string old_val = getEntryValue(index);
        for (auto& e : all_entries)
        {
            if (e.value == old_val)
            {
                e.value = value;
                break;
            }
        }
    }
    GuiEntryList::setEntryValue(index, value);
}

void GuiListbox::setEntry(int index, string name, string value)
{
    if (search_entry && !search_filtering && !search_callback && index >= 0)
    {
        string old_val = getEntryValue(index);
        for (auto& e : all_entries)
        {
            if (e.value == old_val)
            {
                e.name = name;
                e.value = value;
                break;
            }
        }
    }
    GuiEntryList::setEntry(index, name, value);
}

void GuiListbox::removeEntry(int index)
{
    if (search_entry && !search_filtering && !search_callback && index >= 0)
    {
        string val = getEntryValue(index);
        for (auto it = all_entries.begin(); it != all_entries.end(); ++it)
        {
            if (it->value == val)
            {
                all_entries.erase(it);
                break;
            }
        }
    }
    GuiEntryList::removeEntry(index);
}

string GuiListbox::getSearchText() const
{
    return search_text;
}

void GuiListbox::applyFilter()
{
    search_filtering = true;
    // Capture previous selection.
    int prev_index = getSelectionIndex();
    string prev_value = getSelectionValue();

    // Clear the list and rebuild it with matches.
    GuiEntryList::clear();
    for (const auto& e : all_entries)
    {
        if (e.name.lower().find(search_text) >= 0)
        {
            int idx = GuiEntryList::addEntry(e.name, e.value);
            GuiEntryList::setEntryIcon(idx, e.icon_name);
        }
    }

    // Select the previous value, if present.
    int restored = indexByValue(prev_value);
    if (prev_index >= 0 && restored >= 0) setSelectionIndex(restored);
    search_filtering = false;
}

void GuiListbox::onDraw(sp::RenderTarget& renderer)
{
    hover = false;
    const auto& back = back_style->get(getState());
    const auto& back_hover = back_style->get(State::Hover);
    const auto& front = front_style->get(getState());
    const auto& back_selected = back_selected_style->get(getState());
    const auto& back_selected_hover = back_selected_style->get(State::Hover);
    const auto& front_selected = front_selected_style->get(getState());

    // Reserve the top of the rect for the search entry if present.
    float search_offset = search_entry ? search_bar_height : 0.0f;
    sp::Rect clip_rect = rect;
    clip_rect.position.y += search_offset;
    clip_rect.size.y -= search_offset;

    scroll
        ->setValueSize(clip_rect.size.y)
        ->setRange(0, entries.size() * button_height)
        // Determine whether to show the scrollbar based on the total height of
        // all items in the list.
        ->setVisible(static_cast<int>(entries.size()) > clip_rect.size.y / button_height);

    // Draw the button. If the scrollbar is visible, make room.
    sp::Rect button_rect{clip_rect.position, {clip_rect.size.x, button_height}};

    if (scroll->isVisible())
        button_rect.size.x -= scroll->getRect().size.x;

    button_rect.position.y -= scroll->getValue();

    // For each entry, draw a button.
    int index = 0;

    for(auto& e : entries) {
        // Draw the button only if it will be visible within the clip area.
        if (button_rect.position.y + button_rect.size.y >= clip_rect.position.y
            && button_rect.position.y <= clip_rect.position.y + clip_rect.size.y)
        {
            auto* b = button_rect.contains(hover_coordinates) ? &back_hover : &back;
            auto* f = &front;

            // If this is the selected button, change the back and foreground.
            if (index == selection_index)
            {
                b = button_rect.contains(hover_coordinates) ? &back_selected_hover : &back_selected;
                f = &front_selected;
            }

            // Draw the background texture.
            renderer.drawStretchedHVClipped(button_rect, clip_rect, button_height * 0.5f, b->texture, b->color);

            // Draw the icon, if one's defined.
            // 60% button height and aligned left.
            if (e.icon_name != "")
            {
                renderer.drawSpriteClipped(
                    e.icon_name,               // icon
                    glm::vec2(                 // center position
                        button_rect.position.x + button_rect.size.y * 0.8f,
                        button_rect.position.y + button_rect.size.y * 0.5f
                    ),
                    button_rect.size.y * 0.6f, // size
                    clip_rect,                 // clipping rectangle
                    f->color                   // color
                );
            }

            // Prepare the foreground text style.
            auto prepared = f->font->prepare(e.name, 32, text_size, f->color, button_rect.size, sp::Alignment::Center, sp::Font::FlagClip);
            for(auto& c : prepared.data)
                c.position.y -= clip_rect.position.y - button_rect.position.y;

            // Draw the text.
            renderer.drawText(clip_rect, prepared, sp::Font::FlagClip);
        }

        // Prepare to draw the next button below this one.
        button_rect.position.y += button_height;
        index += 1;
    }
}

bool GuiListbox::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    float search_offset = search_entry ? search_bar_height : 0.0f;
    if (position.y < rect.position.y + search_offset) return false;
    int offset = (position.y - rect.position.y - search_offset + scroll->getValue()) / button_height;
    return offset >= 0 && offset < int(entries.size());
}

void GuiListbox::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    float search_offset = search_entry ? search_bar_height : 0.0f;
    int offset = (position.y - rect.position.y - search_offset + scroll->getValue()) / button_height;
    if (offset >= 0 && offset < static_cast<int>(entries.size()))
    {
        soundManager->playSound("sfx/button.wav");
        string selected_value = getEntryValue(offset);
        // Selecting an item clears the search so the full list is visible
        // afterwards, consistent with treating the search as a navigation aid
        // rather than a persistent filter.
        if (search_entry && !search_callback)
        {
            search_text = "";
            search_entry->setText("");
            applyFilter();
            offset = indexByValue(selected_value);
        }
        setSelectionIndex(offset);
        callback();
    }
}

bool GuiListbox::onMouseWheelScroll(glm::vec2 position, float value)
{
    float range = scroll->getCorrectedMax() - scroll->getMin();
    scroll->setValue((scroll->getValue() - value * range / mouse_scroll_steps) );
    return true;
}
