#ifndef HARDWARE_CONTROLLER_H
#define HARDWARE_CONTROLLER_H

#include "engine.h"
#include "hardwareOutputDevice.h"

class HardwareOutputDevice;
class HardwareMappingEffect;
class HardwareMappingState
{
public:
    enum EOperator
    {
        Less,
        Greater,
        Equal,
        NotEqual
    };

    string variable;
    EOperator compare_operator;
    float compare_value;
    int channel_nr;
    
    HardwareMappingEffect* effect;
};
class HardwareController : public Updatable
{
private:
    std::vector<HardwareOutputDevice*> devices;
    std::unordered_map<string, int> channel_mapping;
    std::vector<HardwareMappingState> states;
    std::vector<float> channels;
public:
    HardwareController();
    ~HardwareController();
    
    void loadConfiguration(string filename);
    
    virtual void update(float delta);
private:
    void handleConfig(string section, std::unordered_map<string, string> settings);
    float getVariableValue(string variable_name);
};

#endif//HARDWARE_CONTROLLER_H
