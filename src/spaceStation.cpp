#include <SFML/OpenGL.hpp>
#include "spaceStation.h"
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
    glTranslatef(0, 0, 50);
    glScalef(10.0, 10.0, 10.0);
    objectShader.setParameter("baseMap", *textureManager.getTexture("space_station_4_color.jpg"));
    objectShader.setParameter("illuminationMap", *textureManager.getTexture("space_station_4_illumination.jpg"));
    objectShader.setParameter("specularMap", *textureManager.getTexture("space_station_4_specular.jpg"));
    sf::Shader::bind(&objectShader);
    Mesh* m = Mesh::getMesh("space_station_4.obj");
    m->render();
}

void SpaceStation::update(float delta)
{
}
