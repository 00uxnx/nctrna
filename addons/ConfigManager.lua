local HttpService = game:GetService("HttpService")

local ConfigManager = {
    Library = nil,

    Folder = "Nocturne.bz/Configs",
    DefaultConfig = "Default",
    CurrentConfig = "",

    Defaults = {
        Toggles = {},
        Options = {},
    },

    Prefix = "Nocturne.bz:",

    Ignored = {},
    UI = nil,
}

--==============================================================
-- HELPERS
--==============================================================

local function trim(value)
    return tostring(value or ""):match("^%s*(.-)%s*$")
end

local function cloneTable(value)
    if type(value) ~= "table" then
        return value
    end

    local result = {}

    for key, item in pairs(value) do
        result[key] = cloneTable(item)
    end

    return result
end

local function errorText(value)
    if type(value) ~= "table" then
        return tostring(value or "Unknown error")
    end

    local messages = {}

    for _, message in ipairs(value) do
        table.insert(messages, tostring(message))
    end

    return #messages > 0
        and table.concat(messages, "\n")
        or "Unknown error"
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
    end

    if kind == "EnumItem" then
        return {
            __type = "EnumItem",
            EnumType = tostring(value.EnumType):gsub("^Enum%.", ""),
            Name = value.Name,
        }
    end

    if kind == "table" then
        local result = {}

        for key, item in pairs(value) do
            local packed = packValue(item)

            if packed ~= nil then
                result[key] = packed
            end
        end

        return result
    end

    if kind == "number" then
        if value ~= value or value == math.huge or value == -math.huge then
            return nil
        end

        return value
    end

    if kind == "string" or kind == "boolean" then
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
    end

    if value.__type == "EnumItem" then
        local ok, result = pcall(function()
            return Enum[value.EnumType][value.Name]
        end)

        return ok and result or nil
    end

    local result = {}

    for key, item in pairs(value) do
        result[key] = unpackValue(item)
    end

    return result
end

local function controllerOf(control)
    if type(control) ~= "table" then
        return nil
    end

    if type(control.Controller) == "table" then
        return control.Controller
    end

    return control
end

local function getControlValue(control)
    if type(control) ~= "table" then
        return nil
    end

    if type(control.__ConfigGetter) == "function" then
        local ok, value = pcall(control.__ConfigGetter, control)

        if ok then
            return value
        end
    end

    if type(control.GetValue) == "function" then
        local ok, value = pcall(control.GetValue, control)

        if ok then
            return value
        end
    end

    local controller = controllerOf(control)

    if controller ~= control
        and type(controller.GetValue) == "function" then

        local ok, value = pcall(controller.GetValue, controller)

        if ok then
            return value
        end
    end

    if control.value ~= nil then
        return control.value
    end

    return control.Value
end

local function getOptionValue(option)
    if type(option) ~= "table" then
        return nil
    end

    if type(option.__ConfigGetter) == "function" then
        return getControlValue(option)
    end

    if option.Color ~= nil then
        return {
            Color = option.Color,
            Transparency = option.Transparency or 0,
        }
    end

    if option.Key ~= nil or option.Mode ~= nil then
        return {
            Key = option.Key,
            Mode = option.Mode,
            Value = option.Value,
        }
    end

    return getControlValue(option)
end

local function collectToggles(library)
    local result = {}

    for name, toggle in pairs(library.Toggles or {}) do
        result[name] = toggle
    end

    for name, toggle in pairs(library.ToggleControls or {}) do
        result[name] = toggle
    end

    return result
end

local function applyControl(control, packedValue)
    if type(control) ~= "table" then
        return false, "Control is not a table"
    end

    local value = unpackValue(packedValue)

    if type(control.__ConfigSetter) == "function" then
        return pcall(control.__ConfigSetter, control, value)
    end

    -- Prefer the live controller for records that expose one.
    local controller = controllerOf(control)

    if controller ~= control
        and type(controller.SetValue) == "function" then

        return pcall(controller.SetValue, controller, value)
    end

    if type(control.SetValue) == "function" then
        return pcall(control.SetValue, control, value)
    end

    return false, "Control has no SetValue or registered config setter"
end

--==============================================================
-- SETUP
--==============================================================

function ConfigManager:SetLibrary(library)
    assert(
        type(library) == "table",
        "ConfigManager:SetLibrary expects a library table"
    )

    self.Library = library

    library.Options = library.Options or {}
    library.Toggles = library.Toggles or {}
    library.ToggleControls = library.ToggleControls or {}

    return self
end

function ConfigManager:SetDirectory(path)
    assert(
        type(path) == "string" and trim(path) ~= "",
        "Config directory must be a non-empty string"
    )

    self.Folder = path:gsub("\\", "/"):gsub("/+$", "")

    return self
end

function ConfigManager:Ignore(name)
    self.Ignored[name] = true
    return self
end

function ConfigManager:NormalizeName(name)
    name = trim(name)

    if name == "" then
        return nil, "Enter a config name first"
    end

    name = name:gsub("[\\/:*?\"<>|%c]", "_")
    name = name:gsub("[%. ]+$", "")

    if name == "" then
        return nil, "Invalid config name"
    end

    return name
end

function ConfigManager:GetPath(name)
    local normalized, err = self:NormalizeName(
        name or self.DefaultConfig
    )

    assert(normalized, err)

    return self.Folder .. "/" .. normalized .. ".json"
end

function ConfigManager:EnsureFolder()
    local current = ""

    for part in self.Folder:gmatch("[^/]+") do
        current = current == ""
            and part
            or current .. "/" .. part

        local exists = false

        if type(isfolder) == "function" then
            local ok, result = pcall(isfolder, current)
            exists = ok and result == true
        end

        if not exists then
            if type(makefolder) ~= "function" then
                return false, "makefolder is unavailable"
            end

            local ok, err = pcall(makefolder, current)

            if not ok then
                return false, tostring(err)
            end
        end
    end

    return true
end

function ConfigManager:RegisterToggle(name, control, getter, setter)
    assert(self.Library, "Call SetLibrary first")
    assert(type(control) == "table", "Toggle must be a table")

    self.Library.ToggleControls[name] = control

    control.__ConfigGetter = getter
    control.__ConfigSetter = setter

    return control
end

function ConfigManager:RegisterOption(name, control, getter, setter)
    assert(self.Library, "Call SetLibrary first")
    assert(type(control) == "table", "Option must be a table")

    self.Library.Options[name] = control

    control.__ConfigGetter = getter
    control.__ConfigSetter = setter

    return control
end

--==============================================================
-- SERIALIZATION
--==============================================================

function ConfigManager:GetConfig()
    assert(self.Library, "Call SetLibrary first")

    local config = {
        Version = 1,
        Toggles = {},
        Options = {},
    }

    for name, toggle in pairs(collectToggles(self.Library)) do
        if not self.Ignored[name] then
            local packed = packValue(getControlValue(toggle))

            if packed ~= nil then
                config.Toggles[name] = packed
            end
        end
    end

    for name, option in pairs(self.Library.Options) do
        if not self.Ignored[name] then
            local packed = packValue(getOptionValue(option))

            if packed ~= nil then
                config.Options[name] = packed
            end
        end
    end

    return config
end

function ConfigManager:CaptureDefaults()
    local config = self:GetConfig()

    self.Defaults = {
        Toggles = cloneTable(config.Toggles),
        Options = cloneTable(config.Options),
    }

    return cloneTable(self.Defaults)
end

function ConfigManager:Apply(config)
    assert(self.Library, "Call SetLibrary first")

    if type(config) ~= "table" then
        return false, "Config must be a table"
    end

    if type(config.Toggles or {}) ~= "table"
        or type(config.Options or {}) ~= "table" then

        return false, "Invalid Toggles or Options data"
    end

    local errors = {}
    local toggles = collectToggles(self.Library)

    local function applyEntries(entries, controls, kind)
        for name, value in pairs(entries or {}) do
            if not self.Ignored[name] and controls[name] then
                local ok, err = applyControl(controls[name], value)

                if not ok then
                    table.insert(
                        errors,
                        kind .. " '" .. tostring(name) .. "': " .. tostring(err)
                    )
                end
            end
        end
    end

    applyEntries(config.Toggles, toggles, "Toggle")
    applyEntries(config.Options, self.Library.Options, "Option")

    if type(self.Library.UpdateDependencyBoxes) == "function" then
        local ok, err = pcall(
            self.Library.UpdateDependencyBoxes,
            self.Library
        )

        if not ok then
            table.insert(errors, "Dependency update: " .. tostring(err))
        end
    end

    if #errors > 0 then
        return false, table.concat(errors, "\n")
    end

    return true
end

function ConfigManager:DecodeConfig(contents)
    if type(contents) ~= "string" then
        return nil, "Config must be a JSON string"
    end

    contents = trim(contents)

    -- Accept old prefixed strings as well as plain JSON.
    if contents:sub(1, #self.Prefix) == self.Prefix then
        contents = contents:sub(#self.Prefix + 1)
    end

    local ok, config = pcall(
        HttpService.JSONDecode,
        HttpService,
        contents
    )

    if not ok then
        return nil, tostring(config)
    end

    if type(config) ~= "table" then
        return nil, "Config JSON must decode to a table"
    end

    if config.Toggles ~= nil and type(config.Toggles) ~= "table" then
        return nil, "Invalid Toggles data"
    end

    if config.Options ~= nil and type(config.Options) ~= "table" then
        return nil, "Invalid Options data"
    end

    config.Toggles = config.Toggles or {}
    config.Options = config.Options or {}

    return config
end

function ConfigManager:EncodeConfig(config)
    local ok, json = pcall(
        HttpService.JSONEncode,
        HttpService,
        config
    )

    if not ok then
        return nil, tostring(json)
    end

    return json
end

function ConfigManager:Import(contents)
    local config, err = self:DecodeConfig(contents)

    if not config then
        return false, err
    end

    return self:Apply(config)
end

--==============================================================
-- FILE OPERATIONS
--==============================================================

function ConfigManager:ResolveName(name)
    if name == nil or trim(name) == "" then
        name = self.CurrentConfig ~= ""
            and self.CurrentConfig
            or self.DefaultConfig
    end

    return self:NormalizeName(name)
end

function ConfigManager:ReadConfig(name)
    local normalized, nameError = self:ResolveName(name)

    if not normalized then
        return nil, nameError
    end

    if type(readfile) ~= "function" then
        return nil, "readfile is unavailable"
    end

    local ok, contents = pcall(
        readfile,
        self:GetPath(normalized)
    )

    if not ok then
        return nil, tostring(contents)
    end

    return self:DecodeConfig(contents)
end

function ConfigManager:Export(name)
    local config
    local err

    if name ~= nil and trim(name) ~= "" then
        config, err = self:ReadConfig(name)

        if not config then
            return nil, err
        end
    else
        config = self:GetConfig()
    end

    return self:EncodeConfig(config)
end

function ConfigManager:Save(name)
    local normalized, nameError = self:ResolveName(name)

    if not normalized then
        return false, nameError
    end

    if type(writefile) ~= "function" then
        return false, "writefile is unavailable"
    end

    local folderOK, folderError = self:EnsureFolder()

    if not folderOK then
        return false, folderError
    end

    -- Always save current UI state, not a previously saved file.
    local json, encodeError = self:EncodeConfig(self:GetConfig())

    if not json then
        return false, encodeError
    end

    local ok, err = pcall(
        writefile,
        self:GetPath(normalized),
        json
    )

    if not ok then
        return false, tostring(err)
    end

    self.CurrentConfig = normalized

    return true, "Saved config: " .. normalized
end

function ConfigManager:Create(name)
    local normalized, nameError = self:NormalizeName(name)

    if not normalized then
        return false, nameError
    end

    if type(isfile) == "function" then
        local ok, exists = pcall(isfile, self:GetPath(normalized))

        if ok and exists then
            return false, "Config already exists; use Save config"
        end
    end

    return self:Save(normalized)
end

function ConfigManager:Load(name)
    local normalized, nameError = self:ResolveName(name)

    if not normalized then
        return false, nameError
    end

    local config, err = self:ReadConfig(normalized)

    if not config then
        return false, err
    end

    local success, applyError = self:Apply(config)

    if not success then
        return false, applyError
    end

    self.CurrentConfig = normalized

    return true, "Loaded config: " .. normalized
end

function ConfigManager:Delete(name)
    local normalized, nameError = self:NormalizeName(name)

    if not normalized then
        return false, nameError
    end

    if type(delfile) ~= "function" then
        return false, "delfile is unavailable"
    end

    local path = self:GetPath(normalized)

    if type(isfile) == "function" then
        local ok, exists = pcall(isfile, path)

        if not ok then
            return false, tostring(exists)
        end

        if not exists then
            return false, "Config file does not exist"
        end
    end

    local ok, err = pcall(delfile, path)

    if not ok then
        return false, tostring(err)
    end

    if self.CurrentConfig == normalized then
        self.CurrentConfig = ""
    end

    return true, "Deleted config: " .. normalized
end

function ConfigManager:Refresh()
    if type(listfiles) ~= "function" then
        return {}, "listfiles is unavailable"
    end

    if type(isfolder) == "function" then
        local ok, exists = pcall(isfolder, self.Folder)

        if ok and not exists then
            return {}
        end
    end

    local ok, files = pcall(listfiles, self.Folder)

    if not ok then
        return {}, tostring(files)
    end

    if type(files) ~= "table" then
        return {}, "listfiles returned an invalid result"
    end

    local names = {}
    local seen = {}

    for _, file in ipairs(files) do
        local path = tostring(file):gsub("\\", "/")
        local filename = path:match("([^/]+)$")
        local name = filename and filename:match("^(.-)%.[jJ][sS][oO][nN]$")

        if name and name ~= "" and not seen[name] then
            seen[name] = true
            table.insert(names, name)
        end
    end

    table.sort(names, function(a, b)
        return a:lower() < b:lower()
    end)

    return names
end

function ConfigManager:Reset()
    return self:Apply(cloneTable(self.Defaults))
end

--==============================================================
-- MANAGER-OWNED UI
--==============================================================

function ConfigManager:init(tab, settings)
    assert(self.Library, "Call SetLibrary before init")
    assert(
        tab and type(tab.AddLeftGroupbox) == "function"
            and type(tab.AddRightGroupbox) == "function",
        "ConfigManager:init expects a tab object"
    )

    settings = settings or {}

    if self.UI then
        assert(
            self.UI.Tab == tab,
            "ConfigManager UI is already initialized on another tab"
        )

        self.UI.Refresh()
        return self.UI
    end

    local manager = self
    local EMPTY = "(no saved configs)"

    local ids = {
        Name = "__Nocturne_ConfigName",
        List = "__Nocturne_ConfigList",
        Paste = "__Nocturne_ConfigPaste",
    }

    -- Exclude both new IDs and IDs used by the old loader.
    for _, id in pairs(ids) do
        self:Ignore(id)
    end

    self:Ignore("Config name")
    self:Ignore("Config list")
    self:Ignore("Paste config")

    local ui = {
        Tab = tab,
        Name = self.DefaultConfig,
        Selected = nil,
        Pasted = "",
        Names = {},
        Updating = false,
    }

    local function notify(success, message)
        message = errorText(message or (
            success and "Done" or "Operation failed"
        ))

        if type(settings.Notify) == "function" then
            local ok = pcall(settings.Notify, success, message)

            if ok then
                return
            end
        end

        if success then
            print("[ConfigManager] " .. message)
        else
            warn("[ConfigManager] " .. message)
        end
    end

    local function invoke(method, ...)
        local ok, result, message = pcall(
            manager[method],
            manager,
            ...
        )

        if not ok then
            return false, tostring(result)
        end

        return result, message
    end

    local function afterApply()
        if type(settings.AfterApply) ~= "function" then
            return
        end

        local ok, err = pcall(settings.AfterApply)

        if not ok then
            notify(false, "UI sync failed: " .. tostring(err))
        end
    end

    local function selectedName()
        if ui.Selected and table.find(ui.Names, ui.Selected) then
            return ui.Selected
        end

        return nil
    end

    local function saveName()
        return selectedName() or trim(ui.Name)
    end

    local function dropdownController()
        local record = manager.Library.Options[ids.List]
        local candidates = {
            record,
            ui.Dropdown,
        }

        -- Avoid ipairs stopping at a nil first entry.
        for index = 1, 2 do
            local candidate = candidates[index]
            local controller = controllerOf(candidate)

            if controller and (
                type(controller.SetValues) == "function"
                or type(controller.Refresh) == "function"
            ) then
                return controller
            end
        end

        return controllerOf(record) or controllerOf(ui.Dropdown)
    end

    function ui.Refresh(preferred)
        local names, listError = manager:Refresh()

        ui.Names = names

        local wanted = preferred or ui.Selected

        if wanted and table.find(names, wanted) then
            ui.Selected = wanted
        else
            ui.Selected = names[1]
        end

        local controller = dropdownController()

        if not controller then
            notify(false, "Config dropdown controller was not exposed")
            return false
        end

        local update = controller.SetValues or controller.Refresh

        if type(update) ~= "function" then
            notify(
                false,
                "Config dropdown needs Controller:SetValues(values) "
                    .. "or Controller:Refresh(values)"
            )
            return false
        end

        local values = #names > 0 and names or { EMPTY }

        ui.Updating = true

        local ok, err = pcall(update, controller, values)

        if ok and type(controller.SetValue) == "function" then
            ok, err = pcall(
                controller.SetValue,
                controller,
                ui.Selected or EMPTY
            )
        end

        ui.Updating = false

        if not ok then
            notify(false, "Dropdown refresh failed: " .. tostring(err))
            return false
        end

        if listError then
            notify(false, listError)
            return false
        end

        return true
    end

    local folderOK, folderError = self:EnsureFolder()

    if not folderOK then
        notify(false, folderError)
    end

    ui.Names = self:Refresh()
    ui.Selected = ui.Names[1]

    ui.Configs = tab:AddLeftGroupbox("configurations")
    ui.Options = tab:AddRightGroupbox("options")

    ui.Configs:AddInput(ids.Name, {
        Text = "Config name",
        Default = self.DefaultConfig,
        Placeholder = "Enter config name",

        Callback = function(value)
            ui.Name = tostring(value or "")
        end,
    })

    local values = #ui.Names > 0 and ui.Names or { EMPTY }

    ui.Dropdown = ui.Configs:AddDropdown(ids.List, {
        Text = "Config list",

        values = values,
        Values = values,

        Value = 1,
        Default = 1,

        multi = false,
        Multi = false,

        Callback = function(value)
            if ui.Updating then
                return
            end

            if type(value) == "string"
                and value ~= EMPTY
                and table.find(ui.Names, value) then

                ui.Selected = value
            else
                ui.Selected = nil
            end
        end,
    })

    local function button(groupbox, text, callback, warnClick)
        groupbox:AddButton(text, {
            WarnClick = warnClick == true,

            Callback = function()
                local ok, err = pcall(callback)

                if not ok then
                    notify(false, err)
                end
            end,
        })
    end

    button(ui.Configs, "Create config", function()
        local name, err = manager:NormalizeName(ui.Name)

        if not name then
            notify(false, err)
            return
        end

        local success, message = invoke("Create", name)
        notify(success, message)

        if success then
            ui.Refresh(name)
        end
    end)

    button(ui.Configs, "Save config", function()
        local name, err = manager:NormalizeName(saveName())

        if not name then
            notify(false, err)
            return
        end

        local success, message = invoke("Save", name)
        notify(success, message)

        if success then
            ui.Refresh(name)
        end
    end)

    button(ui.Configs, "Load config", function()
        local name = selectedName()

        if not name then
            notify(false, "Select a saved config first")
            return
        end

        local success, message = invoke("Load", name)
        notify(success, message)

        -- Apply can partially succeed, so sync UI even on reported errors.
        afterApply()
    end)

    button(ui.Configs, "Delete config", function()
        local name = selectedName()

        if not name then
            notify(false, "Select a saved config first")
            return
        end

        local success, message = invoke("Delete", name)
        notify(success, message)

        if success then
            ui.Selected = nil
            ui.Refresh()
        end
    end, true)

    button(ui.Configs, "Export config", function()
        local encoded, err = invoke("Export", selectedName())

        if type(encoded) ~= "string" then
            notify(false, err or "Export failed")
            return
        end

        if type(setclipboard) == "function" then
            local ok = pcall(setclipboard, encoded)

            if ok then
                notify(true, "Config copied to clipboard")
                return
            end
        end

        print(encoded)
        notify(true, "Config printed to output")
    end)

    ui.Configs:AddInput(ids.Paste, {
        Text = "Paste config",
        Default = "",
        Placeholder = "Paste config JSON",

        Callback = function(value)
            ui.Pasted = tostring(value or "")
        end,
    })

    button(ui.Configs, "Import pasted config", function()
        if trim(ui.Pasted) == "" then
            notify(false, "Paste a config string first")
            return
        end

        local success, message = invoke("Import", ui.Pasted)

        notify(success, message or (
            success and "Imported config" or "Import failed"
        ))

        afterApply()

        if success then
            ui.Refresh()
        end
    end, true)

    button(ui.Configs, "Reset config", function()
        local success, message = invoke("Reset")

        notify(success, message or (
            success and "Reset settings to defaults" or "Reset failed"
        ))

        afterApply()
    end, true)

    button(ui.Options, "Refresh configs", function()
        if ui.Refresh() then
            notify(true, "Config list refreshed")
        end
    end)

    ui.Options:AddLabel("Config format: plain JSON")
    ui.Options:AddLabel("Exported configs can be shared.")
    ui.Options:AddLabel("Save imported settings to keep them.")

    self.UI = ui

    ui.Refresh()

    return ui
end

return ConfigManager
