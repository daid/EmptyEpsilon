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

enum ESystem
{
    SYS_None = -1,
    SYS_Reactor = 0,
    SYS_BeamWeapons,
    SYS_MissileSystem,
    SYS_Maneuver,
    SYS_Impulse,
    SYS_Warp,
    SYS_JumpDrive,
    SYS_FrontShield,
    SYS_RearShield,
    SYS_COUNT
};
/* Define script conversion function for the ESystem enum. */
template<> void convert<ESystem>::param(lua_State* L, int& idx, ESystem& es);

class BeamTemplate : public sf::NonCopyable
{
public:
    float arc, direction, range, cycle_time, damage;
};
class ShipRoomTemplate
{
public:
    sf::Vector2i position;
    sf::Vector2i size;
    ESystem system;
    
    ShipRoomTemplate(sf::Vector2i position, sf::Vector2i size, ESystem system) : position(position), size(size), system(system) {}
};
class ShipDoorTemplate
{
public:
    sf::Vector2i position;
    bool horizontal;

    ShipDoorTemplate(sf::Vector2i position, bool horizontal) : position(position), horizontal(horizontal) {}
};
class EngineEmitorTemplate
{
public:
    sf::Vector3f position;
    sf::Vector3f color;
    float scale;

    EngineEmitorTemplate(sf::Vector3f position, sf::Vector3f color, float scale) : position(position), color(color), scale(scale) {}
};

class ShipTemplate : public PObject
{
    static std::map<string, P<ShipTemplate> > templateMap;
public:
    string name;
    string description;

    float scale;
    float radius;
    sf::Vector2f collision_box;
    int size_class; //The size class defines which ships can define to which, you can dock to anything a size class bigger then you.
    string model, colorTexture, specularTexture, illuminationTexture;
    sf::Vector3f renderOffset;
    sf::Vector3f beamPosition[maxBeamWeapons];
    BeamTemplate beams[maxBeamWeapons];
    int weapon_tubes;
    float tube_load_time;
    sf::Vector2f tubePosition[maxWeaponTubes];
    float hull;
    float frontShields, rearShields;
    float impulseSpeed, turnSpeed, warpSpeed;
    float impulseAcceleration;
    bool jumpDrive, cloaking;
    int weapon_storage[MW_Count];
    
    std::vector<ShipRoomTemplate> rooms;
    std::vector<ShipDoorTemplate> doors;
    std::vector<EngineEmitorTemplate> engine_emitors;

    ShipTemplate();
    
    void setName(string name);
    void setDescription(string description) { this->description = description; }
    void setScale(float scale) { this->scale = scale; }
    void setRenderOffset(sf::Vector3f v) { this->renderOffset = v; }
    void setRadius(float radius) { this->radius = radius; }
    void setCollisionBox(sf::Vector2f collision_box) { this->collision_box = collision_box; }
    void setSizeClass(int size_class) { this->size_class = size_class; }
    void setMesh(string model, string colorTexture, string specularTexture, string illuminationTexture);
    void setBeamPosition(int index, sf::Vector3f position);
    void setBeam(int index, float arc, float direction, float range, float cycle_time, float damage);
    void setTubePosition(int index, sf::Vector2f position);
    void setTubes(int amount, float load_time) { weapon_tubes = std::min(maxWeaponTubes, amount); tube_load_time = load_time; }
    void setHull(float amount) { hull = amount; }
    void setShields(float front, float rear) { frontShields = front; rearShields = rear; }
    void setSpeed(float impulse, float turn) { impulseSpeed = impulse; turnSpeed = turn; }
    void setWarpSpeed(float warp) { warpSpeed = warp; }
    void setJumpDrive(bool enabled) { jumpDrive = enabled; }
    void setCloaking(bool enabled) { cloaking = enabled; }
    void setWeaponStorage(EMissileWeapons weapon, int amount) { if (weapon != MW_None) weapon_storage[weapon] = amount; }
    void addRoom(sf::Vector2i position, sf::Vector2i size) { rooms.push_back(ShipRoomTemplate(position, size, SYS_None)); }
    void addRoomSystem(sf::Vector2i position, sf::Vector2i size, ESystem system) { rooms.push_back(ShipRoomTemplate(position, size, system)); }
    void addDoor(sf::Vector2i position, bool horizontal) { doors.push_back(ShipDoorTemplate(position, horizontal)); }
    void addEngineEmitor(sf::Vector3f position, sf::Vector3f color, float scale) { engine_emitors.push_back(EngineEmitorTemplate(position, color, scale)); }
    
    sf::Vector2i interiorSize();
    ESystem getSystemAtRoom(sf::Vector2i position);
public:
    static P<ShipTemplate> getTemplate(string name);
    static std::vector<string> getTemplateNameList();
    static std::vector<string> getPlayerTemplateNameList();
};
string getSystemName(ESystem system);
REGISTER_MULTIPLAYER_ENUM(ESystem);

#endif//SHIP_TEMPLATE_H
