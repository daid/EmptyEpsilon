#pragma once

#include <cstdint>
#include <vector>

#include "io.h"

namespace pack {
	class Builder
	{
	public:
		Builder();
		void add(const std::filesystem::path& name, const uint8_t* data, size_t size);
		bool flush(const std::filesystem::path& output);
	private:
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