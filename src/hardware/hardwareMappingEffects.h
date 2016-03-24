#ifndef HARDWARE_MAPPING_EFFECTS_H
#define HARDWARE_MAPPING_EFFECTS_H

#include <SFML/System.hpp>
#include <unordered_map>
#include "stringImproved.h"

class HardwareController;

class HardwareMappingEffect
{
public:
    HardwareMappingEffect() {}
    virtual ~HardwareMappingEffect() {}
    
    virtual bool configure(std::unordered_map<string, string> settings) = 0;
    
    virtual float onActive() = 0;
    virtual void onInactive() {}

protected:
    static float convertOutput(string number);
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

class HardwareMappingEffectVariable : public HardwareMappingEffect
{
private:
    HardwareController* controller;
    string variable_name;
    float min_input, max_input;
    float min_output, max_output;
public:
    HardwareMappingEffectVariable(HardwareController* controller);

    virtual bool configure(std::unordered_map<string, string> settings);
    virtual float onActive();
};

class HardwareMappingEffectNoise : public HardwareMappingEffect
{
    float smoothness;
    float min_value, max_value;

    sf::Clock clock;
    float start_value;
    float target_value;
public:
    virtual bool configure(std::unordered_map<string, string> settings);
    virtual float onActive();
    virtual void onInactive();
};

#endif//HARDWARE_MAPPING_EFFECTS_H
