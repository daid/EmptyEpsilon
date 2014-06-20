#include <SFML/OpenGL.hpp>
#include "spaceStation.h"
#include "shipTemplate.h"
#include "mesh.h"
#include "main.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_CLASS(SpaceStation)
{
}

REGISTER_MULTIPLAYER_CLASS(SpaceStation, "SpaceStation");
SpaceStation::SpaceStation()
: SpaceObject(300, "SpaceStation")
{
    setCollisionBox(sf::Vector2f(400, 400));
    setCollisionPhysics(true, true);
    
    shields = maxShields;
    hullStrength = maxHullStrength;
    
    registerMemberReplication(&shields, 0.5);
    registerMemberReplication(&shieldHitEffect, 0.5);
    shieldHitEffect = 0.0;
}

void SpaceStation::draw3D()
{
    P<ShipTemplate> t = ShipTemplate::getTemplate("small-station");

    glPushMatrix();
    glTranslatef(0, 0, 50);
    glScalef(t->scale, t->scale, t->scale);
    objectShader.setParameter("baseMap", *textureManager.getTexture(t->colorTexture));
    objectShader.setParameter("illuminationMap", *textureManager.getTexture(t->illuminationTexture));
    objectShader.setParameter("specularMap", *textureManager.getTexture(t->specularTexture));
    sf::Shader::bind(&objectShader);
    Mesh* m = Mesh::getMesh(t->model);
    m->render();
    glPopMatrix();
}

void SpaceStation::draw3DTransparent()
{
    if (shieldHitEffect > 0)
    {
        basicShader.setParameter("textureMap", *textureManager.getTexture("shield_hit_effect.png"));
        sf::Shader::bind(&basicShader);
        float f = (shields / maxShields) * shieldHitEffect;
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
        objectSprite.setScale(0.7, 0.7);
    window.draw(objectSprite);
}

void SpaceStation::update(float delta)
{
    if (shields < maxShields)
    {
        shields += delta * shieldRechargeRate;
        if (shields > maxShields)
            shields = maxShields;
    }
    if (shieldHitEffect > 0)
    {
        shieldHitEffect -= delta;
    }
}

void SpaceStation::takeDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type)
{
    shields -= damageAmount;
    if (shields < 0)
    {
        if (type != DT_EMP)
        {
            hullStrength -= damageAmount;
            if (hullStrength <= 0.0)
                destroy();
        }
        shields = 0;
    }else{
        shieldHitEffect = 1.0;
    }
}
