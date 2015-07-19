#ifndef HARDWARE_MAPPING_EFFECTS_H
#define HARDWARE_MAPPING_EFFECTS_H

#include <SFML/System.hpp>
#include <unordered_map>
#include "stringImproved.h"

class HardwareMappingEffect
{
public:
    HardwareMappingEffect() {}
    virtual ~HardwareMappingEffect() {}
    
    virtual bool configure(std::unordered_map<string, string> settings) = 0;
    
    virtual float onActive() = 0;
    virtual void onInactive() {}
};

class HardwareMappingEffectStatic : public HardwareMappingEffect
{
private:
    float value;
public:
    virtual bool configure(std::unordered_map<string, string> settings);
    virtual float onActive();
};

class HardwareMappingEffectGlow : public HardwareMappingEffect
{
private:
    float min_value, max_value;
    float time;
    sf::Clock clock;
public:
    virtual bool configure(std::unordered_map<string, string> settings);
    virtual float onActive();
    virtual void onInactive();
};

class HardwareMappingEffectBlink : public HardwareMappingEffect
{
private:
    float on_value, off_value;
    float on_time, off_time;
    sf::Clock clock;
public:
    virtual bool configure(std::unordered_map<string, string> settings);
    virtual float onActive();
    virtual void onInactive();
};

#endif//HARDWARE_MAPPING_EFFECTS_H
