#include "gui2_arrowbutton.h"
#include "gui2_spinbox.h"
#include "gui2_label.h"
#include "gui2_panel.h"
#include "soundManager.h"

GuiSpinBox::GuiSpinBox(GuiContainer* owner, string id, unsigned short decimals, float interval, func_t func)
: GuiTextEntry(owner, id, string(0.0f)),
  func(func),
  enter_func(nullptr),
  decimals(decimals),
  text_size(30),
  interval(interval),
  min_value(0.0f),
  max_value(10.0f)
{
    decrement = new GuiArrowButton(this, id + "_DECREMENT", 0, [this]() {
        soundManager->playSound("button.wav");

        applyInterval(-1);

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

        applyInterval(1);

        // Run callback.
        if (this->func)
        {
            func_t f = this->func;
            f(this->text);
        }
    });
    increment->setPosition(0, 0, ATopRight)->setSize(GuiSizeMatchHeight, GuiSizeMax);
}

void GuiSpinBox::onDraw(sf::RenderTarget& window)
{
    // Only check value if something's in the box.
    if (text.length() > 0)
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
    if (focus)
    {
        drawStretched(window, rect, "gui/TextEntryBackground.focused", selectColor(colorConfig.text_entry.background));
    }
    else
    {
        drawStretched(window, rect, "gui/TextEntryBackground", selectColor(colorConfig.text_entry.background));
    }

    bool typing_indicator = focus;
    const float blink_rate = 0.530;

    if (blink_clock.getElapsedTime().asSeconds() < blink_rate)
    {
        typing_indicator = false;
    }

    if (blink_clock.getElapsedTime().asSeconds() > blink_rate * 2.0f)
    {
        blink_clock.restart();
    }

    // TODO: Make TextEntry left pad configurable,
    // then replace redundant code starting at // Draw textbox.
    drawText(window, sf::FloatRect(rect.left + rect.height, rect.top, rect.width, rect.height), text + (typing_indicator ? "_" : ""), ACenterLeft, text_size, main_font, selectColor(colorConfig.text_entry.forground));
}

bool GuiSpinBox::onKey(sf::Event::KeyEvent key, int unicode)
{
    // Only active when the TextEntry component has focus.

    // Backspace key behavior.
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

    // Enter/Return key behavior: validate and set
    if (key.code == sf::Keyboard::Return && text.length() > 0)
    {
        // Cap the entered value.
        text = getLimitedString(text);

        // Run enterCallback.
        if (enter_func)
        {
            func_t f = enter_func;
            f(text);
        }

        return true;
    }

    // Up/Right key behavior: increment
    if ((key.code == sf::Keyboard::Up || key.code == sf::Keyboard::Right) && text.length() > 0)
    {
        applyInterval(1);

        return true;
    }

    // Down/Left key behavior: decrement
    if ((key.code == sf::Keyboard::Down || key.code == sf::Keyboard::Left) && text.length() > 0)
    {
        applyInterval(-1);

        return true;
    }

    // Add to string if key is 0-9 or .
    // TODO: Handle negative values
    if ((unicode > 47 && unicode < 58) || (unicode == 46))
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

    LOG(WARNING) << "Key " << unicode << " entered; must be 47-58 (0-9) or 46 (.) only.";
    return true;
}

void GuiSpinBox::onFocusLost()
{
    // On loss of focus, limit the string value.
    text = getLimitedString(text);
    GuiTextEntry::onFocusLost();
}

void GuiSpinBox::validateTextEntry(int unicode)
{
    if (text.length() == 0 && unicode == 46)
    {
        LOG(DEBUG) << "Can't start spinbox value with a decimal point.";
        text += "0.";
    }
    else
    {
        text += string(char(unicode));
    }
}

float GuiSpinBox::getValue()
{
    // TODO: Return stored value instead of converting display text.
    return stof(text);
}

float GuiSpinBox::getLimitedValue(float value)
{
    // Cap the value to minimum and maximum values.
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
    // TODO: Handle negative values
    if (new_min_value < max_value && new_min_value >= 0.0f)
    {
        min_value = new_min_value;
    }
    else
    {
        LOG(WARNING) << "SpinBox " << id << " minimum value cannot be larger than the maximum value or negative: " << new_min_value;
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
    float modified_factor = factor;

    // Hold down shift to multiiply the interval by 10.
    if (sf::Keyboard::isKeyPressed(sf::Keyboard::LShift) || sf::Keyboard::isKeyPressed(sf::Keyboard::RShift))
    {
        modified_factor *= 10.0f;
    }

    // Adjust the value by the interval and factor.
    setValue(getLimitedValue(getValue() + (modified_factor * interval)));
}
