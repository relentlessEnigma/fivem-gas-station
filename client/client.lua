local player = GetPlayerPed(-1)
local fullTank = 99
local canPay = false
local running = false
local vehicle = nil
local gasPrice = nil
local actualFuelAmount
local payInTotalForFullTank

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsPedInAnyVehicle(player, true) then
            vehicle = GetVehiclePedIsIn(player, true)
        end
        if vehicle ~= nil then
            local vehCoords = GetEntityCoords(vehicle)
            local pedCoords = GetEntityCoords(player)
            vehicle = GetVehiclePedIsIn(player, true)

            if getCoordsDistance() then
                showMenu()
                if IsControlJustPressed(0, 38) then
                    if IsPedInAnyVehicle(player, false) then
                        ESX.ShowNotification("You must be out of the car to fill the tank")    
                    elseif compareDistances(pedCoords, vehCoords, false) < 5 then
                        getCalculationsForUI()
                    else
                        ESX.ShowNotification("You are far from your vehicle")
                    end
                end
            end
        end
    end
end)

function getCalculationsForUI()
    local gasStationName, gasStationAddress = getGasStationPlayerIsIn()
    local petrolTankDamage = GetVehiclePetrolTankHealth(vehicle)/10
    local vehicleMaximumLiters = 100 --hardcoded for now

    actualFuelAmount = GetVehicleFuelLevel(vehicle)
    payInTotalForFullTank = (vehicleMaximumLiters - actualFuelAmount)*gasPrice

    openUI(petrolTankDamage, payInTotalForFullTank)
end

function openUI(tankDamage, payInTotalForFullTank) 
    if(tankDamage < 20 ) then 
        tankDamage = "Damaged!"
        ESX.ShowNotification("Fuel Tank of this car is damaged! Repair it first!")
        return
    end
    if actualFuelAmount >= 99 then
        ESX.ShowNotification("Your car is already with its tank full!")
        return
    end
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "ui",
        visible = true,
        gasPrice = gasPrice,
        tankDamage = tankDamage,
        amountMax = payInTotalForFullTank,
        gasStationName = gasStationName,
        gasStationAddress = gasStationAddress
    })
end

RegisterNUICallback('GasStation:ui-off', function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "ui",
        visible = false
    })
end)

RegisterNUICallback('GasStation:fuel', function(data)

    local quantity = tonumber(data.amount)
    print(data.gasPrice)
    gasPrice = tonumber(data.gasPrice)
    if quantity == "" then
        quantity = 0
        ESX.ShowNotification("Seleciona o valor que queres atestar")
        return
    end

    local finalactualFuelAmount = actualFuelAmount + (quantity*1)/gasPrice
    print("finalactualFuelAmount = actualFuelAmount(" .. actualFuelAmount .. ") + (quantity" .. quantity .. " *1) / gasPrice" .. gasPrice .. " = " .. finalactualFuelAmount)

    local maxGasAllowedInTank = actualFuelAmount + (payInTotalForFullTank*1)/gasPrice
    print("maxGasAllowedInTank = actualFuelAmount(" .. actualFuelAmount .. ") + (payInTotalForFullTank" .. payInTotalForFullTank .. " *1) / gasPrice" .. gasPrice .. " = " .. maxGasAllowedInTank)

    if payGas(quantity) then
        if(finalactualFuelAmount > maxGasAllowedInTank) then
            print("if(finalactualFuelAmount > maxGasAllowedInTank) then SetVehicleFuelLevel(vehicle, maxGasAllowedInTank: " .. maxGasAllowedInTank .. ")")
            SetVehicleFuelLevel(vehicle, maxGasAllowedInTank)
            TriggerServerEvent('GasStation:SaveFuelAmount', GetVehicleNumberPlateText(vehicle), maxGasAllowedInTank)
        else
            SetVehicleFuelLevel(vehicle, finalactualFuelAmount)
            TriggerServerEvent('GasStation:SaveFuelAmount', GetVehicleNumberPlateText(vehicle), finalactualFuelAmount)
        end
        ESX.ShowNotification("Your car is now with " .. string.format("%.0f", GetVehicleFuelLevel(vehicle)) .. "% of fuel")
    end
end)

RegisterNUICallback('GasStation:fuelfull', function()
    local quantity = (100 - actualFuelAmount) * 1 / gasPrice
    if payGas(quantity) then
        SetVehicleFuelLevel(vehicle, fullTank)
        TriggerServerEvent('GasStation:SaveFuelAmount', GetVehicleNumberPlateText(vehicle), fullTank)
        ESX.ShowNotification("Your car is now with " .. string.format("%.0f", GetVehicleFuelLevel(vehicle)) .. "% of fuel")
    end
end)

function payGas(amount)
    running = true
    
    TriggerServerEvent('GasStation:PayGasSV', amount, payInTotalForFullTank)
    while running do
        Wait(200)
    end
    if canPay then
        return true
    end

    ESX.ShowNotification("Sorry! We just take cash and it looks like u dont have it!")
    return false
end

RegisterNetEvent('GasStation:PayGas', function(bool)
    canPay = bool
    running = false
end)

function getCoordsDistance()
    local playerCoords = GetEntityCoords(player)
    local gasStations = Config.GasStations
    
    for j=1, #gasStations.stations, 1 do
        for k=1, #gasStations.stations[j].Poles, 1 do
            if compareDistances(playerCoords, gasStations.stations[j].Poles[k], false) < 1.8 then
                return true
            end
        end
    end

    return false
end

function compareDistances(obj1, obj2, considerZ)
    return GetDistanceBetweenCoords(obj1.x, obj1.y, obj1.z, obj2.x, obj2.y, obj2.z, considerZ)
end

function showMenu()
    SetTextScale(0.6, 0.6)
    SetTextFont(4)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(false)
    AddTextComponentString('Press E to fuel')
    DrawText(0.825, 0.825)    
end

function getGasStationPlayerIsIn()
    local lowestDist = 10000
    local gasStationName = ""
    local gasStationAddress = ""
    local amountOfStations = getTableLenght(Config.GasStations.stations)
    for i=1, amountOfStations, 1 do 
        local playerCoords = GetEntityCoords(player)
        local amountOfPoles = getTableLenght(Config.GasStations.stations[i].Poles)
       
        for j=1, amountOfPoles, 1 do
            local pol = Config.GasStations.stations[i].Poles[j]
            local dist = GetDistanceBetweenCoords(pol.x, pol.y, pol.z, playerCoords.x, playerCoords.y, playerCoords.z)
            if lowestDist > dist then
                lowestDist = dist
                gasStationName = Config.GasStations.stations[i].Name
                gasStationAddress = Config.GasStations.stations[i].Location
                gasPrice = Config.GasStations.stations[i].GasPrice
            end
        end
    end
    return gasStationName, gasStationAddress
end

function getTableLenght(table)
    local size = 0
    for _ in pairs(table) do
        size = size + 1
    end
    return size
end

function isPlayerOwnerOfVehicle(vehicle)
    
end