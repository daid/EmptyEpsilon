#include "blackHole.h"
#include "pathPlanner.h"
#include "main.h"
#include <SFML/OpenGL.hpp>

#include "scriptInterface.h"

/// A blackhole has a 5km radius where it pulls in all near objects. At the center of the black hole everything gets a lot of damage.
/// Which will lead to the eventual destruction of said object.
REGISTER_SCRIPT_SUBCLASS(BlackHole, SpaceObject)
{
}

REGISTER_MULTIPLAYER_CLASS(BlackHole, "BlackHole");
BlackHole::BlackHole()
: SpaceObject(5000, "BlackHole")
{
    update_delta = 0.0;
    PathPlannerManager::getInstance()->addAvoidObject(this, 7000);
    setRadarSignatureInfo(0.9, 0, 0);
}

void BlackHole::update(float delta)
{
    update_delta = delta;
}

#if FEATURE_3D_RENDERING
void BlackHole::draw3DTransparent()
{
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    ShaderManager::getShader("billboardShader")->setUniform("textureMap", *textureManager.getTexture("blackHole3d.png"));
    sf::Shader::bind(ShaderManager::getShader("billboardShader"));
    glColor4f(1, 1, 1, 5000.0);
    glBegin(GL_QUADS);
    glTexCoord2f(0, 0);
    glVertex3f(0, 0, 0);
    glTexCoord2f(1, 0);
    glVertex3f(0, 0, 0);
    glTexCoord2f(1, 1);
    glVertex3f(0, 0, 0);
    glTexCoord2f(0, 1);
    glVertex3f(0, 0, 0);
    glEnd();
    glBlendFunc(GL_ONE, GL_ONE);
}
#endif

void BlackHole::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range)
{
    sf::Sprite object_sprite;
    textureManager.setTexture(object_sprite, "blackHole.png");
    object_sprite.setRotation(getRotation());
    object_sprite.setPosition(position);
    float size = getRadius() * scale / object_sprite.getTextureRect().width * 2;
    object_sprite.setScale(size, size);
    object_sprite.setColor(sf::Color(64, 64, 255));
    window.draw(object_sprite);
    object_sprite.setColor(sf::Color(0, 0, 0));
    window.draw(object_sprite);
}

void BlackHole::collide(Collisionable* target, float collision_force)
{
    if (update_delta == 0.0)
        return;

    P<SpaceObject> obj = P<Collisionable>(target);
    if (!obj) return;
    if (!obj->hasWeight()) { return; } // the object is not affected by gravitation

    sf::Vector2f diff = getPosition() - target->getPosition();
    float distance = sf::length(diff);
    float force = (getRadius() * getRadius() * 50.0f) / (distance * distance);
    DamageInfo info(NULL, DT_Kinetic, getPosition());
    if (force > 10000.0)
    {
        force = 10000.0;
        if (isServer())
        {
            obj->takeDamage(100000.0, info); //try to destroy the object by inflicting a huge amount of damage
            if (target)
            {
                target->destroy();
                return;
            }
        }
    }
    if (force > 100.0 && isServer())
    {
        obj->takeDamage(force * update_delta / 10.0f, info);
    }
    if (!obj) {return;}
    obj->setPosition(obj->getPosition() + diff / distance * update_delta * force);
}
