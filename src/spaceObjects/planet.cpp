#include "planet.h"
#include <SFML/OpenGL.hpp>
#include "main.h"
#include "pathPlanner.h"

#include "scriptInterface.h"

static Mesh* planet_mesh[16];

class PlanetMeshGenerator
{
public:
    std::vector<MeshVertex> vertices;
    int max_iterations;
    
    PlanetMeshGenerator(int iterations)
    {
        max_iterations = iterations;
        
        createFace(0, sf::Vector3f(0, 0, 1), sf::Vector3f(0, 1, 0), sf::Vector3f(1, 0, 0), sf::Vector2f(0, 0), sf::Vector2f(0, 0.5), sf::Vector2f(0.25, 0.5));
        createFace(0, sf::Vector3f(0, 0, 1), sf::Vector3f(1, 0, 0), sf::Vector3f(0,-1, 0), sf::Vector2f(0.25, 0), sf::Vector2f(0.25, 0.5), sf::Vector2f(0.5, 0.5));
        createFace(0, sf::Vector3f(0, 0, 1), sf::Vector3f(0,-1, 0), sf::Vector3f(-1, 0, 0), sf::Vector2f(0.5, 0), sf::Vector2f(0.5, 0.5), sf::Vector2f(0.75, 0.5));
        createFace(0, sf::Vector3f(0, 0, 1), sf::Vector3f(-1, 0, 0), sf::Vector3f(0, 1, 0), sf::Vector2f(0.75, 0), sf::Vector2f(0.75, 0.5), sf::Vector2f(1.0, 0.5));
        
        createFace(0, sf::Vector3f(0, 0,-1), sf::Vector3f(1, 0, 0), sf::Vector3f(0, 1, 0), sf::Vector2f(0, 1.0), sf::Vector2f(0.25, 0.5), sf::Vector2f(0.0, 0.5));
        createFace(0, sf::Vector3f(0, 0,-1), sf::Vector3f(0,-1, 0), sf::Vector3f(1, 0, 0), sf::Vector2f(0.25, 1.0), sf::Vector2f(0.5, 0.5), sf::Vector2f(0.25, 0.5));
        createFace(0, sf::Vector3f(0, 0,-1), sf::Vector3f(-1, 0, 0), sf::Vector3f(0,-1, 0), sf::Vector2f(0.5, 1.0), sf::Vector2f(0.75, 0.5), sf::Vector2f(0.5, 0.5));
        createFace(0, sf::Vector3f(0, 0,-1), sf::Vector3f(0,1, 0), sf::Vector3f(-1, 0, 0), sf::Vector2f(0.75, 1.0), sf::Vector2f(1.0, 0.5), sf::Vector2f(0.75, 0.5));
        
        for(unsigned int n=0; n<vertices.size(); n++)
        {
            //Recalculate the U values of the uvMap so we get proper spherical mapping.
            float u = vertices[n].uv[0];
            float v = fabs(vertices[n].uv[1] - 0.5) * 2.0; // = 0 when at center, 1 at top/bottom of the texture.
            if (v < 1.0)
                u = fmod(u, 0.25) / (1.0 - v) + (floorf(u * 4) / 4.0f);
            
            vertices[n].uv[0] = u;
        }
    }
    
    void createFace(int iteration, sf::Vector3f v0, sf::Vector3f v1, sf::Vector3f v2, sf::Vector2f uv0, sf::Vector2f uv1, sf::Vector2f uv2)
    {
        if (iteration < max_iterations)
        {
            sf::Vector3f v01 = v0 + v1;
            sf::Vector3f v12 = v1 + v2;
            sf::Vector3f v02 = v0 + v2;
            sf::Vector2f uv01 = (uv0 + uv1) / 2.0f;
            sf::Vector2f uv12 = (uv1 + uv2) / 2.0f;
            sf::Vector2f uv02 = (uv0 + uv2) / 2.0f;
            v01 /= sf::length(v01);
            v12 /= sf::length(v12);
            v02 /= sf::length(v02);
            createFace(iteration + 1, v0, v01, v02, uv0, uv01, uv02);
            createFace(iteration + 1, v01, v1, v12, uv01, uv1, uv12);
            createFace(iteration + 1, v01, v12, v02, uv01, uv12, uv02);
            createFace(iteration + 1, v2, v02, v12, uv2, uv02, uv12);
        }else{
            vertices.emplace_back();
            vertices.back().position[0] = v0.x;
            vertices.back().position[1] = v0.y;
            vertices.back().position[2] = v0.z;
            vertices.back().normal[0] = v0.x;
            vertices.back().normal[1] = v0.y;
            vertices.back().normal[2] = v0.z;
            vertices.back().uv[0] = uv0.x;
            vertices.back().uv[1] = uv0.y;

            vertices.emplace_back();
            vertices.back().position[0] = v1.x;
            vertices.back().position[1] = v1.y;
            vertices.back().position[2] = v1.z;
            vertices.back().normal[0] = v1.x;
            vertices.back().normal[1] = v1.y;
            vertices.back().normal[2] = v1.z;
            vertices.back().uv[0] = uv1.x;
            vertices.back().uv[1] = uv1.y;

            vertices.emplace_back();
            vertices.back().position[0] = v2.x;
            vertices.back().position[1] = v2.y;
            vertices.back().position[2] = v2.z;
            vertices.back().normal[0] = v2.x;
            vertices.back().normal[1] = v2.y;
            vertices.back().normal[2] = v2.z;
            vertices.back().uv[0] = uv2.x;
            vertices.back().uv[1] = uv2.y;
        }
    }
};

/// A planet.
REGISTER_SCRIPT_SUBCLASS(Planet, SpaceObject)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(Planet, setPlanetAtmosphereColor);
    REGISTER_SCRIPT_CLASS_FUNCTION(Planet, setPlanetAtmosphereTexture);
    REGISTER_SCRIPT_CLASS_FUNCTION(Planet, setPlanetSurfaceTexture);
    REGISTER_SCRIPT_CLASS_FUNCTION(Planet, setPlanetCloudTexture);
    REGISTER_SCRIPT_CLASS_FUNCTION(Planet, setPlanetRadius);
    REGISTER_SCRIPT_CLASS_FUNCTION(Planet, setPlanetCloudRadius);
    REGISTER_SCRIPT_CLASS_FUNCTION(Planet, setDistanceFromMovementPlane);
}

REGISTER_MULTIPLAYER_CLASS(Planet, "Planet");
Planet::Planet()
: SpaceObject(5000, "Planet")
{
    planet_size = 5000;
    cloud_size = 5200;
    planet_texture = "";
    cloud_texture = "";
    atmosphere_texture = "";
    atmosphere_color = sf::Color(255, 255, 255);
    distance_from_movement_plane = 0;

    update_delta = 0.0;
    collision_size = -2.0f;

    setRadarSignatureInfo(0.5, 0, 0);
    
    registerMemberReplication(&planet_size);
    registerMemberReplication(&cloud_size);
    registerMemberReplication(&planet_texture);
    registerMemberReplication(&cloud_texture);
    registerMemberReplication(&atmosphere_texture);
    registerMemberReplication(&atmosphere_color);
    registerMemberReplication(&distance_from_movement_plane);
}

void Planet::setPlanetAtmosphereColor(float r, float g, float b)
{
    atmosphere_color.r = r * 255;
    atmosphere_color.g = g * 255;
    atmosphere_color.b = b * 255;
}

void Planet::setPlanetAtmosphereTexture(string texture_name)
{
    atmosphere_texture = texture_name;
}

void Planet::setPlanetSurfaceTexture(string texture_name)
{
    planet_texture = texture_name;
}

void Planet::setPlanetCloudTexture(string texture_name)
{
    cloud_texture = texture_name;
}

void Planet::setPlanetRadius(float size)
{
    this->planet_size = size;
    this->cloud_size = size * 1.05;
    this->atmosphere_size = size * 1.2;
}

void Planet::setPlanetCloudRadius(float size)
{
    cloud_size = size;
}

void Planet::setDistanceFromMovementPlane(float distance_from_movement_plane)
{
    this->distance_from_movement_plane = distance_from_movement_plane;
}

void Planet::update(float delta)
{
    update_delta = delta;
    
    if (collision_size == -2.0f)
    {
        updateCollisionSize();
        if (collision_size > 0.0)
            PathPlannerManager::getInstance()->addAvoidObject(this, collision_size);
    }
}

#if FEATURE_3D_RENDERING
void Planet::draw3D()
{
    float distance = sf::length(camera_position - sf::Vector3f(getPosition().x, getPosition().y, distance_from_movement_plane));
    
    //view_scale ~= about the size the planet is on the screen.
    float view_scale = planet_size / distance;
    int level_of_detail = 4;
    if (view_scale < 0.01)
        level_of_detail = 2;
    if (view_scale < 0.1)
        level_of_detail = 3;

    if (planet_texture != "" && planet_size > 0)
    {
        glTranslatef(0, 0, distance_from_movement_plane);
        glScalef(planet_size, planet_size, planet_size);
        glColor3f(1, 1, 1);

        if (!planet_mesh[level_of_detail])
        {
            PlanetMeshGenerator planet_mesh_generator(level_of_detail);
            planet_mesh[level_of_detail] = new Mesh(planet_mesh_generator.vertices);
        }
        planetShader->setParameter("baseMap", *textureManager.getTexture(planet_texture));
        sf::Shader::bind(planetShader);
        planet_mesh[level_of_detail]->render();
    }
}

void Planet::draw3DTransparent()
{
    float distance = sf::length(camera_position - sf::Vector3f(getPosition().x, getPosition().y, distance_from_movement_plane));
    
    //view_scale ~= about the size the planet is on the screen.
    float view_scale = planet_size / distance;
    int level_of_detail = 4;
    if (view_scale < 0.01)
        level_of_detail = 2;
    if (view_scale < 0.1)
        level_of_detail = 3;

    glTranslatef(0, 0, distance_from_movement_plane);
    if (cloud_texture != "" && cloud_size > 0)
    {
        glPushMatrix();
        glScalef(cloud_size, cloud_size, cloud_size);
        glRotatef(engine->getElapsedTime() * 1.0f, 0, 0, 1);
        glColor3f(1, 1, 1);

        if (!planet_mesh[level_of_detail])
        {
            PlanetMeshGenerator planet_mesh_generator(level_of_detail);
            planet_mesh[level_of_detail] = new Mesh(planet_mesh_generator.vertices);
        }
        planetShader->setParameter("baseMap", *textureManager.getTexture(cloud_texture));
        sf::Shader::bind(planetShader);
        planet_mesh[level_of_detail]->render();
        glPopMatrix();
    }
    if (atmosphere_texture != "" && atmosphere_size > 0)
    {
        billboardShader->setParameter("textureMap", *textureManager.getTexture(atmosphere_texture));
        sf::Shader::bind(billboardShader);
        glColor4f(atmosphere_color.r / 255.0f, atmosphere_color.g / 255.0f, atmosphere_color.b / 255.0f, atmosphere_size * 2.0f);
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
    }
}
#endif

void Planet::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    if (collision_size > 0)
    {
        sf::CircleShape radar_radius(collision_size * scale);
        radar_radius.setOrigin(collision_size * scale, collision_size * scale);
        radar_radius.setPosition(position);
        radar_radius.setFillColor(sf::Color(atmosphere_color.r, atmosphere_color.g, atmosphere_color.b, 128));
        window.draw(radar_radius);
    }
}

void Planet::collide(Collisionable* target, float collision_force)
{
    if (update_delta == 0.0)
        return;
/*
    sf::Vector2f diff = getPosition() - target->getPosition();
    float distance = sf::length(diff);
    float force = (getRadius() * getRadius() * 50.0f) / (distance * distance);
    if (force > 10000.0)
    {
        force = 10000.0;
        if (isServer())
            target->destroy();
    }
    DamageInfo info(NULL, DT_Kinetic, getPosition());
    if (force > 100.0 && isServer())
    {
        P<SpaceObject> obj = P<Collisionable>(target);
        if (obj)
            obj->takeDamage(force * update_delta / 10.0f, info);
    }
    target->setPosition(target->getPosition() + diff / distance * update_delta * force);*/
}

void Planet::updateCollisionSize()
{
    setRadius(planet_size);
    if (std::abs(distance_from_movement_plane) >= planet_size)
    {
        collision_size = -1.0;
    }else{
        collision_size = sqrt((planet_size * planet_size) - (distance_from_movement_plane * distance_from_movement_plane)) * 1.1f;
        setCollisionRadius(collision_size);
        setCollisionPhysics(true, true);
    }
}
