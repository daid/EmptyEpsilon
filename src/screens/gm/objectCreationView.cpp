#include "objectCreationView.h"
#include "GMActions.h"
#include "factionInfo.h"
#include "shipTemplate.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_selector.h"


GuiObjectCreationView::GuiObjectCreationView(GuiContainer* owner, func_t enterCreateMode)
: GuiOverlay(owner, "OBJECT_CREATE_SCREEN", sf::Color(0, 0, 0, 128)), enterCreateMode(enterCreateMode)
{
    GuiPanel* box = new GuiPanel(this, "FRAME");
    box->setPosition(0, 0, ACenter)->setSize(1000, 500);

    faction_selector = new GuiSelector(box, "FACTION_SELECTOR", nullptr);
    for(P<FactionInfo> info : factionInfo)
        faction_selector->addEntry(info->getLocaleName(), info->getName());
    faction_selector->setSelectionIndex(0);
    faction_selector->setPosition(20, 20, ATopLeft)->setSize(300, 50);

    player_cpu_selector = new GuiSelector(box, "NPC_PC_SELECTOR", [this](int index, string)
    {
        if (index==1)
        {
            cpu_ship_listbox->hide();
            player_ship_listbox->show();
        }
        else
        {
            cpu_ship_listbox->show();
            player_ship_listbox->hide();
        }
    });
    player_cpu_selector->addEntry("cpu ship","cpu ship");
    player_cpu_selector->addEntry("player ship","player ship");
    player_cpu_selector->setSelectionIndex(0);
    player_cpu_selector->setPosition(20, 70, ATopLeft)->setSize(300, 50);

    float y = 20;
    std::vector<string> template_names = ShipTemplate::getTemplateNameList(ShipTemplate::Station);
    std::sort(template_names.begin(), template_names.end());
    for(string template_name : template_names)
    {
        (new GuiButton(box, "CREATE_STATION_" + template_name, template_name, [this, template_name]() {
            setCreateScript("SpaceStation():setRotation(random(0, 360)):setFactionId(" + string(faction_selector->getSelectionIndex()) + "):setTemplate(\"" + template_name + "\")");
        }))->setTextSize(20)->setPosition(-350, y, ATopRight)->setSize(300, 30);
        y += 30;
    }
    
    (new GuiButton(box, "CREATE_ARTIFACT", "Artifact", [this]() {
        setCreateScript("Artifact()");
    }))->setTextSize(20)->setPosition(-350, y, ATopRight)->setSize(300, 30);
    y += 30;
    (new GuiButton(box, "CREATE_WARP_JAMMER", "Warp Jammer", [this]() {
        setCreateScript("WarpJammer():setRotation(random(0, 360)):setFactionId(" + string(faction_selector->getSelectionIndex()) + ")");
    }))->setTextSize(20)->setPosition(-350, y, ATopRight)->setSize(300, 30);
    y += 30;
    (new GuiButton(box, "CREATE_MINE", "Mine", [this]() {
        setCreateScript("Mine():setFactionId(" + string(faction_selector->getSelectionIndex()) + ")");
    }))->setTextSize(20)->setPosition(-350, y, ATopRight)->setSize(300, 30);
    y += 30;
    // Default supply drop values copied from scripts/supply_drop.lua
    (new GuiButton(box, "CREATE_SUPPLY_DROP", "Supply Drop", [this]() {
        setCreateScript("SupplyDrop():setFactionId(" + string(faction_selector->getSelectionIndex()) + "):setEnergy(500):setWeaponStorage('Nuke', 1):setWeaponStorage('Homing', 4):setWeaponStorage('Mine', 2):setWeaponStorage('EMP', 1)");
    }))->setTextSize(20)->setPosition(-350, y, ATopRight)->setSize(300, 30);
    y += 30;
    (new GuiButton(box, "CREATE_ASTEROID", "Asteroid", [this]() {
        setCreateScript("Asteroid()");
    }))->setTextSize(20)->setPosition(-350, y, ATopRight)->setSize(300, 30);
    y += 30;
    (new GuiButton(box, "CREATE_VISUAL_ASTEROID", "Visual Asteroid", [this]() {
        setCreateScript("VisualAsteroid()");
    }))->setTextSize(20)->setPosition(-350, y, ATopRight)->setSize(300, 30);
    y += 30;
    (new GuiButton(box, "CREATE_PLANET", "Planet", [this]() {
        setCreateScript("Planet()");
    }))->setTextSize(20)->setPosition(-350, y, ATopRight)->setSize(300, 30);
    y += 30;
    (new GuiButton(box, "CREATE_BLACKHOLE", "BlackHole", [this]() {
        setCreateScript("BlackHole()");
    }))->setTextSize(20)->setPosition(-350, y, ATopRight)->setSize(300, 30);
    y += 30;
    (new GuiButton(box, "CREATE_NEBULA", "Nebula", [this]() {
        setCreateScript("Nebula()");
    }))->setTextSize(20)->setPosition(-350, y, ATopRight)->setSize(300, 30);
    y += 30;
    (new GuiButton(box, "CREATE_WORMHOLE", "Worm Hole", [this]() {
        setCreateScript("WormHole()");
    }))->setTextSize(20)->setPosition(-350, y, ATopRight)->setSize(300, 30);
    y += 30;
    y = 20;

    template_names = ShipTemplate::getTemplateNameList(ShipTemplate::Ship);
    std::sort(template_names.begin(), template_names.end());
    cpu_ship_listbox = new GuiListbox(box, "CREATE_SHIPS", [this](int index, string value)
    {
        setCreateScript("CpuShip():setRotation(random(0, 360)):setFactionId(" + string(faction_selector->getSelectionIndex()) + "):setTemplate(\"" + value + "\"):orderRoaming()");
    });
    cpu_ship_listbox->setTextSize(20)->setButtonHeight(30)->setPosition(-20, 20, ATopRight)->setSize(300, 460);
    for(string template_name : template_names)
    {
        cpu_ship_listbox->addEntry(template_name, template_name);
    }

    auto player_template_names = ShipTemplate::getTemplateNameList(ShipTemplate::PlayerShip);
    std::sort(player_template_names.begin(), player_template_names.end());
    player_ship_listbox = new GuiListbox(box, "CREATE_PLAYER_SHIPS", [this](int index, string value)
    {
        setCreateScript("PlayerSpaceship():setFactionId(" + string(faction_selector->getSelectionIndex()) + "):setTemplate(\"" + value + "\")");
    });
    player_ship_listbox->setTextSize(20)->setButtonHeight(30)->setPosition(-20, 20, ATopRight)->setSize(300, 460);
    for (const auto template_name : player_template_names)
    {
        player_ship_listbox->addEntry(template_name, template_name);
    }
    player_ship_listbox->hide();
    
    (new GuiButton(box, "CLOSE_BUTTON", "Cancel", [this]() {
        create_script = "";
        this->hide();
    }))->setPosition(20, -20, ABottomLeft)->setSize(300, 50);
}

bool GuiObjectCreationView::onMouseDown(sf::Vector2f position)
{   //Catch clicks.
    return true;
}

void GuiObjectCreationView::setCreateScript(string script)
{
    create_script = script;
    enterCreateMode();
}

void GuiObjectCreationView::createObject(sf::Vector2f position)
{
    if (create_script == "")
        return;
    gameMasterActions->commandRunScript(create_script + ":setPosition("+string(position.x)+","+string(position.y)+")");
}
