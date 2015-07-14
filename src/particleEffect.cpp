#include <SFML/OpenGL.hpp>
#include "main.h"
#include "particleEffect.h"

ParticleEngine* ParticleEngine::particleEngine;
std::vector<Particle> ParticleEngine::particles;

void ParticleEngine::render()
{
#if FEATURE_3D_RENDERING
    billboardShader.setParameter("textureMap", *textureManager.getTexture("particle.png"));
    sf::Shader::bind(&billboardShader);
    glBegin(GL_QUADS);
    for(unsigned int n=0; n<particles.size(); n++)
    {
        Particle& p = particles[n];
        if (p.life_time > p.max_life_time)
            continue;
        
        sf::Vector3f position = Tween<sf::Vector3f>::easeOutQuad(p.life_time, 0, p.max_life_time, p.start.position, p.end.position);
        sf::Vector3f color = Tween<sf::Vector3f>::easeOutQuad(p.life_time, 0, p.max_life_time, p.start.color, p.end.color);
        float size = Tween<float>::easeOutQuad(p.life_time, 0, p.max_life_time, p.start.size, p.end.size);
        
        glColor4f(color.x, color.y, color.z, size);
        glTexCoord2f(0, 0);
        glVertex3f(position.x, position.y, position.z);
        glTexCoord2f(1, 0);
        glVertex3f(position.x, position.y, position.z);
        glTexCoord2f(1, 1);
        glVertex3f(position.x, position.y, position.z);
        glTexCoord2f(0, 1);
        glVertex3f(position.x, position.y, position.z);
    }
    glEnd();
    sf::Shader::bind(NULL);
#endif//FEATURE_3D_RENDERING
}

void ParticleEngine::update(float delta)
{
    for(unsigned int n=0; n<particles.size(); n++)
    {
        Particle& p = particles[n];
        if (p.life_time <= p.max_life_time)
            p.life_time += delta;
    }
}

void ParticleEngine::spawn(sf::Vector3f position, sf::Vector3f end_position, sf::Vector3f color, sf::Vector3f end_color, float size, float end_size, float life_time)
{
#if FEATURE_3D_RENDERING == 0
    return;
#endif
    if (!particleEngine) particleEngine = new ParticleEngine();

    if (sf::length(position - camera_position) / (size + end_size) < 0.1)
        return;

    unsigned int idx = particles.size();
    for(unsigned int n=0; n<particles.size(); n++)
    {
        if (particles[n].life_time > particles[n].max_life_time)
        {
            idx = n;
            break;
        }
    }
    if (idx == particles.size())
        particles.push_back(Particle());
    particles[idx].start.position = position;
    particles[idx].end.position = end_position;
    particles[idx].start.color = color;
    particles[idx].end.color = end_color;
    particles[idx].start.size = size;
    particles[idx].end.size = end_size;
    particles[idx].life_time = 0.0;
    particles[idx].max_life_time = life_time;
}
