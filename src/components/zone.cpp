#include "zone.h"
#include "math/centerOfMass.h"
#include "math/triangulate.h"


void Zone::updateTriangles()
{
    // Re-initalize the zone radius cache and shape.
    radius = 1.0f;
    triangles.clear();

    // If there aren't any points, clear the shape.
    if (outline.empty()) return;

    // Place the label at the center of the outline.
    label_offset = centerOfMass(outline);

    // Populate the shape and recalculate radius from outline points.
    for (auto p : outline)
    {
        p -= label_offset;
        radius = std::max(radius, glm::length(p));
    }

    // Re-triangulate the shape.
    Triangulate::process(outline, triangles);
}
