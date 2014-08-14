#include "gui.h"
#include "main.h"

sf::RenderTarget* GUI::renderTarget;
sf::Vector2f GUI::mousePosition;
sf::Vector2f GUI::windowSize;
int GUI::mouseClick;
int GUI::mouseDown;

GUI::GUI()
: Renderable(hudLayer)
{
    init = true;
}

void GUI::render(sf::RenderTarget& window)
{
    mousePosition = InputHandler::getMousePos();
    mouseClick = 0;
    mouseDown = 0;
    if (!init)//Do not send mouse clicks the first render, as we can just be created because of a mouseclick.
    {
        if (InputHandler::mouseIsReleased(sf::Mouse::Left))
            mouseClick = 1;
        else if (InputHandler::mouseIsReleased(sf::Mouse::Right))
            mouseClick = 2;
        if (InputHandler::mouseIsDown(sf::Mouse::Left))
            mouseDown = 1;
        else if (InputHandler::mouseIsDown(sf::Mouse::Right))
            mouseDown = 2;
        renderTarget = &window;
        windowSize = window.getView().getSize();
        onGui();
        renderTarget = NULL;
    }
    
    init = false;
}

void GUI::text(sf::FloatRect rect, string text, EAlign align, float fontSize, sf::Color color)
{
    sf::Text textElement(text, mainFont, fontSize);
    float y = rect.top + rect.height / 2.0 - (textElement.getLocalBounds().height + textElement.getLocalBounds().top) / 2.0 - fontSize / 8.0;
    switch(align)
    {
    case AlignLeft:
        textElement.setPosition(rect.left - textElement.getLocalBounds().left, y);
        break;
    case AlignRight:
        textElement.setPosition(rect.left + rect.width - textElement.getLocalBounds().width - textElement.getLocalBounds().left, y);
        break;
    case AlignCenter:
        textElement.setPosition(rect.left + rect.width / 2.0 - textElement.getLocalBounds().width / 2.0 - textElement.getLocalBounds().left, y);
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
    float f = (value - min_value) / (max_value - min_value);
    
    draw9Cut(rect, "button_background", color, f);
    draw9Cut(rect, "border_background");
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
    draw9Cut(rect, "button_background", rect.contains(mousePosition) ? sf::Color(128,128,128,255) : sf::Color::White);
    text(rect, textValue, AlignCenter, fontSize, sf::Color::Black);
    if (mouseClick && rect.contains(mousePosition))
    {
        soundManager.playSound("button.wav");
        return true;
    }
    return false;
}

void GUI::disabledButton(sf::FloatRect rect, string textValue, float textSize)
{
    draw9Cut(rect, "button_background", sf::Color(128,128,128, 255));

    text(rect, textValue, AlignCenter, textSize, sf::Color::Black);
}

bool GUI::toggleButton(sf::FloatRect rect, bool active, string textValue, float fontSize)
{
    sf::Color buttonColor;
    if (rect.contains(mousePosition))
    {
        if (active)
            buttonColor = sf::Color(192,192,192, 255);
        else
            buttonColor = sf::Color( 96, 96, 96, 255);
    }else{
        if (active)
            buttonColor = sf::Color(255,255,255, 255);
        else
            buttonColor = sf::Color(128,128,128, 255);
    }
    draw9Cut(rect, "button_background", buttonColor);

    text(rect, textValue, AlignCenter, fontSize, sf::Color::Black);
    if (mouseClick && rect.contains(mousePosition))
    {
        soundManager.playSound("button.wav");
        return true;
    }
    return false;
}

float GUI::vslider(sf::FloatRect rect, float value, float minValue, float maxValue, float normalValue)
{
    draw9Cut(rect, "button_background", sf::Color(32,32,32, 255));

    float y;
    y = rect.top + (rect.height - rect.width) * (normalValue - minValue) / (maxValue - minValue);
    sf::RectangleShape backgroundZero(sf::Vector2f(rect.width, 8.0));
    backgroundZero.setPosition(rect.left, y + rect.width / 2.0 - 4.0);
    backgroundZero.setFillColor(sf::Color(8,8,8,255));
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

int GUI::selector(sf::FloatRect rect, string textValue, float textSize)
{
    draw9Cut(rect, "border_background", sf::Color::White);
    text(rect, textValue, AlignCenter, textSize, sf::Color::White);
    
    sf::Sprite arrow;
    textureManager.setTexture(arrow, "gui_arrow.png");
    arrow.setPosition(rect.left + rect.height / 2.0, rect.top + rect.height / 2.0);
    float f = rect.height / float(arrow.getTextureRect().height);
    arrow.setScale(f, f);
    if (sf::FloatRect(rect.left, rect.top, rect.height, rect.height).contains(mousePosition))
        arrow.setColor(sf::Color(128, 128, 128, 255));
    renderTarget->draw(arrow);
    arrow.setPosition(rect.left + rect.width - rect.height / 2.0, rect.top + rect.height / 2.0);
    arrow.setRotation(180);
    if (sf::FloatRect(rect.left + rect.width - rect.height, rect.top, rect.height, rect.height).contains(mousePosition))
        arrow.setColor(sf::Color(128, 128, 128, 255));
    else
        arrow.setColor(sf::Color::White);
    renderTarget->draw(arrow);

    if (sf::FloatRect(rect.left, rect.top, rect.height, rect.height).contains(mousePosition) && mouseClick)
    {
        soundManager.playSound("button.wav");
        return -1;
    }

    if (sf::FloatRect(rect.left + rect.width - rect.height, rect.top, rect.height, rect.height).contains(mousePosition) && mouseClick)
    {
        soundManager.playSound("button.wav");
        return 1;
    }
    return 0;
}

string GUI::textEntry(sf::FloatRect rect, string value, float fontSize)
{
    draw9Cut(rect, "button_background", sf::Color(192,192,192,255));
    text(sf::FloatRect(rect.left + 16, rect.top, rect.width, rect.height), value + "_", AlignLeft, fontSize, sf::Color::Black);
    
    if (InputHandler::keyboardIsPressed(sf::Keyboard::BackSpace) && value.length() > 0)
        value = value.substr(0, -1);
    value += InputHandler::getKeyboardTextEntry();
    return value;
}

void GUI::draw9Cut(sf::FloatRect rect, string texture, sf::Color color, float width_factor)
{
    sf::Sprite sprite;
    textureManager.setTexture(sprite, texture);
    sf::IntRect textureSize = sprite.getTextureRect();
    int cornerSizeT = textureSize.height / 3;
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
    
    float w = 1.0;
    if (cornerSizeR > rect.width * width_factor)
        w = rect.width * width_factor / cornerSizeR;
    
    //TopLeft
    sprite.setPosition(rect.left, rect.top);
    sprite.setTextureRect(sf::IntRect(0, 0, cornerSizeT * w, cornerSizeT));
    renderTarget->draw(sprite);
    //BottomLeft
    sprite.setPosition(rect.left, rect.top + rect.height - cornerSizeR);
    sprite.setTextureRect(sf::IntRect(0, textureSize.height - cornerSizeT, cornerSizeT * w, cornerSizeT));
    renderTarget->draw(sprite);

    if (rect.height > cornerSizeR * 2)
    {
        //left
        sprite.setPosition(rect.left, rect.top + cornerSizeR);
        sprite.setTextureRect(sf::IntRect(0, cornerSizeT, cornerSizeT * w, 1));
        sprite.setScale(scale, rect.height - cornerSizeR*2);
        renderTarget->draw(sprite);
        sprite.setScale(scale, scale);
    }
    if (w < 1.0)
        return;

    if (rect.width - cornerSizeR > rect.width * width_factor)
        w = (width_factor - cornerSizeR / rect.width) * (rect.width / (rect.width - cornerSizeR * 2));

    if (rect.width > cornerSizeR * 2)
    {
        //Top
        sprite.setPosition(rect.left + cornerSizeR, rect.top);
        sprite.setTextureRect(sf::IntRect(cornerSizeT, 0, textureSize.width - cornerSizeT * 2, cornerSizeT));
        sprite.setScale((rect.width - cornerSizeR*2) / float(textureSize.width - cornerSizeT * 2) * w, scale);
        renderTarget->draw(sprite);
        //Bottom
        sprite.setPosition(rect.left + cornerSizeR, rect.top + rect.height - cornerSizeR);
        sprite.setTextureRect(sf::IntRect(cornerSizeT, textureSize.height - cornerSizeT, textureSize.width - cornerSizeT * 2, cornerSizeT));
        sprite.setScale((rect.width - cornerSizeR*2) / float(textureSize.width - cornerSizeT * 2) * w, scale);
        renderTarget->draw(sprite);
        sprite.setScale(scale, scale);
    }

    if (rect.width > cornerSizeR * 2 && rect.height > cornerSizeR * 2)
    {
        //Center
        sprite.setPosition(rect.left + cornerSizeR, rect.top + cornerSizeR);
        sprite.setTextureRect(sf::IntRect(cornerSizeT, cornerSizeT, 1, 1));
        sprite.setScale((rect.width - cornerSizeR*2) * w, rect.height - cornerSizeR*2);
        renderTarget->draw(sprite);
        sprite.setScale(scale, scale);
    }
    if (w < 1.0)
        return;
    if (width_factor < 1.0)
        w = (width_factor - (rect.width - cornerSizeR) / rect.width) * (rect.width / cornerSizeR);
    
    //TopRight
    sprite.setPosition(rect.left + rect.width - cornerSizeR, rect.top);
    sprite.setTextureRect(sf::IntRect(textureSize.width - cornerSizeT, 0, cornerSizeT * w, cornerSizeT));
    renderTarget->draw(sprite);
    //BottomRight
    sprite.setPosition(rect.left + rect.width - cornerSizeR, rect.top + rect.height - cornerSizeR);
    sprite.setTextureRect(sf::IntRect(textureSize.width - cornerSizeT, textureSize.height - cornerSizeT, cornerSizeT * w, cornerSizeT));
    renderTarget->draw(sprite);

    if (rect.height > cornerSizeR * 2)
    {
        //Right
        sprite.setPosition(rect.left + rect.width - cornerSizeR, rect.top + cornerSizeR);
        sprite.setTextureRect(sf::IntRect(textureSize.width - cornerSizeT, cornerSizeT, cornerSizeT * w, 1));
        sprite.setScale(scale, rect.height - cornerSizeR*2);
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

    sf::Vector2f mouse = InputHandler::getMousePos();
    
    sf::Sprite mouseSprite;
    textureManager.setTexture(mouseSprite, "mouse.png");
    mouseSprite.setPosition(mouse);
    window.draw(mouseSprite);
}
