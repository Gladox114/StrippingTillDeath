

-- config --
orelist = { -- the script will scan the words in the name of the block and mine it
    "_ore", -- Don't use "ore" when you have mods like wild_explORErer because that will mine every block of that mod
    "ore_"
}

-- If false then "turtle.location" will be updated with GPS when needed.
-- if true then it needs to know where it is like calculating the coordination with every step.
offlineCoordination = true 
------------

Vdig = {}
shouldCheck = true
function Vdig.main(Tinspect,Tdig)
    local isblock, block = Tinspect()
    if isblock then -- if the block isn't air then
        local ore = false
        local blacklisted = false
        for i,name in pairs(blacklist) do -- check for every blacklisted word and if there is one then don't dig, else otherwise
            if string.find(block["name"],name) then
                blacklisted = true
                break
            end
        end
        if blacklisted == false then
            if shouldCheck then
                if not inv.checkInv(block["name"]) then
                    shouldCheck = false
                    local saveLocation_diging = turtle.location
                    local saveFacing_diging = turtle.facing
                    -- go to the last savePoint where the first ore was found (back on track) --
                    local dest = saveLocation_VeinMining - turtle.location
                    Goto.facingFirst(dest,Vmove,turtle.facing)
                    -- going home --
                    -- function from "Stripping.lua"
                    local goingFromPosition = isGoingFromHome(turtle.location)
                    dest = strip.startPosition - turtle.location
                    Goto.position(dest, strip.mainAxis, goingFromPosition, Vmove)

                    inv.gotoChest()

                    -- going home --
                    -- function from "Stripping.lua"
                    local goingFromPosition = isGoingFromHome(turtle.location)
                    dest = strip.startPosition - turtle.location
                    Goto.position(dest, strip.mainAxis, goingFromPosition, Vmove)

                    -- go to the last savePoint where the first ore was found (back on track) --
                    local dest = saveLocation_VeinMining - turtle.location
                    Goto.position(dest, strip.mainAxis, true,Vmove)


                    local dest = saveLocation_diging - turtle.location
                    Goto.facingFirst(dest,Vmove,turtle.facing)

                    turn.to(saveFacing_diging)
                    Tdig()
                    shouldCheck = true
                else
                    Tdig() -- turtle.digDIRECTION()
                end
            else
                Tdig()
            end
        end
    end
end

function printWholeList(list,speed)
    for i,v in pairs(list) do
        if speed ~= 0 then
            os.sleep(speed)
        end
        if type(v) == "table" then
            for z,a in pairs(v) do
                print(i,z,a)
            end
        else
            print(i,v)
        end
    end
end


--function printWholeList(list) for i,v in pairs(list) do os.sleep(yees) if type(v) == "table" then for z,a in pairs(v) do print(i,z,a) end else print(i,v) end end end

Vdig.forward =   function() Vdig.main(turtle.inspect, turtle.dig) end
Vdig.up =        function() Vdig.main(turtle.inspectUp, turtle.digUp) end
Vdig.down =      function() Vdig.main(turtle.inspectDown, turtle.digDown) end

Vmove = {}

Vmove.forward =  function() move.main("forward", Vdig.forward) end
Vmove.up =       function() move.main("up", Vdig.up) end
Vmove.down =     function() move.main("down", Vdig.down) end


function scanOre(blockname)
    for i,name in pairs(orelist) do
        if string.find(blockname,name) then
            print(name)
            return true
        end
    end
    return false
end

inspectDirection = {
    up = turtle.inspectUp,
    down = turtle.inspectDown,
    forward = turtle.inspect,
    left = function() turn.left() local a,b=turtle.inspect() turn.right() return a,b end,
    right = function() turn.right() local a,b=turtle.inspect() turn.left() return a,b end,
    back = function() turn.leftTwice() local a,b=turtle.inspect() turn.leftTwice() return a,b end
}

vectorFacing = { -- same included in movement
--          x,y,z
vector.new(-1,0,0), -- ore is from your position facing to -x
vector.new(0,0,-1), -- block is facing -z
vector.new(1,0,0), -- block is facing +x
vector.new(0,0,1), -- +z

vector.new(0,1,0), -- +y
vector.new(0,-1,0) -- -y
}



getBlockPos = {
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
    },
    main = function(facing) -- saving some bytes | I'm actually lazy to write it into each function
        return turtle.location+vectorFacing[facing]
    end,

    forward = function() return getBlockPos.main(turtle.facing) end,
    left = function() return getBlockPos.main(getBlockPos.dryTurn.left(turtle.facing)) end,
    right = function() return getBlockPos.main(getBlockPos.dryTurn.right(turtle.facing)) end,
    back = function() return getBlockPos.main(getBlockPos.dryTurn.left(getBlockPos.dryTurn.left(turtle.facing))) end,

    up = function() return turtle.location+vectorFacing[5] end,
    down = function() return turtle.location+vectorFacing[6] end
}

directionalOrder = {
    "forward",
    "left",
    "right",
    "up",
    "down",
    "back"
}

-- check if block back is already in mappedOre or mappedWalked list. If yes then don't scan it
mapping = {}

mapping.mappedOre = {}
mapping.onlyOres = {}

-- Returns a vector from a string --
------------------------------------
-- sources that helped --
-- https://stackoverflow.com/questions/19262761/lua-need-to-split-at-comma
-------------------------
function mapping.stringToVector(vectorString)
    if vectorString then
        return vector.new(string.gmatch(vectorString, "([^,]+),([^,]+),([^,]+)")())
    end
end

-- Returns the distance between two vectors --
----------------------------------------------
-- sources that helped --
-- https://www.varsitytutors.com/calculus_3-help/distance-between-vectors
-- http://www.computercraft.info/wiki/VectorA:length
-------------------------
function mapping.calculateDistance(vector1,vector2)
    vector3 = vector1-vector2  -- subtract each other
    distance = vector3:length()  -- the squareroot of summed up squared coordinates | squareroot(x²+y²+z²)
    return distance
end

function mapping.getDistancetoAll(list)
    for i,v in pairs(list) do
        list[i].distance = mapping.calculateDistance(turtle.location,mapping.stringToVector(i))
    end
end

--                            table
function mapping.getTheLowest(list)
    local lowestValue = math.huge
    local lowestIndex
    for i,v in pairs(list) do
        if v.distance < lowestValue then
            lowestIndex = i
            lowestValue = v.distance
        end
    end
    return lowestIndex
end

function mapping.onlyOresList(list)
    local newTable = {}
    for coord,values in pairs(list) do
        if values.ore == true then
            newTable[coord] = values
        end
    end
    return newTable
end

-- Returns vector to closest ore --
--------------------------------------
-- Calculates Ores to all distances --
-- and returns the closest ore      --
--------------------------------------
function mapping.getNearestOre()
    mapping.onlyOres = mapping.onlyOresList(mapping.mappedOre) -- sorting the active ores (not mined) out and putting them into a list
    mapping.getDistancetoAll(mapping.onlyOres)
    return mapping.stringToVector(mapping.getTheLowest(mapping.onlyOres))
end

-- Returns a boolean --
------------------------------------------------------
-- Function checks if the object exists in the list.--
-- It also provides a state check. When true then   --
-- only true items in the list are checked.         --
-- If your list doesn't provide a direct boolean    --
-- but a table then there is a stateVariableName to --
-- find that boolean                                --
------------------------------------------------------
--                 vector, table with strings, boolean*   , string*
function checkList(object, list              , activeState, stateVariableName) 

    for item,state in pairs(list) do

        if stateVariableName then
            state = state[stateVariableName]
        end

        if object:tostring() == item then
            if not activeState then
                --print("z",item,state)
                return true 
            elseif state == true then
                --print("z",item,state)
                return true
            end
        end
    end
    return false
end

function updateLocation()
    turtle.location = getLocation(5)
end

if offlineCoordination then
    updateLocation = function() return end
end

function scanSurrounding()
    updateLocation()
    -- for every direction 
    for i,direction in pairs(directionalOrder) do
        print(direction)
        print(turtle.location,turtle.facing)
            -- get position of that directional block without rotating and moving
        local blockPosition = getBlockPos[direction]()
        print("1")
            -- check if you already scanned that block. If not then rotate and inspect that ore
        if checkList(blockPosition,mapping.mappedOre) == false then
            -- inspect that ore and return info
            local isblock, block = inspectDirection[direction]()
            if not mapping.mappedOre[blockPosition:tostring()] then
                mapping.mappedOre[blockPosition:tostring()] = {}
            end
            if isblock then
                if scanOre(block["name"]) then
                    print("OreFound: "..direction,blockPosition) -- debug
                    --print(blockPosition:tostring())
                    mapping.mappedOre[blockPosition:tostring()].ore = true
                else
                    mapping.mappedOre[blockPosition:tostring()].ore = false
                end
            else
                mapping.mappedOre[blockPosition:tostring()].ore = false
            end
        else -- debug
            print("OreIsAlreadyScanned: "..i)
        end

    end
    --printWholeList(mapping.mappedOre) -- debug
end

--[[
function scanSurrounding2()

end
]]

digDirection = {
    left = function() turn.left() Vmove.forward() end,
    right = function() turn.right() Vmove.forward() end,
    forward = Vmove.forward,
    up = Vmove.up,
    down = Vmove.down,
    back = function() turn.rightTwice() Vmove.forward() end
}

function mineNearestOre() -- |if you move the turtle then this function still things it is in the old position when turtle.location isn't updated
    -- for every direction, rotate so far till you find ore,
    -- then mine it and go to it
    for i,direction in pairs(directionalOrder) do

        local blockPosition = getBlockPos[direction]()
        --print("im checking",direction,blockPosition)
        if checkList(blockPosition,mapping.mappedOre,true,"ore") then
            print(direction,"Minin it!")
            digDirection[direction]()

            mapping.mappedOre[blockPosition:tostring()].ore = false -- mark the mined ore as mined
            --count = 0
            --[[
            for z,v in pairs(mapping.mappedOre) do -- debug
                count = count +1
                print(z,v)
            end
            ]]
            --print(count)
            return true

        end
    end
    return false
end



--bug if it's under then the turtle maybe doesn't set it to false

function vinemining()
    saveFacing_VeinMining = turtle.facing
    updateLocation()
    saveLocation_VeinMining = turtle.location
    local distance
    local scan = true
    while true do
        if scan then scanSurrounding() end --scan surround and mark ore 
        scan = mineNearestOre() --return if it should be scanned. When Ore get's mined it is in a new location.
        if scan == false then -- if there was no ore to mine then
            pos = mapping.getNearestOre(mapping.mappedOre) -- get the next closest ore position from the scanned list
            if pos then -- if the list has some ore to mine
                print("going to nearest Ore")
                --updateLocation()
                Goto.facingFirst(pos,Vmove,turtle.facing) -- Fixed |The Goto command mines the Ore but doesn't remove it from the list!!!
                --updateLocation() -- get the location of the current position | or update it
                mapping.mappedOre[turtle.location:tostring()].ore = false -- Remove the ore you went to
            else -- goto last position and continue strip mining or smth
                print("going back to job")
                --updateLocation()
                Goto.position(saveLocation_VeinMining,Goto.getAxis(saveFacing_VeinMining),false,Vmove)
                turn.to(saveFacing_VeinMining)
                break
            end
        end

    end
end

