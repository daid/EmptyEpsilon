#include "gameGlobalInfo.h"

P<GameGlobalInfo> gameGlobalInfo;

REGISTER_MULTIPLAYER_CLASS(GameGlobalInfo, "GameGlobalInfo")
GameGlobalInfo::GameGlobalInfo()
: MultiplayerObject("GameGlobalInfo")
{
    assert(!gameGlobalInfo);

    victory_faction = -1;
    gameGlobalInfo = this;
    for(int n=0; n<maxPlayerShips; n++)
    {
        playerShipId[n] = -1;
        registerMemberReplication(&playerShipId[n]);
    }
    for(int n=0; n<maxNebula; n++)
    {
        nebulaInfo[n].vector = sf::Vector3f(random(-1, 1), random(-1, 1), random(-1, 1));
        nebulaInfo[n].textureName = "Nebula" + string(irandom(1, 3));
        registerMemberReplication(&nebulaInfo[n].vector);
        registerMemberReplication(&nebulaInfo[n].textureName);
    }
    
    player_warp_jump_drive_setting = PWJ_ShipDefault;
    long_range_radar_range = 25000;
    use_beam_shield_frequencies = true;

    registerMemberReplication(&victory_faction);
    registerMemberReplication(&long_range_radar_range);
    registerMemberReplication(&use_beam_shield_frequencies);
}

P<PlayerSpaceship> GameGlobalInfo::getPlayerShip(int index)
{
    assert(index >= 0 && index < maxPlayerShips);
    if (game_server)
        return game_server->getObjectById(playerShipId[index]);
    return game_client->getObjectById(playerShipId[index]);
}

void GameGlobalInfo::setPlayerShip(int index, P<PlayerSpaceship> ship)
{
    assert(index >= 0 && index < maxPlayerShips);
    assert(game_server);

    if (ship)
        playerShipId[index] = ship->getMultiplayerId();
    else
        playerShipId[index] = -1;
}

int GameGlobalInfo::findPlayerShip(P<PlayerSpaceship> ship)
{
    for(int n=0; n<maxPlayerShips; n++)
        if (getPlayerShip(n) == ship)
            return n;
    return -1;
}

int GameGlobalInfo::insertPlayerShip(P<PlayerSpaceship> ship)
{
    for(int n=0; n<maxPlayerShips; n++)
    {
        if (!getPlayerShip(n))
        {
            setPlayerShip(n, ship);
            return n;
        }
    }
    return -1;
}

string playerWarpJumpDriveToString(EPlayerWarpJumpDrive player_warp_jump_drive)
{
    switch(player_warp_jump_drive)
    {
    case PWJ_ShipDefault:
        return "Ship default";
    case PWJ_WarpDrive:
        return "Warp-drive";
    case PWJ_JumpDrive:
        return "Jump-drive";
    case PWJ_WarpAndJumpDrive:
        return "Both";
    default:
        return "?";
    }
}
