local VORPInv = {}
VORPInv = exports.vorp_inventory:vorp_inventoryApi()

local Core = exports.vorp_core:GetCore()

RegisterServerEvent("bcc-law:grabdata") -- Go on duty, add cop count, restrict based off Max cop count event
AddEventHandler("bcc-law:grabdata", function(id)
    local _source = source
    local player = Core.getUser(id).getUsedCharacter
    local playermoney = player.money
    TriggerClientEvent('bcc-law:senddata', _source, playermoney)
end)

RegisterServerEvent("bcc-law:GivePaycheck") -- Go on duty, add cop count, restrict based off Max cop count event
AddEventHandler("bcc-law:GivePaycheck", function()
    local _source = source
    local player = Core.getUser(_source).getUsedCharacter
    local job = player.job
    local jobgrade = player.jobGrade
    player.addCurrency(0, PaycheckInfo[job][jobgrade])
    Core.NotifyRightTip(_source, _U('justgotpaid') .. PaycheckInfo[job][jobgrade], 4000)
end)

RegisterServerEvent("bcc-law:goondutysv") -- Go on duty, add cop count, restrict based off Max cop count event
AddEventHandler("bcc-law:goondutysv", function(ptable)
    local _source = source
    local player = Core.getUser(_source).getUsedCharacter
    local job = player.job
    local str = job
    local newjob = string.sub(str, 4)
    print(newjob)
    local grade = player.jobGrade
    local playername = player.firstname .. ' ' .. player.lastname
    if CheckTable(OffDutyJobs, job) then
        player.setJob(newjob, grade)
        Core.NotifyRightTip(_source, _U('goonduty'), 4000)
        TriggerClientEvent("bcc-law:onduty", _source, true)
        Core.AddWebhook("Duty", 'webhooklinkhere', playername .. " just went on duty")
    else
        Core.NotifyRightTip(_source, _U('nottherightjob'), 4000)
    end
end)

RegisterServerEvent("bcc-law:synsociety", function(status)
    local _source = source
    local player = Core.getUser(_source).getUsedCharacter
    local job = player.job
    exports["syn_society"]:SetPlayerDuty(_source, job, status, nil)
end)

RegisterServerEvent('bcc-law:checkjob') -- Get id event currently not used/ *now fixed
AddEventHandler('bcc-law:checkjob', function()
    local _source = source
    local User = Core.getUser(_source)
    local Character = User.getUsedCharacter
    local job = Character.job
    local jobgrade = Character.jobGrade
    TriggerClientEvent('bcc-law:PlayerJob', _source, job, jobgrade)
end)

RegisterServerEvent("bcc-law:gooffdutysv") -- Go off duty event
AddEventHandler("bcc-law:gooffdutysv", function()
    local _source = source
    local player = Core.getUser(_source).getUsedCharacter
    local job = player.job
    local grade = player.jobGrade
    if not CheckTable(OffDutyJobs, job) then
        player.setJob('off' .. job, grade)
        Core.NotifyRightTip(_source, _U('gooffduty'), 4000)
        TriggerClientEvent("bcc-law:onduty", _source, false)
    else
        Core.NotifyRightTip(_source, _U('nottherightjob'), 4000)
    end
end)

RegisterServerEvent('bcc-law:FinePlayer') --Fine a player event, this is the one that removes right from pockets
AddEventHandler('bcc-law:FinePlayer', function(finetype, player, amount, bankname)
    local _source = source
    local target = Core.getUser(player).getUsedCharacter
    local targetid = target.charIdentifier
    local user = Core.getUser(_source).getUsedCharacter
    local username = user.firstname .. ' ' .. target.lastname
    local Job = user.job
    local targetname = target.firstname .. ' ' .. target.lastname

    local fine = tonumber(amount)
    if finetype == 'fine' then
        for i, v in pairs(OnDutyJobs) do
            if v == user.job then
                local pJob = v
                local Society_Account = pJob
                if user.job == Society_Account then
                    if target.money < fine then
                        target.removeCurrency(0, target.money)
                        exports.ghmattimysql:executeSync(
                            'UPDATE society_ledger SET ledger = ledger + @fine WHERE job = @job'
                            , { fine = target.money, job = Society_Account })
                    else
                        target.removeCurrency(0, fine)
                        exports.ghmattimysql:executeSync(
                            'UPDATE society_ledger SET ledger = ledger + @fine WHERE job = @job'
                            , { fine = fine, job = Society_Account })
                    end

                    if ConfigWebhook.UseWebhook then
                        Core.AddWebhook(ConfigWebhook.WebhookInfo.FineTitle, ConfigWebhook.WebhookInfo.FineWebhook,
                            Job .. ' ' .. username .. _U('gaveafine') .. amount .. _U('to') .. targetname,
                            ConfigWebhook.WebhookInfo.FineColor,
                            ConfigWebhook.WebhookInfo.FineName, ConfigWebhook.WebhookInfo.FineLogo,
                            ConfigWebhook.WebhookInfo.FineFooterLogo,
                            ConfigWebhook.WebhookInfo.FineAvatar)
                    end

                    Core.NotifyRightTip(_source,
                        _U('youfined') .. target.firstname .. ' ' .. target.lastname .. _U('currency') .. amount, 4000)
                    Core.NotifyRightTip(player, _U('recievedfine') .. fine, 4000)
                end
            end
        end
    end
    if finetype == 'bill' then
        for i, v in pairs(OnDutyJobs) do
            if v == user.job then
                local pJob = v
                local Society_Account = pJob
                if user.job == Society_Account then
                    exports.ghmattimysql:executeSync(
                        'UPDATE @banktable SET @moneycolumn = @moneycolumn - @fine WHERE @charidcolumn = @charid AND @banknamecolumn = @bankname'
                        , {
                            banktable = BankInfo.banktable,
                            moneycolumn = BankInfo.moneycolumn,
                            fine = fine,
                            charidcolumn = BankInfo.charidcolumn,
                            charid = targetid,
                            banknamecolumn = BankInfo.banknamecolumn,
                            bankname = bankname
                        })
                    exports.ghmattimysql:executeSync(
                        'UPDATE society_ledger SET ledger = ledger + @fine WHERE job = @job'
                        , { fine = fine, job = Society_Account })
                    if ConfigWebhook.UseWebhook then
                        Core.AddWebhook(ConfigWebhook.WebhookInfo.FineTitle, ConfigWebhook.WebhookInfo.FineWebhook,
                            Job ..
                            ' ' ..
                            username .. _U('gaveabill') .. amount .. _U('to') .. targetname .. _U('tothebank') ..
                            bankname,
                            ConfigWebhook.WebhookInfo.FineColor,
                            ConfigWebhook.WebhookInfo.FineName, ConfigWebhook.WebhookInfo.FineLogo,
                            ConfigWebhook.WebhookInfo.FineFooterLogo,
                            ConfigWebhook.WebhookInfo.FineAvatar)
                    end

                    Core.NotifyRightTip(_source,
                        _U('youfined') .. target.firstname .. ' ' .. target.lastname .. _U('currency') .. amount, 4000)
                    Core.NotifyRightTip(player, _U('recievedfine') .. fine, 4000)
                end
            end
        end
    end
end)

RegisterServerEvent('bcc-law:JailPlayer') --Jail player event
AddEventHandler('bcc-law:JailPlayer', function(player, amount, loc)
    local _source = source
    local target = Core.getUser(player).getUsedCharacter
    local user = Core.getUser(_source).getUsedCharacter
    local username = user.firstname .. ' ' .. target.lastname
    local Job = user.job
    local targetname = target.firstname .. ' ' .. target.lastname
    local steam_id = target.identifier
    local Character = target.charIdentifier
    -- TIME
    local amount = amount * 60
    local timestamp = getTime() + amount

    exports.ghmattimysql:execute(
        "INSERT INTO jail (identifier, characterid, name, time, time_s, jaillocation) VALUES (@identifier, @characterid, @name, @timestamp, @time, @jaillocation)"
        ,
        {
            ["@identifier"] = steam_id,
            ["@characterid"] = Character,
            ["@name"] = targetname,
            ["@timestamp"] = timestamp,
            ["@time"] = amount,
            ["@jaillocation"] = loc
        })
    TriggerClientEvent("bcc-law:JailPlayer", player, amount, loc)

    if ConfigWebhook.UseWebhook then
        Core.AddWebhook(ConfigWebhook.WebhookInfo.JailTitle, ConfigWebhook.WebhookInfo.JailWebhook,
            Job .. ' ' .. username .. _U('sentto') .. targetname .. _U('tojailfor') .. amount .. _U('seconds'),
            ConfigWebhook.WebhookInfo.JailColor,
            ConfigWebhook.WebhookInfo.JailName, ConfigWebhook.WebhookInfo.JailLogo,
            ConfigWebhook.WebhookInfo.JailFooterLogo,
            ConfigWebhook.WebhookInfo.JailAvatar)
    end
end)

RegisterServerEvent('bcc-law:CommunityService') --Start community Service event
AddEventHandler('bcc-law:CommunityService', function(player, chore, amount)
    local _source = source
    local target = Core.getUser(player).getUsedCharacter
    local user = Core.getUser(_source).getUsedCharacter
    local username = user.firstname .. ' ' .. target.lastname
    local Job = user.job
    local targetname = target.firstname .. ' ' .. target.lastname
    local steam_id = target.identifier
    local Character = target.charIdentifier

    exports.ghmattimysql:execute(
        "INSERT INTO communityservice (identifier, characterid, name, communityservice, servicecount) VALUES (@identifier, @characterid, @name, @communityservice, @servicecount)"
        ,
        {
            ["@identifier"] = steam_id,
            ["@characterid"] = Character,
            ["@name"] = targetname,
            ["@communityservice"] = chore,
            ["@servicecount"] = amount
        })

    TriggerClientEvent("bcc-law:ServicePlayer", player, chore, amount)
    Core.NotifyRightTip(player, _U('givenservice'), 4000)

    if ConfigWebhook.UseWebhook then
        Core.AddWebhook(ConfigWebhook.WebhookInfo.ServiceTitle, ConfigWebhook.WebhookInfo.ServiceWebhook,
            Job .. " " .. username .. _U('gaveservice') .. targetname .. amount .. _U('ofchores'),
            ConfigWebhook.WebhookInfo.ServiceColor,
            ConfigWebhook.WebhookInfo.ServiceName, ConfigWebhook.WebhookInfo.ServiceLogo,
            ConfigWebhook.WebhookInfo.ServiceFooterLogo,
            ConfigWebhook.WebhookInfo.ServiceAvatar)
    end
end)

RegisterServerEvent("bcc-law:finishedjail") --Unjail event
AddEventHandler("bcc-law:finishedjail", function(target_id)
    local target = Core.getUser(target_id).getUsedCharacter
    local steam_id = target.identifier
    local Character = target.charIdentifier
    exports.ghmattimysql:execute("SELECT * FROM `jail` WHERE characterid = @characterid",
        { ["@characterid"] = Character }
        , function(result)
            if result[1] then
                local loc = result[1]["jaillocation"]
                TriggerClientEvent("bcc-law:UnjailPlayer", target_id, loc)
            end
        end)
    exports.ghmattimysql:execute("DELETE FROM jail WHERE identifier = @identifier AND characterid = @characterid",
        { ["@identifier"] = steam_id, ["@characterid"] = Character })
end)

RegisterServerEvent("bcc-law:unjailed") --Unjail event
AddEventHandler("bcc-law:unjailed", function(target_id, loc)
    local _source = source
    local target = Core.getUser(target_id).getUsedCharacter
    local user = Core.getUser(_source).getUsedCharacter
    local username = user.firstname .. ' ' .. target.lastname
    local Job = user.job
    local targetname = target.firstname .. ' ' .. target.lastname
    local steam_id = target.identifier
    local Character = target.charIdentifier
    exports.ghmattimysql:execute("SELECT * FROM `jail` WHERE characterid = @characterid",
        { ["@characterid"] = Character }
        , function(result)
            if result[1] then
                local loc = result[1]["jaillocation"]
                TriggerClientEvent("bcc-law:UnjailPlayer", target_id, loc)
            end
        end)
    exports.ghmattimysql:execute("DELETE FROM jail WHERE identifier = @identifier AND characterid = @characterid",
        { ["@identifier"] = steam_id, ["@characterid"] = Character })

    if ConfigWebhook.UseWebhook then
        Core.AddWebhook(ConfigWebhook.WebhookInfo.JailTitle, ConfigWebhook.WebhookInfo.JailWebhook,
            Job .. " " .. username .. _U('unjailed') .. targetname, ConfigWebhook.WebhookInfo.JailColor,
            ConfigWebhook.WebhookInfo.JailName, ConfigWebhook.WebhookInfo.JailLogo,
            ConfigWebhook.WebhookInfo.JailFooterLogo,
            ConfigWebhook.WebhookInfo.JailAvatar)
    end
end)

RegisterServerEvent('bcc-law:GetID') -- Get id event currently not used/ *now fixed
AddEventHandler('bcc-law:GetID', function(player)
    local _source = tonumber(source)

    local User = Core.getUser(player)
    local Target = User.getUsedCharacter

    Core.NotifyLeft(_source, _U('idcheck'),
        _U('name') .. Target.firstname .. ' ' .. Target.lastname .. "             " .. _U('job') .. Target.job,
        "toasts_mp_generic", "toast_mp_customer_service", 8000, "COLOR_WHITE")
end)

RegisterServerEvent('bcc-law:getVehicleInfo') --Get vehicle/horse owner event
AddEventHandler('bcc-law:getVehicleInfo', function(player, mount)
    local _source = tonumber(source)

    local User = Core.getUser(player)
    local Character = User.getUsedCharacter

    exports.ghmattimysql:execute("SELECT * FROM `horses` WHERE charid=@identifier",
        { identifier = Character.charIdentifier }
        , function(result)
            local found = false
            if result[1] then
                for i, v in pairs(result) do
                    if GetHashKey(v.model) == mount then
                        found = true
                        Core.NotifyLeft(_source, _U('idcheck'),
                            _U('name') .. Character.firstname .. ' ' .. Character.lastname .. '', "toasts_mp_generic",
                            "toast_mp_customer_service", 8000, "COLOR_WHITE")
                    end
                end
            end
            if not found then
                Core.NotifyLeft(_source, _U('idcheck'), _U('notowned'), "toasts_mp_generic",
                    "toast_mp_customer_service"
                    , 8000, "COLOR_WHITE")
            end
        end)
end)



RegisterServerEvent('bcc-law:handcuff', function(player)
    TriggerClientEvent('bcc-law:handcuff', player)
end)

RegisterServerEvent('bcc-law:lockpicksv') --Lockpick Handcuff event
AddEventHandler('bcc-law:lockpicksv', function(player)
    local _source = source
    local chance = math.random(1, 100)
    if chance < 5 then
        exports.vorp_inventory:subItem(_source, 'lockpick', 1)
        Core.NotifyRightTip(_source, _U('lockpickbroke'), 4000)
    else
        TriggerClientEvent('bcc-law:lockpicked', player)
    end
end)

RegisterServerEvent('bcc-law:drag') --Drag Event
AddEventHandler('bcc-law:drag', function(target)
    local _source = source
    local user = Core.getUser(_source).getUsedCharacter
    for i, v in pairs(OnDutyJobs) do
        if user.job == v then
            TriggerClientEvent('bcc-law:drag', target, _source)
        end
    end
end)

RegisterServerEvent("bcc-law:updateservice") --Update chore amount when chore is completed event
AddEventHandler("bcc-law:updateservice", function()
    local _source = source
    Citizen.Wait(2000)
    local User = Core.getUser(_source)
    local CharInfo = User.getUsedCharacter
    local steam_id = CharInfo.identifier
    local Character = CharInfo.charIdentifier
    exports.ghmattimysql:execute(
        "SELECT * FROM communityservice WHERE identifier = @identifier AND characterid = @characterid"
        , { ["@identifier"] = steam_id, ["@characterid"] = Character }, function(result)
            if result[1] ~= nil then
                local count = result[1]["servicecount"]
                local identifier = result[1]["identifier"]
                local charid = result[1]["characterid"]
                exports.ghmattimysql:execute(
                    "UPDATE communityservice SET servicecount = @count WHERE identifier = @identifier AND characterid = @characterid"
                    , { ["@identifier"] = identifier, ["@characterid"] = charid, ["@count"] = count - 1 })
            end
        end)
end)

RegisterNetEvent("bcc-law:endservice") -- Finished Community Service Event
AddEventHandler("bcc-law:endservice", function()
    local _source = source
    local User = Core.getUser(_source)
    local CharInfo = User.getUsedCharacter
    local steam_id = CharInfo.identifier
    local Character = CharInfo.charIdentifier
    exports.ghmattimysql:execute(
        "DELETE FROM communityservice WHERE identifier = @identifier AND characterid = @characterid"
        , { ["@identifier"] = steam_id, ["@characterid"] = Character }, function(result)
            if result[1] ~= nil then
                Core.NotifyRightTip(_source, _U('servicecomplete'), 4000)
            end
        end)
end)

RegisterNetEvent("bcc-law:jailedservice") --Jailed from breaking community service event
AddEventHandler("bcc-law:jailedservice", function()
    local _source = source

    local User = Core.getUser(_source)
    local CharInfo = User.getUsedCharacter
    local steam_id = CharInfo.identifier

    local Character = CharInfo.charIdentifier
    exports.ghmattimysql:execute(
        "DELETE FROM communityservice WHERE identifier = @identifier AND characterid = @characterid"
        , { ["@identifier"] = steam_id, ["@characterid"] = Character }, function(result)
            if result[1] ~= nil then
                Core.NotifyRightTip(_source, _U('jailed'), 4000)
            end
        end)
end)


RegisterServerEvent("bcc-law:check_jail") --Check if jailed when selecting character event
AddEventHandler("bcc-law:check_jail", function()
    local _source = source
    Wait(2000)
    local User = Core.getUser(_source)
    local CharInfo = User.getUsedCharacter
    local steam_id = CharInfo.identifier
    local Character = CharInfo.charIdentifier
    exports.ghmattimysql:execute("SELECT * FROM jail WHERE identifier = @identifier AND characterid = @characterid",
        { ["@identifier"] = steam_id, ["@characterid"] = Character }, function(result)
            if result[1] ~= nil then
                local time = result[1]["time_s"]
                local identifier = result[1]["identifier"]
                exports.ghmattimysql:execute("UPDATE jail SET time = @time WHERE identifier = @identifier",
                    { ["@time"] = getTime() + time, ["@identifier"] = identifier })
                time = tonumber(time)
                TriggerClientEvent("bcc-law:JailPlayer", _source, time)
                TriggerEvent("bcc-law:wear_prison", _source)
            end
        end)
end)

RegisterNetEvent("bcc-law:jailbreak") --Jail break event, deletes time in jail
AddEventHandler("bcc-law:jailbreak", function()
    local _source = source
    Wait(1000)
    local User = Core.getUser(_source)
    local CharInfo = User.getUsedCharacter
    local steam_id = CharInfo.identifier
    local Character = CharInfo.charIdentifier
    exports.ghmattimysql:execute("DELETE FROM jail WHERE identifier = @identifier AND characterid = @characterid",
        { ["@identifier"] = steam_id, ["@characterid"] = Character }, function(result)
        end)
end)

RegisterServerEvent("bcc-law:taketime") --Updates timer of how long left in jail defined by player
AddEventHandler("bcc-law:taketime", function()
    local _source = source
    local User = Core.getUser(_source)
    local CharInfo = User.getUsedCharacter
    local steam_id = CharInfo.identifier
    local Character = CharInfo.charIdentifier
    exports.ghmattimysql:execute("SELECT * FROM jail WHERE identifier = @identifier AND characterid = @characterid",
        { ["@identifier"] = steam_id, ["@characterid"] = Character }, function(result)
            if result[1] ~= nil then
                local time = result[1]["time_s"]
                local newtime = time - 30
                local identifier = result[1]["identifier"]
                exports.ghmattimysql:execute("UPDATE jail SET time_s = @time WHERE identifier = @identifier",
                    { ["@time"] = newtime, ["@identifier"] = identifier })
            end
        end)
end)

RegisterServerEvent("bcc-law:guncabinet") -- Adds weapon from gun cabinet
AddEventHandler("bcc-law:guncabinet", function(weapon, ammoList, compList)
    local _source = source
    exports.vorp_inventory:createWeapon(_source, weapon, ammoList, compList)
end)

RegisterServerEvent("bcc-law:addammo") -- Adds weapon from gun cabinet
AddEventHandler("bcc-law:addammo", function(ammotype)
    local _source = source
    exports.vorp_inventory:addItem(_source, ammotype, 1)
end)

function getTime() -- GEt time function
    return os.time(os.date("!*t"))
end

RegisterServerEvent('bcc-law:lockpick:break') --Lockpick broke event
AddEventHandler('bcc-law:lockpick:break', function()
    local _source = source
    exports.vorp_inventory:subItem(_source, "lockpick", 1)
    Core.NotifyRightTip(_source, _U('lockpickbroke'), 4000)
end)

exports.vorp_inventory:registerUsableItem("lockpick", function(data) --Lockpick usable
    exports.vorp_inventory:closeInventory(data.source)
    TriggerClientEvent("bcc-law:lockpick", data.source)
end)

exports.vorp_inventory:registerUsableItem("handcuffs", function(data) --Handcuffs usable
    exports.vorp_inventory:closeInventory(data.source)
    TriggerClientEvent("bcc-law:cuffs", data.source)
end)

function CheckTable(table, element)
    for k, v in pairs(table) do
        if v == element then
            return true
        end
    end
    return false
end

RegisterServerEvent("bcc-law:policenotify")
AddEventHandler("bcc-law:policenotify", function(coords)
    for z, m in ipairs(GetPlayers()) do
        local User = Core.getUser(m)
        local used = User.getUsedCharacter
        if CheckTable(OnDutyJobs, used.job) then -- if job exist in table then pass
            Wait(200)
            TriggerClientEvent("bcc-law:witness", m, coords)
        end
    end
end)

RegisterCommand(ConfigMain.finecommand, function(source, args, rawCommand)
    local _source = source -- player source
    local Character = Core.getUser(_source).getUsedCharacter
    local target = args[1]
    local fine = args[2]
    if Character.group == "admin" or CheckTable(OnDutyJobs, job) then
        TriggerEvent("bcc-law:FinePlayer", tonumber(target), tonumber(fine))
    end
end)

RegisterCommand(ConfigMain.jailcommand, function(source, args, rawCommand)
    local _source = source -- player source
    local Character = Core.getUser(_source).getUsedCharacter
    local job = Character.job
    local target = args[1]
    local jailtime = args[2]
    local jailid = args[3]
    if jailid == nil then
        jailid = 'sk'
    end
    if Character.group == "admin" or CheckTable(OnDutyJobs, job) then
        TriggerEvent('bcc-law:JailPlayer', tonumber(target), tonumber(jailtime), jailid)
    end
end)

RegisterCommand(ConfigMain.unjailcommand, function(source, args, rawCommand)
    local _source = source -- player source

    local Character = Core.getUser(_source).getUsedCharacter
    local target = tonumber(args[1])
    if target then
        if Core.getUser(target) then
            if Character.group == "admin" or CheckTable(OnDutyJobs, job) then
                TriggerEvent("bcc-law:unjailed", target)
            end
        end
    end
end)

RegisterServerEvent("bcc-law:GetPlayerWagonID") -- Take out vehicle event not currently used
AddEventHandler("bcc-law:GetPlayerWagonID", function(player)
    if player ~= nil then
        TriggerClientEvent('bcc-law:PlayerInWagon', player)
    end
end)

RegisterServerEvent('syn_search:TakeFromsteal')
AddEventHandler('syn_search:TakeFromsteal', function(obj)
    local _source = source
    TriggerClientEvent('bcc-law:GetSearch', _source, obj)
    TriggerClientEvent("vorp_inventory:CloseInv", _source)
end)

RegisterServerEvent('bcc-law:TakeFrom')
AddEventHandler('bcc-law:TakeFrom', function(obj, steal_source)
    local _steal_source = steal_source
    local _source = source
    local target = Core.getUser(_steal_source).getUsedCharacter
    local targetname = target.firstname .. ' ' .. target.lastname
    local user = Core.getUser(_source).getUsedCharacter
    local username = user.firstname .. ' ' .. user.lastname
    local Job = user.job

    local decode_obj = json.decode(obj)

    if decode_obj.type ~= 'item_weapon' and tonumber(decode_obj.number) > 0 and
        tonumber(decode_obj.number) <= tonumber(decode_obj.item.count) then
        local canCarry = exports.vorp_inventory:canCarryItem(_source, decode_obj.item.name, decode_obj.number)
        if canCarry then
            exports.vorp_inventory:subItem(_steal_source, decode_obj.item.name, decode_obj.number, decode_obj.item.metadata)
            exports.vorp_inventory:addItem(_source, decode_obj.item.name, decode_obj.number, decode_obj.item.metadata)
            Core.NotifyRightTip(_source, _U('took') .. decode_obj.number .. " " .. decode_obj.item.label, 4000)
            Wait(100)
            TriggerEvent('bcc-law:ReloadInventory', _steal_source, _source)
            if ConfigWebhook.UseWebhook then
                Core.AddWebhook(ConfigWebhook.WebhookInfo.SearchedTitle, ConfigWebhook.WebhookInfo.SearchedWebhook,
                    Job ..
                    " " ..
                    username ..
                    _U('took') .. decode_obj.number .. " " .. decode_obj.item.label .. _U('from') .. targetname,
                    ConfigWebhook.WebhookInfo.SearchedColor,
                    ConfigWebhook.WebhookInfo.SearchedName, ConfigWebhook.WebhookInfo.SearchedLogo,
                    ConfigWebhook.WebhookInfo.SearchedFooterLogo,
                    ConfigWebhook.WebhookInfo.SearchedAvatar)
            end
        else
        end
    elseif decode_obj.type == 'item_weapon' then
        exports.vorp_inventory:canCarryWeapons(_source, decode_obj.number, function(cb)
            local canCarry = cb
            if canCarry then
                exports.vorp_inventory:subWeapon(_steal_source, decode_obj.item.id)
                exports.vorp_inventory:giveWeapon(_source, decode_obj.item.id, 0)
                Core.NotifyRightTip(_source, _U('took') .. decode_obj.item.label .. _U('from') .. targetname, 4000)

                Wait(100)
                TriggerEvent('bcc-law:ReloadInventory', _steal_source, _source)
                if ConfigWebhook.UseWebhook then
                    Core.AddWebhook(ConfigWebhook.WebhookInfo.SearchedTitle,
                        ConfigWebhook.WebhookInfo.SearchedWebhook,
                        Job ..
                        " " ..
                        username ..
                        _U('took') .. decode_obj.number .. " " .. decode_obj.item.label .. _U('from') .. targetname,
                        ConfigWebhook.WebhookInfo.SearchedColor,
                        ConfigWebhook.WebhookInfo.SearchedName, ConfigWebhook.WebhookInfo.SearchedLogo,
                        ConfigWebhook.WebhookInfo.SearchedFooterLogo,
                        ConfigWebhook.WebhookInfo.SearchedAvatar)
                end
            else
            end
        end)
    end
end)

RegisterServerEvent('bcc-law:ReloadInventory')
AddEventHandler('bcc-law:ReloadInventory', function(steal_source, player_source)
    local _steal_source = steal_source
    local _source
    if not player_source then
        _source = source
    else
        _source = player_source
    end
    local inventory = {}

    TriggerEvent('vorpCore:getUserInventory', tonumber(_steal_source), function(getInventory)
        for _, item in pairs(getInventory) do
            local data_item = {
                count = item.count,
                name = item.name,
                limit = item.limit,
                type = item.type,
                label = item.label,
                metadata = item.metadata,
            }
            table.insert(inventory, data_item)
        end
    end)
    TriggerEvent('vorpCore:getUserWeapons', tonumber(_steal_source), function(getUserWeapons)
        for _, weapon in pairs(getUserWeapons) do
            local data_weapon = {
                count = -1,
                name = weapon.name,
                limit = -1,
                type = 'item_weapon',
                label = '',
                id = weapon.id,
            }
            table.insert(inventory, data_weapon)
        end
    end)

    local data = {
        itemList = inventory,
        action = 'setSecondInventoryItems',
    }
    TriggerClientEvent('vorp_inventory:ReloadstealInventory', _source, json.encode(data))
end)


----- Commisary add item ----
RegisterServerEvent('bcc-law:CommisaryAddItem', function()
    local _source = source
    exports.vorp_inventory:addItem(_source, ConfigJail.Jails.sisika.Commisary.FoodItem, 1)
    exports.vorp_inventory:addItem(_source, ConfigJail.Jails.sisika.Commisary.WaterItem, 1)
end)
----- check handcuffs are in inv ----


RegisterServerEvent('bcc-law:CheckHandcuffs')
AddEventHandler('bcc-law:CheckHandcuffs', function()
    local _source = source
    local hasHandcuffs = false

    TriggerEvent('vorpCore:getUserInventory', tonumber(_source), function(inventory)
        for _, item in pairs(inventory) do
            if item.name == 'handcuffs' then
                hasHandcuffs = true
                break
            end
        end

        TriggerClientEvent('bcc-law:HandcuffsChecked', _source, hasHandcuffs)
    end)
end)


RegisterServerEvent('bcc-law:CheckLedgerSv')
AddEventHandler('bcc-law:CheckLedgerSv', function(cabid)
    local _source = source
    local user = Core.getUser(_source).getUsedCharacter
    if not user then return end
    local job = user.job
    print(job)
    exports.ghmattimysql:execute("SELECT ledger FROM `society_ledger` WHERE job = @jobname",
        { ["@jobname"] = job }
        , function(result)
            if result[1] then
                print(result[1].ledger)
                TriggerClientEvent("bcc-law:CheckLedgerCl", _source, result[1].ledger, cabid)
            end
        end)
end)

RegisterServerEvent('bcc-law:ChangeLedger')
AddEventHandler('bcc-law:ChangeLedger', function(deposit, amount)
    local _source = source
    local user = Core.getUser(_source).getUsedCharacter
    if not user then return end
    local job = user.job

    if deposit then
        exports.ghmattimysql:execute("SELECT ledger FROM `society_ledger` WHERE job = @jobname",
            { ["@jobname"] = job }
            , function(result)
                if result[1] then
                    local ledgeramount = result[1].ledger
                    exports.ghmattimysql:executeSync(
                        'UPDATE society_ledger SET ledger = @ledgeramount + @amount WHERE job = @job'
                        , { ledgeramount = ledgeramount, amount = amount, job = job })
                    user.removeCurrency(0, amount)
                end
            end)
    else
        exports.ghmattimysql:execute("SELECT ledger FROM `society_ledger` WHERE job = @jobname",
            { ["@jobname"] = job }
            , function(result)
                if result[1] then
                    local ledgeramount = result[1].ledger
                    exports.ghmattimysql:executeSync(
                        'UPDATE society_ledger SET ledger = @ledgeramount - @amount WHERE job = @job'
                        , { ledgeramount = ledgeramount, amount = amount, job = job })
                    user.addCurrency(0, amount)
                end
            end)
    end
    TriggerClientEvent('bcc-law:OpenBossMenu', _source)
end)

RegisterServerEvent('bcc-law:PlayerJob')
AddEventHandler('bcc-law:PlayerJob', function()
    local _source = source
    local Character = Core.getUser(_source).getUsedCharacter
    local CharacterJob = Character.job
    local grade = Character.jobGrade
    TriggerClientEvent('bcc-law:PlayerJob', _source, { job = CharacterJob, grade = grade })
end)

RegisterServerEvent('bcc-law:ReloadInventory')
AddEventHandler('bcc-law:ReloadInventory', function(steal_source, player_source)
    local _steal_source = steal_source
    local _source
    if not player_source then
        _source = source
    else
        _source = player_source
    end
    local inventory = {}

    TriggerEvent('vorpCore:getUserInventory', tonumber(_steal_source), function(getInventory)
        for _, item in pairs(getInventory) do
            local data_item = {
                count = item.count,
                name = item.name,
                limit = item.limit,
                type = item.type,
                label = item.label,
                metadata = item.metadata,
            }
            table.insert(inventory, data_item)
        end
    end)
    TriggerEvent('vorpCore:getUserWeapons', tonumber(_steal_source), function(getUserWeapons)
        for _, weapon in pairs(getUserWeapons) do
            local data_weapon = {
                count = -1,
                name = weapon.name,
                limit = -1,
                type = 'item_weapon',
                label = '',
                id = weapon.id,
            }
            table.insert(inventory, data_weapon)
        end
    end)

    local data = {
        itemList = inventory,
        action = 'setSecondInventoryItems',
    }
    TriggerClientEvent('vorp_inventory:ReloadstealInventory', _source, json.encode(data))
end)


RegisterServerEvent("bcc-law:FireEmployee") --Update chore amount when chore is completed event
AddEventHandler("bcc-law:FireEmployee", function(charid)
    exports.ghmattimysql:executeSync(
        'UPDATE characters SET job = @job WHERE charidentifier = @charid'
        , { charid = charid, job = 'unemployed' })
    Core.NotifyRightTip(source, _U('youfired'), 4000)
end)

RegisterServerEvent("bcc-law:HireEmployee") --Update chore amount when chore is completed event
AddEventHandler("bcc-law:HireEmployee", function(id)
    local newid = id
    exports.ghmattimysql:executeSync(
        'UPDATE characters SET job = @job WHERE charidentifier = @charid'
        , { charid = newid, job = 'offpolice' })
    Core.NotifyRightTip(source, _U('youhired'), 4000)
end)

RegisterServerEvent("bcc-law:GiveNearbyPoliceSv") --Update chore amount when chore is completed event
AddEventHandler("bcc-law:GiveNearbyPoliceSv", function(ids, cabid)
    local PlayerInfo = {}
    for index, value in ipairs(ids) do
        local char = Core.getUser(value).getUsedCharacter
        local firstname = char.firstname
        local lastname = char.lastname
        local charid = char.charIdentifier
        table.insert(PlayerInfo, { firstname = firstname, lastname = lastname, id = charid })
    end
    TriggerClientEvent('bcc-law:HireEmployeeMenu', source, PlayerInfo, cabid)
end)


RegisterServerEvent("bcc-law:GetPoliceSv") --Update chore amount when chore is completed event
AddEventHandler("bcc-law:GetPoliceSv", function(cabid)
    local _source = source
    exports.ghmattimysql:execute(
        "SELECT firstname, lastname,charidentifier FROM characters WHERE job = @job"
        , { ["@job"] = 'police' and 'offpolice' }, function(result)
            if result[1] ~= nil then
                TriggerClientEvent('bcc-law:FireEmployeeMenu', _source, result, cabid)
            end
        end)
end)

RegisterServerEvent("bcc-law:RegisterStorageSv") --Update chore amount when chore is completed event
AddEventHandler("bcc-law:RegisterStorageSv", function()
    print('is this working')

    if InventoryOptions.privatestorage then
        if InventoryOptions.allstoragessame then
            local data = {
                InventoryOptions.id .. 'personal',
                InventoryOptions.name,
                InventoryOptions.privatelimit,
                InventoryOptions.acceptWeapons,
                false,
                InventoryOptions.ignorestacklimit,
                InventoryOptions.whitelistitems,
                false,
                InventoryOptions.usewhitelist,
                InventoryOptions.whitelistweapons
            }
            exports.vorp_inventory:registerInventory(data)
        else
            for key, value in pairs(ConfigCabinets.Guncabinets) do
                local data = {
                    InventoryOptions.id .. '[' .. key .. ']' .. 'personal',
                    InventoryOptions.name,
                    InventoryOptions.privatelimit,
                    InventoryOptions.acceptWeapons,
                    false,
                    InventoryOptions.ignorestacklimit,
                    InventoryOptions.whitelistitems,
                    false,
                    InventoryOptions.usewhitelist,
                    InventoryOptions.whitelistweapons
                }
                exports.vorp_inventory:registerInventory(data)
            end
        end
    end
    if InventoryOptions.sharedstorage then
        if InventoryOptions.allstoragessame then
            local data = {
                InventoryOptions.id,
                InventoryOptions.name,
                InventoryOptions.privatelimit,
                InventoryOptions.acceptWeapons,
                true,
                InventoryOptions.ignorestacklimit,
                InventoryOptions.whitelistitems,
                false,
                InventoryOptions.usewhitelist,
                InventoryOptions.whitelistweapons
            }
            exports.vorp_inventory:registerInventory(data)
        else
            for key, value in pairs(ConfigCabinets.Guncabinets) do
                local data = {
                    InventoryOptions.id .. '[' .. key .. ']',
                    InventoryOptions.name,
                    InventoryOptions.privatelimit,
                    InventoryOptions.acceptWeapons,
                    true,
                    InventoryOptions.ignorestacklimit,
                    InventoryOptions.whitelistitems,
                    false,
                    InventoryOptions.usewhitelist,
                    InventoryOptions.whitelistweapons
                }
                exports.vorp_inventory:registerInventory(data)
            end
        end
    end
end)

RegisterServerEvent("bcc-law:OpenStorageSv") --Update chore amount when chore is completed event
AddEventHandler("bcc-law:OpenStorageSv", function(cabinetid, storagetype)
    local _source = source
    if storagetype == 'personal' then
        if InventoryOptions.allstoragessame then
            print('we got to here')
            exports.vorp_inventory:openInventory(_source, InventoryOptions.id .. 'personal')
        else
            exports.vorp_inventory:openInventory(_source, InventoryOptions.id .. '[' .. cabinetid .. ']' .. 'personal')
        end
    else
        if InventoryOptions.allstoragessame then
            exports.vorp_inventory:openInventory(_source, InventoryOptions.id)
        else
            exports.vorp_inventory:openInventory(_source, InventoryOptions.id .. '[' .. cabinetid .. ']')
        end
    end
end)

AddEventHandler('playerDropped', function()
    local _source = source
    local player = Core.getUser(_source).getUsedCharacter
    local job = player.job
    local grade = player.jobGrade
    for k, v in pairs(OnDutyJobs) do
        if v == job then
            player.setJob('off' .. job, grade)
        end
        TriggerClientEvent("bcc-law:onduty", _source, false)
    end
end)
