#include "dmx512SerialDevice.h"
#include "hardware/serialDriver.h"
#include "logging.h"

DMX512SerialDevice::DMX512SerialDevice()
: update_thread(&DMX512SerialDevice::updateLoop, this)
{
    port = nullptr;
    for(int n=0; n<1+512; n++)
        data_stream[n] = 0;
    channel_count = 512;
    resend_delay = 25;
    run_thread = false;
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
    if (settings.find("channels") != settings.end())
    {
        channel_count = std::max(1, std::min(512, settings["channels"].toInt()));
    }
    if (settings.find("resend_delay") != settings.end())
    {
        resend_delay = settings["resend_delay"].toInt();
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
    if (channel >= 0 && channel < channel_count)
        data_stream[1+channel] = int((value * 255.0) + 0.5);
}

//Return the number of output channels supported by this device.
int DMX512SerialDevice::getChannelCount()
{
    return channel_count;
}

void DMX512SerialDevice::updateLoop()
{
    //On the Open DMX USB controller, the RTS line is used to enable the RS485 transmitter.
    port->clearRTS();

    //Configure the port for straight DMX-512 protocol.
    port->configure(250000, 8, SerialPort::NoParity, SerialPort::TwoStopbits);

    while(run_thread)
    {
        //Send a break to initiate transfer, break needs to be at least 88uSec (note, not all USB serial convertors implement BREAK sending)
        port->sendBreak();

        //Send the channel data.
        port->send(data_stream, 1 + channel_count);

        //Delay a bit before sending again.
        sf::sleep(sf::milliseconds(resend_delay));
    }
}
