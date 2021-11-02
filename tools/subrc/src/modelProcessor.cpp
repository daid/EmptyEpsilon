#include "modelProcessor.h"

#include <array>

#define FAST_OBJ_UINT_TYPE uint32_t
#define FAST_OBJ_IMPLEMENTATION
#include <fast_obj.h>

#include <meshoptimizer.h>

#include "io.h"
#include "log.h"
#include "packBuilder.h"

namespace {
	using obj_ptr = std::unique_ptr<fastObjMesh, decltype(&fast_obj_destroy)>;
	struct Vertex
	{
		float position[3]{}; // 12 B
		float normal[3]{};   // 12 B
		float uv[2]{};       //  8 B
	};                       // 32 B
	static_assert(sizeof(Vertex) == 32, "Padding to handle!");


	/*! fast_obj interface. */
	namespace obj_vector
	{
		struct holder
		{
			const std::vector<uint8_t>& data;
			size_t consumed{};
		};

		void* open(const char*, void* user_data)
		{
			return user_data;
		}

		void close(void* file, void* user_data)
		{
			delete static_cast<holder*>(file);
		}

		size_t read(void* file, void* dst, size_t bytes, void* user_data)
		{
			auto vector = static_cast<holder*>(file);
			bytes = std::min(vector->data.size() - vector->consumed, bytes);
			memcpy(dst, vector->data.data() + vector->consumed, bytes);
			vector->consumed += bytes;
			return bytes;
		}

		unsigned long size(void* file, void* user_data)
		{
			return static_cast<unsigned long>(static_cast<holder*>(file)->data.size());
		}

	}

	/*! Opens and load a .obj file through fast_obj. */
	obj_ptr open_obj(const std::vector<uint8_t>& mesh)
	{
		fastObjCallbacks callbacks{
			&obj_vector::open, &obj_vector::close, &obj_vector::read, &obj_vector::size
		};

		return { fast_obj_read_with_callbacks("", &callbacks, new obj_vector::holder{mesh}), &fast_obj_destroy };
	}

	std::vector<uint8_t> optimize_vertices(const Vertex* unindexed_vertices, size_t unindexed_count)
	{
		// Recreate index buffer.
		std::vector<uint32_t> remap(unindexed_count); // allocate temporary memory for the remap table
		size_t vertex_count = meshopt_generateVertexRemap(remap.data(), nullptr, unindexed_count, unindexed_vertices, unindexed_count, sizeof(Vertex));

		// Recreate index buffer.
		std::vector<uint32_t> indices(unindexed_count);
		meshopt_remapIndexBuffer(indices.data(), nullptr, indices.size(), remap.data());

		// Recreate vertex buffer (without duplications)
		std::vector<Vertex> vertices(vertex_count);
		meshopt_remapVertexBuffer(vertices.data(), unindexed_vertices, unindexed_count, sizeof(Vertex), remap.data());

		// Optimization passes
		meshopt_optimizeVertexCache(indices.data(), indices.data(), indices.size(), vertices.size());
		meshopt_optimizeOverdraw(indices.data(), indices.data(), indices.size(), vertices.data()->position, vertices.size(), sizeof(Vertex), 1.05f);
		meshopt_optimizeVertexFetch(vertices.data(), indices.data(), indices.size(), vertices.data(), vertices.size(), sizeof(Vertex));

		// model2: All little endian.
		// Header is
		// <version_and_flags:u32>
		// <vertex_count:u32><indices_count:u32>
		// <compressed_vtx_size:u32><compressed_idx_size:u32>
		// 
		// then data;
		// <compressed_vtx_data:compressed_vtx_size*u8>
		// <compressed_idx_size:compressed_idx_size*u8>
		size_t element_size = [](size_t vertex_count)
		{
			if (vertex_count <= 65536)
				return sizeof(uint16_t);

			return sizeof(uint32_t);
		}(vertices.size());

		// For allocation purposes.
		auto vtx_compress_bound = meshopt_encodeVertexBufferBound(vertices.size(), sizeof(Vertex));
		auto idx_compress_bound = meshopt_encodeIndexBufferBound(indices.size(), vertices.size());

		struct header_t
		{
			uint32_t version{};
			uint32_t vertex_count{};
			uint32_t index_count{};
			uint32_t compressed_vertex_size{};
			uint32_t compressed_index_size{};
		};

		static_assert(sizeof(header_t) == 5 * sizeof(uint32_t), "padding.");
		std::vector<uint8_t> optimized(sizeof(header_t) + vtx_compress_bound + idx_compress_bound);
		auto header = reinterpret_cast<header_t*>(optimized.data());
		header->version = to_little(uint32_t{ 1 });
		header->vertex_count = to_little(static_cast<uint32_t>(vertices.size()));
		header->index_count = to_little(static_cast<uint32_t>(indices.size()));

		auto offset = sizeof(header_t);
		
		// Write vertices.
		header->compressed_vertex_size = to_little(static_cast<uint32_t>(
			meshopt_encodeVertexBuffer(optimized.data() + offset, optimized.size() - offset, vertices.data(), vertices.size(), sizeof(Vertex))
		));
		offset += header->compressed_vertex_size;
		
		// Write indices.
		header->compressed_index_size = to_little(static_cast<uint32_t>(
			meshopt_encodeIndexBuffer(optimized.data() + offset, optimized.size() - offset, indices.data(), indices.size())
		));
		offset += header->compressed_index_size;

		// Trim to actual size (remove worst-case overhead)
		optimized.resize(offset);

		return optimized;
	}

	/*! Upgrade a .model to new format. */
	std::vector<uint8_t> optimize_model(const std::vector<uint8_t>& mesh)
	{
		auto vertex_count = from_big(*reinterpret_cast<const int32_t*>(mesh.data()));

		std::vector<Vertex> vertices(vertex_count);

		memcpy(vertices.data(), mesh.data() + sizeof(int32_t), vertex_count * sizeof(Vertex));

		return optimize_vertices(vertices.data(), vertices.size());
	}

	std::vector<uint8_t> optimize_obj(const std::vector<uint8_t>& mesh)
	{
		auto obj = open_obj(mesh);
		if (!obj)
		{
			VLOG_F(loglevel::Error, "Failed to load .obj");
			return {};
		}
			

		// Move everything into one buffer,
		// triangularize
		size_t index_count{};
		// 3 index per face (one triangle)
		// Each additional vertex creates one new triangle.
		for (auto face = 0u; face < obj->face_count; ++face)
			index_count += (1 + (obj->face_vertices[face] - 3)) * 3;

		std::vector<Vertex> unindexed_vertices(index_count);

		auto copy_vertex = [&unindexed_vertices, &obj](size_t i, const auto& index)
		{
			// EE swaps z/y.
			unindexed_vertices[i].position[0] = obj->positions[3 * index.p + 0];
			unindexed_vertices[i].position[1] = obj->positions[3 * index.p + 2];
			unindexed_vertices[i].position[2] = obj->positions[3 * index.p + 1];

			unindexed_vertices[i].normal[0] = obj->normals[3 * index.n + 0];
			unindexed_vertices[i].normal[1] = obj->normals[3 * index.n + 2];
			unindexed_vertices[i].normal[2] = obj->normals[3 * index.n + 1];

			unindexed_vertices[i].uv[0] = obj->texcoords[2 * index.t + 0];

			// Make OpenGL happy by flipping the y coordinate.
			unindexed_vertices[i].uv[1] = 1.f - obj->texcoords[2 * index.t + 1];

		};

		size_t base_index{};
		size_t current_vertex{};
		// Process each face, triangularize.
		for (auto face = 0u; face < obj->face_count; ++face)
		{
			auto indices = obj->indices + base_index;
			for (auto v = 2u; v < obj->face_vertices[face]; ++v)
			{
				copy_vertex(current_vertex, indices[0]);
				copy_vertex(current_vertex + 2, indices[v]);
				copy_vertex(current_vertex + 1, indices[v - 1]);

				current_vertex += 3;
			}

			base_index += obj->face_vertices[face];
		}

		return optimize_vertices(unindexed_vertices.data(), unindexed_vertices.size());
	}
} // anonymous ns

ModelProcessor::ModelProcessor(pack::Builder& builder)
	:AssetProcessor{ builder }
{
	// Use the improved encoder.
	meshopt_encodeIndexVersion(1);
}

ModelProcessor::~ModelProcessor()
{
	VLOG_F(loglevel::Debug, "[model]: %zu KB -> %zu KB (%.2f)", size_in / 1024, size_out / 1024, float(size_out) / size_in);
}

bool ModelProcessor::accept(const std::filesystem::path& entry) const
{
	static constexpr std::array accepted{ ".obj", ".model" };
	return std::find(std::cbegin(accepted), std::cend(accepted), entry.extension()) != std::cend(accepted);
}

bool ModelProcessor::process(const std::filesystem::path& root, const std::filesystem::path& file)
{
	auto mesh_file = open_file(file, "rb");
	if (!mesh_file)
	{
		VLOG_F(loglevel::Error, "Failed to open %s: %s", file.u8string().c_str(), strerror(errno));
		return false;
	}


	std::vector<uint8_t> mesh_data(std::filesystem::file_size(file));
	if (fread(mesh_data.data(), mesh_data.size(), 1, mesh_file.get()) != 1)
	{
		VLOG_F(loglevel::Error, "Failed to read %s: %s", file.u8string().c_str(), strerror(errno));
		return false;
	}

	std::vector<uint8_t> optimized = file.extension() == ".obj" ? optimize_obj(mesh_data) : optimize_model(mesh_data);
	
	size_in += mesh_data.size();
	size_out += optimized.size();
	
	builder.add(std::filesystem::relative(file, root).replace_extension(".mdl2"), optimized.data(), optimized.size());
	return true;
}
