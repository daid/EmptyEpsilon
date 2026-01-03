#include "scanning.h"
#include "components/scanning.h"
#include "gameGlobalInfo.h"
#include "multiplayer_server.h"
#include "menus/luaConsole.h"

#include <ecs/query.h>


void ScanningSystem::update(float delta)
{
    for (auto [entity, scanner] : sp::ecs::Query<ScienceScanner>())
    {
        // If the scan setting or a target's scan complexity is none/0,
        // complete the scan after a delay.
        if (auto ss = scanner.target.getComponent<ScanState>())
        {
            if (ss->complexity == 0 || (ss->complexity < 0 && gameGlobalInfo->scanning_complexity == SC_None))
            {
                // If scan has just started, fire the onScanInitiated callback.
                if (scanner.delay == scanner.max_scanning_delay && ss->on_scan_initiated)
                    LuaConsole::checkResult(ss->on_scan_initiated.call<void>(scanner.target, entity, scanner.source));

                scanner.delay -= delta;
                if (scanner.delay < 0.0f && game_server)
                    scanningFinished(entity);
            }
        }
        // Otherwise, ignore the scanning_delay setting.
        else scanner.delay = 0.0f;
    }
}

void ScanningSystem::scanningFinished(sp::ecs::Entity command_source)
{
    auto scanner = command_source.getComponent<ScienceScanner>();
    if (!scanner) return;

    if (auto ss = scanner->target.getComponent<ScanState>())
    {
        switch(ss->getStateFor(command_source))
        {
        case ScanState::State::NotScanned:
        case ScanState::State::FriendOrFoeIdentified:
            if (ss->allow_simple_scan)
                ss->setStateFor(command_source, ScanState::State::SimpleScan);
            else
                ss->setStateFor(command_source, ScanState::State::FullScan);
            break;
        case ScanState::State::SimpleScan:
            ss->setStateFor(command_source, ScanState::State::FullScan);
            break;
        case ScanState::State::FullScan:
            break;
        }

        LuaConsole::checkResult(ss->on_scan_completed.call<void>(scanner->target, command_source, scanner->source));
    }

    scanner->target = {};
    scanner->source = {};
    scanner->delay = 0.0f;
}
