ESX = exports["es_extended"]:getSharedObject()

local lastCallID = 0
local lastRequestTime = {}
local callIDLocations = {}
local acceptedCalls = {}
local requesterIDs = {}
local requestDetails = {}

local function generateCallID()
    lastCallID = lastCallID + 1
    return lastCallID
end

local function canRequestUber(playerId)
    local currentTime = os.time()
    local lastTime = lastRequestTime[playerId] or 0
    local cooldown = 180

    if currentTime - lastTime >= cooldown then
        lastRequestTime[playerId] = currentTime
        return true
    else
        return false
    end
end

local function getPlayerCoords(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return nil end

    local playerPed = GetPlayerPed(playerId)
    return GetEntityCoords(playerPed)
end

RegisterCommand('requestuber', function(source, args, rawCommand)
    TriggerClientEvent('esx_uber:requestUber', source)
end, false)

RegisterNetEvent('flexin_uber:sendUberRequest')
AddEventHandler('flexin_uber:sendUberRequest', function(currentLocation, destination)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)

    if not canRequestUber(playerId) then
        local timeRemaining = 180 - (os.time() - (lastRequestTime[playerId] or 0))
        TriggerClientEvent('chat:addMessage', playerId, {
            args = { 'Uber Request', 'You must wait ' .. math.ceil(timeRemaining / 60) .. ' minutes before requesting another Uber.' }
        })
        return
    end

    local callID = generateCallID()
    local xPlayerName = xPlayer.getName()
    local playerCoords = getPlayerCoords(playerId)

    callIDLocations[callID] = playerCoords
    requesterIDs[callID] = playerId
    acceptedCalls[callID] = nil
    requestDetails[callID] = { currentLocation = currentLocation, destination = destination }

    local requestMessage = xPlayerName .. ' has requested an Uber. Call ID: ' .. callID .. ' Current Location: ' .. currentLocation .. ' Destination: ' .. destination

    local players = ESX.GetExtendedPlayers()
    for _, player in pairs(players) do
        if player.job.name == 'uber' then
            TriggerClientEvent('chat:addMessage', player.source, {
                args = { 'Uber Request', requestMessage }
            })
        end
    end

    TriggerClientEvent('chat:addMessage', xPlayer.source, {
        args = { 'Uber Request', 'Your Uber request has been sent to all available drivers. Call ID: ' .. callID .. ' Current Location: ' .. currentLocation .. ' Destination: ' .. destination }
    })
end)

RegisterCommand('acceptcall', function(source, args, rawCommand)
    local callID = tonumber(args[1])
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayerName = xPlayer.getName()

    if not callID or not callIDLocations[callID] then
        TriggerClientEvent('chat:addMessage', playerId, {
            args = { 'Uber Request', 'Invalid call ID or no request found.' }
        })
        return
    end

    if acceptedCalls[callID] then
        TriggerClientEvent('chat:addMessage', playerId, {
            args = { 'Uber Request', 'This call has already been accepted.' }
        })
        return
    end

    acceptedCalls[callID] = playerId

    local requesterId = requesterIDs[callID]
    if requesterId then
        TriggerClientEvent('chat:addMessage', requesterId, {
            args = { 'Uber Request', xPlayerName .. ' has accepted your call and is on the way. You can contact them by doing /pm ' .. playerId }
        })
    end

    TriggerClientEvent('chat:addMessage', playerId, {
        args = { 'Uber Request', 'You have accepted the call with ID: ' .. callID .. '. Current Location: ' .. requestDetails[callID].currentLocation .. ', Destination: ' .. requestDetails[callID].destination .. '. You can contact the player who made the request by doing /pm ' .. requesterId }
    })

    local requesterCoords = callIDLocations[callID]
    TriggerClientEvent('flexin_uber:setGPS', playerId, requesterCoords)
end, false)

RegisterCommand('finishride', function(source, args, rawCommand)
    local callID = tonumber(args[1])
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)

    if not callID or not acceptedCalls[callID] or acceptedCalls[callID] ~= playerId then
        TriggerClientEvent('chat:addMessage', playerId, {
            args = { 'Uber Ride', 'Invalid call ID or you have not accepted this ride.' }
        })
        return
    end

    local requesterId = requesterIDs[callID]
    acceptedCalls[callID] = nil
    callIDLocations[callID] = nil
    requesterIDs[callID] = nil
    requestDetails[callID] = nil

    if requesterId then
        TriggerClientEvent('chat:addMessage', requesterId, {
            args = { 'Uber Ride', xPlayer.getName() .. ' has finished your Uber ride. Thank you!' }
        })
    end

    TriggerClientEvent('chat:addMessage', playerId, {
        args = { 'Uber Ride', 'You have finished the ride for Call ID: ' .. callID .. '.' }
    })
end, false)

