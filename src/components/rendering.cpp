#include "mesh.h"
#include "textureManager.h"
#include "rendering.h"

Mesh* MeshRenderComponent::getMesh()
{
    if (!mesh.ptr && !mesh.name.empty())
        mesh.ptr = Mesh::getMesh(mesh.name);
    return mesh.ptr;
}

sp::Texture* MeshRenderComponent::getTexture()
{
    if (!texture.ptr && !texture.name.empty())
        texture.ptr = textureManager.getTexture(texture.name);
    return texture.ptr;
}

sp::Texture* MeshRenderComponent::getSpecularTexture()
{
    if (!specular_texture.ptr && !specular_texture.name.empty())
        specular_texture.ptr = textureManager.getTexture(specular_texture.name);
    return specular_texture.ptr;
}

sp::Texture* MeshRenderComponent::getIlluminationTexture()
{
    if (!illumination_texture.ptr && !illumination_texture.name.empty())
        illumination_texture.ptr = textureManager.getTexture(illumination_texture.name);
    return illumination_texture.ptr;
}

