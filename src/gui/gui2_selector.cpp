#include "gui2_arrowbutton.h"
#include "gui2_selector.h"
#include "gui2_label.h"
#include "gui2_panel.h"
#include "soundManager.h"

GuiSelector::GuiSelector(GuiContainer* owner, string id, func_t func)
: GuiEntryList(owner, id, func), text_size(30)
{
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

    glm::u8vec4 color = glm::u8vec4{255,255,255,255};
    if (entries.size() < 1 || !enabled)
        color = glm::u8vec4(128, 128, 128, 255);

    renderer.drawStretched(rect, "gui/widget/SelectorBackground.png", color);
    if (selection_index >= 0 && selection_index < (int)entries.size())
        renderer.drawText(rect, entries[selection_index].name, sp::Alignment::Center, text_size, main_font, color);

    if (!focus)
        popup->hide();
    float top = rect.position.y;
    float height = entries.size() * 50;
    if (selection_index >= 0)
        top -= selection_index * 50;
    top = std::max(0.0f, top);
    top = std::min(900.0f - height, top);
    popup->setPosition(rect.position.x, top, sp::Alignment::TopLeft)->setSize(rect.size.x, height);
}

GuiSelector* GuiSelector::setTextSize(float size)
{
    text_size = size;
    return this;
}

bool GuiSelector::onMouseDown(glm::vec2 position)
{
    return true;
}

void GuiSelector::onMouseUp(glm::vec2 position)
{
    if (rect.contains(position))
    {
        soundManager->playSound("sfx/button.wav");
        for(unsigned int n=0; n<entries.size(); n++)
        {
            if (popup_buttons.size() <= n)
            {
                popup_buttons.push_back(new GuiButton(popup, "", entries[n].name, [this, n]()
                {
                    setSelectionIndex(n);
                    callback();
                }));
                popup_buttons[n]->setSize(GuiElement::GuiSizeMax, 50);
                popup_buttons[n]->setTextSize(text_size);
            }else{
                popup_buttons[n]->setText(entries[n].name);
            }
            popup_buttons[n]->setActive(int(n) == selection_index);
            popup_buttons[n]->setPosition(0, n * 50, sp::Alignment::TopLeft);
        }
        for(unsigned int n=entries.size(); n<popup_buttons.size(); n++)
        {
            popup_buttons[n]->hide();
        }
        popup->show()->moveToFront();
    }
}
