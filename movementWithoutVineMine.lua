--[[
-x = 1
-z = 2
+x = 3
+z = 4
]]

nilfunc = function() return end



TT1 = require("fuelCheck") -- if you don't want or need this then just remove this

if not TT1 then
    refuelItself = nilfunc
end


--- config ---
blacklist = {
    "chest",
    "turtle"
}
veinMiningEnabled = true
--------------

-- Turn functions
turn = {}
function turn.left()
    facing = facing - 1
    if facing < 1 then facing = 4 end
    turtle.turnLeft()
end

function turn.right()
    facing = facing + 1
    if facing > 4 then facing = 1 end
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
    local turnnum = direction - facing
    print(turnnum)
    directionList[turnnum]()
end

-- Dig functions
dig = {}
function dig.main(Tinspect,Tdig)
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
            Tdig() -- turtle.digDIRECTION()
        end
    end
end

function dig.forward()
    dig.main(turtle.inspect, turtle.dig)
end

function dig.up()
    dig.main(turtle.inspectUp, turtle.digUp)
end

function dig.down()
    dig.main(turtle.inspectDown, turtle.digDown)
end



-- Movement functions
move = {}
function move.main(Tmove,digFunc)
    while true do -- while the turtle isn't moving try to make the way clear by digging
        moved,error = Tmove()
        if moved then return end
        if error == "Movement obstructed" then
            digFunc()
        elseif error == "Out of fuel" then
            refuelItself()
        end
    end
end

function move.forward()
    move.main(turtle.forward, dig.forward)
end

function move.up()
    move.main(turtle.up, dig.up)
end

function move.down()
    move.main(turtle.down, dig.down)
end

function move.tunnel()
    move.main(turtle.forward, dig.forward)
    dig.up()
end

function move.line(moveFunc,number) -- one move function like move.forward or even move.tunnel,how many times to walk it |repeating a process to walk a line
    for i=1,number do
        moveFunc()
    end
end