#include <SFML/OpenGL.hpp>

#include "playerInfo.h"
#include "radarView.h"

GuiRadarView::GuiRadarView(GuiContainer* owner, string id, float distance)
: GuiElement(owner, id), distance(distance), long_range(false), show_callsigns(true), range_indicator_step_size(0.0f), style(Circular)
{
}

void GuiRadarView::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
        view_position = my_spaceship->getPosition();
    
    drawBackground(window);
    drawSectorGrid(window);
    drawRangeIndicators(window);
    drawObjects(window);
    switch(style)
    {
    case Rectangular:
        break;
    case Circular:
        drawRadarCutoff(window);
        break;
    case CircularMasked:
        glDisable(GL_STENCIL_TEST);
        break;
    }
}

void GuiRadarView::drawBackground(sf::RenderTarget& window)
{
    switch(style)
    {
    case Rectangular:
    case Circular:
        {
            sf::RectangleShape background(sf::Vector2f(rect.width, rect.height));
            background.setPosition(rect.left, rect.top);
            background.setFillColor(sf::Color(20, 20, 20, 255));
            window.draw(background);
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
