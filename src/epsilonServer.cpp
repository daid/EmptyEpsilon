#include "epsilonServer.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "main.h"

EpsilonServer::EpsilonServer()
: GameServer("Server", VERSION_NUMBER)
{
    new GameGlobalInfo();
    PlayerInfo* info = new PlayerInfo();
    info->client_id = 0;
    my_player_info = info;
    engine->setGameSpeed(0.0);
    for(unsigned int n=0; n<factionInfo.size(); n++)
        factionInfo[n]->reset();

    threat_estimate = new ThreatLevelEstimate();
    threat_estimate->setCallbacks([](){
        soundManager->playMusicSet({"music/Nebulous_0.ogg", "music/OutThere.ogg", "music/GalacticTemple.ogg", "music/Please, answer me my friend.ogg", "music/spacelifeNo14_0.ogg"});
    }, []() {
        soundManager->playMusicSet({"music/Dream Raid Full Version (Mock Up).ogg", "music/Thrust Sequence.ogg", "music/Recall of the Shadows_0.ogg", "music/Imminent Threat.ogg", "music/neocrey - Last Cyber Dance.ogg"});
    });
    soundManager->playMusicSet({"music/Nebulous_0.ogg", "music/OutThere.ogg", "music/GalacticTemple.ogg", "music/Please, answer me my friend.ogg", "music/spacelifeNo14_0.ogg"});
}

EpsilonServer::~EpsilonServer()
{
    if (threat_estimate)
        threat_estimate->destroy();
}

void EpsilonServer::onNewClient(int32_t client_id)
{
    LOG(INFO) << "New client: " << client_id;
    PlayerInfo* info = new PlayerInfo();
    info->client_id = client_id;
}

void EpsilonServer::onDisconnectClient(int32_t client_id)
{
    LOG(INFO) << "Client left: " << client_id;
    foreach(PlayerInfo, i, player_info_list)
        if (i->client_id == client_id)
            i->destroy();
    player_info_list.update();
}

void disconnectFromServer()
{
    soundManager->stopMusic();

    if (game_client)
        game_client->destroy();
    if (game_server)
        game_server->destroy();
    if (gameGlobalInfo)
        gameGlobalInfo->destroy();
    foreach(PlayerInfo, i, player_info_list)
        i->destroy();
    foreach(GameEntity, e, entityList)
        e->destroy();
    foreach(SpaceObject, o, space_object_list)
        o->destroy();
    if (my_player_info)
        my_player_info->destroy();
    if (engine->getObject("scenario"))
        engine->getObject("scenario")->destroy();
}
