#ifndef GUI_INDICATOR_OVERLAYS_H
#define GUI_INDICATOR_OVERLAYS_H

#include "gui/gui2_element.h"

class GuiOverlay;
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
    GuiLabel* victory_label;
public:
    GuiIndicatorOverlays(GuiContainer* owner);
    virtual ~GuiIndicatorOverlays();
    
    virtual void onDraw(sf::RenderTarget& window);
    
    virtual bool onMouseDown(sf::Vector2f position);
private:
    void drawAlertLevel(sf::RenderTarget& window);
};

#endif//GUI_INDICATOR_OVERLAYS_H
