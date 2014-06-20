#ifndef SHIP_TEMPLATE_H
#define SHIP_TEMPLATE_H

#include <map>
#include "engine.h"

const static int maxBeamWeapons = 16;
const static int maxWeaponTubes = 16;

enum EMissileWeapons
{
    MW_None = -1,
    MW_Homing = 0,
    MW_Nuke,
    MW_Mine,
    MW_EMP,
    MW_Count
};
/* Define script conversion function for the EMissileWeapons enum. */
template<> void convert<EMissileWeapons>::param(lua_State* L, int& idx, EMissileWeapons& es);

class BeamTemplate : public sf::NonCopyable
{
public:
    float arc, direction, range, cycle_time, damage;
};

class ShipTemplate : public PObject
{
    static std::map<string, P<ShipTemplate> > templateMap;

    string name;
public:
    float scale;
    string model, colorTexture, specularTexture, illuminationTexture;
    sf::Vector3f beamPosition[maxBeamWeapons];
    BeamTemplate beams[maxBeamWeapons];
    int weaponTubes;
    float frontShields, rearShields;
    float impulseSpeed, turnSpeed, warpSpeed;
    bool jumpDrive, cloaking;
    int weaponStorage[MW_Count];

    ShipTemplate();
    
    void setName(string name);
    void setScale(float scale) { this->scale = scale; }
    void setMesh(string model, string colorTexture, string specularTexture, string illuminationTexture);
    void setBeamPosition(int index, sf::Vector3f position);
    void setBeam(int index, float arc, float direction, float range, float cycle_time, float damage);
    void setTubes(int amount) { weaponTubes = std::min(maxWeaponTubes, amount); }
    void setShields(float front, float rear) { frontShields = front; rearShields = rear; }
    void setSpeed(float impulse, float turn) { impulseSpeed = impulse; turnSpeed = turn; }
    void setWarpSpeed(float warp) { warpSpeed = warp; }
    void setJumpDrive(bool enabled) { jumpDrive = enabled; }
    void setCloaking(bool enabled) { cloaking = enabled; }
    void setWeaponStorage(EMissileWeapons weapon, int amount) { if (weapon != MW_None) weaponStorage[weapon] = amount; }
public:
    static P<ShipTemplate> getTemplate(string name);
};

#endif//SHIP_TEMPLATE_H
