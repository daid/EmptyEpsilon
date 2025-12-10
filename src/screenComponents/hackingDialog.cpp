#include "random.h"
#include "hackingDialog.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "mineSweeper.h"
#include "lightsOut.h"
#include "miniGame.h"
#include "i18n.h"
#include "engine.h"
#include <memory>
#include <algorithm>

#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_scrolltext.h"

GuiHackingDialog::GuiHackingDialog(GuiContainer* owner, string id)
: GuiOverlay(owner, id, glm::u8vec4(0,0,0,64))
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    hide();

    // Dummy game panel until we choose a system
    minigame_box = new GuiPanel(this, id + "_GAME_BOX");

    minigame_box->setPosition(0, 0, sp::Alignment::Center);
    game = std::make_shared<MiniGame>(minigame_box, this, 2);
    auto board_size = game->getBoardSize();
    minigame_box->setSize(board_size.x + 100, board_size.y + 150);

    // Status labels
    status_label = new GuiLabel(minigame_box, "", "...", 25);
    status_label->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 30);

    hacking_status_label = new GuiLabel(minigame_box, "", "", 25);
    hacking_status_label->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 0);

    reset_button = new GuiButton(minigame_box, "", tr("hacking", "Reset"), [this]()
    {
        game->reset();
    });
    reset_button->setSize(200, 50);
    reset_button->setPosition(25, -25, sp::Alignment::BottomLeft);
    close_button = new GuiButton(minigame_box, "", tr("button", "Close"), [this]()
    {
        hide();
    });
    close_button->setSize(200, 50);
    close_button->setPosition(-25, -25, sp::Alignment::BottomRight);

    progress_bar = new GuiProgressbar(minigame_box, "", 0, 1, 0.0);
    progress_bar->setPosition(-25, 75, sp::Alignment::TopRight);
    progress_bar->setSize(50, game->getBoardSize().y);

    // Target selection panel
    target_selection_box = new GuiPanel(this, id + "_BOX");
    target_selection_box
        ->setSize(300.0f, 545.0f)
        ->setPosition(board_size.x * 0.5f + 200.0f, 0.0f, sp::Alignment::Center)
        ->setAttribute("layout", "vertical");
    target_selection_box
        ->setAttribute("padding", "20, 20, 0, 20");

    GuiLabel* target_selection_label = new GuiLabel(target_selection_box, "", tr("hacking", "Target system"), 25.0f);
    target_selection_label
        ->addBackground()
        ->setSize(GuiElement::GuiSizeMax, 50.0f)
        ->setAttribute("margin", "0, 20, 0, 0");

    target_list = new GuiListbox(target_selection_box, "TARGET_SYSTEMS",
        [this](int index, string value)
        {
            target_system = ShipSystem::Type(value.toInt());
            getNewGame();
        });
    target_list->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    target_help = new GuiScrollText(target_selection_box, "MINIGAME_HELP", tr("Select a system in the targeted ship to begin a remote intrusion attempt, or hack. If successful, you reduce that system's effectiveness for a short period of time. Continue hacking systems on hostile targets to give your crew and allies a tactical advantage against it."));
    target_help
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->hide();

    (new GuiToggleButton(target_selection_label, "", "?",
        [this, target_selection_label](bool value)
        {
            target_help->setVisible(value);
            target_list->setVisible(!value);
            target_selection_label->setText(value ? tr("hacking", "Instructions") : tr("hacking", "Target system"));
        }
    ))
        ->setSize(30.0f, 30.0f)
        ->setPosition(0.0f, 0.0f, sp::Alignment::CenterRight);

    last_game_success = false;
}

void GuiHackingDialog::open(sp::ecs::Entity target)
{
    this->target = target;
    show();
    while(target_list->entryCount() > 0)
        target_list->removeEntry(0);
    for(int n=0; n<int(ShipSystem::Type::COUNT); n++) {
        auto sys = ShipSystem::get(target, ShipSystem::Type(n));
        if (sys && sys->can_be_hacked)
            target_list->addEntry(getLocaleSystemName(ShipSystem::Type(n)), string(n));
    }

    target_selection_box->show();
    game->disable();
}

void GuiHackingDialog::onDraw(sp::RenderTarget& renderer)
{
    if (!target)
    {
        hide();
        return;
    }
    GuiOverlay::onDraw(renderer);
    if (game->isGameComplete())
    {
        if (reset_time - engine->getElapsedTime() < 0.0f)
        {
            if (my_spaceship && last_game_success)
            {
                my_player_info->commandHackingFinished(target, target_system);
            }
            getNewGame();
        }else{
            progress_bar->setValue((reset_time - engine->getElapsedTime()) / auto_reset_time);
        }
    } else {
        progress_bar->setValue(game->getProgress());
        status_label->setText(tr("hacking", "Hacking in Progress: {percent}%").format({{"percent", string(int(100 * game->getProgress()))}}));
    }
    if (target_system != ShipSystem::Type::None)
    {
        auto sys = ShipSystem::get(target, target_system);
        if (sys && sys->can_be_hacked)
            hacking_status_label->setText(tr("hacking", "{target}: hacked {percent}%").format({{"target", getLocaleSystemName(target_system)}, {"percent", string(int(sys->hacked_level * 100.0f + 0.5f))}}));
    }
}

bool GuiHackingDialog::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    return true;
}

void GuiHackingDialog::onMiniGameComplete(bool success)
{
    reset_time = engine->getElapsedTime() + auto_reset_time;
    game->disable();
    last_game_success = success;
    status_label->setText(success ? tr("Hacking SUCCESS!") : tr("Hacking FAILURE!"));
}

void GuiHackingDialog::getNewGame() {
    int difficulty = 2;
    EHackingGames games = HG_All;
    if (gameGlobalInfo) {
      difficulty = gameGlobalInfo->hacking_difficulty;
      games = gameGlobalInfo->hacking_games;
    }

    const string lights_help = tr("To successfully hack this system, you must fully deactivate all illuminated binary countermeasure nodes by manipulating adjacent nodes.\n\nSelect a node in the grid to toggle its state between off and on. Doing so also toggles the state of the adjacent nodes immediately above, below, and to its sides. Continue toggling nodes until every node is deactivated.\n\nYou can make an unlimited number of moves, but seek efficient solutions to best aid your crewmates. Inexperienced hackers might chase illuminated nodes from top row to the bottom row by selecting the node immediately below each illuminated node. More experienced intrusion specialists might identify more efficient solutions.\n\nClick the Reset button to reset the field, or select a system to attempt a different intrusion method.");
    const string mine_help = tr("To successfully hack this system, you must apply a systematic process of elimination to identify sensitive data nodes within a grid without disturbing them.\n\nSelect a node in the grid to reveal it. If you reveal a sensitive node, the hacking interface marks it with an X. You can safely reveal one sensitive node, but revealing a second sensitive node alerts the system being hacked and disconnects your intrusion attempt.\n\nAn empty node lights up, and if no sensitive nodes surround it, any other adjacent nodes that also lack a nearby sensitive node automatically reveal themselves.\n\nIf a sensitive node is immediately adjacent to or diagonal from the revealed node, a number indicates how many of the surrounding nodes are sensitive. Seek patterns in the numbers that surround unrevealed nodes to determine which unrevealed nodes are sensitive.\n\nClick the Reset button to reset the field, or select a system to attempt a different intrusion method.");

    switch (games)
    {
    case HG_Lights:
        target_help->setText(lights_help);
        game = std::make_shared<LightsOut>(minigame_box, this, difficulty);
        break;
    case HG_Mine:
        target_help->setText(mine_help);
        game = std::make_shared<MineSweeper>(minigame_box, this, difficulty);
        break;
    default:
        if (irandom(0,1))
        {
            target_help->setText(lights_help);
            game = std::make_shared<LightsOut>(minigame_box, this, difficulty);
        }
        else
        {
            target_help->setText(mine_help);
            game = std::make_shared<MineSweeper>(minigame_box, this, difficulty);
        }
    }
    glm::vec2 board_size = game->getBoardSize();

    minigame_box->setSize(std::max(board_size.x + 100, 500.f), std::max(board_size.y + 150, 450.f));
    progress_bar
        ->setSize(50.0f, game->getBoardSize().y)
        ->setPosition(-25.0f, (minigame_box->getSize().y - board_size.y) * 0.5f, sp::Alignment::TopRight);
    target_selection_box->setPosition(minigame_box->getSize().x / 2 + 150, 0, sp::Alignment::Center);
}
