RegisterNetEvent('GasStation:PayGasSV', function(amount, payInTotalForFullTank)
    local _amount = tonumber(amount)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer.getMoney() >= _amount then
        if(_amount > payInTotalForFullTank) then
            xPlayer.removeMoney(payInTotalForFullTank)
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