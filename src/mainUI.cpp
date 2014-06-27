#include "mainUI.h"
#include "main.h"
#include "shipSelectionScreen.h"
#include "repairCrew.h"

void MainUI::onGui()
{
    if (sf::Keyboard::isKeyPressed(sf::Keyboard::Escape) || sf::Keyboard::isKeyPressed(sf::Keyboard::BackSpace))
    {
        destroy();
        new ShipSelectionScreen();
    }
    
    if (gameServer)
    {
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Space))
            engine->setGameSpeed(1.0);
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::P))
            engine->setGameSpeed(0.0);
#ifdef DEBUG
        text(sf::FloatRect(0, 0, 1600 - 5, 20), string(gameServer->getSendDataRate()) + " bytes per second", AlignRight, 15);
#endif
    }
    
    if (mySpaceship)
    {
        if (mySpaceship->hull_damage_indicator > 0.0)
        {
            sf::RectangleShape fullScreenOverlay(sf::Vector2f(1600, 900));
            fullScreenOverlay.setFillColor(sf::Color(255, 0, 0, 255 * mySpaceship->hull_damage_indicator));
            getRenderTarget()->draw(fullScreenOverlay);
        }
        
        if (mySpaceship->warp_indicator > 0.0)
        {
            if (mySpaceship->warp_indicator > 1.0)
            {
                sf::RectangleShape fullScreenOverlay(sf::Vector2f(1600, 900));
                fullScreenOverlay.setFillColor(sf::Color(0, 0, 0, 255 * (mySpaceship->warp_indicator - 1.0)));
                getRenderTarget()->draw(fullScreenOverlay);
            }
            glitchPostProcessor->enabled = true;
            glitchPostProcessor->setUniform("magtitude", mySpaceship->warp_indicator * 10.0);
            glitchPostProcessor->setUniform("delta", random(0, 360));
        }else{
            glitchPostProcessor->enabled = false;
        }
    }else{
        glitchPostProcessor->enabled = false;
    }
    
    if (engine->getGameSpeed() == 0.0)
    {
        text(sf::FloatRect(0, 600, 1600, 100), "Game Paused", AlignCenter, 70);
        if (gameServer)
            text(sf::FloatRect(0, 680, 1600, 30), "(Press [SPACE] to resume)", AlignCenter, 30);
    }
}

void MainUI::mainScreenSelectGUI()
{
    if (button(sf::FloatRect(1400, 40, 200, 40), "Front", 30))
        mySpaceship->commandMainScreenSetting(MSS_Front);
    if (button(sf::FloatRect(1400, 80, 200, 40), "Back", 30))
        mySpaceship->commandMainScreenSetting(MSS_Back);
    if (button(sf::FloatRect(1400, 120, 200, 40), "Left", 30))
        mySpaceship->commandMainScreenSetting(MSS_Left);
    if (button(sf::FloatRect(1400, 160, 200, 40), "Right", 30))
        mySpaceship->commandMainScreenSetting(MSS_Right);
    if (button(sf::FloatRect(1400, 200, 200, 40), "Tactical", 30))
        mySpaceship->commandMainScreenSetting(MSS_Tactical);
    if (button(sf::FloatRect(1400, 240, 200, 40), "Long-Range", 30))
        mySpaceship->commandMainScreenSetting(MSS_LongRange);
}

void MainUI::drawStatic(float alpha)
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

void MainUI::drawRaderBackground(sf::Vector2f view_position, sf::Vector2f position, float size, float scale)
{
    const float sector_size = 20000;
    const float sub_sector_size = sector_size / 8;
    
    int sector_x_min = int((view_position.x - (size / scale)) / sector_size) - 1;
    int sector_x_max = int((view_position.x + (size / scale)) / sector_size);
    int sector_y_min = int((view_position.y - (size / scale)) / sector_size) - 1;
    int sector_y_max = int((view_position.y + (size / scale)) / sector_size);
    sf::VertexArray lines_x(sf::Lines, 2 * (sector_x_max - sector_x_min + 1));
    sf::VertexArray lines_y(sf::Lines, 2 * (sector_y_max - sector_y_min + 1));
    sf::Color color(64, 64, 128, 128);
    for(int sector_x = sector_x_min; sector_x <= sector_x_max; sector_x++)
    {
        float x = position.x + ((sector_x * sector_size) - view_position.x) * scale;
        lines_x[(sector_x - sector_x_min)*2].position = sf::Vector2f(x, 0);
        lines_x[(sector_x - sector_x_min)*2].color = color;
        lines_x[(sector_x - sector_x_min)*2+1].position = sf::Vector2f(x, 900);
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
        lines_y[(sector_y - sector_y_min)*2].position = sf::Vector2f(0, y);
        lines_y[(sector_y - sector_y_min)*2].color = color;
        lines_y[(sector_y - sector_y_min)*2+1].position = sf::Vector2f(1600, y);
        lines_y[(sector_y - sector_y_min)*2+1].color = color;
    }
    getRenderTarget()->draw(lines_x);
    getRenderTarget()->draw(lines_y);
    
    int sub_sector_x_min = int((view_position.x - (size / scale)) / sub_sector_size) - 1;
    int sub_sector_x_max = int((view_position.x + (size / scale)) / sub_sector_size);
    int sub_sector_y_min = int((view_position.y - (size / scale)) / sub_sector_size) - 1;
    int sub_sector_y_max = int((view_position.y + (size / scale)) / sub_sector_size);
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

void MainUI::drawHeadingCircle(sf::Vector2f position, float size)
{
    sf::RenderTarget& window = *getRenderTarget();
    
    sf::VertexArray tigs(sf::Lines, 360/20*2);
    for(unsigned int n=0; n<360; n+=20)
    {
        tigs[n/20*2].position = position + sf::vector2FromAngle(float(n)) * size;
        tigs[n/20*2+1].position = position + sf::vector2FromAngle(float(n)) * (size - 20);
    }
    window.draw(tigs);
    sf::VertexArray smallTigs(sf::Lines, 360/5*2);
    for(unsigned int n=0; n<360; n+=5)
    {
        smallTigs[n/5*2].position = position + sf::vector2FromAngle(float(n)) * size;
        smallTigs[n/5*2+1].position = position + sf::vector2FromAngle(float(n)) * (size - 10);
    }
    window.draw(smallTigs);
    for(unsigned int n=0; n<360; n+=20)
    {
        sf::Text text(string(n), mainFont, 15);
        text.setPosition(position + sf::vector2FromAngle(float(n)) * (size - 25));
        text.setOrigin(text.getLocalBounds().width / 2.0, text.getLocalBounds().height / 2.0);
        text.setRotation(n);
        window.draw(text);
    }
    sf::Sprite cutOff;
    textureManager.setTexture(cutOff, "radarCutoff.png");
    cutOff.setPosition(position);
    cutOff.setScale(size / float(cutOff.getTextureRect().width) * 2.1, size / float(cutOff.getTextureRect().width) * 2.1);
    window.draw(cutOff);
    
    sf::RectangleShape rectH(sf::Vector2f(1600, position.y - size * 1.05));
    rectH.setFillColor(sf::Color::Black);
    window.draw(rectH);
    rectH.setPosition(0, position.y + size * 1.05);
    window.draw(rectH);
    sf::RectangleShape rectV(sf::Vector2f(position.x - size * 1.05, 900));
    rectV.setFillColor(sf::Color::Black);
    window.draw(rectV);
    rectV.setPosition(position.x + size * 1.05, 0);
    window.draw(rectV);
}

void MainUI::drawShipInternals(sf::Vector2f position, P<SpaceShip> ship, ESystem highlight_system)
{
    if (!ship || !ship->shipTemplate) return;
    sf::RenderTarget& window = *getRenderTarget();
    P<ShipTemplate> st = ship->shipTemplate;
    
    const float room_size = 48.0f;
    for(unsigned int n=0; n<st->rooms.size(); n++)
    {
        sf::RectangleShape room(sf::Vector2f(st->rooms[n].size) * room_size - sf::Vector2f(4, 4));
        room.setPosition(position + sf::Vector2f(st->rooms[n].position) * room_size + sf::Vector2f(4, 4));
        room.setFillColor(sf::Color(96, 96, 96, 255));
        if (st->rooms[n].system == highlight_system && highlight_system != SYS_None)
            room.setFillColor(sf::Color(128, 128, 32, 255));
        room.setOutlineColor(sf::Color(192, 192, 192, 255));
        room.setOutlineThickness(4.0);
        window.draw(room);
        if (st->rooms[n].system != SYS_None && ship->hasSystem(ESystem(n)))
        {
            sf::Sprite sprite;
            textureManager.setTexture(sprite, "redicule.png");
            sprite.setScale(0.7, 0.7);
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
