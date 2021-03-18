
--config--
inv = {
    chestItemsPos = vector.new(0,0,0), -- don't select the chest position but rather one that is in front of the chest
    chestItemsDir = 4,
    homePosition = vector.new(0,0,0), -- This would be the strip.startLocation or any other location where you started.
    blacklist = {
        "torch",
        "coal"
    },
    realBlocks = {}
}
inv.realBlocks["minecraft:stone"] = "minecraft:cobblestone"
----------

function inv.Space()
    local slotsEmpty = 0
    for i=1,16 do
        if turtle.getItemCount(i) == 0 then
            slotsEmpty = slotsEmpty + 1
        end
    end
    if slotsEmpty == 0 then
        return false
    else return true end
end

function inv.doesItFit(name) -- call this if the inventory is full
    for i=1,16 do
        if turtle.getItemDetail(i)["name"] == name then
            if turtle.getItemSpace() > 0 then
                return true
            end
        end
    end
    return false
end

local emptyInv = {
    function () turn.to(1) turtle.drop() end,
    function () turn.to(2) turtle.drop() end,
    function () turn.to(3) turtle.drop() end,
    function () turn.to(4) turtle.drop() end,

    function () turtle.dropUp() end,
    function () turtle.dropDown() end
}

function inv.checkBlacklisted(object,blacklist)
    for i,name in pairs(blacklist) do
        if string.find(object,name) then
            return true
        end
    end
    return false
end

function inv.emptyFullInv(chestDirection)
    for i=1,16 do
        local currentItem = turtle.getItemDetail(i)
        if currentItem then
            if inv.checkBlacklisted(currentItem["name"],inv.blacklist) == false then
                turtle.select(i)
                emptyInv[chestDirection]()
            end
        end
    end
end

function inv.gotoChest()
     --local saveFacing = turtle.facing
    local saveLocation = turtle.location
    -- goto home first --
     --[[
     --print("test",inv.homePosition,turtle.location)
     local distance = inv.homePosition - turtle.location
     Goto.position(distance,Goto.getAxis(turtle.facing),true,move)
     ]]
    -- goto the chest --
    Goto.facingFirst_custom(inv.chestItemsPos,move,turtle.facing)
    --Goto.position(distance,Goto.getAxis(turtle.facing),true,move)
    
    -- empty yourself --
    inv.emptyFullInv(inv.chestItemsDir)
    --[[
    -- goto home --
    distance = inv.homePosition - turtle.location
    Goto.position(distance,Goto.getAxis(turtle.facing),false,move)
    
    -- Go back to the last saved location --
    distance = saveLocation - turtle.location
    Goto.position(distance,Goto.getAxis(turtle.facing),true,move)
     --turn.to(saveFacing)]]
end

function inv.checkInv(blockName) -- passthrough the blockname as string
    -- check for space
    if inv.Space() == false then
        -- If it still can fit then mine it. If not then go back and empty yourself
        if inv.doesItFit(blockName) == false then -- if the block doesn't fit
            -- return back to chests and empty yourself
            return false
        end
    end
    return true
end

