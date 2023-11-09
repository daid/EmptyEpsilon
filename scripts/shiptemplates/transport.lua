
for type=1,5 do
    for cnt=1,5 do
        template = ShipTemplate():setName("Transport" .. type .. "x" .. cnt):setLocaleName(string.format(_("ship", "Transport %dx%d"), type, cnt)):setModel("transport_" .. type .. "_" .. cnt)
        template:setHull(100)
        template:setShields(50, 50)
        template:setSpeed(60 - 5 * cnt, 6, 10)
        template:setRadarTrace("transport.png")
        template:setDefaultAI("evasion")
    end
end
