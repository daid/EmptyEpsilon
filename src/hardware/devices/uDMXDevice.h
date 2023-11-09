#ifndef UDMX_DEVICE_H
#define UDMX_DEVICE_H

#include <stdint.h>
#include "hardware/hardwareOutputDevice.h"

class UDMXDevice : public HardwareOutputDevice
{
private:
public:
    UDMXDevice() = default;
    virtual ~UDMXDevice() = default;

    //Configure the device.
    virtual bool configure(std::unordered_map<string, string> settings) override;

    //Set a hardware channel output. Value is 0.0 to 1.0 for no to max output.
    virtual void setChannelData(int channel, float value) override;

    //Return the number of output channels supported by this device.
    virtual int getChannelCount() override;
};

#endif//UDMX_DEVICE_H
