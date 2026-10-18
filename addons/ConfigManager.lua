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
