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
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setTubes);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setShields);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setSpeed);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setWarpSpeed);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setJumpDrive);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setCloaking);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setWeaponStorage);
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
    frontShields = 0;
    rearShields = 0.0;
    impulseSpeed = 500.0;
    turnSpeed = 10.0;
    warpSpeed = 0.0;
    jumpDrive = false;
    cloaking = false;
    for(int n=0; n<MW_Count; n++)
        weaponStorage[n] = 0;
}

void ShipTemplate::setName(string name)
{
    this->name = name;
    templateMap[name] = this;
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

P<ShipTemplate> ShipTemplate::getTemplate(string name)
{
    return templateMap[name];
}
