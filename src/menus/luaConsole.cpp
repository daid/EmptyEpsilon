#include "luaConsole.h"
#include "main.h"
#include "gameGlobalInfo.h"

#include "gui/gui2_overlay.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_textentry.h"
#include "gui/theme.h"

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
        P<ScriptObject> script = engine->getObject("scenario");
        if (script)
            script->runCode(s);
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
    P<ScriptObject> script = engine->getObject("scenario");
    if (script) {
        if (last_error != script->getError()) {
            last_error = script->getError();
            if (!last_error.empty())
                addLog(last_error);
        }
    }
    if (!ScriptSimpleCallback::last_error.empty()) {
        addLog(ScriptSimpleCallback::last_error);
        ScriptSimpleCallback::last_error.clear();
    }

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
