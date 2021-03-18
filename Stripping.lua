--[[
-x = 1
-z = 2
+x = 3
+z = 4
]]

require("getDirection")
require("gotoGPS")
require("movement")
-- config --
strip = {
    nextStrip = 3, -- 3 blocks in front to the next strippin mine. 2 blocks appart to each other strip
    stripDepthLeft = 11, -- how deep to go into the strips
    stripDepthRight = 11,
    strips = 5, -- how many stips to do. nextStrip * strips = forward length of the whole strip mining in blocks
    startPosition = "current", -- put in a vector as vector.new(x,y,z) or a string named "current" for the curernt position
    startFacing = "current", -- same here but just use an integer from 1 to 4
    miningMode = move.tunnel -- move.tunnel or move.forward
}
--[[
if not torch then 
    torch = {} 
    torch.TorchList = {}
end]]

--torch.active = true

----------------

strip.positionsList = {}

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

    -- does nothing now
    table.insert(strip.positionsList,{name = "home",position = strip.startPosition})
end
--Goto.position(dest,"z",false,tunnelMove)

strip.LocationsToGo = {}

function insertPos(list,position,torched)
    table.insert(list,{ position = position,
                                       torch = torched})
end

function calc(vPos,vFacing,distance,direction)
    vFacing = dryTurn[direction](vFacing) -- virtually turning left or right
    vPos = vPos + vectorFacing[vFacing](distance) -- calculating distance to
    return vPos
end

-- use this when you place torches on the main path. It will fill the rest of the light to the strips
function calcTorch(vPos,vFacing,distance,direction)
    vFacing = dryTurn[direction](vFacing)
    if distance > 6 then
        print("distance is above 6")
        -- move virtually 6 blocks to the edge of the light
        vPos = vPos + vectorFacing[vFacing](6)
        -- subtract that distance from our distance to the end
        distance = distance - 6
        while distance > 0 do
            -- if the distance can reach the full length of the torch light
            if distance >= 7 then
                -- move the full light of the torch
                vPos = vPos + vectorFacing[vFacing](7)
                -- add that position to our torch list
                torch.TorchList[tostring(vPos)] = true
                -- subtract that distance from our distance to the end
                distance = distance - 7
                -- if our distance to the end can reach 7 blocks then we need to cover that light (6 covers all the light)
                if distance > 6 then
                    -- move to the edge of the light and repeat everything
                    vPos = vPos + vectorFacing[vFacing](6)
                    distance = distance - 6
                else
                    return -- if it can't reach after the edge of the light than we don't need to place more torches
                end
            else
                -- if it can't reach the full light distance then place the torch with the remaining distance
                vPos = vPos + vectorFacing[vFacing](distance)
                torch.TorchList[tostring(vPos)] = true
                return
            end
        end
    end
end

-- calculates the distance to the torches to fill the main path with light also
function calcTorch2(vPos,vFacing,distance,direction,distanceCloseTorch)
    vFacing = dryTurn[direction](vFacing)
    if distance > distanceCloseTorch then
        -- move virtually 5 blocks to place the next torch that will fill the way with light
        vPos = vPos + vectorFacing[vFacing](distanceCloseTorch)
        -- add that position to our torch list
        torch.TorchList[tostring(vPos)] = true
        -- subtract that distance from our distance to the end
        distance = distance - distanceCloseTorch
        while distance > 0 do
            if distance > 6 then
                -- move to the edge of the light
                vPos = vPos + vectorFacing[vFacing](6)
                distance = distance - 6

                if distance >= 7 then
                    -- move the full light of the torch
                    vPos = vPos + vectorFacing[vFacing](7)
                    -- add that position to our torch list
                    torch.TorchList[tostring(vPos)] = true
                    -- subtract that distance from our distance to the end
                    distance = distance - 7
                else
                    -- if it can't reach the full light distance then place the torch with the remaining distance
                    vPos = vPos + vectorFacing[vFacing](distance)
                    torch.TorchList[tostring(vPos)] = true
                    return
                end
            else
                return
            end
        end
    else
        if distance > 0 then
            -- if it can't reach the full light distance then place the torch with the remaining distance
            vPos = vPos + vectorFacing[vFacing](distance)
            torch.TorchList[tostring(vPos)] = true
            return
        end
    end
end


function calculateWholeStrip(list)
    local virtualFacing = strip.startFacing
    local virtualPosition = strip.startPosition
    print("virtualPosition:",strip.startFacing)
    print(virtualFacing,turtle.facing,virtualPosition)
    --[[2blocks = 5distance
        4blocks = 4distance
        6blocks = 3distance

        2/2 = 1   6-1 = 5
        4/2 = 2   6-2 = 4
        5/2 = 2.5 6-2.5 = 3.5 floor(3.5) = 3
        6/2 = 3   6-3 = 3    ]]
    distanceCloseTorch = math.floor(6-((strip.nextStrip-1)/2))
    -- for every strip do
    for blockDistance=1,strip.strips do
        --------------------------------------------------------------------
        -- calculate the next position to the mid point of the stripping
        -- insert the position into a list and continue from the virtualPosition again going to the sides and back>> Repeat
        --------------------------------------------------------------------

        -- Next Middle Point
        --------------------
        local midPoint = virtualPosition + vectorFacing[virtualFacing](strip.nextStrip)
        virtualPosition = midPoint -- save the midpoint as current "virtual" position
        insertPos(list,virtualPosition,false) -- insert the position into a execute list
        torch.TorchList[tostring(vector.new(virtualPosition))] = true
        -- Left Entrace
        ---------------
        leftPoint = calc(midPoint,strip.startFacing,strip.stripDepthLeft,"left") -- going left
        insertPos(list,leftPoint,false)
        calcTorch2(midPoint,strip.startFacing,strip.stripDepthLeft,"left",distanceCloseTorch)
        
        -- Old Middle Point
        -------------------
        insertPos(list,midPoint,true) -- going back to the midPoint


        -- Right Entrace
        ----------------
        rightPoint = calc(midPoint,strip.startFacing,strip.stripDepthRight,"right") -- going right
        insertPos(list,rightPoint,false)
        calcTorch2(midPoint,strip.startFacing,strip.stripDepthRight,"right",distanceCloseTorch)

        -- Old Middle Point
        -------------------
        insertPos(list,midPoint,true) -- going back to the midPoint
    end
end

function initHomeAxis()
    -- get the main axis (x axis or y axis) so the turtle will always try to go the main path and then to the sides regardless where.
    strip.mainAxis = Goto.getAxis(strip.startFacing)
    strip.oppositeMainAxis = Goto.getAxis(dryTurn.left(strip.startFacing))
end

function isGoingFromHome(position)
    -- compare if the startPosition (aka home) axis and the target position axis are the same.
    -- with this method we can know if we are going to that position or from, which is needed for the Goto library.
    if strip.startPosition[strip.oppositeMainAxis] == position[oppositeMainAxis] then
        --goingFromPosition = true
        return true
    else
        --goingFromPosition = false
        return false
    end
end

function execute45(LocationsToGo)

    initHomeAxis()

    for i,v in pairs(LocationsToGo) do
        -- compare if the startPosition (aka home) axis and the target position axis are the same.
        -- this feature is obsolete because we actually go straight lines
        print(v.position,turtle.location)
        if v.torch then
            turtle.inverted = true
            turtle.facing = dryTurn.back(turtle.facing)
            Goto.position(v.position,strip.mainAxis,isGoingFromHome(v.position),move.backTorchedDown)
            turtle.facing = dryTurn.back(turtle.facing)
            turtle.inverted = false
        else
            Goto.position(v.position,strip.mainAxis,isGoingFromHome(v.position),move.tunnel)
        end
    end
end


