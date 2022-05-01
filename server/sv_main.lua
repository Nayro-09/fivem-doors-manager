ESX = nil;
TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj;
end);

-- Check if a player has the required job
local function IsAuthorized(jobList, playerJob)
    for _index, job in pairs(jobList) do
        if job == playerJob then
            return true
        end
    end

    return false
end

-- Check if a player has the required key
local function HasKey(keysList, playerInventory)
    for _index, key in pairs(keysList) do
        for index, item in pairs(playerInventory) do
            if playerInventory[index]['count'] > 0 then
                if keysList[_index] == playerInventory[index]['name'] then
                    return true;
                end
            end
        end
    end

    return false;
end

-- Sync the DB
RegisterServerEvent('doorsManager:srv_syncDoors');
AddEventHandler('doorsManager:srv_syncDoors', function()
    local keyDoors = {};
    local cardDoors = {};

    MySQL.query('SELECT * FROM `doors_manager`', function(result)
        if result then
            for _, v in ipairs(result) do
                if v.type == 0 then
                    local data = {
                        locked = v.locked,
                        distance = tonumber(v.distance),
                        private = v.private,
                        doors = String_to_table(v.doors),
                        jobs = String_to_table(v.jobs),
                        keys = String_to_table(v.keys),
                        breakable = String_to_table(v.breakable),
                        animations = String_to_table(v.animations)
                    };

                    if not keyDoors[v.identifier] then
                        keyDoors[v.identifier] = data;
                    end
                elseif v.type == 1 then
                    local data = {
                        locked = true,
                        distance = tonumber(v.distance),
                        private = v.private,
                        doors = String_to_table(v.doors),
                        jobs = String_to_table(v.jobs),
                        keys = String_to_table(v.keys),
                        -- breakable = String_to_table(v.breakable),
                        keypads = String_to_table(v.keypads),
                        timer = tonumber(v.timer)
                    };

                    if not cardDoors[v.identifier] then
                        cardDoors[v.identifier] = data;
                    end
                end
            end

            TriggerClientEvent('doorsManager:clt_SyncDoors', -1, keyDoors, cardDoors);
        end
    end);
end);

-- Sync with the DB every 2min
Citizen.CreateThread(function()
    while true do
        TriggerEvent('doorsManager:srv_syncDoors');

        Citizen.Wait(120000);
    end
end);

-- Check the requirement to open a door 
RegisterServerEvent('doorsManager:srv_updateState');
AddEventHandler('doorsManager:srv_updateState', function(index, type)
    local _source = source;
    local xPlayer = ESX.GetPlayerFromId(_source);
    local data = GetDoorInfo(index);

    if data.private then
        if IsAuthorized(data.jobs, xPlayer.job.name) then
            if data.type == 0 then
                InteractWithKeyDoors(_source, index, data.locked);
            elseif data.type == 1 then
                InteractWithCardDoors(_source, index, data.locked, data.timer);
            end
        else
            TriggerClientEvent('doorsManager:clt_allow', _source);

            TriggerClientEvent('doorsManager:clt_information', _source,
                '~r~Vous n\'avez pas la permission ' .. StateMessage(data.locked)[1] .. ' cette porte.');
        end
    elseif not data.private then
        if data.breakable and data.breakable.isBreak then
            TriggerClientEvent('doorsManager:clt_allow', _source);

            return TriggerClientEvent('doorsManager:clt_information', _source,
                '~r~Cette porte semble avoir été enfoncée.');
        end

        if IsAuthorized(data.jobs, xPlayer.job.name) or HasKey(data.keys, xPlayer.inventory) then
            if data.type == 0 then
                InteractWithKeyDoors(_source, index, data.locked);
            elseif data.type == 1 then
                InteractWithCardDoors(_source, index, data.locked, data.timer);
            end
        else
            TriggerClientEvent('doorsManager:clt_allow', _source);

            return TriggerClientEvent('doorsManager:clt_information', _source, '~r~Vous n\'avez pas la clé pour ' ..
                StateMessage(data.locked)[2] .. ' cette porte.');
        end
    end
end)

-- Update the door health/break state in the DB
RegisterServerEvent('doorsManager:srv_updateBreak');
AddEventHandler('doorsManager:srv_updateBreak', function(index, newHealth)
    local _source = source;
    local data = GetDoorInfo(index);

    local updatedHealth = data.breakable.currentHealth - (data.breakable.currentHealth - newHealth);

    data.breakable.currentHealth = updatedHealth;

    if updatedHealth <= 0 then
        data.breakable.isBreak = not data.breakable.isBreak;

        local updateDoor = UpdateDoorState(index, true);

        if updateDoor then
            TriggerClientEvent('doorsManager:clt_updateState', -1, index, true, 0);
            TriggerClientEvent('doorsManager:clt_information', _source, 'Porte ~b~Enfoncée');
        end
    end

    local updateBreak = UpdateDoorBreak(index, data.breakable);

    if updateBreak then
        TriggerClientEvent('doorsManager:clt_updateBreak', -1, index, updatedHealth, data.breakable.isBreak);
    end
end)

-- Repair the door
RegisterServerEvent('doorsManager:srv_repair');
AddEventHandler('doorsManager:srv_repair', function(index)
    local _source = source;
    local xPlayer = ESX.GetPlayerFromId(_source);
    local data = GetDoorInfo(index);

    if data.breakable.isBreak then
        if xPlayer.getInventoryItem('door_repair_kit').count >= 1 then
            xPlayer.removeInventoryItem('door_repair_kit', 1);

            TriggerClientEvent('doorsManager:clt_animation', _source, index, 1);

            Wait(19000);

            data.breakable.isBreak = not data.breakable.isBreak;
            data.breakable.currentHealth = data.breakable.baseHealth;

            local updateBreak = UpdateDoorBreak(index, data.breakable);

            if updateBreak then
                TriggerClientEvent('doorsManager:clt_updateBreak', -1, index, data.breakable.baseHealth, data.breakable.isBreak);

                TriggerClientEvent('doorsManager:clt_information', _source, 'Porte ~g~Réparée');

                TriggerClientEvent('doorsManager:clt_allow', _source);
            end
        else
            TriggerClientEvent('doorsManager:clt_allow', _source);

            return TriggerClientEvent('doorsManager:clt_information', _source, 'Vous n\'avez pas de ~b~' ..
                xPlayer.getInventoryItem('door_repair_kit').label .. '~s~ pour réparer cete porte.');
        end

    elseif not data.breakable.isBreak then
        TriggerClientEvent('doorsManager:clt_allow', _source);

        return TriggerClientEvent('doorsManager:clt_information', _source, '~b~Cette porte semble être en bon état.');
    end
end)
