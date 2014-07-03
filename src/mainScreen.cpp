#include <SFML/OpenGL.hpp>
#include "mainScreen.h"
#include "shipSelectionScreen.h"
#include "particleEffect.h"
#include "main.h"

MainScreenUI::MainScreenUI()
{
    P<MouseRenderer> mouseRenderer = engine->getObject("mouseRenderer");
    mouseRenderer->visible = false;
}

void MainScreenUI::onGui()
{
    if (mySpaceship)
    {
        switch(mySpaceship->mainScreenSetting)
        {
        case MSS_Front:
        case MSS_Back:
        case MSS_Left:
        case MSS_Right:
            render3dView(*getRenderTarget());
            break;
        case MSS_Tactical:
            renderTactical(*getRenderTarget());
            break;
        case MSS_LongRange:
            renderLongRange(*getRenderTarget());
            break;
        }
    }else{
        render3dView(*getRenderTarget());
    }
    
    MainUI::onGui();
}

void MainScreenUI::destroy()
{
    P<MouseRenderer> mouseRenderer = engine->getObject("mouseRenderer");
    mouseRenderer->visible = true;
    MainUI::destroy();
}

void MainScreenUI::render3dView(sf::RenderTarget& window)
{
    window.pushGLStates();

    glClearDepth(1.f);
    glClear(GL_DEPTH_BUFFER_BIT);
    glDepthMask(GL_TRUE);
    glEnable(GL_CULL_FACE);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(60.f, 1600.0/900.0, 1.f, 16000.f);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glRotatef(90, 1, 0, 0);
    glScalef(1,1,-1);
    glRotatef(-25, 1, 0, 0);
#ifdef DEBUG
    if (sf::Keyboard::isKeyPressed(sf::Keyboard::Z))
        glRotatef(-50, 1, 0, 0);
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
        sf::Vector2f cameraPosition2D = mySpaceship->getPosition() + sf::vector2FromAngle(cameraRotation) * -300.0f;
        sf::Vector3f targetCameraPosition(cameraPosition2D.x, cameraPosition2D.y, 300);
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

void MainScreenUI::renderTactical(sf::RenderTarget& window)
{
    float radarDistance = 5000;
    drawRaderBackground(mySpaceship->getPosition(), sf::Vector2f(800, 450), 400, 400.0f / radarDistance);

    foreach(SpaceObject, obj, spaceObjectList)
    {
        if (obj != mySpaceship && sf::length(obj->getPosition() - mySpaceship->getPosition()) < radarDistance)
            obj->drawRadar(window, sf::Vector2f(800, 450) + (obj->getPosition() - mySpaceship->getPosition()) / radarDistance * 400.0f, 400.0f / radarDistance, false);
    }
    
    mySpaceship->drawRadar(window, sf::Vector2f(800, 450), 400.0f / radarDistance, false);
    drawHeadingCircle(sf::Vector2f(800, 450), 400);
}

void MainScreenUI::renderLongRange(sf::RenderTarget& window)
{
    float radarDistance = 50000;
    drawRaderBackground(mySpaceship->getPosition(), sf::Vector2f(800, 450), 800, 400.0f / radarDistance);

    foreach(SpaceObject, obj, spaceObjectList)
    {
        if (obj != mySpaceship && sf::length(obj->getPosition() - mySpaceship->getPosition()) < radarDistance)
            obj->drawRadar(window, sf::Vector2f(800, 450) + (obj->getPosition() - mySpaceship->getPosition()) / radarDistance * 400.0f, 400.0f / radarDistance, true);
    }
    
    P<SpaceObject> target = mySpaceship->getTarget();
    if (target)
    {
        sf::Sprite objectSprite;
        textureManager.setTexture(objectSprite, "redicule.png");
        objectSprite.setPosition(sf::Vector2f(800, 450) + (target->getPosition() - mySpaceship->getPosition()) / radarDistance * 400.0f);
        window.draw(objectSprite);
    }
    mySpaceship->drawRadar(window, sf::Vector2f(800, 450), 400.0f / radarDistance, true);
    drawHeadingCircle(sf::Vector2f(800, 450), 400);
}
