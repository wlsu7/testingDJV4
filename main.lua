repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end

local args = nil
if type(args) == "table" and args.Username then
	shared.ValidatedUsername = args.Username
end

if type(args) == "table" and args.Closet then
	getgenv().Closet = true
elseif getgenv().Closet == nil then
	getgenv().Closet = false
end

getgenv().isSkidPaid = true

local _realLoadstring = clonefunction(loadstring)
local vape
local loadstring = function(src, chunkname)
	local res, err = _realLoadstring(src, chunkname)
	if err and vape and vape.CreateNotification then
		pcall(function()
			vape:CreateNotification('DongJunV4', 'Failed to load : '..err, 30, 'alert')
		end)
	end
	return res
end

local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file) writefile(file, '') end
local cloneref = cloneref or function(obj) return obj end
local playersService = cloneref(game:GetService('Players'))
local httpService = cloneref(game:GetService('HttpService'))

local function downloadFile(path, func)
	if not isfile(path) then
		local res
		local success = false
		for attempt = 1, 3 do
			local suc, result = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/MostOpps/DongJunV4/' .. (readfile('newvape/profiles/commit.txt') or 'main') .. '/' .. select(1, path:gsub('newvape/', '')), true)
			end)
			if suc and result and result ~= '404: Not Found' and result ~= '' then
				res = result
				success = true
				break
			end
			task.wait(0.5)
		end
		if not success then
			warn('[Vape] Failed to download ' .. path .. ' (Skipping asset)')
			writefile(path, '')
			return ''
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n' .. res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function migrateProfiles()
	if isfile('newvape/profiles/migrated_placeid.txt') then return end
	local oldId = tostring(game.GameId)
	local newId = tostring(game.PlaceId)
	if oldId == newId then
		pcall(writefile, 'newvape/profiles/migrated_placeid.txt', 'done')
		return
	end
	local suffix = oldId .. '.txt'
	for _, path in ipairs(listfiles('newvape/profiles')) do
		local name = path:gsub('\\', '/')
		if name:sub(-#suffix) == suffix then
			local newPath = name:sub(1, -#suffix - 1) .. newId .. '.txt'
			if not isfile(newPath) then
				pcall(function() writefile(newPath, readfile(path)) end)
			end
		end
	end
	if isfolder('newvape/profiles/premade') then
		for _, path in ipairs(listfiles('newvape/profiles/premade')) do
			local name = path:gsub('\\', '/')
			if name:sub(-#suffix) == suffix then
				local newPath = name:sub(1, -#suffix - 1) .. newId .. '.txt'
				if not isfile(newPath) then
					pcall(function() writefile(newPath, readfile(path)) end)
				end
			end
		end
	end
	pcall(writefile, 'newvape/profiles/migrated_placeid.txt', 'done')
end
pcall(migrateProfiles)

local function finishLoading()
	vape.Init = nil
	if not vape.Load then
		warn('[DongJunV4] vape.Load is nil skipping load')
		return
	end
	
	pcall(function() vape:Load() end)
	
	vape:Clean(task.spawn(function()
		repeat
			pcall(vape.Save, vape)
			task.wait(10)
		until vape.Loaded == nil
	end))
	
	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				loadstring(game:HttpGet('https://raw.githubusercontent.com/MostOpps/DongJunV4/'..readfile('newvape/profiles/commit.txt')..'/loader.lua', true), 'loader')()
			]]
			if shared.VapeDeveloper then
				teleportScript = 'shared.VapeDeveloper = true\n' .. teleportScript
			end
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "' .. shared.VapeCustomProfile .. '"\n' .. teleportScript
			end
			if shared.ValidatedUsername then
				teleportScript = 'shared.ValidatedUsername = "' .. shared.ValidatedUsername .. '"\n' .. teleportScript
			end
			pcall(function() vape:Save() end)
			queue_on_teleport(teleportScript)
		end
	end))
	
	if not shared.vapereload then
		local name = shared.ValidatedUsername and ('wsg, ' .. shared.ValidatedUsername .. ' :D ') or 'welcome '
		pcall(function()
			if vape.CreateNotification then
				vape:CreateNotification('[DongJunV4] Finished Loading', name .. (vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press Shift / Keybind to open GUI'), 5)
			end
		end)
	end
end

local ASSETS_NEW = {
	'blockedtab.png', 'blockedicon.png', 'blatanticon.png',
	'bindbkg.png', 'bind.png', 'back.png', 'arrowmodule.png',
	'allowedtab.png', 'allowedicon.png', 'alert.png', 'add.png',
	'combaticon.png', 'colorpreview.png', 'closemini.png', 'close.png',
	'blurnotif.png', 'blur.png',
	'dots.png', 'discord.png', 'customsettings.png', 'edit.png',
	'expandicon.png', 'worldicon.png', 'warning.png', 'vape.png',
	'utilityicon.png', 'textvape.png', 'textv4.png', 'textguiicon.png',
	'targetstab.png', 'targetplayers2.png', 'targetplayers1.png',
	'targetnpc2.png', 'targetnpc1.png', 'targetinfoicon.png',
	'search.png', 'rendertab.png', 'rendericon.png', 'rangearrow.png',
	'range.png', 'rainbow_4.png', 'rainbow_3.png', 'rainbow_2.png',
	'rainbow_1.png', 'radaricon.png', 'profilesicon.png', 'pin.png',
	'overlaystab.png', 'overlaysicon.png', 'notification.png',
	'module.png', 'miniicon.png', 'legittab.png', 'legit.png',
	'inventoryicon.png', 'info.png', 'guivape.png', 'guiv4.png',
	'guisliderrain.png', 'guislider.png', 'guisettings.png',
	'friendstab.png', 'expandup.png', 'expandright.png',
	'guiicon.png', 'settingsicon.png', 'checkbox.png', 'barlogo.png'
}

if not isfile('newvape/profiles/gui.txt') then
	writefile('newvape/profiles/gui.txt', 'new')
end
local gui = readfile('newvape/profiles/gui.txt')

if not isfolder('newvape/assets/' .. gui) then
	makefolder('newvape/assets/' .. gui)
end

task.spawn(function()
	for _, name in ipairs(ASSETS_NEW) do 
		pcall(downloadFile, 'newvape/assets/new/' .. name) 
	end
end)

local guiSource = downloadFile('newvape/guis/' .. gui .. '.lua')
if not guiSource or guiSource == '' then
	error('[DongJunV4] Failed to fetch guiSource')
end

local guiFunc, guiErr = _realLoadstring(guiSource, 'gui')
if not guiFunc then
	error('[DongJunV4] syntax error in ' .. gui .. '.lua\n' .. tostring(guiErr))
end

vape = guiFunc()
if not vape then
	error('[DongJunV4] GUI returned nil file may be corrupted try deleting newvape/guis/' .. gui .. '.lua and reinjecting.')
end
if not vape.Load then
	if delfile then pcall(function() delfile('newvape/guis/' .. gui .. '.lua') end) end
	error('[DongJunV4] gui file corrupted (missing load) reinject..')
end

shared.vape = vape
task.wait(0.1)

if getgenv().Closet then
	local LogService = cloneref(game:GetService('LogService'))
	local originals = {}
	local function hook(funcName)
		if typeof(getgenv()[funcName]) == 'function' then
			local original = hookfunction(getgenv()[funcName], function() end)
			originals[funcName] = original
		end
	end
	hook('print')
	hook('warn')
	hook('error')
	hook('info')
	pcall(function() LogService:ClearOutput() end)
	local conn = LogService.MessageOut:Connect(function() LogService:ClearOutput() end)
	getgenv()._vape_log_connection = conn
	getgenv()._vape_originals = originals
end

if not shared.VapeIndependent then
	pcall(function()
		_realLoadstring(downloadFile('newvape/games/universal.lua'), 'universal')()
	end)
	
	local gameFileId = (game.GameId == 2619619496) and (game.PlaceId == 6872265039 and 6872265039 or 6872274481) or game.PlaceId
	
	if isfile('newvape/games/' .. gameFileId .. '.lua') then
		pcall(function()
			_realLoadstring(downloadFile('newvape/games/' .. gameFileId .. '.lua'), tostring(gameFileId))()
		end)
	else
		if not shared.VapeDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/MostOpps/DongJunV4/' .. (readfile('newvape/profiles/commit.txt') or 'main') .. '/games/' .. gameFileId .. '.lua', true)
			end)
			if suc and res and res ~= '404: Not Found' then
				pcall(function()
					_realLoadstring(downloadFile('newvape/games/' .. gameFileId .. '.lua'), tostring(gameFileId))()
				end)
			end
		end
	end
	
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
