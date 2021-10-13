#include "packResourceProvider.h"

#include <cstdio>
#include <SDL_endian.h>

#ifdef _WIN32
#include <malloc.h>
#else
#include <alloca.h>
#endif

#ifdef _MSC_VER
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#else
#include <dirent.h>
#endif

static inline int readInt(FILE* f)
{
    int32_t ret = 0;
    fread(&ret, sizeof(int32_t), 1, f);
    return SDL_SwapBE32(ret);
}

static inline string readString(FILE *f)
{
    int8_t len = 0;
    fread(&len, sizeof(int8_t), 1, f);
    // MFC - MSVC doesn't support non-const [] initializers
    char *buffer = (char*)alloca(len + 1);
    fread(buffer, len, 1, f);
    buffer[len] = '\0';
    return string(buffer);
}

PackResourceProvider::PackResourceProvider(string filename)
: filename(filename)
{
    FILE* f = fopen(filename.c_str(), "rb");
    if (!f)
        return;

    int version = readInt(f);
    if (version == 0)
    {
        int file_count = readInt(f);
        LOG(INFO) << "Loaded: " << filename << " with " << file_count << " files";
        for(int n=0; n<file_count; n++)
        {
            string fileName = readString(f);
            int position = readInt(f);
            int size = readInt(f);
            files[fileName] = PackResourceInfo(position, size);
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

void PackResourceProvider::addPackResourcesForDirectory(const string directory)
{
#ifdef _MSC_VER
    WIN32_FIND_DATAA data;
    auto search_root = directory;
    if (!search_root.endswith("/"))
    {
        search_root += "/";
    }
    HANDLE handle = FindFirstFileA((search_root + "*").c_str(), &data);
    if (handle == INVALID_HANDLE_VALUE)
        return;

    do {
        if (data.cFileName[0] == '.')
            continue;
        string name = directory + "/" + string(data.cFileName);
        if (name.lower().endswith(".pack"))
        {
            new PackResourceProvider(name);
        }
    } while (FindNextFileA(handle, &data));

    FindClose(handle);
#else
    DIR* dir = opendir(directory.c_str());
    if (!dir)
        return;

    struct dirent *entry;
    while ((entry = readdir(dir)) != nullptr)
    {
        if (entry->d_name[0] == '.')
            continue;
        string name = directory + "/" + string(entry->d_name);
        if (name.lower().endswith(".pack"))
        {
            new PackResourceProvider(name);
        }
    }
    closedir(dir);
#endif
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

size_t PackResourceStream::read(void* data, size_t size)
{
    int ret;
    if (read_position + size > this->size)
        size = this->size - read_position;
    ret = fread(data, 1, size, f);
    if (ret > 0)
        read_position += ret;
    return ret;
}

size_t PackResourceStream::seek(size_t position)
{
    read_position = position;
    fseek(f, this->position + read_position, SEEK_SET);
    return read_position;
}

size_t PackResourceStream::tell()
{
    return read_position;
}

size_t PackResourceStream::getSize()
{
    return size;
}
