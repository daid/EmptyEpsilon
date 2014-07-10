#include <SFML/OpenGL.hpp>
#include "asteroid.h"
#include "explosionEffect.h"
#include "main.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_SUBCLASS(Asteroid, SpaceObject)
{
}

REGISTER_MULTIPLAYER_CLASS(Asteroid, "Asteroid");
Asteroid::Asteroid()
: SpaceObject(120, "Asteroid")
{
    setRotation(random(0, 360));
    rotation_speed = random(0.1, 0.8);
}

void Asteroid::draw3D()
{
    glRotatef(engine->getElapsedTime() * rotation_speed, 0, 0, 1);
    glScalef(getRadius(), getRadius(), getRadius());
    simpleObjectShader.setParameter("baseMap", *textureManager.getTexture("asteroid.png"));
    sf::Shader::bind(&simpleObjectShader);
    Mesh* m = Mesh::getMesh("asteroid.obj");
    m->render();
}

void Asteroid::drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    sf::Sprite objectSprite;
    textureManager.setTexture(objectSprite, "RadarBlip.png");
    objectSprite.setRotation(getRotation());
    objectSprite.setPosition(position);
    objectSprite.setColor(sf::Color(255, 200, 100));
    float size = getRadius() * scale / objectSprite.getTextureRect().width * 2;
    if (size < 0.2)
        size = 0.2;
    objectSprite.setScale(size, size);
    window.draw(objectSprite);
}

void Asteroid::collision(Collisionable* target)
{
    if (!gameServer)
        return;
    P<SpaceObject> hitObject = P<Collisionable>(target);
    if (!hitObject || !hitObject->canBeTargeted())
        return;
    
    hitObject->takeDamage(35, getPosition(), DT_Kinetic);

    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(getRadius());
    e->setPosition(getPosition());
    destroy();
}
