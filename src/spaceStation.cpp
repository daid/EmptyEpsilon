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
        ship->addCommsReply(2001, "Do you have spare homing missiles for us?");
        ship->addCommsReply(2002, "Please re-stock our mines.");
        ship->addCommsReply(2003, "Can you supply us with some nukes.");
        ship->addCommsReply(2004, "Please re-stock our EMP Missiles.");
    }else{
        if (ship->docking_state != DS_Docked || ship->docking_target != this)
        {
            ship->setCommsMessage("Greetings sir.\nIf you want to do business please dock with us first.");
            return true;
        }
        ship->setCommsMessage("Welcome to our lovely station");
        ship->addCommsReply(1001, "Do you have spare homing missiles for us?");
        ship->addCommsReply(1002, "Please re-stock our mines.");
        ship->addCommsReply(1003, "Can you supply us with some nukes.");
        ship->addCommsReply(1004, "Please re-stock our EMP Missiles.");
    }
    return true;
}

void SpaceStation::commChannelMessage(P<PlayerSpaceship> ship, int32_t message_id)
{
    switch(message_id)
    {
    case 1001:
        if (ship->weapon_storage[MW_Homing] >= ship->weapon_storage_max[MW_Homing] / 2)
        {
            ship->setCommsMessage("You seem to have more then enough missiles");
        }else{
            ship->weapon_storage[MW_Homing] = ship->weapon_storage_max[MW_Homing] / 2;
            ship->setCommsMessage("We generously resupplied you with some free homing missiles.\nPut them to good use.");
        }
        break;
    case 1002:
        if (ship->weapon_storage[MW_Mine] >= ship->weapon_storage_max[MW_Mine])
        {
            ship->setCommsMessage("You are fully stocked with mines.");
        }else{
            ship->weapon_storage[MW_Mine] = ship->weapon_storage_max[MW_Mine];
            ship->setCommsMessage("Here, have some mines.\nMines are good defensive weapons.");
        }
        break;
    case 1003:
        ship->setCommsMessage("We do not deal in weapons of mass destruction.");
        break;
    case 1004:
        ship->setCommsMessage("We do not deal in weapons of mass disruption.");
        break;

    case 2001:
        if (ship->weapon_storage[MW_Homing] >= ship->weapon_storage_max[MW_Homing])
        {
            ship->setCommsMessage("Sorry sir, but you are fully stocked with homing missiles.");
        }else{
            ship->weapon_storage[MW_Homing] = ship->weapon_storage_max[MW_Homing] / 2;
            ship->setCommsMessage("Filled up your missile supply.");
        }
        break;
    case 2002:
        if (ship->weapon_storage[MW_Mine] >= ship->weapon_storage_max[MW_Mine])
        {
            ship->setCommsMessage("Captain,\nYou have all the mines you can fit in that ship.");
        }else{
            ship->weapon_storage[MW_Mine] = ship->weapon_storage_max[MW_Mine];
            ship->setCommsMessage("Loaded you up with mines.");
        }
        break;
    case 2003:
        if (ship->weapon_storage[MW_Nuke] >= ship->weapon_storage_max[MW_Nuke])
        {
            ship->setCommsMessage("All nukes are charged and primed for distruction.");
        }else{
            ship->weapon_storage[MW_Nuke] = ship->weapon_storage_max[MW_Nuke];
            ship->setCommsMessage("You are fully loaded,\nand ready to explode things.");
        }
        break;
    case 2004:
        if (ship->weapon_storage[MW_EMP] >= ship->weapon_storage_max[MW_EMP])
        {
            ship->setCommsMessage("All storage for EMP missiles is filled sir.");
        }else{
            ship->weapon_storage[MW_EMP] = ship->weapon_storage_max[MW_EMP];
            ship->setCommsMessage("Recallibrated the electronics and\nfitted you with all the EMP missiles you can carry.");
        }
        break;
    default:
        ship->setCommsMessage("Sorry, Dave, I can't let you do that");
    }
}
