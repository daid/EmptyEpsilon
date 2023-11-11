#ifndef HARDWARE_MAPPING_EFFECTS_H
#define HARDWARE_MAPPING_EFFECTS_H

#include <unordered_map>
#include "stringImproved.h"
#include "timer.h"

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
    virtual bool configure(std::unordered_map<string, string> settings) override;
    virtual float onActive() override;
};

class HardwareMappingEffectGlow : public HardwareMappingEffect
{
private:
    float min_value, max_value;
    float time;
    sp::Timer timer;
    bool back;
public:
    virtual bool configure(std::unordered_map<string, string> settings) override;
    virtual float onActive() override;
    virtual void onInactive() override;
};

class HardwareMappingEffectBlink : public HardwareMappingEffect
{
private:
    float on_value, off_value;
    float on_time, off_time;
    sp::Timer timer;
    bool on;
public:
    virtual bool configure(std::unordered_map<string, string> settings) override;
    virtual float onActive() override;
    virtual void onInactive() override;
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

    virtual bool configure(std::unordered_map<string, string> settings) override;
    virtual float onActive() override;
};

class HardwareMappingEffectNoise : public HardwareMappingEffect
{
    float smoothness;
    float min_value, max_value;

    sp::Timer timer;
    float start_value;
    float target_value;
public:
    virtual bool configure(std::unordered_map<string, string> settings) override;
    virtual float onActive() override;
    virtual void onInactive() override;
};

#endif//HARDWARE_MAPPING_EFFECTS_H
