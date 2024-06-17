#include "random.h"
#include "hackingDialog.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/spaceObject.h"
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

GuiHackingDialog::GuiHackingDialog(GuiContainer* owner, string id)
: GuiOverlay(owner, id, glm::u8vec4(0,0,0,64))
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    hide();
    //dummy game panel until we choose a system
    minigame_box = new GuiPanel(this, id + "_GAME_BOX");

    minigame_box->setPosition(0, 0, sp::Alignment::Center);
    game = std::make_shared<MiniGame>(minigame_box, this, 2);
    auto board_size = game->getBoardSize();
    minigame_box->setSize(board_size.x + 100, board_size.y + 150);
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

    target_selection_box = new GuiPanel(this, id + "_BOX");
    target_selection_box->setSize(300, 545)->setPosition(board_size.x / 2 + 200, 0, sp::Alignment::Center);

    GuiLabel* target_selection_label = new GuiLabel(target_selection_box, "", tr("hacking", "Target system:"), 25);
    target_selection_label->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 15);

    target_list = new GuiListbox(target_selection_box, "", [this](int index, string value)
    {
        target_system = ShipSystem::Type(value.toInt());
        getNewGame();
    });
    target_list->setPosition(25, 75, sp::Alignment::TopLeft);
    target_list->setSize(250, 445);

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

    switch (games)
    {
    case HG_Lights:
      game = std::make_shared<LightsOut>(minigame_box, this, difficulty);
      break;
    case HG_Mine:
      game = std::make_shared<MineSweeper>(minigame_box, this, difficulty);
      break;
    default:
      irandom(0,1) ? game = std::make_shared<LightsOut>(minigame_box, this, difficulty) : game = std::make_shared<MineSweeper>(minigame_box, this, difficulty);
    }
    glm::vec2 board_size = game->getBoardSize();

    minigame_box->setSize(std::max(board_size.x + 100, 500.f), std::max(board_size.y + 150, 450.f));
    progress_bar->setSize(50, game->getBoardSize().y);
    progress_bar->setPosition(-25, (minigame_box->getSize().y - board_size.y)/2, sp::Alignment::TopRight);

    target_selection_box->setPosition(minigame_box->getSize().x / 2 + 150, 0, sp::Alignment::Center);
}
