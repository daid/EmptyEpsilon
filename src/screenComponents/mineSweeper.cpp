#include "random.h"
#include "mineSweeper.h"
#include "miniGame.h"
#include "hackingDialog.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_label.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_panel.h"

static constexpr int MAX_FAILURES = 2;

MineSweeper::MineSweeper(GuiPanel* owner, GuiHackingDialog* parent, int difficulty)
: MiniGame(owner, parent, difficulty)
{
    field_size = difficulty * 2 + 6;
    bomb_count = difficulty * 2 + 6;

    // Create failures remaining label
    failures_label = new GuiLabel(owner, "MINESWEEPER_FAILURES", "", 25.0f);
    failures_label
        ->setPosition(0.0f, -30.0f, sp::Alignment::BottomCenter)
        ->setSize(100.0f, 30.0f);

    for(int x=0; x<field_size; x++)
    {
        for(int y=0; y<field_size; y++)
        {
            FieldItem* item = new FieldItem(
                owner, "", "",
                [this, x, y](bool value) {
                    onFieldClick(x, y);
                },
                [this, x, y](bool value) {
                    onFieldRightClick(x, y);
                }
            );

            item
                ->setSize(50, 50)
                ->setPosition(x * 50 - field_size * 25, 25 + y * 50 - field_size * 25, sp::Alignment::Center);
            board.emplace_back(item);
        }
    }
    reset();
}

void MineSweeper::disable()
{
    MiniGame::disable();
    for(int x=0; x < field_size; x++)
    {
        for(int y=0; y < field_size; y++)
        {
            FieldItem* item = getFieldItem(x, y);
            item
                ->setValue(false)
                ->setText("")
                ->disable();
        }
    }
}

void MineSweeper::reset()
{
    MiniGame::reset();
    for(int x=0; x < field_size; x++)
    {
        for(int y=0; y < field_size; y++)
        {
            FieldItem* item = getFieldItem(x, y);
            item
                ->setValue(false)
                ->setText("")
                ->enable();
            item->bomb = false;
        }
    }
    for(int n=0; n < bomb_count; n++)
    {
        int x = irandom(0, field_size - 1);
        int y = irandom(0, field_size - 1);

        if (getFieldItem(x, y)->bomb)
        {
            n--;
            continue;
        }
        getFieldItem(x, y)->bomb = true;
    }
    error_count = 0;
    correct_count = 0;
    updateFailuresLabel();
}

float MineSweeper::getProgress()
{
    return (float)correct_count / (float)(field_size * field_size - bomb_count);
}

void MineSweeper::gameComplete()
{
    bool success = correct_count == (field_size * field_size) - bomb_count;
    parent->onMiniGameComplete(success);
    game_complete = true;
}

glm::vec2 MineSweeper::getBoardSize()
{
    return glm::vec2(field_size*50, field_size*50);
}

void MineSweeper::onFieldClick(int x, int y)
{
    FieldItem* item = getFieldItem(x, y);

    if (item->getValue() || item->getText() == "X" || item->getText() == "F" || error_count > 1 || correct_count == (field_size * field_size - bomb_count))
    {
        //Unpressing an already pressed button, or flagged tile, or game over.
        return;
    }

    item->setValue(true);

    if (item->bomb)
    {
        item
            ->setValue(false)
            ->setText("X");
        error_count++;
        updateFailuresLabel();
    }
    else
    {
        correct_count++;
        int proximity = 0;
        if (x > 0 && y > 0 && getFieldItem(x - 1, y - 1)->bomb) proximity++;
        if (x > 0 && getFieldItem(x - 1, y)->bomb) proximity++;
        if (x > 0 && y < field_size - 1 && getFieldItem(x - 1, y + 1)->bomb) proximity++;

        if (y > 0 && getFieldItem(x, y - 1)->bomb) proximity++;
        if (y < field_size - 1 && getFieldItem(x, y + 1)->bomb) proximity++;

        if (x < field_size - 1 && y > 0 && getFieldItem(x + 1, y - 1)->bomb) proximity++;
        if (x < field_size - 1 && getFieldItem(x + 1, y)->bomb) proximity++;
        if (x < field_size - 1 && y < field_size - 1 && getFieldItem(x + 1, y + 1)->bomb) proximity++;

        if (proximity < 1)
            item->setText("");
        else
            item->setText(string(proximity));

        if (proximity < 1)
        {
            //if no bombs found in proximity, auto click on all surrounding tiles
            if (x > 0 && y > 0) onFieldClick(x - 1, y - 1);
            if (x > 0) onFieldClick(x - 1, y);
            if (x > 0 && y < field_size - 1) onFieldClick(x - 1, y + 1);

            if (y > 0) onFieldClick(x, y - 1);
            if (y < field_size - 1) onFieldClick(x, y + 1);

            if (x < field_size - 1 && y > 0) onFieldClick(x + 1, y - 1);
            if (x < field_size - 1) onFieldClick(x + 1, y);
            if (x < field_size - 1 && y < field_size - 1) onFieldClick(x + 1, y + 1);
        }
    }

    if (error_count > 1 || correct_count == (field_size * field_size - bomb_count))
    {
        gameComplete();
    }
}

void MineSweeper::onFieldRightClick(int x, int y)
{
    FieldItem* item = getFieldItem(x, y);

    // Don't allow flagging already revealed tiles
    if (item->getValue()) return;

    // Don't allow flagging after game is over
    if (error_count > 1 || correct_count == (field_size * field_size - bomb_count)) return;

    // Toggle flag
    if (item->getIcon() == "waypoint.png") item->setIcon("");
    else item->setIcon("waypoint.png", sp::Alignment::Center);
}

void MineSweeper::updateFailuresLabel()
{
    int failures_remaining = MAX_FAILURES - error_count;
    failures_label->setText("Failures: " + string(failures_remaining) + "/" + string(MAX_FAILURES));
}

MineSweeper::FieldItem* MineSweeper::getFieldItem(int x, int y)
{
    return dynamic_cast<MineSweeper::FieldItem*>(board[x * field_size + y]);
}

MineSweeper::FieldItem::FieldItem(GuiContainer* owner, string id, string text, func_t left_func, func_t right_func)
: GuiToggleButton(owner, id, text, nullptr), bomb(false), left_click_func(left_func), right_click_func(right_func), last_button(sp::io::Pointer::Button::Unknown)
{
}

bool MineSweeper::FieldItem::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    last_button = button;
    return true;
}

void MineSweeper::FieldItem::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (!rect.contains(position)) return;

    if (last_button == sp::io::Pointer::Button::Left && left_click_func)
    {
        func_t f = left_click_func;
        f(getValue());
    }
    else if (last_button == sp::io::Pointer::Button::Right && right_click_func)
    {
        func_t f = right_click_func;
        f(getValue());
    }
}
