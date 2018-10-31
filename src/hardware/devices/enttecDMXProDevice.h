#ifndef ENTTEC_DMX_PRO_DEVICE_H
#define ENTTEC_DMX_PRO_DEVICE_H

#include <SFML/System.hpp>
#include <stdint.h>
#include "hardware/hardwareOutputDevice.h"

//The DMX512SerialDevice can talk to Enttec DMX Pro hardware:
// http://www.enttec.com/?main_menu=Products&pn=70304
class SerialPort;
class EnttecDMXProDevice : public HardwareOutputDevice
{
private:
    SerialPort* port;
    sf::Thread update_thread;
    
    bool run_thread;
    int channel_count;
    uint8_t channel_data[512];
public:
    EnttecDMXProDevice();
    virtual ~EnttecDMXProDevice();
    
    //Configure the device.
    // Parameter: port: name of the serial port to connect to.
    virtual bool configure(std::unordered_map<string, string> settings);

    //Set a hardware channel output. Value is 0.0 to 1.0 for no to max output.
    virtual void setChannelData(int channel, float value);
    
    //Return the number of output channels supported by this device.
    virtual int getChannelCount();

private:
    void updateLoop();
};

#endif//ENTTEC_DMX_PRO_DEVICE_H
