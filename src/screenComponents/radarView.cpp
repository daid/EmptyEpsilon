#include <graphics/opengl.h>
#include <unordered_set>

#include "featureDefs.h"
#include "ecs/query.h"
#include "systems/collision.h"

#include "main.h"
#include "gameGlobalInfo.h"
#include "tween.h"
#include "playerInfo.h"

#include "components/beamweapon.h"
#include "components/collision.h"
#include "components/docking.h"
#include "components/hull.h"
#include "components/shields.h"
#include "components/missiletubes.h"
#include "components/target.h"
#include "components/radar.h"
#include "components/radarblock.h"
#include "components/impulse.h"
#include "components/scanning.h"
#include "systems/missilesystem.h"
#include "systems/radarblock.h"
#include "systems/radar.h"

#include "radarView.h"
#include "missileTubeControls.h"
#include "targetsContainer.h"

#include "gui/theme.h"

namespace
{
    enum class RadarStencil : uint8_t
    {
        None = 0,
        RadarBounds = 1 << 0,
        VisibleSpace = 1 << 1,
        InBoundsAndVisible = RadarBounds | VisibleSpace,
        All = InBoundsAndVisible
    };

    constexpr std::underlying_type_t<RadarStencil> as_mask(RadarStencil mask)
    {
        return static_cast<std::underlying_type_t<RadarStencil>>(mask);
    }
}

GuiRadarView::GuiRadarView(GuiContainer* owner, string id, TargetsContainer* targets)
: GuiElement(owner, id),
    next_ghost_dot_update(0.0),
    targets(targets),
    missile_tube_controls(nullptr),
    view_position(0.0f,0.0f),
    view_rotation(0),
    auto_center_target(my_spaceship),
    auto_center_on_ship(true),
    auto_rotate_on_ship(false),
    auto_distance(true),
    distance(5000.0f),
    long_range(false),
    show_ghost_dots(false),
    show_waypoints(false),
    show_target_projection(false),
    show_missile_tubes(false),
    show_callsigns(false),
    show_heading_indicators(false),
    show_game_master_data(false),
    range_indicator_step_size(0.0f),
    background_alpha(255),
    style(Circular),
    fog_style(NoFogOfWar),
    mouse_down_func(nullptr),
    mouse_drag_func(nullptr),
    mouse_up_func(nullptr)
{
    radar_outline_style = theme->getStyle("radar_outline");
    ship_waypoint_background_style = theme->getStyle("ship_waypoint.background");
    ship_waypoint_text_style = theme->getStyle("ship_waypoint.text");
}

GuiRadarView::GuiRadarView(GuiContainer* owner, string id, float distance, TargetsContainer* targets)
: GuiElement(owner, id),
    next_ghost_dot_update(0.0),
    targets(targets),
    missile_tube_controls(nullptr),
    view_position(0.0f, 0.0f),
    view_rotation(0),
    auto_center_target(my_spaceship),
    auto_center_on_ship(true),
    auto_rotate_on_ship(false),
    distance(distance),
    long_range(false),
    show_ghost_dots(false),
    show_waypoints(false),
    show_target_projection(false),
    show_missile_tubes(false),
    show_callsigns(false),
    show_heading_indicators(false),
    show_game_master_data(false),
    range_indicator_step_size(0.0f),
    background_alpha(255),
    style(Circular),
    fog_style(NoFogOfWar),
    mouse_down_func(nullptr),
    mouse_drag_func(nullptr),
    mouse_up_func(nullptr)
{
    radar_outline_style = theme->getStyle("radar_outline");
    ship_waypoint_background_style = theme->getStyle("ship_waypoint.background");
    ship_waypoint_text_style = theme->getStyle("ship_waypoint.text");
}

void GuiRadarView::onDraw(sp::RenderTarget& renderer)
{
    // Auto-center on the target, defaulting to my_spaceship on creation.
    auto transform = auto_center_target.getComponent<sp::Transform>();

    // If target has no transform, it might be docked inside another ship.
    // Otherwise, if the target doesn't physically exist, fall back to
    // my_spaceship if possible.
    if (!transform)
    {
        if (auto dp = auto_center_target.getComponent<DockingPort>())
            transform = dp->target.getComponent<sp::Transform>();
        else if (!transform && my_spaceship)
            auto_center_target = my_spaceship;
        else
            auto_center_target = sp::ecs::Entity();
    }

    if (transform && auto_center_on_ship)
    {
        view_position = transform->getPosition();
        if (auto_rotate_on_ship)
            view_rotation = transform->getRotation() + 90;
    }

    if (auto_distance)
    {
        distance = long_range ? 30000.0f : 5000.0f;
        if (auto lrr = my_spaceship.getComponent<LongRangeRadar>())
            distance = long_range ? lrr->long_range : lrr->short_range;
    }

    // Make sure all the drawing up till now is no longer queued and passed to the GPU.
    renderer.finish();

    //We must take some care to not overstep our bounds,
    // quite literally.
    // We use scissoring to define a 'box' in which all draw operations can happen.
    // This allows the side main screen to work correctly even when falling back in the non-render texture path.
    auto origin = renderer.virtualToPixelPosition(rect.position);
    auto extents = renderer.virtualToPixelPosition(rect.position + rect.size);

    glEnable(GL_SCISSOR_TEST);
    glScissor(origin.x, renderer.getPhysicalSize().y - extents.y, extents.x - origin.x, extents.y - origin.y);

    // Draw the initial background 'clear' color.
    if (style == Rectangular)
    {
        drawBackground(renderer);
    }
    
    if ((style == CircularMasked || style == Circular))
    {
        // Draw the radar's outline. First, and before any stencil kicks in.
        // this way, the outline is not even a part of the rendering area.
        float r = std::min(rect.size.x, rect.size.y) * 0.5f;
        renderer.drawCircleOutline(getCenterPoint(), r, 2.0f, radar_outline_style->get(getState()).color);
    }

    // Stencil setup.
    renderer.finish();
    glEnable(GL_STENCIL_TEST);
    glStencilMask(as_mask(RadarStencil::InBoundsAndVisible));
    
    // By default, nothing's visible.
    auto clear_mask = as_mask(RadarStencil::None);
    if (style == Rectangular)
    {
        // Rectangular shape, radar bounds is the entire texture target.
        clear_mask |= as_mask(RadarStencil::RadarBounds);

        // Without fog of war (ie GM), everything is deemed visible :)
        if (fog_style == NoFogOfWar)
            clear_mask |= as_mask(RadarStencil::VisibleSpace);
    }
    glClearStencil(clear_mask);
    glClear(GL_STENCIL_BUFFER_BIT);

    glDepthMask(GL_FALSE); // Nothing in this process writes in the depth.
    
    glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
    
    if ((style == CircularMasked || style == Circular))
    {
        // When drawing the radar 'scope', mark the area as "in sight" and "visible".
        glStencilFunc(GL_ALWAYS, as_mask(RadarStencil::InBoundsAndVisible), 0);

        // Draws the radar circle shape.
        // Note that this draws both in the stencil and the color buffer!
        renderer.fillCircle(getCenterPoint(), std::min(rect.size.x, rect.size.y) / 2.0f - 2.0f, glm::u8vec4{ 20, 20, 20, background_alpha });
        renderer.finish();
    }

    if (fog_style == NebulaFogOfWar)
    {
        // Draw the *blocked* areas.
        // In this cas, we want to clear the 'visible' bit,
        // for all the stencil that has the radar one.
        glStencilFunc(GL_EQUAL, as_mask(RadarStencil::RadarBounds), as_mask(RadarStencil::RadarBounds));
        drawNebulaBlockedAreas(renderer);
    }
    else if (fog_style == FriendlysShortRangeFogOfWar)
    {
        // Draws the *visible* areas.
        // Add the visible states to anything that's in friendly sight (and still in bounds)
        glStencilFunc(GL_EQUAL, as_mask(RadarStencil::InBoundsAndVisible), as_mask(RadarStencil::RadarBounds));
        drawNoneFriendlyBlockedAreas(renderer);
    }

    // Stencil is setup!
    renderer.finish();
    glStencilMask(as_mask(RadarStencil::None)); // disable writes.
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP); // Back to defaults.

    // These always draw within the radar's confine.
    glStencilFunc(GL_EQUAL, as_mask(RadarStencil::RadarBounds), as_mask(RadarStencil::RadarBounds));
    drawSectorGrid(renderer);
    drawRangeIndicators(renderer);
    if (show_target_projection)
        drawTargetProjections(renderer);
    if (show_missile_tubes)
        drawMissileTubes(renderer);

    ///Start drawing of foreground
    // Foreground is radar confine + not blocked out.
    
    //Draw things that are masked out by fog-of-war
    if (show_ghost_dots)
    {
        updateGhostDots();
        drawGhostDots(renderer);
    }

    drawObjects(renderer);

    // Post masking
    renderer.finish();
    glStencilFunc(GL_EQUAL, as_mask(RadarStencil::RadarBounds), as_mask(RadarStencil::RadarBounds));
    if (show_game_master_data)
        drawObjectsGM(renderer);

    if (show_waypoints)
        drawWaypoints(renderer);
    if (show_heading_indicators)
        drawHeadingIndicators(renderer);
    drawTargets(renderer);

    if (style == Rectangular && transform)
    {
        auto ship_offset = (transform->getPosition() - view_position) / distance * std::min(rect.size.x, rect.size.y) / 2.0f;
        if (ship_offset.x < -rect.size.x / 2.0f || ship_offset.x > rect.size.x / 2.0f || ship_offset.y < -rect.size.y / 2.0f || ship_offset.y > rect.size.y / 2.0f)
        {
            glm::vec2 position(rect.position.x + rect.size.x / 2.0f, rect.position.y + rect.size.y / 2.0f);
            position += ship_offset / glm::length(ship_offset) * std::min(rect.size.x, rect.size.y) * 0.4f;

            renderer.drawRotatedSprite("waypoint.png", position, 32, vec2ToAngle(ship_offset) - 90);
        }
    }
    // Done with the stencil.
    renderer.finish();
    glDepthMask(GL_TRUE);
    glDisable(GL_STENCIL_TEST);
    glDisable(GL_SCISSOR_TEST);
}

void GuiRadarView::updateGhostDots()
{
    if (next_ghost_dot_update < engine->getElapsedTime())
    {
        next_ghost_dot_update = engine->getElapsedTime() + 5.0f;
        for(auto [entity, impulse, transform] : sp::ecs::Query<ImpulseEngine, sp::Transform>())
        {
            if (glm::length(transform.getPosition() - view_position) < distance)
            {
                ghost_dots.push_back(GhostDot(transform.getPosition()));
            }
        }

        for(unsigned int n=0; n < ghost_dots.size(); n++)
        {
            if (ghost_dots[n].end_of_life <= engine->getElapsedTime())
            {
                ghost_dots.erase(ghost_dots.begin() + n);
                n--;
            }
        }
    }
}

void GuiRadarView::drawBackground(sp::RenderTarget& renderer)
{
    uint8_t tint = fog_style == NoFogOfWar ? 20 : 0;
    // When drawing a non-rectangular radar (ie circle),
    // we need full transparency on the outer edge.
    // We then use the stencil mask to allow the actual drawing.
    if (style == Rectangular)
        renderer.fillRect(rect, {tint, tint, tint, background_alpha});
    else
        renderer.fillRect(rect, {0, 0, 0, 0});
}

void GuiRadarView::drawNoneFriendlyBlockedAreas(sp::RenderTarget& renderer)
{
    if (my_spaceship)
    {
        float scale = std::min(rect.size.x, rect.size.y) / 2.0f / distance;

        for(auto [entity, ssrr, transform] : sp::ecs::Query<ShareShortRangeRadar, sp::Transform>())
        {
            if (Faction::getRelation(my_spaceship, entity) != FactionRelation::Friendly)
                continue;
            if (auto lrr = entity.getComponent<LongRangeRadar>())
            {
                auto r = lrr->short_range * scale;
                renderer.fillCircle(worldToScreen(transform.getPosition()), r, glm::u8vec4{ 20, 20, 20, background_alpha });
            } else {
                auto r = 5000.f * scale;
                renderer.fillCircle(worldToScreen(transform.getPosition()), r, glm::u8vec4{ 20, 20, 20, background_alpha });
            }
        }
    }
}

void GuiRadarView::drawSectorGrid(sp::RenderTarget& renderer)
{
    auto radar_screen_center = rect.center();
    float scale = std::min(rect.size.x, rect.size.y) / 2.0f / distance;

    constexpr float sector_size = 20000;
    const float sub_sector_size = sector_size / 8;

    int sector_x_min = floor((view_position.x - (radar_screen_center.x - rect.position.x) / scale) / sector_size) + 1;
    int sector_x_max = floor((view_position.x + (rect.position.x + rect.size.x - radar_screen_center.x) / scale) / sector_size);
    int sector_y_min = floor((view_position.y - (radar_screen_center.y - rect.position.y) / scale) / sector_size) + 1;
    int sector_y_max = floor((view_position.y + (rect.position.y + rect.size.y - radar_screen_center.y) / scale) / sector_size);
    glm::u8vec4 color(64, 64, 128, 128);
    for(int sector_x = sector_x_min - 1; sector_x <= sector_x_max; sector_x++)
    {
        float x = sector_x * sector_size;
        for(int sector_y = sector_y_min - 1; sector_y <= sector_y_max; sector_y++)
        {
            float y = sector_y * sector_size;
            auto pos = worldToScreen(glm::vec2(x+(30/scale),y+(30/scale)));
            renderer.drawText(sp::Rect(pos.x-10, pos.y-10, 20, 20), getSectorName(glm::vec2(sector_x * sector_size + sub_sector_size, sector_y * sector_size + sub_sector_size)), sp::Alignment::Center, 30, bold_font, color);
        }
    }

    for(int sector_x = sector_x_min; sector_x <= sector_x_max; sector_x++)
    {
        float x = sector_x * sector_size;
        renderer.drawLine(worldToScreen(glm::vec2(x, (sector_y_min-1)*sector_size)), worldToScreen(glm::vec2(x, (sector_y_max+1)*sector_size)), color);
    }
    for(int sector_y = sector_y_min; sector_y <= sector_y_max; sector_y++)
    {
        float y = sector_y * sector_size;
        renderer.drawLine(worldToScreen(glm::vec2((sector_x_min-1)*sector_size, y)), worldToScreen(glm::vec2((sector_x_max+1)*sector_size, y)), color);
    }

    color = glm::u8vec4(64, 64, 128, 255);
    int sub_sector_x_min = floor((view_position.x - (radar_screen_center.x - rect.position.x) / scale) / sub_sector_size) + 1;
    int sub_sector_x_max = floor((view_position.x + (rect.position.x + rect.size.x - radar_screen_center.x) / scale) / sub_sector_size);
    int sub_sector_y_min = floor((view_position.y - (radar_screen_center.y - rect.position.y) / scale) / sub_sector_size) + 1;
    int sub_sector_y_max = floor((view_position.y + (rect.position.y + rect.size.y - radar_screen_center.y) / scale) / sub_sector_size);

    for(int sector_x = sub_sector_x_min; sector_x <= sub_sector_x_max; sector_x++)
    {
        float x = sector_x * sub_sector_size;
        for(int sector_y = sub_sector_y_min; sector_y <= sub_sector_y_max; sector_y++)
        {
            float y = sector_y * sub_sector_size;
            renderer.drawPoint(worldToScreen(glm::vec2(x,y)), color);
        }
    }
    //We finish the rendering here, to make sure the sector grid lines are drawn below anything else.
    renderer.finish();
}

void GuiRadarView::drawNebulaBlockedAreas(sp::RenderTarget& renderer)
{
    auto transform = my_spaceship.getComponent<sp::Transform>();
    if (!transform)
        return;
    auto scan_center = transform->getPosition();
    float scale = std::min(rect.size.x, rect.size.y) / 2.0f / distance;

    for(auto [entity, radarblock, transform] : sp::ecs::Query<RadarBlock, sp::Transform>())
    {
        auto diff = transform.getPosition() - scan_center;
        float diff_len = glm::length(diff);

        if (diff_len < radarblock.range + distance)
        {
            if (diff_len < radarblock.range)
            {
                // Inside a nebula - everything is blocked out.
                renderer.fillRect(rect, glm::u8vec4(0, 0, 0, 255));
                
                // Leave the loop here: there's no point adding more blocked areas.
                break;
            }else{
                float r = radarblock.range * scale;
                renderer.fillCircle(worldToScreen(transform.getPosition()), r, glm::u8vec4(0, 0, 0, 255));

                if (radarblock.behind) {
                    float diff_angle = vec2ToAngle(diff);
                    float angle = glm::degrees(acosf(radarblock.range / diff_len));

                    auto pos_a = transform.getPosition() - vec2FromAngle(diff_angle + angle) * radarblock.range;
                    auto pos_b = transform.getPosition() - vec2FromAngle(diff_angle - angle) * radarblock.range;
                    auto pos_c = scan_center + glm::normalize(pos_a - scan_center) * distance * 3.0f;
                    auto pos_d = scan_center + glm::normalize(pos_b - scan_center) * distance * 3.0f;
                    auto pos_e = scan_center + diff / diff_len * distance * 3.0f;

                    renderer.drawTriangleStrip({worldToScreen(pos_a), worldToScreen(pos_b), worldToScreen(pos_c), worldToScreen(pos_d), worldToScreen(pos_e)}, glm::u8vec4(0, 0, 0, 255));
                }
            }
        }
    }

    // ship's short radar range is always visible.
    if (auto lrr = my_spaceship.getComponent<LongRangeRadar>())
    {
        float scale = std::min(rect.size.x, rect.size.y) / 2.0f / distance;

        auto r = lrr->short_range * scale;
        renderer.fillCircle(worldToScreen(transform->getPosition()), r, glm::u8vec4{ 20, 20, 20, background_alpha });
    }
}

void GuiRadarView::drawGhostDots(sp::RenderTarget& renderer)
{
    for(unsigned int n=0; n<ghost_dots.size(); n++)
    {
        renderer.drawPoint(worldToScreen(ghost_dots[n].position), glm::u8vec4(255, 255, 255, 255 * std::max(((ghost_dots[n].end_of_life - engine->getElapsedTime()) / GhostDot::total_lifetime), 0.f)));
    }
}

void GuiRadarView::drawWaypoints(sp::RenderTarget& renderer)
{
    auto waypoints = my_spaceship.getComponent<Waypoints>();
    if (!waypoints)
        return;

    glm::vec2 radar_screen_center(rect.position.x + rect.size.x / 2.0f, rect.position.y + rect.size.y / 2.0f);

    for(unsigned int n=0; n<waypoints->waypoints.size(); n++)
    {
        auto screen_position = worldToScreen(waypoints->waypoints[n].position);

        // TODO: Define sprite image in GuiThemeStyle
        renderer.drawSprite("waypoint.png", screen_position - glm::vec2(0, 10), 20, ship_waypoint_background_style->get(getState()).color);
        renderer.drawText(sp::Rect(screen_position.x, screen_position.y - 10, 0, 0), string(waypoints->waypoints[n].id), sp::Alignment::Center, 14, bold_font, ship_waypoint_text_style->get(getState()).color);

        if (style != Rectangular && glm::length(screen_position - radar_screen_center) > std::min(rect.size.x, rect.size.y) * 0.5f)
        {
            screen_position = radar_screen_center + ((screen_position - radar_screen_center) / glm::length(screen_position - radar_screen_center) * std::min(rect.size.x, rect.size.y) * 0.4f);

            renderer.drawRotatedSprite("waypoint.png", screen_position, 20, vec2ToAngle(screen_position - radar_screen_center) - 90, ship_waypoint_background_style->get(getState()).color);
            renderer.drawText(sp::Rect(screen_position.x, screen_position.y, 0, 0), string(waypoints->waypoints[n].id), sp::Alignment::Center, 14, bold_font, ship_waypoint_text_style->get(getState()).color);
        }
    }
}

void GuiRadarView::drawRangeIndicators(sp::RenderTarget& renderer)
{
    if (range_indicator_step_size < 1.0f)
        return;

    glm::vec2 radar_screen_center(rect.position.x + rect.size.x / 2.0f, rect.position.y + rect.size.y / 2.0f);
    float scale = std::min(rect.size.x, rect.size.y) / 2.0f / distance;

    for(float circle_size=range_indicator_step_size; circle_size < distance; circle_size+=range_indicator_step_size)
    {
        float s = circle_size * scale;
        renderer.drawCircleOutline(radar_screen_center, s, 2.0, glm::u8vec4(255, 255, 255, 16));
        renderer.drawText(sp::Rect(radar_screen_center.x, radar_screen_center.y - s - 20, 0, 0), string(int(circle_size / 1000.0f + 0.1f)) + DISTANCE_UNIT_1K, sp::Alignment::Center, 20, bold_font, glm::u8vec4(255, 255, 255, 32));
    }
}

void GuiRadarView::drawTargetProjections(sp::RenderTarget& renderer)
{
    const float seconds_per_distance_tick = 5.0f;
    float scale = std::min(rect.size.x, rect.size.y) / 2.0f / distance;

    auto transform = my_spaceship.getComponent<sp::Transform>();
    if (transform && missile_tube_controls) {
        auto tubes = my_spaceship.getComponent<MissileTubes>();
        if (tubes) {
            for(auto& mount : tubes->mounts)
            {
                if (mount.state != MissileTubes::MountPoint::State::Loaded)
                    continue;
                auto fire_position = transform->getPosition() + rotateVec2(glm::vec2(mount.position), transform->getRotation());

                const MissileWeaponData& data = MissileWeaponData::getDataFor(mount.type_loaded);
                float fire_angle = mount.direction + (transform->getRotation());
                float missile_target_angle = fire_angle;
                if (data.turnrate > 0.0f)
                {
                    if (missile_tube_controls->getManualAim())
                    {
                        missile_target_angle = missile_tube_controls->getMissileTargetAngle();
                    }else if (auto target = my_spaceship.getComponent<Target>()) {
                        float firing_solution = MissileSystem::calculateFiringSolution(my_spaceship, mount, target->entity);
                        if (firing_solution != std::numeric_limits<float>::infinity())
                            missile_target_angle = firing_solution;
                    }
                }

                float angle_diff = angleDifference(missile_target_angle, fire_angle);
                float turn_radius = ((360.0f / data.turnrate) * data.speed) / (2.0f * float(M_PI));
                if (data.turnrate == 0.0f)
                    turn_radius = 0.0f;

                float left_or_right = 90;
                if (angle_diff > 0)
                    left_or_right = -90;

                auto turn_center = vec2FromAngle(fire_angle + left_or_right) * turn_radius;
                auto turn_exit = turn_center + vec2FromAngle(missile_target_angle - left_or_right) * turn_radius;

                float turn_distance = fabs(angle_diff) / 360.0f * (turn_radius * 2.0f * float(M_PI));
                float lifetime_after_turn = data.lifetime - turn_distance / data.speed;
                float length_after_turn = data.speed * lifetime_after_turn;

                std::vector<glm::vec2> missile_path;
                missile_path.push_back(worldToScreen(fire_position));
                for(int cnt=0; cnt<10; cnt++)
                    missile_path.push_back(worldToScreen(fire_position + (turn_center + vec2FromAngle(fire_angle - angle_diff / 10.0f * cnt - left_or_right) * turn_radius)));
                missile_path.push_back(worldToScreen(fire_position + turn_exit));
                missile_path.push_back(worldToScreen(fire_position + (turn_exit + vec2FromAngle(missile_target_angle) * length_after_turn)));
                renderer.drawLine(missile_path, glm::u8vec4(255, 255, 255, 128));

                float offset = seconds_per_distance_tick * data.speed;
                for(int cnt=0; cnt<floor(data.lifetime / seconds_per_distance_tick); cnt++)
                {
                    glm::vec2 p;
                    glm::vec2 n{};
                    if (offset < turn_distance)
                    {
                        n = vec2FromAngle(fire_angle - (angle_diff * offset / turn_distance) - left_or_right);
                        p = worldToScreen(fire_position + (turn_center + n * turn_radius));
                    }else{
                        p = worldToScreen(fire_position + (turn_exit + vec2FromAngle(missile_target_angle) * (offset - turn_distance)));
                        n = vec2FromAngle(missile_target_angle + 90.0f);
                    }
                    n = rotateVec2(n, -view_rotation);
                    n = glm::normalize(n);

                    renderer.drawLine(p - glm::vec2(n.x, n.y) * 10.0f, p + glm::vec2(n.x, n.y) * 10.0f, glm::u8vec4{255,255,255,255});

                    offset += seconds_per_distance_tick * data.speed;
                }
            }
        }
    }

    if (targets)
    {
        for(auto obj : targets->getTargets())
        {
            auto physics = obj.getComponent<sp::Physics>();
            if (!physics || glm::length2(physics->getVelocity()) < 1.0f)
                continue;
            auto transform = obj.getComponent<sp::Transform>();
            if (!transform)
                continue;

            auto start = worldToScreen(transform->getPosition());
            renderer.drawLine(start, worldToScreen(transform->getPosition() + physics->getVelocity() * 60.0f), glm::u8vec4(255, 255, 255, 128), glm::u8vec4(255, 255, 255, 0));
            glm::vec2 n = glm::normalize(rotateVec2(glm::vec2(-physics->getVelocity().y, physics->getVelocity().x), -view_rotation)) * 10.0f;
            for(int cnt=0; cnt<5; cnt++)
            {
                auto p = rotateVec2(physics->getVelocity() * (seconds_per_distance_tick * (cnt + 1.0f) * scale), -view_rotation);
                renderer.drawLine(start + p + n, start + p - n, glm::u8vec4(255, 255, 255, 128 - cnt * 20));
            }
        }
    }
}

void GuiRadarView::drawMissileTubes(sp::RenderTarget& renderer)
{
    float scale = std::min(rect.size.x, rect.size.y) / 2.0f / distance;

    auto tubes = my_spaceship.getComponent<MissileTubes>();
    if (!tubes) return;
    auto transform = my_spaceship.getComponent<sp::Transform>();
    if (!transform) return;
    for(auto& mount : tubes->mounts)
    {
        auto fire_position = transform->getPosition() + rotateVec2(glm::vec2(mount.position), transform->getRotation());
        auto fire_draw_position = worldToScreen(fire_position);

        float fire_angle = transform->getRotation() + mount.direction - view_rotation;

        renderer.drawLine(fire_draw_position, fire_draw_position + (vec2FromAngle(fire_angle) * 1000.0f * scale), glm::u8vec4(128, 128, 128, 128), glm::u8vec4(128, 128, 128, 0));
    }
}

void GuiRadarView::drawObjects(sp::RenderTarget& renderer)
{
    float scale = std::min(rect.size.x, rect.size.y) / 2.0f / distance;

    sp::Bitset visible_objects;
    switch(fog_style)
    {
    case NoFogOfWar:
        for(auto [entity, transform] : sp::ecs::Query<sp::Transform>())
            visible_objects.set(entity.getIndex());
        break;
    case FriendlysShortRangeFogOfWar:
        // Reveal objects if they are within short-range radar range (or 5U) of
        // a friendly ship, station, or scan probe.

        // Continue only if the player's ship exists.
        if (!my_spaceship)
        {
            return;
        }

        // For each SpaceObject on the map...
        for(auto [entity, transform] : sp::ecs::Query<sp::Transform>())
        {
            // If the object can't hide in a nebula, it's considered visible.
            if (entity.hasComponent<NeverRadarBlocked>()) {
                visible_objects.set(entity.getIndex());
                continue;
            }

            // Consider the object only if it is:
            // - Any ShipTemplateBasedObject (ship or station)
            // - A SpaceObject belonging to a friendly faction
            // - The player's ship
            // - A scan probe owned by the player's ship
            // This check is duplicated in RelayScreen::onDraw.
            if (!entity.hasComponent<ShareShortRangeRadar>())
                continue;
            if (Faction::getRelation(my_spaceship, entity) != FactionRelation::Friendly)
                continue;

            // Set the radius to reveal as getShortRangeRadarRange() if the
            // object's a ShipTemplateBasedObject. Otherwise, default to 5U.
            float r = entity.getComponent<LongRangeRadar>() ? entity.getComponent<LongRangeRadar>()->short_range : 5000.0f;

            // Query for objects within short-range radar/5U of this object.
            auto position = transform.getPosition();

            // For each of those objects, check if it is at least partially
            // inside the revealed radius. If so, reveal the object on the map.
            for(auto entity2 : sp::CollisionSystem::queryArea(position - glm::vec2(r, r), position + glm::vec2(r, r)))
            {
                //TODO: This isn't great, as not everything will collision attached...
                auto trace = entity2.getComponent<RadarTrace>();
                float r2 = r + (trace ? trace->radius : 300.0f);
                if (auto t2 = entity2.getComponent<sp::Transform>()) {
                    if (glm::length2(transform.getPosition() - t2->getPosition()) < r2*r2)
                        visible_objects.set(entity2.getIndex());
                }
            }
        }

        break;
    case NebulaFogOfWar:
        if (auto transform = my_spaceship.getComponent<sp::Transform>())
        {
            auto lrr = my_spaceship.getComponent<LongRangeRadar>();
            auto short_range = lrr ? lrr->short_range : 5000.0f;
            for(auto [entity, t] : sp::ecs::Query<sp::Transform>())
            {
                if (RadarBlockSystem::isRadarBlockedFrom(transform->getPosition(), entity, short_range))
                    continue;
                visible_objects.set(entity.getIndex());
            }
        }
        break;
    }

    int flags = 0;
    if (long_range)
        flags |= RadarRenderSystem::FlagLongRange;
    else
        flags |= RadarRenderSystem::FlagShortRange;
    if (show_game_master_data)
        flags |= RadarRenderSystem::FlagGM;
    if (show_callsigns)
        flags |= RadarRenderSystem::FlagCallsigns;

    glm::vec2 radar_screen_center = rect.center();

    glStencilFunc(GL_EQUAL, as_mask(RadarStencil::RadarBounds), as_mask(RadarStencil::RadarBounds));
    RadarRenderSystem::render(renderer, radar_screen_center, scale, view_position, view_rotation, flags, visible_objects);
}

void GuiRadarView::drawObjectsGM(sp::RenderTarget& renderer)
{
    /*
    float scale = std::min(rect.size.x, rect.size.y) / 2.0f / distance;
    foreach(SpaceObject, obj, space_object_list)
    {
        auto object_position_on_screen = worldToScreen(obj->getPosition());
        auto trace = obj->entity.getComponent<RadarTrace>();
        float r = trace ? trace->radius * scale : 0.0f;
        sp::Rect object_rect(object_position_on_screen.x - r, object_position_on_screen.y - r, r * 2, r * 2);
        if (rect.overlaps(object_rect))
        {
            obj->drawOnGMRadar(renderer, object_position_on_screen, scale, view_rotation, long_range);
        }

        if (!long_range)
        {
            auto hull = obj->entity.getComponent<Hull>();
            if (hull) {
                renderer.fillRect(sp::Rect(object_position_on_screen.x - 30, object_position_on_screen.y - 30, 60 * hull->current / hull->max, 5), glm::u8vec4(128, 255, 128, 128));
            }
        }
    }
    */
}

void GuiRadarView::drawTargets(sp::RenderTarget& renderer)
{
    float scale = std::min(rect.size.x, rect.size.y) / 2.0f / distance;

    if (!targets)
        return;

    for(auto obj : targets->getTargets())
    {
        auto transform = obj.getComponent<sp::Transform>();
        if (!transform) continue;
        auto object_position_on_screen = worldToScreen(transform->getPosition());
        auto trace = obj.getComponent<RadarTrace>();
        float r = trace ? trace->radius * scale : 0.0f;
        sp::Rect object_rect(object_position_on_screen.x - r, object_position_on_screen.y - r, r * 2, r * 2);
        if (obj != my_spaceship && rect.overlaps(object_rect))
        {
            renderer.drawSprite("redicule.png", object_position_on_screen, 48);
        }
    }

    auto waypoints = my_spaceship.getComponent<Waypoints>();
    if (my_spaceship && waypoints && targets->getWaypointIndex() > -1)
    {
        if (auto waypoint_position = waypoints->get(targets->getWaypointIndex())) {
            auto object_position_on_screen = worldToScreen(waypoint_position.value());

            renderer.drawSprite("redicule.png", object_position_on_screen - glm::vec2{0, 10}, 48);
        }
    }
}

void GuiRadarView::drawHeadingIndicators(sp::RenderTarget& renderer)
{
    auto radar_screen_center = rect.center();
    float scale = std::min(rect.size.x, rect.size.y) / 2.0f;

    // If radar is 600-800px then tigs run every 20 degrees, small tigs every 5.
    // So if radar is 400-600x then the tigs should run every 45 degrees and smalls every 5.
    // If radar is <400px, tigs every 90, smalls every 10.
    unsigned int tig_interval = 20;
    unsigned int small_tig_interval = 5;

    if (scale >= 300.0f)
    {
        tig_interval = 20;
        small_tig_interval = 5;
    }
    else if (scale > 200.0f && scale <= 300.0f)
    {
        tig_interval = 45;
        small_tig_interval = 5;
    }
    else if (scale <= 200.0f)
    {
        tig_interval = 90;
        small_tig_interval = 10;
    }

    // Main radar tigs
    for(unsigned int n = 0; n < 360; n += tig_interval)
    {
        renderer.drawLine(
            radar_screen_center + vec2FromAngle(float(n) - 90 - view_rotation) * (scale - 20),
            radar_screen_center + vec2FromAngle(float(n) - 90 - view_rotation) * (scale - 40),
            {255, 255, 255, 255});
    }

    for(unsigned int n = 0; n < 360; n += small_tig_interval)
    {
        renderer.drawLine(
            radar_screen_center + vec2FromAngle(float(n) - 90 - view_rotation) * (scale - 20),
            radar_screen_center + vec2FromAngle(float(n) - 90 - view_rotation) * (scale - 30),
            {255, 255, 255, 255});
    }

    for(unsigned int n = 0; n < 360; n += tig_interval)
    {
        renderer.drawRotatedText(
            radar_screen_center + vec2FromAngle(float(n) - 90 - view_rotation) * (scale - 50), n-view_rotation,
            string(n), 15.0f, main_font, {255, 255, 255, 255});
    }
}

glm::vec2 GuiRadarView::worldToScreen(glm::vec2 world_position)
{
    glm::vec2 radar_screen_center = rect.center();
    float scale = std::min(rect.size.x, rect.size.y) / 2.0f / distance;

    auto radar_position = rotateVec2((world_position - view_position) * scale, -view_rotation);
    return glm::vec2(radar_position.x, radar_position.y) + radar_screen_center;
}

glm::vec2 GuiRadarView::screenToWorld(glm::vec2 screen_position)
{
    glm::vec2 radar_screen_center = rect.center();
    float scale = std::min(rect.size.x, rect.size.y) / 2.0f / distance;

    glm::vec2 radar_position = rotateVec2((screen_position - radar_screen_center) / scale, view_rotation);
    return view_position + glm::vec2(radar_position.x, radar_position.y);
}

bool GuiRadarView::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    if (style == Circular || style == CircularMasked)
    {
        float radius = std::min(rect.size.x, rect.size.y) / 2.0f;
        if (glm::length(position - getCenterPoint()) > radius)
            return false;
    }
    if (!mouse_down_func && !mouse_drag_func && !mouse_up_func)
        return false;
    if (mouse_down_func)
        mouse_down_func(button, screenToWorld(position));
    return true;
}

void GuiRadarView::onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (mouse_drag_func)
        mouse_drag_func(screenToWorld(position));
}

void GuiRadarView::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (mouse_up_func)
        mouse_up_func(screenToWorld(position));
}
