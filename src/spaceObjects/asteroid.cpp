#include <graphics/opengl.h>
#include <glm/gtc/type_ptr.hpp>
#include "components/radar.h"
#include "components/collision.h"
#include "asteroid.h"
#include "explosionEffect.h"
#include "main.h"
#include "random.h"
#include "pathPlanner.h"

#include "scriptInterface.h"
#include "glObjects.h"
#include "shaderRegistry.h"
#include "textureManager.h"

#include <glm/ext/matrix_transform.hpp>

/// An Asteroid is an inert piece of space terrain.
/// Upon collision with another SpaceObject, it deals damage and is destroyed.
/// It has a default rotation speed, random z-offset, and model, and AI behaviors attempt to avoid hitting them.
/// To create a customizable object with more complex actions upon collisions, use an Artifact or SupplyDrop.
/// For a purely decorative asteroid positioned outside of the movement plane, use a VisualAsteroid.
/// Example: asteroid = Asteroid():setSize(150):setPosition(1000,2000)
REGISTER_SCRIPT_SUBCLASS(Asteroid, SpaceObject)
{
    /// Sets this Asteroid's radius.
    /// Defaults to a random value between 110 and 130.
    /// Example: asteroid:setSize(150)
    REGISTER_SCRIPT_CLASS_FUNCTION(Asteroid, setSize);
    /// Returns this Asteroid's radius.
    /// Example: asteroid:getSize()
    REGISTER_SCRIPT_CLASS_FUNCTION(Asteroid, getSize);
}

REGISTER_MULTIPLAYER_CLASS(Asteroid, "Asteroid");
Asteroid::Asteroid()
: SpaceObject(random(110, 130), "Asteroid")
{
    setRotation(random(0, 360));
    rotation_speed = random(0.1f, 0.8f);
    z = random(-50, 50);
    size = 120;
    model_number = irandom(1, 10);
    setRadarSignatureInfo(0.05f, 0, 0);

    registerMemberReplication(&z);
    registerMemberReplication(&size);

    PathPlannerManager::getInstance()->addAvoidObject(this, 300);

    if (entity) {
        auto physics = entity.getComponent<sp::Physics>();
        if (physics)
            size = physics->getSize().x;

        auto& trace = entity.getOrAddComponent<RadarTrace>();
        trace.icon = "radar/blip.png";
        trace.radius = size;
        trace.color = glm::u8vec4(255, 200, 100, 255);
        trace.flags = 0;
    }
}

void Asteroid::draw3D()
{
    auto model_matrix = getModelMatrix();
    ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::ObjectSpecular);

    glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));

    textureManager.getTexture("Astroid_" + string(model_number) + "_d.png")->bind();

    glActiveTexture(GL_TEXTURE0 + ShaderRegistry::textureIndex(ShaderRegistry::Textures::SpecularMap));
    textureManager.getTexture("Astroid_" + string(model_number) + "_s.png")->bind();

    Mesh* m = Mesh::getMesh("Astroid_" + string(model_number) + ".model");

    gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));
    gl::ScopedVertexAttribArray normals(shader.get().attribute(ShaderRegistry::Attributes::Normal));

    ShaderRegistry::setupLights(shader.get(), model_matrix);
    m->render(positions.get(), texcoords.get(), normals.get());


    glActiveTexture(GL_TEXTURE0);
}

void Asteroid::collide(SpaceObject* target, float force)
{
    if (!isServer())
        return;
    P<SpaceObject> hit_object = target;
    if (!hit_object || !hit_object->canBeTargetedBy(nullptr))
        return;

    DamageInfo info({}, DamageType::Kinetic, getPosition());
    hit_object->takeDamage(35, info);

    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(size);
    e->setPosition(getPosition());
    e->setRadarSignatureInfo(0.f, 0.1f, 0.2f);
    destroy();
}

void Asteroid::setSize(float size)
{
    this->size = size;
    auto trace = entity.getComponent<RadarTrace>();
    if (trace)
        trace->radius = size;
    auto physics = entity.getComponent<sp::Physics>();
    if (physics)
        physics->setCircle(physics->getType(), size);
}

float Asteroid::getSize()
{
    return size;
}

glm::mat4 Asteroid::getModelMatrix() const
{
    auto asteroid_matrix = glm::translate(SpaceObject::getModelMatrix(), glm::vec3(0.f, 0.f, z));
    asteroid_matrix = glm::rotate(asteroid_matrix, glm::radians(engine->getElapsedTime() * rotation_speed), glm::vec3(0.f, 0.f, 1.f));
    return glm::scale(asteroid_matrix, glm::vec3(size));
}

/// A VisualAsteroid is an inert piece of space terrain positioned above or below the movement plane.
/// For an asteroid that ships might collide with, use an Asteroid.
/// Example: vasteroid = VisualAsteroid():setSize(150):setPosition(1000,2000)
REGISTER_SCRIPT_SUBCLASS(VisualAsteroid, SpaceObject)
{
    /// Sets this VisualAsteroid's radius.
    /// Defaults to a random value between 110 and 130.
    /// Example: vasteroid:setSize(150)
    REGISTER_SCRIPT_CLASS_FUNCTION(VisualAsteroid, setSize);
    /// Returns this VisualAsteroid's radius.
    /// Example: vasteroid():getSize()
    REGISTER_SCRIPT_CLASS_FUNCTION(VisualAsteroid, getSize);
}

REGISTER_MULTIPLAYER_CLASS(VisualAsteroid, "VisualAsteroid");
VisualAsteroid::VisualAsteroid()
: SpaceObject(random(110, 130), "VisualAsteroid")
{
    setRotation(random(0, 360));
    rotation_speed = random(0.1f, 0.8f);
    z = random(300, 800);
    if (random(0, 100) < 50)
        z = -z;

    model_number = irandom(1, 10);

    registerMemberReplication(&z);
    registerMemberReplication(&size);

    if (entity) {
        auto physics = entity.getComponent<sp::Physics>();
        if (physics)
            size = physics->getSize().x;
    }
}

void VisualAsteroid::draw3D()
{
    auto model_matrix = getModelMatrix();

    ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::ObjectSpecular);

    glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));

    textureManager.getTexture("Astroid_" + string(model_number) + "_d.png")->bind();

    glActiveTexture(GL_TEXTURE0 + ShaderRegistry::textureIndex(ShaderRegistry::Textures::SpecularMap));
    textureManager.getTexture("Astroid_" + string(model_number) + "_s.png")->bind();

    Mesh* m = Mesh::getMesh("Astroid_" + string(model_number) + ".model");

    gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));
    gl::ScopedVertexAttribArray normals(shader.get().attribute(ShaderRegistry::Attributes::Normal));

    ShaderRegistry::setupLights(shader.get(), model_matrix);
    m->render(positions.get(), texcoords.get(), normals.get());

    glActiveTexture(GL_TEXTURE0);
}

void VisualAsteroid::setSize(float size)
{
    this->size = size;
    while(fabs(z) < size * 2)
        z *= random(1.2f, 2.f);
}

float VisualAsteroid::getSize()
{
    return size;
}

glm::mat4 VisualAsteroid::getModelMatrix() const
{
    auto asteroid_matrix = glm::translate(SpaceObject::getModelMatrix(), glm::vec3(0.f, 0.f, z));
    asteroid_matrix = glm::rotate(asteroid_matrix, glm::radians(engine->getElapsedTime() * rotation_speed), glm::vec3(0.f, 0.f, 1.f));
    return glm::scale(asteroid_matrix, glm::vec3(size));
}
