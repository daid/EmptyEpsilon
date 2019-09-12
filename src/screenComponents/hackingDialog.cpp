#include "hackingDialog.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/spaceObject.h"
#include "spaceObjects/playerSpaceship.h"
#include "mineSweeper.h"
#include "lightsOut.h"
#include "miniGame.h"
#include <memory>
#include <algorithm>

#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_progressbar.h"

GuiHackingDialog::GuiHackingDialog(GuiContainer* owner, string id)
: GuiOverlay(owner, id, sf::Color(0,0,0,64))
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    hide();
    //dummy game panel until we choose a system
    minigame_box  = new GuiPanel(this, id + "_GAME_BOX");

    minigame_box->setPosition(0, 0, ACenter);
    game = new MiniGame(minigame_box, this, 2);
    sf::Vector2f board_size = game->getBoardSize();
    minigame_box->setSize(board_size.x + 50, board_size.y + 150);

    status_label = new GuiLabel(minigame_box, "", "...", 25);
    status_label->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 30);

    hacking_status_label = new GuiLabel(minigame_box, "", "", 25);
    hacking_status_label->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 0);
    reset_button = new GuiButton(minigame_box, "", "Reset", [this]()
    {
        game->reset();
    });
    reset_button->setSize(200, 50);
    reset_button->setPosition(25, -25, ABottomLeft);
    close_button = new GuiButton(minigame_box, "", "Close", [this]()
    {
        hide();
    });
    close_button->setSize(200, 50);
    close_button->setPosition(-25, -25, ABottomRight);

    progress_bar = new GuiProgressbar(minigame_box, "", 0, 1, 0.0);
    progress_bar->setPosition(-25, 100, ATopRight);
    progress_bar->setSize(50, game->getBoardSize().y);


    target_selection_box = new GuiPanel(this, id + "_BOX");
    target_selection_box->setSize(300, 545)->setPosition(board_size.x / 2 + 200, 0, ACenter);

    GuiLabel* target_selection_label = new GuiLabel(target_selection_box, "", "Target system:", 25);
    target_selection_label->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 15);

    target_list = new GuiListbox(target_selection_box, "", [this](int index, string value)
    {
        target_system = value;
        getNewGame();
    });
    target_list->setPosition(25, 75, ATopLeft);
    target_list->setSize(250, 445);

    last_game_success = false;
}

void GuiHackingDialog::open(P<SpaceObject> target)
{
    this->target = target;
    show();
    while(target_list->entryCount() > 0)
        target_list->removeEntry(0);
    std::vector<std::pair<string, float> > targets = target->getHackingTargets();
    for(std::pair<string, float>& target : targets)
    {
        target_list->addEntry(target.first, target.first);
    }
    if (targets.size() == 1)
    {
        target_selection_box->hide();
        target_system = targets[0].first;
        getNewGame();
    } else
    {
        target_selection_box->show();
        minigame_box->disable();
    }
}

void GuiHackingDialog::onDraw(sf::RenderTarget& window)
{
    if (!target)
    {
        hide();
        return;
    }
    GuiOverlay::onDraw(window);
    if (game->isGameComplete())
    {
        if (reset_time - engine->getElapsedTime() < 0.0)
        {
            if (my_spaceship && last_game_success)
            {
                my_spaceship->commandHackingFinished(target, target_system);
            }
            getNewGame();
        }else{
            progress_bar->setValue((reset_time - engine->getElapsedTime()) / auto_reset_time);
        }
    } else {
        progress_bar->setValue(game->getProgress());
        status_label->setText("Hacking in Progress: " + string( int(100 * game->getProgress()))+ "%");
    }
    if (target_system != "")
    {
        std::vector<std::pair<string, float> > targets = target->getHackingTargets();
        for(std::pair<string, float>& target : targets)
        {
            if (target.first == target_system)
            {
                hacking_status_label->setText("Hacked " + target_system + ": " + string(int(target.second * 100.0f + 0.5f)) + "%");
                break;
            }
        }
    }
}

bool GuiHackingDialog::onMouseDown(sf::Vector2f position)
{
    return true;
}

void GuiHackingDialog::miniGameComplete(bool success)
{
    reset_time = engine->getElapsedTime() + auto_reset_time;
    minigame_box->disable();
    last_game_success = success;
    status_label->setText("Hacking " + success ? "SUCCESS!" : "FAILURE!");
}

void GuiHackingDialog::getNewGame(bool sameType) {
    //if we want a game of the same type and the game is already defined, just reset it.
    if (sameType) {
      game->reset();
      return;
    }
    delete game;
    int difficulty = 2;
    EHackingGames games = HG_All;
    if (gameGlobalInfo) {
      difficulty = gameGlobalInfo->hacking_difficulty+1;
      games = gameGlobalInfo->hacking_games;
    }

    switch (games)
    {
    case HG_Lights:
      game = new LightsOut(minigame_box, this, difficulty * 2 + 1);
      break;
    case HG_Mine:
      game = new MineSweeper(minigame_box, this, difficulty * 2 + 4);
      break;
    default:
      irandom(0,1) ? game = new LightsOut(minigame_box, this, difficulty * 2 + 1) : game = new MineSweeper(minigame_box, this, difficulty * 2 + 4);
    }
    sf::Vector2f board_size = game->getBoardSize();

    minigame_box->setSize(std::max(board_size.x + 100, 500.f), std::max(board_size.y + 150, 450.f));
    progress_bar->setSize(50, game->getBoardSize().y);
    progress_bar->setPosition(-25, 50 + (minigame_box->getSize().y - board_size.y)/2, ATopRight);

    target_selection_box->setPosition(minigame_box->getSize().x / 2 + 150, 0, ACenter);


}
