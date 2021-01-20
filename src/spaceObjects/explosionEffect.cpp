#include <SFML/OpenGL.hpp>
#include "main.h"
#include "explosionEffect.h"

/// ExplosionEffect is a visible explosion, like from nukes, missiles, ship destruction, etc
/// Example: ExplosionEffect():setPosition(500,5000):setSize(20)
REGISTER_SCRIPT_SUBCLASS(ExplosionEffect, SpaceObject)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(ExplosionEffect, setSize);
    REGISTER_SCRIPT_CLASS_FUNCTION(ExplosionEffect, setOnRadar);
}

REGISTER_MULTIPLAYER_CLASS(ExplosionEffect, "ExplosionEffect");
ExplosionEffect::ExplosionEffect()
: SpaceObject(1000.0, "ExplosionEffect")
{
    size = 1.0;
    explosion_sound = "explosion.wav";
    on_radar = false;
    setCollisionRadius(1.0);
    lifetime = maxLifetime;
    for(int n=0; n<particleCount; n++)
        particleDirections[n] = sf::normalize(sf::Vector3f(random(-1, 1), random(-1, 1), random(-1, 1))) * random(0.8, 1.2);

    registerMemberReplication(&size);
    registerMemberReplication(&on_radar);
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
ExplosionEffect::~ExplosionEffect()
{
}

#if FEATURE_3D_RENDERING
void ExplosionEffect::draw3DTransparent()
{
    float f = (1.0f - (lifetime / maxLifetime));
    float scale;
    float alpha = 0.5;
    if (f < 0.2f)
    {
        scale = (f / 0.2f);
    }else{
        scale = Tween<float>::easeOutQuad(f, 0.2, 1.0, 1.0f, 1.3f);
        alpha = Tween<float>::easeInQuad(f, 0.2, 1.0, 0.5f, 0.0f);
    }

    glPushMatrix();
    glScalef(scale * size, scale * size, scale * size);
    glColor3f(alpha, alpha, alpha);

    sf::Vector3f v1 = sf::Vector3f(-1, -1, 0);
    sf::Vector3f v2 = sf::Vector3f( 1, -1, 0);
    sf::Vector3f v3 = sf::Vector3f( 1,  1, 0);
    sf::Vector3f v4 = sf::Vector3f(-1,  1, 0);

    ShaderManager::getShader("basicShader")->setUniform("textureMap", *textureManager.getTexture("fire_sphere_texture.png"));
    sf::Shader::bind(ShaderManager::getShader("basicShader"));
    Mesh* m = Mesh::getMesh("sphere.obj");
    m->render();

    ShaderManager::getShader("basicShader")->setUniform("textureMap", *textureManager.getTexture("fire_ring.png"));
    sf::Shader::bind(ShaderManager::getShader("basicShader"));
    glScalef(1.5, 1.5, 1.5);
    glBegin(GL_QUADS);
    glTexCoord2f(0, 0);
    glVertex3f(v1.x, v1.y, v1.z);
    glTexCoord2f(1, 0);
    glVertex3f(v2.x, v2.y, v2.z);
    glTexCoord2f(1, 1);
    glVertex3f(v3.x, v3.y, v3.z);
    glTexCoord2f(0, 1);
    glVertex3f(v4.x, v4.y, v4.z);
    glEnd();
    glPopMatrix();


    ShaderManager::getShader("billboardShader")->setUniform("textureMap", *textureManager.getTexture("particle.png"));
    sf::Shader::bind(ShaderManager::getShader("billboardShader"));
    scale = Tween<float>::easeInCubic(f, 0.0, 1.0, 0.3f, 5.0f);
    float r = Tween<float>::easeInQuad(f, 0.0, 1.0, 1.0f, 0.0f);
    float g = Tween<float>::easeOutQuad(f, 0.0, 1.0, 1.0f, 0.0f);
    float b = Tween<float>::easeOutQuad(f, 0.0, 1.0, 1.0f, 0.0f);
    glColor4f(r, g, b, size / 32.0f);
    glBegin(GL_QUADS);
    for(int n=0; n<particleCount; n++)
    {
        sf::Vector3f v = particleDirections[n] * scale * size;
        glTexCoord2f(0, 0);
        glVertex3f(v.x, v.y, v.z);
        glTexCoord2f(1, 0);
        glVertex3f(v.x, v.y, v.z);
        glTexCoord2f(1, 1);
        glVertex3f(v.x, v.y, v.z);
        glTexCoord2f(0, 1);
        glVertex3f(v.x, v.y, v.z);
    }
    glEnd();
}
#endif//FEATURE_3D_RENDERING

void ExplosionEffect::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range)
{
    if (!on_radar)
        return;
    if (long_range)
        return;

    sf::CircleShape circle(size * scale);
    circle.setOrigin(size * scale, size * scale);
    circle.setPosition(position);
    circle.setFillColor(sf::Color(255, 0, 0, 64 * (lifetime / maxLifetime)));
    window.draw(circle);
}

void ExplosionEffect::update(float delta)
{
    if (delta > 0 && lifetime == maxLifetime)
        soundManager->playSound(explosion_sound, getPosition(), size * 2, 60.0);
    lifetime -= delta;
    if (lifetime < 0)
        destroy();
}
