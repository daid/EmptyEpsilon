function file_exists(path)
  local f = io.open(path)
  if f == nil then return end
  f:close()
  return path
end

function parseIni(name)
	local array = {}

	if not file_exists(name) then return array end
	
	for line in io.lines(name) do

		-- Key-value pairs
		local key, value = line:match("^([%w_]+)%s-=%s-(.+)$")
		if tonumber(value) then value = tonumber(value) end
		if value == "true" then value = true end
		if value == "false" then value = false end
		if key and value ~= nil then
			array[key] = value
		end
	end

	return array
end