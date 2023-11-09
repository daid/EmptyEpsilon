#ifndef EMPTYEPSILON_GLOBJECTS_H
#define EMPTYEPSILON_GLOBJECTS_H

#include <array>
#include <cstddef>
#include <cstdint>
#include <limits>

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

    enum class Unitialized
    {
    };

    // RAII object to hold multiple buffers (vbo, ebo etc).
    template<size_t Count>
    class Buffers final
    {
    public:

        Buffers()
        {
            details::createBuffers(buffers.size(), buffers.data());
        }

        explicit constexpr Buffers(Unitialized)
        {
        }

        // Move-only type
        Buffers(const Buffers&) = delete;
        Buffers& operator=(const Buffers&) = delete;

        Buffers(Buffers&& other)
            :buffers{ std::move(other.buffers) }
        {
            for (auto& buffer : other.buffers)
            {
                buffer = 0;
            }
        }

        Buffers& operator =(Buffers&& other)
        {
            if (buffers.data() != other.buffers.data())
            {
                reset();
                buffers = std::move(other.buffers);
                for (auto& buffer : other.buffers)
                {
                    buffer = 0;
                }
            }

            return *this;
        }

        ~Buffers()
        {
            reset();
        }

        constexpr uint32_t operator[](size_t index) const
        {
            return buffers[index];
        }
    private:
        void reset()
        {
            if (buffers[0] != 0)
                details::deleteBuffers(buffers.size(), buffers.data());
        }

        std::array<uint32_t, Count> buffers{ 0 };
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

    template<size_t Count>
    class Textures final
    {
    public:
        Textures()
        {
            details::createTextures(buffers.size(), buffers.data());
        }

        explicit constexpr Textures(Unitialized)
        {
        }

        // Move-only type
        Textures(const Textures&) = delete;
        Textures& operator=(const Textures&) = delete;

        Textures(Textures&& other)
            :buffers{ std::move(other.buffers) }
        {
            for (auto& buffer : other.buffers)
            {
                buffer = 0;
            }
        }

        Textures& operator =(Textures&& other)
        {
            if (buffers.data() != other.buffers.data())
            {
                reset();
                buffers = std::move(other.buffers);
                for (auto& buffer : other.buffers)
                {
                    buffer = 0;
                }
            }

            return *this;
        }

        ~Textures()
        {
            reset();
        }

        constexpr uint32_t operator[](size_t index) const
        {
            return buffers[index];
        }
    private:
        void reset()
        {
            if (buffers[0] != 0)
                details::deleteTextures(buffers.size(), buffers.data());
        }
        std::array<uint32_t, Count> buffers{ 0 };
    };

    class ScopedVertexAttribArray final
    {
    public:
        explicit ScopedVertexAttribArray(int32_t attrib);
        ~ScopedVertexAttribArray();

        ScopedVertexAttribArray(const ScopedVertexAttribArray&) = delete;
        ScopedVertexAttribArray& operator=(const ScopedVertexAttribArray&) = delete;

        ScopedVertexAttribArray(ScopedVertexAttribArray&&) noexcept;
        ScopedVertexAttribArray& operator=(ScopedVertexAttribArray&&) noexcept;
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
        uint32_t previously_bound = std::numeric_limits<uint32_t>::max();
    };

    bool isAvailable();
}

#endif // EMPTYEPSILON_GLOBJECTS_H
