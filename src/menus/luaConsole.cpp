#include "luaConsole.h"
#include "main.h"
#include "gameGlobalInfo.h"

#include "gui/gui2_overlay.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_textentry.h"
#include "gui/theme.h"
#include "i18n.h"

#include "io/keybinding.h"


static LuaConsole* console;
sp::io::Keybinding open_console_key("CONSOLE_KEY", {"`"});


LuaConsole::LuaConsole()
: GuiCanvas(consoleRenderLayer)
{
    console = this;
    open_console_key.setLabel(tr("hotkey_menu", "General"), tr("hotkey_General", "Open LUA console"));

    top = new GuiOverlay(this, "", {0, 0, 0, 192});
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
        if (gameGlobalInfo) {
            LuaConsole::addLog("> " + s);
            gameGlobalInfo->execScriptCode(s);
            history.append(s);
            entry->setText("");
        }
    });
    entry->upCallback([this](string s) {
        string text = history.movePrevious(s);
        entry->setText(text);
        entry->setCursorPosition(text.size());
    });
    entry->downCallback([this](string s) {
        string text = history.moveNext(s);
        entry->setText(text);
        entry->setCursorPosition(text.size());
    });

    top->hide();
    entry->hide();
}

void LuaConsole::addLog(const string& message)
{
    if (!console) return;
    for(auto msg : message.split("\n"))
        console->log_messages.push_back(msg);
    while(console->log_messages.size() > 50)
        console->log_messages.erase(console->log_messages.begin());
    console->log->setText(string("\n").join(console->log_messages));
    console->log->setCursorPosition(console->log->getText().size());
    if (!console->is_open) {
        console->message_show_timers.emplace_back();
        console->message_show_timers.back().start(5.0f);
        console->top->layout.size.y = std::min(450.0f, 15.0f + console->message_show_timers.size() * 15.0f);
        console->top->show();
    }
}

void LuaConsole::update(float delta)
{
    if (open_console_key.getDown()) {
        if (is_open) {
            is_open = false;
            top->hide();
            entry->hide();
        } else {
            is_open = true;
            top->layout.size.y = 450;
            message_show_timers.clear();
            top->show();
            entry->show();
        }
    }
    while(!message_show_timers.empty() && message_show_timers.front().isExpired()) {
        message_show_timers.erase(message_show_timers.begin());
        if (message_show_timers.empty()) {
            top->hide();
        } else {
            top->layout.size.y = std::min(450.0f, 15.0f + message_show_timers.size() * 15.0f);
        }
    }
}

string ConsoleHistory::movePrevious(string s) {
    if (position == 0)
        // beginning of history, nothing to go up to. keep the line the same.
        return s;

    if (position == entries.size())
        // previous from a line not in history; set it pending so we can go back down to it later
        pending = s;
    else
        entries[position] = s;

    return entries[--position];
}

string ConsoleHistory::moveNext(string s) {
    if (position == entries.size())
        return s;

    if (position + 1 == entries.size())
    {
        // end of history, nothing to do down to.
        // if we had a pending entry, put it back
        position++;
        string wasPending = pending;
        pending = "";
        return wasPending;
    }

    entries[position] = s;
    return entries[++position];
}

void ConsoleHistory::append(string s)
{
    entries.push_back(s);
    position = entries.size();
    pending = "";
}
