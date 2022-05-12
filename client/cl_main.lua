local keyDoorsList = {};
local cardDoorsList = {};
local spawned = false;
local displayHelp = true;
local checking = true;
local breaching = false;
local useKey = false;

-- Responce from the DB sync
RegisterNetEvent('doorsManager:clt_SyncDoors')
AddEventHandler('doorsManager:clt_SyncDoors', function(key, card)
    keyDoorsList = key;
    cardDoorsList = card;

    for index, data in pairs(key) do
        for _index, door in ipairs(data.doors) do
            local hash = GetHashKey(index .. '-' .. _index);

            AddDoorToSystem(hash, door.hash, door.coords);

            AddTextEntry(hash, index);

            DoorSystemSetDoorState(hash, data.locked and 1 or 0);
        end
    end

    for index, data in pairs(card) do
        for _index, door in ipairs(data.doors) do
            local hash = GetHashKey(index .. '-' .. _index);

            AddDoorToSystem(hash, door.hash, door.coords);

            AddTextEntry(hash, index);

            DoorSystemSetDoorState(hash, data.locked and 1 or 0);
        end
    end

    -- Only for debug
    print('^2[doorsManager] ^0- Sync with success !');
end);

-- Trigger DB sync on spawn
AddEventHandler('playerSpawned', function()
    if not spawned then
        spawned = true;

        TriggerServerEvent('doorsManager:srv_syncDoors');

        Citizen.Wait(2500);

        TriggerEvent('doorsManager:clt_keypads');
    end
end);

-- Trigger DB sync on resource start
AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        TriggerServerEvent('doorsManager:srv_syncDoors');

        Citizen.Wait(2500);

        TriggerEvent('doorsManager:clt_keypads');
    end

    return
end)

-- Spawn Keypads
RegisterNetEvent('doorsManager:clt_keypads')
AddEventHandler('doorsManager:clt_keypads', function()
    for index, data in pairs(cardDoorsList) do
        for _index, keypad in ipairs(data.keypads) do
            local object

            object = CreateObjectNoOffset('ch_prop_fingerprint_scanner_01d', keypad.coords, false, true, false);

            SetEntityRotation(object, keypad.rot, 2, true);
        end
    end
end);

-- allow help info and keys
RegisterNetEvent('doorsManager:clt_allow')
AddEventHandler('doorsManager:clt_allow', function()
    Wait(750);

    displayHelp = true;
    useKey = false;
end);

-- Send notification (door state, deny access...)
RegisterNetEvent('doorsManager:clt_information')
AddEventHandler('doorsManager:clt_information', function(message)
    BeginTextCommandThefeedPost('STRING');
    AddTextComponentSubstringPlayerName(message);
    EndTextCommandThefeedPostTicker(false, false);
end);

-- Play animation for open/close door
RegisterNetEvent('doorsManager:clt_animation')
AddEventHandler('doorsManager:clt_animation', function(index, animation, timer)

    if animation == 0 then
        local _, anim = ClosestCoords(keyDoorsList[index].animations);

        PlayKeyAnimation(PlayerPedId(), anim, 'mp_arresting', 'a_uncuff');
    elseif animation == 1 then
        local _, anim = ClosestCoords(keyDoorsList[index].animations);

        PlayRepairAnimation(PlayerPedId(), anim);
    elseif animation == 2 then
        local _, anim = ClosestCoords(cardDoorsList[index].keypads);

        PlaySwipeCardAnimation(anim, timer);
    end

end);

-- Update the door state for everyone
RegisterNetEvent('doorsManager:clt_updateState')
AddEventHandler('doorsManager:clt_updateState', function(index, state, type)
    state = not state;

    if type == 0 then
        keyDoorsList[index].locked = state;

        for _index, door in ipairs(keyDoorsList[index].doors) do
            local hash = GetHashKey(index .. '-' .. _index);

            DoorSystemSetDoorState(hash, state and 1 or 0);

            DoorSystemSetOpenRatio(hash, 0.00001, false, true);
        end
    elseif type == 1 then
        cardDoorsList[index].locked = state;

        for _index, door in pairs(cardDoorsList[index].doors) do
            local hash = GetHashKey(index .. '-' .. _index);

            if state == false then
                DoorSystemSetHoldOpen(hash, true);

                DoorSystemSetDoorState(hash, 0);
            end
        end

        if state == true then
            local loop = true;

            while loop do
                for _index, door in pairs(cardDoorsList[index].doors) do
                    local hash = GetHashKey(index .. '-' .. _index);

                    DoorSystemSetOpenRatio(hash, 0.0, false, true);

                    DoorSystemSetHoldOpen(hash, false);

                    DoorSystemSetDoorState(hash, 0);

                    if DoorIsClose(hash) then
                        DoorSystemSetDoorState(hash, 1);

                        DoorSystemSetOpenRatio(hash, 0.00001, false, true);
                    end
                end

                if AllDoorsAreClosed(index, cardDoorsList[index]) then
                    loop = false;
                end

                Citizen.Wait(100);
            end
        end
    end
end);

-- Update the break state and health for everyone
RegisterNetEvent('doorsManager:clt_updateBreak')
AddEventHandler('doorsManager:clt_updateBreak', function(index, newHealth, state)
    keyDoorsList[index].breakable.currentHealth = newHealth;
    keyDoorsList[index].breakable.isBreak = state;

    for _index, door in pairs(keyDoorsList[index].doors) do
        local hash = GetHashKey(index .. '-' .. _index);
        local object = GetDoor(hash);

        SetEntityHealth(object, newHealth);

        if state then
            PlaySoundFromEntity(GetSoundId(), 'CRASH', object, 'PAPARAZZO_03A', true, 0);
            Citizen.Wait(500);
            PlaySoundFromEntity(GetSoundId(), 'CRASH', object, 'PAPARAZZO_03A', true, 0);
        end
    end

    breaching = false;
end);

-- Breach system
AddEventHandler('entityDamaged', function(entity, culprit, weapon, baseDamage)
    local doorEntity = entity;
    local doorIndex, doorData = FindDoor(keyDoorsList, GetEntityCoords(doorEntity), GetEntityModel(doorEntity));

    if not breaching and doorIndex and doorData and BreakableSecurity(PlayerPedId(), doorData.breakable) == true then
        breaching = true;

        SetEntityHealth(doorEntity, doorData.breakable.currentHealth);

        local weaponDamage = GetWeaponDamage(weapon) * 8;
        local newHealth = weaponDamage ~= 0 and doorData.breakable.currentHealth - weaponDamage or doorData.breakable.currentHealth - 75;

        TriggerServerEvent('doorsManager:srv_updateBreak', doorIndex, newHealth);
    end
end);

-- Display Help info
Citizen.CreateThread(function()
    while true do
        local letSleep = true;

        if checking then
            keyDist, keyData = DistanceCheck(keyDoorsList, 0);
            cardDist, cardData = DistanceCheck(cardDoorsList, 1);
        end

        if keyDist and displayHelp then
            local coordsDistance = ClosestCoords(keyData.animations);
            if coordsDistance > keyData.distance then
                checking = true;
            else
                checking = false;
            end

            letSleep = false;

            local doorStateMessage = _('close_door');

            if keyData.locked then
                doorStateMessage = _('open_door');
            end

            if IsUsingKeyboard() then
                if keyData.breakable and keyData.breakable.isBreak then
                    DisplayHelpText(_('press') .. ' ~INPUT_4746F32D~ ' .. _('to') .. ' ' .. _('repair_door'));
                else
                    DisplayHelpText(_('press') .. ' ~INPUT_BF65597C~ ' .. _('to') .. ' ' .. doorStateMessage);
                end
            else
                if keyData.breakable and keyData.breakable.isBreak then
                    DisplayHelpText(_('press') .. ' ~INPUT_D54FC5E8~ ' .. _('to') .. ' ' .. _('repair_door'));
                else
                    DisplayHelpText(_('press') .. ' ~INPUT_3D25A3A6~ ' .. _('to') .. ' ' .. doorStateMessage);
                end
            end
        end

        if cardDist and displayHelp then
            local coordsDistance = ClosestCoords(cardData.keypads);
            if coordsDistance > cardData.distance then
                checking = true;
            else
                checking = false;
            end

            letSleep = false;

            if IsUsingKeyboard() then
                DisplayHelpText(_('press') .. ' ~INPUT_BF65597C~ ' .. _('to') .. ' ' .. _('open_door'));
            else
                DisplayHelpText(_('press') .. ' ~INPUT_3D25A3A6~ ' .. _('to') .. ' ' .. _('open_door'));
            end
        end

        if letSleep then
            Citizen.Wait(500);
        else
            Citizen.Wait(50);
        end
    end
end);

-- KEYBOARD
-- Interact with doors (open/close)
RegisterKeyMapping('interactKeyboard', 'Open/Close Doors [KB]', 'keyboard', 'E');
RegisterCommand('interactKeyboard', function(source)
    if not useKey then
        local player = PlayerPedId(source);

        for index, data in pairs(keyDoorsList) do
            local coordsDistance = ClosestCoords(data.animations);

            if coordsDistance < data.distance and AllDoorsAreClosed(index, data) and not IsPedRunning(player) and
                not IsPedSprinting(player) then
                displayHelp = false;
                useKey = true;

                TriggerServerEvent('doorsManager:srv_updateState', index);

                break
            end
        end

        for index, data in pairs(cardDoorsList) do
            local coordsDistance = ClosestCoords(data.keypads);

            if coordsDistance < data.distance and data.locked and AllDoorsAreClosed(index, data) and
                not IsPedRunning(player) and not IsPedSprinting(player) then
                displayHelp = false;
                useKey = true;

                TriggerServerEvent('doorsManager:srv_updateState', index);

                break
            end
        end
    end
end, false);

-- repair doors
RegisterKeyMapping('repairKeyboard', 'Repair Doors [KB]', 'keyboard', 'B');
RegisterCommand('repairKeyboard', function(source)
    if not useKey then
        local player = PlayerPedId(source);

        for index, data in pairs(keyDoorsList) do
            local coordsDistance = ClosestCoords(data.animations);

            if data.breakable and coordsDistance < data.distance and AllDoorsAreClosed(index, data) and
                not IsPedRunning(player) and not IsPedSprinting(player) then
                displayHelp = false;
                useKey = true;

                TriggerServerEvent('doorsManager:srv_repair', index);
            end
        end
    end
end, false);

-- CONTROLLER
-- Interact with doors (open/close)
RegisterKeyMapping('interactController', 'Open/Close Doors [CL]', 'PAD_DIGITALBUTTON', 'LRIGHT_INDEX');
RegisterCommand('interactController', function(source)
    if not useKey then
        local player = PlayerPedId(source);

        for index, data in pairs(keyDoorsList) do
            local coordsDistance = ClosestCoords(data.animations);

            if coordsDistance < data.distance and AllDoorsAreClosed(index, data) and not IsPedRunning(player) and
                not IsPedSprinting(player) then
                displayHelp = false;
                useKey = true;

                TriggerServerEvent('doorsManager:srv_updateState', index);

                break
            end
        end

        for index, data in pairs(cardDoorsList) do
            local coordsDistance = ClosestCoords(data.keypads);

            if coordsDistance < data.distance and data.locked and AllDoorsSwing(index, data) and
                not IsPedRunning(player) and not IsPedSprinting(player) then
                displayHelp = false;
                useKey = true;

                TriggerServerEvent('doorsManager:srv_updateState', index);

                break
            end
        end
    end
end, false);

-- repair doors
RegisterKeyMapping('repairController', 'Repair Doors [CL]', 'PAD_DIGITALBUTTON', 'LDOWN_INDEX');
RegisterCommand('repairController', function(source)
    if not useKey then
        local player = PlayerPedId(source);

        for index, data in pairs(keyDoorsList) do
            local coordsDistance = ClosestCoords(data.animations);

            if data.breakable and coordsDistance < data.distance and AllDoorsAreClosed(index, data) and
                not IsPedRunning(player) and not IsPedSprinting(player) then
                displayHelp = false;
                useKey = true;

                TriggerServerEvent('doorsManager:srv_repair', index);
            end
        end
    end
end, false);
