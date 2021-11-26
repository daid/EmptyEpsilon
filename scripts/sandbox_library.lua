-- library code for the sandbox
-- it is intended to be able to be included in an empty script and function correctly
-- this is probably not yet the case especially with the update system 

--------------------
-- error handling --
--------------------
-- in several places it would be nice to get more errors reported
-- this is to assist with that
-- returns a function which wraps the fun function in error handling logic
-- the error handling logic for the sandbox is a popup and printing to the console
-- this is useful for callbacks and gm buttons (as both of those don't in the current
-- version display the red text with a line number that init code does
-- example addGMFunction("button",wrapWithErrorHandling(function () print("example") end))
function wrapWithErrorHandling(fun)
	assert(type(fun)=="function" or fun==nil,"expected function or nil for wrapWithErrorHandling we instead got a " .. type(fun) .. " with a value of " .. tostring(fun))
	if fun == nil then
		return nil
	end
	return function(...)
		local status,error=pcall(fun, ...)
		if not status then
			print("script error : - ")
			print(error)
			addGMMessage("script error - \n"..error)
		else
			return error
		end
	end
end
-- calls the function fun with the remaining arguments while using the common
-- error handling logic (see wrapWithErrorHandling)
function callWithErrorHandling(fun,...)
	assert(type(fun)=="function" or fun==nil)
	return wrapWithErrorHandling(fun)(...)
end
-- currently EE doesn't make it easy to see if there are errors in GMbuttons
-- this saves the old addGMFunction, and makes it so all calls to addGMFunction
-- are wrapped with the common error handling logic
addGMFunctionReal=addGMFunction
function addGMFunction(msg, fun)
	assert(type(msg)=="string")
	assert(type(fun)=="function" or fun==nil)
	return addGMFunctionReal(msg,wrapWithErrorHandling(fun))
end

onNewPlayerShipReal=onNewPlayerShip
function onNewPlayerShip(fun)
	assert(type(fun)=="function" or fun==nil)
	return onNewPlayerShipReal(wrapWithErrorHandling(fun))
end

onGMClickReal=onGMClick
function onGMClick(fun)
	assert(type(fun)=="function" or fun==nil)
	return onGMClickReal(wrapWithErrorHandling(fun))
end
----------------------
-- debug assistance --
----------------------
function getNumberOfObjectsString(all_objects)
	-- get a multi-line string for the number of objects at the current time
	-- intended to be used via addGMMessage or print, but there may be other uses
	-- it may be worth considering adding a function which would return an array rather than a string
	-- all_objects is passed in (as an optional argument) mostly to assist testing
	assert(all_objects==nil or type(all_objects)=="table")
	if all_objects == nil then
		all_objects=getAllObjects()
	end
	local object_counts={}
	--first up we accumulate the number of each type of object
	for i=1,#all_objects do
		local object_type=all_objects[i].typeName
		local current_count=object_counts[object_type]
		if current_count==nil then
			current_count=0
		end
		object_counts[object_type]=current_count+1
	end
	-- we want the ordering to be stable so we build a key list
	local sorted_counts={}
	for type in pairs(object_counts) do
		table.insert(sorted_counts, type)
	end
	table.sort(sorted_counts)
	--lastly we build the output
	local output=""
	for _,object_type in ipairs(sorted_counts) do
		output=output..string.format("%s: %i\n",object_type,object_counts[object_type])
	end
	return output..string.format("\nTotal: %i",#all_objects)
end
function getNumberOfObjectsStringTest()
	-- ideally we would have something to ensure the tables we pass in are close to getAllObjects tables
	assert(getNumberOfObjectsString({})=="\nTotal: 0")
	assert(getNumberOfObjectsString({{typeName ="test"}})=="test: 1\n\nTotal: 1")
	assert(getNumberOfObjectsString({{typeName ="test"},{typeName ="test"}})=="test: 2\n\nTotal: 2")
	assert(getNumberOfObjectsString({{typeName ="testA"},{typeName ="testB"}})=="testA: 1\ntestB: 1\n\nTotal: 2")
	assert(getNumberOfObjectsString({{typeName ="testA"},{typeName ="testB"},{typeName ="testB"}})=="testA: 1\ntestB: 2\n\nTotal: 3")
end
------------------------------
--	Math related functions  --
------------------------------
function math.lerp (a,b,t)
	-- intended to mirror C++ lerp
	-- linear interpolation
	assert(type(a)=="number")
	assert(type(b)=="number")
	assert(type(t)=="number")
	return a + t * (b - a)
end
function math.CosineInterpolate(y1,y2,mu)
	-- see http://paulbourke.net/miscellaneous/interpolation/
	assert(type(y1)=="number")
	assert(type(y2)=="number")
	assert(type(mu)=="number")
	local mu2 = (1-math.cos(mu*math.pi))/2
	assert(type(mu2)=="number")
	return (y1*(1-mu2)+y2*mu2)
end
function math._CosineInterpolateTableInner(tbl,elmt,t)
	assert(type(tbl)=="table")
	assert(type(t)=="number")
	assert(type(elmt)=="number")
	assert(elmt<#tbl)
	local x_delta=tbl[elmt+1].x-tbl[elmt].x
	if x_delta == 0 then
		return tbl[elmt].y
	end
	local t_scaled=(t-tbl[elmt].x)*(1/x_delta)
	return math.CosineInterpolate(tbl[elmt].y,tbl[elmt+1].y,t_scaled)
end
function math.CosineInterpolateTable(tbl,t)
	assert(type(tbl)=="table")
	assert(type(t)=="number")
	assert(#tbl>1)
	for i=1,#tbl-1 do
		if tbl[i+1].x>t then
			return math._CosineInterpolateTableInner(tbl,i,t)
		end
	end
	return math._CosineInterpolateTableInner(tbl,#tbl-1,t)
end
function math.CubicInterpolate(y0,y1,y2,y3,mu)
	-- see http://paulbourke.net/miscellaneous/interpolation/
	assert(type(y0)=="number")
	assert(type(y1)=="number")
	assert(type(y2)=="number")
	assert(type(y3)=="number")
	assert(type(mu)=="number")
	local mu2 = mu*mu;
	local a0 = y3 - y2 - y0 + y1;
	local a1 = y0 - y1 - a0;
	local a2 = y2 - y0;
	local a3 = y1;
	return(a0*mu*mu2+a1*mu2+a2*mu+a3);
end
function math.CubicInterpolate2DTable(tbl,t)
	-- this takes an array with 2 elements each (x and y)
	-- and returns the Cubic interpolation for the (floating point) element t
	-- it would be tricky and not very useful allowing a table with 3 elements and t==1
	-- likewise caluclation at exactly 1 smaller than the length of the array is slightly tricky for the code
	-- fixing these wouldnt be hard, just branchy and needing a lot of looking at to confirm it all works as expected
	-- currently they will just fail asserts, which in turn allows it to be fixed at a later date without breaking old code
	assert(type(tbl)=="table")
	assert(type(t)=="number")
	assert(t>=1,"CubicInterpolate2DTable t must be >= 1")
	assert(math.ceil(t)+1<=#tbl,"CubicInterpolate2DTable tbl must have one one more element than the size of t")
	local i = math.floor(t)
	local mu = t - i
	local x = math.CubicInterpolate(tbl[i].x,tbl[i+1].x,tbl[i+2].x,tbl[i+3].x,mu)
	local y = math.CubicInterpolate(tbl[i].y,tbl[i+1].y,tbl[i+2].y,tbl[i+3].y,mu)
	return x,y
end
function math.lerpTest()
	assert(math.lerp(1,2,0)==1)
	assert(math.lerp(1,2,1)==2)
	assert(math.lerp(2,1,0)==2)
	assert(math.lerp(2,1,1)==1)
	assert(math.lerp(2,1,.5)==1.5)
	-- extrapolation
	assert(math.lerp(1,2,-1)==0)
	assert(math.lerp(1,2,2)==3)
end
function math.clamp(value,lo,hi)
	-- intended to mirror C++ clamp
	-- clamps value within the range of low and high
	assert(type(value)=="number")
	assert(type(lo)=="number")
	assert(type(hi)=="number")
	if value < lo then
		value = lo
	end
	if value > hi then
		return hi
	end
	return value
end
function math.clampTest()
	assert(math.clamp(0,1,2)==1)
	assert(math.clamp(3,1,2)==2)
	assert(math.clamp(1.5,1,2)==1.5)

	assert(math.clamp(0,2,3)==2)
	assert(math.clamp(4,2,3)==3)
	assert(math.clamp(2.5,2,3)==2.5)
end
function math.extraTests()
	math.lerpTest()
	math.clampTest()
end
------------------
-- web gm tools --
------------------
-- currently (2021/09/23) getScriptStorage() bleeds through
-- scenario restarts, when this is fixed / changed this line can be removed
-- important note - this ***has*** to run before init() is called or you
-- will get odd web tool errors
getScriptStorage()._cuf_gm = nil
-------------------------------------
--	Web GM tool related functions  --
-------------------------------------
function webUploadStart(parts)
-- there are probably a few extra round trips than needed for the web tool
-- end could be made implict when all of the segments have been uploaded
-- currently it relies on the web tool to call it at the right time
-- start could also be merged with the first segment
-- this may improve the web tools responsiveness
-- there are other places to optimise first though
	local slot_id = getScriptStorage()._cuf_gm.uploads.slot_id
	getScriptStorage()._cuf_gm.uploads.slots[slot_id] = {total_parts = parts, parts = {}}
	getScriptStorage()._cuf_gm.uploads.slot_id = slot_id + 1
	return slot_id
end
function webUploadSegment(slot,part,upload_part)
	assert(type(slot)=="number")
	assert(type(part)=="number")
	assert(type(upload_part)=="string")
	assert(getScriptStorage()._cuf_gm.uploads.slots[slot] ~= nil)
	assert(getScriptStorage()._cuf_gm.uploads.slots[slot].parts[part] == nil)
	getScriptStorage()._cuf_gm.uploads.slots[slot].parts[part] = upload_part
end
function webUploadEndAndRunAndFree(slot)
-- this probably wants splitting into multiple parts
-- but its currently used as one command
-- pay very careful attention to what happens with multiple web tools if edited
	assert(getScriptStorage()._cuf_gm.uploads.slots[slot] ~= nil)
	local func_str = ""
	for i = 1, getScriptStorage()._cuf_gm.uploads.slots[slot].total_parts do
		assert(type(getScriptStorage()._cuf_gm.uploads.slots[slot].parts[i])=="string")
		func_str = func_str .. getScriptStorage()._cuf_gm.uploads.slots[slot].parts[i]
	end
	local fn, err = load(func_str)
	getScriptStorage()._cuf_gm.uploads.slots[slot] = nil
	if fn then
		return fn()
	else
		print(err)
		return {error = err}
	end
end
function isValidVariableDescriptionType(type_str)
	assert(type(type_str) == "string")
	if type_str == "string" or type_str == "number" or type_str == "position" or type_str == "npc_ship_template" or type_str == "function" or type_str == "meta" then
		return true
	else
		return false
	end
end
function isWebTableFunction(tbl)
	if type(tbl)=="table" and tbl.call ~= nil and type(tbl.call) == "string" then
		return true
	else
		return false
	end
end
function checkVariableDescriptions(args_table)
	for _,arg_description in ipairs(args_table) do
		local arg_type = arg_description[2]
		for arg_name,arg_value in pairs(arg_description) do
			if arg_name == 1 then -- name
				assert(type(arg_value)=="string")
				-- _this is the name for the table describing the current function, we cant also have an argument of _this
				assert(arg_value ~= "_this")
				-- call as an argument name would cause an alarming degree of chaos
				assert(arg_value ~= "call")
			elseif arg_name == 2 then -- type
				assert(isValidVariableDescriptionType(arg_value))
			elseif arg_name == 3 then -- default
				if arg_value ~= nil then
					-- this is to check the default argument if present is of the correct type
					-- sadly it is much harder to check functions as they will be checked as defined
					-- as such we will just assume they are OK for now
					if not isWebTableFunction(arg_value) then
						webConvertArgument(arg_value,arg_description)
					end
				end
			elseif arg_name == 4 then -- optional array
				assert(arg_value == "array")
			elseif arg_name == "min" then
				assert(arg_type == "number")
			elseif arg_name == "max" then
				assert(arg_type == "number")
			elseif arg_name == "caller_provides" then
				assert(arg_type == "function")
			else
				assert(false,"arg_description has a key that describeFunction doesnt about")
			end
		end
	end
end
function describeFunction(name,func_description,args_table)
	-- the name is better as describeAndExportFunctionForWeb, but there are going to be an absurd number
	-- of these so brevity is important, I have no objection if a find and replace is desired
	--
	-- all of the describeFunction calls in the sandbox are run before init()
	-- this allows describeFunction to be next to the function definition
	-- note the web tool may call describeFunction after init has been called
	-- as such dont assume in init is called that the exported functions will never change
	--
	-- description format is
	-- 1) name of the function as a string (the function call itself is pulled out of the global table)
	--                         as such anonymous functions are presently not supported
	-- 2) function description, which is a table or a string or nil
	--              if it is a string then it is assumed as being func_description[1]
	-- 2.1) func_description[1] is a description used for the web tool
	-- 2.2) func_description[2+] is a list of tags to be used for sorting on the web UI
	-- 3) args_table a table of tables is an optional table describing each argument given to the function
	-- 3.0) each inner table is defined as follows
	-- 3.1) [1] name of the argument
	-- 3.2) [2] type of the argument - see below for types
	-- 3.3) [3] the default value for the argument, note this is not checked for type/value and is current web tool only
	-- 3.4) [4] may be the string "array" in which case this is a table from [1] to #table, this is badly tested, but required for the web tool, if this is going to be used elsewhere better testing is needed
	-- 3.4) the remainder of the table is optional tags based on type
	-- for numbers -
	-- min - minimum value expected
	-- max - maximum value expected
	-- for function
	-- caller_provides - the values this function provides for the function call (this will stop them being shown on the web tool)
	--
	-- types
	-- string - a lua string - example = "the answer"
	-- number - a lua number - example = 42
	-- position - a table of 2 numbers - {x,y} - example = {x = 6, y = 9}
	-- npc_ship_template - the template name for a npc ship, this can be set to valid softtemplates or stock templates - example "Adder MK4"
	-- function - the caller recives a function to be called, the caller provides a table which will be converted by convertWebCallTableToFunction - example = {call = getCpushipSoftTemplates} renaming the caller_provides list is possible with a table called _caller_provides_rename - look at webConvertScalar for details
	local script_storage = getScriptStorage()
	if script_storage._cuf_gm == nil then
		setupWebGMTool()
	end
	assert(type(name) == "string")
	assert(type(func_description) == "table" or type(func_description) == "string" or func_description == nil)
	if type(func_description) ~= "table" then
		func_description = {func_description}
	end
	assert(type(args_table)=="table" or args_table == nil)
	args_table = args_table or {}
	local fn = _ENV[name]
	assert(type(fn)=="function",name)
	checkVariableDescriptions(args_table)
	args_table._this = func_description
	getScriptStorage()._cuf_gm.functions[name] = {fn = fn, args = args_table}
end
function webConvertScalar(value, argSettings)
	-- convert a single value from a web call
	-- only copes with converting functions from the web calling table format
	local convert_to = argSettings[2]
	local is_web_function = isWebTableFunction(value)
	if is_web_function and convert_to ~= "function" then
		value = convertWebCallTableToFunction(value)
	end
	if convert_to == "function" then
		local caller_provides = {}
		if argSettings.caller_provides then
			for _,var in pairs(argSettings.caller_provides) do
				if value._caller_provides_rename ~= nil then
					if value._caller_provides_rename[var] ~= nil then
						var = value._caller_provides_rename[var]
					end
				end
				table.insert(caller_provides,var)
			end
		end
		value = convertWebCallTableToFunction(value,caller_provides)
		assert(type(value) == "function")
	elseif convert_to == "string" then
		assert(type(value) == "string")
	elseif convert_to == "number" then
		-- it is worth considering if min / max should be checked here or not
		assert(type(value) == "number")
	elseif convert_to == "position" then
		assert(type(value) == "table")
		assert(type(value.x) == "number")
		assert(type(value.y) == "number")
	elseif convert_to == "npc_ship_template" then
		-- checking this is a valid template name would be nice
		assert(type(value) == "string")
	elseif convert_to == "meta" then
		return value
	else
		assert(false,"unknown type " .. "\"" .. convert_to .. "\"")
	end
	return value
end
function webConvertArgument(value, argSettings)
	local is_array = (argSettings[4] == "array")
	if is_array then
		for idx,scalar in ipairs(value) do
			value[idx] = webConvertScalar(scalar, argSettings)
		end
	else
		value = webConvertScalar(value, argSettings)
	end
	return value
end
function convertWebCallTableToFunction(args,caller_provides)
	local caller_provides = caller_provides or {}
	assert(type(caller_provides)=="table")
	assert(isWebTableFunction(args))
	local requested_function = getScriptStorage()._cuf_gm.functions[args.call]
	assert(requested_function ~= nil, "attempted to call an undefined function " .. args.call)
	assert(type(requested_function.fn) == "function")
	assert(type(requested_function.args) == "table")
	local need_to_wrap = false
	for arg_num,arg in ipairs(requested_function.args) do
		if arg[1] ~= caller_provides[arg_num] then
			need_to_wrap = true
		end
		if arg[2] == "function" then
			need_to_wrap = true
		end
	end
	if not need_to_wrap then
		return requested_function.fn
	end
	return function (...)
		local callee_args = {}
		local arg_num = 1
		for _,arg in ipairs(requested_function.args) do
			local arg_name = arg[1]
			local arg_type = arg[2]
			local arg_default = arg[3]
			local in_caller_provides = nil
			for arg_num,suppressed in ipairs(caller_provides) do
				if suppressed == arg_name then
					in_caller_provides = arg_num
				end
			end
			local value
			if in_caller_provides then
				assert(select("#",...)<= in_caller_provides)
				value = select(in_caller_provides,...)
			elseif args[arg_name] then
				value = args[arg_name]
			else
				value = arg_default
				if arg_type == "meta" then
					if arg_name == "_clientID" then
						value = getScriptStorage()._cuf_gm.currentWebID
					else
						assert(false)
					end
				end
				assert(value ~= nil,"argument not in list " .. arg_name .. " for function " .. args.call .. " (and there is no default)")
			end
			callee_args[arg_num] = webConvertArgument(value,arg)
			arg_num = arg_num +1
		end
		-- reminder it is possible for entires in requested_function can be nil
		return requested_function.fn(table.unpack(callee_args,1,#requested_function.args))
	end
end
function webCall(clientID,args)
	-- this is the main entry point for the web gm tool
	-- get all serverMessages and call a function
	-- we need to do both as one call due to synchronization issues
	-- the web tool needs to know which serverMessages are from before
	-- the function call and which are after.
	-- As an example consider wanting infomation on if clicks are before
	-- or after the onGMClick function has been changed
	-- currently serverMessages created during the function call and
	-- before are merged, this is presently fine but may not be in future.
	if getScriptStorage()._cuf_gm.serverMessages == nil or getScriptStorage()._cuf_gm.serverMessages[clientID] == nil then
		return {serverMessages = {msg = "invalid clientID"}}
	end
	local ret = {}
	if args ~= nil then
		getScriptStorage()._cuf_gm.currentWebID = clientID
		ret.ret = callWithErrorHandling(convertWebCallTableToFunction(args))
	end
	ret.serverMessages = getScriptStorage()._cuf_gm.serverMessages[clientID]
	getScriptStorage()._cuf_gm.serverMessages[clientID] = {}
	return ret
end
function newWebClient()
	-- this is fairly expensive in CPU terms
	-- at the time of testing on my desktop it is about 80ms of CPU time
	-- given the expected amount of times running this is probably acceptable
	-- this could be cached in 2 places to remove this if it becomes an issue
	-- the web tool could store inside of webStorage and only request on the
	-- event of a version missmatch for EE or sandbox
	-- caching is possible within the sandbox, but I have not tested if the
	-- expensive part is walking over the fairly large amount of data to be copied
	-- in which case it wont help
	getScriptStorage()._cuf_gm.webID = getScriptStorage()._cuf_gm.webID + 1
	local webID = getScriptStorage()._cuf_gm.webID
	getScriptStorage()._cuf_gm.serverMessages[webID] = {}
	return {
		id = webID,
		cpushipSoftTemplates = getCpushipSoftTemplates(),
		modelData = getModelData(),
		extraTemplateData = getExtraTemplateData(),
		functionDescriptions = getWebFunctionDescriptions()
	}
end
function addWebMessageForClient(clientID,msg)
	assert(type(getScriptStorage()._cuf_gm.serverMessages[clientID]) == "table")
	table.insert(getScriptStorage()._cuf_gm.serverMessages[clientID],msg)
end
function getCpushipSoftTemplates()
	local softTemplates = {}
	for ship_template_name,template in pairs(ship_template) do
		local this_ship = {}
		-- shallow copy, this should be moved to a library
		for key,value in pairs(template) do
			this_ship[key] = value
		end

		this_ship.name = ship_template_name
		-- the gm button name != the typeName (sometimes)
		-- we need to have both later in the web tool so we
		-- to create a real ship to find the type name
		local ship = this_ship.create("Human Navy",this_ship.name)
		this_ship["type_name"] = ship:getTypeName()
		ship:destroy()
		this_ship.create = nil -- remove functions from the table
		table.insert(softTemplates,this_ship)
	end
	return softTemplates
end
function getModelData()
	-- the original use for this is beam positions
	-- this should probably be available inside of lua without doing this
	-- if beam position is exported consider reviewing if this is still needed
	-- this may be expensive in CPU terms - see newWebClient
	local models = {}
	local ModelDataOrig = ModelData

	_G.ModelData = function ()
		local data = {
			BeamPosition = {}
		}
		local ret = {
			setName = function (self,name)
				data.Name=name
				return self
			end,
			setMesh = function (self,mesh)
				data.Mesh=mesh
				return self
			end,
			setTexture = function (self,texture)
				data.Texture=texture
				return self
			end,
			setSpecular = function (self,specular)
				data.Specular=specular
				return self
			end,
			setIllumination = function (self,illumination)
				data.Illumination = illumination
				return self
			end,
			setRenderOffset = function (self,x,y,z)
				data.RenderOffset = {x=x,y=y,z=z}
				return self
			end,
			setScale = function (self,scale)
				data.Scale = scale
				return self
			end,
			setRadius = function (self,radius)
				data.Radius = radius
				return self
			end,
			setCollisionBox = function (self,x,y)
				data.CollisionBox = {x=x, y=y, z=z}
				return self
			end,
			addBeamPosition = function (self,x,y,z)
				if data.BeamPosition == nil then
					data.BeamPosition = {}
				end
				table.insert(data.BeamPosition,{x=x, y=y, z=z})
				return self
			end,
			addEngineEmitter = function (self,x,y,z)
				if data.EngineEmitter == nil then
					data.EngineEmitter = {}
				end
				table.insert(data.EngineEmitter,{x=x, y=y, z=z})
				return self
			end,
			addTubePosition = function (self,x,y,z)
				if data.TubePosition == nil then
					data.TubePosition = {}
				end
				table.insert(data.TubePosition,{x=x, y=y, z=z})
				return self
			end
		}
		table.insert(models,data)
		return ret
	end
	require("model_data.lua")

	_G.ModelData = ModelDataOrig
	return models
end
function getExtraTemplateData()
	-- this was originally written to help the web tool
	-- it only exports the members without getters
	-- with some EE engine fixes it may be possible to remove
	-- this may be expensive in CPU terms - see newWebClient
	local templates = {}
	local ShipTemplateOrig = ShipTemplate
	_G.ShipTemplate = function ()
		local data = {
			Type = "ship"
		}
		local ret = {
			setName = function (self,name)
				data.Name=name
				return self
			end,
			-- we need to look up the model to find the beam origin points
			setModel = function (self,model)
				data.Model = model
				return self
			end,
			 -- SpaceShip::getRadarTrace() currently doesn't exist
			setRadarTrace = function (self,radarTrace)
				data.RadarTrace = radarTrace
				return self
			end,
			-- the template files chain templates together, we need to mimic this or have odd errors
			copy = function (self,name)
				return ShipTemplate()
					:setModel(data.Model)
					:setName(name)
					:setRadarTrace(data.RadarTrace)
					:setType(data.Type)
			end,
			-- we need to be able to figure out if we are looking at a CpuShip, PlayerSpaceship or SpaceStation
			-- this may? not be needed if the other functions where exported
			setType = function (self, type)
				data.Type = type
				return self
			end,
		}
		-- any unknown entries will just return a function returning self
		-- this makes us mostly not care if new things are exported from EE
		setmetatable(ret,{__index =
			function ()
				return function (self)
					return self
				end
			end})
		table.insert(templates,data)
		return ret
	end
	require("shipTemplates.lua")

	_G.ShipTemplate = ShipTemplateOrig
	return templates
end
function getWebFunctionDescriptions()
	local ret = {}
	-- strip out the function itself
	for name,fn in pairs(getScriptStorage()._cuf_gm.functions) do
		local copy = {}
		for key,value in pairs(fn.args) do
			copy[key] = value
		end
		ret[name] = copy
	end
	return ret
end
function setupWebGMTool()
	-- currently (2021/09/02) getScriptStorage() bleeds through
	-- scenario restarts, this is a problem, I am also willfully
	-- ignoring this problem at the moment, as at some point the engine should be fixed
	-- so this doesnt happen, be aware that to properly test somethings
	-- you may need to close and reopen empty epsilon and that
	-- a script restart may not be enough
	getScriptStorage()._cuf_gm = {
		-- _ENV is kind of alarming to export, but it allows some very powerful web tools
		_ENV = _ENV,
		-- used for uploading data larger than EE's maximum post size
		-- each upload slot has the number of segements expected for that upload and the current slot id
		-- while not well tested it should allow multiple web tools to work at once without jumbling each others uploads
		-- better tested is that all the segements can be uploaded at once saving round trip times
		-- there are currently some issues with round trips due to bugs in EE regarding escape charaters
		uploads = {
			slots = {},
			slot_id = 0,
		},
		-- we dont start at 0 as that makes it easy for clashes web clients that have
		-- been running since the last sandbox restart
		-- in an ideal world we would synchronise with web clients between runs
		-- but that is somewhere between hard and impossible
		-- if you see a real world clash and have to debug it you have my sympathies
		-- and a suggestion that you go and gamble at borlan as you have spent your bad luck for the day
		webID = irandom(0,1000000),
		serverMessages = {},
		-- all the functions exported to the web tool
		functions = {
			-- see describeFunction for details
		},
		webUploadStart = webUploadStart,
		webUploadEndAndRunAndFree = webUploadEndAndRunAndFree,
		webUploadSegment = webUploadSegment,
		webCall = webCall,
		newWebClient = newWebClient
	}
end
-- stock EE / lua functions
describeFunction("irandom",nil,
	{	{"min","number"},
		{"max","number"}	})

function addGMClickedMessage(_clientID,location)
	addWebMessageForClient(_clientID,{msg = "gmClicked", x = location.x, y = location.y})
end
describeFunction("addGMClickedMessage",nil,{
	{"_clientID","meta"},
	{"location", "position"}})
function gm_click_wrapper(onclick)
	onGMClick(function (x,y)
		onclick({x = x, y = y})
	end)
end
describeFunction("gm_click_wrapper",nil,
	{{"onclick", "function", {call = "null_function"},caller_provides = {"location"}}})
------------------
-- common utils --
------------------
function isInGMSelection(obj)
	for _,current in ipairs(getGMSelection()) do
		if current == obj then
			return true
		end
	end
	return false
end
function destroyEEtable(tbl)
	-- itterate through a table destroying all elements
	-- returns an empty table to try to be similar with removeInvalidFromEETable
	assert(type(tbl)=="table")
	for i=#tbl,1,-1 do
		if tbl[i]:isValid() then
			tbl[i]:destroy()
		end
	end
	return {}
end
function removeInvalidFromEETable(tbl)
	-- return a table with all invalid elements removed
	assert(type(tbl)=="table")
	for i=#tbl,1,-1 do
		if not tbl[i]:isValid() then
			table.remove(tbl,i)
		end
	end
	return tbl
end
------------------------------------------------------
--	Individual beam weapon parameter set functions  --
------------------------------------------------------
-- I (starry) will at some point soon add a similar function to these in a pull request to EE core
-- they will be added to each spaceship
-- if it is accepted, then on the version after that which is release we can use that
-- if not then we should probably find a nice location for these functions to live long term
function compatSetBeamWeaponArc(obj,index,val)
	obj:setBeamWeapon(
		index,
		val,
		obj:getBeamWeaponDirection(index),
		obj:getBeamWeaponRange(index),
		obj:getBeamWeaponCycleTime(index),
		obj:getBeamWeaponDamage(index)
	)
end
function compatSetBeamWeaponDirection(obj,index,val)
	obj:setBeamWeapon(
		index,
		obj:getBeamWeaponArc(index),
		val,
		obj:getBeamWeaponRange(index),
		obj:getBeamWeaponCycleTime(index),
		obj:getBeamWeaponDamage(index)
	)
end
function compatSetBeamWeaponRange(obj,index,val)
	obj:setBeamWeapon(
		index,
		obj:getBeamWeaponArc(index),
		obj:getBeamWeaponDirection(index),
		val,
		obj:getBeamWeaponCycleTime(index),
		obj:getBeamWeaponDamage(index)
	)
end
function compatSetBeamWeaponCycleTime(obj,index,val)
	obj:setBeamWeapon(
		index,
		obj:getBeamWeaponArc(index),
		obj:getBeamWeaponDirection(index),
		obj:getBeamWeaponRange(index),
		val,
		obj:getBeamWeaponDamage(index)
	)
end
function compatSetBeamWeaponDamage(obj,index,val)
	obj:setBeamWeapon(
		index,
		obj:getBeamWeaponArc(index),
		obj:getBeamWeaponDirection(index),
		obj:getBeamWeaponRange(index),
		obj:getBeamWeaponCycleTime(index),
		val
	)
end
-----------------
-- fleetCustom --
-----------------
-- fleetCustom is a bunch of wrappers to make fleets of
-- player ships have the same custom buttons / info / messages
-- we always use the wrapped.*Custom.* functions
-- I am unaware of any reason the non wrapped functions should be used
-- if there is a reason this should be looked at again
fleetCustom = {}
fleetCustom.__index = fleetCustom
function fleetCustom:create()
	local ret = {
		-- a table with name (of the custom info) mapping to a table where
		-- the first element is the name of the function to duplicate this call
		-- and the rest are all of the calls in order
		-- as normal with stuff starting with _ please dont touch outside of fleetCustom
		_custom_info = {},
		-- table of all players, any call in here should free lua objects for destroyed playerShips
		_player_list = {}
	}
	setmetatable(ret,fleetCustom)
	return ret
end
function fleetCustom:_garbage_collection()
	-- internal to fleetCustom, should be called often, but doesnt need to be each update()
	removeInvalidFromEETable(self._player_list)
end
function fleetCustom:addToFleet(player)
	-- note there currently is no removal from fleets
	-- this wouldnt be hard to write, but I currently see no
	-- use for it
	self:_garbage_collection()
	table.insert(self._player_list,player)
	for _,custom in pairs(self._custom_info) do
		if custom[1] == "addCustomButton" then
			local _,position,name,caption,callback_inner,order = table.unpack(custom)
			local callback = function ()
				callback_inner(player)
			end
			player:wrappedAddCustomButton(position,name,caption,callback,order)
		else
			local set = function (fun_name,...)
				player[fun_name](player,...)
			end
			set(table.unpack(custom))
		end
	end
end
function fleetCustom:addCustomButton(position,name,caption,callback_inner,order)
	-- note the first argument in the callback becomes the player ship
	-- this makes this incompatable with the base game
	-- it really shouldnt for any real world code though
	self:_garbage_collection()
	for _,p in pairs(self._player_list) do
		local callback = function ()
			callback_inner(p)
		end
		p:wrappedAddCustomButton(position,name,caption,callback,order)
	end
	self._custom_info[name]={"addCustomButton",position,name,caption,callback_inner,order}
end
function fleetCustom:addCustomInfo(player,position,name,caption,order)
	self:_garbage_collection()
	for _,p in pairs(self._player_list) do
		p:wrappedAddCustomInfo(position,name,caption,order)
	end
	self._custom_info[name]={"wrappedAddCustomInfo",position,name,caption,order}
end
function fleetCustom:addCustomMessage(position,name,caption)
	-- we arent even going to try to cache messages, we have no way to tell
	-- when players have clicked on them
	-- its possible if we wrap calls round addCustomMessage we could make it work
	-- but it opens questions like "do we show this if one ship has closed and one has opened"
	-- this is a logical thing to implement if it ends up being wanted though
	self:_garbage_collection()
	for _,p in pairs(self._player_list) do
		p:wrappedAddCustomMessage(position,name,caption)
	end
end
function fleetCustom:addCustomMessageWithCallback(position,name,caption,callback)
	-- see addCustomMessage
	self:_garbage_collection()
	for _,p in pairs(self._player_list) do
		p:wrappedAddCustomMessageWithCallback(position,name,caption,callback)
	end
end
function fleetCustom:removeCustom(name)
	self:_garbage_collection()
	for _,p in pairs(self._player_list) do
		p:wrappedRemoveCustom(name)
	end
	self._custom_info[name]=nil
end
-------------------
-- update system --
-------------------

updateSystem = {}
updateSystem.__index = updateSystem
function updateSystem:create()
	local update_sys = {}
	setmetatable(update_sys,updateSystem)
	-- treat _update_objects as private to updateSystem
	-- my lack of lua knowledge is showing here
	-- _update_objects is an array, which probably is probably non optimal
	-- in particular random removal and checking if an item is within are slow
	-- this was not a issue with the few thousand entries tested with, but may need revisiting if performance issue surface
	update_sys._update_objects={}
	return update_sys
end
function updateSystem:update(delta)
	-- update should be called each time the main update is called
	-- it will run all updates on all objects
	-- it will also handle the case that objects are deleted
	-- TODO it should have a way to say "remove this update", but currently doesn't
	assert(type(self)=="table")
	assert(type(delta)=="number")
	-- we iterate through the _update_objects in reverse order so removed entries don't result in skipped updates
	for index = #self._update_objects,1,-1 do
		if self._update_objects[index]:isValid() then
			local obj=self._update_objects[index]
			for index = #obj.update_list,1,-1 do
				if obj:isValid() then -- one of the updates can call obj:destroy()
					obj.update_list[index]:update(obj,delta)
				end
			end
		else
			table.remove(self._update_objects,index)
		end
	end
end
function updateSystem:_clear_update_list()
	-- mostly to assist in testing
	-- while it could easily be done inline it hopefully will make it easier to change data structures if needed
	assert(type(self)=="table")
	self._update_objects = {}
end
function updateSystem:_addToUpdateList(obj)
	-- treat _addToUpdateList as private to updateSystem
	-- this adds a object to the update list, while ensuring it isn't duplicated
	assert(type(self)=="table")
	assert(type(obj)=="table")
	for index = 0,#self._update_objects do
		if self._update_objects[index]==obj then
			return
		end
	end
	table.insert(self._update_objects,obj)
end
function updateSystem:removeUpdateNamed(obj,name)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(name)=="string")
	if obj.update_list ~= nil then
		for index = #obj.update_list,1,-1 do
			assert(type(obj.update_list[index].name)=="string")
			if obj.update_list[index].name==name then
				table.remove(obj.update_list,index)
			end
		end
	end
end
function updateSystem:removeThisUpdate(obj,update)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(update)=="table")
	if obj.update_list ~= nil then
		for index = 1,#obj.update_list do
			if obj.update_list[index]==update then
				table.remove(obj.update_list,index)
				return
			end
		end
	end
end
function updateSystem:getUpdateNamed(obj,name)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(name)=="string")
	if obj.update_list ~= nil then
		for index = 1,#obj.update_list do
			if obj.update_list[index].name==name then
				return obj.update_list[index]
			end
		end
	end
	return nil
end
function updateSystem:addUpdate(obj,update_name,update_data)
	-- there is only one update function of each update_name
	-- update_data is a table with at a minimum a function called update which takes 3 arguments
	-- argument 1 - self (the table)
	-- argument 2 - delta - delta (as passed from the main update function)
	-- argument 3 - obj - the object being updated
	-- it is expected that data needed needed for the update function will be stored in the obj or the update_data table
	assert(type(obj)=="table")
	assert(type(update_name)=="string")
	assert(type(update_data)=="table")
	update_data.name=update_name
	assert(type(update_data.update)=="function","addUpdate update_data must be a table with a member update as a function update="..update_name)
	if update_data.edit == nil then
		update_data.edit = {}
	end
	self:removeUpdateNamed(obj,update_name)
	if obj.update_list == nil then
		obj.update_list = {}
	end
	table.insert(obj.update_list,update_data)
	self:_addToUpdateList(obj)
end
function updateSystem:getUpdateNamesOnObject(obj)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	if obj.update_list == nil then
		return {}
	end
	local ret={}
	for index = 1,#obj.update_list do
		local update_name=obj.update_list[index].name
		assert(type(update_name)=="string")
		local edit={}
		assert(type(obj.update_list[index].edit)=="table","each update object must have an edit table")
		for index2 = 1,#obj.update_list[index].edit do
			local name=obj.update_list[index].edit[index2].name
			local array_index=obj.update_list[index].edit[index2].index
			local fixedAdjAmount=obj.update_list[index].edit[index2].fixedAdjAmount
			assert(type(name)=="string")
			local display_name=name
			assert(array_index==nil or type(array_index)=="number")
			if array_index ~= nil then
				display_name = display_name .. "[" .. array_index .. "]"
			end
			table.insert(edit,{
				getter = function()
					-- note the time that this is executed the number of updates and their order may of changed
					-- as such we have to fetch them from scratch
					-- this probably could use being tested better, ideally added into the testing code
					local ret=self:getUpdateNamed(obj,update_name)[name]
					if array_index ~= nil then
						ret=ret[array_index]
					end
					assert(type(ret)=="number")
					return ret
				end,
				setter = function(val)
					if array_index == nil then
						self:getUpdateNamed(obj,update_name)[name]=val
					else
						self:getUpdateNamed(obj,update_name)[name][array_index]=val
					end
				end,
				fixedAdjAmount=fixedAdjAmount,
				name=display_name
			})
		end
		table.insert(ret,{
			name=update_name,
			edit=edit
		})
	end
	return ret
end
function updateSystem:addUpdateFixedPositions(obj, again_time, points)
	-- move an object along a list of points, cycling every again_time 
	-- Note: my text editor tries to pair repeat_time with other bits of code, so I changed it to again_time
	-- due to the copy made of points it is kind of memory hungry
	-- caution should be used if you are creating a lot of these objects
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(again_time)=="number")
	assert(type(points)=="table")
	-- points is really an array of objects with an x & y location
	local update_data = {
		again_time = again_time,
		points = points,
		update = function(self,obj,delta)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(delta)=="number")
			local orbit_pos = math.floor(((getScenarioTime() % self.again_time) / self.again_time) * #points) + 1
			obj:setPosition(points[orbit_pos].x,points[orbit_pos].y)
		end
	}
	self:addUpdate(obj,"fixed positions",update_data)
end
function updateSystem:addSlowAndAccurateElliptical(obj, cx, cy, orbit_duration, rotation, e, semi_major_axis, start_angle)
	-- much of the cost of this is in the making the orbit speed up in the center
	-- there is a fairly heavy computational cost in generating the orbit
	-- and a fairly large array used after calculation
	-- in other words be very mindful when using this elsewhere
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(cx)=="number")
	assert(type(cy)=="number")
	assert(type(orbit_duration)=="number")
	assert(type(rotation)=="number")
	assert(type(e)=="number")
	assert(type(semi_major_axis)=="number")
	assert(type(start_angle)=="number")
	local locs = {}
	local triangles = {}
	local area = {}
	local total_area = 0
	local desired_points = orbit_duration * 50
	local total_segments = desired_points * 10
	-- we generate more points at an equal angle around the ellipse
	-- we are then going to calculate the area under a triangle made
	-- by each point
	for i = 0, total_segments do
		local angle = ((start_angle/360)*math.pi*2) + ((math.pi * 2)/total_segments * -i)
		local minor_axis = semi_major_axis * (math.sqrt(1-e*e))
		local c = semi_major_axis * e
		local r = minor_axis * minor_axis / (semi_major_axis - c * math.cos(angle))
		angle = angle + ((rotation/360) * math.pi*2)
		locs[i]={x=math.cos(angle) * r,y = math.sin(angle) * r, r=r}
		-- we start with the fomula for the area of a triangle with 2 sides and 1 angle
		-- which given the lines a, b & angle c is
		-- which is 0.5*a*b*sin(C)
		-- the real area isnt the goal - just the relative scaling between the triangles
		-- as C is a constant sin(C) is a constant, and the 0.5 and sin(C) for each triangle can be ignored
		-- thus for our purpose the area is a*b
		if i ~= 0 then
			area[i-1] = locs[i].r *locs[i-1].r
			total_area = total_area + area[i-1]
		end
		if i == total_segments then
			area[i] = locs[i].r *locs[0].r
			total_area = total_area + area[i]
		end
	end
	-- we now know the total area
	-- we also know the area of each triangle
	-- we also know from kepler's second law that an orbit will go over the same area with the same amount of time
	-- using this we will calculate the number of points requested
	-- Note: my text editor tries to pair end_points with other bits of code, so I changed it to completion_points
	local completion_points = {}
	local desired_area = 0
	for i=0,total_segments do
		if desired_area <= 0 then
			desired_area = desired_area + total_area / desired_points
			completion_points[#completion_points+1] = {x = locs[i].x + cx, y = locs[i].y + cy}
		end
		desired_area = desired_area - area[i]
	end
	update_system:addUpdateFixedPositions(obj,orbit_duration,completion_points)
end
function updateSystem:addLinear(obj, dx, dy, speed)
	-- linear makes the object ignore the pull of wormholes and blackholes
	-- every use case seems to be a linear to / from 2 locations
	-- as such it probably wants to become addLinearTo
	-- I am less than sure this is the best setup
	-- should it take an angle?
	-- should dx and dy not be scaled by speed
	-- all very good questions, also questions I dont have time to deal with right now
	-- so future code readers, feel free to come up with better answers and swtich over to them
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(dx)=="number")
	assert(type(dy)=="number")
	assert(type(speed)=="number")
	local x,y = obj:getPosition()
	local update_data = {
		speed = speed,
		dx = dx,
		dy = dy,
		x = x, -- todo document overwritting of wormholes etc
		y = y,
		update = function (self, obj, delta)
			self.x=self.x+self.dx*self.speed*delta
			self.y=self.y+self.dy*self.speed*delta
			obj:setPosition(self.x,self.y)
		end
	}
	self:addUpdate(obj,"linear to",update_data)
end
function updateSystem:addOwned(owned, owner)
	-- when the owner is destroyed the owned objects is also destroyed
	assert(type(self)=="table")
	assert(type(owned)=="table")
	assert(type(owner)=="table")
	local update_data = {
		owner = owner,
		update = function (self, obj, delta)
			assert(type(self)=="table")
			assert(type(owned)=="table")
			if self.owner == nil or not self.owner:isValid() then
				obj:destroy()
			end
		end
	}
	self:addUpdate(owned,"owned",update_data)
end
function updateSystem:addEnergyDecayCurve(obj, total_time, curve_x, curve_y)
	-- addShieldDecayCurve and addEnergyDecayCurve are mostly the same, they probably should be merged in some way
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(total_time)=="number")
	assert(type(curve_x)=="table")
	assert(#curve_x==4)
	assert(type(curve_x[1])=="number")
	assert(type(curve_x[2])=="number")
	assert(type(curve_x[3])=="number")
	assert(type(curve_x[4])=="number")
	assert(type(curve_y)=="table")
	assert(#curve_y==4)
	assert(type(curve_y[1])=="number")
	assert(type(curve_y[2])=="number")
	assert(type(curve_y[3])=="number")
	assert(type(curve_y[4])=="number")
	local update_data = {
		total_time = total_time,
		curve_x = curve_x,
		curve_y = curve_y,
		elapsed_time = 0,
		edit = {
			{name = "total_time", fixedAdjAmount=1},
			{name = "elapsed_time", fixedAdjAmount=60},
			{name = "curve_x", index = 1, fixedAdjAmount=0.01},
			{name = "curve_x", index = 2, fixedAdjAmount=0.01},
			{name = "curve_x", index = 3, fixedAdjAmount=0.01},
			{name = "curve_x", index = 4, fixedAdjAmount=0.01},
			{name = "curve_y", index = 1, fixedAdjAmount=0.01},
			{name = "curve_y", index = 2, fixedAdjAmount=0.01},
			{name = "curve_y", index = 3, fixedAdjAmount=0.01},
			{name = "curve_y", index = 4, fixedAdjAmount=0.01}
		},
		update = function (self, obj, delta)
			self.elapsed_time = self.elapsed_time + delta
			local time_ratio = math.clamp(0,1,self.elapsed_time / self.total_time)
			local curve={-- bah this is bad but until the update edit is better its needed
				{x = self.curve_x[1], y = self.curve_y[1]},
				{x = self.curve_x[2], y = self.curve_y[2]},
				{x = self.curve_x[3], y = self.curve_y[3]},
				{x = self.curve_x[4], y = self.curve_y[4]}
			}
			local energy_drain_per_second=math.CosineInterpolateTable(curve,time_ratio)
			local new_energy=obj:getEnergy()+energy_drain_per_second*delta
			obj:setEnergy(math.clamp(0,obj:getMaxEnergy(),new_energy))
		end
	}
	self:addUpdate(obj,"energy decay",update_data)
end
function updateSystem:addShieldDecayCurve(obj, total_time, curve_x, curve_y)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(total_time)=="number")
	assert(type(curve_x)=="table")
	assert(#curve_x==4)
	assert(type(curve_x[1])=="number")
	assert(type(curve_x[2])=="number")
	assert(type(curve_x[3])=="number")
	assert(type(curve_x[4])=="number")
	assert(type(curve_y)=="table")
	assert(#curve_y==4)
	assert(type(curve_y[1])=="number")
	assert(type(curve_y[2])=="number")
	assert(type(curve_y[3])=="number")
	assert(type(curve_y[4])=="number")
	local update_data = {
		total_time = total_time,
		curve_x = curve_x,
		curve_y = curve_y,
		elapsed_time = 0,
		edit = {
			{name = "total_time", fixedAdjAmount=1},
			{name = "elapsed_time", fixedAdjAmount=60},
			{name = "curve_x", index = 1, fixedAdjAmount=0.01},
			{name = "curve_x", index = 2, fixedAdjAmount=0.01},
			{name = "curve_x", index = 3, fixedAdjAmount=0.01},
			{name = "curve_x", index = 4, fixedAdjAmount=0.01},
			{name = "curve_y", index = 1, fixedAdjAmount=0.01},
			{name = "curve_y", index = 2, fixedAdjAmount=0.01},
			{name = "curve_y", index = 3, fixedAdjAmount=0.01},
			{name = "curve_y", index = 4, fixedAdjAmount=0.01}
		},
		update = function (self, obj, delta)
			self.elapsed_time = self.elapsed_time + delta
			local time_ratio = math.clamp(0,1,self.elapsed_time / self.total_time)
			local curve={-- bah this is bad but until the update edit is better its needed
				{x = self.curve_x[1], y = self.curve_y[1]},
				{x = self.curve_x[2], y = self.curve_y[2]},
				{x = self.curve_x[3], y = self.curve_y[3]},
				{x = self.curve_x[4], y = self.curve_y[4]}
			}
			local maxShieldRatio=math.CosineInterpolateTable(curve,time_ratio)
			local shields = {}
			for i=0,obj:getShieldCount()-1 do
				table.insert(shields,math.min((obj:getShieldMax(i)*maxShieldRatio),obj:getShieldLevel(i)))
			end
			obj:setShields(table.unpack(shields))
		end
	}
	self:addUpdate(obj,"shield decay",update_data)
end
function updateSystem:_addGenericOverclock(obj, overboosted_time, boost_time, overclock_name, data_mirror ,add_extra_update_data, inner_update)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(overboosted_time)=="number")
	assert(type(boost_time)=="number")
	assert(type(overclock_name)=="string")
	assert(type(data_mirror)=="function")
	assert(type(inner_update)=="function")
	assert(type(add_extra_update_data)=="function")
	local update_self = self
	local update_data = {
		boost_time = boost_time,
		overboosted_time = overboosted_time,

		time = overboosted_time + boost_time,
		mirrored_data = data_mirror(self,obj),
		edit = {
			{name = "boost_time", fixedAdjAmount=1},
			{name = "overboosted_time", fixedAdjAmount=1},
			{name = "time", fixedAdjAmount=1}
			-- mirrored data would be nice to export but not realistic
			-- refresh would be nice as an exported button
		},
		refresh = function (self)
			assert(type(self)=="table")
			self.time = self.overboosted_time + self.boost_time
		end,
		update = function (self, obj, delta)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(delta)=="number")
			self.time = self.time - delta
			local scale = math.clamp(self.time/self.boost_time,0,1)
			inner_update(self, obj, scale)
			-- if scale == 0 inner_update has already been called with 0, resulting in overclocks being turned off
			if scale == 0 then
				update_self:removeThisUpdate(obj,self)
			end
		end,
	}
	add_extra_update_data(self,obj,update_data)
	self:addUpdate(obj,overclock_name,update_data)
end
function updateSystem:addBeamBoostOverclock(obj, overboosted_time, boost_time, max_range_boosted, max_cycle_boosted)
	-- note calling this on a object that already has a boost enabled will probably not work as expected
	-- as it will pull the beam range/cycle time off of the boosted values rather than the default
	-- this should be fixed at some time
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(overboosted_time)=="number")
	assert(type(boost_time)=="number")
	assert(type(max_range_boosted)=="number")
	assert(type(max_cycle_boosted)=="number")

	self:_addGenericOverclock(obj,overboosted_time, boost_time,"beam overclock",
		-- 16 seems to be the max number of beams (seen via tweak menu)
		-- if the engine exports max number of beams it should be used rather than mirror all data
		function (self, obj)
			local mirrored_data={}
			for index=0,16 do
				table.insert(mirrored_data,
				{
					range = obj:getBeamWeaponRange(index),
					cycle_time = obj:getBeamWeaponCycleTime(index)
				})
			end
			return mirrored_data
		end,
		function (self, obj, update)
			update.max_range_boosted = max_range_boosted
			update.max_cycle_boosted = max_cycle_boosted
			table.insert(update.edit,{name = "max_range_boosted", fixedAdjAmount=0.1})
			table.insert(update.edit,{name = "max cycle_damage_boosted", fixedAdjAmount=0.1})
		end,
		function (self, obj, scale)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(scale)=="number")
				-- 16 seems to be the max number of beams (seen via tweak menu)
				-- if the engine exports max number of beams it should be used rather than mirror all data
			for index=0,16 do
				local beam_range = math.lerp(1,self.max_range_boosted,scale)*self.mirrored_data[index+1].range
				compatSetBeamWeaponRange(obj,index,beam_range)
				local beam_cycle = math.lerp(1,self.max_cycle_boosted,scale)*self.mirrored_data[index+1].cycle_time
				compatSetBeamWeaponCycleTime(obj,index,beam_cycle)
			end
		end
	)
end
function updateSystem:addEngineBoostUpdate(obj, overboosted_time, boost_time, max_impulse_boosted, max_turn_boosted)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(overboosted_time)=="number")
	assert(type(boost_time)=="number")
	assert(type(max_impulse_boosted)=="number")
	assert(type(max_turn_boosted)=="number")
	self:_addGenericOverclock(obj,overboosted_time, boost_time,"engine overclock",
		function (self, obj)
			return {
				impulse = obj:getImpulseMaxSpeed(index),
				turn_rate = obj:getRotationMaxSpeed(index)
			}
		end,
		function (self, obj, update)
			update.max_impulse_boosted = max_impulse_boosted
			update.max_turn_boosted = max_turn_boosted
			table.insert(update.edit,{name = "max_impulse_boosted", fixedAdjAmount=0.1})
			table.insert(update.edit,{name = "max max_turn_boosted", fixedAdjAmount=0.1})
		end,
		function (self, obj, scale)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(scale)=="number")
			obj:setImpulseMaxSpeed(math.lerp(1,self.max_impulse_boosted,scale)*self.mirrored_data.impulse)
			obj:setRotationMaxSpeed(math.lerp(1,self.max_turn_boosted,scale)*self.mirrored_data.turn_rate)
		end
	)
end
function updateSystem:addOverclockableTractor(obj, spawnFunc)
	-- this is horrifically specialized and I don't think there is any way around that
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(spawnFunc)=="function")
	local update_self=self
	local max_dist=1500
	self:_addGenericOverclock(obj,5, 30, "overclockable tractor",
		function (self, obj)end,
		function (self, obj, update)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(update)=="table")
			update.orbitingObj= {}
			for i=1,12 do
				local spawned = spawnFunc()
				self:addOrbitTargetUpdate(spawned,obj, max_dist, 30, i*30)
				table.insert(update.orbitingObj,spawned)
			end
		end,
		function (self, obj, scale)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(scale)=="number")
			for i=#self.orbitingObj,1,-1 do
				local orbiting=self.orbitingObj[i]
				if orbiting:isValid() then
					local orbiting_update=update_self:getUpdateNamed(orbiting,"orbit target")
					if orbiting_update ~= nil then
						orbiting_update.distance=math.lerp(0,max_dist,scale)
					end
				else
					table.remove(self.orbitingObj,i)
				end
			end
		end
	)
end
function updateSystem:_addGenericOverclocker(obj, period, updateName, addUpdate, updateRange, filterFun, playerApply)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(period)=="number")
	assert(type(updateName)=="string")
	assert(type(addUpdate)=="function")
	assert(type(updateRange)=="number")
	assert(filterFun==nil or type(filterFun)=="function")
	assert(playerApply==nil or type(playerApply)=="function")
	local callback = function(obj)
		assert(type(obj)=="table")
		local x,y=obj:getPosition()
		local objs=getObjectsInRadius(x,y,updateRange)
		-- filter to spaceShips that are our faction
		for index=#objs,1,-1 do
			if objs[index].typeName == "CpuShip" and objs[index]:getFaction() == obj:getFaction() and obj ~= objs[index] then
				if filterFun == nil or filterFun(objs[index]) then
					local art=Artifact():setPosition(x,y):setDescription("encrypted data")
					if playerApply ~= nil then
						art:onPlayerCollision(playerApply)
					end
					local callback=function (self, obj, target)
						assert(type(self)=="table")
						assert(type(obj)=="table")
						assert(type(target)=="table")
						local update = self:getUpdateNamed(target,updateName)
						if update == nil then
							addUpdate(target)
						else
							update:refresh()
						end
					end
					self:addChasingUpdate(art,objs[index],1000,callback)
				end
			end
		end
	end
	self:addPeriodicCallback(obj,callback,period)
end
function updateSystem:addBeamOverclocker(obj, period)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(period)=="number")
	local addUpdate = function (target)
		assert(type(target)=="table")
		self:addBeamBoostOverclock(target, 5, 10, 2, 0.75)
	end
	-- defense platforms are too scary to be beam boosted
	local filter = function(possibleTarget)
		return possibleTarget:getTypeName() ~= "Defense platform"
	end
	local playerApply = function(artifact, player)
		artifact:destroy()
		local update = self:getUpdateNamed(player,"beam overclock")
		if update == nil then
			self:addBeamBoostOverclock(player, 10, 30, 0.5, 1.5)
		else
			update:refresh()
		end
		artifact:destroy()
	end
	self:_addGenericOverclocker(obj, period, "beam overclock", addUpdate, 5000, filter, playerApply)
end
function updateSystem:addShieldOverclocker(obj, period)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(period)=="number")
	local addUpdate = function (target)
		assert(type(target)=="table")
		local shields = {}
		for i=0,target:getShieldCount()-1 do
			table.insert(shields,math.min(target:getShieldMax(i),target:getShieldLevel(i)+10))
		end
		target:setShields(table.unpack(shields))
	end
	local playerApply = function(artifact, player)
		local shields = {}
		for i=0,player:getShieldCount()-1 do
			table.insert(shields,math.max(0,player:getShieldLevel(i)-20))
		end
		player:setShields(table.unpack(shields))
		artifact:destroy()
	end
	self:_addGenericOverclocker(obj, period, "shield overclock", addUpdate, 5000, nil, playerApply)
end
function updateSystem:addEngineOverclocker(obj, period)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(period)=="number")
	local addUpdate = function (target)
		assert(type(target)=="table")
		self:addEngineBoostUpdate(target, 5, 10, 2, 2)
	end
	local playerApply = function(artifact, player)
		local update = self:getUpdateNamed(player, "engine overclock")
		if update == nil then
			self:addEngineBoostUpdate(player, 10, 30, 0.5, 0.5)
		else
			update:refresh()
		end
		artifact:destroy()
	end
	self:_addGenericOverclocker(obj, period, "engine overclock", addUpdate, 5000, nil, playerApply)
end
function updateSystem:addOrbitingOverclocker(obj, period)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(period)=="number")
	local addUpdate = function (target) end -- we are not adding updates, only refreshing existing ones
	local filterFun = function (possibleTarget)
		return self:getUpdateNamed(possibleTarget,"overclockable tractor") ~= nil
	end
	self:_addGenericOverclocker(obj, period, "overclockable tractor", addUpdate, 10000, filterFun)
end
function updateSystem:addOverclockOptimizer(obj, period)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(period)=="number")
	local callback = function (obj)
		assert(type(obj)=="table")
		local objs = getAllObjects()
		for index = #objs,1,-1 do
			if objs[index].typeName == "CpuShip" and objs[index]:getFaction() == obj:getFaction() and obj ~= objs[index] then
				-- this is mostly wrong, we really want to check if an overclocker
				-- callback was in the update function, however this is not exposed
				-- currently it is almost always correct to say if there is a periodic callback
				-- then it is an overclocker ship, this is possible to ensure via being aware of
				-- this fact and GMing around it, this is however sub optimal
				if self:getUpdateNamed(objs[index],"periodic callback") ~= nil then
					local x,y=obj:getPosition()
					local art=Artifact():setPosition(x,y)
					self:addChasingUpdate(art,objs[index],2000)
				end
			end
		end
	end
	self:addPeriodicCallback(obj,callback,period)
end
function updateSystem:addArtifactCyclicalColorUpdate(obj, red_start, red1, red2, red_time, green_start, green1, green2, green_time, blue_start, blue1, blue2, blue_time)
	-- cycles from colour1 to colour2 in colour_time
	-- at the end of the cycle it will jump from colour2 to colour1
	-- colour_start specifices how many seconds it should of been running by the time the function is called
	-- so 0 = starts with colour1, getScenarioTime() starts as if it has been running and cycling since the start of the scenario
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(red_start)=="number")
	assert(type(red1)=="number")
	assert(type(red2)=="number")
	assert(type(red_time)=="number")
	assert(type(green_start)=="number")
	assert(type(green1)=="number")
	assert(type(green2)=="number")
	assert(type(green_time)=="number")
	assert(type(blue_start)=="number")
	assert(type(blue1)=="number")
	assert(type(blue2)=="number")
	assert(type(blue_time)=="number")
	local update_data = {
		red_start = red_start - getScenarioTime(),
		red1 = red1,
		red2 = red2,
		red_time = red_time,
		green_start = green_start - getScenarioTime(),
		green1 = green1,
		green2 = green2,
		green_time = green_time,
		blue_start = blue_start - getScenarioTime(),
		blue1 = blue1,
		blue2 = blue2,
		blue_time = blue_time,
		update = function(self, obj, delta)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(delta)=="number")
			local r = math.lerp(self.red1,self.red2,((getScenarioTime()+self.red_start) % self.red_time)/self.red_time)
			local g = math.lerp(self.green1,self.green2,((getScenarioTime()+self.green_start) % self.green_time)/self.green_time)
			local b = math.lerp(self.blue1,self.blue2,((getScenarioTime()+self.blue_start) % self.blue_time)/self.blue_time)
			obj:setRadarTraceColor(math.floor(r),math.floor(g),math.floor(b))
		end
	}
	self:addUpdate(obj,"Artifact Color",update_data)
end
function updateSystem:addOrbitUpdate(obj, center_x, center_y, distance, orbit_time, initial_angle)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(center_x)=="number")
	assert(type(center_y)=="number")
	assert(type(distance)=="number")
	assert(type(orbit_time)=="number")
	assert(type(initial_angle)=="number" or initial_angle == nil)
	initial_angle = initial_angle or 0
	local update_data = {
		center_x = center_x,
		center_y = center_y,
		distance = distance,
		orbit_time = orbit_time/(2*math.pi),
		start_offset = (initial_angle/360)*orbit_time,
		edit = {
			-- center x and y should be added when it can be - it probably wants an onclick handler
			{name = "distance" , fixedAdjAmount=1000},
			{name = "orbit_time", fixedAdjAmount=1},
			{name = "start_offset", fixedAdjAmount=1}
		},
		update = function (self,obj,delta)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(delta)=="number")
			local orbit_pos=((getScenarioTime() + self.start_offset)/self.orbit_time)
			obj:setPosition(self.center_x+(math.cos(orbit_pos)*self.distance),self.center_y+(math.sin(orbit_pos)*self.distance))
		end
	}
	self:addUpdate(obj,"orbit",update_data)
end
function updateSystem:addAttachedUpdate(obj, attach_target, relative_attach_x, relative_attach_y)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(attach_target)=="table")
	assert(type(relative_attach_x)=="number")
	assert(type(relative_attach_y)=="number")
	local update_data = {
		attach_target = attach_target,
		relative_attach_x = relative_attach_x,
		relative_attach_y = relative_attach_y,
		update = function (self,obj)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			if self.attach_target ~= nil and self.attach_target:isValid() then
				local attach_x, attach_y = self.attach_target:getPosition()
				obj:setPosition(attach_x+self.relative_attach_x,attach_y+self.relative_attach_y)
			else
				update_system:removeUpdateNamed(obj,"attached")
			end
		end
	}
	self:addUpdate(obj,"attached",update_data)
end
function updateSystem:addChasingUpdate(obj, target, speed, callback_on_contact)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(target)=="table")
	assert(type(speed)=="number")
	assert(callback_on_contact==nil or type(callback_on_contact)=="function")
	local update_self = self -- this is so it can be captured for later
	local update_data = {
		speed = speed,
		target = target,
		callback_on_contact = callback_on_contact,
		edit = {
			-- todo add target
			{name = "speed", fixedAdjAmount = 100}
		},
		update = function (self, obj, delta)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(delta)=="number")
			if target==nil or not target:isValid() then
				obj:destroy()
			else
				local update_speed=speed*delta
				local my_x, my_y = obj:getPosition()
				local target_x, target_y = target:getPosition()
				local dist=distance(my_x, my_y, target_x, target_y)
				if dist > update_speed then
					local dx=target_x-my_x
					local dy=target_y-my_y
					local angle=math.atan2(dx,dy)
					local ny=math.cos(angle)*update_speed
					local nx=math.sin(angle)*update_speed
					obj:setPosition(my_x+nx,my_y+ny)
				else
					if self.callback_on_contact ~= nil then
						self.callback_on_contact(update_self, obj, target)
					end
					obj:destroy()
				end
			end
		end
	}
	self:addUpdate(obj,"chasing",update_data)
end
function updateSystem:addFormationLeaderCommandUpdate(obj, distance)
	assert(type(obj)=="table")			--generally another reference to self
	assert(type(distance)=="number")	--how far away to allow enemies
	local update_data = {
		name = "formation leader command",
		distance = distance,
		edit = {
			{name = "distance", fixedAdjAmount = 1000}
		},
		update = function (self, obj, delta)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(delta)=="number")
			if obj:areEnemiesInRange(self.distance) then
				if self.formation_ships ~= nil then
					for _, ship in ipairs(self.formation_ships) do
						if ship ~= nil and ship:isValid() then
							ship:orderDefendTarget(self)
						end
					end
					self.formation_ships = nil
				end
				update_system:removeUpdateNamed(obj,"formation leader command")
			end
		end
	}
	self:addUpdate(obj,"formation leader command",update_data)
end
function updateSystem:addOrbitTargetUpdate(obj, orbit_target, distance, orbit_time, initial_angle)
	assert(type(self)=="table")
	assert(type(obj)=="table")			--generally another reference to self that is orbiting
	assert(type(orbit_target)=="table")	--the thing that self is orbiting
	assert(type(distance)=="number")	--how far away self is orbiting orbit_target
	assert(type(orbit_time)=="number")	--how long to complete one orbit
	assert(type(initial_angle)=="number" or 
		initial_angle == nil)			--angle at which to start the orbit
	initial_angle = initial_angle or 0
	local update_data = {
		name = "orbit target",
		orbit_target = orbit_target,
		distance = distance,
		orbit_time = orbit_time/(2*math.pi),
		initial_angle = initial_angle, -- this looks obsolete, test removal with proper testing
		start_offset = (initial_angle/360)*orbit_time,
		time = 0, -- this can be removed after getScenarioTime gets into the current version of EE
		edit = {
			-- orbit target wants to be exposed when we have a object selection control
			{name = "distance" , fixedAdjAmount=1000},
			{name = "orbit_time", fixedAdjAmount=1},
			{name = "start_offset", fixedAdjAmount=1}
		},
		update = function (self,obj,delta)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(delta)=="number")
			self.time = self.time + delta
			local orbit_pos=(self.time+self.start_offset)/self.orbit_time
			if self.orbit_target ~= nil and self.orbit_target:isValid() then
				local orbit_target_x, orbit_target_y = self.orbit_target:getPosition()
				obj:setPosition(orbit_target_x+(math.cos(orbit_pos)*self.distance),orbit_target_y+(math.sin(orbit_pos)*self.distance))
			end
		end
	}
	self:addUpdate(obj,"orbit target",update_data)
end
function updateSystem:addOrbitTargetWithInfluenceUpdate(obj, orbit_target, orbit_radius, slow_orbit_speed, fast_orbit_speed, orbit_influencer, slow_distance, fast_distance)
	assert(type(self)=="table")
	assert(type(obj)=="table")				--generally another reference to self that is orbiting
	assert(type(orbit_target)=="table")		--the thing that self is orbiting
	assert(type(orbit_radius)=="number")	--how far away self is orbiting orbit_target
	assert(type(slow_orbit_speed)=="number")	--how fast to orbit while in slow region; deg/sec
	assert(type(fast_orbit_speed)=="number")	--how fast to orbit while in fast region; deg/sec
	assert(type(orbit_influencer)=="table")	--the thing that influences how fast self orbits orbit_target
	assert(type(slow_distance)=="number")	--boundary distance between slow and transition speed
	assert(type(fast_distance)=="number")	--boundary distance between fast and transition speed
	local ot_x, ot_y = orbit_target:getPosition()
	local obj_x, obj_y = obj:getPosition()
	local orbit_angle = angleFromVectorNorth(ot_x,ot_y,obj_x,obj_y)
	local update_data = {
		orbit_target = orbit_target,
		orbit_radius = orbit_radius,
		slow_orbit_speed = slow_orbit_speed,
		fast_orbit_speed = fast_orbit_speed,
		orbit_influencer = orbit_influencer,
		slow_distance = slow_distance,
		fast_distance = fast_distance,
		orbit_angle = orbit_angle,
		edit = {
			{name = "orbit_radius" , fixedAdjAmount=100},
		},
		update = function (self,obj,delta)
			if self.orbit_target ~= nil and self.orbit_target:isValid() then
				local orbit_target_x, orbit_target_y = self.orbit_target:getPosition()
				local orbit_speed = 0
				if self.orbit_influencer ~= nil and self.orbit_influencer:isValid() then
					local orbit_influencer_x, orbit_influencer_y = self.orbit_influencer:getPosition()
					local influence_distance = distance(obj,obj.orbit_influencer)
					if influence_distance < self.slow_distance then
						orbit_speed = self.slow_orbit_speed
					elseif influence_distance > self.fast_distance then
						orbit_speed = self.fast_orbit_speed
					else
						orbit_speed = influence_distance/self.fast_distance*self.fast_orbit_speed
					end
				else
					orbit_speed = self.fast_orbit_speed
				end
				self.orbit_angle = (self.orbit_angle + (orbit_speed*delta)) % 360
				local new_pos_x, new_pos_y = vectorFromAngleNorth(self.orbit_angle,self.orbit_radius)
				obj:setPosition(orbit_target_x + new_pos_x,orbit_target_y + new_pos_y)
			end
		end
	}
	self:addUpdate(obj,"orbit target with influence",update_data)
end
function updateSystem:addPatrol(obj, patrol_points, patrol_point_index, patrol_check_timer_interval)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(patrol_points)=="table")
	assert(type(patrol_point_index)=="number")
	assert(type(patrol_check_timer_interval)=="number")
	local update_self = self
	obj.patrol_points = patrol_points
	obj.patrol_point_index = patrol_point_index
	obj.patrol_check_timer_interval = patrol_check_timer_interval
	obj.patrol_check_timer = patrol_check_timer_interval
	local update_data = {
		update = function (self, obj, delta)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(delta)=="number")
			if obj.patrol_points == nil then
				obj.patrol_point_index = nil
				obj.patrol_check_timer_interval = nil
				obj.patrol_check_timer = nil
				update_self:removeThisUpdate(obj,self)
			else
				obj.patrol_check_timer = obj.patrol_check_timer - delta
				if obj.patrol_check_timer < 0 then
					if string.find(obj:getOrder(),"Defend") then
						obj.patrol_point_index = obj.patrol_point_index + 1
						if obj.patrol_point_index > #obj.patrol_points then
							obj.patrol_point_index = 1
						end
						obj:orderFlyTowards(obj.patrol_points[obj.patrol_point_index].x,obj.patrol_points[obj.patrol_point_index].y)
					end
					obj.patrol_check_timer = obj.patrol_check_timer_interval
				end
			end
		end
	}
	self:addUpdate(obj,"patrol",update_data)
end
function updateSystem:addPeriodicCallback(obj, callback, period, accumulated_time, random_jitter)
	-- TODO - currently only one periodic function can be on a update object, this probably should be fixed
	-- the callback is called every period seconds, it can be called multiple times if delta is big or period is small
	-- it is undefined if called with an exact amount of delta == period as to if the callback is called that update or not
	-- consider moving to the scheduler code that hemmond made
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(callback)=="function")
	assert(type(period)=="number")
	assert(accumulated_time==nil or type(accumulated_time)=="number")
	assert(random_jitter==nil or type(random_jitter)=="number")
	assert(period>0.0001) -- really just needs to be positive, but this is low enough to probably not be an issue
	local update_data = {
		callback = callback,
		period = period,
		accumulated_time = accumulated_time or 0,
		random_jitter = random_jitter or 0,
		edit = {
			-- orbit target wants to be exposed when we have a object selection control
			{name = "period" , fixedAdjAmount=1},
			{name = "accumulated_time", fixedAdjAmount=1}
		},
		update = function (self,obj,delta)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(delta)=="number")
			self.accumulated_time = self.accumulated_time + delta
			if self.accumulated_time > self.period then
				self.callback(obj)
				self.accumulated_time = self.accumulated_time - self.period - random(0,self.random_jitter)
				-- we could do this via a loop
				-- or via calling back into this own function
				-- technically this is probably slower (as we will end up with calling a function and the assert logic)
				-- I am going to be surprised if that matters
				-- a callback is pretty easy to do, so we will do it that way
				self:update(obj,0)
			end
		end
	}
	self:addUpdate(obj,"periodic callback",update_data)
end
function updateSystem:addNameCycleUpdate(obj, period, nameTable, accumulated_time)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(period)=="number")
	assert(type(nameTable)=="table")
	assert(#nameTable~=0)
	assert(accumulated_time==nil or type(accumulated_time)=="number")
	obj.nameNum=0
	local callback = function(obj)
		obj.nameNum = (obj.nameNum + 1) % #nameTable
		obj:setCallSign(nameTable[obj.nameNum + 1])
	end
	self:addPeriodicCallback(obj,callback,period,accumulated_time)
end
function updateSystem:addTimeToLiveUpdate(obj, timeToLive)
	assert(type(self)=="table")
	assert(type(obj)=="table")
	assert(type(timeToLive)=="number" or TimeToLive==nil)
	timeToLive = timeToLive or 300
	local update_data = {
		timeToLive = timeToLive,
		edit = {
			{name = "timeToLive", fixedAdjAmount=1}
		},
		update = function (self,obj,delta)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(delta)=="number")
			self.timeToLive = self.timeToLive - delta
			if self.timeToLive < 0 then
				obj:destroy()
			end
		end
	}
	self:addUpdate(obj,"time To Live",update_data)
end
function updateSystem:_test()
	assert(type(self)=="table")
	---------------------------------------------------------------------------------------------------------------
	-- first up we are going to ensure that _addToUpdateList doesn't add the same element multiple times
	-- this likely would be annoying to debug (as things would run faster for no real reason) and hard to spot
	-- (as many of the ways it will fail would not result in errors)
	---------------------------------------------------------------------------------------------------------------
	local tmp1={}
	local tmp2={}
	-- starting
	assert(#self._update_objects==0)
	-- add the first element
	self:_addToUpdateList(tmp1)
	assert(#self._update_objects==1)
	-- ensure we cant add one more
	self:_addToUpdateList(tmp1)
	assert(#self._update_objects==1)
	-- add the second element
	self:_addToUpdateList(tmp2)
	assert(#self._update_objects==2)
	-- ensure both the first and last element are checked
	self:_addToUpdateList(tmp1)
	assert(#self._update_objects==2)
	self:_addToUpdateList(tmp2)
	assert(#self._update_objects==2)

	-- reset for next test
	self:_clear_update_list()
	assert(#self._update_objects==0)
	---------------------------------------------------------------------------------------------------------------
	-- now onto testing addUpdate
	-- we are going to ensure that multiple updates of the same type cant be added (as that will break in non obvious ways)
	-- note the testObj is not a spaceObject, which will break some functions like update
	-- if this blocks fails asserts later, it is possible that checks have been added to addUpdate to ensure that the object is a spaceObject
	---------------------------------------------------------------------------------------------------------------
	local testObj={}
	assert(testObj.update_list==nil)
	self:addUpdate(testObj,"test",{update=function()end})
	assert(testObj.update_list~=nil)
	assert(#testObj.update_list==1)
	self:addUpdate(testObj,"test",{update=function()end})
	assert(#testObj.update_list==1)
	self:addUpdate(testObj,"test2",{update=function()end})
	assert(#testObj.update_list==2)
	self:addUpdate(testObj,"test",{update=function()end})
	assert(#testObj.update_list==2)
	self:addUpdate(testObj,"test2",{update=function()end})
	assert(#testObj.update_list==2)

	-- reset for next test
	self:_clear_update_list()
	assert(#self._update_objects==0)
	---------------------------------------------------------------------------------------------------------------
	-- addPeriodicCallback
	---------------------------------------------------------------------------------------------------------------
	local testObj=newPhonySpaceObject()
	local captured=0
	local captured_fun = function ()
		captured = captured + 1
	end
	self:addPeriodicCallback(testObj,captured_fun,1)
	assert(captured==0)
	-- insufficient to run the callback
	self:update(0.9)
	assert(captured==0)
	-- check that the callback being called once results in the callback running once
	self:update(1)
	assert(captured==1)
	-- check that the callback being overdue results in multiple calls
	self:update(2)
	assert(captured==3)
	-- TODO check with different periodic values
	--assert(captured==0)

	-- reset for next test
	self:_clear_update_list()
	assert(#self._update_objects==0)
end
-------------------------
-- registering regions --
-------------------------
function universe()
	return {
		-- each region has at least 1 function
		-- destroy(self) this destroys the sector
		active_regions = {},
		-- spawn a region already registered in the available_regions
		-- it is expected to be called like
		-- universe:spawnRegion(universe.available_regions[spawnIndex])
		-- rather than the region being built from scratch
		-- that allows addAvailableRegion to have validated the region rather than relying on outside validation
		spawnRegion = function (self,region)
			assert(type(self)=="table")
			assert(type(region)=="table")
			assert(type(region.name)=="string")
			assert(type(region.spawn)=="function")
			if region.name ~= "Icarus (F5)" then
				addGMMessage(region.name .. " created")
			end
			table.insert(self.active_regions,{name=region.name,region=region.spawn()})
		end,
		-- has the following region been spawned already
		-- expected use is like the spawnRegion above
		hasRegionSpawned = function (self,region)
			assert(type(self)=="table")
			assert(type(region)=="table")
			assert(type(region.name)=="string")
			for i = 1,#self.active_regions do
				if self.active_regions[i].name==region.name then
					return true
				end
			end
			return false
		end,
		-- remove the following region from the region
		-- expected use is much like spawnRegion above
		-- it is asserted that self:hasRegionSpawned(region)==true
		removeRegion = function (self,region)
			assert(type(self)=="table")
			assert(type(region)=="table")
			assert(type(region.name)=="string")
			addGMMessage(region.name .. " removed")
			for i = 1,#self.active_regions do
				if self.active_regions[i].name==region.name then
					self.active_regions[i].region:destroy()
					table.remove(self.active_regions,i)
					return
				end
			end
			-- if we reached this then we have been asked to remove an area that wasn't spawned
			-- this means the calling code is in error
			assert(false)
		end,
		-- add an available region to the internal list
		-- name is what will be shown to the gm
		-- spawn_function should create the region and return a table in the same form active_regions uses
		-- spawn_x and spawn_y are used for default location for new ships in this region (this is ensure outside of this class currently)
		addAvailableRegion = function (self, name, spawn_function, spawn_x, spawn_y)
			assert(type(self)=="table")
			assert(type(name)=="string")
			assert(type(spawn_function)=="function")
			assert(type(spawn_x)=="number")
			assert(type(spawn_y)=="number")
			table.insert(self.available_regions,{name=name,spawn=spawn_function,spawn_x=spawn_x,spawn_y=spawn_y})
		end,
		available_regions = {}
	}
end
-----------------------------
-- spaceObject look alikes --
-----------------------------
function newPhonySpaceObject()
	return {
		valid=true,
		isValid=function (self) return self.valid end,
		destroy=function (self) self.valid=false end,
	}
end