test = {
    ["-248,2,-8"] = {ore = true},
    ["-250,2,2"] = {ore = true},
    ["-230,2,0"] = {ore = false}
}

function getLocation(timeout,debug)

    x,y,z = gps.locate(timeout,debug)

    if x then
        return vector.new(x,y,z)
    else
        error("Can't locate GPS")
    end
end

turtle.location = getLocation(5)
if not turtle.location then
    error("couldn't find location")
end

function stringToVector(vectorString)
    return vector.new(string.gmatch(vectorString, "([^,]+),([^,]+),([^,]+)")()) 
end

function calculateDistance(vector1,vector2)
    vector3 = vector1-vector2  -- subtract each other
    distance = vector3:length()  -- the squareroot of summed up squared coordinates | squareroot(x²+y²+z²)
    return distance
end

function getDistancetoAll(list)
    for i,v in pairs(list) do
        test[i].distance = calculateDistance(turtle.location,stringToVector(i))
    end
end

function getTheLowest(list)
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

function onlyOresList(list)
    local newTable = {}
    for coord,values in pairs(list) do
        if values.ore == true then
            newTable[coord] = values
        end
    end
    return newTable
end


onlyOres = onlyOresList(test)
getDistancetoAll(onlyOres)


for i,v in pairs(onlyOres) do
    if type(v) == "table" then
        for z,a in pairs(v) do
            print(i,z,a)
        end
    else
        print(i,v)
    end
end

nearest = getTheLowest(onlyOres)
print(nearest)