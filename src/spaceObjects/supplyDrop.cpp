#include <SFML/OpenGL.hpp>
#include "supplyDrop.h"
#include "spaceship.h"
#include "playerInfo.h"
#include "playerSpaceship.h"
#include "main.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_SUBCLASS(SupplyDrop, SpaceObject)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(SupplyDrop, setEnergy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SupplyDrop, setWeaponStorage);
}

REGISTER_MULTIPLAYER_CLASS(SupplyDrop, "SupplyDrop");

SupplyDrop::SupplyDrop()
: SpaceObject(100, "SupplyDrop")
{
    for(int n=0; n<MW_Count; n++)
        weapon_storage[n] = 0;
    energy = 0.0;
}

void SupplyDrop::draw3D()
{
    float scale = 1.0;
    glScalef(scale, scale, scale);
    glRotatef(35, 1, 0, 0);
    objectShader.setParameter("baseMap", *textureManager.getTexture("ammo_box.png"));
    objectShader.setParameter("illuminationMap", *textureManager.getTexture("ammo_box_illumination.png"));
    objectShader.setParameter("specularMap", *textureManager.getTexture("ammo_box_specular.png"));
    sf::Shader::bind(&objectShader);
    Mesh* m = Mesh::getMesh("ammo_box.obj");
    m->render();
}

void SupplyDrop::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    sf::Sprite object_sprite;
    textureManager.setTexture(object_sprite, "RadarBlip.png");
    object_sprite.setRotation(getRotation());
    object_sprite.setPosition(position);
    if (my_spaceship && !my_spaceship->isFriendly(this))
        object_sprite.setColor(sf::Color(200, 50, 50));
    else
        object_sprite.setColor(sf::Color(100, 200, 255));
    float size = 0.5;
    object_sprite.setScale(size, size);
    window.draw(object_sprite);
}

void SupplyDrop::collide(Collisionable* target)
{
    P<SpaceShip> ship = P<Collisionable>(target);
    if (ship && isFriendly(ship))
    {
        bool picked_up = false;
        P<PlayerSpaceship> player = ship;
        if (player)
        {
            player->energy_level += energy;
            picked_up = true;
        }
        for(int n=0; n<MW_Count; n++)
        {
            uint8_t delta = std::min(int(weapon_storage[n]), ship->weapon_storage_max[n] - ship->weapon_storage[n]);
            if (delta > 0)
            {
                ship->weapon_storage[n] += delta;
                weapon_storage[n] -= delta;
                picked_up = true;
            }
        }

        if (picked_up)
            destroy();
    }
}
