fx_version 'cerulean'
game 'gta5'

author 'Flexxin'
description 'Simple Uber Driver Script'
version '1.0.0'
lua54 'yes'

shared_scripts { 
    '@es_extended/imports.lua',
    '@ox_lib/init.lua', 
    
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}