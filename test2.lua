--[[
-x = 1
-z = 2
+x = 3
+z = 4
]]

require("movement")
require("getDirection")
require("gotoGPS")

function getLocation(timeout,debug)

    x,y,z = gps.locate(timeout,debug)

    if x then
        return vector.new(x,y,z)
    else
        error("Can't locate GPS")
    end
end

if not turtle.facing then
    turtle.back()
    turtle.facing = getOrientation()
end


turtle.location = getLocation(5)

--scanSurrounding()

--[[
while true do
    scanSurrounding()
    mineNearestOre()
    read()
end
]]

vinemining()