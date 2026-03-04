#pragma once

// Base class for Postproccessor components, never created directtly

class PostProcessorComponent
{
public:
    enum class Type
    {
        Glitch,
        Warp
    };
    float effect_strength = 1.0f; // postprocessor effect strength at min_radius
    float min_radius = 0.0f;
    float max_radius = 5000.0f;
};

string getPostProcessorType(PostProcessorComponent::Type postprocessor);


class GlitchPostProcessor: public PostProcessorComponent{
public:
    //Config

};

class WarpPostProcessor: public PostProcessorComponent{
public:
    // Config
};
