#include "crewHelmsUI.h"

CrewHelmsUI::CrewHelmsUI()
{
    jump_distance = 10.0;
    ghost_delay = 0.0;
}

void CrewHelmsUI::update(float delta)
{
    if (!my_spaceship)
        return;

    ///Ghost dots are the dots drawn on screen to indicate previous positions of the ship.
    if (ghost_delay > 0)
    {
        ghost_delay -= delta;
    } else {
        ghost_delay = 5.0;

        foreach(SpaceObject, obj, space_object_list)
        {
            P<SpaceShip> ship = obj;
            if (ship && sf::length(obj->getPosition() - my_spaceship->getPosition()) < 5000.0)
            {
                ghost_dot.push_back(HelmsGhostDot(obj->getPosition()));
            }
        }
    }

    for(unsigned int n=0; n < ghost_dot.size(); n++)
    {
        HelmsGhostDot& ghost = ghost_dot[n];
        ghost.lifetime -= delta;
        if (ghost.lifetime <= 0.0)
        {
            ghost_dot.erase(ghost_dot.begin() + n);
            n--;
        }
    }

    CrewUI::update(delta);
}

void CrewHelmsUI::onCrewUI()
{
    sf::Vector2f mouse = InputHandler::getMousePos();
    sf::Vector2f radar_center = getWindowSize() / 2.0f;
    if (InputHandler::mouseIsPressed(sf::Mouse::Left) || InputHandler::mouseIsReleased(sf::Mouse::Left))
    {
        sf::Vector2f diff = mouse - radar_center;
        if (sf::length(diff) < 400)
            my_spaceship->commandTargetRotation(sf::vector2ToAngle(diff));
    }

    sf::VertexArray ghost_dots(sf::Points, ghost_dot.size());
    for(unsigned int n=0; n<ghost_dot.size(); n++)
    {
        ghost_dots[n].position = radar_center + (ghost_dot[n].position - my_spaceship->getPosition()) / 5000.0f * 400.0f;
        ghost_dots[n].color = sf::Color(255, 255, 255, 255 * (ghost_dot[n].lifetime / HelmsGhostDot::total_lifetime));
    }
    getRenderTarget()->draw(ghost_dots);

    drawRadar(radar_center, 400, 5000, false, my_spaceship->getTarget());
    if (InputHandler::mouseIsDown(sf::Mouse::Left))
    {
        sf::Vector2f diff = mouse - radar_center;
        if (sf::length(diff) < 400)
        {
            sf::Vector2f text_pos = mouse;
            if (engine->getObject("mouseRenderer"))
                text_pos.y -= 10.0;
            else
                text_pos.y -= 30.0;
            drawText(sf::FloatRect(text_pos.x, text_pos.y, 0, 0), string(fmodf(sf::vector2ToAngle(diff) + 360.0 + 360.0 - 270.0, 360.0), 1), AlignCenter, 20);
        }
    }
    drawDamagePowerDisplay(sf::FloatRect(radar_center.x - 140, radar_center.y + 150, 280, 50), SYS_Maneuver, 20);

    drawKeyValueDisplay(sf::FloatRect(20, 100, 240, 40), 0.45, "Energy", string(int(my_spaceship->energy_level)), 20);
    drawKeyValueDisplay(sf::FloatRect(20, 140, 240, 40), 0.45, "Heading", string(fmodf(my_spaceship->getRotation() + 360.0 + 360.0 - 270.0, 360.0), 1), 20);
    float velocity = sf::length(my_spaceship->getVelocity()) / 1000 * 60;
    string velocity_text = string(velocity, 1);
    drawKeyValueDisplay(sf::FloatRect(20, 180, 240, 40), 0.45, "Speed", velocity_text + "km/min", 20);

    drawImpulseSlider(sf::FloatRect(20, 400, 50, 300), 20);

    float x = 100;
    if (my_spaceship->has_warp_drive)
    {
        drawWarpSlider(sf::FloatRect(x, 400, 50, 300), 20);
        x += 80;
    }
    if (my_spaceship->has_jump_drive)
    {
        drawJumpSlider(jump_distance, sf::FloatRect(x, 400, 50, 300), 20);
        x += 80;
        drawJumpButton(jump_distance, sf::FloatRect(20, 750, 280, 50), 30);
    }

    drawDockingButton(sf::FloatRect(20, 800, 280, 50), 30);

    x = getWindowSize().x - 300;


    //TODO: Here a trick is used to draw the same control twice to get a "snap back to default" type of control.
    float combat_boost_request = drawVerticalSlider(sf::FloatRect(x + 140 - 25, 750 - 165, 50, 165), 0.0, 1.0, 0.0, 0.0);
    drawVerticalSlider(sf::FloatRect(x + 140 - 25, 750 - 165, 50, 165), combat_boost_request, 1.0, 0.0, 0.0);
    if (combat_boost_request != my_spaceship->combat_maneuver_boost_request)
        my_spaceship->commandCombatManeuverBoost(combat_boost_request);
    float combat_strafe_request = drawHorizontalSlider(sf::FloatRect(x, 750, 280, 50), 0.0, -1.0, 1.0, 0.0);
    drawHorizontalSlider(sf::FloatRect(x, 750, 280, 50), combat_strafe_request, -1.0, 1.0, 0.0);
    if (combat_strafe_request != my_spaceship->combat_maneuver_strafe_request)
        my_spaceship->commandCombatManeuverStrafe(combat_strafe_request);
    
    drawDamagePowerDisplay(sf::FloatRect(x + 140 - 25, 750 - 165, 50, 165), SYS_Impulse, 20);
    drawDamagePowerDisplay(sf::FloatRect(x, 750, 280, 50), SYS_Maneuver, 20);
    
    drawProgressBar(sf::FloatRect(x, 800, 280, 50), my_spaceship->combat_maneuver_charge, 0.0, 1.0);
    drawText(sf::FloatRect(x, 800, 280, 50), "Combat maneuver", AlignCenter, 20, sf::Color::Black);
}

void CrewHelmsUI::onPauseHelpGui()
{
    float x = getWindowSize().x - 300;
    float y = 50;
    float line_x = x - 200;
    drawTextBoxWithBackground(sf::FloatRect(x, y, 300, 80), "Control your ship by setting a heading and speed", AlignTopLeft, 20);
    drawUILine(sf::Vector2f(getWindowSize().x / 2.0f, 300), sf::Vector2f(x, y + 25), line_x);
    line_x += 10;
    drawUILine(sf::Vector2f(60, 420), sf::Vector2f(x, y + 35), line_x);
    line_x += 40;
    y += 80;

    if (my_spaceship->has_warp_drive)
    {
        drawTextBoxWithBackground(sf::FloatRect(x, y, 300, 80), "Use the warp drive to cover long distances (drains energy fast)", AlignTopLeft, 20);
        drawUILine(sf::Vector2f(140, 480), sf::Vector2f(x, y + 25), line_x);
        line_x += 40;
        y += 80;
    }
    if (my_spaceship->has_jump_drive)
    {
        drawTextBoxWithBackground(sf::FloatRect(x, y, 300, 80), "Use the jump drive to cover long distances (uses energy)", AlignTopLeft, 20);
        drawUILine(sf::Vector2f(my_spaceship->has_warp_drive ? 220 : 140, 520), sf::Vector2f(x, y + 25), line_x);
        line_x += 10;
        drawUILine(sf::Vector2f(280, 770), sf::Vector2f(x, y + 35), line_x);
        line_x += 40;
        y += 80;
    }
    drawTextBoxWithBackground(sf::FloatRect(x, y, 300, 80), "When near a station, dock for energy recharge.", AlignTopLeft, 20);
    drawUILine(sf::Vector2f(280, 820), sf::Vector2f(x, y + 35), line_x);
    line_x += 40;
    y += 80;
    drawTextBoxWithBackground(sf::FloatRect(x, y, 300, 100), "During combat, use maneuvers to gain an edge on enemies.", AlignTopLeft, 20);
    drawUILine(sf::Vector2f(x+80, 670), sf::Vector2f(x, y + 35), line_x);
    drawUILine(sf::Vector2f(x+10, 720), sf::Vector2f(x, y + 35), line_x);
    drawUILine(sf::Vector2f(x+10, 770), sf::Vector2f(x, y + 35), line_x);
    drawUILine(sf::Vector2f(x+10, 820), sf::Vector2f(x, y + 35), line_x);
    line_x += 40;
    y += 100;

    drawTextBoxWithBackground(sf::FloatRect(x, y, 300, 80), "And always, listen to your captain!", AlignTopLeft, 20);

    x = 20;
    y = 200;
    drawTextBoxWithBackground(sf::FloatRect(x, y, 300, 100), "Tip: The arcs shown at your ship indicates what the beam weapons can hit.", AlignTopLeft, 20);
    y += 100;
}
