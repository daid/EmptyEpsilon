#ifndef THREAD_LEVEL_ESTIMATE_H
#define THREAD_LEVEL_ESTIMATE_H

#include "engine.h"

class SpaceShip;
class ThreatLevelEstimate : public Updatable
{
private:
    typedef std::function<void()> func_t;
    
    static constexpr float threat_drop_off_time = 20.0f;
    static constexpr float threat_high_level = 700.0f;
    static constexpr float threat_low_level = 300.0f;
    
    float smoothed_threat_level;
    bool threat_high;
    
    func_t threat_low_func;
    func_t threat_high_func;
public:
    ThreatLevelEstimate();
    
    float getThreat() { return smoothed_threat_level; }
    void setCallbacks(func_t low, func_t high) { threat_low_func = low; threat_high_func = high; }
    
    virtual void update(float delta);
private:
    float getThreatFor(P<SpaceShip> ship);
};

#endif//THREAD_LEVEL_ESTIMATE_H
