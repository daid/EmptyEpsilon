#include "systems/rendering.h"
#include "components/rendering.h"
#include "textureManager.h"
#include "vectorUtils.h"
#include "shaderRegistry.h"
#include <graphics/opengl.h>
#include <glm/gtc/type_ptr.hpp>
#include "tween.h"
#include "random.h"


std::vector<RenderSystem::RenderHandler> RenderSystem::render_handlers;

bool MeshRenderComponent::ensureLoaded()
{
    if (!mesh.ptr && !mesh.name.empty())
        mesh.ptr = Mesh::getMesh(mesh.name);
    if (!mesh.ptr)
        return false;
    if (!texture.ptr && !texture.name.empty())
        texture.ptr = textureManager.getTexture(texture.name);
    if (!specular_texture.ptr && !specular_texture.name.empty())
        specular_texture.ptr = textureManager.getTexture(specular_texture.name);
    if (!illumination_texture.ptr && !illumination_texture.name.empty())
        illumination_texture.ptr = textureManager.getTexture(illumination_texture.name);
    return true;
}

void RenderSystem::render3D(float aspect, float camera_fov)
{
    view_vector = vec2FromAngle(camera_yaw);
    depth_cutoff_back = camera_position.z * -tanf(glm::radians(90+camera_pitch + camera_fov/2.f));
    depth_cutoff_front = camera_position.z * -tanf(glm::radians(90+camera_pitch - camera_fov/2.f));
    if (camera_pitch - camera_fov/2.f <= 0.f)
        depth_cutoff_front = std::numeric_limits<float>::infinity();
    if (camera_pitch + camera_fov/2.f >= 180.f)
        depth_cutoff_back = -std::numeric_limits<float>::infinity();
    for(auto& handler : render_handlers)
        (this->*(handler.func))(handler.rif);

    for(int n=render_lists.size() - 1; n >= 0; n--)
    {
        auto& render_list = render_lists[n];
        std::sort(render_list.begin(), render_list.end(), [](const RenderEntry& a, const RenderEntry& b) { return a.depth > b.depth; });

        auto projection = glm::perspective(glm::radians(camera_fov), aspect, 1.f, 25000.f * (n + 1));
        // Update projection matrix in shaders.
        ShaderRegistry::updateProjectionView(projection, {});

        glDepthMask(true);
        glDisable(GL_BLEND);
        for(auto info : render_list)
            if (!info.transparent)
                info.call_rif(info.rif, info.entity, *info.transform, info.component_ptr);
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE);
        glDepthMask(false);
        for(auto info : render_list)
            if (info.transparent)
                info.call_rif(info.rif, info.entity, *info.transform, info.component_ptr);
    }
}

glm::mat4 calculateModelMatrix(glm::vec2 position, float rotation, MeshRenderComponent& mrc, float scale_override = -1.) {
    float scale = scale_override > 0 ? scale_override : mrc.scale;
    auto model_matrix = glm::translate(glm::identity<glm::mat4>(), glm::vec3{ position.x, position.y, 0.f });
    model_matrix = glm::rotate(model_matrix, glm::radians(rotation), glm::vec3{ 0.f, 0.f, 1.f });
    model_matrix = glm::translate(model_matrix, mrc.mesh_offset);

    // EE's coordinate flips to a Z-up left hand.
    // To account for that, flip the model around 180deg.
    auto modeldata_matrix = glm::rotate(model_matrix, glm::radians(180.f), {0.f, 0.f, 1.f});
    modeldata_matrix = glm::scale(modeldata_matrix, glm::vec3{scale});
    //modeldata_matrix = glm::translate(modeldata_matrix, mrc.mesh_offset); // Old mesh offset
    return modeldata_matrix;
}

ShaderRegistry::ScopedShader lookUpShader(MeshRenderComponent& mrc)
{
    auto shader_id = ShaderRegistry::Shaders::Object;
    if (mrc.texture.ptr && mrc.specular_texture.ptr && mrc.illumination_texture.ptr)
        shader_id = ShaderRegistry::Shaders::ObjectSpecularIllumination;
    else if (mrc.texture.ptr && mrc.specular_texture.ptr)
        shader_id = ShaderRegistry::Shaders::ObjectSpecular;
    else if (mrc.texture.ptr && mrc.illumination_texture.ptr)
        shader_id = ShaderRegistry::Shaders::ObjectIllumination;

    return ShaderRegistry::ScopedShader(shader_id);
}

void MeshRenderSystem::update(float delta)
{
}

void MeshRenderSystem::render3D(sp::ecs::Entity e, sp::Transform& transform, MeshRenderComponent& mrc)
{
    mrc.ensureLoaded();

    auto modeldata_matrix = calculateModelMatrix(
            transform.getPosition(),
            transform.getRotation(),
            mrc);

    auto shader = lookUpShader(mrc);
    glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(modeldata_matrix));

    // Lights setup.
    // FIX!!: temporarily using flipped matrix here.
    ShaderRegistry::setupLights(shader.get(), modeldata_matrix);

    // Textures
    if (mrc.texture.ptr)
        mrc.texture.ptr->bind();

    if (mrc.specular_texture.ptr)
    {
        glActiveTexture(GL_TEXTURE0 + ShaderRegistry::textureIndex(ShaderRegistry::Textures::SpecularMap));
        mrc.specular_texture.ptr->bind();
    }

    if (mrc.illumination_texture.ptr)
    {
        glActiveTexture(GL_TEXTURE0 + ShaderRegistry::textureIndex(ShaderRegistry::Textures::IlluminationMap));
        mrc.illumination_texture.ptr->bind();
    }

    // Draw
    gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));
    gl::ScopedVertexAttribArray normals(shader.get().attribute(ShaderRegistry::Attributes::Normal));

    mrc.mesh.ptr->render(positions.get(), texcoords.get(), normals.get());

    if (mrc.specular_texture.ptr || mrc.illumination_texture.ptr)
        glActiveTexture(GL_TEXTURE0);
}

void NebulaRenderSystem::update(float delta)
{
}

void NebulaRenderSystem::render3D(sp::ecs::Entity e, sp::Transform& transform, NebulaRenderer& nr)
{
    ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::Billboard);

    struct VertexAndTexCoords
    {
        glm::vec3 vertex;
        glm::vec2 texcoords;
    };
    std::array<VertexAndTexCoords, 4> quad{
        glm::vec3{}, {0.f, 1.f},
        glm::vec3{}, {1.f, 1.f},
        glm::vec3{}, {1.f, 0.f},
        glm::vec3{}, {0.f, 0.f}
    };

    gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));

    for(auto& cloud : nr.clouds)
    {
        glm::vec3 position = glm::vec3(transform.getPosition().x, transform.getPosition().y, 0) + glm::vec3(cloud.offset.x, cloud.offset.y, 0);
        float size = cloud.size;

        float distance = glm::length(camera_position - position);
        float alpha = 1.0f - (distance / nr.render_range);
        if (alpha < 0.0f)
            continue;

        // setup our quad.
        for (auto& point : quad)
        {
            point.vertex = position;
        }

        if (!cloud.texture.ptr)
            cloud.texture.ptr = textureManager.getTexture(cloud.texture.name);
        if (cloud.texture.ptr)
            cloud.texture.ptr->bind();
        glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), alpha * 0.8f, alpha * 0.8f, alpha * 0.8f, size);
        auto cloud_model_matrix = glm::translate(glm::identity<glm::mat4>(), {cloud.offset.x, cloud.offset.y, 0});
        glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(cloud_model_matrix));

        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quad.data());
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quad.data() + sizeof(glm::vec3)));
        std::initializer_list<uint16_t> indices = { 0, 3, 2, 0, 2, 1 };
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, std::begin(indices));
    }
}

void ExplosionRenderSystem::update(float delta)
{
    for(auto [entity, ee] : sp::ecs::Query<ExplosionEffect>()) {
        ee.lifetime -= delta;
        if (ee.lifetime < 0.0f)
            entity.destroy();
    }
}

void ExplosionRenderSystem::render3D(sp::ecs::Entity e, sp::Transform& transform, ExplosionEffect& ee)
{
    float f = (1.0f - (ee.lifetime / ee.max_lifetime));
    float scale;
    float alpha = 0.5f;
    if (f < 0.2f) {
        scale = (f / 0.2f);
        if (ee.electrical)
            scale *= 0.8f;
    } else {
        if (ee.electrical)
            scale = Tween<float>::easeOutQuad(f, 0.2f, 1.f, 0.8f, 1.0f);
        else
            scale = Tween<float>::easeOutQuad(f, 0.2f, 1.f, 1.0f, 1.3f);
        alpha = Tween<float>::easeInQuad(f, 0.2f, 1.f, 0.5f, 0.0f);
    }

    auto position = transform.getPosition();
    auto rotation = transform.getRotation();
    auto model_matrix = glm::translate(glm::identity<glm::mat4>(), glm::vec3{ position.x, position.y, 0.f });
    model_matrix = glm::rotate(model_matrix, glm::radians(rotation), glm::vec3{ 0.f, 0.f, 1.f });

    auto explosion_matrix = glm::scale(model_matrix, glm::vec3(scale * ee.size));
    ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::Basic);
    {
        glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(explosion_matrix));
        glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), alpha, alpha, alpha, 1.f);
        if (ee.electrical)
            textureManager.getTexture("texture/electric_sphere_texture.png")->bind();
        else
            textureManager.getTexture("texture/fire_sphere_texture.png")->bind();

        gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
        gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));
        gl::ScopedVertexAttribArray normals(shader.get().attribute(ShaderRegistry::Attributes::Normal));

        Mesh* m = Mesh::getMesh("mesh/sphere.obj");
        m->render(positions.get(), texcoords.get(), normals.get());
        if (ee.electrical) {
            glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(glm::scale(explosion_matrix, glm::vec3(.5f))));
            m->render(positions.get(), texcoords.get(), normals.get());
        }
    }
    std::vector<glm::vec3> vertices(4 * ee.max_quad_count);

    if (!ee.particles_buffers) {
        for(int n=0; n<ee.particle_count; n++)
            ee.particle_directions[n] = glm::normalize(glm::vec3(random(-1, 1), random(-1, 1), random(-1, 1))) * random(0.8f, 1.2f);

        ee.particles_buffers = std::make_shared<gl::Buffers<2>>();

        // Each vertex is a position and a texcoords.
        // The two arrays are maintained separately (texcoords are fixed, vertices position change).
        constexpr size_t vertex_size = sizeof(glm::vec3) + sizeof(glm::vec2);
        gl::ScopedBufferBinding vbo(GL_ARRAY_BUFFER, (*ee.particles_buffers)[0]);
        gl::ScopedBufferBinding ebo(GL_ELEMENT_ARRAY_BUFFER, (*ee.particles_buffers)[1]);

        // VBO
        glBufferData(GL_ARRAY_BUFFER, ee.max_quad_count * 4 * vertex_size, nullptr, GL_STREAM_DRAW);

        // Create initial data.
        std::vector<uint16_t> indices(6 * ee.max_quad_count);
        std::vector<glm::vec2> texcoords(4 * ee.max_quad_count);
        for (auto i = 0U; i < ee.max_quad_count; ++i)
        {
            auto quad_offset = 4 * i;
            texcoords[quad_offset + 0] = { 0.f, 1.f };
            texcoords[quad_offset + 1] = { 1.f, 1.f };
            texcoords[quad_offset + 2] = { 1.f, 0.f };
            texcoords[quad_offset + 3] = { 0.f, 0.f };

            indices[6 * i + 0] = quad_offset + 0;
            indices[6 * i + 1] = quad_offset + 2;
            indices[6 * i + 2] = quad_offset + 1;
            indices[6 * i + 3] = quad_offset + 0;
            indices[6 * i + 4] = quad_offset + 3;
            indices[6 * i + 5] = quad_offset + 2;
        }

        // Update texcoords
        glBufferSubData(GL_ARRAY_BUFFER, ee.max_quad_count * 4 * sizeof(glm::vec3), texcoords.size() * sizeof(glm::vec2), texcoords.data());
        // Upload indices
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(uint16_t), indices.data(), GL_STATIC_DRAW);
    }

    gl::ScopedBufferBinding vbo(GL_ARRAY_BUFFER, (*ee.particles_buffers)[0]);
    gl::ScopedBufferBinding ebo(GL_ELEMENT_ARRAY_BUFFER, (*ee.particles_buffers)[1]);

    // Fire ring
    if (!ee.electrical)
    {
        textureManager.getTexture("texture/fire_ring.png")->bind();

        explosion_matrix = glm::scale(explosion_matrix, glm::vec3(1.5f));
        glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(explosion_matrix));

        vertices[0] = glm::vec3(-1, -1, 0);
        vertices[1] = glm::vec3(1, -1, 0);
        vertices[2] = glm::vec3(1, 1, 0);
        vertices[3] = glm::vec3(-1, 1, 0);
        {
            gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
            gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));

            glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(glm::vec3), (GLvoid*)0);
            glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(glm::vec2), (GLvoid*)(vertices.size() * sizeof(glm::vec3)));

            // upload single vertex
            glBufferSubData(GL_ARRAY_BUFFER, 0, 4 * sizeof(glm::vec3), vertices.data());

            glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, nullptr);
        }
    }

    shader = ShaderRegistry::ScopedShader(ShaderRegistry::Shaders::Billboard);
    glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));

    gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));

    textureManager.getTexture("particle.png")->bind();

    scale = Tween<float>::easeInCubic(f, 0.f, 1.f, 0.3f, 5.0f);
    float r = Tween<float>::easeInQuad(f, 0.f, 1.f, 1.0f, 0.0f);
    float g = Tween<float>::easeOutQuad(f, 0.f, 1.f, 1.0f, 0.0f);
    float b = Tween<float>::easeOutQuad(f, 0.f, 1.f, 1.0f, 0.0f);
    if (ee.electrical) {
        scale = Tween<float>::easeInCubic(f, 0.f, 1.f, 0.3f, 3.0f);
        r = Tween<float>::easeOutQuad(f, 0.f, 1.f, 1.0f, 0.0f);
        g = Tween<float>::easeOutQuad(f, 0.f, 1.f, 1.0f, 0.0f);
        b = Tween<float>::easeInQuad(f, 0.f, 1.f, 1.0f, 0.0f);
    }
    glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), r, g, b, ee.size / 32.0f);

    glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(glm::vec3), (GLvoid*)0);
    glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(glm::vec2), (GLvoid*)(vertices.size() * sizeof(glm::vec3)));

    const size_t quad_count = ee.max_quad_count;
    // We're drawing particles `quad_count` at a time.
    for (size_t n = 0; n < ee.particle_count;)
    {
        auto active_quads = std::min(quad_count, ee.particle_count - n);
        // setup quads
        for (auto p = 0U; p < active_quads; ++p)
        {
            glm::vec3 v = ee.particle_directions[n + p] * scale * ee.size;
            vertices[4 * p + 0] = v;
            vertices[4 * p + 1] = v;
            vertices[4 * p + 2] = v;
            vertices[4 * p + 3] = v;
        }
        // upload
        glBufferSubData(GL_ARRAY_BUFFER, 0, vertices.size() * sizeof(glm::vec3), vertices.data());

        glDrawElements(GL_TRIANGLES, static_cast<GLsizei>(6 * active_quads), GL_UNSIGNED_SHORT, nullptr);
        n += active_quads;
    }
}

void BillboardRenderSystem::update(float delta)
{
}

void BillboardRenderSystem::render3D(sp::ecs::Entity e, sp::Transform& transform, BillboardRenderer& bbr)
{
    struct VertexAndTexCoords
    {
        glm::vec3 vertex;
        glm::vec2 texcoords;
    };
    static std::array<VertexAndTexCoords, 4> quad{
        glm::vec3{}, {0.f, 1.f},
        glm::vec3{}, {1.f, 1.f},
        glm::vec3{}, {1.f, 0.f},
        glm::vec3{}, {0.f, 0.f}
    };

    textureManager.getTexture(bbr.texture)->bind();
    ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::Billboard);

    auto position = transform.getPosition();
    auto rotation = transform.getRotation();
    auto model_matrix = glm::translate(glm::identity<glm::mat4>(), glm::vec3{ position.x, position.y, 0.f });
    model_matrix = glm::rotate(model_matrix, glm::radians(rotation), glm::vec3{ 0.f, 0.f, 1.f });

    glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));
    glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), 1.f, 1.f, 1.f, bbr.size);
    gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quad.data());
    glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quad.data() + sizeof(glm::vec3)));

    std::initializer_list<uint16_t> indices = { 0, 2, 1, 0, 3, 2 };
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, std::begin(indices));
    glBlendFunc(GL_ONE, GL_ONE);
}
