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
    } texture_mode;
    string texture;
public:
    GuiOverlay(GuiContainer* owner, string id, sf::Color color);

    virtual void onDraw(sp::RenderTarget& target) override;

    GuiOverlay* setColor(sf::Color color);
    GuiOverlay* setAlpha(int alpha);
    GuiOverlay* setTextureTiled(string texture);
    GuiOverlay* setTextureNone();
};

#endif//GUI2_OVERLAY_H
