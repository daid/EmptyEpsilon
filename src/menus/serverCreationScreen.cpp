#include <i18n.h>
#include "preferenceManager.h"
#include "serverCreationScreen.h"
#include "shipSelectionScreen.h"
#include "gameGlobalInfo.h"
#include "epsilonServer.h"
#include "gui/scriptError.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_autolayout.h"
#include "gui/gui2_label.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_scrolltext.h"
#include "scenarioInfo.h"
#include "main.h"


ServerSetupScreen::ServerSetupScreen()
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    // Create main layout
    GuiElement* main_panel = new GuiAutoLayout(this, "", GuiAutoLayout::LayoutVerticalTopToBottom);
    main_panel->setPosition(0, 20, sp::Alignment::TopCenter)->setSize(750, GuiElement::GuiSizeMax);

    // Left column contents.
    // General section.
    (new GuiLabel(main_panel, "GENERAL_LABEL", tr("Server configuration"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Server name row.
    GuiElement* row = new GuiAutoLayout(main_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "NAME_LABEL", tr("Server name: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(250, GuiElement::GuiSizeMax);
    server_name = new GuiTextEntry(row, "SERVER_NAME", "server");
    server_name->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Server password row.
    row = new GuiAutoLayout(main_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "PASSWORD_LABEL", tr("Server password: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(250, GuiElement::GuiSizeMax);
    server_password = new GuiTextEntry(row, "SERVER_PASSWORD", "");
    server_password->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // GM control code row.
    row = new GuiAutoLayout(main_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "GM_CONTROL_CODE_LABEL", tr("GM control code: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(250, GuiElement::GuiSizeMax);
    gm_password = new GuiTextEntry(row, "GM_CONTROL_CODE", "");
    gm_password->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // LAN/Internet row.
    row = new GuiAutoLayout(main_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "LAN_INTERNET_LABEL", tr("Server visibility: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(250, GuiElement::GuiSizeMax);
    server_visibility = new GuiSelector(row, "LAN_INTERNET_SELECT", [](int index, string value) { });
    server_visibility->setOptions({tr("LAN only"), tr("Internet")})->setSelectionIndex(0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiLabel(main_panel, "GENERAL_LABEL", tr("Server info"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    // Server IP row.
    row = new GuiAutoLayout(main_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 350);
    (new GuiLabel(row, "IP_LABEL", tr("Server IP: "), 30))->setAlignment(sp::Alignment::TopRight)->setSize(250, GuiElement::GuiSizeMax);
    auto ips = new GuiListbox(row, "IP", [](int index, string value){});
    ips->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    ips->setTextSize(20);
    for(auto addr_str : sp::io::network::Address::getLocalAddress().getHumanReadable())
    {
        if (addr_str == "::1" || addr_str == "127.0.0.1") continue;
        ips->addEntry(addr_str, addr_str);
    }

    //======== Bottom buttons
    // Close server button.
    (new GuiButton(this, "CLOSE_SERVER", tr("Close"), [this]() {
        destroy();
        returnToMainMenu();
    }))->setPosition(-250, -50, sp::Alignment::BottomCenter)->setSize(300, 50);

    // Start server button.
    (new GuiButton(this, "START_SERVER", tr("Start server"), [this]() {
        new EpsilonServer();
        game_server->setServerName(server_name->getText());
        game_server->setPassword(server_password->getText().upper());
        gameGlobalInfo->gm_control_code = gm_password->getText().upper();
        if (server_visibility->getSelectionIndex() == 1)
            game_server->registerOnMasterServer(PreferencesManager::get("registry_registration_url", "http://daid.eu/ee/register.php"));

        new ServerScenarioSelectionScreen();
        destroy();
    }))->setPosition(250, -50, sp::Alignment::BottomCenter)->setSize(300, 50);
}

ServerScenarioSelectionScreen::ServerScenarioSelectionScreen()
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    GuiElement* container = new GuiAutoLayout(this, "", GuiAutoLayout::ELayoutMode::LayoutVerticalColumns);
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    GuiElement* left = new GuiAutoLayout(new GuiElement(container, ""), "", GuiAutoLayout::LayoutVerticalTopToBottom);
    left->setPosition(0, 20, sp::Alignment::TopCenter)->setSize(400, GuiElement::GuiSizeMax);
    GuiElement* middle = new GuiAutoLayout(new GuiElement(container, ""), "", GuiAutoLayout::LayoutVerticalTopToBottom);
    middle->setPosition(0, 20, sp::Alignment::TopCenter)->setSize(400, GuiElement::GuiSizeMax);
    GuiElement* right = new GuiAutoLayout(new GuiElement(container, ""), "", GuiAutoLayout::LayoutVerticalTopToBottom);
    right->setPosition(0, 20, sp::Alignment::TopCenter)->setSize(400, GuiElement::GuiSizeMax);

    (new GuiLabel(left, "GENERAL_LABEL", tr("Category"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    category_list = new GuiListbox(left, "SCENARIO_CATEGORY", [this](int index, string value) {
        scenario_list->setSelectionIndex(-1);
        scenario_list->setOptions({});
        for(const auto& info : ScenarioInfo::getScenarios(value))
            scenario_list->addEntry(info.name, info.filename);
        start_button->disable();
        description_text->setText("Select a scenario...");
    });
    category_list->setSize(GuiElement::GuiSizeMax, 700);

    (new GuiLabel(middle, "GENERAL_LABEL", tr("Scenario"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    scenario_list = new GuiListbox(middle, "SCENARIO_LIST", [this](int index, string value)
    {
        ScenarioInfo info(value);
        description_text->setText(info.description);
        start_button->enable();
    });
    scenario_list->setSize(GuiElement::GuiSizeMax, 700);
    (new GuiLabel(right, "GENERAL_LABEL", tr("Description"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    description_text = new GuiScrollText(right, "SCENARIO_DESCRIPTION", "Select a scenario...");
    description_text->setSize(GuiElement::GuiSizeMax, 700);

    for(const auto& category : ScenarioInfo::getCategories())
        category_list->addEntry(category, category);

    //======== Bottom buttons
    // Close server button.
    (new GuiButton(this, "CLOSE_SERVER", tr("Close"), [this]() {
        destroy();
        disconnectFromServer();
        new ServerSetupScreen();
    }))->setPosition(-250, -50, sp::Alignment::BottomCenter)->setSize(300, 50);

    // Start server button.
    start_button = new GuiButton(this, "START_SCENARIO", tr("Start scenario"), [this]() {
        if (scenario_list->getSelectionIndex() == -1)
            return;
        auto filename = scenario_list->getEntryValue(scenario_list->getSelectionIndex());
        ScenarioInfo info(filename);

        if (info.settings.empty())
        {
            // Start the selected scenario.
            gameGlobalInfo->startScenario(filename);

            // Destroy this screen and move on to ship selection.
            destroy();
            returnToShipSelection();
            new ScriptErrorRenderer();
        }
        else
        {
            new ServerScenarioOptionsScreen(filename);
            destroy();
        }
    });
    start_button->setPosition(250, -50, sp::Alignment::BottomCenter)->setSize(300, 50)->disable();

    gameGlobalInfo->reset();
    gameGlobalInfo->scenario_settings.clear();
}

ServerScenarioOptionsScreen::ServerScenarioOptionsScreen(string filename)
{
    ScenarioInfo info(filename);

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    GuiElement* column_container = new GuiAutoLayout(this, "", GuiAutoLayout::ELayoutMode::LayoutVerticalColumns);
    column_container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    GuiAutoLayout* container = nullptr;
    int count = 0;
    for(auto& setting : info.settings)
    {
        if (!container || count == 2)
        {
            container = new GuiAutoLayout(new GuiElement(column_container, ""), "", GuiAutoLayout::LayoutVerticalTopToBottom);
            container->setPosition(0, 20, sp::Alignment::TopCenter)->setSize(350, GuiElement::GuiSizeMax);
            count = 0;
        }
        (new GuiLabel(container, "", setting.key, 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
        auto selector = new GuiSelector(container, "", [this, info, setting](int index, string value) {
            gameGlobalInfo->scenario_settings[setting.key] = value;
            for(auto& option : setting.options)
                if (option.first == value)
                    description_per_setting[setting.key]->setText(option.second);
            start_button->setEnable(gameGlobalInfo->scenario_settings.size() >= info.settings.size());
        });
        selector->setSize(GuiElement::GuiSizeMax, 50);
        for(auto& option : setting.options)
            selector->addEntry(option.first.capitalize(), option.first);
        auto description = new GuiScrollText(container, "", setting.description);
        description->setSize(GuiElement::GuiSizeMax, 300);
        count++;

        description_per_setting[setting.key] = description;
    }

    //======== Bottom buttons
    // Close server button.
    (new GuiButton(this, "BACK", tr("Back"), [this]() {
        new ServerScenarioSelectionScreen();
        destroy();
    }))->setPosition(-250, -50, sp::Alignment::BottomCenter)->setSize(300, 50);

    // Start server button.
    start_button = new GuiButton(this, "START_SCENARIO", tr("Start scenario"), [this, filename]() {
        // Start the selected scenario.
        gameGlobalInfo->startScenario(filename);

        // Destroy this screen and move on to ship selection.
        destroy();
        returnToShipSelection();
        new ScriptErrorRenderer();
    });
    start_button->setPosition(250, -50, sp::Alignment::BottomCenter)->setSize(300, 50)->disable();
}
