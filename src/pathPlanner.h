#ifndef PATH_PLANNER_H
#define PATH_PLANNER_H

#include "spaceObjects/spaceObject.h"

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
    std::unordered_map<uint32_t, std::list<PathPlannerAvoidObject> > small_objects;

public:
    virtual void update(float delta);

    void addAvoidObject(P<SpaceObject> source, float size);

    static P<PathPlannerManager> getInstance() { if (!instance) instance = new PathPlannerManager(); return *instance; }

    friend class PathPlanner;
};

//The path planner is used to plan a route trough the world map without hitting any objects.
class PathPlanner : public sf::NonCopyable
{
private:
    unsigned int insert_idx, remove_idx, remove_idx2;
    P<PathPlannerManager> manager;
public:
    PathPlanner();

    std::vector<sf::Vector2f> route;

    void plan(sf::Vector2f start, sf::Vector2f end);
    void clear();
private:
    void recursivePlan(sf::Vector2f start, sf::Vector2f end, int& recursion_counter);
    bool checkToAvoid(sf::Vector2f start, sf::Vector2f end, sf::Vector2f& new_point, sf::Vector2f* alt_point=NULL);
};

#endif//PATH_PLANNER_H
