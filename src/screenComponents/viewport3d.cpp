#include <SFML/OpenGL.hpp>

#include "main.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "viewport3d.h"

#include "particleEffect.h"

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

GuiViewport3D::GuiViewport3D(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    show_callsigns = false;
    show_headings = false;
    show_spacedust = false;
}

void GuiViewport3D::onDraw(sf::RenderTarget& window)
{
#if FEATURE_3D_RENDERING
    if (my_spaceship)
        soundManager->setListenerPosition(my_spaceship->getPosition(), my_spaceship->getRotation());
    else
        soundManager->setListenerPosition(sf::Vector2f(camera_position.x, camera_position.y), camera_yaw);
    window.popGLStates();

    ShaderManager::getShader("billboardShader")->setParameter("camera_position", camera_position);

    float camera_fov = 60.0f;
    float sx = window.getSize().x * window.getView().getViewport().width / window.getView().getSize().x;
    float sy = window.getSize().y * window.getView().getViewport().height / window.getView().getSize().y;
    glViewport(rect.left * sx, (float(window.getView().getSize().y) - rect.height - rect.top) * sx, rect.width * sx, rect.height * sy);

    glClearDepth(1.f);
    glClear(GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    glDepthMask(GL_TRUE);
    glEnable(GL_CULL_FACE);
    glColor4f(1,1,1,1);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    _glPerspective(camera_fov, rect.width/rect.height, 1.f, 25000.f);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glRotatef(90, 1, 0, 0);
    glScalef(1,1,-1);
    glRotatef(-camera_pitch, 1, 0, 0);
    glRotatef(-camera_yaw - 90, 0, 0, 1);

    glGetDoublev(GL_PROJECTION_MATRIX, projection_matrix);
    glGetDoublev(GL_MODELVIEW_MATRIX, model_matrix);
    glGetDoublev(GL_VIEWPORT, viewport);

    glDepthMask(false);
    sf::Texture::bind(textureManager.getTexture("StarsBack"), sf::Texture::Normalized);
    glBegin(GL_TRIANGLE_STRIP);
    glTexCoord2f(0.0, 0.0); glVertex3f( 100, 100, 100);
    glTexCoord2f(0.0, 1.0); glVertex3f( 100, 100,-100);
    glTexCoord2f(1.0, 0.0); glVertex3f(-100, 100, 100);
    glTexCoord2f(1.0, 1.0); glVertex3f(-100, 100,-100);
    glEnd();
    sf::Texture::bind(textureManager.getTexture("StarsLeft"), sf::Texture::Normalized);
    glBegin(GL_TRIANGLE_STRIP);
    glTexCoord2f(0.0, 0.0); glVertex3f(-100, 100, 100);
    glTexCoord2f(0.0, 1.0); glVertex3f(-100, 100,-100);
    glTexCoord2f(1.0, 0.0); glVertex3f(-100,-100, 100);
    glTexCoord2f(1.0, 1.0); glVertex3f(-100,-100,-100);
    glEnd();
    sf::Texture::bind(textureManager.getTexture("StarsFront"), sf::Texture::Normalized);
    glBegin(GL_TRIANGLE_STRIP);
    glTexCoord2f(0.0, 0.0); glVertex3f(-100,-100, 100);
    glTexCoord2f(0.0, 1.0); glVertex3f(-100,-100,-100);
    glTexCoord2f(1.0, 0.0); glVertex3f( 100,-100, 100);
    glTexCoord2f(1.0, 1.0); glVertex3f( 100,-100,-100);
    glEnd();
    sf::Texture::bind(textureManager.getTexture("StarsRight"), sf::Texture::Normalized);
    glBegin(GL_TRIANGLE_STRIP);
    glTexCoord2f(0.0, 0.0); glVertex3f( 100,-100, 100);
    glTexCoord2f(0.0, 1.0); glVertex3f( 100,-100,-100);
    glTexCoord2f(1.0, 0.0); glVertex3f( 100, 100, 100);
    glTexCoord2f(1.0, 1.0); glVertex3f( 100, 100,-100);
    glEnd();
    sf::Texture::bind(textureManager.getTexture("StarsTop"), sf::Texture::Normalized);
    glBegin(GL_TRIANGLE_STRIP);
    glTexCoord2f(0.0, 0.0); glVertex3f(-100, 100, 100);
    glTexCoord2f(0.0, 1.0); glVertex3f(-100,-100, 100);
    glTexCoord2f(1.0, 0.0); glVertex3f( 100, 100, 100);
    glTexCoord2f(1.0, 1.0); glVertex3f( 100,-100, 100);
    glEnd();
    sf::Texture::bind(textureManager.getTexture("StarsBottom"), sf::Texture::Normalized);
    glBegin(GL_TRIANGLE_STRIP);
    glTexCoord2f(1.0, 0.0); glVertex3f( 100,-100,-100);
    glTexCoord2f(0.0, 0.0); glVertex3f(-100,-100,-100);
    glTexCoord2f(1.0, 1.0); glVertex3f( 100, 100,-100);
    glTexCoord2f(0.0, 1.0); glVertex3f(-100, 100,-100);
    glEnd();

    if (gameGlobalInfo)
    {
        //Render the background nebulas from the gameGlobalInfo. This ensures that all screens see the same background as it is replicated across clients.
        for(int n=0; n<GameGlobalInfo::max_nebulas; n++)
        {
            sf::Texture::bind(textureManager.getTexture(gameGlobalInfo->nebula_info[n].textureName), sf::Texture::Pixels);
            glEnable(GL_BLEND);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE);
            glPushMatrix();
            glRotatef(180, gameGlobalInfo->nebula_info[n].vector.x, gameGlobalInfo->nebula_info[n].vector.y, gameGlobalInfo->nebula_info[n].vector.z);
            glColor4f(1,1,1,0.1);
            glBegin(GL_TRIANGLE_STRIP);
            glTexCoord2f(1.0,    0); glVertex3f( 100, 100, 100);
            glTexCoord2f(   0,    0); glVertex3f( 100, 100,-100);
            glTexCoord2f(1.0, 1.0); glVertex3f(-100, 100, 100);
            glTexCoord2f(   0, 1.0); glVertex3f(-100, 100,-100);
            glEnd();
            glPopMatrix();
        }
    }

    {
        float lightpos1[4] = {0, 0, 0, 1.0};
        glLightfv(GL_LIGHT1, GL_POSITION, lightpos1);

        float lightpos0[4] = {20000, 20000, 20000, 1.0};
        glLightfv(GL_LIGHT0, GL_POSITION, lightpos0);
    }

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
    
    sf::Vector2f viewVector = sf::vector2FromAngle(camera_yaw);
    float depth_cutoff_back = camera_position.z * -tanf((90+camera_pitch + camera_fov/2.0) / 180.0f * M_PI);
    float depth_cutoff_front = camera_position.z * -tanf((90+camera_pitch - camera_fov/2.0) / 180.0f * M_PI);
    if (camera_pitch - camera_fov/2.0 <= 0.0)
        depth_cutoff_front = std::numeric_limits<float>::infinity();
    if (camera_pitch + camera_fov/2.0 >= 180.0)
        depth_cutoff_back = -std::numeric_limits<float>::infinity();
    foreach(SpaceObject, obj, space_object_list)
    {
        float depth = sf::dot(viewVector, obj->getPosition() - sf::Vector2f(camera_position.x, camera_position.y));
        if (depth + obj->getRadius() < depth_cutoff_back)
            continue;
        if (depth - obj->getRadius() > depth_cutoff_front)
            continue;
        if (depth > 0 && obj->getRadius() / depth < 1.0 / 500)
            continue;
        int render_list_index = std::max(0, int((depth + obj->getRadius()) / 25000));
        while(render_list_index >= int(render_lists.size()))
            render_lists.emplace_back();
        render_lists[render_list_index].emplace_back(*obj, depth);
    }
    
    for(int n=render_lists.size() - 1; n >= 0; n--)
    {
        auto& render_list = render_lists[n];
        std::sort(render_list.begin(), render_list.end(), [](const RenderInfo& a, const RenderInfo& b) { return a.depth > b.depth; });
        
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        _glPerspective(camera_fov, rect.width/rect.height, 1.f, 25000.f * (n + 1));
        glMatrixMode(GL_MODELVIEW);
        glDepthMask(true);
        glClear(GL_DEPTH_BUFFER_BIT);

        glColor4f(1,1,1,1);
        glDisable(GL_BLEND);
        sf::Texture::bind(NULL);
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_CULL_FACE);
        for(auto info : render_list)
        {
            SpaceObject* obj = info.object;

            glPushMatrix();
            glTranslatef(-camera_position.x,-camera_position.y, -camera_position.z);
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
        for(auto info : render_list)
        {
            SpaceObject* obj = info.object;

            glPushMatrix();
            glTranslatef(-camera_position.x,-camera_position.y, -camera_position.z);
            glTranslatef(obj->getPosition().x, obj->getPosition().y, 0);
            glRotatef(obj->getRotation(), 0, 0, 1);

            obj->draw3DTransparent();
            glPopMatrix();
        }
    }

    glPushMatrix();
    glTranslatef(-camera_position.x,-camera_position.y, -camera_position.z);
    ParticleEngine::render();
    
    if (show_spacedust && my_spaceship)
    {
        static std::vector<sf::Vector3f> space_dust;

        while(space_dust.size() < 1000)
            space_dust.push_back(sf::Vector3f());

        sf::Vector2f dust_vector = my_spaceship->getVelocity() / 100.0f;
        sf::Vector3f dust_center = sf::Vector3f(my_spaceship->getPosition().x, my_spaceship->getPosition().y, 0.0);
        glColor4f(0.7, 0.5, 0.35, 0.07);
        
        for(unsigned int n=0; n<space_dust.size(); n++)
        {
            const float maxDustDist = 500.0f;
            const float minDustDist = 100.0f;
            glPushMatrix();
            if ((space_dust[n] - dust_center) > maxDustDist || (space_dust[n] - dust_center) < minDustDist)
                space_dust[n] = dust_center + sf::Vector3f(random(-maxDustDist, maxDustDist), random(-maxDustDist, maxDustDist), random(-maxDustDist, maxDustDist));
            glTranslatef(space_dust[n].x, space_dust[n].y, space_dust[n].z);
            glBegin(GL_LINES);
            glVertex3f(-dust_vector.x, -dust_vector.y, 0);
            glVertex3f( dust_vector.x,  dust_vector.y, 0);
            glEnd();
            glPopMatrix();
        }
    }
    glPopMatrix();

    if (my_spaceship && my_spaceship->getTarget())
    {
        P<SpaceObject> target = my_spaceship->getTarget();
        glDisable(GL_DEPTH_TEST);
        glPushMatrix();
        glTranslatef(-camera_position.x,-camera_position.y, -camera_position.z);
        glTranslatef(target->getPosition().x, target->getPosition().y, 0);

        ShaderManager::getShader("billboardShader")->setParameter("textureMap", *textureManager.getTexture("redicule2.png"));
        sf::Shader::bind(ShaderManager::getShader("billboardShader"));
        glColor4f(0.5, 0.5, 0.5, target->getRadius() * 2.5);
        glBegin(GL_QUADS);
        glTexCoord2f(0, 0);
        glVertex3f(0, 0, 0);
        glTexCoord2f(1, 0);
        glVertex3f(0, 0, 0);
        glTexCoord2f(1, 1);
        glVertex3f(0, 0, 0);
        glTexCoord2f(0, 1);
        glVertex3f(0, 0, 0);
        glEnd();
        glPopMatrix();
    }

    glDepthMask(true);
    glDisable(GL_BLEND);
    glEnable(GL_CULL_FACE);
    sf::Shader::bind(NULL);
    glColor3f(1, 1, 1);

#ifdef DEBUG
    glDisable(GL_DEPTH_TEST);
    foreach(SpaceObject, obj, space_object_list)
    {
        glPushMatrix();
        glTranslatef(-camera_position.x,-camera_position.y, -camera_position.z);
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

    window.pushGLStates();

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
            
            sf::Vector3f screen_position = worldToScreen(window, sf::Vector3f(obj->getPosition().x, obj->getPosition().y, obj->getRadius()));
            if (screen_position.z < 0)
                continue;
            if (screen_position.z > 10000.0)
                continue;
            float distance_factor = 1.0f - (screen_position.z / 10000.0f);
            drawText(window, sf::FloatRect(screen_position.x, screen_position.y, 0, 0), call_sign, ACenter, 20 * distance_factor, bold_font, sf::Color(255, 255, 255, 128 * distance_factor));
        }
    }
    
    if (show_headings && my_spaceship)
    {
        float distance = 2500.f;
        
        for(int angle = 0; angle < 360; angle += 30)
        {
            sf::Vector2f world_pos = my_spaceship->getPosition() + sf::vector2FromAngle(float(angle - 90)) * distance;
            sf::Vector3f screen_pos = worldToScreen(window, sf::Vector3f(world_pos.x, world_pos.y, 0.0f));
            if (screen_pos.z > 0.0f)
                drawText(window, sf::FloatRect(screen_pos.x, screen_pos.y, 0, 0), string(angle), ACenter, 30, bold_font, sf::Color(255, 255, 255, 128));
        }
    }
#endif//FEATURE_3D_RENDERING
}

sf::Vector3f GuiViewport3D::worldToScreen(sf::RenderTarget& window, sf::Vector3f world)
{
    world -= camera_position;
    
    //Transformation vectors
    float fTempo[8];
    //Modelview transform
    fTempo[0] = model_matrix[0]*world.x+model_matrix[4]*world.y+model_matrix[8]*world.z+model_matrix[12];  //w is always 1
    fTempo[1] = model_matrix[1]*world.x+model_matrix[5]*world.y+model_matrix[9]*world.z+model_matrix[13];
    fTempo[2] = model_matrix[2]*world.x+model_matrix[6]*world.y+model_matrix[10]*world.z+model_matrix[14];
    fTempo[3] = model_matrix[3]*world.x+model_matrix[7]*world.y+model_matrix[11]*world.z+model_matrix[15];
    //Projection transform, the final row of projection matrix is always [0 0 -1 0]
    //so we optimize for that.
    fTempo[4] = projection_matrix[0]*fTempo[0]+projection_matrix[4]*fTempo[1]+projection_matrix[8]*fTempo[2]+projection_matrix[12]*fTempo[3];
    fTempo[5] = projection_matrix[1]*fTempo[0]+projection_matrix[5]*fTempo[1]+projection_matrix[9]*fTempo[2]+projection_matrix[13]*fTempo[3];
    fTempo[6] = projection_matrix[2]*fTempo[0]+projection_matrix[6]*fTempo[1]+projection_matrix[10]*fTempo[2]+projection_matrix[14]*fTempo[3];
    fTempo[7] = -fTempo[2];
    //The result normalizes between -1 and 1
    if(fTempo[7]==0.0)	//The w value
        return sf::Vector3f(0, 0, -1);
    fTempo[7] = 1.0/fTempo[7];
    //Perspective division
    fTempo[4] *= fTempo[7];
    fTempo[5] *= fTempo[7];
    fTempo[6] *= fTempo[7];
    //Window coordinates
    //Map x, y to range 0-1
    sf::Vector3f ret;
    ret.x = (fTempo[4]*0.5+0.5)*viewport[2]+viewport[0];
    ret.y = (fTempo[5]*0.5+0.5)*viewport[3]+viewport[1];
    //This is only correct when glDepthRange(0.0, 1.0)
    //ret.z = (1.0+fTempo[6])*0.5;	//Between 0 and 1
    //Set Z to distance into the screen (negative is behind the screen)
    ret.z = -fTempo[2];
    
    ret.x = ret.x * window.getView().getSize().x / window.getSize().x;
    ret.y = ret.y * window.getView().getSize().y / window.getSize().y;
    ret.y = window.getView().getSize().y - ret.y;
    return ret;
}
