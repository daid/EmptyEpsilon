#include "scanning.h"
#include "components/scanning.h"
#include "multiplayer_server.h"

#include <ecs/query.h>


void ScanningSystem::update(float delta)
{
    for(auto [entity, scanner] : sp::ecs::Query<ScienceScanner>()) {
        if (auto ss = scanner.target.getComponent<ScanState>()) {
            // If the scan setting or a target's scan complexity is none/0,
            // complete the scan after a delay.
            if (ss->complexity < 1)
            {
                scanner.delay -= delta;
                if (scanner.delay < 0 && game_server)
                    scanningFinished(entity);
            }
        }else{
            // Otherwise, ignore the scanning_delay setting.
            scanner.delay = 0.0;
        }
    }
}

void ScanningSystem::scanningFinished(sp::ecs::Entity source)
{
    auto scanner = source.getComponent<ScienceScanner>();
    if (!scanner) return;
    auto ss = scanner->target.getComponent<ScanState>();
    if (ss) {
        switch(ss->getStateFor(source)) {
        case ScanState::State::NotScanned:
        case ScanState::State::FriendOrFoeIdentified:
            if (ss->allow_simple_scan)
                ss->setStateFor(source, ScanState::State::SimpleScan);
            else
                ss->setStateFor(source, ScanState::State::FullScan);
            break;
        case ScanState::State::SimpleScan:
            ss->setStateFor(source, ScanState::State::FullScan);
            break;
        case ScanState::State::FullScan:
            break;
        }
    }
    scanner->target = {};
    scanner->delay = 0.0;
}
