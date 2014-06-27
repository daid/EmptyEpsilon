#include "gui.h"
#include "main.h"

//TODO: This is pretty nasty. Needs to be fixed!
sf::RenderTarget* GUI::renderTarget;
sf::Vector2f GUI::mousePosition;
int GUI::mouse_click;
int GUI::mouse_down;

GUI::GUI()
: Renderable(hud_layer)
{
    init = true;
}

void GUI::render(sf::RenderTarget& window)
{
    P<InputHandler> inputHandler = engine->getObject("inputHandler");
    mousePosition = inputHandler->getMousePos();
    mouse_click = 0;
    mouse_down = 0;
    if (!init)//Do not send mouse clicks the first render, as we can just be created because of a mouseclick.
    {
        if (inputHandler->mouseIsPressed(sf::Mouse::Left))
            mouse_click = 1;
        else if (inputHandler->mouseIsPressed(sf::Mouse::Right))
            mouse_click = 2;
        if (inputHandler->mouseIsDown(sf::Mouse::Left))
            mouse_down = 1;
        else if (inputHandler->mouseIsDown(sf::Mouse::Right))
            mouse_down = 2;
        renderTarget = &window;
        onGui();
        renderTarget = NULL;
    }

    init = false;
}

void GUI::text(sf::FloatRect rect, string text, EAlign align, float fontSize)
{
    sf::Text textElement(text, main_font, fontSize);
    switch(align)
    {
    case AlignLeft:
        textElement.setPosition(rect.left - textElement.getLocalBounds().left, rect.top + rect.height / 2.0 - textElement.getLocalBounds().height / 2.0 - textElement.getLocalBounds().top);
        break;
    case AlignRight:
        textElement.setPosition(rect.left + rect.width - textElement.getLocalBounds().width - textElement.getLocalBounds().left, rect.top + rect.height / 2.0 - textElement.getLocalBounds().height / 2.0 - textElement.getLocalBounds().top);
        break;
    case AlignCenter:
        textElement.setPosition(rect.left + rect.width / 2.0 - textElement.getLocalBounds().width / 2.0 - textElement.getLocalBounds().left, rect.top + rect.height / 2.0 - textElement.getLocalBounds().height / 2.0 - textElement.getLocalBounds().top);
        break;
    }
    renderTarget->draw(textElement);
}

bool GUI::button(sf::FloatRect rect, string text_value, float font_size)
{
    sf::Sprite sprite;
    texture_manager.setTexture(sprite, "button_background");
    if (rect.contains(mousePosition))
        sprite.setColor(sf::Color(255,255,255, 128));
    else
        sprite.setColor(sf::Color::White);
    sprite.setOrigin(0, 0);
    sprite.setPosition(rect.left, rect.top);
    sprite.setScale(rect.width / sprite.getTextureRect().width, rect.height / sprite.getTextureRect().height);
    renderTarget->draw(sprite);

    text(rect, text_value, AlignCenter, font_size);
    if (mouse_click && rect.contains(mousePosition))
        return true;
    return false;
}

bool GUI::toggleButton(sf::FloatRect rect, bool active, string text_value, float font_size)
{
    sf::Sprite sprite;
    texture_manager.setTexture(sprite, "button_background");
    if (rect.contains(mousePosition))
    {
        if (active)
            sprite.setColor(sf::Color(255,255,255, 192));
        else
            sprite.setColor(sf::Color(255,255,255, 64));
    }else{
        if (active)
            sprite.setColor(sf::Color(255,255,255, 255));
        else
            sprite.setColor(sf::Color(255,255,255, 128));
    }
    sprite.setOrigin(0, 0);
    sprite.setPosition(rect.left, rect.top);
    sprite.setScale(rect.width / sprite.getTextureRect().width, rect.height / sprite.getTextureRect().height);
    renderTarget->draw(sprite);

    text(rect, text_value, AlignCenter, font_size);
    if (mouse_click && rect.contains(mousePosition))
        return true;
    return false;
}

float GUI::vslider(sf::FloatRect rect, float value, float min_value, float max_value)
{
    sf::RectangleShape background(sf::Vector2f(rect.width, rect.height));
    background.setPosition(rect.left, rect.top);
    background.setFillColor(sf::Color(255,255,255,32));
    renderTarget->draw(background);

    sf::RectangleShape backgroundZero(sf::Vector2f(rect.width, 8.0));
    backgroundZero.setPosition(rect.left, rect.top + rect.height / 2.0 - 4.0);
    backgroundZero.setFillColor(sf::Color(0,0,0,32));
    renderTarget->draw(backgroundZero);

    float y = rect.top + (rect.height - rect.width) * (value - min_value) / (max_value - min_value);
    sf::Sprite sprite;
    texture_manager.setTexture(sprite, "button_background");
    if (rect.contains(mousePosition) && mousePosition.y >= y && mousePosition.y <= y + rect.width)
        sprite.setColor(sf::Color(255,255,255, 128));
    else
        sprite.setColor(sf::Color::White);
    sprite.setOrigin(0, 0);
    sprite.setPosition(rect.left, y);
    sprite.setScale(rect.width / sprite.getTextureRect().width, rect.width / sprite.getTextureRect().height);
    renderTarget->draw(sprite);

    if (rect.contains(mousePosition) && mouse_down)
    {
        value = (mousePosition.y - rect.top - (rect.width / 2.0)) / (rect.height - rect.width);
        value = min_value + (max_value - min_value) * value;
        if (min_value < max_value)
        {
            if (value < min_value)
                value = min_value;
            if (value > max_value)
                value = max_value;
        }else{
            if (value > min_value)
                value = min_value;
            if (value < max_value)
                value = max_value;
        }
    }

    return value;
}

MouseRenderer::MouseRenderer()
: Renderable(mouse_layer)
{
    visible = true;
}

void MouseRenderer::render(sf::RenderTarget& window)
{
    if (!visible) return;

    P<InputHandler> inputHandler = engine->getObject("inputHandler");
    sf::Vector2f mouse = inputHandler->getMousePos();

    sf::Sprite mouseSprite;
    texture_manager.setTexture(mouseSprite, "mouse.png");
    mouseSprite.setPosition(mouse);
    window.draw(mouseSprite);
}
