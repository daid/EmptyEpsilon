#ifndef EMPTYEPSILON_SHADER_REGISTRY_H
#define EMPTYEPSILON_SHADER_REGISTRY_H
#include "featureDefs.h"

#if FEATURE_3D_RENDERING
#include <array>
#include <bitset>
#include <cstdint>

#include <type_traits>

namespace sf
{
	class Shader;
}

namespace ShaderRegistry
{
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
		ModelView,
		CameraPosition,
		AtmosphereColor,

		TextureMap,
		BaseMap,
		SpecularMap,
		IlluminationMap,

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
		sf::Shader* get() const { return shader; }
		int32_t uniform(Uniforms id) const { return uniforms[Uniforms_t(id)]; }
		int32_t attribute(Attributes id) const { return attributes[Attributes_t(id)]; }
		static void initialize();
	private:
		sf::Shader* shader = nullptr;
		std::array<int32_t, Uniforms_t(Uniforms::Count)> uniforms;
		std::array<int32_t, Uniforms_t(Attributes::Count)> attributes;
	};

	const Shader& get(Shaders id);

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
#else
namespace ShaderRegistry
{
	struct Shader
	{
		static inline void initialize() {}
	};
}
#endif // FEATURE_3D_RENDERING
#endif // EMPTYEPSILON_SHADER_REGISTRY_H