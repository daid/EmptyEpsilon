#ifndef GUI2_RESIZABLEDIALOG_H
#define GUI2_RESIZABLEDIALOG_H

#include "gui2_panel.h"

class GuiLabel;
class GuiButton;
class GuiToggleButton;

class GuiResizableDialog : public GuiPanel
{
public:
    GuiResizableDialog(GuiContainer* owner, string id, string title);

    virtual void onDraw(sp::RenderTarget& target) override;

    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id) override;

    void minimize(bool minimize=true);
    bool isMinimized() const;
    void setTitle(string title);
private:
    static constexpr float resize_icon_size = 25.0f;
    static constexpr float title_bar_height = 30.0f;

    GuiLabel* title_bar;
    GuiToggleButton* minimize_button;
    GuiButton* close_button;
    bool minimized;
    float original_height;

    enum class ClickState
    {
        None,
        Resize,
        Drag
    };
    glm::vec2 click_offset;
    ClickState click_state;

    virtual void onClose();
protected:
    glm::vec2 min_size;
    GuiElement* contents;
};

#endif//GUI2_RESIZABLEDIALOG_H
