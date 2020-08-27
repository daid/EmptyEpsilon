#ifndef PHILIPS_HUE_DEVICE_H
#define PHILIPS_HUE_DEVICE_H

#include <SFML/System.hpp>
#include <SFML/Network.hpp>
#include <stdint.h>
#include "hardware/hardwareOutputDevice.h"

//The PhilipsHueDevice talks to a philips hue bridge.
//Documentation of the philips hue API is at:
//  https://www.developers.meethue.com/documentation/getting-started
//The PhilipsHueDevice device creates 4 channels for each connected light.
//So the amount of available channels is amount of lights x4.
//The channels are:
// Brightness
// Saturation
// Hue
// Transition Time
class PhilipsHueDevice : public HardwareOutputDevice
{
public:
    PhilipsHueDevice();
    virtual ~PhilipsHueDevice();

    //Configure the device.
    // Parameter: "ip": IP address of the bridge.
    // Parameter: "username": API username to use. If not set, will request a username from the bridge.
    // Parameter: "userfile": Filename to store the username API in, if not set with the user parameter and username is requested from the bridge.
    virtual bool configure(std::unordered_map<string, string> settings);

    //Set a hardware channel output. Value is 0.0 to 1.0 for no to max output.
    virtual void setChannelData(int channel, float value);

    //Return the number of output channels supported by this device.
    virtual int getChannelCount();

private:
    class LightInfo
    {
    public:
        LightInfo() : dirty(true), brightness(0), saturation(0), hue(0), transitiontime(0), laststate(0) {}

        bool dirty;
        int brightness;
        int saturation;
        int hue;
        int transitiontime;
        string laststate;
    };

    sf::Thread update_thread;
    sf::Mutex mutex;
    std::vector<LightInfo> lights;

    bool run_thread;

    void updateLoop();

    string ip_address;
    int port = 80;
    string username;
    string userfile;
    int light_count;
};

#endif//S_ACN_DMX_DEVICE_H
