fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Mirage'
ui_page 'html/index.html'

shared_scripts {
    '@ox_lib/init.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'audiodirectory/seatbelt_sounds.awc',
    'data/seatbelt_sounds.dat54.rel'
}

data_file 'AUDIO_WAVEPACK' 'audiodirectory'
data_file 'AUDIO_SOUNDDATA' 'data/seatbelt_sounds.dat'

client_scripts {
    'client.lua',
    'nitro_client.lua'
}

server_scripts {
    'nitro_server.lua'
}