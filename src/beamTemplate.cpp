#include "beamTemplate.h"

BeamTemplate::BeamTemplate()
{
    direction = 0;
    range = 0;
    cycle_time = 0;
    damage = 0;
    beam_texture = "beam_orange.png";

    energy_per_beam_fire = 3.0;
    heat_per_beam_fire = 0.02;
}

string BeamTemplate::getBeamTexture()
{
    return beam_texture;
}

void BeamTemplate::setBeamTexture(string texture)
{
    //TODO: Add some more inteligent input checking
    beam_texture = texture;
}

float BeamTemplate::getDirection()
{
    return direction;
}

void BeamTemplate::setDirection(float direction)
{
    // Clamp values
    while(direction < 0)
        direction += 360;
    while(direction > 360)
        direction -= 360;
    this->direction = direction;
}

float BeamTemplate::getArc()
{
    return arc;
}

void BeamTemplate::setArc(float arc)
{
    while(arc < 0)
        arc += 360;
    while(arc > 360)
        arc -=360;
    this->arc = arc;
}

float BeamTemplate::getRange()
{
    return range;
}

void BeamTemplate::setRange(float range)
{
    if(range <= 0)
        this->range = 0.1;
    else
        this->range = range;
}

float BeamTemplate::getCycleTime()
{
    return cycle_time;
}

void BeamTemplate::setCycleTime(float cycle_time)
{
    if(cycle_time <= 0)
        this->cycle_time = 0.1;
    else
        this->cycle_time = cycle_time;
}

float BeamTemplate::getDamage()
{
    return damage;
}

void BeamTemplate::setDamage(float damage)
{
    if(damage < 0)
        this->damage = 0;
    else
        this->damage = damage;
}

float BeamTemplate::getEnergyPerFire()
{
    return energy_per_beam_fire;
}

void BeamTemplate::setEnergyPerFire(float energy)
{
    energy_per_beam_fire = energy;
}

float BeamTemplate::getHeatPerFire()
{
    return heat_per_beam_fire;
}

void BeamTemplate::setHeatPerFire(float heat)
{
    heat_per_beam_fire = heat;
}

BeamTemplate& BeamTemplate::operator=(const BeamTemplate& other)
{
    beam_texture = other.beam_texture;
    direction = other.direction;
    arc = other.arc;
    range = other.range;
    cycle_time = other.cycle_time;
    damage = other.damage;
    energy_per_beam_fire = other.energy_per_beam_fire;
    heat_per_beam_fire = other.heat_per_beam_fire;
    return *this;
}
