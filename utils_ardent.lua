-- Name: utils_ardent
-- Description: Bunch of useful utility functions that can be used in Ardent scenario scripts.


-- Place random objects in a spheree, from point x1,y1 with radius r1
function placeRandomsphere(object_type, amount, x1, y1, r1)
    for n=1,amount do
        local ra = random(0, 360)
        local distance = random(0, r1)
        local x = x1 + math.cos(ra / 180 * math.pi) * distance
        local y = y1 + math.sin(ra / 180 * math.pi) * distance

        object_type():setPosition(x, y)
    end
end

-- Place random objects in a line, from point x1,y1 to x2,y2 with a random distance of random_amount
function placeRandomline(object_type, amount, x1, y1, x2, y2, random_amount)
    for n=1,amount do
        local f = random(0, 1)
        local x = x1 + (x2 - x1) * f
        local y = y1 + (y2 - y1) * f

        local r = random(0, 360)
        local distance = random(0, random_amount)
        x = x + math.cos(r / 180 * math.pi) * distance
        y = y + math.sin(r / 180 * math.pi) * distance

        object_type():setPosition(x, y)
    end
end

-- Check if some Object is outside a Box

function ifOutsideBox(obj, x1, y1, x2, y2)
        if obj == nil or not obj:isValid() then
                return false
        end
        if x2 < x1 then
        local buf1 = x1
        x1 = x2 
        x2 = buf1
        end

        if y2 < y1 then
        local buf1 = y1
        y1 = y2
        y2 = buf1
        end
        
        x, y = obj:getPosition()
        if x >= x1 and x <= x2 and y >= y1 and y <= y2 then
                return false
        end
        return true
end

-- Check if some Object is inside a Box (not necessary with ifOutsideBox)

function ifInsideBox(obj, x1, y1, x2, y2)
        if obj == nil or not obj:isValid() then
                return false
        end
        x, y = obj:getPosition()

        if x2 < x1 then
        local buf1 = x1
        x1 = x2
        x2 = buf1
        end

        if y2 < y1 then
        local buf1 = y1
        y1 = y2
        y2 = buf1
        end

        if x >= x1 and x <= x2 and y >= y1 and y <= y2 then
                return true
        end
        return false
end

-- Check if some Object is inside a Sphere a Box (not necessary with the distance function).

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



--Crea razas
Dren = FactionInfo():setName("Drenni")
Dren:setGMColor(128, 255, 128)
Dren:setDescription([[ The Drenni are a scientifically advanced bipedal race similar to some kind of Earth's lizard. They have developed a number of unique technologies not known or similar to any other. They have colonised half a dozen of the nearby star systems and are considering an alliance with humans. 

Their culture is highly competitive and places a great deal of emphasis on competitive sports and games. Most individuals play some form of sport, whether it is a physical game or an intellectual game. Contact sports are extremely popular, as are games of strategy. Their leaders are selected by way of a sporting tournament. In order to win a position in the government, players must prove themselves in a variety of different sports, including both physical and mental challenges.]])


navi = FactionInfo():setName("Navien")
navi:setGMColor(255, 153, 204)
navi:setDescription([[ These are 3' 6" tall furry arachnid-like creatures with vestigial wings. They have a very low code of honor. Their hive system only allows those most successful to mate with the queen, but any navi can try. Hence all navi except the queens of each hive are male. The few sociopaths who won't adhere to their belief system are exiled but they believe in their 3 hearts that their actions will vindicate them and assure them a place at the head of the royal queue.

With glowing red eyes and blunted claws at the ends of their fingers. They have a highly evolved sense of smell and spit acid. They secrete a flammable liquid from glands in their skin, and they regularly set fire to themselves as a way of cleansing their bodies.]])
navi:setEnemy(Dren)