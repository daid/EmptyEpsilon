#ifndef FACTION_INFO_H
#define FACTION_INFO_H

#include "P.h"
#include "stringImproved.h"
#include "multiplayer.h"
#include <glm/gtc/type_precision.hpp>


class FactionInfo;
extern std::array<P<FactionInfo>, 32> factionInfo;

enum EFactionVsFactionState
{
    FVF_Friendly,
    FVF_Neutral,
    FVF_Enemy
};

class FactionInfo : public MultiplayerObject, public Updatable
{
public:
    FactionInfo();

    virtual void update(float delta) override;
    /*!
     * \brief Set name of faction.
     * \param Name Name of the faction
     */
    void setName(string name) { this->name = name; if (locale_name == "") locale_name = name; }
    void setLocaleName(string name) { this->locale_name = name; }

    /*!
     * \brief Get name of faction.
     * \return String Name of the faction
     */
    string getName() { return this->name; }
    string getLocaleName() { return this->locale_name; }

    /*!
     * \brief Get description of faction.
     * \return String description of the faction
     */
    string getDescription() {return this->description;}
    /*!
     * \brief Set color of faction on GM screen.
     * \param r Red component.
     * \param g Green component.
     * \param b Blue component.
     */
    void setGMColor(int r, int g, int b) { gm_color = glm::u8vec4(r, g, b, 255); }
    glm::u8vec4 getGMColor() { return gm_color; }
    /*!
     * \brief Set description of faction.
     * \param description
     */
    void setDescription(string description) { this->description = description; }
    /*!
     * \brief Add another faction that this faction sees as an enemy.
     * \param faction info object.
     */
    void setEnemy(P<FactionInfo> other);
    /*!
     * \brief Add another faction that this faction sees as a friendly.
     * \param faction info object.
     */
    void setFriendly(P<FactionInfo> other);

    EFactionVsFactionState getState(P<FactionInfo> other);

    static EFactionVsFactionState getState(uint8_t idx0, uint8_t idx1);
    static unsigned int findFactionId(string name);

    static void reset(); //Destroy all FactionInfo objects
protected:
    uint8_t index;
    glm::u8vec4 gm_color;
    string name;
    string locale_name;
    string description;
    uint32_t enemy_mask;
    uint32_t friend_mask;
};

#endif//FACTION_INFO_H
