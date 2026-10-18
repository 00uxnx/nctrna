
local HttpService = game:GetService("HttpService")

local ThemeManager = {}

--==============================================================
-- CONFIGURATION
--==============================================================

ThemeManager.Library = nil

ThemeManager.Folder = "Nocturnebz/Themes"
ThemeManager.AssetsFolder = "Nocturnebz/Assets"

ThemeManager.DefaultTheme = "Default"
ThemeManager.CurrentTheme = "Default"
ThemeManager.SelectedTheme = "Default"
ThemeManager.NewThemeName = "MyTheme"

ThemeManager.CustomThemes = {}

ThemeManager.FontRoot = nil
ThemeManager.FontConnection = nil

ThemeManager.Controls = {}
ThemeManager.SyncingControls = false
ThemeManager.WarnedRefresh = false
ThemeManager.Refreshing = false

local THEME_VERSION = 2

local COLOR_FIELDS = {
	{ Field = "AccentColor", Label = "Accent color" },
	{ Field = "MainColor", Label = "Main color" },
	{ Field = "SecondaryColor", Label = "Secondary color" },
	{ Field = "FontColor", Label = "Font color" },
	{ Field = "UIstroke", Label = "UI stroke" },
}

local REFRESH_FUNCTIONS = {
	"UpdateTheme",
	"UpdateColors",
	"UpdateColorsUsingRegistry",
	"RefreshTheme",
	"ThemeUpdate",
}

local FONT_REGISTRY = {}
local FONT_NAMES = {}

--==============================================================
-- BUILT-IN THEMES
--==============================================================

ThemeManager.BuiltInThemes = {
	Default = {
		AccentColor = Color3.fromRGB(52, 66, 189),
		MainColor = Color3.fromRGB(15, 15, 15),
		SecondaryColor = Color3.fromRGB(30, 30, 30),
		FontColor = Color3.fromRGB(255, 255, 255),
		UIstroke = Color3.fromRGB(0, 0, 0),
		Font = Enum.Font.Code,
	},

	Classic = {
		AccentColor = Color3.fromRGB(103, 131, 255),
		MainColor = Color3.fromRGB(15, 15, 15),
		SecondaryColor = Color3.fromRGB(25, 25, 25),
		FontColor = Color3.fromRGB(2, 133, 255),
		UIstroke = Color3.fromRGB(0, 0, 0),
		Font = Enum.Font.Code,
	},

	Crimson = {
		AccentColor = Color3.fromRGB(255, 0, 0),
		MainColor = Color3.fromRGB(10, 10, 10),
		SecondaryColor = Color3.fromRGB(18, 18, 18),
		FontColor = Color3.fromRGB(255, 255, 255),
		UIstroke = Color3.fromRGB(0, 0, 0),
		Font = Enum.Font.RobotoCondensed,
	},

	Ubuntu = {
		AccentColor = Color3.fromRGB(226, 88, 30),
		MainColor = Color3.fromRGB(50, 50, 50),
		SecondaryColor = Color3.fromRGB(62, 62, 62),
		FontColor = Color3.fromRGB(255, 255, 255),
		UIstroke = Color3.fromRGB(0, 0, 0),
		Font = Enum.Font.Ubuntu,
	},

	BBot = {
		AccentColor = Color3.fromRGB(126, 72, 163),
		MainColor = Color3.fromRGB(35, 35, 35),
		SecondaryColor = Color3.fromRGB(30, 30, 30),
		FontColor = Color3.fromRGB(255, 255, 255),
		UIstroke = Color3.fromRGB(0, 0, 0),
		Font = Enum.Font.Code,
	},

	Nocturne = {
		AccentColor = Color3.fromRGB(195, 163, 255),
		MainColor = Color3.fromRGB(19, 17, 27),
		SecondaryColor = Color3.fromRGB(34, 29, 46),
		FontColor = Color3.fromRGB(234, 225, 249),
		UIstroke = Color3.fromRGB(70, 54, 94),
		Font = Enum.Font.Code,
	},
}

    --==============================================================
-- GENERAL HELPERS
--==============================================================

local function cloneTable(source)
	local result = {}

	for key, value in pairs(source) do
		result[key] = type(value) == "table"
			and cloneTable(value)
			or value
	end

	return result
end

local function trim(value)
	return tostring(value or ""):match("^%s*(.-)%s*$")
end

local function finiteNumber(value)
	return type(value) == "number"
		and value == value
		and value > -math.huge
		and value < math.huge
end

local function normalizeDirectory(path)
	if type(path) ~= "string" then
		return nil
	end

	path = trim(path):gsub("\\", "/"):gsub("/+", "/")
	path = path:gsub("/$", "")

	if path == "" or path:sub(1, 1) == "/" then
		return nil
	end

	if path:find("[%c:]") then
		return nil
	end

	for part in path:gmatch("[^/]+") do
		if part == "." or part == ".." then
			return nil
		end
	end

	return path
end

local function validThemeName(name)
	return type(name) == "string"
		and #name > 0
		and #name <= 80
		and name == trim(name)
		and not name:find('[%c/\\:*?"<>|]')
		and not name:find("%.%.")
		and not name:match("[%. ]$")
end

local function validFontEnum(value)
	return typeof(value) == "EnumItem"
		and value.EnumType == Enum.Font
		and value ~= Enum.Font.Unknown
end

local function getFontEnum(name)
	if type(name) ~= "string" then
		return nil
	end

	local ok, value = pcall(function()
		return Enum.Font[name]
	end)

	return ok and validFontEnum(value) and value or nil
end

local function sameFace(a, b)
	return typeof(a) == "Font"
		and typeof(b) == "Font"
		and a.Family == b.Family
		and a.Weight == b.Weight
		and a.Style == b.Style
end

local function getEnvironmentFunction(name)
	local environments = {}

	local ok, environment = pcall(function()
		return getfenv(0)
	end)

	if ok and type(environment) == "table" then
		table.insert(environments, environment)

		local getgenvFunction = environment.getgenv

		if type(getgenvFunction) == "function" then
			local success, globalEnvironment = pcall(getgenvFunction)

			if success and type(globalEnvironment) == "table" then
				table.insert(environments, 1, globalEnvironment)
			end
		end
	end

	if type(_G) == "table" then
		table.insert(environments, _G)
	end

	for _, candidate in ipairs(environments) do
		local value = candidate[name]

		if type(value) == "function" then
			return value
		end
	end

	return nil
end

local function notify(message, isError)
	local library = ThemeManager.Library
	local text = "[Nocturne.bz] " .. tostring(message)

	if library and type(library.Notify) == "function" then
		local ok = pcall(function()
			library:Notify(text, 4, isError == true)
		end)

		if ok then
			return
		end
	end

	if isError then
		warn(text)
	else
		print(text)
	end
end

local function setControlValue(control, value)
	if control and type(control.SetValue) == "function" then
		pcall(function()
			control:SetValue(value)
		end)
	end
end

local function setControlValues(control, values)
	if not control then
		return
	end

	if type(control.SetValues) == "function" then
		pcall(function()
			control:SetValues(values)
		end)
	elseif type(control.Refresh) == "function" then
		pcall(function()
			control:Refresh(values)
		end)
	end
end

local function sortFontNames()
	table.sort(FONT_NAMES, function(a, b)
		return a:lower() < b:lower()
	end)
end

--==============================================================
-- FILESYSTEM
--==============================================================

local function ensureDirectory(path)
	local makefolderFunction = getEnvironmentFunction("makefolder")
	local isfolderFunction = getEnvironmentFunction("isfolder")

	if not makefolderFunction then
		return false, "Filesystem functions unavailable"
	end

	local current = ""

	for part in path:gmatch("[^/]+") do
		current = current == "" and part or current .. "/" .. part

		local exists = false

		if isfolderFunction then
			local ok, result = pcall(isfolderFunction, current)
			exists = ok and result == true
		end

		if not exists then
			local created, err = pcall(makefolderFunction, current)

			if not created then
				local confirmed = false

				if isfolderFunction then
					local checked, result = pcall(isfolderFunction, current)
					confirmed = checked and result == true
				end

				if not confirmed then
					return false, tostring(err)
				end
			end
		end
	end

	return true
end

function ThemeManager:SetDirectory(path)
	local directory = normalizeDirectory(path)

	assert(directory, "ThemeManager: invalid themes directory")

	self.Folder = directory
	self.CustomThemes = {}
end

function ThemeManager:SetAssetsDirectory(path)
	local directory = normalizeDirectory(path)

	assert(directory, "ThemeManager: invalid assets directory")

	self.AssetsFolder = directory
end

function ThemeManager:EnsureFolder()
	return ensureDirectory(self.Folder)
end

function ThemeManager:EnsureAssetsFolder()
	return ensureDirectory(self.AssetsFolder)
end

function ThemeManager:GetPath(name)
	assert(validThemeName(name), "ThemeManager: invalid theme name")

	return self.Folder .. "/" .. name .. ".json"
end

--==============================================================
-- FONT REGISTRY
--==============================================================

-- Register every supported enum font automatically.
for _, enumFont in ipairs(Enum.Font:GetEnumItems()) do
	if validFontEnum(enumFont) then
		local ok, face = pcall(Font.fromEnum, enumFont)

		if ok then
			FONT_REGISTRY[enumFont.Name] = {
				Face = face,
				Fallback = enumFont,
				Source = "Enum",
			}

			table.insert(FONT_NAMES, enumFont.Name)
		end
	end
end

sortFontNames()

function ThemeManager:GetFontNames()
	return table.clone(FONT_NAMES)
end

function ThemeManager:GetFontName(theme)
	theme = theme or self.Library or {}

	local key = theme.FontKey

	if type(key) == "string" and FONT_REGISTRY[key] then
		if typeof(theme.FontFace) ~= "Font"
			or sameFace(FONT_REGISTRY[key].Face, theme.FontFace) then
			return key
		end
	end

	if typeof(theme.FontFace) == "Font" then
		for _, name in ipairs(FONT_NAMES) do
			if sameFace(FONT_REGISTRY[name].Face, theme.FontFace) then
				return name
			end
		end
	end

	if validFontEnum(theme.Font) then
		return theme.Font.Name
	end

	return "Code"
end

function ThemeManager:RefreshFontDropdown()
	local previous = self.SyncingControls
	self.SyncingControls = true

	setControlValues(self.Controls.Font, self:GetFontNames())

	if self.Library then
		setControlValue(
			self.Controls.Font,
			self:GetFontName(self.Library)
		)
	end

	self.SyncingControls = previous
end

function ThemeManager:RegisterFont(name, face, fallback, source)
	name = trim(name)

	if name == "" or #name > 100 or name:find("%c") then
		return false, "Enter a valid font name"
	end

	if typeof(face) ~= "Font" then
		return false, "RegisterFont expects a Font object"
	end

	local existing = FONT_REGISTRY[name]

	-- Do not silently replace built-in enum entries.
	if existing and existing.Source == "Enum" then
		if sameFace(existing.Face, face) then
			return true
		end

		return false, "That name belongs to a built-in Roblox font"
	end

	if not validFontEnum(fallback) then
		fallback = Enum.Font.Code
	end

	FONT_REGISTRY[name] = {
		Face = face,
		Fallback = fallback,
		Source = source or "Custom",
	}

	if not existing then
		table.insert(FONT_NAMES, name)
		sortFontNames()
	end

	-- Update cached themes when a local font is re-registered.
	for _, theme in pairs(self.CustomThemes) do
		if theme.FontKey == name then
			theme.FontFace = face
			theme.Font = fallback
		end
	end

	if self.Library and self.Library.FontKey == name then
		self.Library.Font = fallback
		self.Library.FontFace = face
		self:ApplyFontToRoot()
	end

	self:RefreshFontDropdown()

	return true
end

function ThemeManager:RegisterRobloxFont(name, assetId, weight, style)
	local text = tostring(assetId)
	local id = text:match("^%d+$")
		or text:match("^rbxassetid://(%d+)$")

	if not id or not id:find("[1-9]") then
		return false, "Expected a Roblox font-family asset ID"
	end

	local ok, face = pcall(function()
		return Font.new(
			"rbxassetid://" .. id,
			weight or Enum.FontWeight.Regular,
			style or Enum.FontStyle.Normal
		)
	end)

	if not ok then
		return false, "Could not construct font: " .. tostring(face)
	end

	-- Registration does not verify asset permissions or rendering.
	return self:RegisterFont(
		name,
		face,
		Enum.Font.Code,
		"Roblox"
	)
end

function ThemeManager:RegisterLocalFont(name, filename)
	name = trim(name)

	if name == "" or #name > 100 or name:find("%c") then
		return false, "Enter a valid font name"
	end

	if FONT_REGISTRY[name]
		and FONT_REGISTRY[name].Source == "Enum" then
		return false, "Choose a name that is not a built-in font"
	end

	if type(filename) ~= "string"
		or filename:find("[/\\]")
		or filename:find("%.%.")
		or filename:find("[%c:]")
		or not filename:lower():match("%.ttf$") then
		return false, "Expected a .ttf filename, not a path"
	end

	local isfileFunction = getEnvironmentFunction("isfile")
	local writefileFunction = getEnvironmentFunction("writefile")
	local customAssetFunction = getEnvironmentFunction("getcustomasset")
		or getEnvironmentFunction("getsynasset")

	if not isfileFunction
		or not writefileFunction
		or not customAssetFunction then
		return false, "Local font loading is unavailable"
	end

	local folderOk, folderError = self:EnsureAssetsFolder()

	if not folderOk then
		return false, folderError
	end

	local fontPath = self.AssetsFolder .. "/" .. filename
	local checked, exists = pcall(isfileFunction, fontPath)

	if not checked or not exists then
		return false, "Missing font file: " .. fontPath
	end

	local ok, faceOrError = pcall(function()
		local fontAsset = customAssetFunction(fontPath)

		if type(fontAsset) ~= "string" or fontAsset == "" then
			error("No local asset URI was returned for the TTF")
		end

		local family = {
			name = name,
			faces = {
				{
					name = "Regular",
					weight = 400,
					style = "normal",
					assetId = fontAsset,
				},
			},
		}

		local familyPath = fontPath .. ".font.json"

		writefileFunction(
			familyPath,
			HttpService:JSONEncode(family)
		)

		local familyAsset = customAssetFunction(familyPath)

		if type(familyAsset) ~= "string" or familyAsset == "" then
			error("No local asset URI was returned for the font family")
		end

		return Font.new(
			familyAsset,
			Enum.FontWeight.Regular,
			Enum.FontStyle.Normal
		)
	end)

	if not ok then
		return false, "Local font construction failed: "
			.. tostring(faceOrError)
	end

	-- Font.new may succeed even if the renderer cannot load the file.
	local registered, err = self:RegisterFont(
		name,
		faceOrError,
		Enum.Font.Code,
		"Local"
	)

	if not registered then
		return false, err
	end

	return true, "Registered; rendering depends on local font support"
end

--==============================================================
-- LIVE FONT APPLICATION
--==============================================================

local function applyFontToObject(object, face)
	if not (
		object:IsA("TextLabel")
			or object:IsA("TextButton")
			or object:IsA("TextBox")
		) then
		return
	end

	-- Preserve icon fonts / special labels when requested.
	if object:GetAttribute("NocturneKeepFont") then
		return
	end

	pcall(function()
		if not sameFace(object.FontFace, face) then
			object.FontFace = face
		end
	end)
end

function ThemeManager:ApplyFontToRoot()
	local root = self.FontRoot
	local library = self.Library

	if not root
		or not library
		or typeof(library.FontFace) ~= "Font" then
		return
	end

	local face = library.FontFace

	applyFontToObject(root, face)

	for _, object in ipairs(root:GetDescendants()) do
		applyFontToObject(object, face)
	end
end

function ThemeManager:SetFontRoot(root)
	assert(
		root == nil or typeof(root) == "Instance",
		"ThemeManager:SetFontRoot expects a ScreenGui or Frame"
	)

	if self.FontConnection then
		self.FontConnection:Disconnect()
		self.FontConnection = nil
	end

	self.FontRoot = root

	if not root then
		return
	end

	self.FontConnection = root.DescendantAdded:Connect(function(object)
		task.defer(function()
			if self.FontRoot ~= root
				or not object:IsDescendantOf(root) then
				return
			end

			local library = self.Library

			if library and typeof(library.FontFace) == "Font" then
				applyFontToObject(object, library.FontFace)
			end
		end)
	end)

	self:ApplyFontToRoot()
end

function ThemeManager:SetFont(name)
	if not self.Library then
		return false, "Call SetLibrary first"
	end

	local entry = FONT_REGISTRY[name]

	if not entry then
		return false, "Font is not registered: " .. tostring(name)
	end

	self.Library.Font = entry.Fallback
	self.Library.FontFace = entry.Face
	self.Library.FontKey = name

	self.CurrentTheme = "Custom"

	self:Refresh()
	self:SyncControls()

	return true
end

--==============================================================
-- THEME NORMALIZATION / VALIDATION
--==============================================================

local function normalizeTheme(theme)
	if type(theme) ~= "table" then
		return nil, "Theme data must be a table"
	end

	local defaults = ThemeManager.BuiltInThemes.Default
	local result = {}

	for _, info in ipairs(COLOR_FIELDS) do
		local value = theme[info.Field]

		if value == nil then
			value = defaults[info.Field]
		end

		if typeof(value) ~= "Color3" then
			return nil, "Invalid color: " .. info.Field
		end

		result[info.Field] = value
	end

	local fallback = theme.Font

	if fallback == nil then
		fallback = defaults.Font
	end

	if not validFontEnum(fallback) then
		return nil, "Invalid Enum.Font fallback"
	end

	local face = theme.FontFace
	local key = theme.FontKey

	if face ~= nil and typeof(face) ~= "Font" then
		return nil, "Invalid FontFace"
	end

	if key ~= nil and (
		type(key) ~= "string"
			or key == ""
			or #key > 100
			or key:find("%c")
		) then
		return nil, "Invalid font name"
	end

	local entry = key and FONT_REGISTRY[key]

	if entry then
		fallback = entry.Fallback
		face = entry.Face
	elseif face then
		key = key or "Custom font"
	else
		face = Font.fromEnum(fallback)
		key = fallback.Name
	end

	result.Font = fallback
	result.FontFace = face
	result.FontKey = key

	return result
end

--==============================================================
-- SERIALIZATION
--==============================================================

local function encodeTheme(theme)
	local result = {
		Version = THEME_VERSION,

		Font = {
			Type = "Enum",
			EnumType = "Enum.Font",
			Name = theme.Font.Name,
		},

		FontKey = theme.FontKey,

		FontFace = {
			Type = "FontFace",
			Family = theme.FontFace.Family,
			Weight = theme.FontFace.Weight.Name,
			Style = theme.FontFace.Style.Name,
		},
	}

	for _, info in ipairs(COLOR_FIELDS) do
		local color = theme[info.Field]

		result[info.Field] = {
			Type = "Color3",
			R = color.R,
			G = color.G,
			B = color.B,
		}
	end

	return result
end

local function decodeTheme(data)
	if type(data) ~= "table" then
		return nil, "Invalid theme JSON structure"
	end

	local result = {}

	for _, info in ipairs(COLOR_FIELDS) do
		local value = data[info.Field]

		if value ~= nil then
			if type(value) ~= "table"
				or value.Type ~= "Color3"
				or not finiteNumber(value.R)
				or not finiteNumber(value.G)
				or not finiteNumber(value.B) then
				return nil, "Invalid saved color: " .. info.Field
			end

			result[info.Field] = Color3.new(
				math.clamp(value.R, 0, 1),
				math.clamp(value.G, 0, 1),
				math.clamp(value.B, 0, 1)
			)
		end
	end

	if data.Font ~= nil then
		if type(data.Font) ~= "table"
			or data.Font.Type ~= "Enum"
			or data.Font.EnumType ~= "Enum.Font" then
			return nil, "Invalid saved font"
		end

		result.Font = getFontEnum(data.Font.Name)

		if not result.Font then
			return nil, "Unknown saved Enum.Font"
		end
	else
		result.Font = Enum.Font.Code
	end

	if data.FontKey ~= nil then
		if type(data.FontKey) ~= "string"
			or data.FontKey == ""
			or #data.FontKey > 100
			or data.FontKey:find("%c") then
			return nil, "Invalid saved font name"
		end

		result.FontKey = data.FontKey
	end

	local registered = result.FontKey
		and FONT_REGISTRY[result.FontKey]

	if registered then
		result.Font = registered.Fallback
		result.FontFace = registered.Face
	elseif data.FontFace ~= nil then
		local saved = data.FontFace

		if type(saved) ~= "table"
			or saved.Type ~= "FontFace"
			or type(saved.Family) ~= "string"
			or type(saved.Weight) ~= "string"
			or type(saved.Style) ~= "string" then
			return nil, "Invalid saved FontFace"
		end

		-- Reconstruct persistent Roblox families.
		-- Local font URIs must be registered again each session.
		local persistent = saved.Family:match("^rbxassetid://%d+$")
			or saved.Family:match("^rbxasset://fonts/")

		if persistent then
			local ok, face = pcall(function()
				return Font.new(
					saved.Family,
					Enum.FontWeight[saved.Weight],
					Enum.FontStyle[saved.Style]
				)
			end)

			if not ok then
				return nil, "Could not reconstruct saved font family"
			end

			result.FontFace = face
			result.FontKey = result.FontKey or "Saved custom font"
		else
			-- Preserve the key so registering the local font later
			-- can update cached themes.
			result.FontFace = Font.fromEnum(result.Font)
			result.FontKey = result.FontKey or result.Font.Name
		end
	end

	return normalizeTheme(result)
end

--==============================================================
-- INITIALIZATION
--==============================================================

function ThemeManager:SetLibrary(library)
	assert(type(library) == "table", "ThemeManager: invalid library")

	self.Library = library

	local defaults = self.BuiltInThemes[self.DefaultTheme]
		or self.BuiltInThemes.Default

	for _, info in ipairs(COLOR_FIELDS) do
		if typeof(library[info.Field]) ~= "Color3" then
			library[info.Field] = defaults[info.Field]
		end
	end

	if not validFontEnum(library.Font) then
		library.Font = defaults.Font
	end

	if typeof(library.FontFace) ~= "Font" then
		library.FontFace = Font.fromEnum(library.Font)
	end

	library.FontKey = self:GetFontName(library)

	local entry = FONT_REGISTRY[library.FontKey]

	if not entry or not sameFace(entry.Face, library.FontFace) then
		local name = "Library custom font"
		local registered = self:RegisterFont(
			name,
			library.FontFace,
			library.Font
		)

		if registered then
			library.FontKey = name
		end
	end

	self:ApplyFontToRoot()
end

--==============================================================
-- LIBRARY REFRESH
--==============================================================

function ThemeManager:Refresh()
	local library = self.Library

	if not library then
		return false
	end

	if self.Refreshing then
		return false
	end

	self.Refreshing = true

	local refreshed = false

	for _, methodName in ipairs(REFRESH_FUNCTIONS) do
		if type(library[methodName]) == "function" then
			local ok, result = pcall(function()
				return library[methodName](library)
			end)

			if ok and result ~= false then
				refreshed = true
				break
			end

			if not ok then
				warn("[ThemeManager] " .. methodName .. " failed:", result)
			end
		end
	end

	if not refreshed and not self.WarnedRefresh then
		self.WarnedRefresh = true

		warn(
			"[ThemeManager] No working theme refresh method found. "
				.. "Check your library's refresh API."
		)
	end

	-- Apply FontFace after legacy library refresh methods.
	self:ApplyFontToRoot()

	self.Refreshing = false
	return refreshed
end

--==============================================================
-- THEME / FONT CONTROL SYNCHRONIZATION
--==============================================================

function ThemeManager:GetControl(key)
	local control = self.Controls[key]

	if control then
		return control
	end

	local options = self.Library and self.Library.Options

	if options then
		return options["ThemeManager_" .. key]
	end

	return nil
end

function ThemeManager:SyncControls()
	local library = self.Library

	if not library then
		return
	end

	local previous = self.SyncingControls
	self.SyncingControls = true

	for _, info in ipairs(COLOR_FIELDS) do
		setControlValue(
			self:GetControl(info.Field),
			library[info.Field]
		)
	end

	setControlValue(
		self:GetControl("Font"),
		self:GetFontName(library)
	)

	self.SyncingControls = previous
end

function ThemeManager:RefreshThemeDropdown()
	local previous = self.SyncingControls
	self.SyncingControls = true

	local names = self:GetThemeNames()

	if not table.find(names, self.SelectedTheme) then
		self.SelectedTheme = self.DefaultTheme
	end

	setControlValues(self.Controls.SelectedTheme, names)
	setControlValue(self.Controls.SelectedTheme, self.SelectedTheme)

	self.SyncingControls = previous
end

--==============================================================
-- THEME NAMES
--==============================================================

function ThemeManager:GetThemeNames()
	local names = {}
	local seen = {}

	local function add(name)
		if validThemeName(name) and not seen[name] then
			seen[name] = true
			table.insert(names, name)
		end
	end

	for name in pairs(self.BuiltInThemes) do
		add(name)
	end

	for name in pairs(self.CustomThemes) do
		add(name)
	end

	local listfilesFunction = getEnvironmentFunction("listfiles")

	if listfilesFunction then
		local ok, files = pcall(listfilesFunction, self.Folder)

		if ok and type(files) == "table" then
			for _, path in ipairs(files) do
				local normalized = tostring(path):gsub("\\", "/")
				local filename = normalized:match("([^/]+)$")
				local name = filename and filename:match("^(.-)%.json$")

				if name then
					add(name)
				end
			end
		end
	end

	table.sort(names, function(a, b)
		if a == b then
			return false
		end

		if a == "Default" then
			return true
		elseif b == "Default" then
			return false
		end

		if a:lower() == b:lower() then
			return a < b
		end

		return a:lower() < b:lower()
	end)

	return names
end

--==============================================================
-- GET / APPLY / RESET
--==============================================================

function ThemeManager:GetCurrentTheme()
	local library = self.Library

	if not library then
		return normalizeTheme(self.BuiltInThemes.Default)
	end

	local theme = {
		Font = library.Font,
		FontFace = library.FontFace,
		FontKey = library.FontKey,
	}

	for _, info in ipairs(COLOR_FIELDS) do
		theme[info.Field] = library[info.Field]
	end

	return normalizeTheme(theme)
end

function ThemeManager:ApplyTheme(theme)
	if not self.Library then
		return false, "Call SetLibrary first"
	end

	local data
	local themeName

	if type(theme) == "string" then
		themeName = theme
		data = self.BuiltInThemes[theme]

		if not data then
			local ok, loaded = self:LoadCustomTheme(theme)

			if not ok then
				return false, loaded
			end

			data = loaded
		end
	elseif type(theme) == "table" then
		data = theme
	else
		return false, "Expected a theme name or table"
	end

	local normalized, err = normalizeTheme(data)

	if not normalized then
		return false, err
	end

	local key = normalized.FontKey

	if not FONT_REGISTRY[key] then
		local registered, registerError = self:RegisterFont(
			key,
			normalized.FontFace,
			normalized.Font
		)

		if not registered then
			return false, registerError
		end
	end

	for _, info in ipairs(COLOR_FIELDS) do
		self.Library[info.Field] = normalized[info.Field]
	end

	self.Library.Font = normalized.Font
	self.Library.FontFace = normalized.FontFace
	self.Library.FontKey = normalized.FontKey

	self.CurrentTheme = themeName or "Custom"

	if themeName then
		self.SelectedTheme = themeName
	end

	self:Refresh()
	self:SyncControls()

	if themeName then
		local previous = self.SyncingControls
		self.SyncingControls = true

		setControlValue(self.Controls.SelectedTheme, themeName)

		self.SyncingControls = previous
	end

	return true
end

function ThemeManager:Reset()
	return self:ApplyTheme(self.DefaultTheme)
end

--==============================================================
-- SAVE CUSTOM THEME
--==============================================================

function ThemeManager:SaveCustomTheme(name, theme)
	if not validThemeName(name) then
		return false, "Enter a valid theme name"
	end

	-- Avoid case-insensitive filesystem collisions with built-ins.
	for builtInName in pairs(self.BuiltInThemes) do
		if builtInName:lower() == name:lower() then
			return false, "Cannot overwrite a built-in theme"
		end
	end

	if theme == nil then
		local current, currentError = self:GetCurrentTheme()

		if not current then
			return false, currentError
		end

		theme = current
	end

	local data, err = normalizeTheme(theme)

	if not data then
		return false, err
	end

	local writefileFunction = getEnvironmentFunction("writefile")

	if not writefileFunction then
		self.CustomThemes[name] = cloneTable(data)

		return true, "Saved for this session only; filesystem unavailable"
	end

	local folderOk, folderError = self:EnsureFolder()

	if not folderOk then
		return false, "Could not create theme directory: "
			.. tostring(folderError)
	end

	local encoded, json = pcall(function()
		return HttpService:JSONEncode(encodeTheme(data))
	end)

	if not encoded then
		return false, "Could not encode theme: " .. tostring(json)
	end

	local saved, writeError = pcall(
		writefileFunction,
		self:GetPath(name),
		json
	)

	if not saved then
		return false, "Could not write theme: " .. tostring(writeError)
	end

	self.CustomThemes[name] = cloneTable(data)

	return true, "Theme saved"
end

--==============================================================
-- LOAD CUSTOM THEME
--==============================================================

function ThemeManager:LoadCustomTheme(name)
	if not validThemeName(name) then
		return false, "Invalid theme name"
	end

	if self.CustomThemes[name] then
		return true, cloneTable(self.CustomThemes[name])
	end

	local readfileFunction = getEnvironmentFunction("readfile")

	if not readfileFunction then
		return false, "Custom theme not found"
	end

	local readOk, contents = pcall(
		readfileFunction,
		self:GetPath(name)
	)

	if not readOk or type(contents) ~= "string" then
		return false, "Could not read theme file"
	end

	local decoded, rawData = pcall(function()
		return HttpService:JSONDecode(contents)
	end)

	if not decoded then
		return false, "Invalid theme JSON"
	end

	local data, err = decodeTheme(rawData)

	if not data then
		return false, err
	end

	self.CustomThemes[name] = cloneTable(data)

	return true, cloneTable(data)
end

--==============================================================
-- DELETE CUSTOM THEME
--==============================================================

function ThemeManager:DeleteCustomTheme(name)
	if not validThemeName(name) then
		return false, "Select a valid theme"
	end

	for builtInName in pairs(self.BuiltInThemes) do
		if builtInName:lower() == name:lower() then
			return false, "Built-in themes cannot be deleted"
		end
	end

	local path = self:GetPath(name)
	local isfileFunction = getEnvironmentFunction("isfile")
	local delfileFunction = getEnvironmentFunction("delfile")

	local cached = self.CustomThemes[name] ~= nil
	local diskExists = nil

	if isfileFunction then
		local ok, result = pcall(isfileFunction, path)

		if ok then
			diskExists = result == true
		end
	end

	local diskDeleted = false

	if diskExists ~= false and delfileFunction then
		local ok, result = pcall(delfileFunction, path)
		diskDeleted = ok and result ~= false

		if not diskDeleted and diskExists == true then
			return false, "Could not delete theme file"
		end
	elseif diskExists == true then
		return false, "File deletion is unavailable"
	end

	if not cached and not diskDeleted then
		return false, "Theme not found or could not be deleted"
	end

	self.CustomThemes[name] = nil

	if self.CurrentTheme == name then
		self:Reset()
	end

	if self.SelectedTheme == name then
		self.SelectedTheme = self.DefaultTheme
	end

	return true, "Theme deleted"
end

--==============================================================
-- THEME SETTINGS UI
--==============================================================

function ThemeManager:CreateThemeManager(tab)
	assert(self.Library, "ThemeManager: call SetLibrary first")
	assert(tab, "ThemeManager: settings tab is required")

	local library = self.Library

	local appearanceBox = tab:AddLeftGroupbox("Appearance")
	local fontsBox = tab:AddLeftGroupbox("Typography")

	local themesBox = tab:AddRightGroupbox("Theme Presets")
	local customBox = tab:AddRightGroupbox("Custom Themes")

	-- COLOR PICKERS

	for _, info in ipairs(COLOR_FIELDS) do
		local field = info.Field
		local initialColor = library[field]

		local picker = appearanceBox:AddLabel(
			info.Label
		):AddColorPicker("ThemeManager_" .. field, {
			Startcolor = initialColor,
			Default = initialColor,
			Transparency = 0,

			Callback = function(color)
				if self.SyncingControls
					or typeof(color) ~= "Color3" then
					return
				end

				library[field] = color
				self.CurrentTheme = "Custom"
				self:Refresh()
			end,
		})

		-- Some forks return the label instead of the actual picker.
		local options = library.Options
		local registeredPicker = options
			and options["ThemeManager_" .. field]

		if registeredPicker
			and type(registeredPicker.SetValue) == "function" then
			self.Controls[field] = registeredPicker
		elseif picker and type(picker.SetValue) == "function" then
			self.Controls[field] = picker
		end
	end

	-- FONT PICKER

	self.Controls.Font = fontsBox:AddDropdown("ThemeManager_Font", {
		Text = "Font family",
		Values = self:GetFontNames(),
		Default = self:GetFontName(library),

		Callback = function(value)
			if self.SyncingControls or not value then
				return
			end

			local ok, err = self:SetFont(value)

			if not ok then
				notify(err, true)
			end
		end,
	})

	fontsBox:AddButton("Reapply font", {
		Smaller = true,

		Callback = function()
			self:ApplyFontToRoot()

			if self.FontRoot then
				notify("Font reapplied", false)
			else
				notify("Call SetFontRoot with your library UI first", true)
			end
		end,
	})

	fontsBox:AddButton("Refresh font list", {
		Smaller = true,

		Callback = function()
			self:RefreshFontDropdown()
			notify("Font list refreshed", false)
		end,
	})

	-- THEME SELECTOR

	self.Controls.SelectedTheme = themesBox:AddDropdown(
		"ThemeManager_SelectedTheme",
		{
			Text = "Select theme",
			Values = self:GetThemeNames(),
			Default = self.SelectedTheme,

			Callback = function(value)
				if self.SyncingControls or not value then
					return
				end

				self.SelectedTheme = value
			end,
		}
	)

	themesBox:AddButton("Apply selected theme", {
		Smaller = true,

		Callback = function()
			local name = self.SelectedTheme or self.DefaultTheme
			local ok, err = self:ApplyTheme(name)

			if ok then
				notify("Applied theme " .. name, false)
			else
				notify(err, true)
			end
		end,
	})

	themesBox:AddButton("Reset to Default", {
		Smaller = true,
		WarnClick = true,

		Callback = function()
			local ok, err = self:Reset()

			if ok then
				self:RefreshThemeDropdown()
				notify("Reset to Default theme", false)
			else
				notify(err, true)
			end
		end,
	})

	themesBox:AddButton("Refresh theme list", {
		Smaller = true,

		Callback = function()
			-- Clear disk-backed cache so later loads can read edits.
			-- Keep session-only themes when no filesystem reader exists.
			if getEnvironmentFunction("readfile") then
				local isfileFunction = getEnvironmentFunction("isfile")

				if isfileFunction then
					for name in pairs(self.CustomThemes) do
						local ok, exists = pcall(
							isfileFunction,
							self:GetPath(name)
						)

						if ok and exists then
							self.CustomThemes[name] = nil
						end
					end
				end
			end

			self:RefreshThemeDropdown()
			notify("Theme list refreshed", false)
		end,
	})

	-- CUSTOM THEME MANAGEMENT

	customBox:AddInput("ThemeManager_NewThemeName", {
		Text = "Theme name",
		Default = self.NewThemeName,
		Placeholder = "Enter custom theme name",

		Callback = function(value)
			self.NewThemeName = tostring(value or "")
		end,
	})

	customBox:AddButton("Save current theme", {
		Smaller = true,

		Callback = function()
			local name = trim(self.NewThemeName)
			local ok, message = self:SaveCustomTheme(name)

			if ok then
				self.NewThemeName = name
				self.SelectedTheme = name
				self.CurrentTheme = name
				self:RefreshThemeDropdown()
			end

			notify(message, not ok)
		end,
	})

	customBox:AddButton("Delete selected theme", {
		Smaller = true,
		WarnClick = true,

		Callback = function()
			local ok, message = self:DeleteCustomTheme(
				self.SelectedTheme
			)

			if ok then
				self:RefreshThemeDropdown()
			end

			notify(message, not ok)
		end,
	})

	self:SyncControls()
	self:ApplyFontToRoot()

	-- Preserve the original first return value.
	return appearanceBox, fontsBox, themesBox, customBox
end

--==============================================================
-- CLEANUP
--==============================================================

function ThemeManager:Destroy()
	if self.FontConnection then
		self.FontConnection:Disconnect()
		self.FontConnection = nil
	end

	self.FontRoot = nil
	self.Controls = {}
	self.Library = nil
end

return ThemeManager
