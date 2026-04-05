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

int Waypoints::addNew(glm::vec2 position, int set_id)
{
    if (set_id < 1 || set_id > MAX_SETS) return -1;
    int count = 0;
    for (auto& p : waypoints)
        if (p.set_id == set_id) count++;
    if (count >= 9)
        return -1;
    for (int id = 1; id < 10; id++)
    {
        bool used = false;
        for (auto& p : waypoints)
            if (p.id == id && p.set_id == set_id) used = true;
        if (!used)
        {
            waypoints.push_back({id, set_id, position});
            dirty = true;
            return id;
        }
    }
    return -1;
}

void Waypoints::move(int id, glm::vec2 position, int set_id)
{
    for (auto& p : waypoints)
    {
        if (p.id == id && p.set_id == set_id)
        {
            p.position = position;
            dirty = true;
            return;
        }
    }
}

void Waypoints::remove(int id, int set_id)
{
    waypoints.erase(std::remove_if(waypoints.begin(), waypoints.end(), [id, set_id](auto& p) { return p.id == id && p.set_id == set_id; }), waypoints.end());
    dirty = true;
}

std::optional<glm::vec2> Waypoints::get(int id, int set_id)
{
    for (auto& p : waypoints)
        if (p.id == id && p.set_id == set_id) return p.position;
    return {};
}

void Waypoints::setRoute(bool value, int set_id)
{
    if (set_id < 1 || set_id > MAX_SETS) return;
    is_route[set_id - 1] = value;
    dirty = true;
}