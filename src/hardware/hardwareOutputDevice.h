#ifndef HARDWARE_OUTPUT_DEVICE_H
#define HARDWARE_OUTPUT_DEVICE_H

#include <unordered_map>
#include "stringImproved.h"

class HardwareOutputDevice
{
public:
    HardwareOutputDevice();
    virtual ~HardwareOutputDevice();
    
    virtual bool configure(std::unordered_map<string, string> settings) = 0;

    //Set a hardware channel output. Value is 0.0 to 1.0 for no to max output.
    virtual void setChannelData(int channel, float value) = 0;
    
    //Return the number of output channels supported by this device.
    virtual int getChannelCount() = 0;
};

#endif//HARDWARE_OUTPUT_DEVICE_H
