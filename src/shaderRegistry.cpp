#include "shaderRegistry.h"

#include <cassert>
#include <tuple>

#include <graphics/opengl.h>
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>

#include "logging.h"
#include "shaderManager.h"

namespace ShaderRegistry
{
    namespace
    {
        std::array<Shader, Shaders_t(Shaders::Count)> shaders;
        glm::mat4 projection;
        glm::mat4 view;
        glm::vec3 camera; // World space camera position.
    }

    bool Shader::initialize()
    {
        std::array<const char*, Shaders_t(Shaders::Count)> shader_names{
            "shaders/basic",
            "shaders/basicColor",
            "shaders/billboard",
            "shaders/objectShader",
            "shaders/objectShader:ILLUMINATION",
            "shaders/objectShader:SPECULAR",
            "shaders/objectShader:ILLUMINATION:SPECULAR",
            "shaders/planet"
        };

        std::array<const char*, Uniforms_t(Uniforms::Count)> uniform_names{
            "color",
            "model_view_projection",
            "projection",
            "model",
            "view",
            "camera_position",
            "atmosphereColor",
            
            "textureMap",
            "baseMap",
            "specularMap",
            "illuminationMap",

            "ambientLightDirection",
            "specularLightDirection"
        };

        std::array<const char*, Attributes_t(Attributes::Count)> attribute_names{
            "position",
            "texcoords",
            "normal"
        };

        std::array<std::tuple<Uniforms, int32_t>, 4> texture_units{
            std::make_tuple(Uniforms::TextureMap, 0),
            std::make_tuple(Uniforms::BaseMap, 0),
            std::make_tuple(Uniforms::SpecularMap, 1),
            std::make_tuple(Uniforms::IlluminationMap, 2),
        };

        for (auto i = 0U; i < shader_names.size(); ++i)
        {
            auto& entry = shaders[i];
            entry.shader = ShaderManager::getShader(shader_names[i]);

            if (!entry.shader)
                return false;
            
            if (entry.shader)
            {
                entry.get()->bind();

                // First update attribute locations.
                for (auto attrib = 0U; attrib < attribute_names.size(); ++attrib)
                {
                    entry.attributes[attrib] = entry.get()->getAttributeLocation(attribute_names[attrib]);
                }

                // Find out uniform locations
                for (auto uniform = 0U; uniform < uniform_names.size(); ++uniform)
                {
                    entry.uniforms[uniform] = entry.get()->getUniformLocation(uniform_names[uniform]);
                }

                // Lockdown texture locations.
                for (const auto& unit : texture_units)
                {
                    auto location = entry.uniform(std::get<0>(unit));
                    if (location != -1)
                    {
                        glUniform1i(location, std::get<1>(unit));
                    }
                }
                glUseProgram(GL_NONE);
            }
        }
        return true;
    }

    const Shader& get(Shaders shader)
    {
        return shaders[Shaders_t(shader)];
    }

    void updateProjectionView(std::optional<std::reference_wrapper<const glm::mat4>> projection_in, std::optional<std::reference_wrapper<const glm::mat4>> view_in)
    {
        const auto has_projection = projection_in.has_value();
        const auto has_view = view_in.has_value();
        if (has_projection)
            projection = projection_in.value();
        if (has_view)
        {
            view = view_in.value();
            camera = glm::inverse(view)[3];
        }
            
        for (auto i = 0; i < Shaders_t(Shaders::Count); ++i)
        {
            auto& shader = get(Shaders(i));
            auto projection_location = shader.uniform(Uniforms::Projection);
            auto view_location = shader.uniform(Uniforms::View);
            if (projection_location != -1 || view_location != -1)
            {
                shader.get()->bind();

                if (has_projection && projection_location != -1)
                    glUniformMatrix4fv(projection_location, 1, GL_FALSE, glm::value_ptr(projection));
                if (has_view && view_location != -1)
                    glUniformMatrix4fv(view_location, 1, GL_FALSE, glm::value_ptr(view));
            }
        }
        glUseProgram(GL_NONE);
    }

    glm::mat4 getActiveView()
    {
        return view;
    }

    glm::mat4 getActiveProjection()
    {
        return projection;
    }

    glm::vec3 getActiveCamera()
    {
        return camera;
    }

    void setupLights(const Shader& shader, const glm::vec3& target_worldspace)
    {
        const auto lights = { 
            std::tuple	{Uniforms::AmbientLightDirection, ambient_light_offset},
                        {Uniforms::SpecularLightDirection, specular_light_offset}
        };

        for (auto [uniform, offset] : lights)
        {
            if (auto position = shader.uniform(uniform); position != -1)
            {
                glUniform3fv(position, 1, glm::value_ptr(glm::normalize((camera + offset) - target_worldspace)));
            }
        }
    }

    ScopedShader::ScopedShader(Shaders id) noexcept
        :shader{ &ShaderRegistry::get(id) }
    {
        get().get()->bind();
    }

    ScopedShader::~ScopedShader() noexcept
    {
        if (shader)
            glUseProgram(GL_NONE);
    }

    ScopedShader::ScopedShader(ScopedShader&& other) noexcept
        :shader{ other.shader }
    {
        other.shader = nullptr;
    }

    ScopedShader& ScopedShader::operator = (ScopedShader&& other) noexcept
    {
        if (this != &other)
        {
            shader = other.shader;
            other.shader = nullptr;
        }

        get().get()->bind();

        return *this;
    }
}
