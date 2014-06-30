#include <SFML/OpenGL.hpp>
#include "spaceStation.h"
#include "shipTemplate.h"
#include "playerInfo.h"
#include "factionInfo.h"
#include "mesh.h"
#include "explosionEffect.h"
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
    
    registerMemberReplication(&shields, 1.0);
    registerMemberReplication(&shieldHitEffect, 0.5);
    shieldHitEffect = 0.0;
}

void SpaceStation::draw3D()
{
    P<ShipTemplate> t = ShipTemplate::getTemplate("Small Station");

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
    if (mySpaceship)
    {
        if (isEnemy(mySpaceship))
            objectSprite.setColor(sf::Color::Red);
    }else{
        objectSprite.setColor(factionInfo[faction_id].gm_color);
    }
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

bool SpaceStation::openCommChannel(P<PlayerSpaceship> ship)
{
    if (isEnemy(ship))
        return false;
    if (isFriendly(ship))
    {
        ship->setCommsMessage("Good day captain,\nWhat can we do for you today?");
    }else{
        if (ship->docking_state != DS_Docked || ship->docking_target != this)
        {
            ship->setCommsMessage("Greetings sir.\nIf you want to do business please dock with us first.");
            return true;
        }
        ship->setCommsMessage("Welcome to our lovely station");
        ship->addCommsReply(1, "Please re-stock our homing missiles.");
        ship->addCommsReply(2, "Please re-stock our mines.");
        ship->addCommsReply(3, "Please re-stock our nukes.");
        ship->addCommsReply(4, "Please re-stock our EMP Missiles.");
    }
    return true;
}

void SpaceStation::commChannelMessage(P<PlayerSpaceship> ship, int32_t message_id)
{
    switch(message_id)
    {
    default:
        ship->setCommsMessage("Sorry, Dave, I can't let you do that");
    }
}
