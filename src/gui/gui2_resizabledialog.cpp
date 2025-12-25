#include "gui2_resizabledialog.h"
#include "theme.h"

#include "gui2_label.h"
#include "gui2_togglebutton.h"

GuiResizableDialog::GuiResizableDialog(GuiContainer* owner, string id, string title)
: GuiPanel(owner, id)
{
    resize_corner_style = theme->getStyle("resizabledialog.corner");

    auto title_bar_layout = new GuiElement(this, "");
    title_bar_layout->setMargins(25, 0)->setSize(GuiElement::GuiSizeMax, title_bar_height)->setAttribute("layout", "horizontalright");

    close_button = new GuiButton(title_bar_layout, "", "x", [this](){
        onClose();
    });
    close_button->setSize(50, GuiElement::GuiSizeMax);

    minimize_button = new GuiToggleButton(title_bar_layout, "", "_", [this](bool value)
    {
        minimize(value);
    });
    minimize_button->setSize(50, GuiElement::GuiSizeMax);

    title_bar = new GuiLabel(title_bar_layout, "", title, 20);
    title_bar->addBackground()->setAlignment(sp::Alignment::CenterLeft)->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    contents = new GuiElement(this, "");
    contents->setPosition(resize_icon_size / 2.0f, title_bar_height, sp::Alignment::TopLeft);

    min_size = glm::vec2(200, title_bar_height + resize_icon_size);
    minimized = false;
}

void GuiResizableDialog::minimize(bool minimize)
{
    minimize_button->setValue(minimize);
    if (minimize != minimized)
    {
        if (minimize)
        {
            contents->hide();
            original_height = getSize().y;
            setSize(getSize().x, title_bar_height);
        }else{
            contents->show();
            setSize(getSize().x, original_height);
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
