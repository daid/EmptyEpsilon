-- Name: Belly of the Beast
-- Description: Converted Artemis mission

function init()
    timers = {}
    fleet = {}
	temp_transmission_object = SpaceStation():setTemplate("Small Station"):setPosition(-1000000, -1000000)
    Mine():setPosition(-32916.0, -38338.0)
    Mine():setPosition(-41509.0, -38338.0)
    Nebula():setPosition(-36446.0, -55832.0)
    Asteroid():setPosition(-35832.0, -55525.0)
    Nebula():setPosition(-37366.0, -54144.0)
    Nebula():setPosition(-40128.0, -56292.0)
    Nebula():setPosition(-43658.0, -54604.0)
    Nebula():setPosition(-40742.0, -53837.0)
    Nebula():setPosition(-39668.0, -50614.0)
    Nebula():setPosition(-39208.0, -50614.0)
    Nebula():setPosition(-36906.0, -50614.0)
    Nebula():setPosition(-35218.0, -51842.0)
    Nebula():setPosition(-34758.0, -51995.0)
    Nebula():setPosition(-38133.0, -53223.0)
    Nebula():setPosition(-39975.0, -53223.0)
    Nebula():setPosition(-39668.0, -53530.0)
    Nebula():setPosition(-39361.0, -53376.0)
    Nebula():setPosition(-35678.0, -53376.0)
    Nebula():setPosition(-33990.0, -54144.0)
    Nebula():setPosition(-33223.0, -56139.0)
    Nebula():setPosition(-37059.0, -57213.0)
    Nebula():setPosition(-38440.0, -57366.0)
    Nebula():setPosition(-33530.0, -57520.0)
    Nebula():setPosition(-30000.0, -55525.0)
    Nebula():setPosition(-31382.0, -53683.0)
    Nebula():setPosition(-33530.0, -52456.0)
    Nebula():setPosition(-34144.0, -51995.0)
    Nebula():setPosition(-60384.0, -54297.0)
    Nebula():setPosition(-59463.0, -54297.0)
    Nebula():setPosition(-57622.0, -55678.0)
    Nebula():setPosition(-56855.0, -57673.0)
    Nebula():setPosition(-59617.0, -58133.0)
    Nebula():setPosition(-61458.0, -58287.0)
    Nebula():setPosition(-58389.0, -61356.0)
    Nebula():setPosition(-55474.0, -61356.0)
    Nebula():setPosition(-55167.0, -59821.0)
    Nebula():setPosition(-55013.0, -59208.0)
    Nebula():setPosition(-54093.0, -63965.0)
    Nebula():setPosition(-55474.0, -64579.0)
    Nebula():setPosition(-58389.0, -63658.0)
    Nebula():setPosition(-59463.0, -61509.0)
    Nebula():setPosition(-62226.0, -58594.0)
    Nebula():setPosition(-64374.0, -57673.0)
    Nebula():setPosition(-67136.0, -56446.0)
    Nebula():setPosition(-67136.0, -55525.0)
    Nebula():setPosition(-65602.0, -54758.0)
    Nebula():setPosition(-63453.0, -55218.0)
    Nebula():setPosition(-62072.0, -56446.0)
    Nebula():setPosition(-14502.0, -63965.0)
    Nebula():setPosition(-13888.0, -68108.0)
    Nebula():setPosition(-11893.0, -69796.0)
    Nebula():setPosition(-6215.0, -71177.0)
    Nebula():setPosition(-5448.0, -72405.0)
    Nebula():setPosition(-5448.0, -74246.0)
    Nebula():setPosition(-7596.0, -73632.0)
    Nebula():setPosition(-10359.0, -71484.0)
    Nebula():setPosition(-10819.0, -71330.0)
    Nebula():setPosition(-4067.0, -76394.0)
    Nebula():setPosition(-4681.0, -79924.0)
    Nebula():setPosition(-4834.0, -83760.0)
    Nebula():setPosition(-691.0, -85448.0)
    Nebula():setPosition(-1458.0, -85141.0)
    Nebula():setPosition(-1919.0, -82226.0)
    Nebula():setPosition(-3146.0, -79924.0)
    Nebula():setPosition(-2839.0, -78543.0)
    Nebula():setPosition(-1765.0, -75627.0)
    Nebula():setPosition(-3914.0, -73632.0)
    Nebula():setPosition(-4681.0, -70870.0)
    Nebula():setPosition(-6062.0, -69029.0)
    Nebula():setPosition(-9284.0, -67648.0)
    Nebula():setPosition(-10972.0, -65039.0)
    Nebula():setPosition(-11893.0, -62891.0)
    Nebula():setPosition(-13274.0, -64425.0)
    Nebula():setPosition(-11586.0, -67187.0)
    Nebula():setPosition(-8671.0, -69796.0)
    Nebula():setPosition(-5755.0, -66573.0)
    Nebula():setPosition(-8364.0, -65039.0)
    Nebula():setPosition(-76343.0, -17469.0)
    Nebula():setPosition(-76343.0, -13939.0)
    Nebula():setPosition(-75422.0, -10256.0)
    Nebula():setPosition(-72814.0, -7954.0)
    Nebula():setPosition(-76343.0, -5346.0)
    Nebula():setPosition(-77724.0, -8568.0)
    Nebula():setPosition(-78185.0, -12251.0)
    Nebula():setPosition(-80026.0, -15627.0)
    Nebula():setPosition(-80333.0, -7954.0)
    Nebula():setPosition(-80486.0, -5039.0)
    Nebula():setPosition(-78492.0, -4118.0)
    Nebula():setPosition(-76957.0, -2123.0)
    Nebula():setPosition(-78185.0, -1049.0)
    Nebula():setPosition(-76190.0, -1049.0)
    Nebula():setPosition(-73888.0, -1663.0)
    Nebula():setPosition(-74655.0, -4272.0)
    Nebula():setPosition(-74195.0, -6266.0)
    Nebula():setPosition(-75729.0, -8568.0)
    Nebula():setPosition(-76650.0, -10256.0)
    Nebula():setPosition(-77417.0, -11177.0)
    Nebula():setPosition(-79259.0, -11484.0)
    Nebula():setPosition(-78185.0, -7954.0)
    Nebula():setPosition(-29080.0, -34195.0)
    Nebula():setPosition(-25704.0, -33428.0)
    Nebula():setPosition(-21868.0, -31279.0)
    Nebula():setPosition(-21254.0, -29745.0)
    Nebula():setPosition(-22788.0, -33121.0)
    Nebula():setPosition(-24937.0, -33735.0)
    Nebula():setPosition(-27699.0, -33121.0)
    Nebula():setPosition(-21407.0, -32047.0)
    Nebula():setPosition(-16343.0, -31740.0)
    Nebula():setPosition(-15729.0, -28364.0)
    Nebula():setPosition(-17264.0, -27903.0)
    Nebula():setPosition(-18185.0, -30205.0)
    Nebula():setPosition(-16804.0, -31279.0)
    Nebula():setPosition(-11740.0, -29898.0)
    Nebula():setPosition(-14962.0, -27290.0)
    Nebula():setPosition(-12200.0, -27136.0)
    Nebula():setPosition(-9591.0, -28824.0)
    Nebula():setPosition(-10665.0, -31126.0)
    Nebula():setPosition(-5295.0, -30512.0)
    Nebula():setPosition(-3453.0, -29131.0)
    Nebula():setPosition(-4681.0, -27136.0)
    Nebula():setPosition(-4988.0, -27290.0)
    Nebula():setPosition(-8210.0, -28210.0)
    Nebula():setPosition(-998.0, -28210.0)
    Nebula():setPosition(843.0, -28977.0)
    Nebula():setPosition(3913.0, -29131.0)
    Nebula():setPosition(4373.0, -28517.0)
    Nebula():setPosition(2838.0, -26676.0)
    Nebula():setPosition(690.0, -26522.0)
    Nebula():setPosition(5294.0, -26369.0)
    Nebula():setPosition(4987.0, -26369.0)
    Nebula():setPosition(5140.0, -24220.0)
    Nebula():setPosition(6214.0, -22839.0)
    Nebula():setPosition(9744.0, -22072.0)
    Nebula():setPosition(8209.0, -17315.0)
    Nebula():setPosition(9130.0, -13939.0)
    Nebula():setPosition(9744.0, -13786.0)
    Nebula():setPosition(7749.0, -19310.0)
    Nebula():setPosition(8976.0, -20844.0)
    Nebula():setPosition(10358.0, -22993.0)
    Nebula():setPosition(8363.0, -24681.0)
    Nebula():setPosition(7289.0, -26215.0)
    Nebula():setPosition(9130.0, -22226.0)
    Nebula():setPosition(10511.0, -16701.0)
    Nebula():setPosition(11585.0, -16548.0)
    Nebula():setPosition(12506.0, -18696.0)
    Nebula():setPosition(12659.0, -20844.0)
    Nebula():setPosition(14347.0, -19770.0)
    Nebula():setPosition(16035.0, -17622.0)
    Nebula():setPosition(17263.0, -16855.0)
    Nebula():setPosition(13734.0, -22072.0)
    Nebula():setPosition(12659.0, -25448.0)
    Nebula():setPosition(9897.0, -27290.0)
    Nebula():setPosition(-24323.0, -29438.0)
    Nebula():setPosition(-26778.0, -30972.0)
    Nebula():setPosition(-30000.0, -31126.0)
    Nebula():setPosition(-24323.0, -28210.0)
    Nebula():setPosition(-20180.0, -26062.0)
    Nebula():setPosition(-16957.0, -24374.0)
    Nebula():setPosition(-11126.0, -24527.0)
    Nebula():setPosition(-5602.0, -24220.0)
    Nebula():setPosition(-691.0, -23300.0)
    Nebula():setPosition(2071.0, -20844.0)
    Nebula():setPosition(76.0, -24220.0)
    Nebula():setPosition(-5295.0, -24681.0)
    Nebula():setPosition(-7750.0, -24374.0)
    Nebula():setPosition(-9898.0, -24834.0)
    Nebula():setPosition(-14809.0, -25141.0)
    Nebula():setPosition(-15422.0, -25141.0)
    Nebula():setPosition(-7290.0, -25295.0)
    Nebula():setPosition(-691.0, -24834.0)
    Nebula():setPosition(2838.0, -22532.0)
    Nebula():setPosition(4373.0, -22226.0)
    Nebula():setPosition(-2072.0, -24834.0)
    Nebula():setPosition(7595.0, -19770.0)
    Nebula():setPosition(9130.0, -18850.0)
    Nebula():setPosition(4373.0, -20538.0)
    Nebula():setPosition(13120.0, -14706.0)
    Nebula():setPosition(12813.0, -12711.0)
    Nebula():setPosition(14654.0, -12251.0)
    Nebula():setPosition(15115.0, -13632.0)
    Nebula():setPosition(14961.0, -15474.0)
    Nebula():setPosition(15728.0, -16701.0)
    Nebula():setPosition(-73735.0, -32200.0)
    Nebula():setPosition(-77878.0, -33121.0)
    Nebula():setPosition(-73274.0, -33428.0)
    Nebula():setPosition(-70665.0, -33581.0)
    Nebula():setPosition(-78492.0, -86829.0)
    Nebula():setPosition(-78492.0, -89745.0)
    Nebula():setPosition(-77878.0, -93428.0)
    Nebula():setPosition(-79873.0, -95883.0)
    Nebula():setPosition(-77724.0, -98798.0)
    Nebula():setPosition(-74502.0, -98952.0)
    Nebula():setPosition(-75116.0, -97724.0)
    Nebula():setPosition(-78338.0, -94655.0)
    Nebula():setPosition(-76190.0, -96343.0)
    Nebula():setPosition(-72200.0, -100180.0)
    Nebula():setPosition(-71740.0, -100180.0)
    Nebula():setPosition(-75883.0, -98031.0)
    Nebula():setPosition(-79873.0, -92200.0)
    Nebula():setPosition(-79873.0, -87596.0)
    Nebula():setPosition(18337.0, -94041.0)
    Nebula():setPosition(16803.0, -97878.0)
    Nebula():setPosition(14347.0, -99259.0)
    Nebula():setPosition(18951.0, -98492.0)
    Nebula():setPosition(18644.0, -94502.0)
    Nebula():setPosition(18184.0, -91740.0)
    Nebula():setPosition(14961.0, -94655.0)
    Nebula():setPosition(10358.0, -98031.0)
    Nebula():setPosition(2531.0, -98031.0)
    Nebula():setPosition(-5602.0, -99719.0)
    Nebula():setPosition(-9898.0, -99105.0)
    Nebula():setPosition(-384.0, -98952.0)
    Nebula():setPosition(8209.0, -98185.0)
    Nebula():setPosition(5601.0, -98645.0)
    Nebula():setPosition(6521.0, -98645.0)
    Nebula():setPosition(13887.0, -97110.0)
    Nebula():setPosition(16035.0, -92353.0)
    Nebula():setPosition(17570.0, -88977.0)
    Nebula():setPosition(18491.0, -88364.0)
    Nebula():setPosition(18797.0, -87443.0)
    Nebula():setPosition(18644.0, -91586.0)
    Nebula():setPosition(18184.0, -95883.0)
    Nebula():setPosition(14347.0, -98185.0)
    Nebula():setPosition(-80640.0, -67648.0)
    Nebula():setPosition(-78031.0, -68415.0)
    Nebula():setPosition(-74502.0, -71637.0)
    Nebula():setPosition(-70972.0, -75013.0)
    Nebula():setPosition(-67443.0, -78389.0)
    Nebula():setPosition(-68824.0, -83914.0)
    Nebula():setPosition(-67443.0, -85602.0)
    Nebula():setPosition(-71279.0, -80844.0)
    Nebula():setPosition(-71740.0, -78082.0)
    Nebula():setPosition(-69131.0, -80231.0)
    Nebula():setPosition(-66062.0, -82993.0)
    Nebula():setPosition(-68671.0, -79770.0)
    Nebula():setPosition(-73428.0, -73786.0)
    Nebula():setPosition(-75883.0, -72405.0)
    Nebula():setPosition(-73274.0, -75627.0)
    Nebula():setPosition(-72507.0, -76701.0)
    Nebula():setPosition(-77110.0, -73018.0)
    Nebula():setPosition(-79412.0, -70410.0)
    Nebula():setPosition(-79566.0, -69642.0)
    Nebula():setPosition(-75116.0, -71024.0)
    Nebula():setPosition(-72353.0, -74860.0)
    Nebula():setPosition(-69131.0, -77315.0)
    Nebula():setPosition(-67290.0, -77929.0)
    Nebula():setPosition(-64067.0, -81305.0)
    Nebula():setPosition(-66369.0, -81765.0)
    Nebula():setPosition(-66215.0, -80231.0)
    Nebula():setPosition(-65602.0, -80077.0)
    Nebula():setPosition(-70205.0, -81305.0)
    Nebula():setPosition(-72660.0, -75781.0)
    Nebula():setPosition(-75422.0, -74553.0)
    Nebula():setPosition(-76804.0, -74553.0)
    Nebula():setPosition(-78952.0, -72098.0)
    Nebula():setPosition(-79873.0, -72251.0)
    Nebula():setPosition(-79873.0, -74860.0)
    Nebula():setPosition(-79719.0, -76701.0)
    Nebula():setPosition(-80640.0, -79157.0)
    Nebula():setPosition(-81100.0, -81458.0)
    Nebula():setPosition(-81254.0, -83607.0)
    Nebula():setPosition(-80026.0, -85448.0)
    Nebula():setPosition(-79105.0, -86062.0)
    Nebula():setPosition(-80180.0, -83453.0)
    Nebula():setPosition(-79873.0, -81305.0)
    Nebula():setPosition(-79566.0, -79924.0)
    Nebula():setPosition(-78952.0, -78696.0)
    Nebula():setPosition(-77724.0, -77162.0)
    Nebula():setPosition(-75422.0, -77162.0)
    Nebula():setPosition(-74502.0, -77162.0)
    Nebula():setPosition(-76957.0, -70256.0)
    Nebula():setPosition(-52251.0, -89591.0)
    Nebula():setPosition(-51024.0, -87903.0)
    Nebula():setPosition(-48568.0, -88671.0)
    Nebula():setPosition(-46727.0, -89898.0)
    Nebula():setPosition(-43811.0, -91126.0)
    Nebula():setPosition(-41356.0, -90512.0)
    Nebula():setPosition(-38747.0, -89438.0)
    Nebula():setPosition(-44118.0, -88364.0)
    Nebula():setPosition(-46880.0, -87903.0)
    Nebula():setPosition(-50563.0, -86676.0)
    Nebula():setPosition(-53172.0, -87136.0)
    Nebula():setPosition(-53632.0, -88977.0)
    Nebula():setPosition(-48875.0, -89591.0)
    Nebula():setPosition(-45039.0, -90819.0)
    Nebula():setPosition(-40896.0, -90819.0)
    Nebula():setPosition(-40128.0, -89591.0)
    Nebula():setPosition(-43044.0, -88671.0)
    Nebula():setPosition(-44425.0, -86522.0)
    Nebula():setPosition(-41816.0, -84067.0)
    Nebula():setPosition(-39668.0, -86062.0)
    Nebula():setPosition(-40896.0, -86829.0)
    Nebula():setPosition(-37366.0, -92814.0)
    Nebula():setPosition(-39821.0, -94195.0)
    Nebula():setPosition(-38594.0, -96343.0)
    Nebula():setPosition(-34911.0, -98645.0)
    Nebula():setPosition(-30154.0, -100180.0)
    Nebula():setPosition(-33683.0, -100180.0)
    Nebula():setPosition(-40896.0, -97417.0)
    Nebula():setPosition(-43044.0, -94962.0)
    Nebula():setPosition(-45653.0, -94041.0)
    Nebula():setPosition(-47187.0, -93735.0)
    Nebula():setPosition(-44579.0, -92967.0)
    Nebula():setPosition(-41816.0, -92967.0)
    Asteroid():setPosition(-34144.0, -83300.0)
    Asteroid():setPosition(-31382.0, -88517.0)
    Asteroid():setPosition(-33990.0, -87136.0)
    Asteroid():setPosition(-33837.0, -90359.0)
    Asteroid():setPosition(-32456.0, -92200.0)
    Asteroid():setPosition(-31382.0, -90972.0)
    Asteroid():setPosition(-29387.0, -93735.0)
    Asteroid():setPosition(-27392.0, -95422.0)
    Asteroid():setPosition(-24323.0, -97110.0)
    Asteroid():setPosition(-21868.0, -97724.0)
    Asteroid():setPosition(-26011.0, -98645.0)
    Asteroid():setPosition(-31688.0, -96036.0)
    Asteroid():setPosition(-32763.0, -93888.0)
    Asteroid():setPosition(-28773.0, -96343.0)
    Asteroid():setPosition(-35371.0, -84374.0)
    Asteroid():setPosition(-36292.0, -83453.0)
    Asteroid():setPosition(-38594.0, -82226.0)
    Asteroid():setPosition(-41509.0, -80844.0)
    Asteroid():setPosition(-40742.0, -79770.0)
    Asteroid():setPosition(-42891.0, -77929.0)
    Asteroid():setPosition(-46420.0, -77929.0)
    Asteroid():setPosition(-51330.0, -77929.0)
    Asteroid():setPosition(-55474.0, -74860.0)
    Asteroid():setPosition(-58850.0, -73786.0)
    Asteroid():setPosition(-60998.0, -72711.0)
    Asteroid():setPosition(-63760.0, -71177.0)
    Asteroid():setPosition(-67290.0, -69182.0)
    Asteroid():setPosition(-69898.0, -67494.0)
    Asteroid():setPosition(-73274.0, -65039.0)
    Asteroid():setPosition(-76497.0, -61663.0)
    Asteroid():setPosition(-77417.0, -59975.0)
    Asteroid():setPosition(-77878.0, -58594.0)
    Asteroid():setPosition(-76343.0, -61203.0)
    Asteroid():setPosition(-74348.0, -63504.0)
    Asteroid():setPosition(-72507.0, -64272.0)
    Asteroid():setPosition(-78645.0, -62277.0)
    Asteroid():setPosition(-71279.0, -67187.0)
    Asteroid():setPosition(-66676.0, -68722.0)
    Asteroid():setPosition(-63453.0, -69489.0)
    Asteroid():setPosition(-61765.0, -71330.0)
    Asteroid():setPosition(-64988.0, -72098.0)
    Asteroid():setPosition(-51791.0, -76701.0)
    Asteroid():setPosition(-49642.0, -77315.0)
    Asteroid():setPosition(-48261.0, -77622.0)
    Asteroid():setPosition(-21254.0, -99873.0)
    Asteroid():setPosition(-18645.0, -99259.0)
    Asteroid():setPosition(-16190.0, -99873.0)
    Asteroid():setPosition(-23249.0, -99566.0)
    Asteroid():setPosition(-28006.0, -99105.0)
    Asteroid():setPosition(-25857.0, -96957.0)
    Asteroid():setPosition(-78185.0, -19617.0)
    Asteroid():setPosition(-77571.0, -22686.0)
    Asteroid():setPosition(-76957.0, -25141.0)
    Asteroid():setPosition(-77571.0, -26676.0)
    Asteroid():setPosition(-78645.0, -26062.0)
    Asteroid():setPosition(-78798.0, -23453.0)
    Asteroid():setPosition(-78952.0, -21612.0)
    Asteroid():setPosition(-79259.0, -28364.0)
    Asteroid():setPosition(-79873.0, -29131.0)
    Asteroid():setPosition(-80793.0, -26215.0)
    Asteroid():setPosition(-80486.0, -23453.0)
    Asteroid():setPosition(-80333.0, -21765.0)
    Asteroid():setPosition(-80180.0, -57980.0)
    Asteroid():setPosition(-81561.0, -55371.0)
    Asteroid():setPosition(-82481.0, -51995.0)
    Asteroid():setPosition(-83402.0, -49540.0)
    Asteroid():setPosition(-82174.0, -47392.0)
    Asteroid():setPosition(-82481.0, -52302.0)
    Asteroid():setPosition(-80947.0, -55525.0)
    Asteroid():setPosition(-82942.0, -47545.0)
    Asteroid():setPosition(-82635.0, -42635.0)
    Asteroid():setPosition(-82788.0, -39566.0)
    Asteroid():setPosition(-84323.0, -43555.0)
    Asteroid():setPosition(-81868.0, -45397.0)
    Asteroid():setPosition(-81714.0, -40486.0)
    Asteroid():setPosition(-82174.0, -36343.0)
    Asteroid():setPosition(-81561.0, -32814.0)
    Asteroid():setPosition(-81254.0, -30512.0)
    Asteroid():setPosition(-77110.0, -17622.0)
    Asteroid():setPosition(-76497.0, -13479.0)
    Asteroid():setPosition(-76036.0, -12558.0)
    Asteroid():setPosition(-74655.0, -12558.0)
    Asteroid():setPosition(-74655.0, -14706.0)
    Asteroid():setPosition(-73274.0, -13325.0)
    Asteroid():setPosition(-72200.0, -10717.0)
    Asteroid():setPosition(-71279.0, -8568.0)
    Asteroid():setPosition(-71279.0, -6880.0)
    Asteroid():setPosition(-70205.0, -3811.0)
    Asteroid():setPosition(-70972.0, -2584.0)
    Asteroid():setPosition(-71126.0, -2277.0)
    Mine():setPosition(-73735.0, -71944.0)
    Mine():setPosition(-76343.0, -69949.0)
    Mine():setPosition(-75576.0, -71637.0)
    Mine():setPosition(-78185.0, -70256.0)
    Mine():setPosition(-78338.0, -69029.0)
    Mine():setPosition(-79719.0, -68261.0)
    Mine():setPosition(-74809.0, -73632.0)
    Mine():setPosition(-77417.0, -71791.0)
    Mine():setPosition(-76497.0, -73632.0)
    Mine():setPosition(-79259.0, -71944.0)
    Mine():setPosition(-78645.0, -73939.0)
    Mine():setPosition(-36446.0, -89591.0)
    Mine():setPosition(-36139.0, -91586.0)
    Mine():setPosition(-35371.0, -93121.0)
    Mine():setPosition(-35064.0, -95269.0)
    Mine():setPosition(-33530.0, -96343.0)
    Mine():setPosition(-32149.0, -97724.0)
    Mine():setPosition(-30461.0, -98952.0)
    Mine():setPosition(-37520.0, -90819.0)
    Mine():setPosition(-37366.0, -92967.0)
    Mine():setPosition(-36752.0, -94809.0)
    Mine():setPosition(-35371.0, -97264.0)
    Mine():setPosition(-33990.0, -98492.0)
    Mine():setPosition(-32763.0, -99566.0)
    Mine():setPosition(-73581.0, -73786.0)
    Mine():setPosition(-72507.0, -75320.0)
    Mine():setPosition(-71433.0, -76701.0)
    Mine():setPosition(-69745.0, -77775.0)
    Mine():setPosition(-68517.0, -79003.0)
    Mine():setPosition(-68671.0, -77775.0)
    Mine():setPosition(-70359.0, -76548.0)
    Mine():setPosition(-71126.0, -75320.0)
    Mine():setPosition(-72047.0, -73939.0)
    tmp_count = 40
    for tmp_counter=1,tmp_count do
        tmp_x = -79259.0 + (-43197.0 - -79259.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -38952.0 + (-38798.0 - -38952.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 40
    for tmp_counter=1,tmp_count do
        tmp_x = -79259.0 + (-43197.0 - -79259.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -38952.0 + (-38798.0 - -38952.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 40
    for tmp_counter=1,tmp_count do
        tmp_x = -79259.0 + (-43197.0 - -79259.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -38952.0 + (-38798.0 - -38952.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 40
    for tmp_counter=1,tmp_count do
        tmp_x = -79259.0 + (-43197.0 - -79259.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -38952.0 + (-38798.0 - -38952.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 40
    for tmp_counter=1,tmp_count do
        tmp_x = -79259.0 + (-43197.0 - -79259.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -38952.0 + (-38798.0 - -38952.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 40
    for tmp_counter=1,tmp_count do
        tmp_x = -79259.0 + (-43197.0 - -79259.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -38952.0 + (-38798.0 - -38952.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 40
    for tmp_counter=1,tmp_count do
        tmp_x = -79259.0 + (-43197.0 - -79259.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -38952.0 + (-38798.0 - -38952.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 40
    for tmp_counter=1,tmp_count do
        tmp_x = -79259.0 + (-43197.0 - -79259.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -38952.0 + (-38798.0 - -38952.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 55
    for tmp_counter=1,tmp_count do
        tmp_x = -31842.0 + (18220.0 - -31842.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -39105.0 + (-38951.0 - -39105.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 55
    for tmp_counter=1,tmp_count do
        tmp_x = -31842.0 + (18220.0 - -31842.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -39105.0 + (-38951.0 - -39105.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 55
    for tmp_counter=1,tmp_count do
        tmp_x = -31842.0 + (18220.0 - -31842.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -39105.0 + (-38951.0 - -39105.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 55
    for tmp_counter=1,tmp_count do
        tmp_x = -31842.0 + (18220.0 - -31842.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -39105.0 + (-38951.0 - -39105.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 55
    for tmp_counter=1,tmp_count do
        tmp_x = -31842.0 + (18220.0 - -31842.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -39105.0 + (-38951.0 - -39105.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 55
    for tmp_counter=1,tmp_count do
        tmp_x = -31842.0 + (18220.0 - -31842.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -39105.0 + (-38951.0 - -39105.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 55
    for tmp_counter=1,tmp_count do
        tmp_x = -31842.0 + (18220.0 - -31842.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -39105.0 + (-38951.0 - -39105.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 55
    for tmp_counter=1,tmp_count do
        tmp_x = -31842.0 + (18220.0 - -31842.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -39105.0 + (-38951.0 - -39105.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    tmp_count = 55
    for tmp_counter=1,tmp_count do
        tmp_x = -31842.0 + (18220.0 - -31842.0) * (tmp_counter - 1) / tmp_count
        tmp_y = -39105.0 + (-38951.0 - -39105.0) * (tmp_counter - 1) / tmp_count
        Mine():setPosition(tmp_x, tmp_y)
    end
    Nebula():setPosition(17570.0, -42635.0)
    Nebula():setPosition(17570.0, -36957.0)
    Nebula():setPosition(19104.0, -33121.0)
    Nebula():setPosition(18951.0, -34962.0)
    Nebula():setPosition(20025.0, -38185.0)
    Nebula():setPosition(20025.0, -41100.0)
    Nebula():setPosition(15575.0, -35422.0)
    Nebula():setPosition(19411.0, -28517.0)
    Nebula():setPosition(19104.0, -30512.0)
    Nebula():setPosition(19104.0, -32507.0)
    Nebula():setPosition(18797.0, -44476.0)
    Nebula():setPosition(19258.0, -49540.0)
    Nebula():setPosition(20179.0, -57980.0)
    Nebula():setPosition(19565.0, -56139.0)
    Nebula():setPosition(19565.0, -54297.0)
    Nebula():setPosition(19411.0, -52456.0)
    Nebula():setPosition(19718.0, -50307.0)
    Nebula():setPosition(19565.0, -47238.0)
    Nebula():setPosition(19411.0, -46011.0)
    Nebula():setPosition(20485.0, -45090.0)
    Nebula():setPosition(22173.0, -50614.0)
    Nebula():setPosition(22173.0, -56139.0)
    Nebula():setPosition(19718.0, -85295.0)
    Nebula():setPosition(19565.0, -82993.0)
    Nebula():setPosition(19565.0, -81151.0)
    Nebula():setPosition(20179.0, -78236.0)
    Nebula():setPosition(-9898.0, -67187.0)
    Nebula():setPosition(-6522.0, -69336.0)
    Nebula():setPosition(-5448.0, -70256.0)
    Nebula():setPosition(-7596.0, -71024.0)
    Nebula():setPosition(-9438.0, -69949.0)
    Nebula():setPosition(-9898.0, -69029.0)
    Nebula():setPosition(-45960.0, -88671.0)
    Nebula():setPosition(-46727.0, -90205.0)
    Nebula():setPosition(-46266.0, -91586.0)
    Nebula():setPosition(-44732.0, -92814.0)
    Nebula():setPosition(-67903.0, -79770.0)
    Nebula():setPosition(-69591.0, -80077.0)
    Nebula():setPosition(-68824.0, -80998.0)
    Nebula():setPosition(-66983.0, -80844.0)
    Nebula():setPosition(-67903.0, -79003.0)
    Nebula():setPosition(-68364.0, -78543.0)
    Nebula():setPosition(-71126.0, -76855.0)
    Nebula():setPosition(-71433.0, -76855.0)
    Nebula():setPosition(-75116.0, -72405.0)
    Nebula():setPosition(-75729.0, -71177.0)
    Nebula():setPosition(-78645.0, -68415.0)
    Nebula():setPosition(-72814.0, -32814.0)
    Nebula():setPosition(-74962.0, -32660.0)
    Nebula():setPosition(-76036.0, -33428.0)
    Nebula():setPosition(-76190.0, -35269.0)
    Nebula():setPosition(-78338.0, -41100.0)
    Nebula():setPosition(-78338.0, -36650.0)
    Nebula():setPosition(-78185.0, -33581.0)
    Nebula():setPosition(-79105.0, -31740.0)
    Nebula():setPosition(-79105.0, -29284.0)
    Nebula():setPosition(-80333.0, -42942.0)
    Nebula():setPosition(-75729.0, -5499.0)
    Nebula():setPosition(-73581.0, -2123.0)
    Nebula():setPosition(-72660.0, -2891.0)
    Nebula():setPosition(-72814.0, -3197.0)
    Nebula():setPosition(-74195.0, -36036.0)
    Nebula():setPosition(-71433.0, -35422.0)
    Nebula():setPosition(-59310.0, -60435.0)
    Nebula():setPosition(-60077.0, -58287.0)
    Nebula():setPosition(-58696.0, -57366.0)
    Nebula():setPosition(-56701.0, -59208.0)
    Nebula():setPosition(-60384.0, -55371.0)
    Nebula():setPosition(-59157.0, -55218.0)
    Nebula():setPosition(-65755.0, -56752.0)
    Nebula():setPosition(-37520.0, -53530.0)
    Nebula():setPosition(-35985.0, -52609.0)
    Nebula():setPosition(-34758.0, -52302.0)
    Nebula():setPosition(-32302.0, -52916.0)
    Nebula():setPosition(-62072.0, -57213.0)
    Nebula():setPosition(-60384.0, -58287.0)
    Nebula():setPosition(-58850.0, -59668.0)
    Nebula():setPosition(-63300.0, -78696.0)
    Nebula():setPosition(-64988.0, -78082.0)
    Nebula():setPosition(-66215.0, -77622.0)
    Nebula():setPosition(-68824.0, -76087.0)
    Nebula():setPosition(-71126.0, -73479.0)
    Nebula():setPosition(-62686.0, -83300.0)
    Nebula():setPosition(-64527.0, -84527.0)
    Nebula():setPosition(-45499.0, -97264.0)
    Nebula():setPosition(-45346.0, -98492.0)
    Nebula():setPosition(-47648.0, -99259.0)
    Nebula():setPosition(-44118.0, -99259.0)
    Nebula():setPosition(-42123.0, -99719.0)
    Nebula():setPosition(-42277.0, -99873.0)
    Nebula():setPosition(-43658.0, -98492.0)
    Nebula():setPosition(-43504.0, -96957.0)
    Nebula():setPosition(-39975.0, -97878.0)
    Nebula():setPosition(-36446.0, -99259.0)
    Nebula():setPosition(-33990.0, -99105.0)
    Nebula():setPosition(-37673.0, -96650.0)
    Nebula():setPosition(-38901.0, -94809.0)
    Nebula():setPosition(-35525.0, -96650.0)
    Nebula():setPosition(-30921.0, -99566.0)
    Nebula():setPosition(-26625.0, -99719.0)
    Nebula():setPosition(-27545.0, -99873.0)
    Mine():setPosition(19258.0, -39412.0)
    Mine():setPosition(19258.0, -39412.0)
    Mine():setPosition(19258.0, -39412.0)
    Mine():setPosition(19258.0, -39412.0)
    Mine():setPosition(19258.0, -39412.0)
    Mine():setPosition(19258.0, -39412.0)
    Mine():setPosition(19258.0, -39412.0)
    Nebula():setPosition(-35064.0, -90359.0)
    Nebula():setPosition(-35064.0, -93274.0)
    Nebula():setPosition(-37059.0, -90665.0)
    Nebula():setPosition(-36752.0, -92047.0)
    Nebula():setPosition(-36599.0, -93121.0)
    Nebula():setPosition(-33530.0, -94041.0)
    Nebula():setPosition(-32763.0, -96036.0)
    Nebula():setPosition(-31075.0, -97417.0)
    Nebula():setPosition(-29847.0, -98185.0)
    Nebula():setPosition(-28159.0, -96957.0)
    Nebula():setPosition(-31688.0, -94195.0)
    Nebula():setPosition(-32916.0, -93121.0)
    Nebula():setPosition(-34451.0, -90512.0)
    Nebula():setPosition(-28159.0, -94041.0)
    Nebula():setPosition(-25243.0, -97110.0)
    Nebula():setPosition(-20947.0, -98338.0)
    Nebula():setPosition(-22021.0, -98798.0)
    Nebula():setPosition(-26625.0, -98492.0)
    Nebula():setPosition(-36752.0, -90205.0)
    Nebula():setPosition(-79719.0, -63811.0)
    Nebula():setPosition(-78185.0, -65806.0)
    Nebula():setPosition(-79412.0, -59821.0)
    Nebula():setPosition(-80947.0, -57366.0)
    Nebula():setPosition(-83249.0, -50154.0)
    Nebula():setPosition(-82635.0, -53376.0)
    Nebula():setPosition(-80793.0, -57673.0)
    Mine():setPosition(-42584.0, -38798.0)
    Mine():setPosition(-42277.0, -38798.0)
    Mine():setPosition(-42123.0, -38338.0)
    Mine():setPosition(-42430.0, -38645.0)
    Mine():setPosition(-41663.0, -38338.0)
    Mine():setPosition(-32609.0, -39259.0)
    Mine():setPosition(-32302.0, -39105.0)
    Mine():setPosition(-32302.0, -39105.0)
    Mine():setPosition(-32302.0, -38645.0)
    Mine():setPosition(-32763.0, -38338.0)
    Mine():setPosition(-32763.0, -38185.0)
    Mine():setPosition(-41970.0, -38338.0)
    Asteroid():setPosition(17020.0, -14820.0)
    Asteroid():setPosition(14174.0, -18008.0)
    Asteroid():setPosition(10759.0, -22334.0)
    Asteroid():setPosition(7457.0, -24612.0)
    Asteroid():setPosition(11555.0, -18805.0)
    Asteroid():setPosition(7912.0, -22221.0)
    Asteroid():setPosition(4383.0, -23928.0)
    Asteroid():setPosition(-399.0, -25636.0)
    Asteroid():setPosition(-5978.0, -26092.0)
    Asteroid():setPosition(-10418.0, -26547.0)
    Asteroid():setPosition(-13378.0, -28824.0)
    Asteroid():setPosition(-7913.0, -26205.0)
    Asteroid():setPosition(-13834.0, -27116.0)
    Asteroid():setPosition(-17249.0, -29849.0)
    Asteroid():setPosition(-6319.0, -24953.0)
    Asteroid():setPosition(-13037.0, -24839.0)
    Asteroid():setPosition(-17818.0, -27913.0)
    Asteroid():setPosition(-22828.0, -28141.0)
    Asteroid():setPosition(-27723.0, -31443.0)
    Asteroid():setPosition(-28976.0, -33834.0)
    Asteroid():setPosition(-25219.0, -29507.0)
    Asteroid():setPosition(-29317.0, -32467.0)
    Asteroid():setPosition(-30797.0, -34858.0)
    Asteroid():setPosition(-27496.0, -33378.0)
    Asteroid():setPosition(-31025.0, -36908.0)
    Asteroid():setPosition(-33188.0, -39868.0)
    Asteroid():setPosition(-33871.0, -39982.0)
    Asteroid():setPosition(-30911.0, -38046.0)
    Asteroid():setPosition(-26699.0, -41006.0)
    Asteroid():setPosition(-28748.0, -40665.0)
    Asteroid():setPosition(-24194.0, -37135.0)
    Asteroid():setPosition(-28179.0, -37818.0)
    Asteroid():setPosition(-25788.0, -35883.0)
    Asteroid():setPosition(-26130.0, -34289.0)
    Asteroid():setPosition(-18388.0, -30873.0)
    Asteroid():setPosition(-22942.0, -32923.0)
    Asteroid():setPosition(-28976.0, -49317.0)
    Asteroid():setPosition(-31367.0, -52505.0)
    Asteroid():setPosition(-32733.0, -53188.0)
    Asteroid():setPosition(-32619.0, -55579.0)
    Asteroid():setPosition(-33758.0, -56945.0)
    Asteroid():setPosition(-32164.0, -59336.0)
    Asteroid():setPosition(-33075.0, -55352.0)
    Asteroid():setPosition(-36035.0, -56262.0)
    Asteroid():setPosition(-34896.0, -59564.0)
    Asteroid():setPosition(-34441.0, -60019.0)
    Asteroid():setPosition(-35238.0, -57515.0)
    Asteroid():setPosition(-37970.0, -57515.0)
    Asteroid():setPosition(-38198.0, -59450.0)
    Asteroid():setPosition(-35465.0, -58653.0)
    Asteroid():setPosition(-67002.0, -78008.0)
    Asteroid():setPosition(-68824.0, -76983.0)
    Asteroid():setPosition(-69279.0, -75617.0)
    Asteroid():setPosition(-70532.0, -73568.0)
    Asteroid():setPosition(-69393.0, -75959.0)
    Asteroid():setPosition(-67799.0, -78008.0)
    Asteroid():setPosition(-73037.0, -74251.0)
    Asteroid():setPosition(-27040.0, -37249.0)
    Asteroid():setPosition(-27496.0, -35883.0)
    Asteroid():setPosition(-27268.0, -36224.0)
    Asteroid():setPosition(-24308.0, -37135.0)
    Asteroid():setPosition(-27154.0, -38274.0)
    Asteroid():setPosition(-27154.0, -37477.0)
    Asteroid():setPosition(-23169.0, -36111.0)
    Asteroid():setPosition(-25105.0, -37135.0)
    Asteroid():setPosition(-23966.0, -38729.0)
    Asteroid():setPosition(-25902.0, -38615.0)
    Asteroid():setPosition(-28748.0, -37704.0)
    Asteroid():setPosition(-29090.0, -36338.0)
    Asteroid():setPosition(-29545.0, -36680.0)
    Asteroid():setPosition(15882.0, -36452.0)
    Asteroid():setPosition(16223.0, -35883.0)
    Asteroid():setPosition(17362.0, -34061.0)
    Asteroid():setPosition(16907.0, -36224.0)
    Asteroid():setPosition(16451.0, -37249.0)
    Asteroid():setPosition(12808.0, -38160.0)
    Asteroid():setPosition(14516.0, -41120.0)
    Asteroid():setPosition(15426.0, -41348.0)
    Asteroid():setPosition(10417.0, -41803.0)
    Asteroid():setPosition(8823.0, -41689.0)
    Asteroid():setPosition(9848.0, -40778.0)
    Asteroid():setPosition(6318.0, -45105.0)
    Asteroid():setPosition(2106.0, -48293.0)
    Asteroid():setPosition(740.0, -50911.0)
    Asteroid():setPosition(56.0, -52961.0)
    Asteroid():setPosition(1423.0, -50570.0)
    Asteroid():setPosition(-513.0, -50570.0)
    Asteroid():setPosition(-1879.0, -53188.0)
    Asteroid():setPosition(-4042.0, -56149.0)
    Asteroid():setPosition(-5408.0, -66509.0)
    Asteroid():setPosition(-4498.0, -70835.0)
    Asteroid():setPosition(-3473.0, -74820.0)
    Asteroid():setPosition(-4839.0, -71291.0)
    Asteroid():setPosition(-6205.0, -68558.0)
    Asteroid():setPosition(-6205.0, -73340.0)
    Asteroid():setPosition(-3815.0, -78122.0)
    Asteroid():setPosition(-1993.0, -83018.0)
    Asteroid():setPosition(-1310.0, -85750.0)
    Asteroid():setPosition(3244.0, -96566.0)
    Asteroid():setPosition(4497.0, -99412.0)
    Asteroid():setPosition(967.0, -94517.0)
    Asteroid():setPosition(512.0, -93492.0)
    Asteroid():setPosition(56.0, -97021.0)
    Asteroid():setPosition(2789.0, -99185.0)
    Asteroid():setPosition(853.0, -95200.0)
    Asteroid():setPosition(-67344.0, -1841.0)
    Asteroid():setPosition(-69052.0, -2752.0)
    Asteroid():setPosition(-70190.0, -2069.0)
    Asteroid():setPosition(-33758.0, -63321.0)
    Asteroid():setPosition(-31367.0, -67192.0)
    Asteroid():setPosition(-29545.0, -69697.0)
    Asteroid():setPosition(-32733.0, -68217.0)
    Asteroid():setPosition(-34668.0, -65143.0)
    Asteroid():setPosition(-34896.0, -60703.0)
    Asteroid():setPosition(-29317.0, -66737.0)
    Asteroid():setPosition(-27154.0, -71063.0)
    Asteroid():setPosition(-26243.0, -72657.0)
    Asteroid():setPosition(-28862.0, -69811.0)
    Asteroid():setPosition(-26926.0, -73454.0)
    Asteroid():setPosition(-23739.0, -77097.0)
    Asteroid():setPosition(-20323.0, -81538.0)
    Asteroid():setPosition(-20778.0, -80513.0)
    Asteroid():setPosition(-18046.0, -82790.0)
    Asteroid():setPosition(-21120.0, -78008.0)
    Asteroid():setPosition(-22828.0, -76642.0)
    Asteroid():setPosition(-10873.0, -89621.0)
    Asteroid():setPosition(-9052.0, -92353.0)
    Asteroid():setPosition(-7230.0, -96224.0)
    Asteroid():setPosition(-5522.0, -94858.0)
    Asteroid():setPosition(-2562.0, -96794.0)
    Asteroid():setPosition(-2221.0, -97932.0)
    Asteroid():setPosition(-33302.0, -60019.0)
    Asteroid():setPosition(-32164.0, -62524.0)
    Asteroid():setPosition(-33416.0, -63093.0)
    Asteroid():setPosition(-35921.0, -61727.0)
    Asteroid():setPosition(-35921.0, -60247.0)
    Asteroid():setPosition(-35807.0, -59336.0)
    Asteroid():setPosition(-34896.0, -62069.0)
    Asteroid():setPosition(-34782.0, -64004.0)
    Asteroid():setPosition(-31708.0, -65826.0)
    Asteroid():setPosition(-34782.0, -64915.0)
    Asteroid():setPosition(-37856.0, -61613.0)
    Nebula():setPosition(-33644.0, -60930.0)
    Nebula():setPosition(1081.0, -49773.0)
    Nebula():setPosition(5521.0, -45446.0)
    Nebula():setPosition(8823.0, -44649.0)
    Nebula():setPosition(740.0, -51253.0)
    Nebula():setPosition(284.0, -51822.0)
    Nebula():setPosition(3017.0, -48748.0)
    Nebula():setPosition(-2790.0, -52619.0)
    Nebula():setPosition(-3701.0, -54782.0)
    Nebula():setPosition(7343.0, -46585.0)
    Nebula():setPosition(13377.0, -42031.0)
    Nebula():setPosition(15654.0, -41462.0)
    Nebula():setPosition(12922.0, -39868.0)
    Nebula():setPosition(17134.0, -32581.0)
    Nebula():setPosition(17590.0, -29849.0)
    Nebula():setPosition(17931.0, -24839.0)
    Nebula():setPosition(17362.0, -21651.0)
    Nebula():setPosition(18159.0, -19260.0)
    Nebula():setPosition(17931.0, -22790.0)
    Nebula():setPosition(18387.0, -11519.0)
    Nebula():setPosition(18387.0, -12657.0)
    Nebula():setPosition(17020.0, -13909.0)
    Nebula():setPosition(17476.0, -6964.0)
    Nebula():setPosition(15426.0, -10835.0)
    Nebula():setPosition(18500.0, -7875.0)
    Nebula():setPosition(17703.0, -3890.0)
    Nebula():setPosition(17020.0, -1044.0)
    Nebula():setPosition(16793.0, -5257.0)
    Nebula():setPosition(17362.0, -2638.0)
    Nebula():setPosition(15199.0, -1613.0)
    Nebula():setPosition(-33644.0, -57629.0)
    Nebula():setPosition(-33758.0, -60589.0)
    Nebula():setPosition(-36490.0, -62980.0)
    Nebula():setPosition(-37742.0, -61500.0)
    Nebula():setPosition(-38084.0, -58767.0)
    Nebula():setPosition(-35693.0, -58198.0)
    Nebula():setPosition(-32619.0, -58198.0)
    Nebula():setPosition(-32619.0, -61386.0)
    Nebula():setPosition(-32847.0, -66281.0)
    Nebula():setPosition(-29090.0, -69925.0)
    Nebula():setPosition(-29317.0, -71177.0)
    Nebula():setPosition(-32278.0, -65484.0)
    Nebula():setPosition(-34441.0, -61272.0)
    Nebula():setPosition(-29431.0, -52733.0)
    Nebula():setPosition(-32278.0, -51481.0)
    Nebula():setPosition(-33075.0, -52164.0)
    Nebula():setPosition(-29090.0, -52391.0)
    Nebula():setPosition(-27382.0, -51708.0)
    Nebula():setPosition(-31936.0, -51253.0)
    Nebula():setPosition(-30000.0, -50570.0)
    Nebula():setPosition(-42752.0, -53075.0)
    Nebula():setPosition(-43435.0, -52278.0)
    Nebula():setPosition(-41386.0, -53871.0)
    Nebula():setPosition(-38653.0, -55807.0)
    Nebula():setPosition(-36945.0, -56718.0)
    Nebula():setPosition(-33985.0, -55807.0)
    Nebula():setPosition(-9052.0, -67534.0)
    Nebula():setPosition(-7913.0, -70494.0)
    Nebula():setPosition(-5864.0, -72088.0)
    Nebula():setPosition(-9279.0, -71746.0)
    Nebula():setPosition(-12126.0, -68331.0)
    Nebula():setPosition(-10760.0, -66737.0)
    Nebula():setPosition(-7458.0, -70038.0)
    Nebula():setPosition(-5408.0, -72771.0)
    Nebula():setPosition(-4156.0, -76870.0)
    Nebula():setPosition(-3131.0, -79147.0)
    Nebula():setPosition(-5067.0, -75389.0)
    Nebula():setPosition(-12467.0, -65940.0)
    Nebula():setPosition(-10987.0, -65257.0)
    Nebula():setPosition(-25105.0, -33037.0)
    Nebula():setPosition(-27837.0, -34744.0)
    Nebula():setPosition(-27382.0, -31670.0)
    Nebula():setPosition(-26813.0, -29166.0)
    Nebula():setPosition(-28976.0, -31898.0)
    Nebula():setPosition(-23625.0, -29166.0)
    Nebula():setPosition(-20892.0, -29621.0)
    Nebula():setPosition(-24308.0, -32353.0)
    Nebula():setPosition(-27610.0, -34289.0)
    Nebula():setPosition(-26243.0, -31215.0)
    Nebula():setPosition(-27723.0, -30418.0)
    Nebula():setPosition(-30228.0, -30646.0)
    Nebula():setPosition(-26471.0, -27686.0)
    Nebula():setPosition(-23739.0, -27572.0)
    Nebula():setPosition(-19868.0, -28710.0)
    Nebula():setPosition(-17932.0, -28596.0)
    Nebula():setPosition(-13492.0, -28255.0)
    Nebula():setPosition(-5522.0, -27116.0)
    Nebula():setPosition(-8255.0, -27686.0)
    Nebula():setPosition(-4612.0, -26661.0)
    Nebula():setPosition(-1993.0, -26433.0)
    Nebula():setPosition(-6547.0, -26433.0)
    Nebula():setPosition(56.0, -25636.0)
    Nebula():setPosition(1650.0, -26205.0)
    Nebula():setPosition(1423.0, -27230.0)
    Nebula():setPosition(-3815.0, -27002.0)
    Nebula():setPosition(-2904.0, -27230.0)
    Nebula():setPosition(-1424.0, -27002.0)
    Nebula():setPosition(-1196.0, -27230.0)
    Nebula():setPosition(-3473.0, -24953.0)
    Nebula():setPosition(-5750.0, -24042.0)
    Nebula():setPosition(-8824.0, -23701.0)
    Artemis = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Player Cruiser"):setCallSign("Artemis"):setPosition(-30000.0, -1000.0)
    S2117 = CpuShip():setTemplate("Cruiser"):setCallSign("S2117"):setFaction("Kraylor"):setPosition(-1151.0, -41407.0):orderRoaming()
    if fleet[0] == nil then fleet[0] = {} end
    table.insert(fleet[0], S2117)
    S115 = CpuShip():setTemplate("Cruiser"):setCallSign("S115"):setFaction("Kraylor"):setPosition(-47034.0, -42328.0):orderRoaming()
    table.insert(fleet[0], S115)
    S51 = CpuShip():setTemplate("Cruiser"):setCallSign("S51"):setFaction("Kraylor"):setPosition(-78031.0, -54911.0):orderRoaming()
    table.insert(fleet[0], S51)
    Target_debris_1 = SupplyDrop():setFaction("Human Navy"):setPosition(-73581.0, -86983.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
    S051 = CpuShip():setTemplate("Cruiser"):setCallSign("S051"):setFaction("Kraylor"):setPosition(-38901.0, -85908.0):orderRoaming()
    table.insert(fleet[0], S051)
    S417 = CpuShip():setTemplate("Cruiser"):setCallSign("S417"):setFaction("Kraylor"):setPosition(-24016.0, -46164.0):orderRoaming()
    table.insert(fleet[0], S417)
    S771 = CpuShip():setTemplate("Cruiser"):setCallSign("S771"):setFaction("Kraylor"):setPosition(-31688.0, -72251.0):orderRoaming()
    table.insert(fleet[0], S771)
    S420 = CpuShip():setTemplate("Cruiser"):setCallSign("S420"):setFaction("Kraylor"):setPosition(-29387.0, -59515.0):orderRoaming()
    table.insert(fleet[0], S420)
    Target_debris_1a = SupplyDrop():setFaction("Human Navy"):setPosition(-71740.0, -92660.0):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
    S377 = CpuShip():setTemplate("Cruiser"):setCallSign("S377"):setFaction("Kraylor"):setPosition(-21868.0, -94348.0):orderRoaming()
    table.insert(fleet[0], S377)
    S111 = CpuShip():setTemplate("Cruiser"):setCallSign("S111"):setFaction("Kraylor"):setPosition(11585.0, -94655.0):orderRoaming()
    table.insert(fleet[0], S111)
    S67 = CpuShip():setTemplate("Cruiser"):setCallSign("S67"):setFaction("Kraylor"):setPosition(-43965.0, -50768.0):orderRoaming()
    table.insert(fleet[0], S67)
    S61 = CpuShip():setTemplate("Cruiser"):setCallSign("S61"):setFaction("Kraylor"):setPosition(12352.0, -87136.0):orderRoaming()
    table.insert(fleet[0], S61)
    S43 = CpuShip():setTemplate("Cruiser"):setCallSign("S43"):setFaction("Kraylor"):setPosition(6214.0, -46931.0):orderRoaming()
    table.insert(fleet[0], S43)
    S_101 = CpuShip():setTemplate("Cruiser"):setCallSign("S 101"):setFaction("Kraylor"):setPosition(16342.0, -60435.0):orderRoaming()
    table.insert(fleet[0], S_101)
    --WARNING: Ignore <create> {'y': '0.0', 'x': '98185.0', 'z': '90051.0', 'type': 'monster', 'angle': '0'} 
    --WARNING: Ignore <create> {'y': '0.0', 'x': '60435.0', 'z': '1508.0', 'type': 'monster', 'angle': '0'} 
    --WARNING: Ignore <create> {'y': '0.0', 'x': '99259.0', 'z': '92352.0', 'type': 'monster', 'angle': '0'} 
    --WARNING: Ignore <create> {'y': '0.0', 'x': '4460.0', 'z': '77893.0', 'type': 'monster', 'angle': '0'} 
    --WARNING: Ignore <create> {'y': '0.0', 'x': '98501.0', 'z': '66736.0', 'type': 'monster', 'angle': '0'} 
    timers["start_mission_timer_1"] = 10.000000
    timers["sensor_msgA"] = 10.000000
    timers["mssg_timer"] = 15.000000
    variable_chapter_1 = 1.0
end

function update(delta)
    for key, value in pairs(timers) do
        timers[key] = timers[key] - delta
    end
    if (timers["sensor_msgA"] ~= nil and timers["sensor_msgA"] < 0.0) and variable_sensor_msgA ~= (1.0) then
        globalMessage("\n\nRecommend Sensors 33k or less");
        variable_sensor_msgA = 1.0
    end
    if (timers["titleA"] ~= nil and timers["titleA"] < 0.0) and variable_titleA ~= (1.0) and ifOutsideBox(Artemis, 19670.0, -7803.0, -79671.0, -880.0) then
        variable_titleA = 1.0
        globalMessage("The Belly  of  the  Beast\n\n");
        timers["titleB"] = 10.000000
        --WARNING: Ignore <warning_popup_message> {'message': 'The Belly of the Beast', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "The Belly of the Beast")
        Artemis:addCustomMessage("relayOfficer", "warning", "The Belly of the Beast")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "The Belly of the Beast")
        Artemis:addCustomMessage("scienceOfficer", "warning", "The Belly of the Beast")
        Artemis:addCustomMessage("helmsOfficer", "warning", "The Belly of the Beast")
    end
    if (timers["titleB"] ~= nil and timers["titleB"] < 0.0) and variable_titleB ~= (1.0) then
        variable_titleB = 1.0
        globalMessage("\nby  FutileChas\n");
        --WARNING: Ignore <warning_popup_message> {'message': 'by FutileChas', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "by FutileChas")
        Artemis:addCustomMessage("relayOfficer", "warning", "by FutileChas")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "by FutileChas")
        Artemis:addCustomMessage("scienceOfficer", "warning", "by FutileChas")
        Artemis:addCustomMessage("helmsOfficer", "warning", "by FutileChas")
    end
    if (Target_debris_1a == nil or not Target_debris_1a:isValid()) and (Target_debris_1 == nil or not Target_debris_1:isValid()) and ifInsideBox(Artemis, 19450.0, -33077.0, -79561.0, -32748.0) and variable_last_msgA ~= (1.0) then
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy comm")
        variable_last_msgA = 1.0
        timers["comms_timer_13"] = 5.000000
    end
    if (timers["comms_timer_13"] ~= nil and timers["comms_timer_13"] < 0.0) and variable_last_msgB ~= (1.0) then
        variable_last_msgB = 1.0
        timers["if_they_waitA"] = 0.000000
        temp_transmission_object:setCallSign("S420"):sendCommsMessage(getPlayerShip(-1), "420 to Fleet.  Uh, has anyone checked out  A1 lately?")
    end
    if variable_object_1st_mssg ~= (1.0) and (timers["mssg_timer"] ~= nil and timers["mssg_timer"] < 0.0) then
        --WARNING: Ignore <warning_popup_message> {'message': 'Incoming mssg', 'consoles': 'MCO'} 
        Artemis:addCustomMessage("relayOfficer", "warning", "Incoming mssg")
        temp_transmission_object:setCallSign("Deep Space Command"):sendCommsMessage(getPlayerShip(-1), "Artemis, this is Command. There has been heavy Skaraan activity deep in this quadrant. We fear they are working on an advanced weapon or vessel. We need you to infiltrate the quadrant and collect anomalies from the area.  If you are able to collect the anomalous material return to sector E 3.  There are high levels of cosmic radiation in this quadrant and the  Artemis should be able  to remain undetected as long as you keep some distance from enemy ships., we suspect somewhere between 6 to 8 kilometers. There is a laser detection grid across the border, and we do not think you can cross there.  Your best chance is to enter through the main gate but it is heavily guarded.   Do not let the Skaraans discover your presence.  Good luck Artemis. Deep Space Command, out.")
        variable_object_1st_mssg = 1.0
        timers["titleA"] = 25.000000
    end
    if ifInsideBox(Artemis, 17912.0, -39781.0, -32572.0, -38858.0) and variable_detectedA ~= (1.0) then
        globalMessage("Artemis has been detected\n\nmission failed");
        timers["hit_mine"] = 8.000000
        --WARNING: Ignore <warning_popup_message> {'message': 'Artemis has been detected', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("relayOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Artemis has been detected")
        variable_detectedA = 1.0
    end
    if ifInsideBox(Artemis, -41715.0, -39000.0, -79715.0, -38429.0) and variable_detectedB ~= (1.0) then
        globalMessage("Artemis has been detected\n\nmission failed");
        --WARNING: Ignore <warning_popup_message> {'message': 'Artemis has been detected', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("relayOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Artemis has been detected")
        timers["hit_mine"] = 8.000000
        variable_detectedB = 1.0
    end
    if variable_Mine_detection ~= (1.0) and (timers["hit_mine"] ~= nil and timers["hit_mine"] < 0.0) then
        variable_Mine_detection = 1.0
        victory("Independent")
    end
    if ifInsideBox(Artemis, 2000.0, -19286.0, -63715.0, -16000.0) and variable_not_if_we_jam_it_timer ~= (1.0) then
        variable_not_if_we_jam_it_timer = 1.0
        timers["jam_it_timer"] = 3.000000
    end
    if (timers["jam_it_timer"] ~= nil and timers["jam_it_timer"] < 0.0) and variable_jamming ~= (1.0) then
        Artemis:addCustomMessage("scienceOfficer", "warning", "Adjusting Sensors")
        variable_jamming = 1.0
    end
    if ifInsideSphere(S2117, -1151.0, -41407.0, 5000.000000) then
        if S2117 ~= nil and S2117:isValid() then
            S2117:orderFlyTowards(-55627.0, -41254.0)
        end
    end
    if ifInsideSphere(S2117, -55627.0, -41254.0, 5000.000000) then
        if S2117 ~= nil and S2117:isValid() then
            S2117:orderFlyTowards(-1151.0, -41407.0)
        end
    end
    if variable_Ending ~= (1.0) and (Artemis ~= nil and S2117 ~= nil and Artemis:isValid() and S2117:isValid() and distance(Artemis, S2117) <= 6000.000000) then
        globalMessage("Artemis has been detected\n\nmission failed");
        timers["too_close_timer"] = 10.000000
        variable_Ending = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'Artemis has been detected', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("relayOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Artemis has been detected")
    end
    if (timers["return_timer"] ~= nil and timers["return_timer"] < 0.0) and variable_Ending ~= (1.0) and (Artemis ~= nil and S2117 ~= nil and Artemis:isValid() and S2117:isValid() and distance(Artemis, S2117) <= 6000.000000) then
        globalMessage("Artemis has been detected\n\nmission failed");
        timers["too_close_timer"] = 10.000000
        variable_Ending = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'Artemis has been detected', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("relayOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Artemis has been detected")
    end
    if ifInsideSphere(S115, -47034.0, -42328.0, 5000.000000) then
        if S115 ~= nil and S115:isValid() then
            S115:orderFlyTowards(-27085.0, -42788.0)
        end
    end
    if ifInsideSphere(S115, -27085.0, -42788.0, 5000.000000) then
        if S115 ~= nil and S115:isValid() then
            S115:orderFlyTowards(-27085.0, -42328.0)
        end
    end
    if variable_Ending ~= (1.0) and (Artemis ~= nil and S115 ~= nil and Artemis:isValid() and S115:isValid() and distance(Artemis, S115) <= 6000.000000) then
        globalMessage("Artemis has been detected\n\nmission failed");
        timers["too_close_timer"] = 10.000000
        variable_Ending = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'Artemis has been detected', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("relayOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Artemis has been detected")
    end
    if ifInsideSphere(S51, -78031.0, -54911.0, 5000.000000) then
        if S51 ~= nil and S51:isValid() then
            S51:orderFlyTowards(-47034.0, -75320.0)
        end
    end
    if ifInsideSphere(S51, -47034.0, -75320.0, 5000.000000) then
        if S51 ~= nil and S51:isValid() then
            S51:orderFlyTowards(-78031.0, -54911.0)
        end
    end
    if (Artemis ~= nil and S51 ~= nil and Artemis:isValid() and S51:isValid() and distance(Artemis, S51) <= 6000.000000) and variable_Ending ~= (1.0) then
        globalMessage("Artemis has been detected\n\nmission failed");
        timers["too_close_timer"] = 10.000000
        variable_Ending = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'Artemis has been detected', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("relayOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Artemis has been detected")
    end
    if ifInsideSphere(S051, -38901.0, -85908.0, 5000.000000) then
        if S051 ~= nil and S051:isValid() then
            S051:orderFlyTowards(-65755.0, -75167.0)
        end
    end
    if ifInsideSphere(S051, -65755.0, -75167.0, 5000.000000) then
        if S051 ~= nil and S051:isValid() then
            S051:orderFlyTowards(-38901.0, -85908.0)
        end
    end
    if variable_Ending ~= (1.0) and (Artemis ~= nil and S051 ~= nil and Artemis:isValid() and S051:isValid() and distance(Artemis, S051) <= 6000.000000) then
        globalMessage("Artemis has been detected\n\nmission failed");
        timers["too_close_timer"] = 10.000000
        variable_Ending = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'Artemis has been detected', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("relayOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Artemis has been detected")
    end
    if ifInsideSphere(S417, -24016.0, -41164.0, 5000.000000) then
        if S417 ~= nil and S417:isValid() then
            S417:orderFlyTowards(-47034.0, -46778.0)
        end
    end
    if ifInsideSphere(S417, -47034.0, -46778.0, 5000.000000) then
        if S417 ~= nil and S417:isValid() then
            S417:orderFlyTowards(-24016.0, -41164.0)
        end
    end
    if variable_Ending ~= (1.0) and (Artemis ~= nil and S417 ~= nil and Artemis:isValid() and S417:isValid() and distance(Artemis, S417) <= 6000.000000) then
        globalMessage("Artemis has been detected\n\nmission failed");
        timers["too_close_timer"] = 10.000000
        variable_Ending = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'Artemis has been detected', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("relayOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Artemis has been detected")
    end
    if ifInsideSphere(S771, -31688.0, -72251.0, 5000.000000) then
        if S771 ~= nil and S771:isValid() then
            S771:orderFlyTowards(-51944.0, -61509.0)
        end
    end
    if ifInsideSphere(S771, -51944.0, -61509.0, 5000.000000) then
        if S771 ~= nil and S771:isValid() then
            S771:orderFlyTowards(-31688.0, -72251.0)
        end
    end
    if variable_Ending ~= (1.0) and (Artemis ~= nil and S771 ~= nil and Artemis:isValid() and S771:isValid() and distance(Artemis, S771) <= 6000.000000) then
        globalMessage("Artemis has been detected\n\nmission failed");
        timers["too_close_timer"] = 10.000000
        variable_Ending = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'Artemis has been detected', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("relayOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Artemis has been detected")
    end
    if ifInsideSphere(S420, -29387.0, -59515.0, 5000.000000) then
        if S420 ~= nil and S420:isValid() then
            S420:orderFlyTowards(1764.0, -61663.0)
        end
    end
    if ifInsideSphere(S420, 1764.0, -61663.0, 5000.000000) then
        if S420 ~= nil and S420:isValid() then
            S420:orderFlyTowards(-231.0, -90972.0)
        end
    end
    if ifInsideSphere(S420, -231.0, -90972.0, 5000.000000) then
        if S420 ~= nil and S420:isValid() then
            S420:orderFlyTowards(-29387.0, -59515.0)
        end
    end
    if variable_Ending ~= (1.0) and (Artemis ~= nil and S420 ~= nil and Artemis:isValid() and S420:isValid() and distance(Artemis, S420) <= 6000.000000) then
        globalMessage("Artemis has been detected\n\nmission failed");
        timers["too_close_timer"] = 10.000000
        variable_Ending = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'Artemis has been detected', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("relayOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Artemis has been detected")
    end
    if ifInsideSphere(S377, -21868.0, -94348.0, 5000.000000) then
        if S377 ~= nil and S377:isValid() then
            S377:orderFlyTowards(-2226.0, -94655.0)
        end
    end
    if ifInsideSphere(S377, -2226.0, -94655.0, 5000.000000) then
        if S377 ~= nil and S377:isValid() then
            S377:orderFlyTowards(-21868.0, -94348.0)
        end
    end
    if variable_Ending ~= (1.0) and (Artemis ~= nil and S377 ~= nil and Artemis:isValid() and S377:isValid() and distance(Artemis, S377) <= 6000.000000) then
        globalMessage("Artemis has been detected\n\nmission failed");
        timers["too_close_timer"] = 10.000000
        variable_Ending = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'Artemis has been detected', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("relayOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Artemis has been detected")
    end
    if ifInsideSphere(S111, 11585.0, -94655.0, 5000.000000) then
        if S111 ~= nil and S111:isValid() then
            S111:orderFlyTowards(-7443.0, -94041.0)
        end
    end
    if ifInsideSphere(S111, -7443.0, -94041.0, 5000.000000) then
        if S111 ~= nil and S111:isValid() then
            S111:orderFlyTowards(11585.0, -94655.0)
        end
    end
    if variable_Ending ~= (1.0) and (Artemis ~= nil and S111 ~= nil and Artemis:isValid() and S111:isValid() and distance(Artemis, S111) <= 6000.000000) then
        globalMessage("Artemis has been detected\n\nmission failed");
        timers["too_close_timer"] = 10.000000
        variable_Ending = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'Artemis has been detected', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("relayOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Artemis has been detected")
    end
    if ifInsideSphere(S67, -43965.0, -50768.0, 5000.000000) then
        if S67 ~= nil and S67:isValid() then
            S67:orderFlyTowards(-78185.0, -51228.0)
        end
    end
    if ifInsideSphere(S67, -78185.0, -51228.0, 5000.000000) then
        if S67 ~= nil and S67:isValid() then
            S67:orderFlyTowards(-43965.0, -50768.0)
        end
    end
    if variable_Ending ~= (1.0) and (Artemis ~= nil and S67 ~= nil and Artemis:isValid() and S67:isValid() and distance(Artemis, S67) <= 6000.000000) then
        globalMessage("Artemis has been detected\n\nmission failed");
        timers["too_close_timer"] = 10.000000
        variable_Ending = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'Artemis has been detected', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("relayOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Artemis has been detected")
    end
    if ifInsideSphere(S61, 12352.0, -87136.0, 5000.000000) then
        if S61 ~= nil and S61:isValid() then
            S61:orderFlyTowards(16035.0, -67187.0)
        end
    end
    if ifInsideSphere(S61, 16035.0, -67187.0, 5000.000000) then
        if S61 ~= nil and S61:isValid() then
            S61:orderFlyTowards(12352.0, -87136.0)
        end
    end
    if variable_Ending ~= (1.0) and (Artemis ~= nil and S61 ~= nil and Artemis:isValid() and S61:isValid() and distance(Artemis, S61) <= 6000.000000) then
        globalMessage("Artemis has been detected\n\nmission failed");
        timers["too_close_timer"] = 10.000000
        variable_Ending = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'Artemis has been detected', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("relayOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Artemis has been detected")
    end
    if ifInsideSphere(S43, 6214.0, -46931.0, 5000.000000) then
        if S43 ~= nil and S43:isValid() then
            S43:orderFlyTowards(13734.0, -63044.0)
        end
    end
    if ifInsideSphere(S43, 13734.0, -63044.0, 5000.000000) then
        if S43 ~= nil and S43:isValid() then
            S43:orderFlyTowards(6214.0, -46931.0)
        end
    end
    if variable_Ending ~= (1.0) and (Artemis ~= nil and S43 ~= nil and Artemis:isValid() and S43:isValid() and distance(Artemis, S43) <= 6000.000000) then
        globalMessage("Artemis has been detected\n\nmission failed");
        timers["too_close_timer"] = 10.000000
        variable_Ending = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'Artemis has been detected', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("relayOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Artemis has been detected")
    end
    if (Target_debris_1a == nil or not Target_debris_1a:isValid()) and variable_return_timer ~= (1.0) and (Target_debris_1 == nil or not Target_debris_1:isValid()) then
        variable_return_timer = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'Escape to Sector E3 without being detected', 'consoles': 'MHWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Escape to Sector E3 without being detected")
        Artemis:addCustomMessage("relayOfficer", "warning", "Escape to Sector E3 without being detected")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Escape to Sector E3 without being detected")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Escape to Sector E3 without being detected")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Escape to Sector E3 without being detected")
        timers["return_timer"] = 10.000000
    end
    if (Target_debris_1a == nil or not Target_debris_1a:isValid()) and (Target_debris_1 == nil or not Target_debris_1:isValid()) and ifInsideBox(Artemis, -14715.0, -16715.0, -48572.0, -15572.0) and variable_mission_successfulA ~= (1.0) then
        variable_mission_successfulA = 1.0
        globalMessage("Mission Successful\n\nReturn to nearest Starbase");
        timers["end_mission_timer"] = 12.000000
        --WARNING: Ignore <warning_popup_message> {'message': 'Mission Successful', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Mission Successful")
        Artemis:addCustomMessage("relayOfficer", "warning", "Mission Successful")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Mission Successful")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Mission Successful")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Mission Successful")
    end
    if (Target_debris_1 == nil or not Target_debris_1:isValid()) and (Target_debris_1a == nil or not Target_debris_1a:isValid()) and ifInsideBox(Artemis, -45715.0, -18000.0, -46858.0, -3143.0) and variable_mission_successfulB ~= (1.0) then
        variable_mission_successfulB = 1.0
        globalMessage("Mission Successful\n\nReturn to nearest Starbase");
        timers["end_mission_timer"] = 12.000000
    end
    if (Target_debris_1 == nil or not Target_debris_1:isValid()) and (Target_debris_1a == nil or not Target_debris_1a:isValid()) and ifInsideBox(Artemis, -17858.0, -17286.0, -19000.0, -1858.0) and variable_mission_successfulC ~= (1.0) then
        variable_mission_successfulC = 1.0
        globalMessage("Mission Successful\n\nReturn to nearest Starbase");
        timers["end_mission_timer"] = 12.000000
    end
    if (timers["end_mission_timer"] ~= nil and timers["end_mission_timer"] < 0.0) and variable_endgame ~= (1.0) then
        variable_endgame = 1.0
        victory("Independent")
    end
    if ifInsideBox(Artemis, -32572.0, -39286.0, -42858.0, -36858.0) and variable_caution ~= (1.0) then
        variable_caution = 1.0
        timers["warning_timer"] = 3.000000
    end
    if (timers["warning_timer"] ~= nil and timers["warning_timer"] < 0.0) and variable_warning ~= (1.0) then
        --WARNING: Ignore <warning_popup_message> {'message': 'Entering Skaraan Space', 'consoles': 'MSO'} 
        Artemis:addCustomMessage("scienceOfficer", "warning", "Entering Skaraan Space")
        variable_warning = 1.0
    end
    if ifInsideSphere(S_101, 16342.0, -60435.0, 5000.000000) then
        if S_101 ~= nil and S_101:isValid() then
            S_101:orderFlyTowards(12352.0, -87136.0)
        end
    end
    if ifInsideSphere(S_101, 12352.0, -87136.0, 5000.000000) then
        if S_101 ~= nil and S_101:isValid() then
            S_101:orderFlyTowards(16342.0, -60435.0)
        end
    end
    if variable_Ending ~= (1.0) and (Artemis ~= nil and S_101 ~= nil and Artemis:isValid() and S_101:isValid() and distance(Artemis, S_101) <= 6000.000000) then
        globalMessage("Artemis has been detected\n\nmission failed");
        timers["too_close_timer"] = 10.000000
        variable_Ending = 1.0
        --WARNING: Ignore <warning_popup_message> {'message': 'Artemis has been detected', 'consoles': 'HWESCO'} 
        Artemis:addCustomMessage("engineering", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("relayOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("weaponsOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("scienceOfficer", "warning", "Artemis has been detected")
        Artemis:addCustomMessage("helmsOfficer", "warning", "Artemis has been detected")
    end
    if (timers["too_close_timer"] ~= nil and timers["too_close_timer"] < 0.0) and variable_endgame ~= (1.0) then
        variable_endgame = 1.0
        victory("Independent")
    end
    if variable_mssg_1 ~= (1.0) and (Artemis ~= nil and S67 ~= nil and Artemis:isValid() and S67:isValid() and distance(Artemis, S67) <= 10000.000000) then
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy comm")
        timers["science"] = 4.000000
        variable_mssg_1 = 1.0
    end
    if (Artemis ~= nil and S67 ~= nil and Artemis:isValid() and S67:isValid() and distance(Artemis, S67) <= 10000.000000) and variable_mssg2 ~= (1.0) and (timers["science"] ~= nil and timers["science"] < 0.0) then
        Artemis:addCustomMessage("relayOfficer", "warning", "Incoming mssg")
        temp_transmission_object:setCallSign("S67"):sendCommsMessage(getPlayerShip(-1), "S67 to fleet.  Our sensors are acting strange, we are getting ghost readings on nearby ships.")
        timers["comms_timer"] = 1.000000
        variable_mssg2 = 1.0
    end
    if (Artemis ~= nil and S67 ~= nil and Artemis:isValid() and S67:isValid() and distance(Artemis, S67) >= 10000.000000) and (timers["comms_timer"] ~= nil and timers["comms_timer"] < 0.0) and (timers["science"] ~= nil and timers["science"] < 0.0) then
        variable_mssg_1 = 0.0
        variable_mssg2 = 0.0
    end
    if variable_mssg_3 ~= (1.0) and (Artemis ~= nil and S61 ~= nil and Artemis:isValid() and S61:isValid() and distance(Artemis, S61) <= 10000.000000) then
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy comm")
        timers["science2"] = 4.000000
        variable_mssg_3 = 1.0
    end
    if (Artemis ~= nil and S61 ~= nil and Artemis:isValid() and S61:isValid() and distance(Artemis, S61) <= 10000.000000) and variable_mssg4 ~= (1.0) and (timers["science2"] ~= nil and timers["science2"] < 0.0) then
        Artemis:addCustomMessage("relayOfficer", "warning", "Incoming mssg")
        temp_transmission_object:setCallSign("S61"):sendCommsMessage(getPlayerShip(-1), "S61 to fleet.  We are picking up some strange readings near our position.")
        timers["comms_timer1"] = 1.000000
        variable_mssg4 = 1.0
    end
    if (Artemis ~= nil and S61 ~= nil and Artemis:isValid() and S61:isValid() and distance(Artemis, S61) >= 10000.000000) and (timers["comms_timer1"] ~= nil and timers["comms_timer1"] < 0.0) and (timers["science2"] ~= nil and timers["science2"] < 0.0) then
        variable_mssg_3 = 0.0
        variable_mssg4 = 0.0
    end
    if variable_mssg_5 ~= (1.0) and (Artemis ~= nil and S43 ~= nil and Artemis:isValid() and S43:isValid() and distance(Artemis, S43) <= 10000.000000) then
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy comm")
        timers["science_3"] = 4.000000
        variable_mssg_5 = 1.0
    end
    if (Artemis ~= nil and S43 ~= nil and Artemis:isValid() and S43:isValid() and distance(Artemis, S43) <= 10000.000000) and variable_mssg6 ~= (1.0) and (timers["science_3"] ~= nil and timers["science_3"] < 0.0) then
        Artemis:addCustomMessage("relayOfficer", "warning", "Incoming mssg")
        temp_transmission_object:setCallSign("S43"):sendCommsMessage(getPlayerShip(-1), "S43 to fleet.  We are picking up some strange readings near our position.")
        timers["comms_timer_2"] = 1.000000
        variable_mssg6 = 1.0
    end
    if (Artemis ~= nil and S43 ~= nil and Artemis:isValid() and S43:isValid() and distance(Artemis, S43) >= 10000.000000) and (timers["comms_timer_2"] ~= nil and timers["comms_timer_2"] < 0.0) and (timers["science_3"] ~= nil and timers["science_3"] < 0.0) then
        variable_mssg_5 = 0.0
        variable_mssg6 = 0.0
    end
    if variable_mssg_7 ~= (1.0) and (Artemis ~= nil and S_101 ~= nil and Artemis:isValid() and S_101:isValid() and distance(Artemis, S_101) <= 10000.000000) then
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy comm")
        timers["science_4"] = 4.000000
        variable_mssg_7 = 1.0
    end
    if (Artemis ~= nil and S_101 ~= nil and Artemis:isValid() and S_101:isValid() and distance(Artemis, S_101) <= 10000.000000) and variable_mssg_8 ~= (1.0) and (timers["science_4"] ~= nil and timers["science_4"] < 0.0) then
        Artemis:addCustomMessage("relayOfficer", "warning", "Incoming mssg")
        temp_transmission_object:setCallSign("S 101"):sendCommsMessage(getPlayerShip(-1), "S 101 to fleet.  We are picking up some strange readings near our position.")
        timers["comms_timer_3"] = 1.000000
        variable_mssg_8 = 1.0
    end
    if (Artemis ~= nil and S_101 ~= nil and Artemis:isValid() and S_101:isValid() and distance(Artemis, S_101) >= 10000.000000) and (timers["comms_timer_3"] ~= nil and timers["comms_timer_3"] < 0.0) and (timers["science_4"] ~= nil and timers["science_4"] < 0.0) then
        variable_mssg_7 = 0.0
        variable_mssg_8 = 0.0
    end
    if variable_mssg_9 ~= (1.0) and (Artemis ~= nil and S115 ~= nil and Artemis:isValid() and S115:isValid() and distance(Artemis, S115) <= 10000.000000) then
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy comm")
        timers["science_5"] = 4.000000
        variable_mssg_9 = 1.0
    end
    if (Artemis ~= nil and S115 ~= nil and Artemis:isValid() and S115:isValid() and distance(Artemis, S115) <= 10000.000000) and variable_mssg_10 ~= (1.0) and (timers["science_5"] ~= nil and timers["science_5"] < 0.0) then
        Artemis:addCustomMessage("relayOfficer", "warning", "Incoming mssg")
        temp_transmission_object:setCallSign("S115"):sendCommsMessage(getPlayerShip(-1), "S115 to fleet.  We are picking up some strange readings near our position, keep on alert.")
        timers["comms_timer_4"] = 1.000000
        variable_mssg_10 = 1.0
    end
    if (Artemis ~= nil and S115 ~= nil and Artemis:isValid() and S115:isValid() and distance(Artemis, S115) >= 10000.000000) and (timers["comms_timer_4"] ~= nil and timers["comms_timer_4"] < 0.0) and (timers["science_5"] ~= nil and timers["science_5"] < 0.0) then
        variable_mssg_9 = 0.0
        variable_mssg_10 = 0.0
    end
    if variable_mssg_11 ~= (1.0) and (Artemis ~= nil and S2117 ~= nil and Artemis:isValid() and S2117:isValid() and distance(Artemis, S2117) <= 10000.000000) then
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy comm")
        timers["science_6"] = 4.000000
        variable_mssg_11 = 1.0
    end
    if (Artemis ~= nil and S2117 ~= nil and Artemis:isValid() and S2117:isValid() and distance(Artemis, S2117) <= 10000.000000) and variable_mssg_12 ~= (1.0) and (timers["science_6"] ~= nil and timers["science_6"] < 0.0) then
        Artemis:addCustomMessage("relayOfficer", "warning", "Incoming mssg")
        temp_transmission_object:setCallSign("S2117"):sendCommsMessage(getPlayerShip(-1), "S2117 to S 417.  S 417 this is S 2117, are you picking up readings near our position?")
        timers["comms_timer_5"] = 1.000000
        variable_mssg_12 = 1.0
    end
    if (Artemis ~= nil and S2117 ~= nil and Artemis:isValid() and S2117:isValid() and distance(Artemis, S2117) >= 10000.000000) and (timers["comms_timer_5"] ~= nil and timers["comms_timer_5"] < 0.0) and (timers["science_6"] ~= nil and timers["science_6"] < 0.0) then
        variable_mssg_11 = 0.0
        variable_mssg_12 = 0.0
    end
    if variable_mssg_13 ~= (1.0) and (Artemis ~= nil and S51 ~= nil and Artemis:isValid() and S51:isValid() and distance(Artemis, S51) <= 10000.000000) then
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy comm")
        timers["science_7"] = 4.000000
        variable_mssg_13 = 1.0
    end
    if (Artemis ~= nil and S51 ~= nil and Artemis:isValid() and S51:isValid() and distance(Artemis, S51) <= 10000.000000) and variable_mssg_14 ~= (1.0) and (timers["science_7"] ~= nil and timers["science_7"] < 0.0) then
        Artemis:addCustomMessage("relayOfficer", "warning", "Incoming mssg")
        temp_transmission_object:setCallSign("S51"):sendCommsMessage(getPlayerShip(-1), "S51 to fleet.  We are picking up some strange readings near our position.")
        timers["comms_timer_6"] = 1.000000
        variable_mssg_14 = 1.0
    end
    if (Artemis ~= nil and S51 ~= nil and Artemis:isValid() and S51:isValid() and distance(Artemis, S51) >= 10000.000000) and (timers["comms_timer_6"] ~= nil and timers["comms_timer_6"] < 0.0) and (timers["science_7"] ~= nil and timers["science_7"] < 0.0) then
        variable_mssg_13 = 0.0
        variable_mssg_14 = 0.0
    end
    if variable_mssg_15 ~= (1.0) and (Artemis ~= nil and S051 ~= nil and Artemis:isValid() and S051:isValid() and distance(Artemis, S051) <= 10000.000000) then
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy comm")
        timers["science_8"] = 4.000000
        variable_mssg_15 = 1.0
    end
    if (Artemis ~= nil and S051 ~= nil and Artemis:isValid() and S051:isValid() and distance(Artemis, S051) <= 10000.000000) and variable_mssg_16 ~= (1.0) and (timers["science_8"] ~= nil and timers["science_8"] < 0.0) then
        Artemis:addCustomMessage("relayOfficer", "warning", "Incoming mssg")
        temp_transmission_object:setCallSign("S051"):sendCommsMessage(getPlayerShip(-1), "S051 to fleet.  We are picking up strange readings near us.  We may have a ship near us.  All vessels stay on alert!")
        timers["comms_timer_7"] = 1.000000
        variable_mssg_16 = 1.0
    end
    if (Artemis ~= nil and S051 ~= nil and Artemis:isValid() and S051:isValid() and distance(Artemis, S051) >= 10000.000000) and (timers["comms_timer_7"] ~= nil and timers["comms_timer_7"] < 0.0) and (timers["science_8"] ~= nil and timers["science_8"] < 0.0) then
        variable_mssg_15 = 0.0
        variable_mssg_16 = 0.0
    end
    if variable_mssg_17 ~= (1.0) and (Artemis ~= nil and S417 ~= nil and Artemis:isValid() and S417:isValid() and distance(Artemis, S417) <= 10000.000000) then
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy comm")
        timers["science_9"] = 4.000000
        variable_mssg_17 = 1.0
    end
    if (Artemis ~= nil and S417 ~= nil and Artemis:isValid() and S417:isValid() and distance(Artemis, S417) <= 10000.000000) and variable_mssg_18 ~= (1.0) and (timers["science_9"] ~= nil and timers["science_9"] < 0.0) then
        Artemis:addCustomMessage("relayOfficer", "warning", "Incoming mssg")
        temp_transmission_object:setCallSign("S417"):sendCommsMessage(getPlayerShip(-1), "S417 to fleet.  We got some strange readings near us... (static)...wait... maybe these asteroids are reflecting these cosmic rays back at us.")
        timers["comms_timer_8"] = 1.000000
        variable_mssg_18 = 1.0
    end
    if (Artemis ~= nil and S417 ~= nil and Artemis:isValid() and S417:isValid() and distance(Artemis, S417) >= 10000.000000) and (timers["comms_timer_8"] ~= nil and timers["comms_timer_8"] < 0.0) and (timers["science_9"] ~= nil and timers["science_9"] < 0.0) then
        variable_mssg_17 = 0.0
        variable_mssg_18 = 0.0
    end
    if variable_mssg_19 ~= (1.0) and (Artemis ~= nil and S771 ~= nil and Artemis:isValid() and S771:isValid() and distance(Artemis, S771) <= 10000.000000) then
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy comm")
        timers["science_10"] = 4.000000
        variable_mssg_19 = 1.0
    end
    if (Artemis ~= nil and S771 ~= nil and Artemis:isValid() and S771:isValid() and distance(Artemis, S771) <= 10000.000000) and variable_mssg_20 ~= (1.0) and (timers["science_10"] ~= nil and timers["science_10"] < 0.0) then
        Artemis:addCustomMessage("relayOfficer", "warning", "Incoming mssg")
        temp_transmission_object:setCallSign("S771"):sendCommsMessage(getPlayerShip(-1), "S771 to fleet.  We are picking up some strange readings near our position.")
        timers["comms_timer_9"] = 1.000000
        variable_mssg_20 = 1.0
    end
    if (Artemis ~= nil and S771 ~= nil and Artemis:isValid() and S771:isValid() and distance(Artemis, S771) >= 10000.000000) and (timers["comms_timer_9"] ~= nil and timers["comms_timer_9"] < 0.0) and (timers["science_10"] ~= nil and timers["science_10"] < 0.0) then
        variable_mssg_19 = 0.0
        variable_mssg_20 = 0.0
    end
    if variable_mssg_21 ~= (1.0) and (Artemis ~= nil and S420 ~= nil and Artemis:isValid() and S420:isValid() and distance(Artemis, S420) <= 10000.000000) then
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy comm")
        timers["science_11"] = 4.000000
        variable_mssg_21 = 1.0
    end
    if (Artemis ~= nil and S420 ~= nil and Artemis:isValid() and S420:isValid() and distance(Artemis, S420) <= 10000.000000) and variable_mssg_22 ~= (1.0) and (timers["science_11"] ~= nil and timers["science_11"] < 0.0) then
        Artemis:addCustomMessage("relayOfficer", "warning", "Incoming mssg")
        temp_transmission_object:setCallSign("S420"):sendCommsMessage(getPlayerShip(-1), "S420 to fleet.  We are picking up some strange readings near our position.")
        timers["comms_timer_10"] = 1.000000
        variable_mssg_22 = 1.0
    end
    if (Artemis ~= nil and S420 ~= nil and Artemis:isValid() and S420:isValid() and distance(Artemis, S420) >= 10000.000000) and (timers["comms_timer_10"] ~= nil and timers["comms_timer_10"] < 0.0) and (timers["science_11"] ~= nil and timers["science_11"] < 0.0) then
        variable_mssg_21 = 0.0
        variable_mssg_22 = 0.0
    end
    if variable_mssg_23 ~= (1.0) and (Artemis ~= nil and S377 ~= nil and Artemis:isValid() and S377:isValid() and distance(Artemis, S377) <= 10000.000000) then
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy comm")
        timers["science_12"] = 4.000000
        variable_mssg_23 = 1.0
    end
    if (Artemis ~= nil and S377 ~= nil and Artemis:isValid() and S377:isValid() and distance(Artemis, S377) <= 10000.000000) and variable_mssg_24 ~= (1.0) and (timers["science_12"] ~= nil and timers["science_12"] < 0.0) then
        Artemis:addCustomMessage("relayOfficer", "warning", "Incoming mssg")
        temp_transmission_object:setCallSign("S377"):sendCommsMessage(getPlayerShip(-1), "S337 to fleet.  We are picking up some interference on our sensors.  \n")
        timers["comms_timer_11"] = 1.000000
        variable_mssg_24 = 1.0
    end
    if (Artemis ~= nil and S377 ~= nil and Artemis:isValid() and S377:isValid() and distance(Artemis, S377) >= 10000.000000) and (timers["comms_timer_11"] ~= nil and timers["comms_timer_11"] < 0.0) and (timers["science_12"] ~= nil and timers["science_12"] < 0.0) then
        variable_mssg_23 = 0.0
        variable_mssg_24 = 0.0
    end
    if variable_mssg_25 ~= (1.0) and (Artemis ~= nil and S111 ~= nil and Artemis:isValid() and S111:isValid() and distance(Artemis, S111) <= 10000.000000) then
        Artemis:addCustomMessage("scienceOfficer", "warning", "Intercepting enemy comm")
        timers["science_13"] = 4.000000
        variable_mssg_25 = 1.0
    end
    if (Artemis ~= nil and S111 ~= nil and Artemis:isValid() and S111:isValid() and distance(Artemis, S111) <= 10000.000000) and variable_mssg_26 ~= (1.0) and (timers["science_13"] ~= nil and timers["science_13"] < 0.0) then
        Artemis:addCustomMessage("relayOfficer", "warning", "Incoming mssg")
        temp_transmission_object:setCallSign("S111"):sendCommsMessage(getPlayerShip(-1), "S111 to fleet.  We are picking up some strange readings near our position.")
        timers["comms_timer_12"] = 1.000000
        variable_mssg_26 = 1.0
    end
    if (Artemis ~= nil and S111 ~= nil and Artemis:isValid() and S111:isValid() and distance(Artemis, S111) >= 10000.000000) and (timers["comms_timer_12"] ~= nil and timers["comms_timer_12"] < 0.0) and (timers["science_13"] ~= nil and timers["science_13"] < 0.0) then
        variable_mssg_25 = 0.0
        variable_mssg_26 = 0.0
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
