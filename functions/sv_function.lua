DoorsList = {};

-- Only for the command pushDoors
function AddDoors(doors)
    for name, data in pairs(doors) do
        if type(name) ~= 'string' then
            print('[X] | The name of the doors must be a string: ' .. name);
            break
        end

        if type(data.type) ~= 'number' or data.type ~= 0 and data.type ~= 1 and data.type ~= 2 then
            print('[X] | The type of the doors must be a number between [0-2]: ' .. name);
            break
        end

        if type(data.locked) ~= 'boolean' then
            print('[X] | Locked must be a boolean value (true, false): ' .. name);
            break
        end

        if type(data.distance) ~= 'number' then
            print('[X] | Distance must be a number: ' .. name);
            break
        end

        if type(data.private) ~= 'boolean' then
            print('[X] | Private must be a boolean value (true, false): ' .. name);
            break
        end

        if type(data.doors) ~= 'table' then
            print('[X] | Doors must be a table: ' .. name);
            break
        end

        if data.jobs and type(data.jobs) ~= 'table' then
            print('[X] | Jobs must be a table: ' .. name);
            break
        elseif not data.jobs then
            data.jobs = nil;
        end

        if type(data.keys) ~= 'table' then
            print('[X] | Keys must be a table: ' .. name);
            break
        end

        if data.type == 0 and data.breakable and type(data.breakable) ~= 'table' then
            print('[X] | Breakable must be a table: ' .. name);
            break
        elseif data.type == 0 and data.breakable then
            data.breakable = {
                isBreak = false,
                security = data.breakable.security,
                baseHealth = data.breakable.health,
                currentHealth = data.breakable.health
            };
        else
            data.breakable = nil;
        end

        if data.type == 0 and type(data.animations) ~= 'table' then
            print('[X] | Animations must be a table: ' .. name);
            break
        elseif not data.animations then
            data.animations = nil;
        end

        if data.type == 1 and type(data.keypads) ~= 'table' then
            print('[X] | Keypads must be a table: ' .. name);
            break
        elseif not data.keypads then
            data.keypads = nil;
        end

        if data.type == 1 and type(data.timer) ~= 'number' then
            print('[X] | Timer must be a number: ' .. name);
            break
        elseif not data.timer then
            data.timer = nil;
        end

        if DoorsList[name] then
            print('[X] | Duplicate Doors: ' .. name);
            break
        else
            print('[V] | Doors added: ' .. name);

            DoorsList[name] = data;
        end
    end
end

-- Convert boolean value (true, false) to (1, 0) SQL didn't support boolean
function Boolean_to_string(value)
    local result = '';
    if type(value) == 'boolean' then
        if value == true then
            result = 1;
        elseif value == false then
            result = 0;
        end
    end

    return result;
end

-- Convert table/array to string
function Table_to_string(table)
    if type(table) ~= 'table' then
        return nil;
    end

    local result = '{'
    for k, v in pairs(table) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == 'string' then
            result = result .. '' .. k .. '' .. '='
        end

        -- Check the value type
        if type(v) == 'table' then
            result = result .. Table_to_string(v);
        elseif type(v) == 'boolean' then
            result = result .. tostring(v);
        elseif type(v) == 'number' then
            result = result .. '' .. v .. '';
        elseif type(v) == 'string' then
            result = result .. "'" .. v .. "'";
        else
            result = result .. '' .. v .. '';
        end

        result = result .. ',';
    end

    if result ~= '' then
        result = result:sub(1, result:len() - 1);
    end

    return result .. '}';
end

function String_to_table(string)
    if type(string) ~= 'string' then
        return nil;
    end

    return load('return ' .. string)();
end

-- Get door info from the DB
function GetDoorInfo(index)
    local data = MySQL.single.await('SELECT * FROM `doors_manager` WHERE identifier = ?', {index});

    local data = {
        type = data.type,
        locked = data.locked,
        distance = tonumber(data.distance),
        private = data.private,
        doors = String_to_table(data.doors),
        jobs = String_to_table(data.jobs),
        keys = String_to_table(data.keys),
        breakable = String_to_table(data.breakable),
        animations = String_to_table(data.animations),
        keypads = String_to_table(data.keypads),
        timer = tonumber(data.timer)
    };

    return data;
end

function StateMessage(state)
    local message = {'de fermer', 'fermer'};

    if state == true then
        message = {'d\'ouvrir', 'ouvrir'};
    end

    return message;
end

-- Interact with key doors (open/close)
function InteractWithKeyDoors(source, index, state)
    SetCurrentPedWeapon(source, GetHashKey('weapon_unarmed'), true);

    TriggerClientEvent('doorsManager:clt_animation', source, index, 0);

    Wait(2350);

    local updatedDoor = UpdateDoorState(index, state);

    if updatedDoor then
        TriggerClientEvent('doorsManager:clt_updateState', -1, index, state, 0);
    end

    Wait(600);

    local message = nil;

    state = not state;
    if state == true then
        message = 'Porte ~r~Fermée';
    elseif state == false then
        message = 'Porte ~g~Ouverte';
    end

    TriggerClientEvent('doorsManager:clt_information', source, message);

    TriggerClientEvent('doorsManager:clt_allow', source);
end

-- Interact with card doors (open)
function InteractWithCardDoors(source, index, state, timer)
    SetCurrentPedWeapon(source, GetHashKey('weapon_unarmed'), true);

    local function getRandomTimer()
        local items = {
            [4325] = 10,
            [2940] = 9,
            [6050] = 5,
            [7000] = 3,
            [4850] = 1
        };

        local total_sum = 0

        for _, v in pairs(items) do
            total_sum = total_sum + v;
        end

        local RNG = math.random(0, total_sum);
        local sum = 0;
        local item = 0;

        for i, v in pairs(items) do
            sum = sum + v;
            item = i;
            if RNG >= sum - v and RNG < sum then
                break
            end
        end

        return item;
    end

    local random_timer = getRandomTimer();

    TriggerClientEvent('doorsManager:clt_animation', source, index, 2, random_timer);

    Wait(random_timer);

    local openDoor = UpdateDoorState(index, true);

    if openDoor then
        TriggerClientEvent('doorsManager:clt_updateState', -1, index, true, 1);
    end

    TriggerClientEvent('doorsManager:clt_information', source, 'Porte ~g~Ouverte');

    Wait(timer);

    local closedDoor = UpdateDoorState(index, false);

    if closedDoor then
        TriggerClientEvent('doorsManager:clt_updateState', -1, index, false, 1);
    end

    TriggerClientEvent('doorsManager:clt_information', source, 'Porte ~b~Verrouillée');
    TriggerClientEvent('doorsManager:clt_allow', source);
end

-- Update door state in the DB
function UpdateDoorState(index, doorState)
    doorState = not doorState;

    local updateDoor = MySQL.update.await('UPDATE `doors_manager` SET locked = ? WHERE identifier = ? ',
        {doorState, index});

    return updateDoor;
end

-- Update door health in the DB
function UpdateDoorBreak(index, newBreak)
    local updateDoor = MySQL.update.await('UPDATE `doors_manager` SET breakable = ? WHERE identifier = ? ',
        {Table_to_string(newBreak), index});

    return updateDoor;
end
