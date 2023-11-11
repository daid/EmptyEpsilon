#ifndef INDICATOR_OVERLAYS_H
#define INDICATOR_OVERLAYS_H

#include "gui/gui2_element.h"

class GuiOverlay;
class GuiPanel;
class GuiLabel;
/**
    * Full screen overlay for shield hit effect
    * Full screen overlay for hull hit effect
    * Full screen overlay for shields low warning
    * Full screen overlay for jump indication
    * Activating the warp/jump post process shaders
    * Pause full screen overlay and text indicator
    * Victory/defeat result
*/
class GuiIndicatorOverlays : public GuiElement
{
private:
    GuiOverlay* shield_hit_overlay;
    GuiOverlay* hull_hit_overlay;
    GuiOverlay* shield_low_warning_overlay;
    GuiOverlay* pause_overlay;
    GuiOverlay* victory_overlay;
    GuiPanel* victory_panel;
    GuiLabel* victory_label;
    bool has_global_message = false;

public:
    GuiIndicatorOverlays(GuiContainer* owner);
    virtual ~GuiIndicatorOverlays();

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;

    void hasGlobalMessage() { has_global_message = true; }
private:
    void drawAlertLevel(sp::RenderTarget& renderer);
};

#endif//INDICATOR_OVERLAYS_H
