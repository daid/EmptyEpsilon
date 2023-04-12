#include <graphics/opengl.h>
#include <glm/gtc/type_ptr.hpp>
#include "components/radar.h"
#include "components/collision.h"
#include "components/rendering.h"
#include "components/spin.h"
#include "components/avoidobject.h"
#include "asteroid.h"
#include "explosionEffect.h"
#include "main.h"
#include "random.h"

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
    setRadarSignatureInfo(0.05f, 0, 0);

    if (entity) {
        auto z = random(-50, 50);
        auto size = random(110, 130);

        auto model_number = irandom(1, 10);
        auto& mrc = entity.getOrAddComponent<MeshRenderComponent>();
        mrc.mesh.name = "Astroid_" + string(model_number) + ".model";
        mrc.mesh_offset = {0, 0, z};
        mrc.texture.name = "Astroid_" + string(model_number) + "_d.png";
        mrc.specular_texture.name = "Astroid_" + string(model_number) + "_s.png";
        mrc.scale = size;

        auto physics = entity.getComponent<sp::Physics>();
        if (physics)
            physics->setCircle(sp::Physics::Type::Static, size);

        auto& trace = entity.getOrAddComponent<RadarTrace>();
        trace.icon = "radar/blip.png";
        trace.radius = size;
        trace.color = glm::u8vec4(255, 200, 100, 255);
        trace.flags = 0;

        auto& spin = entity.getOrAddComponent<Spin>();
        spin.rate = random(0.1f, 0.8f);

        entity.getOrAddComponent<AvoidObject>().range = 300.0f;
    }
}

void Asteroid::collide(SpaceObject* target, float force)
{
    if (!isServer())
        return;
    P<SpaceObject> hit_object = target;
    if (!hit_object || !hit_object->canBeTargetedBy({}))
        return;

    DamageInfo info({}, DamageType::Kinetic, getPosition());
    hit_object->takeDamage(35, info);

    auto physics = entity.getComponent<sp::Physics>();
    if (physics) {
        P<ExplosionEffect> e = new ExplosionEffect();
        e->setSize(physics->getSize().x);
        e->setPosition(getPosition());
        e->setRadarSignatureInfo(0.f, 0.1f, 0.2f);
    }
    destroy();
}

void Asteroid::setSize(float size)
{
    auto mrc = entity.getComponent<MeshRenderComponent>();
    if (mrc)
        mrc->scale = size;
    auto trace = entity.getComponent<RadarTrace>();
    if (trace)
        trace->radius = size;
    auto physics = entity.getComponent<sp::Physics>();
    if (physics)
        physics->setCircle(physics->getType(), size);
}

float Asteroid::getSize()
{
    auto physics = entity.getComponent<sp::Physics>();
    if (physics)
        return physics->getSize().x;
    return 120.0;
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

    if (entity) {
        auto z = random(300, 800);
        if (random(0, 100) < 50)
            z = -z;

        auto size = random(110, 130);

        auto model_number = irandom(1, 10);
        auto& mrc = entity.getOrAddComponent<MeshRenderComponent>();
        mrc.mesh.name = "Astroid_" + string(model_number) + ".model";
        mrc.mesh_offset = {0, 0, z};
        mrc.texture.name = "Astroid_" + string(model_number) + "_d.png";
        mrc.specular_texture.name = "Astroid_" + string(model_number) + "_s.png";
        mrc.scale = size;

        auto& trace = entity.getOrAddComponent<RadarTrace>();
        trace.icon = "radar/blip.png";
        trace.radius = size;
        trace.color = glm::u8vec4(255, 200, 100, 255);
        trace.flags = 0;

        auto& spin = entity.getOrAddComponent<Spin>();
        spin.rate = random(0.1f, 0.8f);

        entity.removeComponent<sp::Physics>();
    }

}


void VisualAsteroid::setSize(float size)
{
    auto mrc = entity.getComponent<MeshRenderComponent>();
    if (mrc)
        mrc->scale = size;
    auto trace = entity.getComponent<RadarTrace>();
    if (trace)
        trace->radius = size;
    auto physics = entity.getComponent<sp::Physics>();
    if (physics)
        physics->setCircle(physics->getType(), size);

    if (mrc) {
        while(fabs(mrc->mesh_offset.z) < size * 2)
            mrc->mesh_offset.z *= random(1.2f, 2.f);
    }
}

float VisualAsteroid::getSize()
{
    auto physics = entity.getComponent<sp::Physics>();
    if (physics)
        return physics->getSize().x;
    auto mrc = entity.getComponent<MeshRenderComponent>();
    if (mrc)
        return mrc->scale;
    return 120.0;
}
