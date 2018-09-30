#include <SFML/OpenGL.hpp>

#include "main.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/nebula.h"
#include "spaceObjects/blackHole.h"
#include "spaceObjects/scanProbe.h"
#include "playerInfo.h"
#include "sectorsView.h"
#include "missileTubeControls.h"
#include "targetsContainer.h"

SectorsView::SectorsView(GuiContainer *owner, string id, float distance) : GuiElement(owner, id), distance(distance)
{
    // initialize grid colors for different zoom magnitudes
    for (int scale_magnitude = 0; scale_magnitude < SectorsView::grid_scale_size - 1; scale_magnitude++)
    {
        // warning : the computation is balanced using implicit castings, bit overflows and black magic.
        // seriously it's worse than those job interview questions
        // if you change this code even the slightest, verify that it still produces a veriaty of different colors
        sf::Uint8 colorStep = (-128 / SectorsView::grid_scale_size);
        grid_colors[scale_magnitude] = sf::Color(65 + colorStep * scale_magnitude * 0.5, 65 + colorStep * scale_magnitude * 0.3, 129 + colorStep * scale_magnitude, 128);
    }
    // last color is white
    grid_colors[SectorsView::grid_scale_size - 1] = sf::Color(255, 255, 255, 128);
}

sf::Vector2f SectorsView::worldToScreen(sf::Vector2f world_position)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;
    return radar_screen_center + (world_position - view_position) * scale;
}

sf::Vector2f SectorsView::screenToWorld(sf::Vector2f screen_position)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    float scale = std::min(rect.width, rect.height) / 2.0f / distance;
    return view_position + (screen_position - radar_screen_center) / scale;
}

int SectorsView::calcGridScaleMagnitude(int scale_magnitude, int position)
{
    for (int i = SectorsView::grid_scale_size - 1; i >= 0; i--)
    {
        if (position % (int)std::pow(sub_sectors_count, i) == 0)
        {
            return std::min(scale_magnitude + i, SectorsView::grid_scale_size - 1);
        }
    }
    return scale_magnitude;
}

void SectorsView::drawSectorGrid(sf::RenderTarget &window)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    const float scale = std::min(rect.width, rect.height) / 2.0 / distance;
    const float factor = std::floor(std::log10(GameGlobalInfo::sector_size * scale));
    const int scale_magnitude = 2 - std::min(2.f, factor);
    const float sector_size_scaled = GameGlobalInfo::sector_size * std::pow(sub_sectors_count, scale_magnitude);
    const float sub_sector_size = sector_size_scaled / sub_sectors_count;

    int sector_x_min = floor((view_position.x - (radar_screen_center.x - rect.left) / scale) / sector_size_scaled) + 1;
    int sector_x_max = floor((view_position.x + (rect.left + rect.width - radar_screen_center.x) / scale) / sector_size_scaled);
    int sector_y_min = floor((view_position.y - (radar_screen_center.y - rect.top) / scale) / sector_size_scaled) + 1;
    int sector_y_max = floor((view_position.y + (rect.top + rect.height - radar_screen_center.y) / scale) / sector_size_scaled);
    for (int sector_x = sector_x_min - 1; sector_x <= sector_x_max; sector_x++)
    {
        float x = radar_screen_center.x + ((sector_x * sector_size_scaled) - view_position.x) * scale;
        for (int sector_y = sector_y_min - 1; sector_y <= sector_y_max; sector_y++)
        {
            float y = radar_screen_center.y + ((sector_y * sector_size_scaled) - view_position.y) * scale;
            string name = getSectorName(sf::Vector2f(sector_x * sector_size_scaled + 1, sector_y * sector_size_scaled + 1));
            sf::Color color = grid_colors[std::min(calcGridScaleMagnitude(scale_magnitude, sector_x), calcGridScaleMagnitude(scale_magnitude, sector_y))];
            drawText(window, sf::FloatRect(x, y, 30, 30), name, ATopLeft, 30, bold_font, color);
        }
    }
    sf::VertexArray lines_x(sf::Lines, 2 * (sector_x_max - sector_x_min + 1));
    sf::VertexArray lines_y(sf::Lines, 2 * (sector_y_max - sector_y_min + 1));
    for (int sector_x = sector_x_min; sector_x <= sector_x_max; sector_x++)
    {
        float x = radar_screen_center.x + ((sector_x * sector_size_scaled) - view_position.x) * scale;
        sf::Color color = grid_colors[calcGridScaleMagnitude(scale_magnitude, sector_x)];
        lines_x[(sector_x - sector_x_min) * 2].position = sf::Vector2f(x, rect.top);
        lines_x[(sector_x - sector_x_min) * 2].color = color;
        lines_x[(sector_x - sector_x_min) * 2 + 1].position = sf::Vector2f(x, rect.top + rect.height);
        lines_x[(sector_x - sector_x_min) * 2 + 1].color = color;
    }
    for (int sector_y = sector_y_min; sector_y <= sector_y_max; sector_y++)
    {
        float y = radar_screen_center.y + ((sector_y * sector_size_scaled) - view_position.y) * scale;
        sf::Color color = grid_colors[calcGridScaleMagnitude(scale_magnitude, sector_y)];
        lines_y[(sector_y - sector_y_min) * 2].position = sf::Vector2f(rect.left, y);
        lines_y[(sector_y - sector_y_min) * 2].color = color;
        lines_y[(sector_y - sector_y_min) * 2 + 1].position = sf::Vector2f(rect.left + rect.width, y);
        lines_y[(sector_y - sector_y_min) * 2 + 1].color = color;
    }
    window.draw(lines_x);
    window.draw(lines_y);

    sf::Color color = sf::Color(64, 64, 128, 255);
    int sub_sector_x_min = floor((view_position.x - (radar_screen_center.x - rect.left) / scale) / sub_sector_size) + 1;
    int sub_sector_x_max = floor((view_position.x + (rect.left + rect.width - radar_screen_center.x) / scale) / sub_sector_size);
    int sub_sector_y_min = floor((view_position.y - (radar_screen_center.y - rect.top) / scale) / sub_sector_size) + 1;
    int sub_sector_y_max = floor((view_position.y + (rect.top + rect.height - radar_screen_center.y) / scale) / sub_sector_size);
    sf::VertexArray points(sf::Points, (sub_sector_x_max - sub_sector_x_min + 1) * (sub_sector_y_max - sub_sector_y_min + 1));
    for (int sector_x = sub_sector_x_min; sector_x <= sub_sector_x_max; sector_x++)
    {
        float x = radar_screen_center.x + ((sector_x * sub_sector_size) - view_position.x) * scale;
        for (int sector_y = sub_sector_y_min; sector_y <= sub_sector_y_max; sector_y++)
        {
            float y = radar_screen_center.y + ((sector_y * sub_sector_size) - view_position.y) * scale;
            points[(sector_x - sub_sector_x_min) + (sector_y - sub_sector_y_min) * (sub_sector_x_max - sub_sector_x_min + 1)].position = sf::Vector2f(x, y);
            points[(sector_x - sub_sector_x_min) + (sector_y - sub_sector_y_min) * (sub_sector_x_max - sub_sector_x_min + 1)].color = color;
        }
    }
    window.draw(points);
}
