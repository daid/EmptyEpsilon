#ifndef MAIN_H
#define MAIN_H

#include "engine.h"

#define VERSION_NUMBER 0x0000

extern sf::Shader objectShader;
extern sf::Shader basicShader;
extern sf::Font mainFont;
extern RenderLayer* backgroundLayer;
extern RenderLayer* objectLayer;
extern RenderLayer* effectLayer;
extern RenderLayer* hudLayer;
extern RenderLayer* mouseLayer;

#endif//MAIN_H
