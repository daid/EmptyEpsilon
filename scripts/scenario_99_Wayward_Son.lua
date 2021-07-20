-- Name: Wayward Son
-- Description: Converted Artemis mission

function init()
    timers = {}
    fleet = {}
	temp_transmission_object = SpaceStation():setTemplate("Small Station"):setPosition(-1000000, -1000000)
    Nebula():setPosition(-73690.0, -21690.0)
    Nebula():setPosition(-21379.0, -21923.0)
    Nebula():setPosition(14737.0, -22039.0)
    Nebula():setPosition(7747.0, -22389.0)
    Nebula():setPosition(-4253.0, -21690.0)
    Nebula():setPosition(-17068.0, -22971.0)
    Nebula():setPosition(-22777.0, -22272.0)
    Nebula():setPosition(-26039.0, -22971.0)
    Nebula():setPosition(-30350.0, -24369.0)
    Nebula():setPosition(-35942.0, -23088.0)
    Nebula():setPosition(-40020.0, -23088.0)
    Nebula():setPosition(-44447.0, -23204.0)
    Nebula():setPosition(-49457.0, -22855.0)
    Nebula():setPosition(-63787.0, -22272.0)
    Nebula():setPosition(-74505.0, -24486.0)
    Nebula():setPosition(-55399.0, -26234.0)
    Nebula():setPosition(-38738.0, -25185.0)
    Nebula():setPosition(-9496.0, -25418.0)
    Nebula():setPosition(-641.0, -25068.0)
    Nebula():setPosition(291.0, -24719.0)
    Nebula():setPosition(-3088.0, -24020.0)
    Nebula():setPosition(17766.0, -27399.0)
    Nebula():setPosition(8330.0, -27166.0)
    Nebula():setPosition(4252.0, -26700.0)
    Nebula():setPosition(-2389.0, -26816.0)
    Nebula():setPosition(-7049.0, -27748.0)
    Nebula():setPosition(-11243.0, -27166.0)
    Nebula():setPosition(-15088.0, -26234.0)
    Nebula():setPosition(-24525.0, -26816.0)
    Nebula():setPosition(-28952.0, -27282.0)
    Nebula():setPosition(-38389.0, -26467.0)
    Nebula():setPosition(-72292.0, -28098.0)
    Nebula():setPosition(-74738.0, -28331.0)
    Nebula():setPosition(-77301.0, -29962.0)
    Nebula():setPosition(-73573.0, -31127.0)
    Nebula():setPosition(-60641.0, -29729.0)
    Nebula():setPosition(-55748.0, -30428.0)
    Nebula():setPosition(-50272.0, -30777.0)
    Nebula():setPosition(-49107.0, -29729.0)
    Nebula():setPosition(-49107.0, -28214.0)
    Nebula():setPosition(-45263.0, -29146.0)
    Nebula():setPosition(-43865.0, -31243.0)
    Nebula():setPosition(-38738.0, -29030.0)
    Nebula():setPosition(-38622.0, -28331.0)
    Nebula():setPosition(-41418.0, -30195.0)
    Nebula():setPosition(-36641.0, -31127.0)
    Nebula():setPosition(-34311.0, -27515.0)
    Nebula():setPosition(-35360.0, -28447.0)
    Nebula():setPosition(-34894.0, -31243.0)
    Nebula():setPosition(-32913.0, -32758.0)
    Nebula():setPosition(-31865.0, -29030.0)
    Nebula():setPosition(-32913.0, -31942.0)
    Nebula():setPosition(-28719.0, -31010.0)
    Nebula():setPosition(-23127.0, -28564.0)
    Nebula():setPosition(-25224.0, -30195.0)
    Nebula():setPosition(-19632.0, -30311.0)
    Nebula():setPosition(-20680.0, -28098.0)
    Nebula():setPosition(-19049.0, -31127.0)
    Nebula():setPosition(-16602.0, -29379.0)
    Nebula():setPosition(-17418.0, -29845.0)
    Nebula():setPosition(-12874.0, -28797.0)
    Nebula():setPosition(-13340.0, -30078.0)
    Nebula():setPosition(-8447.0, -31709.0)
    Nebula():setPosition(-6583.0, -29263.0)
    Nebula():setPosition(-1340.0, -32059.0)
    Nebula():setPosition(-4602.0, -29612.0)
    Nebula():setPosition(-2855.0, -32175.0)
    Nebula():setPosition(407.0, -30894.0)
    Nebula():setPosition(4019.0, -32525.0)
    Nebula():setPosition(3902.0, -29379.0)
    Nebula():setPosition(3553.0, -29379.0)
    Nebula():setPosition(8213.0, -33107.0)
    Nebula():setPosition(9029.0, -31010.0)
    Nebula():setPosition(14621.0, -29845.0)
    Nebula():setPosition(17883.0, -36602.0)
    Nebula():setPosition(17650.0, -30428.0)
    Nebula():setPosition(9262.0, -32641.0)
    Nebula():setPosition(10660.0, -34855.0)
    Nebula():setPosition(14737.0, -36020.0)
    Nebula():setPosition(14271.0, -39981.0)
    Nebula():setPosition(4951.0, -35670.0)
    Nebula():setPosition(407.0, -34855.0)
    Nebula():setPosition(1339.0, -38117.0)
    Nebula():setPosition(9145.0, -37767.0)
    Nebula():setPosition(11592.0, -38583.0)
    Nebula():setPosition(6699.0, -39981.0)
    Nebula():setPosition(1689.0, -38234.0)
    Nebula():setPosition(-1340.0, -38117.0)
    Nebula():setPosition(-7166.0, -34389.0)
    Nebula():setPosition(-12408.0, -35903.0)
    Nebula():setPosition(-16602.0, -36369.0)
    Nebula():setPosition(-20680.0, -35670.0)
    Nebula():setPosition(-28486.0, -38350.0)
    Nebula():setPosition(-33729.0, -37767.0)
    Nebula():setPosition(-50156.0, -36719.0)
    Nebula():setPosition(-61806.0, -37185.0)
    Nebula():setPosition(-72175.0, -38117.0)
    Nebula():setPosition(-76835.0, -38234.0)
    Nebula():setPosition(-78583.0, -37767.0)
    Nebula():setPosition(-79049.0, -35437.0)
    Nebula():setPosition(-78933.0, -34971.0)
    Nebula():setPosition(-79282.0, -39166.0)
    Nebula():setPosition(-74156.0, -35554.0)
    Nebula():setPosition(-71709.0, -34622.0)
    Nebula():setPosition(-68214.0, -35088.0)
    Nebula():setPosition(-67515.0, -38234.0)
    Nebula():setPosition(-70661.0, -38933.0)
    Nebula():setPosition(-75903.0, -39865.0)
    Nebula():setPosition(-69146.0, -37651.0)
    Nebula():setPosition(-67049.0, -35321.0)
    Nebula():setPosition(-62389.0, -35903.0)
    Nebula():setPosition(-61690.0, -36719.0)
    Nebula():setPosition(-66700.0, -33806.0)
    Nebula():setPosition(-65767.0, -33690.0)
    Nebula():setPosition(-58894.0, -33573.0)
    Nebula():setPosition(-57496.0, -36253.0)
    Nebula():setPosition(-52719.0, -38700.0)
    Nebula():setPosition(-52835.0, -34622.0)
    Nebula():setPosition(-53301.0, -35088.0)
    Nebula():setPosition(-62971.0, -38933.0)
    Nebula():setPosition(-51670.0, -34039.0)
    Nebula():setPosition(-48059.0, -34156.0)
    Nebula():setPosition(-46661.0, -39049.0)
    Nebula():setPosition(-45612.0, -38467.0)
    Nebula():setPosition(-45146.0, -33340.0)
    Nebula():setPosition(-46078.0, -31360.0)
    Nebula():setPosition(-44564.0, -37651.0)
    Nebula():setPosition(-43865.0, -38350.0)
    Nebula():setPosition(-42234.0, -34738.0)
    Nebula():setPosition(-41418.0, -34738.0)
    Nebula():setPosition(-35942.0, -35554.0)
    Nebula():setPosition(-40136.0, -39632.0)
    Nebula():setPosition(-38039.0, -36719.0)
    Nebula():setPosition(-30000.0, -34272.0)
    Nebula():setPosition(-26738.0, -35321.0)
    Nebula():setPosition(-32214.0, -36602.0)
    Nebula():setPosition(-38505.0, -35670.0)
    Nebula():setPosition(-44680.0, -36835.0)
    Nebula():setPosition(-41767.0, -38000.0)
    Nebula():setPosition(-21146.0, -32991.0)
    Nebula():setPosition(-24292.0, -34971.0)
    Nebula():setPosition(-20331.0, -35554.0)
    Nebula():setPosition(-14505.0, -32991.0)
    Nebula():setPosition(-15670.0, -34389.0)
    Nebula():setPosition(-18816.0, -34389.0)
    Nebula():setPosition(-22428.0, -38234.0)
    Nebula():setPosition(-15903.0, -38234.0)
    Nebula():setPosition(-7632.0, -37767.0)
    Nebula():setPosition(-9146.0, -36369.0)
    Nebula():setPosition(-14039.0, -38350.0)
    Nebula():setPosition(-10428.0, -38000.0)
    Nebula():setPosition(-6000.0, -37185.0)
    Nebula():setPosition(-3437.0, -35088.0)
    Nebula():setPosition(-1573.0, -37884.0)
    Nebula():setPosition(2970.0, -38000.0)
    Nebula():setPosition(8097.0, -37301.0)
    Nebula():setPosition(15669.0, -37068.0)
    Nebula():setPosition(17883.0, -38933.0)
    Nebula():setPosition(19980.0, -40331.0)
    Nebula():setPosition(10776.0, -38816.0)
    Nebula():setPosition(-3321.0, -39515.0)
    Nebula():setPosition(-10428.0, -40913.0)
    Nebula():setPosition(-21263.0, -40331.0)
    Nebula():setPosition(-26622.0, -39166.0)
    Nebula():setPosition(-30234.0, -40214.0)
    Nebula():setPosition(-37340.0, -39282.0)
    Nebula():setPosition(-39670.0, -40331.0)
    Nebula():setPosition(-49457.0, -40214.0)
    Nebula():setPosition(-57379.0, -39632.0)
    Nebula():setPosition(-62971.0, -39399.0)
    Nebula():setPosition(-69379.0, -40680.0)
    Nebula():setPosition(-75321.0, -41030.0)
    Nebula():setPosition(-77767.0, -40331.0)
    Nebula():setPosition(-61923.0, -40214.0)
    Nebula():setPosition(-43282.0, -39981.0)
    Nebula():setPosition(-29534.0, -41729.0)
    Nebula():setPosition(-20913.0, -39865.0)
    Nebula():setPosition(-33496.0, -41496.0)
    Nebula():setPosition(-37457.0, -41263.0)
    Nebula():setPosition(-33030.0, -41845.0)
    Nebula():setPosition(-17651.0, -42311.0)
    Nebula():setPosition(-15787.0, -42777.0)
    Nebula():setPosition(-17767.0, -41146.0)
    Nebula():setPosition(-7748.0, -42894.0)
    Nebula():setPosition(3436.0, -41496.0)
    Nebula():setPosition(-8797.0, -41263.0)
    Nebula():setPosition(-31166.0, -43709.0)
    Nebula():setPosition(-43515.0, -43942.0)
    Nebula():setPosition(-49340.0, -41845.0)
    Nebula():setPosition(-55166.0, -42777.0)
    Nebula():setPosition(-59476.0, -42195.0)
    Nebula():setPosition(-58661.0, -42428.0)
    Nebula():setPosition(-67981.0, -41146.0)
    Nebula():setPosition(-71593.0, -41612.0)
    Nebula():setPosition(-76136.0, -41845.0)
    Nebula():setPosition(-60991.0, -42777.0)
    Nebula():setPosition(-46894.0, -43593.0)
    Nebula():setPosition(-35942.0, -45690.0)
    Nebula():setPosition(-19049.0, -45690.0)
    Nebula():setPosition(-8913.0, -45573.0)
    Nebula():setPosition(-641.0, -44641.0)
    Nebula():setPosition(6233.0, -46738.0)
    Nebula():setPosition(17184.0, -46156.0)
    Nebula():setPosition(13223.0, -43942.0)
    Nebula():setPosition(4601.0, -43360.0)
    Nebula():setPosition(-874.0, -46389.0)
    Nebula():setPosition(-1340.0, -50350.0)
    Nebula():setPosition(-292.0, -55127.0)
    Nebula():setPosition(2038.0, -60486.0)
    Nebula():setPosition(1572.0, -53263.0)
    Nebula():setPosition(5766.0, -54078.0)
    Nebula():setPosition(9262.0, -60020.0)
    Nebula():setPosition(10776.0, -56641.0)
    Nebula():setPosition(13339.0, -52564.0)
    Nebula():setPosition(14388.0, -49185.0)
    Nebula():setPosition(11009.0, -48369.0)
    Nebula():setPosition(9262.0, -50117.0)
    Nebula():setPosition(8097.0, -52913.0)
    Nebula():setPosition(6000.0, -48952.0)
    Nebula():setPosition(2504.0, -47903.0)
    Nebula():setPosition(4135.0, -49301.0)
    Nebula():setPosition(7165.0, -45806.0)
    Nebula():setPosition(9961.0, -44292.0)
    Nebula():setPosition(12524.0, -41612.0)
    Nebula():setPosition(17417.0, -43942.0)
    Nebula():setPosition(17067.0, -48253.0)
    Nebula():setPosition(16368.0, -53146.0)
    Nebula():setPosition(11941.0, -58389.0)
    Nebula():setPosition(13572.0, -58039.0)
    Nebula():setPosition(16485.0, -53379.0)
    Nebula():setPosition(18349.0, -56292.0)
    Nebula():setPosition(18815.0, -57806.0)
    Nebula():setPosition(19631.0, -48952.0)
    Nebula():setPosition(17067.0, -42195.0)
    Nebula():setPosition(-758.0, -41030.0)
    Nebula():setPosition(-4835.0, -41263.0)
    Nebula():setPosition(-6700.0, -42311.0)
    Nebula():setPosition(-3321.0, -46971.0)
    Nebula():setPosition(1339.0, -54311.0)
    Nebula():setPosition(6000.0, -62583.0)
    Nebula():setPosition(12640.0, -66777.0)
    Nebula():setPosition(15786.0, -71787.0)
    Nebula():setPosition(12058.0, -66544.0)
    Nebula():setPosition(9611.0, -62700.0)
    Nebula():setPosition(12757.0, -61418.0)
    Nebula():setPosition(15786.0, -68408.0)
    Nebula():setPosition(15902.0, -66894.0)
    Nebula():setPosition(16834.0, -61418.0)
    Nebula():setPosition(17067.0, -64331.0)
    Nebula():setPosition(17883.0, -70622.0)
    Nebula():setPosition(18466.0, -68525.0)
    Nebula():setPosition(19048.0, -60719.0)
    Nebula():setPosition(-24175.0, -43127.0)
    Nebula():setPosition(-27787.0, -42078.0)
    Nebula():setPosition(-14971.0, -46389.0)
    Nebula():setPosition(-9379.0, -47903.0)
    Nebula():setPosition(-25224.0, -48020.0)
    Nebula():setPosition(-5534.0, -56408.0)
    Nebula():setPosition(2504.0, -63632.0)
    Nebula():setPosition(-10661.0, -55243.0)
    Nebula():setPosition(-13923.0, -52331.0)
    Nebula():setPosition(11475.0, -71088.0)
    Nebula():setPosition(17883.0, -77146.0)
    Nebula():setPosition(9145.0, -66428.0)
    Nebula():setPosition(-42816.0, -97651.0)
    Nebula():setPosition(-46894.0, -94389.0)
    Nebula():setPosition(-57379.0, -89845.0)
    Nebula():setPosition(-66350.0, -86933.0)
    Nebula():setPosition(-52835.0, -93923.0)
    Nebula():setPosition(-56564.0, -93690.0)
    Nebula():setPosition(-68098.0, -88447.0)
    Nebula():setPosition(-76253.0, -85884.0)
    Nebula():setPosition(-79865.0, -87865.0)
    Nebula():setPosition(-74505.0, -89845.0)
    Nebula():setPosition(-69146.0, -91942.0)
    Nebula():setPosition(-71593.0, -91127.0)
    Nebula():setPosition(-61573.0, -94272.0)
    Nebula():setPosition(-54117.0, -97301.0)
    Nebula():setPosition(-53767.0, -98933.0)
    Nebula():setPosition(-61923.0, -94272.0)
    Nebula():setPosition(-69263.0, -95437.0)
    Nebula():setPosition(-77534.0, -94855.0)
    Nebula():setPosition(-77651.0, -94738.0)
    Nebula():setPosition(-77068.0, -99748.0)
    Nebula():setPosition(-75321.0, -96602.0)
    Nebula():setPosition(-67166.0, -96952.0)
    Nebula():setPosition(-66350.0, -98700.0)
    Nebula():setPosition(-73107.0, -98350.0)
    Nebula():setPosition(-77651.0, -93457.0)
    Nebula():setPosition(-76020.0, -92408.0)
    Nebula():setPosition(-71593.0, -92874.0)
    Nebula():setPosition(-66816.0, -94622.0)
    Nebula():setPosition(-61107.0, -95787.0)
    Nebula():setPosition(-55515.0, -99166.0)
    Nebula():setPosition(-48758.0, -98700.0)
    Nebula():setPosition(-46894.0, -98000.0)
    Nebula():setPosition(-58311.0, -94505.0)
    Nebula():setPosition(-65068.0, -90428.0)
    Nebula():setPosition(-65418.0, -91593.0)
    Nebula():setPosition(-72059.0, -86350.0)
    Nebula():setPosition(-75787.0, -86234.0)
    Nebula():setPosition(-79748.0, -85185.0)
    Nebula():setPosition(-62505.0, -98467.0)
    Nebula():setPosition(-61340.0, -98000.0)
    Asteroid():setPosition(-49806.0, -36369.0)
    Asteroid():setPosition(-62738.0, -39515.0)
    Asteroid():setPosition(-77651.0, -37767.0)
    Asteroid():setPosition(-72758.0, -37884.0)
    Asteroid():setPosition(-68680.0, -38117.0)
    Asteroid():setPosition(-69962.0, -36486.0)
    Asteroid():setPosition(-62156.0, -37767.0)
    Asteroid():setPosition(-55049.0, -39399.0)
    Asteroid():setPosition(-44214.0, -41379.0)
    Asteroid():setPosition(-74855.0, -36136.0)
    Asteroid():setPosition(-60758.0, -38117.0)
    Asteroid():setPosition(-52136.0, -39515.0)
    Asteroid():setPosition(-33729.0, -42661.0)
    Asteroid():setPosition(-24525.0, -46039.0)
    Asteroid():setPosition(-37923.0, -41146.0)
    Asteroid():setPosition(-44331.0, -40680.0)
    Asteroid():setPosition(-31748.0, -43243.0)
    Asteroid():setPosition(-18583.0, -47554.0)
    Asteroid():setPosition(-14971.0, -49534.0)
    Asteroid():setPosition(-29534.0, -41612.0)
    Asteroid():setPosition(-40719.0, -39282.0)
    Asteroid():setPosition(-52020.0, -38583.0)
    Asteroid():setPosition(-36059.0, -42311.0)
    Asteroid():setPosition(-20913.0, -46039.0)
    Asteroid():setPosition(-8331.0, -55709.0)
    Asteroid():setPosition(-12991.0, -51282.0)
    Asteroid():setPosition(-30350.0, -44874.0)
    Asteroid():setPosition(-13923.0, -51049.0)
    Asteroid():setPosition(-2622.0, -58272.0)
    Asteroid():setPosition(-9612.0, -53146.0)
    Asteroid():setPosition(5417.0, -62933.0)
    Asteroid():setPosition(13339.0, -68641.0)
    Asteroid():setPosition(14388.0, -70039.0)
    Asteroid():setPosition(4834.0, -61767.0)
    Asteroid():setPosition(15786.0, -69224.0)
    Asteroid():setPosition(19747.0, -72253.0)
    Asteroid():setPosition(11825.0, -65962.0)
    Asteroid():setPosition(5300.0, -61418.0)
    Asteroid():setPosition(-6933.0, -55243.0)
    Asteroid():setPosition(-22661.0, -46738.0)
    Asteroid():setPosition(-55282.0, -37301.0)
    Asteroid():setPosition(-68913.0, -36369.0)
    Asteroid():setPosition(-78933.0, -35903.0)
    Asteroid():setPosition(-80098.0, -35437.0)
    Asteroid():setPosition(-69845.0, -35554.0)
    Asteroid():setPosition(-57146.0, -38000.0)
    Asteroid():setPosition(-43748.0, -39865.0)
    Asteroid():setPosition(-33729.0, -40447.0)
    Asteroid():setPosition(-30000.0, -43593.0)
    Asteroid():setPosition(-25923.0, -45690.0)
    Asteroid():setPosition(-22661.0, -46389.0)
    Asteroid():setPosition(-18467.0, -48020.0)
    Asteroid():setPosition(-13224.0, -51282.0)
    Asteroid():setPosition(-14738.0, -50234.0)
    Asteroid():setPosition(-23709.0, -43709.0)
    Asteroid():setPosition(-21030.0, -44641.0)
    Asteroid():setPosition(-12641.0, -48952.0)
    Asteroid():setPosition(-8447.0, -52680.0)
    Asteroid():setPosition(-11010.0, -50700.0)
    Asteroid():setPosition(-16602.0, -46738.0)
    Asteroid():setPosition(-7748.0, -52447.0)
    Asteroid():setPosition(-2971.0, -56408.0)
    Asteroid():setPosition(2271.0, -59088.0)
    Asteroid():setPosition(8912.0, -62467.0)
    Asteroid():setPosition(12524.0, -64447.0)
    Asteroid():setPosition(8330.0, -61301.0)
    Asteroid():setPosition(8213.0, -61185.0)
    Asteroid():setPosition(11242.0, -63981.0)
    Asteroid():setPosition(-8680.0, -51748.0)
    Asteroid():setPosition(-58544.0, -36835.0)
    Asteroid():setPosition(-66933.0, -36835.0)
    Asteroid():setPosition(-71593.0, -36835.0)
    Asteroid():setPosition(-75903.0, -37068.0)
    Asteroid():setPosition(-28253.0, -45690.0)
    Asteroid():setPosition(-23593.0, -46855.0)
    Asteroid():setPosition(-17185.0, -49418.0)
    Asteroid():setPosition(-24874.0, -44874.0)
    Asteroid():setPosition(-6000.0, -53379.0)
    Asteroid():setPosition(-408.0, -55826.0)
    Asteroid():setPosition(-79049.0, -95670.0)
    Asteroid():setPosition(-73340.0, -96486.0)
    Asteroid():setPosition(-71127.0, -98234.0)
    Asteroid():setPosition(-76952.0, -95554.0)
    Asteroid():setPosition(-78000.0, -95670.0)
    Asteroid():setPosition(-76136.0, -97534.0)
    Asteroid():setPosition(-76020.0, -98117.0)
    Asteroid():setPosition(-79748.0, -93573.0)
    Asteroid():setPosition(-75321.0, -94738.0)
    Asteroid():setPosition(-73923.0, -98234.0)
    Asteroid():setPosition(-77418.0, -98467.0)
    Asteroid():setPosition(-77651.0, -95903.0)
    Asteroid():setPosition(-78816.0, -91360.0)
    Asteroid():setPosition(-77884.0, -92525.0)
    tmp_count = 35
    for tmp_counter=1,tmp_count do
        tmp_x = -79166.0 + (-39070.0 - -79166.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -40797.0 + (-40797.0 - -40797.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 35
    for tmp_counter=1,tmp_count do
        tmp_x = -79166.0 + (-39070.0 - -79166.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -40797.0 + (-40797.0 - -40797.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 35
    for tmp_counter=1,tmp_count do
        tmp_x = -79166.0 + (-39070.0 - -79166.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -40797.0 + (-40797.0 - -40797.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 35
    for tmp_counter=1,tmp_count do
        tmp_x = -38622.0 + (-3903.0 - -38622.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -41962.0 + (-59554.0 - -41962.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 35
    for tmp_counter=1,tmp_count do
        tmp_x = -38622.0 + (-3903.0 - -38622.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -41962.0 + (-59554.0 - -41962.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 35
    for tmp_counter=1,tmp_count do
        tmp_x = -38622.0 + (-3903.0 - -38622.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -41962.0 + (-59554.0 - -41962.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 17
    for tmp_counter=1,tmp_count do
        tmp_x = 4252.0 + (19165.0 - 4252.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -63748.0 + (-72719.0 - -63748.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 17
    for tmp_counter=1,tmp_count do
        tmp_x = 4252.0 + (19165.0 - 4252.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -63748.0 + (-72719.0 - -63748.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 17
    for tmp_counter=1,tmp_count do
        tmp_x = 4252.0 + (19165.0 - 4252.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -63748.0 + (-72719.0 - -63748.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 60
    for tmp_counter=1,tmp_count do
        tmp_x, tmp_y = vectorFromAngle(-90.0 + (270.0 - -90.0) * (tmp_counter - 1) / tmp_count, 5000.0)
        tmp_x, tmp_y = tmp_x + -64835.0, tmp_y + -95552.0
        Mine():setPosition(tmp_x, tmp_y)
    end
    Asteroid():setPosition(-56098.0, -64797.0)
    Asteroid():setPosition(-57379.0, -62933.0)
    Asteroid():setPosition(-62738.0, -62583.0)
    Asteroid():setPosition(-61806.0, -61185.0)
    Asteroid():setPosition(-63787.0, -60253.0)
    Asteroid():setPosition(-70777.0, -59088.0)
    Asteroid():setPosition(-70428.0, -60369.0)
    Asteroid():setPosition(-77884.0, -62700.0)
    Asteroid():setPosition(-79049.0, -63865.0)
    Asteroid():setPosition(-73806.0, -61884.0)
    Asteroid():setPosition(-73107.0, -60719.0)
    Asteroid():setPosition(-78467.0, -59554.0)
    Asteroid():setPosition(-79515.0, -60719.0)
    Asteroid():setPosition(-55049.0, -64331.0)
    Asteroid():setPosition(-52719.0, -68175.0)
    Asteroid():setPosition(-48292.0, -73418.0)
    Asteroid():setPosition(-42583.0, -77263.0)
    Asteroid():setPosition(-52486.0, -67010.0)
    Asteroid():setPosition(-47243.0, -72952.0)
    Asteroid():setPosition(-41651.0, -77496.0)
    Asteroid():setPosition(-38272.0, -78661.0)
    Asteroid():setPosition(-30583.0, -81923.0)
    Asteroid():setPosition(-22195.0, -82855.0)
    Asteroid():setPosition(-36408.0, -79010.0)
    Asteroid():setPosition(-31282.0, -81107.0)
    Asteroid():setPosition(-25340.0, -82039.0)
    Asteroid():setPosition(-19865.0, -82971.0)
    Asteroid():setPosition(-10311.0, -82971.0)
    Asteroid():setPosition(-2855.0, -84952.0)
    Asteroid():setPosition(-6467.0, -84952.0)
    Asteroid():setPosition(-1107.0, -85651.0)
    Asteroid():setPosition(4019.0, -89263.0)
    Asteroid():setPosition(8563.0, -93573.0)
    Asteroid():setPosition(-43981.0, -74700.0)
    Asteroid():setPosition(-49690.0, -70855.0)
    Asteroid():setPosition(-51903.0, -69224.0)
    Asteroid():setPosition(-53301.0, -64913.0)
    Asteroid():setPosition(-60175.0, -61534.0)
    Asteroid():setPosition(-66583.0, -57690.0)
    Asteroid():setPosition(-69379.0, -57224.0)
    Asteroid():setPosition(-34428.0, -78078.0)
    Asteroid():setPosition(-29767.0, -79826.0)
    Asteroid():setPosition(-24292.0, -80525.0)
    Asteroid():setPosition(-18583.0, -80991.0)
    Asteroid():setPosition(-12408.0, -81224.0)
    Asteroid():setPosition(-874.0, -82855.0)
    Asteroid():setPosition(2970.0, -85767.0)
    Asteroid():setPosition(6349.0, -88564.0)
    Asteroid():setPosition(10194.0, -92874.0)
    Asteroid():setPosition(13339.0, -96020.0)
    Asteroid():setPosition(14621.0, -97767.0)
    Asteroid():setPosition(7281.0, -91243.0)
    Asteroid():setPosition(2970.0, -89496.0)
    Asteroid():setPosition(-2156.0, -87399.0)
    Asteroid():setPosition(8796.0, -96835.0)
    Asteroid():setPosition(11126.0, -99049.0)
    Asteroid():setPosition(-59360.0, -60136.0)
    Asteroid():setPosition(-63321.0, -58156.0)
    Asteroid():setPosition(-59243.0, -59554.0)
    Asteroid():setPosition(-74855.0, -59787.0)
    Asteroid():setPosition(-78350.0, -62467.0)
    Asteroid():setPosition(-14389.0, -81340.0)
    Asteroid():setPosition(-16602.0, -81573.0)
    Asteroid():setPosition(11126.0, -96486.0)
    Asteroid():setPosition(14155.0, -97418.0)
    Asteroid():setPosition(16834.0, -99515.0)
    Asteroid():setPosition(17417.0, -99515.0)
    Asteroid():setPosition(13456.0, -98933.0)
    Nebula():setPosition(-12175.0, -85884.0)
    Nebula():setPosition(-6816.0, -86933.0)
    Nebula():setPosition(-3903.0, -85767.0)
    Nebula():setPosition(-175.0, -86583.0)
    Nebula():setPosition(3436.0, -90195.0)
    Nebula():setPosition(3203.0, -88447.0)
    Nebula():setPosition(-4369.0, -83321.0)
    Nebula():setPosition(8679.0, -89962.0)
    Nebula():setPosition(15320.0, -97301.0)
    Nebula():setPosition(11475.0, -94389.0)
    Nebula():setPosition(-5185.0, -88098.0)
    Nebula():setPosition(-2039.0, -89379.0)
    Nebula():setPosition(-3670.0, -90428.0)
    Nebula():setPosition(-8797.0, -91360.0)
    Nebula():setPosition(-4020.0, -91360.0)
    Nebula():setPosition(-2272.0, -88331.0)
    Nebula():setPosition(-5651.0, -86700.0)
    Nebula():setPosition(-7515.0, -89379.0)
    Nebula():setPosition(-9496.0, -91360.0)
    Nebula():setPosition(-6234.0, -95321.0)
    Nebula():setPosition(-5185.0, -97651.0)
    Nebula():setPosition(-10195.0, -98000.0)
    Nebula():setPosition(-8447.0, -98000.0)
    Nebula():setPosition(-1923.0, -95437.0)
    Nebula():setPosition(-59.0, -93690.0)
    Nebula():setPosition(2970.0, -97185.0)
    Nebula():setPosition(-12408.0, -95204.0)
    Nebula():setPosition(-18467.0, -98117.0)
    Nebula():setPosition(-24758.0, -98583.0)
    Nebula():setPosition(-15554.0, -99049.0)
    Nebula():setPosition(-77884.0, -81806.0)
    Nebula():setPosition(-78816.0, -77845.0)
    Nebula():setPosition(-79515.0, -76680.0)
    Asteroid():setPosition(14388.0, -27399.0)
    Asteroid():setPosition(16601.0, -29030.0)
    Asteroid():setPosition(13689.0, -21573.0)
    Asteroid():setPosition(14271.0, -22505.0)
    Asteroid():setPosition(16601.0, -31942.0)
    Asteroid():setPosition(18582.0, -36136.0)
    Asteroid():setPosition(13106.0, -19010.0)
    Asteroid():setPosition(15320.0, -8175.0)
    Asteroid():setPosition(15436.0, -13185.0)
    Asteroid():setPosition(16834.0, -21224.0)
    Asteroid():setPosition(17533.0, -23903.0)
    Asteroid():setPosition(13805.0, -7826.0)
    Asteroid():setPosition(7631.0, -719.0)
    Asteroid():setPosition(11825.0, -4214.0)
    Asteroid():setPosition(13106.0, -8874.0)
    Asteroid():setPosition(13805.0, -12253.0)
    Asteroid():setPosition(12990.0, -13185.0)
    Asteroid():setPosition(15553.0, -24719.0)
    Asteroid():setPosition(3553.0, -1767.0)
    Asteroid():setPosition(11242.0, -4680.0)
    Asteroid():setPosition(10660.0, -5729.0)
    Asteroid():setPosition(7281.0, -3399.0)
    Asteroid():setPosition(10893.0, -8292.0)
    Asteroid():setPosition(15553.0, -15865.0)
    Asteroid():setPosition(15902.0, -17379.0)
    Asteroid():setPosition(18699.0, -32292.0)
    Nebula():setPosition(-76136.0, -18311.0)
    Nebula():setPosition(-78467.0, -18544.0)
    Nebula():setPosition(-79981.0, -14117.0)
    Nebula():setPosition(-77534.0, -17030.0)
    Nebula():setPosition(-71593.0, -21107.0)
    Nebula():setPosition(-72641.0, -19127.0)
    Nebula():setPosition(-61457.0, -21457.0)
    Nebula():setPosition(-65068.0, -20758.0)
    Nebula():setPosition(-64253.0, -21107.0)
    Nebula():setPosition(-49690.0, -22156.0)
    Nebula():setPosition(-66816.0, -17146.0)
    Nebula():setPosition(-73573.0, -16098.0)
    Nebula():setPosition(-78234.0, -14700.0)
    Nebula():setPosition(-66467.0, -19010.0)
    Nebula():setPosition(-73690.0, -15166.0)
    Nebula():setPosition(-40486.0, -42777.0)
    Nebula():setPosition(-36641.0, -44991.0)
    Nebula():setPosition(-40253.0, -43243.0)
    Nebula():setPosition(-31632.0, -45806.0)
    Nebula():setPosition(-28020.0, -47670.0)
    Nebula():setPosition(-50156.0, -21224.0)
    Nebula():setPosition(-55515.0, -20641.0)
    Nebula():setPosition(-60874.0, -19243.0)
    Nebula():setPosition(-54933.0, -21573.0)
    Nebula():setPosition(-56913.0, -19942.0)
    Nebula():setPosition(-63787.0, -18428.0)
    Nebula():setPosition(-68447.0, -16797.0)
    Nebula():setPosition(-71942.0, -16331.0)
    Nebula():setPosition(-72292.0, -17729.0)
    Nebula():setPosition(-76835.0, -14117.0)
    Nebula():setPosition(-78467.0, -11437.0)
    Nebula():setPosition(-80331.0, -8059.0)
    Nebula():setPosition(-77884.0, -11787.0)
    Nebula():setPosition(-79049.0, -4680.0)
    Nebula():setPosition(-77068.0, -8991.0)
    Nebula():setPosition(-74389.0, -12602.0)
    Nebula():setPosition(-72408.0, -13534.0)
    Nebula():setPosition(15553.0, -74234.0)
    Nebula():setPosition(18699.0, -76214.0)
    Nebula():setPosition(19398.0, -78894.0)
    Nebula():setPosition(18582.0, -78894.0)
    Nebula():setPosition(16019.0, -74234.0)
    Nebula():setPosition(18233.0, -75399.0)
    Nebula():setPosition(17417.0, -73767.0)
    Nebula():setPosition(17766.0, -70622.0)
    Nebula():setPosition(18582.0, -71437.0)
    Nebula():setPosition(18000.0, -70622.0)
    Nebula():setPosition(16135.0, -64564.0)
    Nebula():setPosition(18582.0, -67593.0)
    Nebula():setPosition(17766.0, -63049.0)
    Nebula():setPosition(19048.0, -64913.0)
    Artemis = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Player Cruiser"):setCallSign("Artemis"):setPosition(-29767.0, -1651.0)
    Explorer_9 = CpuShip():setTemplate("Tug"):setCallSign("Explorer 9"):setFaction("Independent"):setPosition(-64835.0, -95554.0):orderRoaming()
    S_502 = CpuShip():setTemplate("Cruiser"):setCallSign("S 502"):setFaction("Kraylor"):setPosition(17184.0, -76680.0):orderRoaming()
    if fleet[2] == nil then fleet[2] = {} end
    table.insert(fleet[2], S_502)
    if fleet[0] == nil then fleet[0] = {} end
    table.insert(fleet[0], S_502)
    S_500 = CpuShip():setTemplate("Cruiser"):setCallSign("S 500"):setFaction("Kraylor"):setPosition(12757.0, -74000.0):orderRoaming()
    table.insert(fleet[2], S_500)
    table.insert(fleet[0], S_500)
    S_508 = CpuShip():setTemplate("Cruiser"):setCallSign("S 508"):setFaction("Kraylor"):setPosition(-74156.0, -88680.0):orderRoaming()
    table.insert(fleet[0], S_508)
    S_509 = CpuShip():setTemplate("Cruiser"):setCallSign("S 509"):setFaction("Kraylor"):setPosition(-74505.0, -87282.0):orderRoaming()
    table.insert(fleet[0], S_509)
    S_200 = CpuShip():setTemplate("Cruiser"):setCallSign("S 200"):setFaction("Kraylor"):setPosition(-78816.0, -47903.0):orderRoaming()
    table.insert(fleet[0], S_200)
    S_220 = CpuShip():setTemplate("Cruiser"):setCallSign("S 220"):setFaction("Kraylor"):setPosition(-77651.0, -46971.0):orderRoaming()
    table.insert(fleet[0], S_220)
    S_411 = CpuShip():setTemplate("Cruiser"):setCallSign("S 411"):setFaction("Kraylor"):setPosition(8912.0, -69457.0):orderRoaming()
    table.insert(fleet[0], S_411)
    S_412 = CpuShip():setTemplate("Cruiser"):setCallSign("S 412"):setFaction("Kraylor"):setPosition(-9263.0, -60719.0):orderRoaming()
    table.insert(fleet[0], S_412)
    S_425 = CpuShip():setTemplate("Cruiser"):setCallSign("S 425"):setFaction("Kraylor"):setPosition(4485.0, -72136.0):orderRoaming()
    table.insert(fleet[0], S_425)
    S_427 = CpuShip():setTemplate("Cruiser"):setCallSign("S 427"):setFaction("Kraylor"):setPosition(-12175.0, -64797.0):orderRoaming()
    table.insert(fleet[0], S_427)
    S_429 = CpuShip():setTemplate("Cruiser"):setCallSign("S 429"):setFaction("Kraylor"):setPosition(3087.0, -67360.0):orderRoaming()
    table.insert(fleet[0], S_429)
    S_717 = CpuShip():setTemplate("Cruiser"):setCallSign("S 717"):setFaction("Kraylor"):setPosition(-64952.0, -85884.0):orderRoaming()
    table.insert(fleet[0], S_717)
    S_718 = CpuShip():setTemplate("Cruiser"):setCallSign("S 718"):setFaction("Kraylor"):setPosition(-49573.0, -94971.0):orderRoaming()
    table.insert(fleet[0], S_718)
    D3_267 = SupplyDrop():setFaction("Human Navy"):setPosition(-36758.0, -29146.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
    D1_355 = SupplyDrop():setFaction("Human Navy"):setPosition(-71127.0, -35554.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
    A5_20 = SupplyDrop():setFaction("Human Navy"):setPosition(12407.0, -97418.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
    S_507 = CpuShip():setTemplate("Cruiser"):setCallSign("S 507"):setFaction("Kraylor"):setPosition(-72353.0, -86433.0):orderRoaming()
    table.insert(fleet[0], S_507)
    B_1_290 = SupplyDrop():setFaction("Human Navy"):setPosition(-71586.0, -73325.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
    globalMessage("\nHold position\n");
    timers["start_mission_timer_1"] = 10.000000
    Artemis:addCustomMessage("helmsOfficer", "warning", "Hold Position")
    timers["object_1st_mssg"] = 12.000000
    timers["sensor_mssgAA"] = 10.000000
    variable_chapter_1 = 1.0
end

function update(delta)
    for key, value in pairs(timers) do
        timers[key] = timers[key] - delta
    end
    if (timers["sensor_mssgAA"] ~= nil and timers["sensor_mssgAA"] < 0.0) and variable_sensor_mssgAA == (0.0) then
        variable_sensor_mssgAA = 1.0
        globalMessage("\nRecommend Minimal Sensors\n");
    end
    if ifInsideBox(Artemis, 19450.0, -4946.0, -79781.0, -4286.0) and variable_titleA ~= (1.0) then
        globalMessage("Wayward Son\n\n");
        variable_titleA = 1.0
        timers["titleB"] = 9.000000
    end
    if (timers["titleB"] ~= nil and timers["titleB"] < 0.0) and variable_titleB ~= (1.0) then
        globalMessage("\nby FutileChas\n");
        variable_titleB = 1.0
        timers["titleC"] = 0.000000
    end
    if (timers["object_1st_mssg"] ~= nil and timers["object_1st_mssg"] < 0.0) and variable_Deep_Space_Command ~= (1.0) then
        temp_transmission_object:setCallSign("Deep Space Command"):sendCommsMessage(getPlayerShip(-1), "Artemis, this is Deep Space Command.  The Skaraans have taken the scout vessel \" Explorer 9\" prisoner and are holding her in a Skaraan stronghold.  Explorer 9 has sent a low power signal pinpointing her position and enemy patrols nearby.  The Skaraan are holding the Explorer 9 until a convoy arrives to escort her to their home world.  Command has decided to attempt a rescue before their reenforcements arrive.   Get within 10 kilometers of the Explorer and assist her escape.   We have plotted a course into the enemy camp, follow the course exactly to penetrate and escape the compound safely...")
        variable_Deep_Space_Command = 1.0
        timers["object_2nd_deep_space_command_msg_w___heading"] = 35.000000
    end
    if (timers["object_2nd_deep_space_command_msg_w___heading"] ~= nil and timers["object_2nd_deep_space_command_msg_w___heading"] < 0.0) and variable_deep_space_command_heading ~= (1.0) then
        variable_deep_space_command_heading = 1.0
        temp_transmission_object:setCallSign("Deep Space Command"):sendCommsMessage(getPlayerShip(-1), "WARNING!!! We think there are hidden mines in the nebula. The Skaraans use a particular flight path entering the compound.  We feel your best chance for success is through the entrance using these coordinates from your starting point:  Heading 000, distance 19 K. Turn to heading 090, distance 30 K.  Turn to heading 000. This should get you to the main gate. The Skaraans are no doubt expecting a rescue attempt. Be ready for anything.  Good luck Artemis, Command out.")
    end
    if ifInsideSphere(Explorer_9, -64835.0, -95554.0, 1000.000000) then
        if Explorer_9 ~= nil and Explorer_9:isValid() then
            Explorer_9:orderFlyTowards(-64835.0, -95554.0)
        end
    end
    if ifInsideSphere(S_200, -78816.0, -47903.0, 3000.000000) then
        if S_200 ~= nil and S_200:isValid() then
            S_200:orderFlyTowards(-78816.0, -43010.0)
        end
    end
    if ifInsideSphere(S_200, -78816.0, -43010.0, 3000.000000) then
        if S_200 ~= nil and S_200:isValid() then
            S_200:orderFlyTowards(-40719.0, -43942.0)
        end
    end
    if ifInsideSphere(S_200, -40719.0, -43942.0, 3000.000000) then
        if S_200 ~= nil and S_200:isValid() then
            S_200:orderFlyTowards(-15088.0, -56175.0)
        end
    end
    if ifInsideSphere(S_200, -15088.0, -56175.0, 3000.000000) then
        if S_200 ~= nil and S_200:isValid() then
            S_200:orderFlyTowards(-17884.0, -61418.0)
        end
    end
    if ifInsideSphere(S_200, -15088.0, -61418.0, 3000.000000) then
        if S_200 ~= nil and S_200:isValid() then
            S_200:orderFlyTowards(-41068.0, -95000.0)
        end
    end
    if ifInsideSphere(S_200, -41068.0, -95000.0, 3000.000000) then
        if S_200 ~= nil and S_200:isValid() then
            S_200:orderFlyTowards(-78816.0, -47903.0)
        end
    end
    if ifInsideSphere(S_220, -78000.0, -46622.0, 3000.000000) then
        if S_220 ~= nil and S_220:isValid() then
            S_220:orderFlyTowards(-78816.0, -43010.0)
        end
    end
    if ifInsideSphere(S_220, -78117.0, -43593.0, 3000.000000) then
        if S_220 ~= nil and S_220:isValid() then
            S_220:orderFlyTowards(-64020.0, -43593.0)
        end
    end
    if ifInsideSphere(S_220, -64020.0, -43593.0, 3000.000000) then
        if S_220 ~= nil and S_220:isValid() then
            S_220:orderFlyTowards(-41534.0, -43593.0)
        end
    end
    if ifInsideSphere(S_220, -41534.0, -43593.0, 3000.000000) then
        if S_220 ~= nil and S_220:isValid() then
            S_220:orderFlyTowards(-17651.0, -55360.0)
        end
    end
    if ifInsideSphere(S_220, -17651.0, -55360.0, 3000.000000) then
        if S_220 ~= nil and S_220:isValid() then
            S_220:orderFlyTowards(-19748.0, -59787.0)
        end
    end
    if ifInsideSphere(S_220, -41068.0, -48486.0, 3000.000000) then
        if S_220 ~= nil and S_220:isValid() then
            S_220:orderFlyTowards(-78000.0, -46622.0)
        end
    end
    if ifInsideSphere(S_220, -19748.0, -59787.0, 3000.000000) then
        if S_220 ~= nil and S_220:isValid() then
            S_220:orderFlyTowards(-41068.0, -48486.0)
        end
    end
    if ifInsideSphere(S_411, 8912.0, -69457.0, 8000.000000) then
        if S_411 ~= nil and S_411:isValid() then
            S_411:orderFlyTowards(-9612.0, -59321.0)
        end
    end
    if ifInsideSphere(S_411, -9612.0, -59321.0, 3000.000000) then
        if S_411 ~= nil and S_411:isValid() then
            S_411:orderFlyTowards(8912.0, -69457.0)
        end
    end
    if ifInsideSphere(S_412, -9612.0, -60369.0, 3000.000000) then
        if S_412 ~= nil and S_412:isValid() then
            S_412:orderFlyTowards(4485.0, -68292.0)
        end
    end
    if ifInsideSphere(S_412, -9612.0, -60369.0, 3000.000000) then
        if S_412 ~= nil and S_412:isValid() then
            S_412:orderFlyTowards(4485.0, -68292.0)
        end
    end
    if ifInsideSphere(S_425, 4485.0, -72136.0, 3000.000000) then
        if S_425 ~= nil and S_425:isValid() then
            S_425:orderFlyTowards(-5651.0, -73767.0)
        end
    end
    if ifInsideSphere(S_425, -5651.0, -73767.0, 3000.000000) then
        if S_425 ~= nil and S_425:isValid() then
            S_425:orderFlyTowards(-8331.0, -61651.0)
        end
    end
    if ifInsideSphere(S_425, -8331.0, -61651.0, 3000.000000) then
        if S_425 ~= nil and S_425:isValid() then
            S_425:orderFlyTowards(4485.0, -72136.0)
        end
    end
    if ifInsideSphere(S_427, -12175.0, -64797.0, 4000.000000) then
        if S_427 ~= nil and S_427:isValid() then
            S_427:orderFlyTowards(2038.0, -65030.0)
        end
    end
    if ifInsideSphere(S_427, 2038.0, -65030.0, 3000.000000) then
        if S_427 ~= nil and S_427:isValid() then
            S_427:orderFlyTowards(-12175.0, -64797.0)
        end
    end
    if ifInsideSphere(S_429, 2737.0, -65962.0, 3000.000000) then
        if S_429 ~= nil and S_429:isValid() then
            S_429:orderFlyTowards(-11826.0, -65962.0)
        end
    end
    if ifInsideSphere(S_429, -11826.0, -65962.0, 3000.000000) then
        if S_429 ~= nil and S_429:isValid() then
            S_429:orderFlyTowards(3087.0, -67360.0)
        end
    end
    if ifInsideSphere(S_717, -65185.0, -84369.0, 3000.000000) then
        if S_717 ~= nil and S_717:isValid() then
            S_717:orderFlyTowards(-49573.0, -96020.0)
        end
    end
    if ifInsideSphere(S_717, -49573.0, -96020.0, 3000.000000) then
        if S_717 ~= nil and S_717:isValid() then
            S_717:orderFlyTowards(-65185.0, -84369.0)
        end
    end
    if ifInsideSphere(S_718, -49573.0, -94971.0, 3000.000000) then
        if S_718 ~= nil and S_718:isValid() then
            S_718:orderFlyTowards(-63088.0, -84835.0)
        end
    end
    if ifInsideSphere(S_718, -63088.0, -84835.0, 3000.000000) then
        if S_718 ~= nil and S_718:isValid() then
            S_718:orderFlyTowards(-49573.0, -94971.0)
        end
    end
    if (timers["msg"] ~= nil and timers["msg"] < 0.0) and variable_S_507_chase_artemis ~= (1.0) then
        variable_S_507_chase_artemis = 1.0
    end
    if ifInsideSphere(S_507, -72353.0, -86433.0, 2000.000000) and variable_object_507_group_attackA == (0.0) then
        variable_object_507_group_attackA = 1.0
        if S_507 ~= nil and S_507:isValid() then
            S_507:orderFlyTowards(-73690.0, -90428.0)
        end
    end
    if (Artemis ~= nil and S_507 ~= nil and Artemis:isValid() and S_507:isValid() and distance(Artemis, S_507) < 8000.000000) then
        variable_S_507_chase_artemis = 1.0
        timers["msg"] = 1.000000
    end
    if (timers["msg"] ~= nil and timers["msg"] < 0.0) and variable_S_508_chase_artemis ~= (1.0) then
        variable_S_508_chase_artemis = 1.0
        local x,y = Artemis:getPosition()
        S_508:orderFlyTorwards(x, y)
    end
    if ifInsideSphere(S_508, -74156.0, -88680.0, 2000.000000) then
        if S_508 ~= nil and S_508:isValid() then
            S_508:orderFlyTowards(-74156.0, -88680.0)
        end
    end
    if ifInsideSphere(S_509, -74505.0, -87282.0, 2000.000000) then
        if S_509 ~= nil and S_509:isValid() then
            S_509:orderFlyTowards(-74505.0, -87282.0)
        end
    end
    if ifInsideBox(Artemis, -23187.0, -99231.0, -79231.0, -65715.0) and variable_move_it ~= (1.0) then
        variable_move_it = 1.0
        if S_509 ~= nil and S_509:isValid() then
            S_509:orderFlyTowards(-5884.0, -61884.0)
        end
    end
    if ifInsideSphere(S_509, -5884.0, -61884.0, 3000.000000) then
        if S_509 ~= nil and S_509:isValid() then
            S_509:orderFlyTowards(990.0, -65030.0)
        end
    end
    if ifInsideSphere(S_509, 990.0, -65030.0, 2000.000000) then
        if S_509 ~= nil and S_509:isValid() then
            S_509:orderFlyTowards(-5884.0, -61884.0)
        end
    end
    if ifInsideSphere(S_500, 12757.0, -74000.0, 2000.000000) and variable_group_500_attackA == (0.0) then
        variable_group_500_attackA = 1.0
        if S_500 ~= nil and S_500:isValid() then
            S_500:orderFlyTowards(12757.0, -74000.0)
        end
    end
    if variable_group_500_attackA == (1.0) and variable_intruder_call_for_help == (1.0) then
        variable_group_500_attackA = 2.0
        S_502:orderAttack(Artemis)
        S_500:orderAttack(Artemis)
        S_501:orderAttack(Artemis)
    end
    if ifInsideSphere(S_500, 12757.0, -74000.0, 2000.000000) and variable_group_500_attackA == (0.0) then
        variable_group_500_attackA = 1.0
        if S_501 ~= nil and S_501:isValid() then
            S_501:orderFlyTowards(14737.0, -75399.0)
        end
    end
    if ifInsideSphere(S_500, 12757.0, -74000.0, 2000.000000) and variable_group_500_attackA == (0.0) then
        variable_group_500_attackA = 1.0
        if S_502 ~= nil and S_502:isValid() then
            S_502:orderFlyTowards(17184.0, -76680.0)
        end
    end
    if ifInsideBox(Artemis, -3517.0, -24286.0, -79231.0, -23957.0) and variable_minefield_1 ~= (1.0) then
        tmp_count = 80
        for tmp_counter=1,tmp_count do
            tmp_x = -79282.0 + (-5418.0 - -79282.0) * (tmp_counter - 1) / tmp_count
            tmp_y = -24020.0 + (-24020.0 - -24020.0) * (tmp_counter - 1) / tmp_count
            Mine():setPosition(tmp_x, tmp_y)
        end
        tmp_count = 60
        for tmp_counter=1,tmp_count do
            tmp_x = -61690.0 + (-5418.0 - -61690.0) * (tmp_counter - 1) / tmp_count
            tmp_y = -25068.0 + (-25068.0 - -25068.0) * (tmp_counter - 1) / tmp_count
            Mine():setPosition(tmp_x, tmp_y)
        end
        variable_minefield_1 = 1.0
    end
    if ifInsideBox(Artemis, -4946.0, -56924.0, -5825.0, -26484.0) and variable_minefield_2 ~= (1.0) then
        tmp_count = 30
        for tmp_counter=1,tmp_count do
            tmp_x = -5767.0 + (-5767.0 - -5767.0) * (tmp_counter - 1) / tmp_count
            tmp_y = -27282.0 + (-55360.0 - -27282.0) * (tmp_counter - 1) / tmp_count
            Mine():setPosition(tmp_x, tmp_y)
        end
        tmp_count = 30
        for tmp_counter=1,tmp_count do
            tmp_x = -5767.0 + (-5767.0 - -5767.0) * (tmp_counter - 1) / tmp_count
            tmp_y = -27282.0 + (-55360.0 - -27282.0) * (tmp_counter - 1) / tmp_count
            Mine():setPosition(tmp_x, tmp_y)
        end
        tmp_count = 29
        for tmp_counter=1,tmp_count do
            tmp_x = -6933.0 + (-6933.0 - -6933.0) * (tmp_counter - 1) / tmp_count
            tmp_y = -27399.0 + (-55360.0 - -27399.0) * (tmp_counter - 1) / tmp_count
            Mine():setPosition(tmp_x, tmp_y)
        end
        variable_minefield_2 = 1.0
    end
    if ifInsideBox(Artemis, 5857.0, -64000.0, 4835.0, -26814.0) and variable_minefield_3 ~= (1.0) then
        tmp_count = 34
        for tmp_counter=1,tmp_count do
            tmp_x = 5184.0 + (5184.0 - 5184.0) * (tmp_counter - 1) / tmp_count
            tmp_y = -27282.0 + (-63245.0 - -27282.0) * (tmp_counter - 1) / tmp_count
            Mine():setPosition(tmp_x, tmp_y)
        end
        tmp_count = 34
        for tmp_counter=1,tmp_count do
            tmp_x = 5184.0 + (5184.0 - 5184.0) * (tmp_counter - 1) / tmp_count
            tmp_y = -27282.0 + (-63245.0 - -27282.0) * (tmp_counter - 1) / tmp_count
            Mine():setPosition(tmp_x, tmp_y)
        end
        tmp_count = 34
        for tmp_counter=1,tmp_count do
            tmp_x = 5184.0 + (5184.0 - 5184.0) * (tmp_counter - 1) / tmp_count
            tmp_y = -27282.0 + (-63245.0 - -27282.0) * (tmp_counter - 1) / tmp_count
            Mine():setPosition(tmp_x, tmp_y)
        end
        variable_minefield_3 = 1.0
    end
    if ifInsideBox(Artemis, 19340.0, -17253.0, -25495.0, -16374.0) and variable_minefield_4 ~= (1.0) then
        variable_minefield_4 = 1.0
        tmp_count = 50
        for tmp_counter=1,tmp_count do
            tmp_x = -26156.0 + (19058.0 - -26156.0) * (tmp_counter - 1) / tmp_count
            tmp_y = -16797.0 + (-16797.0 - -16797.0) * (tmp_counter - 1) / tmp_count
            Mine():setPosition(tmp_x, tmp_y)
        end
        tmp_count = 49
        for tmp_counter=1,tmp_count do
            tmp_x = -25690.0 + (19054.0 - -25690.0) * (tmp_counter - 1) / tmp_count
            tmp_y = -17729.0 + (-17729.0 - -17729.0) * (tmp_counter - 1) / tmp_count
            Mine():setPosition(tmp_x, tmp_y)
        end
    end
    if ifInsideBox(Artemis, 19230.0, -17583.0, -79341.0, -16814.0) and variable_proximity_warning ~= (1.0) then
        variable_proximity_warning = 1.0
        --WARNING: Ignore <warning_popup_message> {} 
        Artemis:addCustomMessage("scienceOfficer", "warning", "(Science)Cloaked Objects Detected!!!")
    end
    if ifInsideSphere(Artemis, -64369.0, -95204.0, 8000.000000) and variable_trigger_escape ~= (1.0) then
        variable_trigger_escape = 1.0
        for _, obj in ipairs(getObjectsInRadius(-62088.0, -91429.0, 1500.000000)) do
            if obj.typeName == "Mine" then obj:destroy() end
        end
        timers["msg"] = 1.000000
        timers["enemy_scramble_1"] = 10.000000
        timers["enemy_scramble_2"] = 18.000000
        if Explorer_9 ~= nil and Explorer_9:isValid() then Explorer_9:destroy() end
        Explorer__9 = CpuShip():setTemplate("Tug"):setCallSign("Explorer  9"):setFaction("Independent"):setPosition(-64835.0, -95335.0):orderRoaming()
        timers["explorer_to_artemis"] = 8.000000
        timers["restore_enginesA"] = 300.000000
    end
    if ifInsideSphere(Artemis, -64369.0, -95204.0, 8700.000000) and variable_escape_popupA ~= (1.0) then
        variable_escape_popupA = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "High energy particles detected")
    end
    if (timers["msg"] ~= nil and timers["msg"] < 0.0) and variable_jail_break ~= (1.0) and ifInsideSphere(Explorer__9, -64835.0, -95335.0, 3000.000000) then
        variable_jail_break = 1.0
        if Explorer__9 ~= nil and Explorer__9:isValid() then
            Explorer__9:orderFlyTowards(-59942.0, -87748.0)
        end
    end
    if ifInsideSphere(Explorer__9, -59942.0, -87748.0, 2000.000000) then
        if Explorer__9 ~= nil and Explorer__9:isValid() then
            Explorer__9:orderFlyTowards(-32528.0, -79011.0)
        end
    end
    if ifInsideSphere(Explorer__9, -32528.0, -79011.0, 2000.000000) then
        if Explorer__9 ~= nil and Explorer__9:isValid() then
            Explorer__9:orderFlyTowards(-15554.0, -74700.0)
        end
    end
    if (timers["restore_enginesA"] ~= nil and timers["restore_enginesA"] < 0.0) and ifInsideBox(Explorer__9, -28352.0, -100000.0, -29671.0, -48462.0) and variable_spawn_in_510A ~= (1.0) then
        variable_spawn_in_510A = 1.0
        timers["explorer_msgA"] = 8.000000
        S_510 = CpuShip():setTemplate("Cruiser"):setCallSign("S 510"):setFaction("Kraylor"):setPosition(-14289.0, -98160.0):orderRoaming()
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], S_510)
        temp_transmission_object:setCallSign("S 510"):sendCommsMessage(getPlayerShip(-1), "S 510 to Fleet.  There are several more ships just a few moments away. Stop the Artemis at all costs.")
        timers["couple_more_shipsA"] = 100.000000
        timers["couple_more_shipsB"] = 110.000000
        timers["couple_more_shipsC"] = 300.000000
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy transmission")
        --WARNING: Unknown AI: S_510: {'CHASE_ANGER': {'type': 'CHASE_ANGER', 'name': 'S 510'}} 
        S_500:orderAttack(Artemis)
        S_501:orderAttack(Explorer__9)
        if Explorer__9 ~= nil and Explorer__9:isValid() then
            Explorer__9:orderFlyTowards(-2738.0, -69340.0)
        end
    end
    if (timers["couple_more_shipsA"] ~= nil and timers["couple_more_shipsA"] < 0.0) and variable_couple_more_shipsA ~= (1.0) then
        variable_couple_more_shipsA = 1.0
        S_77_Elite = CpuShip():setTemplate("Cruiser"):setCallSign("S 77 Elite"):setFaction("Kraylor"):setPosition(1081.0, -89507.0):orderRoaming()
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], S_77_Elite)
        S_78_Elite = CpuShip():setTemplate("Cruiser"):setCallSign("S 78 Elite"):setFaction("Kraylor"):setPosition(284.0, -86889.0):orderRoaming()
        table.insert(fleet[0], S_78_Elite)
        if S_77_Elite ~= nil and S_77_Elite:isValid() then
            S_77_Elite:setJumpDrive(True)
            S_77_Elite:setWarpDrive(True)
        end
        if S_78_Elite ~= nil and S_78_Elite:isValid() then
            S_78_Elite:setJumpDrive(True)
            S_78_Elite:setWarpDrive(True)
        end
        S_78_Elite:orderAttack(Artemis)
        S_77_Elite:orderAttack(Artemis)
    end
    if (timers["couple_more_shipsB"] ~= nil and timers["couple_more_shipsB"] < 0.0) and variable_couple_more_shipsB ~= (1.0) then
        variable_couple_more_shipsB = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Massive enemy fleet detected")
    end
    if ifInsideSphere(Explorer__9, -15554.0, -74700.0, 8000.000000) and variable_give_ai_commandsA ~= (1.0) then
        variable_give_ai_commandsA = 1.0
        S_501:orderAttack(Artemis)
    end
    if (timers["explorer_msgA"] ~= nil and timers["explorer_msgA"] < 0.0) and variable_explorer_msgA ~= (1.0) then
        variable_explorer_msgA = 1.0
        temp_transmission_object:setCallSign("Explorer 9"):sendCommsMessage(getPlayerShip(-1), "Explorer 9 to Artemis, the Explorer is secure. I repeat, the Explorer is secure. Engineering reports auxiliary power is  restored. We\'ve got a bit extra for the Impulse engines but Warp systems are still down.  Explorer, out.")
    end
    if ifInsideSphere(Explorer__9, -2738.0, -69340.0, 2000.000000) then
        if Explorer__9 ~= nil and Explorer__9:isValid() then
            Explorer__9:orderFlyTowards(873.0, -59204.0)
        end
    end
    if ifInsideSphere(Explorer__9, 873.0, -59204.0, 2000.000000) then
        if Explorer__9 ~= nil and Explorer__9:isValid() then
            Explorer__9:orderFlyTowards(1339.0, -20175.0)
        end
    end
    if ifInsideSphere(Explorer__9, 1339.0, -20175.0, 2000.000000) then
        if Explorer__9 ~= nil and Explorer__9:isValid() then
            Explorer__9:orderFlyTowards(-30117.0, -20059.0)
        end
    end
    if ifInsideSphere(Explorer__9, -30117.0, -20059.0, 2000.000000) then
        if Explorer__9 ~= nil and Explorer__9:isValid() then
            Explorer__9:orderFlyTowards(-29884.0, -1884.0)
        end
    end
    if (timers["msg"] ~= nil and timers["msg"] < 0.0) and variable_Explorer_escaping_pop_up ~= (1.0) then
        variable_Explorer_escaping_pop_up = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Explorer is under way")
    end
    if ifInsideBox(Explorer__9, 19120.0, -55165.0, -39821.0, -440.0) and ifInsideBox(Artemis, 19120.0, -55165.0, -10440.0, -440.0) and (timers["msg"] ~= nil and timers["msg"] < 0.0) and (Explorer__9 ~= nil and Explorer__9:isValid()) and variable_success ~= (1.0) then
        variable_success = 1.0
        globalMessage("\n\nArtemis and Explorer have escaped");
        timers["countdown_for_successful_ending"] = 8.000000
    end
    if ifInsideBox(Explorer__9, 19428.0, -19143.0, -80000.0, -858.0) and ifInsideBox(Artemis, 19571.0, -17715.0, -79858.0, -858.0) and (timers["msg"] ~= nil and timers["msg"] < 0.0) and (Explorer__9 ~= nil and Explorer__9:isValid()) and variable_success ~= (1.0) then
        variable_success = 1.0
        globalMessage("\n\nArtemis and Explorer have escaped");
        timers["countdown_for_successful_ending"] = 8.000000
    end
    if ifInsideBox(Explorer__9, 19285.0, -56143.0, -40000.0, -1429.0) and ifInsideBox(Artemis, 19571.0, -17715.0, -79858.0, -858.0) and (timers["msg"] ~= nil and timers["msg"] < 0.0) and (Explorer__9 ~= nil and Explorer__9:isValid()) and variable_success ~= (1.0) then
        variable_success = 1.0
        globalMessage("\n\nArtemis and Explorer have escaped");
        timers["countdown_for_successful_ending"] = 8.000000
    end
    if ifInsideBox(Artemis, 19285.0, -56143.0, -40000.0, -1429.0) and ifInsideBox(Explorer__9, 19571.0, -17715.0, -79858.0, -858.0) and (timers["msg"] ~= nil and timers["msg"] < 0.0) and (Explorer__9 ~= nil and Explorer__9:isValid()) and variable_success ~= (1.0) then
        variable_success = 1.0
        globalMessage("\n\nArtemis and Explorer have escaped");
        timers["countdown_for_successful_ending"] = 8.000000
    end
    if ifInsideBox(Explorer__9, 19230.0, -55385.0, -10440.0, -24506.0) then
        if Explorer__9 ~= nil and Explorer__9:isValid() then
            Explorer__9:orderFlyTowards(109.0, -20660.0)
        end
    end
    if ifInsideBox(Explorer__9, 18791.0, -22308.0, -22088.0, -17583.0) then
        if Explorer__9 ~= nil and Explorer__9:isValid() then
            Explorer__9:orderFlyTowards(-29451.0, -20220.0)
        end
    end
    if ifInsideBox(Artemis, 19340.0, -20770.0, -79451.0, -660.0) and (timers["msg"] ~= nil and timers["msg"] < 0.0) and (Explorer__9 ~= nil and Explorer__9:isValid()) and variable_succesB ~= (1.0) and ifInsideBox(Explorer__9, 19120.0, -55165.0, -10440.0, -440.0) then
        variable_successB = 1.0
        globalMessage("\n\nArtemis and Explorer have escaped");
        timers["countdown_for_successful_ending"] = 8.000000
        if Explorer__9 ~= nil and Explorer__9:isValid() then
            Explorer__9:orderFlyTowards(-110.0, -21429.0)
        end
    end
    if ifInsideBox(Explorer__9, 19010.0, -67143.0, -79891.0, -66704.0) and variable_massiveA ~= (1.0) and (timers["couple_more_shipsA"] ~= nil and timers["couple_more_shipsA"] < 0.0) then
        variable_massiveA = 1.0
        S_566_Elite = CpuShip():setTemplate("Cruiser"):setCallSign("S 566 Elite"):setFaction("Kraylor"):setPosition(17590.0, -87686.0):orderRoaming()
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], S_566_Elite)
        S_567_Elite = CpuShip():setTemplate("Cruiser"):setCallSign("S 567 Elite"):setFaction("Kraylor"):setPosition(17590.0, -81196.0):orderRoaming()
        table.insert(fleet[0], S_567_Elite)
        S_569_Elite = CpuShip():setTemplate("Cruiser"):setCallSign("S 569 Elite"):setFaction("Kraylor"):setPosition(14857.0, -82107.0):orderRoaming()
        table.insert(fleet[0], S_569_Elite)
        S_566_Elite:orderAttack(Explorer__9)
        S_569_Elite:orderAttack(Explorer__9)
    end
    if ifInsideBox(Artemis, 19120.0, -55165.0, -10440.0, -440.0) and ifInsideBox(Explorer__9, 18681.0, -18572.0, -79121.0, -17143.0) and (timers["msg"] ~= nil and timers["msg"] < 0.0) and (Explorer__9 ~= nil and Explorer__9:isValid()) and variable_successA ~= (1.0) then
        variable_successA = 1.0
        globalMessage("\n\nArtemis and Explorer have escaped");
        timers["countdown_for_successful_ending"] = 8.000000
    end
    if (timers["countdown_for_successful_ending"] ~= nil and timers["countdown_for_successful_ending"] < 0.0) and variable_success_endgame ~= (1.0) then
        variable_success_endgame = 1.0
        timers["endingA"] = 0.000000
        timers["endingB"] = 12.000000
        timers["endingC"] = 16.000000
        timers["endingD"] = 22.000000
        timers["endingE"] = 27.000000
        globalMessage("Mission Successful");
    end
    if (timers["endingA"] ~= nil and timers["endingA"] < 0.0) and variable_endingA ~= (1.0) then
        variable_endingA = 1.0
        globalMessage("Artemis\nby Thom Robertson");
    end
    if (timers["endingB"] ~= nil and timers["endingB"] < 0.0) and variable_endingB ~= (1.0) then
        variable_endingB = 1.0
        globalMessage("Music by\nJohn Robert Matz");
    end
    if (timers["endingC"] ~= nil and timers["endingC"] < 0.0) and variable_endingC ~= (1.0) then
        variable_endingC = 1.0
        globalMessage("Thanks also to Hissatsu");
    end
    if (timers["endingD"] ~= nil and timers["endingD"] < 0.0) and variable_endingD ~= (1.0) then
        variable_endingD = 1.0
        globalMessage("Explorer has escaped");
    end
    if (timers["endingE"] ~= nil and timers["endingE"] < 0.0) and variable_endingE ~= (1.0) then
        variable_endingE = 1.0
        victory("Human Navy")
    end
    if ifInsideBox(Explorer__9, 19560.0, -80110.0, -40220.0, -40220.0) and variable_speed_upA ~= (1.0) then
        variable_speed_upA = 1.0
        --WARNING: Ignore <add_ai> {'type': 'DIR_THROTTLE', 'value2': '0.0'} 
    end
    if (timers["enemy_scramble_1"] ~= nil and timers["enemy_scramble_1"] < 0.0) and variable_intercepting_S_507_alert_call ~= (1.0) then
        variable_intercepting_S_507_alert_call = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy transmission")
        timers["S_507_alert_call"] = 4.000000
    end
    if (timers["S_507_alert_call"] ~= nil and timers["S_507_alert_call"] < 0.0) and variable_S_507_to_fleet_call ~= (1.0) then
        variable_S_507_to_fleet_call = 1.0
        temp_transmission_object:setCallSign("S 507"):sendCommsMessage(getPlayerShip(-1), "S 507 to fleet.  The prisoner ship is trying to escape.  All ships intercept and destroy the Explorer.")
    end
    if (Artemis ~= nil and S_508 ~= nil and Artemis:isValid() and S_508:isValid() and distance(Artemis, S_508) <= 6000.000000) and variable_artemis_approach_508 == (0.0) then
        variable_artemis_approach_508 = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy transmission")
        temp_transmission_object:setCallSign("S 508"):sendCommsMessage(getPlayerShip(-1), "508, to Fleet. The Artemis is in our sector. Need assistance!")
        variable_all_ships_attack_explorer = 1.0
    end
    if variable_forget_all_prior_orders ~= (1.0) and (timers["msg"] ~= nil and timers["msg"] < 0.0) and (Explorer__9 == nil or not Explorer__9:isValid()) and (Explorer_9 == nil or not Explorer_9:isValid()) then
        variable_forget_all_prior_orders = 1.0
        timers["forget_all_prior_orders"] = 0.000000
    end
    if variable_all_ships_get_artemis ~= (1.0) and (timers["forget_all_prior_orders"] ~= nil and timers["forget_all_prior_orders"] < 0.0) then
        variable_all_ships_get_artemis = 1.0
    end
    if (Explorer__9 == nil or not Explorer__9:isValid()) and variable_forget_all_prior_orders ~= (1.0) then
        variable_forget_all_prior_orders = 1.0
        timers["forget_all_prior_orders"] = 0.000000
    end
    if (Explorer__9 == nil or not Explorer__9:isValid()) and variable_forget_all_prior_orders ~= (1.0) then
        variable_forget_all_prior_orders = 1.0
        timers["forget_all_prior_orders"] = 0.000000
    end
    if (Explorer__9 == nil or not Explorer__9:isValid()) and variable_forget_all_prior_orders ~= (1.0) then
        variable_forget_all_prior_orders = 1.0
        timers["forget_all_prior_orders"] = 0.000000
    end
    if (Explorer__9 == nil or not Explorer__9:isValid()) and variable_forget_all_prior_orders ~= (1.0) then
        variable_forget_all_prior_orders = 1.0
        timers["forget_all_prior_orders"] = 0.000000
    end
    if (Explorer__9 == nil or not Explorer__9:isValid()) and variable_forget_all_prior_orders ~= (1.0) then
        variable_forget_all_prior_orders = 1.0
        timers["forget_all_prior_orders"] = 0.000000
    end
    if (Explorer__9 == nil or not Explorer__9:isValid()) and variable_forget_all_prior_orders ~= (1.0) then
        variable_forget_all_prior_orders = 1.0
        timers["forget_all_prior_orders"] = 0.000000
    end
    if (Explorer__9 == nil or not Explorer__9:isValid()) and variable_forget_all_prior_orders ~= (1.0) then
        variable_forget_all_prior_orders = 1.0
        timers["forget_all_prior_orders"] = 0.000000
    end
    if ifInsideSphere(Artemis, -11429.0, -99858.0, 40000.000000) and variable_intruder_call_for_help ~= (1.0) then
        timers["All_ships"] = 5.000000
        variable_intruder_call_for_help = 1.0
    end
    if ifInsideSphere(Artemis, -69143.0, -95286.0, 50000.000000) and variable_intruder_call_for_help ~= (1.0) then
        timers["All_ships"] = 5.000000
        variable_intruder_call_for_help = 1.0
    end
    if ifInsideSphere(Artemis, -5825.0, -71319.0, 12000.000000) and variable_intruder_call_for_help ~= (1.0) then
        timers["All_ships"] = 5.000000
        variable_intruder_call_for_help = 1.0
    end
    if (timers["All_ships"] ~= nil and timers["All_ships"] < 0.0) and variable_all_ships_get_the_artemis ~= (1.0) then
        variable_all_ships_get_the_artemis = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy transmission")
        timers["all_ships_get_the_artemis_4_secs"] = 4.000000
    end
    if (timers["all_ships_get_the_artemis_4_secs"] ~= nil and timers["all_ships_get_the_artemis_4_secs"] < 0.0) and variable_all_ships_get_the_artemis_to_comms ~= (1.0) then
        variable_all_ships_get_the_artemis_to_comms = 1.0
        temp_transmission_object:setCallSign("Skaraan Leader"):sendCommsMessage(getPlayerShip(-1), "All Skaraan ships we have an intruder.  Intercept and destroy.")
        timers["spawn_in_another_groupA"] = 60.000000
        variable_group_500_attackA = 1.0
    end
    if (timers["All_ships"] ~= nil and timers["All_ships"] < 0.0) and variable_order_500_and_501 ~= (1.0) then
        variable_order_500_and_501 = 1.0
        if S_500 ~= nil and S_500:isValid() then
            S_500:orderFlyTowards(-3204.0, -64098.0)
        end
    end
    if ifInsideSphere(S_500, -3204.0, -64098.0, 9000.000000) then
        if S_500 ~= nil and S_500:isValid() then
            S_500:orderFlyTowards(1456.0, -66661.0)
        end
    end
    if (timers["All_ships"] ~= nil and timers["All_ships"] < 0.0) and variable_order_500_and_501 ~= (1.0) then
        variable_order_500_and_501 = 1.0
        if S_501 ~= nil and S_501:isValid() then
            S_501:orderFlyTowards(-3204.0, -64098.0)
        end
    end
    if ifInsideSphere(S_501, -3204.0, -64098.0, 7000.000000) then
        if S_500 ~= nil and S_500:isValid() then
            S_500:orderFlyTowards(1456.0, -66661.0)
        end
    end
    if (Artemis == nil or not Artemis:isValid()) and variable_trigger_mission_failed_timer ~= (1.0) then
        variable_trigger_mission_failed_timer = 1.0
        globalMessage("The Artemis has been lost\n\nMission Failed");
        timers["countdown_to_failed_ending"] = 8.000000
    end
    if (timers["countdown_to_failed_ending"] ~= nil and timers["countdown_to_failed_ending"] < 0.0) and variable_failed_ending ~= (1.0) then
        variable_failed_ending = 1.0
        victory("Independent")
    end
    if (timers["S_507_alert_call"] ~= nil and timers["S_507_alert_call"] < 0.0) and variable_all_ships_attack_explorer ~= (1.0) then
        variable_all_ships_attack_explorer = 1.0
        S_220:orderAttack(Artemis)
        S_200:orderAttack(Artemis)
        S_718:orderAttack(Explorer__9)
        S_717:orderAttack(Explorer__9)
        S_427:orderAttack(Artemis)
        S_411:orderAttack(Artemis)
        S_425:orderAttack(Artemis)
        S_508:orderAttack(Artemis)
        S_509:orderAttack(Artemis)
        S_502:orderAttack(Artemis)
        S_429:orderAttack(Artemis)
        S_507:orderAttack(Artemis)
        S_412:orderAttack(Artemis)
    end
    if (timers["explorer_to_artemis"] ~= nil and timers["explorer_to_artemis"] < 0.0) and (Explorer__9 == nil or not Explorer__9:isValid()) and variable_explorer_dead ~= (1.0) and (timers["msg"] ~= nil and timers["msg"] < 0.0) then
        variable_explorer_dead = 1.0
        timers["explorer_dead_ending"] = 7.000000
    end
    if (timers["explorer_dead_ending"] ~= nil and timers["explorer_dead_ending"] < 0.0) and variable_explorer_dead_let_team_escape ~= (1.0) then
        variable_explorer_dead_let_team_escape = 1.0
        globalMessage("Explorer 9 has been lost\n\nEscape to sector E 3");
    end
    if ifInsideBox(Artemis, 19230.0, -50330.0, -79671.0, -12418.0) and variable_ending_but_lost_the_explorer ~= (1.0) and (Explorer__9 == nil or not Explorer__9:isValid()) and (timers["msg"] ~= nil and timers["msg"] < 0.0) then
        variable_ending_but_lost_the_explorer = 1.0
        timers["countdown_to_ending_afer_losing_explorer"] = 6.000000
        globalMessage("The Explorer has been lost\n\n");
    end
    if (timers["countdown_to_ending_afer_losing_explorer"] ~= nil and timers["countdown_to_ending_afer_losing_explorer"] < 0.0) and variable_end_mission_without_success ~= (1.0) then
        variable_end_mission_without_success = 1.0
        victory("Independent")
    end
    if ifInsideBox(Artemis, 18681.0, -43077.0, -79451.0, -42198.0) and variable_crossing_the_line ~= (1.0) then
        variable_crossing_the_line = 1.0
        timers["crossing_the_line"] = 0.000000
    end
    if ifInsideSphere(Artemis, -29671.0, -21099.0, 2000.000000) and variable_turn_marker_pop_up ~= (1.0) then
        variable_turn_marker_pop_up = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "None")
        Artemis:addCustomMessage("helmsOfficer", "warning", "None")
    end
    if ifInsideSphere(Artemis, 879.0, -20220.0, 2000.000000) and variable_turn_marker_pop_up_2 ~= (1.0) then
        variable_turn_marker_pop_up_2 = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "None")
        Artemis:addCustomMessage("helmsOfficer", "warning", "None")
    end
    if ifInsideSphere(Artemis, 989.0, -19891.0, 2000.000000) and (timers["crossing_the_line"] ~= nil and timers["crossing_the_line"] < 0.0) and variable_turn_marker_pop_up_3 ~= (1.0) then
        variable_turn_marker_pop_up_3 = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Turn to heading 270")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Turn to heading 270")
    end
    if (timers["crossing_the_line"] ~= nil and timers["crossing_the_line"] < 0.0) and variable_turn_marker_pop_up_4 ~= (1.0) and ifInsideSphere(Artemis, -29891.0, -19781.0, 2000.000000) then
        variable_turn_marker_pop_up_4 = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Turn to heading 180")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Turn to heading 180")
    end
    if (timers["all_ships_dead_countdown"] ~= nil and timers["all_ships_dead_countdown"] < 0.0) and variable_all_ships_dead_countdown_to_end ~= (1.0) then
        variable_all_ships_dead_countdown_to_end = 1.0
        victory("Independent")
    end
    if countFleet(0) <= 0.000000 and variable_all_ships_dead ~= (1.0) then
        variable_all_ships_dead = 0.0
        globalMessage("All enemy ships have been destroyed\n\n");
        timers["all_ships_dead_countdown"] = 7.000000
    end
    if (timers["msg"] ~= nil and timers["msg"] < 0.0) and variable_spawn_in_S_321 ~= (1.0) then
        variable_spawn_in_S_321 = 1.0
        S_321 = CpuShip():setTemplate("Cruiser"):setCallSign("S 321"):setFaction("Kraylor"):setPosition(4485.0, -59903.0):orderRoaming()
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], S_321)
    end
    if ifInsideSphere(S_321, 4485.0, -59903.0, 2000.000000) then
        --WARNING: Unknown AI: S_321: {'CHASE_NEUTRAL': {'type': 'CHASE_NEUTRAL', 'value2': '10000', 'value1': '15000', 'name': 'S 321'}, 'POINT_THROTTLE': {'value4': '2.0', 'value3': '36135.0', 'name': 'S 321', 'value1': '24369.0', 'type': 'POINT_THROTTLE', 'value2': '0.0'}} 
    end
    if ifInsideSphere(S_321, -4369.0, -63865.0, 2000.000000) then
        --WARNING: Unknown AI: S_321: {'CHASE_NEUTRAL': {'type': 'CHASE_NEUTRAL', 'value2': '10000', 'value1': '15000', 'name': 'S 321'}, 'POINT_THROTTLE': {'value4': '1.0', 'value3': '40097.0', 'name': 'S 321', 'value1': '15515.0', 'type': 'POINT_THROTTLE', 'value2': '0.0'}} 
    end
    if ifInsideSphere(Artemis, -75952.0, -94272.0, 15000.000000) and variable_anomaly_A1_290 ~= (1.0) then
        variable_anomaly_A1_290 = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Anomaly Detected")
    end
    if ifInsideSphere(Artemis, 12407.0, -97418.0, 15000.000000) and variable_anomaly_A5_20 ~= (1.0) then
        variable_anomaly_A5_20 = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Anomaly Detected")
    end
    if ifInsideSphere(Artemis, -71127.0, -35554.0, 15000.000000) and variable_anomaly_D1_355 ~= (1.0) then
        variable_anomaly_D1_355 = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Anomaly Detected")
    end
    if ifInsideSphere(Artemis, -36758.0, -29146.0, 15000.000000) and variable_anomaly_A1_290 ~= (1.0) then
        variable_anomaly_A1_290 = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Anomaly Detected")
    end
    if (D3_267 == nil or not D3_267:isValid()) and variable_booby_trap_spawn_mines ~= (1.0) then
        variable_booby_trap_spawn_mines = 1.0
        tmp_count = 10
        for tmp_counter=1,tmp_count do
            tmp_x, tmp_y = vectorFromAngle(-90.0 + (270.0 - -90.0) * (tmp_counter - 1) / tmp_count, 500.0)
            tmp_x, tmp_y = tmp_x + -36758.0, tmp_y + -29146.0
            Mine():setPosition(tmp_x, tmp_y)
        end
    end
    if ifInsideSphere(Artemis, -36758.0, -29146.0, 6000.000000) and variable_pop_up_warning_for_booby_trap ~= (1.0) then
        variable_pop_up_warning_for_booby_trap = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Caution! Mines Detected")
    end
    if (timers["explorer_to_artemis"] ~= nil and timers["explorer_to_artemis"] < 0.0) and variable_explorer_to_artemis ~= (1.0) then
        variable_explorer_to_artemis = 1.0
        temp_transmission_object:setCallSign("Explorer 9"):sendCommsMessage(getPlayerShip(-1), "Nice to see you Artemis, we were beginning to wonder if we where on our own.  Our vessel is running on minimal power and we are limited to impulse speed.  We are making a run for the main gate.")
        timers["explorer_to_artemisA"] = 18.000000
    end
    if (timers["explorer_to_artemisA"] ~= nil and timers["explorer_to_artemisA"] < 0.0) and variable_explorer_to_artemisA ~= (1.0) then
        variable_explorer_to_artemisA = 1.0
        temp_transmission_object:setCallSign("Explorer 9"):sendCommsMessage(getPlayerShip(-1), "Artemis this is the Explorer, we are trying to gain control of the ship.  We are operating the ship from engineering. We are repairing our systems and we are trying to get auxiliary power on line.  Explorer, out.")
    end
    if ifInsideBox(S_500, 19340.0, -46264.0, -23517.0, -45495.0) then
        if S_500 ~= nil and S_500:isValid() then
            S_500:orderFlyTowards(439.0, -56924.0)
        end
    end
    if ifInsideSphere(S_500, 439.0, -56924.0, 3000.000000) then
        if S_500 ~= nil and S_500:isValid() then
            S_500:orderFlyTowards(-990.0, -64946.0)
        end
    end
    if ifInsideSphere(S_500, -990.0, -64946.0, 3000.000000) then
        if S_500 ~= nil and S_500:isValid() then
            S_500:orderFlyTowards(12757.0, -74000.0)
        end
    end
    if ifInsideBox(S_411, 19450.0, -61209.0, -6924.0, -54506.0) then
        if S_411 ~= nil and S_411:isValid() then
            S_411:orderFlyTowards(439.0, -56924.0)
        end
    end
    if ifInsideSphere(S_411, 439.0, -56924.0, 3000.000000) then
        if S_411 ~= nil and S_411:isValid() then
            S_411:orderFlyTowards(-990.0, -64946.0)
        end
    end
    if ifInsideSphere(S_411, -990.0, -64946.0, 3000.000000) then
        if S_411 ~= nil and S_411:isValid() then
            S_411:orderFlyTowards(8912.0, -69457.0)
        end
    end
    if ifInsideBox(S_427, 18901.0, -59451.0, -56044.0, -51209.0) then
        if S_427 ~= nil and S_427:isValid() then
            S_427:orderFlyTowards(-12175.0, -64797.0)
        end
    end
    if ifInsideBox(S_429, 18901.0, -59451.0, -56044.0, -51209.0) then
        if S_429 ~= nil and S_429:isValid() then
            S_429:orderFlyTowards(3087.0, -67360.0)
        end
    end
    if ifInsideBox(S_425, 18901.0, -59451.0, -56044.0, -51209.0) then
        if S_425 ~= nil and S_425:isValid() then
            S_425:orderFlyTowards(4485.0, -72136.0)
        end
    end
    if ifInsideBox(S_502, 19120.0, -52528.0, -36594.0, -48902.0) then
        if S_502 ~= nil and S_502:isValid() then
            S_502:orderFlyTowards(-59.0, -59670.0)
        end
    end
    if ifInsideSphere(S_502, -59.0, -59670.0, 3000.000000) then
        if S_502 ~= nil and S_502:isValid() then
            S_502:orderFlyTowards(174.0, -69107.0)
        end
    end
    if ifInsideSphere(S_502, 174.0, -69107.0, 3000.000000) then
        if S_502 ~= nil and S_502:isValid() then
            S_502:orderFlyTowards(17184.0, -76680.0)
        end
    end
    if ifInsideBox(S_412, 19230.0, -50660.0, -36924.0, -49781.0) then
        if S_412 ~= nil and S_412:isValid() then
            S_412:orderFlyTowards(-59.0, -59670.0)
        end
    end
    if ifInsideSphere(S_412, -59.0, -59670.0, 3000.000000) then
        if S_502 ~= nil and S_502:isValid() then
            S_502:orderFlyTowards(174.0, -69107.0)
        end
    end
    if ifInsideSphere(S_412, 174.0, -69107.0, 3000.000000) then
        if S_412 ~= nil and S_412:isValid() then
            S_412:orderFlyTowards(-9263.0, -60719.0)
        end
    end
    if (timers["spawn_in_another_groupA"] ~= nil and timers["spawn_in_another_groupA"] < 0.0) and variable_spawn_in_moreA ~= (1.0) then
        K_21 = CpuShip():setTemplate("Cruiser"):setCallSign("K 21"):setFaction("Kraylor"):setPosition(-3473.0, -82676.0):orderRoaming()
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], K_21)
        K_27 = CpuShip():setTemplate("Cruiser"):setCallSign("K 27"):setFaction("Kraylor"):setPosition(-5864.0, -84270.0):orderRoaming()
        table.insert(fleet[0], K_27)
        variable_spawn_in_moreA = 1.0
    end
    if (K_21 ~= nil and K_21:isValid()) and variable_k21_attack_artemis ~= (1.0) then
        variable_k21_attack_artemis = 1.0
        K_21:orderAttack(Artemis)
    end
    if (K_27 ~= nil and K_27:isValid()) and variable_k27_attack_artemis ~= (1.0) then
        variable_k27_attack_artemis = 1.0
        K_21:orderAttack(Artemis)
    end
    if ifInsideBox(Artemis, 19340.0, -59781.0, -79671.0, -58572.0) and variable_artemis_enters_compoundA ~= (1.0) then
        variable_artemis_enters_compoundA = 1.0
        K_87 = CpuShip():setTemplate("Cruiser"):setCallSign("K 87"):setFaction("Kraylor"):setPosition(-40133.0, -44763.0):orderRoaming()
        if fleet[0] == nil then fleet[0] = {} end
        table.insert(fleet[0], K_87)
        K_88 = CpuShip():setTemplate("Cruiser"):setCallSign("K 88"):setFaction("Kraylor"):setPosition(-38539.0, -46016.0):orderRoaming()
        table.insert(fleet[0], K_88)
        --WARNING: Unknown AI: K_88: {'CHASE_ANGER': {'type': 'CHASE_ANGER', 'name': 'K 88'}, 'ATTACK': {'type': 'ATTACK', 'targetName': 'Explorer  9', 'name': 'K 88', 'value1': '7.0'}} 
        K_87:orderAttack(Artemis)
    end
    if ifInsideBox(Artemis, -40440.0, -99891.0, -61869.0, -85385.0) and (S_718 ~= nil and S_718:isValid()) and variable_object_718_msgA ~= (1.0) and (Artemis ~= nil and S_718 ~= nil and Artemis:isValid() and S_718:isValid() and distance(Artemis, S_718) <= 16000.000000) then
        variable_object_718_msgA = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy transmission")
        timers["object_718_msgB"] = 4.000000
    end
    if (timers["object_718_msgB"] ~= nil and timers["object_718_msgB"] < 0.0) and variable_object_718_msgB ~= (1.0) then
        variable_object_718_msgB = 1.0
        temp_transmission_object:setCallSign("S 718"):sendCommsMessage(getPlayerShip(-1), "S 718 to Fleet. We have detected the Artemis in our area. Need assistance.  718, out.")
    end
    if ifInsideBox(Artemis, -55055.0, -91869.0, -73297.0, -70110.0) and (S_717 ~= nil and S_717:isValid()) and variable_object_717_msgA ~= (1.0) then
        variable_object_717_msgA = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy transmission")
        timers["object_717_msgB"] = 4.000000
    end
    if (timers["object_717_msgB"] ~= nil and timers["object_717_msgB"] < 0.0) and variable_object_717_msgB ~= (1.0) then
        variable_object_717_msgB = 1.0
        temp_transmission_object:setCallSign("S 717"):sendCommsMessage(getPlayerShip(-1), "S 717 to Fleet. The we have the Artemis on our sensors, we are moving in to destroy. S 717 out.")
    end
    if ifInsideBox(Artemis, -68462.0, -54616.0, -79891.0, -41099.0) and (S_220 ~= nil and S_220:isValid()) and variable_object_220_msgA ~= (1.0) then
        variable_object_220_msgA = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy transmission")
        timers["object_220_msgB"] = 4.000000
    end
    if (timers["object_220_msgB"] ~= nil and timers["object_220_msgB"] < 0.0) and variable_object_220_msgB ~= (1.0) and (Artemis ~= nil and S_220 ~= nil and Artemis:isValid() and S_220:isValid() and distance(Artemis, S_220) <= 16000.000000) then
        variable_object_220_msgB = 1.0
        temp_transmission_object:setCallSign("S 220"):sendCommsMessage(getPlayerShip(-1), "S 220 to Fleet.  We have the Artemis on our sensors. Repeat, we have detected the Artemis in our area. Moving to destroy.  S 220, out.")
        S_220:orderAttack(Artemis)
    end
    if (timers["couple_more_shipsA"] ~= nil and timers["couple_more_shipsA"] < 0.0) and ifInsideBox(Explorer__9, 8571.0, -65385.0, -11209.0, -58792.0) and variable_explorer_to_artemisB ~= (1.0) then
        variable_explorer_to_artemisB = 1.0
        temp_transmission_object:setCallSign("Explorer 9"):sendCommsMessage(getPlayerShip(-1), "Artemis, Explorer.  Form up on us we are leaving the compound. Be arare of the enemy minefields.   Explorer 9, out.")
        timers["warp_engine_msgA"] = 16.000000
        timers["warp_engine_msgB"] = 19.000000
        timers["warp_engine_msgC"] = 13.000000
    end
    if (timers["warp_engine_msgA"] ~= nil and timers["warp_engine_msgA"] < 0.0) and variable_warp_msgA ~= (1.0) then
        variable_warp_msgA = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Incoming transmission")
    end
    if (timers["warp_engine_msgB"] ~= nil and timers["warp_engine_msgB"] < 0.0) and variable_warp_msgB ~= (1.0) then
        variable_warp_msgB = 1.0
        temp_transmission_object:setCallSign("Explorer 9"):sendCommsMessage(getPlayerShip(-1), "Explorer to Artemis, engineering reports warp engines are on line.  We are preparing for warp speed...")
    end
    if ifInsideBox(S_507, -53187.0, -99781.0, -53957.0, -46374.0) and variable_object_507_msgA ~= (1.0) and (S_507 ~= nil and S_507:isValid()) then
        variable_object_507_msgA = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy transmission")
        timers["object_507_msgB"] = 4.000000
    end
    if (timers["object_507_msgB"] ~= nil and timers["object_507_msgB"] < 0.0) and variable_object_507_msgB ~= (1.0) then
        variable_object_507_msgB = 1.0
        temp_transmission_object:setCallSign("S 507"):sendCommsMessage(getPlayerShip(-1), "S 507 to Fleet, we ar tracking the Explorer and the Artemis.  Consentrate our forces at the main gate.  507, out.")
    end
    if (S_718 ~= nil and S_718:isValid()) and ifInsideBox(Artemis, -25165.0, -99781.0, -26154.0, -50000.0) and variable_object_718_msgC ~= (1.0) then
        variable_object_718_msgC = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy transmission")
        timers["object_718_msgD"] = 4.000000
    end
    if (timers["object_718_msgD"] ~= nil and timers["object_718_msgD"] < 0.0) and variable_object_718_msgD ~= (1.0) then
        variable_object_718_msgD = 1.0
        temp_transmission_object:setCallSign("S 718"):sendCommsMessage(getPlayerShip(-1), "This is 718, we\'ve got this sector covered.  718, out.")
    end
    if ifInsideBox(Artemis, 19560.0, -24506.0, -79671.0, -23957.0) and variable_explorer_low_power_msgA ~= (1.0) then
        variable_explorer_low_power_msgA = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Low power transmission detected")
        timers["explorer_low_power_msgB"] = 5.000000
    end
    if (timers["explorer_low_power_msgB"] ~= nil and timers["explorer_low_power_msgB"] < 0.0) and variable_explorer_low_power_msgB ~= (1.0) then
        variable_explorer_low_power_msgB = 1.0
        temp_transmission_object:setCallSign("Explorer 9"):sendCommsMessage(getPlayerShip(-1), "TSN vessels, this is the (static)... being held prisoner in an enemy compound(static)...have a plan to extricate our vessel but we need assistance to escape.")
    end
    if ifInsideBox(Artemis, 19230.0, -73187.0, -79671.0, -72418.0) and variable_explorer_low_power_msgC ~= (1.0) then
        variable_explorer_low_power_msgC = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Low power transmission detected")
        timers["explorer_low_power_msgD"] = 5.000000
    end
    if (timers["explorer_low_power_msgD"] ~= nil and timers["explorer_low_power_msgD"] < 0.0) and variable_explorer_low_power_msgD ~= (1.0) then
        variable_explorer_low_power_msgD = 1.0
        temp_transmission_object:setCallSign("Explorer 9"):sendCommsMessage(getPlayerShip(-1), "TSN (static)..., this is the Explorer 9. We are being held prisoner(static)...(static)... have a plan to extricate our vessel but we need assistance to escape.")
    end
    if (Artemis ~= nil and K_87 ~= nil and Artemis:isValid() and K_87:isValid() and distance(Artemis, K_87) <= 10000.000000) and variable_k87_tauntA ~= (1.0) then
        variable_k87_tauntA = 1.0
        Artemis:addCustomMessage("scienceOfficer", "warning", "Incoming enemy transmission")
        timers["k87_tauntB"] = 4.000000
    end
    if (timers["k87_tauntB"] ~= nil and timers["k87_tauntB"] < 0.0) and variable_k87_tauntB ~= (1.0) then
        variable_k87_tauntB = 1.0
        temp_transmission_object:setCallSign("K 87"):sendCommsMessage(getPlayerShip(-1), "K 87 to Artemis, surrender!  You cannot escape!")
    end
    if (Artemis ~= nil and S_507 ~= nil and Artemis:isValid() and S_507:isValid() and distance(Artemis, S_507) < 9000.000000) and variable_get_a1_attackingA == (0.0) then
        variable_get_a1_attackingA = 1.0
        temp_transmission_object:setCallSign("S 507"):sendCommsMessage(getPlayerShip(-1), "S 507, to Fleet. The Artemis is in our area, near the prisoner ship. All ships move to destroy!")
        S_508:orderAttack(Artemis)
        S_509:orderAttack(Artemis)
        S_507:orderAttack(Artemis)
    end
    if (Artemis ~= nil and S_500 ~= nil and Artemis:isValid() and S_500:isValid() and distance(Artemis, S_500) < 6000.000000) and variable_get_b5_attackingA == (0.0) then
        variable_get_b5_attackingA = 1.0
        temp_transmission_object:setCallSign("S 500"):sendCommsMessage(getPlayerShip(-1), "S 500, to Fleet. The Artemis is in our sector! Moving to engage!")
        S_502:orderAttack(Artemis)
        S_500:orderAttack(Artemis)
        S_501:orderAttack(Artemis)
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
