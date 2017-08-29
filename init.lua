-- system extension
function table.copy(tab)
	local ret = {}
	for k,v in pairs(tab) do
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
-- both following functions read and write on system drive
local function readFile(filename)
	-- read file and create table
end
local function writeFile(filename,tab)
	-- write table to file
end
local function loadFile()

local driverControl = {}
local signalControl = {}

for dev,evs in pairs(readFile("/apps/drivers.cfg")) do
	for ev,pos in pairs(evs) do
		driverControl[ev] = {dev,pos}
	end
end
local defaultPackageRunning = {
	enabled = false
	neededFor = {}
}
for name,info in pairs(packList) do
	info.running = table.copy(defaultPackageRunning)
end

local apiSet = {}

local shortcuts = {["fs"]="filesystem"}

-- internal runtime api
local running = {}
local runtime = {}
local metaAccess = function(hid,rights)
	return (type(hid) == "table" and setmetatable({},{__index=function(t,k)
		return metaAccess(hid[k],rights)
	end})) or (type(hid) == "function" and function(...)
		return hid(table.copy(rights),...)
	end) or hid
end
function runtime.add(scriptFunction,dataTable,...)
	local env = setmetatable({},{__index=function(t,k)
		return metaAccess(apiSet[shortcuts[k] or k])
	end})
	local cor,err = coroutine.create(scriptFunction,env)
	if not cor then
		return nil,err
	end
	local ok,err = coroutine.resume(cor,...)
	if not ok then
		return nil,err
	end
	local pid = table.maxn(running) + 1
	running[pid] = dataTable or {}
	running[pid].thread = cor
	return pid
end
function runtime.status(pid)
	return coroutine.status(running[pid].thread)
end

-- initialization sequence

print("Load packages ...")
for name,info in pairs(packList) do
	if info.enabledState > 0 then
		local ok,err = package.enable(name)
		print(" "..name..((not ok and " could not be enabled: "..err) or " enabled"))
	end
end

while true do
	local eD = {computer.pullSignal()}
	
end