/*TODO
void PlayerSpaceship::addToShipLog(string message, glm::u8vec4 color)
{
    auto& log = entity.getOrAddComponent<ShipLog>();
    log.add(message, color);
}

void PlayerSpaceship::addToShipLogBy(string message, P<SpaceObject> target)
{
    // Log messages received from other ships. Friend-or-foe colors are drawn
    // from colorConfig (colors.ini).
    if (!target)
        addToShipLog(message, colorConfig.log_receive_neutral);
    else if (isFriendly(target))
        addToShipLog(message, colorConfig.log_receive_friendly);
    else if (isEnemy(target))
        addToShipLog(message, colorConfig.log_receive_enemy);
    else
        addToShipLog(message, colorConfig.log_receive_neutral);
}
*/
/*TODO
void PlayerSpaceship::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    if (long_range)
    {
        float long_radar_indicator_radius = getLongRangeRadarRange() * scale;
        float short_radar_indicator_radius = getShortRangeRadarRange() * scale;

        // Draw long-range radar radius indicator
        renderer.drawCircleOutline(position, long_radar_indicator_radius, 3.0, glm::u8vec4(255, 255, 255, 64));

        // Draw short-range radar radius indicator
        renderer.drawCircleOutline(position, short_radar_indicator_radius, 3.0, glm::u8vec4(255, 255, 255, 64));
    }
}
*/
