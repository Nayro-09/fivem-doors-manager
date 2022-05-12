RegisterCommand('pushDoors', function(source, args)
    -- Push Doors in the database
    for _index, v in pairs(DoorsList) do

        -- Check if a door is already in the database (avoid duplicate)
        MySQL.single('SELECT * FROM `doors_manager` WHERE `identifier` = ?', {_index}, function(result)
            if result then
                print('[X] | ' .. 'Door: ' .. _index .. ' is already in the database');
            else
                MySQL.insert(
                    'INSERT INTO `doors_manager` (`identifier`, `type`, `locked`, `distance`, `private`, `doors`, `jobs`, `keys`, `breakable`, `animations`, `keypads`, `timer`) VALUES (@identifier, @type, @locked, @distance, @private, @doors, @jobs, @keys, @breakable, @animations, @keypads , @timer)',
                    {
                        ['@identifier'] = _index,
                        ['@type'] = v.type,
                        ['@locked'] = Boolean_to_string(true),
                        ['@distance'] = v.distance,
                        ['@private'] = Boolean_to_string(v.private),
                        ['@doors'] = Table_to_string(v.doors),
                        ['@jobs'] = Table_to_string(v.jobs),
                        ['@keys'] = Table_to_string(v.keys),
                        ['@breakable'] = Table_to_string(v.breakable),
                        ['@animations'] = Table_to_string(v.animations),
                        ['@keypads'] = Table_to_string(v.keypads),
                        ['@timer'] = v.timer
                    }, function(id)
                        print('[V] | ' .. 'Door: ' .. _index .. ' has been added to the database');
                    end)
            end
        end)
    end

    TriggerEvent('doorsManager:srv_syncDoors');
end, true)

RegisterCommand('deleteDoors', function(source, args)
    DoorsList = nil;
end, true)
