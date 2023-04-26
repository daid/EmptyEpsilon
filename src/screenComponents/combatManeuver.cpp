#include <i18n.h>
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "components/maneuveringthrusters.h"
#include "combatManeuver.h"
#include "powerDamageIndicator.h"
#include "snapSlider.h"

#include "gui/gui2_progressbar.h"

GuiCombatManeuver::GuiCombatManeuver(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    charge_bar = new GuiProgressbar(this, id + "_CHARGE", 0.0, 1.0, 0.0);
    charge_bar->setColor(glm::u8vec4(192, 192, 192, 64));
    charge_bar->setPosition(0, 0, sp::Alignment::BottomCenter)->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(charge_bar, "CHARGE_LABEL", tr("Combat maneuver"), 20))->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    slider = new GuiSnapSlider2D(this, id + "_STRAFE", glm::vec2(-1.0, 1.0), glm::vec2(1.0, 0.0), glm::vec2(0.0, 0.0), [](glm::vec2 value) {
        if (my_spaceship)
        {
            my_player_info->commandCombatManeuverBoost(value.y);
            my_player_info->commandCombatManeuverStrafe(value.x);
        }
    });
    slider->setPosition(0, -50, sp::Alignment::BottomCenter)->setSize(GuiElement::GuiSizeMax, 165);

    (new GuiPowerDamageIndicator(slider, id + "_STRAFE_INDICATOR", ShipSystem::Type::Maneuver, sp::Alignment::CenterLeft))->setPosition(0, 0, sp::Alignment::BottomLeft)->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiPowerDamageIndicator(slider, id + "_BOOST_INDICATOR", ShipSystem::Type::Impulse, sp::Alignment::BottomLeft))->setPosition(0, -50, sp::Alignment::BottomLeft)->setSize(GuiElement::GuiSizeMax, 50);
}

void GuiCombatManeuver::onUpdate()
{
    setVisible(my_spaceship.hasComponent<CombatManeuveringThrusters>());

    if (isVisible())
    {
        float strafe = keys.helms_combat_right.getValue() - keys.helms_combat_left.getValue();
        float boost = std::max(0.0f, keys.helms_combat_boost.getValue());
        if (strafe != 0.0f || hotkey_strafe_active)
            setStrafeValue(strafe);
        hotkey_strafe_active = strafe != 0.0f;
        if (boost > 0.0f || hotkey_boost_active)
            setBoostValue(boost);
        hotkey_boost_active = boost > 0.0f;
    }
}

void GuiCombatManeuver::onDraw(sp::RenderTarget& target)
{
    if (my_spaceship)
    {
        auto thrusters = my_spaceship.getComponent<CombatManeuveringThrusters>();
        if (thrusters) {
            charge_bar->setValue(thrusters->charge)->show();
            slider->show();
        } else {
            charge_bar->hide();
            slider->hide();
        }
    }
}

void GuiCombatManeuver::setBoostValue(float value)
{
    slider->setValue(glm::vec2(slider->getValue().x, value));
    my_player_info->commandCombatManeuverBoost(value);
}

void GuiCombatManeuver::setStrafeValue(float value)
{
    slider->setValue(glm::vec2(value, slider->getValue().y));
    my_player_info->commandCombatManeuverStrafe(value);
}
