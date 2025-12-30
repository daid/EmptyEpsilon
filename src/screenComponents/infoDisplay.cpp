#include "infoDisplay.h"
#include "i18n.h"
#include "featureDefs.h"
#include "engine.h"
#include "components/reactor.h"
#include "components/collision.h"
#include "components/shields.h"
#include "components/health.h"
#include "components/hull.h"
#include "components/coolant.h"
#include "playerInfo.h"

static string toNearbyIntString(float value)
{
    return string(int(nearbyint(value)));
}

EnergyInfoDisplay::EnergyInfoDisplay(GuiContainer* owner, const string& id, float div_distance, bool show_delta)
: GuiKeyValueDisplay(owner, id, div_distance, tr("Energy"), ""), show_delta(show_delta)
{
    setIcon("gui/icons/energy")->setTextSize(20);
}

void EnergyInfoDisplay::onUpdate()
{
    auto reactor = my_spaceship.getComponent<Reactor>();
    setVisible(reactor);
    if (reactor) {
        if (show_delta) {
            // Update the energy usage.
            if (previous_energy_measurement == 0.0f)
            {
                previous_energy_level = reactor->energy;
                previous_energy_measurement = engine->getElapsedTime();
            }else{
                if (previous_energy_measurement != engine->getElapsedTime())
                {
                    float delta_t = engine->getElapsedTime() - previous_energy_measurement;
                    float delta_e = reactor->energy - previous_energy_level;
                    float delta_e_per_second = delta_e / delta_t;
                    average_energy_delta = average_energy_delta * 0.99f + delta_e_per_second * 0.01f;

                    previous_energy_level = reactor->energy;
                    previous_energy_measurement = engine->getElapsedTime();
                }
            }

            setValue(toNearbyIntString(reactor->energy) + " (" + tr("{energy}/min").format({{"energy", toNearbyIntString(average_energy_delta * 60.0f)}}) + ")");
        } else {
            setValue(toNearbyIntString(reactor->energy));
        }
        if (reactor->energy < 100.0f)
            setBackColor(glm::u8vec4(255, 0, 0, 255));
        else
            setBackColor(glm::u8vec4{255,255,255,255});
    }
}

HeadingInfoDisplay::HeadingInfoDisplay(GuiContainer* owner, const string& id, float div_distance)
: GuiKeyValueDisplay(owner, id, div_distance, tr("Heading"), "")
{
    setIcon("gui/icons/heading")->setTextSize(20);
}

void HeadingInfoDisplay::onUpdate()
{
    auto transform = my_spaceship.getComponent<sp::Transform>();
    setVisible(transform);
    if (transform) {
        auto rotation = transform->getRotation() - 270.0f;
        while(rotation < 0) rotation += 360.0f;
        while(rotation > 360.0f) rotation -= 360.0f;
        setValue(string(rotation, 1));
    }
}

VelocityInfoDisplay::VelocityInfoDisplay(GuiContainer* owner, const string& id, float div_distance)
: GuiKeyValueDisplay(owner, id, div_distance, tr("Speed"), "")
{
    setIcon("gui/icons/speed")->setTextSize(20);
}

void VelocityInfoDisplay::onUpdate()
{
    auto physics = my_spaceship.getComponent<sp::Physics>();
    setVisible(physics);
    if (physics) {
        float velocity = glm::length(physics->getVelocity()) / 1000 * 60;
        setValue(tr("{value} {unit}/min").format({{"value", string(velocity, 1)}, {"unit", DISTANCE_UNIT_1K}}));
    }
}

HullInfoDisplay::HullInfoDisplay(GuiContainer* owner, const string& id, float div_distance)
: GuiKeyValueDisplay(owner, id, div_distance, tr("health","Hull"), "")
{
    setIcon("gui/icons/hull")->setTextSize(20);
}

void HullInfoDisplay::onUpdate()
{
    // Show Health as Hull, and only if the entity also has Hull.
    auto health = my_spaceship.getComponent<Health>();
    if (health && my_spaceship.hasComponent<Hull>())
    {
        setValue(toNearbyIntString(100.0f * health->current / health->max) + "%");
        if (health->current < health->max / 4.0f)
            setBackColor(glm::u8vec4(255, 0, 0, 255));
        else
            setBackColor(glm::u8vec4{255,255,255,255});
    }
}

ShieldsInfoDisplay::ShieldsInfoDisplay(GuiContainer* owner, const string& id, float div_distance, int shield_index)
: GuiKeyValueDisplay(owner, id, div_distance, tr("Shields"), ""), shield_index(shield_index)
{
    if (shield_index == 0)
        setIcon("gui/icons/shields-fore");
    else if (shield_index == 1)
        setIcon("gui/icons/shields-aft");
    else
        setIcon("gui/icons/shields");
    setTextSize(20);
}

void ShieldsInfoDisplay::onUpdate()
{
    auto shields = my_spaceship.getComponent<Shields>();
    if (shield_index == -1) {
        if (shields && shields->entries.size() > 0) {
            string shields_value = string(shields->entries[0].percentage()) + "%";
            if (shields->entries.size() > 1)
                shields_value += " " + string(shields->entries[1].percentage()) + "%";
            setValue(shields_value);
            show();
        } else {
            hide();
        }
    } else {
        if (shields && int(shields->entries.size()) > shield_index) {
            setValue(string(shields->entries[shield_index].percentage()) + "%");
            show();
        } else {
            hide();
        }
    }
}


CoolantInfoDisplay::CoolantInfoDisplay(GuiContainer* owner, const string& id, float div_distance)
: GuiKeyValueDisplay(owner, id, div_distance, tr("total","Coolant"), "")
{
    setIcon("gui/icons/coolant");
    setTextSize(20);
}

void CoolantInfoDisplay::onUpdate()
{
    auto coolant = my_spaceship.getComponent<Coolant>();
    setVisible(coolant);
    if (coolant) {
        setValue(toNearbyIntString(coolant->max * 100.0f / coolant->max_coolant_per_system) + "%");
    }
}
