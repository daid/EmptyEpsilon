#include <SFML/OpenGL.hpp>
#include "mainUIBase.h"
#include "mainMenus.h"
#include "epsilonServer.h"
#include "main.h"
#include "particleEffect.h"
#include "shipSelectionScreen.h"
#include "repairCrew.h"

void MainUIBase::onGui()
{
    if (gameClient && !gameClient->isConnected())
    {
        destroy();
        disconnectFromServer();
        new MainMenu();
        return;
    }
    
    if (sf::Keyboard::isKeyPressed(sf::Keyboard::Escape) || sf::Keyboard::isKeyPressed(sf::Keyboard::Home))
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
        text(sf::FloatRect(0, 0, 1600 - 5, 20), string(gameServer->getSendDataRate() / 1000) + " kb per second", AlignRight, 15);
        text(sf::FloatRect(0, 20, 1600 - 5, 20), string(gameServer->getSendDataRatePerClient() / 1000) + " kb per client", AlignRight, 15);
#endif
    }
    
    if (mySpaceship)
    {
        soundManager.setListenerPosition(mySpaceship->getPosition(), mySpaceship->getRotation());
        
        if (mySpaceship->front_shield < mySpaceship->front_shield_max / 10.0 || mySpaceship->rear_shield < mySpaceship->rear_shield_max / 10.0)
        {
            sf::RectangleShape fullScreenOverlay(sf::Vector2f(1600, 900));
            float f = fabsf(fmodf(engine->getElapsedTime() * 2.0, 2.0) - 1.0);
            fullScreenOverlay.setFillColor(sf::Color(255, 0, 0, 16 + 32 * f));
            getRenderTarget()->draw(fullScreenOverlay);
        }
        if (mySpaceship->hull_damage_indicator > 0.0)
        {
            sf::RectangleShape fullScreenOverlay(sf::Vector2f(1600, 900));
            fullScreenOverlay.setFillColor(sf::Color(255, 0, 0, 128 * (mySpaceship->hull_damage_indicator / 1.5)));
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

void MainUIBase::mainScreenSelectGUI()
{
    if (button(sf::FloatRect(1400, 40, 200, 40), "Front", 28))
        mySpaceship->commandMainScreenSetting(MSS_Front);
    if (button(sf::FloatRect(1400, 80, 200, 40), "Back", 28))
        mySpaceship->commandMainScreenSetting(MSS_Back);
    if (button(sf::FloatRect(1400, 120, 200, 40), "Left", 28))
        mySpaceship->commandMainScreenSetting(MSS_Left);
    if (button(sf::FloatRect(1400, 160, 200, 40), "Right", 28))
        mySpaceship->commandMainScreenSetting(MSS_Right);
    if (button(sf::FloatRect(1400, 200, 200, 40), "Tactical", 28))
        mySpaceship->commandMainScreenSetting(MSS_Tactical);
    if (button(sf::FloatRect(1400, 240, 200, 40), "Long-Range", 28))
        mySpaceship->commandMainScreenSetting(MSS_LongRange);
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

void MainUIBase::drawRaderBackground(sf::Vector2f view_position, sf::Vector2f position, float size, float scale, sf::FloatRect rect)
{
    const float sector_size = 20000;
    const float sub_sector_size = sector_size / 8;
    
    int sector_x_min = floor((view_position.x - (size / scale)) / sector_size) + 1;
    int sector_x_max = floor((view_position.x + (size / scale)) / sector_size);
    int sector_y_min = floor((view_position.y - (size / scale)) / sector_size) + 1;
    int sector_y_max = floor((view_position.y + (size / scale)) / sector_size);
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
    
    int sub_sector_x_min = floor((view_position.x - (size / scale)) / sub_sector_size) + 1;
    int sub_sector_x_max = floor((view_position.x + (size / scale)) / sub_sector_size);
    int sub_sector_y_min = floor((view_position.y - (size / scale)) / sub_sector_size) + 1;
    int sub_sector_y_max = floor((view_position.y + (size / scale)) / sub_sector_size);
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
}

void MainUIBase::drawRadarCuttoff(sf::Vector2f position, float size, sf::FloatRect rect)
{
    sf::RenderTarget& window = *getRenderTarget();
    
    sf::Sprite cutOff;
    textureManager.setTexture(cutOff, "radarCutoff.png");
    cutOff.setPosition(position);
    cutOff.setScale(size / float(cutOff.getTextureRect().width) * 2.1, size / float(cutOff.getTextureRect().width) * 2.1);
    window.draw(cutOff);
    
    sf::RectangleShape rectH(sf::Vector2f(rect.width, position.y - size * 1.05 - rect.top));
    rectH.setFillColor(sf::Color::Black);
    rectH.setPosition(rect.left, rect.top);
    window.draw(rectH);
    rectH.setPosition(rect.left, position.y + size * 1.05);
    window.draw(rectH);
    
    sf::RectangleShape rectV(sf::Vector2f(position.x - size * 1.05 - rect.left, rect.height));
    rectV.setFillColor(sf::Color::Black);
    rectV.setPosition(rect.left, rect.top);
    window.draw(rectV);
    rectV.setPosition(position.x + size * 1.05, rect.top);
    window.draw(rectV);
}

void MainUIBase::drawRadar(sf::Vector2f position, float size, float range, bool long_range, P<SpaceObject> target, sf::FloatRect rect)
{
    sf::RenderTarget& window = *getRenderTarget();

    if (long_range)
        drawRaderBackground(mySpaceship->getPosition(), position, size, size / range, rect);
    foreach(SpaceObject, obj, spaceObjectList)
    {
        if (obj != mySpaceship && sf::length(obj->getPosition() - mySpaceship->getPosition()) < range)
            obj->drawRadar(window, position + (obj->getPosition() - mySpaceship->getPosition()) / range * size, size / range, long_range);
    }

    if (target)
    {
        sf::Sprite objectSprite;
        textureManager.setTexture(objectSprite, "redicule.png");
        objectSprite.setPosition(position + (target->getPosition() - mySpaceship->getPosition()) / range * size);
        window.draw(objectSprite);
    }
    mySpaceship->drawRadar(window, position, size / range, long_range);
    drawHeadingCircle(position, size, rect);
    drawRadarCuttoff(position, size, rect);
}

void MainUIBase::drawShipInternals(sf::Vector2f position, P<SpaceShip> ship, ESystem highlight_system)
{
    if (!ship || !ship->shipTemplate) return;
    sf::RenderTarget& window = *getRenderTarget();
    P<ShipTemplate> st = ship->shipTemplate;
    P<PlayerSpaceship> playerSpaceship = ship;
    
    const float room_size = 48.0f;
    for(unsigned int n=0; n<st->rooms.size(); n++)
    {
        sf::RectangleShape room(sf::Vector2f(st->rooms[n].size) * room_size - sf::Vector2f(4, 4));
        room.setPosition(position + sf::Vector2f(st->rooms[n].position) * room_size + sf::Vector2f(4, 4));
        room.setFillColor(sf::Color(96, 96, 96, 255));
        if (st->rooms[n].system != SYS_None && ship->hasSystem(ESystem(n)))
        {
            float f = 1.0;
            if (playerSpaceship)
                f = playerSpaceship->systems[st->rooms[n].system].health;
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

static float camera_ship_angle = 30.0f;
static float camera_ship_distance = 420.0f;
static float camera_ship_height = 420.0f;

void MainUIBase::draw3Dworld(sf::FloatRect rect)
{
    sf::RenderTarget& window = *getRenderTarget();
    window.pushGLStates();

    float sx = window.getSize().x * window.getView().getViewport().width / 1600.0f;
    float sy = window.getSize().y * window.getView().getViewport().height / 900.0f;
    glViewport(rect.left * sx, rect.top * sy, rect.width * sx, rect.height * sy);
    
    glClearDepth(1.f);
    glClear(GL_DEPTH_BUFFER_BIT);
    glDepthMask(GL_TRUE);
    glEnable(GL_CULL_FACE);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(60.f, rect.width/rect.height, 1.f, 16000.f);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glRotatef(90, 1, 0, 0);
    glScalef(1,1,-1);
    glRotatef(-camera_ship_angle, 1, 0, 0);
#ifdef DEBUG
    if (sf::Keyboard::isKeyPressed(sf::Keyboard::Z))
        glRotatef(-50, 1, 0, 0);
    /*
    if (sf::Keyboard::isKeyPressed(sf::Keyboard::E)) camera_ship_angle += 1.0;
    if (sf::Keyboard::isKeyPressed(sf::Keyboard::D)) camera_ship_angle -= 1.0;
    if (sf::Keyboard::isKeyPressed(sf::Keyboard::Q)) camera_ship_height += 10.0;
    if (sf::Keyboard::isKeyPressed(sf::Keyboard::A)) camera_ship_height -= 10.0;
    if (sf::Keyboard::isKeyPressed(sf::Keyboard::W)) camera_ship_distance += 10.0;
    if (sf::Keyboard::isKeyPressed(sf::Keyboard::S)) camera_ship_distance -= 10.0;
    printf("%f %f %f\n", camera_ship_angle, camera_ship_height, camera_ship_distance);
    */
#endif
    if (mySpaceship)
    {
        cameraRotation = mySpaceship->getRotation();
#ifdef DEBUG
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Left))
            cameraRotation -= 45;
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Right))
            cameraRotation += 45;
#endif
        switch(mySpaceship->mainScreenSetting)
        {
        case MSS_Back: cameraRotation += 180; break;
        case MSS_Left: cameraRotation -= 90; break;
        case MSS_Right: cameraRotation += 90; break;
        default: break;
        }
    }
    glRotatef(-cameraRotation, 0, 0, 1);

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

    for(unsigned int n=0; n<nebulaInfo.size(); n++)
    {
        sf::Texture::bind(textureManager.getTexture(nebulaInfo[n].textureName), sf::Texture::Pixels);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE);
        glPushMatrix();
        glRotatef(180, nebulaInfo[n].vector.x, nebulaInfo[n].vector.y, nebulaInfo[n].vector.z);
        glColor4f(1,1,1,0.1);
        glBegin(GL_TRIANGLE_STRIP);
        glTexCoord2f(1024,    0); glVertex3f( 100, 100, 100);
        glTexCoord2f(   0,    0); glVertex3f( 100, 100,-100);
        glTexCoord2f(1024, 1024); glVertex3f(-100, 100, 100);
        glTexCoord2f(   0, 1024); glVertex3f(-100, 100,-100);
        glEnd();
        glPopMatrix();
    }
    glColor4f(1,1,1,1);
    glDisable(GL_BLEND);
    sf::Texture::bind(NULL);
    glDepthMask(true);
    glEnable(GL_DEPTH_TEST);
    
    if (mySpaceship)
    {
        sf::Vector2f cameraPosition2D = mySpaceship->getPosition() + sf::vector2FromAngle(cameraRotation) * -camera_ship_distance;
        sf::Vector3f targetCameraPosition(cameraPosition2D.x, cameraPosition2D.y, camera_ship_height);
#ifdef DEBUG
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Z))
            targetCameraPosition.z = 3000.0;
#endif
        cameraPosition = cameraPosition * 0.9f + targetCameraPosition * 0.1f;
    }
    
    {
        float lightpos[4] = {20000, 20000, 20000, 1.0};
        glPushMatrix();
        //glTranslatef(-cameraPosition.x,-cameraPosition.y, -cameraPosition.z);
        glLightfv(GL_LIGHT0, GL_POSITION, lightpos);
        glPopMatrix();
    }
    
    PVector<SpaceObject> renderList;
    sf::Vector2f viewVector = sf::vector2FromAngle(cameraRotation);
    foreach(SpaceObject, obj, spaceObjectList)
    {
        float depth = sf::dot(viewVector, obj->getPosition() - sf::Vector2f(cameraPosition.x, cameraPosition.y));
        if (depth < -obj->getRadius() * 2)
            continue;
        if (depth > 0 && obj->getRadius() / depth < 1.0 / 500)
            continue;
        renderList.push_back(obj);
    }

    foreach(SpaceObject, obj, renderList)
    {
        glPushMatrix();
        glTranslatef(-cameraPosition.x,-cameraPosition.y, -cameraPosition.z);
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
        glTranslatef(-cameraPosition.x,-cameraPosition.y, -cameraPosition.z);
        glTranslatef(obj->getPosition().x, obj->getPosition().y, 0);
        glRotatef(obj->getRotation(), 0, 0, 1);
        
        obj->draw3DTransparent();
        glPopMatrix();
    }

    glPushMatrix();
    glTranslatef(-cameraPosition.x,-cameraPosition.y, -cameraPosition.z);
    ParticleEngine::render();
    glPopMatrix();
    
    glDepthMask(true);
    glDisable(GL_BLEND);
    glEnable(GL_CULL_FACE);
    sf::Shader::bind(NULL);
    glColor3f(1, 1, 1);

#ifdef DEBUG
    glDisable(GL_DEPTH_TEST);
    foreach(SpaceObject, obj, spaceObjectList)
    {
        glPushMatrix();
        glTranslatef(-cameraPosition.x,-cameraPosition.y, -cameraPosition.z);
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
