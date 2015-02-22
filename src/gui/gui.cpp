#include "gui.h"
#include "main.h"

sf::RenderTarget* GUI::renderTarget;
sf::Vector2f GUI::mousePosition;
sf::Vector2f GUI::windowSize;
int GUI::mouseClick;
int GUI::mouseDown;
PVector<GUI> GUI::gui_stack;

GUI::GUI()
: Renderable(hudLayer)
{
    init = true;
    gui_stack.push_back(this);
}

void GUI::render(sf::RenderTarget& window)
{
    mousePosition = sf::Vector2f(-1, -1);
    mouseClick = 0;
    mouseDown = 0;
    gui_stack.update();
    if (!init)//Do not send mouse clicks the first render, as we can just be created because of a mouseclick.
    {
        if (isActive())   //Only handle mouse actions when we are at the top of the GUI stack.
        {
            mousePosition = InputHandler::getMousePos();
            if (InputHandler::mouseIsReleased(sf::Mouse::Left))
                mouseClick = 1;
            else if (InputHandler::mouseIsReleased(sf::Mouse::Right))
                mouseClick = 2;
            if (InputHandler::mouseIsDown(sf::Mouse::Left))
                mouseDown = 1;
            else if (InputHandler::mouseIsDown(sf::Mouse::Right))
                mouseDown = 2;
        }
        renderTarget = &window;
        windowSize = window.getView().getSize();
        onGui();
        if (!isActive())
        {
            sf::RectangleShape fullScreenOverlay(sf::Vector2f(getWindowSize().x, getWindowSize().y));
            fullScreenOverlay.setFillColor(sf::Color(0, 0, 0, 128));
            window.draw(fullScreenOverlay);
        }
        renderTarget = NULL;
    }
    
    init = false;
}

bool GUI::isActive()
{
    return gui_stack.back() == this;
}

void GUI::text(sf::FloatRect rect, string text, EAlign align, float fontSize, sf::Color color)
{
    sf::Text textElement(text, mainFont, fontSize);
    float y = 0;
    float x = 0;
    switch(align)
    {
    case AlignLeft:
    case AlignRight:
    case AlignCenter:
        y = rect.top + rect.height / 2.0 - (textElement.getLocalBounds().height + textElement.getLocalBounds().top) / 2.0 - fontSize / 8.0;
        break;
    case AlignTopLeft:
    case AlignTopRight:
    case AlignTopCenter:
        y = rect.top - textElement.getLocalBounds().top;
        break;
    }
    switch(align)
    {
    case AlignLeft:
    case AlignTopLeft:
        x = rect.left - textElement.getLocalBounds().left;
        break;
    case AlignRight:
    case AlignTopRight:
        x = rect.left + rect.width - textElement.getLocalBounds().width - textElement.getLocalBounds().left;
        break;
    case AlignCenter:
    case AlignTopCenter:
        x = rect.left + rect.width / 2.0 - textElement.getLocalBounds().width / 2.0 - textElement.getLocalBounds().left;
        break;
    }
    textElement.setPosition(x, y);
    textElement.setColor(color);
    renderTarget->draw(textElement);
}

void GUI::vtext(sf::FloatRect rect, string text, EAlign align, float fontSize, sf::Color color)
{
    sf::Text textElement(text, mainFont, fontSize);
    textElement.setRotation(-90);
    float x = 0;
    float y = 0;
    x = rect.left + rect.width / 2.0 - textElement.getLocalBounds().height / 2.0 - textElement.getLocalBounds().top / 2.0;
    switch(align)
    {
    case AlignLeft:
    case AlignTopLeft:
        y = rect.top + rect.height;
        break;
    case AlignRight:
    case AlignTopRight:
        y = rect.top + textElement.getLocalBounds().left + textElement.getLocalBounds().width;
        break;
    case AlignCenter:
    case AlignTopCenter:
        y = rect.top + rect.height / 2.0 + textElement.getLocalBounds().width / 2.0 + textElement.getLocalBounds().left;
        break;
    }
    textElement.setPosition(x, y);
    textElement.setColor(color);
    renderTarget->draw(textElement);
}

void GUI::progressBar(sf::FloatRect rect, float value, float min_value, float max_value, sf::Color color)
{
    float f = (value - min_value) / (max_value - min_value);
    
    if (color != sf::Color::White)
        draw9Cut(rect, "button_background", color, f);
    draw9Cut(rect, "border_background");
    if (color == sf::Color::White)
        draw9Cut(rect, "button_background", color, f);
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

float GUI::hslider(sf::FloatRect rect, float value, float minValue, float maxValue, float normalValue)
{
    draw9Cut(rect, "button_background", sf::Color(64,64,64, 255));

    float x;
    x = rect.left + (rect.width - rect.height) * (normalValue - minValue) / (maxValue - minValue);
    sf::RectangleShape backgroundZero(sf::Vector2f(8.0, rect.height));
    backgroundZero.setPosition(x + rect.height / 2.0 - 4.0, rect.top);
    backgroundZero.setFillColor(sf::Color(8,8,8,255));
    renderTarget->draw(backgroundZero);
    
    x = rect.left + (rect.width - rect.height) * (value - minValue) / (maxValue - minValue);
    sf::Color color = sf::Color::White;
    if (rect.contains(mousePosition) && mousePosition.x >= x && mousePosition.x <= x + rect.height)
        color = sf::Color(255,255,255, 128);
    draw9Cut(sf::FloatRect(x, rect.top, rect.height, rect.height), "button_background", color);

    if (rect.contains(mousePosition) && mouseDown)
    {
        value = (mousePosition.x - rect.left - (rect.height / 2.0)) / (rect.width - rect.height);
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

float GUI::vslider(sf::FloatRect rect, float value, float minValue, float maxValue, float normalValue)
{
    draw9Cut(rect, "button_background", sf::Color(64,64,64, 255));

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
    int ret = 0;
    
    draw9Cut(rect, "border_background", sf::Color::White);
    text(rect, textValue, AlignCenter, textSize, sf::Color::White);
    
    if (drawArrow(sf::FloatRect(rect.left, rect.top, rect.height, rect.height), false, 0))
        ret = -1;
    if (drawArrow(sf::FloatRect(rect.left + rect.width - rect.height, rect.top, rect.height, rect.height), false, 180))
        ret = 1;
    return ret;
}

void GUI::disabledSelector(sf::FloatRect rect, string textValue, float textSize)
{
    draw9Cut(rect, "border_background", sf::Color::White);
    text(rect, textValue, AlignCenter, textSize, sf::Color(128, 128, 128));
    
    drawArrow(sf::FloatRect(rect.left, rect.top, rect.height, rect.height), true, 0);
    drawArrow(sf::FloatRect(rect.left + rect.width - rect.height, rect.top, rect.height, rect.height), true, 180);
}

void GUI::box(sf::FloatRect rect, sf::Color color)
{
    draw9Cut(rect, "border_background", color);
}

void GUI::boxWithBackground(sf::FloatRect rect, sf::Color color, sf::Color bg_color)
{
    draw9Cut(rect, "button_background", bg_color);
    draw9Cut(rect, "border_background", color);
}

void GUI::textbox(sf::FloatRect rect, string text, EAlign align, float textSize, sf::Color color)
{
    {
        unsigned currentOffset = 0;
        bool firstWord = true;
        std::size_t wordBegining = 0;

        for (std::size_t pos(0); pos < text.length(); ++pos)
        {
            char currentChar = text[pos];
            if (currentChar == '\n')
            {
                currentOffset = 0;
                firstWord = true;
                continue;
            } else if (currentChar == ' ')
            {
                wordBegining = pos;
                firstWord = false;
            }

            sf::Glyph glyph = mainFont.getGlyph(currentChar, textSize, false);
            currentOffset += glyph.advance;

            if (!firstWord && currentOffset > rect.width - textSize * 2)
            {
                pos = wordBegining;
                text[pos] = '\n';
                firstWord = true;
                currentOffset = 0;
            }
        }
    }

    box(rect);
    GUI::text(sf::FloatRect(rect.left + textSize, rect.top + textSize, rect.width - textSize * 2, rect.height - textSize * 2), text, align, textSize, color);
}

void GUI::textboxWithBackground(sf::FloatRect rect, string text, EAlign align, float textSize, sf::Color color, sf::Color bg_color)
{
    draw9Cut(rect, "button_background", bg_color);
    textbox(rect, text, align, textSize, color);
}

int GUI::scrolltextbox(sf::FloatRect rect, string text, int start_line_nr, EAlign align, float textSize, sf::Color color)
{
    int line_count = 1;
    {
        float currentOffset = 0;
        bool firstWord = true;
        std::size_t wordBegining = 0;

        for (std::size_t pos(0); pos < text.length(); ++pos)
        {
            char currentChar = text[pos];
            if (currentChar == '\n')
            {
                currentOffset = 0;
                firstWord = true;
                line_count += 1;
                continue;
            } else if (currentChar == ' ')
            {
                wordBegining = pos;
                firstWord = false;
            }

            sf::Glyph glyph = mainFont.getGlyph(currentChar, textSize, false);
            currentOffset += glyph.advance;

            if (!firstWord && currentOffset > rect.width - textSize * 2 - 50)
            {
                pos = wordBegining;
                text[pos] = '\n';
                firstWord = true;
                currentOffset = 0;
                line_count += 1;
            }
        }
    }
    
    int start_pos = 0;
    for(int n=0; n<start_line_nr; n++)
    {
        int next = text.find("\n", start_pos) + 1;
        if (next > 0)
            start_pos = next;
    }
    if (start_pos > 0)
        text = text.substr(start_pos);
    int max_lines = (rect.height - textSize * 2) / mainFont.getLineSpacing(textSize);
    if (line_count - start_line_nr > max_lines)
    {
        int end_pos = 0;
        for(int n=0; n<max_lines; n++)
        {
            int next = text.find("\n", end_pos) + 1;
            if (next > 0)
                end_pos = next;
        }
        if (end_pos > 0)
            text = text.substr(0, end_pos);
    }

    box(rect);
    GUI::text(sf::FloatRect(rect.left + textSize, rect.top + textSize, rect.width - textSize * 2 - 50, rect.height - textSize * 2), text, align, textSize, color);

    //Side scrollbar
    box(sf::FloatRect(rect.left + rect.width - 50, rect.top, 50, rect.height));
    if (drawArrow(sf::FloatRect(rect.left + rect.width - 50, rect.top, 50, 50), false, 90))
        start_line_nr -= 1;
    if (drawArrow(sf::FloatRect(rect.left + rect.width - 50, rect.top + rect.height - 50, 50, 50), false, -90))
        start_line_nr += 1;
    if (start_line_nr >= line_count - max_lines)
        start_line_nr = line_count - max_lines - 1;
    if (start_line_nr < 0)
        start_line_nr = 0;

    float f = std::min(1.0f, float(max_lines) / float(line_count));
    draw9Cut(sf::FloatRect(rect.left + rect.width - 50, rect.top + 50 + (rect.height - 100) * (1.0f - f) * float(start_line_nr) / float(line_count - max_lines - 1), 50, (rect.height - 100) * f), "button_background", sf::Color(255,255,255,255));

    return start_line_nr;
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

void GUI::keyValueDisplay(sf::FloatRect rect, float div_distance, string key, string value, float textSize)
{
    const float div_size = 3.0;
    draw9Cut(rect, "border_background");
    draw9Cut(rect, "button_background", sf::Color::White, div_distance);
    text(sf::FloatRect(rect.left, rect.top, rect.width * div_distance - div_size, rect.height), key, AlignRight, textSize, sf::Color::Black);
    text(sf::FloatRect(rect.left + rect.width * div_distance + div_size, rect.top, rect.width * (1.0 - div_distance), rect.height), value, AlignLeft, textSize);
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

bool GUI::drawArrow(sf::FloatRect rect, bool disabled, float rotation)
{
    sf::Sprite arrow;
    textureManager.setTexture(arrow, "gui_arrow.png");
    arrow.setPosition(rect.left + rect.width / 2.0, rect.top + rect.height / 2.0);
    float f = rect.height / float(arrow.getTextureRect().height);
    arrow.setScale(f, f);
    arrow.setRotation(rotation);
    if (sf::FloatRect(rect.left, rect.top, rect.height, rect.height).contains(mousePosition) || disabled)
        arrow.setColor(sf::Color(128, 128, 128, 255));
    renderTarget->draw(arrow);
    if (!disabled && sf::FloatRect(rect.left, rect.top, rect.height, rect.height).contains(mousePosition) && mouseClick)
    {
        soundManager.playSound("button.wav");
        return true;
    }
    return false;
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
