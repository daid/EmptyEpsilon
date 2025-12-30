#pragma once

// Marker component to indicate that this entity has a hull and can take hull
// damage. Entity health, presented as hull integrity, is tracked in the Health
// component.
// Health is displayed in player-facing interfaces like the Science UI only
// when the entity also has the Hull component.
class Hull
{
public:
};
