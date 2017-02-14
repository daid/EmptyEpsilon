#ifndef GUI2_AUTOLAYOUT_H
#define GUI2_AUTOLAYOUT_H

#include "gui2_element.h"

class GuiAutoLayout : public GuiElement
{
public:
    enum ELayoutMode
    {
        /* Various layout options, set the position of children */
        LayoutHorizontalLeftToRight,
        LayoutHorizontalRightToLeft,
        LayoutVerticalTopToBottom,
        LayoutVerticalBottomToTop,
        
        LayoutHorizontalRows,   /* Evenly spaced horizontal rows. Using up all space. Sets the position and size of children */
        LayoutVerticalColumns   /* Evenly spaced vertical columns. Using up all space. Sets the position and size of children */
    };
private:
    ELayoutMode mode;
public:
    GuiAutoLayout(GuiContainer* owner, string id, ELayoutMode mode);
    
    virtual void onDraw(sf::RenderTarget& window);
protected:
    virtual void drawElements(sf::FloatRect parent_rect, sf::RenderTarget& window);
};

#endif//GUI2_AUTOLAYOUT_H
