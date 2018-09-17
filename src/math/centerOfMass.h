#ifndef MATH_CENTER_OF_MASS_H
#define MATH_CENTER_OF_MASS_H

template<typename T> T polygonArea(const std::vector<sf::Vector2<T>>& path)
{
    int size = path.size();
    if (size < 3) return 0;

    T a = 0;
    for(int i=0, j=size-1; i<size; i++)
    {
        a += (path[j].x + path[i].x) * (path[j].y - path[i].y);
        j = i;
    }
    return std::abs(a * 0.5);
}


template<typename T> sf::Vector2<T> centerOfMass(const std::vector<sf::Vector2<T>>& path)
{
    T x = 0, y = 0;
    sf::Vector2<T> p0 = path[path.size()-1];
    for(unsigned int n=0; n<path.size(); n++)
    {
        sf::Vector2<T> p1 = path[n];
        double second_factor = (p0.x * p1.y) - (p1.x * p0.y);

        x += double(p0.x + p1.x) * second_factor;
        y += double(p0.y + p1.y) * second_factor;
        p0 = p1;
    }

    double area = polygonArea(path);
    x = x / 6 / area;
    y = y / 6 / area;
    return sf::Vector2<T>(x, y);
}

//Check if we are inside the polygon. We do this by tracing from the point towards the negative X direction,
//  every line we cross increments the crossings counter. If we have an even number of crossings then we are not inside the polygon.
template<typename T> bool insidePolygon(const std::vector<sf::Vector2<T>>& path, sf::Vector2<T> point)
{
    if (path.size() < 1)
        return false;
    
    int crossings = 0;
    sf::Vector2i p = sf::Vector2i(point);
    sf::Vector2i p0 = sf::Vector2i(path[path.size()-1]);
    for(unsigned int n=0; n<path.size(); n++)
    {
        sf::Vector2i p1 = sf::Vector2i(path[n]);
        
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

#endif//MATH_CENTER_OF_MASS_H
