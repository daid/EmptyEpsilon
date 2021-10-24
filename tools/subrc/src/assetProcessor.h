#pragma once

#include <filesystem>

namespace pack {
	class Builder;
}

class AssetProcessor
{
public:
	explicit AssetProcessor(pack::Builder& builder);
	virtual ~AssetProcessor();
	virtual bool accept(const std::filesystem::path&) const = 0;
	virtual bool process(const std::filesystem::path& root, const std::filesystem::path& file) = 0;

protected:
	pack::Builder& builder;
};

class CopyProcessor final : public AssetProcessor
{
public:
	using AssetProcessor::AssetProcessor;
	bool accept(const std::filesystem::path&) const override;
	bool process(const std::filesystem::path& root, const std::filesystem::path& file) override;
};
