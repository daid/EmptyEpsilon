#ifndef SHIP_TEMPLATE_H
#define SHIP_TEMPLATE_H

#include <unordered_map>
#include <unordered_set>
#include <optional>
#include "engine.h"
#include "modelData.h"
#include "scriptInterfaceMagic.h"
#include "multiplayer.h"
#include "components/shipsystem.h"
#include "components/beamweapon.h"

#include "beamTemplate.h"
#include "missileWeaponData.h"

constexpr static int max_weapon_tubes = 16;
constexpr static int max_shield_count = 8;


/* Define script conversion function for the ESystem enum. */
template<> void convert<ShipSystem::Type>::param(lua_State* L, int& idx, ShipSystem::Type& es);

class ShipRoomTemplate
{
public:
    glm::ivec2 position;
    glm::ivec2 size;
    ShipSystem::Type system;

    ShipRoomTemplate(glm::ivec2 position, glm::ivec2 size, ShipSystem::Type system) : position(position), size(size), system(system) {}
};
class ShipDoorTemplate
{
public:
    glm::ivec2 position;
    bool horizontal;

    ShipDoorTemplate(glm::ivec2 position, bool horizontal) : position(position), horizontal(horizontal) {}
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
        float direction;
        EMissileSizes size;
    };
private:
    static std::unordered_map<string, P<ShipTemplate> > templateMap;
    string name;
    string locale_name = "";
    string description;
    string class_name;
    string sub_class_name;
    TemplateType type;
public:
    string getName();
    string getLocaleName();
    string getDescription();
    string getClass();
    string getSubClass();
    void setType(TemplateType type);
    TemplateType getType();

    P<ModelData> model_data;
    bool visible{true}; //Should be visible in science/gm/other player facing locations. Invisible templates exists for backwards compatibility.

    /*!
     * List of ship classes that can dock with this ship. (only used for ship2ship docking)
     */
    std::unordered_set<string> external_dock_classes;
    std::unordered_set<string> internal_dock_classes;
    bool shares_energy_with_docked;
    bool repair_docked;
    bool restocks_scan_probes;
    bool restocks_missiles_docked;
    bool can_scan = true;
    bool can_hack = true;
    bool can_dock = true;
    bool can_combat_maneuver = true;
    bool can_self_destruct = true;
    bool can_launch_probe = true;

    float energy_storage_amount;
    int repair_crew_count;
    string default_ai_name;
    BeamTemplate beams[max_beam_weapons];
    int weapon_tube_count;
    TubeTemplate weapon_tube[max_weapon_tubes];
    float hull;
    int shield_count;
    float shield_level[max_shield_count];
    float impulse_speed, impulse_reverse_speed, turn_speed, warp_speed;
    float impulse_acceleration, impulse_reverse_acceleration;
    float combat_maneuver_boost_speed;
    float combat_maneuver_strafe_speed;
    bool has_jump_drive, has_cloaking;
    float jump_drive_min_distance;
    float jump_drive_max_distance;
    int weapon_storage[MW_Count];

    string radar_trace;
    float long_range_radar_range;
    float short_range_radar_range;
    string impulse_sound_file;

    std::vector<ShipRoomTemplate> rooms;
    std::vector<ShipDoorTemplate> doors;

    ShipTemplate();

    void setName(string name);
    void setLocaleName(string name);
    void setClass(string class_name, string sub_class_name);
    void setDescription(string description);
    void hidden() { visible = false; }
    void setModel(string model_name);
    void setDefaultAI(string default_ai_name);
    void setDockClasses(const std::vector<string>& classes);
    void setExternalDockClasses(const std::vector<string>& classes);
    void setInternalDockClasses(const std::vector<string>& classes);
    void setSharesEnergyWithDocked(bool enabled);
    void setRepairDocked(bool enabled);
    void setRestocksScanProbes(bool enabled);
    void setRestocksMissilesDocked(bool enabled);
    void setCanScan(bool enabled) { can_scan = enabled; }
    void setCanHack(bool enabled) { can_hack = enabled; }
    void setCanDock(bool enabled) { can_dock = enabled; }
    void setCanCombatManeuver(bool enabled) { can_combat_maneuver = enabled; }
    void setCanSelfDestruct(bool enabled) { can_self_destruct = enabled; }
    void setCanLaunchProbe(bool enabled) { can_launch_probe = enabled; }
    void setMesh(string model, string color_texture, string specular_texture, string illumination_texture);
    void setEnergyStorage(float energy_amount);
    void setRepairCrewCount(int amount);

    void setBeam(int index, float arc, float direction, float range, float cycle_time, float damage);
    void setBeamWeapon(int index, float arc, float direction, float range, float cycle_time, float damage);
    void setBeamWeaponTurret(int index, float arc, float direction, float rotation_rate);

    /**
     * Convenience function to set the texture of a beam by index.
     */
    void setBeamTexture(int index, string texture);
    void setBeamWeaponEnergyPerFire(int index, float energy) { if (index < 0 || index >= max_beam_weapons) return; return beams[index].setEnergyPerFire(energy); }
    void setBeamWeaponHeatPerFire(int index, float heat) { if (index < 0 || index >= max_beam_weapons) return; return beams[index].setHeatPerFire(heat); }

    void setTubes(int amount, float load_time);
    void setTubeLoadTime(int index, float load_time);
    void weaponTubeAllowMissle(int index, EMissileWeapons type);
    void weaponTubeDisallowMissle(int index, EMissileWeapons type);
    void setWeaponTubeExclusiveFor(int index, EMissileWeapons type);
    void setTubeSize(int index, EMissileSizes size);

    void setTubeDirection(int index, float direction);
    void setHull(float amount) { hull = amount; }
    void setShields(const std::vector<float>& values);
    void setSpeed(float impulse, float turn, float acceleration, std::optional<float> reverse_speed, std::optional<float> reverse_acceleration);
    void setCombatManeuver(float boost, float strafe);
    void setWarpSpeed(float warp);
    void setJumpDrive(bool enabled);
    void setJumpDriveRange(float min, float max) { jump_drive_min_distance = min; jump_drive_max_distance = max; }
    void setCloaking(bool enabled);
    void setWeaponStorage(EMissileWeapons weapon, int amount);
    void addRoom(glm::ivec2 position, glm::ivec2 size);
    void addRoomSystem(glm::ivec2 position, glm::ivec2 size, ShipSystem::Type system);
    void addDoor(glm::ivec2 position, bool horizontal);
    void setRadarTrace(string trace);
    void setLongRangeRadarRange(float range);
    void setShortRangeRadarRange(float range);
    void setImpulseSoundFile(string sound);

    P<ShipTemplate> copy(string new_name);

    glm::ivec2 interiorSize();
    ShipSystem::Type getSystemAtRoom(glm::ivec2 position);

    void setCollisionData(P<SpaceObject> object);
public:
    static P<ShipTemplate> getTemplate(string name);
    static std::vector<string> getAllTemplateNames();
    static std::vector<string> getTemplateNameList(TemplateType type);
};
string getSystemName(ShipSystem::Type system);
string getLocaleSystemName(ShipSystem::Type system);
REGISTER_MULTIPLAYER_ENUM(ShipSystem::Type);

/* Define script conversion function for the ShipTemplate::TemplateType enum. */
template<> void convert<ShipTemplate::TemplateType>::param(lua_State* L, int& idx, ShipTemplate::TemplateType& tt);
#endif//SHIP_TEMPLATE_H
