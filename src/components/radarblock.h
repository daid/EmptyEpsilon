#pragma once

// Component that blocks long range radar, usually a nebula, but, potential for other things as well.
class RadarBlock
{
public:
    float range = 5000.0;
    bool behind = true; //Also block everything behind this radar block. Setting this to false allow creating of "blackout spots"
};

// Entities with this component are never blocked on the long range rader by RadarBlock entities.
class NeverRadarBlocked
{
};
