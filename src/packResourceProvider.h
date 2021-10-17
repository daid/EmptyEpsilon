#ifndef PACK_RESOURCE_PROVIDER_H
#define PACK_RESOURCE_PROVIDER_H

#include "resources.h"
#include <unordered_map>

struct PackResourceInfo
{
    PackResourceInfo() {}
    PackResourceInfo(size_t position, size_t size) : position(position), size(size) {}

    size_t position;
    size_t size;
};

class PackResourceProvider : public ResourceProvider
{
    string filename;
    std::unordered_map<string, PackResourceInfo> files;
public:
    PackResourceProvider(string filename);

    virtual P<ResourceStream> getResourceStream(const string filename) override;
    virtual std::vector<string> findResources(const string searchPattern) override;

    static void addPackResourcesForDirectory(const string directory);
};

class PackResourceStream : public ResourceStream
{
    struct SDL_RWops* f;
    size_t position;
    size_t size;
    size_t read_position;

    PackResourceStream(string filename, PackResourceInfo info);
public:
    virtual ~PackResourceStream();

    virtual size_t read(void* data, size_t size) override;
    virtual size_t seek(size_t position) override;
    virtual size_t tell() override;
    virtual size_t getSize() override;

    friend class PackResourceProvider;
};

#endif//PACK_RESOURCE_PROVIDER_H
