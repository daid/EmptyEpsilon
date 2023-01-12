#include "systems/selfdestruct.h"
#include "components/selfdestruct.h"
#include "components/collision.h"
#include "systems/damage.h"
#include "ecs/query.h"
#include "multiplayer_server.h"
#include "spaceObjects/spaceObject.h"
#include "spaceObjects/explosionEffect.h"
#include "random.h"


void SelfDestructSystem::update(float delta)
{
    if (!game_server) return;

    for(auto [entity, self_destruct] : sp::ecs::Query<SelfDestruct>()) {
        if (!self_destruct.active) continue;

        // If self-destruct has been activated but not started ...
        if (self_destruct.countdown <= 0.0f)
        {
            bool do_self_destruct = true;
            // ... wait until the confirmation codes are entered.
            for(int n = 0; n < SelfDestruct::max_codes; n++)
                if (!self_destruct.confirmed[n])
                    do_self_destruct = false;

            // Then start and announce the countdown.
            if (do_self_destruct)
            {
                self_destruct.countdown = 10.0f; //TODO?: PreferencesManager::get("self_destruct_countdown", "10").toFloat();
                //TODO: playSoundOnMainScreen("sfx/vocal_self_destruction.wav");
            }
        }else{
            // If the countdown has started, tick the clock.
            self_destruct.countdown -= delta;

            // When time runs out, blow up the ship and damage a
            // configurable radius.
            if (self_destruct.countdown <= 0.0f)
            {
                auto transform = entity.getComponent<sp::Transform>();
                if (transform) {
                    for(int n = 0; n < 5; n++)
                    {
                        ExplosionEffect* e = new ExplosionEffect();
                        e->setSize(self_destruct.size * 0.67f);
                        e->setPosition(transform->getPosition() + rotateVec2(glm::vec2(0, random(0, self_destruct.size * 0.33f)), random(0, 360)));
                        e->setRadarSignatureInfo(0.0, 0.6, 0.6);
                    }

                    DamageInfo info(entity, DamageType::Kinetic, transform->getPosition());
                    DamageSystem::damageArea(transform->getPosition(), self_destruct.size, self_destruct.damage - (self_destruct.damage / 3.0f), self_destruct.damage + (self_destruct.damage / 3.0f), info, 0.0);
                }

                //Finally, destroy the entity.
                auto obj_ptr = entity.getComponent<SpaceObject*>();
                if (obj_ptr)
                    (*obj_ptr)->destroy();
            }
        }
    }
}

bool SelfDestructSystem::activate(sp::ecs::Entity entity)
{
    if (auto self_destruct = entity.getComponent<SelfDestruct>()) {
        self_destruct->active = true;
        for(int n=0; n<SelfDestruct::max_codes; n++)
        {
            self_destruct->code[n] = irandom(0, 99999);
            self_destruct->confirmed[n] = false;
            self_destruct->entry_position[n] = max_crew_positions;
            while(self_destruct->entry_position[n] == max_crew_positions)
            {
                self_destruct->entry_position[n] = ECrewPosition(irandom(0, relayOfficer));
                for(int i=0; i<n; i++)
                    if (self_destruct->entry_position[n] == self_destruct->entry_position[i])
                        self_destruct->entry_position[n] = max_crew_positions;
            }
            self_destruct->show_position[n] = max_crew_positions;
            while(self_destruct->show_position[n] == max_crew_positions)
            {
                self_destruct->show_position[n] = ECrewPosition(irandom(0, relayOfficer));
                if (self_destruct->show_position[n] == self_destruct->entry_position[n])
                    self_destruct->show_position[n] = max_crew_positions;
                for(int i=0; i<n; i++)
                    if (self_destruct->show_position[n] == self_destruct->show_position[i])
                        self_destruct->show_position[n] = max_crew_positions;
            }
        }
        return true;
    }
    return false;
}
