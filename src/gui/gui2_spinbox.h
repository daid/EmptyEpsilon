#ifndef GUI2_SPINBOX_H
#define GUI2_SPINBOX_H

#include "gui2_textentry.h"

class GuiArrowButton;

class GuiSpinBox : public GuiTextEntry
{
protected:
    func_t func;
    func_t enter_func;
    unsigned short decimals;
    float text_size;
    float interval;
    float min_value;
    float max_value;
    GuiArrowButton* decrement;
    GuiArrowButton* increment;

    float getLimitedValue(float value);
    string getLimitedString(string value);
    void validateTextEntry(int unicode);
public:
    typedef std::function<void(string text)> func_t;

    GuiSpinBox(GuiContainer* owner, string id, float min_value, float max_value, float start_value, unsigned short decimals, float interval, func_t func);

    virtual void onDraw(sf::RenderTarget& window) override;
    virtual bool onKey(sf::Event::KeyEvent key, int unicode) override;
    virtual void onFocusLost() override;

    void applyInterval(float factor);

    float getValue();
    GuiSpinBox* setValue(float new_value);
    float getInterval();
    GuiSpinBox* setInterval(float interval);
    float getMinValue();
    GuiSpinBox* setMinValue(float min_value);
    float getMaxValue();
    GuiSpinBox* setMaxValue(float max_value);
    bool getDecimals();
    GuiSpinBox* setDecimals(int new_decimals);
    GuiSpinBox* callback(func_t func);
    GuiSpinBox* enterCallback(func_t func);
};

#endif//GUI2_SPINBOX_H
