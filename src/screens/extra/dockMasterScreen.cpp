#include "dockMasterScreen.h"

#include "playerInfo.h"
#include "spaceObjects/shipTemplateBasedObject.h"
#include "spaceObjects/playerSpaceship.h"
//#include "screenComponents/shipsLogControl.h"
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

    docks = new GuiListbox(rootLayout, "DOCKS_LIST", [this](int index, string value) {
        selectDock(index);
    });
    docks->setMargins(20, 20, 20, 20)->setSize(COLUMN_WIDTH, GuiElement::GuiSizeMax);
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
    
    GuiAutoLayout *tacticalPanel = new GuiAutoLayout(rootLayout, "TACTICAL_PANEL", GuiAutoLayout::LayoutHorizontalRightToLeft);
    tacticalPanel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    
    // 5U tactical radar with piloting features.
    GuiRadarView *radar = new GuiRadarView(tacticalPanel, "TACTICAL_RADAR", 2000.0, nullptr, my_spaceship);
    radar->setSize(290, 290);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular);
    GuiTractorBeamControl *beam_control = new GuiTractorBeamControl(tacticalPanel, "BEAM_CONFIG");
    beam_control->setSize(290, 290);

    (new GuiCustomShipFunctions(this, dockMaster, "CUSTOM_FUNCTIONS", my_spaceship))->setPosition(20, 550, ATopLeft)->setSize(360, GuiElement::GuiSizeMax);

    mainPanel = new GuiAutoLayout(rootLayout, "TOP_PANEL", GuiAutoLayout::LayoutHorizontalRows);
    mainPanel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    mainPanel->setPosition(0, 0, ATopRight);
    mainPanel->setMargins(20, 20, 20, 20);

    topPanel = new GuiAutoLayout(mainPanel, "TOP_PANEL", GuiAutoLayout::LayoutVerticalTopToBottom);
    topPanel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax / 2.0);
    topPanel->setPosition(0, 0, ATopRight);
//    mainPanel->setMargins(20, 20, 20, 20);

    bottomPanel = new GuiAutoLayout(mainPanel, "BOTTOM_PANEL", GuiAutoLayout::LayoutVerticalTopToBottom);
    bottomPanel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax / 2.0);
    bottomPanel->setPosition(0, 500, ATopRight);

    // Dock actions
    (new GuiLabel(topPanel, "TITLE", "Transfert des drones", 30))
        ->addBackground()
        ->setAlignment(ACenter)
        ->setPosition(0, 0, ABottomCenter)
        ->setSize(GuiElement::GuiSizeMax, 50);

    action_move = new GuiAutoLayout(topPanel, "ACTION_MOVE", GuiAutoLayout::LayoutVerticalColumns);
    action_move->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 50, ATopCenter);
    (new GuiLabel(action_move, "MOVE_DEST_LABEL", "Transfert vers :", 30))->setAlignment(ACenterRight);
    action_move_selector = new GuiSelector(action_move, "MOVE_DEST_SELECTOR", [this](int _idx, string value) {
        if (my_spaceship)
            my_spaceship->commandSetDockMoveTarget(index, value.toInt());
    });

    action_move_button = new GuiButton(action_move, "MOVE_BUTTON", "Transferer", [this]() {
        if (my_spaceship)
            if (my_spaceship->getSystemEffectiveness(SYS_Docks) > 0)
            {
                Dock &dockData = my_spaceship->docks[index];
                P<Cargo> cargo = dockData.getCargo();

                my_spaceship->addToShipLog("Transfert du drone " + cargo->getCallSign(),colorConfig.log_generic);
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

    action_launch = new GuiAutoLayout(topPanel, "ACTION_MOVE", GuiAutoLayout::LayoutVerticalColumns);
    action_launch->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 50, ATopCenter);

    (new GuiLabel(action_launch, "SPACE", " ", 30));
    (new GuiLabel(action_launch, "ACTION_LAUNCH_LABEL", "Lancement du drone :", 30))->setAlignment(ACenterRight)->setMargins(20,20,20,20);
    action_launch_button = new GuiButton(action_launch, "LAUNCH_DRONE_BUTTON", "Lancer drone", [this]() {
        if (my_spaceship)
            if (my_spaceship->getSystemEffectiveness(SYS_Docks) > 0)
            {
                Dock &dockData = my_spaceship->docks[index];
                P<Cargo> cargo = dockData.getCargo();

                my_spaceship->addToShipLog("Lancement du drone " + cargo->getCallSign(),colorConfig.log_generic);
                my_spaceship->commandLaunchCargo(index);
            }
    });
    action_launch_button->setSize(COLUMN_WIDTH, 50);
    (new GuiPowerDamageIndicator(action_launch_button, "DOCKS_DPI", SYS_Docks, ABottomCenter, my_spaceship))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    action_energy = new GuiAutoLayout(topPanel, "ACTION_MOVE", GuiAutoLayout::LayoutVerticalColumns);
    action_energy->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 50, ATopCenter);

    (new GuiLabel(action_energy, "SPACE", " ", 30));
    (new GuiLabel(action_energy, "ACTION_LAUNCH_LABEL", "Controle de l'energie :", 30))->setAlignment(ATopRight)->setMargins(10, 10, 10, 10);

    GuiElement *energyControl = new GuiElement(action_energy, "ENERGY_CONTROL");
    energyControl->setSize(COLUMN_WIDTH, 50);

    energy_slider = new GuiSlider(energyControl, "ENERGY_SLIDER", 0.0, 10.0, 0.0, [this](float value) {
        if (my_spaceship)
        {
            my_spaceship->commandSetDockEnergyRequest(index, value);
            my_spaceship->addToShipLog("Transfert d'energie requis",colorConfig.log_generic);
        }
    });
    energy_slider->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiPowerDamageIndicator(energy_slider, "DOCKS_DPI", SYS_Docks, ABottomCenter, my_spaceship))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    energy_bar = new GuiProgressbar(energy_slider, "ENERGY_BAR", 0.0, 10.0, 0.0);
    energy_bar->setColor(sf::Color(192, 192, 32, 128))->setText("Energie")->setDrawBackground(false)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setMargins(10, 0, 10, 0);

    action_weapons = new GuiAutoLayout(topPanel, "ACTION_WEAPONS", GuiAutoLayout::LayoutVerticalColumns);
//    action_weapons = new GuiAutoLayout(topPanel, "ACTION_WEAPONS", GuiAutoLayout::LayoutVerticalTopToBottom);
    action_weapons->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 50, ATopCenter);
    (new GuiLabel(action_weapons, "ACTION_WEAPONS_LABEL", "Transfert missiles :", 30))->setAlignment(ACenterRight)->setMargins(10, 10, 10, 10);

    table_weapons = new GuiAutoLayout(action_weapons, "TABLE_WEAPONS", GuiAutoLayout::LayoutVerticalTopToBottom);
    table_weapons->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    weapons_layout_label = new GuiAutoLayout(table_weapons, "WEAPONS_LAYOUT_LABEL", GuiAutoLayout::LayoutVerticalColumns);
    weapons_layout_label -> setSize(GuiElement::GuiSizeMax, 40);
    (new GuiLabel(weapons_layout_label, "", "Missile", 20));
    (new GuiLabel(weapons_layout_label, "", "Station", 20));
    (new GuiLabel(weapons_layout_label, "", "Drone", 20));
    (new GuiLabel(weapons_layout_label, "", " ", 20));
    (new GuiLabel(weapons_layout_label, "", " ", 20));

    for(int n=0; n<MW_Count; n++)
    {
//        weapons_layout[n] = new GuiElement(table_weapons, "WEAPONS_LAYOUT");
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
                {
                    my_spaceship->addToShipLog("Transfert de missile impossible. Aucun stock dans la station",colorConfig.log_generic);
                    return;
                }

                if (cargo->getWeaponStorageMax(EMissileWeapons(n)) == cargo->getWeaponStorage(EMissileWeapons(n)))
                {
                    my_spaceship->addToShipLog("Transfert de missile impossible. Stock maximum dans le drone",colorConfig.log_generic);
                    return;
                }

                my_spaceship->addToShipLog("Transfert de 1 " + getMissileWeaponName(EMissileWeapons(n)) + " Vers le drone",colorConfig.log_generic);

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
                {
                    my_spaceship->addToShipLog("Transfert de missile impossible. Aucun stock dans le drone",colorConfig.log_generic);
                    return;
                }

                if (my_spaceship->weapon_storage[n] == my_spaceship->weapon_storage_max[n])
                {
                    my_spaceship->addToShipLog("Transfert de missile impossible. Stock maximum dans la station",colorConfig.log_generic);
                    return;
                }

                my_spaceship->addToShipLog("Transfert de 1 " + getMissileWeaponName(EMissileWeapons(n)) + " vers la station",colorConfig.log_generic);

                my_spaceship->weapon_storage[n] += 1;
                cargo->setWeaponStorage(EMissileWeapons(n), cargo->getWeaponStorage(EMissileWeapons(n)) - 1);
            }
        });
        weapons_stock_m1[n]->setSize(75, 40);

        (new GuiPowerDamageIndicator(weapons_stock_p1[n], "DOCKS_DPI", SYS_Docks, ACenter, my_spaceship))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        (new GuiPowerDamageIndicator(weapons_stock_m1[n], "DOCKS_DPI", SYS_Docks, ACenter, my_spaceship))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    }

    (new GuiLabel(bottomPanel, "SPACE", " ", 30))->setSize(GuiElement::GuiSizeMax, 50);

    droneTitle = new GuiLabel(bottomPanel, "DRONE_TITLE", "Drone x", 30);
    droneTitle->addBackground()
        ->setAlignment(ACenter)
        ->setPosition(0, 0, ATopCenter)
        ->setSize(GuiElement::GuiSizeMax, 50);

    dronePanel = new GuiAutoLayout(bottomPanel, "DRONE_PANEL", GuiAutoLayout::LayoutVerticalColumns);
    dronePanel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 50, ATopRight);

    dronePanel_col1 = new GuiAutoLayout(dronePanel, "DRONE_COL1", GuiAutoLayout::LayoutVerticalTopToBottom);
//    dronePanel_col1->setSize(COLUMN_WIDTH / 1.75, 1000)->setPosition(0, 100, ATopLeft);
    dronePanel_col1->setSize(COLUMN_WIDTH / 2, 1000)->setPosition(0, 100, ATopLeft)->setMargins(10, 10, 10, 10);

    dronePanel_col2 = new GuiAutoLayout(dronePanel, "DRONE_COL2", GuiAutoLayout::LayoutVerticalTopToBottom);
//    dronePanel_col2->setSize(COLUMN_WIDTH / 1.75, 1000)->setPosition(0, 100, ATopCenter);
    dronePanel_col2->setSize(COLUMN_WIDTH / 2, 1000)->setPosition(0, 100, ATopCenter)->setMargins(10, 10, 10, 10);

    dronePanel_col3 = new GuiElement(dronePanel, "DRONE_COL3");
    dronePanel_col3->setSize(GuiElement::GuiSizeMax, 1000)->setPosition(0, 100, ATopRight)->setMargins(10, 10, 10, 10);

    shipCargoInfo = new GuiAutoLayout(dronePanel_col1, "CARGO_INFO", GuiAutoLayout::LayoutVerticalTopToBottom);
    shipCargoInfo->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    cargoInfo = new GuiAutoLayout(dronePanel_col2, "SHIP_CARGO_INFO", GuiAutoLayout::LayoutVerticalTopToBottom);
    cargoInfo->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    model = new GuiRotatingModelView(dronePanel_col3, "MODEL_VIEW", nullptr);
    model->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setMargins(0, -100, 0, 0);

    overlay = new GuiOverlay(this, "OVERLAY", sf::Color(0, 0, 0, 128));
    overlay->setBlocking(true)->setPosition(COLUMN_WIDTH, 100, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    overlay_label = new GuiLabel(overlay, "OVERLAY_LABEL", "Transporting cargo out", 30);
    overlay_label->setPosition(0, 0, ACenter)->setSize(COLUMN_WIDTH, 50);
    distance_bar = new GuiProgressbar(overlay, "DISTANCE_BAR", 0.0, 1.0, 0.0);
    distance_bar->setPosition(0, 50, ACenter)->setSize(COLUMN_WIDTH, 50);
    (new GuiPowerDamageIndicator(distance_bar, "DOCKS_DPI", SYS_Docks, ATopCenter, my_spaceship))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    cancel_move_button = new GuiButton(overlay, "CANCEL_MOVE_BUTTON", "Annuler transfert", [this]() {
        my_spaceship->commandCancelMoveCargo(index);
    });
    cancel_move_button->setPosition(0, 100, ACenter)->setSize(COLUMN_WIDTH, 50);

    selectDock(0);
    model->moveToBack();
    background_crosses->moveToBack();

    //new ShipsLog(this,"docks");
}

void DockMasterScreen::selectDock(int index)
{
    dockTitle->setText(docks->getEntryValue(index));

    this->index = index;
    docks->setSelectionIndex(index);
    auto &dockData = my_spaceship->docks[index];
    action_move->setVisible(true);
    action_launch->setVisible(dockData.dock_type == Dock_Launcher);
    action_energy->setVisible(dockData.dock_type == Dock_Energy);
    action_weapons->setVisible(dockData.dock_type == Dock_Weapons);
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
                string state = " (" + getDockStateName(dockData.state) + ")";
                //string dockName = "d" + std::to_string(n + 1) + "-" + getDockTypeName(dockData.dock_type)[0];
                string dockName = getDockTypeName(dockData.dock_type) + " - " + std::to_string(n + 1);
                docks->setEntryName(n, dockName + state);
                if (n != index)
                    action_move_selector->addEntry(dockName, string(n));
            }
        }

        Dock &dockData = my_spaceship->docks[index];
        P<Cargo> cargo = dockData.getCargo();
        action_move_selector->setSelectionIndex(action_move_selector->indexByValue(string(dockData.move_target_index)));

        switch (dockData.state)
        {
        case Empty:
            model->setModel(nullptr);
            overlay->setVisible(true);
            overlay_label->setText("Vide");
            distance_bar->setVisible(false);
            cancel_move_button->setVisible(false);
            mainPanel->setVisible(false);
            break;
        case MovingIn:
            displayDroneDetails(dockData);
            overlay->setVisible(true);
            overlay_label->setText("Transfert en cours");
            distance_bar->setVisible(true);
            distance_bar->setValue(dockData.current_distance);
            cancel_move_button->setVisible(true);
            mainPanel->setVisible(false);
            break;
        case Docked:
            displayDroneDetails(dockData);
            cancel_move_button->setVisible(false);
            overlay->setVisible(false);
            mainPanel->setVisible(true);
            break;
        case MovingOut:
            displayDroneDetails(dockData);
            overlay->setVisible(true);
            overlay_label->setText("Transfert en cours");
            distance_bar->setVisible(true);
            distance_bar->setValue(dockData.current_distance);
            cancel_move_button->setVisible(true);
            mainPanel->setVisible(false);
            break;
        }
    }
}

void DockMasterScreen::displayDroneDetails(Dock &dockData)
{
    P<Cargo> cargo = dockData.getCargo();

    droneTitle->setVisible(true);
    droneTitle->setText("Drone " + cargo->getCallSign());

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
//        cargoInfoItems[cnt]->setIcon(std::get<0>(e))->setKey(std::get<1>(e))->setValue(std::get<2>(e));
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
//        shipCargoInfoItems[cnt]->setIcon(std::get<0>(e))->setKey(std::get<1>(e))->setValue(std::get<2>(e));
        shipCargoInfoItems[cnt]->setIcon("")->setKey(std::get<1>(e))->setValue(std::get<2>(e));
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
    for(int n = 0; n < MW_Count; n++)
    {
        weapons_stock_cargo[n]->setText(string(cargo->getWeaponStorage(EMissileWeapons(n))) + " / " + string(cargo->getWeaponStorageMax(EMissileWeapons(n))));
        weapons_stock_ship[n]->setText(string(my_spaceship->getWeaponStorage(EMissileWeapons(n))) + " / " + string(my_spaceship->getWeaponStorageMax(EMissileWeapons(n))));
        weapons_stock_m1[n]->setEnable(cargo->getWeaponStorageMax(EMissileWeapons(n)) > 0 && my_spaceship->getWeaponStorageMax(EMissileWeapons(n)) > 0);
        weapons_stock_p1[n]->setEnable(cargo->getWeaponStorageMax(EMissileWeapons(n)) > 0 && my_spaceship->getWeaponStorageMax(EMissileWeapons(n)) > 0);
    }
    model->setModel(cargo->getModel());
}

