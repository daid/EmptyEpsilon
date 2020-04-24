#ifndef UDMX_DEVICE_H
#define UDMX_DEVICE_H

#include <SFML/System.hpp>
#include <stdint.h>
#include "hardware/hardwareOutputDevice.h"

class UDMXDevice : public HardwareOutputDevice
{
private:
public:
    UDMXDevice() = default;
    virtual ~UDMXDevice() = default;
    
    //Configure the device.
    virtual bool configure(std::unordered_map<string, string> settings);

    //Set a hardware channel output. Value is 0.0 to 1.0 for no to max output.
    virtual void setChannelData(int channel, float value);
    
    //Return the number of output channels supported by this device.
    virtual int getChannelCount();
};

#endif//UDMX_DEVICE_H
