#include "assetProcessor.h"

AssetProcessor::AssetProcessor(pack::Builder& builder)
	:builder{ builder }
{}

AssetProcessor::~AssetProcessor() = default;

bool NoopProcessor::accept(const std::filesystem::path&) const
{
	return true;
}

bool NoopProcessor::process(const std::filesystem::path& root, const std::filesystem::path& file)
{
	return false;
}