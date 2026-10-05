fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'MJ / Bin Blasters RP'
description 'Blackpool Threads V3.0.9 three-piece centre'
version '3.0.9'
ui_page 'web/index.html'
files { 'web/index.html', 'web/style.css', 'web/app.js' }
shared_script 'config.lua'
client_script 'client/main.lua'
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
dependency 'oxmysql'
