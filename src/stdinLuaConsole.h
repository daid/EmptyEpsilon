#pragma once

#include "Updatable.h"
#include "stringImproved.h"


class StdinLuaConsole : public Updatable
{
public:
    StdinLuaConsole();
    void update(float delta) override;

private:
    void addInput(char c);
    void executeCommand(const string& cmd);
    void printPrompt();

    string buffer;
    std::vector<string> history;
};
