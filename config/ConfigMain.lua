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
