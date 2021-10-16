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
	}

	void Shader::initialize()
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
			"model_view",
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

			assert(entry.shader);
			
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
	}

	const Shader& get(Shaders shader)
	{
		return shaders[Shaders_t(shader)];
	}

	void setupLights(const Shader& shader, const glm::vec3& target_viewspace)
	{
		if (auto ambient = shader.uniform(Uniforms::AmbientLightDirection); ambient != -1)
		{
			glUniform3fv(ambient, 1, glm::value_ptr(glm::normalize(ambientLightPosition - target_viewspace)));
		}

		if (auto specular = shader.uniform(Uniforms::SpecularLightDirection); specular != -1)
		{
			glUniform3fv(specular, 1, glm::value_ptr(glm::normalize(specularLightPosition - target_viewspace)));
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
