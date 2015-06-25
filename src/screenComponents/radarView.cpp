#include <SFML/OpenGL.hpp>

#include "main.h"
#include "playerInfo.h"
#include "radarView.h"

GuiRadarView::GuiRadarView(GuiContainer* owner, string id, float distance)
: GuiElement(owner, id), distance(distance), long_range(false), show_target_projection(false), show_callsigns(false), show_heading_indicators(false), show_game_master_data(false), range_indicator_step_size(0.0f), missile_target_angle(0.0f), style(Circular), mouse_down_func(nullptr), mouse_drag_func(nullptr), mouse_up_func(nullptr)
{
}

void GuiRadarView::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
        view_position = my_spaceship->getPosition();
    
    drawBackground(window);
    drawSectorGrid(window);
    drawRangeIndicators(window);
    if (show_target_projection)
        drawTargetProjections(window);
    drawObjects(window);
    if (show_game_master_data)
        drawObjectsGM(window);
    if (show_heading_indicators)
        drawHeadingIndicators(window);
    drawTargets(window);
    switch(style)
    {
    case Rectangular:
        break;
    case Circular:
        drawRadarCutoff(window);
        break;
    case CircularMasked:
        break;
    }
    glDisable(GL_STENCIL_TEST);
}

void GuiRadarView::drawBackground(sf::RenderTarget& window)
{
    switch(style)
    {
    case Rectangular:
    case Circular:
        {
            glEnable(GL_STENCIL_TEST);
            glStencilFunc(GL_ALWAYS, 1, 1);
            glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);

            sf::RectangleShape background(sf::Vector2f(rect.width, rect.height));
            background.setPosition(rect.left, rect.top);
            background.setFillColor(sf::Color(20, 20, 20, 255));
            window.draw(background);

            glStencilFunc(GL_EQUAL, 1, 1);
            glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
        }
        break;
    case CircularMasked:
        {
            sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
            float r = std::min(rect.width, rect.height) / 2.0f;
            
            glEnable(GL_STENCIL_TEST);
            glStencilFunc(GL_ALWAYS, 1, 1);
            glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);

            sf::CircleShape circle(r, 50);
            circle.setOrigin(r, r);
            circle.setPosition(radar_screen_center);
            circle.setFillColor(sf::Color(20, 20, 20, 255));
            circle.setOutlineColor(sf::Color(64, 64, 64, 255));
            circle.setOutlineThickness(2.0);
            window.draw(circle);

            glStencilFunc(GL_EQUAL, 1, 1);
            glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
        }
        break;
    }
}

void GuiRadarView::drawSectorGrid(sf::RenderTarget& window)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    
    const float sector_size = 20000;
    const float sub_sector_size = sector_size / 8;

    float scale = std::min(rect.width, rect.height) / 2.0 / distance;
    int sector_x_min = floor((view_position.x - (radar_screen_center.x - rect.left) / scale) / sector_size) + 1;
    int sector_x_max = floor((view_position.x + (rect.left + rect.width - radar_screen_center.x) / scale) / sector_size);
    int sector_y_min = floor((view_position.y - (radar_screen_center.y - rect.top) / scale) / sector_size) + 1;
    int sector_y_max = floor((view_position.y + (rect.top + rect.height - radar_screen_center.y) / scale) / sector_size);
    sf::VertexArray lines_x(sf::Lines, 2 * (sector_x_max - sector_x_min + 1));
    sf::VertexArray lines_y(sf::Lines, 2 * (sector_y_max - sector_y_min + 1));
    sf::Color color(64, 64, 128, 128);
    for(int sector_x = sector_x_min; sector_x <= sector_x_max; sector_x++)
    {
        float x = radar_screen_center.x + ((sector_x * sector_size) - view_position.x) * scale;
        lines_x[(sector_x - sector_x_min)*2].position = sf::Vector2f(x, rect.top);
        lines_x[(sector_x - sector_x_min)*2].color = color;
        lines_x[(sector_x - sector_x_min)*2+1].position = sf::Vector2f(x, rect.top + rect.height);
        lines_x[(sector_x - sector_x_min)*2+1].color = color;
        for(int sector_y = sector_y_min; sector_y <= sector_y_max; sector_y++)
        {
            float y = radar_screen_center.y + ((sector_y * sector_size) - view_position.y) * scale;
            drawText(window, sf::FloatRect(x, y, 30, 30), string(char('A' + (sector_y + 5))) + string(sector_x + 5), ATopLeft, 30, color);
        }
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
        drawText(window, sf::FloatRect(radar_screen_center.x, radar_screen_center.y - s - 20, 0, 0), string(int(circle_size / 1000.0f + 0.1f)) + "km", ACenter, 20, sf::Color(255, 255, 255, 32));
    }
}

void GuiRadarView::drawTargetProjections(sf::RenderTarget& window)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;
    
    if (my_spaceship)
    {
        sf::Vector2f spaceship_position = radar_screen_center + (view_position - my_spaceship->getPosition()) * scale;
        float angle_diff = sf::angleDifference(missile_target_angle, my_spaceship->getRotation());
        float turn_rate = 10.0f;
        float speed = 200.0f;
        float turn_radius = ((360.0f / turn_rate) * speed) / (2.0f * M_PI);

        float left_or_right = 90;
        if (angle_diff > 0)
            left_or_right = -90;

        sf::Vector2f turn_center = sf::vector2FromAngle(my_spaceship->getRotation() + left_or_right) * turn_radius;
        sf::Vector2f turn_exit = turn_center + sf::vector2FromAngle(missile_target_angle - left_or_right) * turn_radius;

        sf::VertexArray a(sf::LinesStrip, 13);
        a[0].position = spaceship_position;
        for(int cnt=0; cnt<10; cnt++)
            a[cnt + 1].position = spaceship_position + (turn_center + sf::vector2FromAngle(my_spaceship->getRotation() - angle_diff / 10.0f * cnt - left_or_right) * turn_radius) * scale;
        a[11].position = spaceship_position + turn_exit * scale;
        a[12].position = spaceship_position + (turn_exit + sf::vector2FromAngle(missile_target_angle) * distance) * scale;
        for(int cnt=0; cnt<13; cnt++)
            a[cnt].color = sf::Color(255, 255, 255, 128);
        window.draw(a);

        float offset = 10.0 * speed;
        float turn_distance = fabs(angle_diff) / 360.0 * (turn_radius * 2.0f * M_PI);
        for(int cnt=0; cnt<5; cnt++)
        {
            sf::Vector2f p;
            sf::Vector2f n;
            if (offset < turn_distance)
            {
                n = sf::vector2FromAngle(my_spaceship->getRotation() - (angle_diff * offset / turn_distance) - left_or_right);
                p = (turn_center + n * turn_radius) * scale;
            }else{
                p = (turn_exit + sf::vector2FromAngle(missile_target_angle) * (offset - turn_distance)) * scale;
                n = sf::vector2FromAngle(missile_target_angle + 90.0f);
            }
            sf::VertexArray a(sf::Lines, 2);
            a[0].position = spaceship_position + p - n * 10.0f;
            a[1].position = spaceship_position + p + n * 10.0f;
            window.draw(a);

            offset += 10.0 * speed;
        }
    }
    
    foreach(SpaceObject, obj, targets)
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
            sf::Vector2f p = (obj->getVelocity() * (10.0f + 10.0f * cnt)) * scale;
            a[2 + cnt * 2].position = a[0].position + p + n * 10.0f;
            a[3 + cnt * 2].position = a[0].position + p - n * 10.0f;
            a[2 + cnt * 2].color = a[3 + cnt * 2].color = sf::Color(255, 255, 255, 128 - cnt * 20);
        }
        window.draw(a);
    }
}

void GuiRadarView::drawObjects(sf::RenderTarget& window)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;
    
    foreach(SpaceObject, obj, space_object_list)
    {
        sf::Vector2f object_position_on_screen = radar_screen_center + (obj->getPosition() - view_position) * scale;
        float r = obj->getRadius() * scale;
        sf::FloatRect object_rect(object_position_on_screen.x - r, object_position_on_screen.y - r, r * 2, r * 2);
        if (obj != my_spaceship && rect.intersects(object_rect))
        {
            obj->drawOnRadar(window, object_position_on_screen, scale, long_range);
            if (show_callsigns && obj->getCallSign() != "")
                drawText(window, sf::FloatRect(object_position_on_screen.x, object_position_on_screen.y - 15, 0, 0), obj->getCallSign(), ACenter, 12);
        }
    }
    if (my_spaceship)
    {
        sf::Vector2f object_position_on_screen = radar_screen_center + (my_spaceship->getPosition() - view_position) * scale;
        my_spaceship->drawOnRadar(window, object_position_on_screen, scale, long_range);
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
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;
    
    foreach(SpaceObject, obj, targets)
    {
        sf::Vector2f object_position_on_screen = radar_screen_center + (obj->getPosition() - view_position) * scale;
        float r = obj->getRadius() * scale;
        sf::FloatRect object_rect(object_position_on_screen.x - r, object_position_on_screen.y - r, r * 2, r * 2);
        if (obj != my_spaceship && rect.intersects(object_rect))
        {
            sf::Sprite target_sprite;
            textureManager.setTexture(target_sprite, "redicule.png");
            target_sprite.setPosition(object_position_on_screen);
            window.draw(target_sprite);
        }
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
        sf::Text text(string(n), mainFont, 15);
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

GuiRadarView* GuiRadarView::setTarget(P<SpaceObject> obj)
{
    if (obj)
    {
        if (targets.size() > 0)
        {
            targets[0] = obj;
            if (targets.size() > 1)
                targets.resize(1);
        }else{
            targets.push_back(obj);
        }
    }
    else
    {
        clearTargets();
    }
    return this; 
}

GuiRadarView* GuiRadarView::setTargets(PVector<SpaceObject> objs)
{
    targets = objs;
    return this;
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
