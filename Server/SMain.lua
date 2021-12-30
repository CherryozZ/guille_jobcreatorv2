JOB = setmetatable({ }, JOB)
JOB.__Index = JOB
JOB.Players = { }
JOB.Jobs = { }
JOB.Loaded = promise.new()