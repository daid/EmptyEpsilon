#include <memory>
#include <time.h>

// SeriousProton provides nlohmann/json.
// nlohmann::detail::to_chars implements a Grisu2 double-to-char method for
// fast float-to-string conversions designed for JSON output, with a
// std::to_chars-like implementation.
#include "nlohmann/json.hpp"

#include "gameStateLogger.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/spaceObject.h"
#include "spaceObjects/spaceship.h"
#include "spaceObjects/planet.h"

class JSONGenerator
{
public:
    JSONGenerator(char*& ptr)
    : ptr(ptr), first(true)
    {
        *ptr++ = '{';
    }

    ~JSONGenerator()
    {
        *ptr++ = '}';
    }

    template<typename T> void write(const char* key, const T& value)
    {
        if (!first)
            *ptr++ = ',';
        *ptr++ = '"';
        while(*key)
            *ptr++ = *key++;
        *ptr++ = '"';
        *ptr++ = ':';
        first = false;
        writeValue(value);
    }
    JSONGenerator createDict(const char* key)
    {
        if (!first)
            *ptr++ = ',';
        *ptr++ = '"';
        while(*key)
            *ptr++ = *key++;
        *ptr++ = '"';
        *ptr++ = ':';
        first = false;
        return JSONGenerator(ptr);
    }
    void startArray(const char* key)
    {
        if (!first)
            *ptr++ = ',';
        *ptr++ = '"';
        while(*key)
            *ptr++ = *key++;
        *ptr++ = '"';
        *ptr++ = ':';
        *ptr++ = '[';
        first = false;
        array_first = true;
    }
    JSONGenerator arrayCreateDict()
    {
        if (!array_first)
            *ptr++ = ',';
        array_first = false;
        return JSONGenerator(ptr);
    }
    template<typename T> void arrayWrite(const T& value)
    {
        if (!array_first)
            *ptr++ = ',';
        array_first = false;
        writeValue(value);
    }
    void endArray()
    {
        *ptr++ = ']';
        first = false;
        array_first = true;
    }
private:
    void writeValue(bool b)
    {
        const char* c = "false";
        if (b) c = "true";
        while(*c)
            *ptr++ = *c++;
    }
    // TODO: Replace int/float writers with std::to_chars, when/if Apple Clang
    // ever reliably supports both.
    void writeValue(int i) { ptr += sprintf(ptr, "%d", i); }
    void writeValue(float _f) {
        char buf[24] = {}; // arbitrary

        // nlohmann::detail::to_chars returns end-of-chars. Unlike
        // std::to_chars, we have to explicitly reserve the terminator.
        const auto last = nlohmann::detail::to_chars(buf, buf + 23, _f);
        *last = '\0';

        char* b = buf;
        while(*b)
            *ptr++ = *b++;
    }
    void writeValue(const char* value)
    { /*ptr += sprintf(ptr, "\"%s\"", value);*/
        *ptr++ = '"';
        while(*value)
            *ptr++ = *value++;
        *ptr++ = '"';
    }
    void writeValue(const string& value)
    {
        const char* str = value.c_str();
        *ptr++ = '"';
        while(*str)
            *ptr++ = *str++;
        *ptr++ = '"';
    }

    char*& ptr;
    bool first, array_first;
};

GameStateLogger::GameStateLogger()
{
    log_file = nullptr;
    logging_interval = 1.0;
    logging_delay = 0.0;
}

GameStateLogger::~GameStateLogger()
{
    stop();
}

void GameStateLogger::start()
{
    time_t rawtime;
    char filename_buffer[128];

    rawtime = time(nullptr);
    strftime(filename_buffer, sizeof(filename_buffer), "logs/game_log_%d-%m-%Y_%H.%M.%S.txt", localtime(&rawtime));
    log_file = fopen(filename_buffer, "wt");
    if (log_file)
        LOG(INFO) << "Opened game state log: " << filename_buffer;
    else
        LOG(WARNING) << "Failed to open game state log file: " << filename_buffer;
    start_time = engine->getElapsedTime();
}

void GameStateLogger::stop()
{
    if (log_file)
    {
        fclose(log_file);
        log_file = nullptr;
    }
}

void GameStateLogger::update(float delta)
{
    if (!log_file || delta == 0.0f)
        return;

    logging_delay -= delta;
    if (logging_delay > 0.0f)
        return;
    logging_delay = logging_interval;

    logGameState();
}

/* Write the state log entry. All entries are in json format.
   The state entry looke like:
    {
        "type": "state",
        "time": game time passed since start of logging,
        "new_static": [ list of object entries that are not likely to change, and only send once ],
        "objects": [ list of updated objects, this can include objects that have been created by new_static before ],
        "del_static": [ list of ids that have been added with "new_static" in a previous entry, but have been destroyed now ]
    }
*/
void GameStateLogger::logGameState()
{
}
