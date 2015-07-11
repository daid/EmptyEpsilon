#include <SFML/OpenGL.hpp>

#include "rotatingModelView.h"

GuiRotatingModelView::GuiRotatingModelView(GuiContainer* owner, string id, P<ModelData> model)
: GuiElement(owner, id), model(model)
{
}

void GuiRotatingModelView::onDraw(sf::RenderTarget& window)
{
    if (rect.height <= 0) return;
    if (rect.width <= 0) return;
    if (!model) return;
    
    window.pushGLStates();

    float camera_fov = 60.0f;
    float sx = window.getSize().x * window.getView().getViewport().width / window.getView().getSize().x;
    float sy = window.getSize().y * window.getView().getViewport().height / window.getView().getSize().y;
    glViewport(rect.left * sx, (float(window.getView().getSize().y) - rect.height - rect.top) * sx, rect.width * sx, rect.height * sy);

    glClearDepth(1.f);
    glClear(GL_DEPTH_BUFFER_BIT);
    glDepthMask(GL_TRUE);
    glEnable(GL_CULL_FACE);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(camera_fov, rect.width/rect.height, 1.f, 25000.f);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glRotatef(90, 1, 0, 0);
    glScalef(1,1,-1);

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

    glTranslatef(0, -200, 0);
    glRotatef(-30, 1, 0, 0);
    glRotatef(engine->getElapsedTime() * 360.0f / 10.0f, 0.0f, 0.0f, 1.0f);
    {
        float scale = 100.0f / model->getRadius();
        glScalef(scale, scale, scale);
        model->render();
    }
    
    sf::Shader::bind(NULL);
    glDisable(GL_DEPTH_TEST);

    window.popGLStates();
}
