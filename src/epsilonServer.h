#ifndef EPSILON_SERVER_H
#define EPSILON_SERVER_H

#include "engine.h"

class EpsilonServer : public GameServer
{
public:
    EpsilonServer();
    virtual ~EpsilonServer();

    virtual void onNewClient(int32_t client_id);
    virtual void onDisconnectClient(int32_t client_id);
};

void disconnectFromServer();

#endif//EPSILON_SERVER_H
