JOB.Callbacks = { }
JOB.Variables = {
    IsOpen = false,
    PlayerId = GetPlayerServerId(PlayerId()),
    IsChanging = false,
    OwnJob = nil,
}

---comment
---@param name any
---@param cb any
---@param ... any
JOB.ExecuteCallback = function(name, cb, ...)
    JOB.Callbacks[name] = cb
    TriggerServerEvent("jobcreatorv2:server:handleCallback", name, ...)
end

---comment
---@param name any
---@param ... any
JOB.HandleCallback = function(name, ...)
    if JOB.Callbacks[name] then
        JOB.Callbacks[name](...)
    end
end

RegisterNetEvent("jobcreatorv2:client:handleCallback", JOB.HandleCallback)

JOB.OpenUi = function()
    SendNUIMessage({ type = "open" })
    JOB.RefreshData()
    SetNuiFocus(true, true)
    JOB.Variables['IsOpen'] = true
end

---comment
---@param text any
JOB.Notify = function (text)
    SetNotificationTextEntry('STRING')
	AddTextComponentString(text)
	DrawNotification(false, true)
end

RegisterNetEvent("jobcreatorv2:client:openUi", JOB.OpenUi)

---comment
---@param coords any
---@param msg any
JOB.FloatingNotify = function (coords, msg)
    SetFloatingHelpTextWorldPosition(1, coords.x, coords.y, coords.z + 0.9)
	SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
	BeginTextCommandDisplayHelp('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandDisplayHelp(2, false, true, -1)
end

---comment
---@param string any
JOB.GetLocale = function(string)
    return Cfg.Locales[Cfg.Locale][string] 
end

RegisterNUICallback("createJob", function(data, cb)

    TriggerServerEvent("jobcreatorv2:server:sendNewJobData", data.data)

    cb(json.encode("Cherryoz was here"))
end)

RegisterNetEvent("jobcreatorv2:client:initData", JOB.HandleAll)

JOB.Markers = {
    ---comment
    ---@param coords any
    ['armory'] = function (coords)
        JOB.FloatingNotify(coords, JOB.GetLocale("openArmory"))
        if IsControlJustPressed(1, 38) then
            JOB.OpenArmory()
        end
    end,
    ---comment
    ---@param coords any
    ['getvehs'] = function (coords)
        JOB.FloatingNotify(coords, JOB.GetLocale("getVehs"))
        if IsControlJustPressed(1, 38) then
            local OwnData = GlobalState[JOB.Variables.PlayerId.."-jobplayer"]
            local JobData = GlobalState[OwnData.jobdata.name.."-guille"]
            
            local VehData = {}
            for k, v in pairs(JobData['publicvehicles']) do
                table.insert(VehData, {label = JOB.FirstToUpper(v), value = v})
            end
            if #VehData == 0 then
                return JOB.JOB.Notify("You do not have vehicles, add them in the job management")
            end
            JOB.OpenMenu("Vehicles", "vehs_menu", VehData, function (data, menu)
                local v = data.current.value
                JOB.SpawnVehicle(v)
                menu.close()
            end)
        end
    end,
    ---comment
    ---@param coords any
    ['savevehs'] = function (coords)
        JOB.FloatingNotify(coords, JOB.GetLocale("saveVehs"))
        if IsControlJustPressed(1, 38) then
            CreateThread(function ()
                local Vehicle = GetVehiclePedIsIn(PlayerPedId())
                TaskLeaveVehicle(PlayerPedId(), Vehicle, 0)
                Wait(3000)
                NetworkFadeOutEntity(Vehicle, false, true)
                Wait(3000)
                DeleteVehicle(Vehicle)
            end)
        end
    end,
    ---comment
    ---@param coords any
    ['boss'] = function (coords)
        JOB.FloatingNotify(coords, JOB.GetLocale("boss"))
        if IsControlJustPressed(1, 38) then

        end
    end,
    ---comment
    ---@param coords any
    ['shop'] = function (coords)
        JOB.FloatingNotify(coords, JOB.GetLocale("openShop"))
        if IsControlJustPressed(1, 38) then

        end
    end,

    ['wardrobe'] = function (coords)
        JOB.FloatingNotify(coords, JOB.GetLocale("openWardrobe"))
        if IsControlJustPressed(1, 38) then

        end
    end,
}

---comment
---@param str string
---@return string
JOB.FirstToUpper = function(str)
    return (str:gsub("^%l", string.upper))
end

---comment
---@param vehicle any
JOB.SpawnVehicle = function (vehicle)
    local veh = GetHashKey(vehicle)
    if not HasModelLoaded(veh) and IsModelInCdimage(veh) then
		RequestModel(veh)

		while not HasModelLoaded(veh) do
			Citizen.Wait(4)
		end
	end
	local model = (type(vehicle) == 'number' and vehicle or GetHashKey(vehicle))
	Networked = Networked == nil and true or Networked
	CreateThread(function()
        Wait(1000)
		ESX.Streaming.RequestModel(model)

		local vehicle = CreateVehicle(model, GetEntityCoords(PlayerPedId()), 200, Networked, false)

		if Networked then
			local id = NetworkGetNetworkIdFromEntity(vehicle)
			SetNetworkIdCanMigrate(id, true)
			SetEntityAsMissionEntity(vehicle, true, false)
		end
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetModelAsNoLongerNeeded(model)
		SetVehRadioStation(vehicle, 'OFF')

		RequestCollisionAtCoord(GetEntityCoords(PlayerPedId()))
		while not HasCollisionLoadedAroundEntity(vehicle) do
			Citizen.Wait(0)
		end
        local heading = 0.00
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        local coords = GetEntityCoords(PlayerPedId())
        CreateThread(function ()
            while true do
                DisableControlAction(0, 75, true)  -- Disable exit vehicle when stop
                DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
                SetEntityAlpha(vehicle, 180, 0)
                SetVehicleUndriveable(vehicle, true)
                if IsControlPressed(1, 175) then
                    heading = heading + 0.50
                elseif IsControlPressed(1, 174) then
                    heading = heading - 0.50
                elseif IsControlPressed(1, 176) then
                    ResetEntityAlpha(vehicle)
                    SetVehicleUndriveable(vehicle, false)
                    break
                end 
                SetEntityHeading(vehicle, heading)
                SetEntityCoords(vehicle, coords)
                Wait(0)
            end
        end)
	end)
end
---Stash functions

JOB.OpenArmory = function ()
    if Cfg.Framework == "esx" then
        local elements = {}
        table.insert(elements, { label = "Put items", value = "put" })
        table.insert(elements, { label = "Get items", value = "get" })
        JOB.OpenMenu("Gang Inventory", "gang_inv", elements, function (data, menu)
            local v = data.current.value
            if v == "put" then
                JOB.PutStock()
                menu.close()
            elseif v == "get" then
                JOB.GetStock()
                menu.close()
            end
        end)
    else
        
    end
end

--- ESX ONLY

JOB.PutStock = function ()
    JOB.ExecuteCallback('jobcreatorv2:server:getPlyInv', function(accounts, items, weapons)
        local elements = {}
        table.insert(elements, {label = "--Accounts--"})
        for k, v in pairs(accounts) do
            if v.name ~= "bank" then
                table.insert(elements, {itemL = v.label, label = v.label.." - "..v.money.."$" , type = "account", quantity = v.money, name = v.name})
            end
        end
        table.insert(elements, {label = "--Items--"})
        for k, v in pairs(items) do
            if v.count >= 1 then
                table.insert(elements, {itemL = v.label,  label = v.label.." - x"..v.count, type = "item", quantity = v.count, name = v.name})
            end
        end
        table.insert(elements, {label = "--Weapons--"})
        for k, v in pairs(weapons) do
            table.insert(elements, {itemL = v.label, label = v.label.." - x"..v.ammo, type = "weapon", quantity = v.ammo, name = v.name})
        end
        ESX.UI.Menu.Open('default',GetCurrentResourceName(),"my_inv",
        { 
        title = "your_inv", 
        align = "bottom-right", 
        elements = elements 
        }, function(data, menu)
        if data.current.type == "account" then
            ESX.UI.Menu.Open('dialog',GetCurrentResourceName(),"def_count",
            { 
            title = "how_mon", 
            align = "middle", 
            elements = elements 
            }, function(data2, menu2)
                local count = tonumber(data2.value)
                if count == nil or count == 0 then
                    JOB.Notify('inv_ammount')
                else
                    if count <= data.current.quantity then
                        menu2.close()
                        TriggerServerEvent('jobcreatorv2:server:addItemToInv', data.current.type, data.current.name, count, data.current.itemL, JOB.Variables.OwnJob.name)
                        JOB.PutStock()
                    else
                        JOB.Notify('inv_ammount')
                    end
                end
            end, function(data2, menu2) 
                menu2.close()
                JOB.PutStock()
            end)
        elseif data.current.type == "item" then
            ESX.UI.Menu.Open('dialog',GetCurrentResourceName(),"def_count_2",
            { 
            title = "How_much_items?", 
            align = "middle", 
            elements = elements 
            }, function(data2, menu2)
                local count = tonumber(data2.value)
                if count == nil or count == 0 then
                    JOB.Notify('inv_ammount')
                else
                    if count <= data.current.quantity then
                        menu2.close()
                        TriggerServerEvent('jobcreatorv2:server:addItemToInv', data.current.type, data.current.name, count, data.current.itemL, JOB.Variables.OwnJob.name)
                        JOB.PutStock()
                    else
                        JOB.Notify('inv_ammount')
                    end
                end
            end, function(data2, menu2) 
                menu2.close()
                JOB.PutStock()
            end)
        elseif data.current.type == "weapon" then
            TriggerServerEvent('jobcreatorv2:server:addItemToInv', data.current.type, data.current.name, data.current.quantity, data.current.itemL,  JOB.Variables.OwnJob.name)
            menu.close()
            JOB.PutStock()
        end
        end, function(data, menu) 
            menu.close() 
        end)
    end)
end

JOB.GetStock = function ()
    ESX.UI.Menu.CloseAll()
    local OwnData = GlobalState[JOB.Variables.PlayerId.."-jobplayer"]
    JOB.Variables.OwnJob = OwnData.jobdata
    local JobData = GlobalState[OwnData.jobdata.name.."-guille"]
    local elements = {}
    for k, v in pairs(JobData.inventory) do
        
        if v.type == "account" then
            table.insert(elements, {label = v.label.." - "..v.count.."$" , type = v.type, quantity = v.count, name = v.name})
        elseif v.type == "item" then
            table.insert(elements, {label = v.label.." - x"..v.count , type = v.type, quantity = v.count, name = v.name})
        elseif v.type == "weapon" then
            table.insert(elements, {label = v.label.." - x"..v.count , type = v.type, quantity = v.count, name = v.name})
        end
    end
    ESX.UI.Menu.Open('default',GetCurrentResourceName(),"get_stock",
    { 
    title = "gang_inv", 
    align = "bottom-right", 
    elements = elements 
    }, function(data, menu)
        if data.current.type ~= "weapon" then
            ESX.UI.Menu.Open('dialog',GetCurrentResourceName(),"def_count_3",
            { 
            title = "How_much_items?", 
            align = "middle", 
            }, function(data2, menu2)
                local count = tonumber(data2.value)
                if count == nil or count == 0 then
                    JOB.Notify('inv_ammount')
                else
                    if count <= data.current.quantity then
                        TriggerServerEvent("jobcreatorv2:server:removeItemInv", data.current.type, data.current.name, count, JOB.Variables.OwnJob.name)
                        JOB.GetStock()
                        ESX.UI.Menu.CloseAll()
                        
                        
                        
                    else
                        JOB.Notify('inv_ammount')
                    end
                end
            end, function(data2, menu2) 
                menu2.close()
                JOB.GetStock()
            end)
        else
            TriggerServerEvent("jobcreatorv2:server:removeItemInv", data.current.type, data.current.name, data.current.quantity, JOB.Variables.OwnJob.name)
            ESX.UI.Menu.CloseAll()
        end
    end, function(data, menu) 
        menu.close() 
    end)
end