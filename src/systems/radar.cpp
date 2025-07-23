#include "systems/radar.h"
#include "playerInfo.h"
#include "main.h"
#include "components/faction.h"
#include "components/scanning.h"
#include "components/radarblock.h"
#include "radar.h"
#include "utils/rawScannerUtil.h"

int RadarRenderSystem::current_flags;
float RadarRenderSystem::current_scale;
float RadarRenderSystem::current_rotation_offset;
glm::vec2 RadarRenderSystem::radar_screen_center;
glm::vec2 RadarRenderSystem::view_position;
sp::Bitset RadarRenderSystem::visible_objects;
std::vector<RadarRenderSystem::Handler> RadarRenderSystem::handlers;


void BasicRadarRendering::renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity entity, glm::vec2 screen_position, float scale, float rotation, RadarTrace& trace)
{
    if ((RadarRenderSystem::current_flags & RadarRenderSystem::FlagLongRange) && !(trace.flags & RadarTrace::LongRange))
        return;

    auto scanstate = entity.getComponent<ScanState>();
    auto size = trace.radius * scale * 2.0f;
    size = std::clamp(size, trace.min_size, trace.max_size);

    auto color = trace.color;
    if (trace.flags & RadarTrace::ColorByFaction) {
        color = Faction::getInfo(entity).gm_color;
        if (my_spaceship)
        {
            if (entity == my_spaceship)
                color = glm::u8vec4(192, 192, 255, 255);
            else if (scanstate && scanstate->getStateFor(my_spaceship) == ScanState::State::NotScanned)
                color = glm::u8vec4(192, 192, 192, 255);
            else if (Faction::getRelation(my_spaceship, entity) == FactionRelation::Enemy)
                color = glm::u8vec4(255, 0, 0, 255);
            else if (Faction::getRelation(my_spaceship, entity) == FactionRelation::Friendly)
                color = glm::u8vec4(128, 255, 128, 255);
            else
                color = glm::u8vec4(128, 128, 255, 255);
        }
    }
    auto icon = trace.icon;
    if ((trace.flags & RadarTrace::ArrowIfNotScanned) && scanstate && my_spaceship)
    {
        // If the object is a ship that hasn't been scanned, draw the default icon.
        // Otherwise, draw the ship-specific icon.
        switch(scanstate->getStateFor(my_spaceship)) {
        case ScanState::State::NotScanned:
        case ScanState::State::FriendOrFoeIdentified:
            icon = "radar/ship.png";
            break;
        default:
            break;
        }
    }

    if ((trace.flags & RadarTrace::BlendAdd) && (trace.flags & RadarTrace::Rotate))
        renderer.drawRotatedSpriteBlendAdd(icon, screen_position, size, rotation);
    else if (trace.flags & RadarTrace::BlendAdd)
        renderer.drawRotatedSpriteBlendAdd(icon, screen_position, size, 0);
    else if (trace.flags & RadarTrace::Rotate)
        renderer.drawRotatedSprite(icon, screen_position, size, rotation, color);
    else
        renderer.drawSprite(icon, screen_position, size, color);
}

void BasicRadarRendering::renderOnRadar(sp::RenderTarget &renderer, sp::ecs::Entity entity, glm::vec2 screen_position, float scale, float rotation, RawRadarSignatureInfo &component)
{
    if (RadarRenderSystem::current_flags & 0b1110000 == 0)
        return;
    auto dynamic_signature = my_spaceship.getComponent<DynamicRadarSignatureInfo>();

    RawRadarSignatureInfo signature = component;
    if (dynamic_signature)
    {
        signature.biological += dynamic_signature->biological;
        signature.electrical += dynamic_signature->electrical;
        signature.gravity += dynamic_signature->gravity;
    }

    float r = GetEntityRadarTraceSize(entity);

    float band_radius = r;

    glm::u8vec4 band_color{32, 32, 32, 223};

    // Electrical (red)
    if ((RadarRenderSystem::current_flags & RadarRenderSystem::ElectricalTraces) && signature.electrical > 0.0f)
    {
        band_color.r += 64 + std::min(1.0f, abs(signature.electrical) * 100);
        if (signature.electrical > 1.0f)
            band_radius += r * (signature.electrical - 1.0f);
    }

    // Gravity (blue)
    if ((RadarRenderSystem::current_flags & RadarRenderSystem::GravitationalTraces) && signature.gravity > 0.0f)
    {
        band_color.b += 64 + std::min(1.0f, abs(signature.gravity) * 100);
        if (signature.gravity > 1.0f)
            band_radius += r * (signature.gravity - 1.0f);
    }

    // Biological (green)
    if ((RadarRenderSystem::current_flags & RadarRenderSystem::BiologicalTraces) && signature.biological > 0.0f)
    {
        band_color.g += 64 + std::min(1.0f, abs(signature.biological) * 100);
        if (signature.biological > 1.0f)
            band_radius += r * (signature.biological - 1.0f);
    }

    if (band_radius > 0.0f && band_color.r + band_color.g + band_color.b > 96)
    {
        band_radius = std::max(2.0f, band_radius);
        renderer.fillCircle(screen_position, band_radius * scale, band_color);
    }
}

void BasicRadarRendering::renderOnRadar(sp::RenderTarget &renderer, sp::ecs::Entity entity, glm::vec2 screen_position, float scale, float rotation, CallSign &callsign)
{
    if (entity == my_spaceship) return;
    
    renderer.drawText(sp::Rect(screen_position.x, screen_position.y - 15, 0, 0), callsign.callsign, sp::Alignment::Center, 15, bold_font);
}
