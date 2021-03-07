--http://www.computercraft.info/forums2/index.php?/topic/1704-get-the-direction-the-turtle-face/

function getOrientation()
    local loc1 = vector.new(gps.locate(2, false))
    if not turtle.forward() then
        for j=1,6 do
            local status,error = turtle.forward()
            if not status then
                if error == "Movement obstructed" then
                    turtle.dig()
                elseif error == "Out of fuel" then
                    error("No fuel. Refuel manually to use the orientation Function")
                end
            else break end
        end
    end
    local loc2 = vector.new(gps.locate(2, false))
    local heading = loc2 - loc1
    return ((heading.x + math.abs(heading.x) * 2) + (heading.z + math.abs(heading.z) * 3))
end

function getLocation(timeout,debug)

    local x,y,z = gps.locate(timeout,debug)

    if x then
        return vector.new(x,y,z)
    else
        error("Can't locate GPS")
    end
end

function updateLocation()
    turtle.location = getLocation(5)
end

if offlineCoordination then
    updateLocation = function() return end
end


--[[orientation will be:
-x = 1
-z = 2
+x = 3
+z = 4
This matches exactly with orientation in game, except that Minecraft uses 0 for +z instead of 4.
--]]
