#include <SFML/OpenGL.hpp>
#include "main.h"
#include "explosionEffect.h"

REGISTER_MULTIPLAYER_CLASS(ExplosionEffect, "ExplosionEffect");
ExplosionEffect::ExplosionEffect()
: SpaceObject(1000.0, "ExplosionEffect")
{
    setCollisionRadius(1.0);
    lifetime = maxLifetime;
    for(int n=0; n<particleCount; n++)
        particleDirections[n] = sf::normalize(sf::Vector3f(random(-1, 1), random(-1, 1), random(-1, 1))) * random(0.8, 1.2);
    
    registerMemberReplication(&size);
}

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

    basicShader.setParameter("textureMap", *textureManager.getTexture("fire_sphere_texture.png"));
    sf::Shader::bind(&basicShader);
    Mesh* m = Mesh::getMesh("sphere.obj");
    m->render();

    basicShader.setParameter("textureMap", *textureManager.getTexture("fire_ring.png"));
    sf::Shader::bind(&basicShader);
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
    
    
    basicShader.setParameter("textureMap", *textureManager.getTexture("particle.png"));
    sf::Shader::bind(&basicShader);
    scale = Tween<float>::easeInCubic(f, 0.0, 1.0, 0.3f, 5.0f);
    float r = Tween<float>::easeInQuad(f, 0.0, 1.0, 1.0f, 0.0f);
    float g = Tween<float>::easeOutQuad(f, 0.0, 1.0, 1.0f, 0.0f);
    float b = Tween<float>::easeOutQuad(f, 0.0, 1.0, 1.0f, 0.0f);
    glColor3f(r, g, b);
    glBegin(GL_QUADS);
    for(int n=0; n<particleCount; n++)
    {
        sf::Vector3f eyeNormal = sf::normalize(cameraPosition - particleDirections[n]);
        sf::Vector3f up = sf::cross(eyeNormal, sf::Vector3f(0, 0, 1));
        sf::Vector3f side = sf::cross(eyeNormal, up);
        up = up * size / 32.0f;
        side = side * size / 32.0f;
        
        sf::Vector3f v;
        glTexCoord2f(0, 0);
        v = particleDirections[n] * scale * size - up - side; glVertex3f(v.x, v.y, v.z);
        glTexCoord2f(1, 0);
        v = particleDirections[n] * scale * size + up - side; glVertex3f(v.x, v.y, v.z);
        glTexCoord2f(1, 1);
        v = particleDirections[n] * scale * size + up + side; glVertex3f(v.x, v.y, v.z);
        glTexCoord2f(0, 1);
        v = particleDirections[n] * scale * size - up + side; glVertex3f(v.x, v.y, v.z);
    }
    glEnd();
}

void ExplosionEffect::update(float delta)
{
    if (delta > 0 && lifetime == maxLifetime)
        soundManager.playSound("explosion.wav", getPosition(), size, 1.0);
    lifetime -= delta;
    if (lifetime < 0)
        destroy();
}
