local acc = {}
-- level : 0: guests (controlled by other app) | 1: user | 2: admin | 3:system
-- options : 4: with argument | 8: single asking
local perms = { -- "permName" , "permName#argument"
	changePermissions = 3+4+8,

	useMainComponent = 1+4,
	useSystemComponent = 2+4,
	bindComponent = 2+4,
	releaseComponent = 3+4+8,
	bindComponentType = 3+4,
	releaseComponentType = 3+4+8,

	changeFilesystem = 3+4,
	releaseDefaultFilesystem = 2+4+8,
	releaseMainFilesystem = 3+4+8,

	createWindows = 1,
	changeToWindow = 2,

	useNetwork = 0,
	bindDefaultPort = 2+4,
	bindMainPort = 3+4,
	releasePort = 3+4+8,

	changePackages = 3+4+8,
}
local appPerms = {} -- "packageName" -> "permName" , "packageName#permName#argument"
local cfg = readFileTab("/apps/access.cfg")

local function splitPerm(name)
	if type(name) ~= "string" or name:len() < 1 then
		return false
	end
	local s = string.split(name,"#")
	if not s[1] then return false end
	if perms[s[1]] then
		return true,nil,s[1],s[2]
	end
	if s[2] and appPerms[s[1]] and appPerms[s[1]][s[2]] then
		return true,s[1],s[2],s[3]
	end
	return false
end

local function getLevel(perm)
	local b,p,r,a = splitPerm(perm)
	if not b then
		return false,"Permission does not exist"
	end
	if p then
		return appPerms[p][r] % 4
	else
		return perms[perm] % 4
	end
end
local function hasArgument(perm)
	local b,p,r,a = splitPerm(perm)
	if not b then
		return false,"Permission does not exist"
	end
	if p then
		return appPerms[p][r] % 4
	else
		return perms[perm] % 4
	end
	return bit32.extract(perms[p],2) == 1
end
local function isSingleAsk(perm)
	if not perms[perm] then
		return false,"Permission does not exist"
	end
	return bit32.extract(perms[perm],3) == 1
end

function acc.giveAccessTo(pack,perm)
	if not perms[perm] then
		return false,"Permission does not exist"
	end
	if not package.isEnabled(pack) then
		return false,"Package is not enabled"
	end
	if not cfg[pack] then
		cfg[pack] = {}
	end
	cfg[pack][perm] = true
	return true
end
function acc.askAccessTo(pack,perm)
	if not perms[perm] then
		return false,"Permission does not exist"
	end
	if not package.isEnabled(pack) then
		return false,"Package is not enabled"
	end
	if not cfg[pack] then
		cfg[pack] = {}
	end

end
function acc.hasAccessTo(pack,perm)
	if not perms[perm] then
		return false,"Permission does not exist"
	end
	if not package.isEnabled(pack) then
		return false,"Package is not enabled"
	end
	if not cfg[pack] then
		cfg[pack] = {}
	end
	local ok = cfg[pack][perm] ~= nil
	if ok and 
end
function acc.canHaveAccessTo(pack,perm)
	if not perms[perm] then
		return false,"Permission does not exist"
	end
	if not package.isEnabled(pack) then
		return false,"Package is not enabled"
	end
	if not cfg[pack] then
		cfg[pack] = {}
	end
end
function acc.removeAccessTo(pack,perm)
	if not perms[perm] then
		return false,"Permission does not exist"
	end
	if not package.isEnabled(pack) then
		return false,"Package is not enabled"
	end
	if not cfg[pack] then
		cfg[pack] = {}
	end
	cfg[pack][perm] = false
	return true
end
function acc.save()
	writeFile("/apps/access.cfg",cfg)
end

function acc.infos()
	return "",
end
function acc.init()
	for
end
function acc.runtime() -- also second init
	local l = {}
	for k,v in pairs(cfg) do
		if not package.isInstalled(k) then
			l[k] = true
		end
	end
	for k,v in pairs(l) do
		cfg[k] = nil
	end
	acc.save()

end

return acc