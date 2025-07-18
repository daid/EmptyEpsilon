#ifndef MATH_CENTER_OF_MASS_H
#define MATH_CENTER_OF_MASS_H

#include <glm/gtx/norm.hpp>

static inline float polygonArea(const std::vector<glm::vec2>& path)
{
    int size = path.size();
    if (size < 3) return 0;

    float a = 0;
    for(int i=0, j=size-1; i<size; i++)
    {
        a += (path[j].x + path[i].x) * (path[j].y - path[i].y);
        j = i;
    }
    return a * -0.5f;
}


static inline glm::vec2 centerOfMass(const std::vector<glm::vec2>& path)
{
    float x = 0, y = 0;
    auto p0 = path[path.size()-1];
    for(unsigned int n=0; n<path.size(); n++)
    {
        auto p1 = path[n];

        auto p0x = p0.x - path[0].x;
        auto p0y = p0.y - path[0].y;
        auto p1x = p1.x - path[0].x;
        auto p1y = p1.y - path[0].y;

        float second_factor = ((p0x * p1y) - (p1x * p0y));

        x += (p0x + p1x) * second_factor;
        y += (p0y + p1y) * second_factor;
        p0 = p1;
    }

    float area = polygonArea(path);
    x = x / 6 / area + path[0].x;
    y = y / 6 / area + path[0].y;

    return glm::vec2(x, y);
}

//Check if we are inside the polygon. We do this by tracing from the point towards the negative X direction,
//  every line we cross increments the crossings counter. If we have an even number of crossings then we are not inside the polygon.
static inline bool insidePolygon(const std::vector<glm::vec2>& path, glm::vec2 point)
{
    if (path.size() < 1)
        return false;

    int crossings = 0;
    glm::ivec2 p = glm::ivec2(point);
    glm::ivec2 p0 = glm::ivec2(path[path.size()-1]);
    for(unsigned int n=0; n<path.size(); n++)
    {
        glm::ivec2 p1 = glm::ivec2(path[n]);

        if ((p0.y >= p.y && p1.y < p.y) || (p1.y > p.y && p0.y <= p.y))
        {
            int64_t x = p0.x + (p1.x - p0.x) * (p.y - p0.y) / (p1.y - p0.y);
            if (x >= p.x)
                crossings++;
        }
        p0 = p1;
    }
    return (crossings % 2) == 1;
}

// Find the distance from a point to the closest position on the edge of a polygon.
static inline float distanceToEdge(const std::vector<glm::vec2>& path, glm::vec2 point) {
    if (path.size() < 1)
        return 0.0f;

    auto p0 = path[path.size()-1];

    float min_dist2 = std::numeric_limits<float>::infinity();

    for (unsigned int n=0; n<path.size(); n++)
    {
        auto p1 = path[n];

        auto len2 = glm::length2(p1 - p0);
        if (len2 <= 0)
            continue;

        float t = std::clamp(glm::dot(point-p0, p1-p0) / len2, 0.0f, 1.0f);

        auto closest_pos = p0 + t * (p1 - p0);
        auto dist2 = glm::length2(closest_pos - point);
        if (dist2 < min_dist2)
            min_dist2 = dist2;

        p0 = p1;
    }

    return std::sqrt(min_dist2);
}

#endif//MATH_CENTER_OF_MASS_H
