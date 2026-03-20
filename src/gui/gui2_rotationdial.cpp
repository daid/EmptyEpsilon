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

    // Fetch styles
    dial_style = theme->getStyle("rotationdial");
    back_style = theme->getStyle("rotationdial.back");
    front_style = theme->getStyle("rotationdial.front");
    texture_style = theme->getStyle("rotationdial.front.texture");
    handle_style = theme->getStyle("rotationdial.front.handle");
}

void GuiRotationDial::onDraw(sp::RenderTarget& renderer)
{
    // Refresh radius.
    radius = std::min(rect.size.x, rect.size.y) * 0.5f;
    // Skip if radius < 1.
    if (radius < 1.0f) return;

    // Cache center point.
    const glm::vec2 center = getCenterPoint();

    // Get theme properties.
    const auto state = getState();
    const auto& back = back_style->get(state);
    const auto& front = front_style->get(state);
    const auto& texture = texture_style->get(state);

    // Calculate ring thickness and handle arc.

    // The global theme default for the size property is 30, so omitting size
    // results in 30% instead of 10%.
    // TODO: Fix the global size default behavior, since use of size isn't
    // limited to fonts.
    const float thickness_pct = dial_style->get(GuiElement::State::Normal).size > 0.0f
        ? dial_style->get(GuiElement::State::Normal).size
        : 10.0f;
    const float effective_thickness = ring_thickness < 1.0f
        ? std::clamp(radius * thickness_pct / 100.0f, 1.0f, radius)
        : ring_thickness;
    const float effective_handle_arc = handle_arc > 0.0f
        ? handle_arc
        : handle_style->get(state).size;

    // Draw ring track, using the texture if defined or drawCircleOutline if not.
    if (!back.texture.empty())
        renderer.drawStretched(rect, back.texture, back.color);
    else
        renderer.drawCircleOutline(center, radius, effective_thickness, back.color);

    // Draw handle as an arc segment centered on the current value position.
    float fraction = (value - min_value) / (max_value - min_value);
    float offset_rad = rotation_offset * static_cast<float>(M_PI) / 180.0f;
    float angle_rad = static_cast<float>(M_PI) - fraction * static_cast<float>(M_PI) * 2.0f + offset_rad;

    // Draw handle on both sides of the value.
    const float handle_half_arc = effective_handle_arc * 0.5f * static_cast<float>(M_PI) / 180.0f;
    float outer_r = radius;
    float inner_r = radius - effective_thickness;

    // Apply the theme texture with 9-segment UV scaling to the curved arc
    // triangle mesh. Fix corners, stretch middle segments along arc (U), and
    // stretch edge segments along radius (V).
    if (!texture.texture.empty())
    {
        // Approximate arc length at mid-radius for arc-axis corner sizing.
        const float arc_length = 2.0f * handle_half_arc * ((inner_r + outer_r) * 0.5f);
        // Use texture.size as the corner size in pixels. Clamp corner sizes so
        // they never exceed half of each dimension.
        const float u_corner = std::min(texture.size, arc_length * 0.5f);
        const float v_corner = std::min(texture.size, effective_thickness * 0.5f);

        // Build arc positions with corner-aligned subdivisions. Corners must
        // always span a fixed pixel width regardless of handle_arc.
        constexpr int corner_segs = 2;

        // Scale middle mesh segments to middle arc length, at about 1 segment
        // per 20px.
        const int mid_segs = std::max(1, static_cast<int>((arc_length - 2.0f * u_corner) / 20.0f));
        std::vector<std::pair<float, float>> arc_uvs;
        arc_uvs.reserve(2 * corner_segs + mid_segs + 1);

        // Left corner maps U to 0-0.5.
        for (int i = 0; i <= corner_segs; i++)
        {
            const float t = static_cast<float>(i) / static_cast<float>(corner_segs);
            arc_uvs.push_back({t * u_corner, t * 0.5f});
        }

        // Middle segment maps U to 0.5 (stretch 1 pixel).
        if (arc_length > 2.0f * u_corner)
        {
            for (int i = 1; i <= mid_segs; i++)
            {
                const float t = static_cast<float>(i) / static_cast<float>(mid_segs);
                arc_uvs.push_back({u_corner + t * (arc_length - 2.0f * u_corner), 0.5f});
            }
        }

        // Right corner maps U to 0.5-1.0.
        for (int i = 1; i <= corner_segs; i++)
        {
            const float t = static_cast<float>(i) / static_cast<float>(corner_segs);
            arc_uvs.push_back({arc_length - u_corner + t * u_corner, 0.5f + t * 0.5f});
        }

        // Build four radial (V-axis) bands from outer to inner edges.
        const float radii[4] = {outer_r, outer_r - v_corner, inner_r + v_corner, inner_r};
        constexpr float v_uvs[4] = {0.0f, 0.5f, 0.5f, 1.0f};

        // Draw each radial band as its own strip.
        for (int band = 0; band < 3; band++)
        {
            std::vector<glm::vec2> positions;
            std::vector<glm::vec2> uvs;
            positions.reserve(arc_uvs.size() * 2);
            uvs.reserve(arc_uvs.size() * 2);

            for (const auto& [arc_pos, u] : arc_uvs)
            {
                // Map arc_pos back to an angle and compute the vertex position.
                const float angle = arc_length > 0.0f
                    ? angle_rad - handle_half_arc + (arc_pos / arc_length) * 2.0f * handle_half_arc
                    : angle_rad;
                const float angle_sin = sinf(angle);
                const float angle_cos = cosf(angle);

                // Push positions and UVs for the outer and inner edge of this band.
                positions.push_back(center + glm::vec2{angle_sin * radii[band], angle_cos * radii[band]});
                uvs.push_back({u, v_uvs[band]});
                positions.push_back(center + glm::vec2{angle_sin * radii[band + 1], angle_cos * radii[band + 1]});
                uvs.push_back({u, v_uvs[band + 1]});
            }

            renderer.drawTexturedTriangleStrip(texture.texture, positions, uvs, front.color);
        }
    }
    // If not textured, draw the handle as a flat-colored triangle strip
    // without segmenting on radial rings.
    else
    {
        // Scale segments to arc length, about 1 segment per 10 degrees.
        const int handle_segments = std::max(4, static_cast<int>(effective_handle_arc / 10.0f));

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
        ? radius * dial_style->get(GuiElement::State::Normal).size / 100.0f
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
    // fmod once to reduce value to -range, range, then again to reduce to
    // 0, range.
    this->value = lower_range + std::fmod(std::fmod(value - lower_range, range) + range, range);

    return this;
}

float GuiRotationDial::getValue() const
{
    return value;
}
