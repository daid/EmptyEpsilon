#include "shipTemplate.h"
#include "spaceObjects/spaceObject.h"
#include "mesh.h"

#include "scriptInterface.h"

/// ShipTemplates are created when EmptyEpsilon is started.
/// And used to fill the ship starting statistics, and other information.
REGISTER_SCRIPT_CLASS(ShipTemplate)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setName);
    /// Set the class name, and subclass name for the ship. Used to divide ships into different classes.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setClass);
    /// Set the description shown for this ship in the science database.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setDescription);
    /// Sets the type of template. Defaults to normal ships, so then it does not need to be set.
    /// Example: template:setType("ship"), template:setType("playership"), template:setType("station")
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setType);
    /// Set the default AI behaviour. EE has 3 types of AI coded into the game right now: "default", "fighter", "missilevolley"
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setDefaultAI);
    /// Set the 3D model to be used for this template. The model referers to data set in the model_data.lua file.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setModel);
    /// Supply a list of ship classes that can be docked to this ship. setDockClasses("Starfighter") will allow all small starfighter type ships to dock with this ship.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setDockClasses);
    /// Set the amount of energy available for this ship. Note that only player ships use energy. So setting this for anything else is useless.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setEnergyStorage);
    /// Setup a beam weapon.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setBeam);
    /// Setup a beam weapon.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setBeamWeapon);
    /// Setup a beam weapon texture
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setBeamTexture);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setBeamWeaponEnergyPerFire);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setBeamWeaponHeatPerFire);
    /// Set the amount of missile tubes, limited to a maximum of 16.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setTubes);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setTubeLoadTime);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, weaponTubeAllowMissle);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, weaponTubeDisallowMissle);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setWeaponTubeExclusiveFor);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setTubeDirection);
    /// Set the amount of starting hull
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setHull);
    /// Set the shield levels, amount of parameters defines the amount of shields. (Up to a maximum of 8 shields)
    /// Example: setShieldData(400) setShieldData(100, 80) setShieldData(100, 50, 50)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setShields);
    /// Set the impulse speed, rotation speed and impulse acceleration for this ship.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setSpeed);
    /// Sets the combat maneuver power of this ship.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setCombatManeuver);
    /// Set the warp speed for warp level 1 for this ship. Setting this will indicate that this ship has a warpdrive. (normal value is 1000)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setWarpSpeed);
    /// Set if this ship has a jump drive. Example: template:setJumpDrive(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setJumpDrive);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setCloaking);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setWeaponStorage);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, addRoom);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, addRoomSystem);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, addDoor);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setRadarTrace);
    /// Return a new template with the given name, which is an exact copy of this template.
    /// Used to make easy variations of templates.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, copy);
}

std::unordered_map<string, P<ShipTemplate> > ShipTemplate::templateMap;

ShipTemplate::ShipTemplate()
{
    if (game_server) { LOG(ERROR) << "ShipTemplate objects can not be created during a scenario."; destroy(); return; }
    
    type = Ship;
    class_name = "No class";
    class_name = "No sub-class";
    energy_storage_amount = 1000;
    repair_crew_count = 3;
    weapon_tube_count = 0;
    for(int n=0; n<max_weapon_tubes; n++)
    {
        weapon_tube[n].load_time = 8.0;
        weapon_tube[n].type_allowed_mask = (1 << MW_Count) - 1;
        weapon_tube[n].direction = 0;
    }
    hull = 70;
    shield_count = 0;
    for(int n=0; n<max_shield_count; n++)
        shield_level[n] = 0.0;
    impulse_speed = 500.0;
    impulse_acceleration = 20.0;
    turn_speed = 10.0;
    combat_maneuver_boost_speed = 0.0f;
    combat_maneuver_strafe_speed = 0.0f;
    warp_speed = 0.0;
    has_jump_drive = false;
    has_cloaking = false;
    for(int n=0; n<MW_Count; n++)
        weapon_storage[n] = 0;
    radar_trace = "RadarArrow.png";
}

void ShipTemplate::setBeamTexture(int index, string texture)

{
    if (index >= 0 && index < max_beam_weapons)
    {
        beams[index].setBeamTexture(texture);
    }
}

void ShipTemplate::setTubes(int amount, float load_time)
{
    weapon_tube_count = std::min(max_weapon_tubes, amount);
    for(int n=0; n<max_weapon_tubes; n++)
        weapon_tube[n].load_time = load_time;
}

void ShipTemplate::setTubeLoadTime(int index, float load_time)
{
    if (index < 0 || index >= max_weapon_tubes)
        return;
    weapon_tube[index].load_time = load_time;
}

void ShipTemplate::weaponTubeAllowMissle(int index, EMissileWeapons type)
{
    if (index < 0 || index >= max_weapon_tubes)
        return;
    weapon_tube[index].type_allowed_mask |= (1 << type);
}

void ShipTemplate::weaponTubeDisallowMissle(int index, EMissileWeapons type)
{
    if (index < 0 || index >= max_weapon_tubes)
        return;
    weapon_tube[index].type_allowed_mask &=~(1 << type);
}

void ShipTemplate::setWeaponTubeExclusiveFor(int index, EMissileWeapons type)
{
    if (index < 0 || index >= max_weapon_tubes)
        return;
    weapon_tube[index].type_allowed_mask = (1 << type);
}

void ShipTemplate::setTubeDirection(int index, float direction)
{
    if (index < 0 || index >= max_weapon_tubes)
        return;
    weapon_tube[index].direction = direction;
}

void ShipTemplate::setType(TemplateType type)
{
    if (radar_trace == "RadarArrow.png" && type == Station)
    {
        radar_trace = "RadarBlip.png";
    }
     this->type = type;
}

void ShipTemplate::setName(string name)
{
    if (templateMap.find(name) != templateMap.end())
    {
        LOG(ERROR) << "Duplicate ship template definition: " << name;
    }

    templateMap[name] = this;
    if (name.startswith("Player "))
        name = name.substr(7);
    this->name = name;
}

void ShipTemplate::setClass(string class_name, string sub_class_name)
{
    this->class_name = class_name;
    this->sub_class_name = sub_class_name;
}

void ShipTemplate::setBeam(int index, float arc, float direction, float range, float cycle_time, float damage)
{
    setBeamWeapon(index, arc, direction, range, cycle_time, damage);
}

void ShipTemplate::setBeamWeapon(int index, float arc, float direction, float range, float cycle_time, float damage)
{
    if (index < 0 || index > max_beam_weapons)
        return;
    beams[index].setDirection(direction);
    beams[index].setArc(arc);
    beams[index].setRange(range);
    beams[index].setCycleTime(cycle_time);
    beams[index].setDamage(damage);
}

sf::Vector2i ShipTemplate::interiorSize()
{
    sf::Vector2i min_pos(1000, 1000);
    sf::Vector2i max_pos(0, 0);
    for(unsigned int n=0; n<rooms.size(); n++)
    {
        min_pos.x = std::min(min_pos.x, rooms[n].position.x);
        min_pos.y = std::min(min_pos.y, rooms[n].position.y);
        max_pos.x = std::max(max_pos.x, rooms[n].position.x + rooms[n].size.x);
        max_pos.y = std::max(max_pos.y, rooms[n].position.y + rooms[n].size.y);
    }
    if (min_pos != sf::Vector2i(1, 1))
    {
        sf::Vector2i offset = sf::Vector2i(1, 1) - min_pos;
        for(unsigned int n=0; n<rooms.size(); n++)
            rooms[n].position += offset;
        for(unsigned int n=0; n<doors.size(); n++)
            doors[n].position += offset;
        max_pos += offset;
    }
    max_pos += sf::Vector2i(1, 1);
    return max_pos;
}

ESystem ShipTemplate::getSystemAtRoom(sf::Vector2i position)
{
    for(unsigned int n=0; n<rooms.size(); n++)
    {
        if (rooms[n].position.x <= position.x && rooms[n].position.x + rooms[n].size.x > position.x && rooms[n].position.y <= position.y && rooms[n].position.y + rooms[n].size.y > position.y)
            return rooms[n].system;
    }
    return SYS_None;
}

void ShipTemplate::setCollisionData(P<SpaceObject> object)
{
    model_data->setCollisionData(object);
}

void ShipTemplate::setShields(std::vector<float> values)
{
    shield_count = std::min(max_shield_count, int(values.size()));
    for(int n=0; n<shield_count; n++)
    {
        shield_level[n] = values[n];
    }
}


P<ShipTemplate> ShipTemplate::getTemplate(string name)
{
    if (templateMap.find(name) == templateMap.end())
    {
        LOG(ERROR) << "Failed to find ship template: " << name;
        return nullptr;
    }
    return templateMap[name];
}

std::vector<string> ShipTemplate::getAllTemplateNames()
{
    std::vector<string> ret;
    for(std::unordered_map<string, P<ShipTemplate> >::iterator i = templateMap.begin(); i != templateMap.end(); i++)
        ret.push_back(i->first);
    return ret;
}

std::vector<string> ShipTemplate::getTemplateNameList(TemplateType type)
{
    std::vector<string> ret;
    for(std::unordered_map<string, P<ShipTemplate> >::iterator i = templateMap.begin(); i != templateMap.end(); i++)
        if (i->second->getType() == type)
            ret.push_back(i->first);
    return ret;
}

string getSystemName(ESystem system)
{
    switch(system)
    {
    case SYS_Reactor: return "Reactor";
    case SYS_BeamWeapons: return "Beam Weapons";
    case SYS_MissileSystem: return "Missile System";
    case SYS_Maneuver: return "Maneuvering";
    case SYS_Impulse: return "Impulse Engines";
    case SYS_Warp: return "Warp Drive";
    case SYS_JumpDrive: return "Jump Drive";
    case SYS_FrontShield: return "Front Shields";
    case SYS_RearShield: return "Rear Shields";
    default:
        return "UNKNOWN";
    }
}

void ShipTemplate::setDescription(string description)
{
    this->description = description;
}

void ShipTemplate::setModel(string model_name)
{
    this->model_data = ModelData::getModel(model_name);
}

void ShipTemplate::setDefaultAI(string default_ai_name)
{
    this->default_ai_name = default_ai_name;
}

void ShipTemplate::setDockClasses(std::vector<string> classes)
{
    can_be_docked_by_class = std::unordered_set<string>(classes.begin(), classes.end());
}

void ShipTemplate::setSpeed(float impulse, float turn, float acceleration)
{
    impulse_speed = impulse;
    turn_speed = turn;
    impulse_acceleration = acceleration;
}

void ShipTemplate::setCombatManeuver(float boost, float strafe)
{
    combat_maneuver_boost_speed = boost;
    combat_maneuver_strafe_speed = strafe;
}

void ShipTemplate::setWarpSpeed(float warp)
{
    warp_speed = warp;
}

void ShipTemplate::setJumpDrive(bool enabled)
{
    has_jump_drive = enabled;
}

void ShipTemplate::setCloaking(bool enabled)
{
    has_cloaking = enabled;
}

void ShipTemplate::setWeaponStorage(EMissileWeapons weapon, int amount)
{
    if (weapon != MW_None)
    {
        weapon_storage[weapon] = amount;
    }
}

void ShipTemplate::addRoom(sf::Vector2i position, sf::Vector2i size)
{
    rooms.push_back(ShipRoomTemplate(position, size, SYS_None));
}

void ShipTemplate::addRoomSystem(sf::Vector2i position, sf::Vector2i size, ESystem system)
{
    rooms.push_back(ShipRoomTemplate(position, size, system));
}

void ShipTemplate::addDoor(sf::Vector2i position, bool horizontal)
{
    doors.push_back(ShipDoorTemplate(position, horizontal));
}

void ShipTemplate::setRadarTrace(string trace)
{
    radar_trace = trace;
}

P<ShipTemplate> ShipTemplate::copy(string new_name)
{
    P<ShipTemplate> result = new ShipTemplate();
    result->setName(new_name);

    result->description = description;
    result->class_name = class_name;
    result->sub_class_name = sub_class_name;
    result->type = type;
    result->model_data = model_data;

    result->can_be_docked_by_class = can_be_docked_by_class;
    result->energy_storage_amount = energy_storage_amount;
    result->repair_crew_count = repair_crew_count;
    result->default_ai_name = default_ai_name;
    for(int n=0; n<max_beam_weapons; n++)
        result->beams[n] = beams[n];
    result->weapon_tube_count = weapon_tube_count;
    for(int n=0; n<max_beam_weapons; n++)
        result->weapon_tube[n] = weapon_tube[n];
    result->hull = hull;
    result->shield_count = shield_count;
    for(int n=0; n<max_shield_count; n++)
        result->shield_level[n] = shield_level[n];
    result->impulse_speed = impulse_speed;
    result->turn_speed = turn_speed;
    result->warp_speed = warp_speed;
    result->impulse_acceleration;
    result->combat_maneuver_boost_speed;
    result->combat_maneuver_strafe_speed;
    result->has_jump_drive = has_jump_drive;
    result->has_cloaking = has_cloaking;
    for(int n=0; n<MW_Count; n++)
        result->weapon_storage[n] = weapon_storage[n];
    result->radar_trace = radar_trace;

    result->rooms = rooms;
    result->doors = doors;
    
    return result;
}

void ShipTemplate::setEnergyStorage(float energy_amount)
{
    this->energy_storage_amount = energy_amount;
}

void ShipTemplate::setRepairCrewCount(int amount)
{
    this->repair_crew_count = amount;
}

string ShipTemplate::getName()
{
    return this->name;
}

string ShipTemplate::getDescription()
{
    return this->description;
}

string ShipTemplate::getClass()
{
    return this->class_name;
}

string ShipTemplate::getSubClass()
{
    return this->sub_class_name;
}

ShipTemplate::TemplateType ShipTemplate::getType()
{
    return type;
}

#ifndef _MSC_VER
#include "shipTemplate.hpp"
#endif /* _MSC_VER */
