local Stats = game:GetService("Stats")

local dir = "https://raw.githubusercontent.com/00uxnx/nctrna/main/"

local sigion = {
    stuff = {

    };

	directory = {
		Main = "Sigion.pex",
		Configurations = "Sigion.pex/Configs",
		Themes = "Sigion.pex/Themes",
		Assets = "Sigion.pex/Assets",
		Dump = "Sigion.pex/Dump",
	};

	Error = {};
}

local function loadRemote(path)
	local url = dir .. path
	local fetched, source = pcall(function()
		return game:HttpGet(url)
	end)

	if not fetched then
		error("[Sigion.pex] Failed to fetch " .. path .. ": " .. tostring(source))
	end

	local chunk, compileError = loadstring(source)
	if not chunk then
		error("[Sigion.pex] Compile error in " .. path .. ": " .. tostring(compileError))
	end

	local ran, result = pcall(chunk)
	if not ran then
		error("[Sigion.pex] Runtime error in " .. path .. ": " .. tostring(result))
	end

	if type(result) ~= "table" then
		error("[Sigion.pex] " .. path .. " did not return a table")
	end

	return result
end

local lib = loadRemote("v2ui2026/test.lua")
local EspLibrary = loadRemote("visiual.lua")

--// Addons \\--
local Addon_ThemesManager = loadRemote("addons/ThemeManager.lua")
local Config_Manager = loadRemote("addons/ConfigManager.lua")
local Addon_MusicPlayer = loadRemote("addons/MusicPlayer.lua")
local Spotify_API = loadRemote("addons/SpotifyAPI.lua")

local function formatMessage(message)
	if type(message) == "table" then
		local result = {}
		for _, item in ipairs(message) do
			table.insert(result, tostring(item))
		end
		return table.concat(result, "\n")
	end

	return tostring(message or "")
end

local function notify(success, message, duration)
	local text = "[Sigion.pex] " .. formatMessage(message)

	if type(lib.Notify) == "function" then
		local ok = pcall(function()
			lib:Notify(text, duration or 3, not success)
		end)
		if ok then
			return
		end
	end

	if success then
		print(text)
	else
		warn(text)
	end
end

Addon_ThemesManager:SetLibrary(lib)
Addon_ThemesManager:SetDirectory(sigion.directory.Themes)
Addon_ThemesManager:SetAssetsDirectory(sigion.directory.Assets)

local function ensureThemeDirectory(methodName)
	local method = Addon_ThemesManager[methodName]
	if type(method) ~= "function" then
		return
	end

	local ran, success, message = pcall(method, Addon_ThemesManager)
	if not ran then
		warn("[Sigion.pex] " .. methodName .. " failed: " .. tostring(success))
	elseif success == false then
		warn("[Sigion.pex] " .. tostring(message))
	end
end

ensureThemeDirectory("EnsureFolder")
ensureThemeDirectory("EnsureAssetsFolder")

local ExternalFonts = {
	{ Name = "Starborn", File = "Starborn.ttf" },
	{ Name = "Minecraftia", File = "Minecraftia.ttf" },
}

for _, fontInfo in ipairs(ExternalFonts) do
	local ran, registered, message = pcall(function()
		return Addon_ThemesManager:RegisterLocalFont(fontInfo.Name, fontInfo.File)
	end)

	if not ran then
		warn("[Sigion.pex fonts] " .. fontInfo.Name .. ": " .. tostring(registered))
	elseif not registered then
		warn("[Sigion.pex fonts] " .. fontInfo.Name .. ": " .. tostring(message))
	end
end

local connections = {}
local tweens = {}
local unloaded = false
local cleanup

local window = lib:NewWindow({
	AutoShow = true,
	Center = true,
	Unlockmouse = true,
	Draggable = true,
})

Addon_MusicPlayer:SetLibrary(lib)
Addon_MusicPlayer:SetSpotifyModule(Spotify_API)

local MusicPlayer = Addon_MusicPlayer:CreatePlayermdl(window)
MusicPlayer:SetVisible(false)

local Tabs = {}
Tabs.Mains = window:CreateSection("Main", "rbxassetid://10723407389")
Tabs.Main = Tabs.Mains:NewTab("General")
Tabs.Render = Tabs.Mains:NewTab("Render")
Tabs.Floors = Tabs.Mains:NewTab("Floor Exploits")

Tabs.Misc = window:CreateSection("Misc", "rbxassetid://10734924532")
Tabs.information = Tabs.Misc:NewTab("Credits")

Tabs.Scripts = window:CreateSection("Scripts", "rbxassetid://10734943448")
Tabs.Morphs = Tabs.Scripts:NewTab("Morphs")

Tabs.Settings = window:CreateSection("UI Settings", "rbxassetid://10734950020")
Tabs.Configuration = Tabs.Settings:NewTab("Configs")
Tabs.Library = Tabs.Settings:NewTab("Settings")

-- Doors Vars
local Objects = {
	Prompts = {},
	Objectives = {},
	Doors = {},
	HidingSpots = {},
	Entities = {},
	SeekObstructions = {},
	Items = {},
	Chests = {},
	Currency = {},
	Ladders = {},
	Misc = {},
	Obstructions = {},
	EventTriggers = {},
	JumpscareModules = {},
	SeekHighlights = {},
	EyestalkHighlights = {},
	SeekNodes = {},
	SeekDuckBoards = {},
	SeekBridges = {},
	PathLights = {}
}

local Services = {
    Players = cloneref(game:GetService("Players"));
    ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"));
    Workspace = cloneref(game:GetService("Workspace"));
    RunService = cloneref(game:GetService("RunService"));
}

local RemotesFolder = Services.ReplicatedStorage:FindFirstChild("RemotesFolder")
local LiveModifiers = Services.ReplicatedStorage:FindFirstChild("LiveModifiers")
local FloorReplicated = Services.ReplicatedStorage:FindFirstChild("FloorReplicated")
local CurrentRooms = Services.Workspace:FindFirstChild("CurrentRooms")
local Drops = Services.Workspace:FindFirstChild("Drops")
local GameData = Services.ReplicatedStorage:WaitForChild("GameData")
local Floor = GameData:WaitForChild("Floor").Value
local LatestRoom = GameData:WaitForChild("LatestRoom")
local FinishedLoadingRoom = GameData:FindFirstChild("FinishedLoadingRoom")

local player = nil 
local Character
local RootPart

local Collision
local CollisionClone
local CollisionPart
local CollisionPartClone

local Camera

player = Services.Players.LocalPlayer
Character = player.Character

if not RemotesFolder then
	if Services.ReplicatedStorage:FindFirstChild("EntityInfo") then
		RemotesFolder = Services.ReplicatedStorage:FindFirstChild("EntityInfo")
	elseif Services.ReplicatedStorage:FindFirstChild("Bricks") then
		RemotesFolder = Services.ReplicatedStorage:FindFirstChild("Bricks")
	end
end

if Floor == "Hotel" and RemotesFolder.Name == "Bricks" then
	Floor = "OldHotel"
end

if not LiveModifiers then
	LiveModifiers = Instance.new("Folder")
end

if not FloorReplicated then
	FloorReplicated = Instance.new("Folder")
end

local FakeEvents = {
	Screech = Instance.new("RemoteEvent"),
	Shade   = Instance.new("RemoteEvent"),
	A90     = Instance.new("RemoteEvent"),
	Surge   = Instance.new("RemoteEvent"),
}

FakeEvents.Screech.Name  = "Screech"
FakeEvents.Shade.Name    = "ShadeResult"
FakeEvents.A90.Name      = "A90"
FakeEvents.Surge.Name    = "SurgeRemote"

FakeEvents.Screech_Real = RemotesFolder:WaitForChild("Screech")
FakeEvents.Shade_Real = RemotesFolder:WaitForChild("ShadeResult")
FakeEvents.A90_Real = RemotesFolder:FindFirstChild("A90")
FakeEvents.Surge_Real = RemotesFolder:FindFirstChild("SurgeRemote")

if RemotesFolder:FindFirstChild("FootstepRemoteThatWeNeed") then
    local RealRemote = RemotesFolder:FindFirstChild("FootstepRemoteThatWeNeed")
    RealRemote:Destroy()

    local FakeRemote = Instance.new("RemoteEvent", RemotesFolder)
    FakeRemote.Name = "FootstepRemoteThatWeNeed"
end

local functions = {}

functions.GetCurrentMinigame = function()
    local attribute = Character:GetAttribute("InMinigame")
    if not attribute then return nil end

    return attribute
end

functions.IsCrouching = function()
    local attribute = Character:GetAttribute("Crouching")
	if not attribute then 
        return CollisionPart.CollisionGroup == "PlayerCrouching"
    end 

    return attribute
end

functions.GetInjuriesSpeed = function()
	return 0.075 * (Character.Humanoid.MaxHealth - Character.Humanoid.Health)
end

functions.GetSpeed = function()
    local Speed = 15
	Speed += Character:GetAttribute("SpeedBoost") or 0
	Speed += Character:GetAttribute("SpeedBoostBehind") or 0
	Speed += Character:GetAttribute("SpeedBoostExtra") or 0
	Speed += (Floor == "Party" and 10 or 0)
	Speed += (LiveModifiers:FindFirstChild("PlayerFast") and 3 or 0)
	Speed += (LiveModifiers:FindFirstChild("PlayerFaster") and 6 or 0)
	Speed += (LiveModifiers:FindFirstChild("PlayerFastest") and 20 or 0)
	Speed -= (LiveModifiers:FindFirstChild("PlayerSlow") and 3 or 0)
	Speed -= (LiveModifiers:FindFirstChild("PlayerSlowHealth") and functions.GetInjuriesSpeed() or 0)
	if functions.IsCrouching() then
		if LiveModifiers:FindFirstChild("PlayerCrouchSlow") then
			Speed -= 8
		elseif LiveModifiers:FindFirstChild("PlayerSlow") then
			Speed -= 8
		else
			Speed -= 5
		end
	end
	return Speed
end

functions.GetAnchor = function()
    local AnchorCode = player.PlayerGui.MainUI.AnchorHintFrame.AnchorCode.Text
	for _, Anchor in Objects.Objectives do
		if Anchor.Name == "MinesAnchor" and Anchor:FindFirstChild("Sign") then
			if Anchor.Sign.TextLabel.Text == AnchorCode then
				return Anchor
			end
		end
	end
end

functions.GetMinecart = function()
	return Camera:FindFirstChild("MinecartRig") ~= nil
end 

functions.IsItem = function(Name, OnlyCharacter)
	if not OnlyCharacter and player.Backpack:FindFirstChild(Name) then
		return player.Backpack:FindFirstChild(Name)
	elseif Character:FindFirstChild(Name) then
		return Character:FindFirstChild(Name)
	end
end

functions.GetDoorNumber = function(Object)
	local DoorNumber = tonumber(Object.Parent.Name) or tonumber(Object.Parent.Parent.Name)
	if DoorNumber then
		DoorNumber = DoorNumber + 1
	end
	if Floor == "Mines" then
		DoorNumber = DoorNumber + 100
	end
	if Floor == "Backdoor" then
		DoorNumber = DoorNumber - 50
	end

	return tostring(DoorNumber)
end

functions.GetLibraryCode = function()
	local Paper = Character:FindFirstChild("LibraryHintPaper")
		or Character:FindFirstChild("LibraryHintPaperHard")
		or player.Backpack:FindFirstChild("LibraryHintPaper")
		or player.Backpack:FindFirstChild("LibraryHintPaperHard")

	if Paper and Paper:FindFirstChild("UI") then
		local Code = {}
		local CodeLength = Floor == "Fools" and 10 or 5
		for I = 1, CodeLength do Code[I] = "_" end

		local HintChildren = player.PlayerGui.PermUI.Hints:GetChildren()
		local UIChildren = Paper.UI:GetChildren()

		for _, Hint in HintChildren do
			for _, UIChild in UIChildren do
				if Hint:IsA("ImageLabel") and UIChild:IsA("ImageLabel")
					and Hint.ImageRectOffset == UIChild.ImageRectOffset
					and Code[tonumber(UIChild.Name)]
				then
					Code[tonumber(UIChild.Name)] = Hint.TextLabel.Text
				end
			end
		end
		return table.concat(Code)
	end
	return Floor == "Fools" and "__________" or "_____"
end

local Usedcodes = {}

functions.GetRandomCode = function()
    local CodeTemplate = functions.GetLibraryCode()
    if not CodeTemplate then
        return nil
    end

    local NewCode
    local Tries = 0
    repeat
        NewCode = CodeTemplate:gsub("_", function()
            return tostring(math.random(0, 9))
        end)
        Tries = Tries + 1
    until not Usedcodes[NewCode] or Tries >= 10

    Usedcodes[NewCode] = true
    return NewCode
end

-- General
--// Line Graph Example
local GraphGroup = Tabs.Main:AddLeftGroupbox("Graph Example")

local latestPoints = {}

local SpeedGraph = GraphGroup:AddLineGraph("Speed Curve", {
    -- Straight line is the default.
    DefaultPoints = {
        { X = 0, Y = 0 },
        { X = 1, Y = 1 }
    },

    -- Optional preset buttons appear only when true.
    Presets = true,

    Color = Color3.fromRGB(100, 170, 255),

    Callback = function(points)
        latestPoints = points

        -- points is an array like:
        -- {
        --     { X = 0.00, Y = 0.10 },
        --     { X = 0.45, Y = 0.72 },
        --     { X = 1.00, Y = 1.00 }
        -- }

        print("Line graph updated:", #points, "points")
    end
})

-- Optional: open the graph from another control.
GraphGroup:AddButton("Open Speed Curve", {
    Callback = function()
        SpeedGraph:Open()
    end
})

GraphGroup:AddButton("Reset Speed Curve", {
    Callback = function()
        SpeedGraph:Reset()
    end
})

GraphGroup:AddButton("Print Curve Points", {
    Callback = function()
        for i, point in ipairs(SpeedGraph:GetPoints()) do
            print(i, point.X, point.Y)
        end
    end
})
-- General vars
sigion.stuff.General = {
    Speedhack = false;
    Speed = 30;

    Fly = false;
    Flyspeed = 100;

    Noclip = false;
    Jumping = false;
    Sliding = false;

    DoorReach = false;
    NoIdle = false;

    AutoInteract = false;
    interactdelay = 0.01;

    PromptReach = false;
    InstantPrompt = false;
    PromptReachMulti = 2;

    Upsidedown = false;
    Spin = false;

    Dance = false;
}

-- ui general
local Charactergen
local Worldgen

-- Render

-- Render vars
sigion.stuff.Render = {
	visual = {};
	world = {};
}

-- ui render
local Worldr = Tabs.Render:Intab('World', "rbxassetid://10723398002")
local Skinsr = Tabs.Render:Intab('Skin Changer', "rbxassetid://10723398002")

-- Floor
sigion.stuff.FloorExploits = {
    AntiCheatManipulation = false;
    ACManipulationMethod = "Velocity";

    PositionSpoof = false;
    PosSpoofMethod = 1;

    CrouchSpoof = false;

    AutoLibrary = false;
    LibraryCodeBrute = false;
    AutoUnlock = false;
    UnlockDist = 20;

    AutoHotel = false;
    AutoBreaker = false;
    SkipSeek = false;
    HeartbeatGame = false;

    InfiniteItem = false;

    -- Archives
    BypassDrones = false;
    BypassWater = false;
    BypassScribble = false;
    BypassAlma = false;
    AntiCheatBypassArch = false;
    ForgetMeNotSkip = false;
    DelayTimeAlways = false;
    AutoBoxs = false;
    BoxEsp = false;
    NoHit = false;

    BypassType = "Orbit";

    -- Stairwell
    NoTv = false;
    Items = false;
    KillAllCart = false;
    BugCreak = false;
    CreakAggresion = false;
    NoCrushers = false;
    NoMeld = false;
    TPTrash = false;

    GetAllShoppingCarts = false;
    KillTarget = nil;

    BringItems = false;
    BringItemsInterval = 1;
    OrbitDropped = false;

    -- Mines
    AntiCheatBypassMines = false;
}

local Archivesint = Tabs.Floors:Intab('Archives', "rbxassetid://104508835882225")
local Stairwellint = Tabs.Floors:Intab('Stairwell', "rbxassetid://80017304328364")
local Minesint = Tabs.Floors:Intab('Mines', "rbxassetid://10734952773")

-- Main
local bypassM = Tabs.Floors:AddLeftGroupbox('Bypass')
local AudioM = Tabs.Floors:AddLeftGroupbox('Audio')
local ExploitsM = Tabs.Floors:AddRightGroupbox('Exploits')

-- archives
local expar = Archivesint:AddLeftGroupbox('Exploits')
local bypar = Archivesint:AddRightGroupbox('Bypass')
local exp2ar = Archivesint:AddRightGroupbox('Experimental')

-- stairwell
local expsw = Stairwellint:AddLeftGroupbox('Exploits')
local exsw = Stairwellint:AddRightGroupbox('Experimental')

-- Mines
local expMs = Minesint:AddLeftGroupbox('Exploits')
local exMs = Minesint:AddLeftGroupbox('Experimental')

-- Settings
local wm = lib:Watermark({
	Text = "Sigion.pex",
	Draggable = true,
})

local menu = Tabs.Library:AddLeftGroupbox("Menu Options")
menu:AddToggle("Watermark", {
	Default = true,
	Callback = function(value)
		wm:ToggleVisibility(value)
	end,
})

menu:AddLabel('Menu Key', {}):AddKeyPicker('Menu Keybind', {
    Mode = "Toggle";

    CallbackKey = function(v)
        lib.Menukey = v
    end
})

menu:Divider()

menu:AddButton("Unload", {
	WarnClick = true,
	Smaller = false,
	Callback = function()
		print("[Sigion.pex] Unloading...")

		if type(lib.Unload) ~= "function" then
			warn("[Sigion.pex] Library has no Unload method.")
			if cleanup then
				cleanup()
			end
			return
		end

		local ok, err = pcall(lib.Unload, lib)
		if cleanup then
			cleanup()
		end

		if not ok then
			warn("[Sigion.pex] Unload failed: " .. tostring(err))
		end
	end,
})

menu:AddButton("Copy Errors", {
	Smaller = false,
	Callback = function()
		notify(false, "Error collection has not been implemented.", 3)
	end,
})

menu:AddButton("Music Player", {
	Smaller = true,
	Callback = function()
		if MusicPlayer and not MusicPlayer.Destroyed then
			MusicPlayer:ToggleVisibility()
		end
	end,
})

menu:AddButton("Join Discord", {
	Smaller = true,
	Callback = function()
		notify(false, "25 Invites only", 3)
        setclipboard("https://discord.gg/2tYyHcMXZ")
	end,
})

wm:ToggleVisibility(true)

local fps = 0
local ping = 0
local frames = 0
local elapsed = 0

local function updateWatermark()
	wm:WatermarkUpdate(
		"FPS: " .. tostring(fps)
			.. " | Ping: " .. tostring(ping)
			.. "ms | Version: beta"
	)
end

connections.WatermarkUpdate = Services.RunService.RenderStepped:Connect(function(dt)
	if unloaded then
		return
	end

	frames += 1
	elapsed += dt

	if elapsed < 0.1 then
		return
	end

	fps = math.floor(frames / elapsed + 0.5)
	frames = 0
	elapsed = 0

	local success, value = pcall(function()
		return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
	end)

	ping = success and type(value) == "number" and math.floor(value) or 0
	updateWatermark()
end)

Config_Manager:SetLibrary(lib)
Config_Manager:SetDirectory(sigion.directory.Configurations)

if type(Config_Manager.init) == "function" then
	Config_Manager:init(Tabs.Configuration, {
		Notify = function(success, message)
			notify(success, message, 3)
		end,

		AfterApply = function()
			if type(Addon_ThemesManager.SyncControls) == "function" then
				Addon_ThemesManager:SyncControls()
			end
			if type(Addon_ThemesManager.ApplyFontToRoot) == "function" then
				Addon_ThemesManager:ApplyFontToRoot()
			end
		end,
	})
else
	warn("[Sigion.pex] Config manager does not expose init().")
end

if type(Addon_ThemesManager.CreateThemeManager) == "function" then
	Addon_ThemesManager:CreateThemeManager(Tabs.Library)
else
	warn("[Sigion.pex] Theme manager does not expose CreateThemeManager().")
end

if type(Addon_ThemesManager.SyncControls) == "function" then
	Addon_ThemesManager:SyncControls()
end
if type(Addon_ThemesManager.ApplyFontToRoot) == "function" then
	Addon_ThemesManager:ApplyFontToRoot()
end

cleanup = function()
	if unloaded then
		return
	end

	unloaded = true
	_G.LoadedSigion = nil

	if MusicPlayer then
		local ok, err = pcall(function()
			MusicPlayer:Destroy()
		end)
		if not ok then
			warn("[Sigion.pex] Music player cleanup failed: " .. tostring(err))
		end
		MusicPlayer = nil
	end

	if type(Addon_ThemesManager.Destroy) == "function" then
		local ok, err = pcall(Addon_ThemesManager.Destroy, Addon_ThemesManager)
		if not ok then
			warn("[Sigion.pex] Theme cleanup failed: " .. tostring(err))
		end
	end

	for _, connection in pairs(connections) do
		if typeof(connection) == "RBXScriptConnection" then
			pcall(function()
				connection:Disconnect()
			end)
		end
	end
	table.clear(connections)

	for _, tween in pairs(tweens) do
		pcall(function()
			tween:Cancel()
		end)
	end
	table.clear(tweens)
end

local previousOnUnload = lib.OnUnload
lib.OnUnload = function(self, ...)
	if cleanup then
		cleanup()
	end

	EspLibrary:Unload()

	if type(previousOnUnload) == "function" then
		local ok, err = pcall(previousOnUnload, self, ...)
		if not ok then
			warn("[Sigion.pex] Previous unload callback failed: " .. tostring(err))
		end
	end
end

_G.LoadedSigion = true
notify(true, "Sigion.pex has been initialized.", 4)
