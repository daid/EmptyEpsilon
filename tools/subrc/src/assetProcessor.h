#pragma once

#include <filesystem>

namespace pack {
	class Builder;
}

/*! Abstract 'asset processor' class. */
class AssetProcessor
{
public:
	explicit AssetProcessor(pack::Builder& builder);
	virtual ~AssetProcessor();

	/*! Returns true if the processor accepts the given path.
	* Usually used to check extensions
	*/
	virtual bool accept(const std::filesystem::path&) const = 0;
	
	/*! Process the asset.
	* \param[in] root root path of file.
	* \param[in] file full pathname to process.
	* 
	* \return true if successful.
	*/
	virtual bool process(const std::filesystem::path& root, const std::filesystem::path& file) = 0;

protected:
	pack::Builder& builder;
};
/*! Processes the file by simply copying the content without transformation.
 * Accepts everything.
*/
class CopyProcessor final : public AssetProcessor
{
public:
	using AssetProcessor::AssetProcessor;
	bool accept(const std::filesystem::path&) const override;
	bool process(const std::filesystem::path& root, const std::filesystem::path& file) override;
};
