#include "packResourceProvider.h"

static inline int readInt(FILE* f)
{
    int32_t ret = 0;
    fread(&ret, sizeof(int32_t), 1, f);
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__ || defined(_WIN32)
    return (ret & 0xFF) << 24 | (ret & 0xFF00) << 8 | (ret & 0xFF0000) >> 8 | (ret & 0xFF000000) >> 24;
#endif
    return ret;
}

PackResourceProvider::PackResourceProvider(string filename)
: filename(filename)
{
    FILE* f = fopen(filename.c_str(), "rb");
    int version = readInt(f);
    if (version == 0)
    {
        int file_count = readInt(f);
        LOG(INFO) << "Loaded: " << filename << " with " << file_count << " files";
        for(int n=0; n<file_count; n++)
        {
            int8_t filename_size = 0;
            fread(&filename_size, sizeof(int8_t), 1, f);
            char buffer[filename_size + 1];
            fread(&buffer, filename_size, 1, f);
            buffer[filename_size] = '\0';
            int position = readInt(f);
            int size = readInt(f);
            
            files[string(buffer)] = PackResourceInfo(position, size);
        }
    }
    fclose(f);
}

P<ResourceStream> PackResourceProvider::getResourceStream(const string filename)
{
    if (files.find(filename) != files.end())
        return new PackResourceStream(this->filename, files.find(filename)->second);
    return NULL;
}

std::vector<string> PackResourceProvider::findResources(const string searchPattern)
{
    std::vector<string> ret;
    return ret;
}

PackResourceStream::PackResourceStream(string filename, PackResourceInfo info)
: position(info.position), size(info. size)
{
    f = fopen(filename.c_str(), "rb");
    if (!f)
        destroy();
    else
        seek(0);
}
PackResourceStream::~PackResourceStream()
{
    if (f)
        fclose(f);
}

sf::Int64 PackResourceStream::read(void* data, sf::Int64 size)
{
    int ret;
    if (read_position + size > this->size)
        size = this->size - read_position;
    ret = fread(data, 1, size, f);
    if (ret > 0)
        read_position += ret;
    return ret;
}

sf::Int64 PackResourceStream::seek(sf::Int64 position)
{
    read_position = position;
    fseek(f, this->position + read_position, SEEK_SET);
    return read_position;
}

sf::Int64 PackResourceStream::tell()
{
    return read_position;
}

sf::Int64 PackResourceStream::getSize()
{
    return size;
}
