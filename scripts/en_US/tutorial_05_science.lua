-- Name: Science
-- Description: [Tutoriel du poste]
--- -------------------
--- Passe en revue du poste scientifique.
---
--- [Infos sur le poste]
--- -------------------
--- Radar longue port�e : 
--- -Le poste scientifique dispose d'un radar � longue port�e qui peut localiser des vaisseaux et des objets � une distance allant jusqu'� 25U. La t�che la plus importante de l'officier scientifique est de signaler l'�tat du secteur et tout changement � l'int�rieur de celui-ci. Sur le bord du radar se trouvent des bandes color�es d'interf�rences de signaux qui peuvent vaguement sugg�rer la pr�sence d'objets ou de dangers spatiaux encore plus �loign�s, mais c'est � l'officier scientifique de les interpr�ter.
---
--- Scanner : 
--- -Vous pouvez scanner les vaisseaux pour obtenir plus d'informations � leur sujet. L'officier scientifique doit aligner deux des fr�quences de scan du vaisseau avec une cible pour compl�ter le scan. La plupart des vaisseaux sont inconnus (gris) de votre �quipage au d�but d'un sc�nario et doivent �tre scann�s avant de pouvoir �tre identifi�s comme amis (vert), ennemis (rouge) ou neutres (bleu). Un scan identifie �galement le type de navire, que l'officier scientifique peut utiliser pour identifier ses capacit�s dans la base de donn�es du poste.
---
--- Scans approfondis : 
--- -Un deuxi�me scan, plus difficile, donne plus d'informations sur le vaisseau, y compris sur son bouclier et les fr�quences du faisceau. L'officier scientifique doit aligner la fr�quence et la modulation simultan�ment pour effectuer un scan approfondi. Le navigateur et l'artilleur peuvent �galement voir les arcs de tir des vaisseaux scann�s en profondeur, ce qui les aide � guider votre vaisseau pour qu'il ne soit pas touch� par leurs faisceaux.
---
--- N�buleuses : 
----Les n�buleuses bloquent le scanner longue port�e du vaisseau. L'officier scientifique ne peut pas voir ce qui se trouve � l'int�rieur ou au-del�, et lorsqu'il se trouve dans une n�buleuse, les radars du vaisseau ne peuvent pas d�tecter ce qui se trouve � l'ext�rieur. Ces particularit�s font des n�buleuses des endroits id�aux pour se cacher en vue de r�parations ou pour organiser une embuscade. Pour �viter les surprises autour des n�buleuses, transmettez au capitaine et � l'officier de transmission des informations sur les endroits o� vous pouvez et ne pouvez pas voir les objets.
---
--- Vue de la sonde : 
--- -L'officier de transmission peut lancer des sondes et en connecter une au poste scientifique. L'officier scientifique peut alors consulter les donn�es des capteurs � courte port�e de la sonde pour scanner les vaisseaux se trouvant dans sa zone, m�me si la sonde est loin des scanners � longue port�e du navire ou dans une n�buleuse.
---
--- Base de donn�es : 
--- -L'officier scientifique peut acc�der � la base de donn�es de tous les vaisseaux connus, ainsi qu'aux donn�es sur les armes et les dangers de l'espace. Cela peut �tre vital pour �valuer les capacit�s d'un vaisseau sans un balayage approfondi, ou pour faciliter la navigation dans un trou noir, un trou de ver ou une autre anomalie.
-- Type: Basic
require("utils.lua")
require("options.lua")
require(lang .. "/ships.lua")
require(lang .. "/factions.lua")


function init()
    --Create the player ship
    player = PlayerSpaceship():setFaction(humanFaction):setTemplate(phobosM3P)
    tutorial:setPlayerShip(player)

    tutorial:showMessage([[Bienvenue dans le tutoriel de EmptyEpsilon.
    Notez que ce tutoriel est con�u pour vous donner un aper�u rapide des options de base du jeu, mais ne couvre pas tous les aspects.
    
    Appuyez sur suivant pour continuer...]], true)
    tutorial_list = {
        scienceTutorial
    }
    tutorial:onNext(function()
        tutorial_list_index = 1
        startSequence(tutorial_list[tutorial_list_index])
    end)
end

-- TODO: Need to refactor this region into a utility (*Need help LUA hates me)
--[[ Assist function in creating tutorial sequences --]]
function startSequence(sequence)
    current_sequence = sequence
    current_index = 1
    runNextSequenceStep()
end

function runNextSequenceStep()
    local data = current_sequence[current_index]
    current_index = current_index + 1
    if data == nil then
        tutorial_list_index = tutorial_list_index + 1
        if tutorial_list[tutorial_list_index] ~= nil then
            startSequence(tutorial_list[tutorial_list_index])
        else
            tutorial:finish()
        end
    elseif data["message"] ~= nil then
        tutorial:showMessage(data["message"], data["finish_check_function"] == nil)
        if data["finish_check_function"] == nil then
            update = nil
            tutorial:onNext(runNextSequenceStep)
        else
            update = function(delta)
                if data["finish_check_function"]() then
                    runNextSequenceStep()
                end
            end
            tutorial:onNext(nil)
        end
    elseif data["run_function"] ~= nil then
        local has_next_step = current_index <= #current_sequence
        data["run_function"]()
        if has_next_step then
            runNextSequenceStep()
        end
    end
end

function createSequence()
    return {}
end

function addToSequence(sequence, data, data2)
    if type(data) == "string" then
        if data2 == nil then
            table.insert(sequence, {message = data})
        else
            table.insert(sequence, {message = data, finish_check_function = data2})
        end
    elseif type(data) == "function" then
        table.insert(sequence, {run_function = data})
    end
end

function resetPlayerShip()
    player:setJumpDrive(false)
    player:setWarpDrive(false)
    player:setImpulseMaxSpeed(1)
    player:setRotationMaxSpeed(1)
    for _, system in ipairs({"reactor", "beamweapons", "missilesystem", "maneuver", "impulse", "warp", "jumpdrive", "frontshield", "rearshield"}) do
        player:setSystemHealth(system, 1.0)
        player:setSystemHeat(system, 0.0)
        player:setSystemPower(system, 1.0)
        player:commandSetSystemPowerRequest(system, 1.0)
        player:setSystemCoolant(system, 0.0)
        player:commandSetSystemCoolantRequest(system, 0.0)
    end
    player:setPosition(0, 0)
    player:setRotation(0)
    player:commandImpulse(0)
    player:commandWarp(0)
    player:commandTargetRotation(0)
    player:commandSetShields(false)
    player:setWeaponStorageMax("homing", 0)
    player:setWeaponStorageMax("nuke", 0)
    player:setWeaponStorageMax("mine", 0)
    player:setWeaponStorageMax("emp", 0)
    player:setWeaponStorageMax("hvli", 0)
end
--End Region Tut Utils


scienceTutorial = createSequence()
addToSequence(scienceTutorial, function()
    tutorial:switchViewToScreen(3)
    tutorial:setMessageToBottomPosition()
    resetPlayerShip()
end)
addToSequence(scienceTutorial, [[Bienvenue, officier scientifique.

Vous �tes les yeux du vaisseau. Votre travail consiste � fournir des informations au capitaine. Depuis votre poste, vous pouvez d�tecter et scanner des objets jusqu'� une distance de 30u.]])
addToSequence(scienceTutorial, function() prev_object = SpaceStation():setTemplate(mediumStation):setFaction(humanFaction):setPosition(3000, -15000) end)
addToSequence(scienceTutorial, function() prev_object2 = CpuShip():setFaction(humanFaction):setTemplate(phobosT3):setPosition(5000, -17000):orderIdle():setScanned(true) end)
addToSequence(scienceTutorial, [[Sur ce radar, vous pouvez s�lectionner des objets pour obtenir des informations � leur sujet.
J'ai ajout� un vaisseau ami et une station que vous pouvez examiner. S�lectionnez-les et remarquez la quantit� d'informations que vous pouvez observer.
Le cap et la distance sont particuli�rement importants, car sans eux, l'officier de navigation pilotera � l'aveugle.]])
addToSequence(scienceTutorial, function() prev_object:destroy() end)
addToSequence(scienceTutorial, function() prev_object = CpuShip():setFaction(kraylorFaction):setTemplate(phobosT3):setPosition(3000, -15000):orderIdle() end)
addToSequence(scienceTutorial, [[J'ai remplac� la station amie par un vaisseau inconnu. Une fois s�lectionn�, remarquez que vous ne savez rien � son sujet.
Pour en savoir plus, vous devez le scanner. Pour ce faire, vous devez faire correspondre les bandes de fr�quence de votre scanner � celles de votre cible.
Scannez ce vaisseau maintenant.]], function() return prev_object:isScannedBy(player) end)
addToSequence(scienceTutorial, [[Bien. Remarquez que ce vaisseau est inamical. Il aurait �galement pu �tre ami ou neutre, mais vous ne pouvez pas le savoir tant que vous ne l'avez pas scann�.]])
addToSequence(scienceTutorial, [[Notez que vous avez moins d'informations sur ce vaisseau que sur le vaisseau ami. Vous devez effectuer un scan approfondi pour obtenir plus d'informations.
Un scan approfondi demande plus d'efforts et vous oblige � aligner 2 bandes de fr�quences diff�rentes simultan�ment.
Effectuez un scan approfondi de l'ennemi maintenant.]], function() return prev_object:isFullyScannedBy(player) end)
addToSequence(scienceTutorial, [[Excellent. Notez que cela a pris plus de temps et de concentration que le scan simple, alors faites attention � n'effectuer des scannes approfondis que lorsque c'est n�cessaire ou vous risqueriez de manquer de temps.]])
addToSequence(scienceTutorial, function() prev_object:destroy() end)
addToSequence(scienceTutorial, function() prev_object2:destroy() end)
addToSequence(scienceTutorial, function() tutorial:setMessageToTopPosition() end)
addToSequence(scienceTutorial, [[Outre le radar � longue port�e, le poste scientifique peut �galement acc�der � la base de donn�es scientifiques.

Dans cette base de donn�es, vous pouvez rechercher des informations telles que les types de navires, les armes et d'autres objets.]])
addToSequence(scienceTutorial, [[N'oubliez pas que votre travail consiste � fournir des informations. Conna�tre l'emplacement et le statut des autres vaisseaux est vital pour votre capitaine.

Sans vos informations, l'�quipage est pratiquement aveugle.]])

