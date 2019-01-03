#ifndef DOCK_MASTER_SCREEN_H
#define DOCK_MASTER_SCREEN_H

#include "gui/gui2_overlay.h"
#include "gui/gui2_autolayout.h"
#include "spaceObjects/shipTemplateBasedObject.h"

class GuiToggleButton;
class GuiPanel;
class GuiSlider;
class GuiButton;
class GuiLabel;
class GuiAutoLayout;
class GuiEntryList;
class GuiSelector;
class GuiProgressbar;
class GuiKeyValueDisplay;
class GuiListbox;
class GuiRotatingModelView;
class GuiOverlay;
class Dock;

class GuiTractorBeamControl : public GuiAutoLayout
{
private:
    GuiSelector* mode_slector;
    GuiSlider* arc_slider;
    GuiSlider* direction_slider;
    GuiSlider* range_slider;
public:
    GuiTractorBeamControl(GuiContainer* owner, string id);
    virtual void onDraw(sf::RenderTarget& window) override;
};

class DockMasterScreen : public GuiOverlay
{
  private:

    GuiListbox* docks;
    int index = 0;
    GuiLabel *title;
    GuiAutoLayout *cargoView;
    GuiAutoLayout* cargoInfo;
    std::vector<GuiKeyValueDisplay*> cargoInfoItems;
    GuiRotatingModelView* model;

    GuiToggleButton* tractor_beam_switch;

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