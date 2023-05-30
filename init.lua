-- system api extension
function assert(ok, ...)
	if not ok then
		error(...)
	end
end
function table.copy(tab)
	local ret = {}
	for k, v in pairs(tab) do
		if type(v) == "table" then
			ret[k] = table.copy(v)
		else
			ret[k] = v
		end
	end
	return ret
end
function string.split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	local i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

-- following functions read and write on system drive
local sysdrv = {}
function sysdrv.getFolders(path)

end
function sysdrv.getFiles(path)

end
function sysdrv.readFile(filename)
	-- read file
end
function sysdrv.readFileTab(filename)
	-- read file and create table
end
function sysdrv.writeFile(filename, txt)
	-- write text / table to file
end

local driverControl = {}
local signalControl = {}

for dev, evs in pairs(sysdrv.readFileTab("/apps/drivers.cfg")) do
	for ev, pos in pairs(evs) do
		driverControl[ev] = {dev, pos}
	end
end
local defaultPackageRunning = {
	enabled = false
	neededFor = {}
}
for name, info in pairs(packList) do
	info.running = table.copy(defaultPackageRunning)
end

local apiSet = {}

local shortcuts = {["fs"]="filesystem"}

-- internal runtime api

local runtime = {}
local running = {} -- { thread ,  }
_G.runtime = runtime

local metaAccess = function(hid, data)
	return (type(hid) == "table" and setmetatable({}, {__index=function(t, k)
		return metaAccess(hid[k], data)
	end})) or (type(hid) == "function" and function(...)
		return (data and hid(table.copy(data), ...)) or hid(...)
	end) or hid
end
function runtime.add(scriptFunction, dataTable, ...)
	local env = setmetatable({}, {__index=function(t, k)
		return metaAccess(apiSet[shortcuts[k] or k])
	end})
	local cor, err = coroutine.create(scriptFunction, env)
	if not cor then
		return false, err
	end
	local pid = table.maxn(running) + 1
	data = data or {}
	data.runtime = data.runtime or {}
	local r = data.runtime
	for k, v in pairs({
		isDaemon = false,
		byModule = "",
		sourceType = "unknown" -- unknown , module , package , filesystem , sideLoaded | filesystem means it was a file what is not registered as part of a package
		sourceInfo = "" -- nil , moduleName , packageName , path , executingPid
	}) do
		r[k] = r[k] or v
	end
	running[pid] = data
	running[pid].thread = cor
	local ok, err = coroutine.resume(cor, ...)
	if not ok then
		return false, err
	end
	return pid
end
function runtime.status(pid)
	return coroutine.status(running[pid].thread)
end

-- module initialization

local modules = {runtime = runtime, sysdrv = sysdrv}
local modEnv = setmetatable({}, {__index = function(t, k)
	return metaAccess(modules[k] or _G[k])
end, __newindex = function(t, k, v) end})

print("Preinstalled modules")
for k, v in pairs(modules) do
	print("  "..k)
end
print("Load external modules")
for k, v in pairs(getFiles("/system/runtime")) do
	if v:sub(-4) == ".lua" then
		local name = tostring(v:sub(1, -5))
		assert(_G[name] or modules[name], "ZockerCore: Name of Module \""..name.."\" is not valid", 0)
		print("  "..name)
		local raw = sysdrv.readFile("/system/runtime/"..name..".lua")
		assert(type(raw) ~= "string", "ZockerCore: Module "..name.." cannot be loaded", 0)
		local bin, err = load(raw, "modules."..name, "t", modEnv)
		assert(bin, err, 0)
		modules[name] = bin()
	end
end
print("Initialize modules")
for k, v in pairs(modules) do
	if type(v.init) == "function" then
		print("  "..k)
		v.init()
	end
end
print("Add modules to runtime")
for k, v in pairs(modules) do
	if type(v.runtime) == "function" then
		local name, desc = k, "/system/runtime/"..k..".lua"
		if type(v.infos) == "function" then
			name, desc = v.infos()
		end
		print("  "..name)
		local ok, err = runtime.add(v, {
			runtime = {
				name = name,
				description = desc,
				isDaemon = true,
				byModule = k,
			},
			access = {
				level = 4
			},
		})
		assert(ok, err, 0)
	end
end

-- run sequence

print("Pass control to modules")
computer.pushSignal("boot_completed")
while true do
	local eD = {computer.pullSignal()}
	
end