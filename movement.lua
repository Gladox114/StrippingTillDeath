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

TT1 = require("fuelCheck") -- if you don't want or need this then just remove this or don't put in the file
TT2 = require("veinMining")


if not TT1 then
    fuel.refuelItself = nilfunc
    print("Movement: fuelCheck not loaded")
end
if not TT2 then
    veinminer.scanOre = nilfunc
    veinminer.vinemining = nilfunc
    print("Movement: veinmining not loaded")
end



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
function dig.main(Tinspect,Tdig)
    local isblock, block = Tinspect()
    if isblock then -- if the block isn't air then
        local blacklisted = false
        for i,name in pairs(blacklist) do -- check for every blacklisted word and if there is one then don't dig, else otherwise
            if string.find(block["name"],name) then
                blacklisted = true
                break
            end
        end
        if blacklisted == false then
            if scanOre(block["name"]) then -- if it's ore
                vinemining()
            else
                Tdig() -- turtle.digDIRECTION()
            end
        end
    end
end


dig.forward =   function() dig.main(turtle.inspect, turtle.dig) end
dig.up =        function() dig.main(turtle.inspectUp, turtle.digUp) end
dig.down =      function() dig.main(turtle.inspectDown, turtle.digDown) end


-- Movement functions
move = {}
function move.main(Tmove,digFunc)
    while true do -- while the turtle isn't moving try to make the way clear by digging
        local moved,error = Tmove()
        if moved then return end
        if error == "Movement obstructed" then
            digFunc()
        elseif error == "Out of fuel" then
            fuel.refuelItself()
        end

        -- check if inventory is full

    end
end

move.forward =  function() move.main(turtle.forward, dig.forward) end
move.up =       function() move.main(turtle.up, dig.up) end
move.down =     function() move.main(turtle.down, dig.down) end


move.tunnel = function()
    move.main(turtle.forward, dig.forward)
    dig.up()
end

move.line = function(moveFunc,number) -- one move function like move.forward or even move.tunnel,how many times to walk it |repeating a process to walk a line
    for i=1,number do
        moveFunc()
    end
end

