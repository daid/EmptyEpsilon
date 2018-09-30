#ifndef SECTORS_VIEW_H
#define SECTORS_VIEW_H

#include "gui/gui2_element.h"

class SectorsView : public GuiElement
{
public:
  static const int grid_scale_size = 5;

private:
  sf::Color grid_colors[SectorsView::grid_scale_size];
  const float sub_sectors_count = 8;
  float distance;
  sf::Vector2f view_position;

public:
  SectorsView(GuiContainer *owner, string id, float distance);

  virtual SectorsView *setDistance(float distance)
  {
    this->distance = distance;
    return this;
  }
  float getDistance() { return distance; }
  virtual SectorsView *setViewPosition(sf::Vector2f view_position)
  {
    this->view_position = view_position;
    return this;
  }
  sf::Vector2f getViewPosition() { return view_position; }
  sf::Vector2f worldToScreen(sf::Vector2f world_position);
  sf::Vector2f screenToWorld(sf::Vector2f screen_position);
  float getScale() { return std::min(rect.width, rect.height) / 2.0f / distance; };

  void drawSectorGrid(sf::RenderTarget &window);

private:
  int calcGridScaleMagnitude(int scale_magnitude, int position);
};

#endif //SECTORS_VIEW_H
