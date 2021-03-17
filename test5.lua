--[[
-x = 1
-z = 2
+x = 3
+z = 4
]]

require("Stripping")
-- config
strip.nextStrip = 3
strip.strips = 20
strip.stripDepthLeft = 10
strip.stripDepthRight = 10
inv.chestItemsPos = vector.new(0,0,1)
inv.chestItemsDir = 4



InitialisePosition(true)
inv.homePosition = strip.startPosition

strip.LocationsToGo = {}
calculateWholeStrip(strip.LocationsToGo)

--printWholeList(strip.LocationsToGo,0)

execute45(strip.LocationsToGo)


turn.to(strip.startFacing)
