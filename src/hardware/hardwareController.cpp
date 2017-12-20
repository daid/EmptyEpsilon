#include "hardwareController.h"
#include "serialDriver.h"
#include "logging.h"
#include "gameGlobalInfo.h"
#include "playerInfo.h"
#include "spaceObjects/nebula.h"
#include "spaceObjects/warpJammer.h"

#include "devices/dmx512SerialDevice.h"
#include "devices/enttecDMXProDevice.h"
#include "devices/virtualOutputDevice.h"
#include "devices/sACNDMXDevice.h"
#include "devices/uDMXDevice.h"

#include "hardwareMappingEffects.h"

HardwareController::HardwareController()
{
}

HardwareController::~HardwareController()
{
    for(HardwareOutputDevice* device : devices)
        delete device;
    for(HardwareMappingState& state : states)
        delete state.effect;
    for(HardwareMappingEvent& event : events)
        delete event.effect;
}

void HardwareController::loadConfiguration(string filename)
{
    FILE* f = fopen(filename.c_str(), "r");
    if (!f)
    {
        LOG(INFO) << filename << " not found. Not controlling external hardware.";
        return;
    }

    std::unordered_map<string, string> settings;
    string section = "";
    char buffer[512];
    while(fgets(buffer, sizeof(buffer), f))
    {
        string line = string(buffer).strip();
        if(line.find("#") > -1)
            line = line.substr(0, line.find("#")).strip();
        if (line.startswith("[") && line.endswith("]"))
        {
            if (section != "")
            {
                handleConfig(section, settings);
                settings.clear();
            }
            section = line;
        }else if (line.find("=") > -1)
        {
            string key = line.substr(0, line.find("=")).strip();
            string value = line.substr(line.find("=") + 1).strip();
            settings[key] = value;
        }
    }
    if (section != "")
        handleConfig(section, settings);
    
    fclose(f);

    channels.resize(0);
    for(HardwareOutputDevice* device : devices)
    {
        channels.resize(channels.size() + device->getChannelCount(), 0.0f);
    }
    LOG(INFO) << "Hardware subsystem initialized with: " << channels.size() << " channels";
    
    if (devices.size() < 1)
    {
        LOG(INFO) << "List of available serial ports:";
        for(string port : SerialPort::getAvailablePorts())
        {
            LOG(INFO) << port << " - " << SerialPort::getPseudoDriverName(port);
        }
    }
}

void HardwareController::handleConfig(string section, std::unordered_map<string, string>& settings)
{
    if (section == "[hardware]")
    {
        HardwareOutputDevice* device = nullptr;
        
        if (settings["device"] == "")
            LOG(ERROR) << "No device definition in [hardware] section";
        else if (settings["device"] == "DMX512SerialDevice")
            device = new DMX512SerialDevice();
        else if (settings["device"] == "EnttecDMXProDevice")
            device = new EnttecDMXProDevice();
        else if (settings["device"] == "VirtualOutputDevice")
            device = new VirtualOutputDevice();
        else if (settings["device"] == "sACNDevice")
            device = new StreamingAcnDMXDevice();
        else if (settings["device"] == "uDMXDevice")
            device = new UDMXDevice();
        if (device)
        {
            if (!device->configure(settings))
            {
                LOG(ERROR) << "Failed to configure device: " << settings["device"];
                delete device;
            }else{
                LOG(INFO) << "New hardware device: " << settings["device"] << " with: " << device->getChannelCount() << " channels";
                devices.push_back(device);
            }
        }
    }else if(section == "[channel]")
    {
        if (settings["channel"] == "" || settings["name"] == "")
        {
            LOG(ERROR) << "Incorrect properties in [channel] section";
        }
        else
        {
            channel_mapping[settings["name"]].clear();
            channel_mapping[settings["name"]].push_back((settings["channel"].toInt() - 1));
            LOG(INFO) << "Channel #" << settings["channel"] << ": " << settings["name"];
        }
    }else if(section == "[channels]")
    {
        for(std::pair<string, string> item : settings)
        {
            channel_mapping[item.first].clear();
            for(string number : item.second.split(","))
            {
                channel_mapping[item.first].push_back((number.strip().toInt() - 1));
                LOG(INFO) << "Channel #" << item.second << ": " << number;
            }
        }
    }else if(section == "[state]")
    {
        if (channel_mapping.find(settings["target"]) == channel_mapping.end())
        {
            LOG(ERROR) << "Unknown target channel in hardware.ini: " << settings["target"];
        }else{
            std::vector<int> channel_numbers = channel_mapping[settings["target"]];
            for(unsigned int idx=0; idx<channel_numbers.size(); idx++)
            {
                std::unordered_map<string, string> per_channel_settings;
                for(std::pair<string, string> item : settings)
                {
                    std::vector<string> values = item.second.split(",");
                    if (values.size() > idx)
                        per_channel_settings[item.first] = values[idx].strip();
                    else
                        per_channel_settings[item.first] = values[values.size() - 1].strip();
                }
                createNewHardwareMappingState(channel_numbers[idx], per_channel_settings);
            }
        }
    }else if(section == "[event]")
    {
        if (channel_mapping.find(settings["target"]) == channel_mapping.end())
        {
            LOG(ERROR) << "Unknown target channel in hardware.ini: " << settings["target"];
        }else{
            std::vector<int> channel_numbers = channel_mapping[settings["target"]];
            for(unsigned int idx=0; idx<channel_numbers.size(); idx++)
            {
                std::unordered_map<string, string> per_channel_settings;
                for(std::pair<string, string> item : settings)
                {
                    std::vector<string> values = item.second.split(",");
                    if (values.size() > idx)
                        per_channel_settings[item.first] = values[idx];
                    else
                        per_channel_settings[item.first] = values[values.size() - 1];
                }
                createNewHardwareMappingEvent(channel_numbers[idx], per_channel_settings);
            }
        }
    }else{
        LOG(ERROR) << "Unknown section in hardware.ini: " << section;
    }
}

void HardwareController::update(float delta)
{
    if (channels.size() < 1)
        return;
    for(float& value : channels)
        value = 0.0;
    for(HardwareMappingState& state : states)
    {
        float value;
        bool active = false;
        if (getVariableValue(state.variable, value))
        {
            switch(state.compare_operator)
            {
            case HardwareMappingState::Less: active = value < state.compare_value; break;
            case HardwareMappingState::Greater: active = value > state.compare_value; break;
            case HardwareMappingState::Equal: active = value == state.compare_value; break;
            case HardwareMappingState::NotEqual: active = value != state.compare_value; break;
            }
        }
        
        if (active && state.channel_nr < int(channels.size()))
        {
            channels[state.channel_nr] = state.effect->onActive();
        }else{
            state.effect->onInactive();
        }
    }
    for(HardwareMappingEvent& event : events)
    {
        float value;
        bool trigger = false;
        if (getVariableValue(event.trigger_variable, value))
        {
            if (event.previous_valid)
            {
                switch(event.compare_operator)
                {
                case HardwareMappingEvent::Change:
                    if (fabs(event.previous_value - value) > 0.1)
                        trigger = true;
                    break;
                case HardwareMappingEvent::Increase:
                    if (value > event.previous_value + 0.1)
                        trigger = true;
                    break;
                case HardwareMappingEvent::Decrease:
                    if (value < event.previous_value - 0.1)
                        trigger = true;
                    break;
                }
            }
            event.previous_value = value;
            event.previous_valid = true;
        }else{
            event.previous_valid = false;
        }
        if (trigger)
        {
            event.triggered = true;
            event.start_time.restart();
        }
        if (event.triggered && event.channel_nr < int(channels.size()))
        {
            channels[event.channel_nr] = event.effect->onActive();
            if (event.start_time.getElapsedTime().asSeconds() > event.runtime)
                event.triggered = false;
        }else{
            event.effect->onInactive();
        }
    }

    int idx = 0;
    for(HardwareOutputDevice* device : devices)
    {
        for(int n=0; n<device->getChannelCount(); n++)
            device->setChannelData(n, channels[idx++]);
    }
}

void HardwareController::createNewHardwareMappingState(int channel_number, std::unordered_map<string, string>& settings)
{
    string condition = settings["condition"];
    
    HardwareMappingState state;
    state.variable = condition;
    state.compare_operator = HardwareMappingState::Greater;
    state.compare_value = 0.0;
    state.channel_nr = channel_number;
    
    for(HardwareMappingState::EOperator compare_operator : {HardwareMappingState::Less, HardwareMappingState::Greater, HardwareMappingState::Equal, HardwareMappingState::NotEqual})
    {
        string compare_string = "<";
        switch(compare_operator)
        {
        case HardwareMappingState::Less: compare_string = "<"; break;
        case HardwareMappingState::Greater: compare_string = ">"; break;
        case HardwareMappingState::Equal: compare_string = "=="; break;
        case HardwareMappingState::NotEqual: compare_string = "!="; break;
        }
        if (condition.find(compare_string) > -1)
        {
            state.variable = condition.substr(0, condition.find(compare_string)).strip();
            state.compare_operator = compare_operator;
            state.compare_value = condition.substr(condition.find(compare_string) + 1).strip().toFloat();
        }
    }
    
    state.effect = createEffect(settings);
    
    if (state.effect)
    {
        LOG(DEBUG) << "New hardware state: " << state.channel_nr << ":" << state.variable << " " << state.compare_operator << " " << state.compare_value;
        states.push_back(state);
    }
}

void HardwareController::createNewHardwareMappingEvent(int channel_number, std::unordered_map<string, string>& settings)
{
    string trigger = settings["trigger"];
    
    HardwareMappingEvent event;
    event.compare_operator = HardwareMappingEvent::Change;
    if (trigger.startswith("<"))
    {
        event.compare_operator = HardwareMappingEvent::Decrease;
        trigger = trigger.substr(1).strip();
    }
    if (trigger.startswith(">"))
    {
        event.compare_operator = HardwareMappingEvent::Increase;
        trigger = trigger.substr(1).strip();
    }
    event.trigger_variable = trigger;
    event.channel_nr = channel_number;
    event.runtime = settings["runtime"].toFloat();
    event.triggered = false;
    event.previous_value = 0.0;
    
    event.effect = createEffect(settings);
    if (event.effect)
    {
        LOG(DEBUG) << "New hardware event: " << event.channel_nr << ":" << event.trigger_variable << " " << event.compare_operator;
        events.push_back(event);
    }
}

HardwareMappingEffect* HardwareController::createEffect(std::unordered_map<string, string>& settings)
{
    HardwareMappingEffect* effect = nullptr;
    string effect_name = settings["effect"].lower();
    if (effect_name == "static" || effect_name == "")
        effect = new HardwareMappingEffectStatic();
    else if (effect_name == "glow")
        effect = new HardwareMappingEffectGlow();
    else if (effect_name == "blink")
        effect = new HardwareMappingEffectBlink();
    else if (effect_name == "variable")
        effect = new HardwareMappingEffectVariable(this);
    else if (effect_name == "noise")
        effect = new HardwareMappingEffectNoise();
    
    if (effect->configure(settings))
        return effect;
    delete effect;
    return nullptr;
}

#define SHIP_VARIABLE(name, formula) if (variable_name == name) { if (ship) { value = (formula); return true; } return false; }
bool HardwareController::getVariableValue(string variable_name, float& value)
{
    P<PlayerSpaceship> ship = my_spaceship;
    if (!ship && gameGlobalInfo)
        ship = gameGlobalInfo->getPlayerShip(0);
    
    if (variable_name == "Always")
    {
        value = 1.0;
        return true;
    }
    if (variable_name == "HasShip")
    {
        value = bool(ship) ? 1.0f : 0.0f;
        return true;
    }
    SHIP_VARIABLE("Hull", 100.0f * ship->hull_strength / ship->hull_max);
    SHIP_VARIABLE("FrontShield", ship->getShieldPercentage(0));
    SHIP_VARIABLE("RearShield", ship->getShieldPercentage(1));
    SHIP_VARIABLE("Shield0", ship->getShieldPercentage(0));
    SHIP_VARIABLE("Shield1", ship->getShieldPercentage(1));
    SHIP_VARIABLE("Shield2", ship->getShieldPercentage(2));
    SHIP_VARIABLE("Shield3", ship->getShieldPercentage(3));
    SHIP_VARIABLE("Shield4", ship->getShieldPercentage(4));
    SHIP_VARIABLE("Shield5", ship->getShieldPercentage(5));
    SHIP_VARIABLE("Shield6", ship->getShieldPercentage(6));
    SHIP_VARIABLE("Shield7", ship->getShieldPercentage(7));
    SHIP_VARIABLE("Energy", ship->energy_level * 100 / ship->max_energy_level);
    SHIP_VARIABLE("ShieldsUp", ship->shields_active ? 1.0f : 0.0f);
    SHIP_VARIABLE("Impulse", ship->current_impulse * ship->getSystemEffectiveness(SYS_Impulse));
    SHIP_VARIABLE("Warp", ship->current_warp * ship->getSystemEffectiveness(SYS_Warp));
    SHIP_VARIABLE("Docking", ship->docking_state == DS_Docking ? 1.0f : 0.0f);
    SHIP_VARIABLE("Docked", ship->docking_state == DS_Docked ? 1.0f : 0.0f);
    SHIP_VARIABLE("InNebula", Nebula::inNebula(ship->getPosition()) ? 1.0f : 0.0f);
    SHIP_VARIABLE("IsJammed", WarpJammer::isWarpJammed(ship->getPosition()) ? 1.0f : 0.0f);
    SHIP_VARIABLE("Jumping", ship->jump_delay > 0.0f ? 1.0f : 0.0f);
    SHIP_VARIABLE("Jumped", ship->jump_indicator > 0.0f ? 1.0f : 0.0f);
    SHIP_VARIABLE("Alert", ship->getAlertLevel() != AL_Normal ? 1.0f : 0.0f);
    SHIP_VARIABLE("YellowAlert", ship->getAlertLevel() == AL_YellowAlert ? 1.0f : 0.0f);
    SHIP_VARIABLE("RedAlert", ship->getAlertLevel() == AL_RedAlert ? 1.0f : 0.0f);
    for(int n=0; n<max_weapon_tubes; n++)
    {
        SHIP_VARIABLE("TubeLoaded" + string(n), ship->weapon_tube[n].isLoaded() ? 1.0f : 0.0f);
        SHIP_VARIABLE("TubeLoading" + string(n), ship->weapon_tube[n].isLoading() ? 1.0f : 0.0f);
        SHIP_VARIABLE("TubeUnloading" + string(n), ship->weapon_tube[n].isUnloading() ? 1.0f : 0.0f);
        SHIP_VARIABLE("TubeFiring" + string(n), ship->weapon_tube[n].isFiring() ? 1.0f : 0.0f);
    }
    
    LOG(WARNING) << "Unknown variable: " << variable_name;
    value = 0.0;
    return false;
}
