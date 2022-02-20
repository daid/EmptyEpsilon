#include "gui2_listbox.h"
#include "theme.h"


GuiListbox::GuiListbox(GuiContainer* owner, string id, func_t func)
: GuiEntryList(owner, id, func), text_size(30), button_height(50), text_alignment(sp::Alignment::Center)
{
    scroll = new GuiScrollbar(this, id + "_SCROLL", 0, 0, 0, [this](int value) {});
    scroll->setPosition(0, 0, sp::Alignment::TopRight)->setSize(button_height, GuiSizeMax)->hide();
    scroll->setClickChange(button_height);

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
    scroll->setClickChange(button_height);
    scroll->setSize(button_height, GuiSizeMax);
    return this;
}

GuiListbox* GuiListbox::scrollTo(int index)
{
    scroll->setValue(index * button_height);
    return this;
}

void GuiListbox::onDraw(sp::RenderTarget& renderer)
{
    hover = false;
    const auto& back = back_style->get(getState());
    const auto& front = front_style->get(getState());
    const auto& back_selected = back_selected_style->get(getState());
    const auto& front_selected = front_selected_style->get(getState());

    scroll->setValueSize(rect.size.y);
    scroll->setRange(0, entries.size() * button_height);
    if ((int)entries.size() <= rect.size.y / button_height)
        scroll->hide();
    else
        scroll->show();
    
    sp::Rect button_rect{rect.position, {rect.size.x, button_height}};
    if (scroll->isVisible())
        button_rect.size.x -= scroll->getRect().size.x;
    button_rect.position.y -= scroll->getValue();
    int index = 0;
    for(auto& e : entries) {
        if (button_rect.position.y + button_rect.size.y >= rect.position.y && button_rect.position.y <= rect.position.y + rect.size.y) {
            auto* b = &back;
            auto* f = &front;
            if (index == selection_index) { b = &back_selected; f = &front_selected; }
            renderer.drawStretchedHVClipped(button_rect, rect, button_height*0.5f, b->texture, b->color);
            auto prepared = f->font->prepare(e.name, 32, text_size, button_rect.size, sp::Alignment::Center, sp::Font::FlagClip);
            for(auto& c : prepared.data)
                c.position.y -= rect.position.y - button_rect.position.y;
            renderer.drawText(rect, prepared, text_size, f->color, sp::Font::FlagClip);
        }
        button_rect.position.y += button_height;
        index += 1;
    }
}

bool GuiListbox::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    return true;
}

void GuiListbox::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    int offset = (position.y - rect.position.y + scroll->getValue()) / button_height;
    if (offset >= 0 && offset < int(entries.size())) {
        soundManager->playSound("sfx/button.wav");
        setSelectionIndex(offset);
        callback();
    }
}
