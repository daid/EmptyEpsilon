#include "rawScannerDataRadarOverlay.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"

RawScannerDataRadarOverlay::RawScannerDataRadarOverlay(GuiContainer* owner, string id, float distance)
: GuiElement(owner, id), distance(distance)
{
}

void RawScannerDataRadarOverlay::onDraw(sf::RenderTarget& window)
{
    if (!my_spaceship)
        return;

    sf::Vector2f view_position = my_spaceship->getPosition();;

    const int point_count = 512;
    float radius = std::min(rect.width, rect.height) / 2.0f;

    RawRadarSignatureInfo signatures[point_count];
    foreach(SpaceObject, obj, space_object_list)
    {
        if (obj == my_spaceship)
            continue;
        float a_0, a_1;
        float dist = sf::length(obj->getPosition() - view_position);
        float scale = 1.0;
        if (dist > distance * 2.0)
            continue;
        if (dist > distance)
            scale = (dist - distance) / distance;
        if (dist <= obj->getRadius())
        {
            a_0 = 0.0f;
            a_1 = 360.0f;
        }else{
            float a_diff = asinf(obj->getRadius() / dist) / M_PI * 180.0f;
            float a_center = sf::vector2ToAngle(obj->getPosition() - view_position);
            a_0 = a_center - a_diff;
            a_1 = a_center + a_diff;
        }
        RawRadarSignatureInfo info = obj->getRadarSignatureInfo();
        for(float a=a_0; a<=a_1; a += 360.f / float(point_count))
        {
            int idx = (int(a / 360.0f * point_count) + point_count * 2) % point_count;
            signatures[idx] += info * scale;
        }
    }

    float amp_r[point_count];
    float amp_g[point_count];
    float amp_b[point_count];

    for(int n=0; n<point_count; n++)
    {
        signatures[n].gravity = std::max(0.0f, std::min(1.0f, signatures[n].gravity));
        signatures[n].electrical = std::max(0.0f, std::min(1.0f, signatures[n].electrical));
        signatures[n].biological = std::max(0.0f, std::min(1.0f, signatures[n].biological));

        float r = random(-1, 1);
        float g = random(-1, 1);
        float b = random(-1, 1);

        r += signatures[n].biological * 30;
        g += signatures[n].biological * 30;

        r += random(-20, 20) * signatures[n].electrical;
        b += random(-20, 20) * signatures[n].electrical;
        
        r = r * (1.0f - signatures[n].gravity);
        g = g * (1.0f - signatures[n].gravity) + 40 * signatures[n].gravity;
        b = b * (1.0f - signatures[n].gravity) + 40 * signatures[n].gravity;
        
        amp_r[n] = r;
        amp_g[n] = g;
        amp_b[n] = b;
    }
    
    sf::VertexArray a_r(sf::LinesStrip, point_count+1);
    sf::VertexArray a_g(sf::LinesStrip, point_count+1);
    sf::VertexArray a_b(sf::LinesStrip, point_count+1);

    for(int n=0; n<point_count; n++)
    {
        float r = 0.0;
        float g = 0.0;
        float b = 0.0;
        for(int m = n - 2 + point_count; m <= n + 2 + point_count; m++)
        {
            r += amp_r[m % point_count];
            g += amp_g[m % point_count];
            b += amp_b[m % point_count];
        }
        r /= 5;
        g /= 5;
        b /= 5;
        
        a_r[n].position.x = rect.left + rect.width / 2.0f;
        a_r[n].position.y = rect.top + rect.height / 2.0f;
        a_r[n].position += sf::vector2FromAngle(float(n) / float(point_count) * 360.0f) * (radius * (0.95f - r / 500));
        a_r[n].color = sf::Color(255, 0, 0);

        a_g[n].position.x = rect.left + rect.width / 2.0f;
        a_g[n].position.y = rect.top + rect.height / 2.0f;
        a_g[n].position += sf::vector2FromAngle(float(n) / float(point_count) * 360.0f) * (radius * (0.92f - g / 500));
        a_g[n].color = sf::Color(0, 255, 0);

        a_b[n].position.x = rect.left + rect.width / 2.0f;
        a_b[n].position.y = rect.top + rect.height / 2.0f;
        a_b[n].position += sf::vector2FromAngle(float(n) / float(point_count) * 360.0f) * (radius * (0.89f - b / 500));
        a_b[n].color = sf::Color(0, 0, 255);
    }
    a_r[point_count] = a_r[0];
    a_g[point_count] = a_g[0];
    a_b[point_count] = a_b[0];
    window.draw(a_r, sf::BlendAdd);
    window.draw(a_g, sf::BlendAdd);
    window.draw(a_b, sf::BlendAdd);
}
