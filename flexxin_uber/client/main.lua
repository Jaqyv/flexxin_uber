ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('esx_uber:requestUber')
AddEventHandler('esx_uber:requestUber', function()
    local input = lib.inputDialog('Uber Request', {'Current Location', 'Destination'})
    if not input or #input < 2 then
        ESX.ShowNotification('Uber request canceled.')
        return
    end
    TriggerServerEvent('esx_uber:sendUberRequest', input[1], input[2])
end)

RegisterNetEvent('esx_uber:setGPS')
AddEventHandler('esx_uber:setGPS', function(coords)
    SetNewWaypoint(coords.x, coords.y)

    ESX.ShowNotification('The GPS has been set to the requester\'s location.')
end)
