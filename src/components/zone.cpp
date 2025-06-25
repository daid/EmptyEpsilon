#include "zone.h"
#include "math/centerOfMass.h"
#include "math/triangulate.h"


void Zone::updateTriangles()
{
    if (outline.empty()) {
        radius = 1;
        triangles.clear();
        return;
    }

    label_offset = centerOfMass(outline);
    radius = 1;
    for(auto p : outline) {
        p -= label_offset;
        radius = std::max(radius, glm::length(p));
    }
    
    triangles.clear();
    Triangulate::process(outline, triangles);
}