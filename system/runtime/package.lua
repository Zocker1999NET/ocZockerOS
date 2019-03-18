local package = {}
local packList = readFileTab("/apps/installed.cfg")
local packageLoading = {}

function package.setEntry(name,info)
	packList[name] = info
	info.running = {}
	info.running.enabled = false
end
local function packageEnableFor(info,forName)
	info.running.enabled = true
	if forName then
		info.running.neededFor[forName] = true
	end
end
function package.enableFor(name,forName)
	local info = packList[name]
	if not info then
		return false,"Package is not installed"
	end
	if packageLoading[name] then
		return true
	end
	if info.running.enabled then
		return packageEnabledFor(info,forName)
	end
	if info.enabledState < 0 then
		return false,"Package is disabled"
	end
	if not info.requirements then
		return packageEnabledFor(info,forName)
	end
	packageLoading[name] = true
	for _,v in pairs(info.requirements) do
		if not package.enable(v,name) then
			return false,"Requirements are missing"
		end
	end
	return packageEnabledFor(info,forName)
end
function package.isInstalled(name)
	return packList[name] ~= nil
end
function package.enable(name)
	return package.enableFor(name,nil)
end
function package.isEnabled(name)
	local info = packList[name]
	if not info then
		return false,"Package is not installed"
	end
	return info.running.enabled
end
function package.disable(name) do
	local info = packList[name]
	if not info then
		return false,"Package is not installed"
	end
	if packageLoading[name] then
		return true
	end
	packageLoading[name] = true
	for k,v in pairs(info.running.neededBy)
		package.disable(name)
	end
	if info.requirements then
		for k,v in pairs(info.requirements) do
			package.disableUnneded(v)
		end
	end
	for k,v in pairs(info.running.neededFor) do
		package.disable(k)
	end
	info.running.neededFor = {}
	info.running.enabled = false
	return true
end
function package.disableUnneeded(name)
	local info = packList[name]
	if not info then
		return false,"Package is not installed"
	end
	if info.running.disabled then
		return true
	end
	if info.enabledState > 0 then
		return false,"Package should be activated"
	end
	local needed = false
	for k,v in pairs(info.running.neededFor)
		if v then
			return false,"Package is needed"
		end
	end
	return package.disable(name)
end
function package.save()
	local sav = table.copy(packList)
	for name,info in pairs(sav)
		info.running = nil
	end
	writeFile("/apps/installed.cfg",sav)
end

function package.init()
	print("Load packages ...")
	for name,info in pairs(packList) do
		if info.enabledState > 0 then
			local ok,err = package.enable(name)
			print(" "..name..((not ok and " could not be enabled: "..err) or " enabled"))
		end
	end
end
function package.runtime()

end

return package