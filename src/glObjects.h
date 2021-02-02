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

    class ScopedBufferBinding final
    {
    public:
        explicit ScopedBufferBinding(uint32_t target, uint32_t buffer);
        ~ScopedBufferBinding();

        uint32_t get() const { return buffer; }
    private:
        uint32_t target = 0;
        uint32_t buffer = 0;
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

    class ScopedTexture final
    {
    public:
        ScopedTexture(uint32_t target, uint32_t texture);
        ~ScopedTexture();

        uint32_t get() const { return texture; }
    private:
        uint32_t target = 0;
        uint32_t texture = 0;
        int32_t previously_bound = -1;
    };

    bool isAvailable();
}
#endif // FEATURE_3D_RENDERING
#endif // EMPTYEPSILON_GLOBJECTS_H
