#include "gui.h"
#include "main.h"

sf::RenderTarget* GUI::renderTarget;
sf::Vector2f GUI::mousePosition;
int GUI::mouseClick;
int GUI::mouseDown;

GUI::GUI()
: Renderable(hudLayer)
{
    init = true;
}

void GUI::render(sf::RenderTarget& window)
{
    P<InputHandler> inputHandler = engine->getObject("inputHandler");
    mousePosition = inputHandler->getMousePos();
    mouseClick = 0;
    mouseDown = 0;
    if (!init)//Do not send mouse clicks the first render, as we can just be created because of a mouseclick.
    {
        if (inputHandler->mouseIsPressed(sf::Mouse::Left))
            mouseClick = 1;
        else if (inputHandler->mouseIsPressed(sf::Mouse::Right))
            mouseClick = 2;
        if (inputHandler->mouseIsDown(sf::Mouse::Left))
            mouseDown = 1;
        else if (inputHandler->mouseIsDown(sf::Mouse::Right))
            mouseDown = 2;
        renderTarget = &window;
        onGui();
        renderTarget = NULL;
    }
    
    init = false;
}

void GUI::text(sf::FloatRect rect, string text, EAlign align, float fontSize, sf::Color color)
{
    sf::Text textElement(text, mainFont, fontSize);
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
    textElement.setColor(color);
    renderTarget->draw(textElement);
}

void GUI::vtext(sf::FloatRect rect, string text, EAlign align, float fontSize, sf::Color color)
{
    sf::Text textElement(text, mainFont, fontSize);
    textElement.setRotation(-90);
    switch(align)
    {
    case AlignLeft:
        textElement.setPosition(rect.left + rect.width / 2.0 - textElement.getLocalBounds().height / 2.0 - textElement.getLocalBounds().top / 2.0, rect.top + rect.height);
        break;
    case AlignRight:
        textElement.setPosition(rect.left + rect.width / 2.0 - textElement.getLocalBounds().height / 2.0 - textElement.getLocalBounds().top / 2.0, rect.top + textElement.getLocalBounds().left + textElement.getLocalBounds().width);
        break;
    case AlignCenter:
        textElement.setPosition(rect.left + rect.width / 2.0 - textElement.getLocalBounds().height / 2.0 - textElement.getLocalBounds().top / 2.0, rect.top + rect.height / 2.0 + textElement.getLocalBounds().width / 2.0 + textElement.getLocalBounds().left);
        break;
    }
    textElement.setColor(color);
    renderTarget->draw(textElement);
}

void GUI::progressBar(sf::FloatRect rect, float value, float min_value, float max_value, sf::Color color)
{
    rect.left += 4.0;
    rect.top += 4.0;
    rect.width -= 8.0;
    rect.height -= 8.0;

    sf::RectangleShape background(sf::Vector2f(rect.width, rect.height));
    background.setPosition(rect.left, rect.top);
    background.setFillColor(sf::Color::Transparent);
    background.setOutlineColor(sf::Color(32, 32, 32, 255));
    background.setOutlineThickness(4.0);
    renderTarget->draw(background);

    sf::RectangleShape bar_fill(sf::Vector2f(rect.width * (value - min_value) / (max_value - min_value), rect.height));
    bar_fill.setPosition(rect.left, rect.top);
    bar_fill.setFillColor(color);
    renderTarget->draw(bar_fill);
}

void GUI::vprogressBar(sf::FloatRect rect, float value, float min_value, float max_value, sf::Color color)
{
    rect.left += 4.0;
    rect.top += 4.0;
    rect.width -= 8.0;
    rect.height -= 8.0;

    sf::RectangleShape background(sf::Vector2f(rect.width, rect.height));
    background.setPosition(rect.left, rect.top);
    background.setFillColor(sf::Color::Transparent);
    background.setOutlineColor(sf::Color(32, 32, 32, 255));
    background.setOutlineThickness(4.0);
    renderTarget->draw(background);

    float h = rect.height * (value - min_value) / (max_value - min_value);
    sf::RectangleShape bar_fill(sf::Vector2f(rect.width, h));
    bar_fill.setPosition(rect.left, rect.top + rect.height - h);
    bar_fill.setFillColor(color);
    renderTarget->draw(bar_fill);
}

bool GUI::button(sf::FloatRect rect, string textValue, float fontSize)
{
    draw9Cut(rect, "button_background", rect.contains(mousePosition) ? sf::Color(255,255,255, 128) : sf::Color::White);

    text(rect, textValue, AlignCenter, fontSize);
    if (mouseClick && rect.contains(mousePosition))
        return true;
    return false;
}

bool GUI::toggleButton(sf::FloatRect rect, bool active, string textValue, float fontSize)
{
    sf::Color buttonColor;
    if (rect.contains(mousePosition))
    {
        if (active)
            buttonColor = sf::Color(255,255,255, 192);
        else
            buttonColor = sf::Color(255,255,255, 64);
    }else{
        if (active)
            buttonColor = sf::Color(255,255,255, 255);
        else
            buttonColor = sf::Color(255,255,255, 128);
    }
    draw9Cut(rect, "button_background", buttonColor);

    text(rect, textValue, AlignCenter, fontSize);
    if (mouseClick && rect.contains(mousePosition))
        return true;
    return false;
}

float GUI::vslider(sf::FloatRect rect, float value, float minValue, float maxValue, float normalValue)
{
    sf::RectangleShape background(sf::Vector2f(rect.width, rect.height));
    background.setPosition(rect.left, rect.top);
    background.setFillColor(sf::Color(255,255,255,32));
    renderTarget->draw(background);

    float y;
    y = rect.top + (rect.height - rect.width) * (normalValue - minValue) / (maxValue - minValue);
    sf::RectangleShape backgroundZero(sf::Vector2f(rect.width, 8.0));
    backgroundZero.setPosition(rect.left, y + rect.width / 2.0 - 4.0);
    backgroundZero.setFillColor(sf::Color(0,0,0,32));
    renderTarget->draw(backgroundZero);
    
    y = rect.top + (rect.height - rect.width) * (value - minValue) / (maxValue - minValue);
    sf::Color color = sf::Color::White;
    if (rect.contains(mousePosition) && mousePosition.y >= y && mousePosition.y <= y + rect.width)
        color = sf::Color(255,255,255, 128);
    draw9Cut(sf::FloatRect(rect.left, y, rect.width, rect.width), "button_background", color);

    if (rect.contains(mousePosition) && mouseDown)
    {
        value = (mousePosition.y - rect.top - (rect.width / 2.0)) / (rect.height - rect.width);
        value = minValue + (maxValue - minValue) * value;
        if (minValue < maxValue)
        {
            if (value < minValue)
                value = minValue;
            if (value > maxValue)
                value = maxValue;
        }else{
            if (value > minValue)
                value = minValue;
            if (value < maxValue)
                value = maxValue;
        }
    }

    return value;
}

void GUI::draw9Cut(sf::FloatRect rect, string texture, sf::Color color)
{
    sf::Sprite sprite;
    textureManager.setTexture(sprite, texture);
    sf::IntRect textureSize = sprite.getTextureRect();
    int cornerSizeT = textureSize.height / 2;
    float cornerSizeR = cornerSizeT;
    float scale = 1.0;
    if (cornerSizeT > rect.height / 2)
    {
        scale = float(rect.height / 2) / cornerSizeR;
        sprite.setScale(scale, scale);
        cornerSizeR *= scale;
    }
    if (cornerSizeT > rect.width / 2)
    {
        scale = float(rect.width / 2) / cornerSizeR;
        sprite.setScale(scale, scale);
        cornerSizeR *= scale;
    }
    sprite.setColor(color);
    sprite.setOrigin(0, 0);
    //TopLeft
    sprite.setPosition(rect.left, rect.top);
    sprite.setTextureRect(sf::IntRect(0, 0, cornerSizeT, cornerSizeT));
    renderTarget->draw(sprite);
    //BottomLeft
    sprite.setPosition(rect.left, rect.top + rect.height - cornerSizeR);
    sprite.setTextureRect(sf::IntRect(0, textureSize.height - cornerSizeT, cornerSizeT, cornerSizeT));
    renderTarget->draw(sprite);
    //TopRight
    sprite.setPosition(rect.left + rect.width - cornerSizeR, rect.top);
    sprite.setTextureRect(sf::IntRect(textureSize.width - cornerSizeT, 0, cornerSizeT, cornerSizeT));
    renderTarget->draw(sprite);
    //BottomRight
    sprite.setPosition(rect.left + rect.width - cornerSizeR, rect.top + rect.height - cornerSizeR);
    sprite.setTextureRect(sf::IntRect(textureSize.width - cornerSizeT, textureSize.height - cornerSizeT, cornerSizeT, cornerSizeT));
    renderTarget->draw(sprite);
    
    if (rect.width > cornerSizeR * 2)
    {
        //Top
        sprite.setPosition(rect.left + cornerSizeR, rect.top);
        sprite.setTextureRect(sf::IntRect(cornerSizeT, 0, textureSize.width - cornerSizeT * 2, cornerSizeT));
        sprite.setScale((rect.width - cornerSizeR*2) / float(textureSize.width - cornerSizeT * 2), scale);
        renderTarget->draw(sprite);
        //Bottom
        sprite.setPosition(rect.left + cornerSizeR, rect.top + rect.height - cornerSizeR);
        sprite.setTextureRect(sf::IntRect(cornerSizeT, textureSize.height - cornerSizeT, textureSize.width - cornerSizeT * 2, cornerSizeT));
        sprite.setScale((rect.width - cornerSizeR*2) / float(textureSize.width - cornerSizeT * 2), scale);
        renderTarget->draw(sprite);
    }
    if (rect.height > cornerSizeR * 2)
    {
        //left
        sprite.setPosition(rect.left, rect.top + cornerSizeR);
        sprite.setTextureRect(sf::IntRect(0, cornerSizeT, cornerSizeT, 1));
        sprite.setScale(scale, rect.height - cornerSizeR*2);
        renderTarget->draw(sprite);
        //Right
        sprite.setPosition(rect.left + rect.width - cornerSizeR, rect.top + cornerSizeR);
        sprite.setTextureRect(sf::IntRect(textureSize.width - cornerSizeT, cornerSizeT, cornerSizeT, 1));
        sprite.setScale(scale, rect.height - cornerSizeR*2);
        renderTarget->draw(sprite);
    }
    if (rect.width > cornerSizeR * 2 && rect.height > cornerSizeR * 2)
    {
        //Center
        sprite.setPosition(rect.left + cornerSizeR, rect.top + cornerSizeR);
        sprite.setTextureRect(sf::IntRect(cornerSizeT, cornerSizeT, 1, 1));
        sprite.setScale(rect.width - cornerSizeR*2, rect.height - cornerSizeR*2);
        renderTarget->draw(sprite);
    }
}

MouseRenderer::MouseRenderer()
: Renderable(mouseLayer)
{
    visible = true;
}

void MouseRenderer::render(sf::RenderTarget& window)
{
    if (!visible) return;

    P<InputHandler> inputHandler = engine->getObject("inputHandler");
    sf::Vector2f mouse = inputHandler->getMousePos();
    
    sf::Sprite mouseSprite;
    textureManager.setTexture(mouseSprite, "mouse.png");
    mouseSprite.setPosition(mouse);
    window.draw(mouseSprite);
}
