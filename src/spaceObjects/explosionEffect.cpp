#include <GL/glew.h>
#include <SFML/OpenGL.hpp>
#include "main.h"
#include "explosionEffect.h"
#include "glObjects.h"

#if FEATURE_3D_RENDERING
sf::Shader* ExplosionEffect::basicShader = nullptr;
uint32_t ExplosionEffect::basicShaderPositionAttribute = 0;
uint32_t ExplosionEffect::basicShaderTexCoordsAttribute = 0;

sf::Shader* ExplosionEffect::particlesShader = nullptr;
uint32_t ExplosionEffect::particlesShaderPositionAttribute = 0;
uint32_t ExplosionEffect::particlesShaderTexCoordsAttribute = 0;

struct VertexAndTexCoords
{
    sf::Vector3f vertex;
    sf::Vector2f texcoords;
};
#endif

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
#if FEATURE_3D_RENDERING
    if (!basicShader && gl::isAvailable())
    {
        basicShader = ShaderManager::getShader("shaders/basic");
        basicShaderPositionAttribute = glGetAttribLocation(basicShader->getNativeHandle(), "position");
        basicShaderTexCoordsAttribute = glGetAttribLocation(basicShader->getNativeHandle(), "texcoords");

        particlesShader = ShaderManager::getShader("shaders/billboard");
        particlesShaderPositionAttribute = glGetAttribLocation(particlesShader->getNativeHandle(), "position");
        particlesShaderTexCoordsAttribute = glGetAttribLocation(particlesShader->getNativeHandle(), "texcoords");
    }
#endif
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

    basicShader->setUniform("textureMap", *textureManager.getTexture("fire_ring.png"));
    basicShader->setUniform("color", sf::Glsl::Vec4(alpha, alpha, alpha, 1.f));
    sf::Shader::bind(basicShader);
    glScalef(1.5, 1.5, 1.5);

    constexpr size_t quad_count = 10;
    std::array<VertexAndTexCoords, 4*quad_count> quads;
    // Initialize texcoords per quad.
    for (auto i = 0; i < quads.size(); i += 4)
    {
        quads[i + 0].texcoords = { 0.f, 0.f };
        quads[i + 1].texcoords = { 1.f, 0.f };
        quads[i + 2].texcoords = { 1.f, 1.f };
        quads[i + 3].texcoords = { 0.f, 1.f };
    }
    // Draw
    {
        quads[0].vertex = v1;
        quads[1].vertex = v2;
        quads[2].vertex = v3;
        quads[3].vertex = v4;
        gl::ScopedVertexAttribArray positions(basicShaderPositionAttribute);
        gl::ScopedVertexAttribArray texcoords(basicShaderTexCoordsAttribute);
        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quads.data());
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quads.data() + sizeof(sf::Vector3f)));
        glDrawArrays(GL_QUADS, 0, 4);
    }
    glPopMatrix();


    particlesShader->setUniform("textureMap", *textureManager.getTexture("particle.png"));
    
    sf::Shader::bind(particlesShader);
    scale = Tween<float>::easeInCubic(f, 0.0, 1.0, 0.3f, 5.0f);
    float r = Tween<float>::easeInQuad(f, 0.0, 1.0, 1.0f, 0.0f);
    float g = Tween<float>::easeOutQuad(f, 0.0, 1.0, 1.0f, 0.0f);
    float b = Tween<float>::easeOutQuad(f, 0.0, 1.0, 1.0f, 0.0f);
    particlesShader->setUniform("color", sf::Glsl::Vec4(r, g, b, size / 32.0f));
    gl::ScopedVertexAttribArray positions(particlesShaderPositionAttribute);
    gl::ScopedVertexAttribArray texcoords(particlesShaderTexCoordsAttribute);

    // We're drawing particles `quad_count` at a time.
    for(size_t n = 0; n<particleCount;)
    {
        auto active_quads = std::min(quad_count, particleCount - n);
        // setup quads
        for (auto p = 0; p < active_quads; ++p)
        {
            sf::Vector3f v = particleDirections[n + p] * scale * size;
            quads[4 * p + 0].vertex = v;
            quads[4 * p + 1].vertex = v;
            quads[4 * p + 2].vertex = v;
            quads[4 * p + 3].vertex = v;
        }
       
        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quads.data());
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quads.data() + sizeof(sf::Vector3f)));
        glDrawArrays(GL_QUADS, 0, 4 * active_quads);
        n += active_quads;
    }    
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
