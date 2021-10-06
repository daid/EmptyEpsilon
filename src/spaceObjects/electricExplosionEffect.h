#ifndef ELECTRIC_EXPLOSION_EFFECT_H
#define ELECTRIC_EXPLOSION_EFFECT_H

#include "spaceObject.h"
#include "glObjects.h"

class ElectricExplosionEffect : public SpaceObject, public Updatable
{
    constexpr static float maxLifetime = 4.0;
    constexpr static int particleCount = 1000;

    float lifetime;
    float size;
    glm::vec3 particleDirections[particleCount];
    bool on_radar;

    // Fit elements in a uint8 - at 4 vertices per quad, that's (256 / 4 =) 64 quads.
    static constexpr size_t max_quad_count = 64;
    static gl::Buffers<2> particlesBuffers;
public:
    ElectricExplosionEffect();
    virtual ~ElectricExplosionEffect();

    virtual void draw3DTransparent(const glm::mat4& object_view_matrix) override;
    virtual void drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool longRange) override;
    virtual void update(float delta) override;

    void setSize(float size) { this->size = size; }
    void setOnRadar(bool on_radar) { this->on_radar = on_radar; }
};

#endif//ELECTRIC_EXPLOSION_EFFECT_H
