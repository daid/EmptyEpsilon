#pragma once
#include "assetProcessor.h"

class ModelProcessor final : public AssetProcessor
{
public:
	explicit ModelProcessor(pack::Builder& builder);
	~ModelProcessor() override;
	bool accept(const std::filesystem::path&) const override;
	bool process(const std::filesystem::path& root, const std::filesystem::path& file) override;
private:
	size_t size_in{};
	size_t size_out{};
};