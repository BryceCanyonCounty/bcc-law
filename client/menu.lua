Playerid = 0

local Core = exports.vorp_core:GetCore()

FeatherMenu = exports['feather-menu'].initiate()
local InputMenu = FeatherMenu:RegisterMenu('feather:inputpolice:menu', {
    top = '40%',
    left = '20%',
    ['720width'] = '500px',
    ['1080width'] = '600px',
    ['2kwidth'] = '700px',
    ['4kwidth'] = '900px',
    style = {},
    contentslot = {
        style = { --This style is what is currently making the content slot scoped and scrollable. If you delete this, it will make the content height dynamic to its inner content.
            ['height'] = '300px',
            ['min-height'] = '300px',
            ['width'] = '300px',

        }
    },
    draggable = true,
    canclose = true
}, {
    closed = function()
        Inmenu = false
    end,
})
local MainMenu = FeatherMenu:RegisterMenu('feather:mainpolice:menu', {
    top = '40%',
    left = '20%',
    ['720width'] = '500px',
    ['1080width'] = '600px',
    ['2kwidth'] = '700px',
    ['4kwidth'] = '900px',
    style = {},
    contentslot = {
        style = { --This style is what is currently making the content slot scoped and scrollable. If you delete this, it will make the content height dynamic to its inner content.
            ['height'] = '600px',
            ['min-height'] = '300px',
            ['width'] = '500px',

        }
    },
    draggable = true,
    canclose = true
}, {
    closed = function()
        Inmenu = false
    end,
})


function ClockMenu()
    local MyFirstPage = InputMenu:RegisterPage('first:page')
    MyFirstPage:RegisterElement('header', {
        value = _U('lawmenu'),
        slot = "header",
        style = {}
    })
    MyFirstPage:RegisterElement('bottomline', {
        slot = "content",
        style = {}
    })
    if PoliceOnDuty then
        MyFirstPage:RegisterElement('button', {
            label = _U('lawmenu'),
            style = {},
        }, function()
            OpenPoliceMenu()
        end)
        MyFirstPage:RegisterElement('button', {
            label = _U('clockoff'),
            style = {},
        }, function()
            InputMenu:Close()
            ExecuteCommand('gooffduty')
        end)
    else
        MyFirstPage:RegisterElement('button', {
            label = _U('clockon'),
            style = {},
        }, function()
            InputMenu:Close()
            ExecuteCommand('goonduty')
        end)
    end
    InputMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = MyFirstPage,
    })
end

function OpenPoliceMenu()
    local MyFirstPage = MainMenu:RegisterPage('first:page')
    MyFirstPage:RegisterElement('header', {
        value = _U('lawmenu'),
        slot = "header",
        style = {}
    })
    MyFirstPage:RegisterElement('bottomline', {
        slot = "content",
        style = {}
    })
    MyFirstPage:RegisterElement('button', {
        label = _U('togglebadge'),
        style = {},
    }, function()
        TriggerServerEvent("bcc-law:PlayerJob")
        Wait(200)
        TriggerEvent('bcc-law:badgeon')
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('idmenu'),
        style = {},
    }, function()
        OpenIDMenu()
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('cufftoggle'),
        style = {},
    }, function()
        local closestPlayer, closestDistance = GetClosestPlayerPed()
        if closestPlayer ~= -1 and closestDistance <= 3.0 then
            HandcuffPlayer()
        else
            Core.NotifyRightTip(_U('notcloseenough'), 4000)
        end
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('escort'),
        style = {},
    }, function()
        local closestPlayer, closestDistance = GetClosestPlayerPed()
        if closestPlayer ~= -1 and closestDistance <= 3.0 then
            TriggerServerEvent('bcc-law:drag', GetPlayerServerId(closestPlayer))
        else
            Core.NotifyRightTip(_U('notcloseenough'), 4000)
        end
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('putinoutvehicle'),
        style = {},
    }, function()
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local closestWagon, distance = GetClosestVehicle(coords)
        if closestWagon ~= -1 and distance <= 5.0 then
            PutInOutVehicle()
        else
            Core.NotifyRightTip(_U('notcloseenoughtowagon'), 4000)
        end
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('fineplayer'),
        style = {},
    }, function()
        OpenFineMenu()
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('jailplayer'),
        style = {},
    }, function()
        OpenJailMenu()
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('serviceplayer'),
        style = {},
    }, function()
        OpenChoreMenu()
    end)
    MainMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = MyFirstPage,
    })
end

function OpenJailMenu()
    local MyFirstPage = MainMenu:RegisterPage('first:page')
    local JailID = 'val'
    MyFirstPage:RegisterElement('header', {
        value = _U('lawmenu'),
        slot = "header",
        style = {}
    })
    MyFirstPage:RegisterElement('bottomline', {
        slot = "content",
        style = {}
    })
    local playerIDinput = ''
    MyFirstPage:RegisterElement('input', {
        label = _U('playerid'),
        placeholder = _U('numberonly'),
        style = {}
    }, function(data)
        playerIDinput = data.value
    end)
    local jailtimeinput = ''
    MyFirstPage:RegisterElement('input', {
        label = _U('jailamount'),
        placeholder = _U('numberonly'),
        style = {}
    }, function(data)
        jailtimeinput = data.value
    end)


    MyFirstPage:RegisterElement('arrows', {
        label = _U('Autotele'),
        start = 1,
        options = {
            { display = 'Yes', value = true },
            { display = 'No',  value = false }
        },
    }, function(data)
        Autotele = data.value.value

        -- This gets triggered whenever the arrow selected value changes
    end)


    TextDisplay = MyFirstPage:RegisterElement('textdisplay', {
        value = _U('jaildesc'),
        style = {}
    })

    MyFirstPage:RegisterElement('arrows', {
        label = _U('jailmenu'),
        start = 1,
        options = {
            { display = _U('valjail'), value = "val" },
            { display = _U('bwjail'),  value = "bw" },
            { display = _U('sdjail'),  value = "sd" },
            { display = _U('rhjail'),  value = "rh" },
            { display = _U('stjail'),  value = "st" },
            { display = _U('arjail'),  value = "ar" },
            { display = _U('tujail'),  value = "tu" },
            { display = _U('anjail'),  value = "an" },
            { display = _U('sisika'),  value = "sk" },
        },
    }, function(data)
        JailID = data.value.value
        -- This gets triggered whenever the arrow selected value changes
    end)

    MyFirstPage:RegisterElement('button', {
        label = _U('jail'),
        style = {},
    }, function()
        if tonumber(playerIDinput) and tonumber(jailtimeinput) > 0 then
            TriggerServerEvent('bcc-law:JailPlayer', tonumber(playerIDinput), tonumber(jailtimeinput), JailID)
        end
    end)

    MyFirstPage:RegisterElement('button', {
        label = _U('unjail'),
        style = {},
    }, function()
        if tonumber(playerIDinput) > 0 then
            TriggerServerEvent('bcc-law:unjailed', tonumber(playerIDinput), JailID)
        end
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('goback'),
        style = {},
    }, function()
        OpenPoliceMenu()
    end)
    MainMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = MyFirstPage,
    })
end

function OpenFineMenu()
    local MyFirstPage = MainMenu:RegisterPage('first:page')
    MyFirstPage:RegisterElement('header', {
        value = _U('lawmenu'),
        slot = "header",
        style = {}
    })
    MyFirstPage:RegisterElement('bottomline', {
        slot = "content",
        style = {}
    })
    local playerIDinput = ''
    MyFirstPage:RegisterElement('input', {
        label = _U('playerid'),
        placeholder = _U('numberonly'),
        style = {}
    }, function(data)
        playerIDinput = data.value
    end)
    local fineamountinput = ''
    MyFirstPage:RegisterElement('input', {
        label = _U('fineamount'),
        placeholder = _U('numberonly'),
        style = {}
    }, function(data)
        fineamountinput = data.value
    end)
    MyFirstPage:RegisterElement('bottomline', {
        slot = "content",
        style = {}
    })
    local bankname
    print(BankInfo.names[1])
    MyFirstPage:RegisterElement('arrows', {
        label = _U('bankoptions'),
        start = 1,
        options = BankInfo.names
    }, function(data)
        bankname = data.value.value
        -- This gets triggered whenever the arrow selected value changes
    end)

    MyFirstPage:RegisterElement('button', {
        label = _U('bill'),
        style = {},
    }, function()
        if ConfigMain.synsociety then
            if tonumber(playerIDinput) and tonumber(fineamountinput) > 0 then
                TriggerServerEvent("syn_society:bill", tonumber(fineamountinput), tonumber(playerIDinput)) -- playerid
            end
        else
            TriggerServerEvent("bcc-law:FinePlayer", 'bill', tonumber(playerIDinput), tonumber(fineamountinput), bankname)
        end
    end)
    if ConfigMain.synsociety then
        MyFirstPage:RegisterElement('textdisplay', {
            value = _U('billdescsyn'),
            style = {}
        })
    else
        MyFirstPage:RegisterElement('textdisplay', {
            value = _U('billdesc'),
            style = {}
        })
    end
    MyFirstPage:RegisterElement('bottomline', {
        slot = "content",
        style = {}
    })
    MyFirstPage:RegisterElement('button', {
        label = _U('fine'),
        style = {},
    }, function()
        if tonumber(playerIDinput) > 0 then
            TriggerServerEvent("bcc-law:FinePlayer", 'fine', tonumber(playerIDinput), tonumber(fineamountinput), bankname)
        end
    end)
    MyFirstPage:RegisterElement('textdisplay', {
        value = _U('finedesc'),
        style = {}
    })
    MyFirstPage:RegisterElement('button', {
        label = _U('goback'),
        style = {},
    }, function()
        OpenPoliceMenu()
    end)
    MainMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = MyFirstPage,
    })
end

function OpenChoreMenu()
    local MyFirstPage = MainMenu:RegisterPage('first:page')
    MyFirstPage:RegisterElement('header', {
        value = _U('lawmenu'),
        slot = "header",
        style = {}
    })
    MyFirstPage:RegisterElement('bottomline', {
        slot = "content",
        style = {}
    })
    local playerIDinput = ''
    MyFirstPage:RegisterElement('input', {
        label = _U('playerid'),
        placeholder = _U('numberonly'),
        style = {}
    }, function(data)
        playerIDinput = data.value
    end)
    local choreamountinput = ''
    MyFirstPage:RegisterElement('input', {
        label = _U('amountofchores'),
        placeholder = _U('numberonly'),
        style = {}
    }, function(data)
        choreamountinput = data.value
    end)

    local selectedchore
    MyFirstPage:RegisterElement('arrows', {
        label = _U('choosechore'),
        start = 1,
        options = {
            { display = _U('choretype'), value = 'cont' }
        }
    }, function(data)
        selectedchore = data.value.value
        -- This gets triggered whenever the arrow selected value changes
    end)

    MyFirstPage:RegisterElement('button', {
        label = _U('giveservice'),
        style = {},
    }, function()
        if tonumber(playerIDinput) and tonumber(choreamountinput) > 0 then
            TriggerServerEvent("bcc-law:CommunityService", tonumber(playerIDinput), selectedchore,
                tonumber(choreamountinput))
        end
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('goback'),
        style = {},
    }, function()
        OpenPoliceMenu()
    end)
    MainMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = MyFirstPage,
    })
end

function WeaponMenu(cabinetid)
    local MyFirstPage = MainMenu:RegisterPage('first:page')
    MyFirstPage:RegisterElement('header', {
        value = _U('grabweapons'),
        slot = "header",
        style = {}
    })
    MyFirstPage:RegisterElement('bottomline', {
        slot = "content",
        style = {}
    })

    local selectedweapon
    MyFirstPage:RegisterElement('arrows', {
        label = _U('weaponoptions'),
        start = 1,
        options = {
            { display = ConfigCabinets.WeaponsandAmmo.RevolverName1, value = ConfigCabinets.WeaponsandAmmo.RevolverSpawnName1 },
            { display = ConfigCabinets.WeaponsandAmmo.RevolverName2, value = ConfigCabinets.WeaponsandAmmo.RevolverSpawnName2 },
            { display = ConfigCabinets.WeaponsandAmmo.RepeaterName,  value = ConfigCabinets.WeaponsandAmmo.RepeaterSpawnName },
            { display = ConfigCabinets.WeaponsandAmmo.RifleName,  value = ConfigCabinets.WeaponsandAmmo.RifleSpawnName },
            { display = ConfigCabinets.WeaponsandAmmo.ShotgunName,  value = ConfigCabinets.WeaponsandAmmo.ShotgunSpawnName },
            { display = ConfigCabinets.WeaponsandAmmo.KnifeName,     value = ConfigCabinets.WeaponsandAmmo.KnifeSpawnName },
            { display = ConfigCabinets.WeaponsandAmmo.LassoName,     value = ConfigCabinets.WeaponsandAmmo.LassoSpawnName },
        }
    }, function(data)
        selectedweapon = data.value.value
        print(selectedweapon)
    end)

    MyFirstPage:RegisterElement('button', {
        label = _U('grabweapons'),
        style = {},
    }, function()
        TriggerServerEvent("bcc-law:guncabinet", selectedweapon)
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('goback'),
        style = {},
    }, function()
        CabinetMenu(cabinetid)
    end)
    MainMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = MyFirstPage,
    })
end

function AmmoMenu(cabinetid)
    local MyFirstPage = MainMenu:RegisterPage('first:page')
    MyFirstPage:RegisterElement('header', {
        value = _U('grabammo'),
        slot = "header",
        style = {}
    })
    MyFirstPage:RegisterElement('bottomline', {
        slot = "content",
        style = {}
    })

    local ammotype
    MyFirstPage:RegisterElement('arrows', {
        label = _U('ammooptions'),
        start = 1,
        options = {
            { display = ConfigCabinets.WeaponsandAmmo.RevolverAmmoName, value = ConfigCabinets.WeaponsandAmmo.RevolverAmmoType },
            { display = ConfigCabinets.WeaponsandAmmo.RepeaterAmmoName, value = ConfigCabinets.WeaponsandAmmo.RepeaterAmmoType },
            { display = ConfigCabinets.WeaponsandAmmo.RifleAmmoName, value = ConfigCabinets.WeaponsandAmmo.RifleAmmoType },
            { display = ConfigCabinets.WeaponsandAmmo.ShotgunAmmoName, value = ConfigCabinets.WeaponsandAmmo.ShotgunAmmoType },
        }
    }, function(data)
        ammotype = data.value.value
        -- This gets triggered whenever the arrow selected value changes
        print(ammotype)
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('grabammo'),
        style = {},
    }, function()
        TriggerServerEvent("bcc-law:addammo", ammotype)
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('goback'),
        style = {},
    }, function()
        CabinetMenu(cabinetid)
    end)
    MainMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = MyFirstPage,
    })
end

function CabinetMenu(cabinetid)
    local MyFirstPage = MainMenu:RegisterPage('first:page')
    MyFirstPage:RegisterElement('header', {
        value = _U('Cabinet'),
        slot = "header",
        style = {}
    })
    MyFirstPage:RegisterElement('bottomline', {
        slot = "content",
        style = {}
    })
    MyFirstPage:RegisterElement('button', {
        label = _U('grabweapons'),
        style = {},
    }, function()
        WeaponMenu(cabinetid)
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('grabammo'),
        style = {},
    }, function()
        AmmoMenu(cabinetid)
    end)
    if PlayerJobGrade == ConfigMain.BossGrade then
        MyFirstPage:RegisterElement('button', {
            label = _U('bossmenu'),
            style = {},
        }, function()
            TriggerEvent('bcc-law:OpenBossMenu', cabinetid)
        end)
    end
    if InventoryOptions.privatestorage then
        MyFirstPage:RegisterElement('button', {
            label = _U('privatestorage'),
            style = {},
        }, function()
            TriggerServerEvent('bcc-law:OpenStorageSv', cabinetid, 'personal')
        end)
    end
    if InventoryOptions.sharedstorage then
        MyFirstPage:RegisterElement('button', {
            label = _U('sharedstorage'),
            style = {},
        }, function()
            TriggerServerEvent('bcc-law:OpenStorageSv', cabinetid, 'shared')
        end)
    end
    MainMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = MyFirstPage,
    })
end

function OpenIDMenu() -- Set chore menu logic
    local MyFirstPage = MainMenu:RegisterPage('first:page')
    MyFirstPage:RegisterElement('header', {
        value = _U('idmenu'),
        slot = "header",
        style = {}
    })
    MyFirstPage:RegisterElement('bottomline', {
        slot = "content",
        style = {}
    })
    MyFirstPage:RegisterElement('button', {
        label = _U('citizenid'),
        style = {},
    }, function()
        local closestPlayer, closestDistance = GetClosestPlayerPed()
        if closestPlayer ~= -1 and closestDistance <= 3.0 then
            TriggerServerEvent('bcc-law:GetID', GetPlayerServerId(closestPlayer))
        end
    end)
    if ConfigMain.CheckHorse then
        MyFirstPage:RegisterElement('button', {
            label = _U('horseowner'),
            style = {},
        }, function()
            local closestPlayer, closestDistance = GetClosestPlayerPed()
            if closestPlayer ~= -1 and closestDistance <= 3.0 then
                local mount = GetMount(PlayerPedId())
                TriggerServerEvent('bcc-law:getVehicleInfo', GetPlayerServerId(closestPlayer), GetEntityModel(mount))
            else
                local mount = GetMount(PlayerPedId())
                local id = GetPlayerServerId(GetPlayerIndex())
                TriggerServerEvent('bcc-law:getVehicleInfo', id, GetEntityModel(mount))
            end
        end)
    end
    MyFirstPage:RegisterElement('button', {
        label = _U('goback'),
        style = {},
    }, function()
        OpenPoliceMenu()
    end)
    MainMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = MyFirstPage,
    })
end

function SearchMenu(takenmoney) -- Set chore menu logic
    local MyFirstPage = MainMenu:RegisterPage('first:page')
    MyFirstPage:RegisterElement('header', {
        value = _U('searchmenu'),
        slot = "header",
        style = {}
    })
    MyFirstPage:RegisterElement('bottomline', {
        slot = "content",
        style = {}
    })

    MyFirstPage:RegisterElement('textdisplay', {
        value = _U('playermoney') .. takenmoney,
        style = {}
    })
    MyFirstPage:RegisterElement('button', {
        label = _U('checkitems'),
        style = {},
    }, function()
        TriggerEvent('bcc-law:StartSearch')
    end)
    MainMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = MyFirstPage,
    })
end

RegisterNetEvent('bcc-law:OpenBossMenu')
AddEventHandler('bcc-law:OpenBossMenu', function(cabid)
    local MyFirstPage = MainMenu:RegisterPage('first:page')
    MyFirstPage:RegisterElement('header', {
        value = _U('Cabinet'),
        slot = "header",
        style = {}
    })
    MyFirstPage:RegisterElement('bottomline', {
        slot = "content",
        style = {}
    })
    MyFirstPage:RegisterElement('button', {
        label = _U('ledgermenu'),
        style = {},
    }, function()
        TriggerServerEvent('bcc-law:CheckLedgerSv', cabid)
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('hireemployeemenu'),
        style = {},
    }, function()
        local players = getPlayersInRange(5.0)
        local PlayerServerIds = {}
        for key, value in pairs(players) do
            table.insert(PlayerServerIds, GetPlayerServerId(value))
        end
        TriggerServerEvent('bcc-law:GiveNearbyPoliceSv', PlayerServerIds, cabid)
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('fireemployeemenu'),
        style = {},
    }, function()
        TriggerServerEvent('bcc-law:GetPoliceSv', cabid)
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('goback'),
        style = {},
    }, function()
        CabinetMenu(cabid)
    end)
    MainMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = MyFirstPage,
    })
end)

RegisterNetEvent('bcc-law:CheckLedgerCl')
AddEventHandler('bcc-law:CheckLedgerCl', function(ledgeramount, cabid)
    local MyFirstPage = MainMenu:RegisterPage('first:page')
    MyFirstPage:RegisterElement('header', {
        value = _U('Cabinet'),
        slot = "header",
        style = {}
    })
    MyFirstPage:RegisterElement('bottomline', {
        slot = "content",
        style = {}
    })

    MyFirstPage:RegisterElement('textdisplay', {
        value = _U('ledgeramount') .. ledgeramount,
        style = {}
    })
    MyFirstPage:RegisterElement('button', {
        label = _U('deposit'),
        style = {},
    }, function()
        CreateInputMenu('Deposit', true)
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('withdraw'),
        style = {},
    }, function()
        CreateInputMenu('Withdraw', false)
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('goback'),
        style = {},
    }, function()
        CabinetMenu(cabid)
    end)
    MainMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = MyFirstPage,
    })
end)

RegisterNetEvent('bcc-law:HireEmployeeMenu')
AddEventHandler('bcc-law:HireEmployeeMenu', function(chardata, cabid)
    local MyFirstPage = MainMenu:RegisterPage('first:page')
    local elements = {}
    for index, v in ipairs(chardata) do
        table.insert(elements,
            {
                display = v.id .. ' ' .. '|' .. ' ' .. v.firstname .. ' ' .. v.lastname,
                value = v.id
            }
        )
    end
    MyFirstPage:RegisterElement('header', {
        value = _U('Cabinet'),
        slot = "header",
        style = {}
    })
    MyFirstPage:RegisterElement('bottomline', {
        slot = "content",
        style = {}
    })
    local persontohireid
    MyFirstPage:RegisterElement('arrows', {
        label = _U('nearbypeople'),
        start = 1,
        options = elements
    }, function(data)
        persontohireid = data.value.value
        -- This gets triggered whenever the arrow selected value changes
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('hireselected'),
        style = {},
    }, function()
        TriggerServerEvent('bcc-law:HireEmployee', persontohireid)
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('goback'),
        style = {},
    }, function()
        TriggerEvent('bcc-law:OpenBossMenu', cabid)
    end)
    MainMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = MyFirstPage,
    })
end)

RegisterNetEvent('bcc-law:FireEmployeeMenu')
AddEventHandler('bcc-law:FireEmployeeMenu', function(players, cabid)
    local MyFirstPage = MainMenu:RegisterPage('first:page')
    local elements = {}
    for index, value in ipairs(players) do
        table.insert(elements,
            {
                display = value.charidentifier .. " " .. value.firstname .. ' ' .. value.lastname,
                value = value.charidentifier
            })
    end
    MyFirstPage:RegisterElement('header', {
        value = _U('Cabinet'),
        slot = "header",
        style = {}
    })
    MyFirstPage:RegisterElement('bottomline', {
        slot = "content",
        style = {}
    })
    local persontofireid
    MyFirstPage:RegisterElement('arrows', {
        label = _U('hiredpeople'),
        start = 1,
        options = elements
    }, function(data)
        persontofireid = data.value.value
        -- This gets triggered whenever the arrow selected value changes
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('fireselected'),
        style = {},
    }, function()
        TriggerServerEvent('bcc-law:FireEmployee', persontofireid)
    end)
    MyFirstPage:RegisterElement('button', {
        label = _U('goback'),
        style = {},
    }, function()
        TriggerEvent('bcc-law:OpenBossMenu', cabid)
    end)
    MainMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = MyFirstPage,
    })
end)

function CreateInputMenu(option, depositing)
    local MyFirstPage = InputMenu:RegisterPage('first:page')
    MyFirstPage:RegisterElement('header', {
        value = _U('depositmenu'),
        slot = "header",
        style = {}
    })
    InputValue = ''
    MyFirstPage:RegisterElement('input', {
        label = _U('amountto') .. option,
        placeholder = _U('numberonly'),
        style = {}
    }, function(data)
        -- This gets triggered whenever the input value changes
        InputValue = data.value
    end)
    MyFirstPage:RegisterElement('button', {
        label = option .. _U('amount'),
        style = {},
    }, function()
        InputMenu:Close()
        Inmenu = false
        TriggerServerEvent('bcc-law:ChangeLedger', depositing, InputValue)
    end)
    InputMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = MyFirstPage,
    })
end
