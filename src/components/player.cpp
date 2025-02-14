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
