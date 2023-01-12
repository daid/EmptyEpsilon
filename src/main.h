#ifndef MAIN_H
#define MAIN_H

#include <glm/vec3.hpp>
#include "graphics/font.h"
#include "Renderable.h"
#include "postProcessManager.h"
#include "config.h"

extern glm::vec3 camera_position;
extern float camera_yaw;
extern float camera_pitch;
extern sp::Font* main_font;
extern sp::Font* bold_font;
extern RenderLayer* mouseLayer;
extern PostProcessor* glitchPostProcessor;
extern PostProcessor* warpPostProcessor;
extern PVector<Window> windows;
extern std::vector<RenderLayer*> window_render_layers;

void returnToMainMenu(RenderLayer*);
void returnToShipSelection(RenderLayer*);
void returnToOptionMenu();

#endif//MAIN_H
