#ifndef DRONE_MASTER_SCREEN_H
#define DRONE_MASTER_SCREEN_H

#include "gui/gui2_overlay.h"
#include "spaceObjects/shipTemplateBasedObject.h"

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
class GuiElement;
class GuiImage;

class Dock;
class DockMasterScreen : public GuiOverlay
{
  private:
    GuiListbox* docks;
    int index = 0;
    GuiLabel *dockTitle;
    GuiLabel *droneTitle;

    GuiAutoLayout *mainPanel;
    GuiAutoLayout *lateralPanel;
    GuiAutoLayout *topPanel;
    GuiAutoLayout *bottomPanel;
    GuiAutoLayout *dronePanel;

    GuiImage* dockImage;
    GuiAutoLayout* action_move;
    GuiAutoLayout* action_launch;
    GuiAutoLayout* action_energy;
    GuiAutoLayout* action_weapons;
    GuiAutoLayout* action_repair;

    GuiAutoLayout* cargoInfo;
    GuiAutoLayout* shipCargoInfo;
    std::vector<GuiKeyValueDisplay*> cargoInfoItems;
    std::vector<GuiKeyValueDisplay*> shipCargoInfoItems;
    GuiRotatingModelView* model;

    GuiElement* energyControl;
    GuiProgressbar *energy_bar;
    GuiSlider *energy_slider;
    GuiKeyValueDisplay *energy_main;
    GuiKeyValueDisplay *energy_cargo;

    GuiAutoLayout *table_weapons;
    GuiAutoLayout *weapons_layout_label;

    GuiAutoLayout *weapons_layout_p1;
    GuiAutoLayout* weapons_layout[MW_Count];
    GuiLabel* weapons_stock_ship[MW_Count];
    GuiLabel* weapons_stock_cargo[MW_Count];
    GuiButton* weapons_stock_p1[MW_Count];
    GuiButton* weapons_stock_m1[MW_Count];

    GuiProgressbar *repair_bar;
    GuiLabel *repair_label;

    GuiAutoLayout* dronePanel_col1;
    GuiAutoLayout* dronePanel_col2;
    GuiElement* dronePanel_col3;

    GuiButton* action_launch_button;
    GuiButton* action_move_button;
    GuiElement* action_move_dest;

    GuiSelector* action_move_selector;
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
#endif //DRONE_MASTER_SCREEN_H
