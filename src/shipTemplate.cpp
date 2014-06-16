#include "shipTemplate.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_CLASS(ShipTemplate)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setName);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setMesh);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setScale);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setBeamPosition);
}

std::map<string, P<ShipTemplate> > ShipTemplate::templateMap;

void ShipTemplate::setName(string name)
{
    this->name = name;
    templateMap[name] = this;
}

void ShipTemplate::setScale(float scale)
{
    this->scale = scale;
}

void ShipTemplate::setMesh(string model, string colorTexture, string specularTexture, string illuminationTexture)
{
    this->model = model;
    this->colorTexture = colorTexture;
    this->specularTexture = specularTexture;
    this->illuminationTexture = illuminationTexture;
}

void ShipTemplate::setBeamPosition(int index, sf::Vector3f position)
{
    if (index < 0 || index > 16)
        return;
    beamPosition[index] = position;
}

P<ShipTemplate> ShipTemplate::getTemplate(string name)
{
    return templateMap[name];
}
