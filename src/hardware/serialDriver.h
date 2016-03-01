#ifndef SERIAL_DRIVER_H
#define SERIAL_DRIVER_H

#ifdef __WIN32__
#include <windows.h>
#endif
#include "stringImproved.h"

//Class to interact with serial ports. Abstracts the difference between UNIX and Windows API.
//  And uses some tricks to help identify serial ports.
class SerialPort
{
private:
#ifdef __WIN32__
    HANDLE handle;
#endif
#if defined(__gnu_linux__) || (defined(__APPLE__) && defined(__MACH__))
    int handle;
#endif

public:
    enum EParity
    {
        NoParity,
        OddParity,
        EvenParity,
        MarkParity
    };
    enum EStopBits
    {
        OneStopBit,
        OneAndAHalfStopBit,
        TwoStopbits
    };

    SerialPort(string name);
    ~SerialPort();
    
    bool isOpen();
    
    void configure(int baudrate, int databits, EParity parity, EStopBits stopbits);
    
    void send(void* data, int data_size);
    int recv(void* data, int data_size);
    
    void setDTR();
    void clearDTR();
    void setRTS();
    void clearRTS();
    void sendBreak();
    
    static std::vector<string> getAvailablePorts();
    static string getPseudoDriverName(string port);
    static std::vector<string> portsByPseudoDriverName(string driver_name);
};

#endif//SERIAL_DRIVER_H
