#include "components/shiplog.h"
#include "gameGlobalInfo.h"


void ShipLog::add(const string& message, glm::u8vec4 color)
{
    // Cap the ship's log size to 100 entries. If it exceeds that limit,
    // start erasing entries from the beginning.
    if (entries.size() > 100)
        entries.erase(entries.begin());

    // Timestamp a log entry, color it, and add it to the end of the log.
    entries.push_back({gameGlobalInfo->getMissionTime() + string(": "), message, color});
}