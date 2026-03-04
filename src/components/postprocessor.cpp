#include "postprocessor.h"

string getPostProcessorType(PostProcessor::Type postprocessor)
{
    switch(postprocessor)
    {
        case PostProcessor::Type::Glitch: return "glitch";
        case PostProcessor::Type::Warp: return "warp";
        default:
            return "UNKNOWN";
    }
}
