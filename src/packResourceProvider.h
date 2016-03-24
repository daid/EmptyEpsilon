#ifndef PACK_RESOURCE_PROVIDER_H
#define PACK_RESOURCE_PROVIDER_H

#include "engine.h"

struct PackResourceInfo
{
    PackResourceInfo() {}
    PackResourceInfo(int position, int size) : position(position), size(size) {}
    
    int position;
    int size;
};

class PackResourceProvider : public ResourceProvider
{
    string filename;
    std::unordered_map<string, PackResourceInfo> files;
public:
    PackResourceProvider(string filename);

    virtual P<ResourceStream> getResourceStream(const string filename);
    virtual std::vector<string> findResources(const string searchPattern);
};

class PackResourceStream : public ResourceStream
{
    FILE* f;
    int position;
    int size;
    int read_position;
    
    PackResourceStream(string filename, PackResourceInfo info);
public:
    virtual ~PackResourceStream();
    
    virtual sf::Int64 read(void* data, sf::Int64 size);
    virtual sf::Int64 seek(sf::Int64 position);
    virtual sf::Int64 tell();
    virtual sf::Int64 getSize();
    
    friend class PackResourceProvider;
};

#endif//PACK_RESOURCE_PROVIDER_H
