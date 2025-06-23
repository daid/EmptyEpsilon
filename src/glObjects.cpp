#include "glObjects.h"

#include <graphics/opengl.h>
#include <graphics/image.h>
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

    CubemapTexture::CubemapTexture(const string& file_path)
    {
        // Load up the cube texture.
        // Face setup
        std::array<std::tuple<string, uint32_t>, 6> faces{
            std::make_tuple(file_path + "/right.png", GL_TEXTURE_CUBE_MAP_POSITIVE_X),
            std::make_tuple(file_path + "/left.png", GL_TEXTURE_CUBE_MAP_NEGATIVE_X),
            std::make_tuple(file_path + "/top.png", GL_TEXTURE_CUBE_MAP_POSITIVE_Y),
            std::make_tuple(file_path + "/bottom.png", GL_TEXTURE_CUBE_MAP_NEGATIVE_Y),
            std::make_tuple(file_path + "/front.png", GL_TEXTURE_CUBE_MAP_POSITIVE_Z),
            std::make_tuple(file_path + "/back.png", GL_TEXTURE_CUBE_MAP_NEGATIVE_Z),
        };

        // Upload
        glBindTexture(GL_TEXTURE_CUBE_MAP, texture[0]);
        sp::Image image;
        for (const auto& face : faces)
        {
            auto stream = getResourceStream(std::get<0>(face));
            if (!stream || !image.loadFromStream(stream))
            {
                LOG(Warning, "Failed to load texture: ", std::get<0>(face));
                image = sp::Image({8, 8}, {255, 0, 255, 128});
            }

            glTexImage2D(std::get<1>(face), 0, GL_RGBA, image.getSize().x, image.getSize().y, 0, GL_RGBA, GL_UNSIGNED_BYTE, image.getPtr());
        }

        // Make it pretty.
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

        //GL_TEXTURE_WRAP_R does not exist in GLES2.0?
        for (auto wrap_axis : { GL_TEXTURE_WRAP_S, GL_TEXTURE_WRAP_T /*, GL_TEXTURE_WRAP_R*/ })
            glTexParameteri(GL_TEXTURE_CUBE_MAP, wrap_axis, GL_CLAMP_TO_EDGE);

        if (GLAD_GL_ES_VERSION_2_0)
            glGenerateMipmap(GL_TEXTURE_CUBE_MAP);
        glBindTexture(GL_TEXTURE_CUBE_MAP, GL_NONE);

        LOG(Info, "Loaded cubemap: ", file_path);
    }

    void CubemapTexture::bind()
    {
        glBindTexture(GL_TEXTURE_CUBE_MAP, texture[0]);
    }

    bool isAvailable()
    {
        return true;
    }
} // namespace gl
