#include <string.h>

#include "sACNDMXDevice.h"
#include "random.h"
#include "logging.h"

StreamingAcnDMXDevice::StreamingAcnDMXDevice()
{
    for(int n=0; n<512; n++)
        channel_data[n] = 0;
    channel_count = 512;

    multicast = false;
    resend_delay = 50;

    universe = 1;
    for(int n=0; n<16; n++)
        uuid[n] = uint8_t(irandom(0, 255));
    memset(source_name, 0, sizeof(source_name));
    strcpy((char*)source_name, "EmptyEpsilon");
    run_thread = false;
    socket.bind(acn_port - 1);
}

StreamingAcnDMXDevice::~StreamingAcnDMXDevice()
{
    if (run_thread)
    {
        run_thread = false;
        update_thread.join();
    }
}

bool StreamingAcnDMXDevice::configure(std::unordered_map<string, string> settings)
{
    if (settings.find("channels") != settings.end())
    {
        channel_count = std::max(1, std::min(512, settings["channels"].toInt()));
    }
    if (settings.find("universe") != settings.end())
    {
        universe = std::max(1, std::min(63999, settings["universe"].toInt()));
    }
    if (settings.find("resend_delay") != settings.end())
    {
        resend_delay = std::max(1, settings["resend_delay"].toInt());
    }
    if (settings.find("multicast") != settings.end())
    {
        multicast = settings["multicast"].toInt() != 0;
    }

    run_thread = true;
    update_thread = std::thread(&StreamingAcnDMXDevice::updateLoop, this);
    return true;
}

//Set a hardware channel output. Value is 0.0 to 1.0 for no to max output.
void StreamingAcnDMXDevice::setChannelData(int channel, float value)
{
    if (channel >= 0 && channel < channel_count)
        channel_data[channel] = int((value * 255.0f) + 0.5f);
}

//Return the number of output channels supported by this device.
int StreamingAcnDMXDevice::getChannelCount()
{
    return channel_count;
}

void StreamingAcnDMXDevice::updateLoop()
{
    uint8_t sequence_number = 0;
    while(run_thread)
    {
        std::vector<uint8_t> buffer;
        auto addU8 = [&buffer](uint8_t d) { buffer.resize(buffer.size() + 1); buffer[buffer.size()-1] = d; };
        auto addU16 = [&buffer](uint16_t d) { buffer.resize(buffer.size() + 2); buffer[buffer.size()-2] = d >> 8; buffer[buffer.size()-1] = d; };
        auto addU32 = [&buffer](uint16_t d) { buffer.resize(buffer.size() + 4); buffer[buffer.size()-4] = d >> 24; buffer[buffer.size()-3] = d >> 16; buffer[buffer.size()-2] = d >> 8; buffer[buffer.size()-1] = d; };

        //Root layer
        addU16(0x0010); //RLP Size
        addU16(0x0000); //RLP Preamble size
        addU8('A'); addU8('S'); addU8('C'); addU8('-'); addU8('E'); addU8('1'); addU8('.'); addU8('1'); addU8('7'); addU8('\0'); addU8('\0'); addU8('\0'); //ACN Packet identifier
        addU16(0x7000 | (110 + channel_count)); //Flags and length
        addU32(0x0004); //Vector, identifies as PDU protocol
        for(int n=0; n<16; n++)
            addU8(uuid[n]);//Sender Unique ID, needs to be an UUID by spec. But most likely ignored by equipment.
        //Framing layer
        addU16(0x7000 | (88 + channel_count)); //Flags and length
        addU32(0x0002); //Vector, identifies as DMP protocol PDU
        for(int n=0; n<64; n++)
            addU8(source_name[n]);//Source name, needs to be an UTF-8 zero terminated string. Only for ID goals.
        addU8(100); //Priority
        addU16(0);  //Reserved
        addU8(sequence_number);  //sequence number
        addU8(0);  //option flags
        addU16(universe);  //Universe number
        //DMP layer
        addU16(0x7000 | (11 + channel_count)); //Flags and length
        addU8(2);  //Vector, message is PDU
        addU8(0xa1);  //Format of address and data
        addU16(0x0000);  //First property address
        addU16(0x0001);  //Address increments
        addU16(1 + channel_count);  //Value count
        addU8(0x00); //DMX512 start byte.
        for(int n=0; n<channel_count; n++)
            addU8(channel_data[n]);

        sequence_number++;

        if (multicast)
            socket.sendMulticast(buffer.data(), buffer.size(), universe, acn_port);
        else
            socket.sendBroadcast(buffer.data(), buffer.size(), acn_port);

        std::this_thread::sleep_for(std::chrono::milliseconds(resend_delay));
    }
}
