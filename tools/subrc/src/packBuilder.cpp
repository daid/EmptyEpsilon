#include "packBuilder.h"

#include <cstring>

#include "log.h"

namespace {
	bool write_int32(file_ptr& file, int32_t value) noexcept
	{
		value = to_big(value);
		return fwrite(&value, sizeof(int32_t), 1, file.get()) == 1;
	}

	bool write_string(file_ptr& file, std::string_view str)
	{
		auto length = static_cast<int8_t>(str.size());
		if (fwrite(&length, sizeof(int8_t), 1, file.get()) == 1)
		{
			return fwrite(str.data(), length, 1, file.get()) == 1;
		}
		return false;
	}
}

namespace pack {
	Builder::Entry::Entry(std::string_view name, int32_t position, int32_t size)
		: name{ name }, position{ position }, size{ size }
	{}

	Builder::Entry::~Entry() = default;
	Builder::Entry::Entry(const Entry&) = default;
	Builder::Entry::Entry(Entry&&) = default;

	Builder::Entry& Builder::Entry::operator=(const Entry&) = default;
	Builder::Entry& Builder::Entry::operator=(Entry&&) = default;

	Builder::Builder()
		:contents{ tmpfile(), &fclose }
	{}
	void Builder::add(const std::filesystem::path& name, const uint8_t* data, size_t size)
	{
		VLOG_F(loglevel::Debug, "[builder]: adding entry %s", name.generic_u8string().c_str());
		entries.emplace_back(name.generic_u8string().c_str(), 0, static_cast<int32_t>(size));
		if (size > 0)
		{
			fwrite(data, size, 1, contents.get());
		}
		else
			VLOG_F(loglevel::Warning, "[builder]: entry %s has no content.", name.generic_u8string().c_str());
	}

	bool Builder::flush(const std::filesystem::path& output)
	{
		auto dest = open_file(output, "wb");
		if (!dest)
		{
			VLOG_F(loglevel::Error, "failed to open %s for writing.", output.u8string().c_str());
			return false;
		}

		// Get header size.
		auto header_size{2 * sizeof(int32_t)};
		for (const auto& entry : entries)
		{
			header_size += 2 * sizeof(int32_t) + sizeof(int8_t) + entry.name.size();
		}

		// Write header.
		write_int32(dest, 0);
		write_int32(dest, static_cast<int32_t>(entries.size()));

			
		size_t running_position{header_size};
		for (const auto& entry : entries)
		{
			write_string(dest, entry.name);
			write_int32(dest, entry.position + static_cast<int32_t>(running_position));
			write_int32(dest, entry.size);
			running_position += entry.size;
		}

		// Write file contents.
		// Readback from the tmpfile 8MB at a time.
		std::vector<uint8_t> buffer(8 * 1024 * 1024);
		rewind(contents.get());
		for (;;)
		{
			auto bytes = fread(buffer.data(), 1, buffer.size(), contents.get());
			if (bytes == 0)
				break;
			
			auto written = fwrite(buffer.data(), bytes, 1, dest.get());
			if (written == 0)
			{
				VLOG_F(loglevel::Error, "Failed writing to %s. Reason: %s", output.u8string().c_str(), strerror(errno));
				dest.reset();
				remove(output.u8string().c_str());
				return false;
			}
		}

		if (ferror(contents.get()) || !feof(contents.get()))
		{
			VLOG_F(loglevel::Error, "Reading back contents to write in %s. Reason: %s", output.u8string().c_str(), strerror(errno));
			dest.reset();
			remove(output.u8string().c_str());
			return false;
		}

		return true;
	}
} // namespace pack
