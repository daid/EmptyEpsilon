#pragma once

#include "gui/gui2_overlay.h"

class GuiFrequencyCurve;
class GuiKeyValueDisplay;
class GuiLabel;
class GuiRotatingModelView;
class GuiProgressbar;
class GuiScanningDialog;
class GuiSelector;
class GuiScrollText;

class ScannerScreen : public GuiOverlay
{
private:
    GuiLabel* label;
    GuiRotatingModelView* mesh_viewer;
    GuiProgressbar* progress;
    GuiScanningDialog* dialog;

    GuiSelector* sidebar_selector;
    GuiElement* right_sidebar;
    GuiElement* left_sidebar;
    GuiLabel* info_target;
    GuiKeyValueDisplay* info_callsign;
    GuiKeyValueDisplay* info_distance;
    GuiKeyValueDisplay* info_heading;
    GuiKeyValueDisplay* info_relspeed;
    GuiKeyValueDisplay* info_faction;
    GuiKeyValueDisplay* info_type;
    GuiKeyValueDisplay* info_shields;
    GuiKeyValueDisplay* info_hull;
    GuiScrollText* info_description;

    GuiLabel* info_systems;
    GuiKeyValueDisplay* info_system[ShipSystem::COUNT];
    GuiFrequencyCurve* info_shield_frequency;
    GuiFrequencyCurve* info_beam_frequency;

    sp::ecs::Entity last_target;
public:
    ScannerScreen(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& renderer) override;
};
