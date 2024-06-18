-- A FactionInfo object contains presentation details and faction relationships for member SpaceObjects.
-- This file is loaded upon launching a scenario.
-- For details, see the FactionInfo class and getFactionInfo() global function in the scripting reference.

corp = FactionInfo():setName("Corporate owned")
corp:setGMColor(160, 0, 128)

foths = FactionInfo():setName("Faith of the High Science")
foths:setGMColor(160, 0, 128)

gov = FactionInfo():setName("Government owned")
gov:setGMColor(160, 0, 128)

unreg = FactionInfo():setName("Unregistered")
unreg:setGMColor(160, 0, 128)

eoc = FactionInfo():setName("EOC Starfleet")
eoc:setGMColor(255, 110, 0)

eocs = FactionInfo():setName("EOC_Starfleet")
eocs:setGMColor(255, 200, 0)

unident = FactionInfo():setName("Unidentified")
unident:setGMColor(0, 0, 255)

machines = FactionInfo():setName("Machines")
machines:setGMColor(255, 0, 0)

corp:setEnemy(machines)
foths:setEnemy(machines)
gov:setEnemy(machines)
unreg:setEnemy(machines)
eoc:setEnemy(machines)
eocs:setEnemy(machines)
unident:setEnemy(machines)

corp:setFriendly(foths)
corp:setFriendly(gov)
corp:setFriendly(eoc)
corp:setFriendly(eocs)
corp:setFriendly(unreg)
foths:setFriendly(corp)
foths:setFriendly(gov)
foths:setFriendly(unreg)
foths:setFriendly(eoc)
foths:setFriendly(eocs)
gov:setFriendly(foths)
gov:setFriendly(corp)
gov:setFriendly(unreg)
gov:setFriendly(eoc)
gov:setFriendly(eocs)
eoc:setFriendly(foths)
eoc:setFriendly(gov)
eoc:setFriendly(unreg)
eoc:setFriendly(corp)

eocs:setFriendly(corp)
eocs:setFriendly(foths)
eocs:setFriendly(gov)
eocs:setFriendly(unreg)
eocs:setFriendly(corp)
eocs:setFriendly(eoc)
machines:setNeutral(eocs)


machines:setEnemy(eoc)
machines:setEnemy(unident)
machines:setEnemy(corp)
machines:setEnemy(foths)
machines:setEnemy(gov)
machines:setEnemy(unreg)
