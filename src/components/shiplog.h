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

    void add(const string& message, glm::u8vec4 color);
    void add(const string& prefix, const string& message, glm::u8vec4 color);
    void clear();

    size_t size() const { return entries.size(); }
    const Entry& get(size_t index) const { return entries[index]; }

    // Info for replication
    bool cleared = false;
    size_t new_entry_count = 0;
private:
    std::vector<Entry> entries;
};
