#include "stdinLuaConsole.h"
#include "gameGlobalInfo.h"
#ifdef _WIN32
#include <windows.h>
#elif !defined(ANDROID)
#include <sys/select.h>
#include <unistd.h>
#endif
#include <unordered_set>

StdinLuaConsole::StdinLuaConsole()
{
}

void StdinLuaConsole::update(float delta)
{
#ifdef _WIN32
    auto handle = GetStdHandle(STD_INPUT_HANDLE);
    while(1) {
        DWORD count = 0;
        GetNumberOfConsoleInputEvents(handle, &count);
        if (!count)
            return;
        INPUT_RECORD input_record;
        ReadConsoleInput(handle, &input_record, 1, &count);
        if (input_record.EventType == KEY_EVENT && input_record.Event.KeyEvent.bKeyDown) {
            if (input_record.Event.KeyEvent.uChar.AsciiChar) {
                printf("%c", input_record.Event.KeyEvent.uChar.AsciiChar);
                addInput(input_record.Event.KeyEvent.uChar.AsciiChar);
            }
        }
    }
#elif !defined(ANDROID)
    struct timeval tv;
    fd_set fds;
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    FD_ZERO(&fds);
    FD_SET(STDIN_FILENO, &fds);
    select(STDIN_FILENO+1, &fds, NULL, NULL, &tv);
    if (FD_ISSET(0, &fds))
    {
        char buffer[128];
        int amount = read(0, buffer, sizeof(buffer));
        for (int n=0; n<amount; n++)
            addInput(buffer[n]);
    }
#endif
}

void StdinLuaConsole::addInput(char c)
{
    if (c == '\r' || c == '\n')
    {
        executeCommand(buffer);
        buffer.clear();
    }
    else if (c == 8 || c == 127)
    {
        if (!buffer.empty()) buffer.pop_back();
    }
    else if (c >= 32)
        buffer.push_back(c);
}

void StdinLuaConsole::executeCommand(const string& cmd)
{
    if (cmd.empty())
    {
        printPrompt();
        return;
    }

    // !help: Print command help
    if (cmd == "!help")
    {
        printf("\n!help         Print this help\n");
        printf("!globals      Print names of all global values and functions\n");
        printf("!history      Print Lua command history\n");
        printf("!<N>          Run a Lua command by its number (<N>) in the history list\n");
        printf("!!            Run the most recent Lua command in the history list\n");
        printf("!save <FILE>  Write Lua command history to <FILE>\n");
        printf("!clear        Clear Lua command history\n\n");
        printPrompt();
        return;
    }

    // !history: Print Lua command history
    if (cmd == "!history")
    {
        for (size_t i = 0; i < history.size(); i++)
            printf("%3zu  %s\n", i + 1, history[i].c_str());

        printPrompt();
        return;
    }

    // !save: Write Lua command history to file
    if (cmd.size() > 6 && cmd.substr(0, 6) == "!save ")
    {
        string filename = cmd.substr(6);
        FILE* f = fopen(filename.c_str(), "w");
        if (!f)
        {
            printf("Can't write to %s\n", filename.c_str());
            printPrompt();
            return;
        }

        for (const auto& line : history)
            fprintf(f, "%s\n", line.c_str());

        fclose(f);
        printf("History written to %s\n", filename.c_str());
        printPrompt();
        return;
    }

    // !clear: Clear Lua command history
    if (cmd == "!clear")
    {
        history.clear();
        printf("History cleared.\n");
        printPrompt();
        return;
    }

    // !globals: Print names of all global values and functions
    if (cmd == "!globals" && gameGlobalInfo)
    {
        if (gameGlobalInfo->main_scenario_script)
        {
            if (lua_State* L = sp::script::Environment::getL())
            {
                std::vector<string> names;
                std::unordered_set<string> seen;

                auto scanEnv = [&](sp::script::Environment* env)
                {
                    if (!env) return;

                    lua_rawgetp(L, LUA_REGISTRYINDEX, env);
                    lua_pushnil(L);

                    while (lua_next(L, -2))
                    {
                        if (lua_type(L, -2) == LUA_TSTRING)
                        {
                            string key = lua_tostring(L, -2);
                            if (!seen.count(key))
                            {
                                seen.insert(key);
                                names.push_back(key);
                            }
                        }
                        lua_pop(L, 1);
                    }
                    lua_pop(L, 1);  // pop env table
                };

                // Enumerate E_main first (scenario globals shadow base globals of the same name)
                scanEnv(gameGlobalInfo->main_scenario_script.get());
                // Then E_base (C++ globals)
                scanEnv(gameGlobalInfo->script_environment_base.get());

                std::sort(names.begin(), names.end());
                for (auto name : names)
                    printf("%s\n", name.c_str());
            }
        }

        printPrompt();
        return;
    }

    // !N: Re-execute history entry N (all chars after ! must be digits)
    if (cmd.size() > 1 && cmd[0] == '!'
        && std::all_of(cmd.begin() + 1, cmd.end(), ::isdigit))
    {
        int n = std::stoi(cmd.substr(1));
        if (n < 1 || n > static_cast<int>(history.size()))
        {
            LOG(Error, "Event ", n, " not found");
            printPrompt();
            return;
        }

        const string recalled = history[static_cast<size_t>(n) - 1];

        // Echo and run the recalled command.
        printf("%s\n", recalled.c_str());
        executeCommand(recalled);
        return;
    }

    // !!: Re-execute the most recent history entry
    if (cmd == "!!" && history.size() > 0)
    {
        const string recalled = history[history.size() - 1];

        // Echo and run the recalled command.
        printf("%s\n", recalled.c_str());
        executeCommand(recalled);
        return;
    }

    history.push_back(cmd);

    if (gameGlobalInfo) gameGlobalInfo->execScriptCode(cmd);
    printPrompt();
}

void StdinLuaConsole::printPrompt()
{
    printf("EE> ");
    fflush(stdout);
}
