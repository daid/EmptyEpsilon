#include "scenarioInfo.h"
#include "resources.h"
#include "preferenceManager.h"
#include <i18n.h>
#include <unordered_set>

static std::unique_ptr<i18n::Catalogue> locale;
std::vector<ScenarioInfo> ScenarioInfo::cached_full_list;

ScenarioInfo::ScenarioInfo(string filename)
{
    this->filename = filename;
    name = filename.substr(9, -4);

    P<ResourceStream> stream = getResourceStream(filename);
    if (!stream) return;
    locale = i18n::Catalogue::create("locale/" + filename.replace(".lua", "." + PreferencesManager::get("language", "en") + ".po"));

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
    locale.reset();
}

bool ScenarioInfo::hasCategory(const string& category) const
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
    if (key.lower() == "name")
    {
        name = locale->tr(value);
    }
    else if (key.lower() == "description")
    {
        description = locale->tr(value);
    }
    else if (key.lower() == "author")
    {
        author = value;
    }
    else if (key.lower() == "type" || key.lower() == "category")
    {
        categories.push_back(value);
    }
    else if (key.lower() == "variation" && additional != "")
    {
        if (!addSettingOption("variation", additional, value))
        {
            Setting setting;
            setting.key = "variation";
            setting.key_localized = "variation";
            setting.description = "Select a scenario variation";
            setting.options.push_back({"None", "None", ""});
            settings.push_back(setting);
            addSettingOption("variation", additional, value);
        }
    }
    else if (key.lower() == "setting" && additional != "")
    {
        Setting setting;
        setting.key = additional;
        setting.key_localized = locale->tr("setting", additional);
        setting.description = locale->tr("setting", value);
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
    for(const auto& info : getScenarios())
    {
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
    string tag = "";
    if (option.find('|') > 0)
    {
        tag = option.substr(option.find('|') + 1).lower();
        option = option.substr(0, option.find('|'));
    }
    for(auto& setting : settings)
    {
        if (setting.key == key)
        {
            setting.options.push_back({option, locale->tr(key, option), locale->tr(key, description)});
            if (tag == "default")
                setting.default_option = option;
            return true;
        }
    }
    return false;
}

const std::vector<ScenarioInfo>& ScenarioInfo::getScenarios()
{
    if (cached_full_list.empty())
    {
        auto start_time = std::chrono::steady_clock::now();
        // Fetch and sort all Lua files starting with "scenario_".
        std::vector<string> scenario_filenames = findResources("scenario_*.lua");
        std::sort(scenario_filenames.begin(), scenario_filenames.end());
        // remove duplicates
        scenario_filenames.erase(std::unique(scenario_filenames.begin(), scenario_filenames.end()), scenario_filenames.end());

        for(string filename : scenario_filenames)
            cached_full_list.emplace_back(filename);
        LOG(Debug, "Get scenarios time: ", int(std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now() - start_time).count()), "ms");
    }
    return cached_full_list;
}

std::vector<ScenarioInfo> ScenarioInfo::getScenarios(const string& category)
{
    std::vector<ScenarioInfo> result;
    
    for(const auto& info : getScenarios())
    {
        if (info.hasCategory(category))
            result.push_back(info);
    }
    return result;
}
