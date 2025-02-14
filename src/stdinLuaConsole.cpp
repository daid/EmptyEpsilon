#include "stdinLuaConsole.h"
#include "gameGlobalInfo.h"
#ifdef _WIN32
#include <windows.h>
#elif !defined(ANDROID)
#include <sys/select.h>
#include <unistd.h>
#endif



void StdinLuaConsole::update(float delta) {
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
    if (FD_ISSET(0, &fds)) {
        char buffer[128];
        int amount = read(0, buffer, sizeof(buffer));
        for(int n=0; n<amount; n++) {
            addInput(buffer[n]);
        }
    }
#endif
}

void StdinLuaConsole::addInput(char c) {
    if (c == '\r' || c == '\n') {
        printf("%s\n", buffer.c_str());
        if (gameGlobalInfo)
            gameGlobalInfo->execScriptCode(buffer);
        buffer.clear();
    } else if (c == 8) {
        if (!buffer.empty()) buffer.pop_back();
        printf(" \x08");
    } else if (c < 32) {
        printf("??: %02x\n", c);
    } else {
        buffer.push_back(c);
    }
}
