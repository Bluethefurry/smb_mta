local alpha = 100 -- MARKER ALPHA

function table.removeValue(theTable,value)
	for index, tableVal in ipairs(theTable) do
		if tableVal == value then
			table.remove(theTable,index)
		end
	end
end
function getPositionFromElementOffset(element,offX,offY,offZ)
	local m = getElementMatrix ( element ) -- Get the matrix
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1] -- Apply transform
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	return x, y, z -- Return the transformed point
end

local streamedInCars = {}
function onCarStreamIn()
	if getElementType(source) ~= "vehicle" then return end
	if getVehicleType(source) ~= "Automobile" then return end
	table.removeValue(streamedInCars,source)
	table.insert(streamedInCars,source)
end
addEventHandler("onClientElementStreamIn",root,onCarStreamIn)


function onCarStreamOut()
	if getElementType(source) ~= "vehicle" then return end
	destroyDataElement(source,getElementData(source,"lfblinker"))
	destroyDataElement(source,getElementData(source,"rfblinker"))
	destroyDataElement(source,getElementData(source,"rrblinker"))
	destroyDataElement(source,getElementData(source,"lrblinker"))
	table.removeValue(streamedInCars,source)
end
addEventHandler("onClientElementStreamOut",root,onCarStreamOut)
addEventHandler("onClientElementDestroy",root,onCarStreamOut)



function addAllStreamedInCars()
	for _, veh in ipairs(getElementsByType("vehicle")) do
		if isElementStreamedIn(veh) and getVehicleType(veh) == "Automobile" then
			table.insert(streamedInCars,veh)
		end
	end
end
addAllStreamedInCars()

function destroyDataElement(element,data)
	if not element or not isElement(element) then return end
	if not data then return end
	if not getElementData(element,data) then return end
	if isElement(getElementData(element,data)) then
		destroyElement(getElementData(element,data))
	end
	setElementData(element,data,false,false)
end

function destroyCoronaElement(element,data)
	if not element or not isElement(element) then return end
	if not getElementData(element,data) then return end
	if isElement(getElementData(element,data)) then
		exports.custom_coronas:destroyCorona(getElementData(element,data))
	end
	setElementData(element,data,false,false)
end



function handleAllVehicles()
	for _, veh in ipairs(streamedInCars) do
		checkifBlinking(veh)
	end
end
addEventHandler("onClientRender",root,handleAllVehicles)



function getVehicleGear(veh) 
	if (veh) then
		local vehicleGear = getVehicleCurrentGear(veh)
		return tonumber(vehicleGear)
	else
		return 0
	end
end


function drawCoronaPosition(veh)
	local model = getElementModel(veh)
	local corona1,corona2,corona3,corona4 = getElementData(veh,"lfblinker"), getElementData(veh,"rfblinker"),getElementData(veh,"lrblinker"), getElementData(veh,"rrblinker")
	
	corona1x,corona1y,corona1z = getPositionFromElementOffset(veh,blinker_table[model .. "blinkerFrontx"],blinker_table[model .. "blinkerFronty"],blinker_table[model .. "blinkerFrontz"])
	corona2x,corona2y,corona2z = getPositionFromElementOffset(veh,blinker_table[model .. "blinkerRearx"],blinker_table[model .. "blinkerReary"],blinker_table[model .. "blinkerRearz"])
	exports.custom_coronas:setCoronaPosition(corona1,corona1x,corona1y,corona1z)
	exports.custom_coronas:setCoronaPosition(corona2,corona2x,corona2y,corona2z)
	
	corona3x,corona3y,corona3z = getPositionFromElementOffset(veh,blinker_table[model .. "blinkerFrontx"]-blinker_table[model .. "blinkerRearx"]*2,blinker_table[model .. "blinkerFronty"],blinker_table[model .. "blinkerFrontz"])
	corona4x,corona4y,corona4z = getPositionFromElementOffset(veh,blinker_table[model .. "blinkerRearx"]-blinker_table[model .. "blinkerRearx"]*2,blinker_table[model .. "blinkerReary"],blinker_table[model .. "blinkerRearz"])
	exports.custom_coronas:setCoronaPosition(corona3,corona3x,corona3y,corona3z)
	exports.custom_coronas:setCoronaPosition(corona4,corona4x,corona4y,corona4z)
	
	
	
	
	
	
end



function enableHazards(cmd,state)
	local veh = getPedOccupiedVehicle(localPlayer)
	if state == "true" then
		
		if getElementData(veh,"hazardsActive") then return end
		
		blinkTimer = setTimer(function()
			local blinkState = getElementData(getPedOccupiedVehicle(localPlayer),"hazards")
			setElementData(veh,"hazards",not blinkState)
			setElementData(veh,"hazardsActive",true)
		end,1000,0)
		
		
	else
		setElementData(veh,"hazards",false)
		killTimer(blinkTimer)
		setElementData(veh,"hazardsActive",false)
	end
end
addCommandHandler("hazards", enableHazards,false,false)




function onVehLeave(thePlayer)
if thePlayer == localPlayer then
		destroyCoronaElement(source,"lfblinker")
		destroyCoronaElement(source,"rfblinker")
		destroyCoronaElement(source,"lrblinker")
		destroyCoronaElement(source,"rrblinker")
		setElementData(source,"hazards",false)
		killTimer(blinkTimer)
		setElementData(source,"hazardsActive",false)

end
end
addEventHandler("onClientVehicleExit", getPedOccupiedVehicle(localPlayer), onVehLeave)


function checkifBlinking(veh)
	local ped = getVehicleOccupant(veh,0)
	if not ped then return end
	local model = getElementModel(veh)
	if not blinker_table[model .. "blinkerFrontx"] then return end
	if getElementData(veh, "hazards") then
		if not isElement(getElementData(veh,"lfblinker")) then
			setElementData(veh,"lfblinker",exports.custom_coronas:createCorona(1, 1, 1, 0.4, 255, 191, 0,alpha),false)
			setElementData(veh,"rfblinker",exports.custom_coronas:createCorona(1, 1, 1, 0.4, 255, 191, 0,alpha),false)
			setElementData(veh,"lrblinker",exports.custom_coronas:createCorona(1, 1, 1, 0.4, 255, 191, 0,alpha),false)
			setElementData(veh,"rrblinker",exports.custom_coronas:createCorona(1, 1, 1, 0.4, 255, 191, 0,alpha),false)
			
		end
		drawCoronaPosition(veh)
	end
	if getElementData(veh, "hazards") == false then
		destroyCoronaElement(veh,"lfblinker")
		destroyCoronaElement(veh,"rfblinker")
		destroyCoronaElement(veh,"lrblinker")
		destroyCoronaElement(veh,"rrblinker")
	end
end