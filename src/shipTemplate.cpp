#include "shipTemplate.h"
#include "mesh.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_CLASS(ShipTemplate)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setName);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setMesh);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setScale);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setRadius);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setBeamPosition);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setBeam);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setTubePosition);
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
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, addEngineEmitor);
}

/* Define script conversion function for the EMissileWeapons enum. */
template<> void convert<EMissileWeapons>::param(lua_State* L, int& idx, EMissileWeapons& es)
{
    const char* str = luaL_checkstring(L, idx++);
    if (strcasecmp(str, "Homing") == 0)
        es = MW_Homing;
    else if (strcasecmp(str, "Nuke") == 0)
        es = MW_Nuke;
    else if (strcasecmp(str, "Mine") == 0)
        es = MW_Mine;
    else if (strcasecmp(str, "EMP") == 0)
        es = MW_EMP;
    else
        es = MW_None;
}

/* Define script conversion function for the EMissileWeapons enum. */
template<> void convert<ESystem>::param(lua_State* L, int& idx, ESystem& es)
{
    const char* str = luaL_checkstring(L, idx++);
    if (strcasecmp(str, "Reactor") == 0)
        es = SYS_Reactor;
    else if (strcasecmp(str, "BeamWeapons") == 0)
        es = SYS_BeamWeapons;
    else if (strcasecmp(str, "MissileSystem") == 0)
        es = SYS_MissileSystem;
    else if (strcasecmp(str, "Maneuver") == 0)
        es = SYS_Maneuver;
    else if (strcasecmp(str, "Impulse") == 0)
        es = SYS_Impulse;
    else if (strcasecmp(str, "Warp") == 0)
        es = SYS_Warp;
    else if (strcasecmp(str, "JumpDrive") == 0)
        es = SYS_JumpDrive;
    else if (strcasecmp(str, "FrontShield") == 0)
        es = SYS_FrontShield;
    else if (strcasecmp(str, "RearShield") == 0)
        es = SYS_RearShield;
    else
        es = SYS_None;
}

std::map<string, P<ShipTemplate> > ShipTemplate::templateMap;

ShipTemplate::ShipTemplate()
{
    scale = 1.0;
    for(int n=0; n<maxBeamWeapons; n++)
    {
        beams[n].arc = 0.0;
        beams[n].direction = 0.0;
        beams[n].range = 0.0;
        beams[n].damage = 0.0;
    }
    radius = 50.0;
    weaponTubes = 0;
    hull = 70;
    frontShields = 0;
    rearShields = 0.0;
    impulseSpeed = 500.0;
    turnSpeed = 10.0;
    warpSpeed = 0.0;
    jumpDrive = false;
    cloaking = false;
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

void ShipTemplate::setMesh(string model, string colorTexture, string specularTexture, string illuminationTexture)
{
    this->model = model;
    this->colorTexture = colorTexture;
    this->specularTexture = specularTexture;
    this->illuminationTexture = illuminationTexture;
    Mesh::getMesh(model);
    textureManager.getTexture(colorTexture);
    textureManager.getTexture(specularTexture);
    textureManager.getTexture(illuminationTexture);
}

void ShipTemplate::setBeamPosition(int index, sf::Vector3f position)
{
    if (index < 0 || index > maxBeamWeapons)
        return;
    beamPosition[index] = position;
}

void ShipTemplate::setBeam(int index, float arc, float direction, float range, float cycle_time, float damage)
{
    if (index < 0 || index > maxBeamWeapons)
        return;
    beams[index].arc = arc;
    beams[index].direction = direction;
    beams[index].range = range;
    beams[index].cycle_time = cycle_time;
    beams[index].damage = damage;
}


void ShipTemplate::setTubePosition(int index, sf::Vector2f position)
{
    if (index < 0 || index > maxWeaponTubes)
        return;
    tubePosition[index] = position;
}

sf::Vector2i ShipTemplate::interiorSize()
{
    sf::Vector2i size(0, 0);
    for(unsigned int n=0; n<rooms.size(); n++)
    {
        size.x = std::max(size.x, rooms[n].position.x + rooms[n].size.x);
        size.y = std::max(size.y, rooms[n].position.y + rooms[n].size.y);
    }
    return size;
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

P<ShipTemplate> ShipTemplate::getTemplate(string name)
{
    return templateMap[name];
}

std::vector<string> ShipTemplate::getTemplateNameList()
{
    std::vector<string> ret;
    for(std::map<string, P<ShipTemplate> >::iterator i = templateMap.begin(); i != templateMap.end(); i++)
        if (!i->first.endswith("Station") && !i->first.startswith("Player"))
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
