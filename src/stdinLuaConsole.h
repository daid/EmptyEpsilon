#pragma once

#include "Updatable.h"
#include "stringImproved.h"


class StdinLuaConsole : public Updatable {
public:
    void update(float delta) override;

private:
    void addInput(char c);

    string buffer;
};