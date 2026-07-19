#include "gui2_resizabledialog.h"
#include "theme.h"

#include "gui2_label.h"
#include "gui2_togglebutton.h"

GuiResizableDialog::GuiResizableDialog(GuiContainer* owner, string id, string title)
: GuiPanel(owner, id)
{
    resize_corner_style = theme->getStyle("resizabledialog.corner");
    auto layout = new GuiElement(this, "RESIZABLE_LAYOUT");
    layout->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    layout->setAttribute("layout", "vertical");
    const float button_size = title_bar_height - 4.0f;

    auto title_bar_layout = new GuiElement(layout, "RESIZABLE_TITLE_BAR_LAYOUT");
    title_bar_layout->setMargins(25.0f, 0.0f, 10.0f, 0.0f)->setSize(GuiElement::GuiSizeMax, title_bar_height);
    title_bar_layout->setAttribute("layout", "horizontal");
    title_bar = new GuiAutoSizeLabel(title_bar_layout, "RESIZABLE_TITLE_BAR", title, glm::vec2(100.0f, title_bar_height), glm::vec2(500.0f, title_bar_height), 20.0f, 20.0f);
    title_bar->setClipped()->addBackground()->setAlignment(sp::Alignment::CenterLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    minimize_button = new GuiToggleButton(title_bar_layout, "RESIZABLE_MINIMIZE", "", [this](bool value)
    {
        minimize(value);
    });
    minimize_button->setTextSize(20.0f)->setIcon("gui/widget/IndicatorArrow.png", sp::Alignment::Center, 90.0f)->setSize(button_size, button_size)->setMargins(0.0f, 2.0f);

    close_button = new GuiButton(title_bar_layout, "RESIZABLE_CLOSE", "X", [this]()
    {
        onClose();
    });
    close_button->setTextSize(20.0f)->setSize(button_size, button_size)->setMargins(0.0f, 2.0f);

    contents = new GuiElement(layout, "RESIZABLE_CONTENTS");
    contents->setMargins(25.0f, 0.0f, 25.0f, 10.0f)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    contents->setAttribute("layout", "vertical");

    min_size = glm::vec2(200.0f, title_bar_height + resize_icon_size);
    minimized = false;
}

void GuiResizableDialog::minimize(bool minimize)
{
    minimize_button->setValue(minimize);
    minimize_button->setIcon("gui/widget/IndicatorArrow.png", sp::Alignment::Center, 90.0f * (minimize ? -1.0f : 1.0f));

    if (minimize != minimized)
    {
        if (minimize)
        {
            contents->hide();
            original_height = getSize().y;
            setSize(getSize().x, title_bar_height);
        }
        else
        {
            setSize(getSize().x, original_height);
            contents->show();
        }
    }
    minimized = minimize;
}

bool GuiResizableDialog::isMinimized() const
{
    return minimized;
}

void GuiResizableDialog::setTitle(string title)
{
    title_bar->setText(title);
}

void GuiResizableDialog::onDraw(sp::RenderTarget& renderer)
{
    GuiPanel::onDraw(renderer);

    contents->setSize(rect.size.x - resize_icon_size, rect.size.y - title_bar_height - resize_icon_size / 2.0f);
    window_size = renderer.getVirtualSize();

    if (rect.position.x < -50.0f)
        setPosition(-50.0f, getPositionOffset().y);
    if (rect.position.y < -(title_bar_height / 2.0f))
        setPosition(getPositionOffset().x, -(title_bar_height / 2.0f));
    if (rect.position.x > window_size.x - 50.0f)
        setPosition(window_size.x - 50.0f, getPositionOffset().y);
    if (rect.position.y > window_size.y - title_bar_height)
        setPosition(getPositionOffset().x, window_size.y - title_bar_height);

    if (minimized) return;

    const auto& corner = resize_corner_style->get(getState());
    renderer.drawSprite(corner.texture, rect.position + rect.size - glm::vec2(resize_icon_size * 0.5f, resize_icon_size * 0.5f), resize_icon_size, corner.color);
}

bool GuiResizableDialog::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    click_state = ClickState::None;

    if (title_bar->getRect().contains(position))
    {
        click_state = ClickState::Drag;
        drag_start_mouse = position;
        drag_start_dialog = rect.position;
    }

    if (!minimized && position.x >= rect.position.x + rect.size.x - resize_icon_size && position.y >= rect.position.y + rect.size.y - resize_icon_size)
        click_state = ClickState::Resize;

    click_offset = position - rect.position;
    return true;
}

void GuiResizableDialog::onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
    switch (click_state)
    {
        case ClickState::None:
            break;
        case ClickState::Drag:
        {
            glm::vec2 new_position = drag_start_dialog + (position - drag_start_mouse);
            setPosition(glm::vec2(std::clamp(new_position.x, -50.0f, window_size.x - 50.0f), std::clamp(new_position.y, 0.0f, window_size.y - title_bar_height)));
            break;
        }
        case ClickState::Resize:
        {
            glm::vec2 offset = position - rect.position;
            offset -= click_offset;
            setSize(getSize() + offset);
            click_offset += offset;
            if (getSize().x < min_size.x)
                setSize(min_size.x, getSize().y);
            if (getSize().y < min_size.y)
                setSize(getSize().x, min_size.y);
            break;
        }
    }
}

void GuiResizableDialog::onClose()
{
}
