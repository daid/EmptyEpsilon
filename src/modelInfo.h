#ifndef MODEL_INFO_H
#define MODEL_INFO_H

#include "modelData.h"

class ModelInfo : sf::NonCopyable
{
private:
    P<ModelData> data;
    float last_engine_particle_time;
    float last_warp_particle_time;
public:
    ModelInfo();
    
    float engine_scale;
    float warp_scale;

    void render(sf::Vector2f position, float rotation);
    void renderOverlay(sf::Texture* texture, float alpha);
    void renderShield(float alpha);
    void renderFrontShield(float alpha);
    void renderRearShield(float alpha);
    
    void setData(P<ModelData> data) { this->data = data; }
    void setData(string name);
};

#endif//MODEL_INFO_H
