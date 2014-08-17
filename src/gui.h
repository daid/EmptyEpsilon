#ifndef GUI_H
#define GUI_H

#include "engine.h"

enum EAlign
{
    AlignLeft,
    AlignRight,
    AlignCenter,
    AlignTopLeft,
    AlignTopRight,
    AlignTopCenter
};

class GUI: public Renderable
{
    static sf::RenderTarget* renderTarget;
    static sf::Vector2f mousePosition;
    static sf::Vector2f windowSize;
    static int mouseClick;
    static int mouseDown;
    bool init;
public:
    GUI();
    
    virtual void render(sf::RenderTarget& window);
    
    virtual void onGui() = 0;

    static void text(sf::FloatRect rect, string text, EAlign align = AlignLeft, float textSize = 30, sf::Color color=sf::Color::White);
    static void vtext(sf::FloatRect rect, string text, EAlign align = AlignLeft, float textSize = 30, sf::Color color=sf::Color::White);
    static void progressBar(sf::FloatRect rect, float value, float min_value = 0.0, float max_value = 1.0, sf::Color color=sf::Color::White);
    static void vprogressBar(sf::FloatRect rect, float value, float min_value = 0.0, float max_value = 1.0, sf::Color color=sf::Color::White);
    static bool button(sf::FloatRect rect, string text, float textSize = 30);
    static void disabledButton(sf::FloatRect rect, string text, float textSize = 30);
    static bool toggleButton(sf::FloatRect rect, bool active, string textValue, float fontSize = 30);
    static float vslider(sf::FloatRect rect, float value, float minValue, float maxValue, float normalValue = 0.0);
    static int selector(sf::FloatRect rect, string text, float textSize = 30);
    static int box(sf::FloatRect rect);
    static string textEntry(sf::FloatRect rect, string value, float fontSize = 30);
    static void keyValueDisplay(sf::FloatRect, float div_distance, string key, string value, float textSize = 30.0f);

    static sf::RenderTarget* getRenderTarget() { return renderTarget; }
    static sf::Vector2f getWindowSize() { return windowSize; }

private:
    static void draw9Cut(sf::FloatRect rect, string texture, sf::Color color=sf::Color::White, float width_factor = 1.0);
};

class MouseRenderer : public Renderable
{
public:
    bool visible;
    
    MouseRenderer();
    
    virtual void render(sf::RenderTarget& window);
};

#endif//GUI_H
