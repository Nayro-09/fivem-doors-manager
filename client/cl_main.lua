local keyDoorsList = {};
local cardDoorsList = {};
local displayHelp = true;
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

            print(hash)
        end
    end

    -- print(GetLabelText('1623445651'), GetLabelText('2131889455'));

    -- Only for debug
    print('^2[doorsManager] ^0- Sync with success !');
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

            DoorSystemSetOpenRatio(hash, 0.0, false, true);

            DoorSystemSetHoldOpen(hash, not state);

            Citizen.Wait(150);

            if state == false then
                DoorSystemSetDoorState(hash, state and 1 or 0);
            end
        end
    end
end);

-- Update the break state and health for everyone
RegisterNetEvent('doorsManager:clt_updateBreak')
AddEventHandler('doorsManager:clt_updateBreak', function(index, newHealth, state)
    keyDoorsList[index].breakable.currentHealth = newHealth;
    keyDoorsList[index].breakable.isBreak = state;

    for _index, doors in pairs(keyDoorsList[index].doors) do
        SetEntityHealth(doors.object, newHealth);
    end

    if state then
        PlaySoundFromEntity(GetSoundId(), 'CRASH', keyDoorsList[index].doors[1].object, 'PAPARAZZO_03A', true, 0);
        Citizen.Wait(500);
        PlaySoundFromEntity(GetSoundId(), 'CRASH', keyDoorsList[index].doors[1].object, 'PAPARAZZO_03A', true, 0);
    end
end);

-- Get doors has entity, Compare distance to the player, Freeze | set heading entity, spawn keypads
Citizen.CreateThread(function()
    TriggerServerEvent('doorsManager:srv_syncDoors');

    while true do
        local playerCoords = GetEntityCoords(PlayerPedId());

        for _index, data in pairs(keyDoorsList) do
            for index, doors in ipairs(data.doors) do
                if doors.object and DoesEntityExist(doors.object) then
                    data.distanceToPlayer = #(playerCoords - GetEntityCoords(doors.object));
                else
                    data.distanceToPlayer = nil;

                    doors.object = GetClosestObjectOfType(doors.coords, 1.0, doors.hash, false, false, false);

                    if data.breakable then
                        SetEntityHealth(doors.object, data.breakable.currentHealth);
                    end
                end
            end
        end

        for _index, data in pairs(cardDoorsList) do
            for index, doors in ipairs(data.doors) do
                if doors.object and DoesEntityExist(doors.object) then
                    data.distanceToPlayer = #(playerCoords - GetEntityCoords(doors.object));

                    if DoorsSwing(doors) and data.locked then
                        local hash = GetHashKey(_index .. '-' .. index);

                        DoorSystemSetDoorState(hash, 1);

                        DoorSystemSetOpenRatio(hash, 0.00001, false, true);
                    end
                else
                    data.distanceToPlayer = nil;

                    doors.object = GetClosestObjectOfType(doors.coords, 1.0, doors.hash, false, false, false);
                end
            end

            for index, keypad in ipairs(data.keypads) do
                if data.distanceToPlayer and data.distanceToPlayer < 40 and not keypad.object and
                    not DoesEntityExist(keypad.object) then
                    local object

                    object = CreateObjectNoOffset('ch_prop_fingerprint_scanner_01d', keypad.coords, false, true, false);

                    SetEntityRotation(object, keypad.rot, 2, true);

                    keypad.object = object;
                elseif data.distanceToPlayer and data.distanceToPlayer > 40 and keypad.object and
                    DoesEntityExist(keypad.object) then
                    DeleteObject(keypad.object);
                    keypad.object = nil;
                end
            end
        end

        Citizen.Wait(500);
    end
end);

-- Breach system/update health of the door
Citizen.CreateThread(function()
    while true do
        local letSleep = true;
        local player = PlayerPedId();

        for _index, data in pairs(keyDoorsList) do
            if data.distanceToPlayer and data.distanceToPlayer < 30 then
                for index, doors in ipairs(data.doors) do
                    if not data.private and data.breakable and not data.breakable.isBreak and
                        BreakableSecurity(player, data.breakable) == true then
                        letSleep = false;

                        if data.breakable.currentHealth ~= GetEntityHealth(doors.object) or data.breakable.currentHealth ~=
                            GetEntityHealth(doors.object) and IsPedPerformingMeleeAction(player) then

                            TriggerServerEvent('doorsManager:srv_updateBreak', _index, GetEntityHealth(doors.object));
                        end
                    elseif data.breakable and not data.breakable.isBreak then
                        SetEntityHealth(doors.object, data.breakable.currentHealth);
                    end
                end
            end
        end

        if letSleep then
            Citizen.Wait(1500);
        else
            Citizen.Wait(275);
        end
    end
end);

-- Display Help info
Citizen.CreateThread(function()
    while true do
        local letSleep = true;
        local player = PlayerPedId();

        for _index, data in pairs(keyDoorsList) do

            local coordsDistance = ClosestCoords(data.animations);

            if data.distanceToPlayer and coordsDistance < data.distance and AllDoorsAreClosed(_index, data) and
                displayHelp then
                letSleep = false;

                local helpMessage = '~r~fermer';

                if data.locked then
                    helpMessage = '~g~ouvrir';
                end

                if IsUsingKeyboard() then
                    if data.breakable and data.breakable.isBreak then
                        DisplayHelpText('Appuyez sur ~INPUT_4746F32D~ pour ~b~réparer ~s~la porte');
                    else
                        DisplayHelpText('Appuyez sur ~INPUT_BF65597C~ pour ' .. helpMessage .. '~s~ la porte');
                    end
                else
                    if data.breakable and data.breakable.isBreak then
                        DisplayHelpText('Appuyez sur ~INPUT_D54FC5E8~ pour ~b~réparer ~s~la porte');
                    else
                        DisplayHelpText('Appuyez sur ~INPUT_3D25A3A6~ pour ' .. helpMessage .. '~s~ la porte');
                    end
                end
            end
        end

        for _index, data in pairs(cardDoorsList) do
            local coordsDistance = ClosestCoords(data.keypads);

            if data.distanceToPlayer and coordsDistance < data.distance and displayHelp and data.locked and
                AllDoorsSwing(_index, data) then
                letSleep = false;

                if IsUsingKeyboard() then
                    DisplayHelpText('Appuyez sur ~INPUT_BF65597C~ pour ~g~ouvrir ~s~la porte');
                else
                    DisplayHelpText('Appuyez sur ~INPUT_3D25A3A6~ pour ~g~ouvrir ~s~la porte');
                end
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

        for _index, data in pairs(keyDoorsList) do
            local coordsDistance = ClosestCoords(data.animations);

            if data.distanceToPlayer and coordsDistance < data.distance and AllDoorsAreClosed(_index, data) and
                not IsPedRunning(player) and not IsPedSprinting(player) then
                displayHelp = false;
                useKey = true;

                TriggerServerEvent('doorsManager:srv_updateState', _index);

                break
            end
        end

        for _index, data in pairs(cardDoorsList) do
            local coordsDistance = ClosestCoords(data.keypads);

            if data.distanceToPlayer and coordsDistance < data.distance and data.locked and not IsPedRunning(player) and
                not IsPedSprinting(player) then
                displayHelp = false;
                useKey = true;

                TriggerServerEvent('doorsManager:srv_updateState', _index);

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

        for _index, data in pairs(keyDoorsList) do
            local coordsDistance = ClosestCoords(data.animations);

            if data.distanceToPlayer and data.breakable and coordsDistance < data.distance and
                AllDoorsAreClosed(_index, data) and not IsPedRunning(player) and not IsPedSprinting(player) then
                displayHelp = false;
                useKey = true;

                TriggerServerEvent('doorsManager:srv_repair', _index);
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

        for _index, data in pairs(keyDoorsList) do
            local coordsDistance = ClosestCoords(data.animations);

            if data.distanceToPlayer and coordsDistance < data.distance and AllDoorsAreClosed(_index, data) and
                not IsPedRunning(player) and not IsPedSprinting(player) then
                displayHelp = false;
                useKey = true;

                TriggerServerEvent('doorsManager:srv_updateState', _index);

                break
            end
        end

        for _index, data in pairs(cardDoorsList) do
            local coordsDistance = ClosestCoords(data.keypads);

            if data.distanceToPlayer and coordsDistance < data.distance and data.locked and AllDoorsSwing(_index, data) and
                not IsPedRunning(player) and not IsPedSprinting(player) then
                displayHelp = false;
                useKey = true;

                TriggerServerEvent('doorsManager:srv_updateState', _index);

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

        for _index, data in pairs(keyDoorsList) do
            local coordsDistance = ClosestCoords(data.animations);

            if data.distanceToPlayer and data.breakable and coordsDistance < data.distance and
                AllDoorsAreClosed(_index, data) and not IsPedRunning(player) and not IsPedSprinting(player) then
                displayHelp = false;
                useKey = true;

                TriggerServerEvent('doorsManager:srv_repair', _index);
            end
        end
    end
end, false);
