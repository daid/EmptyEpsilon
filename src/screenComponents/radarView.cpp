#include <SFML/OpenGL.hpp>

#include "main.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/nebula.h"
#include "spaceObjects/scanProbe.h"
#include "playerInfo.h"
#include "radarView.h"
#include "missileTubeControls.h"
#include "targetsContainer.h"

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
    view_position(sf::Vector2f(0.0f,0.0f)),
    view_rotation(0),
    auto_center_on_my_ship(true),
    auto_rotate_on_my_ship(false),
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
}

GuiRadarView::GuiRadarView(GuiContainer* owner, string id, float distance, TargetsContainer* targets)
: GuiElement(owner, id),
    next_ghost_dot_update(0.0),
    targets(targets),
    missile_tube_controls(nullptr),
    view_position(sf::Vector2f(0.0f,0.0f)),
    view_rotation(0),
    auto_center_on_my_ship(true),
    auto_rotate_on_my_ship(false),
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
}

void GuiRadarView::onDraw(sf::RenderTarget& window)
{
    //Hacky, when not relay and we have a ship, center on it.
    if (my_spaceship && auto_center_on_my_ship) {
        view_position = my_spaceship->getPosition();
    }
    if (my_spaceship && auto_rotate_on_my_ship) {
        view_rotation = my_spaceship->getRotation() + 90;
    }
    if (auto_distance)
    {
        distance = long_range ? 30000.0f : 5000.0f;
        if (my_spaceship)
        {
            if (long_range)
                distance = my_spaceship->getLongRangeRadarRange();
            else
                distance = my_spaceship->getShortRangeRadarRange();
        }
    }

    //Setup our texture for rendering
    auto use_rendertexture = adjustRenderTexture(background_texture);
    auto& radar_target = use_rendertexture ? background_texture : window;

    if (!use_rendertexture)
    {
        // When we are not using a render texture, we must take some care to not overstep our bounds,
        // quite literally.
        // We use scissoring to define a 'box' in which all draw operations can happen.
        // This allows the side main screen to work correctly even when falling back in the non-render texture path.
        auto origin = radar_target.mapCoordsToPixel(sf::Vector2f{ rect.left, rect.top });
        auto extents = radar_target.mapCoordsToPixel(sf::Vector2f{ rect.width, rect.height });

        radar_target.setActive(true);

        glEnable(GL_SCISSOR_TEST);
        glScissor(origin.x, origin.y, extents.x, extents.y);
    }

    // Draw the initial background 'clear' color.
    if (use_rendertexture || style == Rectangular)
    {
        drawBackground(radar_target);
    }
    
    
    sf::CircleShape circle(0.f, 50);
    if ((style == CircularMasked || style == Circular))
    {
        // Draw the radar's outline. First, and before any stencil kicks in.
        // this way, the outline is not even a part of the rendering area.
        float r = std::min(rect.width, rect.height) / 2.0f - 2.0f;
        circle.setRadius(r);
        circle.setOrigin(r, r);
        circle.setPosition(getCenterPoint());
        circle.setFillColor(sf::Color::Transparent);
        circle.setOutlineThickness(2.f);
        circle.setOutlineColor(colorConfig.radar_outline);
        radar_target.draw(circle);
    }

    // Ensure the calls land in the context of the RT.
    // Even if we don't use multithreading, there are still setup per platforms
    // (for instance, FBO binding when they're used).
    // Each SFML call may reset the binding,
    // so we have to keep re-activating the target window all the time.
    // We're relying on stencil buffer to draw the radar:
    radar_target.setActive(true);

    // Stencil setup.
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
        circle.setFillColor(sf::Color{ 20, 20, 20, background_alpha });
        circle.setOutlineThickness(0.f);
        radar_target.draw(circle);
    }

    radar_target.setActive(true);
    if (fog_style == NebulaFogOfWar)
    {
        // Draw the *blocked* areas.
        // In this cas, we want to clear the 'visible' bit,
        // for all the stencil that has the radar one.
        glStencilFunc(GL_EQUAL, as_mask(RadarStencil::RadarBounds), as_mask(RadarStencil::RadarBounds));
        drawNebulaBlockedAreas(radar_target);
    }
    else if (fog_style == FriendlysShortRangeFogOfWar)
    {
        // Draws the *visible* areas.
        // Add the visible states to anything that's in friendly sight (and still in bounds)
        glStencilFunc(GL_EQUAL, as_mask(RadarStencil::InBoundsAndVisible), as_mask(RadarStencil::RadarBounds));
        drawNoneFriendlyBlockedAreas(radar_target);
    }

    // Stencil is setup!
    radar_target.setActive(true);
    glStencilMask(as_mask(RadarStencil::None)); // disable writes.
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP); // Back to defaults.

    // These always draw within the radar's confine.
    glStencilFunc(GL_EQUAL, as_mask(RadarStencil::RadarBounds), as_mask(RadarStencil::RadarBounds));
    drawSectorGrid(radar_target);
    drawRangeIndicators(radar_target);
    if (show_target_projection)
        drawTargetProjections(radar_target);
    if (show_missile_tubes)
        drawMissileTubes(radar_target);

    ///Start drawing of foreground
    // Foreground is radar confine + not blocked out.
    
    //Draw things that are masked out by fog-of-war
    if (show_ghost_dots)
    {
        updateGhostDots();
        drawGhostDots(radar_target);
    }

    drawObjects(radar_target);

    // Post masking
    radar_target.setActive(true);
    glStencilFunc(GL_EQUAL, as_mask(RadarStencil::RadarBounds), as_mask(RadarStencil::RadarBounds));
    if (show_game_master_data)
        drawObjectsGM(radar_target);

    if (show_waypoints)
        drawWaypoints(radar_target);
    if (show_heading_indicators)
        drawHeadingIndicators(radar_target);
    drawTargets(radar_target);

    if (style == Rectangular && my_spaceship)
    {
        sf::Vector2f ship_offset = (my_spaceship->getPosition() - view_position) / distance * std::min(rect.width, rect.height) / 2.0f;
        if (ship_offset.x < -rect.width / 2.0f || ship_offset.x > rect.width / 2.0f || ship_offset.y < -rect.height / 2.0f || ship_offset.y > rect.height / 2.0f)
        {
            sf::Vector2f position(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0);
            position += ship_offset / sf::length(ship_offset) * std::min(rect.width, rect.height) * 0.4f;

            sf::Sprite arrow_sprite;
            textureManager.setTexture(arrow_sprite, "waypoint");
            arrow_sprite.setPosition(position);
            arrow_sprite.setRotation(sf::vector2ToAngle(ship_offset) - 90);
            radar_target.draw(arrow_sprite);
        }
    }
    // Done with the stencil.
    radar_target.setActive(true);
    glDepthMask(GL_TRUE);
    glDisable(GL_STENCIL_TEST);
    
    if (!use_rendertexture)
    {
        glDisable(GL_SCISSOR_TEST);
    }

    radar_target.setActive(false);

    if (use_rendertexture)
    {
        //Render the final radar
        drawRenderTexture(background_texture, window);
    }
    
}

void GuiRadarView::updateGhostDots()
{
    if (next_ghost_dot_update < engine->getElapsedTime())
    {
        next_ghost_dot_update = engine->getElapsedTime() + 5.0;
        foreach(SpaceObject, obj, space_object_list)
        {
            P<SpaceShip> ship = obj;
            if (ship && sf::length(obj->getPosition() - view_position) < distance)
            {
                ghost_dots.push_back(GhostDot(obj->getPosition()));
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

void GuiRadarView::drawBackground(sf::RenderTarget& window)
{
    uint8_t tint = fog_style == NoFogOfWar ? 20 : 0;
    // When drawing a non-rectangular radar (ie circle),
    // we need full transparency on the outer edge.
    // We then use the stencil mask to allow the actual drawing.
    window.clear(style == Rectangular ? sf::Color{ tint, tint, tint, background_alpha } : sf::Color::Transparent);
}

void GuiRadarView::drawNoneFriendlyBlockedAreas(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        float scale = std::min(rect.width, rect.height) / 2.0f / distance;

        sf::CircleShape circle(0.f, 50);
        circle.setFillColor(sf::Color{ 20, 20, 20, background_alpha });
        foreach(SpaceObject, obj, space_object_list)
        {
            P<ShipTemplateBasedObject> stb_obj = obj;

            if (stb_obj
                && (obj->isFriendly(my_spaceship) || obj == my_spaceship))
            {
                auto r = stb_obj->getShortRangeRadarRange() * scale;
                circle.setRadius(r);
                circle.setOrigin(r, r);
                circle.setPosition(worldToScreen(obj->getPosition()));
                window.draw(circle);
            }

            P<ScanProbe> sp = obj;

            if (sp && sp->owner_id == my_spaceship->getMultiplayerId())
            {
                auto r = 5000.f * scale;
                circle.setRadius(r);
                circle.setOrigin(r, r);
                circle.setPosition(worldToScreen(obj->getPosition()));
                window.draw(circle);
            }
        }
    }
}

void GuiRadarView::drawSectorGrid(sf::RenderTarget& window)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0 / distance;

    constexpr float sector_size = 20000;
    const float sub_sector_size = sector_size / 8;

    int sector_x_min = floor((view_position.x - (radar_screen_center.x - rect.left) / scale) / sector_size) + 1;
    int sector_x_max = floor((view_position.x + (rect.left + rect.width - radar_screen_center.x) / scale) / sector_size);
    int sector_y_min = floor((view_position.y - (radar_screen_center.y - rect.top) / scale) / sector_size) + 1;
    int sector_y_max = floor((view_position.y + (rect.top + rect.height - radar_screen_center.y) / scale) / sector_size);
    sf::Color color(64, 64, 128, 128);
    for(int sector_x = sector_x_min - 1; sector_x <= sector_x_max; sector_x++)
    {
        float x = sector_x * sector_size;
        for(int sector_y = sector_y_min - 1; sector_y <= sector_y_max; sector_y++)
        {
            float y = sector_y * sector_size;
            sf::Vector2f pos = worldToScreen(sf::Vector2f(x+(30/scale),y+(30/scale)));
            drawText(window, sf::FloatRect(pos.x-10, pos.y-10, 20, 20), getSectorName(sf::Vector2f(sector_x * sector_size + sub_sector_size, sector_y * sector_size + sub_sector_size)), ACenter, 30, bold_font, color);
        }
    }
    sf::VertexArray lines_x(sf::Lines, 2 * (sector_x_max - sector_x_min + 1));
    sf::VertexArray lines_y(sf::Lines, 2 * (sector_y_max - sector_y_min + 1));
    for(int sector_x = sector_x_min; sector_x <= sector_x_max; sector_x++)
    {
        float x = sector_x * sector_size;
        lines_x[(sector_x - sector_x_min)*2].position = worldToScreen(sf::Vector2f(x, (sector_y_min-1)*sector_size));
        lines_x[(sector_x - sector_x_min)*2].color = color;
        lines_x[(sector_x - sector_x_min)*2+1].position = worldToScreen(sf::Vector2f(x, (sector_y_max+1)*sector_size));
        lines_x[(sector_x - sector_x_min)*2+1].color = color;
    }
    for(int sector_y = sector_y_min; sector_y <= sector_y_max; sector_y++)
    {
        float y = sector_y * sector_size;
        lines_y[(sector_y - sector_y_min)*2].position = worldToScreen(sf::Vector2f((sector_x_min-1)*sector_size, y));
        lines_y[(sector_y - sector_y_min)*2].color = color;
        lines_y[(sector_y - sector_y_min)*2+1].position = worldToScreen(sf::Vector2f((sector_x_max+1)*sector_size, y));
        lines_y[(sector_y - sector_y_min)*2+1].color = color;
    }
    window.draw(lines_x);
    window.draw(lines_y);

    color = sf::Color(64, 64, 128, 255);
    int sub_sector_x_min = floor((view_position.x - (radar_screen_center.x - rect.left) / scale) / sub_sector_size) + 1;
    int sub_sector_x_max = floor((view_position.x + (rect.left + rect.width - radar_screen_center.x) / scale) / sub_sector_size);
    int sub_sector_y_min = floor((view_position.y - (radar_screen_center.y - rect.top) / scale) / sub_sector_size) + 1;
    int sub_sector_y_max = floor((view_position.y + (rect.top + rect.height - radar_screen_center.y) / scale) / sub_sector_size);
    sf::VertexArray points(sf::Points, (sub_sector_x_max - sub_sector_x_min + 1) * (sub_sector_y_max - sub_sector_y_min + 1));
    for(int sector_x = sub_sector_x_min; sector_x <= sub_sector_x_max; sector_x++)
    {
        float x = sector_x * sub_sector_size;
        for(int sector_y = sub_sector_y_min; sector_y <= sub_sector_y_max; sector_y++)
        {
            float y = sector_y * sub_sector_size;
            points[(sector_x - sub_sector_x_min) + (sector_y - sub_sector_y_min) * (sub_sector_x_max - sub_sector_x_min + 1)].position = worldToScreen(sf::Vector2f(x,y));
            points[(sector_x - sub_sector_x_min) + (sector_y - sub_sector_y_min) * (sub_sector_x_max - sub_sector_x_min + 1)].color = color;
        }
    }
    window.draw(points);
}

void GuiRadarView::drawNebulaBlockedAreas(sf::RenderTarget& window)
{
    if (!my_spaceship)
        return;
    sf::Vector2f scan_center = my_spaceship->getPosition();
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;

    PVector<Nebula> nebulas = Nebula::getNebulas();
    
    sf::CircleShape circle(0.f, 32);
    circle.setFillColor(sf::Color::Black);
    sf::VertexArray a(sf::TrianglesStrip, 5);
    for(int n=0; n<5;n++)
        a[n].color = sf::Color::Black;

    foreach(Nebula, n, nebulas)
    {
        sf::Vector2f diff = n->getPosition() - scan_center;
        float diff_len = sf::length(diff);

        if (diff_len < n->getRadius() + distance)
        {
            if (diff_len < n->getRadius())
            {
                // Inside a nebula - everything is blocked out.
                sf::RectangleShape background(sf::Vector2f(rect.width, rect.height));
                background.setPosition(rect.left, rect.top);
                background.setFillColor(sf::Color::Black);
                window.draw(background);
                
                // Leave the loop here: there's no point adding more blocked areas.
                break;
            }else{
                float r = n->getRadius() * scale;
                circle.setRadius(r);
                circle.setOrigin(r, r);
                circle.setPosition(worldToScreen(n->getPosition()));
                window.draw(circle);

                float diff_angle = sf::vector2ToAngle(diff);
                float angle = acosf(n->getRadius() / diff_len) / M_PI * 180.0f;

                sf::Vector2f pos_a = n->getPosition() - sf::vector2FromAngle(diff_angle + angle) * n->getRadius();
                sf::Vector2f pos_b = n->getPosition() - sf::vector2FromAngle(diff_angle - angle) * n->getRadius();
                sf::Vector2f pos_c = scan_center + sf::normalize(pos_a - scan_center) * distance * 3.0f;
                sf::Vector2f pos_d = scan_center + sf::normalize(pos_b - scan_center) * distance * 3.0f;
                sf::Vector2f pos_e = scan_center + diff / diff_len * distance * 3.0f;

                a[0].position = worldToScreen(pos_a);
                a[1].position = worldToScreen(pos_b);
                a[2].position = worldToScreen(pos_c);
                a[3].position = worldToScreen(pos_d);
                a[4].position = worldToScreen(pos_e);
                
                window.draw(a);
            }
        }
    }

    // ship's short radar range is always visible.
    {
        float scale = std::min(rect.width, rect.height) / 2.0f / distance;

        circle.setFillColor(sf::Color{ 20, 20, 20, background_alpha });
        auto r = my_spaceship->getShortRangeRadarRange() * scale;
        circle.setRadius(r);
        circle.setOrigin(r, r);
        circle.setPosition(worldToScreen(my_spaceship->getPosition()));
        window.draw(circle);
    }
}

void GuiRadarView::drawGhostDots(sf::RenderTarget& window)
{
    sf::VertexArray ghost_points(sf::Points, ghost_dots.size());
    for(unsigned int n=0; n<ghost_dots.size(); n++)
    {
        ghost_points[n].position = worldToScreen(ghost_dots[n].position);
        ghost_points[n].color = sf::Color(255, 255, 255, 255 * std::max(((ghost_dots[n].end_of_life - engine->getElapsedTime()) / GhostDot::total_lifetime), 0.f));
    }
    window.draw(ghost_points);
}

void GuiRadarView::drawWaypoints(sf::RenderTarget& window)
{
    if (!my_spaceship)
        return;

    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);

    for(unsigned int n=0; n<my_spaceship->waypoints.size(); n++)
    {
        sf::Vector2f screen_position = worldToScreen(my_spaceship->waypoints[n]);

        sf::Sprite object_sprite;
        textureManager.setTexture(object_sprite, "waypoint");
        object_sprite.setColor(colorConfig.ship_waypoint_background);
        object_sprite.setPosition(screen_position - sf::Vector2f(0, 10));
        object_sprite.setScale(0.8, 0.8);
        window.draw(object_sprite);
        drawText(window, sf::FloatRect(screen_position.x, screen_position.y - 10, 0, 0), string(n + 1), ACenter, 18, bold_font, colorConfig.ship_waypoint_text);

        if (style != Rectangular && sf::length(screen_position - radar_screen_center) > std::min(rect.width, rect.height) * 0.5f)
        {
            screen_position = radar_screen_center + ((screen_position - radar_screen_center) / sf::length(screen_position - radar_screen_center) * std::min(rect.width, rect.height) * 0.4f);

            object_sprite.setPosition(screen_position);
            object_sprite.setRotation(sf::vector2ToAngle(screen_position - radar_screen_center) - 90);
            window.draw(object_sprite);

            drawText(window, sf::FloatRect(screen_position.x, screen_position.y, 0, 0), string(n + 1), ACenter, 18, bold_font, colorConfig.ship_waypoint_text);
        }
    }
}

void GuiRadarView::drawRangeIndicators(sf::RenderTarget& window)
{
    if (range_indicator_step_size < 1.0)
        return;

    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;

    for(float circle_size=range_indicator_step_size; circle_size < distance; circle_size+=range_indicator_step_size)
    {
        float s = circle_size * scale;
        sf::CircleShape circle(s, 50);
        circle.setOrigin(s, s);
        circle.setPosition(radar_screen_center);
        circle.setFillColor(sf::Color::Transparent);
        circle.setOutlineColor(sf::Color(255, 255, 255, 16));
        circle.setOutlineThickness(2.0);
        window.draw(circle);
        drawText(window, sf::FloatRect(radar_screen_center.x, radar_screen_center.y - s - 20, 0, 0), string(int(circle_size / 1000.0f + 0.1f)) + DISTANCE_UNIT_1K, ACenter, 20, bold_font, sf::Color(255, 255, 255, 32));
    }
}

void GuiRadarView::drawTargetProjections(sf::RenderTarget& window)
{
    const float seconds_per_distance_tick = 5.0f;
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;

    if (my_spaceship && missile_tube_controls)
    {
        for(int n=0; n<my_spaceship->weapon_tube_count; n++)
        {
            if (!my_spaceship->weapon_tube[n].isLoaded())
                continue;
            sf::Vector2f fire_position = my_spaceship->getPosition() + sf::rotateVector(my_spaceship->ship_template->model_data->getTubePosition2D(n), my_spaceship->getRotation());

            const MissileWeaponData& data = MissileWeaponData::getDataFor(my_spaceship->weapon_tube[n].getLoadType());
            float fire_angle = my_spaceship->weapon_tube[n].getDirection() + (my_spaceship->getRotation());
            float missile_target_angle = fire_angle;
            if (data.turnrate > 0.0f)
            {
                if (missile_tube_controls->getManualAim())
                {
                    missile_target_angle = missile_tube_controls->getMissileTargetAngle();
                }else{
                    float firing_solution = my_spaceship->weapon_tube[n].calculateFiringSolution(my_spaceship->getTarget());
                    if (firing_solution != std::numeric_limits<float>::infinity())
                        missile_target_angle = firing_solution;
                }
            }

            float angle_diff = sf::angleDifference(missile_target_angle, fire_angle);
            float turn_radius = ((360.0f / data.turnrate) * data.speed) / (2.0f * M_PI);
            if (data.turnrate == 0.0f)
                turn_radius = 0.0f;

            float left_or_right = 90;
            if (angle_diff > 0)
                left_or_right = -90;

            sf::Vector2f turn_center = sf::vector2FromAngle(fire_angle + left_or_right) * turn_radius;
            sf::Vector2f turn_exit = turn_center + sf::vector2FromAngle(missile_target_angle - left_or_right) * turn_radius;

            float turn_distance = fabs(angle_diff) / 360.0 * (turn_radius * 2.0f * M_PI);
            float lifetime_after_turn = data.lifetime - turn_distance / data.speed;
            float length_after_turn = data.speed * lifetime_after_turn;

            sf::VertexArray a(sf::LinesStrip, 13);
            a[0].position = fire_position;
            for(int cnt=0; cnt<10; cnt++)
                a[cnt + 1].position = fire_position + (turn_center + sf::vector2FromAngle(fire_angle - angle_diff / 10.0f * cnt - left_or_right) * turn_radius);
            a[11].position = fire_position + turn_exit;
            a[12].position = fire_position + (turn_exit + sf::vector2FromAngle(missile_target_angle) * length_after_turn);
            for(int cnt=0; cnt<13; cnt++) {
                a[cnt].position = worldToScreen(a[cnt].position);
                a[cnt].color = sf::Color(255, 255, 255, 128);
            }
            window.draw(a);

            float offset = seconds_per_distance_tick * data.speed;
            for(int cnt=0; cnt<floor(data.lifetime / seconds_per_distance_tick); cnt++)
            {
                sf::Vector2f p;
                sf::Vector2f n;
                if (offset < turn_distance)
                {
                    n = sf::vector2FromAngle(fire_angle - (angle_diff * offset / turn_distance) - left_or_right);
                    p = worldToScreen(fire_position + (turn_center + n * turn_radius));
                }else{
                    p = worldToScreen(fire_position + (turn_exit + sf::vector2FromAngle(missile_target_angle) * (offset - turn_distance)));
                    n = sf::vector2FromAngle(missile_target_angle + 90.0f);
                }
                n = sf::rotateVector(n, -view_rotation);
                n = sf::normalize(n);
                sf::VertexArray a(sf::Lines, 2);
                a[0].position = p - n * 10.0f;
                a[1].position = p + n * 10.0f;
                window.draw(a);

                offset += seconds_per_distance_tick * data.speed;
            }
        }
    }

    if (targets)
    {
        for(P<SpaceObject> obj : targets->getTargets())
        {
            if (obj->getVelocity() < 1.0f)
                continue;

            sf::VertexArray a(sf::Lines, 12);
            a[0].position = worldToScreen(obj->getPosition());
            a[0].color = sf::Color(255, 255, 255, 128);
            a[1].position = worldToScreen(obj->getPosition() + obj->getVelocity() * 60.0f);
            a[1].color = sf::Color(255, 255, 255, 0);
            sf::Vector2f n = sf::normalize(sf::rotateVector(sf::Vector2f(-obj->getVelocity().y, obj->getVelocity().x), -view_rotation));
            for(int cnt=0; cnt<5; cnt++)
            {
                sf::Vector2f p = sf::rotateVector(obj->getVelocity() * (seconds_per_distance_tick * (cnt + 1.0f) * scale), -view_rotation);
                a[2 + cnt * 2].position = a[0].position + p + n * 10.0f;
                a[3 + cnt * 2].position = a[0].position + p - n * 10.0f;
                a[2 + cnt * 2].color = a[3 + cnt * 2].color = sf::Color(255, 255, 255, 128 - cnt * 20);
            }
            window.draw(a);
        }
    }
}

void GuiRadarView::drawMissileTubes(sf::RenderTarget& window)
{
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;

    if (my_spaceship)
    {
        sf::VertexArray a(sf::Lines, my_spaceship->weapon_tube_count * 2);
        for(int n=0; n<my_spaceship->weapon_tube_count; n++)
        {
            sf::Vector2f fire_position = my_spaceship->getPosition() + sf::rotateVector(my_spaceship->ship_template->model_data->getTubePosition2D(n), my_spaceship->getRotation());
            sf::Vector2f fire_draw_position = worldToScreen(fire_position);

            float fire_angle = my_spaceship->getRotation() + my_spaceship->weapon_tube[n].getDirection() - view_rotation;

            a[n * 2].position = fire_draw_position;
            a[n * 2 + 1].position = fire_draw_position + (sf::vector2FromAngle(fire_angle) * 1000.0f) * scale;
            a[n * 2].color = sf::Color(128, 128, 128, 128);
            a[n * 2 + 1].color = sf::Color(128, 128, 128, 0);
        }
        window.draw(a);
    }
}

void GuiRadarView::drawObjects(sf::RenderTarget& window)
{
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;

    std::unordered_set<SpaceObject*> visible_objects;
    visible_objects.reserve(space_object_list.size());
    switch(fog_style)
    {
    case NoFogOfWar:
        foreach(SpaceObject, obj, space_object_list)
        {
            visible_objects.emplace(*obj);
        }
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
        foreach(SpaceObject, obj, space_object_list)
        {
            // If the object can't hide in a nebula, it's considered visible.
            if (!obj->canHideInNebula())
            {
                visible_objects.emplace(*obj);
            }

            // Consider the object only if it is:
            // - Any ShipTemplateBasedObject (ship or station)
            // - A SpaceObject belonging to a friendly faction
            // - The player's ship
            // - A scan probe owned by the player's ship
            // This check is duplicated in RelayScreen::onDraw.
            P<ShipTemplateBasedObject> stb_obj = obj;

            if (!stb_obj
                || (!obj->isFriendly(my_spaceship) && obj != my_spaceship))
            {
                P<ScanProbe> sp = obj;

                if (!sp || sp->owner_id != my_spaceship->getMultiplayerId())
                {
                    continue;
                }
            }

            // Set the radius to reveal as getShortRangeRadarRange() if the
            // object's a ShipTemplateBasedObject. Otherwise, default to 5U.
            float r = stb_obj ? stb_obj->getShortRangeRadarRange() : 5000.0f;

            // Query for objects within short-range radar/5U of this object.
            sf::Vector2f position = obj->getPosition();
            PVector<Collisionable> obj_list = CollisionManager::queryArea(position - sf::Vector2f(r, r), position + sf::Vector2f(r, r));

            // For each of those objects, check if it is at least partially
            // inside the revealed radius. If so, reveal the object on the map.
            foreach(Collisionable, c_obj, obj_list)
            {
                P<SpaceObject> obj2 = c_obj;

                if (obj2 && (obj->getPosition() - obj2->getPosition()) < r + obj2->getRadius())
                {
                    visible_objects.emplace(*obj2);
                }
            }
        }

        break;
    case NebulaFogOfWar:
        foreach(SpaceObject, obj, space_object_list)
        {
            if (obj->canHideInNebula() && my_spaceship && Nebula::blockedByNebula(my_spaceship->getPosition(), obj->getPosition()))
                continue;
            visible_objects.emplace(*obj);
        }
        break;
    }

    auto draw_object = [&window, this, scale](SpaceObject* obj)
    {
        sf::Vector2f object_position_on_screen = worldToScreen(obj->getPosition());
        float r = obj->getRadius() * scale;
        sf::FloatRect object_rect(object_position_on_screen.x - r, object_position_on_screen.y - r, r * 2, r * 2);
        if (obj != *my_spaceship && rect.intersects(object_rect))
        {
            obj->drawOnRadar(window, object_position_on_screen, scale, view_rotation, long_range);
            if (show_callsigns && obj->getCallSign() != "")
                drawText(window, sf::FloatRect(object_position_on_screen.x, object_position_on_screen.y - 15, 0, 0), obj->getCallSign(), ACenter, 15, bold_font);
        }
    };

    window.setActive(true);
    glStencilFunc(GL_EQUAL, as_mask(RadarStencil::RadarBounds), as_mask(RadarStencil::RadarBounds));
    for(SpaceObject* obj : visible_objects)
    {
            draw_object(obj);
    }

    if (my_spaceship)
    {
        sf::Vector2f object_position_on_screen = worldToScreen(my_spaceship->getPosition());
        my_spaceship->drawOnRadar(window, object_position_on_screen, scale, view_rotation, long_range);
    }
}

void GuiRadarView::drawObjectsGM(sf::RenderTarget& window)
{
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;
    foreach(SpaceObject, obj, space_object_list)
    {
        sf::Vector2f object_position_on_screen = worldToScreen(obj->getPosition());
        float r = obj->getRadius() * scale;
        sf::FloatRect object_rect(object_position_on_screen.x - r, object_position_on_screen.y - r, r * 2, r * 2);
        if (rect.intersects(object_rect))
        {
            obj->drawOnGMRadar(window, object_position_on_screen, scale, view_rotation, long_range);
        }
    }
}

void GuiRadarView::drawTargets(sf::RenderTarget& window)
{
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;

    if (!targets)
        return;
    sf::Sprite target_sprite;
    textureManager.setTexture(target_sprite, "redicule.png");

    for(P<SpaceObject> obj : targets->getTargets())
    {
        sf::Vector2f object_position_on_screen = worldToScreen(obj->getPosition());
        float r = obj->getRadius() * scale;
        sf::FloatRect object_rect(object_position_on_screen.x - r, object_position_on_screen.y - r, r * 2, r * 2);
        if (obj != my_spaceship && rect.intersects(object_rect))
        {
            target_sprite.setPosition(object_position_on_screen);
            window.draw(target_sprite);
        }
    }

    if (my_spaceship && targets->getWaypointIndex() > -1 && targets->getWaypointIndex() < my_spaceship->getWaypointCount())
    {
        sf::Vector2f object_position_on_screen = worldToScreen(my_spaceship->waypoints[targets->getWaypointIndex()]);

        target_sprite.setPosition(object_position_on_screen - sf::Vector2f(0, 10));
        window.draw(target_sprite);
    }
}

void GuiRadarView::drawHeadingIndicators(sf::RenderTarget& window)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f;

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

    sf::VertexArray tigs(sf::Lines, 360 / tig_interval * 2);
    for(unsigned int n = 0; n < 360; n += tig_interval)
    {
        tigs[n / tig_interval * 2].position = radar_screen_center + sf::vector2FromAngle(float(n) - 90 - view_rotation) * (scale - 20);
        tigs[n / tig_interval * 2 + 1].position = radar_screen_center + sf::vector2FromAngle(float(n) - 90 - view_rotation) * (scale - 40);
    }
    window.draw(tigs);

    sf::VertexArray small_tigs(sf::Lines, 360 / small_tig_interval * 2);
    for(unsigned int n = 0; n < 360; n += small_tig_interval)
    {
        small_tigs[n / small_tig_interval * 2].position = radar_screen_center + sf::vector2FromAngle(float(n) - 90 - view_rotation) * (scale - 20);
        small_tigs[n / small_tig_interval * 2 + 1].position = radar_screen_center + sf::vector2FromAngle(float(n) - 90 - view_rotation) * (scale - 30);
    }
    window.draw(small_tigs);

    for(unsigned int n = 0; n < 360; n += tig_interval)
    {
        sf::Text text(string(n), *main_font, 15);
        text.setPosition(radar_screen_center + sf::vector2FromAngle(float(n) - 90 - view_rotation) * (scale - 45));
        text.setOrigin(text.getLocalBounds().width / 2.0, text.getLocalBounds().height / 2.0);
        text.setRotation(n-view_rotation);
        window.draw(text);
    }
}

void GuiRadarView::drawRadarCutoff(sf::RenderTarget& window)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float screen_size = std::min(rect.width, rect.height) / 2.0f;

    sf::Sprite cutOff;
    textureManager.setTexture(cutOff, "radarCutoff.png");
    cutOff.setPosition(radar_screen_center);
    cutOff.setScale(screen_size / float(cutOff.getTextureRect().width) * 2, screen_size / float(cutOff.getTextureRect().width) * 2);
    window.draw(cutOff);

    sf::RectangleShape rectTop(sf::Vector2f(rect.width, radar_screen_center.y - screen_size - rect.top));
    rectTop.setFillColor(sf::Color::Black);
    rectTop.setPosition(rect.left, rect.top);
    window.draw(rectTop);
    sf::RectangleShape rectBottom(sf::Vector2f(rect.width, rect.height - screen_size - (radar_screen_center.y - rect.top)));
    rectBottom.setFillColor(sf::Color::Black);
    rectBottom.setPosition(rect.left, radar_screen_center.y + screen_size);
    window.draw(rectBottom);

    sf::RectangleShape rectLeft(sf::Vector2f(radar_screen_center.x - screen_size - rect.left, rect.height));
    rectLeft.setFillColor(sf::Color::Black);
    rectLeft.setPosition(rect.left, rect.top);
    window.draw(rectLeft);
    sf::RectangleShape rectRight(sf::Vector2f(rect.width - screen_size - (radar_screen_center.x - rect.left), rect.height));
    rectRight.setFillColor(sf::Color::Black);
    rectRight.setPosition(radar_screen_center.x + screen_size, rect.top);
    window.draw(rectRight);
}

sf::Vector2f GuiRadarView::worldToScreen(sf::Vector2f world_position)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;

    sf::Vector2f radar_position = sf::rotateVector((world_position - view_position) * scale, -view_rotation);
    return radar_position + radar_screen_center;
}

sf::Vector2f GuiRadarView::screenToWorld(sf::Vector2f screen_position)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;

    sf::Vector2f radar_position = sf::rotateVector((screen_position - radar_screen_center) / scale, view_rotation);
    return view_position + radar_position;
}

bool GuiRadarView::onMouseDown(sf::Vector2f position)
{
    if (style == Circular || style == CircularMasked)
    {
        float radius = std::min(rect.width, rect.height) / 2.0f;
        if (position - getCenterPoint() > radius)
            return false;
    }
    if (!mouse_down_func && !mouse_drag_func && !mouse_up_func)
        return false;
    if (mouse_down_func)
        mouse_down_func(screenToWorld(position));
    return true;
}

void GuiRadarView::onMouseDrag(sf::Vector2f position)
{
    if (mouse_drag_func)
        mouse_drag_func(screenToWorld(position));
}

void GuiRadarView::onMouseUp(sf::Vector2f position)
{
    if (mouse_up_func)
        mouse_up_func(screenToWorld(position));
}
