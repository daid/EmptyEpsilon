#ifndef GUI2_SLIDER_H
#define GUI2_SLIDER_H

#include "gui2_element.h"
#include "gui2_label.h"

class GuiThemeStyle;
class GuiBasicSlider : public GuiElement
{
public:
    typedef std::function<void(float value)> func_t;
protected:
    float min_value;
    float max_value;
    float value;
    func_t func;

    const GuiThemeStyle* front_style;
    const GuiThemeStyle* back_style;
public:
    GuiBasicSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func);

    virtual void onDraw(sp::RenderTarget& window) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;

    GuiBasicSlider* setValue(float value);
    GuiBasicSlider* setRange(float min, float max);
    float getValue() const;
};

class GuiSlider : public GuiBasicSlider
{
public:
    typedef std::function<void(float value)> func_t;
protected:
    struct TSnapPoint
    {
        float value;
        float range;
    };
    std::vector<TSnapPoint> snap_points;
    GuiLabel* overlay_label;
    const GuiThemeStyle* tick_style;
public:
    GuiSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func);

    virtual void onDraw(sp::RenderTarget& window) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;

    GuiSlider* setValueSnapped(float value);
    GuiSlider* clearSnapValues();
    GuiSlider* addSnapValue(float value, float range);
    GuiSlider* addOverlay();
};

class GuiSlider2D : public GuiElement
{
public:
public:
    typedef std::function<void(glm::vec2 value)> func_t;
protected:
    struct TSnapPoint
    {
        glm::vec2 value;
        glm::vec2 range;
    };
    glm::vec2 min_value;
    glm::vec2 max_value;
    glm::vec2 value;
    std::vector<TSnapPoint> snap_points;
    func_t func;

    const GuiThemeStyle* front_style;
    const GuiThemeStyle* back_style;
public:
    GuiSlider2D(GuiContainer* owner, string id, glm::vec2 min_value, glm::vec2 max_value, glm::vec2 start_value, func_t func);

    virtual void onDraw(sp::RenderTarget& window) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;

    GuiSlider2D* clearSnapValues();
    GuiSlider2D* addSnapValue(glm::vec2 value, glm::vec2 range);
    GuiSlider2D* setValue(glm::vec2 value);
    glm::vec2 getValue();
};

#endif//GUI2_SLIDER_H
