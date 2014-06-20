#ifndef GUI_H
#define GUI_H

#include "engine.h"

enum EAlign
{
    AlignLeft,
    AlignRight,
    AlignCenter
};

class GUI: public Renderable
{
    static sf::RenderTarget* renderTarget;
    static sf::Vector2f mousePosition;
    static int mouseClick;
    static int mouseDown;
    bool init;
public:
    GUI();
    
    virtual void render(sf::RenderTarget& window);
    
    virtual void onGui() = 0;

    static void text(sf::FloatRect rect, string text, EAlign align = AlignLeft, float textSize = 30, sf::Color color=sf::Color::White);
    static bool button(sf::FloatRect rect, string text, float textSize = 30);
    static bool toggleButton(sf::FloatRect rect, bool active, string textValue, float fontSize = 30);
    static float vslider(sf::FloatRect rect, float value, float minValue, float maxValue);
    static sf::RenderTarget* getRenderTarget() { return renderTarget; }

private:
    static void draw9Cut(sf::FloatRect rect, string texture, sf::Color color=sf::Color::White);
};

class MouseRenderer : public Renderable
{
public:
    bool visible;
    
    MouseRenderer();
    
    virtual void render(sf::RenderTarget& window);
};

#endif//GUI_H
