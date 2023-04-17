#ifndef FACTION_INFO_H
#define FACTION_INFO_H

#include "P.h"
#include "stringImproved.h"
#include "multiplayer.h"
#include <glm/gtc/type_precision.hpp>
#include <array>
#include "ecs/entity.h"
#include "components/faction.h"


class FactionInfoLegacy : public MultiplayerObject, public Updatable
{
public:
    sp::ecs::Entity entity;

    FactionInfoLegacy();
    virtual ~FactionInfoLegacy();

    virtual void update(float delta) override;
    /*!
     * \brief Set name of faction.
     * \param Name Name of the faction
     */
    void setName(string name);
    void setLocaleName(string name);

    /*!
     * \brief Get name of faction.
     * \return String Name of the faction
     */
    string getName();
    string getLocaleName();

    /*!
     * \brief Get description of faction.
     * \return String description of the faction
     */
    string getDescription();
    /*!
     * \brief Set color of faction on GM screen.
     * \param r Red component.
     * \param g Green component.
     * \param b Blue component.
     */
    void setGMColor(int r, int g, int b);
    glm::u8vec4 getGMColor();
    /*!
     * \brief Set description of faction.
     * \param description
     */
    void setDescription(string description);
    /*!
     * \brief Add another faction that this faction sees as an enemy.
     * \param faction info object.
     */
    void setEnemy(P<FactionInfoLegacy> other);
    /*!
     * \brief Add another faction that this faction sees as a friendly.
     * \param faction info object.
     */
    void setFriendly(P<FactionInfoLegacy> other);
    void setNeutral(P<FactionInfoLegacy> other);

    static void reset(); //Destroy all FactionInfo objects
};

#endif//FACTION_INFO_H
