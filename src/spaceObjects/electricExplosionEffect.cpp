#include <SFML/OpenGL.hpp>
#include "main.h"
#include "electricExplosionEffect.h"

/// ElectricExplosionEffect is a visible electrical explosion, as seen from EMP missiles
/// Example: ElectricExplosionEffect():setPosition(500,5000):setSize(20)
REGISTER_SCRIPT_SUBCLASS(ElectricExplosionEffect, SpaceObject)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(ElectricExplosionEffect, setSize);
}

REGISTER_MULTIPLAYER_CLASS(ElectricExplosionEffect, "ElectricExplosionEffect");
ElectricExplosionEffect::ElectricExplosionEffect()
: SpaceObject(1000.0, "ElectricExplosionEffect")
{
    on_radar = false;
    size = 1.0;
    
    setCollisionRadius(1.0);
    lifetime = maxLifetime;
    for(int n=0; n<particleCount; n++)
        particleDirections[n] = sf::normalize(sf::Vector3f(random(-1, 1), random(-1, 1), random(-1, 1))) * random(0.8, 1.2);
    
    registerMemberReplication(&size);
    registerMemberReplication(&on_radar);
}

#if FEATURE_3D_RENDERING
void ElectricExplosionEffect::draw3DTransparent()
{
    float f = (1.0f - (lifetime / maxLifetime));
    float scale;
    float alpha = 0.5;
    if (f < 0.2f)
    {
        scale = (f / 0.2f) * 0.8;
    }else{
        scale = Tween<float>::easeOutQuad(f, 0.2, 1.0, 0.8f, 1.0f);
        alpha = Tween<float>::easeInQuad(f, 0.2, 1.0, 0.5f, 0.0f);
    }
    
    glPushMatrix();
    glScalef(scale * size, scale * size, scale * size);
    glColor3f(alpha, alpha, alpha);
    
    ShaderManager::getShader("basicShader")->setParameter("textureMap", *textureManager.getTexture("electric_sphere_texture.png"));
    sf::Shader::bind(ShaderManager::getShader("basicShader"));
    Mesh* m = Mesh::getMesh("sphere.obj");
    m->render();
    glScalef(0.5, 0.5, 0.5);
    m->render();
    glPopMatrix();
    
    ShaderManager::getShader("billboardShader")->setParameter("textureMap", *textureManager.getTexture("particle.png"));
    sf::Shader::bind(ShaderManager::getShader("billboardShader"));
    scale = Tween<float>::easeInCubic(f, 0.0, 1.0, 0.3f, 3.0f);
    float r = Tween<float>::easeOutQuad(f, 0.0, 1.0, 1.0f, 0.0f);
    float g = Tween<float>::easeOutQuad(f, 0.0, 1.0, 1.0f, 0.0f);
    float b = Tween<float>::easeInQuad(f, 0.0, 1.0, 1.0f, 0.0f);
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

void ElectricExplosionEffect::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    if (!on_radar)
        return;
    if (long_range)
        return;

    sf::CircleShape circle(size * scale);
    circle.setOrigin(size * scale, size * scale);
    circle.setPosition(position);
    circle.setFillColor(sf::Color(0, 0, 255, 64 * (lifetime / maxLifetime)));
    window.draw(circle);
}

void ElectricExplosionEffect::update(float delta)
{
    if (delta > 0 && lifetime == maxLifetime)
        soundManager->playSound("sfx/emp_explosion.wav", getPosition(), size, 1.0);
    lifetime -= delta;
    if (lifetime < 0)
        destroy();
}
