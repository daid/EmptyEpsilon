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

    // Draw ring track using drawCircleOutline.
    // TODO: Sprites from legacy are ignored if defined in the theme!
    //       Warn if there's a sprite in the theme.
    renderer.drawCircleOutline(center, radius, effective_thickness, back.color);

    // Draw handle as an arc segment centered on the current value position.
    // TODO: Sprites from legacy also ignored here.
    float fraction = (value - min_value) / (max_value - min_value);
    float offset_rad = rotation_offset * static_cast<float>(M_PI) / 180.0f;
    float angle_rad = static_cast<float>(M_PI) - fraction * static_cast<float>(M_PI) * 2.0f + offset_rad;
    // Draw handle by defined arc degrees on either side of the value.
    const float handle_half_arc = handle_arc * 0.5f * static_cast<float>(M_PI) / 180.0f;
    constexpr int handle_segments = 8;
    float outer_r = radius;
    float inner_r = radius - effective_thickness;
    std::vector<glm::vec2> pts;
    // Could just reserve 18 points, but left parameterized in case
    // handle_segments needs tweaking.
    pts.reserve((handle_segments + 1) * 2);

    // Generate and draw handle triangles.
    for (auto i = 0; i <= handle_segments; i++)
    {
        const float angle = angle_rad - handle_half_arc + handle_half_arc * 2.0f * static_cast<float>(i) / static_cast<float>(handle_segments);
        const float sine = sinf(angle);
        const float cosine = cosf(angle);
        pts.push_back(center + glm::vec2{sine * outer_r, cosine * outer_r});
        pts.push_back(center + glm::vec2{sine * inner_r, cosine * inner_r});
    }

    renderer.drawTriangleStrip(pts, front.color);
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
