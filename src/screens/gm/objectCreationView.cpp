#include "objectCreationView.h"
#include "GMActions.h"
#include "factionInfo.h"
#include "shipTemplate.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_listbox.h"


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
    GuiListbox* listbox = new GuiListbox(box, "CREATE_SHIPS", [this](int index, string value)
    {
        setCreateScript("CpuShip():setRotation(random(0, 360)):setFactionId(" + string(faction_selector->getSelectionIndex()) + "):setTemplate(\"" + value + "\"):orderRoaming()");
    });
    listbox->setTextSize(20)->setButtonHeight(30)->setPosition(-20, 20, ATopRight)->setSize(300, 460);
    for(string template_name : template_names)
    {
        listbox->addEntry(template_name, template_name);
    }
    
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
