#include <SFML/OpenGL.hpp>

#include "main.h"
#include "wormHole.h"
#include "spaceship.h"
#include "scriptInterface.h"

#define FORCE_MULTIPLIER          50.0
#define FORCE_MAX                 10000.0
#define ALPHA_MULTIPLIER          10.0
#define DEFAULT_COLLISION_RADIUS  2500
#define AVOIDANCE_MULTIPLIER      1.2
#define TARGET_SPREAD             500

// A wormhole object that drags objects toward it like a black hole, and then
// teleports them to another point when they reach its center.
REGISTER_SCRIPT_SUBCLASS(WormHole, SpaceObject)
{
    /// Set the target of this wormhole
    REGISTER_SCRIPT_CLASS_FUNCTION(WormHole, setTargetPosition);
    REGISTER_SCRIPT_CLASS_FUNCTION(WormHole, getTargetPosition);
    /// Set a function that will be called if a SpaceObject is teleported.
    /// First argument given to the function will be the WormHole, the second the SpaceObject that has been teleported.
    REGISTER_SCRIPT_CLASS_FUNCTION(WormHole, onTeleportation);
}

REGISTER_MULTIPLAYER_CLASS(WormHole, "WormHole");
WormHole::WormHole()
: SpaceObject(DEFAULT_COLLISION_RADIUS, "WormHole") 
{
    pathPlanner = PathPlannerManager::getInstance();
    pathPlanner->addAvoidObject(this, (DEFAULT_COLLISION_RADIUS * AVOIDANCE_MULTIPLIER) );
    
    setRadarSignatureInfo(0.9, 0.0, 0.0);

    // Choose a texture to show on radar
    radar_visual = irandom(1, 3);
    registerMemberReplication(&radar_visual);
    
    // Create some overlaying clouds
    for(int n=0; n<cloud_count; n++)
    {
        clouds[n].size = random(1024, 1024 * 4);
        clouds[n].texture = irandom(1, 3);
        clouds[n].offset = sf::Vector2f(0, 0); 
    }
}

#if FEATURE_3D_RENDERING
void WormHole::draw3DTransparent()
{
    glRotatef(getRotation(), 0, 0, -1);
    glTranslatef(-getPosition().x, -getPosition().y, 0);
    for(int n=0; n<cloud_count; n++)
    {
        NebulaCloud& cloud = clouds[n];

        sf::Vector3f position = sf::Vector3f(getPosition().x, getPosition().y, 0) + sf::Vector3f(cloud.offset.x, cloud.offset.y, 0);
        float size = cloud.size;
        
        float distance = sf::length(camera_position - position);
        float alpha = 1.0 - (distance / 10000.0f);
        if (alpha < 0.0)
            continue;

        ShaderManager::getShader("billboardShader")->setParameter("textureMap", *textureManager.getTexture("wormHole" + string(cloud.texture) + ".png"));
        sf::Shader::bind(ShaderManager::getShader("billboardShader"));
        glBegin(GL_QUADS);
        glColor4f(alpha * 0.8, alpha * 0.8, alpha * 0.8, size);
        glTexCoord2f(0, 0);
        glVertex3f(position.x, position.y, position.z);
        glTexCoord2f(1, 0);
        glVertex3f(position.x, position.y, position.z);
        glTexCoord2f(1, 1);
        glVertex3f(position.x, position.y, position.z);
        glTexCoord2f(0, 1);
        glVertex3f(position.x, position.y, position.z);
        glEnd();
    }
}
#endif//FEATURE_3D_RENDERING


void WormHole::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    sf::Sprite object_sprite;
    textureManager.setTexture(object_sprite, "wormHole" + string(radar_visual) + ".png");
    object_sprite.setRotation(getRotation());
    object_sprite.setPosition(position);
    float size = getRadius() * scale / object_sprite.getTextureRect().width * 3.0;
    object_sprite.setScale(size, size);
    object_sprite.setColor(sf::Color(255, 255, 255));
    window.draw(object_sprite, sf::RenderStates(sf::BlendAdd));
}

// Draw a line toward the target position
void WormHole::drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{    
    sf::VertexArray a(sf::Lines, 2);
    a[0].position = position;
    a[1].position = position + (target_position - getPosition()) * scale;
    a[0].color = sf::Color(255, 255, 255, 32);
    window.draw(a);
    
    sf::CircleShape range_circle(getRadius() * scale);
    range_circle.setOrigin(getRadius() * scale, getRadius() * scale);
    range_circle.setPosition(position);
    range_circle.setFillColor(sf::Color::Transparent);
    range_circle.setOutlineColor(sf::Color(255, 255, 255, 32));
    range_circle.setOutlineThickness(2.0);
    window.draw(range_circle);
}


void WormHole::update(float delta)
{
    update_delta = delta;
}

void WormHole::collide(Collisionable* target, float collision_force)
{
    if (update_delta == 0.0)
        return;

    sf::Vector2f diff = getPosition() - target->getPosition();
    float distance = sf::length(diff);
    float force = (getRadius() * getRadius() * FORCE_MULTIPLIER) / (distance * distance);
    
    P<SpaceShip> obj = P<Collisionable>(target);
    
    if (force > FORCE_MAX)
    {
        force = FORCE_MAX;
        if (isServer())
            target->setPosition( (target_position + 
                                  sf::Vector2f(random(-TARGET_SPREAD, TARGET_SPREAD), 
                                               random(-TARGET_SPREAD, TARGET_SPREAD))));
        if (obj)
        {
            obj->wormhole_alpha = 0.0;
            if (on_teleportation.isSet())
            {
                on_teleportation.call(P<WormHole>(this), obj);
            }
        }
    }
    
    // Warp postprocessor-alpha is calculated using alpha = (1 - (delay/10))
    if (obj)
        obj->wormhole_alpha = ((distance / getRadius()) * ALPHA_MULTIPLIER);
    
    // TODO: Escaping is impossible. Change setPosition to something Newtonianish.
    target->setPosition(target->getPosition() + diff / distance * update_delta * force);
}

void WormHole::setTargetPosition(sf::Vector2f v)
{
    target_position = v;
}

sf::Vector2f WormHole::getTargetPosition()
{
    return target_position;
}

void WormHole::onTeleportation(ScriptSimpleCallback callback)
{
    this->on_teleportation = callback;
}
