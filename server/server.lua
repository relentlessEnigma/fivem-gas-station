local amountMax

ESX.RegisterServerCallback('GasStation:GetInformation', function(source, cb, fuelAvailable)
    local playerPed = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(playerPed, true)

    local petrolTankDamage = GetVehiclePetrolTankHealth(vehicle)/10
    local vehcileMaximumLiters = 100 --hardcoded for now
    local gasPrice = 1.85 --hardcoded for now
    local litersAvailableInTank = fuelAvailable
    amountMax = (vehcileMaximumLiters - litersAvailableInTank)*gasPrice

    cb(gasPrice, petrolTankDamage, amountMax)
end)

RegisterNetEvent('GasStation:PayGasSV', function(amount)
    local _amount = tonumber(amount)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer.getMoney() >= _amount then
        if(_amount > amountMax) then
            xPlayer.removeMoney(amountMax)
        else
            xPlayer.removeMoney(_amount)
        end
        TriggerClientEvent('GasStation:PayGas', -1, true)
    else
        TriggerClientEvent('GasStation:PayGas', -1, false)
    end
end)

RegisterNetEvent('GasStation:SaveFuelAmount', function(plate, fuel)
    MySQL.Async.fetchAll('UPDATE owned_vehicles SET fuel = @fuel WHERE plate = @plate', {['@fuel'] = fuel, ['@plate'] = plate})
    MySQL.Async.fetchAll('UPDATE theft_vehicles SET fuel = @fuel WHERE carPlate = @carPlate', {['@fuel'] = fuel, ['@carPlate'] = plate})
end)