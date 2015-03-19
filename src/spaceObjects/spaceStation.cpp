#include <SFML/OpenGL.hpp>
#include "spaceObjects/spaceStation.h"
#include "shipTemplate.h"
#include "playerInfo.h"
#include "factionInfo.h"
#include "gui/gui.h"
#include "mesh.h"
#include "spaceObjects/explosionEffect.h"
#include "main.h"
#include "pathPlanner.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_SUBCLASS(SpaceStation, SpaceObject)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceStation, setTemplate);
}

REGISTER_MULTIPLAYER_CLASS(SpaceStation, "SpaceStation");
SpaceStation::SpaceStation()
: SpaceObject(300, "SpaceStation")
{
    setCollisionPhysics(true, true);

    shields = shields_max = 400;
    hull_strength = hull_max = 200;

    registerMemberReplication(&template_name);
    registerMemberReplication(&shields, 1.0);
    registerMemberReplication(&shields_max);
    registerMemberReplication(&shieldHitEffect, 0.5);
    shieldHitEffect = 0.0;

    comms_script_name = "comms_station.lua";
}

void SpaceStation::draw3D()
{
    if (!ship_template) return;

    glScalef(ship_template->scale, ship_template->scale, ship_template->scale);
    glTranslatef(ship_template->render_offset.x, ship_template->render_offset.y, ship_template->render_offset.z);
    objectShader.setParameter("baseMap", *textureManager.getTexture(ship_template->color_texture));
    objectShader.setParameter("illuminationMap", *textureManager.getTexture(ship_template->illumination_texture));
    objectShader.setParameter("specularMap", *textureManager.getTexture(ship_template->specular_texture));
    sf::Shader::bind(&objectShader);
    Mesh* m = Mesh::getMesh(ship_template->model);
    m->render();
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

void SpaceStation::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    sf::Sprite objectSprite;
    textureManager.setTexture(objectSprite, "RadarBlip.png");
    objectSprite.setPosition(position);
    float sprite_scale = scale * getRadius() / objectSprite.getTextureRect().width * 1.5;

    if (long_range)
    {
        GUI::drawText(sf::FloatRect(position.x, position.y - 15, 0, 0), getCallSign(), AlignCenter, 12);
        sprite_scale *= 0.7;
    }
    objectSprite.setScale(sprite_scale, sprite_scale);
    if (my_spaceship)
    {
        if (isEnemy(my_spaceship))
            objectSprite.setColor(sf::Color::Red);
        if (isFriendly(my_spaceship))
            objectSprite.setColor(sf::Color(128, 255, 128));
    }else{
        objectSprite.setColor(factionInfo[getFactionId()]->gm_color);
    }
    window.draw(objectSprite);
}

void SpaceStation::update(float delta)
{
    if (!ship_template || ship_template->getName() != template_name)
    {
        ship_template = ShipTemplate::getTemplate(template_name);
        if (!ship_template)
            return;
        ship_template->setCollisionData(this);
    }

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

void SpaceStation::takeDamage(float damage_amount, DamageInfo& info)
{
    shields -= damage_amount;
    if (shields < 0)
    {
        if (info.type != DT_EMP)
        {
            hull_strength -= damage_amount;
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

void SpaceStation::setTemplate(string template_name)
{
    P<ShipTemplate> new_ship_template = ShipTemplate::getTemplate(template_name);
    if (!new_ship_template)
    {
        LOG(ERROR) << "Failed to find template for station: " << template_name;
        return;
    }
    this->template_name = template_name;
    ship_template = new_ship_template;

    hull_strength = hull_max = ship_template->hull;
    shields = shields_max = ship_template->front_shields;

    ship_template->setCollisionData(this);

    PathPlannerManager::getInstance()->addAvoidObject(this, getRadius() * 1.5f);
}
