#ifndef HTTP_SCRIPT_ACCESS_H
#define HTTP_SCRIPT_ACCESS_H

#include "io/http/server.h"

class EEHttpServer
{
public:
    EEHttpServer(int port, string static_file_path);

private:
    sp::io::http::Server server;
};

#endif//HTTP_SCRIPT_ACCESS_H
