#ifndef FACTION_INFO_H
#define FACTION_INFO_H

#include "engine.h"

class FactionInfo;
extern PVector<FactionInfo> factionInfo;

enum EFactionVsFactionState
{
    FVF_Friendly,
    FVF_Neutral,
    FVF_Enemy
};

class FactionInfo : public PObject
{
private:
public:
    FactionInfo();

    sf::Color gm_color;

    std::vector<EFactionVsFactionState> states;

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
    void setGMColor(int r, int g, int b) { gm_color = sf::Color(r, g, b); }
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
    /*!
     * \brief Reset the data.
     * \todo Implement this.
     */
    void reset();

    static unsigned int findFactionId(string name);
protected:
    string name;
    string locale_name;
    string description;
};

#endif//FACTION_INFO_H
