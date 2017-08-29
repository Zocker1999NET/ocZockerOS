local com = {}
local devices = {}

function com.isAvailable(pid,devName)

end
function com.invoke(pid,devName,...)

end
function com.proxy(devName)

end

function com.init()
	for k,v in components.list() do
		devices[v] = {["type"] = components.type(v)} -- components type
	end
end
function com.runtime()
	while true do
		local eD = {coroutine.yield()}
		if eD[1] == "component_added" then -- component added
			devices[eD[2]] = {["type"] = eD[3]}
		elseif eD[1] == "component_removed" then -- component removed

		end
	end
end

return com