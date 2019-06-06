
#ifndef GUI2_OVERLAY_H
#define GUI2_OVERLAY_H

#include "gui2_element.h"

class GuiOverlay : public GuiElement
{
private:
    sf::Color color;
    enum ETextureMode
    {
        TM_None,
        TM_Tiled,
        TM_Centered
    } texture_mode;
    string texture;
    bool blocking;
public:
    GuiOverlay(GuiContainer* owner, string id, sf::Color color);

    virtual void onDraw(sf::RenderTarget& window);
    
    GuiOverlay* setColor(sf::Color color);
    GuiOverlay* setBlocking(bool blocking){ this->blocking = blocking; return this;}
    GuiOverlay* setAlpha(int alpha);
    GuiOverlay* setTextureCenter(string texture);
    GuiOverlay* setTextureTiled(string texture);
    GuiOverlay* setTextureNone();
    virtual bool onMouseDown(sf::Vector2f position);

};

#endif//GUI2_OVERLAY_H
