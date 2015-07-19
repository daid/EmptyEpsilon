#include "hardwareController.h"
#include "serialDriver.h"
#include "logging.h"
#include "gameGlobalInfo.h"
#include "playerInfo.h"
#include "spaceObjects/nebula.h"
#include "spaceObjects/warpJammer.h"

#include "dmx512SerialDevice.h"
#include "enttecDMXProDevice.h"
#include "virtualOutputDevice.h"
#include "hardwareMappingEffects.h"

HardwareController::HardwareController()
{
}

HardwareController::~HardwareController()
{
    for(HardwareOutputDevice* device : devices)
        delete device;
    for(HardwareMappingEvent& event : events)
        delete event.effect;
}

void HardwareController::loadConfiguration(string filename)
{
    FILE* f = fopen(filename.c_str(), "r");
    if (!f)
    {
        LOG(INFO) << "No hardware.ini file. Not controlling external hardware.";
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
    
    if (devices.size() < 1)
    {
        LOG(INFO) << "List of available serial ports:";
        for(string port : SerialPort::getAvailablePorts())
        {
            LOG(INFO) << port << " - " << SerialPort::getPseudoDriverName(port);
        }
    }
}

void HardwareController::handleConfig(string section, std::unordered_map<string, string> settings)
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
        if (device)
        {
            if (!device->configure(settings))
            {
                LOG(ERROR) << "Failed to configure device: " << settings["device"];
                delete device;
            }else{
                devices.push_back(device);
            }
        }
    }else if(section == "[channel]")
    {
        if (settings["channel"] == "" || settings["name"] == "")
            LOG(ERROR) << "Incorrect properties in [channel] section";
        else
            channel_mapping[settings["name"]] = settings["channel"].toInt();
    }else if(section == "[event]")
    {
        string condition = settings["condition"];
        string effect = settings["effect"].lower();
        if (effect == "")
            effect = "static";
        
        HardwareMappingEvent event;
        event.variable = condition;
        event.compare_operator = HardwareMappingEvent::Greater;
        event.compare_value = 0.0;
        event.effect = nullptr;
        event.channel_nr = -1;
        if (channel_mapping.find(settings["target"]) != channel_mapping.end())
            event.channel_nr = channel_mapping[settings["target"]];
        
        for(HardwareMappingEvent::EOperator compare_operator : {HardwareMappingEvent::Less, HardwareMappingEvent::Greater, HardwareMappingEvent::Equal, HardwareMappingEvent::NotEqual})
        {
            string compare_string = "<";
            switch(compare_operator)
            {
            case HardwareMappingEvent::Less: compare_string = "<"; break;
            case HardwareMappingEvent::Greater: compare_string = ">"; break;
            case HardwareMappingEvent::Equal: compare_string = "=="; break;
            case HardwareMappingEvent::NotEqual: compare_string = "!="; break;
            }
            if (condition.find(compare_string) > -1)
            {
                event.variable = condition.substr(0, condition.find(compare_string)).strip();
                event.compare_operator = compare_operator;
                event.compare_value = condition.substr(condition.find(compare_string) + 1).strip().toFloat();
            }
        }
        
        if (event.channel_nr < 0)
        {
        }else{
            if (effect == "static")
                event.effect = new HardwareMappingEffectStatic();
            else if (effect == "glow")
                event.effect = new HardwareMappingEffectGlow();
            else if (effect == "blink")
                event.effect = new HardwareMappingEffectBlink();
            
            if (event.effect)
            {
                if (event.effect->configure(settings))
                {
                    LOG(DEBUG) << "New hardware event: " << event.channel_nr << ":" << event.variable << " " << event.compare_operator << " " << event.compare_value;
                    events.push_back(event);
                }else{
                    delete event.effect;
                }
            }
        }
    }else{
        LOG(ERROR) << "Unknown section in hardware.ini: " << section;
    }
}

void HardwareController::update(float delta)
{
    for(HardwareMappingEvent& event : events)
    {
        float variable = getVariableValue(event.variable);
        bool active = false;
        switch(event.compare_operator)
        {
        case HardwareMappingEvent::Less: active = variable < event.compare_value; break;
        case HardwareMappingEvent::Greater: active = variable > event.compare_value; break;
        case HardwareMappingEvent::Equal: active = variable == event.compare_value; break;
        case HardwareMappingEvent::NotEqual: active = variable != event.compare_value; break;
        }
        
        if (active)
        {
            float value = event.effect->onActive();
            for(HardwareOutputDevice* device : devices)
            {
                device->setChannelData(event.channel_nr, value);
            }
        }else{
            event.effect->onInactive();
        }
    }
}

#define SHIP_VARIABLE(name, formula) if (variable_name == name) { if (ship) { return formula; } return 0.0f; }
float HardwareController::getVariableValue(string variable_name)
{
    P<PlayerSpaceship> ship = my_spaceship;
    if (!ship && gameGlobalInfo)
        ship = gameGlobalInfo->getPlayerShip(0);
    
    if (variable_name == "Always")
        return 1.0;
    SHIP_VARIABLE("Hull", 100.0f * ship->hull_strength / ship->hull_max);
    SHIP_VARIABLE("FrontShield", 100.0f * ship->front_shield / ship->front_shield_max);
    SHIP_VARIABLE("RearShield", 100.0f * ship->rear_shield / ship->rear_shield_max);
    SHIP_VARIABLE("Energy", ship->energy_level);
    SHIP_VARIABLE("ShieldsUp", ship->shields_active ? 1.0f : 0.0f);
    SHIP_VARIABLE("Impulse", ship->current_impulse);
    SHIP_VARIABLE("Warp", ship->current_warp);
    SHIP_VARIABLE("Docking", ship->docking_state != DS_NotDocking ? 1.0f : 0.0f);
    SHIP_VARIABLE("Docked", ship->docking_state == DS_Docked ? 1.0f : 0.0f);
    SHIP_VARIABLE("InNebula", Nebula::inNebula(ship->getPosition()) ? 1.0f : 0.0f);
    SHIP_VARIABLE("IsJammed", WarpJammer::isWarpJammed(ship->getPosition()) ? 1.0f : 0.0f);
    SHIP_VARIABLE("Jumping", ship->jump_delay > 0.0f ? 1.0f : 0.0f);
    SHIP_VARIABLE("Jumped", ship->jump_indicator > 0.0f ? 1.0f : 0.0f);
    for(int n=0; n<max_weapon_tubes; n++)
    {
        SHIP_VARIABLE("TubeLoaded" + string(n), ship->weaponTube[n].state == WTS_Loaded ? 1.0f : 0.0f);
        SHIP_VARIABLE("TubeLoading" + string(n), ship->weaponTube[n].state == WTS_Loading ? 1.0f : 0.0f);
        SHIP_VARIABLE("TubeUnloading" + string(n), ship->weaponTube[n].state == WTS_Unloading ? 1.0f : 0.0f);
    }
    
    LOG(WARNING) << "Unknown effect variable: " << variable_name;
    return 0.0;
}
