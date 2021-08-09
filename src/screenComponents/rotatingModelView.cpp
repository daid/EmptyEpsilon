#include <GL/glew.h>
#include <SFML/OpenGL.hpp>

#include "featureDefs.h"
#include "rotatingModelView.h"

#include "glObjects.h"
#include "shaderRegistry.h"

#include <array>

#include <glm/glm.hpp>
#include <glm/ext/matrix_transform.hpp>
#include <glm/ext/matrix_clip_space.hpp>
#include <glm/gtc/type_ptr.hpp>

GuiRotatingModelView::GuiRotatingModelView(GuiContainer* owner, string id, P<ModelData> model)
: GuiElement(owner, id), model(model)
{
}

void GuiRotatingModelView::onDraw(sp::RenderTarget& renderer)
{
#if FEATURE_3D_RENDERING
    if (rect.size.x <= 0) return;
    if (rect.size.y <= 0) return;
    if (!model) return;

    renderer.getSFMLTarget().setActive();

    auto& window = renderer.getSFMLTarget();
    float camera_fov = 60.0f;
    float sx = window.getSize().x * window.getView().getViewport().width / window.getView().getSize().x;
    float sy = window.getSize().y * window.getView().getViewport().height / window.getView().getSize().y;
    glViewport(rect.position.x * sx, (float(window.getView().getSize().y) - rect.size.y - rect.position.y) * sx, rect.size.x * sx, rect.size.y * sy);

    glClearDepth(1.f);
    glClear(GL_DEPTH_BUFFER_BIT);
    glDepthMask(GL_TRUE);
    glEnable(GL_CULL_FACE);

    auto projection = glm::perspective(glm::radians(camera_fov), rect.size.x / rect.size.y, 1.f, 25000.f);

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

    for (auto i = 0; i < ShaderRegistry::Shaders_t(ShaderRegistry::Shaders::Count); ++i)
    {
        auto& shader = ShaderRegistry::get(ShaderRegistry::Shaders(i));
        auto projection_location = shader.uniform(ShaderRegistry::Uniforms::Projection);
        if (projection_location != -1)
        {
            auto handle = shader.get()->getNativeHandle();
            glUseProgram(handle);
            glUniformMatrix4fv(projection_location, 1, GL_FALSE, glm::value_ptr(projection));
        }
    }
    glUseProgram(GL_NONE);

    {
        float scale = 100.0f / model->getRadius();
        glScalef(scale, scale, scale);
        model->render();
#ifdef DEBUG
        ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::BasicColor);
        {
            // Common state - matrices.
            std::array<float, 16> matrix;
            glGetFloatv(GL_MODELVIEW_MATRIX, matrix.data());
            glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::ModelView), 1, GL_FALSE, matrix.data());

            // Vertex attrib
            gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));

            for (const EngineEmitterData& ee : model->engine_emitters)
            {
                glm::vec3 offset = ee.position * model->scale;
                float r = model->scale * ee.scale * 0.5;

                glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), ee.color.x, ee.color.y, ee.color.z, 1.f);
                auto vertices = {
                    glm::vec3{offset.x + r, offset.y, offset.z},
                    glm::vec3{offset.x - r, offset.y, offset.z},
                    glm::vec3{offset.x, offset.y + r, offset.z},
                    glm::vec3{offset.x, offset.y - r, offset.z},
                    glm::vec3{offset.x, offset.y, offset.z + r},
                    glm::vec3{offset.x, offset.y, offset.z - r}
                };
                glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(glm::vec3), std::begin(vertices));
                glDrawArrays(GL_LINES, 0, vertices.size());
            }
            float r = model->getRadius() * 0.1f;
            
            glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), 1.f, 1.f, 1.f, 1.f);

            for (const glm::vec3& position : model->beam_position)
            {
                glm::vec3 offset = position * model->scale;

                auto vertices = {
                    glm::vec3{offset.x + r, offset.y, offset.z},
                    glm::vec3{offset.x - r, offset.y, offset.z},
                    glm::vec3{offset.x, offset.y + r, offset.z},
                    glm::vec3{offset.x, offset.y - r, offset.z},
                    glm::vec3{offset.x, offset.y, offset.z + r},
                    glm::vec3{offset.x, offset.y, offset.z - r}
                };
                glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(glm::vec3), std::begin(vertices));
                glDrawArrays(GL_LINES, 0, vertices.size());
            }
            
            for (const glm::vec3& position : model->tube_position)
            {
                glm::vec3 offset = position * model->scale;

                auto vertices = {
                    glm::vec3{offset.x + r * 3, offset.y, offset.z},
                    glm::vec3{offset.x - r, offset.y, offset.z},
                    glm::vec3{offset.x, offset.y + r, offset.z},
                    glm::vec3{offset.x, offset.y - r, offset.z},
                    glm::vec3{offset.x, offset.y, offset.z + r},
                    glm::vec3{offset.x, offset.y, offset.z - r}
                };
                glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(glm::vec3), std::begin(vertices));
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
