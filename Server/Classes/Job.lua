---comment
---@param name any
---@param label any
---@param ranks any
---@param points any
---@param options any
---@param blips any
---@param publicvehicles any
---@param privatevehicles any
---@return table
JOB.CreateJob = function(name, label, ranks, points, options, blips, publicvehicles, privatevehicles)
    local self = { }

    self.name = name or "None"
    self.label = label or "None"
    self.ranks = ranks or { }
    self.points = points or { }
    self.options = options or { }
    self.blips = blips or { }
    self.publicvehicles = publicvehicles or { }
    self.privatevehicles = privatevehicles or { }

    ---comment
    ---@param newMarkers any
    ---@param cb any
    ---@return boolean or void
    self.updateMarkers = function (newMarkers, cb)
        self.points = newMarkers
        GlobalState[self.name.."-guille"] = JOB.Jobs[self.name]
        JOB.Print("INFO", ("Job updated '%s'"):format(self.name))
        GlobalState.JobsData = JOB.Jobs
        for k, v in pairs(JOB.Jobs[self.name].players) do 
            TriggerClientEvent("jobcreatorv2:client:initData", tonumber(v))
        end
        JOB.Execute("UPDATE guille_jobcreator SET points = ? WHERE name = ?", {
            json.encode(self.points),
            self.name
        })
        if cb then
            return cb(true)
        else
            return true
        end
    end

    self.updatePublicVehs = function (newVehs, cb)
        print(json.encode(newVehs))
        self.publicvehicles = newVehs
        GlobalState[self.name.."-guille"] = JOB.Jobs[self.name]
        JOB.Print("INFO", ("Job updated '%s'"):format(self.name))
        GlobalState.JobsData = JOB.Jobs
        for k, v in pairs(JOB.Jobs[self.name].players) do 
            TriggerClientEvent("jobcreatorv2:client:initData", tonumber(v))
        end
        JOB.Execute("UPDATE guille_jobcreator SET publicvehicles = ? WHERE name = ?", {
            json.encode(self.publicvehicles),
            self.name
        })
        if cb then
            return cb(true)
        else
            return true
        end
    end

    return self
    
end

