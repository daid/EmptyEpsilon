#include <graphics/opengl.h>
#include "main.h"
#include "featureDefs.h"
#include "particleEffect.h"
#include "shaderManager.h"
#include "textureManager.h"
#include "tween.h"

#include <SDL_assert.h>

#include <glm/gtx/norm.hpp>
#include <glm/gtc/type_ptr.hpp>

ParticleEngine* ParticleEngine::particleEngine = nullptr;

// Helper function, to avoid verbose casting.
template<typename Enum>
static constexpr typename std::underlying_type<Enum>::type as_index(Enum entry)
{
    return static_cast<typename std::underlying_type<Enum>::type>(entry);
}


void ParticleEngine::render(const glm::mat4& projection, const glm::mat4& view)
{
    if (particleEngine)
        particleEngine->doRender(projection, view);
}

void ParticleEngine::update(float delta)
{
    // Update particles, move all freshly expired particles to the end.
    // Update our first_expired entry.
    first_expired = std::partition(std::begin(particles), first_expired, [delta](Particle& p)
    {
        p.life_time += delta;
        return p.life_time <= p.max_life_time;
    });
}

void ParticleEngine::spawn(glm::vec3 position, glm::vec3 end_position, glm::vec3 color, glm::vec3 end_color, float size, float end_size, float life_time)
{
    if (glm::length2(position - camera_position) / (size + end_size) < 0.1f*0.1f)
        return;

    if (!particleEngine)
        particleEngine = new ParticleEngine();

    particleEngine->doSpawn(position, end_position, color, end_color, size, end_size, life_time);
}

ParticleEngine::ParticleEngine()
    :first_expired{ std::end(particles) }
{
    buffers = gl::Buffers<static_cast<size_t>(Buffers::Count)>{};
    // Cache shader info.
    shader = ShaderManager::getShader("shaders/particles");

    shader->bind();

    uniforms[as_index(Uniforms::Projection)] = shader->getUniformLocation("projection");
    uniforms[as_index(Uniforms::View)] = shader->getUniformLocation("view");

    attributes[as_index(Attributes::CenterAndSize)] = shader->getAttributeLocation("center_and_size");
    attributes[as_index(Attributes::TexCoords)] = shader->getAttributeLocation("texcoords");
    attributes[as_index(Attributes::Color)] = shader->getAttributeLocation("color");

    std::vector<uint16_t> elements(instances_per_draw * elements_per_instance);
    texcoords_data.resize(max_vertex_count);
    particle_data.resize(max_vertex_count);
    for (auto quad = 0U; quad < instances_per_draw; ++quad)
    {
        auto base_vertex = static_cast<uint16_t>(vertices_per_instance * quad);
        auto base_element = elements_per_instance * quad;

        // Each quad is two triangles
        elements[base_element + 0] = base_vertex + 0;
        elements[base_element + 1] = base_vertex + 3;
        elements[base_element + 2] = base_vertex + 2;
        elements[base_element + 3] = base_vertex + 0;
        elements[base_element + 4] = base_vertex + 2;
        elements[base_element + 5] = base_vertex + 1;

        // Setup texcoords.
        // OpenGL origin is bottom left.
        texcoords_data[base_vertex + 0] = { 0, 1 };
        texcoords_data[base_vertex + 1] = { 1, 1 };
        texcoords_data[base_vertex + 2] = { 1, 0 };
        texcoords_data[base_vertex + 3] = { 0, 0 };
    }

    // Hand off to the GPU.
    gl::ScopedBufferBinding element_buffer(GL_ELEMENT_ARRAY_BUFFER, buffers[as_index(Buffers::Element)]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, elements.size() * sizeof(uint16_t), elements.data(), GL_STATIC_DRAW);
}


void ParticleEngine::doRender(const glm::mat4& projection, const glm::mat4& view)
{
    shader->bind();

    // Setup shared state:
    // - Texture
    textureManager.getTexture("particle.png")->bind();

    // - Matrices
    glUniformMatrix4fv(uniforms[as_index(Uniforms::Projection)], 1, GL_FALSE, glm::value_ptr(projection));
    glUniformMatrix4fv(uniforms[as_index(Uniforms::View)], 1, GL_FALSE, glm::value_ptr(view));
    
    {
        gl::ScopedVertexAttribArray centers_and_sizes(attributes[as_index(Attributes::CenterAndSize)]);
        gl::ScopedVertexAttribArray texcoords(attributes[as_index(Attributes::TexCoords)]);
        gl::ScopedVertexAttribArray colors(attributes[as_index(Attributes::Color)]);

        gl::ScopedBufferBinding element_buffer(GL_ELEMENT_ARRAY_BUFFER, buffers[as_index(Buffers::Element)]);
        gl::ScopedBufferBinding vertex_buffer(GL_ARRAY_BUFFER, buffers[as_index(Buffers::Vertex)]);

        
        glVertexAttribPointer(centers_and_sizes.get(), 4, GL_FLOAT, GL_FALSE, sizeof(ParticleRenderData), reinterpret_cast<const GLvoid*>(offsetof(ParticleRenderData, position_and_size)));
        glVertexAttribPointer(colors.get(), 3, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(ParticleRenderData), reinterpret_cast<const GLvoid*>(offsetof(ParticleRenderData, color)));
        
        constexpr auto texcoords_start_offset = max_vertex_count * sizeof(ParticleRenderData);
        glVertexAttribPointer(texcoords.get(), 2, GL_UNSIGNED_BYTE, GL_FALSE, sizeof(glm::u8vec2), reinterpret_cast<const GLvoid*>(texcoords_start_offset));

        // Process only non-expired
        size_t live_particle_count = first_expired - std::begin(particles);
        for (size_t n = 0U; n < live_particle_count;)
        {
            auto instance_count = std::min(live_particle_count - n, instances_per_draw);
            auto total_vertex_count = instance_count * vertices_per_instance; 

            // setup the instances (individual particles)
            for (auto instance = 0U; instance < instance_count; ++instance)
            {
                const auto& p = particles[n + instance];
                auto position = Tween<glm::vec3>::easeOutQuad(p.life_time, 0, p.max_life_time, p.start.position, p.end.position);
                auto color = 255.f * Tween<glm::vec3>::easeOutQuad(p.life_time, 0, p.max_life_time, p.start.color, p.end.color);
                auto size = Tween<float>::easeOutQuad(p.life_time, 0, p.max_life_time, p.start.size, p.end.size);

                glm::vec4 position_and_size(position, size);
                auto base_vertex = vertices_per_instance * instance;
                for (auto v = 0U; v < vertices_per_instance; ++v)
                {
                    particle_data[base_vertex + v].position_and_size = position_and_size;
                    particle_data[base_vertex + v].color = color;
                }
            }

            // Orphan+reacquire.
            // See https://www.khronos.org/opengl/wiki/Buffer_Object_Streaming#Buffer_re-specification for more details.
            glBufferData(GL_ARRAY_BUFFER, max_vertex_count * (sizeof(ParticleRenderData) + sizeof(glm::u8vec2)), nullptr, GL_STREAM_DRAW);
            glBufferSubData(GL_ARRAY_BUFFER, 0, total_vertex_count * sizeof(ParticleRenderData), particle_data.data());
            glBufferSubData(GL_ARRAY_BUFFER, texcoords_start_offset, total_vertex_count * sizeof(glm::u8vec2), texcoords_data.data());
            
            // Draw our instances
            glDrawElements(GL_TRIANGLES, static_cast<GLsizei>(elements_per_instance * instance_count), GL_UNSIGNED_SHORT, nullptr);

            n += instance_count;
        }
    }
}

void ParticleEngine::doSpawn(glm::vec3 position, glm::vec3 end_position, glm::vec3 color, glm::vec3 end_color, float size, float end_size, float life_time)
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
