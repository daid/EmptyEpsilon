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
        if (getSelectionIndex() <= 0)
            setSelectionIndex(entries.size() - 1);
        else
            setSelectionIndex(getSelectionIndex() - 1);
        callback();
    });
    left->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiSizeMatchHeight, GuiSizeMax);
    right = new GuiArrowButton(this, id + "_ARROW_RIGHT", 180.0f, [this]() {
        if (getSelectionIndex() >= static_cast<int>(entries.size()) - 1)
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
        renderer.drawText(rect, entries[selection_index].name, sp::Alignment::Center, text_size, nullptr, front.color);

    // Fit selector text between the arrow buttons.
    sp::Rect text_rect(rect.position.x + rect.size.y * 0.5f, rect.position.y, rect.size.x - rect.size.y, rect.size.y);
    if (selection_index >= 0 && selection_index < static_cast<int>(entries.size()))
        renderer.drawText(text_rect, entries[selection_index].name, sp::Alignment::Center, text_size, nullptr, front.color, sp::Font::FlagClip);

    if (!focus) popup->hide();

    setPopupWidth(popup_width);
    float popup_left_pos = std::min(rect.position.x, rect.position.x - (popup_width - rect.size.x));
    float popup_top_pos = rect.position.y;

    // Attempt to fit tall popups to the window height by reducing the button
    // height by up to half.
    float popup_height = entries.size() * popup_button_height;
    float popup_overflow = popup_height - renderer.getVirtualSize().y;
    if (popup_overflow > 0.0f)
    {
        popup_button_height = std::max(25.0f, popup_button_height - popup_overflow / entries.size());
        popup_height = entries.size() * popup_button_height;
    }

    if (selection_index >= 0) popup_top_pos -= selection_index * popup_button_height;
    popup_top_pos = std::max(0.0f, popup_top_pos);
    popup_top_pos = std::min(900.0f - popup_height, popup_top_pos);

    // Size and position the popup, factoring its override width if set.
    popup
        ->setPosition(popup_left_pos, popup_top_pos, sp::Alignment::TopLeft)
        ->setSize(popup_width, popup_height);
}

GuiSelector* GuiSelector::setTextSize(float size)
{
    text_size = size;
    return this;
}

GuiSelector* GuiSelector::setPopupWidth(float width)
{
    popup_width = std::max(rect.size.x, width);
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

        for (size_t n = 0; n < entries.size(); n++)
        {
            if (popup_buttons.size() <= n)
            {
                popup_buttons.push_back(new GuiToggleButton(popup, "", entries[n].name, [this, n](bool b)
                {
                    setSelectionIndex(n);
                    callback();
                }));
                popup_buttons[n]->setSize(GuiElement::GuiSizeMax, popup_button_height);
                popup_buttons[n]->setTextSize(std::min(text_size, popup_button_height * 0.6f));
            }
            else
            {
                popup_buttons[n]->setText(entries[n].name);
                popup_buttons[n]->show();
            }
            popup_buttons[n]->setValue(static_cast<int>(n) == selection_index);
            popup_buttons[n]->setPosition(0, n * popup_button_height, sp::Alignment::TopLeft);
        }
        for (size_t n = entries.size(); n < popup_buttons.size(); n++)
            popup_buttons[n]->hide();

        popup->show()->moveToFront();
    }
}

void GuiSelector::onFocusLost()
{
    // Explicitly hide the popup when the selector loses focus.
    popup->hide();
}
