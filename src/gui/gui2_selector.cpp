#include "gui2_selector.h"
#include "soundManager.h"
#include "theme.h"

#include "gui2_arrowbutton.h"
#include "gui2_label.h"
#include "gui2_panel.h"
#include "gui2_scrollcontainer.h"
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
    popup_scroll = new GuiScrollContainer(popup, id + "_POPUP_SCROLL");
    popup_scroll
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setAttribute("layout", "vertical");
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

    // rect.position is in layout space; the popup lives at the canvas level
    // (no scroll translation), so convert to screen coordinates first.
    glm::vec2 screen_pos = rect.position + renderer.getTranslation();
    const float max_popup_height = button_height * 10.0f;
    float popup_height = std::min(static_cast<float>(entries.size()) * button_height, max_popup_height);
    float top = screen_pos.y;
    top = std::clamp(top, 0.0f, 900.0f - popup_height);
    popup
        ->setPosition(screen_pos.x, top, sp::Alignment::TopLeft)
        ->setSize(rect.size.x, popup_height);
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
        if (popup->isVisible())
        {
            popup->hide();
            return;
        }

        soundManager->playSound("sfx/button.wav");
        for (unsigned int n = 0; n < entries.size(); n++)
        {
            if (popup_buttons.size() <= n)
            {
                popup_buttons.push_back(new GuiToggleButton(popup_scroll, "", entries[n].name, [this, n](bool b)
                {
                    setSelectionIndex(n);
                    callback();
                    popup->hide();
                }));

                popup_buttons[n]
                    ->setTextSize(text_size)
                    ->setSize(GuiElement::GuiSizeMax, button_height);
            }
            else
            {
                popup_buttons[n]
                    ->setText(entries[n].name)
                    ->show();
            }
            popup_buttons[n]->setValue(static_cast<int>(n) == selection_index);
        }

        // Hide each popup button.
        for (auto n = entries.size(); n < popup_buttons.size(); n++)
            popup_buttons[n]->hide();

        // Scroll so the selected item is visible.
        if (selection_index >= 0)
            popup_scroll->scrollToOffset(selection_index * button_height);

        popup
            ->show()
            ->moveToFront();
    }
}

void GuiSelector::onFocusLost()
{
    // Hide the popup on a focus change outside of the popup rect.
    if (!popup->getRect().contains(hover_coordinates))
        popup->hide();
}
