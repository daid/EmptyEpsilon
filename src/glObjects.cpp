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
} // namespace gl

#endif // FEATURE_3D_RENDERING

