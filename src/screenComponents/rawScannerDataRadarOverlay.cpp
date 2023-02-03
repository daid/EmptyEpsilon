#include "rawScannerDataRadarOverlay.h"
#include "radarView.h"
#include "playerInfo.h"
#include "random.h"
#include "spaceObjects/playerSpaceship.h"
#include "components/collision.h"
#include "ecs/query.h"


RawScannerDataRadarOverlay::RawScannerDataRadarOverlay(GuiRadarView* owner, string id, float distance)
: GuiElement(owner, id), radar(owner), distance(distance)
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void RawScannerDataRadarOverlay::onDraw(sp::RenderTarget& renderer)
{
    if (!my_spaceship)
        return;

    auto view_position = radar->getViewPosition();
    float view_rotation = radar->getViewRotation();

    // Cap the number of signature points, which determines the raw data's
    // resolution.
    const int point_count = 512;
    float radius = std::min(rect.size.x, rect.size.y) / 2.0f;

    RawRadarSignatureInfo signatures[point_count];

    // For each SpaceObject ...
    for(auto [entity, signature, dynamic_signature, transform] : sp::ecs::Query<RawRadarSignatureInfo, sp::ecs::optional<DynamicRadarSignatureInfo>, sp::Transform>())
    {
        // Don't measure our own ship.
        if (entity == my_spaceship)
            continue;

        // Initialize angle, distance, and scale variables.
        float a_0, a_1;
        float dist = glm::length(transform.getPosition() - view_position);
        float scale = 1.0;

        // If the object is more than twice as far away as the maximum radar
        // range, disregard it.
        if (dist > distance * 2.0f)
            continue;

        // The further away the object is, the less its effect on radar data.
        if (dist > distance)
            scale = 1.0f - ((dist - distance) / distance);

        auto physics = entity.getComponent<sp::Physics>();
        // If we're adjacent to the object ...
        if (physics && dist <= physics->getSize().x)
        {
            // ... affect all angles of the radar.
            a_0 = 0.0f;
            a_1 = 360.0f;
        }else{
            // Otherwise, measure the affected range of angles by the object's
            // distance and radius.
            float a_diff = glm::degrees(asinf((physics ? physics->getSize().x : 300.0f) / dist));
            float a_center = vec2ToAngle(transform.getPosition() - view_position);
            a_0 = a_center - a_diff;
            a_1 = a_center + a_diff;
        }

        // Get the object's radar signature.
        // If the object is a SpaceShip, adjust the signature dynamically based
        // on its current state and activity.
        RawRadarSignatureInfo info = signature;
        if (dynamic_signature)
        {
            info.gravity += dynamic_signature->gravity;
            info.electrical += dynamic_signature->electrical;
            info.biological += dynamic_signature->biological;
        }

        // For each interval determined by the level of raw data resolution,
        // initialize the signatures array.
        for(float a = a_0; a <= a_1; a += 360.f / float(point_count))
        {
            int idx = (int(a / 360.0f * point_count) + point_count * 2) % point_count;
            signatures[idx] += info * scale;
        }
    }

    // Initialize the data's amplitude along each of the three color bands.
    float amp_r[point_count];
    float amp_g[point_count];
    float amp_b[point_count];

    // For each data point ...
    for(int n = 0; n < point_count; n++)
    {
        // ... initialize its values in the array ...
        signatures[n].gravity = std::max(0.0f, std::min(1.0f, signatures[n].gravity));
        signatures[n].electrical = std::max(0.0f, std::min(1.0f, signatures[n].electrical));
        signatures[n].biological = std::max(0.0f, std::min(1.0f, signatures[n].biological));

        // ... make some noise ...
        float r = random(-1, 1);
        float g = random(-1, 1);
        float b = random(-1, 1);

        // ... and then modify the bands' values based on the object's signature.
        // Biological signatures amplify the red and green bands.
        r += signatures[n].biological * 30;
        g += signatures[n].biological * 30;

        // Electrical signatures amplify the red and blue bands.
        r += random(-20, 20) * signatures[n].electrical;
        b += random(-20, 20) * signatures[n].electrical;

        // Gravitational signatures amplify all bands, but especially modify
        // the green and blue bands.
        r = r * (1.0f - signatures[n].gravity);
        g = g * (1.0f - signatures[n].gravity) + 40 * signatures[n].gravity;
        b = b * (1.0f - signatures[n].gravity) + 40 * signatures[n].gravity;

        // Apply the values to the radar bands.
        amp_r[n] = r;
        amp_g[n] = g;
        amp_b[n] = b;
    }

    // Create a vertex array containing each data point.
    std::vector<glm::vec2> a_r;
    std::vector<glm::vec2> a_g;
    std::vector<glm::vec2> a_b;

    // For each data point ...
    for(int n = 0; n < point_count; n++)
    {
        // ... set a baseline of 0 ...
        float r = 0.0;
        float g = 0.0;
        float b = 0.0;

        // ... then sum the amplitude values ...
        for(int m = n - 2 + point_count; m <= n + 2 + point_count; m++)
        {
            r += amp_r[m % point_count];
            g += amp_g[m % point_count];
            b += amp_b[m % point_count];
        }

        // ... divide them by 5 ...
        r /= 5;
        g /= 5;
        b /= 5;

        // ... and add vectors for each point.
        a_r.push_back(
            glm::vec2(rect.position.x + rect.size.x / 2.0f, rect.position.y + rect.size.y / 2.0f) +
            vec2FromAngle(float(n) / float(point_count) * 360.0f - view_rotation) * (radius * (0.95f - r / 500)));

        a_g.push_back(
            glm::vec2(rect.position.x + rect.size.x / 2.0f, rect.position.y + rect.size.y / 2.0f) +
            vec2FromAngle(float(n) / float(point_count) * 360.0f - view_rotation) * (radius * (0.92f - g / 500)));

        a_b.push_back(
            glm::vec2(rect.position.x + rect.size.x / 2.0f, rect.position.y + rect.size.y / 2.0f) +
            vec2FromAngle(float(n) / float(point_count) * 360.0f - view_rotation) * (radius * (0.89f - b / 500)));
    }

    // Set a zero value at the "end" of the data point array.
    a_r.push_back(a_r.front());
    a_g.push_back(a_g.front());
    a_b.push_back(a_b.front());

    // Draw each band as a line.
    renderer.drawLineBlendAdd(a_r, glm::u8vec4(255, 0, 0, 255));
    renderer.drawLineBlendAdd(a_g, glm::u8vec4(0, 255, 0, 255));
    renderer.drawLineBlendAdd(a_b, glm::u8vec4(0, 0, 255, 255));
}
