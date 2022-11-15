ESX.RegisterServerCallback('GasStation:GetInformation', function(source, cb, fuelAvailable)

    print("SERVER: fuelAvailable" .. fuelAvailable)

    local playerPed = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(playerPed, true)

    local petrolTankDamage = GetVehiclePetrolTankHealth(vehicle)/10
    local vehcileMaximumLiters = 100 --hardcoded for now
    local gasPrice = 1.85 --hardcoded for now
    local litersAvailableInTank = fuelAvailable
    local amountMax = (vehcileMaximumLiters - litersAvailableInTank)*gasPrice

    cb(gasPrice, petrolTankDamage, amountMax)
end)

RegisterNetEvent('GasStation:PayGasSV', function(amount)
    local _amount = tonumber(amount)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer.getMoney() >= _amount then
        xPlayer.removeMoney(_amount)
        TriggerClientEvent('GasStation:PayGas', -1, true)
    else
        TriggerClientEvent('GasStation:PayGas', -1, false)
    end
end)