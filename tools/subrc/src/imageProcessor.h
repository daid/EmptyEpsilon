#pragma once
#include "assetProcessor.h"

/*! Process images into textures. */
class ImageProcessor final : public AssetProcessor
{
public:
	explicit ImageProcessor(pack::Builder& builder);
	~ImageProcessor() override;
	bool accept(const std::filesystem::path&) const override;
	bool process(const std::filesystem::path& root, const std::filesystem::path& file) override;
private:
	struct Details;
	std::unique_ptr<Details> impl;
	size_t size_in{};
	size_t size_out{};
};
