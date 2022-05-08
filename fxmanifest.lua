name 'Doors Manager';
description 'Advanced door locking system for FiveM using ESX.';
author 'Nayro';

fx_version 'cerulean';
game 'gta5';

shared_scripts {'functions/sh_function.lua', 'config.lua', '_locales/fr.lua', '_locales/en.lua'};

client_scripts {'functions/cl_function.lua', 'client/*.lua'};

server_scripts {'@oxmysql/lib/MySQL.lua', 'functions/sv_function.lua', '_doorsList/*.lua', 'server/*.lua', 'config.lua'};
