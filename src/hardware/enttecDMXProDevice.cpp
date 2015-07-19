#include "enttecDMXProDevice.h"
#include "serialDriver.h"
#include "logging.h"

EnttecDMXProDevice::EnttecDMXProDevice()
: update_thread(&EnttecDMXProDevice::updateLoop, this)
{
    port = nullptr;
    for(int n=0; n<512; n++)
        channel_data[n] = 0;
}

EnttecDMXProDevice::~EnttecDMXProDevice()
{
    if (run_thread)
    {
        run_thread = false;
        update_thread.wait();
    }
    if (port)
        delete port;
}

bool EnttecDMXProDevice::configure(std::unordered_map<string, string> settings)
{
    if (settings.find("port") != settings.end())
    {
        port = new SerialPort(settings["port"]);
        if (!port->isOpen())
        {
            LOG(ERROR) << "Failed to open port: " << settings["port"] << " for EnttecDMXProDevice";
            port = nullptr;
            delete port;
        }
    }
    if (port)
    {
        run_thread = true;
        update_thread.launch();
        return true;
    }
    return false;
}

//Set a hardware channel output. Value is 0.0 to 1.0 for no to max output.
void EnttecDMXProDevice::setChannelData(int channel, float value)
{
    if (channel >= 0 && channel < 512)
        channel_data[channel] = int((value * 255.0) + 0.5);
}

//Return the number of output channels supported by this device.
int EnttecDMXProDevice::getChannelCount()
{
    return 512;
}

void EnttecDMXProDevice::updateLoop()
{
    //Configuration does not real matter as it's just a virtual device.
    port->configure(115200, 8, SerialPort::NoParity, SerialPort::OneStopBit);    
    
    int size = 513;
    uint8_t start_code[5] = {0x7E, 0x06, uint8_t(size & 0xFF), uint8_t(size >> 8), 0x00};
    uint8_t end_code[1] = {0xE7};
    while(run_thread)
    {
        port->send(start_code, sizeof(start_code));
        port->send(channel_data, sizeof(channel_data));
        port->send(end_code, sizeof(end_code));
        
        //Delay a bit before sending again.
        sf::sleep(sf::milliseconds(100));
    }
}
