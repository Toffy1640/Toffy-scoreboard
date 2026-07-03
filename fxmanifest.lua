fx_version 'cerulean'
game 'gta5'

description 'Toffy Scoreboard'
author 'Toffy'
version '1.0.0'

shared_scripts {
    'locales/tr.lua',
    'locales/en.lua',
    'config/config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
}

lua54 'yes'
