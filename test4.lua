require("Stripping")

InitialisePosition(true)

strip.LocationsToGo = {}
calculateWholeStrip(strip.LocationsToGo)

printWholeList(strip.LocationsToGo,0)

execute45(strip.LocationsToGo)

turn.to(strip.startFacing)