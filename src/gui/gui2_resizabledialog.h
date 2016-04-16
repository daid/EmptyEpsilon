#ifndef GUI2_RESIZABLE_DIALOG_H
#define GUI2_RESIZABLE_DIALOG_H

#include "gui2_panel.h"

class GuiLabel;
class GuiButton;
class GuiToggleButton;

class GuiResizableDialog : public GuiPanel
{
public:
    GuiResizableDialog(GuiContainer* owner, string id, string title);
    
    virtual void onDraw(sf::RenderTarget& window) override;

    virtual bool onMouseDown(sf::Vector2f position) override;
    virtual void onMouseDrag(sf::Vector2f position) override;
    
    void minimize(bool minimize=true);
    bool isMinimized();
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
    sf::Vector2f click_offset;
    ClickState click_state;
    
    virtual void onClose();
protected:
    sf::Vector2f min_size;
    GuiElement* contents;
};

#endif//GUI2_RESIZABLE_DIALOG_H
