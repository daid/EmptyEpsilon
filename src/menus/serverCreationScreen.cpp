#include <i18n.h>
#include "preferenceManager.h"
#include "serverCreationScreen.h"
#include "shipSelectionScreen.h"
#include "gameGlobalInfo.h"
#include "epsilonServer.h"
#include "gui/gui2_overlay.h"
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
    // Background elements.
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    // Layout elements.
    GuiElement* container = new GuiElement(this, "CONTAINER");
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
             ->setAttribute("padding", "50");
    container->setAttribute("layout", "vertical");

    GuiElement* column = new GuiElement(container, "COLUMN");
    column->setSize(750.0f, GuiElement::GuiSizeMax)
          ->setAttribute("layout", "vertical");
    column->setAttribute("alignment", "topcenter");

    // Server configuration section.
    (new GuiLabel(column, "CONFIG_LABEL", tr("Server configuration"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50.0f);

    // Server name row.
    GuiElement* row = new GuiElement(column, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiLabel(row, "NAME_LABEL", tr("Server name: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(250, GuiElement::GuiSizeMax);
    server_name = new GuiTextEntry(row, "SERVER_NAME", "server");
    server_name->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Server password row.
    row = new GuiElement(column, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiLabel(row, "PASSWORD_LABEL", tr("Server password: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(250, GuiElement::GuiSizeMax);
    server_password = new GuiTextEntry(row, "SERVER_PASSWORD", "");
    server_password->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // GM control code row.
    row = new GuiElement(column, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiLabel(row, "GM_CONTROL_CODE_LABEL", tr("GM control code: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(250, GuiElement::GuiSizeMax);
    gm_password = new GuiTextEntry(row, "GM_CONTROL_CODE", "");
    gm_password->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // LAN/Internet row.
    row = new GuiElement(column, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiLabel(row, "LAN_INTERNET_LABEL", tr("List on master server: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(250, GuiElement::GuiSizeMax);
    server_visibility = new GuiSelector(row, "LAN_INTERNET_SELECT", [](int index, string value) { });
    server_visibility->setOptions({tr("No"), tr("Yes")})->setSelectionIndex(0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    row = new GuiElement(column, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiLabel(row, "SERVER_PORT", tr("Server port: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(250, GuiElement::GuiSizeMax);
    server_port = new GuiTextEntry(row, "SERVER_PORT", string(defaultServerPort));
    server_port->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Server info section.
    (new GuiLabel(column, "INFO_LABEL", tr("Server info"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Reverse proxy server IP row.
    string reverse_proxy_value = PreferencesManager::get("serverproxy");
    GuiPanel* server_proxy_panel = new GuiPanel(column, "SERVERPROXY_MESSAGE_BOX");
    server_proxy_panel
        ->setSize(GuiElement::GuiSizeMax, 80.0f)
        ->setVisible(reverse_proxy_value != "");
    // Serverproxy (reverse proxy) is directly configured in options or command
    // line
    (new GuiLabel(server_proxy_panel, "PROXY_LABEL", tr("Server was configured to connect to reverse proxy:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    string proxy_ips;
    string sep="";
    for (auto proxy_ip : reverse_proxy_value.split(":"))
    {
        proxy_ips = proxy_ips + sep + "[" + proxy_ip + "]";
        sep = ",";
    }
    (new GuiLabel(server_proxy_panel, "PROXY_IPS", proxy_ips, 30))->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0,30);

    // Server IP row.
    row = new GuiElement(column, "");
    row->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "horizontal");
    (new GuiLabel(row, "SERVER_IP_LABEL", tr("Server IP: "), 30))->setAlignment(sp::Alignment::TopRight)->setSize(250, GuiElement::GuiSizeMax);

    auto server_ips = new GuiListbox(row, "SERVER_IPS", [](int index, string value){});
    server_ips->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    server_ips->setTextSize(20);
    for (auto addr_str : sp::io::network::Address::getLocalAddress().getHumanReadable())
    {
        if (addr_str == "::1" || addr_str == "127.0.0.1") continue;
        server_ips->addEntry(addr_str, addr_str);
    }

    // Bottom buttons.
    row = new GuiElement(container, "");
    row->setSize(GuiElement::GuiSizeMax, 50.0f)
       ->setAttribute("margin", "0, 0, 50, 0");

    // Close server button.
    (new GuiButton(row, "CLOSE_SERVER", tr("Close"), [this]() {
        destroy();
        returnToMainMenu(getRenderLayer());
    }))->setSize(300.0f, GuiElement::GuiSizeMax)
       ->setPosition(-250.0f, 0.0f, sp::Alignment::BottomCenter);

    // Start server button.
    (new GuiButton(row, "START_SERVER", tr("Start server"), [this]() {
        int port = server_port->getText().toInt();
        if (port < 1)
            port = defaultServerPort;
        new EpsilonServer(port);
        game_server->setServerName(server_name->getText());
        game_server->setPassword(server_password->getText().upper());
        gameGlobalInfo->gm_control_code = gm_password->getText().upper();
        if (server_visibility->getSelectionIndex() == 1)
        {
            game_server->registerOnMasterServer(PreferencesManager::get("registry_registration_url", "http://daid.eu/ee/register.php"));
            new ServerSetupMasterServerRegistrationScreen();
        }
        else
        {
            new ServerScenarioSelectionScreen();
        }
        destroy();
    }))->setSize(300.0f, GuiElement::GuiSizeMax)
       ->setPosition(250.0f, 0.0f, sp::Alignment::BottomCenter);
}

ServerSetupMasterServerRegistrationScreen::ServerSetupMasterServerRegistrationScreen()
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    info_label = new GuiLabel(this, "INFO", "", 30);
    info_label->setPosition({0, 0}, sp::Alignment::Center);

    (new GuiButton(this, "CLOSE_SERVER", tr("Close"), [this]() {
        disconnectFromServer();
        new ServerSetupScreen();
        destroy();
    }))->setPosition(-250, -50, sp::Alignment::BottomCenter)->setSize(300, 50);

    // Start server button.
    continue_button = new GuiButton(this, "CONTINUE", tr("Continue"), [this]() {
        new ServerScenarioSelectionScreen();
        destroy();
    });
    continue_button->setPosition(250, -50, sp::Alignment::BottomCenter)->setSize(300, 50);
}

void ServerSetupMasterServerRegistrationScreen::update(float delta)
{
    switch(game_server->getMasterServerState())
    {
    case GameServer::MasterServerState::Disabled:
        info_label->setText("Not connecting to masterserver?");
        continue_button->enable();
        break;
    case GameServer::MasterServerState::Registering:
        info_label->setText("Connecting to master server");
        continue_button->disable();
        break;
    case GameServer::MasterServerState::Success:
        info_label->setText("Master server connection successful");
        continue_button->enable();
        break;
    case GameServer::MasterServerState::FailedToReachMasterServer:
        info_label->setText("Failed to reach the master server.");
        continue_button->disable();
        break;
    case GameServer::MasterServerState::FailedPortForwarding:
        info_label->setText("Port forwarding check failed.");
        continue_button->disable();
        break;
    }
}

ServerScenarioSelectionScreen::ServerScenarioSelectionScreen()
{
    // Background elements.
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    // Layout elements.
    GuiElement* container = new GuiElement(this, "");
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
             ->setAttribute("padding", "50");
    container->setAttribute("layout", "vertical");

    GuiElement* columns = new GuiElement(container, "");
    columns->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
           ->setAttribute("layout", "horizontal");

    GuiElement* left = new GuiElement(columns, "LEFT_COLUMN");
    left->setSize(350.0f, GuiElement::GuiSizeMax)
        ->setAttribute("layout", "vertical");
    GuiElement* middle = new GuiElement(columns, "MIDDLE_COLUMN");
    middle->setSize(350.0f, GuiElement::GuiSizeMax)
          ->setAttribute("layout", "vertical");
    middle->setAttribute("margin", "20, 0");
    GuiElement* right = new GuiElement(columns, "RIGHT_COLUMN");
    right->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
         ->setAttribute("layout", "vertical");

    // Scenario categories.
    (new GuiLabel(left, "CATEGORY_LABEL", tr("Category"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    category_list = new GuiListbox(left, "SCENARIO_CATEGORY", [this](int index, string value) {
        loadScenarioList(value);
    });
    category_list->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Scenario list.
    (new GuiLabel(middle, "LIST_LABEL", tr("Scenario"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    scenario_list = new GuiListbox(middle, "SCENARIO_LIST", [this](int index, string value)
    {
        ScenarioInfo info(value);
        description_text->setText(info.description);
        start_button->enable();
    });
    scenario_list->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Scenario description.
    (new GuiLabel(right, "DESCRIPTION_LABEL", tr("Description"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    description_text = new GuiScrollFormattedText(right, "SCENARIO_DESCRIPTION", tr("Select a scenario..."));
    description_text->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    for(const auto& category : ScenarioInfo::getCategories())
        category_list->addEntry(category, category);

    // Bottom buttons.
    GuiElement* row = new GuiElement(container, "");
    row->setSize(GuiElement::GuiSizeMax, 50.0f)
       ->setAttribute("margin", "0, 0, 50, 0");

    // Close server button.
    (new GuiButton(row, "CLOSE_SERVER", tr("Close"), [this]() {
        destroy();
        disconnectFromServer();
        new ServerSetupScreen();
    }))->setPosition(-250.0f, 0.0f, sp::Alignment::BottomCenter)
       ->setSize(300.0f, GuiElement::GuiSizeMax);

    // Start server button.
    start_button = new GuiButton(row, "START_SCENARIO", tr("Start scenario"), [this]() {
        if (scenario_list->getSelectionIndex() == -1)
            return;
        auto filename = scenario_list->getEntryValue(scenario_list->getSelectionIndex());
        ScenarioInfo info(filename);

        if (info.settings.empty())
        {
            // Start the selected scenario.
            gameGlobalInfo->scenario = info.name;
            gameGlobalInfo->startScenario(filename);

            // Destroy this screen and move on to ship selection.
            destroy();
            returnToShipSelection(getRenderLayer());
        }
        else
        {
            new ServerScenarioOptionsScreen(filename);
            destroy();
        }
    });
    start_button->setPosition(250.0f, 0.0f, sp::Alignment::BottomCenter)
                ->setSize(300.0f, GuiElement::GuiSizeMax)->disable();

    // Select the previously selected scenario.
    for(const auto& info : ScenarioInfo::getScenarios()) {
        if (info.name == gameGlobalInfo->scenario) {
            for(int n=0; n<category_list->entryCount(); n++) {
                if (info.hasCategory(category_list->getEntryValue(n))) {
                    category_list->setSelectionIndex(n);
                    category_list->scrollTo(n);
                    loadScenarioList(category_list->getEntryValue(n));
                    break;
                }
            }
            for(int n=0; n<scenario_list->entryCount(); n++) {
                if (info.filename == scenario_list->getEntryValue(n))
                {
                    scenario_list->setSelectionIndex(n);
                    scenario_list->scrollTo(n);
                    description_text->setText(info.description);
                    start_button->enable();
                    break;
                }
            }
        }
    }

    gameGlobalInfo->reset();
    gameGlobalInfo->scenario_settings.clear();
}

void ServerScenarioSelectionScreen::loadScenarioList(const string& category)
{
    scenario_list->setSelectionIndex(-1);
    scenario_list->setOptions({});
    for(const auto& info : ScenarioInfo::getScenarios(category))
        scenario_list->addEntry(info.name, info.filename);
    start_button->disable();
    description_text->setText(tr("Select a scenario..."));
}

ServerScenarioOptionsScreen::ServerScenarioOptionsScreen(string filename)
{
    ScenarioInfo info(filename);
    scenario_settings = {};

    // Background elements.
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    // Layout elements.
    GuiElement* container = new GuiElement(this, "");
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
             ->setAttribute("padding", "50");
    container->setAttribute("layout", "vertical");

    GuiElement* columns = new GuiElement(container, "");
    columns->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
           ->setAttribute("layout", "horizontal");

    // Scenario options.
    GuiElement* option_container = nullptr;
    int count = 0;
    // Allow wider columns if there are fewer than 5 options.
    float column_width = static_cast<int>(info.settings.size()) < 5
        ? 450.0f
        : 300.0f;

    // Left centering spacer for dynamic-width column.
    (new GuiElement(columns, ""))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Add an item per option, in up to 2 rows of 3 columns.
    for (auto& setting : info.settings)
    {
        // Break columns at two options.
        if (!option_container || count == 2)
        {
            option_container = new GuiElement(columns, "");
            option_container
                ->setSize(column_width, GuiElement::GuiSizeMax)
                ->setAttribute("layout", "vertical");
            // Add margin to columns after the first.
            if (count == 2) option_container->setAttribute("margin", "20, 0, 0, 0");
            count = 0;
        }

        // Option name.
        (new GuiLabel(option_container, "", setting.key_localized, 30.0f))
            ->addBackground()
            ->setSize(GuiElement::GuiSizeMax, 50.0f);

        // Option value selector.
        GuiSelector* selector = new GuiSelector(option_container, "",
            [this, info, setting](int index, string value)
            {
                this->scenario_settings[setting.key] = value;
                for (auto& option : setting.options)
                {
                    if (option.value == value)
                        description_per_setting[setting.key]->setText(option.description);
                }
                start_button->setEnable(this->scenario_settings.size() >= info.settings.size());
            }
        );
        selector->setSize(GuiElement::GuiSizeMax, 50.0f);

        for (auto& option : setting.options)
        {
            selector->addEntry(option.value_localized, option.value);
            if (option.value == setting.default_option)
            {
                selector->setSelectionIndex(selector->entryCount() - 1);
                this->scenario_settings[setting.key] = option.value;
            }
        }

        // Option description.
        GuiScrollFormattedText* description = new GuiScrollFormattedText(option_container, "", setting.description);
        description->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        // Add margin to bottom of first row.
        if (count == 0) description->setAttribute("margin", "0, 0, 0, 20");
        description_per_setting[setting.key] = description;

        count++;
    }

    // Right centering spacer for dynamic-width column.
    (new GuiElement(columns, ""))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Bottom buttons.
    GuiElement* row = new GuiElement(container, "");
    row->setSize(GuiElement::GuiSizeMax, 50.0f)
       ->setAttribute("margin", "0, 0, 50, 0");

    // Close server button.
    (new GuiButton(row, "BACK", tr("Back"), [this]() {
        new ServerScenarioSelectionScreen();
        destroy();
    }))->setPosition(-250.0f, 0.0f, sp::Alignment::BottomCenter)
       ->setSize(300.0f, GuiElement::GuiSizeMax);

    // Start server button.
    start_button = new GuiButton(row, "START_SCENARIO", tr("Start scenario"), [this, info, filename]() {
        // Start the selected scenario.
        gameGlobalInfo->scenario = info.name;
        gameGlobalInfo->startScenario(filename, this->scenario_settings);

        // Destroy this screen and move on to ship selection.
        destroy();
        returnToShipSelection(getRenderLayer());
    });
    start_button
        ->setPosition(250.0f, 0.0f, sp::Alignment::BottomCenter)
        ->setSize(300.0f, GuiElement::GuiSizeMax)
        ->setEnable(scenario_settings.size() >= info.settings.size());
}
