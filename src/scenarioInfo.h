#ifndef SCENARIO_INFO_H
#define SCENARIO_INFO_H

#include "stringImproved.h"

class ScenarioInfo
{
public:
    string filename;
    string name;
    string description;
    string type;
    string author;
    std::vector<std::pair<string, string> > variations;

    ScenarioInfo(string filename);

private:
    void addKeyValue(string key, string value);
};

#endif//SCENARIO_INFO_H
