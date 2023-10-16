/*TODO
void WarpJammerObject::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    glm::u8vec4 color(200, 150, 100, 255);
    if (my_spaceship && Faction::getRelation(my_spaceship, entity) == FactionRelation::Enemy)
        color = glm::u8vec4(255, 0, 0, 255);
    renderer.drawSprite("radar/blip.png", position, 20, color);

    if (long_range)
    {
        if (auto jammer = entity.getComponent<WarpJammer>()) {
            color = glm::u8vec4(200, 150, 100, 64);
            if (my_spaceship && Faction::getRelation(my_spaceship, entity) == FactionRelation::Enemy)
                color = glm::u8vec4(255, 0, 0, 64);
            renderer.drawCircleOutline(position, jammer->range*scale, 2.0, color);
        }
    }
}
*/