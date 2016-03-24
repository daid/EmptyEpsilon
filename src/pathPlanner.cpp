#include "pathPlanner.h"

const double small_object_grid_size = 5000.0f;
const double small_object_max_size = 1000.0f;

static uint32_t hashSector(uint32_t x, uint32_t y)
{
    return (x) ^ (y << 16);
}

static uint32_t positionToSector(float f)
{
    return uint32_t(f / small_object_grid_size);
}

static uint32_t hashPosition(sf::Vector2f position)
{
    return hashSector(positionToSector(position.x), positionToSector(position.y));
}

P<PathPlannerManager> PathPlannerManager::instance;

void PathPlannerManager::addAvoidObject(P<SpaceObject> source, float size)
{
    // Make a classification for small objects which fit in a grid, so the checkToAvoid function does not has to iterate on all objects.
    // Until then, astroids and mines should not generate avoidAreas to prevent performance issues.
    if (size < small_object_max_size)
    {
        uint32_t hash = hashPosition(source->getPosition());
        small_objects[hash].push_back(PathPlannerAvoidObject(source, size));
    }else{
        big_objects.push_back(PathPlannerAvoidObject(source, size));
    }
}

void PathPlannerManager::update(float delta)
{
    for(std::list<PathPlannerManager::PathPlannerAvoidObject>::iterator i = big_objects.begin(); i != big_objects.end(); )
    {
        if (i->source)
        {
            i++;
        }else{
            i = big_objects.erase(i);
        }
    }
    
    for(auto h_it = small_objects.begin(); h_it != small_objects.end(); h_it++)
    {
        for(auto it = h_it->second.begin(); it != h_it->second.end();)
        {
            if (it->source && hashPosition(it->source->getPosition()) == h_it->first)
            {
                it++;
            }else{
                if (it->source)
                {
                    small_objects[hashPosition(it->source->getPosition())].push_back(PathPlannerAvoidObject(it->source, it->size));
                }

                it = big_objects.erase(it);
            }
        }
    }
}

PathPlanner::PathPlanner()
{
    manager = PathPlannerManager::getInstance();
}

void PathPlanner::plan(sf::Vector2f start, sf::Vector2f end)
{
    if (route.size() == 0 || sf::length(route.back() - end) > 2000)
    {
        route.clear();
        recursivePlan(start, end);
        route.push_back(end);
        
        insert_idx = 0;
        remove_idx = 1;
        remove_idx2 = 1;
    }else{
        route.back() = end;
        
        sf::Vector2f p0 = start;
        if (insert_idx < route.size())
        {
            if (insert_idx > 0)
                p0 = route[insert_idx - 1];
            sf::Vector2f p1 = route[insert_idx];
            
            sf::Vector2f new_point;
            if (checkToAvoid(p0, p1, new_point))
            {
                route.insert(route.begin() + insert_idx, new_point);
            }
            insert_idx++;
        }else if (remove_idx < route.size())
        {
            if (remove_idx > 1)
                p0 = route[remove_idx - 2];
            sf::Vector2f p1 = route[remove_idx];
            sf::Vector2f new_position;
            sf::Vector2f alt_position;
            if (!checkToAvoid(p0, p1, new_position, &alt_position))
            {
                route.erase(route.begin() + remove_idx - 1);
            }else{
                if ((route[remove_idx-1] - new_position) > 200.0f && (route[remove_idx-1] - alt_position) > 200.0f)
                    route[remove_idx-1] = new_position;
                remove_idx++;
            }
        }else if (remove_idx2 < route.size())
        {
            sf::Vector2f new_point;
            sf::Vector2f p1 = route[remove_idx2];
            if (!checkToAvoid(p0, p1, new_point))
            {
                route.erase(route.begin(), route.begin() + remove_idx2);
            }else{
                remove_idx2++;
            }
        }else{
            insert_idx = 0;
            remove_idx = 1;
            remove_idx2 = 1;
        }
    }
}

void PathPlanner::clear()
{
    route.clear();
}

void PathPlanner::recursivePlan(sf::Vector2f start, sf::Vector2f end)
{
    sf::Vector2f new_point;
    if (checkToAvoid(start, end, new_point))
    {
        recursivePlan(start, new_point);
        recursivePlan(new_point, end);
    }else{
        route.push_back(end);
    }
}

bool PathPlanner::checkToAvoid(sf::Vector2f start, sf::Vector2f end, sf::Vector2f& new_point, sf::Vector2f* alt_point)
{
    sf::Vector2f startEndDiff = end - start;
    float startEndLength = sf::length(startEndDiff);
    if (startEndLength < 100.0)
        return false;
    float firstAvoidF = startEndLength;
    PathPlannerManager::PathPlannerAvoidObject avoidObject(NULL, 0);
    sf::Vector2f firstAvoidQ;

    for(std::list<PathPlannerManager::PathPlannerAvoidObject>::iterator i = manager->big_objects.begin(); i != manager->big_objects.end(); )
    {
        if (i->source)
        {
            sf::Vector2f position = i->source->getPosition();
            float f = sf::dot(startEndDiff, position - start) / startEndLength;
            if (f > 0 && f < startEndLength - i->size)
            {
                sf::Vector2f q = start + startEndDiff / startEndLength * f;
                if ((q - position) < i->size)
                {
                    if (f < firstAvoidF)
                    {
                        avoidObject = *i;
                        firstAvoidF = f;
                        firstAvoidQ = q;
                    }
                }
            }
            i++;
        }else{
            i = manager->big_objects.erase(i);
        }
    }
    
    {
        // Bresenham's line algorithm to 
        int x1 = positionToSector(start.x);
        int y1 = positionToSector(start.y);
        int x2 = positionToSector(end.x);
        int y2 = positionToSector(end.y);

        const bool steep = abs(y2 - y1) > abs(x2 - x1);
        if(steep)
        {
            std::swap(x1, y1);
            std::swap(x2, y2);
        }

        if(x1 > x2)
        {
            std::swap(x1, x2);
            std::swap(y1, y2);
        }

        const int dx = x2 - x1;
        const int dy = abs(y2 - y1);

        int error = dx / 2;
        const int ystep = (y1 < y2) ? 1 : -1;
        int y = y1;

        for(int x=x1; x<=x2; x++)
        {
            uint32_t hash;
            if(steep)
            {
                hash = hashSector(y, x);
            }
            else
            {
                hash = hashSector(x, y);
            }
            
            for(std::list<PathPlannerManager::PathPlannerAvoidObject>::iterator i = manager->small_objects[hash].begin(); i != manager->small_objects[hash].end(); )
            {
                if (i->source)
                {
                    sf::Vector2f position = i->source->getPosition();
                    float f = sf::dot(startEndDiff, position - start) / startEndLength;
                    if (f > 0 && f < startEndLength - i->size)
                    {
                        sf::Vector2f q = start + startEndDiff / startEndLength * f;
                        if ((q - position) < i->size)
                        {
                            if (f < firstAvoidF)
                            {
                                avoidObject = *i;
                                firstAvoidF = f;
                                firstAvoidQ = q;
                            }
                        }
                    }
                    i++;
                }else{
                    i = manager->small_objects[hash].erase(i);
                }
            }

            error -= dy;
            if(error < 0)
            {
                y += ystep;
                error += dx;
            }
        }
    }
    
    if (firstAvoidF < startEndLength)
    {
        sf::Vector2f position = avoidObject.source->getPosition();
        new_point = position + sf::normalize(firstAvoidQ - position) * avoidObject.size * 1.1f;
        if (alt_point)
            *alt_point = position - sf::normalize(firstAvoidQ - position) * avoidObject.size * 1.1f;
        return true;
    }
    return false;
}
