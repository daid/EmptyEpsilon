#include <graphics/opengl.h>

#include "main.h"
#include "nebula.h"
#include "playerInfo.h"
#include "random.h"
#include "textureManager.h"
#include "components/collision.h"
#include "components/radarblock.h"
#include "components/rendering.h"

#include "scriptInterface.h"

#include "glObjects.h"
#include "shaderRegistry.h"

#include <glm/ext/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>


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

    if (entity) {
        entity.getOrAddComponent<RadarBlock>();
        entity.getOrAddComponent<NeverRadarBlocked>();
        auto& nr = entity.getOrAddComponent<NebulaRenderer>();
        for(int n=0; n<cloud_count; n++)
        {
            nr.clouds.emplace_back();
            auto& cloud = nr.clouds.back();
            cloud.size = random(512, 1024 * 2);
            cloud.texture.name = "Nebula" + string(irandom(1, 3)) + ".png";
            float dist_min = cloud.size / 2.0f;
            float dist_max = radius - cloud.size;
            cloud.offset = vec2FromAngle(float(n * 360 / cloud_count)) * random(dist_min, dist_max);
        }

        auto& trace = entity.getOrAddComponent<RadarTrace>();
        trace.radius = 5000.0f * 3.0f;
        trace.min_size = 0.0f;
        trace.max_size = std::numeric_limits<float>::max();
        trace.icon = "Nebula" + string(irandom(1, 3)) + ".png";
        trace.flags = RadarTrace::BlendAdd | RadarTrace::Rotate;
    }
}

void Nebula::draw3DTransparent()
{
    
}

void Nebula::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    renderer.drawCircleOutline(position, radius * scale, 2.0, glm::u8vec4(255, 255, 255, 64));
}

glm::mat4 Nebula::getModelMatrix() const
{
    return glm::identity<glm::mat4>();
}
