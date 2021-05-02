#include <GL/glew.h>
#include <SFML/OpenGL.hpp>
#include "main.h"
#include "electricExplosionEffect.h"
#include "glObjects.h"

#if FEATURE_3D_RENDERING
sf::Shader* ElectricExplosionEffect::particlesShader = nullptr;
uint32_t ElectricExplosionEffect::particlesShaderPositionAttribute = 0;
uint32_t ElectricExplosionEffect::particlesShaderTexCoordsAttribute = 0;
gl::Buffers<2> ElectricExplosionEffect::particlesBuffers(gl::Unitialized{});
#endif

/// ElectricExplosionEffect is a visible electrical explosion, as seen from EMP missiles
/// Example: ElectricExplosionEffect():setPosition(500,5000):setSize(20)
REGISTER_SCRIPT_SUBCLASS(ElectricExplosionEffect, SpaceObject)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(ElectricExplosionEffect, setSize);
    REGISTER_SCRIPT_CLASS_FUNCTION(ElectricExplosionEffect, setOnRadar);
}

REGISTER_MULTIPLAYER_CLASS(ElectricExplosionEffect, "ElectricExplosionEffect");
ElectricExplosionEffect::ElectricExplosionEffect()
: SpaceObject(1000.0, "ElectricExplosionEffect")
{
    has_weight = false;
    on_radar = false;
    size = 1.0;

    setCollisionRadius(1.0);
    lifetime = maxLifetime;
    for(int n=0; n<particleCount; n++)
        particleDirections[n] = sf::normalize(sf::Vector3f(random(-1, 1), random(-1, 1), random(-1, 1))) * random(0.8, 1.2);

    registerMemberReplication(&size);
    registerMemberReplication(&on_radar);
#if FEATURE_3D_RENDERING
    if (!particlesShader && gl::isAvailable())
    {
        particlesShader = ShaderManager::getShader("shaders/billboard");
        particlesShaderPositionAttribute = glGetAttribLocation(particlesShader->getNativeHandle(), "position");
        particlesShaderTexCoordsAttribute = glGetAttribLocation(particlesShader->getNativeHandle(), "texcoords");

        particlesBuffers = gl::Buffers<2>();

        
        // Each vertex is a position and a texcoords.
        // The two arrays are maintained separately (texcoords are fixed, vertices position change).
        constexpr size_t vertex_size = sizeof(sf::Vector3f) + sizeof(sf::Vector2f);
        gl::ScopedBufferBinding vbo(GL_ARRAY_BUFFER, particlesBuffers[0]);
        gl::ScopedBufferBinding ebo(GL_ELEMENT_ARRAY_BUFFER, particlesBuffers[1]);

        // VBO
        glBufferData(GL_ARRAY_BUFFER, max_quad_count * 4 * vertex_size, nullptr, GL_DYNAMIC_DRAW);

        // Create initial data.
        std::array<uint8_t, 6 * max_quad_count> indices;
        std::array<sf::Vector2f, 4 * max_quad_count> texcoords;
        for (auto i = 0; i < max_quad_count; ++i)
        {
            auto quad_offset = 4 * i;
            texcoords[quad_offset + 0] = { 0.f, 1.f };
            texcoords[quad_offset + 1] = { 1.f, 1.f };
            texcoords[quad_offset + 2] = { 1.f, 0.f };
            texcoords[quad_offset + 3] = { 0.f, 0.f };

            indices[6 * i + 0] = quad_offset + 0;
            indices[6 * i + 1] = quad_offset + 2;
            indices[6 * i + 2] = quad_offset + 1;
            indices[6 * i + 3] = quad_offset + 0;
            indices[6 * i + 4] = quad_offset + 3;
            indices[6 * i + 5] = quad_offset + 2;
        }

        // Update texcoords
        glBufferSubData(GL_ARRAY_BUFFER, max_quad_count * 4 * sizeof(sf::Vector3f), texcoords.size() * sizeof(sf::Vector2f), texcoords.data());
        // Upload indices
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(uint8_t), indices.data(), GL_STATIC_DRAW);
    }
#endif
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
ElectricExplosionEffect::~ElectricExplosionEffect()
{
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

    ShaderManager::getShader("shaders/basicShader")->setUniform("textureMap", *textureManager.getTexture("electric_sphere_texture.png"));
    sf::Shader::bind(ShaderManager::getShader("shaders/basicShader"));
    Mesh* m = Mesh::getMesh("sphere.obj");
    m->render();
    glScalef(0.5, 0.5, 0.5);
    m->render();
    glPopMatrix();

    scale = Tween<float>::easeInCubic(f, 0.0, 1.0, 0.3f, 3.0f);
    float r = Tween<float>::easeOutQuad(f, 0.0, 1.0, 1.0f, 0.0f);
    float g = Tween<float>::easeOutQuad(f, 0.0, 1.0, 1.0f, 0.0f);
    float b = Tween<float>::easeInQuad(f, 0.0, 1.0, 1.0f, 0.0f);

    std::array<sf::Vector3f, 4 * max_quad_count> vertices;

    particlesShader->setUniform("textureMap", *textureManager.getTexture("particle.png"));

    sf::Shader::bind(particlesShader);
    particlesShader->setUniform("color", sf::Glsl::Vec4(r, g, b, size / 32.0f));
    gl::ScopedBufferBinding vbo(GL_ARRAY_BUFFER, particlesBuffers[0]);
    gl::ScopedBufferBinding ebo(GL_ELEMENT_ARRAY_BUFFER, particlesBuffers[1]);
    gl::ScopedVertexAttribArray positions(particlesShaderPositionAttribute);
    gl::ScopedVertexAttribArray texcoords(particlesShaderTexCoordsAttribute);

    // Set up attribs
    glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(sf::Vector3f), (GLvoid*)0);
    glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(sf::Vector2f), (GLvoid*)(vertices.size() * sizeof(sf::Vector3f)));


    const size_t quad_count = max_quad_count;
    // We're drawing particles `quad_count` at a time.
    for (size_t n = 0; n < particleCount;)
    {
        auto active_quads = std::min(quad_count, particleCount - n);
        // setup quads
        for (auto p = 0; p < active_quads; ++p)
        {
            sf::Vector3f v = particleDirections[n + p] * scale * size;
            vertices[4 * p + 0] = v;
            vertices[4 * p + 1] = v;
            vertices[4 * p + 2] = v;
            vertices[4 * p + 3] = v;
        }

        // upload
        glBufferSubData(GL_ARRAY_BUFFER, 0, vertices.size() * sizeof(sf::Vector3f), vertices.data());
        
        glDrawElements(GL_TRIANGLES, 6 * active_quads, GL_UNSIGNED_BYTE, nullptr);
        n += active_quads;
    }
}
#endif//FEATURE_3D_RENDERING

void ElectricExplosionEffect::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range)
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
        soundManager->playSound("sfx/emp_explosion.wav", getPosition(), size * 2, 60.0);
    lifetime -= delta;
    if (lifetime < 0)
        destroy();
}
