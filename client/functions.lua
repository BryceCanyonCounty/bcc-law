local IsSearching = false


local Core = exports.vorp_core:GetCore()

 VORPutils = {}

TriggerEvent("getUtils", function(utils)
    VORPutils = utils
end)


function getPlayersInRange(distance)
    local playersInRange = {}
    local playerPed = PlayerPedId()              -- Get the player's Ped ID
    local playerPos = GetEntityCoords(playerPed) -- Get the player's current position

    -- Loop through all players
    for _, playerId in ipairs(GetActivePlayers()) do
        -- Skip the local player
        -- Get the Ped ID of the other player
        local ped = GetPlayerPed(playerId)
        local pedPos = GetEntityCoords(ped) -- Get the position of the other player's Ped

        -- Calculate the distance between the two players
        local dist = #(playerPos - pedPos)

        -- Check if the distance is within the specified range
        if dist <= distance then
            table.insert(playersInRange, playerId)
        end
    end

    return playersInRange
end

function HandcuffPlayer() --Handcuff player function
    Inmenu = false
    local closestPlayer, closestDistance = GetClosestPlayerPed()
    local targetplayerid = GetPlayerServerId(closestPlayer)
    local isDead = IsEntityDead(PlayerPedId())

    if closestDistance <= 3.0 then
        if not isDead then
            TriggerServerEvent('bcc-law:handcuff', targetplayerid)
            if not IsSearching then
                IsSearching = true
                --CuffPlayer(closestPlayer)
            elseif IsSearching then
                IsSearching = false
            end
        end
    else
        Core.NotifyBottomRight(_U('notcloseenough'), 4000)
    end
end

function GetClosestPlayerPed() -- Get closest player function
    local players, closestDistance, closestPlayer = GetActivePlayers(), -1, -1
    local playerPed, playerId = PlayerPedId(), PlayerId()
    local coords, usePlayerPed = coords, false

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        usePlayerPed = true
        coords = GetEntityCoords(playerPed)
    end

    for i = 1, #players, 1 do
        local tgt = GetPlayerPed(players[i])

        if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then
            local targetCoords = GetEntityCoords(tgt)
            local distance = #(coords - targetCoords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = players[i]
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

function CuffPlayer(closestPlayer) -- Prompt and code to access Gun Cabinets
    while true do
        local playercoords = GetEntityCoords(PlayerPedId())
        local tgtcoords = GetEntityCoords(GetPlayerPed(closestPlayer))
        local distance = #(playercoords - tgtcoords)
        local isDead = IsEntityDead(PlayerPedId())
        Wait(0)
        if distance <= 1.5 then
            if not isDead then
                if IsSearching then
                    if not Inmenu then
                        if not InWagon then
                            local item_name = CreateVarString(10, 'LITERAL_STRING', _U('searchplayer'))
                            PromptSetActiveGroupThisFrame(prompt2, item_name)
                        end
                    end
                end
            end
        end
        if PromptHasHoldModeCompleted(Search) then
            TriggerServerEvent('bcc-law:grabdata', GetPlayerServerId(closestPlayer))
            Wait(200)
            if Takenmoney then
                SearchMenu(Takenmoney)
            end
        end
    end
end

function DrawTxt(text, x, y, w, h, enableShadow, col1, col2, col3, a, centre) -- Draw text function
    local str = CreateVarString(10, "LITERAL_STRING", text)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
    SetTextCentre(centre)
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
    Citizen.InvokeNative(0xADA9255D, 1);
    DisplayText(str, x, y)
end

function CreateVarString(p0, p1, variadic) -- Create variable string function
    return Citizen.InvokeNative(0xFA925AC00EB830B9, p0, p1, variadic, Citizen.ResultAsLong())
end

function CheckTable(table, element) --Job checking table
    for k, v in pairs(table) do
        if v == element then
            return true
        end
    end
    return false
end

function GetPlayers() -- Get players function
    local players = {}
    for i = 0, 256 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, GetPlayerServerId(i))
        end
    end
    return players
end

function PutInOutVehicle()
    local closestPlayer, closestDistance = GetClosestPlayerPed()
    local iscuffed = Citizen.InvokeNative(0x74E559B3BC910685, closestPlayer)
    print(iscuffed)
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        TriggerServerEvent('bcc-law:GetPlayerWagonID', GetPlayerServerId(closestPlayer))
    else
        Core.NotifyBottomRight(_U('notcloseenough'), 4000)
        return
    end
end

function GetClosestVehicle(coords)
    local ped = PlayerPedId()
    local objects = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestObject = -1
    if coords then
    else
        coords = GetEntityCoords(ped)
    end
    for i = 1, #objects, 1 do
        local objectCoords = GetEntityCoords(objects[i])
        local distance = #(objectCoords - coords)
        if closestDistance == -1 or closestDistance > distance then
            closestObject = objects[i]
            closestDistance = distance
        end
    end
    return closestObject, closestDistance
end
