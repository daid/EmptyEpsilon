#ifndef EPSILON_SERVER_H
#define EPSILON_SERVER_H

#include "multiplayer_server.h"

class EpsilonServer : public GameServer
{
public:
    EpsilonServer(int server_port);
    virtual ~EpsilonServer() = default;

    virtual void onNewClient(int32_t client_id) override;
    virtual void onDisconnectClient(int32_t client_id) override;

    virtual std::unordered_set<int32_t> onVoiceChat(int32_t client_id, int32_t target_identifier) override;
};

void disconnectFromServer();

#endif//EPSILON_SERVER_H
