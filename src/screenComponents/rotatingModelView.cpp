#include <GL/glew.h>
#include <SFML/OpenGL.hpp>

#include "featureDefs.h"
#include "rotatingModelView.h"

#include "glObjects.h"
#include "shaderRegistry.h"

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

    window.setActive();

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

    glDisable(GL_BLEND);
    sf::Texture::bind(NULL);
    glDepthMask(true);
    glEnable(GL_DEPTH_TEST);

    glTranslatef(0, -200, 0);
    glRotatef(-30, 1, 0, 0);
    glRotatef(engine->getElapsedTime() * 360.0f / 10.0f, 0.0f, 0.0f, 1.0f);
    {
        float scale = 100.0f / model->getRadius();
        glScalef(scale, scale, scale);
        model->render();
#ifdef DEBUG
        ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::BasicColor);
        {
            // Common state - matrices.
            std::array<float, 16> matrix;
            glGetFloatv(GL_PROJECTION_MATRIX, matrix.data());
            glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Projection), 1, GL_FALSE, matrix.data());

            glGetFloatv(GL_MODELVIEW_MATRIX, matrix.data());
            glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::ModelView), 1, GL_FALSE, matrix.data());

            // Vertex attrib
            gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));

            for (const EngineEmitterData& ee : model->engine_emitters)
            {
                sf::Vector3f offset = ee.position * model->scale;
                float r = model->scale * ee.scale * 0.5;

                glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), ee.color.x, ee.color.y, ee.color.z, 1.f);
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
            
            glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), 1.f, 1.f, 1.f, 1.f);

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
    glDisable(GL_DEPTH_TEST);

    window.resetGLStates();
    window.setActive(false);
#endif//FEATURE_3D_RENDERING
}
