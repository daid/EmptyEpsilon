#ifndef SHIP_TEMPLATE_H
#define SHIP_TEMPLATE_H

#include <unordered_map>
#include "engine.h"
#include "modelData.h"

const static int max_beam_weapons = 16;
const static int max_weapon_tubes = 16;

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

class SpaceObject;
class ShipTemplate : public PObject
{
    static std::unordered_map<string, P<ShipTemplate> > templateMap;
    string name;
    string description;
public:
    string getName() {return this->name;}
    string getDescription() {return this->description;}

    P<ModelData> model_data;
    /*!
     * Size class is used to check if one ship can dock with another (eg; other ship needs to be way bigger)
     */
    int size_class;
    string default_ai_name;
    BeamTemplate beams[max_beam_weapons];
    int weapon_tubes;
    float tube_load_time;
    float hull;
    float front_shields, rear_shields;
    float impulse_speed, turn_speed, warp_speed;
    float impulse_acceleration;
    bool has_jump_drive, has_cloaking;
    int weapon_storage[MW_Count];
    float weapon_damage_modifier[MW_Count] = {1.0}; // Damage of tube-launched weapons

    std::vector<ShipRoomTemplate> rooms;
    std::vector<ShipDoorTemplate> doors;

    ShipTemplate();

    void setName(string name);
    void setDescription(string description) { this->description = description; }
    void setModel(string model_name) { this->model_data = ModelData::getModel(model_name); }
    void setDefaultAI(string default_ai_name) { this->default_ai_name = default_ai_name; }
    void setSizeClass(int size_class) { this->size_class = size_class; }
    void setMesh(string model, string color_texture, string specular_texture, string illumination_texture);
    void setBeam(int index, float arc, float direction, float range, float cycle_time, float damage);
    void setTubes(int amount, float load_time) { weapon_tubes = std::min(max_weapon_tubes, amount); tube_load_time = load_time; }
    void setHull(float amount) { hull = amount; }
    void setShields(float front, float rear) { front_shields = front; rear_shields = rear; }
    void setSpeed(float impulse, float turn, float acceleration) { impulse_speed = impulse; turn_speed = turn; impulse_acceleration = acceleration; }
    void setWarpSpeed(float warp) { warp_speed = warp; }
    void setJumpDrive(bool enabled) { has_jump_drive = enabled; }
    void setCloaking(bool enabled) { has_cloaking = enabled; }
    void setWeaponStorage(EMissileWeapons weapon, int amount)  { if (weapon != MW_None) weapon_storage[weapon] = amount; }
    void setWeaponDamageModifier( EMissileWeapons weapon, float damage){ if (weapon != MW_None) weapon_damage_modifier[weapon] = damage; }
    void addRoom(sf::Vector2i position, sf::Vector2i size) { rooms.push_back(ShipRoomTemplate(position, size, SYS_None)); }
    void addRoomSystem(sf::Vector2i position, sf::Vector2i size, ESystem system) { rooms.push_back(ShipRoomTemplate(position, size, system)); }
    void addDoor(sf::Vector2i position, bool horizontal) { doors.push_back(ShipDoorTemplate(position, horizontal)); }

    sf::Vector2i interiorSize();
    ESystem getSystemAtRoom(sf::Vector2i position);

    void setCollisionData(P<SpaceObject> object);
public:
    static P<ShipTemplate> getTemplate(string name);
    static std::vector<string> getTemplateNameList();
    static std::vector<string> getPlayerTemplateNameList();
    static std::vector<string> getStationTemplateNameList();
};
string getSystemName(ESystem system);
REGISTER_MULTIPLAYER_ENUM(ESystem);

#endif//SHIP_TEMPLATE_H
