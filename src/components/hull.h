#pragma once

// Marker component to indicate that this entity has a hull and can take hull
// damage. Entity health, presented as hull integrity, is tracked in the Health
// component.
// If an entity has the Hull component, it gains certain ship-like properties:
// - Automatic health regeneration from DockingBay entities with the
//   DockingBay::Repair flag (as hull repairs)
// - Can be targeted by AI
// - Can be selected on Relay and Science radars
// - With Health component, display of health values as hull percentage/points
//   in user interfaces
class Hull
{
public:
};
