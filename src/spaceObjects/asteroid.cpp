#include <SFML/OpenGL.hpp>
#include "asteroid.h"
#include "explosionEffect.h"
#include "main.h"

#include "scriptInterface.h"

/// An asteroid in space. Nothing more, nothing less.
REGISTER_SCRIPT_SUBCLASS(Asteroid, SpaceObject)
{
}

REGISTER_MULTIPLAYER_CLASS(Asteroid, "Asteroid");
Asteroid::Asteroid()
: SpaceObject(120, "Asteroid")
{
    setRotation(random(0, 360));
    rotation_speed = random(0.1, 0.8);
    z = random(-100, 100);

    registerMemberReplication(&z);
}

void Asteroid::draw3D()
{
#if FEATURE_3D_RENDERING
    glTranslatef(0, 0, z);
    glRotatef(engine->getElapsedTime() * rotation_speed, 0, 0, 1);
    glScalef(getRadius(), getRadius(), getRadius());
    simpleObjectShader->setParameter("baseMap", *textureManager.getTexture("asteroid.png"));
    sf::Shader::bind(simpleObjectShader);
    Mesh* m = Mesh::getMesh("asteroid.obj");
    m->render();
#endif//FEATURE_3D_RENDERING
}

void Asteroid::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    sf::Sprite object_sprite;
    textureManager.setTexture(object_sprite, "RadarBlip.png");
    object_sprite.setRotation(getRotation());
    object_sprite.setPosition(position);
    object_sprite.setColor(sf::Color(255, 200, 100));
    float size = getRadius() * scale / object_sprite.getTextureRect().width * 2;
    if (size < 0.2)
        size = 0.2;
    object_sprite.setScale(size, size);
    window.draw(object_sprite);
}

void Asteroid::collide(Collisionable* target)
{
    if (!isServer())
        return;
    P<SpaceObject> hit_object = P<Collisionable>(target);
    if (!hit_object || !hit_object->canBeTargeted())
        return;

    DamageInfo info(NULL, DT_Kinetic, getPosition());
    hit_object->takeDamage(35, info);

    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(getRadius());
    e->setPosition(getPosition());
    destroy();
}
