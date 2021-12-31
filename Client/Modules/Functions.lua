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
                return JOB.Notify("You do not have vehicles, add them in the job management")
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
}

---comment
---@param str any
---@return string
JOB.FirstToUpper = function(str)
    return (str:gsub("^%l", string.upper))
end

JOB.SpawnVehicle = function (vehicle)
    local veh = GetHashKey(vehicle)
    if not HasModelLoaded(veh) and IsModelInCdimage(veh) then
		RequestModel(veh)

		while not HasModelLoaded(veh) do
			Citizen.Wait(4)
		end
	end
	local model = (type(vehicle) == 'number' and vehicle or GetHashKey(vehicle))
	networked = networked == nil and true or networked
	CreateThread(function()
        Wait(2000)
		ESX.Streaming.RequestModel(model)

		local vehicle = CreateVehicle(model, GetEntityCoords(PlayerPedId()), 200, networked, false)

		if networked then
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