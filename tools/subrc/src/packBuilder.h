#pragma once

#include <cstdint>
#include <vector>

#include "io.h"

namespace pack {
    /*! Builds a .pack file. */
    class Builder
    {
    public:
        Builder();
        /*! Add a file to the pack.
        * \param[in] name filename (relative, may contain leading folder)
        * \param[in] data file contents.
        * \param[in] size file contents size.
        */
        void add(const std::filesystem::path& name, const void* data, size_t size);

        /*! Writes contents to file.
        * \param[in] output target pack file.
        */
        bool flush(const std::filesystem::path& output);
    private:
        /*! Pack file entry information. */
        struct Entry
        {
            std::string name{};
            int32_t position{};
            int32_t size{};

            Entry(std::string_view name, int32_t position, int32_t size);
            ~Entry();
            Entry(const Entry&);
            Entry(Entry&&);

            Entry& operator=(const Entry&);
            Entry& operator=(Entry&&);
        };

        std::vector<Entry> entries;
        file_ptr contents;
    };
} // namespace pack
