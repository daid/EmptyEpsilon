/*TODO
// Draw a line toward the target position
void WormHole::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    auto offset = target_position - getPosition();
    renderer.drawLine(position, position + glm::vec2(offset.x, offset.y) * scale, glm::u8vec4(255, 255, 255, 32));

    renderer.drawCircleOutline(position, 5000.0f * scale, 2.0, glm::u8vec4(255, 255, 255, 32));
}
*/