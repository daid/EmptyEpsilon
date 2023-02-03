#pragma once

#include "stringImproved.h"
#include <vector>
#include <glm/gtc/type_precision.hpp>


class ShipLog
{
public:
    class Entry
    {
    public:
        string prefix;
        string text;
        glm::u8vec4 color;

        bool operator!=(const Entry& e) const { return prefix != e.prefix || text != e.text || color != e.color; }
    };

    std::vector<Entry> entries;

    void add(const string& message, glm::u8vec4 color);
};
