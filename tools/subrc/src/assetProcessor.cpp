#include "assetProcessor.h"

#include "io.h"
#include "packBuilder.h"

AssetProcessor::AssetProcessor(pack::Builder& builder)
	:builder{ builder }
{}

AssetProcessor::~AssetProcessor() = default;

bool CopyProcessor::accept(const std::filesystem::path&) const
{
	return true;
}

bool CopyProcessor::process(const std::filesystem::path& root, const std::filesystem::path& file)
{
	auto source = open_file(file, "rb");
	if (!source)
	{
		error("[copy]: ailed to open %s: %s" LF, file.u8string().c_str(), strerror(errno));
		return false;
	}

	std::vector<uint8_t> data(std::filesystem::file_size(file));
	if (fread(data.data(), data.size(), 1, source.get()) != 1)
	{
		error("[copy]: Could not read %s. Reason: %s" LF, file.u8string().c_str(), strerror(errno));
		return false;
	}

	builder.add(std::filesystem::relative(file, root), data.data(), data.size());
	return true;
}