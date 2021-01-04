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
    startPosition = "current", -- put in a vector or a string named "current" for the curernt position
    startFacing = "current", -- same here
    miningMode = move.tunnel -- move.tunnel or move.forward
}

torch = {
    active = true,
    direction = turtle.placeUp
}
----------------

--turtle.facing = 1 -- If this value is wrong then your turtle is drunk. It can even happen that it goes into infinity trying to reach it's own destination or smth. I can't read minds
function InitialisePosition() --setup
    if not turtle.facing then
        turtle.facing = getOrientation()
    end

    turtle.location = getLocation(5)

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
    vPos = virtualPosition + strip.vectorFacing[vFacing](distance) -- calculating distance to
    return vPos
end

function funcRight(vPos,vFacing,distance)
    vFacing = dryTurn.right(vFacing) -- virtually turning left
    vPos = vPos + strip.vectorFacing[vFacing](distance) -- calculating distance to
    return vPos
end

function calculateWholeStrip(list)
    virtualFacing = strip.startFacing
    virtualPosition = strip.startPosition
    print(virtualFacing,turtle.facing,virtualPosition)
    for blockDistance=1,strip.strips do -- for every stip thing do
        midPoint = virtualPosition + strip.vectorFacing[virtualFacing](strip.nextStrip) -- calculate the next position
        virtualPosition = midPoint 
        insertPos(list,virtualPosition,false) -- insert the position

        leftPoint = funcLeft(midPoint,strip.startFacing,strip.stripDepthLeft) -- going left
        insertPos(list,leftPoint,false)
        -- Insert here Torch Positions
        rightPoint = funcRight(midPoint,strip.startFacing,strip.stripDepthRight) -- going right
        insertPos(list,rightPoint,false)
        -- Insert here Torch Positions
        insertPos(list,midPoint,false) -- going back to the midPoint
    end
end

function execute45(LocationsToGo)

    mainAxis = Goto.getAxis(strip.startFacing)
    oppositeMainAxis = Goto.getAxis(dryTurn.left(strip.startFacing))
    for i,v in pairs(LocationsToGo) do
        updateLocation()

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


