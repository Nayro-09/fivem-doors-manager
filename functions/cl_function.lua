-- Show helps on the top right of the screen
function DisplayHelpText(lineOne, lineTwo, lineThree)
    BeginTextCommandDisplayHelp("THREESTRINGS");
    AddTextComponentSubstringPlayerName(lineOne);
    AddTextComponentSubstringPlayerName(lineTwo or '');
    AddTextComponentSubstringPlayerName(lineThree or '');
    EndTextCommandDisplayHelp(0, false, false, 1000);
end

-- Get the coords of the nearest animations
function ClosestCoords(_table)
    local _ClosestDistance = 100000;
    local animation = nil;

    for _, v in pairs(_table) do
        local _Distance = #(v.coords - GetEntityCoords(PlayerPedId()));
        if _Distance <= _ClosestDistance then
            _ClosestDistance = _Distance;

            animation = v;
        end
    end

    return _ClosestDistance, animation;
end

-- Check if all doors are closed
function AllDoorsAreClosed(k, v)
    local _loop = true;
    local isClose = nil;

    for k2, v2 in pairs(v.doors) do
        local doorRotation = (GetEntityHeading(v2.object) - v2.heading + 180 + 360) % 360 - 180;

        if doorRotation >= -20.0 and doorRotation <= 20.0 and _loop then
            isClose = true;
        else
            _loop = false;
            isClose = false;
        end
    end

    return isClose
end

function DoorsSwing(door)
    local isClose = nil;

    local doorRotation = (GetEntityHeading(door.object) - door.heading + 180 + 360) % 360 - 180;

    if doorRotation >= -15.0 and doorRotation <= 15.0 then
        isClose = true;
    else
        isClose = false;
    end

    return isClose;
end

function AllDoorsSwing(k, v)
    local _loop = true;
    local isClose = nil;

    for k2, v2 in pairs(v.doors) do
        local doorRotation = (GetEntityHeading(v2.object) - v2.heading + 180 + 360) % 360 - 180;

        if doorRotation >= -15.0 and doorRotation <= 15.0 and _loop then
            isClose = true;
        else
            _loop = false;
            isClose = false;
        end
    end

    return isClose
end

-- Check if a player has a valid weapon that matches the security level of the door
function BreakableSecurity(playerPed, data)
    return Switch(data.security, {
        ['low'] = function()
            local weaponsList = {'weapon_sawnoffshotgun', 'weapon_assaultshotgun', 'weapon_bullpupshotgun',
                                 'weapon_dbshotgun', 'weapon_autoshotgun', 'weapon_combatshotgun', 'weapon_crowbar',
                                 'weapon_hammer', 'weapon_unarmed'};

            for _index, gun in ipairs(weaponsList) do
                if GetSelectedPedWeapon(playerPed) == GetHashKey(gun) then
                    return true;
                end
            end

            return false;
        end,
        ['medium'] = function()
            local weaponsList = {'weapon_sawnoffshotgun', 'weapon_assaultshotgun', 'weapon_bullpupshotgun',
                                 'weapon_dbshotgun', 'weapon_autoshotgun', 'weapon_combatshotgun', 'weapon_crowbar'};

            for _index, gun in ipairs(weaponsList) do
                if GetSelectedPedWeapon(playerPed) == GetHashKey(gun) then
                    return true;
                end
            end

            return false;
        end,
        ['high'] = function()
            local weaponsList = {'weapon_assaultshotgun', 'weapon_bullpupshotgun', 'weapon_combatshotgun'};

            for _index, gun in ipairs(weaponsList) do
                if GetSelectedPedWeapon(playerPed) == GetHashKey(gun) then
                    return true;
                end
            end

            return false;
        end,
        ['default'] = function()
            local weaponsList = {'weapon_assaultshotgun', 'weapon_bullpupshotgun', 'weapon_combatshotgun'};

            for _index, gun in ipairs(weaponsList) do
                if GetSelectedPedWeapon(playerPed) == GetHashKey(gun) then
                    return true;
                end
            end

            return false;
        end
    });
end

-- Request animation dict
function CanRequestAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict);

        while not HasAnimDictLoaded(animDict) do
            Citizen.Wait(1);
        end
    end
end

-- Animation to open/close a key door
function PlayKeyAnimation(playerPed, animation, dict, animToPlay)
    TaskGoStraightToCoord(playerPed, animation.coords, 0.001, 2000, animation.heading, 0.70);

    -- SetEntityHeading(playerPed, animation.heading);

    Wait(100);

    local _isMoving = true;

    while _isMoving do
        local coords = GetEntityCoords(playerPed);

        if coords.x >= (animation.coords.x - 0.085) and coords.x <= (animation.coords.x + 0.085) and coords.y >=
            (animation.coords.y - 0.085) and coords.y <= (animation.coords.y + 0.085) then
            _isMoving = false;
        end

        Citizen.Wait(10);
    end

    CanRequestAnimDict(dict);

    TaskPlayAnim(playerPed, dict, animToPlay, 7.0, 2.0, 2750, 16, 0.0, false, false, false);

    local soundId = GetSoundId();
    PlaySoundFromEntity(soundId, "keys", playerPed, "dlc_xm_pickup_sweetener_sounds", true, 0);
    Wait(1500);
    StopSound(soundId);
    ReleaseSoundId(soundId);

    Wait(100);

    while IsEntityPlayingAnim(playerPed, dict, animToPlay, 3) do
        Citizen.Wait(200);
    end
end
-- Animation to repair a door
function PlayRepairAnimation(playerPed, animation)
    local dict = 'missmechanic';
    local anim_in = 'work2_in';
    local anim_base = 'work2_base';
    local anim_out = 'work2_out';

    local dict2, anim2 = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer';

    TaskGoStraightToCoord(playerPed, animation.coords, 0.001, 1000, animation.heading, 0.70);

    Wait(250);

    local _isMoving = true;

    while _isMoving do
        local coords = GetEntityCoords(playerPed);

        if coords.x >= (animation.coords.x - 0.1) and coords.x <= (animation.coords.x + 0.1) and coords.y >=
            (animation.coords.y - 0.1) and coords.y <= (animation.coords.y + 0.1) then
            _isMoving = false;
        end

        Citizen.Wait(10);
    end

    CanRequestAnimDict(dict);

    CanRequestAnimDict(dict2);

    Wait(175);

    SetEntityHeading(playerPed, animation.heading);

    Wait(175);

    TaskPlayAnimAdvanced(playerPed, dict, anim_in, animation.coords, 0.0, 0.0, animation.heading, 1.0, 1.0, 1700, 2,
        0.0, 1, 1);
    Wait(1700);
    TaskPlayAnimAdvanced(playerPed, dict, anim_base, animation.coords, 0.0, 0.0, animation.heading, 1.0, 1.0, 7500, 1,
        0.0, 1, 1);
    Wait(4000);
    local fwd = GetEntityForwardVector(playerPed)
    Wait(3000);
    TaskGoStraightToCoord(playerPed, animation.coords - (fwd * 0.35), 0.5, 550, animation.heading, 0.5);
    Wait(750);

    TaskPlayAnimAdvanced(playerPed, dict2, anim2, animation.coords - (fwd * 0.35), 0.0, 0.0, animation.heading, 1.50,
        1.70, 8000, 1, 0.0, 1, 1);

    -- TaskPlayAnimAdvanced(playerPed, dict, anim_out, animation.coords, 0.0, 0.0, animation.heading, 1.0, 1.0, 2450, 1,
    --     0.0, 1, 1);
    -- Wait(2450);
end

-- Animation to open a card door
function PlaySwipeCardAnimation(keypad, timer)
    local ped = PlayerPedId();
    local heading = GetEntityHeading(keypad.object);
    local dict = 'anim_heist@hs3f@ig3_cardswipe@male@';
    local fwd = GetEntityForwardVector(keypad.object);

    local animations = {{
        pedAnim = 'drop_card_success_var02',
        cardAnim = 'drop_card_success_var02_card',
        delay = 4850,
        insert = 3550,
        success = 1000
    }, {
        pedAnim = 'fail_success_var01',
        cardAnim = 'fail_success_var01_card',
        delay = 6050,
        insert = 1820,
        fail = 1000,
        insert2 = 1850,
        success = 900
    }, {
        pedAnim = 'fail_success_var02',
        cardAnim = 'fail_success_var02_card',
        delay = 7000,
        insert = 1975,
        fail = 1000,
        insert2 = 1810,
        success = 900
    }, {
        pedAnim = 'success_var02',
        cardAnim = 'success_var02_card',
        delay = 2940,
        insert = 1750,
        success = 700
    }, {
        pedAnim = 'success_var03',
        cardAnim = 'success_var03_card',
        delay = 4325,
        insert = 2450,
        success = 900
    }};

    local random;

    for index, data in ipairs(animations) do
        if data.delay == timer then
            random = animations[index];
        end
    end

    RequestAnimDict(dict);

    RequestModel('prop_cs_swipe_card');

    while not HasAnimDictLoaded(dict) or not HasModelLoaded('prop_cs_swipe_card') do
        Citizen.Wait(200);
    end

    TaskGoStraightToCoord(ped, keypad.coords - (fwd * 0.84), 0.025, 5000, heading, 0.6);

    Citizen.Wait(100);

    local _isMoving = true;

    while _isMoving do
        local coords = GetEntityCoords(ped);

        if coords.x >= (keypad.coords.x - 0.85) and coords.x <= (keypad.coords.x + 0.85) and coords.y >=
            (keypad.coords.y - 0.85) and coords.y <= (keypad.coords.y + 0.85) then
            _isMoving = false;
        end

        Citizen.Wait(10);
    end

    Citizen.Wait(100);

    local targetPosition = (vec3(GetEntityCoords(ped)));

    FreezeEntityPosition(ped, true);

    local card = CreateObject(GetHashKey('prop_cs_swipe_card'), targetPosition, 1, 1, 0);

    local netScene = NetworkCreateSynchronisedScene(keypad.coords, keypad.rot, 2, false, false, 1065353216, 0, 1.0);
    NetworkAddPedToSynchronisedScene(ped, netScene, dict, random.pedAnim, 1.5, -4.0, 1, 16, 1148846080, 0);
    NetworkAddEntityToSynchronisedScene(card, netScene, dict, random.cardAnim, 4.0, -8.0, 1);

    Citizen.Wait(100);

    NetworkStartSynchronisedScene(netScene);

    local delaySound = 0;

    if random.insert then
        Citizen.Wait(random.insert);

        local soundId1 = GetSoundId();
        PlaySoundFrontend(soundId1, 'Insert_Keycard', 'Twin_Card_Entry_Sounds', true);
        ReleaseSoundId(soundId1);

        delaySound = delaySound + random.insert;
    end

    if random.fail then
        Citizen.Wait(random.fail);

        local soundId1 = GetSoundId();
        PlaySoundFrontend(soundId1, 'Keycard_Fail', 'Twin_Card_Entry_Sounds', true);
        ReleaseSoundId(soundId1);

        Citizen.Wait(random.insert2);

        local soundId1 = GetSoundId();
        PlaySoundFrontend(soundId1, 'Insert_Keycard', 'Twin_Card_Entry_Sounds', true);
        ReleaseSoundId(soundId1);

        delaySound = delaySound + random.fail + random.insert2;
    end

    if random.success then
        Citizen.Wait(random.success);

        local soundId1 = GetSoundId();
        PlaySoundFrontend(soundId1, 'Keycard_Success', 'Twin_Card_Entry_Sounds', true);
        ReleaseSoundId(soundId1);

        delaySound = delaySound + random.success;
    end

    Citizen.Wait(random.delay - delaySound);

    FreezeEntityPosition(ped, false);

    NetworkStopSynchronisedScene(netScene);
    DeleteObject(card);
end

-- Switch statement for lua (like JS)
function Switch(condition, result)
    local value = result[condition] or result.default;

    return type(value) == "function" and value() or value;
end
