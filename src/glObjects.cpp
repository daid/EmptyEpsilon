#include "glObjects.h"

#include <graphics/opengl.h>
#include <type_traits>
#include <cassert>

static_assert(std::is_same<uint32_t, GLuint>::value, "GLuint and uint32_t are *NOT* the same: troubles!");

#define GL_CHECK(statement) statement

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
        GL_CHECK(glGetIntegerv(target == GL_TEXTURE_2D ? GL_TEXTURE_BINDING_2D : GL_TEXTURE_BINDING_CUBE_MAP, (int32_t*)&previously_bound));
        
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
        return true;
    }
} // namespace gl
