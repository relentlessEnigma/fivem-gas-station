fx_version 'cerulean'
game 'gta5'

author 'kori'
description 'Gas Station Script'
version '1.0.0'
lua54 'yes'

client_script 'client/client.lua'
server_script 'server/server.lua'

files {
    'html/*',
}

ui_page 'html/index.html'

shared_scripts { 
	'@es_extended/imports.lua',
	'@oxmysql/lib/MySQL.lua',
	'config.lua'
}