#ifndef REDONCULUS_SERVER_H
#define REDONCULUS_SERVER_H

#include "engine.h"
#include "threatLevelEstimate.h"

class EpsilonServer : public GameServer
{
    P<ThreatLevelEstimate> threat_estimate;
public:
    EpsilonServer();
    virtual ~EpsilonServer();

    virtual void onNewClient(int32_t client_id);
    virtual void onDisconnectClient(int32_t client_id);
};

void disconnectFromServer();

#endif//REDONCULUS_SERVER_H
