#ifndef PATH_PLANNER_H
#define PATH_PLANNER_H

#include "spaceObject.h"

//The path planner is used to plan a route trough the world map without hitting any objects.
class PathPlanner
{
    class PathPlannerAvoidObject
    {
    public:
        P<SpaceObject> source;
        float size;
        
        PathPlannerAvoidObject(P<SpaceObject> source, float size) : source(source), size(size) {}
    };
    static std::list<PathPlannerAvoidObject> big_objects;
    
public:
    std::vector<sf::Vector2f> route;
    
    void plan(sf::Vector2f start, sf::Vector2f end);
    
    static void addAvoidObject(P<SpaceObject> source, float size);

private:
    void recursivePlan(sf::Vector2f start, sf::Vector2f end);
    static bool checkToAvoid(sf::Vector2f start, sf::Vector2f end, sf::Vector2f& new_point);
};

#endif//PATH_PLANNER_H
