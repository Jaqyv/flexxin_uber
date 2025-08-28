ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('flexin_uber:requestUber')
AddEventHandler('flexin_uber:requestUber', function()
    local input = lib.inputDialog('Uber Request', {'Current Location', 'Destination'})
    if not input or #input < 2 then
        ESX.ShowNotification('Uber request canceled.')
        return
    end
    TriggerServerEvent('esx_uber:sendUberRequest', input[1], input[2])
end)

RegisterNetEvent('flexin_uber:setGPS')
AddEventHandler('flexin_uber:setGPS', function(coords)
    SetNewWaypoint(coords.x, coords.y)

    ESX.ShowNotification('The GPS has been set to the requester\'s location.')
end)

