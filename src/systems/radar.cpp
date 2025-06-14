#include "systems/radar.h"
#include "systems/ai.h"
#include "playerInfo.h"
#include "main.h"
#include "components/faction.h"
#include "components/scanning.h"
#include "ai/ai.h"

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

void BasicRadarRendering::renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity entity, glm::vec2 screen_position, float scale, float rotation, CallSign& callsign)
{
    if (entity == my_spaceship) return;
    
    renderer.drawText(sp::Rect(screen_position.x, screen_position.y - 15, 0, 0), callsign.callsign, sp::Alignment::Center, 15, bold_font);
}
