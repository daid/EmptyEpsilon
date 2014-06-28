#ifndef MAIN_H
#define MAIN_H

#include "engine.h"

#define VERSION_NUMBER 0x0000

extern sf::Shader object_shader;
extern sf::Font main_font;
extern RenderLayer* background_layer;
extern RenderLayer* object_layer;
extern RenderLayer* effect_layer;
extern RenderLayer* hud_layer;
extern RenderLayer* mouse_layer;

#endif//MAIN_H
