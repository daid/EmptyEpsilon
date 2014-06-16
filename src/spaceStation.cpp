#include <SFML/OpenGL.hpp>
#include "spaceStation.h"
#include "shipTemplate.h"
#include "mesh.h"
#include "main.h"

REGISTER_MULTIPLAYER_CLASS(SpaceStation, "SpaceStation");
SpaceStation::SpaceStation()
: SpaceObject(200, "SpaceStation")
{
    setCollisionBox(sf::Vector2f(400, 400));
    setCollisionPhysics(true, true);
}

void SpaceStation::draw3D()
{
    P<ShipTemplate> t = ShipTemplate::getTemplate("small-station");

    glTranslatef(0, 0, 50);
    glScalef(t->scale, t->scale, t->scale);
    objectShader.setParameter("baseMap", *textureManager.getTexture(t->colorTexture));
    objectShader.setParameter("illuminationMap", *textureManager.getTexture(t->illuminationTexture));
    objectShader.setParameter("specularMap", *textureManager.getTexture(t->specularTexture));
    sf::Shader::bind(&objectShader);
    Mesh* m = Mesh::getMesh(t->model);
    m->render();
}

void SpaceStation::update(float delta)
{
}
