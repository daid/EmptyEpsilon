#pragma once

#include "stringImproved.h"
#include "crewPosition.h"
#include "script/callback.h"
#include <vector>


class CustomShipFunctions
{
public:
    class Function
    {
    public:
        enum class Type
        {
            Info,
            Button,
            Message
        };
        Type type;
        string name;
        string caption;
        CrewPositions crew_positions;
        sp::script::Callback callback;
        int order;

        bool operator!=(const Function& csf) { return type != csf.type || name != csf.name || caption != csf.caption || crew_positions != csf.crew_positions; }
        bool operator<(const Function& other) const { return (order < other.order); }
    };

    std::vector<Function> functions;
    bool functions_dirty = true;
};
