#ifndef MAIN_H
#define MAIN_H

#include "engine.h"

#ifndef VERSION_NUMBER
#define VERSION_NUMBER 0x0000
#endif

extern sf::Vector3f camera_position;
extern float camera_yaw;
extern float camera_pitch;
extern sf::Font* main_font;
extern sf::Font* bold_font;
extern RenderLayer* backgroundLayer;
extern RenderLayer* objectLayer;
extern RenderLayer* effectLayer;
extern RenderLayer* hudLayer;
extern RenderLayer* mouseLayer;
extern PostProcessor* glitchPostProcessor;
extern PostProcessor* warpPostProcessor;

void returnToMainMenu();
void returnToShipSelection();
void returnToOptionMenu();

#endif//MAIN_H
