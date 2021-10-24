#include "imageProcessor.h"

#include <array>
#include <thread>

#include <encoder/basisu_enc.h>
#include <encoder/basisu_comp.h>

#define STBI_ONLY_PNG
#define STBI_ONLY_JPEG
#define STBI_ONLY_BMP
#define STBI_ONLY_TGA
#define STB_IMAGE_STATIC
#define STBI_NO_STDIO
#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

#include "io.h"
#include "log.h"
#include "packBuilder.h"

namespace {
	using image_ptr = std::unique_ptr<uint8_t, decltype(&stbi_image_free)>;
}

struct ImageProcessor::Details final
{
	Details()
		:job_pool{ std::max(1u, std::thread::hardware_concurrency()) }
	{
	}

	basisu::job_pool job_pool;
	basisu::basis_compressor compressor;
};

ImageProcessor::ImageProcessor(pack::Builder& builder)
	:AssetProcessor{builder}
{
	basisu::basisu_encoder_init();
	impl = std::make_unique<Details>();
}

ImageProcessor::~ImageProcessor()
{
	VLOG_F(loglevel::Debug, "[image]: %zu MB -> %zu MB (%.2f)", size_in / (1024 * 1024), size_out / (1024 * 1024), float(size_out) / size_in);
}

bool ImageProcessor::accept(const std::filesystem::path& entry) const
{
	static constexpr std::array accepted{ ".tga", ".bmp", ".jpg", ".jpeg", ".png" };
	return std::find(std::cbegin(accepted), std::cend(accepted), entry.extension()) != std::cend(accepted);
}

bool ImageProcessor::process(const std::filesystem::path& root, const std::filesystem::path& file)
{
	auto image_file = open_file(file, "rb");
	if (!image_file)
	{
		VLOG_F(loglevel::Error, "[image]: Failed to open %s. Reason: %s", file.u8string().c_str(), strerror(errno));
		return false;
	}

	std::vector<uint8_t> raw_data(std::filesystem::file_size(file));
	size_in += raw_data.size();
	if (fread(raw_data.data(), raw_data.size(), 1, image_file.get()) != 1)
	{
		VLOG_F(loglevel::Error, "[image]: Could not read %s. Reason: %s", file.u8string().c_str(), strerror(errno));
		return false;
	}

	int width{}, height{}, channels{};
	image_ptr image_data{ stbi_load_from_memory(raw_data.data(), static_cast<int>(raw_data.size()), &width, &height, &channels, STBI_default), &stbi_image_free };
	if (!image_data)
	{
		VLOG_F(loglevel::Error, "[image] failed to load data: %s", stbi_failure_reason());
		return false;
	}

	basisu::image img(image_data.get(), width, height, channels);

	// setup compression.
	basisu::basis_compressor_params params{};

	// Zstd KTX2.
	params.m_ktx2_uastc_supercompression = basist::KTX2_SS_ZSTANDARD;
	params.m_create_ktx2_file = true;
	params.m_ktx2_zstd_supercompression_level = 20;
	params.m_source_images.push_back(img);

	// UASTC type, with mips.
	params.m_uastc = true;
	params.m_mip_gen = true;
	params.m_mip_smallest_dimension = std::max(height / 4, width / 4);
	params.m_pJob_pool = &impl->job_pool;

	params.m_status_output = false;


	if (!impl->compressor.init(params))
	{
		VLOG_F(loglevel::Error, "Failed to initialize compressor");
		return false;
	}

	if (auto result = impl->compressor.process(); result != basisu::basis_compressor::cECSuccess)
	{
		VLOG_F(loglevel::Error, "Compression failed: %s", [result]()
			{
				switch (result)
				{
				case basisu::basis_compressor::cECFailedReadingSourceImages:
					return "reading source image.";
				case basisu::basis_compressor::cECFailedValidating:
					return "validation failed.";
				case basisu::basis_compressor::cECFailedEncodeUASTC:
					return "encode UASTC.";
				case basisu::basis_compressor::cECFailedFrontEnd:
					return "generic frontend failure.";
				case basisu::basis_compressor::cECFailedFontendExtract:
					return "frontend extract.";
				case basisu::basis_compressor::cECFailedBackend:
					return "generic backend failure.";
				case basisu::basis_compressor::cECFailedCreateBasisFile:
					return "creating basis file.";
				case basisu::basis_compressor::cECFailedWritingOutput:
					return "writing output.";
				case basisu::basis_compressor::cECFailedUASTCRDOPostProcess:
					return "UASTC RDO post process.";
				case basisu::basis_compressor::cECFailedCreateKTX2File:
					return "creating KTX2 file.";
				default:
					return "unknown error."; // new errors?
				}
		}());

		return false;
	}

	const auto& ktx2_output = impl->compressor.get_output_ktx2_file();
	size_out += ktx2_output.size();
	builder.add(std::filesystem::relative(file, root).replace_extension(".ktx2"), ktx2_output.data(), ktx2_output.size());
	return true;
}