
local tanker1 = TankerIA:new({
    plane = "KC135", 
    alt = 20000, 
    knot = 450, 
    frequency = 110, 
    tacan = {frequency = 110, band = "Y", code = "KC1"}, 
    callsign = {name = "Shell", groupeNumber = 1}, 
    takeOffFrom = "Nellis",
    startTo = {startPosition = "KC135-1", endPosition = "KC135-2"},
})


local tanker2 = TankerIA:new({
    plane = "KC135", 
    alt = 18000, 
    knot = 450, 
    frequency = 111, 
    tacan = {frequency = 111, band = "Y", code = "KC2"}, 
    callsign = {name = "Shell", groupeNumber = 2}, 
    takeOffFrom = "Nellis",
    startTo = {startPosition = "KC135-1", endPosition = "KC135-2"}, 
})




local IA = IABlue:new()
IA:SetTankers({tanker1, tanker2})
IA:Init()



local menu = Menu:new()
menu:AddIA(IA)
menu:AddFrequences()
menu:Init()



