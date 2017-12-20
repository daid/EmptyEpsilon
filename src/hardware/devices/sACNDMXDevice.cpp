#include <string.h>

#include "fixedSocket.h"
#include "sACNDMXDevice.h"
#include "random.h"
#include "logging.h"

StreamingAcnDMXDevice::StreamingAcnDMXDevice()
: update_thread(&StreamingAcnDMXDevice::updateLoop, this)
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
}

StreamingAcnDMXDevice::~StreamingAcnDMXDevice()
{
    if (run_thread)
    {
        run_thread = false;
        update_thread.wait();
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
    update_thread.launch();
    return true;
}

//Set a hardware channel output. Value is 0.0 to 1.0 for no to max output.
void StreamingAcnDMXDevice::setChannelData(int channel, float value)
{
    if (channel >= 0 && channel < channel_count)
        channel_data[channel] = int((value * 255.0) + 0.5);
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
        sf::Packet packet;
        //Root layer
        packet << uint16_t(0x0010); //RLP Size
        packet << uint16_t(0x0000); //RLP Preamble size
        packet << uint8_t('A') << uint8_t('S') << uint8_t('C') << uint8_t('-') << uint8_t('E') << uint8_t('1') << uint8_t('.') << uint8_t('1') << uint8_t('7') << uint8_t('\0') << uint8_t('\0') << uint8_t('\0'); //ACN Packet identifier
        packet << uint16_t(0x7000 | (110 + channel_count)); //Flags and length
        packet << uint32_t(0x0004); //Vector, identifies as PDU protocol
        for(int n=0; n<16; n++)
            packet << uuid[n];//Sender Unique ID, needs to be an UUID by spec. But most likely ignored by equipment.
        //Framing layer
        packet << uint16_t(0x7000 | (88 + channel_count)); //Flags and length
        packet << uint32_t(0x0002); //Vector, identifies as DMP protocol PDU
        for(int n=0; n<64; n++)
            packet << source_name[n];//Source name, needs to be an UTF-8 zero terminated string. Only for ID goals.
        packet << uint8_t(100); //Priority
        packet << uint16_t(0);  //Reserved
        packet << uint8_t(sequence_number);  //sequence number
        packet << uint8_t(0);  //option flags
        packet << uint16_t(universe);  //Universe number
        //DMP layer
        packet << uint16_t(0x7000 | (11 + channel_count)); //Flags and length
        packet << uint8_t(2);  //Vector, message is PDU
        packet << uint8_t(0x1a);  //Format of address and data
        packet << uint16_t(0x0000);  //First property address
        packet << uint16_t(0x0001);  //Address increments
        packet << uint16_t(1 + channel_count);  //Value count
        packet << uint8_t(0x00); //DMX512 start byte.
        for(int n=0; n<channel_count; n++)
            packet << uint8_t(channel_data[n]);

        sequence_number++;
        
        if (multicast)
            socket.send(packet.getData(), packet.getDataSize(), sf::IpAddress(239, 255, (universe >> 8), universe & 0xFF), acn_port);
        else
            UDPbroadcastPacket(socket, packet.getData(), packet.getDataSize(), acn_port);
        
        sf::sleep(sf::milliseconds(resend_delay));
    }
}
