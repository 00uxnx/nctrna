
--// Nocturne.bz Config Manager

local HttpService = game:GetService("HttpService")

local ConfigManager = {
	Library = nil,
	Folder = "Nocturnebz/Configs",
	DefaultConfig = "Default",
	CurrentConfig = "",

	Defaults = {
		Toggles = {},
		Options = {},
	},

	Prefix = "Nocturne.bz:",
}

--// Base64 encoder / decoder

local Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function base64Encode(data)
	return ((data:gsub(".", function(char)
		local byte = string.byte(char)
		local bits = ""

		for i = 7, 0, -1 do
			bits ..= math.floor(byte / 2^i) % 2
		end

		return bits
	end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(bits)
		if #bits < 6 then
			return ""
		end

		local value = 0
		for i = 1, 6 do
			if bits:sub(i, i) == "1" then
				value += 2^(6-i)
			end
		end

		return Alphabet:sub(value + 1, value + 1)
	end) .. ({ "", "==", "=" })[#data % 3 + 1])
end

local function base64Decode(data)
	data = data:gsub("[^" .. Alphabet .. "=]", "")

	local bits = data:gsub(".", function(char)
		if char == "=" then
			return ""
		end

		local value = Alphabet:find(char, 1, true) - 1
		local result = ""

		for i = 5, 0, -1 do
			result ..= math.floor(value / 2^i) % 2
		end

		return result
	end)

	return (bits:gsub("%d%d%d%d%d%d%d%d", function(byte)
		local value = 0

		for i = 1, 8 do
			if byte:sub(i, i) == "1" then
				value += 2^(8-i)
			end
		end

		return string.char(value)
	end))
end

--// Serialization helpers

local function packValue(value)
	local kind = typeof(value)

	if kind == "Color3" then
		return {
			__type = "Color3",
			R = value.R,
			G = value.G,
			B = value.B,
		}
	elseif kind == "EnumItem" then
		return {
			__type = "EnumItem",
			EnumType = tostring(value.EnumType):gsub("^Enum%.", ""),
			Name = value.Name,
		}
	elseif kind == "table" then
		local result = {}

		for key, item in pairs(value) do
			result[key] = packValue(item)
		end

		return result
	elseif kind == "string" or kind == "number"
		or kind == "boolean" or kind == "nil" then
		return value
	end

	return nil
end

local function unpackValue(value)
	if type(value) ~= "table" then
		return value
	end

	if value.__type == "Color3" then
		return Color3.new(value.R, value.G, value.B)
	elseif value.__type == "EnumItem" then
		local enumType = Enum[value.EnumType]
		return enumType and enumType[value.Name] or nil
	end

	local result = {}

	for key, item in pairs(value) do
		result[key] = unpackValue(item)
	end

	return result
end

--// Setup

function ConfigManager:SetLibrary(library)
	self.Library = library
end

function ConfigManager:SetDirectory(path)
	self.Folder = path
end

function ConfigManager:GetPath(name)
	name = tostring(name or "")

	if name == "" or name:find("[/\\]") or name:find("%.%.") then
		return nil
	end

	return self.Folder .. "/" .. name .. ".json"
end

function ConfigManager:EnsureFolder()
	if not (makefolder and isfolder) then
		return false, "Folder functions unavailable"
	end

	local current = ""

	for part in self.Folder:gmatch("[^/]+") do
		current = current == "" and part or current .. "/" .. part

		if not isfolder(current) then
			makefolder(current)
		end
	end

	return true
end

--// Capture the controls' initial defaults.
--// Call this AFTER creating all UI controls.

function ConfigManager:CaptureDefaults()
	assert(self.Library, "Call SetLibrary first")

	self.Defaults = {
		Toggles = {},
		Options = {},
	}

	for name, control in pairs(self.Library.Toggles or {}) do
		self.Defaults.Toggles[name] = packValue(control.Value)
	end

	for name, control in pairs(self.Library.Options or {}) do
		self.Defaults.Options[name] = packValue(control.Value)
	end
end

function ConfigManager:GetConfig()
	assert(self.Library, "Call SetLibrary first")

	local data = {
		Toggles = {},
		Options = {},
	}

	for name, control in pairs(self.Library.Toggles or {}) do
		data.Toggles[name] = packValue(control.Value)
	end

	for name, control in pairs(self.Library.Options or {}) do
		data.Options[name] = packValue(control.Value)
	end

	return data
end

--// Export to a shareable branded string

function ConfigManager:Export(name)
	local data = self:GetConfig()
	data.ConfigName = name or self.CurrentConfig or self.DefaultConfig

	local ok, json = pcall(function()
		return HttpService:JSONEncode(data)
	end)

	if not ok then
		return nil, "Failed to encode settings"
	end

	return self.Prefix .. base64Encode(json)
end

--// Decode and validate an imported config

function ConfigManager:DecodeConfig(encoded)
	if type(encoded) ~= "string" then
		return nil, "Config must be text"
	end

	encoded = encoded:gsub("^%s+", ""):gsub("%s+$", "")

	if encoded:sub(1, #self.Prefix) ~= self.Prefix then
		return nil, "Invalid Nocturne.bz config prefix"
	end

	local payload = encoded:sub(#self.Prefix + 1)

	if #payload == 0 or #payload > 2000000 then
		return nil, "Empty or oversized config"
	end

	local ok, decoded = pcall(base64Decode, payload)
	if not ok then
		return nil, "Invalid encoded config"
	end

	local jsonOK, data = pcall(function()
		return HttpService:JSONDecode(decoded)
	end)

	if not jsonOK or type(data) ~= "table" then
		return nil, "Invalid config data"
	end

	if type(data.Toggles) ~= "table"
		or type(data.Options) ~= "table" then
		return nil, "Missing settings data"
	end

	return data
end

--// Apply settings to existing controls

function ConfigManager:Apply(data)
	if not self.Library then
		return false, "Library not set"
	end

	local function applyGroup(controls, values)
		for name, saved in pairs(values or {}) do
			local control = controls[name]

			if control then
				local value = unpackValue(saved)

				if control.SetValue then
					pcall(function()
						control:SetValue(value)
					end)
				elseif control.Set then
					pcall(function()
						control:Set(value)
					end)
				else
					-- Do not assume direct assignment triggers UI callbacks.
					warn("No setter available for control:", name)
				end
			end
		end
	end

	applyGroup(self.Library.Toggles or {}, data.Toggles)
	applyGroup(self.Library.Options or {}, data.Options)

	self.CurrentConfig = data.ConfigName or self.CurrentConfig

	return true, "Config applied"
end

function ConfigManager:Import(encoded)
	local data, err = self:DecodeConfig(encoded)

	if not data then
		return false, err
	end

	return self:Apply(data)
end

--// Reset all controls to captured startup defaults

function ConfigManager:Reset()
	if not self.Library then
		return false, "Library not set"
	end

	local ok, err = self:Apply({
		Toggles = self.Defaults.Toggles,
		Options = self.Defaults.Options,
		ConfigName = "",
	})

	if ok then
		self.CurrentConfig = ""
		return true, "Settings reset to startup defaults"
	end

	return false, err
end

--// File operations

function ConfigManager:Save(name)
	name = name or self.CurrentConfig
	if name == "" then
		name = self.DefaultConfig
	end

	local path = self:GetPath(name)

	if not path then
		return false, "Invalid config name"
	end

	if not writefile then
		return false, "File functions unavailable"
	end

	local ok, err = self:EnsureFolder()
	if not ok then
		return false, err
	end

	local data = self:GetConfig()
	data.ConfigName = name

	local encodedOK, json = pcall(function()
		return HttpService:JSONEncode(data)
	end)

	if not encodedOK then
		return false, "Failed to encode config"
	end

	local writeOK, writeErr = pcall(function()
		writefile(path, json)
	end)

	if not writeOK then
		return false, tostring(writeErr)
	end

	self.CurrentConfig = name
	return true, "Saved " .. name
end

function ConfigManager:Load(name)
	name = name or self.CurrentConfig
	if name == "" then
		name = self.DefaultConfig
	end

	local path = self:GetPath(name)

	if not path or not (isfile and readfile) or not isfile(path) then
		return false, "Config not found"
	end

	local ok, contents = pcall(function()
		return readfile(path)
	end)

	if not ok then
		return false, "Failed to read config"
	end

	local decodedOK, data = pcall(function()
		return HttpService:JSONDecode(contents)
	end)

	if not decodedOK or type(data) ~= "table"
		or type(data.Toggles) ~= "table"
		or type(data.Options) ~= "table" then
		return false, "Invalid config file"
	end

	data.ConfigName = name
	return self:Apply(data)
end

function ConfigManager:Create(name)
	name = name or self.DefaultConfig

	local path = self:GetPath(name)

	if not path then
		return false, "Invalid config name"
	end

	if not (isfile and writefile) then
		return false, "File functions unavailable"
	end

	if isfile(path) then
		return false, "Config already exists"
	end

	local ok, err = self:EnsureFolder()
	if not ok then
		return false, err
	end

	local data = {
		ConfigName = name,
		Toggles = {},
		Options = {},
	}

	local success, message = pcall(function()
		writefile(path, HttpService:JSONEncode(data))
	end)

	if not success then
		return false, tostring(message)
	end

	return true, "Created " .. name
end

function ConfigManager:Delete(name)
	name = name or self.CurrentConfig

	local path = self:GetPath(name)

	if not path or not (isfile and delfile) or not isfile(path) then
		return false, "Config not found"
	end

	local ok, err = pcall(function()
		delfile(path)
	end)

	if not ok then
		return false, tostring(err)
	end

	if self.CurrentConfig == name then
		self.CurrentConfig = ""
	end

	return true, "Deleted " .. name
end

function ConfigManager:Refresh()
	if not listfiles then
		return {}
	end

	local ok, files = pcall(function()
		return listfiles(self.Folder)
	end)

	if not ok then
		return {}
	end

	local result = {}

	for _, path in ipairs(files) do
		local name = path:match("([^/\\]+)%.json$")

		if name then
			table.insert(result, name)
		end
	end

	table.sort(result)
	return result
end

return ConfigManager
