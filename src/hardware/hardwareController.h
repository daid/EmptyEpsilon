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
class HardwareMappingEvent
{
public:
    enum EOperator
    {
        Change,
        Increase,
        Decrease
    };
    
    string trigger_variable;
    float runtime;
    bool triggered;
    sf::Clock start_time;

    EOperator compare_operator;
    bool previous_valid;
    float previous_value;
    int channel_nr;
    
    HardwareMappingEffect* effect;
};
class HardwareController : public Updatable
{
private:
    std::vector<HardwareOutputDevice*> devices;
    std::unordered_map<string, std::vector<int> > channel_mapping;
    std::vector<HardwareMappingState> states;
    std::vector<HardwareMappingEvent> events;
    std::vector<float> channels;
public:
    HardwareController();
    ~HardwareController();
    
    void loadConfiguration(string filename);
    
    virtual void update(float delta);
private:
    void handleConfig(string section, std::unordered_map<string, string>& settings);
    void createNewHardwareMappingState(int channel_number, std::unordered_map<string, string>& settings);
    void createNewHardwareMappingEvent(int channel_number, std::unordered_map<string, string>& settings);
    HardwareMappingEffect* createEffect(std::unordered_map<string, string>& settings);
    
    bool getVariableValue(string variable_name, float& value);
};

#endif//HARDWARE_CONTROLLER_H
