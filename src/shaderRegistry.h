#ifndef EMPTYEPSILON_SHADER_REGISTRY_H
#define EMPTYEPSILON_SHADER_REGISTRY_H
#include "featureDefs.h"

#include <array>
#include <cstdint>
#include <functional>
#include <optional>

#include <type_traits>

#include <glm/vec3.hpp>
#include <glm/vec4.hpp>
#include <glm/mat4x4.hpp>

namespace sp
{
	class Shader;
}

namespace ShaderRegistry
{
	// Lights position, expressed as offset from the camera (world space).
	constexpr glm::vec3 ambient_light_offset{ 20000.f, 20000.f, 20000.f };
	constexpr glm::vec3 specular_light_offset{ 0.f, 0.f, 0.f };

	enum class Shaders
	{
		Basic = 0,
		BasicColor,
		Billboard,
		Object,
		ObjectIllumination,
		ObjectSpecular,
		ObjectSpecularIllumination,
		Planet,

		Count
	};

	using Shaders_t = std::underlying_type<Shaders>::type;

	enum class Uniforms : uint8_t
	{
		Color = 0,
		ModelViewProjection,
		Projection,
		Model,
		View,
		CameraPosition,
		AtmosphereColor,

		TextureMap,
		BaseMap,
		SpecularMap,
		IlluminationMap,

		AmbientLightDirection,
		SpecularLightDirection,

		Count
	};

	using Uniforms_t = std::underlying_type<Uniforms>::type;

	enum class Attributes : uint8_t
	{
		Position = 0,
		Texcoords,
		Normal,

		Count
	};

	enum class Textures : uint8_t
	{
		BaseMap = 0,
		TextureMap = 0,
		SpecularMap = 1,
		IlluminationMap = 2,
	};

	constexpr uint32_t textureIndex(Textures unit) { return uint32_t(unit); }

	using Attributes_t = std::underlying_type<Attributes>::type;

	struct Shader
	{
		sp::Shader* get() const { return shader; }
		int32_t uniform(Uniforms id) const { return uniforms[Uniforms_t(id)]; }
		int32_t attribute(Attributes id) const { return attributes[Attributes_t(id)]; }
		static bool initialize();
	private:
		sp::Shader* shader = nullptr;
		std::array<int32_t, Uniforms_t(Uniforms::Count)> uniforms;
		std::array<int32_t, Uniforms_t(Attributes::Count)> attributes;
	};

	

	const Shader& get(Shaders id);

	void updateProjectionView(std::optional<std::reference_wrapper<const glm::mat4>> projection, std::optional<std::reference_wrapper<const glm::mat4>> view);
	glm::mat4 getActiveView();
	glm::mat4 getActiveProjection();
	glm::vec3 getActiveCamera();

	void setupLights(const Shader& shader, const glm::vec3& target_worldspace);
	inline void setupLights(const Shader& shader, const glm::mat4& model)
	{
		// Target center of model.
		setupLights(shader, model * glm::vec4{ glm::vec3{0.f}, 1.f });
	}
	

	class ScopedShader final
	{
	public:
		explicit ScopedShader(Shaders id) noexcept;
		~ScopedShader() noexcept;

		ScopedShader(const ScopedShader&) = delete;
		ScopedShader& operator = (const ScopedShader&) = delete;

		ScopedShader(ScopedShader&&) noexcept;
		ScopedShader& operator = (ScopedShader&&) noexcept;

		const Shader& get() const { return *shader; }
	private:
		const Shader* shader = nullptr;
	};
}

#endif // EMPTYEPSILON_SHADER_REGISTRY_H
