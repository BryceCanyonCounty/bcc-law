game 'rdr3'
fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'
author 'BCC Team'

description 'A Complete Police Script'

client_script {
    'client/client.lua',
    'client/functions.lua',
    'client/menu.lua'

}

server_script {
    'server/server.lua'
}

shared_script {
    'locale.lua',
    'languages/*.lua',
    'config/ConfigMain.lua',
    'config/ConfigWebhook.lua',
    'config/ConfigJail.lua',
    'config/ConfigCabinets.lua',
    'config/ConfigService.lua'
}

dependency {
	'vorp_core',
	'vorp_character',
	'vorp_inventory',
    'oxmysql',
	'feather-menu',
	'vorp_utils',
    'bcc-utils'
}

version '1.0.0'
