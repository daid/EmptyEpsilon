#ifndef PATH_PLANNER_H
#define PATH_PLANNER_H

#include "spaceObject.h"

class PathPlannerManager : public Updatable
{
    static P<PathPlannerManager> instance;
    
    class PathPlannerAvoidObject
    {
    public:
        P<SpaceObject> source;
        float size;
        
        PathPlannerAvoidObject(P<SpaceObject> source, float size) : source(source), size(size) {}
    };
    std::list<PathPlannerAvoidObject> big_objects;
    
public:
    virtual void update(float delta);

    void addAvoidObject(P<SpaceObject> source, float size);
    
    static PathPlannerManager* getInstance() { if (!instance) instance = new PathPlannerManager(); return *instance; }
    
    friend class PathPlanner;
};

//The path planner is used to plan a route trough the world map without hitting any objects.
class PathPlanner : public sf::NonCopyable
{
private:
    PathPlannerManager* manager;
public:
    PathPlanner();
    
    std::vector<sf::Vector2f> route;
    
    void plan(sf::Vector2f start, sf::Vector2f end);
    void clear();
private:
    void recursivePlan(sf::Vector2f start, sf::Vector2f end);
    bool checkToAvoid(sf::Vector2f start, sf::Vector2f end, sf::Vector2f& new_point);
};

#endif//PATH_PLANNER_H
