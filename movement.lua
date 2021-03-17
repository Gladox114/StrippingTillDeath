--[[
-x = 1
-z = 2
+x = 3
+z = 4
]]


--- config ---
blacklist = {
    "chest",
    "turtle"
}
veinMiningEnabled = true
--------------


-- Calling Requirements
nilfunc = function() return end

fuel = {}
veinminer = {}
torch = {}

TT1 = require("fuelCheck") -- if you don't want or need this then just remove this or don't put in the file
TT2 = require("veinMining")
TT3 = require("invCheck")
TT4 = require("torch")
if not TT1 then
    fuel.refuelItself = nilfunc
    print("Movement: fuelCheck not loaded")
end
if not TT2 then
    veinminer.scanOre = nilfunc
    veinminer.vinemining = nilfunc
    print("Movement: veinmining not loaded")
end
if not TT3 then
    inv.checkInv = nilfunc
    print("Movement: InvCheck not loaded")
end
if not TT4 then
    torch.placeTorch = nilfunc
    print("Movement: Torch not loaded")
end

cachedVectorFacing = {
    --          x,y,z
    vector.new(-1,0,0), -- ore is from your position facing to -x
    vector.new(0,0,-1), -- block is facing -z
    vector.new(1,0,0), -- block is facing +x
    vector.new(0,0,1), -- +z
    
    vector.new(0,1,0), -- +y
    vector.new(0,-1,0) -- -y
}

vectorFacing = {
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
    end,
    back = function(dryFacing)
        dryFacing = dryFacing + 1
        if dryFacing > 4 then dryFacing = 1 end
        dryFacing = dryFacing + 1
        if dryFacing > 4 then dryFacing = 1 end
        return dryFacing
    end
}

-- Virtual steps --
-- Tracking location without GPS --
virt = { 
    forward = function() turtle.location = turtle.location + cachedVectorFacing[turtle.facing] end,
    up = function() turtle.location = turtle.location + cachedVectorFacing[5] end,
    down = function() turtle.location = turtle.location + cachedVectorFacing[6] end,
    back = function() turtle.location = turtle.location + cachedVectorFacing[turtle.facing] end
    --back = function() turtle.location = turtle.location + cachedVectorFacing[dryTurn.left(dryTurn.left(turtle.facing))] end
}
-------------------


-- Turn functions
turn = {}
function turn.left()
    turtle.facing = turtle.facing - 1
    if turtle.facing < 1 then turtle.facing = 4 end -- If facing under
    turtle.turnLeft()
end

function turn.right()
    turtle.facing = turtle.facing + 1
    if turtle.facing > 4 then turtle.facing = 1 end
    turtle.turnRight()
end

function turn.leftTwice() turn.left() turn.left() end
function turn.rightTwice() turn.right() turn.right() end

directionList = {
    [0] = nilfunc, -- there is nothing to do |if the robot is facing the same target direction then it always gets zero and there is nothing to do

    [1] = turn.right, -- direction is one to the left or right
    [-1] = turn.left,

    [2] = turn.rightTwice, -- direction is behind the turtle
    [-2] = turn.leftTwice,

    [3] = turn.left,  -- direction is one to the left or right but not mathematicly
    [-3] = turn.right
}

function turn.to(direction)
    local turnnum = direction - turtle.facing
    directionList[turnnum]()
end


-- Dig functions
dig = {}
local shouldCheck = true
function dig.inspect(Tinspect)
    local isblock, block = Tinspect()
    if isblock then -- if the block isn't air then
        local blacklisted = false
        -- check for every blacklisted word and if there is one then don't dig, else otherwise
        for i,name in pairs(blacklist) do
            if string.find(block["name"],name) then
                blacklisted = true
                break
            end
        end
        if blacklisted == false then
            if scanOre(block["name"]) then -- if it's ore
                vinemining()
                return false
            else
                if shouldCheck then
                    if not inv.checkInv(block["name"]) then
                        shouldCheck = false
                        local saveLocation = turtle.location
                        local saveFacing = turtle.facing
                        -- go to start position --
                        Goto.position_custom(  strip.startPosition,
                                        strip.mainAxis, -- choose one axis like z or x
                                        isGoingFromHome(turtle.location), -- returns true or false
                                        move)

                        inv.gotoChest()
                        
                        -- go to start position
                        Goto.position_custom(strip.startPosition,strip.mainAxis,isGoingFromHome(turtle.location),move)
                        
                        -- go back to the saved location --
                        Goto.facingFirst_custom(saveLocation,move,turtle.facing)

                        turn.to(saveFacing)
                        shouldCheck = true
                        return true
                    end
                end
                return true
            end
        end
    end
    return false
end

function dig.main(Tinspect,Tdig)
    if dig.inspect(Tinspect) then
        Tdig() -- turtle.digDIRECTION()
    end
end


dig.forward =   function() dig.main(turtle.inspect, turtle.dig) end
dig.up =        function() dig.main(turtle.inspectUp, turtle.digUp) end
dig.down =      function() dig.main(turtle.inspectDown, turtle.digDown) end
dig.back =      function() turn.leftTwice() dig.main(turtle.inspect, turtle.dig) turn.rightTwice() end

-- Movement functions
move = {}
function move.main(MoveDirection,digFunc)
    while true do -- while the turtle isn't moving try to make the way clear by digging
        
        local moved,error = turtle[MoveDirection]()
        if moved then 
            virt[MoveDirection]()
            return
        end
        if error == "Movement obstructed" then
            digFunc()
        elseif error == "Out of fuel" then
            fuel.refuelItself()
        end

    end
end

move.forward =  function() move.main("forward", dig.forward) end
move.up =       function() move.main("up", dig.up) end
move.down =     function() move.main("down", dig.down) end
move.back =     function() move.main("back",dig.back) end
-- same like "move.forward" but also diggin above making a tunnel --
move.tunnel = function()
    move.forward()
    dig.up()
    dig.inspect(turtle.inspectDown)
end

move.bigTunnel = function()
    move.forward()
    dig.up()
    dig.down()
end

move.backTorchedDown = function()
    move.back()
    torch.placeTorch("place",dryTurn.back(turtle.facing))
end

-- repeating one function --
move.line = function(moveFunc,number) -- one move function like "move.forward" or even "move.tunnel",how many times to walk it |repeating a process to walk a line
    for i=1,number do
        moveFunc()
    end
end

