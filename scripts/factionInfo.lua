

corp = FactionInfo():setName("Corporate owned")
corp:setGMColor(255, 2, 128)

foths = FactionInfo():setName("Faith of the High Science")
foths:setGMColor(255, 2, 128)

gov = FactionInfo():setName("Government owned")
gov:setGMColor(255, 2, 128)

unreg = FactionInfo():setName("Unregistered")
unreg:setGMColor(255, 2, 128)

machines = FactionInfo():setName("Machines")
machines:setGMColor(255, 0, 0)

eoc = FactionInfo():setName("EOC Starfleet")
eoc:setGMColor(255, 128, 0)

corp:setEnemy(machines)
foths:setEnemy(machines)
gov:setEnemy(machines)
unreg:setEnemy(machines)
machines:setEnemy(eoc)
machines:setEnemy(corp)
machines:setEnemy(foths)
machines:setEnemy(gov)
machines:setEnemy(unreg)

