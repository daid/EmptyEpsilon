#pragma once

#include <loguru.hpp>

namespace loglevel {
    enum Verbosity : loguru::Verbosity
    {
        Error = -2,
        Warning,
        Info,
        Debug,
        Trace
    };
}
