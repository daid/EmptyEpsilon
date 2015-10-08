#include "gameGlobalInfo.h"
#include "threatLevelEstimate.h"
#include "spaceObjects/beamEffect.h"
#include "spaceObjects/missileWeapon.h"

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
    for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
    {
        max_threat = std::max(max_threat, getThreatFor(gameGlobalInfo->getPlayerShip(n)));
    }
    float f = delta / threat_drop_off_time;
    smoothed_threat_level = ((1.0 - f) * smoothed_threat_level) + (max_threat * f);
    
    if (!threat_high && smoothed_threat_level > threat_high_level)
    {
        threat_high = true;
        if (threat_high_func)
            threat_high_func();
    }
        
    if (threat_high && smoothed_threat_level < threat_low_level)
    {
        threat_high = false;
        if (threat_low_func)
            threat_low_func();
    }
}

float ThreatLevelEstimate::getThreatFor(P<SpaceShip> ship)
{
    if (!ship)
        return 0.0;
    
    float threat = 0.0;
    if (ship->shields_active)
        threat += 200;
    
    threat += ship->front_shield_max - ship->front_shield;
    threat += ship->rear_shield_max - ship->rear_shield;
    threat += ship->hull_max - ship->hull_strength;
    
    float radius = 7000.0;
    PVector<Collisionable> objectList = CollisionManager::queryArea(ship->getPosition() - sf::Vector2f(radius, radius), ship->getPosition() + sf::Vector2f(radius, radius));
    foreach(Collisionable, obj, objectList)
    {
        P<SpaceShip> other_ship = obj;
        if (!other_ship || !ship->isEnemy(other_ship))
        {
            if (P<MissileWeapon>(obj))
                threat += 5000.0f;
            if (P<BeamEffect>(obj))
                threat += 5000.0f;
            continue;
        }
        
        float score = 200.0f + other_ship->hull_max + other_ship->front_shield_max + other_ship->rear_shield_max;
        if (other_ship->front_shield_hit_effect || other_ship->rear_shield_hit_effect)
            score += 500.0f;
        
        threat += score;
    }
    
    return threat;
}

void ThreatLevelEstimate::setCallbacks(func_t low, func_t high)
{
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
