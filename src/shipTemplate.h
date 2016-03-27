#ifndef SHIP_TEMPLATE_H
#define SHIP_TEMPLATE_H

#include <unordered_map>
#include "engine.h"
#include "modelData.h"

#include "beamTemplate.h"
constexpr static int max_beam_weapons = 16;
constexpr static int max_weapon_tubes = 16;
constexpr static int max_shield_count = 8;

enum EMissileWeapons
{
    MW_None = -1,
    MW_Homing = 0,
    MW_Nuke,
    MW_Mine,
    MW_EMP,
    MW_HVLI,
    MW_Count
};
/* Define script conversion function for the EMissileWeapons enum. */
template<> void convert<EMissileWeapons>::param(lua_State* L, int& idx, EMissileWeapons& es);
template<> int convert<EMissileWeapons>::returnType(lua_State* L, EMissileWeapons es);

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
public:
    enum TemplateType
    {
        Ship,
        PlayerShip,
        Station
    };
    class TubeTemplate
    {
    public:
        float load_time;
        uint32_t type_allowed_mask;
    };
private:
    static std::unordered_map<string, P<ShipTemplate> > templateMap;
    string name;
    string description;
    TemplateType type;
public:
    string getName();
    string getDescription();
    void setType(TemplateType type);
    TemplateType getType();

    P<ModelData> model_data;

    /*!
     * Size class is used to check if one ship can dock with another (eg; other ship needs to be way bigger)
     */
    int size_class;
    float energy_storage_amount;
    string default_ai_name;
    BeamTemplate beams[max_beam_weapons];
    int weapon_tube_count;
    TubeTemplate weapon_tube[max_weapon_tubes];
    float hull;
    int shield_count;
    float shield_level[max_shield_count];
    float impulse_speed, turn_speed, warp_speed;
    float impulse_acceleration;
    bool has_jump_drive, has_cloaking;
    int weapon_storage[MW_Count];

    string radar_trace;

    std::vector<ShipRoomTemplate> rooms;
    std::vector<ShipDoorTemplate> doors;

    ShipTemplate();

    void setName(string name);
    void setDescription(string description);
    void setModel(string model_name);
    void setDefaultAI(string default_ai_name);
    void setSizeClass(int size_class);
    void setMesh(string model, string color_texture, string specular_texture, string illumination_texture);
    void setEnergyStorage(float energy_amount);

    void setBeam(int index, float arc, float direction, float range, float cycle_time, float damage);

    /**
     * Convenience function to set the texture of a beam by index.
     */
    void setBeamTexture(int index, string texture);

    void setTubes(int amount, float load_time);
    void setTubeLoadTime(int index, float load_time);
    void weaponTubeAllowMissle(int index, EMissileWeapons type);
    void weaponTubeDisallowMissle(int index, EMissileWeapons type);
    void setWeaponTubeExclusiveFor(int index, EMissileWeapons type);
    void setHull(float amount) { hull = amount; }
    void setShields(std::vector<float> values);
    void setSpeed(float impulse, float turn, float acceleration);
    void setWarpSpeed(float warp);
    void setJumpDrive(bool enabled);
    void setCloaking(bool enabled);
    void setWeaponStorage(EMissileWeapons weapon, int amount);
    void addRoom(sf::Vector2i position, sf::Vector2i size);
    void addRoomSystem(sf::Vector2i position, sf::Vector2i size, ESystem system);
    void addDoor(sf::Vector2i position, bool horizontal);
    void setRadarTrace(string trace);

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

/* Define script conversion function for the ShipTemplate::TemplateType enum. */
template<> void convert<ShipTemplate::TemplateType>::param(lua_State* L, int& idx, ShipTemplate::TemplateType& tt);

#endif//SHIP_TEMPLATE_H
