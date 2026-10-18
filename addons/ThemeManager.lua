--[[
    Nocturne.bz | ThemeManager

    Directories:
        Nocturnebz/Themes
        Nocturnebz/Assets

    Features:
        Built-in themes
        Live color updates
        All available Enum.Font entries
        Additional Roblox font-family registration
        Optional local TTF registration
        Font preview and diagnostics
        Custom theme save / load / delete
        Session-only saving without filesystem access
        Legacy theme JSON support
        Explicit GUI-root font application

    Optional files:
        Nocturnebz/Assets/Starborn.ttf
        Nocturnebz/Assets/Minecraftia.ttf

    Local font registration requires environment support.
    Font files are never downloaded by this module.

    Setup:
        ThemeManager:SetLibrary(library)
        ThemeManager:SetDirectory("Nocturnebz/Themes")
        ThemeManager:SetAssetsDirectory("Nocturnebz/Assets")
        ThemeManager:SetFontRoot(actualLibraryGui)

        ThemeManager:RegisterLocalFont("Starborn", "Starborn.ttf")
        ThemeManager:RegisterLocalFont("Minecraftia", "Minecraftia.ttf")

        ThemeManager:CreateThemeManager(settingsTab)
]]

local HttpService = game:GetService("HttpService")

local ThemeManager = {}

--==============================================================
-- STATE / CONFIGURATION
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
ThemeManager.Preview = nil

ThemeManager.Controls = {}
ThemeManager.SyncingControls = false
ThemeManager.Refreshing = false
ThemeManager.WarnedRefresh = false

local FONT_REGISTRY = {}
local FONT_NAMES = {}

-- Disk-backed themes can be evicted when refreshing.
-- Session-only themes are retained.
local DISK_THEMES = {}

local COLOR_FIELDS = {
    { Field = "AccentColor", Label = "Accent color" },
    { Field = "MainColor", Label = "Main color" },
    { Field = "SecondaryColor", Label = "Secondary color" },
    { Field = "FontColor", Label = "Font color" },
    { Field = "UIstroke", Label = "UI stroke" },
}

local REFRESH_METHODS = {
    "UpdateTheme",
    "UpdateColors",
    "UpdateColorsUsingRegistry",
    "RefreshTheme",
    "ThemeUpdate",
}

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

local function trim(value)
    return tostring(value or ""):match("^%s*(.-)%s*$")
end

local function clone(source)
    local result = {}

    for key, value in pairs(source) do
        result[key] = type(value) == "table" and clone(value) or value
    end

    return result
end

local function finite(value)
    return type(value) == "number"
        and value == value
        and value > -math.huge
        and value < math.huge
end

local function validThemeName(name)
    return type(name) == "string"
        and name == trim(name)
        and #name > 0
        and #name <= 80
        and not name:find('[%c/\\:*?"<>|]')
        and not name:find("%.%.")
        and not name:match("[%. ]$")
end

local function validFontName(name)
    return type(name) == "string"
        and name == trim(name)
        and #name > 0
        and #name <= 100
        and not name:find("%c")
end

local function validFontEnum(value)
    return typeof(value) == "EnumItem"
        and value.EnumType == Enum.Font
        and value ~= Enum.Font.Unknown
end

local function getEnumFont(name)
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

local function notify(message, isError)
    local text = "[Nocturne.bz] " .. tostring(message)
    local library = ThemeManager.Library

    if library and type(library.Notify) == "function" then
        local ok = pcall(function()
            library:Notify(text, 5, isError == true)
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

local function getEnvironmentFunction(name)
    local environments = {}

    local ok, environment = pcall(function()
        return getfenv(0)
    end)

    if ok and type(environment) == "table" then
        table.insert(environments, environment)

        local getGlobalEnvironment = environment.getgenv

        if type(getGlobalEnvironment) == "function" then
            local success, globalEnvironment = pcall(getGlobalEnvironment)

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

local function normalizeDirectory(path)
    if type(path) ~= "string" then
        return nil
    end

    path = trim(path):gsub("\\", "/"):gsub("/+", "/")
    path = path:gsub("/$", "")

    if path == ""
        or path:sub(1, 1) == "/"
        or path:find('[%c:*?"<>|]') then
        return nil
    end

    for part in path:gmatch("[^/]+") do
        if part == "." or part == ".." then
            return nil
        end
    end

    return path
end

local function isBuiltInName(name)
    for builtInName in pairs(ThemeManager.BuiltInThemes) do
        if builtInName:lower() == name:lower() then
            return true
        end
    end

    return false
end

--==============================================================
-- CONTROL HELPERS
--==============================================================

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

function ThemeManager:GetControl(name)
    local options = self.Library and self.Library.Options
    local registered = options and options["ThemeManager_" .. name]

    return registered or self.Controls[name]
end

--==============================================================
-- DIRECTORIES
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
            local checked, result = pcall(isfolderFunction, current)
            exists = checked and result == true
        end

        if not exists then
            local created, result = pcall(makefolderFunction, current)

            if not created or result == false then
                local confirmed = false

                if isfolderFunction then
                    local checked, found = pcall(isfolderFunction, current)
                    confirmed = checked and found == true
                end

                if not confirmed then
                    return false, "Could not create " .. current
                        .. ": " .. tostring(result)
                end
            end
        end
    end

    return true
end

function ThemeManager:SetDirectory(path)
    local directory = normalizeDirectory(path)
    assert(directory, "ThemeManager: invalid themes directory")

    if self.Folder ~= directory then
        self.CustomThemes = {}
        table.clear(DISK_THEMES)
    end

    self.Folder = directory
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

local function sortFontNames()
    table.sort(FONT_NAMES, function(a, b)
        if a:lower() == b:lower() then
            return a < b
        end

        return a:lower() < b:lower()
    end)
end

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

    local entry = theme.FontKey and FONT_REGISTRY[theme.FontKey]

    if entry and (
        typeof(theme.FontFace) ~= "Font"
        or sameFace(entry.Face, theme.FontFace)
    ) then
        return theme.FontKey
    end

    if typeof(theme.FontFace) == "Font" then
        for _, name in ipairs(FONT_NAMES) do
            if sameFace(FONT_REGISTRY[name].Face, theme.FontFace) then
                return name
            end
        end
    end

    return validFontEnum(theme.Font) and theme.Font.Name or "Code"
end

function ThemeManager:RefreshFontDropdown()
    local previous = self.SyncingControls
    self.SyncingControls = true

    local picker = self:GetControl("Font")

    setControlValues(picker, self:GetFontNames())

    if self.Library then
        setControlValue(picker, self:GetFontName(self.Library))
    end

    self.SyncingControls = previous
end

function ThemeManager:RegisterFont(name, face, fallback, source)
    name = trim(name)

    if not validFontName(name) then
        return false, "Invalid font name"
    end

    if typeof(face) ~= "Font" then
        return false, "RegisterFont expects a Font object"
    end

    local existing = FONT_REGISTRY[name]

    if existing and existing.Source == "Enum" then
        if sameFace(existing.Face, face) then
            return true, "Built-in font already available"
        end

        return false, "Cannot replace a built-in font name"
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

    for _, theme in pairs(self.CustomThemes) do
        if theme.FontKey == name then
            theme.Font = fallback
            theme.FontFace = face
        end
    end

    if self.Library and self.Library.FontKey == name then
        self.Library.Font = fallback
        self.Library.FontFace = face
        self:ApplyFontToRoot()
        self:UpdateFontPreview()
    end

    self:RefreshFontDropdown()

    print("[Nocturne fonts] Registered:", name, source or "Custom")

    return true, "Font registered"
end

function ThemeManager:RegisterRobloxFont(name, assetId, weight, style)
    local text = tostring(assetId)
    local id = text:match("^%d+$")
        or text:match("^rbxassetid://(%d+)$")

    if not id or not id:find("[1-9]") then
        return false, "Expected a font-family asset ID"
    end

    local ok, face = pcall(function()
        return Font.new(
            "rbxassetid://" .. id,
            weight or Enum.FontWeight.Regular,
            style or Enum.FontStyle.Normal
        )
    end)

    if not ok then
        return false, "Font construction failed: " .. tostring(face)
    end

    return self:RegisterFont(name, face, Enum.Font.Code, "Roblox")
end

function ThemeManager:RegisterLocalFont(name, filename)
    name = trim(name)

    if not validFontName(name) then
        return false, "Invalid font name"
    end

    if FONT_REGISTRY[name]
        and FONT_REGISTRY[name].Source == "Enum" then
        return false, "Choose a name other than a built-in font"
    end

    if type(filename) ~= "string"
        or filename:find('[%c/\\:*?"<>|]')
        or filename:find("%.%.")
        or not filename:lower():match("%.ttf$") then
        return false, "Expected a .ttf filename, not a path"
    end

    local isfileFunction = getEnvironmentFunction("isfile")
    local writefileFunction = getEnvironmentFunction("writefile")
    local readfileFunction = getEnvironmentFunction("readfile")

    local customAssetFunction = getEnvironmentFunction("getcustomasset")
        or getEnvironmentFunction("getsynasset")

    if not isfileFunction
        or not writefileFunction
        or not customAssetFunction then
        return false, "Local font functions unavailable"
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

    -- Optional signature check catches HTML downloads or wrong files.
    if readfileFunction then
        local readOk, contents = pcall(readfileFunction, fontPath)

        if not readOk or type(contents) ~= "string" then
            return false, "Could not read font: " .. fontPath
        end

        local signature = contents:sub(1, 4)
        local recognized = signature == "\0\1\0\0"
            or signature == "true"
            or signature == "OTTO"

        if not recognized then
            return false, "File does not have a recognized font header: "
                .. fontPath
        end
    end

    local ok, face = pcall(function()
        local ttfAsset = customAssetFunction(fontPath)

        if type(ttfAsset) ~= "string" or ttfAsset == "" then
            error("No asset URI returned for the font file")
        end

        local family = {
            name = name,
            faces = {
                {
                    name = "Regular",
                    weight = 400,
                    style = "normal",
                    assetId = ttfAsset,
                },
            },
        }

        local familyPath = fontPath .. ".font.json"

        local written = writefileFunction(
            familyPath,
            HttpService:JSONEncode(family)
        )

        if written == false then
            error("Could not write font-family JSON")
        end

        local familyAsset = customAssetFunction(familyPath)

        if type(familyAsset) ~= "string" or familyAsset == "" then
            error("No asset URI returned for font-family JSON")
        end

        print("[Nocturne fonts] File:", fontPath)
        print("[Nocturne fonts] TTF URI:", ttfAsset)
        print("[Nocturne fonts] Family URI:", familyAsset)

        return Font.new(
            familyAsset,
            Enum.FontWeight.Regular,
            Enum.FontStyle.Normal
        )
    end)

    if not ok then
        return false, "Local font construction failed: " .. tostring(face)
    end

    local registered, err = self:RegisterFont(
        name,
        face,
        Enum.Font.Code,
        "Local"
    )

    if not registered then
        return false, err
    end

    return true, "Registered; use Preview font to check rendering"
end

--==============================================================
-- FONT ROOT / APPLICATION
--==============================================================

local function applyFace(object, face)
    if not (
        object:IsA("TextLabel")
        or object:IsA("TextButton")
        or object:IsA("TextBox")
    ) then
        return false
    end

    if object:GetAttribute("NocturneKeepFont") then
        return false
    end

    local ok = pcall(function()
        if not sameFace(object.FontFace, face) then
            object.FontFace = face
        end
    end)

    return ok
end

function ThemeManager:ApplyFontToRoot()
    if not self.FontRoot
        or not self.Library
        or typeof(self.Library.FontFace) ~= "Font" then
        return 0
    end

    local root = self.FontRoot
    local face = self.Library.FontFace
    local count = 0

    if applyFace(root, face) then
        count += 1
    end

    for _, object in ipairs(root:GetDescendants()) do
        if applyFace(object, face) then
            count += 1
        end
    end

    return count
end

function ThemeManager:SetFontRoot(root)
    assert(
        root == nil
            or (
                typeof(root) == "Instance"
                and (root:IsA("ScreenGui") or root:IsA("GuiObject"))
            ),
        "ThemeManager:SetFontRoot expects a ScreenGui or GuiObject"
    )

    if self.FontConnection then
        self.FontConnection:Disconnect()
        self.FontConnection = nil
    end

    if self.Preview then
        self.Preview:Destroy()
        self.Preview = nil
    end

    self.FontRoot = root

    if not root then
        return
    end

    print("[Nocturne fonts] UI root:", root:GetFullName())

    self.FontConnection = root.DescendantAdded:Connect(function(object)
        task.defer(function()
            if self.FontRoot ~= root
                or not object:IsDescendantOf(root) then
                return
            end

            local library = self.Library

            if library and typeof(library.FontFace) == "Font" then
                applyFace(object, library.FontFace)
            end
        end)
    end)

    self:ApplyFontToRoot()
end

function ThemeManager:SetFont(name)
    local library = self.Library
    local entry = FONT_REGISTRY[name]

    if not library then
        return false, "Call SetLibrary first"
    end

    if not entry then
        return false, "Font is not registered: " .. tostring(name)
    end

    library.Font = entry.Fallback
    library.FontFace = entry.Face
    library.FontKey = name

    self.CurrentTheme = "Custom"

    self:Refresh()
    self:SyncControls()
    self:UpdateFontPreview()

    print("[Nocturne fonts] Selected:", name)
    print("[Nocturne fonts] Family:", entry.Face.Family)

    return true
end

--==============================================================
-- FONT PREVIEW / DIAGNOSTICS
--==============================================================

function ThemeManager:UpdateFontPreview()
    local preview = self.Preview
    local library = self.Library

    if not preview or not preview.Parent or not library then
        return
    end

    preview.Text = tostring(library.FontKey)
        .. "\nNocturne.bz | ABC abc 012345"

    preview.FontFace = library.FontFace
end

function ThemeManager:ShowFontPreview()
    if not self.Library then
        return false, "Call SetLibrary first"
    end

    local root = self.FontRoot

    if not root then
        return false, "No UI root connected. Call SetFontRoot first."
    end

    local screenGui = root:IsA("ScreenGui") and root
        or root:FindFirstAncestorOfClass("ScreenGui")

    if not screenGui then
        return false, "The UI root is not inside a ScreenGui"
    end

    if self.Preview then
        self.Preview:Destroy()
        self.Preview = nil
    end

    local preview = Instance.new("TextLabel")
    preview.Name = "NocturneFontPreview"
    preview:SetAttribute("NocturneKeepFont", true)

    preview.AnchorPoint = Vector2.new(0.5, 1)
    preview.Position = UDim2.new(0.5, 0, 1, -24)
    preview.Size = UDim2.new(0.85, 0, 0, 82)

    preview.BackgroundColor3 = Color3.fromRGB(19, 17, 27)
    preview.BackgroundTransparency = 0.05
    preview.BorderSizePixel = 0

    preview.TextColor3 = Color3.fromRGB(235, 220, 255)
    preview.TextSize = 20
    preview.TextWrapped = true
    preview.ZIndex = 1000

    local constraint = Instance.new("UISizeConstraint")
    constraint.MaxSize = Vector2.new(520, 82)
    constraint.Parent = preview

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = preview

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.fromRGB(125, 92, 165)
    stroke.Thickness = 1
    stroke.Parent = preview

    -- Set the face before parenting.
    preview.FontFace = self.Library.FontFace
    preview.Parent = screenGui

    self.Preview = preview
    self:UpdateFontPreview()

    task.delay(15, function()
        if self.Preview == preview then
            self.Preview = nil
        end

        preview:Destroy()
    end)

    return true
end

function ThemeManager:PrintFontDiagnostics()
    print("========== Nocturne font diagnostics ==========")
    print("[Nocturne fonts] Available:", table.concat(FONT_NAMES, ", "))

    local library = self.Library

    if not library then
        warn("[Nocturne fonts] No library connected")
        return
    end

    print("[Nocturne fonts] Selected:", library.FontKey)
    print("[Nocturne fonts] Fallback:", library.Font)
    print(
        "[Nocturne fonts] Root:",
        self.FontRoot and self.FontRoot:GetFullName() or "NOT CONNECTED"
    )

    if typeof(library.FontFace) == "Font" then
        print("[Nocturne fonts] Family:", library.FontFace.Family)
        print("[Nocturne fonts] Weight:", library.FontFace.Weight.Name)
        print("[Nocturne fonts] Style:", library.FontFace.Style.Name)
    end

    local entry = library.FontKey and FONT_REGISTRY[library.FontKey]

    print("[Nocturne fonts] Source:", entry and entry.Source or "Unknown")
    print("================================================")
end

--==============================================================
-- THEME NORMALIZATION
--==============================================================

local function normalizeTheme(theme)
    if type(theme) ~= "table" then
        return nil, "Theme data must be a table"
    end

    local result = {}
    local defaults = ThemeManager.BuiltInThemes.Default

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

    local fallback = theme.Font or defaults.Font
    local face = theme.FontFace
    local key = theme.FontKey

    if not validFontEnum(fallback) then
        return nil, "Invalid Enum.Font fallback"
    end

    if face ~= nil and typeof(face) ~= "Font" then
        return nil, "Invalid FontFace"
    end

    if key ~= nil and not validFontName(key) then
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
        key = key or fallback.Name
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
    local entry = FONT_REGISTRY[theme.FontKey]

    local result = {
        Version = 3,

        Font = {
            Type = "Enum",
            EnumType = "Enum.Font",
            Name = theme.Font.Name,
        },

        FontKey = theme.FontKey,
        FontSource = entry and entry.Source or "Custom",

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

    local theme = {}

    for _, info in ipairs(COLOR_FIELDS) do
        local value = data[info.Field]

        if value ~= nil then
            if type(value) ~= "table"
                or value.Type ~= "Color3"
                or not finite(value.R)
                or not finite(value.G)
                or not finite(value.B) then
                return nil, "Invalid saved color: " .. info.Field
            end

            theme[info.Field] = Color3.new(
                math.clamp(value.R, 0, 1),
                math.clamp(value.G, 0, 1),
                math.clamp(value.B, 0, 1)
            )
        end
    end

    if data.Font ~= nil then
        local saved = data.Font

        if type(saved) ~= "table"
            or saved.Type ~= "Enum"
            or saved.EnumType ~= "Enum.Font" then
            return nil, "Invalid saved font"
        end

        theme.Font = getEnumFont(saved.Name)

        if not theme.Font then
            return nil, "Unknown saved Enum.Font"
        end
    else
        theme.Font = Enum.Font.Code
    end

    if data.FontKey ~= nil then
        if not validFontName(data.FontKey) then
            return nil, "Invalid saved font name"
        end

        theme.FontKey = data.FontKey
    end

    local entry = theme.FontKey and FONT_REGISTRY[theme.FontKey]

    if entry then
        theme.Font = entry.Fallback
        theme.FontFace = entry.Face
    elseif data.FontFace ~= nil then
        local saved = data.FontFace

        if type(saved) ~= "table"
            or saved.Type ~= "FontFace"
            or type(saved.Family) ~= "string"
            or type(saved.Weight) ~= "string"
            or type(saved.Style) ~= "string" then
            return nil, "Invalid saved FontFace"
        end

        local persistent = saved.Family:match("^rbxassetid://%d+$")
            or saved.Family:match("^rbxasset://fonts/")

        if persistent and data.FontSource ~= "Local" then
            local ok, face = pcall(function()
                return Font.new(
                    saved.Family,
                    Enum.FontWeight[saved.Weight],
                    Enum.FontStyle[saved.Style]
                )
            end)

            if not ok then
                return nil, "Could not reconstruct saved FontFace"
            end

            theme.FontFace = face
            theme.FontKey = theme.FontKey or "Saved custom font"
        else
            -- Do not reuse stale local asset URIs.
            theme.FontFace = Font.fromEnum(theme.Font)

            warn(
                "[Nocturne fonts] Saved local font is not registered: "
                .. tostring(theme.FontKey)
                .. ". Using enum fallback."
            )
        end
    end

    return normalizeTheme(theme)
end

--==============================================================
-- LIBRARY INITIALIZATION
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

    local selected = nil

    for _, name in ipairs(FONT_NAMES) do
        if sameFace(FONT_REGISTRY[name].Face, library.FontFace) then
            selected = name
            break
        end
    end

    if not selected then
        selected = "Library custom font"

        local ok, err = self:RegisterFont(
            selected,
            library.FontFace,
            library.Font
        )

        assert(ok, tostring(err))
    end

    library.FontKey = selected
    self:ApplyFontToRoot()
end

--==============================================================
-- REFRESH / CONTROL SYNC
--==============================================================

function ThemeManager:Refresh()
    if not self.Library or self.Refreshing then
        return false
    end

    self.Refreshing = true

    local refreshed = false

    for _, name in ipairs(REFRESH_METHODS) do
        local method = self.Library[name]

        if type(method) == "function" then
            local ok, result = pcall(method, self.Library)

            if ok and result ~= false then
                refreshed = true
                break
            elseif not ok then
                warn("[ThemeManager] " .. name .. " failed:", result)
            end
        end
    end

    if not refreshed and not self.WarnedRefresh then
        self.WarnedRefresh = true

        warn(
            "[ThemeManager] No working library theme-refresh method found."
        )
    end

    -- Restore custom faces after legacy enum-font updates.
    self:ApplyFontToRoot()
    self:UpdateFontPreview()

    self.Refreshing = false
    return refreshed
end

function ThemeManager:SyncControls()
    if not self.Library then
        return
    end

    local previous = self.SyncingControls
    self.SyncingControls = true

    for _, info in ipairs(COLOR_FIELDS) do
        setControlValue(
            self:GetControl(info.Field),
            self.Library[info.Field]
        )
    end

    setControlValue(
        self:GetControl("Font"),
        self:GetFontName(self.Library)
    )

    self.SyncingControls = previous
end

--==============================================================
-- THEME LIST
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
        elseif a == "Default" then
            return true
        elseif b == "Default" then
            return false
        elseif a:lower() == b:lower() then
            return a < b
        end

        return a:lower() < b:lower()
    end)

    return names
end

function ThemeManager:RefreshThemeDropdown()
    local previous = self.SyncingControls
    self.SyncingControls = true

    local names = self:GetThemeNames()

    if not table.find(names, self.SelectedTheme) then
        self.SelectedTheme = self.DefaultTheme
    end

    local picker = self:GetControl("SelectedTheme")

    setControlValues(picker, names)
    setControlValue(picker, self.SelectedTheme)

    self.SyncingControls = previous
end

--==============================================================
-- GET / APPLY / RESET
--==============================================================

function ThemeManager:GetCurrentTheme()
    if not self.Library then
        return normalizeTheme(self.BuiltInThemes.Default)
    end

    local theme = {
        Font = self.Library.Font,
        FontFace = self.Library.FontFace,
        FontKey = self.Library.FontKey,
    }

    for _, info in ipairs(COLOR_FIELDS) do
        theme[info.Field] = self.Library[info.Field]
    end

    return normalizeTheme(theme)
end

function ThemeManager:ApplyTheme(theme)
    if not self.Library then
        return false, "Call SetLibrary first"
    end

    local data
    local name

    if type(theme) == "string" then
        name = theme
        data = self.BuiltInThemes[name]

        if not data then
            local ok, loaded = self:LoadCustomTheme(name)

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

    -- Register persistent custom faces reconstructed from JSON.
    if not FONT_REGISTRY[normalized.FontKey] then
        local family = normalized.FontFace.Family
        local persistent = family:match("^rbxassetid://%d+$")
            or family:match("^rbxasset://fonts/")

        -- Missing local fonts keep their saved key but use fallback.
        -- Do not register that fallback under the missing font's name.
        if persistent and not sameFace(
            normalized.FontFace,
            Font.fromEnum(normalized.Font)
        ) then
            local registered, registerError = self:RegisterFont(
                normalized.FontKey,
                normalized.FontFace,
                normalized.Font,
                "Saved"
            )

            if not registered then
                return false, registerError
            end
        end
    end

    for _, info in ipairs(COLOR_FIELDS) do
        self.Library[info.Field] = normalized[info.Field]
    end

    self.Library.Font = normalized.Font
    self.Library.FontFace = normalized.FontFace
    self.Library.FontKey = normalized.FontKey

    self.CurrentTheme = name or "Custom"

    if name then
        self.SelectedTheme = name
    end

    self:Refresh()
    self:RefreshFontDropdown()
    self:SyncControls()

    if name then
        self:RefreshThemeDropdown()
    end

    return true
end

function ThemeManager:Reset()
    return self:ApplyTheme(self.DefaultTheme)
end

--==============================================================
-- SAVE / LOAD / DELETE
--==============================================================

function ThemeManager:SaveCustomTheme(name, theme)
    if not validThemeName(name) then
        return false, "Enter a valid theme name"
    end

    if isBuiltInName(name) then
        return false, "Cannot overwrite a built-in theme"
    end

    if theme == nil then
        local current, err = self:GetCurrentTheme()

        if not current then
            return false, err
        end

        theme = current
    end

    local data, err = normalizeTheme(theme)

    if not data then
        return false, err
    end

    local writefileFunction = getEnvironmentFunction("writefile")

    if not writefileFunction then
        self.CustomThemes[name] = clone(data)
        DISK_THEMES[name] = nil

        return true, "Saved for this session only"
    end

    local folderOk, folderError = self:EnsureFolder()

    if not folderOk then
        return false, folderError
    end

    local encoded, json = pcall(function()
        return HttpService:JSONEncode(encodeTheme(data))
    end)

    if not encoded then
        return false, "Could not encode theme: " .. tostring(json)
    end

    local written, result = pcall(
        writefileFunction,
        self:GetPath(name),
        json
    )

    if not written or result == false then
        return false, "Could not write theme: " .. tostring(result)
    end

    self.CustomThemes[name] = clone(data)
    DISK_THEMES[name] = true

    return true, "Theme saved"
end

function ThemeManager:LoadCustomTheme(name)
    if not validThemeName(name) then
        return false, "Invalid theme name"
    end

    if self.CustomThemes[name] then
        return true, clone(self.CustomThemes[name])
    end

    local readfileFunction = getEnvironmentFunction("readfile")

    if not readfileFunction then
        return false, "Custom theme not found"
    end

    local readOk, contents = pcall(readfileFunction, self:GetPath(name))

    if not readOk or type(contents) ~= "string" then
        return false, "Could not read theme file"
    end

    local decoded, raw = pcall(function()
        return HttpService:JSONDecode(contents)
    end)

    if not decoded then
        return false, "Invalid theme JSON"
    end

    local theme, err = decodeTheme(raw)

    if not theme then
        return false, err
    end

    self.CustomThemes[name] = clone(theme)
    DISK_THEMES[name] = true

    return true, clone(theme)
end

function ThemeManager:DeleteCustomTheme(name)
    if not validThemeName(name) then
        return false, "Select a valid theme"
    end

    if isBuiltInName(name) then
        return false, "Built-in themes cannot be deleted"
    end

    local path = self:GetPath(name)
    local isfileFunction = getEnvironmentFunction("isfile")
    local delfileFunction = getEnvironmentFunction("delfile")

    local cached = self.CustomThemes[name] ~= nil
    local diskExists = nil

    if isfileFunction then
        local checked, exists = pcall(isfileFunction, path)

        if checked then
            diskExists = exists == true
        end
    end

    local mustDeleteDisk = diskExists == true or DISK_THEMES[name] == true
    local deletedDisk = false

    if mustDeleteDisk and diskExists ~= false and not delfileFunction then
        return false, "File deletion unavailable"
    end

    if diskExists ~= false and delfileFunction then
        local ok, result = pcall(delfileFunction, path)
        deletedDisk = ok and result ~= false

        if mustDeleteDisk and not deletedDisk then
            return false, "Could not delete theme file"
        end
    end

    if not cached and not deletedDisk then
        return false, "Theme not found"
    end

    self.CustomThemes[name] = nil
    DISK_THEMES[name] = nil

    if self.CurrentTheme == name then
        self:Reset()
    end

    if self.SelectedTheme == name then
        self.SelectedTheme = self.DefaultTheme
    end

    return true, "Theme deleted"
end

--==============================================================
-- SETTINGS UI
--==============================================================

function ThemeManager:CreateThemeManager(tab)
    assert(self.Library, "ThemeManager: call SetLibrary first")
    assert(tab, "ThemeManager: settings tab required")

    local library = self.Library

    local appearanceBox = tab:AddLeftGroupbox("Appearance")
    local fontsBox = tab:AddLeftGroupbox("Typography")
    local themesBox = tab:AddRightGroupbox("Theme Presets")
    local customBox = tab:AddRightGroupbox("Custom Themes")

    -- APPEARANCE

    for _, info in ipairs(COLOR_FIELDS) do
        local field = info.Field

        local picker = appearanceBox:AddLabel(
            info.Label
        ):AddColorPicker("ThemeManager_" .. field, {
            Startcolor = library[field],
            Default = library[field],
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

        self.Controls[field] = picker
    end

    -- TYPOGRAPHY
    -- The separate label remains readable in forks that ignore Text.

    fontsBox:AddLabel("Font family")

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
            elseif not self.FontRoot then
                notify(
                    "Font selected, but no UI root is connected. "
                    .. "Call SetFontRoot with your library GUI.",
                    true
                )
            end
        end,
    })

    fontsBox:AddButton("Preview font", {
        Smaller = true,

        Callback = function()
            local ok, err = self:ShowFontPreview()

            if not ok then
                notify(err, true)
            end
        end,
    })

    fontsBox:AddButton("Reapply font", {
        Smaller = true,

        Callback = function()
            if not self.FontRoot then
                notify("No UI root connected. Call SetFontRoot first.", true)
                return
            end

            local count = self:ApplyFontToRoot()

            notify(
                "Applied FontFace to " .. tostring(count) .. " text objects",
                false
            )
        end,
    })

    fontsBox:AddButton("Refresh font list", {
        Smaller = true,

        Callback = function()
            self:RefreshFontDropdown()
            notify("Font list refreshed", false)
        end,
    })

    fontsBox:AddButton("Print font diagnostics", {
        Smaller = true,

        Callback = function()
            self:PrintFontDiagnostics()
            notify("Font diagnostics printed to Output", false)
        end,
    })

    -- PRESETS

    self.Controls.SelectedTheme = themesBox:AddDropdown(
        "ThemeManager_SelectedTheme",
        {
            Text = "Select theme",
            Values = self:GetThemeNames(),
            Default = self.SelectedTheme,

            Callback = function(value)
                if not self.SyncingControls and value then
                    self.SelectedTheme = value
                end
            end,
        }
    )

    themesBox:AddButton("Apply selected theme", {
        Smaller = true,

        Callback = function()
            local name = self.SelectedTheme or self.DefaultTheme
            local ok, err = self:ApplyTheme(name)

            notify(ok and ("Applied theme " .. name) or err, not ok)
        end,
    })

    themesBox:AddButton("Reset to Default", {
        Smaller = true,
        WarnClick = true,

        Callback = function()
            local ok, err = self:Reset()

            notify(ok and "Reset to Default theme" or err, not ok)
        end,
    })

    themesBox:AddButton("Refresh theme list", {
        Smaller = true,

        Callback = function()
            for name in pairs(DISK_THEMES) do
                self.CustomThemes[name] = nil
            end

            self:RefreshThemeDropdown()
            notify("Theme list refreshed", false)
        end,
    })

    -- CUSTOM THEMES

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
            local ok, message = self:DeleteCustomTheme(self.SelectedTheme)

            if ok then
                self:RefreshThemeDropdown()
            end

            notify(message, not ok)
        end,
    })

    print("[Nocturne fonts] Available:", table.concat(FONT_NAMES, ", "))

    self:RefreshFontDropdown()
    self:SyncControls()
    self:ApplyFontToRoot()

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

    if self.Preview then
        self.Preview:Destroy()
        self.Preview = nil
    end

    self.FontRoot = nil
    self.Controls = {}
    self.Library = nil
end

return ThemeManager
