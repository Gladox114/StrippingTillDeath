require("Stripping")

InitialisePosition()

strip.LocationsToGo = {}
calculateWholeStrip(strip.LocationsToGo)

printWholeList(strip.LocationsToGo)

execute45(strip.LocationsToGo)

turn.to(strip.startFacing)