#include "miniGame.h"

#include "gui/gui2_label.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_progressbar.h"
#include "hackingDialog.h"

MiniGame::MiniGame(GuiHackingDialog* owner, string id, int difficulty)
: GuiPanel(owner, id), difficulty(difficulty), parent(owner) {
  status_label = new GuiLabel(this, "", "...", 25);
  status_label->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 30);

  hacking_status_label = new GuiLabel(this, "", "", 25);
  hacking_status_label->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 0);

  reset_button = new GuiButton(this, "", "Reset", [this]()
  {
      reset();
  });
  reset_button->setSize(200, 50);
  //TODO Set Position

  GuiButton* close_button = new GuiButton(this, "", "Close", [this]()
  {
      parent->hide();
  });
  close_button->setSize(200, 50);
  close_button->setPosition(-25, 75 + difficulty * 50, ATopRight);
  progress_bar = new GuiProgressbar(this, "", 0, 1, 0.0);
  progress_bar->setPosition(-25, 75, ATopRight);
  progress_bar->setSize(50, difficulty * 50);
}

void MiniGame::disable()
{
  status_label->setText("Select hacking target...");
  reset_button->disable();
}

bool MiniGame::onMouseDown(sf::Vector2f position)
{
    return true;
}

void MiniGame::setProgress(float progress)
{
  progress_bar->setValue(progress);
}

void MiniGame::setHackingStatusText(string text)
{
  hacking_status_label->setText(text);
}

void MiniGame::gameComplete()
{
    parent->miniGameComplete(this);
    status_label->setText("Hacking SUCCESS");
    progress_bar->setValue(1.0f);
    game_complete = true;
}

bool MiniGame::isGameComplete()
{
  return game_complete;
}