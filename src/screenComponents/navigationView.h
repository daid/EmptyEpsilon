#ifndef NAVIGATION_VIEW_H
#define NAVIGATION_VIEW_H

#include "gui/gui2_element.h"
#include "sectorsView.h"

class NavigationView : public SectorsView
{
  private:
    sf::RenderTexture background_texture;
    sf::RenderTexture forground_texture;
  public:
    NavigationView(GuiContainer *owner, string id, float distance, TargetsContainer *targets);

    virtual void onDraw(sf::RenderTarget &window);

    virtual NavigationView *setDistance(float distance)
    {
        SectorsView::setDistance(distance);
        return this;
    }
    virtual NavigationView *setViewPosition(sf::Vector2f view_position)
    {
        SectorsView::setViewPosition(view_position);
        return this;
    }
private:
    void drawObjects(sf::RenderTarget& window_normal, sf::RenderTarget& window_alpha);
    void drawWaypoints(sf::RenderTarget &window);
};

#endif //NAVIGATION_VIEW_H
