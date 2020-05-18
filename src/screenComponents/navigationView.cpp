#include <SFML/OpenGL.hpp>

#include "navigationView.h"
#include "main.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/nebula.h"
#include "spaceObjects/blackHole.h"
#include "spaceObjects/scanProbe.h"
#include "playerInfo.h"
#include "missileTubeControls.h"
#include "targetsContainer.h"

NavigationView::NavigationView(GuiContainer* owner, string id, float distance, TargetsContainer* targets)
: SectorsView(owner, id, distance, targets) {
}

void NavigationView::onDraw(sf::RenderTarget& window)
{
    //Setup our textures for rendering
    adjustRenderTexture(background_texture);
    adjustRenderTexture(forground_texture);

    background_texture.clear(sf::Color(30, 20, 30, 255));
    
    drawSectorGrid(background_texture);

    forground_texture.clear(sf::Color::Transparent);
    
    drawObjects(forground_texture, background_texture);
    drawRoutes(forground_texture);
    drawTargets(forground_texture);

    if (my_spaceship)
    {
        sf::Vector2f ship_offset = (my_spaceship->getPosition() - getViewPosition()) / getDistance() * std::min(rect.width, rect.height) / 2.0f;
        if (ship_offset.x < -rect.width / 2.0f || ship_offset.x > rect.width / 2.0f || ship_offset.y < -rect.height / 2.0f || ship_offset.y > rect.height / 2.0f)
        {
            sf::Vector2f position(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0);
            position += ship_offset / sf::length(ship_offset) * std::min(rect.width, rect.height) * 0.4f;

            sf::Sprite arrow_sprite;
            textureManager.setTexture(arrow_sprite, "waypoint");
            arrow_sprite.setPosition(position);
            arrow_sprite.setRotation(sf::vector2ToAngle(ship_offset) - 90);
            forground_texture.draw(arrow_sprite);
        }
    }

    //Render the final radar
    drawRenderTexture(background_texture, window);
    drawRenderTexture(forground_texture, window);
}

void NavigationView::drawObjects(sf::RenderTarget& window_normal, sf::RenderTarget& window_alpha)
{
    sf::Vector2f radar_screen_center(rect.left + rect.width / 2.0f, rect.top + rect.height / 2.0f);
    std::set<SpaceObject*> visible_objects;
    foreach(SpaceObject, obj, space_object_list)
    {
        if (P<Nebula>(obj) || P<BlackHole>(obj))
            visible_objects.insert(*obj);
    }
    for(SpaceObject* obj : visible_objects)
    {
        sf::Vector2f object_position_on_screen = worldToScreen(obj->getPosition());
        float r = obj->getRadius() * getScale();
        sf::FloatRect object_rect(object_position_on_screen.x - r, object_position_on_screen.y - r, r * 2, r * 2);
        if (obj != *my_spaceship && rect.intersects(object_rect))
        {
            sf::RenderTarget* window = &window_normal;
            if (!obj->canHideInNebula())
                window = &window_alpha;
            obj->drawOnRadar(*window, object_position_on_screen, getScale(), 0, true);
        }
    }
    if (my_spaceship)
    {
        sf::Vector2f object_position_on_screen = worldToScreen(my_spaceship->getPosition());
        my_spaceship->drawOnRadar(window_normal, object_position_on_screen, getScale(), 0, true);
    }
}
