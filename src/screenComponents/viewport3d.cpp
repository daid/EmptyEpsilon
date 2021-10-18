#include <graphics/opengl.h>

#include "main.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "viewport3d.h"
#include "shaderManager.h"
#include "soundManager.h"
#include "textureManager.h"
#include "random.h"

#include "particleEffect.h"
#include "glObjects.h"
#include "shaderRegistry.h"

#include <glm/glm.hpp>
#include <glm/ext/matrix_transform.hpp>
#include <glm/ext/matrix_clip_space.hpp>
#include <glm/gtc/type_ptr.hpp>


GuiViewport3D::GuiViewport3D(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    show_callsigns = false;
    show_headings = false;
    show_spacedust = false;

    // Load up our starbox into a cubemap.
    // Setup shader.
    starbox_shader = ShaderManager::getShader("shaders/starbox");
    starbox_shader->bind();
    starbox_uniforms[static_cast<size_t>(Uniforms::Projection)] = starbox_shader->getUniformLocation("projection");
    starbox_uniforms[static_cast<size_t>(Uniforms::View)] = starbox_shader->getUniformLocation("view");

    starbox_vertex_attributes[static_cast<size_t>(VertexAttributes::Position)] = starbox_shader->getAttributeLocation("position");

    // Load up the cube texture.
    // Face setup
    std::array<std::tuple<const char*, uint32_t>, 6> faces{
        std::make_tuple("skybox/right.png", GL_TEXTURE_CUBE_MAP_POSITIVE_X),
        std::make_tuple("skybox/left.png", GL_TEXTURE_CUBE_MAP_NEGATIVE_X),
        std::make_tuple("skybox/top.png", GL_TEXTURE_CUBE_MAP_POSITIVE_Y),
        std::make_tuple("skybox/bottom.png", GL_TEXTURE_CUBE_MAP_NEGATIVE_Y),
        std::make_tuple("skybox/front.png", GL_TEXTURE_CUBE_MAP_POSITIVE_Z),
        std::make_tuple("skybox/back.png", GL_TEXTURE_CUBE_MAP_NEGATIVE_Z),
    };

    // Upload
    glBindTexture(GL_TEXTURE_CUBE_MAP, starbox_texture[0]);
    sp::Image image;
    for (const auto& face : faces)
    {
        auto stream = getResourceStream(std::get<0>(face));
        if (!stream || !image.loadFromStream(stream))
        {
            LOG(WARNING) << "Failed to load texture: " << std::get<0>(face);
            image = sp::Image({8, 8}, {255, 0, 255, 128});
        }

        glTexImage2D(std::get<1>(face), 0, GL_RGBA, image.getSize().x, image.getSize().y, 0, GL_RGBA, GL_UNSIGNED_BYTE, image.getPtr());
    }

    // Make it pretty.
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

    //GL_TEXTURE_WRAP_R does not exist in GLES2.0?
    for (auto wrap_axis : { GL_TEXTURE_WRAP_S, GL_TEXTURE_WRAP_T /*, GL_TEXTURE_WRAP_R*/ })
        glTexParameteri(GL_TEXTURE_CUBE_MAP, wrap_axis, GL_CLAMP_TO_EDGE);

    if (GLAD_GL_ES_VERSION_2_0)
        glGenerateMipmap(GL_TEXTURE_CUBE_MAP);
    glBindTexture(GL_TEXTURE_CUBE_MAP, GL_NONE);

    // Load up the ebo and vbo for the cube.
    /*   
           .2------6
         .' |    .'|
        3---+--7'  |
        |   |  |   |
        |  .0--+---4
        |.'    | .'
        1------5'
    */
    std::array<glm::vec3, 8> positions{
        // Left face
        glm::vec3{-1.f, -1.f, -1.f}, // 0
        glm::vec3{-1.f, -1.f, 1.f},  // 1
        glm::vec3{-1.f, 1.f, -1.f},  // 2
        glm::vec3{-1.f, 1.f, 1.f},   // 3

        // Right face
        glm::vec3{1.f, -1.f, -1.f},  // 4
        glm::vec3{1.f, -1.f, 1.f},   // 5
        glm::vec3{1.f, 1.f, -1.f},   // 6
        glm::vec3{1.f, 1.f, 1.f},    // 7
    };

    constexpr std::array<uint16_t, 6 * 6> elements{
        2, 6, 4, 4, 0, 2, // Back
        3, 2, 0, 0, 1, 3, // Left
        6, 7, 5, 5, 4, 6, // Right
        7, 3, 1, 1, 5, 7, // Front
        6, 2, 3, 3, 7, 6, // Top
        0, 4, 5, 5, 1, 0, // Bottom
    };

    // Upload to GPU.
    glBindBuffer(GL_ARRAY_BUFFER, starbox_buffers[static_cast<size_t>(Buffers::Vertex)]);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, starbox_buffers[static_cast<size_t>(Buffers::Element)]);

    glBufferData(GL_ARRAY_BUFFER, positions.size() * sizeof(glm::vec3), positions.data(), GL_STATIC_DRAW);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, elements.size() * sizeof(uint16_t), elements.data(), GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_NONE);
    // Setup spacedust
    spacedust_shader = ShaderManager::getShader("shaders/spacedust");
    spacedust_shader->bind();
    spacedust_uniforms[static_cast<size_t>(Uniforms::Projection)] = spacedust_shader->getUniformLocation("projection");
    spacedust_uniforms[static_cast<size_t>(Uniforms::View)] = spacedust_shader->getUniformLocation("view");
    spacedust_uniforms[static_cast<size_t>(Uniforms::Rotation)] = spacedust_shader->getUniformLocation("rotation");

    spacedust_vertex_attributes[static_cast<size_t>(VertexAttributes::Position)] = spacedust_shader->getAttributeLocation("position");
    spacedust_vertex_attributes[static_cast<size_t>(VertexAttributes::Sign)] = spacedust_shader->getAttributeLocation("sign_value");

    // Reserve our GPU buffer.
    // Each dust particle consist of:
    // - a worldpace position (Vector3f)
    // - a sign value (single byte, passed as float).
    // Both "arrays" are maintained separate:
    // the signs are stable (they just tell us which "end" of the line we're on)
    // The positions will get updated more frequently.
    // It means each particle occupies 2*16B (assuming tight packing)
    glBindBuffer(GL_ARRAY_BUFFER, spacedust_buffer[0]);
    glBufferData(GL_ARRAY_BUFFER, 2 * spacedust_particle_count * (sizeof(glm::vec3) + sizeof(float)), nullptr, GL_DYNAMIC_DRAW);

    // Generate and update the alternating vertices signs.
    std::array<float, 2 * spacedust_particle_count> signs;
    
    for (auto n = 0U; n < signs.size(); n += 2)
    {
        signs[n] = -1.f;
        signs[n + 1] = 1.f;
    }

    // Update sign parts.
    glBufferSubData(GL_ARRAY_BUFFER, 2 * spacedust_particle_count * sizeof(glm::vec3), signs.size() * sizeof(float), signs.data());
    {
        // zero out positions.
        const std::vector<glm::vec3> zeroed_positions(2 * spacedust_particle_count);
        glBufferSubData(GL_ARRAY_BUFFER, 0, 2 * spacedust_particle_count * sizeof(glm::vec3), zeroed_positions.data());
    }
    glBindBuffer(GL_ARRAY_BUFFER, GL_NONE);
}

void GuiViewport3D::onDraw(sp::RenderTarget& renderer)
{
    if (rect.size.x == 0.f)
    {
        // The GUI ticks before Updatables.
        // When the 3D screen is on the side of a station,
        // and the window is resized in a way that will hide the main screen,
        // this leaves a *one frame* gap where the 3D gui element is 'visible' but will try to render
        // with a computed 0-width rect.
        // Since some gl calls don't really like an empty viewport, just ignore the draw.
        return;
    }
    renderer.finish();
   
    if (my_spaceship)
        soundManager->setListenerPosition(my_spaceship->getPosition(), my_spaceship->getRotation());
    else
        soundManager->setListenerPosition(glm::vec2(camera_position.x, camera_position.y), camera_yaw);
    
    glActiveTexture(GL_TEXTURE0);

    float camera_fov = 60.0f;
    {
        auto p0 = renderer.virtualToPixelPosition(rect.position);
        auto p1 = renderer.virtualToPixelPosition(rect.position + rect.size);
        glViewport(p0.x, renderer.getPhysicalSize().y - p1.y, p1.x - p0.x, p1.y - p0.y);
    }
    if (GLAD_GL_ES_VERSION_2_0)
        glClearDepthf(1.f);
    else
        glClearDepth(1.f);

    glClear(GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    glFrontFace(GL_CCW);

    projection_matrix = glm::perspective(glm::radians(camera_fov), rect.size.x / rect.size.y, 1.f, 25000.f);

    // OpenGL standard: X across (left-to-right), Y up, Z "towards".
    view_matrix = glm::rotate(glm::identity<glm::mat4>(), glm::radians(90.0f), {1.f, 0.f, 0.f}); // -> X across (l-t-r), Y "towards", Z down 
    view_matrix = glm::scale(view_matrix, {1.f,1.f,-1.f});  // -> X across (l-t-r), Y "towards", Z up
    view_matrix = glm::rotate(view_matrix, glm::radians(-camera_pitch), {1.f, 0.f, 0.f});
    view_matrix = glm::rotate(view_matrix, glm::radians(-(camera_yaw + 90.f)), {0.f, 0.f, 1.f});

    // Translate camera
    view_matrix = glm::translate(view_matrix, -camera_position);

    // Draw starbox.
    glDepthMask(GL_FALSE);
    {
        starbox_shader->bind();
        glUniform1f(starbox_shader->getUniformLocation("scale"), 100.0f);

        // Setup shared state (uniforms)
        glBindTexture(GL_TEXTURE_CUBE_MAP, starbox_texture[0]);
        
        // Uniform
        // Upload matrices (only float 4x4 supported in es2)
        glUniformMatrix4fv(starbox_uniforms[static_cast<size_t>(Uniforms::Projection)], 1, GL_FALSE, glm::value_ptr(projection_matrix));
        glUniformMatrix4fv(starbox_uniforms[static_cast<size_t>(Uniforms::View)], 1, GL_FALSE, glm::value_ptr(view_matrix));
        
        // Bind our cube
        {
            gl::ScopedVertexAttribArray positions(starbox_vertex_attributes[static_cast<size_t>(VertexAttributes::Position)]);
            glBindBuffer(GL_ARRAY_BUFFER, starbox_buffers[static_cast<size_t>(Buffers::Vertex)]);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, starbox_buffers[static_cast<size_t>(Buffers::Element)]);

            // Vertex attributes.
            glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(glm::vec3), (GLvoid*)0);

            glDrawElements(GL_TRIANGLES, 6 * 6, GL_UNSIGNED_SHORT, (GLvoid*)0);

            // Cleanup
            glBindBuffer(GL_ARRAY_BUFFER, GL_NONE);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_NONE);
        }

        glBindTexture(GL_TEXTURE_CUBE_MAP, GL_NONE);
    }
    glDepthMask(GL_TRUE);

    class RenderInfo
    {
    public:
        RenderInfo(SpaceObject* obj, float d)
        : object(obj), depth(d)
        {}

        SpaceObject* object;
        float depth;
    };
    std::vector<std::vector<RenderInfo>> render_lists;

    auto viewVector = vec2FromAngle(camera_yaw);
    float depth_cutoff_back = camera_position.z * -tanf(glm::radians(90+camera_pitch + camera_fov/2.f));
    float depth_cutoff_front = camera_position.z * -tanf(glm::radians(90+camera_pitch - camera_fov/2.f));
    if (camera_pitch - camera_fov/2.f <= 0.f)
        depth_cutoff_front = std::numeric_limits<float>::infinity();
    if (camera_pitch + camera_fov/2.f >= 180.f)
        depth_cutoff_back = -std::numeric_limits<float>::infinity();
    foreach(SpaceObject, obj, space_object_list)
    {
        float depth = glm::dot(viewVector, obj->getPosition() - glm::vec2(camera_position.x, camera_position.y));
        if (depth + obj->getRadius() < depth_cutoff_back)
            continue;
        if (depth - obj->getRadius() > depth_cutoff_front)
            continue;
        if (depth > 0 && obj->getRadius() / depth < 1.0f / 500)
            continue;
        int render_list_index = std::max(0, int((depth + obj->getRadius()) / 25000));
        while(render_list_index >= int(render_lists.size()))
            render_lists.emplace_back();
        render_lists[render_list_index].emplace_back(*obj, depth);
    }

    // Update view matrix in shaders.
    ShaderRegistry::updateProjectionView({}, view_matrix);


    for(int n=render_lists.size() - 1; n >= 0; n--)
    {
        auto& render_list = render_lists[n];
        std::sort(render_list.begin(), render_list.end(), [](const RenderInfo& a, const RenderInfo& b) { return a.depth > b.depth; });

        auto projection = glm::perspective(glm::radians(camera_fov), rect.size.x / rect.size.y, 1.f, 25000.f * (n + 1));
        // Update projection matrix in shaders.
        ShaderRegistry::updateProjectionView(projection, {});

        glDepthMask(true);

        glDisable(GL_BLEND);
        for(auto info : render_list)
        {
            SpaceObject* obj = info.object;
            obj->draw3D();
        }
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE);
        glDepthMask(false);
        for(auto info : render_list)
        {
            SpaceObject* obj = info.object;
            obj->draw3DTransparent();
        }
    }
    ParticleEngine::render(projection_matrix, view_matrix);

    if (show_spacedust && my_spaceship)
    {
        static std::vector<glm::vec3> space_dust(2 * spacedust_particle_count);
        
        glm::vec2 dust_vector = my_spaceship->getVelocity() / 100.f;
        glm::vec3 dust_center = glm::vec3(my_spaceship->getPosition().x, my_spaceship->getPosition().y, 0.f); 

        constexpr float maxDustDist = 500.f;
        constexpr float minDustDist = 100.f;
        
        bool update_required = false; // Do we need to update the GPU buffer?

        for (auto n = 0U; n < space_dust.size(); n += 2)
        {
            //
            auto delta = space_dust[n] - dust_center;
            if (glm::length2(delta) > maxDustDist*maxDustDist || glm::length2(delta) < minDustDist*minDustDist)
            {
                update_required = true;
                space_dust[n] = dust_center + glm::vec3(random(-maxDustDist, maxDustDist), random(-maxDustDist, maxDustDist), random(-maxDustDist, maxDustDist));
                space_dust[n + 1] = space_dust[n];
            }
        }

        spacedust_shader->bind();

        // Upload matrices (only float 4x4 supported in es2)
        glUniformMatrix4fv(spacedust_uniforms[static_cast<size_t>(Uniforms::Projection)], 1, GL_FALSE, glm::value_ptr(projection_matrix));
        glUniformMatrix4fv(spacedust_uniforms[static_cast<size_t>(Uniforms::View)], 1, GL_FALSE, glm::value_ptr(view_matrix));

        // Ship information for flying particles
        glUniform2f(spacedust_shader->getUniformLocation("velocity"), dust_vector.x, dust_vector.y);
        
        {
            gl::ScopedVertexAttribArray positions(spacedust_vertex_attributes[static_cast<size_t>(VertexAttributes::Position)]);
            gl::ScopedVertexAttribArray signs(spacedust_vertex_attributes[static_cast<size_t>(VertexAttributes::Sign)]);
            glBindBuffer(GL_ARRAY_BUFFER, spacedust_buffer[0]);
            
            if (update_required)
            {
                glBufferSubData(GL_ARRAY_BUFFER, 0, space_dust.size() * sizeof(glm::vec3), space_dust.data());
            }
            glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(glm::vec3), (GLvoid*)0);
            glVertexAttribPointer(signs.get(), 1, GL_FLOAT, GL_FALSE, 0, (GLvoid*)(2 * spacedust_particle_count * sizeof(glm::vec3)));
            
            glDrawArrays(GL_LINES, 0, 2 * spacedust_particle_count);
            glBindBuffer(GL_ARRAY_BUFFER, GL_NONE);
        }
    }

    if (my_spaceship && my_spaceship->getTarget())
    {
        ShaderRegistry::ScopedShader billboard(ShaderRegistry::Shaders::Billboard);

        P<SpaceObject> target = my_spaceship->getTarget();
        glDisable(GL_DEPTH_TEST);
        auto model_matrix = glm::translate(glm::identity<glm::mat4>(), glm::vec3(target->getPosition(), 0.f));


        textureManager.getTexture("redicule2.png")->bind();
        glUniformMatrix4fv(billboard.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));
        glUniform4f(billboard.get().uniform(ShaderRegistry::Uniforms::Color), .5f, .5f, .5f, target->getRadius() * 2.5f);
        {
            gl::ScopedVertexAttribArray positions(billboard.get().attribute(ShaderRegistry::Attributes::Position));
            gl::ScopedVertexAttribArray texcoords(billboard.get().attribute(ShaderRegistry::Attributes::Texcoords));
            auto vertices = {
                0.f, 0.f, 0.f,
                0.f, 0.f, 0.f,
                0.f, 0.f, 0.f,
            };
            glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, 0, (GLvoid*)vertices.begin());
            auto coords = {
                0.f, 1.f,
                1.f, 1.f,
                1.f, 0.f,
                0.f, 0.f
            };
            glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, 0, (GLvoid*)coords.begin());
            std::initializer_list<uint16_t> indices{ 0, 2, 1, 0, 3, 2 };
            glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, std::begin(indices));
        }
    }

    glDepthMask(true);
    glDisable(GL_BLEND);
    glEnable(GL_CULL_FACE);
/*
#ifdef DEBUG
    glDisable(GL_DEPTH_TEST);
    
    {
        ShaderRegistry::ScopedShader debug_shader(ShaderRegistry::Shaders::BasicColor);
        // Common state: color, projection matrix.
        glUniform4f(debug_shader.get().uniform(ShaderRegistry::Uniforms::Color), 1.f, 1.f, 1.f, 1.f);

        std::array<float, 16> matrix;
        glUniformMatrix4fv(debug_shader.get().uniform(ShaderRegistry::Uniforms::Projection), 1, GL_FALSE, glm::value_ptr(projection_matrix));

        std::vector<glm::vec3> points;
        gl::ScopedVertexAttribArray positions(debug_shader.get().attribute(ShaderRegistry::Attributes::Position));

        foreach(SpaceObject, obj, space_object_list)
        {
            glPushMatrix();
            glTranslatef(-camera_position.x, -camera_position.y, -camera_position.z);
            glTranslatef(obj->getPosition().x, obj->getPosition().y, 0);
            glRotatef(obj->getRotation(), 0, 0, 1);

            glGetFloatv(GL_MODELVIEW_MATRIX, matrix.data());
            glUniformMatrix4fv(debug_shader.get().uniform(ShaderRegistry::Uniforms::ModelView), 1, GL_FALSE, matrix.data());

            auto collisionShape = obj->getCollisionShape();

            if (collisionShape.size() > points.size())
            {
                points.resize(collisionShape.size());
                glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(glm::vec3), points.data());
            }

            for (unsigned int n = 0; n < collisionShape.size(); n++)
                points[n] = glm::vec3(collisionShape[n].x, collisionShape[n].y, 0.f);
            
            glDrawArrays(GL_LINE_LOOP, 0, collisionShape.size());
            glPopMatrix();
        }
    }
#endif
*/
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    if (show_callsigns && render_lists.size() > 0)
    {
        for(auto info : render_lists[0])
        {
            SpaceObject* obj = info.object;
            if (!obj->canBeTargetedBy(my_spaceship) || obj == *my_spaceship)
                continue;
            string call_sign = obj->getCallSign();
            if (call_sign == "")
                continue;

            glm::vec3 screen_position = worldToScreen(renderer, glm::vec3(obj->getPosition().x, obj->getPosition().y, obj->getRadius()));
            if (screen_position.z < 0.0f)
                continue;
            if (screen_position.z > 10000.0f)
                continue;
            float distance_factor = 1.0f - (screen_position.z / 10000.0f);
            renderer.drawText(sp::Rect(screen_position.x, screen_position.y, 0, 0), call_sign, sp::Alignment::Center, 20 * distance_factor, bold_font, glm::u8vec4(255, 255, 255, 128 * distance_factor));
        }
    }

    if (show_headings && my_spaceship)
    {
        float distance = 2500.f;

        for(int angle = 0; angle < 360; angle += 30)
        {
            glm::vec2 world_pos = my_spaceship->getPosition() + vec2FromAngle(angle - 90.f) * distance;
            glm::vec3 screen_pos = worldToScreen(renderer, glm::vec3(world_pos.x, world_pos.y, 0.0f));
            if (screen_pos.z > 0.0f)
                renderer.drawText(sp::Rect(screen_pos.x, screen_pos.y, 0, 0), string(angle), sp::Alignment::Center, 30, bold_font, glm::u8vec4(255, 255, 255, 128));
        }
    }

    glViewport(0, 0, renderer.getPhysicalSize().x, renderer.getPhysicalSize().y);
}

glm::vec3 GuiViewport3D::worldToScreen(sp::RenderTarget& renderer, glm::vec3 world)
{
    auto view_pos = view_matrix * glm::vec4(world, 1.f);
    auto pos = projection_matrix * view_pos;

    // Perspective division
    pos /= pos.w;

    //Window coordinates
    //Map x, y to range 0-1
    glm::vec3 ret;
    ret.x = pos.x * .5f + .5f;
    ret.y = pos.y * .5f + .5f;
    //This is only correct when glDepthRange(0.0, 1.0)
    //ret.z = (1.0+fTempo[6])*0.5;  //Between 0 and 1
    //Set Z to distance into the screen (negative is behind the screen)
    ret.z = -view_pos.z;

    ret.x = rect.position.x + rect.size.x * ret.x;
    ret.y = rect.position.y + rect.size.y * (1.0f - ret.y);
    return ret;
}
