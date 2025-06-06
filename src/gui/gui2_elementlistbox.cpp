#include "gui2_elementlistbox.h"
#include "soundManager.h"
#include "theme.h"


GuiElementListbox::GuiElementListbox(GuiContainer *owner, string id, int frame_margin, int element_height, func_t func)
: GuiElement(owner, id), element_height(element_height), frame_margin(frame_margin)
{
    scroll = new GuiScrollbar(this, id + "_SCROLL", 0, 0, 0, [this](int value) {});
    scroll->setPosition(0, 0, sp::Alignment::TopRight)->setSize(element_height, GuiSizeMax);
    scroll->setClickChange(element_height);

    back_style = theme->getStyle("listbox.back");
    front_style = theme->getStyle("listbox.front");
    back_selected_style = theme->getStyle("listbox.selected.back");
    front_selected_style = theme->getStyle("listbox.selected.front");
}

GuiElementListbox *GuiElementListbox::addElement(GuiElement* element)
{
    elements.push_back(element);
    element->setPosition(0, elements.size() * element_height, sp::Alignment::TopLeft);
    element->setSize(GuiElement::GuiSizeMax, element_height);
    element->setMargins(this->frame_margin / 2);
    return this;
}

GuiElementListbox *GuiElementListbox::setElementHeight(int height)
{
    this->element_height = height;
    
    for (size_t i = 0; i < elements.size(); ++i)
    {
        elements[i]->setPosition(0, i * element_height, sp::Alignment::TopLeft);
        elements[i]->setSize(GuiElement::GuiSizeMax, element_height);
    }
    return this;
}

void GuiElementListbox::onDraw(sp::RenderTarget& renderer)
{
    if (elements.size() * element_height < this->rect.size.y*0.9f) {
        scroll->hide();
    }
    else{
        scroll->show();
        // Value size and allows to have a bigger scroll button
        scroll->setValueSize(rect.size.y/10);
        scroll->setRange(0, elements.size() * element_height - this->rect.size.y*0.9f);
    }

    int scroll_offset = scroll->getValue();
    for (size_t i = 0; i < elements.size(); ++i)
    {
        // Here we round the position to avoid having to deal with blocs being drawn halfway outside of the listbox
        elements[i]->setPosition(0, round(i  - scroll_offset/element_height) * element_height, sp::Alignment::TopLeft);
        if ((i + 1) * element_height - scroll_offset > this->rect.size.y|| i * element_height - scroll_offset + element_height < 0)
        {
            elements[i]->hide();
        }
        else
        {
            elements[i]->show();
        }

    }
}

float GuiElementListbox::getTotalHeight()
{
    return elements.size() * element_height;
}


GuiElementListbox* GuiElementListbox::destroyAndClear()
{
    for (auto& e : elements)
    {
        e->destroy();
    }
    elements.clear();
    return this;
}
