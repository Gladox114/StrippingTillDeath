

vectorFacing = {
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