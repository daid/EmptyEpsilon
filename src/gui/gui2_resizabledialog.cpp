#include "gui2_resizabledialog.h"
#include "gui2_autolayout.h"

#include "gui2_label.h"
#include "gui2_togglebutton.h"

GuiResizableDialog::GuiResizableDialog(GuiContainer* owner, string id, string title)
: GuiPanel(owner, id)
{
    GuiAutoLayout* title_bar_layout = new GuiAutoLayout(this, "", GuiAutoLayout::LayoutHorizontalRightToLeft);
    title_bar_layout->setMargins(25, 0)->setSize(GuiElement::GuiSizeMax, title_bar_height);

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
    title_bar->addBackground()->setAlignment(ACenterLeft)->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    
    contents = new GuiElement(this, "");
    contents->setPosition(resize_icon_size / 2.0, title_bar_height, ATopLeft);
    
    min_size = sf::Vector2f(200, title_bar_height + resize_icon_size);
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

void GuiResizableDialog::onDraw(sf::RenderTarget& window)
{
    GuiPanel::onDraw(window);
    
    contents->setSize(rect.width - resize_icon_size, rect.height - title_bar_height - resize_icon_size / 2.0f);
    
    if (rect.left < -50)
        setPosition(-50, getPositionOffset().y);
    if (rect.top < -(title_bar_height / 2.0f))
        setPosition(getPositionOffset().x, -(title_bar_height / 2.0f));
    if (rect.left > window.getView().getSize().x - 50)
        setPosition(window.getView().getSize().x - 50, getPositionOffset().y);
    if (rect.top > window.getView().getSize().y - title_bar_height)
        setPosition(getPositionOffset().x, window.getView().getSize().y - title_bar_height);
    
    if (minimized)
        return;
    
    sf::Sprite image;
    textureManager.setTexture(image, "gui/ResizeDialogCorner");
    image.setPosition(rect.left + rect.width - resize_icon_size / 2.0, rect.top + rect.height - resize_icon_size / 2.0);
    float f = resize_icon_size / float(image.getTextureRect().height);
    image.setScale(f, f);
    image.setColor(sf::Color::White);
    window.draw(image);
}

bool GuiResizableDialog::onMouseDown(sf::Vector2f position)
{
    click_state = ClickState::None;
    if (title_bar->getRect().contains(position))
        click_state = ClickState::Drag;
    if (!minimized && position.x >= rect.left + rect.width - resize_icon_size && position.y >= rect.top + rect.height - resize_icon_size)
        click_state = ClickState::Resize;
    click_offset = position - sf::Vector2f(rect.left, rect.top);
    return true;
}

void GuiResizableDialog::onMouseDrag(sf::Vector2f position)
{
    sf::Vector2f offset = (position - sf::Vector2f(rect.left, rect.top));
    switch(click_state)
    {
    case ClickState::None:
        break;
    case ClickState::Drag:
        setPosition(getPositionOffset() + offset - click_offset);
        break;
    case ClickState::Resize:
        offset = offset - click_offset;
        setSize(getSize() + offset);
        click_offset += offset;
        if (getSize().x < min_size.x)
            setSize(min_size.x, getSize().y);
        if (getSize().y < min_size.y)
            setSize(getSize().x, min_size.y);
        break;
    }
}

void GuiResizableDialog::onClose()
{
}
