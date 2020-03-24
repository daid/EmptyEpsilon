#include <SFML/OpenGL.hpp>

#include "main.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/nebula.h"
#include "spaceObjects/scanProbe.h"
#include "playerInfo.h"
#include "radarView.h"
#include "missileTubeControls.h"
#include "targetsContainer.h"

GuiRadarView::GuiRadarView(GuiContainer* owner, string id, TargetsContainer* targets)
: GuiElement(owner, id), next_ghost_dot_update(0.0), targets(targets), missile_tube_controls(nullptr), distance(5000.0f), long_range(false), show_ghost_dots(false)
, show_waypoints(false), show_target_projection(false), show_missile_tubes(false), show_callsigns(false), show_heading_indicators(false), show_game_master_data(false)
, range_indicator_step_size(0.0f), style(Circular), fog_style(NoFogOfWar), mouse_down_func(nullptr), mouse_drag_func(nullptr), mouse_up_func(nullptr)
{
    auto_center_on_my_ship = true;
    auto_distance = true;
}

GuiRadarView::GuiRadarView(GuiContainer* owner, string id, float distance, TargetsContainer* targets)
: GuiElement(owner, id), next_ghost_dot_update(0.0), targets(targets), missile_tube_controls(nullptr), distance(distance), long_range(false), show_ghost_dots(false)
, show_waypoints(false), show_target_projection(false), show_missile_tubes(false), show_callsigns(false), show_heading_indicators(false), show_game_master_data(false)
, range_indicator_step_size(0.0f), style(Circular), fog_style(NoFogOfWar), mouse_down_func(nullptr), mouse_drag_func(nullptr), mouse_up_func(nullptr)
{
    auto_center_on_my_ship = true;
}

void GuiRadarView::onDraw(sf::RenderTarget& window)
{
    //We need 3 textures:
    // * background
    // * forground
    // * mask
    // Depending on what type of radar we are rendering we can use the mask to mask out the forground and/or background textures before rendering them
    // to the screen.

    //New rendering method. Render to texture first, so we do not need the stencil buffer, as this causes issues with the post processing effects.
    // Render background to screen
    // Render sectors to screen
    // Render range indicators to screen
    // Clear texture with 0% alpha
    // Render objects to texture
    // Render fog to texture with 0% alpha
    //      make fog result transparent, clearing anything that is in the fog.
    //      We can use different blendmodes to get the effect we want, as we can mask out alphas with that.
    // Render objects that are not effected by fog to texture
    // Render texture to screen

    //Hacky, when not relay and we have a ship, center on it.
    if (my_spaceship && auto_center_on_my_ship)
        view_position = my_spaceship->getPosition();
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

    //Setup our textures for rendering
    adjustRenderTexture(background_texture);
    adjustRenderTexture(forground_texture);
    adjustRenderTexture(mask_texture);

    ///Draw the mask texture, which will be black vs white for masking.
    // White areas will be visible, black areas will be masked away.
    if (fog_style == NebulaFogOfWar)
        drawNebulaBlockedAreas(mask_texture);
    if (fog_style == FriendlysShortRangeFogOfWar)
        drawNoneFriendlyBlockedAreas(mask_texture);

    ///Draw the background texture
    drawBackground(background_texture);
    if (fog_style == NebulaFogOfWar || fog_style == FriendlysShortRangeFogOfWar)    //Mask the background color with the nebula blocked areas, but show the rest.
        drawRenderTexture(mask_texture, background_texture, sf::Color::White, sf::BlendMultiply);
    drawSectorGrid(background_texture);
    drawRangeIndicators(background_texture);
    if (show_target_projection)
        drawTargetProjections(background_texture);
    if (show_missile_tubes)
        drawMissileTubes(background_texture);

    ///Start drawing of foreground
    forground_texture.clear(sf::Color::Transparent);
    //Draw things that are masked out by fog-of-war
    if (show_ghost_dots)
    {
        updateGhostDots();
        drawGhostDots(forground_texture);
    }
    drawObjects(forground_texture, background_texture);
    if (show_game_master_data)
        drawObjectsGM(forground_texture);

    //Draw the mask on the drawn objects
    if (fog_style == NebulaFogOfWar || fog_style == FriendlysShortRangeFogOfWar)
    {
        drawRenderTexture(mask_texture, forground_texture, sf::Color::White, sf::BlendMode(
            sf::BlendMode::Zero, sf::BlendMode::SrcAlpha, sf::BlendMode::Add
        ));
    }
    //Post masking
    if (show_waypoints)
        drawWaypoints(forground_texture);
    if (show_heading_indicators)
        drawHeadingIndicators(forground_texture);
    drawTargets(forground_texture);

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
            forground_texture.draw(arrow_sprite);
        }
    }

    if (style == CircularMasked || style == Circular)
    {
        //When we have a circular masked radar, use the mask_texture to clear out everything that is not part of the circle.
        mask_texture.clear(sf::Color(0, 0, 0, 0));
        float r = std::min(rect.width, rect.height) / 2.0f - 2.0f;
        sf::CircleShape circle(r, 50);
        circle.setOrigin(r, r);
        circle.setPosition(getCenterPoint());
        circle.setFillColor(sf::Color::Black);
        circle.setOutlineColor(colorConfig.radar_outline);
        circle.setOutlineThickness(2.0);
        mask_texture.draw(circle);

        sf::BlendMode blend_mode(
            sf::BlendMode::One, sf::BlendMode::SrcAlpha, sf::BlendMode::Add,
            sf::BlendMode::Zero, sf::BlendMode::SrcAlpha, sf::BlendMode::Add
        );
        drawRenderTexture(mask_texture, background_texture, sf::Color::White, blend_mode);
        drawRenderTexture(mask_texture, forground_texture, sf::Color::White, blend_mode);
    }

    //Render the final radar
    drawRenderTexture(background_texture, window);
    drawRenderTexture(forground_texture, window);
    //if (style == Circular)
    //    drawRadarCutoff(window);
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
    window.clear(sf::Color(20, 20, 20, 255));
}

void GuiRadarView::drawNoneFriendlyBlockedAreas(sf::RenderTarget& window)
{
    window.clear(sf::Color(0, 0, 0, 255));
    if (my_spaceship)
    {
        sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
        float scale = std::min(rect.width, rect.height) / 2.0f / distance;

        float r = 5000.0 * scale;
        sf::CircleShape circle(r, 50);
        circle.setOrigin(r, r);
        circle.setFillColor(sf::Color(255, 255, 255, 255));

        foreach(SpaceObject, obj, space_object_list)
        {
            if ((P<SpaceShip>(obj) || P<SpaceStation>(obj)) && obj->isFriendly(my_spaceship))
            {
                circle.setPosition(radar_screen_center + (obj->getPosition() - view_position) * scale);
                window.draw(circle);
            }
            P<ScanProbe> sp = obj;
            if (sp && sp->owner_id == my_spaceship->getMultiplayerId())
            {
                circle.setPosition(radar_screen_center + (obj->getPosition() - view_position) * scale);
                window.draw(circle);
            }
        }
    }
}

void GuiRadarView::drawSectorGrid(sf::RenderTarget& window)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);

    constexpr float sector_size = 20000;
    const float sub_sector_size = sector_size / 8;

    float scale = std::min(rect.width, rect.height) / 2.0 / distance;
    int sector_x_min = floor((view_position.x - (radar_screen_center.x - rect.left) / scale) / sector_size) + 1;
    int sector_x_max = floor((view_position.x + (rect.left + rect.width - radar_screen_center.x) / scale) / sector_size);
    int sector_y_min = floor((view_position.y - (radar_screen_center.y - rect.top) / scale) / sector_size) + 1;
    int sector_y_max = floor((view_position.y + (rect.top + rect.height - radar_screen_center.y) / scale) / sector_size);
    sf::Color color(64, 64, 128, 128);
    for(int sector_x = sector_x_min - 1; sector_x <= sector_x_max; sector_x++)
    {
        float x = radar_screen_center.x + ((sector_x * sector_size) - view_position.x) * scale;
        for(int sector_y = sector_y_min - 1; sector_y <= sector_y_max; sector_y++)
        {
            float y = radar_screen_center.y + ((sector_y * sector_size) - view_position.y) * scale;
            drawText(window, sf::FloatRect(x, y, 30, 30), getSectorName(sf::Vector2f(sector_x * sector_size + sub_sector_size, sector_y * sector_size + sub_sector_size)), ATopLeft, 30, bold_font, color);
        }
    }
    sf::VertexArray lines_x(sf::Lines, 2 * (sector_x_max - sector_x_min + 1));
    sf::VertexArray lines_y(sf::Lines, 2 * (sector_y_max - sector_y_min + 1));
    for(int sector_x = sector_x_min; sector_x <= sector_x_max; sector_x++)
    {
        float x = radar_screen_center.x + ((sector_x * sector_size) - view_position.x) * scale;
        lines_x[(sector_x - sector_x_min)*2].position = sf::Vector2f(x, rect.top);
        lines_x[(sector_x - sector_x_min)*2].color = color;
        lines_x[(sector_x - sector_x_min)*2+1].position = sf::Vector2f(x, rect.top + rect.height);
        lines_x[(sector_x - sector_x_min)*2+1].color = color;
    }
    for(int sector_y = sector_y_min; sector_y <= sector_y_max; sector_y++)
    {
        float y = radar_screen_center.y + ((sector_y * sector_size) - view_position.y) * scale;
        lines_y[(sector_y - sector_y_min)*2].position = sf::Vector2f(rect.left, y);
        lines_y[(sector_y - sector_y_min)*2].color = color;
        lines_y[(sector_y - sector_y_min)*2+1].position = sf::Vector2f(rect.left + rect.width, y);
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
        float x = radar_screen_center.x + ((sector_x * sub_sector_size) - view_position.x) * scale;
        for(int sector_y = sub_sector_y_min; sector_y <= sub_sector_y_max; sector_y++)
        {
            float y = radar_screen_center.y + ((sector_y * sub_sector_size) - view_position.y) * scale;
            points[(sector_x - sub_sector_x_min) + (sector_y - sub_sector_y_min) * (sub_sector_x_max - sub_sector_x_min + 1)].position = sf::Vector2f(x, y);
            points[(sector_x - sub_sector_x_min) + (sector_y - sub_sector_y_min) * (sub_sector_x_max - sub_sector_x_min + 1)].color = color;
        }
    }
    window.draw(points);
}

void GuiRadarView::drawNebulaBlockedAreas(sf::RenderTarget& window)
{
    sf::BlendMode blend(
        sf::BlendMode::One, sf::BlendMode::Zero, sf::BlendMode::Add,
        sf::BlendMode::One, sf::BlendMode::Zero, sf::BlendMode::Add
    );
    window.clear(sf::Color(255, 255, 255, 255));
    if (!my_spaceship)
        return;
    sf::Vector2f scan_center = my_spaceship->getPosition();
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;

    PVector<Nebula> nebulas = Nebula::getNebulas();
    foreach(Nebula, n, nebulas)
    {
        sf::Vector2f diff = n->getPosition() - scan_center;
        float diff_len = sf::length(diff);

        if (diff_len < n->getRadius() + distance)
        {
            if (diff_len < n->getRadius())
            {
                sf::RectangleShape background(sf::Vector2f(rect.width, rect.height));
                background.setPosition(rect.left, rect.top);
                background.setFillColor(sf::Color(0, 0, 0, 255));
                window.draw(background, blend);
            }else{
                float r = n->getRadius() * scale;
                sf::CircleShape circle(r, 32);
                circle.setOrigin(r, r);
                circle.setPosition(radar_screen_center + (n->getPosition() - view_position) * scale);
                circle.setFillColor(sf::Color(0, 0, 0, 255));
                window.draw(circle, blend);

                float diff_angle = sf::vector2ToAngle(diff);
                float angle = acosf(n->getRadius() / diff_len) / M_PI * 180.0f;

                sf::Vector2f pos_a = n->getPosition() - sf::vector2FromAngle(diff_angle + angle) * n->getRadius();
                sf::Vector2f pos_b = n->getPosition() - sf::vector2FromAngle(diff_angle - angle) * n->getRadius();
                sf::Vector2f pos_c = scan_center + sf::normalize(pos_a - scan_center) * distance * 3.0f;
                sf::Vector2f pos_d = scan_center + sf::normalize(pos_b - scan_center) * distance * 3.0f;
                sf::Vector2f pos_e = scan_center + diff / diff_len * distance * 3.0f;

                sf::VertexArray a(sf::TrianglesStrip, 5);
                a[0].position = radar_screen_center + (pos_a - view_position) * scale;
                a[1].position = radar_screen_center + (pos_b - view_position) * scale;
                a[2].position = radar_screen_center + (pos_c - view_position) * scale;
                a[3].position = radar_screen_center + (pos_d - view_position) * scale;
                a[4].position = radar_screen_center + (pos_e - view_position) * scale;
                for(int n=0; n<5;n++)
                    a[n].color = sf::Color(0, 0, 0, 255);
                window.draw(a, blend);
            }
        }
    }

    {
        float r = 5000.0f * scale;
        sf::CircleShape circle(r, 32);
        circle.setOrigin(r, r);
        circle.setPosition(radar_screen_center + (scan_center - view_position) * scale);
        circle.setFillColor(sf::Color(255, 255, 255,255));
        window.draw(circle, blend);
    }
}

void GuiRadarView::drawGhostDots(sf::RenderTarget& window)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;

    sf::VertexArray ghost_points(sf::Points, ghost_dots.size());
    for(unsigned int n=0; n<ghost_dots.size(); n++)
    {
        ghost_points[n].position = radar_screen_center + (ghost_dots[n].position - view_position) * scale;
        ghost_points[n].color = sf::Color(255, 255, 255, 255 * ((ghost_dots[n].end_of_life - engine->getElapsedTime()) / GhostDot::total_lifetime));
    }
    window.draw(ghost_points);
}

void GuiRadarView::drawWaypoints(sf::RenderTarget& window)
{
    if (!my_spaceship)
        return;

    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;

    for(unsigned int n=0; n<my_spaceship->waypoints.size(); n++)
    {
        sf::Vector2f screen_position = radar_screen_center + (my_spaceship->waypoints[n] - view_position) * scale;

        sf::Sprite object_sprite;
        textureManager.setTexture(object_sprite, "waypoint");
        object_sprite.setColor(colorConfig.ship_waypoint_background);
        object_sprite.setPosition(screen_position - sf::Vector2f(0, 10));
        object_sprite.setScale(0.8, 0.8);
        window.draw(object_sprite);
        drawText(window, sf::FloatRect(screen_position.x, screen_position.y - 10, 0, 0), string(n + 1), ACenter, 18, bold_font, colorConfig.ship_waypoint_text);

        if (style != Rectangular && sf::length(screen_position - radar_screen_center) > std::min(rect.width, rect.height) * 0.5f)
        {
            sf::Vector2f offset = my_spaceship->waypoints[n] - view_position;
            screen_position = radar_screen_center + (offset / sf::length(offset) * std::min(rect.width, rect.height) * 0.4f);

            object_sprite.setPosition(screen_position);
            object_sprite.setRotation(sf::vector2ToAngle(offset) - 90);
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
            sf::Vector2f fire_draw_position = radar_screen_center - (view_position - fire_position) * scale;

            const MissileWeaponData& data = MissileWeaponData::getDataFor(my_spaceship->weapon_tube[n].getLoadType());
            float fire_angle = my_spaceship->getRotation() + my_spaceship->weapon_tube[n].getDirection();
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
            a[0].position = fire_draw_position;
            for(int cnt=0; cnt<10; cnt++)
                a[cnt + 1].position = fire_draw_position + (turn_center + sf::vector2FromAngle(fire_angle - angle_diff / 10.0f * cnt - left_or_right) * turn_radius) * scale;
            a[11].position = fire_draw_position + turn_exit * scale;
            a[12].position = fire_draw_position + (turn_exit + sf::vector2FromAngle(missile_target_angle) * length_after_turn) * scale;
            for(int cnt=0; cnt<13; cnt++)
                a[cnt].color = sf::Color(255, 255, 255, 128);
            window.draw(a);

            float offset = seconds_per_distance_tick * data.speed;
            for(int cnt=0; cnt<floor(data.lifetime / seconds_per_distance_tick); cnt++)
            {
                sf::Vector2f p;
                sf::Vector2f n;
                if (offset < turn_distance)
                {
                    n = sf::vector2FromAngle(fire_angle - (angle_diff * offset / turn_distance) - left_or_right);
                    p = (turn_center + n * turn_radius) * scale;
                }else{
                    p = (turn_exit + sf::vector2FromAngle(missile_target_angle) * (offset - turn_distance)) * scale;
                    n = sf::vector2FromAngle(missile_target_angle + 90.0f);
                }
                sf::VertexArray a(sf::Lines, 2);
                a[0].position = fire_draw_position + p - n * 10.0f;
                a[1].position = fire_draw_position + p + n * 10.0f;
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
            a[0].position = radar_screen_center + (obj->getPosition() - view_position) * scale;
            a[0].color = sf::Color(255, 255, 255, 128);
            a[1].position = a[0].position + (obj->getVelocity() * 60.0f) * scale;
            a[1].color = sf::Color(255, 255, 255, 0);
            sf::Vector2f n = sf::normalize(sf::Vector2f(-obj->getVelocity().y, obj->getVelocity().x));
            for(int cnt=0; cnt<5; cnt++)
            {
                sf::Vector2f p = (obj->getVelocity() * (seconds_per_distance_tick + seconds_per_distance_tick * cnt)) * scale;
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
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;

    if (my_spaceship)
    {
        sf::VertexArray a(sf::Lines, my_spaceship->weapon_tube_count * 2);
        for(int n=0; n<my_spaceship->weapon_tube_count; n++)
        {
            sf::Vector2f fire_position = my_spaceship->getPosition() + sf::rotateVector(my_spaceship->ship_template->model_data->getTubePosition2D(n), my_spaceship->getRotation());
            sf::Vector2f fire_draw_position = radar_screen_center - (view_position - fire_position) * scale;

            float fire_angle = my_spaceship->getRotation() + my_spaceship->weapon_tube[n].getDirection();
            
            a[n * 2].position = fire_draw_position;
            a[n * 2 + 1].position = fire_draw_position + (sf::vector2FromAngle(fire_angle) * 1000.0f) * scale;
            a[n * 2].color = sf::Color(128, 128, 128, 128);
            a[n * 2 + 1].color = sf::Color(128, 128, 128, 0);
        }
        window.draw(a);
    }
}

void GuiRadarView::drawObjects(sf::RenderTarget& window_normal, sf::RenderTarget& window_alpha)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;

    std::set<SpaceObject*> visible_objects;
    switch(fog_style)
    {
    case NoFogOfWar:
        foreach(SpaceObject, obj, space_object_list)
        {
            visible_objects.insert(*obj);
        }
        break;
    case FriendlysShortRangeFogOfWar:
        if (!my_spaceship)
            return;
        foreach(SpaceObject, obj, space_object_list)
        {
            if (!obj->canHideInNebula())
                visible_objects.insert(*obj);

            if ((!P<SpaceShip>(obj) && !P<SpaceStation>(obj)) || !obj->isFriendly(my_spaceship))
            {
                P<ScanProbe> sp = obj;
                if (!sp || sp->owner_id != my_spaceship->getMultiplayerId())
                {
                    continue;
                }
            }

            sf::Vector2f position = obj->getPosition();
            PVector<Collisionable> obj_list = CollisionManager::queryArea(position - sf::Vector2f(5000, 5000), position + sf::Vector2f(5000, 5000));
            foreach(Collisionable, c_obj, obj_list)
            {
                P<SpaceObject> obj2 = c_obj;
                if (obj2 && (obj->getPosition() - obj2->getPosition()) < 5000.0f + obj2->getRadius())
                {
                    visible_objects.insert(*obj2);
                }
            }
        }
        break;
    case NebulaFogOfWar:
        foreach(SpaceObject, obj, space_object_list)
        {
            if (obj->canHideInNebula() && my_spaceship && Nebula::blockedByNebula(my_spaceship->getPosition(), obj->getPosition()))
                continue;
            visible_objects.insert(*obj);
        }
        break;
    }

    for(SpaceObject* obj : visible_objects)
    {
        sf::Vector2f object_position_on_screen = radar_screen_center + (obj->getPosition() - view_position) * scale;
        float r = obj->getRadius() * scale;
        sf::FloatRect object_rect(object_position_on_screen.x - r, object_position_on_screen.y - r, r * 2, r * 2);
        if (obj != *my_spaceship && rect.intersects(object_rect))
        {
            sf::RenderTarget* window = &window_normal;
            if (!obj->canHideInNebula())
                window = &window_alpha;
            obj->drawOnRadar(*window, object_position_on_screen, scale, long_range);
            if (show_callsigns && obj->getCallSign() != "")
                drawText(*window, sf::FloatRect(object_position_on_screen.x, object_position_on_screen.y - 15, 0, 0), obj->getCallSign(), ACenter, 15, bold_font);
        }
    }
    if (my_spaceship)
    {
        sf::Vector2f object_position_on_screen = radar_screen_center + (my_spaceship->getPosition() - view_position) * scale;
        my_spaceship->drawOnRadar(window_normal, object_position_on_screen, scale, long_range);
    }
}

void GuiRadarView::drawObjectsGM(sf::RenderTarget& window)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;

    foreach(SpaceObject, obj, space_object_list)
    {
        sf::Vector2f object_position_on_screen = radar_screen_center + (obj->getPosition() - view_position) * scale;
        float r = obj->getRadius() * scale;
        sf::FloatRect object_rect(object_position_on_screen.x - r, object_position_on_screen.y - r, r * 2, r * 2);
        if (rect.intersects(object_rect))
        {
            obj->drawOnGMRadar(window, object_position_on_screen, scale, long_range);
        }
    }
}

void GuiRadarView::drawTargets(sf::RenderTarget& window)
{
    if (!targets)
        return;

    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;

    sf::Sprite target_sprite;
    textureManager.setTexture(target_sprite, "redicule.png");

    for(P<SpaceObject> obj : targets->getTargets())
    {
        sf::Vector2f object_position_on_screen = radar_screen_center + (obj->getPosition() - view_position) * scale;
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
        sf::Vector2f object_position_on_screen = radar_screen_center + (my_spaceship->waypoints[targets->getWaypointIndex()] - view_position) * scale;

        target_sprite.setPosition(object_position_on_screen - sf::Vector2f(0, 10));
        window.draw(target_sprite);
    }
}

void GuiRadarView::drawHeadingIndicators(sf::RenderTarget& window)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f;

    sf::VertexArray tigs(sf::Lines, 360/20*2);
    for(unsigned int n=0; n<360; n+=20)
    {
        tigs[n/20*2].position = radar_screen_center + sf::vector2FromAngle(float(n) - 90) * (scale - 20);
        tigs[n/20*2+1].position = radar_screen_center + sf::vector2FromAngle(float(n) - 90) * (scale - 40);
    }
    window.draw(tigs);
    sf::VertexArray small_tigs(sf::Lines, 360/5*2);
    for(unsigned int n=0; n<360; n+=5)
    {
        small_tigs[n/5*2].position = radar_screen_center + sf::vector2FromAngle(float(n) - 90) * (scale - 20);
        small_tigs[n/5*2+1].position = radar_screen_center + sf::vector2FromAngle(float(n) - 90) * (scale - 30);
    }
    window.draw(small_tigs);
    for(unsigned int n=0; n<360; n+=20)
    {
        sf::Text text(string(n), *main_font, 15);
        text.setPosition(radar_screen_center + sf::vector2FromAngle(float(n) - 90) * (scale - 45));
        text.setOrigin(text.getLocalBounds().width / 2.0, text.getLocalBounds().height / 2.0);
        text.setRotation(n);
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
    return radar_screen_center + (world_position - view_position) * scale;
}

sf::Vector2f GuiRadarView::screenToWorld(sf::Vector2f screen_position)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;
    return view_position + (screen_position - radar_screen_center) / scale;
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
