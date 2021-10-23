#include <algorithm>
#include <string>
#include <unordered_map>
#include <vector>

#include "io.h"
#include "packBuilder.h"
#include "assetProcessor.h"
#include "imageProcessor.h"
#include "modelProcessor.h"

namespace {
	void show_help()
	{
		error(
			"(sub)space (r)ift (c)ompressor: Generates optimized assets for EmptyEpsilon." LF
			"Processes .obj and various image formats." LF
			"arguments: [--help] [--pack-everything] [--verbose] <output.pack> <dir> [<dir> ...]" LF
				"\t<output.pack>:" LF
					"\t\tTarget output pack file. Must be writeable." LF
					LF
				"\t<dir> [<dir>...]:" LF
					"\t\tList of directories to iterate over.Asset names in the <output.pack> will be relative to <dir>." LF
					LF
				"\t--help:" LF
					"\t\tShow this message and quits." LF
					LF
				"\t--pack-everything:" LF
					"\t\tIf specified, all files encountered will be added to <output.pack>." LF
					"\t\tDefault is to skip over unrecognized files." LF
					LF
				"\t--verbose:" LF
					"\t\tDebug output (on standard output)." LF
					LF
		);
	}

	bool has_option(std::vector<std::string_view>& arguments, std::string_view option)
	{
		auto candidate = std::find(std::begin(arguments), std::end(arguments), option);
		if (candidate != std::end(arguments))
		{
			arguments.erase(candidate);
			return true;
		}

		return false;
	}
} // anonymous ns

int main(int argc, char* argv[])
{
	std::vector<std::string_view> arguments(argv + 1, argv + argc);
	if (std::find(std::begin(arguments), std::end(arguments), "--help") != std::end(arguments))
	{
		show_help();
		return 0;
	}

	auto pack_everything = has_option(arguments, "--pack-everything");
	auto verbose = has_option(arguments, "--verbose");

	if (arguments.size() < 2)
	{
		fputs("Unexpected number of arguments." LF, stderr);
		show_help();
		return -1;
	}

	// Get output.pack
	std::filesystem::path output_pack{ arguments[0] };
	arguments.erase(std::begin(arguments));

	pack::Builder builder;
	std::vector<std::unique_ptr<AssetProcessor>> processors;
	processors.emplace_back(std::make_unique<ImageProcessor>(builder));
	processors.emplace_back(std::make_unique<ModelProcessor>(builder));

	if (pack_everything)
		processors.emplace_back(std::make_unique<CopyProcessor>(builder));

	for (const auto& arg: arguments)
	{
		std::filesystem::path path{ arg };
		if (std::filesystem::is_directory(path))
		{
			constexpr auto traversal_options{ std::filesystem::directory_options::follow_directory_symlink };
			std::error_code error_code{};
			for (const auto& entry : std::filesystem::recursive_directory_iterator(path, traversal_options, error_code))
			{
				if (error_code)
				{
					if (error_code == std::errc::permission_denied)
					{
						warn("Skipped %s (permission denied)" LF, path.u8string().c_str());
						continue;
					}

					error("Error gathering file in %s: %s" LF, path.u8string().c_str(), error_code.message().c_str());
					return -1;
				}

				if (!entry.is_directory())
				{
					auto processor = std::find_if(std::begin(processors), std::end(processors), [&entry](const auto& proc) { return proc->accept(entry.path()); });
					if (processor != std::end(processors))
					{
						if (!(*processor)->process(path, entry.path()))
						{
							error("Failed to process %s." LF, entry.path().u8string().c_str());
							return -1;
						}
					}
				}
			}
		}
		else
		{
			error("%s is not a directory" LF, path.u8string().c_str());
			return -1;
		}
	}

	if (!builder.flush(output_pack))
	{
		error("Failed to write to %s", output_pack.u8string().c_str());
		return -1;
	}

	
	return 0;
}