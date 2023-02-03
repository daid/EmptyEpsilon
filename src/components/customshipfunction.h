#pragma once

#include "stringImproved.h"
#include "scriptInterface.h"
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
        ECrewPosition crew_position;
        ScriptSimpleCallback callback;
        int order;

        bool operator!=(const Function& csf) { return type != csf.type || name != csf.name || caption != csf.caption || crew_position != csf.crew_position; }
        bool operator<(const Function& other) const { return (order < other.order); }
    };

    std::vector<Function> functions;
};

//static inline sp::io::DataBuffer& operator << (sp::io::DataBuffer& packet, const PlayerSpaceship::CustomShipFunction& csf) { return packet << uint8_t(csf.type) << uint8_t(csf.crew_position) << csf.name << csf.caption; }
//static inline sp::io::DataBuffer& operator >> (sp::io::DataBuffer& packet, PlayerSpaceship::CustomShipFunction& csf) { int8_t tmp; packet >> tmp; csf.type = PlayerSpaceship::CustomShipFunction::Type(tmp); packet >> tmp; csf.crew_position = ECrewPosition(tmp); packet >> csf.name >> csf.caption; return packet; }
