#ifndef S_ACN_DMX_DEVICE_H
#define S_ACN_DMX_DEVICE_H

#include <SFML/System.hpp>
#include <SFML/Network.hpp>
#include <stdint.h>
#include "hardware/hardwareOutputDevice.h"

//The AcnDMXDevice talks the ACN E1.31 protocol. Which is an UDP protocol for sending DMX messages trough IP networks.
class StreamingAcnDMXDevice : public HardwareOutputDevice
{
private:
    static constexpr int acn_port = 5568;

    sf::Thread update_thread;
    sf::UdpSocket socket;
    
    bool run_thread;
    int channel_count;
    uint8_t channel_data[512];
    
    int resend_delay;
    bool multicast;
    
    int universe;
    uint8_t uuid[16];
    uint8_t source_name[64];
public:
    StreamingAcnDMXDevice();
    virtual ~StreamingAcnDMXDevice();
    
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

#endif//S_ACN_DMX_DEVICE_H
