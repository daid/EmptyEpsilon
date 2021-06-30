#include <GL/glew.h>
#include <SFML/OpenGL.hpp>
#include "main.h"
#include "explosionEffect.h"
#include "glObjects.h"

#if FEATURE_3D_RENDERING
gl::Buffers<2> ExplosionEffect::particlesBuffers(gl::Unitialized{});
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
        particleDirections[n] = glm::normalize(glm::vec3(random(-1, 1), random(-1, 1), random(-1, 1))) * random(0.8, 1.2);

    registerMemberReplication(&size);
    registerMemberReplication(&on_radar);
#if FEATURE_3D_RENDERING
    if (!particlesBuffers[0] && gl::isAvailable())
    {
        particlesBuffers = gl::Buffers<2>();


        // Each vertex is a position and a texcoords.
        // The two arrays are maintained separately (texcoords are fixed, vertices position change).
        constexpr size_t vertex_size = sizeof(glm::vec3) + sizeof(glm::vec2);
        gl::ScopedBufferBinding vbo(GL_ARRAY_BUFFER, particlesBuffers[0]);
        gl::ScopedBufferBinding ebo(GL_ELEMENT_ARRAY_BUFFER, particlesBuffers[1]);

        // VBO
        glBufferData(GL_ARRAY_BUFFER, max_quad_count * 4 * vertex_size, nullptr, GL_DYNAMIC_DRAW);

        // Create initial data.
        std::array<uint8_t, 6 * max_quad_count> indices;
        std::array<glm::vec2, 4 * max_quad_count> texcoords;
        for (auto i = 0U; i < max_quad_count; ++i)
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
        glBufferSubData(GL_ARRAY_BUFFER, max_quad_count * 4 * sizeof(glm::vec3), texcoords.size() * sizeof(glm::vec2), texcoords.data());
        // Upload indices
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(uint8_t), indices.data(), GL_STATIC_DRAW);

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
    }
    else {
        scale = Tween<float>::easeOutQuad(f, 0.2, 1.0, 1.0f, 1.3f);
        alpha = Tween<float>::easeInQuad(f, 0.2, 1.0, 0.5f, 0.0f);
    }

    std::array<glm::vec3, 4 * max_quad_count> vertices;

    glPushMatrix();
    ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::Basic);

    

    // Explosion sphere
    {
        glBindTexture(GL_TEXTURE_2D, textureManager.getTexture("fire_sphere_texture.png")->getNativeHandle());

        glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), alpha, alpha, alpha, 1.f);

        gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
        gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));
        gl::ScopedVertexAttribArray normals(shader.get().attribute(ShaderRegistry::Attributes::Normal));

        Mesh* m = Mesh::getMesh("sphere.obj");
        glScalef(scale * size, scale * size, scale * size);
        m->render(positions.get(), texcoords.get(), normals.get());
    }

    gl::ScopedBufferBinding vbo(GL_ARRAY_BUFFER, particlesBuffers[0]);
    gl::ScopedBufferBinding ebo(GL_ELEMENT_ARRAY_BUFFER, particlesBuffers[1]);

    // Fire ring
    {
        glBindTexture(GL_TEXTURE_2D, textureManager.getTexture("fire_ring.png")->getNativeHandle());
        glScalef(1.5f, 1.5f, 1.5f);

        vertices[0] = glm::vec3(-1, -1, 0);
        vertices[1] = glm::vec3(1, -1, 0);
        vertices[2] = glm::vec3(1, 1, 0);
        vertices[3] = glm::vec3(-1, 1, 0);
        {
            gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
            gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));

            glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(glm::vec3), (GLvoid*)0);
            glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(glm::vec2), (GLvoid*)(vertices.size() * sizeof(glm::vec3)));

            // upload single vertex
            glBufferSubData(GL_ARRAY_BUFFER, 0, 4 * sizeof(glm::vec3), vertices.data());

            glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, nullptr);
        }
    }
    glPopMatrix();

    shader = ShaderRegistry::ScopedShader(ShaderRegistry::Shaders::Billboard);

    gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));

    glBindTexture(GL_TEXTURE_2D, textureManager.getTexture("particle.png")->getNativeHandle());

    scale = Tween<float>::easeInCubic(f, 0.0, 1.0, 0.3f, 5.0f);
    float r = Tween<float>::easeInQuad(f, 0.0, 1.0, 1.0f, 0.0f);
    float g = Tween<float>::easeOutQuad(f, 0.0, 1.0, 1.0f, 0.0f);
    float b = Tween<float>::easeOutQuad(f, 0.0, 1.0, 1.0f, 0.0f);
    glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), r, g, b, size / 32.0f);

    glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(glm::vec3), (GLvoid*)0);
    glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(glm::vec2), (GLvoid*)(vertices.size() * sizeof(glm::vec3)));

    const size_t quad_count = max_quad_count;
    // We're drawing particles `quad_count` at a time.
    for(size_t n = 0; n<particleCount;)
    {
        auto active_quads = std::min(quad_count, particleCount - n);
        // setup quads
        for (auto p = 0U; p < active_quads; ++p)
        {
            glm::vec3 v = particleDirections[n + p] * scale * size;
            vertices[4 * p + 0] = v;
            vertices[4 * p + 1] = v;
            vertices[4 * p + 2] = v;
            vertices[4 * p + 3] = v;
        }
        // upload
        glBufferSubData(GL_ARRAY_BUFFER, 0, vertices.size() * sizeof(glm::vec3), vertices.data());
        
        glDrawElements(GL_TRIANGLES, 6 * active_quads, GL_UNSIGNED_BYTE, nullptr);
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
