#include "gui2_elementlistbox.h"
#include "soundManager.h"
#include "theme.h"


GuiElementListbox::GuiElementListbox(GuiContainer *owner, string id, int frame_margin, int element_height)
: GuiElement(owner, id), element_height(element_height), frame_margin(frame_margin), mouse_scroll_steps(25)
{
    scroll = new GuiScrollbar(this, id + "_SCROLL", 0, 0, 0, [this](int value) {});
    scroll->setPosition(0, 0, sp::Alignment::TopRight)->setSize(element_height, GuiSizeMax);
    scroll->setClickChange(element_height);
}

GuiElementListbox *GuiElementListbox::setElementHeight(int height)
{
    this->element_height = height;
    return this;
}

void GuiElementListbox::onDraw(sp::RenderTarget& renderer)
{
    if ((children.size() - 1) * element_height < this->rect.size.y*0.9f)
    {
        scroll->hide();
    }
    else
    {
        scroll->show();
        // Value size and allows to have a bigger scroll button
        scroll->setValueSize(getTotalHeight()/10);
        scroll->setRange(0, (children.size() - 1) * element_height - this->rect.size.y*0.9f);
    }

    float scroll_offset = ((float)scroll->getValue() - (float)scroll->getMin()) / ((float)scroll->getCorrectedMax() - (float)scroll->getMin());
    int i = 0;
    for (auto &e: children)
    {
        if(e == scroll)
            continue;

        e->setSize(GuiElement::GuiSizeMax, element_height);
        e->setMargins(this->frame_margin / 2);
        e->setPosition(0,round(i - scroll_offset * (getTotalHeight() - rect.size.y) / element_height) * element_height, sp::Alignment::TopLeft);
        if ((i + 1) * element_height - scroll_offset > this->rect.size.y || i * element_height - scroll_offset + element_height < 0)
        {
            e->hide();
        }
        else
        {
            e->show();
        }
        i++;
    }
}

float GuiElementListbox::getTotalHeight()
{
    return (children.size() - 1) * element_height;
}


GuiElementListbox* GuiElementListbox::destroyAndClear()
{
    for (auto& e : children)
    {
        if(e == scroll)
            continue;
        e->destroy();
    }
    scroll->setValue(0.0f);
    return this;
}

bool GuiElementListbox::onMouseWheelScroll(glm::vec2 position, float value)
{
    if (!scroll->isVisible())
        return true;
    float range = scroll->getCorrectedMax() - scroll->getMin();
    scroll->setValue((scroll->getValue() - value * range / mouse_scroll_steps) );
    return true;
}