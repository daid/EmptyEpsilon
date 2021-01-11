#include "gui2_arrowbutton.h"
#include "gui2_spinbox.h"
#include "gui2_label.h"
#include "gui2_panel.h"
#include "soundManager.h"

GuiSpinBox::GuiSpinBox(GuiContainer* owner, string id, float min_value, float max_value, float start_value, unsigned short decimals, float interval, func_t func)
: GuiTextEntry(owner, id, string(start_value)),
  func(func),
  enter_func(nullptr),
  decimals(decimals),
  text_size(30),
  interval(interval),
  min_value(min_value),
  max_value(max_value)
{
    decrement = new GuiArrowButton(this, id + "_DECREMENT", 0, [this]() {
        soundManager->playSound("button.wav");
        applyInterval(-(this->interval));

        // Run callback.
        if (this->func)
        {
            func_t f = this->func;
            f(this->text);
        }
    });
    decrement->setPosition(0, 0, ATopLeft)->setSize(GuiSizeMatchHeight, GuiSizeMax);

    increment = new GuiArrowButton(this, id + "_INCREMENT", 180, [this]() {
        soundManager->playSound("button.wav");
        applyInterval(this->interval);

        // Run callback.
        if (this->func)
        {
            func_t f = this->func;
            f(this->text);
        }
    });
    increment->setPosition(0, 0, ATopRight)->setSize(GuiSizeMatchHeight, GuiSizeMax);

    // Pad text entry from the left by about as much as the text size.
    this->setTextLeftpad(text_size);

    // Populate start_value.
    setValue(start_value);
}

void GuiSpinBox::onDraw(sf::RenderTarget& window)
{
    // Only check value if something's in the box.
    if (text.length() > 0 && text != "." && text != "-" && text != "-.")
    {
        // Disable inc/dec buttons if value is at min/max.
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
    }

    // Draw textbox.
    GuiTextEntry::onDraw(window);
}

bool GuiSpinBox::onKey(sf::Event::KeyEvent key, int unicode)
{
    // Only active when the TextEntry component has focus.

    // Backspace key behavior.
    // Mind that Backspace toggles voice chat!
    if (key.code == sf::Keyboard::BackSpace && text.length() > 0)
    {
        // Remove a character behind the cursor.
        text = text.substr(0, -1);

        // Run callback.
        if (func)
        {
            func_t f = func;
            f(text);
        }

        return true;
    }

    // Enter/Return key behavior: validate and set.
    if (key.code == sf::Keyboard::Return && text.length() > 0)
    {
        // Limit the entered value.
        text = getLimitedString(text);

        // Run enterCallback.
        if (enter_func)
        {
            func_t f = enter_func;
            f(text);
        }

        return true;
    }

    // Up/Right key behavior: increment.
    if ((key.code == sf::Keyboard::Up || key.code == sf::Keyboard::Right) && text.length() > 0)
    {
        soundManager->playSound("button.wav");
        applyInterval(interval);

        // Run callback.
        if (func)
        {
            func_t f = func;
            f(text);
        }

        return true;
    }

    // Down/Left key behavior: decrement.
    if ((key.code == sf::Keyboard::Down || key.code == sf::Keyboard::Left) && text.length() > 0)
    {
        soundManager->playSound("button.wav");
        applyInterval(-interval);

        // Run callback.
        if (func)
        {
            func_t f = func;
            f(text);
        }

        return true;
    }

    // Add to string if key is 0-9, ., or -
    if (unicode > 44 && unicode != 47 && unicode < 58)
    {
        validateTextEntry(unicode);

        // Run callback.
        if (func)
        {
            func_t f = func;
            f(text);
        }

        return true;
    }

    return true;
}

void GuiSpinBox::onFocusLost()
{
    // On loss of focus, limit the string value.
    text = getLimitedString(text);

    // Run callback.
    if (func)
    {
        func_t f = func;
        f(text);
    }

    GuiTextEntry::onFocusLost();
}

void GuiSpinBox::validateTextEntry(int unicode)
{
    if (text.length() == 0 && unicode == 46)
    {
        LOG(DEBUG) << "Can't start spinbox value with a decimal point.";
        text += "0.";
    }
    else if ((text == "." || text == "-" || text == "-.") && (unicode == 45 || unicode == 46))
    {
        LOG(DEBUG) << "Can't start spinbox value with multiple non-numerals.";
    }
    else
    {
        // Anything else works, including multiple decimal and negative signs
        // elsewhere in the string, which are discarded.
        text += string(char(unicode));
    }
}

float GuiSpinBox::getValue()
{
    return stof(text);
}

float GuiSpinBox::getLimitedValue(float value)
{
    // Return a limited value if it exceeds min/max.
    if (value > max_value)
    {
        return max_value;
    }
    else if (value < min_value)
    {
        return min_value;
    }

    // Otherwise, just return the value.
    return value;
}

string GuiSpinBox::getLimitedString(string value)
{
    // If the string isn't empty and doesn't start with a "." ...
    if (value.length() > 0)
    {
        if (value.substr(0, 1) != ".")
        {
            // Return the limited value of the string, as a string.
            return string(getLimitedValue(stof(value)), decimals);
        } else {
            // If it starts with ".", prefix it with a 0.
            return string(getLimitedValue(stof("0" + value)), decimals);
        }
    }
    else
    {
        // If the string is empty, return the minimum value.
        return string(min_value, decimals);
    }
}

GuiSpinBox* GuiSpinBox::setValue(float new_value)
{
    float value = getLimitedValue(new_value);

    // Set the TextEntry's "text" to the value, respecting min/max limits.
    // Set the number of decimals. Round to the nearest integral value if 0.
    if (decimals == 0)
    {
        this->text = string(nearbyint(value), 0);
    }
    else
    {
        this->text = string(value, decimals);
    }

    return this;
}

float GuiSpinBox::getInterval()
{
    return interval;
}

GuiSpinBox* GuiSpinBox::setInterval(float new_interval)
{
    // Set the interval as long as it's greater than 0.
    if (new_interval > 0.0f)
    {
        interval = new_interval;
    }
    else
    {
        LOG(WARNING) << "SpinBox " << id << " interval cannot be 0 or negative: " << interval;
        interval = 0.1f;
    }

    return this;
}

float GuiSpinBox::getMinValue()
{
    return min_value;
}

GuiSpinBox* GuiSpinBox::setMinValue(float new_min_value)
{
    // Set the min value as long as it's smaller than the max value.
    if (new_min_value < max_value)
    {
        min_value = new_min_value;
    }
    else
    {
        LOG(WARNING) << "SpinBox " << id << " minimum value cannot be larger than the maximum value: " << new_min_value;
        min_value = 0.0f;
    }

    // Validate the value against the new min.
    setValue(stof(text));

    return this;
}

float GuiSpinBox::getMaxValue()
{
    return max_value;
}

GuiSpinBox* GuiSpinBox::setMaxValue(float new_max_value)
{
    // Set the max value as long as it's larger than the min value.
    if (new_max_value > min_value)
    {
        max_value = new_max_value;
    }
    else
    {
        LOG(WARNING) << "SpinBox " << id << " maximum value cannot be smaller than the minimum value: " << new_max_value;
        max_value = min_value + 0.1f;
    }

    // Validate the value against the new max.
    setValue(stof(text));

    return this;
}

void GuiSpinBox::applyInterval(float factor)
{
    float modifier = 1.0f;

    // Hold down shift to multiply the interval by 10.
    if (sf::Keyboard::isKeyPressed(sf::Keyboard::LShift)
        || sf::Keyboard::isKeyPressed(sf::Keyboard::RShift))
    {
        modifier = 10.0f;
    }

    // Adjust the value by the factor and modifier.
    setValue(getLimitedValue(getValue() + (factor * modifier)));
}

GuiSpinBox* GuiSpinBox::callback(func_t func)
{
    this->func = func;
    return this;
}

GuiSpinBox* GuiSpinBox::enterCallback(func_t func)
{
    this->enter_func = func;
    return this;
}
