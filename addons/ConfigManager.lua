
--[[
    ConfigManager.lua
    Plain JSON config manager for the custom UI library in your pasted code.

    Supports:
      * library.Options controls exposing GetValue/SetValue (sliders, dropdowns, inputs)
      * library.Toggles after exposing the toggle table (patch below)
      * Color3, EnumItem, and multi-select dropdown values
      * Save / Load / Create / Delete / Refresh / Export / Import / Reset

    Filesystem functions (makefolder, isfolder, writefile, readfile, listfiles,
    delfile) are executor-specific. If unavailable, Export/Import still work.
]]
local HttpService = game:GetService("HttpService")

local ConfigManager = {
    Library = nil,
    Folder = "Nocturne.bz/Configs",
    DefaultConfig = "Default",
    CurrentConfig = "",
    Defaults = { Toggles = {}, Options = {} },
    Prefix = "Nocturne.bz:",
}

local function safeCall(fn, ...)
    if type(fn) ~= "function" then
        return false, "function unavailable"
    end
    return pcall(fn, ...)
end

local function cloneTable(value)
    if type(value) ~= "table" then
        return value
    end
    local out = {}
    for k, v in pairs(value) do
        out[k] = cloneTable(v)
    end
    return out
end

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
        for k, v in pairs(value) do
            result[k] = packValue(v)
        end
        return result
    end

    if type(value) == "number" or type(value) == "string"
        or type(value) == "boolean" or value == nil then
        return value
    end

    return nil
end

local function unpackValue(value)
    if type(value) ~= "table" then
        return value
    end

    if value.__type == "Color3" then
        return Color3.new(
            tonumber(value.R) or 1,
            tonumber(value.G) or 1,
            tonumber(value.B) or 1
        )
    elseif value.__type == "EnumItem" then
        local enumType = value.EnumType
        local enumName = value.Name
        if type(enumType) == "string" and type(enumName) == "string" then
            local ok, enum = pcall(function()
                return Enum[enumType][enumName]
            end)
            if ok then
                return enum
            end
        end
        return nil
    end

    local result = {}
    for k, v in pairs(value) do
        result[k] = unpackValue(v)
    end
    return result
end

local function copySerializable(source)
    local result = {}
    if type(source) ~= "table" then
        return result
    end

    for k, v in pairs(source) do
        local packed = packValue(v)
        if packed ~= nil then
            result[k] = packed
        end
    end

    return result
end

local function getControlValue(control)
    if type(control) ~= "table" then
        return nil
    end

    if type(control.GetValue) == "function" then
        local ok, value = pcall(control.GetValue, control)
        if ok then
            return value
        end
    end

    -- Dropdowns in this UI are option records; their live controller owns
    -- GetValue(), while option.Value is only a mirrored state field.
    if type(control.Controller) == "table"
        and type(control.Controller.GetValue) == "function" then
        local ok, value = pcall(control.Controller.GetValue, control.Controller)
        if ok then
            return value
        end
    end

    return control.Value
end

local function getToggleValue(toggleEntry)
    if type(toggleEntry) ~= "table" then
        return nil
    end
    -- The pasted toggle implementation stores its value lowercase.
    if toggleEntry.value ~= nil then
        return toggleEntry.value
    end
    return toggleEntry.Value
end

function ConfigManager:SetLibrary(library)
    assert(type(library) == "table", "ConfigManager:SetLibrary expects the UI library table")
    self.Library = library
    library.Options = library.Options or {}
    library.Toggles = library.Toggles or {}
    library.ToggleControls = library.ToggleControls or {}
    return self
end

function ConfigManager:SetDirectory(path)
    assert(type(path) == "string" and path ~= "", "Directory must be a non-empty string")
    self.Folder = path
    return self
end

function ConfigManager:GetPath(configName)
    configName = tostring(configName or self.DefaultConfig)
    configName = configName:gsub("[\\/:*?\"<>|]", "_")
    return self.Folder .. "/" .. configName .. ".json"
end

function ConfigManager:EnsureFolder()
    if type(makefolder) ~= "function" then
        return false, "makefolder is unavailable in this environment"
    end

    local current = ""
    for part in self.Folder:gmatch("[^/]+") do
        current = current == "" and part or (current .. "/" .. part)
        local exists = false
        if type(isfolder) == "function" then
            local ok, result = pcall(isfolder, current)
            exists = ok and result == true
        end
        if not exists then
            local ok, err = pcall(makefolder, current)
            if not ok then
                return false, err
            end
        end
    end
    return true
end

function ConfigManager:RegisterToggle(name, control, getter, setter)
    assert(type(name) == "string" and name ~= "", "Toggle name is required")
    assert(type(control) == "table", "Toggle control must be a table")
    self.Library = self.Library or {}
    self.Library.ToggleControls = self.Library.ToggleControls or {}
    self.Library.ToggleControls[name] = control
    control.__ConfigGetter = getter
    control.__ConfigSetter = setter
    return control
end

function ConfigManager:RegisterOption(name, control, getter, setter)
    assert(type(name) == "string" and name ~= "", "Option name is required")
    assert(type(control) == "table", "Option control must be a table")
    self.Library = self.Library or {}
    self.Library.Options = self.Library.Options or {}
    self.Library.Options[name] = control
    control.__ConfigGetter = getter
    control.__ConfigSetter = setter
    return control
end

function ConfigManager:CaptureDefaults()
    assert(self.Library, "Call SetLibrary() before CaptureDefaults()")
    local library = self.Library
    local defaults = { Toggles = {}, Options = {} }

    for name, toggle in pairs(library.ToggleControls or library.Toggles or {}) do
        local value = getToggleValue(toggle)
        if value ~= nil then
            defaults.Toggles[name] = packValue(value)
        end
    end

    for name, option in pairs(library.Options or {}) do
        local value
        if type(option.__ConfigGetter) == "function" then
            local ok, result = pcall(option.__ConfigGetter, option)
            if ok then value = result end
        elseif option.Color ~= nil then
            value = { Color = option.Color, Transparency = option.Transparency or 0 }
        else
            value = getControlValue(option)
        end

        local packed = packValue(value)
        if packed ~= nil then
            defaults.Options[name] = packed
        end
    end

    self.Defaults = defaults
    return cloneTable(defaults)
end

function ConfigManager:GetConfig()
    assert(self.Library, "Call SetLibrary() before GetConfig()")
    local library = self.Library
    local config = {
        Version = 1,
        Toggles = {},
        Options = {},
    }

    for name, toggle in pairs(library.ToggleControls or library.Toggles or {}) do
        local value = getToggleValue(toggle)
        if value ~= nil then
            config.Toggles[name] = packValue(value)
        end
    end

    for name, option in pairs(library.Options or {}) do
        local value
        if type(option.__ConfigGetter) == "function" then
            local ok, result = pcall(option.__ConfigGetter, option)
            if ok then value = result end
        elseif option.Color ~= nil then
            -- Color pickers in the pasted UI expose Color and Transparency.
            value = {
                Color = option.Color,
                Transparency = option.Transparency or 0,
            }
        elseif option.Key ~= nil or option.Mode ~= nil then
            -- Key pickers expose Key and Mode, plus Value for active state.
            value = {
                Key = option.Key,
                Mode = option.Mode,
                Value = option.Value,
            }
        else
            value = getControlValue(option)
        end

        local packed = packValue(value)
        if packed ~= nil then
            config.Options[name] = packed
        end
    end

    return config
end

local function applyToggle(toggleEntry, value)
    if type(toggleEntry) ~= "table" then
        return false, "toggle entry is not a table"
    end

    value = unpackValue(value)
    if type(toggleEntry.__ConfigSetter) == "function" then
        return pcall(toggleEntry.__ConfigSetter, toggleEntry, value)
    end
    if type(toggleEntry.SetValue) == "function" then
        local ok, err = pcall(toggleEntry.SetValue, toggleEntry, value)
        if ok then return true end
        return false, err
    end

    -- This library's internal toggle record is { value = boolean, keypicker = ... }.
    -- Directly changing .value alone does not update the checkbox or run its callback.
    return false, "toggle needs the SetValue patch shown in the setup notes"
end

local function applyOption(option, value)
    if type(option) ~= "table" then
        return false, "option is not a table"
    end

    value = unpackValue(value)

    if type(option.__ConfigSetter) == "function" then
        return pcall(option.__ConfigSetter, option, value)
    end

    if type(option.SetValue) == "function" then
        local ok, err = pcall(option.SetValue, option, value, true)
        if ok then return true end
        return false, err
    end

    -- Dropdowns are stored as option records and expose their live API on
    -- option.Controller, not directly on option. Apply through the controller
    -- so the visible selection and callback/state stay synchronized.
    if option.Type == "Dropdown" and type(option.Controller) == "table"
        and type(option.Controller.SetValue) == "function" then
        local ok, err = pcall(option.Controller.SetValue, option.Controller, value, true)
        if ok then return true end
        return false, err
    end

    -- The current custom ColorPicker/KeyPicker implementation does not expose
    -- a setter for its internal state, so a manager cannot safely update its UI.
    if option.Color ~= nil then
        return false, "color picker needs the SetValue patch shown in the setup notes"
    elseif option.Key ~= nil or option.Mode ~= nil then
        return false, "key picker needs the SetValue patch shown in the setup notes"
    end

    if value ~= nil then
        option.Value = value
        return true
    end

    return false, "no supported setter found"
end

function ConfigManager:Apply(config)
    assert(self.Library, "Call SetLibrary() before Apply()")
    assert(type(config) == "table", "Apply expects a config table")

    local library = self.Library
    local errors = {}

    for name, value in pairs(config.Toggles or {}) do
        local toggle = (library.ToggleControls or library.Toggles or {})[name]
        if toggle then
            local ok, err = applyToggle(toggle, value)
            if not ok then
                table.insert(errors, "Toggle '" .. tostring(name) .. "': " .. tostring(err))
            end
        end
    end

    for name, value in pairs(config.Options or {}) do
        local option = (library.Options or {})[name]
        if option then
            local ok, err = applyOption(option, value)
            if not ok then
                table.insert(errors, "Option '" .. tostring(name) .. "': " .. tostring(err))
            end
        end
    end

    if library.UpdateDependencyBoxes then
        pcall(function() library:UpdateDependencyBoxes() end)
    end

    return #errors == 0, errors
end

function ConfigManager:Export()
    local config = self:GetConfig()
    local ok, json = pcall(function()
        return HttpService:JSONEncode(config)
    end)
    if not ok then
        return nil, json
    end
    return json
end

function ConfigManager:DecodeConfig(contents)
    assert(type(contents) == "string", "DecodeConfig expects a JSON string")
    local ok, config = pcall(function()
        return HttpService:JSONDecode(contents)
    end)
    if not ok then
        return nil, config
    end
    if type(config) ~= "table" then
        return nil, "Config JSON must decode to a table"
    end
    config.Toggles = config.Toggles or {}
    config.Options = config.Options or {}
    return config
end

function ConfigManager:Import(contents)
    local config, err = self:DecodeConfig(contents)
    if not config then
        return false, err
    end
    return self:Apply(config)
end

function ConfigManager:Save(configName)
    configName = configName or self.CurrentConfig
    if configName == nil or configName == "" then
        configName = self.DefaultConfig
    end

    local okFolder, folderErr = self:EnsureFolder()
    if not okFolder then
        return false, folderErr
    end
    if type(writefile) ~= "function" then
        return false, "writefile is unavailable in this environment"
    end

    local json, exportErr = self:Export()
    if not json then
        return false, exportErr
    end

    local ok, err = pcall(writefile, self:GetPath(configName), json)
    if not ok then
        return false, err
    end

    self.CurrentConfig = configName
    return true
end

function ConfigManager:Load(configName)
    configName = configName or self.CurrentConfig
    if configName == nil or configName == "" then
        configName = self.DefaultConfig
    end
    if type(readfile) ~= "function" then
        return false, "readfile is unavailable in this environment"
    end

    local path = self:GetPath(configName)
    local ok, contents = pcall(readfile, path)
    if not ok then
        return false, contents
    end

    local success, err = self:Import(contents)
    if success then
        self.CurrentConfig = configName
    end
    return success, err
end

function ConfigManager:Create(configName)
    assert(type(configName) == "string" and configName ~= "", "Config name is required")
    local ok, err = self:Save(configName)
    if ok then
        self.CurrentConfig = configName
    end
    return ok, err
end

function ConfigManager:Delete(configName)
    assert(type(configName) == "string" and configName ~= "", "Config name is required")
    if type(delfile) ~= "function" then
        return false, "delfile is unavailable in this environment"
    end

    local path = self:GetPath(configName)
    local exists = false
    if type(isfile) == "function" then
        local ok, result = pcall(isfile, path)
        exists = ok and result == true
    end
    if not exists then
        return false, "config file does not exist"
    end

    local ok, err = pcall(delfile, path)
    if not ok then
        return false, err
    end
    if self.CurrentConfig == configName then
        self.CurrentConfig = ""
    end
    return true
end

function ConfigManager:Refresh()
    if type(listfiles) ~= "function" then
        return {}
    end

    local ok, files = pcall(listfiles, self.Folder)
    if not ok or type(files) ~= "table" then
        return {}
    end

    local configs = {}
    local prefix = self.Folder:gsub("([^%w])", "%%%1") .. "/"
    for _, file in ipairs(files) do
        local name = tostring(file):match(prefix .. "(.+)%.json$")
        if name then
            table.insert(configs, name)
        end
    end
    table.sort(configs)
    return configs
end

function ConfigManager:Reset()
    local config = cloneTable(self.Defaults)
    config.Version = 1
    config.Toggles = config.Toggles or {}
    config.Options = config.Options or {}
    return self:Apply(config)
end

return ConfigManager
