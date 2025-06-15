#include "rawScannerUtil.h"
#include "ecs/query.h"
#include "components/radar.h"
#include "components/radarblock.h"
#include "playerInfo.h"
#include "random.h"
#include "components/collision.h"
#include "utils/FastNoiseLite.h"
#include "engine.h" // Include SeriousProton's engine header for time functionality

#define NOISE_OFFSET 7
FastNoiseLite noise = FastNoiseLite(0);


float sumFunction(float angle, float target_angle, float target_angle_width)
{
    // Calculate the minimum unsigned angle difference
    float angle_diff = fmod(fabs(angle - target_angle), 360.0f);
    if (angle_diff > 180.0f)
        angle_diff = 360.0f - angle_diff;

    float temp = angle_diff / target_angle_width;
    return 1 - temp * temp;
}

float farSumFunction(float angle, float target_angle, float target_angle_width, float resolution)
{
    // If the whole target width is within one resolution, we just return 1.
    if (target_angle_width < resolution / 2 && abs(angle - target_angle) < resolution / 2)
        return 1;
    // If none of the target angle is within the resolution, we return 0.
    if (abs(angle - target_angle) > resolution / 2 + target_angle_width / 2)
        return 0;
    // Otherwise, we return a linear interpolation between 0 and 1.
    float p = 2 * abs(target_angle - angle) / (resolution  + target_angle_width );
    return 1 - p;
}

float noiseFunction(float angle, float offset, float second_offset, float noise_floor)
{
    // Here we use a 3D noise to have a noise with continuity in the end
    return 0.7 * noise_floor * (noise.GetNoise(200.0f * cosf(M_PI * angle/180.0f), 100.0f * sinf(M_PI * angle/180.0f), offset + second_offset) - 0.5f) + random(-noise_floor, noise_floor);
}

std::vector<RawScannerDataPoint> CalculateRawScannerData(glm::vec2 position, float start_angle, float arc_size, uint point_count, float range, float noise_floor)
{
    // Sanitize the input parameters.
    if (start_angle<0)
        start_angle += 360.0f;
    
    start_angle = fmod(start_angle, 360.0f);
    if (start_angle<0)
        start_angle += 360.0f;
    arc_size = glm::clamp(arc_size, 0.0f, 360.0f - 360.0f / point_count);

    
    // Initialize the data's amplitude along each of the three color bands.
    std::vector<RawScannerDataPoint> return_data_points(point_count);

    float resolution = arc_size / point_count;

    // Pre allocate the angles for computational speed
    float angles[point_count];
    for (int i = 0; i < point_count; i++)
    {
        // Here we do not want to wrap around as the sum function needs it to not wrap around.
        angles[i] = fmod(start_angle + i * resolution, 360.0f);
        if (angles[i] < 0.0f)
            angles[i] += 360.0f;
    }

    // For each SpaceObject ...
    // TODO: Using the same segmented query as the pathfinding might be more efficient
    for (auto [entity, signature, dynamic_signature, transform] : sp::ecs::Query<RawRadarSignatureInfo, sp::ecs::optional<DynamicRadarSignatureInfo>, sp::Transform>())
    {
        // Don't measure our own ship.
        if (entity == my_spaceship)
            continue;

        // Initialize angle, distance, and scale variables.
        float dist = glm::length(transform.getPosition() - position);

        // If the object is further than the maximum range
        // ignore it
        if (dist > range)
            continue;


        // This is used to activate the quadratic interpolation
        bool is_close = false;
        float scale = 1.0;

        float size = GetEntityRadarTraceSize(entity);
        if (size > dist)
        {
            scale = 1.0f;
            is_close = true;
        }
        else
        {
            // if we are out of the object, we want to
            // have a linear interpolation to the range
            scale = 1 - (dist - size) / (range - size);
        }

        // Get object position
        float a_center = vec2ToAngle(transform.getPosition() - position);

        float a_diff;

        // Special case to use a different summing function if the object is very far
        float is_far = false;
        // p is used for interpolation
        float p = 0;
        float p2 = 0;

        // Calculate the angle of the object
        if (is_close)
        {
            p = 1 - dist / size;
            p2 = (p - 0.1) /  0.9;
            a_diff = glm::min(90.0f + 90.0f * 10 * p, 179.999f);
        }
        else
        {
            // Exposed angular size of the object
            a_diff = glm::degrees(asinf(size / dist));
            // If we are very fare we need to use a different summing function
            // To make sure we see it on the radar
            if (a_diff < resolution /2 )
            {
                is_far = true;
                a_diff += 2 * resolution;
            }
        }

        //  Transform to start at start_angle for ease to resolve
        float target_start = fmod(a_center - a_diff - start_angle, 360.0f);
        if (target_start < 0)
            target_start += 360.0f;

        float target_stop = fmod(a_center + a_diff - start_angle, 360.0f);
        if (target_stop < 0)
            target_stop += 360.0f;

        auto cover_arc = [resolution,
            point_count,
            &angles,
            p,
            p2,
            is_far,
            a_center,
            a_diff,
            scale,
            &signature,
            dynamic_signature,
            &return_data_points](float start_angle, float stop_angle) 
        { 
            // Here we need to find where the angle starts to do the sum
            int target_start_angle_index = (int)ceil(start_angle / resolution);
            int target_stop_angle_index = (int)ceil(stop_angle / resolution);
            for (int i = target_start_angle_index; i < target_stop_angle_index; i++)
            {
                float summing_function_value = 0;
                if (p2 == 0)
                {
                    // If we do not intersect with the object we just use the sensor
                    // signal function 1 - (x/(2*a_diff)^2
                    if (is_far)
                        summing_function_value = farSumFunction(angles[i], a_center, a_diff, resolution);
                    else
                        summing_function_value = sumFunction(angles[i], a_center, a_diff);
                }
                else
                {
                    // If we are in the object, we do a quadratic interpolation with 1 depending on the closeness.
                    summing_function_value = sumFunction(angles[i], a_center, a_diff);
                    if (p > 0.1)
                    {
                        summing_function_value = summing_function_value * (1 - p2) + p2;
                    }
                }
    
                float g = signature.biological;
                float r = signature.electrical;
                float b = signature.gravity;
    
                if (dynamic_signature)
                {
                    g += dynamic_signature->biological;
                    r += dynamic_signature->electrical;
                    b += dynamic_signature->gravity;
                }
    
                return_data_points[i].biological += g * summing_function_value * scale;
                return_data_points[i].electrical += r * summing_function_value * scale;
                return_data_points[i].gravity += b * summing_function_value * scale;
            }
        };

        if (target_start < arc_size && target_stop < arc_size && target_stop > target_start)
        {
            cover_arc(target_start, target_stop);
        }
        else if(target_start > arc_size && target_stop > arc_size && target_stop < target_start)
        {
            cover_arc(0, arc_size);
        }
        else
        {
            if (target_start < arc_size)
            {
                cover_arc(target_start, arc_size); 
            }
            if (target_stop < arc_size)
            {
                cover_arc(0, target_stop); 
            }
        }

    }


    static float noise_offset = 0.0f;
    // For each data point ...
    // Now post processing to be as close to what it was before
    for (int i = 0; i < point_count; i++)
    {

        // noise_floor * (noise.GetNoise(i, noise_offset) - 0.5f);
        return_data_points[i].biological =  fmaxf(return_data_points[i].biological, 0) * 40;
        return_data_points[i].electrical =  random(-10, 30) * fmaxf(return_data_points[i].electrical, 0);
        return_data_points[i].gravity =  (random(-10, 10) + 30) * fmaxf(return_data_points[i].gravity, 0);
        

        if (return_data_points[i].biological > 0)
            return_data_points[i].biological = sqrt(1 + return_data_points[i].biological) - 1;
        else
            return_data_points[i].biological = -(sqrt(1 - return_data_points[i].biological) - 1);

        if (return_data_points[i].electrical > 0)
            return_data_points[i].electrical = sqrt(1 + return_data_points[i].electrical) - 1;
        else
            return_data_points[i].electrical = -(sqrt(1 - return_data_points[i].electrical) - 1);

        if (return_data_points[i].gravity > 0)
            return_data_points[i].gravity = sqrt(1 + return_data_points[i].gravity) - 1;
        else
            return_data_points[i].gravity = -(sqrt(1 - return_data_points[i].gravity) - 1);

        return_data_points[i].biological += noiseFunction(angles[i], noise_offset, 0, noise_floor);
        return_data_points[i].electrical += noiseFunction(angles[i], noise_offset, 1000, noise_floor);
        return_data_points[i].gravity += noiseFunction(angles[i], noise_offset, 2000, noise_floor);
        return_data_points[i].biological *= 0.5;
        return_data_points[i].electrical *= 0.5;
        return_data_points[i].gravity *= 0.5;
    }
    // TODO: Change this by a time base movement.
    noise_offset += NOISE_OFFSET;
    if (noise_offset > 3000000)
        noise_offset = 0;

    return return_data_points;
}


std::vector<RawScannerDataPoint> Calculate360RawScannerData(glm::vec2 position, uint point_count, float range, float noise_floor)
{
    return CalculateRawScannerData(position, 0, 360 - 360 / float(point_count), point_count, range, noise_floor);
}

float GetEntityRadarTraceSize(sp::ecs::Entity entity)
{
    float size;
    auto signature = entity.getComponent<RawRadarSignatureInfo>();
    if (signature && signature->size != 0)
        return signature->size;

    // Fallback to physics entity
    auto physics = entity.getComponent<sp::Physics>();
    if(physics)
        return physics->getSize().x;

    // Fallback to radar block for nebulas
    auto radar_block = entity.getComponent<RadarBlock>();
    if (radar_block)
        return radar_block->range;
    
    return 300.0f;
}
