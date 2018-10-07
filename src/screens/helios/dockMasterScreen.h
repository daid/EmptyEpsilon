#ifndef DOCK_MASTER_SCREEN_H
#define DOCK_MASTER_SCREEN_H

#include "gui/gui2_overlay.h"
#include "spaceObjects/shipTemplateBasedObject.h"

class GuiPanel;
class GuiSlider;
class GuiButton;
class GuiLabel;
class GuiAutoLayout;
class GuiSelector;
class GuiProgressbar;
class GuiKeyValueDisplay;
class GuiListbox;
class GuiRotatingModelView;
class GuiOverlay;
class Dock;
class DockMasterScreen : public GuiOverlay
{
  private:

    GuiListbox* docks;
    int index = 0;
    GuiLabel *title;
    GuiAutoLayout *droneDetails;
    GuiRotatingModelView* model;
    GuiKeyValueDisplay *type;
    GuiKeyValueDisplay *callsign;
    GuiKeyValueDisplay *energy;

    GuiProgressbar *energy_bar;
    GuiSlider *energy_slider;
    GuiButton* launch_button;

    GuiSelector* move_dest_selector;
    GuiOverlay* overlay;
    GuiLabel *overlay_label;
    GuiProgressbar *distance_bar;
    GuiButton *cancel_move_button;

  public:
    DockMasterScreen(GuiContainer *owner);

    void onDraw(sf::RenderTarget &window) override;
    private:
    void selectDock(int index);
  private:
    void displayDroneDetails(Dock &dockData);
};
#endif //DOCK_MASTER_SCREEN_H