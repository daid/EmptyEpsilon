#include <graphics/opengl.h>

#include "main.h"
#include "nebula.h"
#include "playerInfo.h"

#include "scriptInterface.h"

#include "glObjects.h"
#include "shaderRegistry.h"

#include <glm/ext/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

struct VertexAndTexCoords
{
    glm::vec3 vertex;
    glm::vec2 texcoords;
};


/// Nebulae block long-range radar in a 5U range.
REGISTER_SCRIPT_SUBCLASS(Nebula, SpaceObject)
{
}

PVector<Nebula> Nebula::nebula_list;

REGISTER_MULTIPLAYER_CLASS(Nebula, "Nebula")
Nebula::Nebula()
: SpaceObject(5000, "Nebula")
{
    // Nebulae need a large radius to render properly from a distance, but
    // collision isn't important, so set the collision radius to a tiny range.
    setCollisionRadius(1);
    setRotation(random(0, 360));
    radar_visual = irandom(1, 3);
    setRadarSignatureInfo(0.0, 0.8, -1.0);

    registerMemberReplication(&radar_visual);

    for(int n=0; n<cloud_count; n++)
    {
        clouds[n].size = random(512, 1024 * 2);
        clouds[n].texture = irandom(1, 3);
        float dist_min = clouds[n].size / 2.0f;
        float dist_max = getRadius() - clouds[n].size;
        clouds[n].offset = vec2FromAngle(float(n * 360 / cloud_count)) * random(dist_min, dist_max);
    }

    nebula_list.push_back(this);
}

void Nebula::draw3DTransparent(const glm::mat4& object_view_matrix)
{
    ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::Billboard);

    std::array<VertexAndTexCoords, 4> quad{
        glm::vec3{}, {0.f, 1.f},
        glm::vec3{}, {1.f, 1.f},
        glm::vec3{}, {1.f, 0.f},
        glm::vec3{}, {0.f, 0.f}
    };

    gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));

    for(int n=0; n<cloud_count; n++)
    {
        NebulaCloud& cloud = clouds[n];

        glm::vec3 position = glm::vec3(getPosition().x, getPosition().y, 0) + glm::vec3(cloud.offset.x, cloud.offset.y, 0);
        float size = cloud.size;

        float distance = glm::length(camera_position - position);
        float alpha = 1.0 - (distance / 10000.0f);
        if (alpha < 0.0)
            continue;

        // setup our quad.
        for (auto& point : quad)
        {
            point.vertex = position;
        }

        textureManager.getTexture("Nebula" + string(cloud.texture) + ".png")->bind();
        glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), alpha * 0.8f, alpha * 0.8f, alpha * 0.8f, size);
        auto model_matrix = glm::translate(glm::mat4(1.0f), {cloud.offset.x, cloud.offset.y, 0});
        glUniformMatrix4fv(shader.get().get()->getUniformLocation("view"), 1, GL_FALSE, glm::value_ptr(object_view_matrix * model_matrix));

        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quad.data());
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quad.data() + sizeof(glm::vec3)));
        std::initializer_list<uint8_t> indices = { 0, 3, 2, 0, 2, 1 };
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, std::begin(indices));
    }
}

void Nebula::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    renderer.drawRotatedSpriteBlendAdd("Nebula" + string(radar_visual) + ".png", position, getRadius() * scale * 3.0, getRotation()-rotation);
}

void Nebula::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    renderer.drawCircleOutline(position, getRadius() * scale, 2.0, glm::u8vec4(255, 255, 255, 64));
}

bool Nebula::inNebula(glm::vec2 position)
{
    foreach(Nebula, n, nebula_list)
    {
        if (glm::length2(n->getPosition() - position) < n->getRadius() * n->getRadius())
            return true;
    }
    return false;
}

bool Nebula::blockedByNebula(glm::vec2 start, glm::vec2 end, float radar_short_range)
{
    auto startEndDiff = end - start;
    float startEndLength = glm::length(startEndDiff);
    if (startEndLength < radar_short_range)
        return false;

    foreach(Nebula, n, nebula_list)
    {
        //Calculate point q, which is a point on the line start-end that is closest to n->getPosition
        float f = glm::dot(startEndDiff, n->getPosition() - start) / startEndLength;
        if (f < 0.0f)
            f = 0.0f;
        if (f > startEndLength)
            f = startEndLength;
        auto q = start + startEndDiff / startEndLength * f;
        if (glm::length2(q - n->getPosition()) < n->getRadius()*n->getRadius())
        {
            return true;
        }
    }
    return false;
}

glm::vec2 Nebula::getFirstBlockedPosition(glm::vec2 start, glm::vec2 end)
{
    auto startEndDiff = end - start;
    float startEndLength = glm::length(startEndDiff);
    P<Nebula> first_nebula;
    float first_nebula_f = startEndLength;
    glm::vec2 first_nebula_q{};
    foreach(Nebula, n, nebula_list)
    {
        float f = glm::dot(startEndDiff, n->getPosition() - start) / startEndLength;
        if (f < 0.0)
            f = 0;
        glm::vec2 q = start + startEndDiff / startEndLength * f;
        if (glm::length2(q - n->getPosition()) < n->getRadius() * n->getRadius())
        {
            if (!first_nebula || f < first_nebula_f)
            {
                first_nebula = n;
                first_nebula_f = f;
                first_nebula_q = q;
            }
        }
    }
    if (!first_nebula)
        return end;

    float d = glm::length(first_nebula_q - first_nebula->getPosition());
    return first_nebula_q + glm::normalize(start - end) * sqrtf(first_nebula->getRadius() * first_nebula->getRadius() - d * d);
}

PVector<Nebula> Nebula::getNebulas()
{
    return nebula_list;
}

glm::mat4 Nebula::getModelMatrix() const
{
    return glm::identity<glm::mat4>();
}
