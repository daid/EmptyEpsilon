#include "shaderRegistry.h"

#if FEATURE_3D_RENDERING

#include <cassert>
#include <tuple>

#include <GL/glew.h>

#include "logging.h"
#include "shaderManager.h"

namespace ShaderRegistry
{
	namespace
	{
		std::array<Shader, ShaderID_t(Shaders::Count)> shaders;
	}

	void Shader::initialize()
	{
		std::array<const char*, Shaders_t(Shaders::Count)> shader_names{
			"shaders/basic",
			"shaders/basicColor",
			"shaders/billboard",
			"shaders/objectShaderB",
			"shaders/objectShaderBI",
			"shaders/objectShaderBS",
			"shaders/objectShaderBSI",
			"shaders/planetShader"
		};

		std::array<const char*, Uniforms_t(Uniforms::Count)> uniform_names{
			"color",
			"model_view_projection",
			"projection",
			"model_view",
			"camera_position",
			"atmosphereColor",
			
			"textureMap",
			"baseMap",
			"specularMap",
			"illuminationMap"
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

		for (auto i = 0; i < shader_names.size(); ++i)
		{
			auto& entry = shaders[i];
			entry.shader = ShaderManager::getShader(shader_names[i]);
			entry.attributes.reset();
			assert(entry.shader);
			
			if (entry.shader)
			{
				auto handle = entry.shader->getNativeHandle();

				// First update attribute locations.
				// Because we might trigger a re-link,
				// which may change uniform locations
				// (doubtful, but better safe than sorry!)
				auto relink = false;
				for (auto attrib = 0; attrib < attribute_names.size(); ++attrib)
				{
					auto location = glGetAttribLocation(handle, attribute_names[attrib]);

					// We force each attribute location to match its position in the enum.
					// This makes all array attributes line up - they can be enabled *once*
					// for an entire series of shaders.
					if (location != -1 && attrib != location)
					{
						location = attrib;
						glBindAttribLocation(handle, location, attribute_names[attrib]);
						relink = true;

					}
					entry.attributes.set(attrib, location != -1);
				}

				if (relink)
				{
					glLinkProgram(handle);
					
					GLint status = GL_FALSE;
					glGetProgramiv(handle, GL_LINK_STATUS, &status);
					
					if (status == GL_FALSE)
					{
						// Log the error.
						GLint length = 0;
						glGetProgramiv(handle, GL_INFO_LOG_LENGTH, &length);
						
						std::string log(length + 1, '\0');
						glGetProgramInfoLog(handle, log.size() + 1, &length, &log[0]);

						LOG(ERROR) << "Failed to link shader: " << log;
					}
				}

				// Find out uniform locations
				for (auto uniform = 0; uniform < uniform_names.size(); ++uniform)
				{
					entry.uniforms[uniform] = glGetUniformLocation(handle, uniform_names[uniform]);
				}

				// Lockdown texture locations.
				glUseProgram(entry.get()->getNativeHandle());
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
		return shaders[ShaderID_t(shader)];
	}

	ScopedShader::ScopedShader(Shaders id) noexcept
		:shader{ &ShaderRegistry::get(id) }
	{
		glUseProgram(get().get()->getNativeHandle());
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

		glUseProgram(get().get()->getNativeHandle());

		return *this;
	}
}
#endif // FEATURE_3D_RENDERING