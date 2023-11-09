#include "packResourceProvider.h"

#include <cstdio>
#include <SDL_endian.h>
#include <SDL_rwops.h>

#ifdef _WIN32
#include <malloc.h>
#else
#include <alloca.h>
#endif

#ifdef ANDROID
#include <jni.h>
#include <android/asset_manager.h>
#include <android/asset_manager_jni.h>
#include <SDL.h>
#else
#include <filesystem>
#endif

static inline int readInt(SDL_RWops* f)
{
    int32_t ret = 0;
    SDL_RWread(f, &ret, sizeof(int32_t), 1);
    return SDL_SwapBE32(ret);
}

static inline string readString(SDL_RWops *f)
{
    int8_t len = 0;
    SDL_RWread(f, &len, sizeof(int8_t), 1);
    // MFC - MSVC doesn't support non-const [] initializers
    char *buffer = (char*)alloca(len + 1);
    SDL_RWread(f, buffer, len, 1);
    buffer[len] = '\0';
    return string(buffer);
}

PackResourceProvider::PackResourceProvider(string filename)
: filename(filename)
{
    auto f = SDL_RWFromFile(filename.c_str(), "rb");
    if (!f)
    {
        LOG(WARNING) << "Failed to open " << filename << ": " << SDL_GetError();
        return;
    }

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
    else
    {
        LOG(WARNING) << filename << " has unknown version " << version;
    }
    SDL_RWclose(f);
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
#if !defined(ANDROID)
    namespace fs = std::filesystem;
    const fs::path root{ directory.data() };

    constexpr auto traversal_options{ fs::directory_options::follow_directory_symlink | fs::directory_options::skip_permission_denied };
    std::error_code error_code{};
    for (const auto& entry : fs::directory_iterator(root, traversal_options, error_code))
    {
        if (!error_code)
        {
            if (!entry.is_directory() && string { entry.path().extension().u8string() }.lower() == ".pack")
                new PackResourceProvider(entry.path().u8string());
        }
        else
            LOG(WARNING, entry.path().u8string(), " encountered an error: ", error_code.message());
    }
#else
    //Limitation : 
    //As far as I know, Android NDK won't provide a way to list subdirectories
    //So we will only list files in the first level directory 
    static jobject asset_manager_jobject;
    static AAssetManager* asset_manager = nullptr;
    if (!asset_manager)
    {
        JNIEnv* env = (JNIEnv*)SDL_AndroidGetJNIEnv();
        jobject activity = (jobject)SDL_AndroidGetActivity();
        jclass clazz(env->GetObjectClass(activity));
        jmethodID method_id = env->GetMethodID(clazz, "getAssets", "()Landroid/content/res/AssetManager;");
        asset_manager_jobject = env->CallObjectMethod(activity, method_id);
        asset_manager = AAssetManager_fromJava(env, asset_manager_jobject);

        env->DeleteLocalRef(activity);
        env->DeleteLocalRef(clazz);
    }

    if (asset_manager)
    {
        LOG(INFO) << "Looking for packs in " << directory;
        auto stripped = directory.rstrip("/");
        AAssetDir* dir = AAssetManager_openDir(asset_manager, stripped.c_str());
        if (dir)
        {
            const char* filename;
            while ((filename = AAssetDir_getNextFileName(dir)) != nullptr)
            {
                string name = stripped + "/" + string(filename);
                if (name.lower().endswith(".pack"))
                {
                    new PackResourceProvider(name);
                }
            }
            AAssetDir_close(dir);
        }
        else
        {
            LOG(WARNING) << "Could not open directory " << directory;
        }
    }
#endif
}

PackResourceStream::PackResourceStream(string filename, PackResourceInfo info)
: position(info.position), size(info. size)
{
    f = SDL_RWFromFile(filename.c_str(), "rb");
    if (!f)
        destroy();
    else
        seek(0);
}
PackResourceStream::~PackResourceStream()
{
    if (f)
        SDL_RWclose(f);
}

size_t PackResourceStream::read(void* data, size_t size)
{
    if (read_position + size > this->size)
        size = this->size - read_position;
    auto ret = SDL_RWread(f, data, 1, size);
    read_position += ret;
    return ret;
}

size_t PackResourceStream::seek(size_t position)
{
    read_position = position;
    SDL_RWseek(f, this->position + read_position, RW_SEEK_SET);
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
