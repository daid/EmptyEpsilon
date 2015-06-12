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

void GUI::drawText(sf::FloatRect rect, string text, EAlign align, float font_size, sf::Color color)
{
    sf::Text textElement(text, mainFont, font_size);
    float y = 0;
    float x = 0;
    switch(align)
    {
    case AlignLeft:
    case AlignRight:
    case AlignCenter:
        y = rect.top + rect.height / 2.0 - (textElement.getLocalBounds().height + textElement.getLocalBounds().top) / 2.0 - font_size / 8.0;
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

void GUI::drawVerticalText(sf::FloatRect rect, string text, EAlign align, float font_size, sf::Color color)
{
    sf::Text textElement(text, mainFont, font_size);
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

void GUI::drawProgressBar(sf::FloatRect rect, float value, float min_value, float max_value, sf::Color color, sf::Color border_color)
{
    float f = (value - min_value) / (max_value - min_value);

    if (color != border_color)
        draw9Cut(rect, "button_background", color, f);
    draw9Cut(rect, "border_background", border_color);
    if (color == border_color)
        draw9Cut(rect, "button_background", color, f);
}

bool GUI::drawButton(sf::FloatRect rect, string text_value, float font_size)
{
    draw9Cut(rect, "button_background", rect.contains(mousePosition) ? sf::Color(128,128,128,255) : sf::Color::White);
    drawText(rect, text_value, AlignCenter, font_size, sf::Color::Black);
    if (mouseClick && rect.contains(mousePosition))
    {
        soundManager.playSound("button.wav");
        return true;
    }
    return false;
}

void GUI::drawDisabledButton(sf::FloatRect rect, string text_value, float text_size)
{
    draw9Cut(rect, "button_background", sf::Color(128,128,128, 255));

    drawText(rect, text_value, AlignCenter, text_size, sf::Color::Black);
}

bool GUI::drawToggleButton(sf::FloatRect rect, bool active, string text_value, float font_size)
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

    drawText(rect, text_value, AlignCenter, font_size, sf::Color::Black);
    if (mouseClick && rect.contains(mousePosition))
    {
        soundManager.playSound("button.wav");
        return true;
    }
    return false;
}

float GUI::drawHorizontalSlider(sf::FloatRect rect, float value, float min_value, float max_value, float normal_value)
{
    draw9Cut(rect, "button_background", sf::Color(64,64,64, 255));

    float x;
    x = rect.left + (rect.width - rect.height) * (normal_value - min_value) / (max_value - min_value);
    sf::RectangleShape backgroundZero(sf::Vector2f(8.0, rect.height));
    backgroundZero.setPosition(x + rect.height / 2.0 - 4.0, rect.top);
    backgroundZero.setFillColor(sf::Color(8,8,8,255));
    renderTarget->draw(backgroundZero);

    x = rect.left + (rect.width - rect.height) * (value - min_value) / (max_value - min_value);
    sf::Color color = sf::Color::White;
    if (rect.contains(mousePosition) && mousePosition.x >= x && mousePosition.x <= x + rect.height)
        color = sf::Color(255,255,255, 128);
    draw9Cut(sf::FloatRect(x, rect.top, rect.height, rect.height), "button_background", color);

    if (rect.contains(mousePosition) && mouseDown)
    {
        value = (mousePosition.x - rect.left - (rect.height / 2.0)) / (rect.width - rect.height);
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

float GUI::drawVerticalSlider(sf::FloatRect rect, float value, float min_value, float max_value, float normal_value)
{
    draw9Cut(rect, "button_background", sf::Color(64,64,64, 255));

    float y;
    y = rect.top + (rect.height - rect.width) * (normal_value - min_value) / (max_value - min_value);
    sf::RectangleShape backgroundZero(sf::Vector2f(rect.width, 8.0));
    backgroundZero.setPosition(rect.left, y + rect.width / 2.0 - 4.0);
    backgroundZero.setFillColor(sf::Color(8,8,8,255));
    renderTarget->draw(backgroundZero);

    y = rect.top + (rect.height - rect.width) * (value - min_value) / (max_value - min_value);
    sf::Color color = sf::Color::White;
    if (rect.contains(mousePosition) && mousePosition.y >= y && mousePosition.y <= y + rect.width)
        color = sf::Color(255,255,255, 128);
    draw9Cut(sf::FloatRect(rect.left, y, rect.width, rect.width), "button_background", color);

    if (rect.contains(mousePosition) && mouseDown)
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

int GUI::drawSelector(sf::FloatRect rect, string text_value, float text_size)
{
    int ret = 0;

    draw9Cut(rect, "border_background", sf::Color::White);
    drawText(rect, text_value, AlignCenter, text_size, sf::Color::White);

    if (drawArrow(sf::FloatRect(rect.left, rect.top, rect.height, rect.height), false, 0))
        ret = -1;
    if (drawArrow(sf::FloatRect(rect.left + rect.width - rect.height, rect.top, rect.height, rect.height), false, 180))
        ret = 1;
    return ret;
}

void GUI::drawDisabledSelector(sf::FloatRect rect, string text_value, float text_size)
{
    draw9Cut(rect, "border_background", sf::Color::White);
    drawText(rect, text_value, AlignCenter, text_size, sf::Color(128, 128, 128));

    drawArrow(sf::FloatRect(rect.left, rect.top, rect.height, rect.height), true, 0);
    drawArrow(sf::FloatRect(rect.left + rect.width - rect.height, rect.top, rect.height, rect.height), true, 180);
}

void GUI::drawBox(sf::FloatRect rect, sf::Color border_color)
{
    draw9Cut(rect, "border_background", border_color);
}

void GUI::drawBoxWithBackground(sf::FloatRect rect, sf::Color border_color, sf::Color background_color)
{
    draw9Cut(rect, "button_background", background_color);
    draw9Cut(rect, "border_background", border_color);
}

void GUI::drawTextBox(sf::FloatRect rect, string text, EAlign align, float text_size, sf::Color color)
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

            sf::Glyph glyph = mainFont.getGlyph(currentChar, text_size, false);
            currentOffset += glyph.advance;

            if (!firstWord && currentOffset > rect.width - text_size * 2)
            {
                pos = wordBegining;
                text[pos] = '\n';
                firstWord = true;
                currentOffset = 0;
            }
        }
    }

    drawBox(rect);
    GUI::drawText(sf::FloatRect(rect.left + text_size, rect.top + text_size, rect.width - text_size * 2, rect.height - text_size * 2), text, align, text_size, color);
}

void GUI::drawTextBoxWithBackground(sf::FloatRect rect, string text, EAlign align, float text_size, sf::Color color, sf::Color bg_color)
{
    draw9Cut(rect, "button_background", bg_color);
    drawTextBox(rect, text, align, text_size, color);
}

int GUI::drawScrollableTextBox(sf::FloatRect rect, string text, int start_line_nr, EAlign align, float text_size, sf::Color color)
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

            sf::Glyph glyph = mainFont.getGlyph(currentChar, text_size, false);
            currentOffset += glyph.advance;

            if (!firstWord && currentOffset > rect.width - text_size * 2 - 50)
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
    int max_lines = (rect.height - text_size * 2) / mainFont.getLineSpacing(text_size);
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

    drawBox(rect);
    GUI::drawText(sf::FloatRect(rect.left + text_size, rect.top + text_size, rect.width - text_size * 2 - 50, rect.height - text_size * 2), text, align, text_size, color);

    //Side scrollbar
    drawBox(sf::FloatRect(rect.left + rect.width - 50, rect.top, 50, rect.height));
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

string GUI::drawTextEntry(sf::FloatRect rect, string value, float font_size)
{
    draw9Cut(rect, "button_background", sf::Color(192,192,192,255));
    drawText(sf::FloatRect(rect.left + 16, rect.top, rect.width, rect.height), value + "_", AlignLeft, font_size, sf::Color::Black);

    if (InputHandler::keyboardIsPressed(sf::Keyboard::BackSpace) && value.length() > 0)
        value = value.substr(0, -1);
    //value += InputHandler::getKeyboarddrawTextEntry();
    return value;
}

void GUI::drawKeyValueDisplay(sf::FloatRect rect, float div_distance, string key, string value, float text_size)
{
    const float div_size = 3.0;
    draw9Cut(rect, "border_background");
    draw9Cut(rect, "button_background", sf::Color::White, div_distance);
    drawText(sf::FloatRect(rect.left, rect.top, rect.width * div_distance - div_size, rect.height), key, AlignRight, text_size, sf::Color::Black);
    drawText(sf::FloatRect(rect.left + rect.width * div_distance + div_size, rect.top, rect.width * (1.0 - div_distance), rect.height), value, AlignLeft, text_size);
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
