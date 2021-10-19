#include "scenarioInfo.h"
#include "resources.h"
#include <unordered_set>

ScenarioInfo::ScenarioInfo(string filename)
{
    this->filename = filename;
    name = filename.substr(9, -4);

    P<ResourceStream> stream = getResourceStream(filename);
    if (!stream) return;

    string key;
    string value;
    while(stream->tell() < stream->getSize())
    {
        string line = stream->readLine().strip();
        // Get the scenario meta-data.
        if (!line.startswith("--"))
            break;
        if (line.startswith("---"))
        {
            line = line.substr(3).strip();
            value = value + "\n" + line;
        }else{
            line = line.substr(2).strip();
            if (line.find(":") < 0)
            {
                key = "";
                continue;
            }
            addKeyValue(key, value);
            key = line.substr(0, line.find(":")).strip();
            value = line.substr(line.find(":") + 1).strip();
        }
    }
    addKeyValue(key, value);
    if (categories.size() == 0)
    {
        LOG(WARNING) << "No scenario category for: " << filename;
        categories.push_back("Unknown");
    }
}

bool ScenarioInfo::hasCategory(const string& category)
{
    for(auto& c : categories)
        if (c == category)
            return true;
    return false;
}

void ScenarioInfo::addKeyValue(string key, string value)
{
    if (key == "")
        return;
    string additional;
    if (key.find("[") >= 0 && key.endswith("]"))
    {
        additional = key.substr(key.find("[") + 1, -1);
        key = key.substr(0, key.find("["));
    }
    key = key.lower();
    if (key == "name")
    {
        name = value;
    }
    else if (key == "description")
    {
        description = value;
    }
    else if (key == "author")
    {
        author = value;
    }
    else if (key == "type" || key == "category")
    {
        categories.push_back(value);
    }
    else if (key == "variation" && additional != "")
    {
        if (!addSettingOption("variation", additional, value))
        {
            Setting setting;
            setting.key = "variation";
            setting.description = "Select a scenario variation";
            setting.options.emplace_back("None", "");
            settings.push_back(setting);
            addSettingOption("variation", additional, value);
        }
    }
    else if (key == "setting" && additional != "")
    {
        Setting setting;
        setting.key = additional;
        setting.description = value;
        settings.push_back(setting);
    }
    else if (additional == "" || !addSettingOption(key, additional, value))
    {
        LOG(WARNING) << "Unknown scenario meta data: " << key << ": " << value;
    }
}

std::vector<string> ScenarioInfo::getCategories()
{
    std::vector<string> result;
    std::unordered_set<string> known_categories;
    // Fetch and sort all Lua files starting with "scenario_".
    std::vector<string> scenario_filenames = findResources("scenario_*.lua");
    std::sort(scenario_filenames.begin(), scenario_filenames.end());
    // remove duplicates
    scenario_filenames.erase(std::unique(scenario_filenames.begin(), scenario_filenames.end()), scenario_filenames.end());
    for(auto& filename : scenario_filenames)
    {
        ScenarioInfo info(filename);
        for(auto& category : info.categories)
        {
            if (known_categories.find(category) != known_categories.end())
                continue;
            result.push_back(category);
            known_categories.insert(category);
        }
    }
    return result;
}

bool ScenarioInfo::addSettingOption(string key, string option, string description)
{
    for(auto& setting : settings)
    {
        if (setting.key == key)
        {
            setting.options.emplace_back(option, description);
            return true;
        }
    }
    return false;
}

std::vector<ScenarioInfo> ScenarioInfo::getScenarios(const string& category)
{
    std::vector<ScenarioInfo> result;
    
    // Fetch and sort all Lua files starting with "scenario_".
    std::vector<string> scenario_filenames = findResources("scenario_*.lua");
    std::sort(scenario_filenames.begin(), scenario_filenames.end());
    // remove duplicates
    scenario_filenames.erase(std::unique(scenario_filenames.begin(), scenario_filenames.end()), scenario_filenames.end());
    for(string filename : scenario_filenames)
    {
        ScenarioInfo info(filename);
        if (info.hasCategory(category))
            result.push_back(info);
    }
    return result;
}