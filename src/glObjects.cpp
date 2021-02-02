#include "glObjects.h"

#if FEATURE_3D_RENDERING

#include <GL/glew.h>
#include <type_traits>

static_assert(std::is_same<uint32_t, GLuint>::value, "GLuint and uint32_t are *NOT* the same: troubles!");

namespace gl
{
    namespace details
    {
        void createBuffers(size_t count, uint32_t* buffers)
        {
            glGenBuffers(count, buffers);
        }
        void deleteBuffers(size_t count, const uint32_t* buffers)
        {
            glDeleteBuffers(count, buffers);
        }

        void createTextures(size_t count, uint32_t* textures)
        {
            glGenTextures(count, textures);
        }
        void deleteTextures(size_t count, const uint32_t* textures)
        {
            glDeleteTextures(count, textures);
        }
    }

    ScopedVertexAttribArray::ScopedVertexAttribArray(int32_t attrib)
        :attrib{ attrib }
    {
        if (attrib != -1)
            glEnableVertexAttribArray(attrib);
    }

    ScopedVertexAttribArray::~ScopedVertexAttribArray()
    {
        if (attrib != -1)
            glDisableVertexAttribArray(attrib);
    }

    bool isAvailable()
    {
        // Works in "greater or equal than" fashion..
        return GLEW_VERSION_2_0;
    }
} // namespace gl

#endif // FEATURE_3D_RENDERING

