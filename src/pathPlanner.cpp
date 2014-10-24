#include "pathPlanner.h"

std::list<PathPlanner::PathPlannerAvoidObject> PathPlanner::big_objects;

void PathPlanner::plan(sf::Vector2f start, sf::Vector2f end)
{
    route.clear();
    recursivePlan(start, end);
    route.push_back(end);
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

void PathPlanner::addAvoidObject(P<SpaceObject> source, float size)
{
    big_objects.push_back(PathPlannerAvoidObject(source, size));
}

bool PathPlanner::checkToAvoid(sf::Vector2f start, sf::Vector2f end, sf::Vector2f& new_point)
{
    sf::Vector2f startEndDiff = end - start;
    float startEndLength = sf::length(startEndDiff);
    float firstAvoidF = startEndLength;
    PathPlannerAvoidObject avoidObject(NULL, 0);
    sf::Vector2f firstAvoidQ;

    for(std::list<PathPlanner::PathPlannerAvoidObject>::iterator i = big_objects.begin(); i != big_objects.end(); )
    {
        if (i->source)
        {
            sf::Vector2f position = i->source->getPosition();
            float f = sf::dot(startEndDiff, position - start) / startEndLength;
            if (f > 0 && f < startEndLength)
            {
                sf::Vector2f q = start + (end - start) / startEndLength * f;
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
            i = big_objects.erase(i);
        }
    }
    if (firstAvoidF < startEndLength)
    {
        sf::Vector2f position = avoidObject.source->getPosition();
        new_point = position + sf::normalize(firstAvoidQ - position) * avoidObject.size * 1.1f;
        return true;
    }
    return false;
}
