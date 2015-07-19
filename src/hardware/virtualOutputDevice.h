#ifndef VIRTUAL_OUTPUT_DEVICE_H
#define VIRTUAL_OUTPUT_DEVICE_H

#include <SFML/System.hpp>
#include <stdint.h>
#include "hardwareOutputDevice.h"

//The virtual output device is a debugging output device.
class VirtualOutputRenderer;
class VirtualOutputDevice : public HardwareOutputDevice
{
private:
    VirtualOutputRenderer* renderer;
public:
    float channel_data[512];
    
    VirtualOutputDevice();
    virtual ~VirtualOutputDevice();
    
    //Configure the device.
    virtual bool configure(std::unordered_map<string, string> settings);

    //Set a hardware channel output. Value is 0.0 to 1.0 for no to max output.
    virtual void setChannelData(int channel, float value);
    
    //Return the number of output channels supported by this device.
    virtual int getChannelCount();
};


#endif//DMX512_SERIAL_DEVICE_H
