#include "hackingDialog.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/spaceObject.h"
#include "spaceObjects/playerSpaceship.h"
#include "mineSweeper.h"
#include "lightsOut.h"
#include <memory>

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
    minigame_box  = new MiniGame(this, id + "_GAME_BOX", 2);
    minigame_box->setPosition(0, 0, ACenter);

    target_selection_box = new GuiPanel(this, id + "_BOX");
    target_selection_box->setSize(300, 545)->setPosition(400, 0, ACenter);

    GuiLabel* target_selection_label = new GuiLabel(target_selection_box, "", "Target system:", 25);
    target_selection_label->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 15);

    target_list = new GuiListbox(target_selection_box, "", [this](int index, string value)
    {
        target_system = value;
        getNewGame();
    });
    target_list->setPosition(25, 75, ATopLeft);
    target_list->setSize(250, 445);
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
    }else{
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
    if (minigame_box->isGameComplete())
    {
        if (reset_time - engine->getElapsedTime() < 0.0)
        {
            if (my_spaceship)
            {
                my_spaceship->commandHackingFinished(target, target_system);
            }
            getNewGame();
        }else{
            minigame_box->setProgress((reset_time - engine->getElapsedTime()) / auto_reset_time);
        }
    }
    if (target_system != "")
    {
        std::vector<std::pair<string, float> > targets = target->getHackingTargets();
        for(std::pair<string, float>& target : targets)
        {
            if (target.first == target_system)
            {
                minigame_box->setHackingStatusText("Hacked " + target_system + ": " + string(int(target.second * 100.0f + 0.5f)) + "%");
                break;
            }
        }
    }
}

bool GuiHackingDialog::onMouseDown(sf::Vector2f position)
{
    return true;
}

void GuiHackingDialog::miniGameComplete()
{
    reset_time = engine->getElapsedTime() + auto_reset_time;
    minigame_box->disable();
}

void GuiHackingDialog::getNewGame(bool sameType) {
    //if we want a game of the same type and the game is already defined, just reset it.
    if (sameType && minigame_box) {
      minigame_box->reset();
      return;
    }
    minigame_box->destroy();
    string game_id = id + "_BOX";
    int difficulty = 2;
    EHackingGames games = HG_All;
    if (gameGlobalInfo) {
      difficulty = gameGlobalInfo->hacking_difficulty+1;
      games = gameGlobalInfo->hacking_games;
    }

    switch (games)
    {
    case HG_Lights:
      minigame_box = new LightsOut(this, game_id, difficulty * 2 + 1);
      break;
    case HG_Mine:
      minigame_box = new MineSweeper(this, game_id, difficulty * 2 + 4);
      break;
    default:
      irandom(0,1) ? minigame_box = new LightsOut(this, game_id, difficulty * 2 + 1) : minigame_box = new MineSweeper(this, game_id, difficulty * 2 + 4);
    }
    minigame_box->setPosition(0, 0, ACenter);

}
