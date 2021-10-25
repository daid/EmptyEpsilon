#include <graphics/opengl.h>

#include "engine.h"
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
    if (rect.size.x <= 0) return;
    if (rect.size.y <= 0) return;
    if (!model) return;
    renderer.finish();

    float camera_fov = 60.0f;
    auto p0 = renderer.virtualToPixelPosition(rect.position);
    auto p1 = renderer.virtualToPixelPosition(rect.position + rect.size);
    glViewport(p0.x, renderer.getPhysicalSize().y - p1.y, p1.x - p0.x, p1.y - p0.y);

    if (GLAD_GL_ES_VERSION_2_0)
        glClearDepthf(1.f);
    else
        glClearDepth(1.f);

    glClear(GL_DEPTH_BUFFER_BIT);
    glDepthMask(GL_TRUE);
    glEnable(GL_CULL_FACE);

    auto projection = glm::perspective(glm::radians(camera_fov), rect.size.x / rect.size.y, 1.f, 25000.f);
    auto view_matrix = glm::rotate(glm::identity<glm::mat4>(), glm::radians(90.f), glm::vec3(1.f, 0.f, 0.f));
    view_matrix = glm::scale(view_matrix, glm::vec3(1.f, 1.f, -1.f));
    view_matrix = glm::translate(view_matrix, glm::vec3(0.f, -200.f, 0.f));
    view_matrix = glm::rotate(view_matrix, glm::radians(-30.f), glm::vec3(1.f, 0.f, 0.f));
    view_matrix = glm::rotate(view_matrix, glm::radians(engine->getElapsedTime() * 360.0f / 10.0f), glm::vec3(0.f, 0.f, 1.f));

    glDisable(GL_BLEND);
    glBindTexture(GL_TEXTURE_2D, 0);
    glDepthMask(true);
    glEnable(GL_DEPTH_TEST);


    ShaderRegistry::updateProjectionView(projection, view_matrix);

    {
        float scale = 100.0f / model->getRadius();
        auto model_matrix = glm::scale(glm::identity<glm::mat4>(), glm::vec3(scale));
        model->render(model_matrix);
#ifdef DEBUG
        ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::BasicColor);
        {
            // Common state - matrices.
            glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Projection), 1, GL_FALSE, glm::value_ptr(projection));
            glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::View), 1, GL_FALSE, glm::value_ptr(view_matrix));
            glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));

            // Vertex attrib
            gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));

            for (const EngineEmitterData& ee : model->engine_emitters)
            {
                glm::vec3 offset = ee.position * model->scale;
                float r = model->scale * ee.scale * 0.5f;

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
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glViewport(0, 0, renderer.getPhysicalSize().x, renderer.getPhysicalSize().y);
}
