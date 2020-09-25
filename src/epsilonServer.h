#ifndef EPSILON_SERVER_H
#define EPSILON_SERVER_H

#include "engine.h"

class EpsilonServer : public GameServer
{
public:
    EpsilonServer();
    virtual ~EpsilonServer() = default;

    virtual void onNewClient(int32_t client_id) override;
    virtual void onDisconnectClient(int32_t client_id) override;

    virtual std::unordered_set<int32_t> onVoiceChat(int32_t client_id, int32_t target_identifier) override;
};

void disconnectFromServer();

#endif//EPSILON_SERVER_H
