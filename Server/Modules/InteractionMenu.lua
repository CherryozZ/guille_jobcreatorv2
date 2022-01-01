RegisterNetEvent("jobcreatorv2:server:requestarrest", function(targetid, playerheading, playerCoords,  playerlocation)
    local src <const> = source
    local targetid <const> = targetid
    TriggerClientEvent('jobcreatorv2:client:getarrested', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('jobcreatorv2:client:doarrested', src)
end)

RegisterNetEvent('jobcreatorv2:server:requestunaarrest', function(targetid, playerheading, playerCoords,  playerlocation)
    local src <const> = source
    local targetid <const> = targetid
    TriggerClientEvent('jobcreatorv2:client:getuncuffed', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('jobcreatorv2:client:douncuffing', source)
end)