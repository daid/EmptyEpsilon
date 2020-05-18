#ifndef SECTORS_VIEW_H
#define SECTORS_VIEW_H

#include "gui/gui2_element.h"
#include "gameGlobalInfo.h"

class TargetsContainer;
class SectorsView : public GuiElement
{
  public:
    typedef std::function<void(sf::Vector2f position)> func_t;
    typedef std::function<void(float position)> ffunc_t;
  static const int grid_scale_size = 5;

private:
  sf::Color grid_colors[SectorsView::grid_scale_size];
  const float sub_sectors_count = 8;
  float distance;
  sf::Vector2f view_position;

  TargetsContainer *targets;
  func_t mouse_down_func;
  func_t mouse_drag_func;
  func_t mouse_up_func;
  ffunc_t joystick_x_func;
  ffunc_t joystick_y_func;
  ffunc_t joystick_z_func;
  ffunc_t joystick_r_func;
    
public:
  SectorsView(GuiContainer *owner, string id, float distance, TargetsContainer *targets);

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
  virtual float getScale() { return std::min(rect.width, rect.height) / 2.0f / distance; };

  void drawSectorGrid(sf::RenderTarget &window);
    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseDrag(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);

    virtual SectorsView *setCallbacks(func_t mouse_down_func, func_t mouse_drag_func, func_t mouse_up_func)
    {
        this->mouse_down_func = mouse_down_func;
        this->mouse_drag_func = mouse_drag_func;
        this->mouse_up_func = mouse_up_func;
        return this;
    }
  protected:
    TargetsContainer * getTargets(){return targets;};
    void drawTargets(sf::RenderTarget &window);
    void drawRoutes(sf::RenderTarget &window);
    virtual sf::Vector2f getCenterPosition();
private:
  int calcGridScaleMagnitude(int scale_magnitude, int position);
};

#endif //SECTORS_VIEW_H
