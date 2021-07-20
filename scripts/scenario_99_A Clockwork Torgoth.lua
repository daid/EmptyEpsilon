-- Name: A Clockwork Torgoth
-- Description: The Artemis is in route the Korova Quadrant to assist after a nearby cataclysmic supernova. The system near the bases needs to be remapped and they have requested your assistance. If there are enemy ships in the area they are no doubt preoccupied with this event as well so we don't expect trouble. This should be a simple survey mission, so tell your crew to relax and enjoy this serine area of space…


function init()
    timers = {}
    fleet = {}
	temp_transmission_object = SpaceStation():setTemplate("Small Station"):setPosition(-1000000, -1000000)
    globalMessage("a mission by FutileChas \n A Clockwork Torgoth");
    Nebula():setPosition(-4384.0, -22562.0)
    Asteroid():setPosition(-627.0, -22676.0)
    Asteroid():setPosition(1195.0, -24498.0)
    Asteroid():setPosition(1650.0, -27116.0)
    Asteroid():setPosition(2220.0, -27799.0)
    Asteroid():setPosition(4724.0, -32467.0)
    Asteroid():setPosition(2561.0, -29052.0)
    Asteroid():setPosition(1195.0, -25522.0)
    Asteroid():setPosition(398.0, -23701.0)
    Asteroid():setPosition(-1310.0, -21993.0)
    Asteroid():setPosition(-2221.0, -20513.0)
    Asteroid():setPosition(-2448.0, -18805.0)
    Asteroid():setPosition(-2334.0, -19602.0)
    Asteroid():setPosition(-1424.0, -20627.0)
    Asteroid():setPosition(-968.0, -21310.0)
    Asteroid():setPosition(-57.0, -22334.0)
    Asteroid():setPosition(398.0, -23245.0)
    Asteroid():setPosition(740.0, -24156.0)
    Asteroid():setPosition(967.0, -25181.0)
    Asteroid():setPosition(1423.0, -26889.0)
    Asteroid():setPosition(2675.0, -28027.0)
    Asteroid():setPosition(3472.0, -29279.0)
    Asteroid():setPosition(4155.0, -30190.0)
    Asteroid():setPosition(5180.0, -31329.0)
    Asteroid():setPosition(6660.0, -32581.0)
    Asteroid():setPosition(8140.0, -33947.0)
    Asteroid():setPosition(10303.0, -35883.0)
    --WARNING: Ignore <create> {'angle': '9', 'podnumber': '1', 'y': '0.0', 'x': '21573.0', 'z': '81805.0', 'type': 'whale'} 
    Asteroid():setPosition(11555.0, -36111.0)
    Asteroid():setPosition(9165.0, -35655.0)
    Asteroid():setPosition(7685.0, -34744.0)
    Asteroid():setPosition(6546.0, -33378.0)
    Asteroid():setPosition(6318.0, -32353.0)
    Asteroid():setPosition(5863.0, -31329.0)
    Asteroid():setPosition(4952.0, -29393.0)
    Asteroid():setPosition(3244.0, -26775.0)
    Asteroid():setPosition(4611.0, -29735.0)
    Asteroid():setPosition(7912.0, -32923.0)
    Asteroid():setPosition(11328.0, -35769.0)
    Asteroid():setPosition(14288.0, -37591.0)
    Asteroid():setPosition(13719.0, -37932.0)
    Asteroid():setPosition(11555.0, -37021.0)
    Asteroid():setPosition(12580.0, -37704.0)
    Asteroid():setPosition(14060.0, -38729.0)
    Asteroid():setPosition(15313.0, -40209.0)
    Asteroid():setPosition(16565.0, -41120.0)
    Asteroid():setPosition(18273.0, -42372.0)
    Asteroid():setPosition(16793.0, -41803.0)
    Asteroid():setPosition(14971.0, -39412.0)
    Asteroid():setPosition(13149.0, -35997.0)
    Asteroid():setPosition(8481.0, -32012.0)
    Asteroid():setPosition(5977.0, -29735.0)
    Asteroid():setPosition(3927.0, -28482.0)
    Asteroid():setPosition(3472.0, -28027.0)
    Asteroid():setPosition(2561.0, -27230.0)
    Asteroid():setPosition(2561.0, -26661.0)
    Asteroid():setPosition(1650.0, -25864.0)
    Asteroid():setPosition(1423.0, -25864.0)
    Asteroid():setPosition(1195.0, -25295.0)
    Asteroid():setPosition(740.0, -24725.0)
    Asteroid():setPosition(740.0, -23815.0)
    Asteroid():setPosition(-399.0, -23245.0)
    Asteroid():setPosition(-513.0, -23701.0)
    Asteroid():setPosition(56.0, -24953.0)
    Asteroid():setPosition(853.0, -26205.0)
    Asteroid():setPosition(-2904.0, -19944.0)
    Asteroid():setPosition(-3359.0, -17894.0)
    Asteroid():setPosition(-3245.0, -16073.0)
    Asteroid():setPosition(-3473.0, -15048.0)
    Asteroid():setPosition(-3587.0, -15389.0)
    Asteroid():setPosition(-4270.0, -13682.0)
    Asteroid():setPosition(-3587.0, -16300.0)
    Asteroid():setPosition(-2562.0, -18350.0)
    Asteroid():setPosition(-3701.0, -12771.0)
    Asteroid():setPosition(-4042.0, -10038.0)
    Asteroid():setPosition(-5636.0, -7420.0)
    Asteroid():setPosition(-5408.0, -4801.0)
    Asteroid():setPosition(-5408.0, -4801.0)
    Asteroid():setPosition(-5181.0, -6281.0)
    Asteroid():setPosition(-4953.0, -6964.0)
    Asteroid():setPosition(-4839.0, -5484.0)
    Asteroid():setPosition(-4498.0, -3093.0)
    Asteroid():setPosition(-4384.0, -1386.0)
    Asteroid():setPosition(-5295.0, -2638.0)
    Asteroid():setPosition(-5408.0, -3435.0)
    Asteroid():setPosition(-5408.0, -2866.0)
    Asteroid():setPosition(-5295.0, -1727.0)
    Asteroid():setPosition(-4953.0, -3093.0)
    Asteroid():setPosition(-4270.0, -4574.0)
    Asteroid():setPosition(-3928.0, -5029.0)
    Asteroid():setPosition(-3815.0, -3093.0)
    Asteroid():setPosition(-3245.0, -2183.0)
    Asteroid():setPosition(-3018.0, -1841.0)
    Asteroid():setPosition(-3928.0, -1386.0)
    Asteroid():setPosition(-5067.0, -703.0)
    Asteroid():setPosition(-5750.0, -589.0)
    Asteroid():setPosition(-5408.0, -1955.0)
    Asteroid():setPosition(-4839.0, -5826.0)
    Asteroid():setPosition(-4498.0, -6737.0)
    Asteroid():setPosition(-3815.0, -6167.0)
    Asteroid():setPosition(-3587.0, -9128.0)
    Asteroid():setPosition(-4042.0, -10608.0)
    Asteroid():setPosition(12352.0, -36680.0)
    Asteroid():setPosition(14288.0, -38160.0)
    Asteroid():setPosition(15199.0, -38843.0)
    Asteroid():setPosition(13833.0, -37818.0)
    Asteroid():setPosition(13149.0, -37249.0)
    Asteroid():setPosition(12011.0, -36566.0)
    Asteroid():setPosition(11100.0, -36111.0)
    Asteroid():setPosition(10417.0, -35541.0)
    Asteroid():setPosition(10986.0, -35200.0)
    Asteroid():setPosition(11669.0, -35541.0)
    Asteroid():setPosition(12922.0, -36680.0)
    Asteroid():setPosition(13263.0, -35997.0)
    Asteroid():setPosition(14060.0, -36566.0)
    Asteroid():setPosition(14857.0, -38160.0)
    Asteroid():setPosition(13946.0, -38160.0)
    Asteroid():setPosition(12580.0, -39071.0)
    Asteroid():setPosition(9506.0, -37363.0)
    Asteroid():setPosition(8823.0, -36680.0)
    Asteroid():setPosition(11669.0, -39185.0)
    Asteroid():setPosition(15996.0, -43169.0)
    Asteroid():setPosition(17931.0, -43966.0)
    Asteroid():setPosition(16793.0, -41348.0)
    Asteroid():setPosition(-399.0, -20057.0)
    Asteroid():setPosition(2675.0, -23815.0)
    Asteroid():setPosition(3927.0, -25750.0)
    Asteroid():setPosition(626.0, -21082.0)
    Asteroid():setPosition(170.0, -18577.0)
    Asteroid():setPosition(-741.0, -17097.0)
    Asteroid():setPosition(-1082.0, -18691.0)
    Asteroid():setPosition(1537.0, -23359.0)
    Asteroid():setPosition(2447.0, -25750.0)
    Asteroid():setPosition(-1993.0, -17211.0)
    Asteroid():setPosition(-1082.0, -19147.0)
    Asteroid():setPosition(-1993.0, -16756.0)
    Asteroid():setPosition(-1879.0, -14479.0)
    Asteroid():setPosition(-2107.0, -13796.0)
    Asteroid():setPosition(1423.0, -21993.0)
    Asteroid():setPosition(5294.0, -28938.0)
    Asteroid():setPosition(7229.0, -31443.0)
    Asteroid():setPosition(-2904.0, -361.0)
    Asteroid():setPosition(-2107.0, -816.0)
    Asteroid():setPosition(3017.0, -4801.0)
    Asteroid():setPosition(6774.0, -15731.0)
    Asteroid():setPosition(11555.0, -24498.0)
    Asteroid():setPosition(11214.0, -12657.0)
    Asteroid():setPosition(9848.0, -6167.0)
    Asteroid():setPosition(11100.0, -16073.0)
    Asteroid():setPosition(14174.0, -22790.0)
    Asteroid():setPosition(17248.0, -27230.0)
    Asteroid():setPosition(14629.0, -27913.0)
    Asteroid():setPosition(16451.0, -31556.0)
    Asteroid():setPosition(14743.0, -35314.0)
    Asteroid():setPosition(7457.0, -26319.0)
    Asteroid():setPosition(1764.0, -12885.0)
    Asteroid():setPosition(5066.0, -21651.0)
    Asteroid():setPosition(6318.0, -24384.0)
    Asteroid():setPosition(10645.0, -23473.0)
    Asteroid():setPosition(10189.0, -24498.0)
    Asteroid():setPosition(7115.0, -15276.0)
    Asteroid():setPosition(2333.0, -4801.0)
    Asteroid():setPosition(2220.0, -3777.0)
    Asteroid():setPosition(3244.0, -3663.0)
    Asteroid():setPosition(4269.0, -3435.0)
    Asteroid():setPosition(3130.0, -1500.0)
    Asteroid():setPosition(15085.0, -1955.0)
    Asteroid():setPosition(17248.0, -5826.0)
    Asteroid():setPosition(17931.0, -6964.0)
    Asteroid():setPosition(15882.0, -3890.0)
    Asteroid():setPosition(13149.0, -3207.0)
    Asteroid():setPosition(14174.0, -5029.0)
    Asteroid():setPosition(16565.0, -7761.0)
    Asteroid():setPosition(13946.0, -3093.0)
    Asteroid():setPosition(12694.0, -930.0)
    Asteroid():setPosition(12239.0, -1272.0)
    Asteroid():setPosition(13605.0, -2183.0)
    Asteroid():setPosition(14743.0, -2183.0)
    Asteroid():setPosition(14971.0, -1386.0)
    Asteroid():setPosition(15540.0, -3663.0)
    Asteroid():setPosition(15540.0, -4574.0)
    Asteroid():setPosition(16110.0, -5712.0)
    Asteroid():setPosition(16679.0, -6167.0)
    Asteroid():setPosition(-7116.0, -5029.0)
    Asteroid():setPosition(-7344.0, -2069.0)
    Nebula():setPosition(-11898.0, -24839.0)
    Nebula():setPosition(-8141.0, -29735.0)
    Nebula():setPosition(-9393.0, -24612.0)
    Nebula():setPosition(-7799.0, -27686.0)
    Nebula():setPosition(-7002.0, -25978.0)
    Nebula():setPosition(-6775.0, -21993.0)
    Nebula():setPosition(-2334.0, -25067.0)
    Nebula():setPosition(-1196.0, -28596.0)
    Nebula():setPosition(-4498.0, -28255.0)
    Nebula():setPosition(-3473.0, -30304.0)
    Nebula():setPosition(1195.0, -31329.0)
    Nebula():setPosition(2447.0, -32012.0)
    Nebula():setPosition(398.0, -28938.0)
    Nebula():setPosition(740.0, -27572.0)
    Nebula():setPosition(-2334.0, -21424.0)
    Nebula():setPosition(-1424.0, -22562.0)
    Nebula():setPosition(740.0, -25864.0)
    Nebula():setPosition(2903.0, -28596.0)
    Nebula():setPosition(5294.0, -32467.0)
    Nebula():setPosition(3358.0, -28369.0)
    Nebula():setPosition(1081.0, -24498.0)
    Nebula():setPosition(-57.0, -21993.0)
    Nebula():setPosition(2903.0, -25750.0)
    Nebula():setPosition(6546.0, -29507.0)
    Nebula():setPosition(5407.0, -27116.0)
    Nebula():setPosition(4041.0, -24498.0)
    Nebula():setPosition(8140.0, -27344.0)
    Nebula():setPosition(10531.0, -29963.0)
    Nebula():setPosition(13605.0, -29963.0)
    Nebula():setPosition(14743.0, -32353.0)
    Nebula():setPosition(10872.0, -31784.0)
    Nebula():setPosition(12125.0, -33720.0)
    Nebula():setPosition(8595.0, -33947.0)
    Nebula():setPosition(10986.0, -35655.0)
    Nebula():setPosition(15996.0, -39071.0)
    Nebula():setPosition(16337.0, -39982.0)
    Nebula():setPosition(13263.0, -38160.0)
    Nebula():setPosition(13719.0, -38160.0)
    Nebula():setPosition(-4953.0, -17211.0)
    Nebula():setPosition(-4384.0, -18805.0)
    Nebula():setPosition(-6092.0, -4232.0)
    Nebula():setPosition(-9735.0, -1386.0)
    Nebula():setPosition(-14403.0, -816.0)
    Nebula():setPosition(-8027.0, -1613.0)
    Nebula():setPosition(-4270.0, -1386.0)
    Nebula():setPosition(-2448.0, -1272.0)
    Nebula():setPosition(9506.0, -3093.0)
    Nebula():setPosition(13491.0, -12543.0)
    Nebula():setPosition(14629.0, -14365.0)
    Nebula():setPosition(11783.0, -10266.0)
    Nebula():setPosition(12580.0, -6167.0)
    Nebula():setPosition(14288.0, -8558.0)
    Nebula():setPosition(15654.0, -9241.0)
    Nebula():setPosition(15882.0, -5826.0)
    Nebula():setPosition(14402.0, -3207.0)
    Nebula():setPosition(14060.0, -2183.0)
    Nebula():setPosition(17362.0, -4004.0)
    Nebula():setPosition(17590.0, -4801.0)
    Nebula():setPosition(16451.0, -1613.0)
    Nebula():setPosition(10759.0, -361.0)
    Nebula():setPosition(16110.0, -33834.0)
    Nebula():setPosition(13491.0, -33378.0)
    Nebula():setPosition(17703.0, -37477.0)
    Nebula():setPosition(-7458.0, -19374.0)
    Nebula():setPosition(-10304.0, -22107.0)
    Nebula():setPosition(-78615.0, -8786.0)
    Nebula():setPosition(-78046.0, -14593.0)
    Nebula():setPosition(-80095.0, -22790.0)
    Nebula():setPosition(-79412.0, -21310.0)
    Nebula():setPosition(-77932.0, -16528.0)
    Nebula():setPosition(-77249.0, -18919.0)
    Nebula():setPosition(-78957.0, -11974.0)
    Nebula():setPosition(-79185.0, -9583.0)
    Nebula():setPosition(-63587.0, -930.0)
    Nebula():setPosition(-56983.0, -1727.0)
    Nebula():setPosition(-52088.0, -5484.0)
    Nebula():setPosition(-52202.0, -4687.0)
    Nebula():setPosition(-60285.0, -2638.0)
    Nebula():setPosition(-55845.0, -3549.0)
    Nebula():setPosition(-51519.0, -2638.0)
    Nebula():setPosition(-45712.0, -1272.0)
    Nebula():setPosition(-42524.0, -1727.0)
    Nebula():setPosition(-49469.0, -1727.0)
    Nebula():setPosition(-41158.0, -2183.0)
    Nebula():setPosition(-36376.0, -1500.0)
    Nebula():setPosition(-39678.0, -930.0)
    Nebula():setPosition(-52657.0, 94.0)
    Nebula():setPosition(-53340.0, -247.0)
    Nebula():setPosition(-49811.0, -2866.0)
    Nebula():setPosition(-45143.0, -2752.0)
    TSN_Ivan = CpuShip():setTemplate("Atlantis X23"):setCallSign("TSN Ivan"):setFaction("Independent"):setPosition(-75655.0, -33947.0):orderRoaming()
    Drone_Scout_42 = CpuShip():setTemplate("Adder MK4"):setCallSign("Drone Scout 42"):setFaction("Independent"):setPosition(-19868.0, -34630.0):orderRoaming()
    DS_27 = SpaceStation():setTemplate("Small Station"):setCallSign("DS 27"):setFaction("Human Navy"):setPosition(-43321.0, -21196.0)
    DS_31 = SpaceStation():setTemplate("Small Station"):setCallSign("DS 31"):setFaction("Human Navy"):setPosition(-14061.0, -9014.0)
    Artemis = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Player Cruiser"):setCallSign("Artemis"):setPosition(-76224.0, -4915.0)
    SupplyDrop():setFaction("Human Navy"):setPosition(16451.0, -2183.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
    SupplyDrop():setFaction("Human Navy"):setPosition(4383.0, -27002.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
    timers["start_mission_timer_1"] = 10.000000
    variable_chapter_1 = 1.0
    timers["destroy_artemisA"] = 1.000000
    timers["destroy_artemisB"] = 2.000000
    timers["destroy_artemisC"] = 3.000000
    timers["destroy_artemisD"] = 4.000000
    timers["destroy_artemisE"] = 45.000000
    variable_IvanWanderPath = 0.0
    variable_ScoutWanderPath = 0.0
    variable_ScoutIn40x34 = 0.0
end

function update(delta)
    for key, value in pairs(timers) do
        timers[key] = timers[key] - delta
    end

    if (timers["start_mission_timer_1"] ~= nil and timers["start_mission_timer_1"] < 0.0) and variable_start_mission_1 ~= (1.0) then
       variable_start_mission_1 = 1.0
       timers["object_1st_msg_to_Ivan"] = 16.0
       timers["object_1st_msg"] = 20.0
    end

    if (Intrepid ~= nil and Intrepid:isValid()) and (timers["object_1st_msg_to_Ivan"] ~= nil and timers["object_1st_msg_to_Ivan"] < 0.0) and variable_object_1st_msg_to_ivan ~= (1.0) then
        temp_transmission_object:setCallSign("DS 27"):sendCommsMessage(getPlayerShip(-1), "Intrepid, this is Command  on DS 27.  Welcome to the Korova Quadrant,  we are currently mapping the northern sectors with the TSN Ivan and an unmanned scout ship.   There was a recent super nova a couple quadrants away and the gravity has shifted everything within a parsec.  The Gamma rays have saturated this area and our sensors are being adapted and recalibrated and we could use your support.  Set course for DS 31 and stand by, dock and refit as nessessary and maintain a position near the station.   We feel a bit better knowing you\'re here. DS 27, out.")
        variable_object_1st_msg_to_ivan = 1.0
    end
    if (timers["object_1st_msg"] ~= nil and timers["object_1st_msg"] < 0.0) and variable_object_1st_msg ~= (1.0) then
        variable_object_1st_msg = 1.0
        temp_transmission_object:setCallSign("DS 27"):sendCommsMessage(getPlayerShip(-1), "Artemis, this is Command on DS 27.  Welcome to the Korova Quadrant,  we are currently mapping the northern sectors with the TSN Ivan and an unmanned scout ship.   There was a recent super nova a couple quadrants away and the gravity has shifted everything within a parsec.  The Gamma rays have saturated this area and our sensors are being adapted and recalibrated and we could use your support. Dock, refit as nessessary, and maintain a position near a starbase.    We feel a bit better knowing you\'re here. DS 27 out.")
        timers["object_1st_msg_to_Artemis"] = 18.000000
        timers["object_1st_msg_to_ArtemisA"] = 26.000000
    end
    if (timers["object_1st_msg_to_Artemis"] ~= nil and timers["object_1st_msg_to_Artemis"] < 0.0) and variable_welcome_artemis ~= (1.0) and (Intrepid ~= nil and Intrepid:isValid()) then
        variable_welcome_artemis = 1.0
        temp_transmission_object:setCallSign("TSN Ivan"):sendCommsMessage(getPlayerShip(-1), "Artemis and Intrepid, base doesn\'t trust the old \" Ive\' \", ha, ha, ha... na we are definately under a bit of stress since the super nova.  If you guys can just hang out and monitor our progress, this should\'nt  be a big deal (static)...Ivan, out.")
    end
    if (timers["object_1st_msg_to_Artemis"] ~= nil and timers["object_1st_msg_to_Artemis"] < 0.0) and variable_welcome_artemis ~= (2.0) and (Intrepid == nil or not Intrepid:isValid()) then
        variable_welcome_artemis = 2.0
        temp_transmission_object:setCallSign("TSN Ivan"):sendCommsMessage(getPlayerShip(-1), "Artemis, base doesn\'t trust the old \" Ive\' \". Ha, ha, ha... na we are definately under a bit of stress since the super nova.  If you guys can just hang out and monitor our progress, this should\'nt  be a big deal (static)...Ivan, out.")
    end
    if (timers["object_1st_msg_to_ArtemisA"] ~= nil and timers["object_1st_msg_to_ArtemisA"] < 0.0) and variable_confirm_artemis_to_athena ~= (1.0) then
        variable_confirm_artemis_to_athena = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Interference...(source unknown)...")
        Artemis:addCustomMessage("relayOfficer", "warning", "Interference...")
    end
    if variable_IvanWanderPath == (0.0) and ifInsideSphere(TSN_Ivan, -75655.0, -33947.0, 500.000000) then
        variable_IvanWanderPath = 1.0
        if TSN_Ivan ~= nil and TSN_Ivan:isValid() then
            TSN_Ivan:orderFlyTowards(-64066.0, -54726.0)
        end
    end
    if ifInsideBox(TSN_Ivan, 19560.0, -51429.0, -79451.0, -50330.0) and variable_createA ~= (1.0) then
        Nebula():setPosition(-78615.0, -61500.0)
        Nebula():setPosition(-75997.0, -63435.0)
        Nebula():setPosition(-78729.0, -64801.0)
        Nebula():setPosition(-77818.0, -67420.0)
        Nebula():setPosition(-75200.0, -68103.0)
        Nebula():setPosition(-71215.0, -61613.0)
        Nebula():setPosition(-70418.0, -64574.0)
        Nebula():setPosition(-72923.0, -63777.0)
        Nebula():setPosition(-75655.0, -61272.0)
        Nebula():setPosition(-73378.0, -65143.0)
        variable_createA = 1.0
        Nebula():setPosition(-72240.0, -66509.0)
        Nebula():setPosition(-68369.0, -62866.0)
        Nebula():setPosition(-67686.0, -65029.0)
        Nebula():setPosition(-69052.0, -66167.0)
        tmp_count = 2
        for tmp_counter=1,tmp_count do
            tmp_x = -63146.0 + (-63146.0 - -63146.0) * (tmp_counter - 1) / tmp_count
            tmp_y = -93581.0 + (-74450.0 - -93581.0) * (tmp_counter - 1) / tmp_count
            tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 3000.0))
            tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
            Nebula():setPosition(tmp_x, tmp_y)
        end
        Nebula():setPosition(-71443.0, -66964.0)
        Nebula():setPosition(-78501.0, -70152.0)
        Nebula():setPosition(-63815.0, -63321.0)
        Nebula():setPosition(-63928.0, -60475.0)
        Nebula():setPosition(-63245.0, -70722.0)
        Nebula():setPosition(-60854.0, -70722.0)
        Nebula():setPosition(-59944.0, -70266.0)
        tmp_count = 2
        for tmp_counter=1,tmp_count do
            tmp_x = -54706.0 + (-74502.0 - -54706.0) * (tmp_counter - 1) / tmp_count
            tmp_y = -79157.0 + (-72302.0 - -79157.0) * (tmp_counter - 1) / tmp_count
            tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, 3000.0))
            tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2
            Nebula():setPosition(tmp_x, tmp_y)
        end
        Artemis:addCustomMessage("scienceOfficer", "warning", "Updating map...")
    end
    if variable_IvanWanderPath == (1.0) and ifInsideSphere(TSN_Ivan, -64066.0, -54726.0, 1500.000000) then
        variable_IvanWanderPath = 2.0
        if TSN_Ivan ~= nil and TSN_Ivan:isValid() then
            TSN_Ivan:orderFlyTowards(-64176.0, -63957.0)
        end
    end
    if ifInsideSphere(TSN_Ivan, -64176.0, -63957.0, 2000.000000) and variable_Ivan_to_base ~= (1.0) then
        variable_Ivan_to_base = 1.0
        temp_transmission_object:setCallSign("TSN Ivan"):sendCommsMessage(getPlayerShip(-1), "Ivan to Base, we are experiencing heavy...(static),............we,............stand by...")
        timers["Ivan_repeat_msg"] = 12.000000
        Artemis:addCustomMessage("relayOfficer", "warning", "Transmission Lost...")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Transmission Lost...")
    end
    if (timers["Ivan_repeat_msg"] ~= nil and timers["Ivan_repeat_msg"] < 0.0) and variable_ivan_repeat ~= (1.0) then
        variable_ivan_repeat = 1.0
        temp_transmission_object:setCallSign("DS 27"):sendCommsMessage(getPlayerShip(-1), "Ivan, repeat last transmission...    I say again Ivan repeat your last transmission....")
        timers["Ivan_responds"] = 17.000000
    end
    if (timers["Ivan_responds"] ~= nil and timers["Ivan_responds"] < 0.0) and variable_ivan_responds ~= (1.0) then
        variable_ivan_responds = 1.0
        temp_transmission_object:setCallSign("TSN Ivan"):sendCommsMessage(getPlayerShip(-1), "static)...stand by Base,...we are (static)..............., repeat, we are reducing speed and holding course.  We are scanning Sector B 1, stand by...")
        timers["base_responds"] = 13.000000
    end
    if (timers["base_responds"] ~= nil and timers["base_responds"] < 0.0) and variable_base_responds ~= (1.0) then
        variable_base_responds = 1.0
        temp_transmission_object:setCallSign("DS 27"):sendCommsMessage(getPlayerShip(-1), "Copy that Ivan,  we are continuing to monitor your progress.  27, out.")
    end
    if variable_IvanWanderPath == (2.0) and ifInsideSphere(TSN_Ivan, -64176.0, -63957.0, 1200.000000) then
        variable_IvanWanderPath = 3.0
        if TSN_Ivan ~= nil and TSN_Ivan:isValid() then
            TSN_Ivan:orderFlyTowards(-63627.0, -69121.0)
        end
    end
    if countFleet(0) >= 2.000000 and variable_call_for_ivan ~= (1.0) then
        variable_call_for_ivan = 1.0
        timers["msg_from_ivan_to_artemis"] = 12.000000
        timers["msg_from_ivan_to_artemisA"] = 16.000000
        temp_transmission_object:setCallSign("TSN Ivan"):sendCommsMessage(getPlayerShip(-1), "Ivan to Base, we got some trouble he... (static)...  Requesting instructions(static)...")
    end
    if (timers["msg_from_ivan_to_artemis"] ~= nil and timers["msg_from_ivan_to_artemis"] < 0.0) and variable_msg_from_ivanA ~= (1.0) then
        variable_msg_from_ivanA = 1.0
        Artemis:addCustomMessage("relayOfficer", "warning", "Interference...")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Sensor malfunction...")
        timers["response_from_baseA"] = 15.000000
        timers["response_from_baseB"] = 30.000000
    end
    if (timers["response_from_baseA"] ~= nil and timers["response_from_baseA"] < 0.0) and variable_response_from_baseA ~= (1.0) then
        variable_response_from_baseA = 1.0
        temp_transmission_object:setCallSign("DS 27"):sendCommsMessage(getPlayerShip(-1), "Station to Ivan, we read you.  Prepare to return to base and stay on alert,  a plan is being formulated as we speak...    We may send another ship to your area.  Stand by,  DS 27, out.")
    end
    if (timers["response_from_baseB"] ~= nil and timers["response_from_baseB"] < 0.0) and variable_response_from_baseB ~= (1.0) and (Intrepid ~= nil and Intrepid:isValid()) then
        variable_response_from_baseB = 1.0
        temp_transmission_object:setCallSign("DS 31"):sendCommsMessage(getPlayerShip(-1), "Intrepid this is base, We are reading multiple enemy attack ships in the quadrant.  Intercept the enemy if you can but be aware of our communications problems,  we may need you to return in a hurry.  DS 31, out.")
    end
    if (timers["response_from_baseB"] ~= nil and timers["response_from_baseB"] < 0.0) and variable_response_from_baseB ~= (2.0) and (Intrepid == nil or not Intrepid:isValid()) then
        variable_response_from_baseB = 2.0
        temp_transmission_object:setCallSign("DS 31"):sendCommsMessage(getPlayerShip(-1), "Artemis, this is base, We are reading multiple enemy attack ships in the quadrant.  Intercept the enemy if you can but be aware of our communications problems,  we may need you to return in a hurry.  DS 31, out.")
    end
    if ifInsideBox(Artemis, 19230.0, -72088.0, -79451.0, -71539.0) and variable_object_30k_msgA ~= (1.0) and (timers["msg_from_ivan_to_artemisA"] ~= nil and timers["msg_from_ivan_to_artemisA"] < 0.0) then
        variable_object_30k_msgA = 1.0
        timers["object_30k_msg_after_static"] = 4.000000
    end
    if ifInsideBox(Intrepid, -30660.0, -62528.0, -50330.0, -57803.0) and variable_object_30k_msgB ~= (1.0) and (timers["msg_from_ivan_to_artemisA"] ~= nil and timers["msg_from_ivan_to_artemisA"] < 0.0) and (timers["reset_intrepid_trap"] ~= nil and timers["reset_intrepid_trap"] < 0.0) then
        variable_object_30k_msgB = 1.0
        Artemis:addCustomMessage("relayOfficer", "warning", "Interference...")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Sensor malfunction...")
        timers["object_30k_msg_after_static"] = 4.000000
        getPlayerShip(-1):setSystemHealth("reactor", -0.500000)
        getPlayerShip(-1):setSystemHealth("reactor", 0.500000)
    end
    if ifInsideBox(Intrepid, 19560.0, -55605.0, -79451.0, -54836.0) and variable_object_30k_msg ~= (1.0) and (timers["msg_from_ivan_to_artemisA"] ~= nil and timers["msg_from_ivan_to_artemisA"] < 0.0) then
        variable_object_30k_msg = 1.0
        Artemis:addCustomMessage("relayOfficer", "warning", "Interference...")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Sensor malfunction...")
        timers["object_30k_msg_after_static"] = 4.000000
        getPlayerShip(-1):setSystemHealth("reactor", 0.000000)
        getPlayerShip(-1):setSystemHealth("reactor", 0.000000)
        getPlayerShip(-1):setSystemHealth("reactor", 0.500000)
        timers["reset_intrepid_trap"] = 60.000000
    end
    if (timers["object_30k_msg_after_static"] ~= nil and timers["object_30k_msg_after_static"] < 0.0) and variable_object_30k_msg_after_static ~= (1.0) then
        variable_object_30k_msg_after_static = 1.0
        temp_transmission_object:setCallSign("DS 27"):sendCommsMessage(getPlayerShip(-1), "static)...Command to Fleet, we may loose communications easily.  Take out the enemy fleet and we will monitor  as best we can.  Good luck.  DS 27, out.")
        timers["msg_to_ivan_from_artemis"] = 15.000000
    end
    if (timers["msg_to_ivan_from_artemis"] ~= nil and timers["msg_to_ivan_from_artemis"] < 0.0) and variable_msg_from_art_to_ivan ~= (1.0) then
        variable_msg_from_art_to_ivan = 1.0
        Artemis:addCustomMessage("relayOfficer", "warning", "Interference...")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Sensor malfunction...")
        temp_transmission_object:setCallSign("DS 27"):sendCommsMessage(getPlayerShip(-1), "Base to Ivan,  if you read us other ships are engaging the enemy.  (static)... make way back to base(static)... out.")
        variable_ivan_to_B_4 = 0.0
    end
    if variable_ScoutWanderPath == (0.0) and ifInsideSphere(Drone_Scout_42, -19671.0, -34630.0, 500.000000) then
        variable_ScoutWanderPath = 1.0
        if Drone_Scout_42 ~= nil and Drone_Scout_42:isValid() then
            Drone_Scout_42:orderFlyTowards(-20330.0, -58352.0)
        end
    end
    if ifInsideBox(Drone_Scout_42, 19230.0, -54176.0, -30110.0, -53847.0) and variable_createB ~= (1.0) then
        Asteroid():setPosition(-33302.0, -64460.0)
        Asteroid():setPosition(-29887.0, -68217.0)
        Asteroid():setPosition(-32164.0, -67306.0)
        Asteroid():setPosition(-13947.0, -71860.0)
        Asteroid():setPosition(-10760.0, -72315.0)
        Artemis:addCustomMessage("scienceOfficer", "warning", "Updating map...")
        Asteroid():setPosition(-10304.0, -72999.0)
        Asteroid():setPosition(-4270.0, -73226.0)
        Asteroid():setPosition(-2107.0, -72999.0)
        Asteroid():setPosition(-854.0, -74365.0)
        Asteroid():setPosition(-32733.0, -65257.0)
        Asteroid():setPosition(-32050.0, -66623.0)
        Asteroid():setPosition(-31822.0, -66395.0)
        Asteroid():setPosition(-31367.0, -66054.0)
        Asteroid():setPosition(-3815.0, -72315.0)
        Asteroid():setPosition(-2448.0, -72315.0)
        Asteroid():setPosition(-1196.0, -73226.0)
        Asteroid():setPosition(-11556.0, -71632.0)
        Asteroid():setPosition(17362.0, -66054.0)
        Asteroid():setPosition(17931.0, -65484.0)
        variable_createB = 1.0
        Nebula():setPosition(-20892.0, -66395.0)
        Nebula():setPosition(-25902.0, -67192.0)
        Nebula():setPosition(-28407.0, -65143.0)
        Nebula():setPosition(-15769.0, -70380.0)
        Nebula():setPosition(-9735.0, -73909.0)
        Nebula():setPosition(-2334.0, -73340.0)
        Nebula():setPosition(1423.0, -76870.0)
        Nebula():setPosition(3472.0, -79602.0)
        Nebula():setPosition(-3018.0, -77211.0)
        Nebula():setPosition(-8369.0, -75959.0)
        Nebula():setPosition(12694.0, -69697.0)
        Nebula():setPosition(14971.0, -69583.0)
        Nebula():setPosition(16565.0, -67875.0)
        Nebula():setPosition(18045.0, -66167.0)
        Nebula():setPosition(15654.0, -66395.0)
        Nebula():setPosition(11555.0, -66851.0)
        Nebula():setPosition(9506.0, -68217.0)
        Nebula():setPosition(8937.0, -68786.0)
        Nebula():setPosition(5635.0, -70722.0)
        Nebula():setPosition(4611.0, -71177.0)
        Nebula():setPosition(2106.0, -71291.0)
        Nebula():setPosition(-37059.0, -64346.0)
        Nebula():setPosition(-33416.0, -65257.0)
        Nebula():setPosition(-31708.0, -67534.0)
        Nebula():setPosition(-31139.0, -67989.0)
        Nebula():setPosition(-31481.0, -65371.0)
        Nebula():setPosition(-34213.0, -63549.0)
        Nebula():setPosition(-35465.0, -61955.0)
        Nebula():setPosition(-32619.0, -61841.0)
        timers["mapping"] = 4.000000
    end
    if (timers["mapping"] ~= nil and timers["mapping"] < 0.0) and ifInsideBox(Drone_Scout_42, -15935.0, -60220.0, -31869.0, -59781.0) and variable_createC ~= (1.0) then
        Asteroid():setPosition(-30000.0, -68786.0)
        Asteroid():setPosition(-28634.0, -69241.0)
        Asteroid():setPosition(-29090.0, -68672.0)
        Asteroid():setPosition(-27951.0, -69355.0)
        Asteroid():setPosition(-27496.0, -70152.0)
        Artemis:addCustomMessage("scienceOfficer", "warning", "Updating map...")
        Asteroid():setPosition(-29545.0, -69697.0)
        Asteroid():setPosition(-31822.0, -68103.0)
        Asteroid():setPosition(-30797.0, -67761.0)
        Asteroid():setPosition(-25788.0, -70722.0)
        Asteroid():setPosition(-26813.0, -70494.0)
        Asteroid():setPosition(-28065.0, -68558.0)
        Asteroid():setPosition(-28862.0, -68331.0)
        Asteroid():setPosition(-29773.0, -68331.0)
        variable_createC = 1.0
        Asteroid():setPosition(-28293.0, -69697.0)
        Asteroid():setPosition(-26926.0, -69925.0)
        Asteroid():setPosition(-26243.0, -69925.0)
        Asteroid():setPosition(-27382.0, -69469.0)
        Asteroid():setPosition(-24649.0, -70152.0)
        Asteroid():setPosition(-24308.0, -70380.0)
        Asteroid():setPosition(-13492.0, -73454.0)
        Asteroid():setPosition(-11215.0, -73682.0)
        Asteroid():setPosition(-10418.0, -74137.0)
        Asteroid():setPosition(-12467.0, -73568.0)
        Asteroid():setPosition(-12126.0, -73340.0)
        Asteroid():setPosition(-10304.0, -74023.0)
        Asteroid():setPosition(-9849.0, -74251.0)
        Asteroid():setPosition(-9052.0, -73682.0)
        Asteroid():setPosition(-8027.0, -73682.0)
        Asteroid():setPosition(-7572.0, -73454.0)
        Asteroid():setPosition(-11101.0, -71974.0)
        Asteroid():setPosition(-11670.0, -71746.0)
        Asteroid():setPosition(-10190.0, -72657.0)
        Asteroid():setPosition(-11898.0, -70608.0)
        Asteroid():setPosition(-14289.0, -70380.0)
        Asteroid():setPosition(-14403.0, -70722.0)
        Asteroid():setPosition(-13947.0, -70722.0)
        Asteroid():setPosition(-13378.0, -70494.0)
        Asteroid():setPosition(-13264.0, -70380.0)
        Asteroid():setPosition(-12809.0, -69811.0)
        Asteroid():setPosition(11783.0, -75731.0)
        Asteroid():setPosition(13605.0, -74023.0)
        Asteroid():setPosition(13491.0, -72543.0)
        Asteroid():setPosition(10645.0, -72202.0)
        Nebula():setPosition(11555.0, -74479.0)
        Nebula():setPosition(12922.0, -72202.0)
        Nebula():setPosition(15313.0, -74479.0)
        Nebula():setPosition(15540.0, -75389.0)
        Nebula():setPosition(-9393.0, -75276.0)
        Nebula():setPosition(-13037.0, -73454.0)
        Nebula():setPosition(-16794.0, -72315.0)
        Nebula():setPosition(-23397.0, -71860.0)
        Nebula():setPosition(-29204.0, -70608.0)
        Nebula():setPosition(-32505.0, -70038.0)
        Nebula():setPosition(-34099.0, -68786.0)
        Nebula():setPosition(-29659.0, -67078.0)
        Nebula():setPosition(-25788.0, -69697.0)
        Nebula():setPosition(-24877.0, -70380.0)
        Nebula():setPosition(-31594.0, -66281.0)
        Nebula():setPosition(-12695.0, -68900.0)
        Nebula():setPosition(-6775.0, -70494.0)
        Nebula():setPosition(-57.0, -72771.0)
        Nebula():setPosition(9278.0, -72771.0)
        Nebula():setPosition(5180.0, -73112.0)
        Asteroid():setPosition(-30911.0, -77667.0)
    end
    if ifInsideBox(Drone_Scout_42, -11869.0, -66814.0, -32638.0, -66044.0) and variable_createD ~= (1.0) then
        Asteroid():setPosition(-30000.0, -68786.0)
        Asteroid():setPosition(-30456.0, -77894.0)
        Asteroid():setPosition(-28634.0, -77439.0)
        Asteroid():setPosition(-26243.0, -78122.0)
        Asteroid():setPosition(-24194.0, -78577.0)
        Asteroid():setPosition(-21917.0, -80057.0)
        Asteroid():setPosition(-23852.0, -79260.0)
        Asteroid():setPosition(-26813.0, -78350.0)
        Asteroid():setPosition(-29431.0, -77894.0)
        Asteroid():setPosition(-31708.0, -77667.0)
        Asteroid():setPosition(-26699.0, -78577.0)
        Artemis:addCustomMessage("scienceOfficer", "warning", "Updating map...")
        Asteroid():setPosition(-25105.0, -79830.0)
        Asteroid():setPosition(-4270.0, -81993.0)
        Asteroid():setPosition(2675.0, -82904.0)
        Asteroid():setPosition(740.0, -82790.0)
        Asteroid():setPosition(-3587.0, -82221.0)
        Asteroid():setPosition(398.0, -82790.0)
        Asteroid():setPosition(-2676.0, -82334.0)
        variable_createD = 1.0
        Asteroid():setPosition(-2221.0, -82790.0)
        Asteroid():setPosition(-1310.0, -83473.0)
        Asteroid():setPosition(-399.0, -83359.0)
        Asteroid():setPosition(-4156.0, -82107.0)
        Asteroid():setPosition(-5522.0, -83245.0)
        Asteroid():setPosition(-7344.0, -82107.0)
        Asteroid():setPosition(-8141.0, -81538.0)
        Asteroid():setPosition(-8482.0, -82562.0)
        Asteroid():setPosition(-6547.0, -82790.0)
        Asteroid():setPosition(-6547.0, -83131.0)
        Asteroid():setPosition(-8824.0, -80399.0)
        Asteroid():setPosition(-8710.0, -80968.0)
        Asteroid():setPosition(-8369.0, -80399.0)
        Asteroid():setPosition(-8255.0, -79830.0)
        Asteroid():setPosition(-8255.0, -78463.0)
        Asteroid():setPosition(-7799.0, -78691.0)
        Asteroid():setPosition(-7002.0, -80171.0)
        Asteroid():setPosition(-6547.0, -81082.0)
        Asteroid():setPosition(-28179.0, -77894.0)
        Asteroid():setPosition(-28862.0, -78691.0)
        Asteroid():setPosition(-29773.0, -79260.0)
        Asteroid():setPosition(-29317.0, -79944.0)
        Asteroid():setPosition(-28634.0, -80627.0)
        Asteroid():setPosition(-29090.0, -80854.0)
        Asteroid():setPosition(-29773.0, -80854.0)
        Asteroid():setPosition(-29887.0, -80741.0)
        Asteroid():setPosition(-30797.0, -79488.0)
        Asteroid():setPosition(-30000.0, -78691.0)
        Asteroid():setPosition(-28748.0, -78691.0)
        Asteroid():setPosition(-27951.0, -77439.0)
        Asteroid():setPosition(-26813.0, -78122.0)
        Asteroid():setPosition(-66433.0, -86547.0)
        Asteroid():setPosition(-64384.0, -87344.0)
        Asteroid():setPosition(12239.0, -72429.0)
        Asteroid():setPosition(10531.0, -72315.0)
        Asteroid():setPosition(7457.0, -73340.0)
        Asteroid():setPosition(-7458.0, -70835.0)
        Asteroid():setPosition(-12353.0, -70608.0)
        Asteroid():setPosition(-399.0, -73909.0)
        Asteroid():setPosition(1423.0, -74365.0)
        Asteroid():setPosition(17703.0, -56604.0)
        Nebula():setPosition(-13606.0, -75048.0)
        Nebula():setPosition(-6661.0, -81082.0)
        Nebula():setPosition(-3928.0, -82334.0)
        Nebula():setPosition(-1082.0, -82562.0)
        Nebula():setPosition(-1310.0, -82904.0)
        Nebula():setPosition(10986.0, -84953.0)
        Nebula():setPosition(12808.0, -85181.0)
        Nebula():setPosition(8823.0, -84156.0)
        Nebula():setPosition(-24536.0, -79147.0)
        Nebula():setPosition(-30228.0, -80513.0)
        Nebula():setPosition(-32050.0, -81082.0)
        Nebula():setPosition(-33302.0, -79716.0)
        Nebula():setPosition(-35579.0, -78122.0)
        Nebula():setPosition(-35465.0, -79033.0)
        Nebula():setPosition(-31594.0, -78350.0)
        Nebula():setPosition(-41272.0, -78350.0)
        Nebula():setPosition(-33075.0, -78122.0)
        Nebula():setPosition(-28293.0, -78122.0)
        Nebula():setPosition(-27837.0, -78350.0)
        Nebula():setPosition(-24080.0, -83701.0)
        Nebula():setPosition(-27154.0, -83928.0)
        Nebula():setPosition(7343.0, -79830.0)
        Nebula():setPosition(13036.0, -78577.0)
        Nebula():setPosition(15085.0, -73340.0)
        Nebula():setPosition(17248.0, -72543.0)
        Nebula():setPosition(16451.0, -75389.0)
        Nebula():setPosition(17362.0, -78350.0)
        Nebula():setPosition(17817.0, -80057.0)
        Nebula():setPosition(-7686.0, -77325.0)
        Nebula():setPosition(-7458.0, -79033.0)
        Nebula():setPosition(-5295.0, -79147.0)
        Nebula():setPosition(-3587.0, -81196.0)
        Nebula():setPosition(-3928.0, -77439.0)
        Nebula():setPosition(-1993.0, -78919.0)
        Nebula():setPosition(-1082.0, -79830.0)
    end
    if variable_ScoutWanderPath == (1.0) and ifInsideSphere(Drone_Scout_42, -20330.0, -58352.0, 1000.000000) then
        variable_ScoutWanderPath = 2.0
        if Drone_Scout_42 ~= nil and Drone_Scout_42:isValid() then
            Drone_Scout_42:orderFlyTowards(-20550.0, -65055.0)
        end
    end
    if variable_ScoutIn40x34 == (0.0) and ifInsideSphere(Drone_Scout_42, -20550.0, -65055.0, 1000.000000) then
        variable_ScoutIn40x34 = 1.0
        if Drone_Scout_42 ~= nil and Drone_Scout_42:isValid() then
            Drone_Scout_42:orderFlyTowards(-15055.0, -68352.0)
        end
    end
    if ifInsideSphere(Drone_Scout_42, -15055.0, -68352.0, 1500.000000) and ifOutsideSphere(Artemis, -15055.0, -68352.0, 10000.000000) then
        if Drone_Scout_42 ~= nil and Drone_Scout_42:isValid() then Drone_Scout_42:destroy() end
        timers["scout_flickerA"] = 3.000000
        timers["scout_flickerB"] = 9.000000
        timers["scout_is_lost_msg"] = 22.000000
    end
    if (timers["scout_flickerA"] ~= nil and timers["scout_flickerA"] < 0.0) and variable_scout_flicker ~= (1.0) then
        Drone_Scout_42 = CpuShip():setTemplate("Tug"):setCallSign("Drone Scout 42"):setFaction("Independent"):setPosition(-14203.0, -68380.0):orderRoaming()
        variable_scout_flicker = 1.0
    end
    if (timers["scout_flickerB"] ~= nil and timers["scout_flickerB"] < 0.0) then
        if Drone_Scout_42 ~= nil and Drone_Scout_42:isValid() then Drone_Scout_42:destroy() end
    end
    if (timers["scout_is_lost_msg"] ~= nil and timers["scout_is_lost_msg"] < 0.0) and variable_scout_is_lostA ~= (1.0) then
        variable_scout_is_lostA = 1.0
        temp_transmission_object:setCallSign("DS 31"):sendCommsMessage(getPlayerShip(-1), "All ships, this is DS 31.  We have lost contact on our scout ship in sector B 4, we are trying to reestablish contact.  Stand by...")
        timers["scout_is_lost_msgA"] = 20.000000
    end
    if (timers["scout_is_lost_msgA"] ~= nil and timers["scout_is_lost_msgA"] < 0.0) and variable_scout_is_lostB ~= (1.0) and (Intrepid ~= nil and Intrepid:isValid()) then
        variable_scout_is_lostB = 1.0
        temp_transmission_object:setCallSign("DS 31"):sendCommsMessage(getPlayerShip(-1), "Intrepid, this is DS 31.  We have lost contact on our scout ship in sector B 4, we have sent the recall code and fear the ship is lost.  We are sending the Ivan to do a quick scan of the area.  Set course for the northern sectors and investigate.  Search for the drone ship, if you find it get within 2 Kilometers of the ship and transmit a reactivation code.  Keep in contact with the bases, we are very vulnerable right now.  DS 31, out.")
        timers["scout_is_lost_msgB"] = 20.000000
    end
    if (timers["scout_is_lost_msgA"] ~= nil and timers["scout_is_lost_msgA"] < 0.0) and variable_scout_is_lostB ~= (2.0) and (Intrepid == nil or not Intrepid:isValid()) then
        variable_scout_is_lostB = 2.0
        temp_transmission_object:setCallSign("DS 31"):sendCommsMessage(getPlayerShip(-1), "Artemis, this is DS 31.  We have lost contact on our scout ship in sector B 4, we have sent the recall code and fear the ship is lost.  We are sending the Ivan to do a quick scan of the area.  Set course for the northern sectors and investigate.  Search for the drone ship, if you find it get within 2 Kilometers of the ship and transmit a reactivation code.  Keep in contact with the bases, we are very vulnerable right now.  DS 31, out.")
        timers["scout_is_lost_msgB"] = 20.000000
    end
    if (timers["scout_is_lost_msgB"] ~= nil and timers["scout_is_lost_msgB"] < 0.0) and variable_scout_is_lostC ~= (1.0) and (Intrepid ~= nil and Intrepid:isValid()) then
        variable_scout_is_lostC = 1.0
        temp_transmission_object:setCallSign("DS 31"):sendCommsMessage(getPlayerShip(-1), "DS 31 to Ivan.  We have ordered the Intrepid to proceed north and search for the scout ship and continue scanning the area, proceed to sector B 4 and do do a quick scan of the area.  The Ivan is not armed well enough for a large engagement, avoid the enemy if possible.  Be on alert.   DS 31, out.")
        Artemis:addCustomMessage("relayOfficer", "warning", "Incoming Data...")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Incoming Data...")
        timers["incoming_data"] = 15.000000
    end
    if (timers["scout_is_lost_msgB"] ~= nil and timers["scout_is_lost_msgB"] < 0.0) and variable_scout_is_lostC ~= (2.0) and (Intrepid == nil or not Intrepid:isValid()) then
        temp_transmission_object:setCallSign("DS 31"):sendCommsMessage(getPlayerShip(-1), "DS 31 to Ivan.  We have ordered the Artemis to proceed north and search for the scout ship and continue scanning the area, proceed to sector B 4 and do do a quick scan of the area.  The Ivan is not armed well enough for a large engagement, avoid the enemy if possible.  Be on alert.   DS 31, out.")
        variable_scout_is_lostC = 2.0
        Artemis:addCustomMessage("relayOfficer", "warning", "Incoming Data...")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Incoming Data...")
        timers["incoming_data"] = 15.000000
    end
    if (timers["incoming_data"] ~= nil and timers["incoming_data"] < 0.0) and variable_incoming_data ~= (1.0) then
        variable_incoming_data = 1.0
        Artemis:addCustomMessage("relayOfficer", "warning", "Data Transfer Complete")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Data Transfer Complete")
    end
    if (timers["scout_is_lost_msgB"] ~= nil and timers["scout_is_lost_msgB"] < 0.0) and variable_ivan_to_B_4 ~= (1.0) then
        variable_ivan_to_B_4 = 1.0
        if TSN_Ivan ~= nil and TSN_Ivan:isValid() then
            TSN_Ivan:orderFlyTowards(1098.0, -77143.0)
        end
    end
    if ifInsideSphere(TSN_Ivan, 1098.0, -77143.0, 8000.000000) and variable_ivan_to_A_4 ~= (1.0) then
        variable_ivan_to_A_4 = 0.7
        timers["lose_the_ivanA"] = 18.000000
        timers["lose_the_ivanB"] = 20.000000
        if TSN_Ivan ~= nil and TSN_Ivan:isValid() then
            TSN_Ivan:orderFlyTowards(-440.0, -83847.0)
        end
    end
    if ifInsideBox(TSN_Ivan, -58022.0, -80110.0, -58682.0, -60660.0) and variable_ivan_to_athena ~= (1.0) then
        variable_ivan_to_athena = 1.0
        temp_transmission_object:setCallSign("TSN Ivan"):sendCommsMessage(getPlayerShip(-1), "Ivan to Base  we are heading to sector B 4.")
    end
    if ifInsideBox(TSN_Ivan, -42638.0, -79671.0, -42968.0, -61429.0) and variable_ivan_to_fleet_goto_red_alert ~= (1.0) then
        variable_ivan_to_fleet_goto_red_alert = 1.0
        temp_transmission_object:setCallSign("TSN Ivan"):sendCommsMessage(getPlayerShip(-1), "Ivan to Fleet, we are detecting enemy activity.  We are going to Red Alert.")
        timers["mapA"] = 3.000000
        timers["mapB"] = 6.000000
        timers["mapC"] = 14.000000
    end
    if (timers["mapA"] ~= nil and timers["mapA"] < 0.0) and variable_mapA ~= (1.0) then
        variable_mapA = 1.0
        Asteroid():setPosition(-73150.0, -95314.0)
        Asteroid():setPosition(-54820.0, -94517.0)
        Asteroid():setPosition(-51974.0, -92581.0)
        Asteroid():setPosition(-46509.0, -93834.0)
        Asteroid():setPosition(-48672.0, -93492.0)
        Asteroid():setPosition(-20437.0, -93720.0)
        Asteroid():setPosition(-20095.0, -92353.0)
        Asteroid():setPosition(-21006.0, -90873.0)
        Asteroid():setPosition(-19640.0, -93720.0)
        Asteroid():setPosition(-19640.0, -94175.0)
        Asteroid():setPosition(-20209.0, -95200.0)
        Asteroid():setPosition(-20437.0, -95655.0)
        Asteroid():setPosition(-19754.0, -92809.0)
        Asteroid():setPosition(-20209.0, -90873.0)
        Nebula():setPosition(-62448.0, -93720.0)
        Nebula():setPosition(-58463.0, -92695.0)
        Nebula():setPosition(-52885.0, -93720.0)
        Nebula():setPosition(-51860.0, -94061.0)
        Nebula():setPosition(-47420.0, -93378.0)
        Nebula():setPosition(-46395.0, -93378.0)
        Nebula():setPosition(-25902.0, -91670.0)
        Nebula():setPosition(-22828.0, -91215.0)
        Nebula():setPosition(-22486.0, -93264.0)
        Nebula():setPosition(-21348.0, -93720.0)
        Artemis:addCustomMessage("scienceOfficer", "warning", "Updating map...")
    end
    if (timers["mapB"] ~= nil and timers["mapB"] < 0.0) and variable_mapB ~= (1.0) then
        variable_mapB = 1.0
        T_75 = CpuShip():setTemplate("Cruiser Q8"):setCallSign("T 75"):setFaction("Kraylor"):setPosition(-46054.0, -93264.0):orderRoaming()
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], T_75)
        T_74 = CpuShip():setTemplate("Cruiser Q8"):setCallSign("T 74"):setFaction("Kraylor"):setPosition(-46167.0, -92467.0):orderRoaming()
        table.insert(fleet[0], T_74)
        T_72 = CpuShip():setTemplate("Cruiser Q8"):setCallSign("T 72"):setFaction("Kraylor"):setPosition(-46054.0, -94744.0):orderRoaming()
        table.insert(fleet[0], T_72)
        T_81 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 81"):setFaction("Kraylor"):setPosition(-44574.0, -92240.0):orderRoaming()
        table.insert(fleet[0], T_81)
        T_21 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 21"):setFaction("Kraylor"):setPosition(-61765.0, -93492.0):orderRoaming()
        table.insert(fleet[0], T_21)
        Anomaly_A2_260 = SupplyDrop():setFaction("Human Navy"):setPosition(-54023.0, -88141.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
    end
    if ifInsideBox(Intrepid, 19230.0, -99781.0, -45935.0, -69671.0) and variable_mapC ~= (1.0) then
        variable_mapC = 1.0
        Asteroid():setPosition(-4498.0, -91101.0)
        Asteroid():setPosition(-5978.0, -91556.0)
        Asteroid():setPosition(-5864.0, -92353.0)
        Asteroid():setPosition(-6775.0, -92809.0)
        Asteroid():setPosition(-4839.0, -92012.0)
        Asteroid():setPosition(-3815.0, -93150.0)
        Asteroid():setPosition(-4725.0, -93720.0)
        Asteroid():setPosition(-4839.0, -92809.0)
        Asteroid():setPosition(-4839.0, -92809.0)
        Asteroid():setPosition(-4384.0, -92240.0)
        Asteroid():setPosition(-4612.0, -91784.0)
        Asteroid():setPosition(-5636.0, -91443.0)
        Asteroid():setPosition(-6092.0, -93037.0)
        Asteroid():setPosition(-5408.0, -92923.0)
        Asteroid():setPosition(-3131.0, -91898.0)
        Asteroid():setPosition(-2790.0, -93264.0)
        Asteroid():setPosition(-1765.0, -93720.0)
        Asteroid():setPosition(-1538.0, -94175.0)
        Asteroid():setPosition(-1310.0, -94175.0)
        Asteroid():setPosition(-1082.0, -93378.0)
        Asteroid():setPosition(-2221.0, -92581.0)
        Artemis:addCustomMessage("scienceOfficer", "warning", "Updating map...")
        Asteroid():setPosition(-2448.0, -92353.0)
        Asteroid():setPosition(-171.0, -94403.0)
        Asteroid():setPosition(1309.0, -94517.0)
        Asteroid():setPosition(-24649.0, -92695.0)
        Asteroid():setPosition(-22714.0, -92695.0)
        Asteroid():setPosition(-22145.0, -93834.0)
        Asteroid():setPosition(-24536.0, -92695.0)
        Asteroid():setPosition(-23283.0, -93264.0)
        Asteroid():setPosition(-23852.0, -93947.0)
        Asteroid():setPosition(-21689.0, -95314.0)
        Asteroid():setPosition(-20437.0, -93834.0)
        Asteroid():setPosition(-19754.0, -94175.0)
        Asteroid():setPosition(-17021.0, -94403.0)
        Asteroid():setPosition(-17932.0, -95427.0)
        Asteroid():setPosition(-19754.0, -94858.0)
        Asteroid():setPosition(-20892.0, -94630.0)
        Asteroid():setPosition(-18046.0, -94630.0)
        Asteroid():setPosition(-15655.0, -95086.0)
        Asteroid():setPosition(-15883.0, -95314.0)
        Asteroid():setPosition(-15541.0, -94972.0)
        Asteroid():setPosition(15199.0, -89735.0)
        Asteroid():setPosition(15996.0, -90646.0)
        Asteroid():setPosition(16110.0, -90873.0)
        Asteroid():setPosition(16907.0, -90873.0)
        Asteroid():setPosition(17362.0, -90532.0)
        Asteroid():setPosition(18387.0, -91670.0)
        Asteroid():setPosition(18614.0, -91784.0)
        Asteroid():setPosition(18728.0, -89621.0)
        Asteroid():setPosition(18842.0, -86433.0)
        Asteroid():setPosition(18842.0, -84498.0)
        Asteroid():setPosition(17476.0, -91101.0)
        Asteroid():setPosition(17931.0, -95200.0)
        Asteroid():setPosition(16451.0, -89507.0)
        Asteroid():setPosition(17134.0, -88710.0)
        Asteroid():setPosition(17931.0, -87116.0)
        Nebula():setPosition(-17021.0, -94289.0)
        Nebula():setPosition(-19982.0, -93834.0)
        Nebula():setPosition(-23739.0, -91784.0)
        Nebula():setPosition(-18046.0, -97932.0)
        Nebula():setPosition(-21462.0, -98615.0)
        Nebula():setPosition(-25333.0, -100095.0)
        Nebula():setPosition(-19982.0, -100095.0)
        Nebula():setPosition(-8369.0, -98729.0)
        Nebula():setPosition(-513.0, -98729.0)
        Nebula():setPosition(-3131.0, -93606.0)
        Nebula():setPosition(-3131.0, -93150.0)
        Nebula():setPosition(398.0, -95427.0)
        Nebula():setPosition(1309.0, -95200.0)
        Nebula():setPosition(-627.0, -94061.0)
        Nebula():setPosition(-1993.0, -96680.0)
        Nebula():setPosition(16679.0, -89279.0)
        Nebula():setPosition(18500.0, -94175.0)
        Nebula():setPosition(18614.0, -90532.0)
        Nebula():setPosition(13036.0, -92809.0)
        Nebula():setPosition(8481.0, -96338.0)
        Nebula():setPosition(9278.0, -97135.0)
        Nebula():setPosition(13833.0, -96224.0)
        Nebula():setPosition(15313.0, -95427.0)
        Nebula():setPosition(16679.0, -97249.0)
        Nebula():setPosition(-12695.0, -96452.0)
        Nebula():setPosition(-13492.0, -98388.0)
        Nebula():setPosition(-17818.0, -98843.0)
        Nebula():setPosition(-26585.0, -94175.0)
        Nebula():setPosition(-28407.0, -95883.0)
        Nebula():setPosition(-22600.0, -95883.0)
        Nebula():setPosition(-26471.0, -96908.0)
        Nebula():setPosition(-23739.0, -94061.0)
        Nebula():setPosition(-15314.0, -92809.0)
        Nebula():setPosition(-8482.0, -93492.0)
        Nebula():setPosition(-5750.0, -92126.0)
        Nebula():setPosition(-8710.0, -90987.0)
        Nebula():setPosition(-4270.0, -90418.0)
        Nebula():setPosition(-3245.0, -91670.0)
        Nebula():setPosition(-2790.0, -92695.0)
        Nebula():setPosition(-6092.0, -92467.0)
        Nebula():setPosition(1992.0, -92923.0)
        Nebula():setPosition(3130.0, -89735.0)
        Nebula():setPosition(3700.0, -89166.0)
        Nebula():setPosition(4952.0, -90646.0)
        Nebula():setPosition(5066.0, -91784.0)
        Nebula():setPosition(5407.0, -92695.0)
        Nebula():setPosition(5977.0, -94175.0)
        Nebula():setPosition(7001.0, -94744.0)
        Nebula():setPosition(3927.0, -96680.0)
        Nebula():setPosition(5066.0, -97477.0)
        Nebula():setPosition(8595.0, -93834.0)
        Nebula():setPosition(9165.0, -93834.0)
        Nebula():setPosition(11100.0, -93264.0)
        Nebula():setPosition(12011.0, -95314.0)
    end
    if ifInsideBox(Artemis, 19230.0, -99781.0, -45935.0, -69671.0) and variable_mapC ~= (1.0) then
        variable_mapC = 1.0
        Asteroid():setPosition(-4498.0, -91101.0)
        Asteroid():setPosition(-5978.0, -91556.0)
        Asteroid():setPosition(-5864.0, -92353.0)
        Asteroid():setPosition(-6775.0, -92809.0)
        Asteroid():setPosition(-4839.0, -92012.0)
        Asteroid():setPosition(-3815.0, -93150.0)
        Asteroid():setPosition(-4725.0, -93720.0)
        Asteroid():setPosition(-4839.0, -92809.0)
        Asteroid():setPosition(-4839.0, -92809.0)
        Asteroid():setPosition(-4384.0, -92240.0)
        Asteroid():setPosition(-4612.0, -91784.0)
        Asteroid():setPosition(-5636.0, -91443.0)
        Asteroid():setPosition(-6092.0, -93037.0)
        Asteroid():setPosition(-5408.0, -92923.0)
        Asteroid():setPosition(-3131.0, -91898.0)
        Asteroid():setPosition(-2790.0, -93264.0)
        Asteroid():setPosition(-1765.0, -93720.0)
        Asteroid():setPosition(-1538.0, -94175.0)
        Asteroid():setPosition(-1310.0, -94175.0)
        Asteroid():setPosition(-1082.0, -93378.0)
        Asteroid():setPosition(-2221.0, -92581.0)
        Artemis:addCustomMessage("scienceOfficer", "warning", "Updating map...")
        Asteroid():setPosition(-2448.0, -92353.0)
        Asteroid():setPosition(-171.0, -94403.0)
        Asteroid():setPosition(1309.0, -94517.0)
        Asteroid():setPosition(-24649.0, -92695.0)
        Asteroid():setPosition(-22714.0, -92695.0)
        Asteroid():setPosition(-22145.0, -93834.0)
        Asteroid():setPosition(-24536.0, -92695.0)
        Asteroid():setPosition(-23283.0, -93264.0)
        Asteroid():setPosition(-23852.0, -93947.0)
        Asteroid():setPosition(-21689.0, -95314.0)
        Asteroid():setPosition(-20437.0, -93834.0)
        Asteroid():setPosition(-19754.0, -94175.0)
        Asteroid():setPosition(-17021.0, -94403.0)
        Asteroid():setPosition(-17932.0, -95427.0)
        Asteroid():setPosition(-19754.0, -94858.0)
        Asteroid():setPosition(-20892.0, -94630.0)
        Asteroid():setPosition(-18046.0, -94630.0)
        Asteroid():setPosition(-15655.0, -95086.0)
        Asteroid():setPosition(-15883.0, -95314.0)
        Asteroid():setPosition(-15541.0, -94972.0)
        Asteroid():setPosition(15199.0, -89735.0)
        Asteroid():setPosition(15996.0, -90646.0)
        Asteroid():setPosition(16110.0, -90873.0)
        Asteroid():setPosition(16907.0, -90873.0)
        Asteroid():setPosition(17362.0, -90532.0)
        Asteroid():setPosition(18387.0, -91670.0)
        Asteroid():setPosition(18614.0, -91784.0)
        Asteroid():setPosition(18728.0, -89621.0)
        Asteroid():setPosition(18842.0, -86433.0)
        Asteroid():setPosition(18842.0, -84498.0)
        Asteroid():setPosition(17476.0, -91101.0)
        Asteroid():setPosition(17931.0, -95200.0)
        Asteroid():setPosition(16451.0, -89507.0)
        Asteroid():setPosition(17134.0, -88710.0)
        Asteroid():setPosition(17931.0, -87116.0)
        Nebula():setPosition(-17021.0, -94289.0)
        Nebula():setPosition(-19982.0, -93834.0)
        Nebula():setPosition(-23739.0, -91784.0)
        Nebula():setPosition(-18046.0, -97932.0)
        Nebula():setPosition(-21462.0, -98615.0)
        Nebula():setPosition(-25333.0, -100095.0)
        Nebula():setPosition(-19982.0, -100095.0)
        Nebula():setPosition(-8369.0, -98729.0)
        Nebula():setPosition(-513.0, -98729.0)
        Nebula():setPosition(-3131.0, -93606.0)
        Nebula():setPosition(-3131.0, -93150.0)
        Nebula():setPosition(398.0, -95427.0)
        Nebula():setPosition(1309.0, -95200.0)
        Nebula():setPosition(-627.0, -94061.0)
        Nebula():setPosition(-1993.0, -96680.0)
        Nebula():setPosition(16679.0, -89279.0)
        Nebula():setPosition(18500.0, -94175.0)
        Nebula():setPosition(18614.0, -90532.0)
        Nebula():setPosition(13036.0, -92809.0)
        Nebula():setPosition(8481.0, -96338.0)
        Nebula():setPosition(9278.0, -97135.0)
        Nebula():setPosition(13833.0, -96224.0)
        Nebula():setPosition(15313.0, -95427.0)
        Nebula():setPosition(16679.0, -97249.0)
        Nebula():setPosition(-12695.0, -96452.0)
        Nebula():setPosition(-13492.0, -98388.0)
        Nebula():setPosition(-17818.0, -98843.0)
        Nebula():setPosition(-26585.0, -94175.0)
        Nebula():setPosition(-28407.0, -95883.0)
        Nebula():setPosition(-22600.0, -95883.0)
        Nebula():setPosition(-26471.0, -96908.0)
        Nebula():setPosition(-23739.0, -94061.0)
        Nebula():setPosition(-15314.0, -92809.0)
        Nebula():setPosition(-8482.0, -93492.0)
        Nebula():setPosition(-5750.0, -92126.0)
        Nebula():setPosition(-8710.0, -90987.0)
        Nebula():setPosition(-4270.0, -90418.0)
        Nebula():setPosition(-3245.0, -91670.0)
        Nebula():setPosition(-2790.0, -92695.0)
        Nebula():setPosition(-6092.0, -92467.0)
        Nebula():setPosition(1992.0, -92923.0)
        Nebula():setPosition(3130.0, -89735.0)
        Nebula():setPosition(3700.0, -89166.0)
        Nebula():setPosition(4952.0, -90646.0)
        Nebula():setPosition(5066.0, -91784.0)
        Nebula():setPosition(5407.0, -92695.0)
        Nebula():setPosition(5977.0, -94175.0)
        Nebula():setPosition(7001.0, -94744.0)
        Nebula():setPosition(3927.0, -96680.0)
        Nebula():setPosition(5066.0, -97477.0)
        Nebula():setPosition(8595.0, -93834.0)
        Nebula():setPosition(9165.0, -93834.0)
        Nebula():setPosition(11100.0, -93264.0)
        Nebula():setPosition(12011.0, -95314.0)
    end
    if ifInsideBox(Artemis, 19450.0, -70220.0, -79011.0, -69671.0) and (timers["mapB"] ~= nil and timers["mapB"] < 0.0) and variable_DS_31_to_Artemis ~= (1.0) and variable_mapC == (1.0) then
        T_771 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 771"):setFaction("Kraylor"):setPosition(-8824.0, -3093.0):orderRoaming()
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], T_771)
        T_777 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 777"):setFaction("Kraylor"):setPosition(-10760.0, -3549.0):orderRoaming()
        table.insert(fleet[0], T_777)
        variable_DS_31_to_Artemis = 1.0
        temp_transmission_object:setCallSign("DS 31"):sendCommsMessage(getPlayerShip(-1), "DS 31 to TSN  vessels,  we have enemy ships inbound.  Can you assist us?  Repeat (static)...Help us (static)...")
    end
    if ifInsideBox(Intrepid, 19450.0, -70220.0, -79011.0, -69671.0) and (timers["mapB"] ~= nil and timers["mapB"] < 0.0) and variable_DS_31_to_Artemis ~= (1.0) and variable_mapC == (1.0) then
        T_771 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 771"):setFaction("Kraylor"):setPosition(-8824.0, -3093.0):orderRoaming()
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], T_771)
        T_777 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 777"):setFaction("Kraylor"):setPosition(-10760.0, -3549.0):orderRoaming()
        table.insert(fleet[0], T_777)
        variable_DS_31_to_Artemis = 1.0
        temp_transmission_object:setCallSign("DS 31"):sendCommsMessage(getPlayerShip(-1), "DS 31 to TSN  vessels,  we have enemy ships inbound.  Can you assist us?  Repeat (static)...Help us (static)...")
    end
    if (Artemis ~= nil and DS_31 ~= nil and Artemis:isValid() and DS_31:isValid() and distance(Artemis, DS_31) <= 6000.000000) and (timers["mapB"] ~= nil and timers["mapB"] < 0.0) and variable_spawn_up_E2____s ~= (1.0) then
        T_911 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 911"):setFaction("Kraylor"):setPosition(-51519.0, -5484.0):orderRoaming()
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], T_911)
        T_912 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 912"):setFaction("Kraylor"):setPosition(-50494.0, -6054.0):orderRoaming()
        table.insert(fleet[0], T_912)
        T_917 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 917"):setFaction("Kraylor"):setPosition(-49355.0, -6623.0):orderRoaming()
        table.insert(fleet[0], T_917)
        variable_spawn_up_E2____s = 1.0
        temp_transmission_object:setCallSign("DS 31"):sendCommsMessage(getPlayerShip(-1), "DS 31 to Fleet, we have an attack force heading on our position.")
    end
    if (T_74 == nil or not T_74:isValid()) and variable_sh____t_stormA ~= (1.0) and (timers["mapB"] ~= nil and timers["mapB"] < 0.0) then
        variable_sh____t_stormA = 1.0
        T_67 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 67"):setFaction("Kraylor"):setPosition(16907.0, -75389.0):orderRoaming()
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], T_67)
        T_62 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 62"):setFaction("Kraylor"):setPosition(18159.0, -65940.0):orderRoaming()
        table.insert(fleet[0], T_62)
        T_65 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 65"):setFaction("Kraylor"):setPosition(17703.0, -74593.0):orderRoaming()
        table.insert(fleet[0], T_65)
        T_511 = CpuShip():setTemplate("Cruiser Q8"):setCallSign("T 511"):setFaction("Kraylor"):setPosition(5066.0, -33834.0):orderRoaming()
        table.insert(fleet[0], T_511)
        T_512 = CpuShip():setTemplate("Cruiser Q8"):setCallSign("T 512"):setFaction("Kraylor"):setPosition(3927.0, -33492.0):orderRoaming()
        table.insert(fleet[0], T_512)
    end
    if (T_75 == nil or not T_75:isValid()) and variable_sh____t_stormA ~= (1.0) and variable_mapC == (1.0) and (timers["mapB"] ~= nil and timers["mapB"] < 0.0) then
        variable_sh____t_stormA = 1.0
        T_55 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 55"):setFaction("Kraylor"):setPosition(-43549.0, -5826.0):orderRoaming()
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], T_55)
        T_233 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 233"):setFaction("Kraylor"):setPosition(-42980.0, -4232.0):orderRoaming()
        table.insert(fleet[0], T_233)
        T_333 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 333"):setFaction("Kraylor"):setPosition(-78046.0, -21310.0):orderRoaming()
        table.insert(fleet[0], T_333)
        T_337 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 337"):setFaction("Kraylor"):setPosition(-76908.0, -20399.0):orderRoaming()
        table.insert(fleet[0], T_337)
        T_336 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 336"):setFaction("Kraylor"):setPosition(-76111.0, -19830.0):orderRoaming()
        table.insert(fleet[0], T_336)
        T_316 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 316"):setFaction("Kraylor"):setPosition(-75997.0, -19147.0):orderRoaming()
        table.insert(fleet[0], T_316)
        T_44 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 44"):setFaction("Kraylor"):setPosition(-76338.0, -13226.0):orderRoaming()
        table.insert(fleet[0], T_44)
        T_778 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 778"):setFaction("Kraylor"):setPosition(2333.0, -28596.0):orderRoaming()
        table.insert(fleet[0], T_778)
        T_771 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 771"):setFaction("Kraylor"):setPosition(1537.0, -27799.0):orderRoaming()
        table.insert(fleet[0], T_771)
    end
    if (T_74 == nil or not T_74:isValid()) and (timers["mapB"] ~= nil and timers["mapB"] < 0.0) and variable_intrepid_sh____t_stormA ~= (1.0) and (Intrepid ~= nil and Intrepid:isValid()) then
        variable_sh____t_stormA = 1.0
        T_401 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 401"):setFaction("Kraylor"):setPosition(-62355.0, -2304.0):orderRoaming()
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], T_401)
        T_402 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 402"):setFaction("Kraylor"):setPosition(-58709.0, -2912.0):orderRoaming()
        table.insert(fleet[0], T_402)
        T_403 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 403"):setFaction("Kraylor"):setPosition(-57038.0, -3064.0):orderRoaming()
        table.insert(fleet[0], T_403)
        timers["intrepid_sh____t_stormB"] = 12.000000
    end
    if (timers["intrepid_sh____t_stormB"] ~= nil and timers["intrepid_sh____t_stormB"] < 0.0) and (Intrepid ~= nil and Intrepid:isValid()) and (Artemis ~= nil and Artemis:isValid()) and variable_intrepid_sh____t_stormB ~= (1.0) then
        variable_intrepid_sh____t_stormB = 1.0
        T_421 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 421"):setFaction("Kraylor"):setPosition(-7823.0, -2152.0):orderRoaming()
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], T_421)
        T_422 = CpuShip():setTemplate("Starhammer II"):setCallSign("T 422"):setFaction("Kraylor"):setPosition(-7368.0, -1545.0):orderRoaming()
        table.insert(fleet[0], T_422)
        timers["intrepid_sh____t_stormB"] = 12.000000
    end
    if (Artemis ~= nil and Artemis:isValid()) then
        if T_75 ~= nil and T_75:isValid() then
            T_75:setJumpDrive(True)
            T_75:setWarpDrive(True)
        end
        if T_21 ~= nil and T_21:isValid() then
            T_21:setJumpDrive(True)
            T_21:setWarpDrive(True)
        end
        if T_771 ~= nil and T_771:isValid() then
            T_771:setJumpDrive(True)
            T_771:setWarpDrive(True)
        end
        if T_777 ~= nil and T_777:isValid() then
            T_777:setJumpDrive(True)
            T_777:setWarpDrive(True)
        end
        if T_911 ~= nil and T_911:isValid() then
            T_911:setJumpDrive(True)
            T_911:setWarpDrive(True)
        end
        if T_912 ~= nil and T_912:isValid() then
            T_912:setJumpDrive(True)
            T_912:setWarpDrive(True)
        end
        if T_917 ~= nil and T_917:isValid() then
            T_917:setJumpDrive(True)
            T_917:setWarpDrive(True)
        end
        if T_67 ~= nil and T_67:isValid() then
            T_67:setJumpDrive(True)
            T_67:setWarpDrive(True)
        end
        if T_62 ~= nil and T_62:isValid() then
            T_62:setJumpDrive(True)
            T_62:setWarpDrive(True)
        end
        if T_65 ~= nil and T_65:isValid() then
            T_65:setJumpDrive(True)
            T_65:setWarpDrive(True)
        end
        if T_511 ~= nil and T_511:isValid() then
            T_511:setJumpDrive(True)
            T_511:setWarpDrive(True)
        end
        if T_512 ~= nil and T_512:isValid() then
            T_512:setJumpDrive(True)
            T_512:setWarpDrive(True)
        end
        if T_55 ~= nil and T_55:isValid() then
            T_55:setJumpDrive(True)
            T_55:setWarpDrive(True)
        end
        if T_233 ~= nil and T_233:isValid() then
            T_233:setJumpDrive(True)
            T_233:setWarpDrive(True)
        end
    end
    if (Artemis == nil or not Artemis:isValid()) and variable_artemis_has_been_lost ~= (1.0) and (Intrepid == nil or not Intrepid:isValid()) and (timers["object_1st_msg_to_Ivan"] ~= nil and timers["object_1st_msg_to_Ivan"] < 0.0) then
        variable_artemis_has_been_lost = 1.0
        globalMessage("The sector has been lost\n\n");
        --WARNING: Ignore <warning_popup_message> {'message': 'The sector has been lost', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "The sector has been lost")
        Artemis:addCustomMessage("relayOfficer", "warning", "The sector has been lost")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "The sector has been lost")
        Artemis:addCustomMessage("scienceOfficer", "warning", "The sector has been lost")
        Artemis:addCustomMessage("helmsOfficer", "warning", "The sector has been lost")
        timers["artemis_has_been_lostA"] = 20.000000
        timers["artemis_has_been_lostB"] = 20.000000
    end
    if (Intrepid == nil or not Intrepid:isValid()) and variable_ivan_has_been_lost ~= (1.0) and (timers["object_1st_msg_to_Ivan"] ~= nil and timers["object_1st_msg_to_Ivan"] < 0.0) then
        variable_ivan_has_been_lost = 1.0
        globalMessage("\n\n");
    end
    if (Artemis == nil or not Artemis:isValid()) and variable_artemis_has_been_lost ~= (1.0) then
        variable_artemis_has_been_lost = 1.0
        globalMessage("The Artemis has been lost\n\n");
        --WARNING: Ignore <warning_popup_message> {'message': 'The Artemis has been lost', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "The Artemis has been lost")
        Artemis:addCustomMessage("relayOfficer", "warning", "The Artemis has been lost")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "The Artemis has been lost")
        Artemis:addCustomMessage("scienceOfficer", "warning", "The Artemis has been lost")
        Artemis:addCustomMessage("helmsOfficer", "warning", "The Artemis has been lost")
    end
    if (timers["artemis_has_been_lostA"] ~= nil and timers["artemis_has_been_lostA"] < 0.0) and variable_artemis_has_been_lostA ~= (1.0) then
        variable_artemis_has_been_lostA = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'Mission Failed', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Mission Failed")
        Artemis:addCustomMessage("relayOfficer", "warning", "Mission Failed")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Mission Failed")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Mission Failed")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Mission Failed")
    end
    if (timers["artemis_has_been_lostB"] ~= nil and timers["artemis_has_been_lostB"] < 0.0) then
    end
    if (TSN_Ivan == nil or not TSN_Ivan:isValid()) and variable_ivan_has_been_lost ~= (1.0) and variable_lose_the_ivanA == (1.0) then
        variable_ivan_has_been_lost = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'The Ivan has been lost', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "The Ivan has been lost")
        Artemis:addCustomMessage("relayOfficer", "warning", "The Ivan has been lost")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "The Ivan has been lost")
        Artemis:addCustomMessage("scienceOfficer", "warning", "The Ivan has been lost")
        Artemis:addCustomMessage("helmsOfficer", "warning", "The Ivan has been lost")
        timers["ivan____s_lost"] = 14.000000
    end
    if (timers["ivan____s_lost"] ~= nil and timers["ivan____s_lost"] < 0.0) and variable_ivan_has_been_lostA ~= (1.0) and (DS_31 ~= nil and DS_31:isValid()) and variable_lose_the_ivanA == (1.0) then
        variable_ivan_has_been_lostA = 1.0
        temp_transmission_object:setCallSign("DS 31"):sendCommsMessage(getPlayerShip(-1), "Base to  Fleet,  we\'ve lost contact with the Ivan.   DS 31, out.")
    end
    if (timers["ivan____s_lost"] ~= nil and timers["ivan____s_lost"] < 0.0) and (DS_31 == nil or not DS_31:isValid()) and countFleet(0) >= 1.000000 and (DS_27 ~= nil and DS_27:isValid()) and variable_ivan_has_been_lostB ~= (1.0) then
        variable_ivan_has_been_lostB = 1.0
        temp_transmission_object:setCallSign("DS 27"):sendCommsMessage(getPlayerShip(-1), "DS 27 to all vessels.  We are in need of assistance.  DS 27, out.")
    end
    if (timers["spawn_last_chaseA"] ~= nil and timers["spawn_last_chaseA"] < 0.0) and (TSN_Ivan == nil or not TSN_Ivan:isValid()) and variable_ivans_dead_from_ds27 ~= (1.0) and (DS_27 ~= nil and DS_27:isValid()) and (DS_31 == nil or not DS_31:isValid()) then
        variable_ivans_dead_from_ds27 = 1.0
        temp_transmission_object:setCallSign("DS 27"):sendCommsMessage(getPlayerShip(-1), "TSN  vessels,  the Ivan\'s been destroyed")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Ivan has been destroyed")
        variable_you_guys_rock_endingA = 1.0
    end
    if (timers["spawn_last_chaseA"] ~= nil and timers["spawn_last_chaseA"] < 0.0) and (TSN_Ivan == nil or not TSN_Ivan:isValid()) and variable_ivans_dead_from_ds31 ~= (1.0) and (DS_27 == nil or not DS_27:isValid()) and (DS_31 ~= nil and DS_31:isValid()) then
        variable_ivans_dead_from_ds31 = 1.0
        temp_transmission_object:setCallSign("DS 31"):sendCommsMessage(getPlayerShip(-1), "TSN  vessels,  the Ivan\'s been destroyed")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Ivan has been destroyed")
        variable_you_guys_rock_endingA = 1.0
    end
    if (timers["spawn_last_chaseA"] ~= nil and timers["spawn_last_chaseA"] < 0.0) and (TSN_Ivan == nil or not TSN_Ivan:isValid()) and variable_ivans_dead_from_ds27and31 ~= (1.0) and (DS_27 ~= nil and DS_27:isValid()) and (DS_31 ~= nil and DS_31:isValid()) then
        variable_ivans_dead_from_ds27and31 = 1.0
        temp_transmission_object:setCallSign("DS 31"):sendCommsMessage(getPlayerShip(-1), "TSN  vessels,  the Ivan\'s been destroyed")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Ivan has been destroyed")
        variable_you_guys_rock_endingA = 1.0
    end
    if (timers["spawn_last_chaseA"] ~= nil and timers["spawn_last_chaseA"] < 0.0) and (TSN_Ivan == nil or not TSN_Ivan:isValid()) and variable_no_ds27_or_31 ~= (1.0) and (DS_27 == nil or not DS_27:isValid()) and (DS_31 == nil or not DS_31:isValid()) then
        variable_no_ds27_or_31 = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Ivan has been destroyed")
        variable_you_guys_rock_endingA = 1.0
    end
    if (timers["lose_the_ivanA"] ~= nil and timers["lose_the_ivanA"] < 0.0) and variable_lose_the_ivanA ~= (1.0) then
        variable_lose_the_ivanA = 1.0
        temp_transmission_object:setCallSign("DS 31"):sendCommsMessage(getPlayerShip(-1), "Base to Ivan, we\'ve lost sensor readings on you(static)...repeat, we\'ve lost you on our sensors...")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Sensor malfunction...")
        Artemis:addCustomMessage("relayOfficer", "warning", "Interference...")
    end
    if (timers["lose_the_ivanB"] ~= nil and timers["lose_the_ivanB"] < 0.0) and variable_lose_the_ivanB ~= (1.0) then
        variable_lose_the_ivanB = 1.0
        temp_transmission_object:setCallSign("DS 31"):sendCommsMessage(getPlayerShip(-1), "Base to Ivan, we\'ve lost sensor readings on you(static)...repeat, we\'ve lost you on our sensors...")
    end
    if (timers["lose_the_ivanB"] ~= nil and timers["lose_the_ivanB"] < 0.0) and variable_lose_the_ivanB ~= (1.0) then
        variable_lose_the_ivanB = 1.0
        temp_transmission_object:setCallSign("DS 31"):sendCommsMessage(getPlayerShip(-1), "Base to TSN ships, we\'ve lost contact with the Ivan (static)... repeat, we\'ve lost contact with (static)...Ivan.")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Sensor malfunction...")
    end
    if (timers["spawn_last_chaseA"] ~= nil and timers["spawn_last_chaseA"] < 0.0) and countFleet(0) <= 0.000000 and variable_enemy_equals_0 ~= (1.0) and (Intrepid ~= nil and Intrepid:isValid()) and (DS_27 == nil or not DS_27:isValid()) and (DS_31 == nil or not DS_31:isValid()) and (timers["grace_before_ending"] ~= nil and timers["grace_before_ending"] < 0.0) then
        variable_enemy_equals_0 = 1.0
        timers["enending_countdownA"] = 8.000000
        timers["enending_countdownB"] = 20.000000
        --WARNING: Ignore <warning_popup_message> {'message': 'The Intrepid has survived', 'consoles': 'MHWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "The Intrepid has survived")
        Artemis:addCustomMessage("relayOfficer", "warning", "The Intrepid has survived")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "The Intrepid has survived")
        Artemis:addCustomMessage("scienceOfficer", "warning", "The Intrepid has survived")
        Artemis:addCustomMessage("helmsOfficer", "warning", "The Intrepid has survived")
    end
    if (timers["spawn_last_chaseA"] ~= nil and timers["spawn_last_chaseA"] < 0.0) and countFleet(0) <= 0.000000 and variable_enemy_equals_0A ~= (1.0) and (Intrepid ~= nil and Intrepid:isValid()) and (Artemis ~= nil and Artemis:isValid()) and (DS_27 == nil or not DS_27:isValid()) and (DS_31 == nil or not DS_31:isValid()) and (timers["mapB"] ~= nil and timers["mapB"] < 0.0) and (timers["grace_before_ending"] ~= nil and timers["grace_before_ending"] < 0.0) then
        variable_enemy_equals_0A = 1.0
        timers["enending_countdownA"] = 8.000000
        timers["enending_countdownB"] = 20.000000
        --WARNING: Ignore <warning_popup_message> {'message': 'Bases have evacuated', 'consoles': 'MHWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Bases have evacuated")
        Artemis:addCustomMessage("relayOfficer", "warning", "Bases have evacuated")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Bases have evacuated")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Bases have evacuated")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Bases have evacuated")
    end
    if (timers["spawn_last_chaseA"] ~= nil and timers["spawn_last_chaseA"] < 0.0) and countFleet(0) <= 0.000000 and variable_enemy_equals_0B ~= (1.0) and (Artemis ~= nil and Artemis:isValid()) and (DS_27 == nil or not DS_27:isValid()) and (DS_31 == nil or not DS_31:isValid()) and (timers["grace_before_ending"] ~= nil and timers["grace_before_ending"] < 0.0) then
        variable_enemy_equals_0B = 1.0
        timers["enending_countdownA"] = 8.000000
        timers["enending_countdownB"] = 20.000000
        --WARNING: Ignore <warning_popup_message> {'message': 'The Artemis has survived', 'consoles': 'MHWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "The Artemis has survived")
        Artemis:addCustomMessage("relayOfficer", "warning", "The Artemis has survived")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "The Artemis has survived")
        Artemis:addCustomMessage("scienceOfficer", "warning", "The Artemis has survived")
        Artemis:addCustomMessage("helmsOfficer", "warning", "The Artemis has survived")
    end
    if (timers["spawn_last_chaseA"] ~= nil and timers["spawn_last_chaseA"] < 0.0) and countFleet(0) <= 0.000000 and variable_enemy_equals_0C ~= (1.0) and (DS_27 ~= nil and DS_27:isValid()) and (DS_31 ~= nil and DS_31:isValid()) and (timers["mapB"] ~= nil and timers["mapB"] < 0.0) and (Artemis ~= nil and Artemis:isValid()) and (Intrepid ~= nil and Intrepid:isValid()) and (timers["grace_before_ending"] ~= nil and timers["grace_before_ending"] < 0.0) then
        variable_enemy_equals_0C = 1.0
        timers["enending_countdownA"] = 8.000000
        timers["enending_countdownB"] = 20.000000
        --WARNING: Ignore <warning_popup_message> {'message': 'nice', 'consoles': 'MHWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "nice")
        Artemis:addCustomMessage("relayOfficer", "warning", "nice")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "nice")
        Artemis:addCustomMessage("scienceOfficer", "warning", "nice")
        Artemis:addCustomMessage("helmsOfficer", "warning", "nice")
    end
    if (timers["spawn_last_chaseA"] ~= nil and timers["spawn_last_chaseA"] < 0.0) and countFleet(0) <= 0.000000 and variable_enemy_equals_0C ~= (1.0) and (DS_27 ~= nil and DS_27:isValid()) and (DS_31 ~= nil and DS_31:isValid()) and (timers["mapB"] ~= nil and timers["mapB"] < 0.0) and (Artemis ~= nil and Artemis:isValid()) and (Intrepid == nil or not Intrepid:isValid()) and (timers["grace_before_ending"] ~= nil and timers["grace_before_ending"] < 0.0) then
        variable_enemy_equals_0C = 1.0
        timers["enending_countdownA"] = 8.000000
        timers["enending_countdownB"] = 20.000000
        --WARNING: Ignore <warning_popup_message> {'message': 'nice', 'consoles': 'MHWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "nice")
        Artemis:addCustomMessage("relayOfficer", "warning", "nice")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "nice")
        Artemis:addCustomMessage("scienceOfficer", "warning", "nice")
        Artemis:addCustomMessage("helmsOfficer", "warning", "nice")
    end
    if variable_enemy_equals_1 ~= (1.0) then
        variable_enemy_equals_1 = 1.0
        if T_75 ~= nil and T_75:isValid() then
            T_75:setWarpDrive(True)
        end
        if T_74 ~= nil and T_74:isValid() then
            T_74:setWarpDrive(True)
        end
        if T_911 ~= nil and T_911:isValid() then
            T_911:setWarpDrive(True)
        end
        if T_912 ~= nil and T_912:isValid() then
            T_912:setWarpDrive(True)
        end
        if T_44 ~= nil and T_44:isValid() then
            T_44:setWarpDrive(True)
        end
        if T_72 ~= nil and T_72:isValid() then
            T_72:setWarpDrive(True)
        end
        if T_81 ~= nil and T_81:isValid() then
            T_81:setWarpDrive(True)
        end
        if T_21 ~= nil and T_21:isValid() then
            T_21:setWarpDrive(True)
        end
        if T_67 ~= nil and T_67:isValid() then
            T_67:setWarpDrive(True)
        end
        if T_65 ~= nil and T_65:isValid() then
            T_65:setWarpDrive(True)
        end
        if T_336 ~= nil and T_336:isValid() then
            T_336:setWarpDrive(True)
        end
        if T_333 ~= nil and T_333:isValid() then
            T_333:orderFlyTowards(1978.0, -97803.0)
        end
        if T_336 ~= nil and T_336:isValid() then
            T_336:orderFlyTowards(1978.0, -97803.0)
        end
        if T_337 ~= nil and T_337:isValid() then
            T_337:orderFlyTowards(1978.0, -97803.0)
        end
        if T_21 ~= nil and T_21:isValid() then
            T_21:orderFlyTowards(1978.0, -97803.0)
        end
        if T_44 ~= nil and T_44:isValid() then
            T_44:orderFlyTowards(1978.0, -97803.0)
        end
        if T_62 ~= nil and T_62:isValid() then
            T_62:orderFlyTowards(1978.0, -97803.0)
        end
        if T_65 ~= nil and T_65:isValid() then
            T_65:orderFlyTowards(1978.0, -97803.0)
        end
        if T_67 ~= nil and T_67:isValid() then
            T_67:orderFlyTowards(1978.0, -97803.0)
        end
        if T_771 ~= nil and T_771:isValid() then
            T_771:orderFlyTowards(1978.0, -97803.0)
        end
        if T_777 ~= nil and T_777:isValid() then
            T_777:orderFlyTowards(1978.0, -97803.0)
        end
        if T_778 ~= nil and T_778:isValid() then
            T_778:orderFlyTowards(1978.0, -97803.0)
        end
        if T_81 ~= nil and T_81:isValid() then
            T_81:orderFlyTowards(1978.0, -97803.0)
        end
        if T_233 ~= nil and T_233:isValid() then
            T_233:orderFlyTowards(1978.0, -97803.0)
        end
        if T_512 ~= nil and T_512:isValid() then
            T_512:orderFlyTowards(1978.0, -97803.0)
        end
        if T_511 ~= nil and T_511:isValid() then
            T_511:orderFlyTowards(1978.0, -97803.0)
        end
        if T_55 ~= nil and T_55:isValid() then
            T_55:orderFlyTowards(1978.0, -97803.0)
        end
        if T_74 ~= nil and T_74:isValid() then
            T_74:orderFlyTowards(1978.0, -97803.0)
        end
        if T_75 ~= nil and T_75:isValid() then
            T_75:orderFlyTowards(1978.0, -97803.0)
        end
        if T_72 ~= nil and T_72:isValid() then
            T_72:orderFlyTowards(1978.0, -97803.0)
        end
        if T_917 ~= nil and T_917:isValid() then
            T_917:orderFlyTowards(1978.0, -97803.0)
        end
        if T_912 ~= nil and T_912:isValid() then
            T_912:orderFlyTowards(1978.0, -97803.0)
        end
        if T_911 ~= nil and T_911:isValid() then
            T_911:orderFlyTowards(1978.0, -97803.0)
        end
    end
    if (timers["enending_countdownB"] ~= nil and timers["enending_countdownB"] < 0.0) and variable_you_guys_rockA ~= (1.0) then
        temp_transmission_object:setCallSign("Base"):sendCommsMessage(getPlayerShip(-1), "TSN  ships, you guys Rock!!!")
        variable_you_guys_rockA = 1.0
        timers["you_guys_rock_ending"] = 15.000000
        variable_you_guys_rock_endingA = 1.0
    end
    if (timers["spawn_last_chaseA"] ~= nil and timers["spawn_last_chaseA"] < 0.0) and (timers["you_guys_rock_ending"] ~= nil and timers["you_guys_rock_ending"] < 0.0) and variable_you_guys_rock_endingA ~= (1.0) then
        variable_you_guys_rock_endingA = 1.0
        timers["you_guys_rock_endingB"] = 10.000000
    end
    if (timers["spawn_last_chaseA"] ~= nil and timers["spawn_last_chaseA"] < 0.0) and variable_last_chaseA ~= (1.0) then
        variable_last_chaseA = 1.0
        K_57 = CpuShip():setTemplate("Phobos M3P"):setCallSign("K 57"):setFaction("Kraylor"):setPosition(4383.0, -31329.0):orderRoaming()
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], K_57)
        temp_transmission_object:setCallSign("TSN Ivan"):sendCommsMessage(getPlayerShip(-1), "Ivan to TSN  fleet, we are being pursued by an enemy warship. We have exhausted our weapons and are running on minimal (static)...need assistence...")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Sensor malfunction...")
        Artemis:addCustomMessage("relayOfficer", "warning", "Interference...")
        getPlayerShip(-1):setSystemHealth("reactor", -0.500000)
        Artemis:addCustomMessage("scienceOfficer", "warning", "IVAN on sensors")
        timers["spawn_last_chaseB"] = 14.000000
        timers["spawn_last_chaseC"] = 22.000000
    end
    if (timers["you_guys_rock_ending"] ~= nil and timers["you_guys_rock_ending"] < 0.0) and variable_last_chaseB ~= (1.0) then
        variable_last_chaseB = 1.0
        timers["you_guys_rock_endingA"] = 0.000000
        if TSN_Ivan ~= nil and TSN_Ivan:isValid() then
            TSN_Ivan:orderFlyTowards(-13407.0, -11979.0)
        end
    end
    if (timers["spawn_last_chaseB"] ~= nil and timers["spawn_last_chaseB"] < 0.0) and variable_spawn_last_chaseA ~= (1.0) then
        variable_spawn_last_chaseA = 1.0
        K_32 = CpuShip():setTemplate("Phobos M3P"):setCallSign("K 32"):setFaction("Kraylor"):setPosition(4383.0, -31329.0):orderRoaming()
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], K_32)
        K477 = CpuShip():setTemplate("Phobos M3P"):setCallSign("K477"):setFaction("Kraylor"):setPosition(2789.0, -31784.0):orderRoaming()
        table.insert(fleet[0], K477)
    end
    if (timers["spawn_last_chaseC"] ~= nil and timers["spawn_last_chaseC"] < 0.0) and variable_looks_like_thats_it ~= (1.0) and countFleet(0) <= 0.000000 then
        variable_looks_like_thats_it = 1.0
        temp_transmission_object:setCallSign("TSN Ivan"):sendCommsMessage(getPlayerShip(-1), "Ivan to Fleet,  looks like that might be the last of them.  Returning to base. Ivan, out.")
        timers["grace_before_ending"] = 15.000000
    end
    if countFleet(0) <= 1.000000 and variable_bring_back_ivanA ~= (1.0) and (timers["lost_ivanC"] ~= nil and timers["lost_ivanC"] < 0.0) and ifOutsideBox(Artemis, 9450.0, -37253.0, -770.0, -25385.0) then
        variable_bring_back_ivanA = 1.0
        TSN_Ivan = CpuShip():setTemplate("Tug"):setCallSign("TSN Ivan"):setFaction("Independent"):setPosition(4383.0, -31329.0):orderRoaming()
        timers["spawn_last_chaseA"] = 7.000000
    end
    if (timers["you_guys_rock_endingA"] ~= nil and timers["you_guys_rock_endingA"] < 0.0) and variable_another_count_to_endA ~= (1.0) then
        --WARNING: Ignore <warning_popup_message> {'message': 'Mission Successful', 'consoles': 'MHWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Mission Successful")
        Artemis:addCustomMessage("relayOfficer", "warning", "Mission Successful")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Mission Successful")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Mission Successful")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Mission Successful")
        variable_another_count_to_endA = 1.0
        timers["ending_creditsA"] = 14.000000
    end
    if (timers["ending_creditsA"] ~= nil and timers["ending_creditsA"] < 0.0) and variable_ending_creditsA ~= (1.0) then
        variable_ending_creditsA = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'All stations turn music on', 'consoles': 'MHWESC'} 
        Artemis:addCustomMessage("engineering", "warning", "All stations turn music on")
        Artemis:addCustomMessage("relayOfficer", "warning", "All stations turn music on")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "All stations turn music on")
        Artemis:addCustomMessage("scienceOfficer", "warning", "All stations turn music on")
        Artemis:addCustomMessage("helmsOfficer", "warning", "All stations turn music on")
        temp_transmission_object:setCallSign("Command"):sendCommsMessage(getPlayerShip(-1), "Nice work everyone, all ships form up with the Ivan and return to base.  Command, out.")
        timers["ending_creditsB"] = 7.000000
    end
    if (timers["ending_creditsB"] ~= nil and timers["ending_creditsB"] < 0.0) and variable_ending_creditsB ~= (1.0) then
        variable_ending_creditsB = 1.0
        Artemis:addCustomMessage("engineering", "warning", "All stations go to observer")
        Artemis:addCustomMessage("relayOfficer", "warning", "All stations go to observer")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "All stations go to observer")
        Artemis:addCustomMessage("scienceOfficer", "warning", "All stations go to observer")
        Artemis:addCustomMessage("helmsOfficer", "warning", "All stations go to observer")
        timers["ending_creditsC"] = 15.000000
    end
    if (timers["ending_creditsC"] ~= nil and timers["ending_creditsC"] < 0.0) and ifInsideBox(TSN_Ivan, 19450.0, -14726.0, -79231.0, -6264.0) and variable_ending_creditsC ~= (1.0) then
        variable_ending_creditsC = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'Artemis by Thom Robertson', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Artemis by Thom Robertson")
        Artemis:addCustomMessage("relayOfficer", "warning", "Artemis by Thom Robertson")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Artemis by Thom Robertson")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Artemis by Thom Robertson")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Artemis by Thom Robertson")
        timers["ending_creditsD"] = 14.000000
        globalMessage("Artemis\nby Thom Robertson\n");
    end
    if (timers["ending_creditsD"] ~= nil and timers["ending_creditsD"] < 0.0) and variable_ending_creditsD ~= (1.0) then
        variable_ending_creditsD = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'music by', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "music by")
        Artemis:addCustomMessage("relayOfficer", "warning", "music by")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "music by")
        Artemis:addCustomMessage("scienceOfficer", "warning", "music by")
        Artemis:addCustomMessage("helmsOfficer", "warning", "music by")
        timers["ending_creditsE"] = 5.000000
        globalMessage("\nmusic by\n");
    end
    if (timers["ending_creditsE"] ~= nil and timers["ending_creditsE"] < 0.0) and variable_ending_creditsE ~= (1.0) then
        variable_ending_creditsE = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'John Robert Matz', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "John Robert Matz")
        Artemis:addCustomMessage("relayOfficer", "warning", "John Robert Matz")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "John Robert Matz")
        Artemis:addCustomMessage("scienceOfficer", "warning", "John Robert Matz")
        Artemis:addCustomMessage("helmsOfficer", "warning", "John Robert Matz")
        globalMessage("\nJohn Robert Matz\n");
        timers["ending_creditsF"] = 12.000000
    end
    if (timers["ending_creditsF"] ~= nil and timers["ending_creditsF"] < 0.0) and variable_ending_creditsF ~= (1.0) then
        variable_ending_creditsF = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'the end', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "the end")
        Artemis:addCustomMessage("relayOfficer", "warning", "the end")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "the end")
        Artemis:addCustomMessage("scienceOfficer", "warning", "the end")
        Artemis:addCustomMessage("helmsOfficer", "warning", "the end")
        globalMessage("\nthe end\n");
        timers["ending_creditsG"] = 8.000000
    end
    if (timers["ending_creditsG"] ~= nil and timers["ending_creditsG"] < 0.0) then
        victory("Human Navy")
    end
    if (DS_27 ~= nil and DS_27:isValid()) and variable_DS_27_survived ~= (1.0) and (DS_31 == nil or not DS_31:isValid()) then
        variable_DS_27_survived = 1.0
        timers["enending_countdownC"] = 8.000000
        timers["enending_countdownCA"] = 11.000000
        timers["enending_countdownD"] = 20.000000
        --WARNING: Ignore <warning_popup_message> {'message': 'DS 31 has been lost', 'consoles': 'MHWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "DS 31 has been lost")
        Artemis:addCustomMessage("relayOfficer", "warning", "DS 31 has been lost")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "DS 31 has been lost")
        Artemis:addCustomMessage("scienceOfficer", "warning", "DS 31 has been lost")
        Artemis:addCustomMessage("helmsOfficer", "warning", "DS 31 has been lost")
    end
    if (DS_31 ~= nil and DS_31:isValid()) and variable_DS_31_survived ~= (1.0) and (DS_27 == nil or not DS_27:isValid()) then
        variable_DS_31_survived = 1.0
        timers["enending_countdownC"] = 8.000000
        timers["enending_countdownCA"] = 11.000000
        timers["enending_countdownD"] = 20.000000
        --WARNING: Ignore <warning_popup_message> {'message': 'DS 27 has been lost', 'consoles': 'MHWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "DS 27 has been lost")
        Artemis:addCustomMessage("relayOfficer", "warning", "DS 27 has been lost")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "DS 27 has been lost")
        Artemis:addCustomMessage("scienceOfficer", "warning", "DS 27 has been lost")
        Artemis:addCustomMessage("helmsOfficer", "warning", "DS 27 has been lost")
    end
    if (timers["enending_countdownCA"] ~= nil and timers["enending_countdownCA"] < 0.0) and variable_enending_countdownCA ~= (1.0) then
        variable_enending_countdownCA = 1.0
        globalMessage("\nMission unsuccessful\n");
        Artemis:addCustomMessage("engineering", "warning", "Mission unsuccessful")
        Artemis:addCustomMessage("relayOfficer", "warning", "Mission unsuccessful")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Mission unsuccessful")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Mission unsuccessful")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Mission unsuccessful")
    end
    if (timers["enending_countdownD"] ~= nil and timers["enending_countdownD"] < 0.0) then
        victory("Kraylor")
    end
    if ifInsideBox(TSN_Ivan, 19028.0, -93886.0, -13297.0, -68572.0) and ifOutsideBox(Artemis, 19200.0, -77086.0, -12858.0, -70572.0) and variable_vanish_ivanA ~= (1.0) then
        variable_vanish_ivanA = 1.0
        if TSN_Ivan ~= nil and TSN_Ivan:isValid() then TSN_Ivan:destroy() end
        timers["lost_ivanA"] = 10.000000
        timers["lost_ivanB"] = 18.000000
        timers["lost_ivanC"] = 2.000000
    end
    if (timers["lost_ivanA"] ~= nil and timers["lost_ivanA"] < 0.0) and variable_lost_ivanA ~= (1.0) then
        variable_lost_ivanA = 1.0
        temp_transmission_object:setCallSign("DS 27"):sendCommsMessage(getPlayerShip(-1), "Ivan this is Command.  Do you read us...")
    end
    if (timers["lost_ivanB"] ~= nil and timers["lost_ivanB"] < 0.0) and variable_lost_ivanB ~= (1.0) then
        variable_lost_ivanB = 1.0
        temp_transmission_object:setCallSign("DS 27"):sendCommsMessage(getPlayerShip(-1), "Ivan this is Command.  Do you read us...")
        timers["apbA"] = 15.000000
    end
    if (timers["apbA"] ~= nil and timers["apbA"] < 0.0) and variable_lost_ivanC ~= (1.0) then
        variable_lost_ivanC = 1.0
        temp_transmission_object:setCallSign("DS 27"):sendCommsMessage(getPlayerShip(-1), "TSN vessels, we have lost contact with the Ivan.  Her last known coordinates where sector B 4.")
        timers["apbB"] = 15.000000
    end
    if countFleet(0) <= 0.000000 and (DS_27 ~= nil and DS_27:isValid()) and (DS_31 ~= nil and DS_31:isValid()) and variable_DS_27_and_31_survived ~= (1.0) and (TSN_Ivan ~= nil and TSN_Ivan:isValid()) and (timers["mapB"] ~= nil and timers["mapB"] < 0.0) and (Artemis ~= nil and Artemis:isValid()) and (timers["you_guys_rock_endingB"] ~= nil and timers["you_guys_rock_endingB"] < 0.0) and (timers["grace_before_ending"] ~= nil and timers["grace_before_ending"] < 0.0) then
        variable_DS_27_and_31_survived = 1.0
        timers["enending_countdownF"] = 20.000000
        timers["enending_countdownE"] = 8.000000
        --WARNING: Ignore <warning_popup_message> {'message': 'All bases have survived', 'consoles': 'MHWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "All bases have survived")
        Artemis:addCustomMessage("relayOfficer", "warning", "All bases have survived")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "All bases have survived")
        Artemis:addCustomMessage("scienceOfficer", "warning", "All bases have survived")
        Artemis:addCustomMessage("helmsOfficer", "warning", "All bases have survived")
    end
    if countFleet(0) <= 0.000000 and (DS_27 ~= nil and DS_27:isValid()) and (DS_31 ~= nil and DS_31:isValid()) and variable_DS_27_and_31_survived ~= (1.0) and (TSN_Ivan ~= nil and TSN_Ivan:isValid()) and (timers["mapB"] ~= nil and timers["mapB"] < 0.0) and (Artemis ~= nil and Artemis:isValid()) and (timers["you_guys_rock_endingB"] ~= nil and timers["you_guys_rock_endingB"] < 0.0) and (timers["grace_before_ending"] ~= nil and timers["grace_before_ending"] < 0.0) then
        variable_DS_27_and_31_survived = 1.0
        timers["enending_countdownF"] = 20.000000
        timers["enending_countdownE"] = 8.000000
        --WARNING: Ignore <warning_popup_message> {'message': 'All bases have survived', 'consoles': 'MHWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "All bases have survived")
        Artemis:addCustomMessage("relayOfficer", "warning", "All bases have survived")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "All bases have survived")
        Artemis:addCustomMessage("scienceOfficer", "warning", "All bases have survived")
        Artemis:addCustomMessage("helmsOfficer", "warning", "All bases have survived")
    end
    if (timers["grace_before_ending"] ~= nil and timers["grace_before_ending"] < 0.0) and countFleet(0) <= 0.000000 and (DS_27 == nil or not DS_27:isValid()) and (DS_31 ~= nil and DS_31:isValid()) and variable_DS_31_survived ~= (1.0) and (TSN_Ivan ~= nil and TSN_Ivan:isValid()) and (timers["mapB"] ~= nil and timers["mapB"] < 0.0) and (Artemis ~= nil and Artemis:isValid()) and (timers["you_guys_rock_endingB"] ~= nil and timers["you_guys_rock_endingB"] < 0.0) then
        variable_DS_31_survived = 1.0
        timers["enending_countdownF"] = 20.000000
        timers["enending_countdownE"] = 8.000000
        --WARNING: Ignore <warning_popup_message> {'message': 'DS 27 has been lost', 'consoles': 'MHWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "DS 27 has been lost")
        Artemis:addCustomMessage("relayOfficer", "warning", "DS 27 has been lost")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "DS 27 has been lost")
        Artemis:addCustomMessage("scienceOfficer", "warning", "DS 27 has been lost")
        Artemis:addCustomMessage("helmsOfficer", "warning", "DS 27 has been lost")
    end
    if (timers["grace_before_ending"] ~= nil and timers["grace_before_ending"] < 0.0) and countFleet(0) <= 0.000000 and (DS_31 == nil or not DS_31:isValid()) and (DS_27 ~= nil and DS_27:isValid()) and variable_DS_27_survived ~= (1.0) and (TSN_Ivan ~= nil and TSN_Ivan:isValid()) and (timers["mapB"] ~= nil and timers["mapB"] < 0.0) and (Artemis ~= nil and Artemis:isValid()) and (timers["you_guys_rock_endingB"] ~= nil and timers["you_guys_rock_endingB"] < 0.0) then
        variable_DS_27_survived = 1.0
        timers["enending_countdownF"] = 20.000000
        timers["enending_countdownE"] = 8.000000
        --WARNING: Ignore <warning_popup_message> {'message': 'DS 27 has been lost', 'consoles': 'MHWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "DS 27 has been lost")
        Artemis:addCustomMessage("relayOfficer", "warning", "DS 27 has been lost")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "DS 27 has been lost")
        Artemis:addCustomMessage("scienceOfficer", "warning", "DS 27 has been lost")
        Artemis:addCustomMessage("helmsOfficer", "warning", "DS 27 has been lost")
    end
    if (timers["enending_countdownE"] ~= nil and timers["enending_countdownE"] < 0.0) and variable_successful_ending ~= (1.0) then
        --WARNING: Ignore <warning_popup_message> {'message': 'Mission Successful', 'consoles': 'MHWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Mission Successful")
        Artemis:addCustomMessage("relayOfficer", "warning", "Mission Successful")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Mission Successful")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Mission Successful")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Mission Successful")
        variable_successful_ending = 1.0
    end
    if (timers["enending_countdownF"] ~= nil and timers["enending_countdownF"] < 0.0) then
        victory("Human Navy")
    end
    if ifInsideBox(Artemis, 0.0, -87033.0, -19891.0, -67803.0) and variable_scans_negativeA ~= (1.0) and (timers["lose_the_ivanA"] ~= nil and timers["lose_the_ivanA"] < 0.0) then
        variable_scans_negativeA = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "(Science)Short Range Sensors Negative")
    end
    if ifInsideBox(Intrepid, 0.0, -87033.0, -19891.0, -67803.0) and variable_scans_negativeB ~= (1.0) and (timers["lose_the_ivanA"] ~= nil and timers["lose_the_ivanA"] < 0.0) then
        variable_scans_negativeB = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "(Science)Short Range Sensors Negative")
    end
end

--[[
	Utility functions
--]]
function vectorFromAngle(angle, length)
    return math.cos(angle / 180 * math.pi) * length, math.sin(angle / 180 * math.pi) * length
end

function ifOutsideBox(obj, x1, y1, x2, y2)
	return not ifInsideBox(obj, x1, y1, x2, y2)
end

function ifInsideBox(obj, x1, y1, x2, y2)
	if obj == nil or not obj:isValid() then
		return false
	end
	x, y = obj:getPosition()
	if ((x >= x1 and x <= x2) or (x >= x2 and x <= x1)) and ((y >= y1 and y <= y2) or (y >= y2 and y <= y1)) then
		return true
	end
	return false
end

function ifInsideSphere(obj, x1, y1, r)
	if obj == nil or not obj:isValid() then
		return false
	end
	x, y = obj:getPosition()
	xd, yd = (x1 - x), (y1 - y)
	if math.sqrt(xd * xd + yd * yd) < r then
		return true
	end
	return false
end

function ifOutsideSphere(obj, x1, y1, r)
	if obj == nil or not obj:isValid() then
		return false
	end
	x, y = obj:getPosition()
	xd, yd = (x1 - x), (y1 - y)
	if math.sqrt(xd * xd + yd * yd) < r then
		return false
	end
	return true
end

function ifdocked(obj)
	-- TODO: Only checks the first player ship.
	return getPlayerShip(-1):isDocked(obj)
end

function countFleet(fleetnr)
	count = 0
	if fleet[fleetnr] ~= nil then
		for key, value in pairs(fleet[fleetnr]) do
			if value:isValid() then
				count = count + 1
			end
		end
	end
	return count
end

function distance(obj1, obj2)
	x1, y1 = obj1:getPosition()
	x2, y2 = obj2:getPosition()
	xd, yd = (x1 - x2), (y1 - y2)
	return math.sqrt(xd * xd + yd * yd)
end
