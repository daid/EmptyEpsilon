#ifndef DMX512_SERIAL_DEVICE_H
#define DMX512_SERIAL_DEVICE_H

#include "hardware/hardwareOutputDevice.h"

#include <stdint.h>
#include <thread>

//The DMX512SerialDevice can talk to Open DMX USB hardware, and just about any hardware which is just an serial port connected to a line driver.
class SerialPort;
class DMX512SerialDevice : public HardwareOutputDevice
{
private:
    SerialPort* port;
    std::thread update_thread;

    bool run_thread;
    int channel_count;
    int resend_delay;
    uint8_t data_stream[1+512];
public:
    DMX512SerialDevice();
    virtual ~DMX512SerialDevice();

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

#endif//DMX512_SERIAL_DEVICE_H
