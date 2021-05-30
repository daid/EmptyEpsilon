#include "glObjects.h"

#if FEATURE_3D_RENDERING

#include <GL/glew.h>
#include <type_traits>
#include <cassert>

static_assert(std::is_same<uint32_t, GLuint>::value, "GLuint and uint32_t are *NOT* the same: troubles!");

#ifndef NDEBUG
#define GL_STRINGIFY(v) #v
#define GL_CHECK(statement) \
  do { \
    auto err = glGetError(); \
    assert(err == GL_NO_ERROR && "Error before " GL_STRINGIFY(statement)); \
    statement; \
    err = glGetError(); \
    assert(err == GL_NO_ERROR && "Error after " GL_STRINGIFY(statement)); \
  } while (false)
#else
#define GL_CHECK(statement) statement
#endif

namespace gl
{
    namespace details
    {
        void createBuffers(size_t count, uint32_t* buffers)
        {
            GL_CHECK(glGenBuffers(count, buffers));
        }
        void deleteBuffers(size_t count, const uint32_t* buffers)
        {
            GL_CHECK(glDeleteBuffers(count, buffers));
        }

        void createTextures(size_t count, uint32_t* textures)
        {
            GL_CHECK(glGenTextures(count, textures));
        }
        void deleteTextures(size_t count, const uint32_t* textures)
        {
            GL_CHECK(glDeleteTextures(count, textures));
        }
    }

    ScopedBufferBinding::ScopedBufferBinding(uint32_t target, uint32_t buffer)
        :target{target}, buffer{buffer}
    {
        GL_CHECK(glBindBuffer(target, buffer));
    }

    ScopedBufferBinding::~ScopedBufferBinding()
    {
        GL_CHECK(glBindBuffer(target, GL_NONE));
    }

    ScopedVertexAttribArray::ScopedVertexAttribArray(int32_t attrib)
        :attrib{ attrib }
    {
        if (attrib != -1)
            GL_CHECK(glEnableVertexAttribArray(attrib));
    }

    ScopedVertexAttribArray::~ScopedVertexAttribArray()
    {
        if (attrib != -1)
            GL_CHECK(glDisableVertexAttribArray(attrib));
    }

    ScopedVertexAttribArray::ScopedVertexAttribArray(ScopedVertexAttribArray&& other) noexcept
        :attrib{other.attrib}
    {
        other.attrib = -1;
    }

    ScopedVertexAttribArray& ScopedVertexAttribArray::operator=(ScopedVertexAttribArray&& other) noexcept
    {
        if (this != &other)
        {
            if (attrib != -1 && attrib != other.attrib)
                GL_CHECK(glDisableVertexAttribArray(attrib));
            attrib = other.attrib;
            other.attrib = -1;
        }

        return *this;
    }

    ScopedTexture::ScopedTexture(uint32_t target, uint32_t texture)
        :target{ target }, texture{ texture }
    {
        // ES2 only supports 2D textures and cubemaps.
        GL_CHECK(glGetIntegerv(target == GL_TEXTURE_2D ? GL_TEXTURE_BINDING_2D : GL_TEXTURE_BINDING_CUBE_MAP, &previously_bound));
        
        if (previously_bound != texture)
            GL_CHECK(glBindTexture(target, texture));
    }

    ScopedTexture::~ScopedTexture()
    {
        if (previously_bound != texture)
            GL_CHECK(glBindTexture(target, previously_bound));
    }

    bool isAvailable()
    {
        // Works in "greater or equal than" fashion..
        return GLEW_VERSION_2_0;
    }
} // namespace gl

#endif // FEATURE_3D_RENDERING

