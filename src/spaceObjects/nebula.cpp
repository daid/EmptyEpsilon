#include <graphics/opengl.h>

#include "main.h"
#include "nebula.h"
#include "playerInfo.h"
#include "random.h"
#include "textureManager.h"
#include "components/collision.h"
#include "components/radarblock.h"

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


/// A Nebula is a piece of space terrain with a 5U radius that blocks long-range radar, but not short-range radar.
/// This hides any SpaceObjects inside of a Nebula, as well as SpaceObjects on the other side of its radar "shadow", from any SpaceShip outside of it.
/// Likewise, a SpaceShip fully inside of a nebula has effectively no long-range radar functionality.
/// In 3D space, a Nebula resembles a dense cloud of colorful gases.
/// Example: nebula = Nebula():setPosition(1000,2000)
REGISTER_SCRIPT_SUBCLASS(Nebula, SpaceObject)
{
}

REGISTER_MULTIPLAYER_CLASS(Nebula, "Nebula")
Nebula::Nebula()
: SpaceObject(5000, "Nebula")
{
    entity.removeComponent<sp::Physics>(); //TODO: Never add this in the first place.
    setRotation(random(0, 360));
    setRadarSignatureInfo(0.0, 0.8, -1.0);

    for(int n=0; n<cloud_count; n++)
    {
        clouds[n].size = random(512, 1024 * 2);
        clouds[n].texture = irandom(1, 3);
        float dist_min = clouds[n].size / 2.0f;
        float dist_max = radius - clouds[n].size;
        clouds[n].offset = vec2FromAngle(float(n * 360 / cloud_count)) * random(dist_min, dist_max);
    }

    if (entity) {
        entity.getOrAddComponent<RadarBlock>();
        entity.getOrAddComponent<NeverRadarBlocked>();

        auto trace = entity.getOrAddComponent<RadarTrace>();
        trace.radius = 5000.0f * 3.0f;
        trace.min_size = 0.0f;
        trace.max_size = std::numeric_limits<float>::max();
        trace.icon = "Nebula" + string(irandom(1, 3)) + ".png";
        trace.flags = RadarTrace::BlendAdd | RadarTrace::Rotate;
    }
}

void Nebula::draw3DTransparent()
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
        float alpha = 1.0f - (distance / 10000.0f);
        if (alpha < 0.0f)
            continue;

        // setup our quad.
        for (auto& point : quad)
        {
            point.vertex = position;
        }

        textureManager.getTexture("Nebula" + string(cloud.texture) + ".png")->bind();
        glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), alpha * 0.8f, alpha * 0.8f, alpha * 0.8f, size);
        auto model_matrix = glm::translate(getModelMatrix(), {cloud.offset.x, cloud.offset.y, 0});
        glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));

        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quad.data());
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quad.data() + sizeof(glm::vec3)));
        std::initializer_list<uint16_t> indices = { 0, 3, 2, 0, 2, 1 };
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, std::begin(indices));
    }
}

void Nebula::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    renderer.drawCircleOutline(position, radius * scale, 2.0, glm::u8vec4(255, 255, 255, 64));
}

glm::mat4 Nebula::getModelMatrix() const
{
    return glm::identity<glm::mat4>();
}
