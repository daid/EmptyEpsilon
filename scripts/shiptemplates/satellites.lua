template = ShipTemplate():setName("ANT 615"):setLocaleName(_("ship", "ANT 615")):setModel("combatsat"):setClass(_("class", "Satellite"),_("subclass", "Sentry Series"))
template:setDescription(_("Military satellite from the old days, back when the earth's population was much more divided than today. Its original purpose was probably to take out other satellites."))
template:setRadarTrace("combatsat.png")
--                 Arc,Dir,Range,CycleTime, Dmg
template:setBeam(0, 15, 5, 990.0, 4.0, 2)
template:setBeam(1, 15,-5, 1000.0, 4.0, 2)

template:setHull(30)
template:setShields(30)
template:setSpeed(120, 30, 25)
