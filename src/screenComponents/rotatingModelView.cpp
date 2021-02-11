#include <GL/glew.h>
#include <SFML/OpenGL.hpp>

#include "featureDefs.h"
#include "rotatingModelView.h"

#include "glObjects.h"

#include <array>

#if FEATURE_3D_RENDERING
static void _glPerspective(double fovY, double aspect, double zNear, double zFar )
{
    const double pi = 3.1415926535897932384626433832795;
    double fW, fH;

    fH = tan(fovY / 360 * pi) * zNear;
    fW = fH * aspect;

    glFrustum(-fW, fW, -fH, fH, zNear, zFar);
}
#endif//FEATURE_3D_RENDERING

GuiRotatingModelView::GuiRotatingModelView(GuiContainer* owner, string id, P<ModelData> model)
: GuiElement(owner, id), model(model)
{
}

void GuiRotatingModelView::onDraw(sf::RenderTarget& window)
{
#if FEATURE_3D_RENDERING
    if (rect.height <= 0) return;
    if (rect.width <= 0) return;
    if (!model) return;

    window.popGLStates();

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
    _glPerspective(camera_fov, rect.width/rect.height, 1.f, 25000.f);

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
#ifdef DEBUG
        auto debug_shader = ShaderManager::getShader("shaders/basicColor");
        sf::Shader::bind(debug_shader);
        {
            // Common state - matrices.
            std::array<float, 16> matrix;
            glGetFloatv(GL_PROJECTION_MATRIX, matrix.data());
            glUniformMatrix4fv(glGetUniformLocation(debug_shader->getNativeHandle(), "projection"), 1, GL_FALSE, matrix.data());

            glGetFloatv(GL_MODELVIEW_MATRIX, matrix.data());
            glUniformMatrix4fv(glGetUniformLocation(debug_shader->getNativeHandle(), "model_view"), 1, GL_FALSE, matrix.data());

            // Vertex attrib
            gl::ScopedVertexAttribArray positions(glGetAttribLocation(debug_shader->getNativeHandle(), "position"));

            for (const EngineEmitterData& ee : model->engine_emitters)
            {
                sf::Vector3f offset = ee.position * model->scale;
                float r = model->scale * ee.scale * 0.5;

                debug_shader->setUniform("color", sf::Glsl::Vec4(ee.color.x, ee.color.y, ee.color.z, 1.f));
                auto vertices = {
                    sf::Vector3f{offset.x + r, offset.y, offset.z},
                    sf::Vector3f{offset.x - r, offset.y, offset.z},
                    sf::Vector3f{offset.x, offset.y + r, offset.z},
                    sf::Vector3f{offset.x, offset.y - r, offset.z},
                    sf::Vector3f{offset.x, offset.y, offset.z + r},
                    sf::Vector3f{offset.x, offset.y, offset.z - r}
                };
                glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(sf::Vector3f), std::begin(vertices));
                glDrawArrays(GL_LINES, 0, vertices.size());
            }
            float r = model->getRadius() * 0.1f;
            debug_shader->setUniform("color", sf::Glsl::Vec4(sf::Color::White));

            for (const sf::Vector3f& position : model->beam_position)
            {
                sf::Vector3f offset = position * model->scale;

                auto vertices = {
                    sf::Vector3f{offset.x + r, offset.y, offset.z},
                    sf::Vector3f{offset.x - r, offset.y, offset.z},
                    sf::Vector3f{offset.x, offset.y + r, offset.z},
                    sf::Vector3f{offset.x, offset.y - r, offset.z},
                    sf::Vector3f{offset.x, offset.y, offset.z + r},
                    sf::Vector3f{offset.x, offset.y, offset.z - r}
                };
                glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(sf::Vector3f), std::begin(vertices));
                glDrawArrays(GL_LINES, 0, vertices.size());
            }
            
            for (const sf::Vector3f& position : model->tube_position)
            {
                sf::Vector3f offset = position * model->scale;

                auto vertices = {
                    sf::Vector3f{offset.x + r * 3, offset.y, offset.z},
                    sf::Vector3f{offset.x - r, offset.y, offset.z},
                    sf::Vector3f{offset.x, offset.y + r, offset.z},
                    sf::Vector3f{offset.x, offset.y - r, offset.z},
                    sf::Vector3f{offset.x, offset.y, offset.z + r},
                    sf::Vector3f{offset.x, offset.y, offset.z - r}
                };
                glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(sf::Vector3f), std::begin(vertices));
                glDrawArrays(GL_LINES, 0, vertices.size());
            }
        }
#endif
    }

    sf::Shader::bind(NULL);
    glDisable(GL_DEPTH_TEST);

    window.pushGLStates();
#endif//FEATURE_3D_RENDERING
}
