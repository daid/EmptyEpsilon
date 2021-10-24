#pragma once

#include <cstdio>
#include <filesystem>
#include <memory>
#include <string>

#ifdef WIN32
#define LF "\r\n"
#else
#define LF "\n"
#endif

#ifdef _MSC_VER
#include <cstdlib>
#define bswap32 _byteswap_ulong
#define bswap16 _byteswap_ushort
#else
#define bswap32 __builtin_bswap32
#define bswap16 __builtin_bswap16
#endif

#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__ || defined(_WIN32)
constexpr uint32_t to_little(uint32_t value)
{
	return value;
}

constexpr uint16_t to_little(uint16_t value)
{
	return value;
}

inline int32_t from_big(int32_t value)
{
	return bswap32(value);
}

inline int32_t to_big(int32_t value)
{
	return bswap32(value);
}
#else
inline uint32_t to_little(uint32_t value)
{
	return bswap32(value);
}

inline uint16_t to_little(uint16_t value)
{
	return bswap16(value);
}

constexpr int32_t from_big(int32_t value)
{
	return value;
}
constexpr int32_t to_big(int32_t value)
{
	return value;
}
#endif

using file_ptr = std::unique_ptr<FILE, decltype(&fclose)>;
inline file_ptr open_file(const std::filesystem::path& filename, std::string_view mode) noexcept
{
	return { fopen(filename.u8string().data(), mode.data()), &fclose };
}
