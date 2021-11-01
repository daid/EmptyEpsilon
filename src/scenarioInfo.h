#ifndef SCENARIO_INFO_H
#define SCENARIO_INFO_H

#include "stringImproved.h"

class ScenarioInfo
{
public:
    class Setting
    {
    public:
        string key;
        string description;
        string default_option;
        std::vector<std::pair<string, string>> options;
    };

    string filename;
    string name;
    string description;
    std::vector<string> categories;
    string author;
    std::vector<Setting> settings;

    ScenarioInfo(string filename);
    bool hasCategory(const string& category);

    static std::vector<string> getCategories();
    static std::vector<ScenarioInfo> getScenarios(const string& category);
private:
    void addKeyValue(string key, string value);
    bool addSettingOption(string key, string option, string description);
};

#endif//SCENARIO_INFO_H
