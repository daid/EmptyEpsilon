#include "gui2_arrowbutton.h"
#include "soundManager.h"
#include "theme.h"

#include "gui2_label.h"
#include "gui2_panel.h"
#include "gui2_selector.h"
#include "gui2_togglebutton.h"

GuiSelector::GuiSelector(GuiContainer* owner, string id, func_t func)
: GuiEntryList(owner, id, func)
{
    back_style = theme->getStyle("selector.back");
    front_style = theme->getStyle("selector.front");
    left = new GuiArrowButton(this, id + "_ARROW_LEFT", 0, [this]() {
        soundManager->playSound("sfx/button.wav");
        if (getSelectionIndex() <= 0)
            setSelectionIndex(entries.size() - 1);
        else
            setSelectionIndex(getSelectionIndex() - 1);
        callback();
    });
    left->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiSizeMatchHeight, GuiSizeMax);
    right = new GuiArrowButton(this, id + "_ARROW_RIGHT", 180, [this]() {
        soundManager->playSound("sfx/button.wav");
        if (getSelectionIndex() >= (int)entries.size() - 1)
            setSelectionIndex(0);
        else
            setSelectionIndex(getSelectionIndex() + 1);
        callback();
    });
    right->setPosition(0, 0, sp::Alignment::TopRight)->setSize(GuiSizeMatchHeight, GuiSizeMax);

    popup = new GuiPanel(getTopLevelContainer(), "");
    popup->hide();
}

void GuiSelector::onDraw(sp::RenderTarget& renderer)
{
    left->setEnable(enabled);
    right->setEnable(enabled);

    const auto& back = back_style->get(getState());
    const auto& front = front_style->get(getState());

    renderer.drawStretched(rect, back.texture, back.color);
    if (selection_index >= 0 && selection_index < (int)entries.size())
        renderer.drawText(rect, entries[selection_index].name, sp::Alignment::Center, text_size, front.font, front.color);

    if (!focus)
        popup->hide();
    // Shrink item height so the whole list fits the virtual screen height.
    float virtual_h = renderer.getVirtualSize().y;
    float item_h = 50.0f;
    if (!entries.empty())
        item_h = std::min(item_h, virtual_h / entries.size());
    float top = rect.position.y;
    float height = entries.size() * item_h;
    if (selection_index >= 0)
        top -= selection_index * item_h;
    top = std::min(virtual_h - height, top);
    top = std::max(0.0f, top);
    popup->setPosition(rect.position.x, top, sp::Alignment::TopLeft)->setSize(rect.size.x, height);
    for(unsigned int n=0; n<popup_buttons.size(); n++)
    {
        popup_buttons[n]->setSize(GuiElement::GuiSizeMax, item_h);
        popup_buttons[n]->setPosition(0, n * item_h, sp::Alignment::TopLeft);
    }
}

GuiSelector* GuiSelector::setTextSize(float size)
{
    text_size = size;
    return this;
}

bool GuiSelector::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    return true;
}

void GuiSelector::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (rect.contains(position))
    {
        soundManager->playSound("sfx/button.wav");
        for(unsigned int n=0; n<entries.size(); n++)
        {
            if (popup_buttons.size() <= n)
            {
                popup_buttons.push_back(new GuiToggleButton(popup, "", entries[n].name, [this, n](bool b)
                {
                    setSelectionIndex(n);
                    callback();
                }));
                popup_buttons[n]->setTextSize(text_size);
            }else{
                popup_buttons[n]->setText(entries[n].name);
                popup_buttons[n]->show();
            }
            popup_buttons[n]->setValue(int(n) == selection_index);
        }
        for(unsigned int n=entries.size(); n<popup_buttons.size(); n++)
        {
            popup_buttons[n]->hide();
        }
        popup->show()->moveToFront();
    }
}

void GuiSelector::onFocusLost()
{
    // Explicitly hide the popup when the selector loses focus.
    popup->hide();
}
