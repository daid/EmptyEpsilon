#ifndef GUI2_SPINBOX_H
#define GUI2_SPINBOX_H

#include "gui2_textentry.h"

class GuiArrowButton;

class GuiSpinBox : public GuiTextEntry
{
protected:
    func_t func;
    func_t enter_func;
    float text_size;
    float interval;
    float min_value;
    float max_value;
    bool display_integer;
    EGuiAlign text_alignment;
    GuiArrowButton* decrement;
    GuiArrowButton* increment;
public:
    typedef std::function<void(string text)> func_t;

    GuiSpinBox(GuiContainer* owner, string id, func_t func);

    virtual void onDraw(sf::RenderTarget& window) override;
    virtual bool onKey(sf::Event::KeyEvent key, int unicode) override;

    float getValue();
    GuiSpinBox* setValue(float value);
    float getInterval();
    GuiSpinBox* setInterval(float interval);
    float getMinValue();
    GuiSpinBox* setMinValue(float min_value);
    float getMaxValue();
    GuiSpinBox* setMaxValue(float max_value);
    bool getDisplayInteger();
    GuiSpinBox* setDisplayInteger(bool display_integer);
};

#endif//GUI2_SPINBOX_H
