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


--facing = 4 -- If this value is wrong then your turtle is drunk

if not turtle.facing then
    turtle.facing = getOrientation()
end

location = getLocation(5)

home = vector.new(-247,2,2)

dest = home - location -- destination
print("location: ",location)
print("home: ",home)
print("destination: ",dest)

--[[
print(facing)

turn.to(4)

print(facing)
]]
tunnelMove = move
tunnelMove.forward = move.tunnel
Goto.position(dest,"z",false,tunnelMove)
turn.to(4)
print(getLocation(5))