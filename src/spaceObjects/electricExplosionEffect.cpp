#include <graphics/opengl.h>
#include <glm/gtc/type_ptr.hpp>
#include "main.h"
#include "electricExplosionEffect.h"
#include "glObjects.h"
#include "shaderRegistry.h"
#include "random.h"
#include "tween.h"
#include "soundManager.h"
#include "textureManager.h"
#include "components/collision.h"

/// An ElectricExplosionEffect is a visual electrical explosion used by EMP missiles.
/// This is a cosmetic effect and does not deal damage on its own.
/// See also the ExplosionEffect class for conventional explosion effects.
/// Example: elec_explosion = ElectricExplosionEffect():setPosition(500,5000):setSize(20):setOnRadar(true)
REGISTER_SCRIPT_SUBCLASS(ElectricExplosionEffect, SpaceObject)
{
    /// Sets the ElectricExplosionEffect's radius.
    /// Defaults to 1.0.
    /// Example: elec_explosion:setSize(1000) -- sets the explosion radius to 1U
    REGISTER_SCRIPT_CLASS_FUNCTION(ElectricExplosionEffect, setSize);
    /// Defines whether to draw the ElectricExplosionEffect on short-range radar.
    /// Defaults to false.
    /// Example: elec_explosion:setOnRadar(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(ElectricExplosionEffect, setOnRadar);
}

REGISTER_MULTIPLAYER_CLASS(ElectricExplosionEffect, "ElectricExplosionEffect");
ElectricExplosionEffect::ElectricExplosionEffect()
: SpaceObject(1000.0, "ElectricExplosionEffect")
{
    on_radar = false;
    size = 1.f;

    entity.removeComponent<sp::Physics>(); //TODO: Never add this in the first place.
    lifetime = maxLifetime;
    for(int n=0; n<particleCount; n++)
        particleDirections[n] = glm::normalize(glm::vec3(random(-1, 1), random(-1, 1), random(-1, 1))) * random(0.8f, 1.2f);

    registerMemberReplication(&size);
    registerMemberReplication(&on_radar);

    static_assert(4 * max_quad_count <= std::numeric_limits<uint16_t>::max(), "Quad count is too large, busts u16 indices size!");
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
ElectricExplosionEffect::~ElectricExplosionEffect()
{
}

void ElectricExplosionEffect::draw3DTransparent()
{
    float f = (1.0f - (lifetime / maxLifetime));
    float scale;
    float alpha = 0.5f;
    if (f < 0.2f)
    {
        scale = (f / 0.2f) * 0.8f;
    }else{
        scale = Tween<float>::easeOutQuad(f, 0.2f, 1.f, 0.8f, 1.0f);
        alpha = Tween<float>::easeInQuad(f, 0.2f, 1.f, 0.5f, 0.0f);
    }

    auto model_matrix = getModelMatrix();
    auto explosion_matrix = glm::scale(model_matrix, glm::vec3(scale * size));
    ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::Basic);

    Mesh* m = Mesh::getMesh("mesh/sphere.obj");
    {
        glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(explosion_matrix));
        glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), alpha, alpha, alpha, 1.f);
        textureManager.getTexture("texture/electric_sphere_texture.png")->bind();

        gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
        gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));
        gl::ScopedVertexAttribArray normals(shader.get().attribute(ShaderRegistry::Attributes::Normal));

        m->render(positions.get(), texcoords.get(), normals.get());

        glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(glm::scale(explosion_matrix, glm::vec3(.5f))));
        m->render(positions.get(), texcoords.get(), normals.get());
        
    }

    scale = Tween<float>::easeInCubic(f, 0.f, 1.f, 0.3f, 3.0f);
    float r = Tween<float>::easeOutQuad(f, 0.f, 1.f, 1.0f, 0.0f);
    float g = Tween<float>::easeOutQuad(f, 0.f, 1.f, 1.0f, 0.0f);
    float b = Tween<float>::easeInQuad(f, 0.f, 1.f, 1.0f, 0.0f);

    std::vector<glm::vec3> vertices(4 * max_quad_count);

    textureManager.getTexture("particle.png")->bind();

    shader = ShaderRegistry::ScopedShader(ShaderRegistry::Shaders::Billboard);

    glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));

    gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));

    glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), r, g, b, size / 32.0f);

    if (!particlesBuffers[0])
        initializeParticles();

    gl::ScopedBufferBinding vbo(GL_ARRAY_BUFFER, particlesBuffers[0]);
    gl::ScopedBufferBinding ebo(GL_ELEMENT_ARRAY_BUFFER, particlesBuffers[1]);
    

    // Set up attribs
    glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(glm::vec3), (GLvoid*)0);
    glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(glm::vec2), (GLvoid*)(vertices.size() * sizeof(glm::vec3)));


    const size_t quad_count = max_quad_count;
    // We're drawing particles `quad_count` at a time.
    for (size_t n = 0; n < particleCount;)
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
        
        glDrawElements(GL_TRIANGLES, static_cast<GLsizei>(6 * active_quads), GL_UNSIGNED_SHORT, nullptr);
        n += active_quads;
    }
}

void ElectricExplosionEffect::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    if (!on_radar)
        return;
    if (long_range)
        return;

    renderer.fillCircle(position, size * scale, glm::u8vec4(0, 0, 255, 64 * (lifetime / maxLifetime)));
}

void ElectricExplosionEffect::update(float delta)
{
    if (delta > 0 && lifetime == maxLifetime)
        soundManager->playSound("sfx/emp_explosion.wav", getPosition(), size * 2, 0.6);
    lifetime -= delta;
    if (lifetime < 0)
        destroy();
}

void ElectricExplosionEffect::initializeParticles()
{
    particlesBuffers = gl::Buffers<2>();


    // Each vertex is a position and a texcoords.
    // The two arrays are maintained separately (texcoords are fixed, vertices position change).
    constexpr size_t vertex_size = sizeof(glm::vec3) + sizeof(glm::vec2);
    gl::ScopedBufferBinding vbo(GL_ARRAY_BUFFER, particlesBuffers[0]);
    gl::ScopedBufferBinding ebo(GL_ELEMENT_ARRAY_BUFFER, particlesBuffers[1]);

    // VBO
    glBufferData(GL_ARRAY_BUFFER, max_quad_count * 4 * vertex_size, nullptr, GL_STREAM_DRAW);

    // Create initial data.
    std::vector<uint16_t> indices(6 * max_quad_count);
    std::vector<glm::vec2> texcoords(4* max_quad_count);
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
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(uint16_t), indices.data(), GL_STATIC_DRAW);
}
