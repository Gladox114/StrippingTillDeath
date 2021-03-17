
--require("gotoGPS")

torch = {}
torch.TorchList = {}
torch.itemPlace = 2
torch.name = "minecraft:torch"


function torch.checkTorch(facing)
    for torchLocation in pairs(torch.TorchList) do
        print(tostring(turtle.location + cachedVectorFacing[facing]),torchLocation)
        if tostring(turtle.location + cachedVectorFacing[facing]) == torchLocation then
            return true
        end
    end
    return false
end

function torch.placeTorch(Tplace,facing)
    print("Checking for torch")
    if torch.checkTorch(facing) then
        print("Torch spot found")
        turtle.select(2)
        local itemSlot = turtle.getItemDetail()
        if itemSlot then
            if itemSlot["name"] == torch.name then
                print("Torch placed: ",Tplace)
                turtle[Tplace]()
                torch.TorchList[tostring(turtle.location + cachedVectorFacing[facing])] = false
            end
        end
    end
    print("done")
end

