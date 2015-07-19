#include "dmx512SerialDevice.h"
#include "serialDriver.h"
#include "logging.h"

DMX512SerialDevice::DMX512SerialDevice()
: update_thread(&DMX512SerialDevice::updateLoop, this)
{
    port = nullptr;
    for(int n=0; n<512; n++)
        channel_data[n] = 0;
}

DMX512SerialDevice::~DMX512SerialDevice()
{
    if (run_thread)
    {
        run_thread = false;
        update_thread.wait();
    }
    if (port)
        delete port;
}

bool DMX512SerialDevice::configure(std::unordered_map<string, string> settings)
{
    if (settings.find("port") != settings.end())
    {
        port = new SerialPort(settings["port"]);
        if (!port->isOpen())
        {
            LOG(ERROR) << "Failed to open port: " << settings["port"] << " for DMX512SerialDevice";
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
void DMX512SerialDevice::setChannelData(int channel, float value)
{
    if (channel >= 0 && channel < 512)
        channel_data[channel] = int((value * 255.0) + 0.5);
}

//Return the number of output channels supported by this device.
int DMX512SerialDevice::getChannelCount()
{
    return 512;
}

void DMX512SerialDevice::updateLoop()
{
    //Configure the port for straight DMX-512 protocol.
    port->configure(250000, 8, SerialPort::NoParity, SerialPort::TwoStopbits);
    
    //On the Open DMX USB controller, the RTS line is used to enable the RS485 transmitter.
    port->clearRTS();
    
    uint8_t start_code[1] = {'\0'};
    while(run_thread)
    {
        //Send a break to initiate transfer
        port->sendBreak();
        //Send the start code, which is used to simulate the MAB.
        port->send(start_code, sizeof(start_code));
        //Send the channel data.
        port->send(channel_data, sizeof(channel_data));
        
        //Delay a bit before sending again.
        sf::sleep(sf::milliseconds(100));
    }
}
