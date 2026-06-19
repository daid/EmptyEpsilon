#include "postprocessor.h"

string getPostProcessorType(PostProcessorComponent::Type postprocessor)
{
    switch(postprocessor)
    {
        case PostProcessorComponent::Type::Glitch: return "glitch";
        case PostProcessorComponent::Type::Warp: return "warp";
        default:
            return "UNKNOWN";
    }
}
