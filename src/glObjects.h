#ifndef EMPTYEPSILON_GLOBJECTS_H
#define EMPTYEPSILON_GLOBJECTS_H

#include "featureDefs.h"

#if FEATURE_3D_RENDERING
#include <array>
#include <cstdint>

namespace gl
{
    // Because sfml and glew clashes, we cannot have any
    // OpenGL functions here (or rather, any 'modern' ones).
    // So add thin wrappers.
    namespace details
    {
        void createBuffers(size_t count, uint32_t* dst);
        void deleteBuffers(size_t count, const uint32_t* src);

        void createTextures(size_t count, uint32_t* textures);
        void deleteTextures(size_t count, const uint32_t* textures);
    }

    // RAII object to hold multiple buffers (vbo, ebo etc).
    template<size_t Count>
    class Buffers final
    {
    public:
        Buffers()
        {
            details::createBuffers(buffers.size(), buffers.data());
        }
        ~Buffers()
        {
            details::deleteBuffers(buffers.size(), buffers.data());
        }
        constexpr uint32_t operator[](size_t index)
        {
            return buffers[index];
        }
    private:
        std::array<uint32_t, Count> buffers;
    };

    template<size_t Count>
    class Textures final
    {
    public:
        Textures()
        {
            details::createTextures(buffers.size(), buffers.data());
        }
        ~Textures()
        {
            details::deleteTextures(buffers.size(), buffers.data());
        }
        constexpr uint32_t operator[](size_t index)
        {
            return buffers[index];
        }
    private:
        std::array<uint32_t, Count> buffers;
    };

    class ScopedVertexAttribArray final
    {
    public:
        explicit ScopedVertexAttribArray(int32_t attrib);
        ~ScopedVertexAttribArray();
        int32_t get() const { return attrib; }
    private:
        int32_t attrib = -1;
    };

    bool isAvailable();
}
#endif // FEATURE_3D_RENDERING
#endif // EMPTYEPSILON_GLOBJECTS_H
