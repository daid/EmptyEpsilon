#include <SFML/OpenGL.hpp>
#include <limits>
#include "mainUIBase.h"
#include "mainMenus.h"
#include "epsilonServer.h"
#include "main.h"
#include "particleEffect.h"
#include "factionInfo.h"
#include "shipSelectionScreen.h"
#include "repairCrew.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/nebula.h"

MainUIBase::MainUIBase()
{
    scan_angle = 0.0;

    foreach(SpaceObject, obj, space_object_list)
    {
        int index = scan_ghost.size();
        scan_ghost.push_back(ScanGhost());
        scan_ghost[index].object = obj;
        scan_ghost[index].position = obj->getPosition();
    }
}

void MainUIBase::onGui()
{
    if (game_client && !game_client->isConnected())
    {
        destroy();
        disconnectFromServer();
        returnToMainMenu();
        return;
    }

    if (isActive())
    {
        if (InputHandler::keyboardIsPressed(sf::Keyboard::Escape) || InputHandler::keyboardIsPressed(sf::Keyboard::Home))
        {
            destroy();
            new ShipSelectionScreen();
        }
    }

    if (game_server)
    {
        if (gameGlobalInfo->getVictoryFactionId() < 0 && isActive())
        {
            if (InputHandler::keyboardIsPressed(sf::Keyboard::Space))
                engine->setGameSpeed(1.0);
            if (InputHandler::keyboardIsPressed(sf::Keyboard::P))
                engine->setGameSpeed(0.0);
        }
#ifdef DEBUG
        text(sf::FloatRect(0, 0, getWindowSize().x - 5, 20), string(game_server->getSendDataRate() / 1000) + " kb per second", AlignRight, 15);
        text(sf::FloatRect(0, 20, getWindowSize().x - 5, 20), string(game_server->getSendDataRatePerClient() / 1000) + " kb per client", AlignRight, 15);
#endif
    }

    if (my_spaceship)
    {
        float shield_hit = (std::max(my_spaceship->front_shield_hit_effect, my_spaceship->rear_shield_hit_effect) - 0.5) / 0.5;
        if (shield_hit > 0)
        {
            sf::RectangleShape fullScreenOverlay(sf::Vector2f(getWindowSize().x, 900));
            fullScreenOverlay.setFillColor(sf::Color(64, 64, 128, 32 * shield_hit));
            getRenderTarget()->draw(fullScreenOverlay);
        }
        if (my_spaceship->front_shield < my_spaceship->front_shield_max / 10.0 || my_spaceship->rear_shield < my_spaceship->rear_shield_max / 10.0)
        {
            sf::RectangleShape fullScreenOverlay(sf::Vector2f(getWindowSize().x, 900));
            float f = fabsf(fmodf(engine->getElapsedTime() * 2.0, 2.0) - 1.0);
            fullScreenOverlay.setFillColor(sf::Color(255, 0, 0, 16 + 32 * f));
            getRenderTarget()->draw(fullScreenOverlay);
        }
        if (my_spaceship->hull_damage_indicator > 0.0)
        {
            sf::RectangleShape fullScreenOverlay(sf::Vector2f(getWindowSize().x, 900));
            fullScreenOverlay.setFillColor(sf::Color(255, 0, 0, 128 * (my_spaceship->hull_damage_indicator / 1.5)));
            getRenderTarget()->draw(fullScreenOverlay);
        }

        if (my_spaceship->warp_indicator > 0.0)
        {
            if (my_spaceship->warp_indicator > 1.0)
            {
                sf::RectangleShape fullScreenOverlay(sf::Vector2f(getWindowSize().x, 900));
                fullScreenOverlay.setFillColor(sf::Color(0, 0, 0, 255 * (my_spaceship->warp_indicator - 1.0)));
                getRenderTarget()->draw(fullScreenOverlay);
            }
            glitchPostProcessor->enabled = true;
            glitchPostProcessor->setUniform("magtitude", my_spaceship->warp_indicator * 10.0);
            glitchPostProcessor->setUniform("delta", random(0, 360));
        }else{
            glitchPostProcessor->enabled = false;
        }
        if (my_spaceship->currentWarp > 0.0)
        {
            warpPostProcessor->enabled = true;
            warpPostProcessor->setUniform("amount", my_spaceship->currentWarp * 0.01);
        }else if (my_spaceship->jumpDelay > 0.0 && my_spaceship->jumpDelay < 2.0)
        {
            warpPostProcessor->enabled = true;
            warpPostProcessor->setUniform("amount", (2.0 - my_spaceship->jumpDelay) * 0.1);
        }else{
            warpPostProcessor->enabled = false;
        }
    }else{
        glitchPostProcessor->enabled = false;
    }

    if (engine->getGameSpeed() == 0.0)
    {
        if (gameGlobalInfo->getVictoryFactionId() < 0)
        {
            sf::RectangleShape fullScreenOverlay(sf::Vector2f(getWindowSize().x, 900));
            fullScreenOverlay.setFillColor(sf::Color(0, 0, 0, 128));
            getRenderTarget()->draw(fullScreenOverlay);
            
            if (my_spaceship)
                onPauseHelpGui();
            
            boxWithBackground(sf::FloatRect(getWindowSize().x / 2 - 250, 600, 500, game_server ? 130 : 100));
            text(sf::FloatRect(0, 600, getWindowSize().x, 100), "Game Paused", AlignCenter, 70);
            if (game_server)
                text(sf::FloatRect(0, 680, getWindowSize().x, 30), "(Press [SPACE] to resume)", AlignCenter, 30);
        }else{
            if (my_spaceship)
            {
                if (factionInfo[gameGlobalInfo->getVictoryFactionId()]->states[my_spaceship->getFactionId()] == FVF_Enemy)
                    text(sf::FloatRect(0, 600, getWindowSize().x, 100), "Defeat!", AlignCenter, 70);
                else
                    text(sf::FloatRect(0, 600, getWindowSize().x, 100), "Victory!", AlignCenter, 70);
            }else{
                text(sf::FloatRect(0, 600, getWindowSize().x, 100), "Game Finished", AlignCenter, 70);
                text(sf::FloatRect(0, 680, getWindowSize().x, 100), factionInfo[gameGlobalInfo->getVictoryFactionId()]->name + " wins", AlignCenter, 70);
            }
        }
    }
}

void MainUIBase::update(float delta)
{
    if (!my_spaceship)
        return;
    
    scan_angle += delta * 20.0f;
    if (scan_angle > 360)
        scan_angle -= 360;
    foreach(SpaceObject, obj, space_object_list)
    {
        float angle = sf::vector2ToAngle(obj->getPosition() - my_spaceship->getPosition());
        float diff = sf::angleDifference(angle, scan_angle);
        if ((diff > 0.0 && diff < 5.0f) || (obj->getPosition() - my_spaceship->getPosition()) < 5000.0f)
        {
            int index = -1;
            for(unsigned int n=0; n<scan_ghost.size(); n++)
            {
                if (scan_ghost[n].object == obj)
                {
                    index = n;
                    break;
                }
            }
            if (index == -1)
            {
                index = scan_ghost.size();
                scan_ghost.push_back(ScanGhost());
                scan_ghost[index].object = obj;
            }
            scan_ghost[index].position = obj->getPosition();
        }
    }
    for(std::vector<ScanGhost>::iterator i = scan_ghost.begin(); i != scan_ghost.end();)
    {
        if (i->object && (!i->object->canHideInNebula() || (i->object->getPosition() - my_spaceship->getPosition()) < 5000.0f || !Nebula::blockedByNebula(my_spaceship->getPosition(), i->object->getPosition())))
        {
            i++;
            continue;
        }
        i = scan_ghost.erase(i);
    }
}

void MainUIBase::mainScreenSelectGUI()
{
    float x = getWindowSize().x - 200;
    float y = 40;
    if (button(sf::FloatRect(x, y, 200, 40), "Front", 28))
        my_spaceship->commandMainScreenSetting(MSS_Front);
    y += 40;
    if (button(sf::FloatRect(x, y, 200, 40), "Back", 28))
        my_spaceship->commandMainScreenSetting(MSS_Back);
    y += 40;
    if (button(sf::FloatRect(x, y, 200, 40), "Left", 28))
        my_spaceship->commandMainScreenSetting(MSS_Left);
    y += 40;
    if (button(sf::FloatRect(x, y, 200, 40), "Right", 28))
        my_spaceship->commandMainScreenSetting(MSS_Right);
    y += 40;
    if (gameGlobalInfo->allow_main_screen_tactical_radar)
    {
        if (button(sf::FloatRect(x, y, 200, 40), "Tactical", 28))
            my_spaceship->commandMainScreenSetting(MSS_Tactical);
        y += 40;
    }
    if (gameGlobalInfo->allow_main_screen_long_range_radar)
    {
        if (button(sf::FloatRect(x, y, 200, 40), "Long-Range", 28))
            my_spaceship->commandMainScreenSetting(MSS_LongRange);
        y += 40;
    }
}

void MainUIBase::selfDestructGUI()
{
    int entry_position = -1;
    int show_position = -1;
    for(int n=0; n<PlayerSpaceship::max_self_destruct_codes; n++)
    {
        if (my_player_info->crew_active_position == my_spaceship->self_destruct_code_entry_position[n])
            entry_position = n;
        if (my_player_info->crew_active_position == my_spaceship->self_destruct_code_show_position[n])
            show_position = n;
    }
    
    float y = 40;
    if (entry_position > -1)
    {
        if (my_spaceship->self_destruct_code_confirmed[entry_position])
        {
            float x = getWindowSize().x - 200;
            boxWithBackground(sf::FloatRect(x, y, 200, 80));
            y += 10;
            text(sf::FloatRect(x, y, 200, 25), "SELF DESTRUCT", AlignCenter, 20);
            x += 25;
            y += 30;
            text(sf::FloatRect(x, y, 150, 25), "Code: " + string(char('A' + entry_position)) + " confirmed", AlignCenter, 20);
            y += 20;
        }else{
            float x = getWindowSize().x - 200;
            boxWithBackground(sf::FloatRect(x, y, 200, 340));
            y += 10;
            text(sf::FloatRect(x, y, 200, 25), "SELF DESTRUCT", AlignCenter, 20);
            y += 25;
            box(sf::FloatRect(x, y, 200, 50));
            x += 25;
            text(sf::FloatRect(x, y, 150, 50), self_destruct_input + "_", AlignLeft, 20);
            y += 50;
            text(sf::FloatRect(x, y, 150, 25), "Enter code: " + string(char('A' + entry_position)), AlignCenter, 20);
            y += 25;
            
            if (button(sf::FloatRect(x, y, 50, 50), "1", 30))
                self_destruct_input += "1";
            if (button(sf::FloatRect(x+50, y, 50, 50), "2", 30))
                self_destruct_input += "2";
            if (button(sf::FloatRect(x+100, y, 50, 50), "3", 30))
                self_destruct_input += "3";
            y += 50;
            if (button(sf::FloatRect(x, y, 50, 50), "4", 30))
                self_destruct_input += "4";
            if (button(sf::FloatRect(x+50, y, 50, 50), "5", 30))
                self_destruct_input += "5";
            if (button(sf::FloatRect(x+100, y, 50, 50), "6", 30))
                self_destruct_input += "6";
            y += 50;
            if (button(sf::FloatRect(x, y, 50, 50), "7", 30))
                self_destruct_input += "7";
            if (button(sf::FloatRect(x+50, y, 50, 50), "8", 30))
                self_destruct_input += "8";
            if (button(sf::FloatRect(x+100, y, 50, 50), "9", 30))
                self_destruct_input += "9";
            y += 50;
            if (button(sf::FloatRect(x, y, 50, 50), "Clr", 20))
                self_destruct_input = "";
            if (button(sf::FloatRect(x+50, y, 50, 50), "0", 30))
                self_destruct_input += "0";
            if (button(sf::FloatRect(x+100, y, 50, 50), "OK", 20))
            {
                my_spaceship->commandConfirmDestructCode(entry_position, self_destruct_input.toInt());
                self_destruct_input = "";
            }
            y += 60;
        }
        y += 25;
    }
    if (show_position > -1)
    {
        float x = getWindowSize().x - 200;
        boxWithBackground(sf::FloatRect(x, y, 200, 80));
        y += 10;
        text(sf::FloatRect(x, y, 200, 25), "SELF DESTRUCT", AlignCenter, 20);
        x += 25;
        y += 30;
        text(sf::FloatRect(x, y, 150, 25), "Code " + string(char('A' + show_position)) + ": " + string(my_spaceship->self_destruct_code[show_position]), AlignCenter, 20);
        y += 20;
    }
}

void MainUIBase::drawStatic(float alpha)
{
    sf::Sprite staticDisplay;
    textureManager.getTexture("noise.png")->setRepeated(true);
    textureManager.setTexture(staticDisplay, "noise.png");
    staticDisplay.setTextureRect(sf::IntRect(0, 0, 2048, 2048));
    staticDisplay.setOrigin(sf::Vector2f(1024, 1024));
    staticDisplay.setScale(3.0, 3.0);
    staticDisplay.setPosition(sf::Vector2f(random(-512, 512), random(-512, 512)));
    staticDisplay.setColor(sf::Color(255, 255, 255, 255*alpha));
    getRenderTarget()->draw(staticDisplay);
}

void MainUIBase::drawRaderBackground(sf::Vector2f view_position, sf::Vector2f position, float size, float range, sf::FloatRect rect)
{
    const float sector_size = 20000;
    const float sub_sector_size = sector_size / 8;

    float scale = size / range;
    int sector_x_min = floor((view_position.x - (position.x - rect.left) / scale) / sector_size) + 1;
    int sector_x_max = floor((view_position.x + (rect.left + rect.width - position.x) / scale) / sector_size);
    int sector_y_min = floor((view_position.y - (position.y - rect.top) / scale) / sector_size) + 1;
    int sector_y_max = floor((view_position.y + (rect.top + rect.height - position.y) / scale) / sector_size);
    sf::VertexArray lines_x(sf::Lines, 2 * (sector_x_max - sector_x_min + 1));
    sf::VertexArray lines_y(sf::Lines, 2 * (sector_y_max - sector_y_min + 1));
    sf::Color color(64, 64, 128, 128);
    for(int sector_x = sector_x_min; sector_x <= sector_x_max; sector_x++)
    {
        float x = position.x + ((sector_x * sector_size) - view_position.x) * scale;
        lines_x[(sector_x - sector_x_min)*2].position = sf::Vector2f(x, rect.top);
        lines_x[(sector_x - sector_x_min)*2].color = color;
        lines_x[(sector_x - sector_x_min)*2+1].position = sf::Vector2f(x, rect.top + rect.height);
        lines_x[(sector_x - sector_x_min)*2+1].color = color;
        for(int sector_y = sector_y_min; sector_y <= sector_y_max; sector_y++)
        {
            float y = position.y + ((sector_y * sector_size) - view_position.y) * scale;
            text(sf::FloatRect(x, y, 30, 30), string(char('A' + (sector_y + 5))) + string(sector_x + 5), AlignLeft, 30, color);
        }
    }
    for(int sector_y = sector_y_min; sector_y <= sector_y_max; sector_y++)
    {
        float y = position.y + ((sector_y * sector_size) - view_position.y) * scale;
        lines_y[(sector_y - sector_y_min)*2].position = sf::Vector2f(rect.left, y);
        lines_y[(sector_y - sector_y_min)*2].color = color;
        lines_y[(sector_y - sector_y_min)*2+1].position = sf::Vector2f(rect.left + rect.width, y);
        lines_y[(sector_y - sector_y_min)*2+1].color = color;
    }
    getRenderTarget()->draw(lines_x);
    getRenderTarget()->draw(lines_y);

    int sub_sector_x_min = floor((view_position.x - (position.x - rect.left) / scale) / sub_sector_size) + 1;
    int sub_sector_x_max = floor((view_position.x + (rect.left + rect.width - position.x) / scale) / sub_sector_size);
    int sub_sector_y_min = floor((view_position.y - (position.y - rect.top) / scale) / sub_sector_size) + 1;
    int sub_sector_y_max = floor((view_position.y + (rect.top + rect.height - position.y) / scale) / sub_sector_size);
    sf::VertexArray points(sf::Points, (sub_sector_x_max - sub_sector_x_min + 1) * (sub_sector_y_max - sub_sector_y_min + 1));
    for(int sector_x = sub_sector_x_min; sector_x <= sub_sector_x_max; sector_x++)
    {
        float x = position.x + ((sector_x * sub_sector_size) - view_position.x) * scale;
        for(int sector_y = sub_sector_y_min; sector_y <= sub_sector_y_max; sector_y++)
        {
            float y = position.y + ((sector_y * sub_sector_size) - view_position.y) * scale;
            points[(sector_x - sub_sector_x_min) + (sector_y - sub_sector_y_min) * (sub_sector_x_max - sub_sector_x_min + 1)].position = sf::Vector2f(x, y);
            points[(sector_x - sub_sector_x_min) + (sector_y - sub_sector_y_min) * (sub_sector_x_max - sub_sector_x_min + 1)].color = color;
        }
    }
    getRenderTarget()->draw(points);
}

void MainUIBase::drawHeadingCircle(sf::Vector2f position, float size, sf::FloatRect rect)
{
    sf::RenderTarget& window = *getRenderTarget();

    sf::VertexArray tigs(sf::Lines, 360/20*2);
    for(unsigned int n=0; n<360; n+=20)
    {
        tigs[n/20*2].position = position + sf::vector2FromAngle(float(n) - 90) * size;
        tigs[n/20*2+1].position = position + sf::vector2FromAngle(float(n) - 90) * (size - 20);
    }
    window.draw(tigs);
    sf::VertexArray smallTigs(sf::Lines, 360/5*2);
    for(unsigned int n=0; n<360; n+=5)
    {
        smallTigs[n/5*2].position = position + sf::vector2FromAngle(float(n) - 90) * size;
        smallTigs[n/5*2+1].position = position + sf::vector2FromAngle(float(n) - 90) * (size - 10);
    }
    window.draw(smallTigs);
    for(unsigned int n=0; n<360; n+=20)
    {
        sf::Text text(string(n), mainFont, 15);
        text.setPosition(position + sf::vector2FromAngle(float(n) - 90) * (size - 25));
        text.setOrigin(text.getLocalBounds().width / 2.0, text.getLocalBounds().height / 2.0);
        text.setRotation(n);
        window.draw(text);
    }
}

void MainUIBase::drawRadarCuttoff(sf::Vector2f position, float size, sf::FloatRect rect)
{
    sf::RenderTarget& window = *getRenderTarget();

    sf::Sprite cutOff;
    textureManager.setTexture(cutOff, "radarCutoff.png");
    cutOff.setPosition(position);
    cutOff.setScale(size / float(cutOff.getTextureRect().width) * 2.1, size / float(cutOff.getTextureRect().width) * 2.1);
    window.draw(cutOff);

    sf::RectangleShape rectTop(sf::Vector2f(rect.width, position.y - size * 1.05 - rect.top));
    rectTop.setFillColor(sf::Color::Black);
    rectTop.setPosition(rect.left, rect.top);
    window.draw(rectTop);
    sf::RectangleShape rectBottom(sf::Vector2f(rect.width, rect.height - size * 1.05 - (position.y - rect.top)));
    rectBottom.setFillColor(sf::Color::Black);
    rectBottom.setPosition(rect.left, position.y + size * 1.05);
    window.draw(rectBottom);

    sf::RectangleShape rectLeft(sf::Vector2f(position.x - size * 1.05 - rect.left, rect.height));
    rectLeft.setFillColor(sf::Color::Black);
    rectLeft.setPosition(rect.left, rect.top);
    window.draw(rectLeft);
    sf::RectangleShape rectRight(sf::Vector2f(rect.width - size * 1.05 - (position.x - rect.left), rect.height));
    rectRight.setFillColor(sf::Color::Black);
    rectRight.setPosition(position.x + size * 1.05, rect.top);
    window.draw(rectRight);
}

void MainUIBase::drawWaypoints(sf::Vector2f view_position, sf::Vector2f position, float size, float range)
{
    sf::RenderTarget& window = *getRenderTarget();

    float scale = size / range;
    for(unsigned int n=0; n<my_spaceship->waypoints.size(); n++)
    {
        sf::Vector2f screen_position = position + (my_spaceship->waypoints[n] - view_position) * scale;
        if (sf::length(screen_position - position) > size)
            continue;
        
        sf::Sprite object_sprite;
        textureManager.setTexture(object_sprite, "waypoint.png");
        object_sprite.setColor(sf::Color(128, 128, 255, 192));
        object_sprite.setPosition(screen_position - sf::Vector2f(0, 10));
        object_sprite.setScale(0.6, 0.6);
        window.draw(object_sprite);
        text(sf::FloatRect(screen_position.x, screen_position.y - 26, 0, 0), "WP" + string(n + 1), AlignCenter, 14, sf::Color(128, 128, 255, 192));
    }
}

void MainUIBase::drawRadarSweep(sf::Vector2f position, float range, float size, float angle)
{
    sf::RenderTarget& window = *getRenderTarget();
    
    sf::VertexArray sweep(sf::Triangles, 3);
    for(int n=0; n<10; n++)
    {
        float length = size * 1.1;
        if (my_spaceship)
        {
            length = sf::length(Nebula::getFirstBlockedPosition(my_spaceship->getPosition(), my_spaceship->getPosition() + sf::vector2FromAngle(float(n) - 9.0f + angle) * range) - my_spaceship->getPosition());
            if (length < 5000.0f)
                length = 5000.0f;
            length = length / range * size;
        }
        sweep[0].position = position;
        sweep[0].color = sf::Color(0, 255, 0, n * 5);
        sweep[1].position = position + sf::vector2FromAngle(float(n) - 10.0f + angle) * length;
        sweep[1].color = sf::Color(0, 255, 0, n * 5);
        sweep[2].position = position + sf::vector2FromAngle(float(n) - 9.0f + angle) * length;
        sweep[2].color = sf::Color(0, 255, 0, n * 5);
        window.draw(sweep);
    }
}

void MainUIBase::drawRadar(sf::Vector2f position, float size, float range, bool long_range, P<SpaceObject> target, sf::FloatRect rect)
{
    sf::RenderTarget& window = *getRenderTarget();
    sf::Vector2f target_position;
    if (target)
        target_position = target->getPosition();

    if (long_range)
    {
        for(float circle_size=5000.0f; circle_size < range; circle_size+=5000.0f)
        {
            float s = circle_size * size / range;
            sf::CircleShape circle(s, 50);
            circle.setOrigin(s, s);
            circle.setPosition(position);
            circle.setFillColor(sf::Color::Transparent);
            circle.setOutlineColor(sf::Color(255, 255, 255, 16));
            circle.setOutlineThickness(2.0);
            window.draw(circle);
            text(sf::FloatRect(position.x, position.y - s - 20, 0, 0), string(int(circle_size / 1000.0f + 0.1f)) + "km", AlignCenter, 20, sf::Color(255, 255, 255, 32));
        }
        drawRaderBackground(my_spaceship->getPosition(), position, size, range, rect);
        drawRadarSweep(position, range, size, scan_angle);
        for(unsigned int n=0; n<scan_ghost.size(); n++)
        {
            P<SpaceObject> obj = scan_ghost[n].object;
            if(!obj)
                continue;
            if (obj != my_spaceship && (scan_ghost[n].position - my_spaceship->getPosition()) < range + obj->getRadius())
                obj->drawOnRadar(window, position + (scan_ghost[n].position - my_spaceship->getPosition()) / range * size, size / range, long_range);
            if (obj == target)
                target_position = scan_ghost[n].position;
        }
    }else{
        for(float circle_size=1000.0f; circle_size < range; circle_size+=1000.0f)
        {
            float s = circle_size * size / range;
            sf::CircleShape circle(s, 50);
            circle.setOrigin(s, s);
            circle.setPosition(position);
            circle.setFillColor(sf::Color::Transparent);
            circle.setOutlineColor(sf::Color(255, 255, 255, 16));
            circle.setOutlineThickness(2.0);
            window.draw(circle);
            text(sf::FloatRect(position.x, position.y - s - 20, 0, 0), string(int(circle_size / 1000.0f + 0.1f)) + "km", AlignCenter, 20, sf::Color(255, 255, 255, 32));
        }
        foreach(SpaceObject, obj, space_object_list)
        {
            if (obj != my_spaceship && (obj->getPosition() - my_spaceship->getPosition()) < range + obj->getRadius())
                obj->drawOnRadar(window, position + (obj->getPosition() - my_spaceship->getPosition()) / range * size, size / range, long_range);
        }
    }

    if (target)
    {
        sf::Sprite objectSprite;
        textureManager.setTexture(objectSprite, "redicule.png");
        objectSprite.setPosition(position + (target_position - my_spaceship->getPosition()) / range * size);
        window.draw(objectSprite);
    }
    drawWaypoints(my_spaceship->getPosition(), position, size, range);
    my_spaceship->drawOnRadar(window, position, size / range, long_range);
    drawHeadingCircle(position, size, rect);
    drawRadarCuttoff(position, size, rect);
}

void MainUIBase::drawShipInternals(sf::Vector2f position, P<SpaceShip> ship, ESystem highlight_system)
{
    if (!ship || !ship->ship_template) return;
    sf::RenderTarget& window = *getRenderTarget();
    P<ShipTemplate> st = ship->ship_template;
    P<PlayerSpaceship> playerSpaceship = ship;

    const float room_size = 48.0f;
    for(unsigned int n=0; n<st->rooms.size(); n++)
    {
        sf::RectangleShape room(sf::Vector2f(st->rooms[n].size) * room_size - sf::Vector2f(4, 4));
        room.setPosition(position + sf::Vector2f(st->rooms[n].position) * room_size + sf::Vector2f(4, 4));
        room.setFillColor(sf::Color(96, 96, 96, 255));
        if (st->rooms[n].system != SYS_None && ship->hasSystem(st->rooms[n].system))
        {
            float f = 1.0;
            if (playerSpaceship)
            {
                f = std::max(0.0f, playerSpaceship->systems[st->rooms[n].system].health);
            }
            if (st->rooms[n].system == highlight_system)
            {
                room.setFillColor(sf::Color(127 + 128 * (1.0 - f), 128 * f, 32 * f, 255));
            }else{
                room.setFillColor(sf::Color(96 + 128 * (1.0 - f), 96 * f, 96 * f, 255));
            }
        }
        room.setOutlineColor(sf::Color(192, 192, 192, 255));
        room.setOutlineThickness(4.0);
        window.draw(room);
        if (st->rooms[n].system != SYS_None && ship->hasSystem(st->rooms[n].system))
        {
            sf::Sprite sprite;
            switch(st->rooms[n].system)
            {
            case SYS_Reactor:
                textureManager.setTexture(sprite, "icon_generator.png");
                break;
            case SYS_BeamWeapons:
                textureManager.setTexture(sprite, "icon_beam.png");
                break;
            case SYS_MissileSystem:
                textureManager.setTexture(sprite, "icon_missile.png");
                break;
            case SYS_Maneuver:
                textureManager.setTexture(sprite, "icon_maneuver.png");
                break;
            case SYS_Impulse:
                textureManager.setTexture(sprite, "icon_impulse.png");
                break;
            case SYS_Warp:
            case SYS_JumpDrive:
                textureManager.setTexture(sprite, "icon_warp.png");
                break;
            case SYS_FrontShield:
                textureManager.setTexture(sprite, "icon_front_shield.png");
                break;
            case SYS_RearShield:
                textureManager.setTexture(sprite, "icon_rear_shield.png");
                break;
            default:
                textureManager.setTexture(sprite, "particle.png");
                break;
            }
            sprite.setPosition(position + sf::Vector2f(st->rooms[n].position) * room_size + sf::Vector2f(st->rooms[n].size) * room_size / 2.0f + sf::Vector2f(2, 2));
            window.draw(sprite);
        }
    }
    for(unsigned int n=0; n<st->doors.size(); n++)
    {
        sf::RectangleShape door;
        if (st->doors[n].horizontal)
        {
            door.setSize(sf::Vector2f(room_size - 8.0, 4.0));
            door.setPosition(position + sf::Vector2f(st->doors[n].position) * room_size + sf::Vector2f(6, 0));
        }else{
            door.setSize(sf::Vector2f(4.0, room_size - 8.0));
            door.setPosition(position + sf::Vector2f(st->doors[n].position) * room_size + sf::Vector2f(0, 6));
        }
        door.setFillColor(sf::Color(255, 128, 32, 255));
        window.draw(door);
    }
}

void MainUIBase::drawUILine(sf::Vector2f start, sf::Vector2f end, float x_split)
{
    float x_vert = x_split;
    float y_offset = std::max(-16.0f, std::min(16.0f, (start.y - end.y) / 2.0f));
    float x_offset_end = fabs(y_offset);
    float x_offset_start = fabs(y_offset);
    if (end.x < x_split)
        x_offset_end = -x_offset_end;
    if (start.x < x_split)
        x_offset_start = -x_offset_start;
    sf::VertexArray ui_line(sf::LinesStrip, 6);
    ui_line[5].position = end;
    ui_line[4].position = sf::Vector2f(x_vert + x_offset_end, end.y);
    ui_line[3].position = sf::Vector2f(x_vert, end.y + y_offset);
    ui_line[2].position = sf::Vector2f(x_vert, start.y - y_offset);
    ui_line[1].position = sf::Vector2f(x_vert + x_offset_start, start.y);
    ui_line[0].position = start;
    ui_line[0].color = ui_line[1].color = ui_line[2].color = ui_line[3].color = ui_line[4].color = ui_line[5].color = sf::Color(128, 128, 128);
    getRenderTarget()->draw(ui_line);
}

void MainUIBase::draw3Dworld(sf::FloatRect rect)
{
    if (my_spaceship)
        soundManager.setListenerPosition(my_spaceship->getPosition(), my_spaceship->getRotation());
    else
        soundManager.setListenerPosition(sf::Vector2f(camera_position.x, camera_position.y), camera_yaw);
    sf::RenderTarget& window = *getRenderTarget();
    window.pushGLStates();
    
    billboardShader.setParameter("camera_position", camera_position);

    float camera_fov = 60.0f;
    float sx = window.getSize().x * window.getView().getViewport().width / getWindowSize().x;
    float sy = window.getSize().y * window.getView().getViewport().height / getWindowSize().y;
    glViewport(rect.left * sx, rect.top * sy, rect.width * sx, rect.height * sy);

    glClearDepth(1.f);
    glClear(GL_DEPTH_BUFFER_BIT);
    glDepthMask(GL_TRUE);
    glEnable(GL_CULL_FACE);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(camera_fov, rect.width/rect.height, 1.f, 16000.f);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glRotatef(90, 1, 0, 0);
    glScalef(1,1,-1);
    glRotatef(-camera_pitch, 1, 0, 0);
    glRotatef(-camera_yaw - 90, 0, 0, 1);

    sf::Texture::bind(textureManager.getTexture("Stars"), sf::Texture::Pixels);
    glDepthMask(false);
    glBegin(GL_TRIANGLE_STRIP);
    glTexCoord2f(1024,    0); glVertex3f( 100, 100, 100);
    glTexCoord2f(   0,    0); glVertex3f( 100, 100,-100);
    glTexCoord2f(1024, 1024); glVertex3f(-100, 100, 100);
    glTexCoord2f(   0, 1024); glVertex3f(-100, 100,-100);
    glEnd();
    glBegin(GL_TRIANGLE_STRIP);
    glTexCoord2f(1024,    0); glVertex3f(-100, 100, 100);
    glTexCoord2f(   0,    0); glVertex3f(-100, 100,-100);
    glTexCoord2f(1024, 1024); glVertex3f(-100,-100, 100);
    glTexCoord2f(   0, 1024); glVertex3f(-100,-100,-100);
    glEnd();
    glBegin(GL_TRIANGLE_STRIP);
    glTexCoord2f(1024,    0); glVertex3f(-100,-100, 100);
    glTexCoord2f(   0,    0); glVertex3f(-100,-100,-100);
    glTexCoord2f(1024, 1024); glVertex3f( 100,-100, 100);
    glTexCoord2f(   0, 1024); glVertex3f( 100,-100,-100);
    glEnd();
    glBegin(GL_TRIANGLE_STRIP);
    glTexCoord2f(1024,    0); glVertex3f( 100,-100, 100);
    glTexCoord2f(   0,    0); glVertex3f( 100,-100,-100);
    glTexCoord2f(1024, 1024); glVertex3f( 100, 100, 100);
    glTexCoord2f(   0, 1024); glVertex3f( 100, 100,-100);
    glEnd();
    glBegin(GL_TRIANGLE_STRIP);
    glTexCoord2f(1024,    0); glVertex3f( 100,-100, 100);
    glTexCoord2f(   0,    0); glVertex3f(-100,-100, 100);
    glTexCoord2f(1024, 1024); glVertex3f( 100, 100, 100);
    glTexCoord2f(   0, 1024); glVertex3f(-100, 100, 100);
    glEnd();
    glBegin(GL_TRIANGLE_STRIP);
    glTexCoord2f(1024,    0); glVertex3f( 100,-100,-100);
    glTexCoord2f(   0,    0); glVertex3f(-100,-100,-100);
    glTexCoord2f(1024, 1024); glVertex3f( 100, 100,-100);
    glTexCoord2f(   0, 1024); glVertex3f(-100, 100,-100);
    glEnd();

    if (gameGlobalInfo)
    {
        for(int n=0; n<GameGlobalInfo::maxNebula; n++)
        {
            sf::Texture::bind(textureManager.getTexture(gameGlobalInfo->nebulaInfo[n].textureName), sf::Texture::Pixels);
            glEnable(GL_BLEND);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE);
            glPushMatrix();
            glRotatef(180, gameGlobalInfo->nebulaInfo[n].vector.x, gameGlobalInfo->nebulaInfo[n].vector.y, gameGlobalInfo->nebulaInfo[n].vector.z);
            glColor4f(1,1,1,0.1);
            glBegin(GL_TRIANGLE_STRIP);
            glTexCoord2f(1024,    0); glVertex3f( 100, 100, 100);
            glTexCoord2f(   0,    0); glVertex3f( 100, 100,-100);
            glTexCoord2f(1024, 1024); glVertex3f(-100, 100, 100);
            glTexCoord2f(   0, 1024); glVertex3f(-100, 100,-100);
            glEnd();
            glPopMatrix();
        }
    }
    glColor4f(1,1,1,1);
    glDisable(GL_BLEND);
    sf::Texture::bind(NULL);
    glDepthMask(true);
    glEnable(GL_DEPTH_TEST);

    {
        float lightpos1[4] = {0, 0, 0, 1.0};
        glLightfv(GL_LIGHT1, GL_POSITION, lightpos1);
        
        float lightpos0[4] = {20000, 20000, 20000, 1.0};
        glLightfv(GL_LIGHT0, GL_POSITION, lightpos0);
    }

    PVector<SpaceObject> renderList;
    sf::Vector2f viewVector = sf::vector2FromAngle(camera_yaw);
    float depth_cutoff_back = camera_position.z * -tanf((90+camera_pitch + camera_fov/2.0) / 180.0f * M_PI);
    float depth_cutoff_front = camera_position.z * -tanf((90+camera_pitch - camera_fov/2.0) / 180.0f * M_PI);
    if (camera_pitch - camera_fov/2.0 <= 0.0)
        depth_cutoff_front = std::numeric_limits<float>::infinity();
    if (camera_pitch + camera_fov/2.0 >= 180.0)
        depth_cutoff_back = -std::numeric_limits<float>::infinity();
    foreach(SpaceObject, obj, space_object_list)
    {
        float depth = sf::dot(viewVector, obj->getPosition() - sf::Vector2f(camera_position.x, camera_position.y));
        if (depth + obj->getRadius() < depth_cutoff_back)
            continue;
        if (depth - obj->getRadius() > depth_cutoff_front)
            continue;
        if (depth > 0 && obj->getRadius() / depth < 1.0 / 500)
            continue;
        renderList.push_back(obj);
    }

    foreach(SpaceObject, obj, renderList)
    {
        glPushMatrix();
        glTranslatef(-camera_position.x,-camera_position.y, -camera_position.z);
        glTranslatef(obj->getPosition().x, obj->getPosition().y, 0);
        glRotatef(obj->getRotation(), 0, 0, 1);

        obj->draw3D();
        glPopMatrix();
    }
    sf::Shader::bind(NULL);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);
    glDisable(GL_CULL_FACE);
    glDepthMask(false);
    foreach(SpaceObject, obj, renderList)
    {
        glPushMatrix();
        glTranslatef(-camera_position.x,-camera_position.y, -camera_position.z);
        glTranslatef(obj->getPosition().x, obj->getPosition().y, 0);
        glRotatef(obj->getRotation(), 0, 0, 1);

        obj->draw3DTransparent();
        glPopMatrix();
    }

    glPushMatrix();
    glTranslatef(-camera_position.x,-camera_position.y, -camera_position.z);
    ParticleEngine::render();
    glPopMatrix();

    if (my_spaceship && my_spaceship->getTarget())
    {
        P<SpaceObject> target = my_spaceship->getTarget();
        glDisable(GL_DEPTH_TEST);
        glPushMatrix();
        glTranslatef(-camera_position.x,-camera_position.y, -camera_position.z);
        glTranslatef(target->getPosition().x, target->getPosition().y, 0);

        billboardShader.setParameter("textureMap", *textureManager.getTexture("redicule2.png"));
        sf::Shader::bind(&billboardShader);
        glBegin(GL_QUADS);
        glColor4f(0.5, 0.5, 0.5, target->getRadius() * 2.5);
        glTexCoord2f(0, 0);
        glVertex3f(0, 0, 0);
        glTexCoord2f(1, 0);
        glVertex3f(0, 0, 0);
        glTexCoord2f(1, 1);
        glVertex3f(0, 0, 0);
        glTexCoord2f(0, 1);
        glVertex3f(0, 0, 0);
        glEnd();
        glPopMatrix();
    }

    glDepthMask(true);
    glDisable(GL_BLEND);
    glEnable(GL_CULL_FACE);
    sf::Shader::bind(NULL);
    glColor3f(1, 1, 1);

#ifdef DEBUG
    glDisable(GL_DEPTH_TEST);
    foreach(SpaceObject, obj, space_object_list)
    {
        glPushMatrix();
        glTranslatef(-camera_position.x,-camera_position.y, -camera_position.z);
        glTranslatef(obj->getPosition().x, obj->getPosition().y, 0);
        glRotatef(obj->getRotation(), 0, 0, 1);

        std::vector<sf::Vector2f> collisionShape = obj->getCollisionShape();
        glBegin(GL_LINE_LOOP);
        for(unsigned int n=0; n<collisionShape.size(); n++)
            glVertex3f(collisionShape[n].x, collisionShape[n].y, 0);
        glEnd();
        glPopMatrix();
    }
#endif

    window.popGLStates();
}
