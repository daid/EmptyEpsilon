#include <SFML/OpenGL.hpp>
#include "spaceStation.h"
#include "shipTemplate.h"
#include "playerInfo.h"
#include "factionInfo.h"
#include "gui.h"
#include "mesh.h"
#include "explosionEffect.h"
#include "main.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_SUBCLASS(SpaceStation, SpaceObject)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceStation, setTemplate);
}

REGISTER_MULTIPLAYER_CLASS(SpaceStation, "SpaceStation");
SpaceStation::SpaceStation()
: SpaceObject(300, "SpaceStation")
{
    setCollisionBox(sf::Vector2f(400, 400));
    setCollisionPhysics(true, true);
    
    shields = shields_max = 400;
    hull_strength = hull_max = 200;
    
    registerMemberReplication(&templateName);
    registerMemberReplication(&shields, 1.0);
    registerMemberReplication(&shields_max);
    registerMemberReplication(&shieldHitEffect, 0.5);
    shieldHitEffect = 0.0;

    comms_script_name = "comms_station.lua";
    
    setTemplate("Small Station");
}

void SpaceStation::draw3D()
{
    if (!shipTemplate) return;

    glPushMatrix();
    glTranslatef(0, 0, 50);
    glScalef(shipTemplate->scale, shipTemplate->scale, shipTemplate->scale);
    objectShader.setParameter("baseMap", *textureManager.getTexture(shipTemplate->colorTexture));
    objectShader.setParameter("illuminationMap", *textureManager.getTexture(shipTemplate->illuminationTexture));
    objectShader.setParameter("specularMap", *textureManager.getTexture(shipTemplate->specularTexture));
    sf::Shader::bind(&objectShader);
    Mesh* m = Mesh::getMesh(shipTemplate->model);
    m->render();
    glPopMatrix();
}

void SpaceStation::draw3DTransparent()
{
    if (shieldHitEffect > 0)
    {
        basicShader.setParameter("textureMap", *textureManager.getTexture("shield_hit_effect.png"));
        sf::Shader::bind(&basicShader);
        float f = (shields / shields_max) * shieldHitEffect;
        glColor4f(f, f, f, 1);
        glRotatef(engine->getElapsedTime() * 5, 0, 0, 1);
        glScalef(getRadius(), getRadius(), getRadius());
        Mesh* m = Mesh::getMesh("sphere.obj");
        m->render();
    }
}

void SpaceStation::drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    sf::Sprite objectSprite;
    textureManager.setTexture(objectSprite, "RadarBlip.png");
    objectSprite.setPosition(position);

    if (long_range)
    {
        GUI::text(sf::FloatRect(position.x, position.y - 15, 0, 0), getCallSign(), AlignCenter, 12);
        objectSprite.setScale(0.7, 0.7);
    }
    if (my_spaceship)
    {
        if (isEnemy(my_spaceship))
            objectSprite.setColor(sf::Color::Red);
        if (isFriendly(my_spaceship))
            objectSprite.setColor(sf::Color(128, 255, 128));
    }else{
        objectSprite.setColor(factionInfo[faction_id].gm_color);
    }
    window.draw(objectSprite);
}

void SpaceStation::update(float delta)
{
    if (shields < shields_max)
    {
        shields += delta * shieldRechargeRate;
        if (shields > shields_max)
            shields = shields_max;
    }
    if (shieldHitEffect > 0)
    {
        shieldHitEffect -= delta;
    }
}

bool SpaceStation::canBeDockedBy(P<SpaceObject> obj)
{
    if (isEnemy(obj))
        return false;
    P<SpaceShip> ship = obj;
    if (!ship)
        return false;
    return true;
}

void SpaceStation::takeDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type)
{
    shields -= damageAmount;
    if (shields < 0)
    {
        if (type != DT_EMP)
        {
            hull_strength -= damageAmount;
            if (hull_strength <= 0.0)
            {
                ExplosionEffect* e = new ExplosionEffect();
                e->setSize(getRadius());
                e->setPosition(getPosition());

                destroy();
            }
        }
        shields = 0;
    }else{
        shieldHitEffect = 1.0;
    }
}

void SpaceStation::setTemplate(string templateName)
{
    this->templateName = templateName;
    shipTemplate = ShipTemplate::getTemplate(templateName);
    if (!shipTemplate)
    {
        printf("Failed to find template for station: %s\n", templateName.c_str());
        return;
    }
    
    hull_strength = hull_max = shipTemplate->hull;
    shields = shields_max = shipTemplate->frontShields;
}
