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
    float min_effect_strength = 0.0f; //postprocessor effect strength at max_radius
    float max_effect_strength = 1.0f; // postprocessor effect strength at min_radius
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
