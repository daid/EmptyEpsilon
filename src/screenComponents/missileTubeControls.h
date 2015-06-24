#ifndef GUI_MISSILE_TUBE_CONTROLS_H
#define GUI_MISSILE_TUBE_CONTROLS_H

#include "gui/gui2.h"

class GuiMissileTubeControls : public GuiAutoLayout
{
private:
    struct TubeRow {
        GuiAutoLayout* layout;
        GuiButton* load_button;
        GuiButton* fire_button;
        GuiProgressbar* loading_bar;
        GuiLabel* loading_label;
    };
    std::vector<TubeRow> rows;
    GuiToggleButton* load_type_buttons[MW_Count];
    EMissileWeapons load_type;
public:
    GuiMissileTubeControls(GuiContainer* owner, string id);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_MISSILE_TUBE_CONTROLS_H
