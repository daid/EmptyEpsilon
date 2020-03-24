#include "gameGlobalInfo.h"
#include "threatLevelEstimate.h"
#include "spaceObjects/beamEffect.h"
#include "spaceObjects/missiles/missileWeapon.h"

ThreatLevelEstimate::ThreatLevelEstimate()
{
    smoothed_threat_level = 0.0;
    threat_high = false;
    threat_high_func = nullptr;
    threat_low_func = nullptr;
}

ThreatLevelEstimate::~ThreatLevelEstimate()
{
}

void ThreatLevelEstimate::update(float delta)
{
    if (!gameGlobalInfo)
        return;
    
    float max_threat = 0.0;
    float f = delta / threat_drop_off_time;

    // Get the largest threat value among all player ships.
    for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
        max_threat = std::max(max_threat, getThreatFor(gameGlobalInfo->getPlayerShip(n)));

    // Adjust the threat value smoothly over time.
    smoothed_threat_level = ((1.0 - f) * smoothed_threat_level) + (max_threat * f);

    // If the smoothened threat value is high enough, enable the
    // high threat state.
    if (!threat_high && smoothed_threat_level > threat_high_level)
    {
        threat_high = true;
        if (threat_high_func)
            threat_high_func();
    }

    if (threat_high && smoothed_threat_level < threat_low_level) {
        // Don't reduce the threat state until the smoothened threat
        // value is under the low threat threshold.
        threat_high = false;
        if (threat_low_func)
            threat_low_func();
    }
}

float ThreatLevelEstimate::getThreatFor(P<SpaceShip> ship)
{
    // If the object isn't a ship, it doesn't feel threatened.
    if (!ship)
        return 0.0;
    
    float threat = 0.0;

    // If the ship's shields are up, add to the threat rating.
    if (ship->getShieldsActive())
        threat += 200;
    
    // If shields are damaged, increase the threat rating by the amount.
    for(int n=0; n<ship->shield_count; n++)
        threat += ship->shield_max[n] - ship->shield_level[n];

    // If the hull is damaged, increase the threat rating by the amount.
    threat += ship->hull_max - ship->hull_strength;

    // Get all objects within 7U.
    float radius = 7000.0;
    PVector<Collisionable> objectList = CollisionManager::queryArea(ship->getPosition() - sf::Vector2f(radius, radius), ship->getPosition() + sf::Vector2f(radius, radius));

    foreach(Collisionable, obj, objectList)
    {
        P<SpaceShip> other_ship = obj;

        // If the object is a missile or a beam impact, increase the
        // threat rating.
        if (!other_ship || !ship->isEnemy(other_ship))
        {
            if (P<MissileWeapon>(obj))
                threat += 5000.0f;
            if (P<BeamEffect>(obj))
                threat += 5000.0f;
            continue;
        }
        
        // If the object is a ship with shields, and especially if
        // the shields are being hit, increase the threat rating.
        bool is_being_attacked = false;
        float score = 200.0f + other_ship->hull_max;

        for(int n=0; n<other_ship->shield_count; n++)
        {
            score += other_ship->shield_max[n] * 2.0f / float(other_ship->shield_count);
            if (other_ship->shield_hit_effect[n] > 0.0f)
                is_being_attacked = true;
        }

        if (is_being_attacked)
            score += 500.0f;
        
        threat += score;
    }
    
    return threat;
}

void ThreatLevelEstimate::setCallbacks(func_t low, func_t high)
{
    // Trigger functions upon threat state changes.
    threat_low_func = low;
    threat_high_func = high; 
    
    if (threat_high)
    {
        if (threat_high_func)
            threat_high_func();
    }else{
        if (threat_low_func)
            threat_low_func();
    }
}
