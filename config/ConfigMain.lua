ConfigMain = {}

--Jail Event for use in other scripts
--TriggerServerEvent('lawmen:JailPlayer', function(id, time, "the location string")
--[[
Jail ID's
Sisika = sk
Blackwater = bw
Armadillo = ar
Tumbleweed = tu
Strawberry = st
Valentine = val
Saint Denis = sd
Annesburg = an
]]
ConfigMain.BossGrade = 6 -- Grade of boss rank, has access to boss options.
ConfigMain.HandcuffHotkeyActive = false
ConfigMain.synsociety = false -- If you use syn_society and want compatability
ConfigMain.CheckHorse = true -- If you want to check horse ID's
Locale = 'en'

PayCheck = false -- If true built in paycheck system will activate. If you use another paycheck system make this false
PaycheckInfo = {
     Waittime = 1, -- minutes to wait before pay
     police = {
          [0] = 14,
          [1] = 16,
          [2] = 18,
          [3] = 20,
          [4] = 22,
          [5] = 24,
          [6] = 26,
     },
     marshal = {
          [0] = 16,
          [1] = 18,
          [2] = 20,
          [3] = 22,
     }
}

BankInfo = {
     banktable = 'bank_users' ,
     moneycolumn = 'money',
     charidcolumn = 'charidentifier',
     banknamecolumn = 'name',
     names ={
          {display = "Valentine", value = 'Valentine'},
          {display = "Blackwater", value = 'Blackwater'},
          {display = "Rhodes", value = 'Rhodes'},
          {display = "StDenis", value = 'StDenis'},
          {display = "Armadillo", value = 'Armadillo'},
     }
}

InventoryOptions = {
     privatestorage = true, -- Gives option in cabinet menu for personal storage
     sharedstorage = true, -- Gives option in cabinet menu for shared job storage
     allstoragessame = true, --All shared storages will be the same at all departments
     id = "lawstorage",
     name = "Law Storage",
     privatelimit = 2500,
     sharedlimit = 2500,
     acceptWeapons = true,
     ignorestacklimit = true,
     whitelistitems = true, -- or ie  {'wool','water','pickaxe'}
     whitelistweapons = false, -- ie {'weapon_revolver_cattleman'}
     usewhitelist = false -- only allow whitelisted items and weapons in
}


OffDutyJobs = {
     'offpolice',
     'offmarshal',
     'offlawmen',
     'offsheriffrhodes',
}

OnDutyJobs = {
     'police',
     'marshal',
     'lawmen',
     'sheriffrhodes',
}

ConfigMain.ondutycommand = "goonduty"         -- Go on duty Command
ConfigMain.offdutycommand = "gooffduty"       --Go off duty Command
ConfigMain.adjustbadgecommand = "adjustbadge" -- Go on duty Command
ConfigMain.openpolicemenu = "pmenu"            -- Open Police Menu Command
ConfigMain.jailcommand = 'jail'               --Command to jail for cops and admins
ConfigMain.unjailcommand = 'unjail'           --Command to unjail for cops and admins
ConfigMain.finecommand = 'fine'               --Command to fine for cops and admins

-----
-- Shoot-Alert
-- To use this feature, bcc-job-alerts is required
-- Download it here https://github.com/BryceCanyonCounty/bcc-job-alerts/releases and ensure it BEFORE bcc-law
ConfigMain.UseShootAlert = true -- If you want to use the shoot alert system
Alerts = {
     Police = {
         name = 'bcc-robbery-police', --The name of the alert
         command = '', -- the command, this is what players will use with /
         message = 'Alert! Shots Heard!', -- Message to show to the police
         alerterTitle = "Damn...",
         alerterNotification = "My shots will be heard!", -- Message to show players they have alerted
         messageTime = 40000, -- Time the message will stay on screen (miliseconds)
         jobs = {    -- Job the alert is for
               'offpolice',
               'offmarshal',
               'offlawmen',
               'offsheriffrhodes',
         },
         jobgrade =  -- What grades the alert will effect
         {
             offpolice = {0,1,2,3,4,5,6},
             offmarshal = {0,1,2,3,4,5,6},
             offlawmen = {0,1,2,3,4,5,6},
             offsheriffrhodes = {0,1,2,3,4,5,6},
         },
         icon = 'star', -- The icon the alert will use
         color = 'COLOR_GOLD', -- The color of the icon / https://github.com/femga/rdr3_discoveries/tree/master/useful_info_from_rpfs/colours
         texturedict = 'generic_textures', --https://github.com/femga/rdr3_discoveries/tree/master/useful_info_from_rpfs/textures/menu_textures
         hash = -1282792512, -- The radius blip
         radius = 40.0, -- The size of the radius blip
         blipTime = 240000, -- How long the blip will stay for the job (miliseconds)
         blipDelay = 5000, -- Delay time before the job is notified (miliseconds)
         originText = '', -- Text displayed to the user who enacted the command
         originTime = 5000 -- The time the origintext displays (miliseconds)
     },
 }

ConfigMain.AlertChance = 65
--------------------------------- Town Locations for Shoot-Alarm ---------------------------------------------------------------------------
------------ Here ypu can change the range of a town, or add more Locations -------------------------
Towns = {
    valentine = {
        coordinates = vector3(-297.48, 791.1, 118.33),
        range = 150, -- Distance to call an alert
    },
    annesburg = {
        coordinates = vector3(2930.95, 1348.91, 44.1),
        range = 250, -- Distance to call an alert
    },
    stdenis = {
        coordinates = vector3(2632.52, -1312.31, 51.42),
        range = 600, -- Distance to call an alert
    },
    rhodes = {
        coordinates = vector3(1346.14, -1312.5, 76.53),
        range = 200, -- Distance to call an alert
    },
    strawberry = {
        coordinates = vector3(-1801.09, -374.86, 161.15),
        range = 150, -- Distance to call an alert
    },
    blackwater = {
        coordinates = vector3(-801.77, -1336.43, 43.54),
        range = 350, -- Distance to call an alert
    },
    armadillo = {
        coordinates = vector3(-3659.38, -2608.91, -14.08),
        range = 150, -- Distance to call an alert
    },
    tumbleweed = {
        coordinates = vector3(-5498.97, -2950.61, -1.62),
        range = 100, -- Distance to call an alert
    },
    --You can add more towns by copy and pasting one of the tables above and changing the coords and range to your liking
}
