#ifndef PATH_PLANNER_H
#define PATH_PLANNER_H

#include "spaceObjects/spaceObject.h"
#include <list>

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
    virtual void update(float delta) override;

    void addAvoidObject(P<SpaceObject> source, float size);

    static P<PathPlannerManager> getInstance() { if (!instance) instance = new PathPlannerManager(); return *instance; }

    friend class PathPlanner;
};

//The path planner is used to plan a route trough the world map without hitting any objects.
class PathPlanner : sp::NonCopyable
{
private:
    unsigned int insert_idx, remove_idx, remove_idx2;
    float my_size = 0.0f;
    P<PathPlannerManager> manager;
public:
    PathPlanner(float my_size);

    std::vector<glm::vec2> route;

    void plan(glm::vec2 start, glm::vec2 end);
    void clear();
private:
    void recursivePlan(glm::vec2 start, glm::vec2 end, int& recursion_counter);
    bool checkToAvoid(glm::vec2 start, glm::vec2 end, glm::vec2& new_point, glm::vec2* alt_point=NULL);
};

#endif//PATH_PLANNER_H
