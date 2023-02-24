#include <graphics/opengl.h>
#include <glm/gtc/type_ptr.hpp>

#include "blackHole.h"
#include "pathPlanner.h"
#include "main.h"
#include "textureManager.h"
#include "components/radarblock.h"
#include "components/gravity.h"

#include "scriptInterface.h"
#include "glObjects.h"
#include "shaderRegistry.h"


struct VertexAndTexCoords
{
    glm::vec3 vertex;
    glm::vec2 texcoords;
};

/// A BlackHole is a piece of space terrain that pulls all nearby SpaceObjects within a 5U radius, including otherwise immobile objects like SpaceStations, toward its center.
/// A SpaceObject capable of taking damage is dealt an increasing amount of damage as it approaches the BlackHole's center.
/// Upon reaching the center, any SpaceObject is instantly destroyed even if it's otherwise incapable of taking damage.
/// AI behaviors avoid BlackHoles by a 2U margin.
/// In 3D space, a BlackHole resembles a black sphere with blue horizon.
/// Example: black_hole = BlackHole():setPosition(1000,2000)
REGISTER_SCRIPT_SUBCLASS(BlackHole, SpaceObject)
{
}

REGISTER_MULTIPLAYER_CLASS(BlackHole, "BlackHole");
BlackHole::BlackHole()
: SpaceObject(5000, "BlackHole")
{
    update_delta = 0.0;
    PathPlannerManager::getInstance()->addAvoidObject(this, 7000);
    setRadarSignatureInfo(0.9, 0, 0);

    if (entity) {
        entity.getOrAddComponent<NeverRadarBlocked>();
        entity.getOrAddComponent<Gravity>().damage = true;
    }
}

void BlackHole::update(float delta)
{
    update_delta = delta;
}

void BlackHole::draw3DTransparent()
{
    static std::array<VertexAndTexCoords, 4> quad{
        glm::vec3{}, {0.f, 1.f},
        glm::vec3{}, {1.f, 1.f},
        glm::vec3{}, {1.f, 0.f},
        glm::vec3{}, {0.f, 0.f}
    };

    textureManager.getTexture("blackHole3d.png")->bind();
    ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::Billboard);

    glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(getModelMatrix()));
    glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), 1.f, 1.f, 1.f, 5000.f);
    gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quad.data());
    glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quad.data() + sizeof(glm::vec3)));

    std::initializer_list<uint16_t> indices = { 0, 2, 1, 0, 3, 2 };
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, std::begin(indices));
    glBlendFunc(GL_ONE, GL_ONE);
}

void BlackHole::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    float size = 5000.0f * scale * 2;
    renderer.drawSprite("radar/blackHole.png", position, size, glm::u8vec4(64, 64, 255, 255));
    renderer.drawSprite("radar/blackHole.png", position, size, glm::u8vec4(0, 0, 0, 255));
}
