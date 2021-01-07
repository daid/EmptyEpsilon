#include "gui2_arrowbutton.h"
#include "gui2_spinbox.h"
#include "gui2_label.h"
#include "gui2_panel.h"
#include "soundManager.h"

GuiSpinBox::GuiSpinBox(GuiContainer* owner, string id, func_t func)
: GuiTextEntry(owner, id, string(0.0f)),
  func(nullptr),
  text_size(30),
  interval(1.0f),
  min_value(0.0f),
  max_value(10.0f),
  display_integer(false)
{
    decrement = new GuiArrowButton(this, id + "_DECREMENT", 0, [this]() {
        soundManager->playSound("button.wav");

        // Decrement by the interval amount.
        setValue(getValue() - interval);

        // Don't let the value drop below the minimum.
        if (getValue() < min_value)
        {
            setValue(min_value);
        }

        // callback();
    });
    decrement->setPosition(0, 0, ATopLeft)->setSize(GuiSizeMatchHeight, GuiSizeMax);

    increment = new GuiArrowButton(this, id + "_INCREMENT", 180, [this]() {
        soundManager->playSound("button.wav");

        // Increment by the interval amount.
        setValue(getValue() + interval);

        // Don't let the value increase past the maximum.
        if (getValue() > max_value)
        {
            setValue(max_value);
        }

        // callback();
    });
    increment->setPosition(0, 0, ATopRight)->setSize(GuiSizeMatchHeight, GuiSizeMax);
}

void GuiSpinBox::onDraw(sf::RenderTarget& window)
{
    // Disable buttons if value is at min/max.
    if (getValue() <= min_value)
    {
        decrement->setEnable(false);
    }
    else
    {
        decrement->setEnable(true);
    }

    if (getValue() >= max_value)
    {
        increment->setEnable(false);
    }
    else
    {
        increment->setEnable(true);
    }

    // Draw textbox.
    GuiTextEntry::onDraw(window);
}

bool GuiSpinBox::onKey(sf::Event::KeyEvent key, int unicode)
{
    // Backspace key behavior.
    if (key.code == sf::Keyboard::BackSpace && text.length() > 0)
    {
        // Remove character behind cursor.
        text = text.substr(0, -1);

        // Run callback.
        if (func)
        {
            func_t f = func;
            f(text);
        }

        return true;
    }

    // Enter/Return key behavior.
    if (key.code == sf::Keyboard::Return)
    {
        // Run enterCallback.
        if (enter_func)
        {
            func_t f = enter_func;
            f(text);
        }

        return true;
    }

    // Paste with Ctrl-V.
    if (key.code == sf::Keyboard::V && key.control)
    {
        for(int unicode : Clipboard::readClipboard())
        {
            // Accept only 0-9 and .
            if ((unicode > 47 && unicode < 58) || (unicode == 46))
            {
                text += string(char(unicode));
            }
        }

        // Run callback.
        if (func)
        {
            func_t f = func;
            f(text);
        }

        return true;
    }

    // Add to string if key is 0-9 or .
    if ((unicode > 47 && unicode < 58) || (unicode == 46))
    {
        text += string(char(unicode));

        // Run callback.
        if (func)
        {
            func_t f = func;
            f(text);
        }

        return true;
    }

    LOG(WARNING) << "Key " << unicode << " not entered; enter 0-9 or . only.";
    return true;
}

float GuiSpinBox::getValue()
{
    return stof(text);
}

GuiSpinBox* GuiSpinBox::setValue(float value)
{
    // Set the TextEntry's "text" to the value.
    // Make it look like an integer if that's what's requested.
    if (display_integer)
    {
        this->text = string(nearbyint(value), 0);
    }
    else
    {
        this->text = string(value);
    }

    return this;
}

float GuiSpinBox::getInterval()
{
    return interval;
}

GuiSpinBox* GuiSpinBox::setInterval(float interval)
{
    // Set the interval as long as it's greater than 0.
    if (interval > 0.0f)
    {
        this->interval = interval;
    }
    else
    {
        LOG(WARNING) << "SpinBox " << id << " interval " << interval << " cannot be negative.";
    }

    return this;
}

float GuiSpinBox::getMinValue()
{
    return min_value;
}

GuiSpinBox* GuiSpinBox::setMinValue(float min_value)
{
    // Set the min value as long as it's smaller than the max value.
    if (min_value < max_value)
    {
        this->min_value = min_value;
    }
    else
    {
        LOG(WARNING) << "SpinBox " << id << " minimum value " << min_value << " cannot be larger than the maximum value.";
    }

    return this;
}

float GuiSpinBox::getMaxValue()
{
    return max_value;
}

GuiSpinBox* GuiSpinBox::setMaxValue(float max_value)
{
    // Set the max value as long as it's larger than the min value.
    if (max_value > min_value)
    {
        this->max_value = max_value;
    }
    else
    {
        LOG(WARNING) << "SpinBox " << id << " maximum value " << max_value << " cannot be smaller than the minimum value.";
    }

    return this;
}

bool GuiSpinBox::getDisplayInteger()
{
    return display_integer;
}

GuiSpinBox* GuiSpinBox::setDisplayInteger(bool display_integer)
{
    // Set whether to display the value as an integer.
    this->display_integer = display_integer;
    return this;
}
