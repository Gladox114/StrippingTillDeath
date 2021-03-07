--[[
-x = 1
-z = 2
+x = 3
+z = 4
]]

require("getDirection")
require("gotoGPS")

-- config --
strip = {
    nextStrip = 3, -- 3 blocks in front to the next strippin mine. 2 blocks appart to each other strip
    stripDepthLeft = 11, -- how deep to go into the strips
    stripDepthRight = 11,
    strips = 5, -- how many stips to do. nextStrip * strips = forward length of the whole strip mining in blocks
    startPosition = "current", -- put in a vector or a string named "current" for the curernt position or the position as vector.new(x,y,z)
    startFacing = "current", -- same here but just use an integer from 1 to 4
    miningMode = move.tunnel -- move.tunnel or move.forward
}

torch = {
    active = true,
    direction = turtle.placeUp
}
----------------

--turtle.facing = 1 -- If this value is wrong then your turtle is drunk. It can even happen that it goes into infinity trying to reach it's own destination or smth. I can't read minds
function InitialisePosition(offlinemode) --setup
    if not turtle.facing then
        if offlinemode then
            turtle.facing = 3
        else
            turtle.facing = getOrientation()
            if turtle.facing == 0 then
                error("Couldn't get Direction from satelites")
            end
        end
    end

    if offlinemode then
        turtle.location = vector.new(0,0,0)
    else
        turtle.location = getLocation(5)
    end

    if strip.startPosition == "current" then
        strip.startPosition = turtle.location
    end
    if strip.startFacing == "current" then
        strip.startFacing = turtle.facing
    end

    strip.move = move -- copy "move" function table
    strip.move.forward = strip.miningMode -- replace forward with your desired forward function like "tunnel"
  
end
--Goto.position(dest,"z",false,tunnelMove)

strip.LocationsToGo = {}

strip.vectorFacing = {
    --          x,y,z
    function(i) return vector.new(-i,0,0) end, -- ore is from your position facing to -x
    function(i) return vector.new(0,0,-i) end, -- block is facing -z
    function(i) return vector.new(i,0,0) end, -- block is facing +x
    function(i) return vector.new(0,0,i) end, -- +z
    
    function(i) return vector.new(0,i,0) end, -- +y
    function(i) return vector.new(0,-i,0) end -- -y
    }

dryTurn = {
    left = function(dryFacing)
        dryFacing = dryFacing - 1
        if dryFacing < 1 then dryFacing = 4 end
        return dryFacing
    end,
    right = function(dryFacing)
        dryFacing = dryFacing + 1
        if dryFacing > 4 then dryFacing = 1 end
        return dryFacing
    end
}

function insertPos(list,position,torched)
    table.insert(list,{ position = position,
                                       torch = torched})
                                       --turning = turning})
end

function funcLeft(vPos,vFacing,distance)
    vFacing = dryTurn.left(vFacing) -- virtually turning left
    vPos = vPos + strip.vectorFacing[vFacing](distance) -- calculating distance to
    return vPos
end

function funcRight(vPos,vFacing,distance)
    vFacing = dryTurn.right(vFacing) -- virtually turning left
    vPos = vPos + strip.vectorFacing[vFacing](distance) -- calculating distance to
    return vPos
end

function calculateWholeStrip(list)
    local virtualFacing = strip.startFacing
    local virtualPosition = strip.startPosition
    print("virtualPosition:",strip.startFacing)
    print(virtualFacing,turtle.facing,virtualPosition)
    -- for every strip do
    for blockDistance=1,strip.strips do
        --------------------------------------------------------------------
        -- calculate the next position to the mid point of the stripping
        -- insert the position into a list and continue from the virtualPosition again going to the sides and back>> Repeat
        --------------------------------------------------------------------

        -- Next Middle Point
        --------------------
        local midPoint = virtualPosition + strip.vectorFacing[virtualFacing](strip.nextStrip)
        virtualPosition = midPoint -- save the midpoint as current "virtual" position
        insertPos(list,virtualPosition,false) -- insert the position into a execute list
  
        -- Left Entrace
        ---------------
        leftPoint = funcLeft(midPoint,strip.startFacing,strip.stripDepthLeft) -- going left
        insertPos(list,leftPoint,false)
        -- INCOMING FEATURE: Insert here Torch Positions
        
        -- Right Entrace
        ----------------
        rightPoint = funcRight(midPoint,strip.startFacing,strip.stripDepthRight) -- going right
        insertPos(list,rightPoint,false)
        -- INCOMING FEATURE: Insert here Torch Positions

        -- Old Middle Point
        -------------------
        insertPos(list,midPoint,false) -- going back to the midPoint
    end
end

function execute45(LocationsToGo)

    -- get the main axis (x axis or y axis) so the turtle will always try to go the main path and then to the sides regardless where.
    mainAxis = Goto.getAxis(strip.startFacing)
    oppositeMainAxis = Goto.getAxis(dryTurn.left(strip.startFacing))
    for i,v in pairs(LocationsToGo) do
        --updateLocation()

        -- compare if the startPosition (aka home) axis and the target position axis are the same.
        -- with this method we can know if we are going to that position or from which is need for the Goto library.
        -- this feature is actually obsolete because we go straight lines
        if strip.startPosition[oppositeMainAxis] == v.position[oppositeMainAxis] then
            goingFromPosition = true
        else
            goingFromPosition = false
        end
        dest = v.position - turtle.location -- get delta to the position you are going to
        print(dest,v.position,turtle.location,goingFromPosition)
        Goto.position(dest,mainAxis,goingFromPosition,strip.move)
    end
end


