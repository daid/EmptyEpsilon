#include <GL/glew.h>
#include "main.h"
#include "featureDefs.h"
#include "particleEffect.h"

#include <glm/gtc/type_ptr.hpp>

ParticleEngine* ParticleEngine::particleEngine = nullptr;

#if FEATURE_3D_RENDERING
// Helper function, to avoid verbose casting.
template<typename Enum>
static constexpr typename std::underlying_type<Enum>::type as_index(Enum entry)
{
    return static_cast<typename std::underlying_type<Enum>::type>(entry);
}
#endif // FEATURE_3D_RENDERING


void ParticleEngine::render(const glm::mat4& projection)
{
#if FEATURE_3D_RENDERING
    if (particleEngine)
        particleEngine->doRender(projection);
#endif//FEATURE_3D_RENDERING
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

void ParticleEngine::spawn(glm::vec3 position, glm::vec3 end_position, glm::vec3 color, glm::vec3 end_color, float size, float end_size, float life_time)
{
#if FEATURE_3D_RENDERING
    if (glm::length2(position - camera_position) / (size + end_size) < 0.1f*0.1f)
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
        buffers = gl::Buffers<static_cast<size_t>(Buffers::Count)>{};
        // Cache shader info.
        shader = ShaderManager::getShader("shaders/particles");

        auto handle = shader->getNativeHandle();
        glValidateProgram(handle);

        uniforms[as_index(Uniforms::Projection)] = glGetUniformLocation(shader->getNativeHandle(), "projection");
        uniforms[as_index(Uniforms::ModelView)] = glGetUniformLocation(shader->getNativeHandle(), "model_view");

        attributes[as_index(Attributes::Center)] = glGetAttribLocation(shader->getNativeHandle(), "center");
        attributes[as_index(Attributes::TexCoords)] = glGetAttribLocation(shader->getNativeHandle(), "texcoords");
        attributes[as_index(Attributes::Color)] = glGetAttribLocation(shader->getNativeHandle(), "color");
        attributes[as_index(Attributes::Size)] = glGetAttribLocation(shader->getNativeHandle(), "size");

        std::array<uint8_t, instances_per_draw * elements_per_instance> elements;

        std::array<glm::vec2, max_vertex_count> texcoords{};

        // Hitting this means either needing to lower the number of instances / vertices per instance,
        // Or switch the element index to a uint16_t.
        static_assert((texcoords.size() - 1) <= std::numeric_limits<uint8_t>::max(), "Too many elements! Indices overflow.");

        for (auto quad = 0U; quad < instances_per_draw; ++quad)
        {
            auto base_vertex = static_cast<uint8_t>(vertices_per_instance * quad);
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
            texcoords[base_vertex + 0] = { 0.f, 1.f };
            texcoords[base_vertex + 1] = { 1.f, 1.f };
            texcoords[base_vertex + 2] = { 1.f, 0.f };
            texcoords[base_vertex + 3] = { 0.f, 0.f };
        }

        // Hand off to the GPU.
        gl::ScopedBufferBinding element_buffer(GL_ELEMENT_ARRAY_BUFFER, buffers[as_index(Buffers::Element)]);
        gl::ScopedBufferBinding vertex_buffer(GL_ARRAY_BUFFER, buffers[as_index(Buffers::Vertex)]);

        glBufferData(GL_ELEMENT_ARRAY_BUFFER, elements.size() * sizeof(uint8_t), elements.data(), GL_STATIC_DRAW);
        glBufferData(GL_ARRAY_BUFFER, max_vertex_count * (sizeof(ParticleData) + sizeof(glm::vec2)), nullptr, GL_DYNAMIC_DRAW);
        {
            // Ensure zero-initialization of the particle data.
            std::array<ParticleData, max_vertex_count> particle_data{};
            glBufferSubData(GL_ARRAY_BUFFER, 0, particle_data.size() * sizeof(ParticleData), particle_data.data());

            // Upload texcoords once.
            glBufferSubData(GL_ARRAY_BUFFER, particle_data.size() * sizeof(ParticleData), texcoords.size() * sizeof(glm::vec2), texcoords.data());
        }
    }
}


void ParticleEngine::doRender(const glm::mat4& projection)
{
    sf::Shader::bind(shader);

    // Setup shared state:
    // - Texture
    gl::ScopedTexture particle_texture(GL_TEXTURE_2D, textureManager.getTexture("particle.png")->getNativeHandle());

    // - Matrices
    glUniformMatrix4fv(uniforms[as_index(Uniforms::Projection)], 1, GL_FALSE, glm::value_ptr(projection));

    std::array<float, 4*4> matrix;
    glGetFloatv(GL_MODELVIEW_MATRIX, matrix.data());
    glUniformMatrix4fv(uniforms[as_index(Uniforms::ModelView)], 1, GL_FALSE, matrix.data());
    
    {
        std::vector<ParticleData> particle_data(max_vertex_count);

        gl::ScopedVertexAttribArray centers(particleEngine->attributes[as_index(Attributes::Center)]);
        gl::ScopedVertexAttribArray texcoords(particleEngine->attributes[as_index(Attributes::TexCoords)]);
        gl::ScopedVertexAttribArray colors(particleEngine->attributes[as_index(Attributes::Color)]);
        gl::ScopedVertexAttribArray sizes(particleEngine->attributes[as_index(Attributes::Size)]);
        gl::ScopedBufferBinding element_buffer(GL_ELEMENT_ARRAY_BUFFER, particleEngine->buffers[as_index(Buffers::Element)]);
        gl::ScopedBufferBinding vertex_buffer(GL_ARRAY_BUFFER, particleEngine->buffers[as_index(Buffers::Vertex)]);

        glVertexAttribPointer(centers.get(), 3, GL_FLOAT, GL_FALSE, sizeof(ParticleData), reinterpret_cast<const GLvoid *>(offsetof(ParticleData, position)));
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(glm::vec2), reinterpret_cast<const GLvoid*>(max_vertex_count * sizeof(ParticleData)));
        glVertexAttribPointer(colors.get(), 3, GL_FLOAT, GL_FALSE, sizeof(ParticleData), reinterpret_cast<const GLvoid*>(offsetof(ParticleData, color)));
        glVertexAttribPointer(sizes.get(), 1, GL_FLOAT, GL_FALSE, sizeof(ParticleData), reinterpret_cast<const GLvoid*>(offsetof(ParticleData, size)));
 
        // Process only non-expired
        size_t live_particle_count = first_expired - std::begin(particles);

        for (size_t n = 0U; n < live_particle_count;)
        {
            auto instance_count = std::min(live_particle_count - n, instances_per_draw);

            // setup the instances (individual particles)
            for (auto instance = 0U; instance < instance_count; ++instance)
            {
                const auto& p = particles[n + instance];
                auto position = Tween<glm::vec3>::easeOutQuad(p.life_time, 0, p.max_life_time, p.start.position, p.end.position);
                auto color = Tween<glm::vec3>::easeOutQuad(p.life_time, 0, p.max_life_time, p.start.color, p.end.color);
                auto size = Tween<float>::easeOutQuad(p.life_time, 0, p.max_life_time, p.start.size, p.end.size);

                auto base_vertex = vertices_per_instance * instance;
                for (auto v = 0U; v < vertices_per_instance; ++v)
                {
                    particle_data[base_vertex + v].position = position;
                    particle_data[base_vertex + v].color = color;
                    particle_data[base_vertex + v].size = size;
                }
            }

            // Send instances to shader.
            glBufferSubData(GL_ARRAY_BUFFER, 0, instance_count * vertices_per_instance * sizeof(ParticleData), particle_data.data());
        
            // Draw our instances
            glDrawElements(GL_TRIANGLES, static_cast<GLsizei>(elements_per_instance * instance_count), GL_UNSIGNED_BYTE, nullptr);
            
            n += instance_count;
        }
    }
    sf::Shader::bind(nullptr);
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
#endif // FEATURE_3D_RENDERING
