#include <GL/glew.h>
#include <SFML/OpenGL.hpp>
#include "main.h"
#include "featureDefs.h"
#include "particleEffect.h"

ParticleEngine* ParticleEngine::particleEngine = nullptr;

#if FEATURE_3D_RENDERING
// Helper function, to avoid verbose casting.
template<typename Enum>
static constexpr typename std::underlying_type<Enum>::type as_index(Enum entry)
{
    return static_cast<typename std::underlying_type<Enum>::type>(entry);
}
#endif // FEATURE_3D_RENDERING


void ParticleEngine::render()
{
#if FEATURE_3D_RENDERING
    if (particleEngine)
        particleEngine->doRender();
#endif
}

void ParticleEngine::update(float delta)
{
#if FEATURE_3D_RENDERING
    // Update particles, move all freshly expired particles to the end.
    // Update our first_expired entry.
    first_expired = std::partition(std::begin(particles), first_expired, [delta](Particle& p)
    {
        p.life_time += delta;
        return p.life_time <= p.max_life_time;
    });
#endif // FEATURE_3D_RENDERING
}

void ParticleEngine::spawn(sf::Vector3f position, sf::Vector3f end_position, sf::Vector3f color, sf::Vector3f end_color, float size, float end_size, float life_time)
{
#if FEATURE_3D_RENDERING
    if (sf::length(position - camera_position) / (size + end_size) < 0.1)
        return;

    if (!particleEngine)
        particleEngine = new ParticleEngine();

    particleEngine->doSpawn(position, end_position, color, end_color, size, end_size, life_time);
#endif
}


#if FEATURE_3D_RENDERING
ParticleEngine::ParticleEngine()
    :first_expired{ std::end(particles) }
{
    if (gl::isAvailable())
    {
        
        // Cache shader info.
        shader = ShaderManager::getShader("shaders/particles");
        shaderVertexIDAttribute = glGetAttribLocation(shader->getNativeHandle(), "vertex_id");

        uniforms[as_index(Uniforms::Centers)] = glGetUniformLocation(shader->getNativeHandle(), "centers");
        uniforms[as_index(Uniforms::ColorAndSizes)] = glGetUniformLocation(shader->getNativeHandle(), "color_and_sizes");


        std::array<uint8_t, instances_per_draw * elements_per_instance> elements;

        // Per vertex data are... the vertex indices.
        // This is because ES2 does not have VertexID in the shader (so we need to pass it down by hand).
        std::array<uint8_t, max_vertex_count> vertex_ids; // 4 vertices (quads) per particle.

        // Hitting this means either needing to lower the number of instances / vertices per instance,
        // Or switch the element index to a uint16_t.
        static_assert((vertex_ids.size() - 1) <= std::numeric_limits<uint8_t>::max(), "Too many elements! Indices overflow.");

        for (auto quad = 0; quad < instances_per_draw; ++quad)
        {
            auto base_vertex = static_cast<uint8_t>(vertices_per_instance * quad);
            auto base_element = elements_per_instance * quad;

            // Each quad is two triangles
            elements[base_element + 0] = base_vertex + 0;
            elements[base_element + 1] = base_vertex + 1;
            elements[base_element + 2] = base_vertex + 2;
            elements[base_element + 3] = base_vertex + 2;
            elements[base_element + 4] = base_vertex + 3;
            elements[base_element + 5] = base_vertex + 0;

            for (auto v = 0; v < 4; ++v)
                vertex_ids[base_vertex + v] = base_vertex + v;
        }

        // Hand off to the GPU.
        gl::ScopedBufferBinding element_buffer(GL_ELEMENT_ARRAY_BUFFER, buffers[as_index(Buffers::Element)]);
        gl::ScopedBufferBinding vertex_buffer(GL_ARRAY_BUFFER, buffers[as_index(Buffers::Vertex)]);

        glBufferData(GL_ELEMENT_ARRAY_BUFFER, elements.size() * sizeof(uint8_t), elements.data(), GL_STATIC_DRAW);
        glBufferData(GL_ARRAY_BUFFER, vertex_ids.size() * sizeof(uint8_t), vertex_ids.data(), GL_STATIC_DRAW);
    }
}


void ParticleEngine::doRender()
{
    shader->setUniform("textureMap", *textureManager.getTexture("particle.png"));

    sf::Shader::bind(shader);

    {
        std::array<sf::Glsl::Vec3, instances_per_draw> positions;
        std::array<sf::Glsl::Vec4, instances_per_draw> color_and_sizes;

        gl::ScopedVertexAttribArray ids(shaderVertexIDAttribute);
        gl::ScopedBufferBinding element_buffer(GL_ELEMENT_ARRAY_BUFFER, particleEngine->buffers[as_index(Buffers::Element)]);
        gl::ScopedBufferBinding vertex_buffer(GL_ARRAY_BUFFER, particleEngine->buffers[as_index(Buffers::Vertex)]);

        glVertexAttribPointer(ids.get(), 1, GL_UNSIGNED_BYTE, GL_FALSE, 0, (GLvoid*)0);

        // Process only non-expired
        size_t live_particle_count = first_expired - std::begin(particles);

        for (size_t n = 0; n < live_particle_count;)
        {
            auto instance_count = std::min(live_particle_count - n, positions.size());

            // setup the instances (individual particles)
            for (auto instance = 0; instance < instance_count; ++instance)
            {
                const auto& p = particles[n + instance];
                auto position = Tween<sf::Vector3f>::easeOutQuad(p.life_time, 0, p.max_life_time, p.start.position, p.end.position);
                auto color = Tween<sf::Vector3f>::easeOutQuad(p.life_time, 0, p.max_life_time, p.start.color, p.end.color);
                auto size = Tween<float>::easeOutQuad(p.life_time, 0, p.max_life_time, p.start.size, p.end.size);

                positions[instance] = sf::Glsl::Vec3(position);
                color_and_sizes[instance] = sf::Glsl::Vec4(color.x, color.y, color.z, size);
            }

            // Send instances to shader.
            glUniform3fv(uniforms[as_index(Uniforms::Centers)], positions.size(), reinterpret_cast<const float*>(positions.data()));
            glUniform4fv(uniforms[as_index(Uniforms::ColorAndSizes)], color_and_sizes.size(), reinterpret_cast<const float*>(color_and_sizes.data()));

            // Draw our instances
            glDrawElements(GL_TRIANGLES, static_cast<GLsizei>(elements_per_instance * instance_count), GL_UNSIGNED_BYTE, nullptr);
            n += instance_count;
        }
    }
    sf::Shader::bind(NULL);
}

void ParticleEngine::doSpawn(sf::Vector3f position, sf::Vector3f end_position, sf::Vector3f color, sf::Vector3f end_color, float size, float end_size, float life_time)
{
    if (first_expired == std::end(particles))
    {
        // No expired particles - add more.
        constexpr size_t batch_size = 64;
        particles.resize(particles.size() + batch_size);
        first_expired = std::end(particles) - batch_size;
    }

    // Update particle at first_expired.
    first_expired->start.position = position;
    first_expired->end.position = end_position;
    first_expired->start.color = color;
    first_expired->end.color = end_color;
    first_expired->start.size = size;
    first_expired->end.size = end_size;
    first_expired->life_time = 0.f;
    first_expired->max_life_time = life_time;

    ++first_expired;
}
#endif // FEATURE_3D_RENDERING
