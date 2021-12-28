JOB.Callbacks = { }

---comment
---@param cb any
JOB.Thread = function (cb)
    CreateThread(cb)
end

---@param name any
---@param cb any
JOB.CreateCallback = function(name, cb)
    JOB.Callbacks[name] = cb
    JOB.Print("INFO", "Callback '" ..name.. "' registered")
end

---comment
---@param src any
---@param cb any
JOB.GetPlayer = function(src, cb)
    if cb then
        return cb(JOB.Players[tonumber(src)])
    else
        return JOB.Players[tonumber(src)]
    end
end

---comment
---@param name any
---@param ... any
JOB.HandleCallback = function(name, ...)
    local src <const> = source
    if JOB.Callbacks[name] then
        JOB.Callbacks[name](src, function(...)
            JOB.Players[src].triggerEvent("jobcreatorv2:client:handleCallback", name, ...)
        end, ...)
    end
end

RegisterNetEvent("jobcreatorv2:server:handleCallback", JOB.HandleCallback)


JOB.IsAllowed = function(source, cb)
    local license = nil
    for k,v in ipairs(GetPlayerIdentifiers(source))do
        if string.sub(v, 1, string.len("license:")) == "license:" then
            license = v
        end
    end
    for k, v in pairs(Cfg.Admins) do
        if v == license then
            if cb then
                return cb(true)
            else
                return true
            end
        end
    end
    if cb then
        return cb(false)
    else
        return false
    end
end

---comment
---@param name any
---@param cb any
JOB.RegisterCommand = function(name, cb)
    RegisterCommand(name, function(source, args)
        local src <const> = source
        JOB.IsAllowed(src, function (isAllowed)
            if isAllowed then
                cb(source, args)
            end
        end)
    end)
end