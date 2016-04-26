#ifndef BEAM_TEMPLATE_H
#define BEAM_TEMPLATE_H

#include "SFML/System/NonCopyable.hpp"

#include "stringImproved.h"

class BeamTemplate : public sf::NonCopyable
{
public:
    BeamTemplate();


    string getBeamTexture();

    void setBeamTexture(string texture);

    /**
     * Beam weapons are 'arc-ed' weapons, the direction is the center of the arc.
     * Will always return values between 0 and 360
     */
    float getDirection();

    /**
     * Set the direction of the beam weapon.
     */
    void setDirection(float direction);

    float getArc();
    void setArc(float arc);

    float getRange();
    void setRange(float range);

    float getCycleTime();
    void setCycleTime(float cycle_time);

    float getDamage();
    void setDamage(float damage);

    float getEnergyPerFire();
    void setEnergyPerFire(float energy);

    float getHeatPerFire();
    void setHeatPerFire(float heat);
    
    BeamTemplate& operator=(const BeamTemplate& other);

protected:
    string beam_texture;
    float direction; //Value between 0 and 360 (degrees)
    float arc; //Value between 0 and 360
    float range; // value greater than 0
    float cycle_time; // Value greater than 0
    float damage;
    float energy_per_beam_fire;
    float heat_per_beam_fire;
};

#endif //BEAM_TEMPLATE_H
