#ifndef SCENARIO_INFO_H
#define SCENARIO_INFO_H

#include <i18n.h>
#include "stringImproved.h"

class ScenarioInfo
{
public:
    class SettingOption
    {
    public:
        string value;
        string value_localized;
        string description;
    };
    class Setting
    {
    public:
        string key;
        string key_localized;
        string description;
        string default_option;
        std::vector<SettingOption> options;
    };

    string filename;
    string name;
    string description;
    std::vector<string> categories;
    string author;
    std::vector<Setting> settings;

    ScenarioInfo(string filename);
    bool hasCategory(const string& category) const;

    static std::vector<string> getCategories();
    static std::vector<ScenarioInfo> getScenarios(const string& category);
private:
    void addKeyValue(string key, string value);
    bool addSettingOption(string key, string option, string description);

    static const std::vector<ScenarioInfo>& getCachedFullList();
    static std::vector<ScenarioInfo> cached_full_list;
};

#endif//SCENARIO_INFO_H
