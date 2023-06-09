__model_data = {}

--- A ModelData object contains 3D appearance and SeriousProton physics collision details.
--- Almost all SpaceObjects have a ModelData associated with them to define how they appear in 3D views.
--- A ScienceDatabase entry can also have ModelData associated with and displayed in it.
---
--- This defines a 3D mesh file, an albedo map ("texture"), a specular/normal map, and an illumination map.
--- These files might be located in the resources/ directory or loaded from resource packs.
---
--- ModelData also defines the model's position offset and scale relative to its mesh coordinates.
--- If the model is for a SpaceShip with weapons or thrusters, this also defines the origin positions of its weapon effects, and particle emitters for thruster and engine effects.
--- For physics, this defines the model's radius for a circle collider, or optional box collider dimensions.
--- (While ModelData defines 3D models, EmptyEpsilon uses a 2D physics engine for collisions.)
--- 
--- EmptyEpsilon loads ModelData from scripts/model_data.lua when launched, and loads meshes and textures when an object using this ModelData is first viewed.
---  
--- For complete examples, see scripts/model_data.lua.
ModelData = createClass()

--- Sets this ModelData's name.
--- Use this name when referencing a ModelData from other objects.
--- Example: model:setName("space_station_1")
function ModelData:setName(name)
    __model_data[name] = self
    return self
end
--- Sets this ModelData's mesh file.
--- Required; if omitted, this ModelData generates an error.
--- Valid values include OBJ-format (.obj extension) 3D models relative to the resources/ directory.
--- You can also reference models from resource packs, which have ".model" extensions.
--- To view resource pack paths, extract strings from the pack, such as by running "strings packs/Angryfly.pack | grep -i model"  on *nix.
--- For example, this lists "battleship_destroyer_2_upgraded/battleship_destroyer_2_upgraded.model", which is a valid mesh path.
--- Examples:
--- setMesh("space_station_1/space_station_1.model") -- loads this model from a resource pack
--- setMesh("mesh/sphere.obj") -- loads this model from the resources/ directory
function ModelData:setMesh(name)
    if self.mesh_render == nil then self.mesh_render = {} end
    self.mesh_render.mesh=name
    return self
end
--- Sets this ModelData's albedo map, or base flat-light color texture.
--- Required; if omitted, this ModelData generates an error.
--- Valid values include PNG- or JPG-format images relative to the resources/ directory.
--- You can also reference textures from resource packs.
--- To view resource pack paths, extract strings from the pack, such as by running "strings packs/Angryfly.pack | egrep -i (png|jpg)" on *nix.
--- Examples:
--- model:setTexture("space_station_1/space_station_1_color.jpg") -- loads this texture from a resource pack
--- model:setTexture("mesh/ship/Ender Battlecruiser.png") -- loads this texture from the resources/ directory
function ModelData:setTexture(texture)
    if self.mesh_render == nil then self.mesh_render = {} end
    self.mesh_render.texture=texture
    return self
end
--- Sets this ModelData's specular map, or shininess texture. Some models use this to load a normal map.
--- Optional; if omitted, no specular map is applied.
--- Valid values include PNG- or JPG-format images relative to the resources/ directory.
--- You can also reference textures from resource packs.
--- To view resource pack paths, extract strings from the pack, such as by running "strings packs/Angryfly.pack | egrep -i (png|jpg)" on *nix.
--- Examples:
--- model:setSpecular("space_station_1/space_station_1_specular.jpg") -- loads this texture from a resource pack
--- model:setSpecular("mesh/various/debris-blog-specular.jpg") -- loads this texture from the resources/ directory
function ModelData:setSpecular(texture)
    if self.mesh_render == nil then self.mesh_render = {} end
    self.mesh_render.specular_texture=texture
    return self
end
--- Sets this ModelData's illumination map, or glow texture, which defines which parts of the texture appear to be luminescent.
--- Optional; if omitted, no illumination map is applied.
--- Valid values include PNG- or JPG-format images relative to the resources/ directory.
--- You can also reference textures from resource packs.
--- To view resource pack paths, extract strings from the pack, such as by running "strings packs/Angryfly.pack | egrep -i (png|jpg)" on *nix.
--- Examples:
--- model:setIllumination("space_station_1/space_station_1_illumination.jpg") -- loads this texture from a resource pack
--- model:setIllumination("mesh/ship/Ender Battlecruiser_illumination.png") -- loads this texture from the resources/ directory
function ModelData:setIllumination(texture)
    if self.mesh_render == nil then self.mesh_render = {} end
    self.mesh_render.illumination_texture=texture
    return self
end
--- Sets this ModelData's mesh offset, relative to its position in its mesh data.
--- If a 3D mesh's central origin point is not at 0,0,0, use this to compensate.
--- If you view the model in Blender, these values are equivalent to -X,+Y,+Z.
--- Example: model:setRenderOffset(1,2,5) -- offsets its in-game position from its mesh file position when rendered
function ModelData:setRenderOffset(x, y, z)
    if self.mesh_render == nil then self.mesh_render = {} end
    self.mesh_render.mesh_offset = {x, y, z}
    return self
end
--- Scales this ModelData's mesh by the given factor.
--- Values greater than 1.0 scale the model up, and values between 0 and 1.0 scale it down.
--- Use this if models you load are smaller or larger than expected.
--- Defaults to 1.0.
--- Example: model:setScale(20) -- scales the model up by 20x
function ModelData:setScale()
    if self.mesh_render == nil then self.mesh_render = {} end
    self.mesh_render.scale = {x, y, z}
    return self
end
--- Sets this ModelData's base radius.
--- By default, EmptyEpsilon uses this to create a circular collider around objects that use this ModelData.
--- SpaceObject:setRadius() can override this for colliders.
--- Setting a box collider with ModelData:setCollisionBox() also overrides this.
--- Defaults to 1.0.
--- Example: model:setRadius(100) -- sets the object's collisionable radius to 0.1U
function ModelData:setRadius(radius)
    if self.physics == nil then self.physics={type="dynamic"} end
    self.physics.size = radius
    return self
end
--- Sets a 2D box collider for this ModelData.
--- If both values are greater than 0.0, this overrides ModelData:setRadius() for collisions.
--- Defaults to 0,0.
--- Example: model:setCollisionBox(400, 400) -- sets the object's collision box to 0.4U by 0.4U
function ModelData:setCollisionBox(w, h)
    if self.physics == nil then self.physics={type="dynamic"} end
    self.physics.size = {w, h}
    return self
end
--- Adds a BeamEffect origin position to this ModelData.
--- If no origin positions are defined, this defaults to the model's origin (0,0,0).
--- If you view the model in Blender, these coordinate values are equivalent to -X,+Y,+Z.
--- Example:
--- -- Add a beam position at the given model X/Y/Z coordinates.
--- model:addBeamPosition(21,-28.2,-2)
function ModelData:addBeamPosition(x, y, z)
    if self.__beam_positions == nil then self.__beam_positions = {} end
    self.__beam_positions[#self.__beam_positions + 1] = {x, y, z}
    return self
end
--- Adds a WeaponTube origin position to this ModelData.
--- If no origin positions are defined, this defaults to the model's origin (0,0,0).
--- If you view the model in Blender, these coordinate values are equivalent to -X,+Y,+Z.
--- -- Add a tube position at the given model X/Y/Z coordinates.
--- model:addTubePosition(21,-28.2,-2)
function ModelData:addTubePosition()
    if self.__tube_positions == nil then self.__tube_positions = {} end
    self.__tube_positions[#self.__tube_positions + 1] = {x, y, z}
    return self
end
--- [DEPRECATED]
--- Use ModelData:addEngineEmitter().
function ModelData:addEngineEmitor(x, y, z, r, g, b, scale)
    print("Called DEPRECATED addEngineEmitor function")
    return self:addEngineEmitter(x, y, z, r, g, b, scale)
end
--- Adds an impulse engine particle effect emitter to this ModelData.
--- When a SpaceShip engages impulse engines, this defines the position, color, and size of a particle trail effect.
--- If no origin positions are defined, this defaults to the model's origin (0,0,0).
--- If you view the model in Blender, these coordinate values are equivalent to -X,+Y,+Z.
--- Example:
--- -- Add an engine emitter at the given model X/Y/Z coordinates, with a RGB color of 1.0/0.2/0.2 and scale of 3.
--- model:addEngineEmitter(-28, 1.5,-5,1.0,0.2,0.2,3.0)
function ModelData:addEngineEmitter(x, y, z, r, g, b, scale)
    return self
end
