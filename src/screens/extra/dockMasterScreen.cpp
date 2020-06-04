#include "dockMasterScreen.h"

#include "playerInfo.h"
#include "shipTemplate.h"
#include "spaceObjects/shipTemplateBasedObject.h"
#include "spaceObjects/playerSpaceship.h"
#include "screenComponents/customShipFunctions.h"
#include "screenComponents/tractorBeamControl.h"
#include "screenComponents/radarView.h"

#include "gui/gui2_listbox.h"
#include "gui/gui2_autolayout.h"
#include "gui/gui2_element.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_button.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_image.h"
#include "screenComponents/powerDamageIndicator.h"

#include "screenComponents/rotatingModelView.h"

const int ROW_SIZE = 4;
const int ROW_HEIGHT = 200;
const int BOX_WIDTH = 290;
const int COLUMN_WIDTH = 400;

DockMasterScreen::DockMasterScreen(GuiContainer *owner)
    : GuiOverlay(owner, "DOCK_MASTER_SCREEN", colorConfig.background)
{
    GuiOverlay *background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", sf::Color::White);
    background_crosses->setTextureTiled("gui/BackgroundCrosses");

    GuiAutoLayout *rootLayout = new GuiAutoLayout(this, "ROOT_LAYOUT", GuiAutoLayout::LayoutHorizontalLeftToRight);
    rootLayout->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, ATopLeft);
    
    lateralPanel = new GuiAutoLayout(rootLayout, "LATERAL_PANEL", GuiAutoLayout::LayoutVerticalTopToBottom);
    lateralPanel->setSize(COLUMN_WIDTH, GuiElement::GuiSizeMax);
    lateralPanel->setPosition(0, 0, ATopLeft);
    lateralPanel->setMargins(20, 20, 20, 20);
    
    (new GuiLabel(lateralPanel, "TITLE", "docks list", 30))
        ->addBackground()
        ->setAlignment(ACenter)
        ->setPosition(0, 0, ABottomCenter)
        ->setSize(GuiElement::GuiSizeMax, 50);

    docks = new GuiListbox(lateralPanel, "DOCKS_LIST", [this](int index, string value) {
        selectDock(index);
    });
    docks->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    docks->setPosition(0, 0, ATopLeft);

    // the index in the button list is assumed to equal the index of the dock
    for (int n = 0; n < max_docks_count; n++)
    {
        if (my_spaceship->docks[n].dock_type != Dock_Disabled)
        {
            string state = my_spaceship ? " (" + getDockStateName(my_spaceship->docks[n].state) + ")" : "";
            docks->addEntry("dock-" + std::to_string(n + 1) + state, "dock-" + std::to_string(n + 1) + " " + getDockTypeName(my_spaceship->docks[n].dock_type));
        }
    }

    (new GuiCustomShipFunctions(this, dockMaster, "CUSTOM_FUNCTIONS", my_spaceship))->setPosition(20, 550, ATopLeft)->setSize(360, GuiElement::GuiSizeMax);

    mainPanel = new GuiAutoLayout(rootLayout, "TOP_PANEL", GuiAutoLayout::LayoutHorizontalRows);
    mainPanel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    mainPanel->setPosition(0, 0, ATopRight);
    mainPanel->setMargins(20, 20, 20, 20);

    topPanel = new GuiAutoLayout(mainPanel, "TOP_PANEL", GuiAutoLayout::LayoutVerticalTopToBottom);
    topPanel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax / 2.0);
    topPanel->setPosition(0, 0, ATopRight);

    bottomPanel = new GuiAutoLayout(mainPanel, "BOTTOM_PANEL", GuiAutoLayout::LayoutVerticalTopToBottom);
    bottomPanel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax / 2.0);
    bottomPanel->setPosition(0, 500, ATopRight);

    // Dock actions
    (new GuiLabel(topPanel, "TITLE", "Dock management", 30))
        ->addBackground()
        ->setAlignment(ACenter)
        ->setPosition(0, 0, ABottomCenter)
        ->setSize(GuiElement::GuiSizeMax, 50);

    action_move = new GuiAutoLayout(topPanel, "ACTION_MOVE", GuiAutoLayout::LayoutVerticalColumns);
    action_move->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 50, ATopCenter);
    (new GuiLabel(action_move, "MOVE_DEST_LABEL", "Deliver to :", 30))->setAlignment(ACenterRight);
    action_move_selector = new GuiSelector(action_move, "MOVE_DEST_SELECTOR", [this](int _idx, string value) {
        if (my_spaceship)
            my_spaceship->commandSetDockMoveTarget(index, value.toInt());
    });

    action_move_button = new GuiButton(action_move, "MOVE_BUTTON", "Deliver", [this]() {
        if (my_spaceship)
            if (my_spaceship->getSystemEffectiveness(SYS_Docks) > 0)
            {
                Dock &dockData = my_spaceship->docks[index];
                P<Cargo> cargo = dockData.getCargo();
                my_spaceship->commandMoveCargo(index);
            }
    });
    action_move_button->setSize(COLUMN_WIDTH, 40);
    (new GuiPowerDamageIndicator(action_move_button, "DOCKS_DPI", SYS_Docks, ATopCenter, my_spaceship))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiLabel(topPanel, "SPACE", " ", 30))->setSize(GuiElement::GuiSizeMax, 50);

    dockTitle = new GuiLabel(topPanel, "TITLE", "Dock x", 30);
    dockTitle->addBackground()
        ->setAlignment(ACenter)
        ->setPosition(0, 0, ABottomCenter)
        ->setSize(GuiElement::GuiSizeMax, 50);
        
    dockImage = new GuiImage(this, "ACTION_LAUNCH_ICON", "");
    dockImage->setSize(400, 400)->setPosition(-50, -90, ACenter);
    dockImage->setColor(sf::Color(128, 128, 128, 100));

    action_launch = new GuiAutoLayout(topPanel, "ACTION_MOVE", GuiAutoLayout::LayoutVerticalColumns);
    action_launch->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 50, ATopCenter);

    (new GuiLabel(action_launch, "SPACE", " ", 30));
    (new GuiLabel(action_launch, "ACTION_LAUNCH_LABEL", "Launch :", 30))->setAlignment(ACenterRight)->setMargins(20,20,20,20);
    action_launch_button = new GuiButton(action_launch, "LAUNCH_DRONE_BUTTON", "Launch", [this]() {
        if (my_spaceship)
            if (my_spaceship->getSystemEffectiveness(SYS_Docks) > 0)
            {
                Dock &dockData = my_spaceship->docks[index];
                P<Cargo> cargo = dockData.getCargo();
                my_spaceship->commandLaunchCargo(index);
            }
    });
    action_launch_button->setSize(COLUMN_WIDTH, 50);
    (new GuiPowerDamageIndicator(action_launch_button, "DOCKS_DPI", SYS_Docks, ABottomCenter, my_spaceship))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    action_energy = new GuiAutoLayout(topPanel, "ACTION_MOVE", GuiAutoLayout::LayoutVerticalColumns);
    action_energy->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 50, ATopCenter);

    (new GuiLabel(action_energy, "SPACE", " ", 30));
    (new GuiLabel(action_energy, "ACTION_ENERGY_LABEL", "Energy control :", 30))->setAlignment(ATopRight)->setMargins(10, 10, 10, 10);

    GuiElement *energyControl = new GuiElement(action_energy, "ENERGY_CONTROL");
    energyControl->setSize(COLUMN_WIDTH, 50);

    energy_slider = new GuiSlider(energyControl, "ENERGY_SLIDER", 0.0, 10.0, 0.0, [this](float value) {
        if (my_spaceship)
            my_spaceship->commandSetDockEnergyRequest(index, value);
    });
    energy_slider->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiPowerDamageIndicator(energy_slider, "DOCKS_DPI", SYS_Docks, ABottomCenter, my_spaceship))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    energy_bar = new GuiProgressbar(energy_slider, "ENERGY_BAR", 0.0, 10.0, 0.0);
    energy_bar->setColor(sf::Color(192, 192, 32, 128))->setText("Energy")->setDrawBackground(false)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setMargins(10, 0, 10, 0);

    energy_main = new GuiKeyValueDisplay(energyControl, "ENERGY_MAIN", 0.45, "Energy Main", "");
    energy_main->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 50, ATopRight);
    energy_cargo = new GuiKeyValueDisplay(energyControl, "ENERGY_CARGO", 0.45, "Energy Cargo", "");
    energy_cargo->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 100, ATopRight);

    action_weapons = new GuiAutoLayout(topPanel, "ACTION_WEAPONS", GuiAutoLayout::LayoutVerticalColumns);
    action_weapons->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 50, ATopCenter);

    table_weapons = new GuiAutoLayout(action_weapons, "TABLE_WEAPONS", GuiAutoLayout::LayoutVerticalTopToBottom);
    table_weapons->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    weapons_layout_label = new GuiAutoLayout(table_weapons, "WEAPONS_LAYOUT_LABEL", GuiAutoLayout::LayoutVerticalColumns);
    weapons_layout_label -> setSize(GuiElement::GuiSizeMax, 40);
    (new GuiLabel(weapons_layout_label, "", "Missiles", 20));
    (new GuiLabel(weapons_layout_label, "", "Main", 20));
    (new GuiLabel(weapons_layout_label, "", "Cargo", 20));
    (new GuiLabel(weapons_layout_label, "", " ", 20));
    (new GuiLabel(weapons_layout_label, "", " ", 20));

    for(int n=0; n<MW_Count; n++)
    {
        weapons_layout[n] = new GuiAutoLayout(table_weapons, "WEAPONS_LAYOUT", GuiAutoLayout::LayoutVerticalColumns);
        weapons_layout[n]->setSize(GuiElement::GuiSizeMax, 40);

        (new GuiLabel(weapons_layout[n], "", getMissileWeaponName(EMissileWeapons(n)), 20))->setSize(75, 30);

        weapons_stock_ship[n] = new GuiLabel(weapons_layout[n],"","0/20",20);
        weapons_stock_ship[n]->setPosition(75,0)->setSize(75, 30);
        weapons_stock_cargo[n] = new GuiLabel(weapons_layout[n],"","0/20",20);
        weapons_stock_cargo[n]->setPosition(150,0)->setSize(75, 30);

        weapons_stock_p1[n] = new GuiButton(weapons_layout[n],"","+ 1", [this, n]() {
            if (my_spaceship)
            {
                Dock &dockData = my_spaceship->docks[index];
                P<Cargo> cargo = dockData.getCargo();

                if (my_spaceship->getSystemEffectiveness(SYS_Docks) <= 0)
                    return;

                if (my_spaceship->weapon_storage[n] <= 0)
                    return;

                if (cargo->getWeaponStorageMax(EMissileWeapons(n)) == cargo->getWeaponStorage(EMissileWeapons(n)))
                    return;

                my_spaceship->weapon_storage[n] -= 1;
                cargo->setWeaponStorage(EMissileWeapons(n), cargo->getWeaponStorage(EMissileWeapons(n)) + 1);
            }
        });
        weapons_stock_p1[n]->setSize(75, 40);

        weapons_stock_m1[n] = new GuiButton(weapons_layout[n],"","- 1", [this,n]() {
            if (my_spaceship)
            {
                Dock &dockData = my_spaceship->docks[index];
                P<Cargo> cargo = dockData.getCargo();

                if (my_spaceship->getSystemEffectiveness(SYS_Docks) <= 0)
                    return;

                if (cargo->getWeaponStorage(EMissileWeapons(n)) <= 0)
                    return;

                if (my_spaceship->weapon_storage[n] == my_spaceship->weapon_storage_max[n])
                    return;

                my_spaceship->weapon_storage[n] += 1;
                cargo->setWeaponStorage(EMissileWeapons(n), cargo->getWeaponStorage(EMissileWeapons(n)) - 1);
            }
        });
        weapons_stock_m1[n]->setSize(75, 40);

        (new GuiPowerDamageIndicator(weapons_stock_p1[n], "DOCKS_DPI", SYS_Docks, ACenter, my_spaceship))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        (new GuiPowerDamageIndicator(weapons_stock_m1[n], "DOCKS_DPI", SYS_Docks, ACenter, my_spaceship))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    }
    
    action_repair = new GuiAutoLayout(topPanel, "ACTION_REPAIR", GuiAutoLayout::LayoutVerticalColumns);
    action_repair->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 50, ATopCenter);
    GuiElement *repairControl = new GuiElement(action_repair, "REPAIR_CONTROL");
    repairControl->setSize(COLUMN_WIDTH, 50);
    repair_bar = new GuiProgressbar(repairControl, "REPAIR_BAR", 0.0, 1.0, 0.0);
    repair_bar->setPosition(0, 50, ACenter)->setSize(COLUMN_WIDTH, 50);
    repair_label = new GuiLabel(repair_bar, "REPAIR_LABEL", "", 30);
    repair_label->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiLabel(bottomPanel, "SPACE", " ", 30))->setSize(GuiElement::GuiSizeMax, 50);

    droneTitle = new GuiLabel(bottomPanel, "DRONE_TITLE", "Drone x", 30);
    droneTitle->addBackground()
        ->setAlignment(ACenter)
        ->setPosition(0, 0, ATopCenter)
        ->setSize(GuiElement::GuiSizeMax, 50);

    dronePanel = new GuiAutoLayout(bottomPanel, "DRONE_PANEL", GuiAutoLayout::LayoutVerticalColumns);
    dronePanel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 50, ATopRight);

    dronePanel_col1 = new GuiAutoLayout(dronePanel, "DRONE_COL1", GuiAutoLayout::LayoutVerticalTopToBottom);
    dronePanel_col1->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 100, ATopLeft)->setMargins(10, 10, 10, 10);

    dronePanel_col2 = new GuiAutoLayout(dronePanel, "DRONE_COL2", GuiAutoLayout::LayoutVerticalTopToBottom);
    dronePanel_col2->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 100, ATopCenter)->setMargins(10, 10, 10, 10);

    dronePanel_col3 = new GuiAutoLayout(dronePanel, "DRONE_COL3", GuiAutoLayout::LayoutVerticalTopToBottom);
    dronePanel_col3->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, ATopRight)->setMargins(10, 10, 10, 10);

    shipCargoInfo = new GuiAutoLayout(dronePanel_col1, "CARGO_INFO", GuiAutoLayout::LayoutVerticalTopToBottom);
    shipCargoInfo->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    cargoInfo = new GuiAutoLayout(dronePanel_col2, "SHIP_CARGO_INFO", GuiAutoLayout::LayoutVerticalTopToBottom);
    cargoInfo->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    model = new GuiRotatingModelView(dronePanel_col3, "MODEL_VIEW", nullptr);
    model->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    overlay = new GuiOverlay(this, "OVERLAY", sf::Color(0, 0, 0, 0));
    overlay->setBlocking(true)->setPosition(COLUMN_WIDTH, 100, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    overlay_label = new GuiLabel(overlay, "OVERLAY_LABEL", "Transporting cargo out", 30);
    overlay_label->setPosition(0, 0, ACenter)->setSize(COLUMN_WIDTH, 50);
    distance_bar = new GuiProgressbar(overlay, "DISTANCE_BAR", 0.0, 1.0, 0.0);
    distance_bar->setPosition(0, 50, ACenter)->setSize(COLUMN_WIDTH, 50);
    (new GuiPowerDamageIndicator(distance_bar, "DOCKS_DPI", SYS_Docks, ATopCenter, my_spaceship))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    cancel_move_button = new GuiButton(overlay, "CANCEL_MOVE_BUTTON", "Cancel deliver", [this]() {
        my_spaceship->commandCancelMoveCargo(index);
    });
    cancel_move_button->setPosition(0, 100, ACenter)->setSize(COLUMN_WIDTH, 50);

    selectDock(0);
    //model->moveToBack();
    //background_crosses->moveToBack();
}

void DockMasterScreen::selectDock(int index)
{
    dockTitle->setText(docks->getEntryValue(index));

    this->index = index;
    docks->setSelectionIndex(index);
    auto &dockData = my_spaceship->docks[index];
    action_move->setVisible(true);
    dockImage->setTextureName(getDockTypeIcon(dockData.dock_type));
    action_launch->setVisible(dockData.dock_type == Dock_Launcher);
    action_energy->setVisible(dockData.dock_type == Dock_Energy);
    action_weapons->setVisible(dockData.dock_type == Dock_Weapons);
    action_repair->setVisible(dockData.dock_type == Dock_Repair);
}

void DockMasterScreen::onDraw(sf::RenderTarget &window)
{
    GuiOverlay::onDraw(window);
    if (my_spaceship)
    {
        action_move_selector->setOptions({});
        for (int n = 0; n < max_docks_count; n++)
        {
            Dock &dockData = my_spaceship->docks[n];
            if (dockData.dock_type != Dock_Disabled)
            {
                string dockType = getDockTypeName(dockData.dock_type);
                string dockNumber = std::to_string(n + 1);
                string state = getDockStateName(dockData.state);
                docks->setEntryName(n, dockType + " - " + dockNumber + " (" + state + ")");
                if (n != index)
                    action_move_selector->addEntry(dockType + " - " + dockNumber, string(n));
            }
        }

        Dock &dockData = my_spaceship->docks[index];
        P<Cargo> cargo = dockData.getCargo();
        action_move_selector->setSelectionIndex(action_move_selector->indexByValue(string(dockData.move_target_index)));
        
        action_move_button->setEnable(dockData.state == Docked);
        action_move_selector->setEnable(dockData.state == Docked);
        action_launch_button->setEnable(dockData.state == Docked);
        energy_slider->setEnable(dockData.state == Docked);
        repair_bar->setVisible(dockData.state == Docked);
        
        for(int n = 0; n < MW_Count; n++)
        {
            weapons_stock_m1[n]->setEnable(dockData.state == Docked);
            weapons_stock_p1[n]->setEnable(dockData.state == Docked);
        }

        switch (dockData.state)
        {
        case Empty:
            model->setModel(nullptr);
            overlay->setVisible(true);
            overlay_label->setText("");
            distance_bar->setVisible(false);
            cancel_move_button->setVisible(false);
            mainPanel->setVisible(true);
            topPanel->setVisible(true);
            bottomPanel->setVisible(false);
            dockImage->setVisible(true);
            break;
        case MovingIn:
            displayDroneDetails(dockData);
            overlay->setVisible(true);
            overlay_label->setText("Incoming cargo");
            distance_bar->setVisible(true);
            distance_bar->setValue(dockData.current_distance);
            cancel_move_button->setVisible(true);
            mainPanel->setVisible(false);
            topPanel->setVisible(true);
            bottomPanel->setVisible(false);
            dockImage->setVisible(false);
            break;
        case Docked:
            displayDroneDetails(dockData);
            cancel_move_button->setVisible(false);
            overlay->setVisible(false);
            mainPanel->setVisible(true);
            topPanel->setVisible(true);
            bottomPanel->setVisible(true);
            dockImage->setVisible(true);
            break;
        case MovingOut:
            displayDroneDetails(dockData);
            overlay->setVisible(true);
            overlay_label->setText("Outcoming cargo");
            distance_bar->setVisible(true);
            distance_bar->setValue(dockData.current_distance);
            cancel_move_button->setVisible(true);
            mainPanel->setVisible(false);
            topPanel->setVisible(true);
            bottomPanel->setVisible(false);
            dockImage->setVisible(false);
            break;
        }
    }
}

void DockMasterScreen::displayDroneDetails(Dock &dockData)
{
    P<Cargo> cargo = dockData.getCargo();

    droneTitle->setVisible(true);
    droneTitle->setText("Cargo: " + cargo->getCallSign());

    unsigned int cnt = 0;
    for(std::tuple<string, string, string> e : cargo->Cargo::getEntries())
    {
        if (cnt == cargoInfoItems.size())
        {
            cargoInfoItems.push_back(new GuiKeyValueDisplay(cargoInfo, "INFO_" + string(cnt), 0.5, "", ""));
            cargoInfoItems[cnt]->setSize(GuiElement::GuiSizeMax, 40);
        }else{
            cargoInfoItems[cnt]->show();
        }
        cargoInfoItems[cnt]->setIcon("")->setKey(std::get<1>(e))->setValue(std::get<2>(e));
        cnt++;
    }
    while(cnt < cargoInfoItems.size())
    {
        cargoInfoItems[cnt]->hide();
        cnt++;
    }

    cnt = 0;
    for(std::tuple<string, string, string> e : cargo->getEntries())
    {
        if (cnt == shipCargoInfoItems.size())
        {
            shipCargoInfoItems.push_back(new GuiKeyValueDisplay(shipCargoInfo, "INFO_" + string(cnt), 0.5, "", ""));
            shipCargoInfoItems[cnt]->setSize(GuiElement::GuiSizeMax, 40);
        }else{
            shipCargoInfoItems[cnt]->show();
        }
        shipCargoInfoItems[cnt]->setIcon("")->setKey(std::get<1>(e))->setValue(std::get<2>(e));
        // Check if it is a Drone or a Ship
        if (std::get<1>(e) == "type")
            droneTitle->setText(std::get<2>(e) + " : " + cargo->getCallSign());
        cnt++;
    }
    while(cnt < shipCargoInfoItems.size())
    {
        shipCargoInfoItems[cnt]->hide();
        cnt++;
    }
    
    energy_bar->setValue(cargo->getEnergy());
    energy_bar->setRange(cargo->getMinEnergy(), cargo->getMaxEnergy());
    energy_slider->setRange(cargo->getMinEnergy(), cargo->getMaxEnergy());
    energy_slider->setValue(dockData.energy_request);
    energy_cargo->setValue(string(int(cargo->getEnergy())) + " / " + string(int(cargo->getMaxEnergy())));
    if (my_spaceship)
        energy_main->setValue(string(int(my_spaceship->energy_level)) + " / " + string(int(my_spaceship->max_energy_level))); 
    
    float health = cargo->getHealth() / cargo->getMaxHealth();
    repair_bar->setValue(health);
    if (health == 1.0)
        repair_label->setText("Repair finished");
    else
        repair_label->setText("Repairing...");
        
    for(int n = 0; n < MW_Count; n++)
    {
        weapons_stock_cargo[n]->setText(string(cargo->getWeaponStorage(EMissileWeapons(n))) + " / " + string(cargo->getWeaponStorageMax(EMissileWeapons(n))));
        weapons_stock_ship[n]->setText(string(my_spaceship->getWeaponStorage(EMissileWeapons(n))) + " / " + string(my_spaceship->getWeaponStorageMax(EMissileWeapons(n))));
        weapons_stock_m1[n]->setEnable(cargo->getWeaponStorageMax(EMissileWeapons(n)) > 0 && my_spaceship->getWeaponStorageMax(EMissileWeapons(n)) > 0);
        weapons_stock_p1[n]->setEnable(cargo->getWeaponStorageMax(EMissileWeapons(n)) > 0 && my_spaceship->getWeaponStorageMax(EMissileWeapons(n)) > 0);
    }
    model->setModel(cargo->getModel());
}

