#ifndef REDONCULUS_SERVER_H
#define REDONCULUS_SERVER_H

#include "engine.h"

class EpsilonServer : public GameServer
{
public:
    EpsilonServer();
    
    virtual void onNewClient(int32_t clientId);
    virtual void onDisconnectClient(int32_t clientId);
};

void disconnectFromServer();

#endif//REDONCULUS_SERVER_H
