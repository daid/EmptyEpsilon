#ifndef MISSILE_TUBE_CONTROLS_H
#define MISSILE_TUBE_CONTROLS_H

#include "gui/gui2_autolayout.h"
#include "missileWeaponData.h"

class GuiButton;
class GuiProgressbar;
class GuiLabel;
class GuiToggleButton;

class GuiMissileTubeControls : public GuiAutoLayout
{
private:
    struct TubeRow {
        GuiElement* layout;
        GuiButton* load_button;
        GuiButton* fire_button;
        GuiProgressbar* loading_bar;
        GuiLabel* loading_label;
    };
    std::vector<TubeRow> rows;
    class TypeRow {
    public:
        GuiElement* layout;
        GuiToggleButton* button;
    };
    TypeRow load_type_rows[MW_Count];
    EMissileWeapons load_type;
    bool manual_aim;
    float missile_target_angle;
public:
    GuiMissileTubeControls(GuiContainer* owner, string id);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;

    void setMissileTargetAngle(float angle);
    float getMissileTargetAngle();

    void setManualAim(bool manual);
    bool getManualAim();

private:
    void selectMissileWeapon(EMissileWeapons type);
};

#endif//MISSILE_TUBE_CONTROLS_H
