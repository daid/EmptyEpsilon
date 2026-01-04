#include "damcon.h"

#include "playerInfo.h"
#include "screenComponents/shieldFreqencySelect.h"
#include "screenComponents/shipInternalView.h"
#include "screenComponents/customShipFunctions.h"
#include "components/hull.h"
#include "i18n.h"

#include "gui/gui2_keyvaluedisplay.h"


DamageControlScreen::DamageControlScreen(GuiContainer* owner)
: GuiOverlay(owner, "DAMCON_SCREEN", colorConfig.background)
{
    (new GuiShipInternalView(this, "SHIP_INTERNAL_VIEW", 48.0f * 1.5f))->setShip(my_spaceship)->setPosition(300, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    auto system_health_layout = new GuiElement(this, "DAMCON_LAYOUT");
    system_health_layout->setPosition(0, 0, sp::Alignment::CenterLeft)->setSize(300, 600)->setAttribute("layout", "vertical");

    hull_display = new GuiKeyValueDisplay(system_health_layout, "HULL", 0.8, tr("damagecontrol", "Hull"), "0%");
    hull_display->setSize(GuiElement::GuiSizeMax, 40);

    for(unsigned int n=0; n<ShipSystem::COUNT; n++)
    {
        system_health[n] = new GuiKeyValueDisplay(system_health_layout, "DAMCON_HEALTH_" + string(n), 0.8, getLocaleSystemName(ShipSystem::Type(n)), "0%");
        system_health[n]->setSize(GuiElement::GuiSizeMax, 40);
    }

    (new GuiCustomShipFunctions(this, CrewPosition::damageControl, ""))->setPosition(-20, 120, sp::Alignment::TopRight)->setSize(250, GuiElement::GuiSizeMax);
}

void DamageControlScreen::onDraw(sp::RenderTarget& renderer)
{
    GuiOverlay::onDraw(renderer);

    if (my_spaceship)
    {
        auto hull = my_spaceship.getComponent<Hull>();
        if (hull) {
            hull_display->setValue(string(int(100 * hull->current / hull->max)) + "%");
            if (hull->current < hull->max / 4.0f)
                hull_display->setBackColor(glm::u8vec4(255, 0, 0, 255));
            else
                hull_display->setBackColor(glm::u8vec4{255,255,255,255});
        }

        for(unsigned int n=0; n<ShipSystem::COUNT; n++)
        {
            auto sys = ShipSystem::get(my_spaceship, ShipSystem::Type(n));
            system_health[n]->setVisible(sys);
            if (sys) {
                system_health[n]->setValue(string(int(sys->health * 100)) + "%");
                if (sys->health < 0)
                    system_health[n]->setBackColor(glm::u8vec4(255, 0, 0, 255));
                else if (sys->health_max < 1.0f)
                    system_health[n]->setBackColor(glm::u8vec4(255, 255, 0, 255));
                else
                    system_health[n]->setBackColor(glm::u8vec4{255,255,255,255});
            }
            
        }
    }
}
