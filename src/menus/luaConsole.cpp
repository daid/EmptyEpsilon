#include "luaConsole.h"
#include "main.h"
#include "gameGlobalInfo.h"

#include "gui/gui2_overlay.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_textentry.h"
#include "gui/theme.h"


static LuaConsole* console;


LuaConsole::LuaConsole()
: GuiCanvas(consoleRenderLayer)
{
    console = this;

    top = new GuiOverlay(this, "", {0, 0, 0, 128});
    top->layout.fill_height = false;
    top->layout.size.y = 450;
    top->layout.margin.left = 50;
    top->layout.margin.right = 50;
    top->setAttribute("layout", "vertical");

    log = new GuiTextEntry(top, "", "");
    log->setAttribute("style", "luaconsole.log");
    log->setAttribute("stretch", "true");
    log->setMultiline(true);
    log->setTextSize(12);
    log->setAttribute("readonly", "true");
    entry = new GuiTextEntry(top, "", "");
    entry->setAttribute("style", "luaconsole.entry");
    entry->layout.fill_width = true;
    entry->layout.size.y = 20;
    entry->setTextSize(12);
    entry->enterCallback([this](string s) {
        if (gameGlobalInfo)
            gameGlobalInfo->execScriptCode(s);
    });
}

void LuaConsole::addLog(const string& message)
{
    if (!console) return;
    console->log_messages.push_back(message);
    if (console->log_messages.size() > 50)
        console->log_messages.erase(console->log_messages.begin());
    console->log->setText(string("\n").join(console->log_messages));
    console->log->setCursorPosition(console->log->getText().size());
}
