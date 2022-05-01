name 'Doors Manager';
description 'Door locking system !';
author 'Nayro';

fx_version 'cerulean';
game 'gta5';

-- shared_scripts {};

client_scripts {'functions/cl_function.lua', 'client/*.lua'};

server_scripts {'@oxmysql/lib/MySQL.lua', 'functions/sv_function.lua', '_doorsList/*.lua', 'server/*.lua', 'config.lua'};
