#include "shipTemplate.h"
#include "spaceObjects/spaceObject.h"
#include "mesh.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_CLASS(ShipTemplate)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setName);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setDescription);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setDefaultAI);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setModel);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setSizeClass);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setBeam);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setTubes);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setHull);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setShields);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setSpeed);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setWarpSpeed);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setJumpDrive);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setCloaking);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setWeaponStorage);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, addRoom);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, addRoomSystem);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, addDoor);
}

/* Define script conversion function for the EMissileWeapons enum. */
template<> void convert<EMissileWeapons>::param(lua_State* L, int& idx, EMissileWeapons& es)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "homing")
        es = MW_Homing;
    else if (str == "nuke")
        es = MW_Nuke;
    else if (str == "mine")
        es = MW_Mine;
    else if (str == "emp")
        es = MW_EMP;
    else
        es = MW_None;
}

/* Define script conversion function for the EMissileWeapons enum. */
template<> void convert<ESystem>::param(lua_State* L, int& idx, ESystem& es)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "reactor")
        es = SYS_Reactor;
    else if (str == "beamweapons")
        es = SYS_BeamWeapons;
    else if (str == "missilesystem")
        es = SYS_MissileSystem;
    else if (str == "maneuver")
        es = SYS_Maneuver;
    else if (str == "impulse")
        es = SYS_Impulse;
    else if (str == "warp")
        es = SYS_Warp;
    else if (str == "jumpdrive")
        es = SYS_JumpDrive;
    else if (str == "frontshield")
        es = SYS_FrontShield;
    else if (str == "rearshield")
        es = SYS_RearShield;
    else
        es = SYS_None;
}

std::unordered_map<string, P<ShipTemplate> > ShipTemplate::templateMap;

ShipTemplate::ShipTemplate()
{
    for(int n=0; n<max_beam_weapons; n++)
    {
        beams[n].arc = 0.0;
        beams[n].direction = 0.0;
        beams[n].range = 0.0;
        beams[n].damage = 0.0;
        beams[n].cycle_time = 0.0;
    }
    size_class = 10;
    weapon_tubes = 0;
    tube_load_time = 8.0;
    hull = 70;
    front_shields = 0;
    rear_shields = 0.0;
    impulse_speed = 500.0;
    impulse_acceleration = 20.0;
    turn_speed = 10.0;
    warp_speed = 0.0;
    has_jump_drive = false;
    has_cloaking = false;
    for(int n=0; n<MW_Count; n++)
        weapon_storage[n] = 0;
}

void ShipTemplate::setName(string name)
{
    templateMap[name] = this;
    if (name.startswith("Player "))
        name = name.substr(7);
    this->name = name;
}

void ShipTemplate::setBeam(int index, float arc, float direction, float range, float cycle_time, float damage)
{
    if (index < 0 || index > max_beam_weapons)
        return;
    while(direction < 0)
        direction += 360;
    beams[index].arc = arc;
    beams[index].direction = direction;
    beams[index].range = range;
    beams[index].cycle_time = cycle_time;
    beams[index].damage = damage;
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

P<ShipTemplate> ShipTemplate::getTemplate(string name)
{
    if (templateMap.find(name) != templateMap.end())
        return templateMap[name];
    return NULL;
}

std::vector<string> ShipTemplate::getTemplateNameList()
{
    std::vector<string> ret;
    for(std::unordered_map<string, P<ShipTemplate> >::iterator i = templateMap.begin(); i != templateMap.end(); i++)
        if (!i->first.endswith("Station") && !i->first.startswith("Player"))
            ret.push_back(i->first);
    return ret;
}

std::vector<string> ShipTemplate::getPlayerTemplateNameList()
{
    std::vector<string> ret;
    for(std::unordered_map<string, P<ShipTemplate> >::iterator i = templateMap.begin(); i != templateMap.end(); i++)
        if (!i->first.endswith("Station") && i->first.startswith("Player"))
            ret.push_back(i->first);
    return ret;
}

std::vector<string> ShipTemplate::getStationTemplateNameList()
{
    std::vector<string> ret;
    for(std::unordered_map<string, P<ShipTemplate> >::iterator i = templateMap.begin(); i != templateMap.end(); i++)
        if (i->first.endswith("Station") && !i->first.startswith("Player"))
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
