#include "miniGame.h"

#include "gui/gui2_label.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_panel.h"

MiniGame::MiniGame(GuiPanel* owner, GuiHackingDialog* parent, int difficulty)
:  difficulty(difficulty), parent(parent), game_complete(false) {
}

MiniGame::~MiniGame()
{
    for(auto it = board.begin(); it != board.end(); )
    {
        GuiElement* element = *it;

        it = board.erase(it);

        element->destroy();

    }
}

void MiniGame::reset()
{
    game_complete = false;
}

void MiniGame::disable()
{
}


float MiniGame::getProgress()
{
    return 0;
}

void MiniGame::gameComplete()
{
    parent->onMiniGameComplete(getProgress() > 0.5);

    game_complete = true;
}

bool MiniGame::isGameComplete()
{
    return game_complete;
}

sf::Vector2f MiniGame::getBoardSize()
{
    return sf::Vector2f(500,500);
}
