#include <algorithm>
#include <string>
#include <unordered_map>
#include <vector>

#include "log.h"

#include "io.h"
#include "packBuilder.h"
#include "assetProcessor.h"
#include "imageProcessor.h"
#include "modelProcessor.h"

namespace {
    void show_help()
    {
        puts(
            "(sub)space (r)ift (c)ompressor: Generates optimized assets for EmptyEpsilon." LF
            "Processes .obj and various image formats." LF
            "arguments: [--help] [--pack-everything] [--log-level <level>] <output.pack> <dir> [<dir> ...]" LF
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
                "\t--log-level <level>:" LF
                    "\t\tChange verbosity level." LF
                    "\t\t<level> can be either:" LF
                    "\t\t\t- one of INFO, WARNING, ERROR, or FATAL." LF
                    "\t\t\t- a numeric value between -2 (only errors) to 9 (extra verbose debug level)."
        );
    }

    /*! Check arguments for an option, removes it and returns true if found. */
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
    // Setup logging library.
    {
        loguru::g_preamble_thread = false; // Single threaded tool (mostly)
        loguru::g_internal_verbosity = loglevel::Debug;
        loguru::Options log_options{};
        log_options.verbosity_flag = "--log-level";
        
        // Loguru will remove the --log-level option if it's there.
        loguru::init(argc, argv, log_options);
        // Keep the log tight, only log details in debug (> INFO) levels.
        loguru::g_preamble_file = loguru::g_stderr_verbosity > 0;
        loguru::g_preamble_uptime = loguru::g_stderr_verbosity > 0;
    }
    
    // Load arguments.
    std::vector<std::string_view> arguments(argv + 1, argv + argc);
    
    // Help trumps everything.
    if (has_option(arguments, "--help"))
    {
        show_help();
        // Asking for help and getting it count as normal termination.
        return 0;
    }

    auto pack_everything = has_option(arguments, "--pack-everything");

    // At this point, we parsed all our options - all that's left should be positional arguments.
    if (arguments.size() < 2)
    {
        VLOG_F(loglevel::Error, "Unexpected number of arguments (got %zu, expected at least 2). Try --help for more info.", arguments.size());
        return -1;
    }

    // Get output.pack (first argument)
    std::filesystem::path output_pack{ arguments[0] };
    arguments.erase(std::begin(arguments));

    VLOG_F(loglevel::Info, "Pack file will be generated at: %s", std::filesystem::absolute(output_pack).u8string().c_str());

    pack::Builder builder;
    
    // Setup asset processors.
    // Processors are tried in-order, first one to accept the file wins.
    std::vector<std::unique_ptr<AssetProcessor>> processors;
    processors.emplace_back(std::make_unique<ImageProcessor>(builder));
    processors.emplace_back(std::make_unique<ModelProcessor>(builder));

    VLOG_F(loglevel::Debug, "Pack everything is %s", pack_everything ? "enabled" : "disabled");
    if (pack_everything)
        processors.emplace_back(std::make_unique<CopyProcessor>(builder));

    for (const auto& arg: arguments)
    {
        std::filesystem::path path{ arg };
        VLOG_SCOPE_F(loglevel::Info, "Processing directory %s", path.u8string().c_str());
        
        constexpr auto traversal_options{ std::filesystem::directory_options::follow_directory_symlink };
        std::error_code error_code{};
        for (const auto& entry : std::filesystem::recursive_directory_iterator(path, traversal_options, error_code))
        {
            if (error_code)
            {
                if (error_code == std::errc::permission_denied)
                {
                    VLOG_F(loglevel::Warning, "Skipped %s (permission denied)" LF, path.u8string().c_str());
                    continue;
                }

                VLOG_F(loglevel::Error, "Error gathering file in %s: %s" LF, path.u8string().c_str(), error_code.message().c_str());
                return -1;
            }

            if (!entry.is_directory())
            {
                // Find and apply processor.
                auto processor = std::find_if(std::begin(processors), std::end(processors), [&entry](const auto& proc) { return proc->accept(entry.path()); });
                if (processor != std::end(processors))
                {
                    VLOG_SCOPE_F(loglevel::Debug, "Processing file... %s", entry.path().u8string().c_str());
                    if (!(*processor)->process(path, entry.path()))
                    {
                        VLOG_F(loglevel::Error, "Failed to process %s.", entry.path().u8string().c_str());
                        return -1;
                    }
                }
                else
                    VLOG_F(loglevel::Debug, "%s was skipped (unrecognized type)", entry.path().u8string().c_str());
            }
        }
    }

    // Write output.
    if (!builder.flush(output_pack))
    {
        VLOG_F(loglevel::Error, "Failed to write to %s", output_pack.u8string().c_str());
        return -1;
    }

    loguru::shutdown();
    return 0;
}
