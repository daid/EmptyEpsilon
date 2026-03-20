#include "gui2_rotationdial.h"

#include "textureManager.h"
#include "vectorUtils.h"
#include "logging.h"
#include "preferenceManager.h"
#include "theme.h"

GuiRotationDial::GuiRotationDial(GuiContainer* owner, string id, float min_value, float max_value, float start_value, float rotation_offset, float ring_thickness, func_t func)
: GuiElement(owner, id), min_value(min_value), max_value(max_value), value(start_value), rotation_offset(rotation_offset), ring_thickness(ring_thickness), func(func)
{
    radius = std::min(rect.size.x, rect.size.y) * 0.5f;

    back_style = theme->getStyle("rotationdial.back");
    front_style = theme->getStyle("rotationdial.front");
}

float GuiRotationDial::getUForSegment(int i, float arc_length, float u_corner, int handle_segments) const
{
    const float arc_pos = (static_cast<float>(i) / static_cast<float>(handle_segments)) * arc_length;
    if (u_corner <= 0.0f)
        return arc_length > 0.0f ? arc_pos / arc_length : 0.0f;
    if (arc_pos <= u_corner)
        return (arc_pos / u_corner) * 0.5f;
    if (arc_pos >= arc_length - u_corner)
        return 0.5f + ((arc_pos - (arc_length - u_corner)) / u_corner) * 0.5f;

    return 0.5f;
}

void GuiRotationDial::onDraw(sp::RenderTarget& renderer)
{
    const auto center = getCenterPoint();
    radius = std::min(rect.size.x, rect.size.y) * 0.5f;

    // Get theme properties.
    const auto& back = back_style->get(getState());
    const auto& front = front_style->get(getState());

    const float effective_thickness = ring_thickness < 1.0f
        ? radius * 0.1f
        : ring_thickness;

    // Draw ring track using drawCircleOutline, then overlay the theme texture if set.
    if (!back.texture.empty())
        renderer.drawStretched(rect, back.texture, back.color);
    else
        renderer.drawCircleOutline(center, radius, effective_thickness, back.color);

    // Draw handle as an arc segment centered on the current value position.
    float fraction = (value - min_value) / (max_value - min_value);
    float offset_rad = rotation_offset * static_cast<float>(M_PI) / 180.0f;
    float angle_rad = static_cast<float>(M_PI) - fraction * static_cast<float>(M_PI) * 2.0f + offset_rad;

    // Draw handle by defined arc degrees on either side of the value.
    const float handle_half_arc = handle_arc * 0.5f * static_cast<float>(M_PI) / 180.0f;
    constexpr int handle_segments = 8;
    float outer_r = radius;
    float inner_r = radius - effective_thickness;

    // Apply the theme texture with 9-segment UV scaling to the curved arc
    // triangle mesh. Fix corners, stretch middle segments along arc (U), and
    // stretch edge segments along radius (V).
    if (!front.texture.empty())
    {
        // Approximate arc length at mid-radius for arc-axis corner sizing.
        const float arc_length = 2.0f * handle_half_arc * ((inner_r + outer_r) * 0.5f);
        // Use front.size as the corner size in pixels, as in drawStretchedHV.
        // Clamp corner sizes so they never exceed half of each dimension.
        const float u_corner = std::min(front.size, arc_length * 0.5f);
        const float v_corner = std::min(front.size, effective_thickness * 0.5f);

        // Build four radial (V-axis) rings from outer to inner edges.
        const float radii[4] = {outer_r, outer_r - v_corner, inner_r + v_corner, inner_r};
        constexpr float v_uvs[4] = {0.0f, 0.5f, 0.5f, 1.0f};

        std::vector<glm::vec2> positions;
        std::vector<glm::vec2> uvs;

        // Reserve vertex positions and their UVs for handle segments across
        // three radial rows.
        positions.reserve((handle_segments + 1) * 2 * 3);
        uvs.reserve((handle_segments + 1) * 2 * 3);

        // Process each segment in each band.
        for (int band = 0; band < 3; band++)
        {
            for (int i = 0; i <= handle_segments; i++)
            {
                // Cache angle calculations and U-axis coords for each segment.
                const float angle = angle_rad - handle_half_arc + handle_half_arc * 2.0f * static_cast<float>(i) / static_cast<float>(handle_segments);
                const float angle_sin = sinf(angle);
                const float angle_cos = cosf(angle);
                const float u = getUForSegment(i, arc_length, u_corner, handle_segments);

                // Push positions and UVs for each band from the outer to inner
                // edge.
                positions.push_back(center + glm::vec2{angle_sin * radii[band], angle_cos * radii[band]});
                uvs.push_back({u, v_uvs[band]});
                positions.push_back(center + glm::vec2{angle_sin * radii[band + 1], angle_cos * radii[band + 1]});
                uvs.push_back({u, v_uvs[band + 1]});
            }
        }

        // Render the segments.
        renderer.drawTexturedTriangleStrip(front.texture, positions, uvs, front.color);
    }
    // If not textured, draw the handle as a flat-colored triangle strip
    // without segmenting on radial rings.
    else
    {
        // Build the handle segments.
        std::vector<glm::vec2> positions;
        positions.reserve((handle_segments + 1) * 2);

        for (int i = 0; i <= handle_segments; i++)
        {
            // Cache angle calculations for each segment.
            const float angle = angle_rad - handle_half_arc + handle_half_arc * 2.0f * static_cast<float>(i) / static_cast<float>(handle_segments);
            const float angle_sin = sinf(angle);
            const float angle_cos = cosf(angle);

            // Push positions from the outer to inner edge.
            positions.push_back(center + glm::vec2{angle_sin * outer_r, angle_cos * outer_r});
            positions.push_back(center + glm::vec2{angle_sin * inner_r, angle_cos * inner_r});
        }

        // Render the segments.
        renderer.drawTriangleStrip(positions, front.color);
    }
}

bool GuiRotationDial::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    const auto diff = position - getCenterPoint();
    const float dist = glm::length(diff);
    const float effective_thickness = ring_thickness < 1.0f
        ? radius * 0.1f
        : ring_thickness;

    // Ignore click if made outside of the ring outline.
    if (dist > radius || dist < radius - effective_thickness) return false;

    onMouseDrag(position, id);
    return true;
}

void GuiRotationDial::onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
    auto diff = position - getCenterPoint();

    // Convert angle to position within range.
    float angle = std::fmod(vec2ToAngle(diff) + 90.0f + rotation_offset, 360.0f);
    if (angle < 0.0f) angle += 360.0f;
    float new_value = min_value + (max_value - min_value) * angle / 360.0f;
    new_value = std::clamp(new_value, std::min(min_value, max_value), std::max(min_value, max_value));

    // If value changed, update it and run any callback present.
    if (value != new_value)
    {
        value = new_value;
        if (func) func(value);
    }
}

void GuiRotationDial::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
}

GuiRotationDial* GuiRotationDial::setValue(float value)
{
    // Normalize any arbitrary float value to 0-360.
    const float range = std::abs(max_value - min_value);
    const float lower_range = std::min(min_value, max_value);
    // fmod once to reduce value to -range, range, then again to reduce to 0, range.
    this->value = lower_range + std::fmod(std::fmod(value - lower_range, range) + range, range);

    return this;
}

float GuiRotationDial::getValue() const
{
    return value;
}
