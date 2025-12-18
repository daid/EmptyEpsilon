#include "player.h"
#include "i18n.h"


string alertLevelToString(AlertLevel level)
{
    // Convert an EAlertLevel to a string.
    switch(level)
    {
    case AlertLevel::RedAlert: return "RED ALERT";
    case AlertLevel::YellowAlert: return "YELLOW ALERT";
    case AlertLevel::Normal: return "Normal";
    default:
        return "???";
    }
}

string alertLevelToLocaleString(AlertLevel level)
{
    // Convert an EAlertLevel to a translated string.
    switch(level)
    {
    case AlertLevel::RedAlert: return tr("alert","RED ALERT");
    case AlertLevel::YellowAlert: return tr("alert","YELLOW ALERT");
    case AlertLevel::Normal: return tr("alert","Normal");
    default:
        return "???";
    }
}

int Waypoints::addNew(glm::vec2 position)
{
    if (waypoints.size() == 9)
        return -1;
    for(int id=1; id<10; id++) {
        bool used = false;
        for(auto& p : waypoints)
            if (p.id == id)
                used = true;
        if (!used) {
            waypoints.push_back({id, position});
            dirty = true;
            return id;
        }
    }
    return -1;
}

void Waypoints::move(int id, glm::vec2 position)
{
    for(auto& p : waypoints) {
        if (p.id == id) {
            p.position = position;
            dirty = true;
            return;
        }
    }
}

void Waypoints::remove(int id)
{
    waypoints.erase(std::remove_if(waypoints.begin(), waypoints.end(), [id](auto& p) { return p.id == id; }), waypoints.end());
}

std::optional<glm::vec2> Waypoints::get(int id)
{
    for(auto& p : waypoints)
        if (p.id == id)
            return p.position;
    return {};
}