--[[
-x = 1
-z = 2
+x = 3
+z = 4
]]

require("Stripping")
-- config
strip.nextStrip = 3
strip.strips = 7
strip.stripDepthLeft = 10
strip.stripDepthRight = 3
inv.chestItemsPos = vector.new(0,0,3)
inv.chestItemsDir = 4



InitialisePosition(true)
inv.homePosition = strip.startPosition

strip.LocationsToGo = {}
calculateWholeStrip(strip.LocationsToGo)

printWholeList(strip.LocationsToGo,0)

execute45(strip.LocationsToGo)


turn.to(strip.startFacing)