#include <graphics/opengl.h>

#include "engine.h"
#include "featureDefs.h"
#include "rotatingModelView.h"

#include "textureManager.h"

#include "glObjects.h"
#include "shaderRegistry.h"
#include "systems/rendering.h"

#include <array>

#include <glm/glm.hpp>
#include <glm/ext/matrix_transform.hpp>
#include <glm/ext/matrix_clip_space.hpp>
#include <glm/gtc/type_ptr.hpp>

#ifdef DEBUG
#include "gui/gui2_panel.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_label.h"
#endif

GuiRotatingModelView::GuiRotatingModelView(GuiContainer* owner, string id, sp::ecs::Entity& entity)

: GuiElement(owner, id), entity(entity)
{
}

void GuiRotatingModelView::onDraw(sp::RenderTarget& renderer)
{
    if (rect.size.x <= 0 || rect.size.y <= 0) return;

    auto mrc = entity.getComponent<MeshRenderComponent>();
    if (!mrc) return;

    renderer.finish();

    float camera_fov = 60.0f;
    auto p0 = renderer.virtualToPixelPosition(rect.position);
    auto p1 = renderer.virtualToPixelPosition(rect.position + rect.size);
    glViewport(p0.x, renderer.getPhysicalSize().y - p1.y, p1.x - p0.x, p1.y - p0.y);

    if (GLAD_GL_ES_VERSION_2_0)
        glClearDepthf(1.f);
    else
        glClearDepth(1.0);

    glClear(GL_DEPTH_BUFFER_BIT);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    glFrontFace(GL_CCW);

    auto mesh_radius = mrc->getMesh()->greatest_distance_from_center * mrc->scale;
    float near_clip_boundary = 1.f;

    float aspect_ratio = rect.size.x / rect.size.y;
    auto projection_matrix = glm::perspective(glm::radians(camera_fov), aspect_ratio, near_clip_boundary, 25000.f);

    // Calculate distance needed to fit the model in both dimensions based on
    // the element's aspect ratio.
    float vertical_fov_rad = glm::radians(camera_fov / 2.0f);
    float horizontal_fov_rad = glm::atan(glm::tan(vertical_fov_rad) * aspect_ratio);

    float view_distance = glm::max(mesh_radius / glm::tan(vertical_fov_rad), mesh_radius / glm::tan(horizontal_fov_rad)) / (desired_fill_percentage * zoom_level);

    // OpenGL standard: X across (left-to-right), Y up, Z "towards".
    auto view_matrix = glm::rotate(glm::identity<glm::mat4>(), glm::radians(90.f), glm::vec3(1.f, 0.f, 0.f)); // -> X across (l-t-r), Y "towards", Z down
    view_matrix = glm::scale(view_matrix, glm::vec3(1.f, 1.f, -1.f)); // -> X across (l-t-r), Y "towards", Z up
    view_matrix = glm::translate(view_matrix, glm::vec3(0.f, -1.f * view_distance - near_clip_boundary, 0.f));

    // Apply rotation
    if (manual_rotation_mode)
    {
        view_matrix = glm::rotate(view_matrix, glm::radians(manual_rotation_x), glm::vec3(1.f, 0.f, 0.f));
        view_matrix = glm::rotate(view_matrix, glm::radians(manual_rotation_z), glm::vec3(0.f, 0.f, 1.f));
    }
    else
    {
        view_matrix = glm::rotate(view_matrix, glm::radians(-30.f), glm::vec3(1.f, 0.f, 0.f));
        view_matrix = glm::rotate(view_matrix, glm::radians(engine->getElapsedTime() * 360.0f / 10.0f), glm::vec3(0.f, 0.f, 1.f));
    }

    glDisable(GL_BLEND);
    glBindTexture(GL_TEXTURE_2D, 0);
    glEnable(GL_DEPTH_TEST);

    ShaderRegistry::updateProjectionView(projection_matrix, view_matrix);

    auto model_matrix = calculateModelMatrix(glm::vec2{}, 0.f, mrc->mesh_offset, mrc->scale);

#ifdef DEBUG
    // Compute light direction once; used for model shading and the marker.
    // Azimuth rotates around Z; elevation tilts up from horizontal.
    const float debug_az = glm::radians(debug_light_azimuth);
    const float debug_el = glm::radians(debug_light_elevation);
    const glm::vec3 debug_light_dir = glm::normalize(glm::vec3{
        glm::cos(debug_el) * glm::sin(debug_az),
        glm::cos(debug_el) * glm::cos(debug_az),
        glm::sin(debug_el)
    });

    // Draw model with debug texture overrides and custom light.
    // We force-load textures via the getters (which write back to ptr), then
    // check ptr directly for shader selection and binding. This avoids the
    // fallback-texture problem: clearing normal_texture.name and calling
    // getNormalTexture() again would load a magenta 8x8 stub, which is
    // non-null and would still select a Normal shader variant.
    {
        mrc->getNormalTexture();
        mrc->getSpecularTexture();
        mrc->getIlluminationTexture();
        mrc->getTexture();

        const bool use_normal       = debug_show_normal_map && (mrc->normal_texture.ptr != nullptr);
        const bool use_specular     = (mrc->specular_texture.ptr != nullptr);
        const bool use_illumination = (mrc->illumination_texture.ptr != nullptr);
        const bool use_texture      = (mrc->texture.ptr != nullptr);

        auto shader_id = ShaderRegistry::Shaders::Object;
        if (use_normal) {
            if (use_texture && use_specular && use_illumination)
                shader_id = ShaderRegistry::Shaders::ObjectSpecularIlluminationNormal;
            else if (use_texture && use_specular)
                shader_id = ShaderRegistry::Shaders::ObjectSpecularNormal;
            else if (use_texture && use_illumination)
                shader_id = ShaderRegistry::Shaders::ObjectIlluminationNormal;
            else
                shader_id = ShaderRegistry::Shaders::ObjectNormal;
        } else {
            if (use_texture && use_specular && use_illumination)
                shader_id = ShaderRegistry::Shaders::ObjectSpecularIllumination;
            else if (use_texture && use_specular)
                shader_id = ShaderRegistry::Shaders::ObjectSpecular;
            else if (use_texture && use_illumination)
                shader_id = ShaderRegistry::Shaders::ObjectIllumination;
        }

        ShaderRegistry::ScopedShader shader(shader_id);
        glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));

        if (auto u = shader.get().uniform(ShaderRegistry::Uniforms::AmbientLightDirection);  u != -1)
            glUniform3fv(u, 1, glm::value_ptr(debug_light_dir));
        if (auto u = shader.get().uniform(ShaderRegistry::Uniforms::SpecularLightDirection); u != -1)
            glUniform3fv(u, 1, glm::value_ptr(debug_light_dir));

        // Bind textures by ptr, skipping normal map when toggled off.
        if (use_texture)
            mrc->texture.ptr->bind();
        if (use_specular) {
            glActiveTexture(GL_TEXTURE0 + ShaderRegistry::textureIndex(ShaderRegistry::Textures::SpecularMap));
            mrc->specular_texture.ptr->bind();
        }
        if (use_illumination) {
            glActiveTexture(GL_TEXTURE0 + ShaderRegistry::textureIndex(ShaderRegistry::Textures::IlluminationMap));
            mrc->illumination_texture.ptr->bind();
        }
        if (use_normal) {
            glActiveTexture(GL_TEXTURE0 + ShaderRegistry::textureIndex(ShaderRegistry::Textures::NormalMap));
            mrc->normal_texture.ptr->bind();
        }

        drawMesh(*mrc, shader);

        if (use_specular || use_illumination)
            glActiveTexture(GL_TEXTURE0);
    }

    // Billboard circle at the light source position.
    {
        glDisable(GL_DEPTH_TEST);

        const glm::vec3 light_pos = debug_light_dir * (mesh_radius * 2.5f);
        const float marker_r      = mesh_radius * 0.07f;

        ShaderRegistry::ScopedShader col(ShaderRegistry::Shaders::BasicColor);
        const auto identity = glm::identity<glm::mat4>();
        glUniformMatrix4fv(col.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(identity));
        glUniform4f(col.get().uniform(ShaderRegistry::Uniforms::Color), 1.f, 0.9f, 0.2f, 0.8f);
        gl::ScopedVertexAttribArray positions(col.get().attribute(ShaderRegistry::Attributes::Position));

        // Camera right and up in world space come from the rows of the view
        // matrix rotation (GLM is column-major: view[col][row]).
        const glm::vec3 cam_right = glm::normalize(glm::vec3(view_matrix[0][0], view_matrix[1][0], view_matrix[2][0]));
        const glm::vec3 cam_up    = glm::normalize(glm::vec3(view_matrix[0][1], view_matrix[1][1], view_matrix[2][1]));

        constexpr int N = 24;
        glm::vec3 verts[N];
        for (int i = 0; i < N; ++i)
        {
            const float a = float(i) / float(N) * 6.28318530f;
            verts[i] = light_pos + glm::cos(a) * marker_r * cam_right
                                 + glm::sin(a) * marker_r * cam_up;
        }
        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, 0, verts);
        glDrawArrays(GL_LINE_LOOP, 0, N);

        glEnable(GL_DEPTH_TEST);
    }
#else
    {
        auto shader = lookUpShader(*mrc);
        glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));

        auto modeldata_matrix = glm::rotate(model_matrix, glm::radians(180.f), {0.f, 0.f, 1.f});
        modeldata_matrix = glm::scale(modeldata_matrix, glm::vec3{mrc->scale});

        ShaderRegistry::setupLights(shader.get(), modeldata_matrix);
        activateAndBindMeshTextures(*mrc);
        drawMesh(*mrc, shader);
    }
#endif

#if 0
    {
        ShaderRegistry::ScopedShader color_shader(ShaderRegistry::Shaders::BasicColor);
        glDisable(GL_DEPTH_TEST);
        auto model_matrix = glm::identity<glm::mat4>();
        glUniformMatrix4fv(color_shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));
        glUniform4f(color_shader.get().uniform(ShaderRegistry::Uniforms::Color), 1.0f, 1.0f, 1.0f, .5f);
        gl::ScopedVertexAttribArray positions(color_shader.get().attribute(ShaderRegistry::Attributes::Position));
        constexpr size_t point_count = 50;
        std::vector<glm::vec3> vertices;
        std::vector<uint16_t> indices;
        auto radius = mesh_radius;
        for(size_t idx=0; idx<point_count; idx++) {
            float f = float(idx) / float(point_count) * static_cast<float>(M_PI) * 2.0f;
            vertices.push_back({std::sin(f) * radius, std::cos(f) * radius, 0.0f});
            indices.push_back(idx);
        }
        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, 0, reinterpret_cast<GLvoid*>(&vertices[0]));
        glDrawElements(GL_LINE_LOOP, point_count, GL_UNSIGNED_SHORT, reinterpret_cast<GLvoid*>(&indices[0]));
    }
#endif

    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glViewport(0, 0, renderer.getPhysicalSize().x, renderer.getPhysicalSize().y);
}

bool GuiRotatingModelView::onMouseWheelScroll(glm::vec2 position, float value)
{
    // Positive value = scroll up = zoom in, negative value = scroll down = zoom out.
    // Multiplicative so each notch is the same relative step across the range.
    constexpr float zoom_step = 1.1f;
    zoom_level *= glm::pow(zoom_step, value);

    // Clamp zoom level to reasonable bounds
    zoom_level = glm::clamp(zoom_level, 0.3f, 5.0f);

    return true;
}

GuiRotatingModelView* GuiRotatingModelView::setFillPercentage(float percentage)
{
    desired_fill_percentage = glm::clamp(percentage, 0.3f, 2.0f);
    return this;
}

GuiRotatingModelView* GuiRotatingModelView::setZoom(float zoom)
{
    zoom_level = glm::clamp(zoom, 0.3f, 5.0f);
    return this;
}

GuiRotatingModelView* GuiRotatingModelView::setManualRotationAllowed(bool allowed)
{
    manual_rotation_allowed = allowed;
    return this;
}

bool GuiRotatingModelView::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    if (!manual_rotation_allowed || button != sp::io::Pointer::Button::Left) return false;

    mouse_down = true;
    is_dragging = false;
    mouse_down_position = position;
    return true;

    return false;
}

void GuiRotatingModelView::onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (!manual_rotation_allowed || !mouse_down) return;

    glm::vec2 drag_delta = position - mouse_down_position;

    // Only register as a drag with significant movement
    float drag_threshold = 2.0f;
    if (!is_dragging && glm::length(drag_delta) > drag_threshold)
    {
        is_dragging = true;
        manual_rotation_mode = true;
    }

    if (is_dragging)
    {
        // Update rotation based on drag
        // Degrees per pixel
        float sensitivity = 0.5f;
        // Horizontal: drag X, model Z; Vertical: drag y, model X
        // Both are intentionally inverted so that click-drag rotates model
        // as if pulling it at the clicked point
        manual_rotation_z -= drag_delta.x * sensitivity;
        manual_rotation_x -= drag_delta.y * sensitivity;

        // Clamp X rotation to prevent flipping
        manual_rotation_x = glm::clamp(manual_rotation_x, -89.0f, 89.0f);

        // Normalize Z rotation
        manual_rotation_z = fmod(manual_rotation_z, 360.0f);
        if (manual_rotation_z < 0.0f) manual_rotation_z += 360.0f;

        // Update mouse down position for next frame
        mouse_down_position = position;
    }
}

void GuiRotatingModelView::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (!manual_rotation_allowed || !mouse_down) return;

    // Reset to default rotation behavior on single click
    if (!is_dragging)
    {
        manual_rotation_mode = false;
        manual_rotation_x = -30.0f;
        manual_rotation_z = 0.0f;
        zoom_level = 1.0f;
    }

    mouse_down = false;
    is_dragging = false;
}

#ifdef DEBUG
GuiRotatingModelDebugView::GuiRotatingModelDebugView(GuiContainer* owner, string id, sp::ecs::Entity& entity)
: GuiRotatingModelView(owner, id, entity)
{
    constexpr float panel_h = 80.f;
    constexpr float ctrl_w  = 160.f;
    constexpr float label_h = 20.f;
    constexpr float ctrl_h  = panel_h - label_h - 8.f;

    auto* panel = (new GuiPanel(this, id + "_DEBUG_PANEL"))
        ->setPosition(0.f, 0.f, sp::Alignment::BottomLeft)
        ->setSize(GuiElement::GuiSizeMax, panel_h);

    // First column is left empty for the normal map toggle, which stays out of
    // the UI until the resource packs ship normal maps.
    constexpr float az_x = ctrl_w + 24.f;
    (new GuiLabel(panel, id + "_AZ_LABEL", "Light azimuth", label_h))
        ->setPosition(az_x, 4.f, sp::Alignment::TopLeft)
        ->setSize(ctrl_w, label_h);
    (new GuiSlider(panel, id + "_AZ_SLIDER", -180.f, 180.f, 45.f,
        [this](float value) { setDebugLightAzimuth(value); }))
        ->setPosition(az_x, label_h + 4.f, sp::Alignment::TopLeft)
        ->setSize(ctrl_w, ctrl_h);

    constexpr float el_x = az_x + ctrl_w + 16.f;
    (new GuiLabel(panel, id + "_EL_LABEL", "Light elevation", label_h))
        ->setPosition(el_x, 4.f, sp::Alignment::TopLeft)
        ->setSize(ctrl_w, label_h);
    (new GuiSlider(panel, id + "_EL_SLIDER", -90.f, 90.f, 45.f,
        [this](float value) { setDebugLightElevation(value); }))
        ->setPosition(el_x, label_h + 4.f, sp::Alignment::TopLeft)
        ->setSize(ctrl_w, ctrl_h);
}
#endif
