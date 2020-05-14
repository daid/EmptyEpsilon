#include <SFML/OpenGL.hpp>
#include "asteroid.h"
#include "explosionEffect.h"
#include "main.h"
#include "pathPlanner.h"

#include "scriptInterface.h"

/// An asteroid in space. Which you can fly into and hit. Will do damage.
REGISTER_SCRIPT_SUBCLASS(Asteroid, SpaceObject)
{
    /// Set the size of this asteroid, per default asteroids have a size of 120
    REGISTER_SCRIPT_CLASS_FUNCTION(Asteroid, setSize);
}

REGISTER_MULTIPLAYER_CLASS(Asteroid, "Asteroid");
Asteroid::Asteroid()
: SpaceObject(random(110, 130), "Asteroid")
{
    setRotation(random(0, 360));
    rotation_speed = random(0.1, 0.8);
    z = random(-50, 50);
    size = getRadius();
    model_number = irandom(1, 10);
    setRadarSignatureInfo(0.05, 0, 0);

    registerMemberReplication(&z);
    registerMemberReplication(&size);
    
    PathPlannerManager::getInstance()->addAvoidObject(this, 300);
}

void Asteroid::draw3D()
{
#if FEATURE_3D_RENDERING
    if (size != getRadius())
        setRadius(size);

    glTranslatef(0, 0, z);
    glRotatef(engine->getElapsedTime() * rotation_speed, 0, 0, 1);
    glScalef(getRadius(), getRadius(), getRadius());
    sf::Shader* shader = ShaderManager::getShader("objectShaderBS");
    shader->setUniform("baseMap", *textureManager.getTexture("Astroid_" + string(model_number) + "_d.png"));
    shader->setUniform("specularMap", *textureManager.getTexture("Astroid_" + string(model_number) + "_s.png"));
    sf::Shader::bind(shader);
    Mesh* m = Mesh::getMesh("Astroid_" + string(model_number) + ".model");
    m->render();
#endif//FEATURE_3D_RENDERING
}

void Asteroid::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range)
{
    if (size != getRadius())
        setRadius(size);

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

void Asteroid::collide(Collisionable* target, float force)
{
    if (!isServer())
        return;
    P<SpaceObject> hit_object = P<Collisionable>(target);
    if (!hit_object || !hit_object->canBeTargetedBy(nullptr))
        return;

    DamageInfo info(nullptr, DT_Kinetic, getPosition());
    hit_object->takeDamage(35, info);

    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(getRadius());
    e->setPosition(getPosition());
    e->setRadarSignatureInfo(0.0, 0.1, 0.2);
    destroy();
}

void Asteroid::setSize(float size)
{
    this->size = size;
    setRadius(size);
}

/// An asteroid in space. Outside of hit range, just for visuals.
REGISTER_SCRIPT_SUBCLASS(VisualAsteroid, SpaceObject)
{
    /// Set the size of this asteroid, per default asteroids have a size of 120
    REGISTER_SCRIPT_CLASS_FUNCTION(VisualAsteroid, setSize);
}

REGISTER_MULTIPLAYER_CLASS(VisualAsteroid, "VisualAsteroid");
VisualAsteroid::VisualAsteroid()
: SpaceObject(random(110, 130), "VisualAsteroid")
{
    setRotation(random(0, 360));
    rotation_speed = random(0.1, 0.8);
    z = random(300, 800);
    if (random(0, 100) < 50)
        z = -z;

    size = getRadius();
    model_number = irandom(1, 10);

    registerMemberReplication(&z);
    registerMemberReplication(&size);
}

void VisualAsteroid::draw3D()
{
#if FEATURE_3D_RENDERING
    if (size != getRadius())
        setRadius(size);

    glTranslatef(0, 0, z);
    glRotatef(engine->getElapsedTime() * rotation_speed, 0, 0, 1);
    glScalef(getRadius(), getRadius(), getRadius());
    sf::Shader* shader = ShaderManager::getShader("objectShaderBS");
    shader->setUniform("baseMap", *textureManager.getTexture("Astroid_" + string(model_number) + "_d.png"));
    shader->setUniform("specularMap", *textureManager.getTexture("Astroid_" + string(model_number) + "_s.png"));
    sf::Shader::bind(shader);
    Mesh* m = Mesh::getMesh("Astroid_" + string(model_number) + ".model");
    m->render();
#endif//FEATURE_3D_RENDERING
}

void VisualAsteroid::setSize(float size)
{
    this->size = size;
    setRadius(size);
    while(fabs(z) < size * 2)
        z *= random(1.2, 2.0);
}
