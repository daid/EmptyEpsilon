#include "assetProcessor.h"

#include "io.h"
#include "log.h"
#include "packBuilder.h"

AssetProcessor::AssetProcessor(pack::Builder& builder)
    :builder{ builder }
{}

AssetProcessor::~AssetProcessor() = default;

bool CopyProcessor::accept(const std::filesystem::path&) const
{
    // copy processor accepts everything.
    return true;
}

bool CopyProcessor::process(const std::filesystem::path& root, const std::filesystem::path& file)
{
    auto source = open_file(file, "rb");
    if (!source)
    {
        VLOG_F(loglevel::Error, "[copy]: failed to open %s: %s", file.u8string().c_str(), strerror(errno));
        return false;
    }

    std::vector<uint8_t> data(std::filesystem::file_size(file));
    if (fread(data.data(), data.size(), 1, source.get()) != 1)
    {
        VLOG_F(loglevel::Error, "[copy]: Could not read %s. Reason: %s", file.u8string().c_str(), strerror(errno));
        return false;
    }

    builder.add(std::filesystem::relative(file, root), data.data(), data.size());
    return true;
}
