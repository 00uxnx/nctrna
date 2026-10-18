warn("loading nocturna")

-- services
local cloneref = (cloneref or clonereference or function(instance: any)
	return instance
end)

local InputService = cloneref(game:GetService('UserInputService'));
local Players = cloneref(game:GetService('Players'));
local RunService = cloneref(game:GetService('RunService'));
local TweenService = cloneref(game:GetService('TweenService'));
local Lighting = cloneref(game:GetService('Lighting'));
local RenderStepped = RunService.RenderStepped;
local LocalPlayer = Players.LocalPlayer;
local Mouse = LocalPlayer:GetMouse();

local Toggles = {}
local Options = {}

local function newSignal()
	local signal = {}
	local connections = {}

	function signal:Connect(callback)
		local connection = {Callback = callback}
		table.insert(connections, connection)

		function connection:Disconnect()
			local index = table.find(connections, connection)
			if index then
				table.remove(connections, index)
			end
		end

		return connection
	end

	function signal:Fire(...)
		for _, connection in next, table.clone(connections) do
			task.spawn(connection.Callback, ...)
		end
	end

	return signal
end

-- gui
local function parentgui(gui)
	local isstudio = RunService:IsStudio()
	if isstudio then
		gui.Parent = LocalPlayer.PlayerGui
	elseif not isstudio then
		gui.Parent = game.CoreGui
	end
end

local screengui = Instance.new("ScreenGui")
screengui.IgnoreGuiInset = true
screengui.ResetOnSpawn = false
screengui.DisplayOrder = 10
screengui.ClipToDeviceSafeArea = false
screengui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None;
screengui.ScreenInsets = Enum.ScreenInsets.None;
parentgui(screengui)

local modal = Instance.new("TextButton")
modal.BackgroundTransparency = 1
modal.Size = UDim2.new(1,0,1,0)
modal.Text = ""
modal.ZIndex = -5
modal.Visible = false
modal.Parent = screengui
modal.Modal = true

local leftnotifsf = Instance.new("Frame")
leftnotifsf.BackgroundTransparency = 1
leftnotifsf.Size = UDim2.new(0, 322,0, 866)
leftnotifsf.Position = UDim2.new(0, 0,0.059, 0)
leftnotifsf.Name = "LeftNotifications"
leftnotifsf.Parent = screengui

local UIpadl = Instance.new("UIPadding")
UIpadl.PaddingLeft = UDim.new(0, 7)
UIpadl.PaddingRight = UDim.new(0, 7)
UIpadl.PaddingTop = UDim.new(0, 5)
UIpadl.Parent = leftnotifsf

local UIlistl = Instance.new("UIListLayout")
UIlistl.Padding = UDim.new(0, 15)
UIlistl.SortOrder = Enum.SortOrder.LayoutOrder
UIlistl.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIlistl.VerticalAlignment = Enum.VerticalAlignment.Top
UIlistl.Parent = leftnotifsf

local rightnotifsf = Instance.new("Frame")
rightnotifsf.BackgroundTransparency = 1
rightnotifsf.Size = UDim2.new(0, 322,0, 866)
rightnotifsf.Position = UDim2.new(0, 0,0.059, 0)
rightnotifsf.Name = "RightNotifications"
rightnotifsf.Parent = screengui

local UIpadr = Instance.new("UIPadding")
UIpadr.PaddingLeft = UDim.new(0, 7)
UIpadr.PaddingRight = UDim.new(0, 7)
UIpadr.PaddingTop = UDim.new(0, 5)
UIpadr.Parent = rightnotifsf

local UIlistr = Instance.new("UIListLayout")
UIlistr.Padding = UDim.new(0, 15)
UIlistr.SortOrder = Enum.SortOrder.LayoutOrder
UIlistr.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIlistr.VerticalAlignment = Enum.VerticalAlignment.Top
UIlistr.Parent = rightnotifsf


local centernotifsf

-- lib
local connections = {};
local tweens = {};

local library = {
	Registry = {};
	DependencyBoxes = {};
	otherwindows = {};
	windowinstances = {};
	maingui = nil;
	scgo = screengui;
	
	MainFrame = nil;
	Menukey = Enum.KeyCode.LeftControl;

	toggledbackground = nil;
	blureffect = nil;
	extraeff = {
		m = nil;
		frames = {};
	};

	mainwindows = {};
	
	TabsCount = 0;
	Tabs = {};
	Tab = nil;

	--// toggle
	visible = false,
	NotificationSide = "Left";
	notificationsets = {
		NotificationSound = true;
		NotificationSoundID = "106553517979212";
		SoundVol = 0.5;
	};

	--// global
	Toggles = Toggles;
	Options = Options;

	--// Addons
	ConfigurationManager = nil;
	AddonsManager = nil;
	ThemeManager = nil;

	--// Window theme
	AccentColor = Color3.fromRGB(52, 66, 189);
	MainColor = Color3.fromRGB(15, 15, 15);
	SecondaryColor = Color3.fromRGB(30, 30, 30);

	FontColor = Color3.fromRGB(255, 255, 255);
	Font = Enum.Font.Code;
	UIstroke = Color3.new(0,0,0);

	ExtraConfiguration = {
		UIToggledBackground = true;
		UIToggledBackgroundConfiguration = {
			Transparency = 0.4;
			Blur = 5;

			Color = Color3.fromRGB(0,0,0);

			Extra = {
				effbg = "Rain";
				snowconf = {
					Color = Color3.fromRGB(255,255,255);
					Transparency = 0.75;
					Scale = 1;
					Speed = 2;
					emitamount = 20
				};

				rainconf = {
					Color = Color3.fromRGB(255,255,255);
					Transparency = 0.75;
					Scale = 1;
					Speed = 1;
					emitamount = 20
				};
			}
		}
	}
}

local keyshorts = {
	["LeftControl"] = "LCtrl";
	["RightControl"] = "RCtrl";
	["LeftShift"] = "LShift";
	["RightShift"] = "RShift";
	["LeftAlt"] = "LAlt";
	["RightAlt"] = "RAlt";
	["Insert"] = "Ins";
	["MouseButton3"] = "MB3";
	["MouseButton2"] = "MB2";
	["MouseButton1"] = "MB1";

	[Enum.KeyCode.LeftControl] = "LCtrl";
	[Enum.KeyCode.RightControl] = "RCtrl";
	[Enum.KeyCode.LeftShift] = "LShift";
	[Enum.KeyCode.RightShift] = "RShift";
	[Enum.KeyCode.LeftAlt] = "LAlt";
	[Enum.KeyCode.RightAlt] = "RAlt";
	[Enum.KeyCode.Insert] = "Ins";
	[Enum.UserInputType.MouseButton3] = "MB3";
	[Enum.UserInputType.MouseButton2] = "MB2";
	[Enum.UserInputType.MouseButton1] = "MB1";
}

local themekeys = {"AccentColor", "MainColor", "SecondaryColor", "FontColor", "UIstroke"}

local function findthemekey(instancep, value)
	if instancep == "Font" then
		return "Font"
	end

	for _, key in ipairs(themekeys) do
		if library[key] == value then
			return key
		end
	end

	return nil
end

function library:AddToRegistry(instance, instancep, tinstance)
	local success, err = pcall(function()
		local entry = {
			Instance = instance;
			InstanceProperty = instancep;
			themetarget = tinstance;
			ThemeKey = findthemekey(instancep, tinstance);
		}

		table.insert(library.Registry, entry)

		instance.Destroying:Connect(function()
			for i = #library.Registry, 1, -1 do
				if library.Registry[i] == entry then
					table.remove(library.Registry, i)
				end
			end
		end)
	end)

	if not success then
		warn("[library] AddToRegistry failed: " .. tostring(err))
	end
end

function library:UpdateTheme(theme)
	if type(theme) == "table" then
		for key, value in next, theme do
			self[key] = value
		end
	end

	for _, entry in next, self.Registry do
		local key = entry.ThemeKey

		if key then
			local value = self[key]

			if value ~= nil then
				pcall(function()
					entry.Instance[entry.InstanceProperty] = value
				end)
			end
		end
	end
end

function library:Create(Class, Properties, ...)
	local _Instance = Class

	if type(Class) == "string" then
		_Instance = Instance.new(Class)
	end

	local hasBorderSizePixel = pcall(function()
		return _Instance.BorderSizePixel
	end)

	if hasBorderSizePixel then
		_Instance.BorderSizePixel = 0
	end

	--// Apply properties
	for Property, Value in next, Properties do
		_Instance[Property] = Value
	end

	--// Registry
	for _, registry in next, {...} do
		if registry then
			library:AddToRegistry(
				_Instance,
				registry.instancep,
				registry.tinstance
			)
		end
	end

	return _Instance
end

function library:Toggle()
	library.visible = not library.visible
	
	if library.visible == false	then
		if library.windowinstances.Colorbox then
			library.windowinstances.Colorbox:Close()
		end
		
		if library.windowinstances.Keybindbox then
			library.windowinstances.Keybindbox:Close()
		end
	end
	
	local unlock = false
	for _, w in pairs(library.mainwindows) do
		w.MainFrame.Visible = library.visible
		if w.Config.Unlockmouse then
			unlock = true
		end
	end
	modal.Visible = library.visible and unlock

	if connections.EffectConnection then
		connections.EffectConnection:Disconnect()
		connections.EffectConnection = nil
	end

	for _, v in pairs(library.extraeff.frames) do
		v:Destroy()
	end
	library.extraeff.frames = {}

	if library.toggledbackground then
		library.toggledbackground:Destroy()
		library.toggledbackground = nil
	end

	if library.blureffect then
		library.blureffect:Destroy()
		library.blureffect = nil
	end

	local cfg = library.ExtraConfiguration
	if not library.visible or not cfg.UIToggledBackground then
		return
	end

	local bgcfg = cfg.UIToggledBackgroundConfiguration

	if bgcfg.Blur and bgcfg.Blur > 0 then
		local blur = Instance.new("BlurEffect")
		blur.Name = "UIBlur"
		blur.Size = bgcfg.Blur
		blur.Parent = Lighting
		library.blureffect = blur
	end

	local newbg = library:Create("Frame", {
		Name = "toggledbackground";
		Position = UDim2.new(0,0,0,0);
		Size = UDim2.new(1,0,1,0);
		BackgroundTransparency = bgcfg.Transparency;
		BackgroundColor3 = bgcfg.Color;
		ZIndex = -100;
		Parent = screengui;
	}, {
		instancep = "BackgroundColor3";
		tinstance = bgcfg.Color;
	}, {
		instancep = "BackgroundTransparency";
		tinstance = bgcfg.Transparency;
	})
	library.toggledbackground = newbg

	local kind = bgcfg.Extra.effbg
	local conf = (kind == "Snow" and bgcfg.Extra.snowconf) or (kind == "Rain" and bgcfg.Extra.rainconf)
	if not conf then
		return
	end

	local effectframe = library:Create("Frame", {
		Name = "effectframe";
		Size = UDim2.new(1,0,1,0);
		Position = UDim2.new(0,0,0,0);
		BackgroundTransparency = 1;
		ZIndex = 0;
		Parent = newbg;
	})

	local frames, data = {}, {}
	local rng = Random.new()
	local buffer = 0
	library.extraeff.frames = frames

	connections.EffectConnection = RunService.RenderStepped:Connect(function(dt)
		dt = math.min(dt, 0.1)

		buffer = buffer + conf.emitamount * dt
		while buffer >= 1 do
			buffer = buffer - 1

			local p = Instance.new("Frame")
			p.BorderSizePixel = 0
			p.ZIndex = 0
			p.BackgroundColor3 = conf.Color
			p.BackgroundTransparency = math.clamp(conf.Transparency + rng:NextNumber(-0.1, 0.1), 0, 1)

			if kind == "Snow" then
				local s = math.max(1, math.floor(rng:NextNumber(3, 6) * conf.Scale))
				p.Size = UDim2.fromOffset(s, s)
				p.Position = UDim2.new(rng:NextNumber(), 0, 0, -s)

				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(1, 0)
				corner.Parent = p

				data[p] = {
					speed = 60 * conf.Speed * rng:NextNumber(0.6, 1.4);
					sway = rng:NextNumber(-15, 15) * conf.Speed;
				}
			else
				local len = math.max(2, math.floor(rng:NextNumber(12, 24) * conf.Scale))
				p.Size = UDim2.fromOffset(1, len)
				p.Position = UDim2.new(rng:NextNumber(), 0, 0, -len)

				data[p] = {
					speed = 700 * conf.Speed * rng:NextNumber(0.8, 1.3);
					sway = 0;
				}
			end

			p.Parent = effectframe
			table.insert(frames, p)
		end

		local height = effectframe.AbsoluteSize.Y
		local width = math.max(effectframe.AbsoluteSize.X, 1)

		for i = #frames, 1, -1 do
			local p = frames[i]
			local d = data[p]
			local pos = p.Position
			local ny = pos.Y.Offset + d.speed * dt

			if ny > height then
				p:Destroy()
				data[p] = nil
				table.remove(frames, i)
			else
				p.Position = UDim2.new(pos.X.Scale + (d.sway * dt) / width, 0, 0, ny)
			end
		end
	end)
end

function library:CloseAllTabs()
	for _, tab in pairs(library.Tabs) do
		tab:Close()
	end
end

library.DependencyBoxes = library.DependencyBoxes or {}

function library:UpdateDependencyBoxes()
	for _, box in next, self.DependencyBoxes do
		box:Update()
	end
end

function library:NewWindow(configuration)
	local window = {}

	--// Window Creation
	local mainframe = library:Create("Frame", {
		Name = "Window";
		Size = UDim2.new(0, 815,0, 489);
		Position = UDim2.new(0.5, 0, 0.5, 0);
		AnchorPoint = Vector2.new(0.5,0.5);

		BackgroundColor3 = library.MainColor;
		BackgroundTransparency = 0;

		ZIndex = 1;
		Visible = false;

		Parent = screengui;
	},
	{
		instancep = "BackgroundColor3";
		tinstance = library.MainColor;
	})

	local uistroke1 = library:Create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		Color = library.SecondaryColor;
		LineJoinMode = Enum.LineJoinMode.Miter;
		Thickness = 1;
		Parent = mainframe;
		ZIndex = 1;
	},
	{
		instancep = "Color";
		tinstance = library.SecondaryColor;
	})

	local uistroke2 = library:Create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		Color = library.MainColor;
		Thickness = 3;
		Parent = mainframe;
		ZIndex = 0;
		LineJoinMode = Enum.LineJoinMode.Miter;
	},
	{
		instancep = "Color";
		tinstance = library.MainColor;
	})

	-- ls
	local line1 = library:Create("Frame", {
		Name = "l1";
		Size = UDim2.new(0, 1,1, 0);
		Position = UDim2.new(0.163, 0,0, 0);
		BackgroundColor3 = library.SecondaryColor;
		ZIndex = 1;
		Parent = mainframe;
	}, {
		instancep = "BackgroundColor3";
		tinstance = library.SecondaryColor;
	})

	local line2 = library:Create("Frame", {
		Name = "l2";
		Size = UDim2.new(1, 0,0, 1);
		Position = UDim2.new(0, 0,0.1, 0);
		BackgroundColor3 = library.SecondaryColor;
		ZIndex = 1;
		Parent = mainframe;
	}, {
		instancep = "BackgroundColor3";
		tinstance = library.SecondaryColor;
	})

	-- name header
	local namemainholder = library:Create("Frame", {
		Name = "bx";
		Size = UDim2.new(0, 132,0, 51);
		Position = UDim2.new(0, 0,0, 0);
		BackgroundTransparency = 1;
		Parent = mainframe;
	})

	local nameholder = library:Create("CanvasGroup", {
		Name = "bx2";
		Size = UDim2.new(1,0,1,0);
		Position = UDim2.new(0, 0,0, 0);
		BackgroundTransparency = 1;
		Parent = namemainholder;
	})

	local uilist = library:Create("UIListLayout", {
		Name = "list";
		FillDirection = Enum.FillDirection.Horizontal;
		Padding = UDim.new(0, 0);
		SortOrder = Enum.SortOrder.LayoutOrder;
		HorizontalAlignment = Enum.HorizontalAlignment.Left;
		VerticalAlignment = Enum.VerticalAlignment.Center;
		Parent = nameholder;
	})

	local uipad = library:Create("UIPadding", {
		Name = "pad";
		PaddingLeft = UDim.new(0, 2);
		PaddingRight = UDim.new(0, 2);
		PaddingTop = UDim.new(0, 3);
		PaddingBottom = UDim.new(0, 3);
		Parent = nameholder;
	})

	local iconnt = library:Create("ImageLabel", {
		Name = "icon";
		Size = UDim2.new(0, 35,0, 35);
		Position = UDim2.new(0, 0,0, 0);
		BackgroundTransparency = 1;

		ImageColor3 = library.AccentColor;

		Image = "rbxassetid://132964249585974";
		ScaleType = Enum.ScaleType.Crop;
		Parent = nameholder;
	}, {
		instancep = "ImageColor3";
		tinstance = library.AccentColor;
	})

	local name = library:Create("TextLabel", {
		Name = "name";
		Size = UDim2.new(0.7, 0,0, 50);
		Position = UDim2.new(0, 0,0, 0);
		BackgroundTransparency = 1;
		Text = "Nocturne.bz";
		TextScaled = true;
		Font = Enum.Font.SourceSansBold;
		TextColor3 = library.AccentColor;
		TextXAlignment = Enum.TextXAlignment.Left;
		TextYAlignment = Enum.TextYAlignment.Center;
		TextWrapped = true;

		TextSize = 22;
		Parent = nameholder;
	}, {
		instancep = "TextColor3";
		tinstance = library.AccentColor;
	})

	local dragbutton = library:Create("TextButton", {
		Name = "bx";
		Size = UDim2.new(0, 132,0, 51);
		Position = UDim2.new(0, 0,0, 0);
		BackgroundTransparency = 1;
		Parent = mainframe;
		ZIndex = 2;
		Text = "";
		Active = true;
	})

	local uistroke = library:Create("UIStroke", {
		Name = "stroke";
		ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
		Color = Color3.new(0,0,0);
		Thickness = 1;
		Parent = name;
	})

	local uitextsize = library:Create("UITextSizeConstraint", {
		Name = "uitextsize";
		MaxTextSize = 22;
		Parent = name;
	})

	local uipad222 = library:Create("UIPadding", {
		Name = "pad";
		PaddingLeft = UDim.new(0, 0);
		PaddingRight = UDim.new(0, 2);
		PaddingTop = UDim.new(0, 0);
		PaddingBottom = UDim.new(0, 0);
		Parent = name;
	})

	local gradient = library:Create("UIGradient", {
		Name = "grad";
		Offset = Vector2.new(0, 0.035);
		Rotation = 90;
		Parent = name;

		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.new(1,1,1));
			ColorSequenceKeypoint.new(0.4, Color3.new(1,1,1));
			ColorSequenceKeypoint.new(0.498, Color3.new(0.258824, 0.258824, 0.258824));
			ColorSequenceKeypoint.new(.6, Color3.new(1,1,1));
			ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
		};
	})

	local gradient2 = library:Create("UIGradient", {
		Name = "grad";
		Offset = Vector2.new(0, 0.035);
		Rotation = 90;
		Parent = iconnt;

		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.new(1,1,1));
			ColorSequenceKeypoint.new(0.4, Color3.new(1,1,1));
			ColorSequenceKeypoint.new(0.498, Color3.new(0.258824, 0.258824, 0.258824));
			ColorSequenceKeypoint.new(.6, Color3.new(1,1,1));
			ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
		};
	})

	-- Search
	local Sholder = library:Create("Frame", {
		Name = "Search";
		Size = UDim2.new(0, 681,0, 50);
		Position = UDim2.new(0.164, 0,-0.002, 0);
		BackgroundColor3 = Color3.new(0,0,0);
		BackgroundTransparency = 1;
		Parent = mainframe;
		ZIndex = 2;
	})

	local uilist = library:Create("UIListLayout", {
		Name = "list";
		FillDirection = Enum.FillDirection.Horizontal;
		Padding = UDim.new(0, 15);
		SortOrder = Enum.SortOrder.LayoutOrder;
		Parent = Sholder;

		HorizontalAlignment = Enum.HorizontalAlignment.Left;
		VerticalAlignment = Enum.VerticalAlignment.Center;
	})

	local uipad = library:Create("UIPadding", {
		Name = "pad";
		PaddingLeft = UDim.new(0, 10);
		PaddingRight = UDim.new(0, 0);
		Parent = Sholder;
	})

	local searchicon = library:Create("ImageLabel", {
		Name = "icon";
		Size = UDim2.new(0, 25,0, 25);
		Position = UDim2.new(0,0,0,0);
		BackgroundColor3 = Color3.new(0,0,0);
		BackgroundTransparency = 1;
		Parent = Sholder;
		LayoutOrder = 0;

		Image = "rbxassetid://10734943674";
		ImageColor3 = library.SecondaryColor;
		ScaleType = Enum.ScaleType.Crop;
	}, {
		instancep = "ImageColor3";
		tinstance = library.SecondaryColor
	})

	local Input = library:Create("TextBox", {
		Name = "SearchBox";
		Size = UDim2.new(0.924, 0,0.65, 0);
		Position = UDim2.new(0,0,0,0);

		BackgroundColor3 = library.MainColor;
		BackgroundTransparency = 0;
		Font = Enum.Font.Code;
		TextColor3 = library.FontColor;
		Text = "";

		TextSize = 15;
		TextXAlignment = Enum.TextXAlignment.Left;
		TextYAlignment = Enum.TextYAlignment.Center;

		PlaceholderColor3 = Color3.new(0.498039, 0.498039, 0.498039);
		PlaceholderText = "Search here.";

		Parent = Sholder;
		LayoutOrder = 1;

		ClearTextOnFocus = false;
	}, {
		instancep = "BackgroundColor3";
		tinstance = library.MainColor;
	}, {
		instancep = "TextColor3";
		tinstance = library.FontColor;
	})

	local uis1 = library:Create("UIStroke", {
		Name = "stroke";
		Parent = Input;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;

		Transparency = 0;
		Color = library.SecondaryColor;
		Thickness = 1;
	}, {
		instancep = "Color";
		tinstance = library.SecondaryColor;
	})

	local uis2 = library:Create("UIStroke", {
		Name = "stroke2";
		Parent = Input;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;

		Transparency = 0;
		Color = library.UIstroke;
		Thickness = 1;
	}, {
		instancep = "Color";
		tinstance = library.UIstroke;
	})

	local uip = library:Create("UIPadding", {
		Name = "pad";
		PaddingLeft = UDim.new(0, 5);
		PaddingRight = UDim.new(0, 0);
		PaddingTop = UDim.new(0, 0);
		PaddingBottom = UDim.new(0, 0);
		Parent = Input;
	})


	-- Tabs
	local tabholder = library:Create("ScrollingFrame", {
		Name = "tabs";
		Size = UDim2.new(0, 131,0.9, 0);
		Position = UDim2.new(0.001, 0,0.1, 0);
		BackgroundTransparency = 1;
		AutomaticCanvasSize = Enum.AutomaticSize.Y;
		CanvasSize = UDim2.new(0, 0,0, 0);
		ScrollBarThickness = 0;
		ScrollingDirection = Enum.ScrollingDirection.Y;
		Parent = mainframe;
	})
	
	local tablayout = library:Create("UIListLayout", {
		Name = "layout";
		FillDirection = Enum.FillDirection.Vertical;
		HorizontalAlignment = Enum.HorizontalAlignment.Center;
		VerticalAlignment = Enum.VerticalAlignment.Top;
		SortOrder = Enum.SortOrder.LayoutOrder;
		Padding = UDim.new(0, 7);
		Parent = tabholder;
	})
	
	local uipad = library:Create("UIPadding", {
		Name = "pad";
		PaddingLeft = UDim.new(0, 0);
		PaddingRight = UDim.new(0, 0);
		PaddingTop = UDim.new(0, 10);
		PaddingBottom = UDim.new(0, 10);
		Parent = tabholder;
	})
	
	-- Holder
	local tabpageholder = library:Create("Frame", {
		Name = "tabpageholder";
		Size = UDim2.new(0, 681,0, 439);
		Position = UDim2.new(0.164, 0,0.102, 0);
		BackgroundTransparency = 1;
		Parent = mainframe;
		ZIndex = 2;
	})
	
	-- Creation api
	function window:CreateSection(name)
		local section = {}
	
		local section = library:Create("Frame", {
			Name = "section";
			Size = UDim2.new(0.95, 0,0, 0);
			BackgroundTransparency = 1;
			Parent = tabholder;
			AutomaticSize = Enum.AutomaticSize.Y;
			LayoutOrder = #tabholder:GetChildren();
		})
		
		local frame = library:Create("Frame", {
			Name = "frame";
			Size = UDim2.new(0, 3,1, 0);
			Position = UDim2.new(0, 0,0, 0);
			Parent = section;
			
			BackgroundColor3 = library.AccentColor;
		}, {
			instancep = "BackgroundColor3";
			tinstance = library.AccentColor;
		})
		
		local uic = library:Create("UICorner", {
			Name = "corner";
			CornerRadius = UDim.new(1, 0);
			Parent = frame;
		})
		
		local title = library:Create("TextLabel", {
			Name = "title";
			Size = UDim2.new(0.975, 0,1, 0);
			Position = UDim2.new(0.025, 0,0, 0);
			BackgroundTransparency = 1;
			TextXAlignment = Enum.TextXAlignment.Left;
			TextYAlignment = Enum.TextYAlignment.Center;
			Text = name;
			TextSize = 14;
			Font = library.Font;
			TextColor3 = library.FontColor;
			
			Parent = section;
		}, {
			instancep = "TextColor3";
			tinstance = library.FontColor;
		}, {
			instancep = "Font";
			tinstance = library.Font;
		})
		
		local uis = library:Create("UIStroke", {
			Name = "stroke";
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
			Color = library.UIstroke;
			Thickness = 1;
			Parent = title;
		}, {
			instancep = "Color";
			tinstance = library.UIstroke;
		})
		
		local uip = library:Create("UIPadding", {
			Name = "pad";
			PaddingLeft = UDim.new(0, 8);
			PaddingRight = UDim.new(0, 0);
			PaddingTop = UDim.new(0, 5);
			PaddingBottom = UDim.new(0, 5);
			
			Parent = title;
		})
			
		
		local tsize = library:Create("UITextSizeConstraint", {
			Name = "tsize";
			MaxTextSize = 14;
			Parent = title;
		})
		
		return section
	end
	
	function window:AddTab(opts)
		local tab = {}
		local isFirst = (#library.Tabs == 0)
		
		tab.frame = nil
		tab.visible = false
		
		local Groupboxs = {}
		local Tabboxs = {}
		
		-- tab button creation.
		local tabframemain = library:Create("Frame", {
			Name = "tab";
			Size = UDim2.new(0, 122,0, 33);
			Position = UDim2.new(0, 0,0, 0);
			BackgroundColor3 = library.MainColor;
			LayoutOrder = #tabholder:GetChildren();
			Parent = tabholder;
		}, {
			instancep = "BackgroundColor3";
			tinstance = library.MainColor;
		})
		
		local tabbutton = library:Create("TextButton", {
			Name = "button";
			Size = UDim2.new(1, 0,1, 0);
			BackgroundTransparency = 1;
			Text = "";
			ZIndex = 2;
			Parent = tabframemain;
		})
		
		local holderframe = library:Create("Frame", {
			Name = "holder";
			Size = UDim2.new(1, 0,1, 0);
			BackgroundTransparency = 1;
			ZIndex = 1;
			Parent = tabframemain;
		})
		
		local tabimage = library:Create("ImageLabel", {
			Name = "tabimage";
			Size = UDim2.new(0, 25,0, 25);
			BackgroundTransparency = 1;
			LayoutOrder = 1;
			Parent = holderframe;
			
			Image = opts.Image or "rbxassetid://10734965702"; 
			ImageColor3 = library.AccentColor;
		}, {
			instancep = "ImageColor3";
			tinstance = library.AccentColor;
		})
		
		local tabtitle = library:Create("TextLabel", {
			Name = "title";
			Size = UDim2.new(0, 77,0, 31);
			LayoutOrder = 2;
			BackgroundTransparency = 1;
			Text = opts.Text;
			TextSize = 15;
			Font = library.Font;
			TextColor3 = library.FontColor;
			
			Parent = holderframe;
		}, {
			instancep = "TextColor3";
			tinstance = library.FontColor;
		}, {
			instancep = "Font";
			tinstance = library.Font;
		})
		
		local tabstroke = library:Create("UIStroke", {
			Name = "stroke";
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
			Color = library.UIstroke;
			Thickness = 1;
			Parent = tabtitle;
		}, {
			instancep = "Color";
			tinstance = library.UIstroke;
		})
		
		local tabuil = library:Create("UIListLayout", {
			Name = "uil";
			FillDirection = Enum.FillDirection.Horizontal;
			Padding = UDim.new(0, 5);	
			SortOrder = Enum.SortOrder.LayoutOrder;
			HorizontalAlignment = Enum.HorizontalAlignment.Center;
			VerticalAlignment = Enum.VerticalAlignment.Center;
			Parent = holderframe;
		})
		
		local tabuis = library:Create("UIStroke", {
			Name = "stroke";
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			Color = library.SecondaryColor;
			Thickness = 1;
			Parent = tabframemain;
			LineJoinMode = Enum.LineJoinMode.Miter;
		}, {
			instancep = "Color";
			tinstance = library.SecondaryColor;
		})
		
		-- tab page creation.
		local tabpage = library:Create("Frame", {
			Name = opts.Text;
			Size = UDim2.new(1, 0,1, 0);
			Position = UDim2.new(0, 0,0, 0);
			BackgroundTransparency = 1;
			Visible = isFirst;
			Parent = tabpageholder
		})
		
		local tableft = library:Create("ScrollingFrame", {
			Name = "Left";
			Size = UDim2.new(0.5, 0,1, 0);
			Position = UDim2.new(0, 0,0, 0);
			BackgroundTransparency = 1;

			AutomaticCanvasSize = Enum.AutomaticSize.Y;
			CanvasSize = UDim2.new(0, 0,0, 0);
			ScrollingDirection = Enum.ScrollingDirection.Y;
			ScrollBarThickness = 0;

			Parent = tabpage	
		})
		
		local tabluil = library:Create("UIListLayout", {
			Name = "uil";
			FillDirection = Enum.FillDirection.Vertical;
			Padding = UDim.new(0, 5);
			SortOrder = Enum.SortOrder.LayoutOrder;
			HorizontalAlignment = Enum.HorizontalAlignment.Center;
			VerticalAlignment = Enum.VerticalAlignment.Top;
			Parent = tableft;
		})
		
		local tabuip = library:Create("UIPadding", {
			Name = "uip";
			PaddingRight = UDim.new(0, 0);
			PaddingLeft = UDim.new(0, 0);
			PaddingTop = UDim.new(0, 10);
			PaddingBottom = UDim.new(0, 0);
			Parent = tableft;
		})
		
		local tabright = library:Create("ScrollingFrame", {
			Name = "Right";
			Size = UDim2.new(0.5, 0,1, 0);
			Position = UDim2.new(.5, 0,0, 0);
			BackgroundTransparency = 1;
			
			AutomaticCanvasSize = Enum.AutomaticSize.Y;
			CanvasSize = UDim2.new(0, 0,0, 0);
			ScrollingDirection = Enum.ScrollingDirection.Y;
			ScrollBarThickness = 0;
			
			Parent = tabpage	
		})
		
		local tabruil = library:Create("UIListLayout", {
			Name = "uil";
			FillDirection = Enum.FillDirection.Vertical;
			Padding = UDim.new(0, 5);
			SortOrder = Enum.SortOrder.LayoutOrder;
			HorizontalAlignment = Enum.HorizontalAlignment.Center;
			VerticalAlignment = Enum.VerticalAlignment.Top;
			Parent = tabright;
		})

		local tabruip = library:Create("UIPadding", {
			Name = "uip";
			PaddingRight = UDim.new(0, 0);
			PaddingLeft = UDim.new(0, 0);
			PaddingTop = UDim.new(0, 10);
			PaddingBottom = UDim.new(0, 0);
			Parent = tabright;
		})
		
		-- tab page api
		function tab:AddLeftGroupbox(title)
			local groupbox = {
				elements = {};
			}
			
			local groupboxf = library:Create("Frame", {
				Name = "Groupbox";
				Size = UDim2.new(0.95, 0,0, 0);
				Position = UDim2.new(0, 0,0, 0);
				BackgroundColor3 = library.MainColor;
				AutomaticSize = Enum.AutomaticSize.Y;
				LayoutOrder = #tableft:GetChildren();
				Parent = tableft;
			}, {
				instancep = "BackgroundColor3";
				tinstance = library.MainColor;
			})
			
			local uistroke = library:Create("UIStroke", {
				Name = "UIStroke";
				Parent = groupboxf;
				Thickness = 1;
				Color = library.SecondaryColor;
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			}, {
				instancep = "Color";
				tinstance = library.SecondaryColor;
			})

			local uilay = library:Create("UIListLayout", {
				Name = "uil";
				FillDirection = Enum.FillDirection.Vertical;
				Padding = UDim.new(0, 1);
				SortOrder = Enum.SortOrder.LayoutOrder;
				HorizontalAlignment = Enum.HorizontalAlignment.Center;
				VerticalAlignment = Enum.VerticalAlignment.Top;

				Parent = groupboxf;
			})

			local uipad = library:Create("UIPadding", {
				Name = "uip";
				PaddingRight = UDim.new(0, 0);
				PaddingLeft = UDim.new(0, 0);
				PaddingTop = UDim.new(0, 0);
				PaddingBottom = UDim.new(0, 4);
				Parent = groupboxf;
			})

			local accent = library:Create("Frame", {
				Name = "Accent";
				Size = UDim2.new(1, 0,0, 1);
				Position = UDim2.new(0, 0,0, 0);
				BackgroundColor3 = library.AccentColor;
				LayoutOrder = -1000;
				Parent = groupboxf;
			}, {
				instancep = "BackgroundColor3";
				tinstance = library.AccentColor;
			})

			local titlegroupbox = library:Create("TextLabel", {
				Name = "Title";
				Size = UDim2.new(1, 0,0, 20);
				LayoutOrder = -1;

				BackgroundTransparency = 1;
				Text = title;
				Font = library.Font;
				TextColor3 = library.FontColor;
				TextSize = 14;

				Parent = groupboxf;
			}, {
				instancep = "TextColor3";
				tinstance = library.FontColor;
			}, {
				instancep = "Font";
				tinstance = library.Font;
			})

			local titleuis = library:Create("UIStroke", {
				Name = "UIStroke";
				Parent = titlegroupbox;
				Thickness = 1;
				Color = library.UIstroke;
			}, {
				instancep = "Color";
				tinstance = library.UIstroke;
			})

			local titleuits = library:Create("UITextSizeConstraint", {
				Name = "uit";
				MaxTextSize = 14;
				Parent = titlegroupbox;
			})

			local titleuip = library:Create("UIPadding", {
				Name = "uip";
				PaddingRight = UDim.new(0, 0);
				PaddingLeft = UDim.new(0, 0);
				PaddingTop = UDim.new(0, 3);
				PaddingBottom = UDim.new(0, 0);
				Parent = titlegroupbox;
			})

			local elementsholder = library:Create("Frame", {
				Name = "elem";
				Size = UDim2.new(1, 0,0, 0);
				BackgroundTransparency = 1;
				LayoutOrder = 1;
				AutomaticSize = Enum.AutomaticSize.Y;
				Parent = groupboxf;
			})

			local elemsuill = library:Create("UIListLayout", {
				Name = "UIListLayout";
				FillDirection = Enum.FillDirection.Horizontal;
				Wraps = true;
				HorizontalAlignment = Enum.HorizontalAlignment.Center;
				VerticalAlignment = Enum.VerticalAlignment.Top;
				SortOrder = Enum.SortOrder.LayoutOrder;
				Padding = UDim.new(0, 5);
				Parent = elementsholder;
			})

			local elemsuip = library:Create("UIPadding", {
				Name = "UIPadding";
				PaddingBottom = UDim.new(0, 0);
				PaddingLeft = UDim.new(0, 0);
				PaddingRight = UDim.new(0, 0);
				PaddingTop = UDim.new(0, 3);
				Parent = elementsholder;
			})
			
			-- api	
			function groupbox:AddLabel(text, opts)
				--[[
				    MAX 3 COLOR PICKERS (cant use key picker if u do this)
				    MAX 1 KEY PICKER (cant use color pickers if u do this)
				]]

				local label = {}
				local colorpickers = {}
				local keypicker = nil

				local RestrictedKeypicker = false
				local RestrictedColorpicker = false

				local holder = library:Create("Frame", {
					Name = "Holder";
					Size = UDim2.new(0.95, 0,0, 20);
					BackgroundTransparency = 1;
					LayoutOrder = #elementsholder:GetChildren();
					Parent = elementsholder;
				})

				local uitext = library:Create("TextLabel", {
					Name = "TextLabel";
					Size = UDim2.new(.795, 0,1, 0);
					BackgroundTransparency = 1;
					Text = text;
					TextSize = 13;
					TextColor3 = library.FontColor;
					Font = library.Font;
					LayoutOrder = 1;
					TextXAlignment = Enum.TextXAlignment.Left;
					TextYAlignment = Enum.TextYAlignment.Center;
					Parent = holder;
				}, {
					instancep = "TextColor3";
					tinstance = library.FontColor;
				})

				local uitextsui = library:Create("UITextSizeConstraint", {
					Name = "UITextSizeConstraint";
					MaxTextSize = 13;
					Parent = uitext;
				})

				local uistroke = library:Create("UIStroke", {
					Name = "UIStroke";
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
					Color = Color3.fromRGB(0, 0, 0);
					Thickness = 1;
					Parent = uitext;
				}, {
					instancep = "Color";
					tinstance = library.UIstroke;
				})

				local uill = library:Create("UIListLayout", {
					Name = "UIListLayout";
					FillDirection = Enum.FillDirection.Horizontal;
					HorizontalAlignment = Enum.HorizontalAlignment.Left;
					SortOrder = Enum.SortOrder.LayoutOrder;
					Parent = holder;
				})

				local holder2 = library:Create("Frame", {
					Name = "Holder";
					Size = UDim2.new(0.043, 50,1, 0);
					BackgroundTransparency = 1;
					LayoutOrder = 2;
					Parent = holder;
				})

				local uillh = library:Create("UIListLayout", {
					Name = "UIListLayout";
					FillDirection = Enum.FillDirection.Horizontal;
					HorizontalAlignment = Enum.HorizontalAlignment.Right;
					VerticalAlignment = Enum.VerticalAlignment.Center;
					SortOrder = Enum.SortOrder.LayoutOrder;
					Padding = UDim.new(0, 6);
					Parent = holder2;
				})

				function label:AddColorPicker(name, opts)
					if RestrictedColorpicker then
						error("Restricted your using a keypicker!")
						return
					end

					if #colorpickers >= 3 then
						error("Max number of colorpickers reached")
						return
					end

					local colorpicker = {}
					table.insert(colorpickers, colorpicker)
					RestrictedKeypicker = true
					local color = opts.Startcolor or Color3.new(1, 1, 1)
					local transparency = opts.Transparency or 0
					local pointPosition

					colorpicker.Color = color
					colorpicker.Transparency = transparency
					colorpicker.OnChanged = newSignal()
					Options[name] = colorpicker
					local opened = false
					local instance 
					local followConn
					local outsideConn

					local colorbox = library:Create("Frame", {
						Name = "ColorBox";
						Size = UDim2.new(0, 17,0, 15);
						BackgroundColor3 = color;
						LayoutOrder = #holder2:GetChildren();
						Parent = holder2;
					})

					local uistroke = library:Create("UIStroke", {
						Name = "UIStroke";
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
						LineJoinMode = Enum.LineJoinMode.Miter;
						Color = library.SecondaryColor;
						Thickness = 1;
						Parent = colorbox;
					}, {
						instancep = "Color";
						tinstance = library.SecondaryColor;
					})

					local hitbox = library:Create("TextButton", {
						Name = "Hitbox";
						Size = UDim2.new(1,0,1,0);
						BackgroundTransparency = 1;
						Active = true;
						ZIndex = 10;
						Selectable = true;
						Text = "";
						Parent = colorbox;
					})

					local function OnChange(newcolor, newtransparency)
						colorpicker.Color = newcolor
						colorpicker.Transparency = newtransparency

						if opts.Callback then
							opts.Callback(newcolor, newtransparency)
						end

						colorpicker.OnChanged:Fire(newcolor, newtransparency)
					end

					local function Createcolorpickerbox()
						opened = true

						local function getPos()
							local abs = colorbox.AbsolutePosition
							local base = screengui.AbsolutePosition
							return UDim2.new(0, abs.X - base.X, 0, abs.Y - base.Y)
						end

						local cursorbox = library:Create("Frame", {
							Name = "CursorBox";
							Size = UDim2.new(0, 15,0, 15);
							Position = getPos();
							BackgroundColor3 = Color3.new(1,1,1);
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = screengui;
						})

						instance = cursorbox

						followConn = colorbox:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
							if instance then
								instance.Position = getPos()
							end
						end)

						local framewindow = library:Create("Frame", {
							Name = "Frame";
							Size = UDim2.new(0, 323,0, 198);
							Position = UDim2.new(1, 0,1.4, 0);
							BackgroundColor3 = library.MainColor;
							ZIndex = 2;
							Parent = cursorbox;
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local uistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							LineJoinMode = Enum.LineJoinMode.Miter;
							Color = library.SecondaryColor;
							Thickness = 1;
							ZIndex = 2;
							Parent = framewindow;
						}, {
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local uistroke2 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							LineJoinMode = Enum.LineJoinMode.Miter;
							Color = library.MainColor;
							Thickness = 4;
							Parent = framewindow;
						}, {
							instancep = "Color";
							tinstance = library.MainColor;
						})

						local text = library:Create("TextLabel", {
							Name = "TextLabel";
							Size = UDim2.new(1, 0,0, 16);
							Position = UDim2.new(0, 0,0, 0);
							Text = name;
							TextColor3 = library.FontColor;
							Font = library.Font;
							TextSize = 13;
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = framewindow;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local textuistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = text;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local textuisize = library:Create("UITextSizeConstraint", {
							Name = "UISizeConstraint";
							MaxTextSize = 13;
							Parent = text;
						})

						local colors = library:Create("Frame", {
							Name = "Colors";
							Size = UDim2.new(1, 0,0, 23);
							Position = UDim2.new(0, 0,0.879, 0);
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = framewindow;
						})

						local colorsUIl = library:Create("UIListLayout", {
							Name = "UIListLayout";
							FillDirection = Enum.FillDirection.Horizontal;
							HorizontalAlignment = Enum.HorizontalAlignment.Center;
							Padding = UDim.new(0, 8);
							SortOrder = Enum.SortOrder.LayoutOrder;
							VerticalAlignment = Enum.VerticalAlignment.Center;
							Parent = colors;
						})

						local colorsboxcolor = library:Create("Frame", {
							Name = "Color";
							Size = UDim2.new(0, 20,0, 20);
							BackgroundColor3 = color;
							ZIndex = 2;
							LayoutOrder = 1;
							Parent = colors;
						}, {
							instancep = "BackgroundColor3";
							tinstance = color;
						})

						local colorsboxcoloruistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							Color = library.SecondaryColor;
							Thickness = 1;
							Parent = colorsboxcolor;
						}, {
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local function rgbText(c)
							return math.floor(c.R * 255 + 0.5) .. "," .. math.floor(c.G * 255 + 0.5) .. "," .. math.floor(c.B * 255 + 0.5)
						end

						local huecoloreditbox = library:Create("TextBox", {
							Name = "Hue";
							Size = UDim2.new(0, 71,0, 20);
							BackgroundColor3 = library.MainColor;
							TextColor3 = library.FontColor;
							Text = rgbText(color);
							TextSize = 13;
							Font = Enum.Font.SourceSans;
							MultiLine = false;
							ZIndex = 2;
							LayoutOrder = 2;
							Parent = colors;
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						})

						local huecolorboxuis1 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							Color = library.SecondaryColor;
							Thickness = 1;
							Parent = huecoloreditbox;
						}, {
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local huecolorboxuis2 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = huecoloreditbox;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local transditbox = library:Create("TextBox", {
							Name = "trans";
							Size = UDim2.new(0, 71,0, 20);
							BackgroundColor3 = library.MainColor;
							TextColor3 = library.FontColor;
							Text = transparency;
							TextSize = 13;
							Font = Enum.Font.SourceSans;
							MultiLine = false;
							ZIndex = 2;
							LayoutOrder = 2;
							Parent = colors;
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						})

						local transboxuis1 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							Color = library.SecondaryColor;
							Thickness = 1;
							Parent = transditbox;
						}, {
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local transboxuis2 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = transditbox;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local hexditbox = library:Create("TextBox", {
							Name = "trans";
							Size = UDim2.new(0, 71,0, 20);
							BackgroundColor3 = library.MainColor;
							TextColor3 = library.FontColor;
							Text = color:ToHex();
							TextSize = 13;
							Font = Enum.Font.SourceSans;
							MultiLine = false;
							ZIndex = 2; 
							LayoutOrder = 2;
							Parent = colors;
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						})

						local hexboxuis1 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							Color = library.SecondaryColor;
							Thickness = 1;
							Parent = hexditbox;
						}, {
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local hexboxuis2 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = hexditbox;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local main = library:Create("Frame", {
							Name = "Main";
							Size = UDim2.new(1, 0,0, 158);
							Position = UDim2.new(0, 0,0.081, 0);
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = framewindow;
						})

						local uillmain = library:Create("UIListLayout", {
							Name = "UIListLayout";
							FillDirection = Enum.FillDirection.Horizontal;
							SortOrder = Enum.SortOrder.LayoutOrder;
							HorizontalAlignment = Enum.HorizontalAlignment.Center;
							VerticalAlignment = Enum.VerticalAlignment.Center;
							Padding = UDim.new(0, 5);
							Parent = main;
						})

						local h, s, v = color:ToHSV()
						local UIS = game:GetService("UserInputService")

						local huebox = library:Create("Frame", {
							Name = "HueBox";
							Size = UDim2.new(0.576, 50,0.94, 0);
							BackgroundColor3 = Color3.fromHSV(h, 1, 1);
							ZIndex = 2;
							Parent = main;
						})

						local helight = library:Create("Frame", {
							Name = "HueBox2";
							Size = UDim2.new(1,0,1,0);
							BackgroundColor3 = Color3.new(1, 1, 1);
							ZIndex = 3;
							Parent = huebox;
						})

						local huelightgrad = library:Create("UIGradient", {
							Name = "grad";
							Parent = helight;

							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(1, 1),
							})
						})

						local huedark = library:Create("Frame", {
							Name = "HueBox3";
							Size = UDim2.new(1,0,1,0);
							BackgroundColor3 = Color3.new(0, 0, 0);
							ZIndex = 3;
							Parent = huebox;
						})

						local huedarkgrad = library:Create("UIGradient", {
							Name = "grad";
							Parent = huedark;

							Rotation = 90,
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(1, 0),
							}),
						})

						local shiftbox = library:Create("Frame", {
							Name = "shiftbox";
							Size = UDim2.new(-0.057, 50,0.94, 0);
							BackgroundColor3 = Color3.new(1,1,1);
							ZIndex = 2;
							LayoutOrder = 2;
							Parent = main;
						})

						local rainbow = {}
						for i = 0, 6 do
							table.insert(rainbow, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
						end

						local shiftgrad = library:Create("UIGradient", {
							Name = "grad";
							Rotation = 90;
							Color = ColorSequence.new(rainbow);
							Parent = shiftbox;
						})

						local transparencybox = library:Create("Frame", {
							Name = "TransparencyBox";
							Size = UDim2.new(-0.057, 50,0.94, 0);
							BackgroundColor3 = Color3.new(1,1,1);
							ZIndex = 2;
							LayoutOrder = 3;
							Parent = main;
						})

						local imagetrans = library:Create("ImageLabel", {
							Name = "ImageLabel";
							Size = UDim2.new(1,0,1,0);
							BackgroundColor3 = Color3.new(1,1,1);
							Parent = transparencybox;
							Image = "rbxassetid://155451930";
							ScaleType = Enum.ScaleType.Tile;
							TileSize = UDim2.new(1, 0,0.3, 0);
						})

						local transfade = library:Create("Frame", {
							Name = "Fade";
							Size = UDim2.new(1,0,1,0);
							BackgroundColor3 = color;
							ZIndex = 3;
							Parent = transparencybox;
						})

						local transfadegrad = library:Create("UIGradient", {
							Name = "grad";
							Rotation = 90;
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(1, 1),
							});
							Parent = transfade;
						})

						local function refresh()
							color = Color3.fromHSV(h, s, v)
							colorbox.BackgroundColor3 = color
							colorsboxcolor.BackgroundColor3 = color
							huebox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
							transfade.BackgroundColor3 = color
							huecoloreditbox.Text = rgbText(color)
							hexditbox.Text = color:ToHex()
							transditbox.Text = tostring(math.floor(transparency * 100 + 0.5) / 100)
							OnChange(color, transparency, pointPosition)
						end

						local function makeSlider(box, start, onChange)
							box.Active = true

							local bar = library:Create("Frame", {
								Name = "Bar";
								Size = UDim2.new(1, 4,0, 3);
								AnchorPoint = Vector2.new(0.5, 0.5);
								Position = UDim2.new(0.5, 0,start, 0);
								BackgroundColor3 = Color3.new(1, 1, 1);
								ZIndex = 5;
								Parent = box;
							})

							local barstroke = library:Create("UIStroke", {
								Name = "UIStroke";
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
								Color = Color3.new(0, 0, 0);
								Thickness = 1;
								Parent = bar;
							})

							local moveConn, endConn

							local function stop()
								if moveConn then moveConn:Disconnect() moveConn = nil end
								if endConn then endConn:Disconnect() endConn = nil end
							end

							local function update(input)
								local a = math.clamp((input.Position.Y - box.AbsolutePosition.Y) / box.AbsoluteSize.Y, 0, 1)
								bar.Position = UDim2.new(0.5, 0,a, 0)
								onChange(a)
							end

							box.InputBegan:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
									stop()
									update(input)

									moveConn = UIS.InputChanged:Connect(function(i)
										if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
											update(i)
										end
									end)

									endConn = UIS.InputEnded:Connect(function(i)
										if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
											stop()
										end
									end)
								end
							end)

							return function(a)
								bar.Position = UDim2.new(0.5, 0,a, 0)
							end
						end

						local setHueBar = makeSlider(shiftbox, h, function(a)
							h = a
							refresh()
						end)

						local setTransBar = makeSlider(transparencybox, transparency, function(a)
							transparency = a
							refresh()
						end)

						local cursor = library:Create("Frame", {
							Name = "Cursor";
							Size = UDim2.new(0, 8,0, 8);
							AnchorPoint = Vector2.new(0.5, 0.5);
							Position = UDim2.new(s, 0,1 - v, 0);
							BackgroundColor3 = Color3.new(1, 1, 1);
							ZIndex = 6;
							Parent = huebox;
						})

						local cursorcorner = library:Create("UICorner", {
							CornerRadius = UDim.new(1, 0);
							Parent = cursor;
						})

						local cursorstroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							Color = Color3.new(0, 0, 0);
							Thickness = 1;
							Parent = cursor;
						})

						local function setCursor(ns, nv)
							cursor.Position = UDim2.new(ns, 0,1 - nv, 0)
						end

						do
							huedark.Active = true
							local moveConn, endConn

							local function stop()
								if moveConn then moveConn:Disconnect() moveConn = nil end
								if endConn then endConn:Disconnect() endConn = nil end
							end

							local function update(input)
								local pos, size = huebox.AbsolutePosition, huebox.AbsoluteSize
								s = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
								v = 1 - math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
								setCursor(s, v)
								refresh()
							end

							huedark.InputBegan:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
									stop()
									update(input)

									moveConn = UIS.InputChanged:Connect(function(i)
										if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
											update(i)
										end
									end)

									endConn = UIS.InputEnded:Connect(function(i)
										if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
											stop()
										end
									end)
								end
							end)
						end

						huecoloreditbox.FocusLost:Connect(function()
							local r, g, b = huecoloreditbox.Text:match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")
							r, g, b = tonumber(r), tonumber(g), tonumber(b)

							if r and g and b then
								local c = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
								h, s, v = c:ToHSV()
								setHueBar(h)
								setCursor(s, v)
								refresh()
							else
								huecoloreditbox.Text = rgbText(color)
							end
						end)

						outsideConn = game:GetService("UserInputService").InputBegan:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
								return
							end

							local function isInside(gui)
								local pos, size = gui.AbsolutePosition, gui.AbsoluteSize
								local m = input.Position
								return m.X >= pos.X and m.X <= pos.X + size.X and m.Y >= pos.Y and m.Y <= pos.Y + size.Y
							end

							if isInside(framewindow) or isInside(colorbox) then
								return
							end

							colorpicker:Close()
						end)

					end

					function colorpicker:Close()
						if not opened then return end
						opened = false

						if followConn then
							followConn:Disconnect()
							followConn = nil
						end

						if outsideConn then
							outsideConn:Disconnect()
							outsideConn = nil
						end

						if instance then
							instance:Destroy()
							instance = nil
						end
					end

					hitbox.Activated:Connect(function()
						if opened then
							colorpicker:Close()
						else
							Createcolorpickerbox()
						end
					end)

					function colorpicker:AddColorPicker(name, opts)
						return label:AddColorPicker(name, opts)
					end

					library.windowinstances.Colorbox = colorpicker

					return colorpicker
				end

				function label:AddKeyPicker(name, opts)
					if type(name) == "table" then
						opts = name
						name = uitext.Text
					end

					opts = opts or {}

					local picker = {}
					local InputService = InputService or game:GetService("UserInputService")

					local function resolvekey(k)
						if typeof(k) == "EnumItem" then
							return k
						end

						if type(k) == "string" then
							local ok, res = pcall(function()
								return Enum.KeyCode[k]
							end)
							if ok then
								return res
							end
						end

						return nil
					end

					local currentkey = resolvekey(opts.Default)
					local Mode = opts.Mode or "Hold"
					local modes = {"Hold", "Toggle", "Always"}

					local opened = false
					local instance
					local followConn
					local outsideConn
					local waitkeyconn

					local waiting_for_key = false

					local winkeytext
					local winmodetext

					local ignoredkeys = {
						library.Menukey;
						Enum.KeyCode.Return,
						Enum.KeyCode.End,
						Enum.KeyCode.Home,
						Enum.KeyCode.PageUp,
						Enum.KeyCode.PageDown,
					}

					local ignoredset = {}
					for _, k in next, ignoredkeys do
						if k then
							ignoredset[k] = true
						end
					end

					if RestrictedKeypicker then
						error("Restricted your using a colorpicker!")
						return
					end

					if keypicker then
						warn("KeyPicker already exists for this label")
						return
					end

					keypicker = picker
					RestrictedColorpicker = true

					picker.Key = currentkey
					picker.Mode = Mode
					picker.OnChanged = newSignal()
					Options[name] = picker

					local keyframe = library:Create("Frame", {
						Name = "KeyPicker",
						Size = UDim2.new(0, 50, 0, 15),
						LayoutOrder = #holder2:GetChildren();
						BackgroundColor3 = library.MainColor,
						Parent = holder2;
					},{
						instancep = "BackgroundColor3";
						tinstance = library.MainColor;
					})

					local uistrokekey = library:Create("UIStroke", {
						Name = "UIStroke",
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = library.SecondaryColor,
						Thickness = 1,
						Parent = keyframe,
					},{
						instancep = "Color";
						tinstance = library.SecondaryColor;
					})

					local keybox = library:Create("TextButton", {
						Name = "KeyBox",
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = "",
						ZIndex = 4,
						Parent = keyframe,
					})

					local keytext = library:Create("TextLabel", {
						Name = "KeyText",
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = "None",
						TextColor3 = library.FontColor,
						TextSize = 13,
						Font = library.Font,
						TextXAlignment = Enum.TextXAlignment.Center,
						Parent = keyframe,
					},{
						instancep = "TextColor3";
						tinstance = library.FontColor;
					}, {
						instancep = "Font";
						tinstance = library.Font;
					})

					local active = false
					picker.Value = false

					local function setState(state)
						if active == state then return end
						active = state
						picker.Value = state

						if opts.Callback then
							opts.Callback(state)
						end
					end

					local function updatetexts()
						local t
						if waiting_for_key then
							t = "..."
						elseif currentkey then
							t = keyshorts[currentkey] or currentkey.Name
						else
							t = "None"
						end

						keytext.Text = t
						if winkeytext then
							winkeytext.Text = t
						end
						if winmodetext then
							winmodetext.Text = Mode
						end
					end

					local function setKey(k)
						currentkey = k
						picker.Key = k
						updatetexts()

						if opts.CallbackKey then
							opts.CallbackKey(k)
						end

						picker.OnChanged:Fire(currentkey, Mode)
					end

					local function setMode(m)
						Mode = m
						picker.Mode = m
						updatetexts()

						setState(m == "Always")

						if opts.CallbackMode then
							opts.CallbackMode(m)
						end

						picker.OnChanged:Fire(currentkey, Mode)
					end

					local function startbind()
						if waiting_for_key then
							return
						end

						waiting_for_key = true
						updatetexts()

						waitkeyconn = InputService.InputBegan:Connect(function(input, gameproccessed)
							if gameproccessed then return end
							if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
							if ignoredset[input.KeyCode] then return end

							if waitkeyconn then
								waitkeyconn:Disconnect()
								waitkeyconn = nil
							end

							task.defer(function()
								waiting_for_key = false
								updatetexts()
							end)

							if input.KeyCode == Enum.KeyCode.Backspace then
								setKey(nil)
							else
								setKey(input.KeyCode)
							end
						end)
					end

					local function openminiwindow()
						opened = true

						local function getPos()
							local abs = keyframe.AbsolutePosition
							local base = screengui.AbsolutePosition
							return UDim2.new(0, abs.X - base.X, 0, abs.Y - base.Y)
						end

						local cursorbox = library:Create("Frame", {
							Name = "CursorBox";
							Size = UDim2.new(0, 15,0, 15);
							Position = getPos();
							BackgroundColor3 = Color3.new(1,1,1);
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = screengui;
						})

						instance = cursorbox

						followConn = keyframe:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
							if instance then
								instance.Position = getPos()
							end
						end)

						local framewindow = library:Create("Frame", {
							Name = "Frame";
							Size = UDim2.new(0, 323,0, 93);
							Position = UDim2.new(1, 0,1.4, 0);
							BackgroundColor3 = library.MainColor;
							ZIndex = 2;
							Parent = cursorbox;
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local uistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							LineJoinMode = Enum.LineJoinMode.Miter;
							Color = library.SecondaryColor;
							Thickness = 1;
							Parent = framewindow;
						}, {
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local uistroke2 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							LineJoinMode = Enum.LineJoinMode.Miter;
							Color = library.MainColor;
							Thickness = 4;
							Parent = framewindow;
						}, {
							instancep = "Color";
							tinstance = library.MainColor;
						})

						local text = library:Create("TextLabel", {
							Name = "TextLabel";
							Size = UDim2.new(1, 0,0, 16);
							Position = UDim2.new(0, 0,0, 0);
							Text = name;
							TextColor3 = library.FontColor;
							Font = library.Font;
							TextSize = 13;
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = framewindow;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local textuistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = text;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local textuisize = library:Create("UITextSizeConstraint", {
							Name = "UISizeConstraint";
							MaxTextSize = 13;
							Parent = text;
						})

						local holder = library:Create("Frame", {
							Name = "Holder";
							Size = UDim2.new(1, 0,-0.228, 96);
							Position = UDim2.new(0, 0,0.195, 0);
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = framewindow;
						})

						local uill = library:Create("UIListLayout", {
							Name = "UIListLayout";
							Padding = UDim.new(0, 5);
							SortOrder = Enum.SortOrder.LayoutOrder;
							FillDirection = Enum.FillDirection.Vertical;
							HorizontalAlignment = Enum.HorizontalAlignment.Center;
							VerticalAlignment = Enum.VerticalAlignment.Top;
							Parent = holder;
						})

						local uipadd = library:Create("UIPadding", {
							Name = "UIPadding";
							PaddingLeft = UDim.new(0, 0);
							PaddingRight = UDim.new(0, 0);
							PaddingTop = UDim.new(0, 3);
							PaddingBottom = UDim.new(0, 0);
							Parent = holder;
						})

						local keysetbind = library:Create("Frame", {
							Name = "KeysetBind";
							Size = UDim2.new(.95, 0,0, 20);
							BackgroundTransparency = 1;
							LayoutOrder = 1;
							Parent = holder;
							ZIndex = 2;
						})

						local keybindsetuil = library:Create("UIListLayout", {
							Name = "UIListLayout";
							Padding = UDim.new(0, 0);
							SortOrder = Enum.SortOrder.LayoutOrder;
							FillDirection = Enum.FillDirection.Horizontal;
							HorizontalAlignment = Enum.HorizontalAlignment.Left;
							VerticalAlignment = Enum.VerticalAlignment.Center;
							Parent = keysetbind;
						})

						local keylabelset = library:Create("TextLabel", {
							Name = "KeyLabel";
							Size = UDim2.new(1, -55,1, 0);
							BackgroundTransparency = 1;
							Text = "Keybind";
							TextColor3 = library.FontColor;
							TextSize = 13;
							TextXAlignment = Enum.TextXAlignment.Left;
							TextYAlignment = Enum.TextYAlignment.Center;
							Font = library.Font;
							LayoutOrder = 1;
							ZIndex = 2;
							Parent = keysetbind;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local labeluistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = keylabelset;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local labeltsize = library:Create("UITextSizeConstraint", {
							Name = "UITextSizeConstraint";
							MaxTextSize = 13;
							Parent = keylabelset;
						})

						local winkeyframe = library:Create("Frame", {
							Name = "KeyPicker",
							Size = UDim2.new(0, 50, 0, 15),
							LayoutOrder = 2;
							BackgroundColor3 = library.MainColor,
							ZIndex = 2;
							Parent = keysetbind,
						},{
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local winuistrokekey = library:Create("UIStroke", {
							Name = "UIStroke",
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = library.SecondaryColor,
							Thickness = 1,
							Parent = winkeyframe,
						},{
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local winkeybox = library:Create("TextButton", {
							Name = "KeyBox",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "",
							ZIndex = 3,
							Parent = winkeyframe,
						})

						winkeytext = library:Create("TextLabel", {
							Name = "KeyText",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "None",
							TextColor3 = library.FontColor,
							TextSize = 13,
							Font = library.Font,
							TextXAlignment = Enum.TextXAlignment.Center,
							ZIndex = 2,
							Parent = winkeyframe,
						},{
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})


						local modesetbind = library:Create("Frame", {
							Name = "ModesetBind";
							Size = UDim2.new(.95, 0,0, 20);
							BackgroundTransparency = 1;
							LayoutOrder = 2;
							Parent = holder;
							ZIndex = 2;
						})

						local modesetuil = library:Create("UIListLayout", {
							Name = "UIListLayout";
							Padding = UDim.new(0, 0);
							SortOrder = Enum.SortOrder.LayoutOrder;
							FillDirection = Enum.FillDirection.Horizontal;
							HorizontalAlignment = Enum.HorizontalAlignment.Left;
							VerticalAlignment = Enum.VerticalAlignment.Center;
							Parent = modesetbind;
						})

						local modelabelset = library:Create("TextLabel", {
							Name = "ModeLabel";
							Size = UDim2.new(1, -55,1, 0);
							BackgroundTransparency = 1;
							Text = "Mode";
							TextColor3 = library.FontColor;
							TextSize = 13;
							TextXAlignment = Enum.TextXAlignment.Left;
							TextYAlignment = Enum.TextYAlignment.Center;
							Font = library.Font;
							LayoutOrder = 1;
							ZIndex = 2;
							Parent = modesetbind;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local labelmuistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = modelabelset;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local labelmtsize = library:Create("UITextSizeConstraint", {
							Name = "UITextSizeConstraint";
							MaxTextSize = 13;
							Parent = modelabelset;
						})

						local modeframe = library:Create("Frame", {
							Name = "ModePicker",
							Size = UDim2.new(0, 50, 0, 15),
							LayoutOrder = 2;
							BackgroundColor3 = library.MainColor,
							ZIndex = 2;
							Parent = modesetbind,
						},{
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local uistrokemode = library:Create("UIStroke", {
							Name = "UIStroke",
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = library.SecondaryColor,
							Thickness = 1,
							Parent = modeframe,
						},{
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local Modebox = library:Create("TextButton", {
							Name = "ModeBox",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "",
							ZIndex = 3,
							Parent = modeframe,
						})

						winmodetext = library:Create("TextLabel", {
							Name = "ModeText",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = Mode,
							TextColor3 = library.FontColor,
							TextSize = 13,
							Font = library.Font,
							TextXAlignment = Enum.TextXAlignment.Center,
							ZIndex = 2,
							Parent = modeframe,
						},{
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local unbindbox = library:Create("Frame", {
							Name = "UnbindBox",
							Size = UDim2.new(0.95, 0,0, 15),
							LayoutOrder = 3,
							BackgroundColor3 = library.MainColor,
							ZIndex = 2,
							Parent = holder,
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local unbindstroke = library:Create("UIStroke", {
							Name = "UIStroke",
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = library.SecondaryColor,
							Thickness = 1,
							Parent = unbindbox,
						},{
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local unbindtext = library:Create("TextLabel", {
							Name = "UnbindText",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "Unbind",
							TextColor3 = library.FontColor,
							TextSize = 13,
							Font = library.Font,
							TextXAlignment = Enum.TextXAlignment.Center,
							ZIndex = 2,
							Parent = unbindbox,
						},{
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local unbindboxt = library:Create("TextButton", {
							Name = "UnbindBoxText",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "",
							ZIndex = 3,
							Parent = unbindbox,
						})

						winkeybox.MouseButton1Click:Connect(startbind)

						Modebox.MouseButton1Click:Connect(function()
							local index = table.find(modes, Mode) or 1
							setMode(modes[index % #modes + 1])
						end)

						unbindboxt.MouseButton1Click:Connect(function()
							setKey(nil)
						end)

						updatetexts()

						outsideConn = InputService.InputBegan:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
								return
							end

							local function isInside(gui)
								local pos, size = gui.AbsolutePosition, gui.AbsoluteSize
								local m = input.Position
								return m.X >= pos.X and m.X <= pos.X + size.X and m.Y >= pos.Y and m.Y <= pos.Y + size.Y
							end

							if isInside(framewindow) or isInside(keyframe) then
								return
							end

							picker:Close()
						end)
					end

					function picker:Close()
						if not opened then return end
						opened = false

						winkeytext = nil
						winmodetext = nil

						if followConn then
							followConn:Disconnect()
							followConn = nil
						end

						if outsideConn then
							outsideConn:Disconnect()
							outsideConn = nil
						end

						if instance then
							instance:Destroy()
							instance = nil
						end
					end

					keybox.MouseButton1Click:Connect(startbind)

					keybox.MouseButton2Click:Connect(function()
						if opened then
							picker:Close()
						else
							openminiwindow()
						end
					end)

					InputService.InputBegan:Connect(function(input, gameproccessed)
						if gameproccessed or waiting_for_key then return end
						if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
						if not currentkey or input.KeyCode ~= currentkey then return end

						if Mode == "Toggle" then
							setState(not active)
						elseif Mode == "Hold" then
							setState(true)
						end
					end)

					InputService.InputEnded:Connect(function(input)
						if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
						if not currentkey or input.KeyCode ~= currentkey then return end

						if Mode == "Hold" then
							setState(false)
						end
					end)

					updatetexts()

					if Mode == "Always" then
						setState(true)
					end

					library.windowinstances.Keybindbox = picker

					return picker
				end

				return label
			end

			function groupbox:AddToggle(name, opts)
				local toggle = {}
				local togglename = name
				local toggled = opts.Default

				if opts.Default == nil then
					toggled = false
				end

				toggle.Value = toggled

				local holder = library:Create("Frame", {
					Name = "Holder";
					Size = UDim2.new(0.95, 0,0, 20);
					BackgroundTransparency = 1;
					LayoutOrder = #elementsholder:GetChildren();
					Parent = elementsholder;
				})

				local hb = library:Create("TextButton", {
					Name = "Hitbox";
					Size = UDim2.new(1, 0, 1, 0);
					BackgroundTransparency = 1;
					ZIndex = 2;
					Text = "";
					Parent = holder;
				})

				local elements = library:Create("Frame", {
					Name = "Holder2";
					Size = UDim2.new(1,0,1,0);
					BackgroundTransparency = 1;
					Parent = holder;
				})

				local uilistlayout = library:Create("UIListLayout", {
					Name = "UIListLayout";
					FillDirection = Enum.FillDirection.Horizontal;
					HorizontalAlignment = Enum.HorizontalAlignment.Left;
					SortOrder = Enum.SortOrder.LayoutOrder;
					VerticalAlignment = Enum.VerticalAlignment.Center;
					Padding = UDim.new(0, 0);
					Parent = elements;
				})

				local boxelem = library:Create("Frame", {
					Name = "Box";
					Size = UDim2.new(0, 15, 0, 15);
					BackgroundColor3 = library.AccentColor;
					BackgroundTransparency = 1;
					LayoutOrder = 1;
					Parent = elements;
				}, {
					instancep = "BackgroundColor3";
					tinstance = library.AccentColor;
				})

				local uis1 = library:Create("UIStroke", {
					Name = "UIStroke";
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
					LineJoinMode = Enum.LineJoinMode.Miter;
					Color = library.SecondaryColor;
					Thickness = 1;

					Parent = boxelem;
				}, {
					instancep = "Color";
					tinstance = library.SecondaryColor;
				})

				local label = library:Create("TextLabel", {
					Name = "Label";
					Size = UDim2.new(0.772, 0, 1, 0);
					BackgroundTransparency = 1;
					Text = name;
					TextColor3 = library.FontColor;
					Font = library.Font;
					TextSize = 13;
					TextXAlignment = Enum.TextXAlignment.Left;
					LayoutOrder = 2;
					TextYAlignment = Enum.TextYAlignment.Center;
					Parent = elements;
				}, {
					instancep = "TextColor3";
					tinstance = library.FontColor;
				}, {
					instancep = "Font";
					tinstance = library.Font;
				})

				local luip = library:Create("UIPadding", {
					Name = "UIPadding";
					PaddingLeft = UDim.new(0, 7);
					PaddingRight = UDim.new(0, 0);
					PaddingTop = UDim.new(0, 0);
					PaddingBottom = UDim.new(0, 0);
					Parent = label;
				})

				local luis = library:Create("UIStroke", {
					Name = "UIStroke";
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
					Color = library.UIstroke;
					Thickness = 1;

					Parent = label;
				}, {
					instancep = "Color";
					tinstance = library.UIstroke;
				})

				local luitextsize = library:Create("UITextSizeConstraint", {
					Name = "UITextSizeConstraint";
					MaxTextSize = 13;
					Parent = label;
				})

				if toggled then
					boxelem.BackgroundTransparency = 0
				end

				local function togglef()
					toggled = not toggled

					if toggled then
						boxelem.BackgroundTransparency = 0
					else
						boxelem.BackgroundTransparency = 1
					end

					Toggles[togglename].value = toggled
					toggle.Value = toggled

					if opts.Callback then
						opts.Callback(toggled)
					end

					if library.UpdateDependencyBoxes then
						library:UpdateDependencyBoxes()
					end
				end

				hb.MouseButton1Click:Connect(togglef)

				Toggles[togglename] = {
					value = toggled;
					keypicker = nil;
				}

				function toggle:AddKeyPicker(name, opts)
					if type(name) == "table" then
						opts = name
						name = togglename
					end

					opts = opts or {}

					local keypicker = {}
					local InputService = InputService or game:GetService("UserInputService")

					local function resolvekey(k)
						if typeof(k) == "EnumItem" then
							return k
						end

						if type(k) == "string" then
							local ok, res = pcall(function()
								return Enum.KeyCode[k]
							end)
							if ok then
								return res
							end
						end

						return nil
					end

					local currentkey = resolvekey(opts.Default)
					local Mode = opts.Mode or "Hold"
					local modes = {"Hold", "Toggle", "Always"}

					local opened = false
					local instance
					local followConn
					local outsideConn
					local waitkeyconn

					local waiting_for_key = false

					local winkeytext
					local winmodetext

					local ignoredkeys = {
						library.Menukey;
						Enum.KeyCode.Return,
						Enum.KeyCode.End,
						Enum.KeyCode.Home,
						Enum.KeyCode.PageUp,
						Enum.KeyCode.PageDown,
					}

					local ignoredset = {}
					for _, k in next, ignoredkeys do
						if k then
							ignoredset[k] = true
						end
					end

					if not Toggles[togglename].keypicker then
						Toggles[togglename].keypicker = keypicker
					else
						warn("KeyPicker already exists for toggle: "..togglename)
						return 
					end

					keypicker.Key = currentkey
					keypicker.Mode = Mode
					keypicker.OnChanged = newSignal()
					Options[name] = keypicker

					local keyframe = library:Create("Frame", {
						Name = "KeyPicker",
						Size = UDim2.new(0, 50, 0, 15),
						LayoutOrder = 999;
						BackgroundColor3 = library.MainColor,
						Parent = elements;
					},{
						instancep = "BackgroundColor3";
						tinstance = library.MainColor;
					})

					local uistrokekey = library:Create("UIStroke", {
						Name = "UIStroke",
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = library.SecondaryColor,
						Thickness = 1,
						Parent = keyframe,
					},{
						instancep = "Color";
						tinstance = library.SecondaryColor;
					})

					local keybox = library:Create("TextButton", {
						Name = "KeyBox",
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = "",
						ZIndex = 4,
						Parent = keyframe,
					})

					local keytext = library:Create("TextLabel", {
						Name = "KeyText",
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = "None",
						TextColor3 = library.FontColor,
						TextSize = 13,
						Font = library.Font,
						TextXAlignment = Enum.TextXAlignment.Center,
						Parent = keyframe,
					},{
						instancep = "TextColor3";
						tinstance = library.FontColor;
					}, {
						instancep = "Font";
						tinstance = library.Font;
					})

					local function setState(state)
						if toggled == state then return end
						togglef()
						Toggles[togglename].value = toggled
					end

					local function updatetexts()
						local t
						if waiting_for_key then
							t = "..."
						elseif currentkey then
							t = keyshorts[currentkey] or currentkey.Name
						else
							t = "None"
						end

						keytext.Text = t
						if winkeytext then
							winkeytext.Text = t
						end
						if winmodetext then
							winmodetext.Text = Mode
						end
					end

					local function setKey(k)
						currentkey = k
						keypicker.Key = k
						updatetexts()

						if opts.CallbackKey then
							opts.CallbackKey(k)
						end

						keypicker.OnChanged:Fire(currentkey, Mode)
					end

					local function setMode(m)
						Mode = m
						keypicker.Mode = m
						updatetexts()

						setState(m == "Always")

						if opts.CallbackMode then
							opts.CallbackMode(m)
						end

						keypicker.OnChanged:Fire(currentkey, Mode)
					end

					local function startbind()
						if waiting_for_key then
							return
						end

						waiting_for_key = true
						updatetexts()

						waitkeyconn = InputService.InputBegan:Connect(function(input, gameproccessed)
							if gameproccessed then return end
							if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
							if ignoredset[input.KeyCode] then return end

							if waitkeyconn then
								waitkeyconn:Disconnect()
								waitkeyconn = nil
							end

							task.defer(function()
								waiting_for_key = false
								updatetexts()
							end)

							if input.KeyCode == Enum.KeyCode.Backspace then
								setKey(nil)
							else
								setKey(input.KeyCode)
							end
						end)
					end

					local function openminiwindow()
						opened = true

						local function getPos()
							local abs = keyframe.AbsolutePosition
							local base = screengui.AbsolutePosition
							return UDim2.new(0, abs.X - base.X, 0, abs.Y - base.Y)
						end

						local cursorbox = library:Create("Frame", {
							Name = "CursorBox";
							Size = UDim2.new(0, 15,0, 15);
							Position = getPos();
							BackgroundColor3 = Color3.new(1,1,1);
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = screengui;
						})

						instance = cursorbox

						followConn = keyframe:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
							if instance then
								instance.Position = getPos()
							end
						end)

						local framewindow = library:Create("Frame", {
							Name = "Frame";
							Size = UDim2.new(0, 323,0, 93);
							Position = UDim2.new(1, 0,1.4, 0);
							BackgroundColor3 = library.MainColor;
							ZIndex = 2;
							Parent = cursorbox;
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local uistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							LineJoinMode = Enum.LineJoinMode.Miter;
							Color = library.SecondaryColor;
							Thickness = 1;
							Parent = framewindow;
						}, {
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local uistroke2 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							LineJoinMode = Enum.LineJoinMode.Miter;
							Color = library.MainColor;
							Thickness = 4;
							Parent = framewindow;
						}, {
							instancep = "Color";
							tinstance = library.MainColor;
						})

						local text = library:Create("TextLabel", {
							Name = "TextLabel";
							Size = UDim2.new(1, 0,0, 16);
							Position = UDim2.new(0, 0,0, 0);
							Text = name;
							TextColor3 = library.FontColor;
							Font = library.Font;
							TextSize = 13;
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = framewindow;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local textuistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = text;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local textuisize = library:Create("UITextSizeConstraint", {
							Name = "UISizeConstraint";
							MaxTextSize = 13;
							Parent = text;
						})

						local holder = library:Create("Frame", {
							Name = "Holder";
							Size = UDim2.new(1, 0,-0.228, 96);
							Position = UDim2.new(0, 0,0.195, 0);
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = framewindow;
						})

						local uill = library:Create("UIListLayout", {
							Name = "UIListLayout";
							Padding = UDim.new(0, 5);
							SortOrder = Enum.SortOrder.LayoutOrder;
							FillDirection = Enum.FillDirection.Vertical;
							HorizontalAlignment = Enum.HorizontalAlignment.Center;
							VerticalAlignment = Enum.VerticalAlignment.Top;
							Parent = holder;
						})

						local uipadd = library:Create("UIPadding", {
							Name = "UIPadding";
							PaddingLeft = UDim.new(0, 0);
							PaddingRight = UDim.new(0, 0);
							PaddingTop = UDim.new(0, 3);
							PaddingBottom = UDim.new(0, 0);
							Parent = holder;
						})

						local keysetbind = library:Create("Frame", {
							Name = "KeysetBind";
							Size = UDim2.new(.95, 0,0, 20);
							BackgroundTransparency = 1;
							LayoutOrder = 1;
							Parent = holder;
							ZIndex = 2;
						})

						local keybindsetuil = library:Create("UIListLayout", {
							Name = "UIListLayout";
							Padding = UDim.new(0, 0);
							SortOrder = Enum.SortOrder.LayoutOrder;
							FillDirection = Enum.FillDirection.Horizontal;
							HorizontalAlignment = Enum.HorizontalAlignment.Left;
							VerticalAlignment = Enum.VerticalAlignment.Center;
							Parent = keysetbind;
						})

						local keylabelset = library:Create("TextLabel", {
							Name = "KeyLabel";
							Size = UDim2.new(1, -55,1, 0);
							BackgroundTransparency = 1;
							Text = "Keybind";
							TextColor3 = library.FontColor;
							TextSize = 13;
							TextXAlignment = Enum.TextXAlignment.Left;
							TextYAlignment = Enum.TextYAlignment.Center;
							Font = library.Font;
							LayoutOrder = 1;
							ZIndex = 2;
							Parent = keysetbind;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local labeluistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = keylabelset;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local labeltsize = library:Create("UITextSizeConstraint", {
							Name = "UITextSizeConstraint";
							MaxTextSize = 13;
							Parent = keylabelset;
						})

						local winkeyframe = library:Create("Frame", {
							Name = "KeyPicker",
							Size = UDim2.new(0, 50, 0, 15),
							LayoutOrder = 2;
							BackgroundColor3 = library.MainColor,
							ZIndex = 2;
							Parent = keysetbind,
						},{
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local winuistrokekey = library:Create("UIStroke", {
							Name = "UIStroke",
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = library.SecondaryColor,
							Thickness = 1,
							Parent = winkeyframe,
						},{
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local winkeybox = library:Create("TextButton", {
							Name = "KeyBox",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "",
							ZIndex = 3,
							Parent = winkeyframe,
						})

						winkeytext = library:Create("TextLabel", {
							Name = "KeyText",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "None",
							TextColor3 = library.FontColor,
							TextSize = 13,
							Font = library.Font,
							TextXAlignment = Enum.TextXAlignment.Center,
							ZIndex = 2,
							Parent = winkeyframe,
						},{
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})


						local modesetbind = library:Create("Frame", {
							Name = "ModesetBind";
							Size = UDim2.new(.95, 0,0, 20);
							BackgroundTransparency = 1;
							LayoutOrder = 2;
							Parent = holder;
							ZIndex = 2;
						})

						local modesetuil = library:Create("UIListLayout", {
							Name = "UIListLayout";
							Padding = UDim.new(0, 0);
							SortOrder = Enum.SortOrder.LayoutOrder;
							FillDirection = Enum.FillDirection.Horizontal;
							HorizontalAlignment = Enum.HorizontalAlignment.Left;
							VerticalAlignment = Enum.VerticalAlignment.Center;
							Parent = modesetbind;
						})

						local modelabelset = library:Create("TextLabel", {
							Name = "ModeLabel";
							Size = UDim2.new(1, -55,1, 0);
							BackgroundTransparency = 1;
							Text = "Mode";
							TextColor3 = library.FontColor;
							TextSize = 13;
							TextXAlignment = Enum.TextXAlignment.Left;
							TextYAlignment = Enum.TextYAlignment.Center;
							Font = library.Font;
							LayoutOrder = 1;
							ZIndex = 2;
							Parent = modesetbind;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local labelmuistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = modelabelset;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local labelmtsize = library:Create("UITextSizeConstraint", {
							Name = "UITextSizeConstraint";
							MaxTextSize = 13;
							Parent = modelabelset;
						})

						local modeframe = library:Create("Frame", {
							Name = "ModePicker",
							Size = UDim2.new(0, 50, 0, 15),
							LayoutOrder = 2;
							BackgroundColor3 = library.MainColor,
							ZIndex = 2;
							Parent = modesetbind,
						},{
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local uistrokemode = library:Create("UIStroke", {
							Name = "UIStroke",
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = library.SecondaryColor,
							Thickness = 1,
							Parent = modeframe,
						},{
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local Modebox = library:Create("TextButton", {
							Name = "ModeBox",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "",
							ZIndex = 3,
							Parent = modeframe,
						})

						winmodetext = library:Create("TextLabel", {
							Name = "ModeText",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = Mode,
							TextColor3 = library.FontColor,
							TextSize = 13,
							Font = library.Font,
							TextXAlignment = Enum.TextXAlignment.Center,
							ZIndex = 2,
							Parent = modeframe,
						},{
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local unbindbox = library:Create("Frame", {
							Name = "UnbindBox",
							Size = UDim2.new(0.95, 0,0, 15),
							LayoutOrder = 3,
							BackgroundColor3 = library.MainColor,
							ZIndex = 2,
							Parent = holder,
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local unbindstroke = library:Create("UIStroke", {
							Name = "UIStroke",
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = library.SecondaryColor,
							Thickness = 1,
							Parent = unbindbox,
						},{
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local unbindtext = library:Create("TextLabel", {
							Name = "UnbindText",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "Unbind",
							TextColor3 = library.FontColor,
							TextSize = 13,
							Font = library.Font,
							TextXAlignment = Enum.TextXAlignment.Center,
							ZIndex = 2,
							Parent = unbindbox,
						},{
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local unbindboxt = library:Create("TextButton", {
							Name = "UnbindBoxText",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "",
							ZIndex = 3,
							Parent = unbindbox,
						})

						winkeybox.MouseButton1Click:Connect(startbind)

						Modebox.MouseButton1Click:Connect(function()
							local index = table.find(modes, Mode) or 1
							setMode(modes[index % #modes + 1])
						end)

						unbindboxt.MouseButton1Click:Connect(function()
							setKey(nil)
						end)

						updatetexts()

						outsideConn = InputService.InputBegan:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
								return
							end

							local function isInside(gui)
								local pos, size = gui.AbsolutePosition, gui.AbsoluteSize
								local m = input.Position
								return m.X >= pos.X and m.X <= pos.X + size.X and m.Y >= pos.Y and m.Y <= pos.Y + size.Y
							end

							if isInside(framewindow) or isInside(keyframe) then
								return
							end

							keypicker:Close()
						end)
					end

					function keypicker:Close()
						if not opened then return end
						opened = false

						winkeytext = nil
						winmodetext = nil

						if followConn then
							followConn:Disconnect()
							followConn = nil
						end

						if outsideConn then
							outsideConn:Disconnect()
							outsideConn = nil
						end

						if instance then
							instance:Destroy()
							instance = nil
						end
					end

					keybox.MouseButton1Click:Connect(startbind)

					keybox.MouseButton2Click:Connect(function()
						if opened then
							keypicker:Close()
						else
							openminiwindow()
						end
					end)

					InputService.InputBegan:Connect(function(input, gameproccessed)
						if gameproccessed or waiting_for_key then return end
						if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
						if not currentkey or input.KeyCode ~= currentkey then return end

						if Mode == "Toggle" then
							setState(not toggled)
						elseif Mode == "Hold" then
							setState(true)
						end
					end)

					InputService.InputEnded:Connect(function(input)
						if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
						if not currentkey or input.KeyCode ~= currentkey then return end

						if Mode == "Hold" then
							setState(false)
						end
					end)

					updatetexts()

					if Mode == "Always" then
						setState(true)
					end

					library.windowinstances.Keybindbox = keypicker

					return keypicker
				end

				return toggle
			end

			function groupbox:AddSlider(name, opts)
				opts = opts or {}

				local slider = {}
				local UIS = InputService

				local config = {
					Minimum = opts.Minimum;
					Maximum = opts.Maximum;
					DefaultValue = opts.Default;
					Step = opts.Step;
					Format = opts.Format;
				}

				local range = config.Maximum - config.Minimum
				if range <= 0 then
					range = 1
				end

				local stepsize = config.Step > 0 and config.Step

				local function decimalsof(n)
					local d = tostring(n):match("%.(%d+)")
					return d and #d or 0
				end

				local decimals = opts.Rounding or math.max(decimalsof(stepsize), decimalsof(config.Minimum))

				local currentvalue = config.Minimum
				local dragging = false

				local mainframe = library:Create("Frame", {
					Name = "Slider",
					Size = UDim2.new(0.95, 0, 0, 20),
					BackgroundTransparency = 1,
					LayoutOrder = #elementsholder:GetChildren(),
					Parent = elementsholder,
				})
				
				if opts.Smaller then
					mainframe.Size = UDim2.new(0.465, 0, 0, 15)
				end

				local uistroke = library:Create("UIStroke", {
					Name = "UIStroke",
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = library.SecondaryColor,
					Thickness = 1,
					LineJoinMode = Enum.LineJoinMode.Miter,
					Parent = mainframe,
				}, {
					instancep = "Color";
					tinstance = library.SecondaryColor;
				})

				local frame = library:Create("Frame", {
					Name = "Frame",
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundColor3 = library.AccentColor,
					Parent = mainframe,
				}, {
					instancep = "BackgroundColor3";
					tinstance = library.AccentColor;
				})

				local hitbox = library:Create("TextButton", {
					Name = "Hitbox",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					ZIndex = 3,
					Parent = mainframe,
				})

				local text = library:Create("TextLabel", {
					Name = "Text",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = name,
					TextColor3 = library.FontColor,
					Font = library.Font,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					ZIndex = 2,
					Parent = mainframe,
				}, {
					instancep = "TextColor3";
					tinstance = library.FontColor;
				}, {
					instancep = "Font";
					tinstance = library.Font;
				})

				local uistoke2 = library:Create("UIStroke", {
					Name = "UIStroke",
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
					Color = library.UIstroke,
					Thickness = 1,
					LineJoinMode = Enum.LineJoinMode.Round,
					Parent = text,
				}, {
					instancep = "Color";
					tinstance = library.UIstroke;
				})

				local textuisize = library:Create("UITextSizeConstraint", {
					Name = "UITextSizeConstraint",
					MaxTextSize = 13,
					Parent = text,
				})

				local function fmt(n)
					return tostring(n)
				end

				local function refreshui()
					local alpha = (currentvalue - config.Minimum) / range
					frame.Size = UDim2.new(math.clamp(alpha, 0, 1), 0, 1, 0)

					local suffix = ""
					if config.Format ~= "" then
						suffix = " " .. config.Format
					end

					text.Text = name .. ": " .. fmt(currentvalue) .. "/" .. fmt(config.Maximum) .. suffix
				end

				local function setvalue(v, silent)
					v = math.clamp(v, config.Minimum, config.Maximum)
					v = config.Minimum + math.floor((v - config.Minimum) / stepsize + 0.5) * stepsize
					v = math.clamp(v, config.Minimum, config.Maximum)
					v = tonumber(string.format("%." .. decimals .. "f", v))

					local changed = v ~= currentvalue
					currentvalue = v
					slider.Value = v
					refreshui()

					if changed and not silent then
						if opts.Callback then
							opts.Callback(v)
						end

						slider.OnChanged:Fire(v)
					end
				end

				slider.Value = currentvalue
				slider.OnChanged = newSignal()
				Options[name] = slider

				function slider:SetValue(v)
					setvalue(v)
				end

				function slider:GetValue()
					return currentvalue
				end

				setvalue(config.DefaultValue, true)

				local moveConn
				local endConn

				local function stop()
					dragging = false

					if moveConn then
						moveConn:Disconnect()
						moveConn = nil
					end

					if endConn then
						endConn:Disconnect()
						endConn = nil
					end
				end

				local function drag(input)
					local pos, size = mainframe.AbsolutePosition, mainframe.AbsoluteSize
					local alpha = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
					setvalue(config.Minimum + alpha * range)
				end

				hitbox.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						stop()
						dragging = true
						drag(input)

						moveConn = UIS.InputChanged:Connect(function(i)
							if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
								drag(i)
							end
						end)

						endConn = UIS.InputEnded:Connect(function(i)
							if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
								stop()
							end
						end)
					end
				end)

				return slider
			end

			function groupbox:AddButton(name , opts)
				opts = opts or {}

				local button = {}

				local warnclick = opts.WarnClick or opts.Warn or false
				local smaller = opts.Smaller or false
				local armed = false
				local armtoken = 0

				local Holder = library:Create("Frame", {
					Name = "Button",
					Size = smaller and UDim2.new(0.465, 0, 0, 15) or UDim2.new(0.95, 0,0, 15),
					LayoutOrder = #elementsholder:GetChildren(),
					BackgroundColor3 = library.MainColor,
					Parent = elementsholder,
				}, {
					instancep = "BackgroundColor3";
					tinstance = library.MainColor;
				})

				local stroketext = library:Create("UIStroke", {
					Name = "UIStroke",
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = library.SecondaryColor,
					Thickness = 1,
					Parent = Holder,
				},{
					instancep = "Color";
					tinstance = library.SecondaryColor;
				})

				local text = library:Create("TextLabel", {
					Name = "text",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = name,
					TextColor3 = library.FontColor,
					TextSize = 13,
					Font = library.Font,
					TextXAlignment = Enum.TextXAlignment.Center,
					ZIndex = 2,
					Parent = Holder,
				},{
					instancep = "TextColor3";
					tinstance = library.FontColor;
				}, {
					instancep = "Font";
					tinstance = library.Font;
				})

				local uistroke = library:Create("UIStroke", {
					Name = "UIStroke",
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
					Color = library.UIstroke,
					Thickness = 1,
					Parent = text,
				},{
					instancep = "Color";
					tinstance = library.UIstroke;
				})

				local textsizecon = library:Create("UITextSizeConstraint", {
					Name = "UITextSizeConstraint",
					MaxTextSize = 13,
					Parent = text,
				})

				local Textbutton = library:Create("TextButton", {
					Name = "Boxhit",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					ZIndex = 3,
					Parent = Holder,
				})

				local function disarm()
					armed = false
					armtoken += 1
					text.Text = name
					text.TextColor3 = library.FontColor
				end

				Textbutton.MouseButton1Click:Connect(function()
					if warnclick and not armed then
						armed = true
						text.Text = "Are you sure?"
						text.TextColor3 = Color3.fromRGB(255, 0, 0)

						armtoken += 1
						local mytoken = armtoken

						task.delay(2, function()
							if armed and armtoken == mytoken then
								disarm()
							end
						end)

						return
					end

					if armed then
						disarm()
					end

					if opts.Callback then
						opts.Callback()
					end
				end)

				return button
			end

			function groupbox:AddDependencyBox()
				local dependencybox = {}
				dependencybox.Dependencies = {}

				local groupbox = self
				local Container = elementsholder

				local Holder = library:Create("Frame", {
					Name = "DependencyBox";
					BackgroundTransparency = 1;
					Size = UDim2.new(1, 0, 0, 0);
					AutomaticSize = Enum.AutomaticSize.Y;
					LayoutOrder = #Container:GetChildren();
					Visible = false;
					Parent = Container;
				})

				local Frame = library:Create("Frame", {
					Name = "Elements";
					BackgroundTransparency = 1;
					Size = UDim2.new(1, 0, 0, 0);
					AutomaticSize = Enum.AutomaticSize.Y;
					Parent = Holder;
				})

				local Layout = library:Create("UIListLayout", {
					Name = "UIListLayout";
					FillDirection = Enum.FillDirection.Horizontal;
					Wraps = true;
					HorizontalAlignment = Enum.HorizontalAlignment.Center;
					VerticalAlignment = Enum.VerticalAlignment.Top;
					SortOrder = Enum.SortOrder.LayoutOrder;
					Padding = UDim.new(0, 5);
					Parent = Frame;
				})

				local order = 0

				local function wrap(fname)
					if typeof(groupbox[fname]) ~= "function" then
						return
					end

					dependencybox[fname] = function(_, ...)
						local before = {}

						for _, child in ipairs(Container:GetChildren()) do
							before[child] = true
						end

						local result = groupbox[fname](groupbox, ...)

						for _, child in ipairs(Container:GetChildren()) do
							if not before[child] then
								order += 1
								child.LayoutOrder = order
								child.Parent = Frame
							end
						end

						return result
					end
				end

				for _, fname in ipairs({"AddLabel", "AddToggle", "AddSlider", "AddButton", "AddTextbox", "AddDropdown", "AddDependencyBox", "Divider"}) do
					wrap(fname)
				end

				function dependencybox:Update()
					for _, Dependency in next, dependencybox.Dependencies do
						local Element = Dependency[1]
						local Value = Dependency[2]

						local current = Element.Value
						if current == nil then
							current = Element.value
						end

						if current ~= Value then
							Holder.Visible = false
							return
						end
					end

					Holder.Visible = true
				end

				function dependencybox:SetupDependencies(Dependencies)
					for _, Dependency in next, Dependencies do
						assert(typeof(Dependency) == "table", "SetupDependencies: Dependency is not of type `table`.")
						assert(Dependency[1], "SetupDependencies: Dependency is missing element argument.")
						assert(Dependency[2] ~= nil, "SetupDependencies: Dependency is missing value argument.")
					end

					dependencybox.Dependencies = Dependencies
					dependencybox:Update()
				end

				table.insert(groupbox.elements, dependencybox)
				table.insert(library.DependencyBoxes, dependencybox)

				return dependencybox
			end

			function groupbox:Divider()
				local divider = {}

				local frame = library:Create("Frame", {
					Name = "Divider",
					Size = UDim2.new(0.95, 0, 0, 3),
					BackgroundColor3 = library.MainColor,
					LayoutOrder = #elementsholder:GetChildren(),
					Parent = elementsholder,
				}, {
					instancep = "BackgroundColor3";
					tinstance = library.MainColor;
				})

				local uistroke1 = library:Create("UIStroke", {
					Name = "UIStroke",
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = library.SecondaryColor,
					Thickness = 1,
					ZIndex = 2,
					Parent = frame,
				}, {
					instancep = "Color";
					tinstance = library.SecondaryColor;
				})

				return divider
			end
			
			function groupbox:AddDropdown(name, opts)
				opts = opts or {}

				library.Options = library.Options or {}

				if library.Options[name] then
					warn("An option named '" .. name .. "' already exists.")
					return nil
				end

				local Dropdown = {}
				local elements = {}
				local picked = nil
				local Multipicked = {}
				local isopen = false
				local maxItems = 25
				local updating = false

				opts.Values = opts.Values or {}

				while #opts.Values > maxItems do
					table.remove(opts.Values)
				end

				local changedEvent = Instance.new("BindableEvent")

				local option = {
					Type = "Dropdown",
					Name = name,
					Value = nil,
					OnChanged = changedEvent.Event,
				}

				library.Options[name] = option

				local main = library:Create("Frame", {
					Name = "Dropdown",
					ZIndex = 10,
					Size = UDim2.new(0.95, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = #elementsholder:GetChildren(),
					BackgroundTransparency = 1,
					Parent = elementsholder,
				})

				library:Create("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = main,
				})

				local header = library:Create("TextLabel", {
					Name = "Header",
					ZIndex = 11,
					Size = UDim2.new(1, 0, 0, 15),
					LayoutOrder = 1,
					BackgroundTransparency = 1,
					Text = name,
					Font = library.Font,
					TextColor3 = library.FontColor,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = main,
				}, {
					instancep = "TextColor3",
					tinstance = library.FontColor,
				}, {
					instancep = "Font",
					tinstance = library.Font,
				})

				library:Create("UITextSizeConstraint", {
					MaxTextSize = 13,
					Parent = header,
				})

				library:Create("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
					Color = library.UIstroke,
					Thickness = 1,
					Parent = header,
				}, {
					instancep = "Color",
					tinstance = library.UIstroke,
				})

				local dropdownFrame = library:Create("Frame", {
					Name = "DropdownFrame",
					ZIndex = 10,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = 2,
					BackgroundTransparency = 1,
					ClipsDescendants = false,
					Parent = main,
				})

				library:Create("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 3),
					Parent = dropdownFrame,
				})

				local selectionRow = library:Create("Frame", {
					Name = "SelectionRow",
					ZIndex = 11,
					Size = UDim2.new(1, 0, 0, 20),
					LayoutOrder = 1,
					BackgroundTransparency = 1,
					Parent = dropdownFrame,
				})

				library:Create("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = library.SecondaryColor,
					Thickness = 1,
					Parent = selectionRow,
				}, {
					instancep = "Color",
					tinstance = library.SecondaryColor,
				})

				local selectedLabel = library:Create("TextLabel", {
					Name = "Selected",
					ZIndex = 12,
					Size = UDim2.new(1, -25, 1, 0),
					Position = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = "-",
					Font = library.Font,
					TextColor3 = library.AccentColor,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Parent = selectionRow,
				}, {
					instancep = "TextColor3",
					tinstance = library.AccentColor,
				}, {
					instancep = "Font",
					tinstance = library.Font,
				})

				library:Create("UIPadding", {
					PaddingLeft = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 3),
					Parent = selectedLabel,
				})

				library:Create("UITextSizeConstraint", {
					MaxTextSize = 13,
					Parent = selectedLabel,
				})

				library:Create("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
					Color = library.UIstroke,
					Thickness = 1,
					Parent = selectedLabel,
				}, {
					instancep = "Color",
					tinstance = library.UIstroke,
				})

				local arrow = library:Create("ImageLabel", {
					Name = "DropdownImage",
					ZIndex = 13,
					Size = UDim2.new(0, 15, 0, 15),
					Position = UDim2.new(1, -19, 0.5, -7),
					BackgroundTransparency = 1,
					Image = "rbxassetid://10709767827",
					ScaleType = Enum.ScaleType.Crop,
					Parent = selectionRow,
				})

				local button = library:Create("TextButton", {
					Name = "DropdownButton",
					ZIndex = 14,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					AutoButtonColor = false,
					Parent = selectionRow,
				})

				local holder = library:Create("ScrollingFrame", {
					Name = "Holder",
					ZIndex = 20,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					CanvasSize = UDim2.new(0, 0, 0, 0),
					LayoutOrder = 2,
					BackgroundColor3 = library.MainColor,
					BorderSizePixel = 0,
					ScrollBarThickness = 0,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					Visible = false,
					ClipsDescendants = true,
					Parent = dropdownFrame,
				}, {
					instancep = "BackgroundColor3",
					tinstance = library.MainColor,
				})

				library:Create("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = library.SecondaryColor,
					Thickness = 1,
					Parent = holder,
				})

				library:Create("UIListLayout", {
					Name = "UIListLayout",
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					Padding = UDim.new(0, 4),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = holder,
				})

				library:Create("UIPadding", {
					PaddingLeft = UDim.new(0, 2),
					PaddingRight = UDim.new(0, 2),
					PaddingTop = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 2),
					Parent = holder,
				})

				library:Create("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = library.SecondaryColor,
					Thickness = 1,
					Parent = holder,
				}, {
					instancep = "Color",
					tinstance = library.SecondaryColor,
				})

				local function getValue()
					if opts.Multipick then
						local values = {}

						for i, value in ipairs(opts.Values) do
							if Multipicked[i] then
								table.insert(values, value)
							end
						end

						return values
					end

					return picked
				end

				local function getIndex()
					if opts.Multipick then
						local indices = {}

						for i = 1, #opts.Values do
							if Multipicked[i] then
								table.insert(indices, i)
							end
						end

						return indices
					end

					for i, value in ipairs(opts.Values) do
						if value == picked then
							return i
						end
					end

					return nil
				end

				local function updateSelectedText()
					if opts.Multipick then
						local values = {}

						for i, value in ipairs(opts.Values) do
							if Multipicked[i] then
								table.insert(values, tostring(value))
							end
						end

						selectedLabel.Text = #values > 0
							and table.concat(values, ", ")
							or "-"
					else
						selectedLabel.Text = picked ~= nil
							and tostring(picked)
							or "-"
					end

					-- Accent only when a value is selected; otherwise use the normal font color.
					local hasSelection
					if opts.Multipick then
						hasSelection = next(Multipicked) ~= nil
					else
						hasSelection = picked ~= nil
					end

					selectedLabel.TextColor3 = hasSelection
						and library.AccentColor
						or library.FontColor

					option.Value = getValue()
				end

				local function updateItems()
					for _, item in ipairs(elements) do
						local selected

						if opts.Multipick then
							selected = Multipicked[item.index] == true
						else
							selected = picked == item.name
						end

						item.button.Text = selected
							and ("✓  " .. tostring(item.name))
							or tostring(item.name)

						item.button.TextColor3 = selected
							and library.AccentColor
							or library.FontColor
					end
				end

				local function notifyChanged()
					local value = getValue()

					option.Value = value
					changedEvent:Fire(value)

					if opts.Callback then
						opts.Callback(value)
					end
				end

				local function setValue(value, silent)
					if opts.Multipick then
						table.clear(Multipicked)

						local selections = type(value) == "table"
							and value
							or {value}

						for _, selection in ipairs(selections) do
							local index

							if type(selection) == "number" then
								index = selection
							else
								for i, itemName in ipairs(opts.Values) do
									if itemName == selection then
										index = i
										break
									end
								end
							end

							if index and index >= 1 and index <= #opts.Values then
								Multipicked[index] = true
							end
						end
					else
						local index

						if type(value) == "number" then
							index = value
						else
							for i, itemName in ipairs(opts.Values) do
								if itemName == value then
									index = i
									break
								end
							end
						end

						if index and index >= 1 and index <= #opts.Values then
							picked = opts.Values[index]
						else
							picked = nil
						end
					end

					updateSelectedText()
					updateItems()

					if not silent then
						notifyChanged()
					end
				end

				function option:GetValue()
					return getValue()
				end

				function option:GetIndex()
					return getIndex()
				end

				function option:SetValue(value)
					setValue(value, false)
				end

				function Dropdown:GetValue()
					return getValue()
				end

				function Dropdown:GetIndex()
					return getIndex()
				end

				function Dropdown:SetValue(value)
					option:SetValue(value)
				end

				function Dropdown:GetInstance()
					return selectedLabel
				end

				local function toggleOpen()
					isopen = not isopen
					holder.Visible = isopen
					arrow.Rotation = isopen and 180 or 0
				end

				button.MouseButton1Click:Connect(toggleOpen)

				function Dropdown:AddItem(itemName)
					if #opts.Values >= maxItems then
						warn("Dropdown maximum is 10 items.")
						return nil
					end

					table.insert(opts.Values, itemName)

					local index = #opts.Values
					local item = {
						name = itemName,
						index = index,
					}

					local itemButton = library:Create("TextButton", {
						Name = "Item_" .. index,
						ZIndex = 21,
						Size = UDim2.new(1, 0, 0, 18),
						BackgroundTransparency = 1,
						Text = tostring(itemName),
						TextSize = 13,
						TextColor3 = library.FontColor,
						Font = library.Font,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						LayoutOrder = index,
						AutoButtonColor = false,
						Parent = holder,
					}, {
						instancep = "Font",
						tinstance = library.Font,
					})

					item.button = itemButton
					elements[index] = item

					local itemIndex = index
					itemButton.MouseButton1Click:Connect(function()
						if opts.Multipick then
							-- Clicking an already-selected item must deselect it.
							Multipicked[itemIndex] = not (Multipicked[itemIndex] == true)
						else
							picked = itemName
							isopen = false
							holder.Visible = false
							arrow.Rotation = 0
						end

						updateSelectedText()
						updateItems()
						notifyChanged()
					end)

					updateSelectedText()
					updateItems()

					return item
				end

				function Dropdown:Refresh(values, defaultValue)
					values = values or {}

					-- Copy first: callers may pass opts.Values itself.
					local refreshedValues = {}
					for _, value in ipairs(values) do
						table.insert(refreshedValues, value)
					end
					values = refreshedValues

					if #values > maxItems then
						warn("Dropdown supports a maximum of 25 items.")
						return
					end

					for _, item in ipairs(elements) do
						item.button:Destroy()
					end

					table.clear(elements)
					table.clear(opts.Values)
					table.clear(Multipicked)

					picked = nil

					for _, value in ipairs(values) do
						self:AddItem(value)
					end

					setValue(defaultValue, true)
				end

				for _, value in ipairs(opts.Values) do
					Dropdown:AddItem(value)
				end

				-- Apply defaults without firing callbacks during initialization.
				if opts.Default ~= nil then
					setValue(opts.Default, true)
				else
					updateSelectedText()
					updateItems()
				end

				Dropdown.Instance = selectedLabel
				Dropdown.Holder = holder
				Dropdown.Option = option

				return Dropdown
			end

			function groupbox:AddInput(name, opts)
				opts = opts or {}

				local input = {}

				local initialValue = tostring(opts.Default or "")
				local changedEvent = Instance.new("BindableEvent")

				local option = {
					Type = "Input",
					Name = name,
					Value = initialValue,
					OnChanged = changedEvent.Event,
				}

				library.Options = library.Options or {}
				library.Options[name] = option

				local Holder = library:Create("Frame", {
					Name = "Input",
					Size = UDim2.new(0.95, 0, 0, 20),
					LayoutOrder = #elementsholder:GetChildren(),
					BackgroundColor3 = library.MainColor,
					Parent = elementsholder,
				}, {
					instancep = "BackgroundColor3",
					tinstance = library.MainColor,
				})

				library:Create("UIStroke", {
					Name = "UIStroke",
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = library.SecondaryColor,
					Thickness = 1,
					Parent = Holder,
				}, {
					instancep = "Color",
					tinstance = library.SecondaryColor,
				})

				local text = library:Create("TextBox", {
					Name = "Text",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					ClearTextOnFocus = false,
					MultiLine = false,
					PlaceholderText = name .. "..",
					Text = initialValue,
					TextColor3 = library.FontColor,
					TextSize = 13,
					Font = library.Font,
					TextXAlignment = Enum.TextXAlignment.Center,
					ZIndex = 2,
					Parent = Holder,
				}, {
					instancep = "TextColor3",
					tinstance = library.FontColor,
				}, {
					instancep = "Font",
					tinstance = library.Font,
				})

				library:Create("UIStroke", {
					Name = "TextStroke",
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
					Color = library.UIstroke,
					Thickness = 1,
					Parent = text,
				}, {
					instancep = "Color",
					tinstance = library.UIstroke,
				})

				library:Create("UITextSizeConstraint", {
					Name = "UITextSizeConstraint",
					MaxTextSize = 13,
					Parent = text,
				})

				local updating = false

				local function setValue(value, silent)
					value = tostring(value or "")

					option.Value = value

					if text.Text ~= value then
						updating = true
						text.Text = value
						updating = false
					end

					if not silent then
						changedEvent:Fire(value)

						if opts.Callback then
							opts.Callback(value)
						end
					end
				end

				function option:GetValue()
					return option.Value
				end

				function option:SetValue(value)
					setValue(value, false)
				end

				function input:GetValue()
					return option.Value
				end

				function input:SetValue(value)
					option:SetValue(value)
				end

				function input:GetInstance()
					return text
				end

				text:GetPropertyChangedSignal("Text"):Connect(function()
					if updating then
						return
					end

					local value = text.Text

					if option.Value == value then
						return
					end

					option.Value = value
					changedEvent:Fire(value)

					if opts.Callback then
						opts.Callback(value)
					end
				end)

				input.Instance = text
				input.Holder = Holder
				input.Option = option

				return input
			end	
			
			return groupbox
		end

		function tab:AddRightGroupbox(title)
			local groupbox = {
				elements = {};
			}

			local groupboxf = library:Create("Frame", {
				Name = "Groupbox";
				Size = UDim2.new(0.95, 0,0, 0);
				Position = UDim2.new(0, 0,0, 0);
				BackgroundColor3 = library.MainColor;
				AutomaticSize = Enum.AutomaticSize.Y;
				LayoutOrder = #tabright:GetChildren();
				Parent = tabright;
			}, {
				instancep = "BackgroundColor3";
				tinstance = library.MainColor;
			})

			local uistroke = library:Create("UIStroke", {
				Name = "UIStroke";
				Parent = groupboxf;
				Thickness = 1;
				Color = library.SecondaryColor;
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			}, {
				instancep = "Color";
				tinstance = library.SecondaryColor;
			})

			local uilay = library:Create("UIListLayout", {
				Name = "uil";
				FillDirection = Enum.FillDirection.Vertical;
				Padding = UDim.new(0, 1);
				SortOrder = Enum.SortOrder.LayoutOrder;
				HorizontalAlignment = Enum.HorizontalAlignment.Center;
				VerticalAlignment = Enum.VerticalAlignment.Top;

				Parent = groupboxf;
			})

			local uipad = library:Create("UIPadding", {
				Name = "uip";
				PaddingRight = UDim.new(0, 0);
				PaddingLeft = UDim.new(0, 0);
				PaddingTop = UDim.new(0, 0);
				PaddingBottom = UDim.new(0, 4);
				Parent = groupboxf;
			})

			local accent = library:Create("Frame", {
				Name = "Accent";
				Size = UDim2.new(1, 0,0, 1);
				Position = UDim2.new(0, 0,0, 0);
				BackgroundColor3 = library.AccentColor;
				LayoutOrder = -1000;
				Parent = groupboxf;
			}, {
				instancep = "BackgroundColor3";
				tinstance = library.AccentColor;
			})
			
			local titlegroupbox = library:Create("TextLabel", {
				Name = "Title";
				Size = UDim2.new(1, 0,0, 20);
				LayoutOrder = -1;

				BackgroundTransparency = 1;
				Text = title;
				Font = library.Font;
				TextColor3 = library.FontColor;
				TextSize = 14;

				Parent = groupboxf;
			}, {
				instancep = "TextColor3";
				tinstance = library.FontColor;
			}, {
				instancep = "Font";
				tinstance = library.Font;
			})

			local titleuis = library:Create("UIStroke", {
				Name = "UIStroke";
				Parent = titlegroupbox;
				Thickness = 1;
				Color = library.UIstroke;
			}, {
				instancep = "Color";
				tinstance = library.UIstroke;
			})

			local titleuits = library:Create("UITextSizeConstraint", {
				Name = "uit";
				MaxTextSize = 14;
				Parent = titlegroupbox;
			})

			local titleuip = library:Create("UIPadding", {
				Name = "uip";
				PaddingRight = UDim.new(0, 0);
				PaddingLeft = UDim.new(0, 0);
				PaddingTop = UDim.new(0, 3);
				PaddingBottom = UDim.new(0, 0);
				Parent = titlegroupbox;
			})
			
			local elementsholder = library:Create("Frame", {
				Name = "elem";
				Size = UDim2.new(1, 0,0, 0);
				BackgroundTransparency = 1;
				LayoutOrder = 1;
				AutomaticSize = Enum.AutomaticSize.Y;
				Parent = groupboxf;
			})
			
			local elemsuill = library:Create("UIListLayout", {
				Name = "UIListLayout";
				FillDirection = Enum.FillDirection.Horizontal;
				Wraps = true;
				HorizontalAlignment = Enum.HorizontalAlignment.Center;
				VerticalAlignment = Enum.VerticalAlignment.Top;
				SortOrder = Enum.SortOrder.LayoutOrder;
				Padding = UDim.new(0, 4);
				Parent = elementsholder;
			})
			
			local elemsuip = library:Create("UIPadding", {
				Name = "UIPadding";
				PaddingBottom = UDim.new(0, 0);
				PaddingLeft = UDim.new(0, 0);
				PaddingRight = UDim.new(0, 0);
				PaddingTop = UDim.new(0, 3);
				Parent = elementsholder;
			})

			-- api
			function groupbox:AddLabel(text, opts)
				--[[
				    MAX 3 COLOR PICKERS (cant use key picker if u do this)
				    MAX 1 KEY PICKER (cant use color pickers if u do this)
				]]

				local label = {}
				local colorpickers = {}
				local keypicker = nil

				local RestrictedKeypicker = false
				local RestrictedColorpicker = false

				local holder = library:Create("Frame", {
					Name = "Holder";
					Size = UDim2.new(0.95, 0,0, 20);
					BackgroundTransparency = 1;
					LayoutOrder = #elementsholder:GetChildren();
					Parent = elementsholder;
				})

				local uitext = library:Create("TextLabel", {
					Name = "TextLabel";
					Size = UDim2.new(.795, 0,1, 0);
					BackgroundTransparency = 1;
					Text = text;
					TextSize = 13;
					TextColor3 = library.FontColor;
					Font = library.Font;
					LayoutOrder = 1;
					TextXAlignment = Enum.TextXAlignment.Left;
					TextYAlignment = Enum.TextYAlignment.Center;
					Parent = holder;
				}, {
					instancep = "TextColor3";
					tinstance = library.FontColor;
				})

				local uitextsui = library:Create("UITextSizeConstraint", {
					Name = "UITextSizeConstraint";
					MaxTextSize = 13;
					Parent = uitext;
				})

				local uistroke = library:Create("UIStroke", {
					Name = "UIStroke";
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
					Color = Color3.fromRGB(0, 0, 0);
					Thickness = 1;
					Parent = uitext;
				}, {
					instancep = "Color";
					tinstance = library.UIstroke;
				})

				local uill = library:Create("UIListLayout", {
					Name = "UIListLayout";
					FillDirection = Enum.FillDirection.Horizontal;
					HorizontalAlignment = Enum.HorizontalAlignment.Left;
					SortOrder = Enum.SortOrder.LayoutOrder;
					Parent = holder;
				})

				local holder2 = library:Create("Frame", {
					Name = "Holder";
					Size = UDim2.new(0.043, 50,1, 0);
					BackgroundTransparency = 1;
					LayoutOrder = 2;
					Parent = holder;
				})

				local uillh = library:Create("UIListLayout", {
					Name = "UIListLayout";
					FillDirection = Enum.FillDirection.Horizontal;
					HorizontalAlignment = Enum.HorizontalAlignment.Right;
					VerticalAlignment = Enum.VerticalAlignment.Center;
					SortOrder = Enum.SortOrder.LayoutOrder;
					Padding = UDim.new(0, 6);
					Parent = holder2;
				})

				function label:AddColorPicker(name, opts)
					if RestrictedColorpicker then
						error("Restricted your using a keypicker!")
						return
					end

					if #colorpickers >= 3 then
						error("Max number of colorpickers reached")
						return
					end

					local colorpicker = {}
					table.insert(colorpickers, colorpicker)
					RestrictedKeypicker = true
					local color = opts.Startcolor or Color3.new(1, 1, 1)
					local transparency = opts.Transparency or 0
					local pointPosition

					colorpicker.Color = color
					colorpicker.Transparency = transparency
					colorpicker.OnChanged = newSignal()
					Options[name] = colorpicker
					local opened = false
					local instance 
					local followConn
					local outsideConn

					local colorbox = library:Create("Frame", {
						Name = "ColorBox";
						Size = UDim2.new(0, 17,0, 15);
						BackgroundColor3 = color;
						LayoutOrder = #holder2:GetChildren();
						Parent = holder2;
					}, {
						instancep = "BackgroundColor3";
						tinstance = color;
					})

					local uistroke = library:Create("UIStroke", {
						Name = "UIStroke";
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
						LineJoinMode = Enum.LineJoinMode.Miter;
						Color = library.SecondaryColor;
						Thickness = 1;
						Parent = colorbox;
					}, {
						instancep = "Color";
						tinstance = library.SecondaryColor;
					})

					local hitbox = library:Create("TextButton", {
						Name = "Hitbox";
						Size = UDim2.new(1,0,1,0);
						BackgroundTransparency = 1;
						Active = true;
						ZIndex = 10;
						Selectable = true;
						Text = "";
						Parent = colorbox;
					})

					local function OnChange(newcolor, newtransparency)
						colorpicker.Color = newcolor
						colorpicker.Transparency = newtransparency

						if opts.Callback then
							opts.Callback(newcolor, newtransparency)
						end

						colorpicker.OnChanged:Fire(newcolor, newtransparency)
					end

					local function Createcolorpickerbox()
						opened = true

						local function getPos()
							local abs = colorbox.AbsolutePosition
							local base = screengui.AbsolutePosition
							return UDim2.new(0, abs.X - base.X, 0, abs.Y - base.Y)
						end

						local cursorbox = library:Create("Frame", {
							Name = "CursorBox";
							Size = UDim2.new(0, 15,0, 15);
							Position = getPos();
							BackgroundColor3 = Color3.new(1,1,1);
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = screengui;
						})

						instance = cursorbox

						followConn = colorbox:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
							if instance then
								instance.Position = getPos()
							end
						end)

						local framewindow = library:Create("Frame", {
							Name = "Frame";
							Size = UDim2.new(0, 323,0, 198);
							Position = UDim2.new(1, 0,1.4, 0);
							BackgroundColor3 = library.MainColor;
							ZIndex = 2;
							Parent = cursorbox;
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local uistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							LineJoinMode = Enum.LineJoinMode.Miter;
							Color = library.SecondaryColor;
							Thickness = 1;
							ZIndex = 2;
							Parent = framewindow;
						}, {
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local uistroke2 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							LineJoinMode = Enum.LineJoinMode.Miter;
							Color = library.MainColor;
							Thickness = 4;
							Parent = framewindow;
						}, {
							instancep = "Color";
							tinstance = library.MainColor;
						})

						local text = library:Create("TextLabel", {
							Name = "TextLabel";
							Size = UDim2.new(1, 0,0, 16);
							Position = UDim2.new(0, 0,0, 0);
							Text = name;
							TextColor3 = library.FontColor;
							Font = library.Font;
							TextSize = 13;
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = framewindow;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local textuistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = text;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local textuisize = library:Create("UITextSizeConstraint", {
							Name = "UISizeConstraint";
							MaxTextSize = 13;
							Parent = text;
						})

						local colors = library:Create("Frame", {
							Name = "Colors";
							Size = UDim2.new(1, 0,0, 23);
							Position = UDim2.new(0, 0,0.879, 0);
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = framewindow;
						})

						local colorsUIl = library:Create("UIListLayout", {
							Name = "UIListLayout";
							FillDirection = Enum.FillDirection.Horizontal;
							HorizontalAlignment = Enum.HorizontalAlignment.Center;
							Padding = UDim.new(0, 8);
							SortOrder = Enum.SortOrder.LayoutOrder;
							VerticalAlignment = Enum.VerticalAlignment.Center;
							Parent = colors;
						})

						local colorsboxcolor = library:Create("Frame", {
							Name = "Color";
							Size = UDim2.new(0, 20,0, 20);
							BackgroundColor3 = color;
							ZIndex = 2;
							LayoutOrder = 1;
							Parent = colors;
						}, {
							instancep = "BackgroundColor3";
							tinstance = color;
						})

						local colorsboxcoloruistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							Color = library.SecondaryColor;
							Thickness = 1;
							Parent = colorsboxcolor;
						}, {
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local function rgbText(c)
							return math.floor(c.R * 255 + 0.5) .. "," .. math.floor(c.G * 255 + 0.5) .. "," .. math.floor(c.B * 255 + 0.5)
						end

						local huecoloreditbox = library:Create("TextBox", {
							Name = "Hue";
							Size = UDim2.new(0, 71,0, 20);
							BackgroundColor3 = library.MainColor;
							TextColor3 = library.FontColor;
							Text = rgbText(color);
							TextSize = 13;
							Font = Enum.Font.SourceSans;
							MultiLine = false;
							ZIndex = 2;
							LayoutOrder = 2;
							Parent = colors;
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						})

						local huecolorboxuis1 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							Color = library.SecondaryColor;
							Thickness = 1;
							Parent = huecoloreditbox;
						}, {
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local huecolorboxuis2 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = huecoloreditbox;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local transditbox = library:Create("TextBox", {
							Name = "trans";
							Size = UDim2.new(0, 71,0, 20);
							BackgroundColor3 = library.MainColor;
							TextColor3 = library.FontColor;
							Text = transparency;
							TextSize = 13;
							Font = Enum.Font.SourceSans;
							MultiLine = false;
							ZIndex = 2;
							LayoutOrder = 2;
							Parent = colors;
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						})

						local transboxuis1 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							Color = library.SecondaryColor;
							Thickness = 1;
							Parent = transditbox;
						}, {
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local transboxuis2 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = transditbox;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local hexditbox = library:Create("TextBox", {
							Name = "trans";
							Size = UDim2.new(0, 71,0, 20);
							BackgroundColor3 = library.MainColor;
							TextColor3 = library.FontColor;
							Text = color:ToHex();
							TextSize = 13;
							Font = Enum.Font.SourceSans;
							MultiLine = false;
							ZIndex = 2; 
							LayoutOrder = 2;
							Parent = colors;
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						})

						local hexboxuis1 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							Color = library.SecondaryColor;
							Thickness = 1;
							Parent = hexditbox;
						}, {
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local hexboxuis2 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = hexditbox;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local main = library:Create("Frame", {
							Name = "Main";
							Size = UDim2.new(1, 0,0, 158);
							Position = UDim2.new(0, 0,0.081, 0);
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = framewindow;
						})

						local uillmain = library:Create("UIListLayout", {
							Name = "UIListLayout";
							FillDirection = Enum.FillDirection.Horizontal;
							SortOrder = Enum.SortOrder.LayoutOrder;
							HorizontalAlignment = Enum.HorizontalAlignment.Center;
							VerticalAlignment = Enum.VerticalAlignment.Center;
							Padding = UDim.new(0, 5);
							Parent = main;
						})

						local h, s, v = color:ToHSV()
						local UIS = InputService

						local huebox = library:Create("Frame", {
							Name = "HueBox";
							Size = UDim2.new(0.576, 50,0.94, 0);
							BackgroundColor3 = Color3.fromHSV(h, 1, 1);
							ZIndex = 2;
							Parent = main;
						})

						local helight = library:Create("Frame", {
							Name = "HueBox2";
							Size = UDim2.new(1,0,1,0);
							BackgroundColor3 = Color3.new(1, 1, 1);
							ZIndex = 3;
							Parent = huebox;
						})

						local huelightgrad = library:Create("UIGradient", {
							Name = "grad";
							Parent = helight;

							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(1, 1),
							})
						})

						local huedark = library:Create("Frame", {
							Name = "HueBox3";
							Size = UDim2.new(1,0,1,0);
							BackgroundColor3 = Color3.new(0, 0, 0);
							ZIndex = 3;
							Parent = huebox;
						})

						local huedarkgrad = library:Create("UIGradient", {
							Name = "grad";
							Parent = huedark;

							Rotation = 90,
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(1, 0),
							}),
						})

						local shiftbox = library:Create("Frame", {
							Name = "shiftbox";
							Size = UDim2.new(-0.057, 50,0.94, 0);
							BackgroundColor3 = Color3.new(1,1,1);
							ZIndex = 2;
							LayoutOrder = 2;
							Parent = main;
						})

						local rainbow = {}
						for i = 0, 6 do
							table.insert(rainbow, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
						end

						local shiftgrad = library:Create("UIGradient", {
							Name = "grad";
							Rotation = 90;
							Color = ColorSequence.new(rainbow);
							Parent = shiftbox;
						})

						local transparencybox = library:Create("Frame", {
							Name = "TransparencyBox";
							Size = UDim2.new(-0.057, 50,0.94, 0);
							BackgroundColor3 = Color3.new(1,1,1);
							ZIndex = 2;
							LayoutOrder = 3;
							Parent = main;
						})

						local imagetrans = library:Create("ImageLabel", {
							Name = "ImageLabel";
							Size = UDim2.new(1,0,1,0);
							BackgroundColor3 = Color3.new(1,1,1);
							Parent = transparencybox;
							Image = "rbxassetid://155451930";
							ScaleType = Enum.ScaleType.Tile;
							TileSize = UDim2.new(1, 0,0.3, 0);
						})

						local transfade = library:Create("Frame", {
							Name = "Fade";
							Size = UDim2.new(1,0,1,0);
							BackgroundColor3 = color;
							ZIndex = 3;
							Parent = transparencybox;
						})

						local transfadegrad = library:Create("UIGradient", {
							Name = "grad";
							Rotation = 90;
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(1, 1),
							});
							Parent = transfade;
						})

						local function refresh()
							color = Color3.fromHSV(h, s, v)
							colorbox.BackgroundColor3 = color
							colorsboxcolor.BackgroundColor3 = color
							huebox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
							transfade.BackgroundColor3 = color
							huecoloreditbox.Text = rgbText(color)
							hexditbox.Text = color:ToHex()
							transditbox.Text = tostring(math.floor(transparency * 100 + 0.5) / 100)
							OnChange(color, transparency, pointPosition)
						end

						local function makeSlider(box, start, onChange)
							box.Active = true

							local bar = library:Create("Frame", {
								Name = "Bar";
								Size = UDim2.new(1, 4,0, 3);
								AnchorPoint = Vector2.new(0.5, 0.5);
								Position = UDim2.new(0.5, 0,start, 0);
								BackgroundColor3 = Color3.new(1, 1, 1);
								ZIndex = 5;
								Parent = box;
							})

							local barstroke = library:Create("UIStroke", {
								Name = "UIStroke";
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
								Color = Color3.new(0, 0, 0);
								Thickness = 1;
								Parent = bar;
							})

							local moveConn, endConn

							local function stop()
								if moveConn then moveConn:Disconnect() moveConn = nil end
								if endConn then endConn:Disconnect() endConn = nil end
							end

							local function update(input)
								local a = math.clamp((input.Position.Y - box.AbsolutePosition.Y) / box.AbsoluteSize.Y, 0, 1)
								bar.Position = UDim2.new(0.5, 0,a, 0)
								onChange(a)
							end

							box.InputBegan:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
									stop()
									update(input)

									moveConn = UIS.InputChanged:Connect(function(i)
										if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
											update(i)
										end
									end)

									endConn = UIS.InputEnded:Connect(function(i)
										if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
											stop()
										end
									end)
								end
							end)

							return function(a)
								bar.Position = UDim2.new(0.5, 0,a, 0)
							end
						end

						local setHueBar = makeSlider(shiftbox, h, function(a)
							h = a
							refresh()
						end)

						local setTransBar = makeSlider(transparencybox, transparency, function(a)
							transparency = a
							refresh()
						end)

						local cursor = library:Create("Frame", {
							Name = "Cursor";
							Size = UDim2.new(0, 8,0, 8);
							AnchorPoint = Vector2.new(0.5, 0.5);
							Position = UDim2.new(s, 0,1 - v, 0);
							BackgroundColor3 = Color3.new(1, 1, 1);
							ZIndex = 6;
							Parent = huebox;
						})

						local cursorcorner = library:Create("UICorner", {
							CornerRadius = UDim.new(1, 0);
							Parent = cursor;
						})

						local cursorstroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							Color = Color3.new(0, 0, 0);
							Thickness = 1;
							Parent = cursor;
						})

						local function setCursor(ns, nv)
							cursor.Position = UDim2.new(ns, 0,1 - nv, 0)
						end

						do
							huedark.Active = true
							local moveConn, endConn

							local function stop()
								if moveConn then moveConn:Disconnect() moveConn = nil end
								if endConn then endConn:Disconnect() endConn = nil end
							end

							local function update(input)
								local pos, size = huebox.AbsolutePosition, huebox.AbsoluteSize
								s = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
								v = 1 - math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
								setCursor(s, v)
								refresh()
							end

							huedark.InputBegan:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
									stop()
									update(input)

									moveConn = UIS.InputChanged:Connect(function(i)
										if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
											update(i)
										end
									end)

									endConn = UIS.InputEnded:Connect(function(i)
										if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
											stop()
										end
									end)
								end
							end)
						end

						huecoloreditbox.FocusLost:Connect(function()
							local r, g, b = huecoloreditbox.Text:match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")
							r, g, b = tonumber(r), tonumber(g), tonumber(b)

							if r and g and b then
								local c = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
								h, s, v = c:ToHSV()
								setHueBar(h)
								setCursor(s, v)
								refresh()
							else
								huecoloreditbox.Text = rgbText(color)
							end
						end)

						outsideConn = game:GetService("UserInputService").InputBegan:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
								return
							end

							local function isInside(gui)
								local pos, size = gui.AbsolutePosition, gui.AbsoluteSize
								local m = input.Position
								return m.X >= pos.X and m.X <= pos.X + size.X and m.Y >= pos.Y and m.Y <= pos.Y + size.Y
							end

							if isInside(framewindow) or isInside(colorbox) then
								return
							end

							colorpicker:Close()
						end)

					end

					function colorpicker:Close()
						if not opened then return end
						opened = false

						if followConn then
							followConn:Disconnect()
							followConn = nil
						end

						if outsideConn then
							outsideConn:Disconnect()
							outsideConn = nil
						end

						if instance then
							instance:Destroy()
							instance = nil
						end
					end

					hitbox.Activated:Connect(function()
						if opened then
							colorpicker:Close()
						else
							Createcolorpickerbox()
						end
					end)

					function colorpicker:AddColorPicker(name, opts)
						return label:AddColorPicker(name, opts)
					end

					library.windowinstances.Colorbox = colorpicker

					return colorpicker
				end

				function label:AddKeyPicker(name, opts)
					if type(name) == "table" then
						opts = name
						name = uitext.Text
					end

					opts = opts or {}

					local picker = {}
					local InputService = InputService or game:GetService("UserInputService")

					local function resolvekey(k)
						if typeof(k) == "EnumItem" then
							return k
						end

						if type(k) == "string" then
							local ok, res = pcall(function()
								return Enum.KeyCode[k]
							end)
							if ok then
								return res
							end
						end

						return nil
					end

					local currentkey = resolvekey(opts.Default)
					local Mode = opts.Mode or "Hold"
					local modes = {"Hold", "Toggle", "Always"}

					local opened = false
					local instance
					local followConn
					local outsideConn
					local waitkeyconn

					local waiting_for_key = false

					local winkeytext
					local winmodetext

					local ignoredkeys = {
						library.Menukey;
						Enum.KeyCode.Return,
						Enum.KeyCode.End,
						Enum.KeyCode.Home,
						Enum.KeyCode.PageUp,
						Enum.KeyCode.PageDown,
					}

					local ignoredset = {}
					for _, k in next, ignoredkeys do
						if k then
							ignoredset[k] = true
						end
					end

					if RestrictedKeypicker then
						error("Restricted your using a colorpicker!")
						return
					end

					if keypicker then
						warn("KeyPicker already exists for this label")
						return
					end

					keypicker = picker
					RestrictedColorpicker = true

					picker.Key = currentkey
					picker.Mode = Mode
					picker.OnChanged = newSignal()
					Options[name] = picker

					local keyframe = library:Create("Frame", {
						Name = "KeyPicker",
						Size = UDim2.new(0, 50, 0, 15),
						LayoutOrder = #holder2:GetChildren();
						BackgroundColor3 = library.MainColor,
						Parent = holder2;
					},{
						instancep = "BackgroundColor3";
						tinstance = library.MainColor;
					})

					local uistrokekey = library:Create("UIStroke", {
						Name = "UIStroke",
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = library.SecondaryColor,
						Thickness = 1,
						Parent = keyframe,
					},{
						instancep = "Color";
						tinstance = library.SecondaryColor;
					})

					local keybox = library:Create("TextButton", {
						Name = "KeyBox",
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = "",
						ZIndex = 4,
						Parent = keyframe,
					})

					local keytext = library:Create("TextLabel", {
						Name = "KeyText",
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = "None",
						TextColor3 = library.FontColor,
						TextSize = 13,
						Font = library.Font,
						TextXAlignment = Enum.TextXAlignment.Center,
						Parent = keyframe,
					},{
						instancep = "TextColor3";
						tinstance = library.FontColor;
					}, {
						instancep = "Font";
						tinstance = library.Font;
					})

					local active = false
					picker.Value = false

					local function setState(state)
						if active == state then return end
						active = state
						picker.Value = state

						if opts.Callback then
							opts.Callback(state)
						end
					end

					local function updatetexts()
						local t
						if waiting_for_key then
							t = "..."
						elseif currentkey then
							t = keyshorts[currentkey] or currentkey.Name
						else
							t = "None"
						end

						keytext.Text = t
						if winkeytext then
							winkeytext.Text = t
						end
						if winmodetext then
							winmodetext.Text = Mode
						end
					end

					local function setKey(k)
						currentkey = k
						picker.Key = k
						updatetexts()

						if opts.CallbackKey then
							opts.CallbackKey(k)
						end

						picker.OnChanged:Fire(currentkey, Mode)
					end

					local function setMode(m)
						Mode = m
						picker.Mode = m
						updatetexts()

						setState(m == "Always")

						if opts.CallbackMode then
							opts.CallbackMode(m)
						end

						picker.OnChanged:Fire(currentkey, Mode)
					end

					local function startbind()
						if waiting_for_key then
							return
						end

						waiting_for_key = true
						updatetexts()

						waitkeyconn = InputService.InputBegan:Connect(function(input, gameproccessed)
							if gameproccessed then return end
							if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
							if ignoredset[input.KeyCode] then return end

							if waitkeyconn then
								waitkeyconn:Disconnect()
								waitkeyconn = nil
							end

							task.defer(function()
								waiting_for_key = false
								updatetexts()
							end)

							if input.KeyCode == Enum.KeyCode.Backspace then
								setKey(nil)
							else
								setKey(input.KeyCode)
							end
						end)
					end

					local function openminiwindow()
						opened = true

						local function getPos()
							local abs = keyframe.AbsolutePosition
							local base = screengui.AbsolutePosition
							return UDim2.new(0, abs.X - base.X, 0, abs.Y - base.Y)
						end

						local cursorbox = library:Create("Frame", {
							Name = "CursorBox";
							Size = UDim2.new(0, 15,0, 15);
							Position = getPos();
							BackgroundColor3 = Color3.new(1,1,1);
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = screengui;
						})

						instance = cursorbox

						followConn = keyframe:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
							if instance then
								instance.Position = getPos()
							end
						end)

						local framewindow = library:Create("Frame", {
							Name = "Frame";
							Size = UDim2.new(0, 323,0, 93);
							Position = UDim2.new(1, 0,1.4, 0);
							BackgroundColor3 = library.MainColor;
							ZIndex = 2;
							Parent = cursorbox;
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local uistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							LineJoinMode = Enum.LineJoinMode.Miter;
							Color = library.SecondaryColor;
							Thickness = 1;
							Parent = framewindow;
						}, {
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local uistroke2 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							LineJoinMode = Enum.LineJoinMode.Miter;
							Color = library.MainColor;
							Thickness = 4;
							Parent = framewindow;
						}, {
							instancep = "Color";
							tinstance = library.MainColor;
						})

						local text = library:Create("TextLabel", {
							Name = "TextLabel";
							Size = UDim2.new(1, 0,0, 16);
							Position = UDim2.new(0, 0,0, 0);
							Text = name;
							TextColor3 = library.FontColor;
							Font = library.Font;
							TextSize = 13;
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = framewindow;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local textuistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = text;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local textuisize = library:Create("UITextSizeConstraint", {
							Name = "UISizeConstraint";
							MaxTextSize = 13;
							Parent = text;
						})

						local holder = library:Create("Frame", {
							Name = "Holder";
							Size = UDim2.new(1, 0,-0.228, 96);
							Position = UDim2.new(0, 0,0.195, 0);
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = framewindow;
						})

						local uill = library:Create("UIListLayout", {
							Name = "UIListLayout";
							Padding = UDim.new(0, 5);
							SortOrder = Enum.SortOrder.LayoutOrder;
							FillDirection = Enum.FillDirection.Vertical;
							HorizontalAlignment = Enum.HorizontalAlignment.Center;
							VerticalAlignment = Enum.VerticalAlignment.Top;
							Parent = holder;
						})

						local uipadd = library:Create("UIPadding", {
							Name = "UIPadding";
							PaddingLeft = UDim.new(0, 0);
							PaddingRight = UDim.new(0, 0);
							PaddingTop = UDim.new(0, 3);
							PaddingBottom = UDim.new(0, 0);
							Parent = holder;
						})

						local keysetbind = library:Create("Frame", {
							Name = "KeysetBind";
							Size = UDim2.new(.95, 0,0, 20);
							BackgroundTransparency = 1;
							LayoutOrder = 1;
							Parent = holder;
							ZIndex = 2;
						})

						local keybindsetuil = library:Create("UIListLayout", {
							Name = "UIListLayout";
							Padding = UDim.new(0, 0);
							SortOrder = Enum.SortOrder.LayoutOrder;
							FillDirection = Enum.FillDirection.Horizontal;
							HorizontalAlignment = Enum.HorizontalAlignment.Left;
							VerticalAlignment = Enum.VerticalAlignment.Center;
							Parent = keysetbind;
						})

						local keylabelset = library:Create("TextLabel", {
							Name = "KeyLabel";
							Size = UDim2.new(1, -55,1, 0);
							BackgroundTransparency = 1;
							Text = "Keybind";
							TextColor3 = library.FontColor;
							TextSize = 13;
							TextXAlignment = Enum.TextXAlignment.Left;
							TextYAlignment = Enum.TextYAlignment.Center;
							Font = library.Font;
							LayoutOrder = 1;
							ZIndex = 2;
							Parent = keysetbind;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local labeluistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = keylabelset;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local labeltsize = library:Create("UITextSizeConstraint", {
							Name = "UITextSizeConstraint";
							MaxTextSize = 13;
							Parent = keylabelset;
						})

						local winkeyframe = library:Create("Frame", {
							Name = "KeyPicker",
							Size = UDim2.new(0, 50, 0, 15),
							LayoutOrder = 2;
							BackgroundColor3 = library.MainColor,
							ZIndex = 2;
							Parent = keysetbind,
						},{
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local winuistrokekey = library:Create("UIStroke", {
							Name = "UIStroke",
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = library.SecondaryColor,
							Thickness = 1,
							Parent = winkeyframe,
						},{
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local winkeybox = library:Create("TextButton", {
							Name = "KeyBox",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "",
							ZIndex = 3,
							Parent = winkeyframe,
						})

						winkeytext = library:Create("TextLabel", {
							Name = "KeyText",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "None",
							TextColor3 = library.FontColor,
							TextSize = 13,
							Font = library.Font,
							TextXAlignment = Enum.TextXAlignment.Center,
							ZIndex = 2,
							Parent = winkeyframe,
						},{
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})


						local modesetbind = library:Create("Frame", {
							Name = "ModesetBind";
							Size = UDim2.new(.95, 0,0, 20);
							BackgroundTransparency = 1;
							LayoutOrder = 2;
							Parent = holder;
							ZIndex = 2;
						})

						local modesetuil = library:Create("UIListLayout", {
							Name = "UIListLayout";
							Padding = UDim.new(0, 0);
							SortOrder = Enum.SortOrder.LayoutOrder;
							FillDirection = Enum.FillDirection.Horizontal;
							HorizontalAlignment = Enum.HorizontalAlignment.Left;
							VerticalAlignment = Enum.VerticalAlignment.Center;
							Parent = modesetbind;
						})

						local modelabelset = library:Create("TextLabel", {
							Name = "ModeLabel";
							Size = UDim2.new(1, -55,1, 0);
							BackgroundTransparency = 1;
							Text = "Mode";
							TextColor3 = library.FontColor;
							TextSize = 13;
							TextXAlignment = Enum.TextXAlignment.Left;
							TextYAlignment = Enum.TextYAlignment.Center;
							Font = library.Font;
							LayoutOrder = 1;
							ZIndex = 2;
							Parent = modesetbind;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local labelmuistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = modelabelset;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local labelmtsize = library:Create("UITextSizeConstraint", {
							Name = "UITextSizeConstraint";
							MaxTextSize = 13;
							Parent = modelabelset;
						})

						local modeframe = library:Create("Frame", {
							Name = "ModePicker",
							Size = UDim2.new(0, 50, 0, 15),
							LayoutOrder = 2;
							BackgroundColor3 = library.MainColor,
							ZIndex = 2;
							Parent = modesetbind,
						},{
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local uistrokemode = library:Create("UIStroke", {
							Name = "UIStroke",
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = library.SecondaryColor,
							Thickness = 1,
							Parent = modeframe,
						},{
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local Modebox = library:Create("TextButton", {
							Name = "ModeBox",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "",
							ZIndex = 3,
							Parent = modeframe,
						})

						winmodetext = library:Create("TextLabel", {
							Name = "ModeText",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = Mode,
							TextColor3 = library.FontColor,
							TextSize = 13,
							Font = library.Font,
							TextXAlignment = Enum.TextXAlignment.Center,
							ZIndex = 2,
							Parent = modeframe,
						},{
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local unbindbox = library:Create("Frame", {
							Name = "UnbindBox",
							Size = UDim2.new(0.95, 0,0, 15),
							LayoutOrder = 3,
							BackgroundColor3 = library.MainColor,
							ZIndex = 2,
							Parent = holder,
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local unbindstroke = library:Create("UIStroke", {
							Name = "UIStroke",
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = library.SecondaryColor,
							Thickness = 1,
							Parent = unbindbox,
						},{
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local unbindtext = library:Create("TextLabel", {
							Name = "UnbindText",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "Unbind",
							TextColor3 = library.FontColor,
							TextSize = 13,
							Font = library.Font,
							TextXAlignment = Enum.TextXAlignment.Center,
							ZIndex = 2,
							Parent = unbindbox,
						},{
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local unbindboxt = library:Create("TextButton", {
							Name = "UnbindBoxText",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "",
							ZIndex = 3,
							Parent = unbindbox,
						})

						winkeybox.MouseButton1Click:Connect(startbind)

						Modebox.MouseButton1Click:Connect(function()
							local index = table.find(modes, Mode) or 1
							setMode(modes[index % #modes + 1])
						end)

						unbindboxt.MouseButton1Click:Connect(function()
							setKey(nil)
						end)

						updatetexts()

						outsideConn = InputService.InputBegan:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
								return
							end

							local function isInside(gui)
								local pos, size = gui.AbsolutePosition, gui.AbsoluteSize
								local m = input.Position
								return m.X >= pos.X and m.X <= pos.X + size.X and m.Y >= pos.Y and m.Y <= pos.Y + size.Y
							end

							if isInside(framewindow) or isInside(keyframe) then
								return
							end

							picker:Close()
						end)
					end

					function picker:Close()
						if not opened then return end
						opened = false

						winkeytext = nil
						winmodetext = nil

						if followConn then
							followConn:Disconnect()
							followConn = nil
						end

						if outsideConn then
							outsideConn:Disconnect()
							outsideConn = nil
						end

						if instance then
							instance:Destroy()
							instance = nil
						end
					end

					keybox.MouseButton1Click:Connect(startbind)

					keybox.MouseButton2Click:Connect(function()
						if opened then
							picker:Close()
						else
							openminiwindow()
						end
					end)

					InputService.InputBegan:Connect(function(input, gameproccessed)
						if gameproccessed or waiting_for_key then return end
						if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
						if not currentkey or input.KeyCode ~= currentkey then return end

						if Mode == "Toggle" then
							setState(not active)
						elseif Mode == "Hold" then
							setState(true)
						end
					end)

					InputService.InputEnded:Connect(function(input)
						if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
						if not currentkey or input.KeyCode ~= currentkey then return end

						if Mode == "Hold" then
							setState(false)
						end
					end)

					updatetexts()

					if Mode == "Always" then
						setState(true)
					end

					library.windowinstances.Keybindbox = picker

					return picker
				end

				return label
			end

			function groupbox:AddToggle(name, opts)
				local toggle = {}
				local togglename = name
				local toggled = opts.Default

				if opts.Default == nil then
					toggled = false
				end

				toggle.Value = toggled

				local holder = library:Create("Frame", {
					Name = "Holder";
					Size = UDim2.new(0.95, 0,0, 20);
					BackgroundTransparency = 1;
					LayoutOrder = #elementsholder:GetChildren();
					Parent = elementsholder;
				})

				local hb = library:Create("TextButton", {
					Name = "Hitbox";
					Size = UDim2.new(1, 0, 1, 0);
					BackgroundTransparency = 1;
					ZIndex = 2;
					Text = "";
					Parent = holder;
				})

				local elements = library:Create("Frame", {
					Name = "Holder2";
					Size = UDim2.new(1,0,1,0);
					BackgroundTransparency = 1;
					Parent = holder;
				})

				local uilistlayout = library:Create("UIListLayout", {
					Name = "UIListLayout";
					FillDirection = Enum.FillDirection.Horizontal;
					HorizontalAlignment = Enum.HorizontalAlignment.Left;
					SortOrder = Enum.SortOrder.LayoutOrder;
					VerticalAlignment = Enum.VerticalAlignment.Center;
					Padding = UDim.new(0, 0);
					Parent = elements;
				})

				local boxelem = library:Create("Frame", {
					Name = "Box";
					Size = UDim2.new(0, 15, 0, 15);
					BackgroundColor3 = library.AccentColor;
					BackgroundTransparency = 1;
					LayoutOrder = 1;
					Parent = elements;
				}, {
					instancep = "BackgroundColor3";
					tinstance = library.AccentColor;
				})

				local uis1 = library:Create("UIStroke", {
					Name = "UIStroke";
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
					LineJoinMode = Enum.LineJoinMode.Miter;
					Color = library.SecondaryColor;
					Thickness = 1;

					Parent = boxelem;
				}, {
					instancep = "Color";
					tinstance = library.SecondaryColor;
				})

				local label = library:Create("TextLabel", {
					Name = "Label";
					Size = UDim2.new(0.772, 0, 1, 0);
					BackgroundTransparency = 1;
					Text = name;
					TextColor3 = library.FontColor;
					Font = library.Font;
					TextSize = 13;
					TextXAlignment = Enum.TextXAlignment.Left;
					LayoutOrder = 2;
					TextYAlignment = Enum.TextYAlignment.Center;
					Parent = elements;
				}, {
					instancep = "TextColor3";
					tinstance = library.FontColor;
				}, {
					instancep = "Font";
					tinstance = library.Font;
				})

				local luip = library:Create("UIPadding", {
					Name = "UIPadding";
					PaddingLeft = UDim.new(0, 7);
					PaddingRight = UDim.new(0, 0);
					PaddingTop = UDim.new(0, 0);
					PaddingBottom = UDim.new(0, 0);
					Parent = label;
				})

				local luis = library:Create("UIStroke", {
					Name = "UIStroke";
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
					Color = library.UIstroke;
					Thickness = 1;

					Parent = label;
				}, {
					instancep = "Color";
					tinstance = library.UIstroke;
				})

				local luitextsize = library:Create("UITextSizeConstraint", {
					Name = "UITextSizeConstraint";
					MaxTextSize = 13;
					Parent = label;
				})

				if toggled then
					boxelem.BackgroundTransparency = 0
				end

				local function togglef()
					toggled = not toggled

					if toggled then
						boxelem.BackgroundTransparency = 0
					else
						boxelem.BackgroundTransparency = 1
					end

					Toggles[togglename].value = toggled
					toggle.Value = toggled

					if opts.Callback then
						opts.Callback(toggled)
					end

					if library.UpdateDependencyBoxes then
						library:UpdateDependencyBoxes()
					end
				end

				hb.MouseButton1Click:Connect(togglef)

				Toggles[togglename] = {
					value = toggled;
					keypicker = nil;
				}

				function toggle:AddKeyPicker(name, opts)
					if type(name) == "table" then
						opts = name
						name = togglename
					end

					opts = opts or {}

					local keypicker = {}
					local InputService = InputService or game:GetService("UserInputService")

					local function resolvekey(k)
						if typeof(k) == "EnumItem" then
							return k
						end

						if type(k) == "string" then
							local ok, res = pcall(function()
								return Enum.KeyCode[k]
							end)
							if ok then
								return res
							end
						end

						return nil
					end

					local currentkey = resolvekey(opts.Default)
					local Mode = opts.Mode or "Hold"
					local modes = {"Hold", "Toggle", "Always"}

					local opened = false
					local instance
					local followConn
					local outsideConn
					local waitkeyconn

					local waiting_for_key = false

					local winkeytext
					local winmodetext

					local ignoredkeys = {
						library.Menukey;
						Enum.KeyCode.Return,
						Enum.KeyCode.End,
						Enum.KeyCode.Home,
						Enum.KeyCode.PageUp,
						Enum.KeyCode.PageDown,
					}

					local ignoredset = {}
					for _, k in next, ignoredkeys do
						if k then
							ignoredset[k] = true
						end
					end

					if not Toggles[togglename].keypicker then
						Toggles[togglename].keypicker = keypicker
					else
						warn("KeyPicker already exists for toggle: "..togglename)
						return 
					end

					keypicker.Key = currentkey
					keypicker.Mode = Mode
					keypicker.OnChanged = newSignal()
					Options[name] = keypicker

					local keyframe = library:Create("Frame", {
						Name = "KeyPicker",
						Size = UDim2.new(0, 50, 0, 15),
						LayoutOrder = 999;
						BackgroundColor3 = library.MainColor,
						Parent = elements;
					},{
						instancep = "BackgroundColor3";
						tinstance = library.MainColor;
					})

					local uistrokekey = library:Create("UIStroke", {
						Name = "UIStroke",
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = library.SecondaryColor,
						Thickness = 1,
						Parent = keyframe,
					},{
						instancep = "Color";
						tinstance = library.SecondaryColor;
					})

					local keybox = library:Create("TextButton", {
						Name = "KeyBox",
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = "",
						ZIndex = 4,
						Parent = keyframe,
					})

					local keytext = library:Create("TextLabel", {
						Name = "KeyText",
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = "None",
						TextColor3 = library.FontColor,
						TextSize = 13,
						Font = library.Font,
						TextXAlignment = Enum.TextXAlignment.Center,
						Parent = keyframe,
					},{
						instancep = "TextColor3";
						tinstance = library.FontColor;
					}, {
						instancep = "Font";
						tinstance = library.Font;
					})

					local function setState(state)
						if toggled == state then return end
						togglef()
						Toggles[togglename].value = toggled
					end

					local function updatetexts()
						local t
						if waiting_for_key then
							t = "..."
						elseif currentkey then
							t = keyshorts[currentkey] or currentkey.Name
						else
							t = "None"
						end

						keytext.Text = t
						if winkeytext then
							winkeytext.Text = t
						end
						if winmodetext then
							winmodetext.Text = Mode
						end
					end

					local function setKey(k)
						currentkey = k
						keypicker.Key = k
						updatetexts()

						if opts.CallbackKey then
							opts.CallbackKey(k)
						end

						keypicker.OnChanged:Fire(currentkey, Mode)
					end

					local function setMode(m)
						Mode = m
						keypicker.Mode = m
						updatetexts()

						setState(m == "Always")

						if opts.CallbackMode then
							opts.CallbackMode(m)
						end

						keypicker.OnChanged:Fire(currentkey, Mode)
					end

					local function startbind()
						if waiting_for_key then
							return
						end

						waiting_for_key = true
						updatetexts()

						waitkeyconn = InputService.InputBegan:Connect(function(input, gameproccessed)
							if gameproccessed then return end
							if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
							if ignoredset[input.KeyCode] then return end

							if waitkeyconn then
								waitkeyconn:Disconnect()
								waitkeyconn = nil
							end

							task.defer(function()
								waiting_for_key = false
								updatetexts()
							end)

							if input.KeyCode == Enum.KeyCode.Backspace then
								setKey(nil)
							else
								setKey(input.KeyCode)
							end
						end)
					end

					local function openminiwindow()
						opened = true

						local function getPos()
							local abs = keyframe.AbsolutePosition
							local base = screengui.AbsolutePosition
							return UDim2.new(0, abs.X - base.X, 0, abs.Y - base.Y)
						end

						local cursorbox = library:Create("Frame", {
							Name = "CursorBox";
							Size = UDim2.new(0, 15,0, 15);
							Position = getPos();
							BackgroundColor3 = Color3.new(1,1,1);
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = screengui;
						})

						instance = cursorbox

						followConn = keyframe:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
							if instance then
								instance.Position = getPos()
							end
						end)

						local framewindow = library:Create("Frame", {
							Name = "Frame";
							Size = UDim2.new(0, 323,0, 93);
							Position = UDim2.new(1, 0,1.4, 0);
							BackgroundColor3 = library.MainColor;
							ZIndex = 2;
							Parent = cursorbox;
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local uistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							LineJoinMode = Enum.LineJoinMode.Miter;
							Color = library.SecondaryColor;
							Thickness = 1;
							Parent = framewindow;
						}, {
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local uistroke2 = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							LineJoinMode = Enum.LineJoinMode.Miter;
							Color = library.MainColor;
							Thickness = 4;
							Parent = framewindow;
						}, {
							instancep = "Color";
							tinstance = library.MainColor;
						})

						local text = library:Create("TextLabel", {
							Name = "TextLabel";
							Size = UDim2.new(1, 0,0, 16);
							Position = UDim2.new(0, 0,0, 0);
							Text = name;
							TextColor3 = library.FontColor;
							Font = library.Font;
							TextSize = 13;
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = framewindow;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local textuistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = text;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local textuisize = library:Create("UITextSizeConstraint", {
							Name = "UISizeConstraint";
							MaxTextSize = 13;
							Parent = text;
						})

						local holder = library:Create("Frame", {
							Name = "Holder";
							Size = UDim2.new(1, 0,-0.228, 96);
							Position = UDim2.new(0, 0,0.195, 0);
							BackgroundTransparency = 1;
							ZIndex = 2;
							Parent = framewindow;
						})

						local uill = library:Create("UIListLayout", {
							Name = "UIListLayout";
							Padding = UDim.new(0, 5);
							SortOrder = Enum.SortOrder.LayoutOrder;
							FillDirection = Enum.FillDirection.Vertical;
							HorizontalAlignment = Enum.HorizontalAlignment.Center;
							VerticalAlignment = Enum.VerticalAlignment.Top;
							Parent = holder;
						})

						local uipadd = library:Create("UIPadding", {
							Name = "UIPadding";
							PaddingLeft = UDim.new(0, 0);
							PaddingRight = UDim.new(0, 0);
							PaddingTop = UDim.new(0, 3);
							PaddingBottom = UDim.new(0, 0);
							Parent = holder;
						})

						local keysetbind = library:Create("Frame", {
							Name = "KeysetBind";
							Size = UDim2.new(.95, 0,0, 20);
							BackgroundTransparency = 1;
							LayoutOrder = 1;
							Parent = holder;
							ZIndex = 2;
						})

						local keybindsetuil = library:Create("UIListLayout", {
							Name = "UIListLayout";
							Padding = UDim.new(0, 0);
							SortOrder = Enum.SortOrder.LayoutOrder;
							FillDirection = Enum.FillDirection.Horizontal;
							HorizontalAlignment = Enum.HorizontalAlignment.Left;
							VerticalAlignment = Enum.VerticalAlignment.Center;
							Parent = keysetbind;
						})

						local keylabelset = library:Create("TextLabel", {
							Name = "KeyLabel";
							Size = UDim2.new(1, -55,1, 0);
							BackgroundTransparency = 1;
							Text = "Keybind";
							TextColor3 = library.FontColor;
							TextSize = 13;
							TextXAlignment = Enum.TextXAlignment.Left;
							TextYAlignment = Enum.TextYAlignment.Center;
							Font = library.Font;
							LayoutOrder = 1;
							ZIndex = 2;
							Parent = keysetbind;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local labeluistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = keylabelset;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local labeltsize = library:Create("UITextSizeConstraint", {
							Name = "UITextSizeConstraint";
							MaxTextSize = 13;
							Parent = keylabelset;
						})

						local winkeyframe = library:Create("Frame", {
							Name = "KeyPicker",
							Size = UDim2.new(0, 50, 0, 15),
							LayoutOrder = 2;
							BackgroundColor3 = library.MainColor,
							ZIndex = 2;
							Parent = keysetbind,
						},{
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local winuistrokekey = library:Create("UIStroke", {
							Name = "UIStroke",
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = library.SecondaryColor,
							Thickness = 1,
							Parent = winkeyframe,
						},{
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local winkeybox = library:Create("TextButton", {
							Name = "KeyBox",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "",
							ZIndex = 3,
							Parent = winkeyframe,
						})

						winkeytext = library:Create("TextLabel", {
							Name = "KeyText",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "None",
							TextColor3 = library.FontColor,
							TextSize = 13,
							Font = library.Font,
							TextXAlignment = Enum.TextXAlignment.Center,
							ZIndex = 2,
							Parent = winkeyframe,
						},{
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})


						local modesetbind = library:Create("Frame", {
							Name = "ModesetBind";
							Size = UDim2.new(.95, 0,0, 20);
							BackgroundTransparency = 1;
							LayoutOrder = 2;
							Parent = holder;
							ZIndex = 2;
						})

						local modesetuil = library:Create("UIListLayout", {
							Name = "UIListLayout";
							Padding = UDim.new(0, 0);
							SortOrder = Enum.SortOrder.LayoutOrder;
							FillDirection = Enum.FillDirection.Horizontal;
							HorizontalAlignment = Enum.HorizontalAlignment.Left;
							VerticalAlignment = Enum.VerticalAlignment.Center;
							Parent = modesetbind;
						})

						local modelabelset = library:Create("TextLabel", {
							Name = "ModeLabel";
							Size = UDim2.new(1, -55,1, 0);
							BackgroundTransparency = 1;
							Text = "Mode";
							TextColor3 = library.FontColor;
							TextSize = 13;
							TextXAlignment = Enum.TextXAlignment.Left;
							TextYAlignment = Enum.TextYAlignment.Center;
							Font = library.Font;
							LayoutOrder = 1;
							ZIndex = 2;
							Parent = modesetbind;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local labelmuistroke = library:Create("UIStroke", {
							Name = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
							Color = library.UIstroke;
							Thickness = 1;
							Parent = modelabelset;
						}, {
							instancep = "Color";
							tinstance = library.UIstroke;
						})

						local labelmtsize = library:Create("UITextSizeConstraint", {
							Name = "UITextSizeConstraint";
							MaxTextSize = 13;
							Parent = modelabelset;
						})

						local modeframe = library:Create("Frame", {
							Name = "ModePicker",
							Size = UDim2.new(0, 50, 0, 15),
							LayoutOrder = 2;
							BackgroundColor3 = library.MainColor,
							ZIndex = 2;
							Parent = modesetbind,
						},{
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local uistrokemode = library:Create("UIStroke", {
							Name = "UIStroke",
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = library.SecondaryColor,
							Thickness = 1,
							Parent = modeframe,
						},{
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local Modebox = library:Create("TextButton", {
							Name = "ModeBox",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "",
							ZIndex = 3,
							Parent = modeframe,
						})

						winmodetext = library:Create("TextLabel", {
							Name = "ModeText",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = Mode,
							TextColor3 = library.FontColor,
							TextSize = 13,
							Font = library.Font,
							TextXAlignment = Enum.TextXAlignment.Center,
							ZIndex = 2,
							Parent = modeframe,
						},{
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local unbindbox = library:Create("Frame", {
							Name = "UnbindBox",
							Size = UDim2.new(0.95, 0,0, 15),
							LayoutOrder = 3,
							BackgroundColor3 = library.MainColor,
							ZIndex = 2,
							Parent = holder,
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						local unbindstroke = library:Create("UIStroke", {
							Name = "UIStroke",
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = library.SecondaryColor,
							Thickness = 1,
							Parent = unbindbox,
						},{
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local unbindtext = library:Create("TextLabel", {
							Name = "UnbindText",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "Unbind",
							TextColor3 = library.FontColor,
							TextSize = 13,
							Font = library.Font,
							TextXAlignment = Enum.TextXAlignment.Center,
							ZIndex = 2,
							Parent = unbindbox,
						},{
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local unbindboxt = library:Create("TextButton", {
							Name = "UnbindBoxText",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "",
							ZIndex = 3,
							Parent = unbindbox,
						})

						winkeybox.MouseButton1Click:Connect(startbind)

						Modebox.MouseButton1Click:Connect(function()
							local index = table.find(modes, Mode) or 1
							setMode(modes[index % #modes + 1])
						end)

						unbindboxt.MouseButton1Click:Connect(function()
							setKey(nil)
						end)

						updatetexts()

						outsideConn = InputService.InputBegan:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
								return
							end

							local function isInside(gui)
								local pos, size = gui.AbsolutePosition, gui.AbsoluteSize
								local m = input.Position
								return m.X >= pos.X and m.X <= pos.X + size.X and m.Y >= pos.Y and m.Y <= pos.Y + size.Y
							end

							if isInside(framewindow) or isInside(keyframe) then
								return
							end

							keypicker:Close()
						end)
					end

					function keypicker:Close()
						if not opened then return end
						opened = false

						winkeytext = nil
						winmodetext = nil

						if followConn then
							followConn:Disconnect()
							followConn = nil
						end

						if outsideConn then
							outsideConn:Disconnect()
							outsideConn = nil
						end

						if instance then
							instance:Destroy()
							instance = nil
						end
					end

					keybox.MouseButton1Click:Connect(startbind)

					keybox.MouseButton2Click:Connect(function()
						if opened then
							keypicker:Close()
						else
							openminiwindow()
						end
					end)

					InputService.InputBegan:Connect(function(input, gameproccessed)
						if gameproccessed or waiting_for_key then return end
						if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
						if not currentkey or input.KeyCode ~= currentkey then return end

						if Mode == "Toggle" then
							setState(not toggled)
						elseif Mode == "Hold" then
							setState(true)
						end
					end)

					InputService.InputEnded:Connect(function(input)
						if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
						if not currentkey or input.KeyCode ~= currentkey then return end

						if Mode == "Hold" then
							setState(false)
						end
					end)

					updatetexts()

					if Mode == "Always" then
						setState(true)
					end

					library.windowinstances.Keybindbox = keypicker

					return keypicker
				end

				return toggle
			end

			function groupbox:AddSlider(name, opts)
				opts = opts or {}

				local slider = {}
				local UIS = InputService

				local config = {
					Minimum = opts.Minimum;
					Maximum = opts.Maximum;
					DefaultValue = opts.Default;
					Step = opts.Step;
					Format = opts.Format;
				}

				local range = config.Maximum - config.Minimum
				if range <= 0 then
					range = 1
				end

				local stepsize = config.Step > 0 and config.Step

				local function decimalsof(n)
					local d = tostring(n):match("%.(%d+)")
					return d and #d or 0
				end

				local decimals = opts.Rounding or math.max(decimalsof(stepsize), decimalsof(config.Minimum))

				local currentvalue = config.Minimum
				local dragging = false

				local mainframe = library:Create("Frame", {
					Name = "Slider",
					Size = UDim2.new(0.95, 0, 0, 20),
					BackgroundTransparency = 1,
					LayoutOrder = #elementsholder:GetChildren(),
					Parent = elementsholder,
				})

				local uistroke = library:Create("UIStroke", {
					Name = "UIStroke",
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = library.SecondaryColor,
					Thickness = 1,
					LineJoinMode = Enum.LineJoinMode.Miter,
					Parent = mainframe,
				}, {
					instancep = "Color";
					tinstance = library.SecondaryColor;
				})

				local frame = library:Create("Frame", {
					Name = "Frame",
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundColor3 = library.AccentColor,
					Parent = mainframe,
				}, {
					instancep = "BackgroundColor3";
					tinstance = library.AccentColor;
				})

				local hitbox = library:Create("TextButton", {
					Name = "Hitbox",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					ZIndex = 3,
					Parent = mainframe,
				})

				local text = library:Create("TextLabel", {
					Name = "Text",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = name,
					TextColor3 = library.FontColor,
					Font = library.Font,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					ZIndex = 2,
					Parent = mainframe,
				}, {
					instancep = "TextColor3";
					tinstance = library.FontColor;
				}, {
					instancep = "Font";
					tinstance = library.Font;
				})

				local uistoke2 = library:Create("UIStroke", {
					Name = "UIStroke",
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
					Color = library.UIstroke,
					Thickness = 1,
					LineJoinMode = Enum.LineJoinMode.Round,
					Parent = text,
				}, {
					instancep = "Color";
					tinstance = library.UIstroke;
				})

				local textuisize = library:Create("UITextSizeConstraint", {
					Name = "UITextSizeConstraint",
					MaxTextSize = 13,
					Parent = text,
				})

				local function fmt(n)
					return tostring(n)
				end

				local function refreshui()
					local alpha = (currentvalue - config.Minimum) / range
					frame.Size = UDim2.new(math.clamp(alpha, 0, 1), 0, 1, 0)

					local suffix = ""
					if config.Format ~= "" then
						suffix = " " .. config.Format
					end

					text.Text = name .. ": " .. fmt(currentvalue) .. "/" .. fmt(config.Maximum) .. suffix
				end

				local function setvalue(v, silent)
					v = math.clamp(v, config.Minimum, config.Maximum)
					v = config.Minimum + math.floor((v - config.Minimum) / stepsize + 0.5) * stepsize
					v = math.clamp(v, config.Minimum, config.Maximum)
					v = tonumber(string.format("%." .. decimals .. "f", v))

					local changed = v ~= currentvalue
					currentvalue = v
					slider.Value = v
					refreshui()

					if changed and not silent then
						if opts.Callback then
							opts.Callback(v)
						end

						slider.OnChanged:Fire(v)
					end
				end

				slider.Value = currentvalue
				slider.OnChanged = newSignal()
				Options[name] = slider

				function slider:SetValue(v)
					setvalue(v)
				end

				function slider:GetValue()
					return currentvalue
				end

				setvalue(config.DefaultValue, true)

				local moveConn
				local endConn

				local function stop()
					dragging = false

					if moveConn then
						moveConn:Disconnect()
						moveConn = nil
					end

					if endConn then
						endConn:Disconnect()
						endConn = nil
					end
				end

				local function drag(input)
					local pos, size = mainframe.AbsolutePosition, mainframe.AbsoluteSize
					local alpha = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
					setvalue(config.Minimum + alpha * range)
				end

				hitbox.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						stop()
						dragging = true
						drag(input)

						moveConn = UIS.InputChanged:Connect(function(i)
							if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
								drag(i)
							end
						end)

						endConn = UIS.InputEnded:Connect(function(i)
							if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
								stop()
							end
						end)
					end
				end)

				return slider
			end
			
			function groupbox:AddButton(name , opts)
				opts = opts or {}

				local button = {}

				local warnclick = opts.WarnClick or opts.Warn or false
				local smaller = opts.Smaller or false
				local armed = false
				local armtoken = 0

				local Holder = library:Create("Frame", {
					Name = "Button",
					Size = smaller and UDim2.new(0.465, 0, 0, 15) or UDim2.new(0.95, 0,0, 15),
					LayoutOrder = #elementsholder:GetChildren(),
					BackgroundColor3 = library.MainColor,
					Parent = elementsholder,
				}, {
					instancep = "BackgroundColor3";
					tinstance = library.MainColor;
				})

				local stroketext = library:Create("UIStroke", {
					Name = "UIStroke",
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = library.SecondaryColor,
					Thickness = 1,
					Parent = Holder,
				},{
					instancep = "Color";
					tinstance = library.SecondaryColor;
				})

				local text = library:Create("TextLabel", {
					Name = "text",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = name,
					TextColor3 = library.FontColor,
					TextSize = 13,
					Font = library.Font,
					TextXAlignment = Enum.TextXAlignment.Center,
					ZIndex = 2,
					Parent = Holder,
				},{
					instancep = "TextColor3";
					tinstance = library.FontColor;
				}, {
					instancep = "Font";
					tinstance = library.Font;
				})

				local uistroke = library:Create("UIStroke", {
					Name = "UIStroke",
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
					Color = library.UIstroke,
					Thickness = 1,
					Parent = text,
				},{
					instancep = "Color";
					tinstance = library.UIstroke;
				})

				local textsizecon = library:Create("UITextSizeConstraint", {
					Name = "UITextSizeConstraint",
					MaxTextSize = 13,
					Parent = text,
				})

				local Textbutton = library:Create("TextButton", {
					Name = "Boxhit",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					ZIndex = 3,
					Parent = Holder,
				})

				local function disarm()
					armed = false
					armtoken += 1
					text.Text = name
					text.TextColor3 = library.FontColor
				end

				Textbutton.MouseButton1Click:Connect(function()
					if warnclick and not armed then
						armed = true
						text.Text = "Are you sure?"
						text.TextColor3 = Color3.fromRGB(255, 0, 0)

						armtoken += 1
						local mytoken = armtoken

						task.delay(2, function()
							if armed and armtoken == mytoken then
								disarm()
							end
						end)

						return
					end

					if armed then
						disarm()
					end

					if opts.Callback then
						opts.Callback()
					end
				end)

				return button
			end

			function groupbox:AddDependencyBox()
				local dependencybox = {}
				dependencybox.Dependencies = {}

				local groupbox = self
				local Container = elementsholder

				local Holder = library:Create("Frame", {
					Name = "DependencyBox";
					BackgroundTransparency = 1;
					Size = UDim2.new(1, 0, 0, 0);
					AutomaticSize = Enum.AutomaticSize.Y;
					LayoutOrder = #Container:GetChildren();
					Visible = false;
					Parent = Container;
				})

				local Frame = library:Create("Frame", {
					Name = "Elements";
					BackgroundTransparency = 1;
					Size = UDim2.new(1, 0, 0, 0);
					AutomaticSize = Enum.AutomaticSize.Y;
					Parent = Holder;
				})

				local Layout = library:Create("UIListLayout", {
					Name = "UIListLayout";
					FillDirection = Enum.FillDirection.Horizontal;
					Wraps = true;
					HorizontalAlignment = Enum.HorizontalAlignment.Center;
					VerticalAlignment = Enum.VerticalAlignment.Top;
					SortOrder = Enum.SortOrder.LayoutOrder;
					Padding = UDim.new(0, 5);
					Parent = Frame;
				})

				local order = 0

				local function wrap(fname)
					if typeof(groupbox[fname]) ~= "function" then
						return
					end

					dependencybox[fname] = function(_, ...)
						local before = {}

						for _, child in ipairs(Container:GetChildren()) do
							before[child] = true
						end

						local result = groupbox[fname](groupbox, ...)

						for _, child in ipairs(Container:GetChildren()) do
							if not before[child] then
								order += 1
								child.LayoutOrder = order
								child.Parent = Frame
							end
						end

						return result
					end
				end

				for _, fname in ipairs({"AddLabel", "AddToggle", "AddSlider", "AddButton", "AddTextbox", "AddDropdown", "AddDependencyBox", "Divider"}) do
					wrap(fname)
				end

				function dependencybox:Update()
					for _, Dependency in next, dependencybox.Dependencies do
						local Element = Dependency[1]
						local Value = Dependency[2]

						local current = Element.Value
						if current == nil then
							current = Element.value
						end

						if current ~= Value then
							Holder.Visible = false
							return
						end
					end

					Holder.Visible = true
				end

				function dependencybox:SetupDependencies(Dependencies)
					for _, Dependency in next, Dependencies do
						assert(typeof(Dependency) == "table", "SetupDependencies: Dependency is not of type `table`.")
						assert(Dependency[1], "SetupDependencies: Dependency is missing element argument.")
						assert(Dependency[2] ~= nil, "SetupDependencies: Dependency is missing value argument.")
					end

					dependencybox.Dependencies = Dependencies
					dependencybox:Update()
				end

				table.insert(groupbox.elements, dependencybox)
				table.insert(library.DependencyBoxes, dependencybox)

				return dependencybox
			end
			
			function groupbox:AddDropdown(name, opts)
				opts = opts or {}

				library.Options = library.Options or {}

				if library.Options[name] then
					warn("An option named '" .. name .. "' already exists.")
					return nil
				end

				local Dropdown = {}
				local elements = {}
				local picked = nil
				local Multipicked = {}
				local isopen = false
				local maxItems = 10
				local updating = false

				opts.Values = opts.Values or {}

				while #opts.Values > maxItems do
					table.remove(opts.Values)
				end

				local changedEvent = Instance.new("BindableEvent")

				local option = {
					Type = "Dropdown",
					Name = name,
					Value = nil,
					OnChanged = changedEvent.Event,
				}

				library.Options[name] = option

				local main = library:Create("Frame", {
					Name = "Dropdown",
					ZIndex = 10,
					Size = UDim2.new(0.95, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = #elementsholder:GetChildren(),
					BackgroundTransparency = 1,
					Parent = elementsholder,
				})

				library:Create("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = main,
				})

				local header = library:Create("TextLabel", {
					Name = "Header",
					ZIndex = 11,
					Size = UDim2.new(1, 0, 0, 15),
					LayoutOrder = 1,
					BackgroundTransparency = 1,
					Text = name,
					Font = library.Font,
					TextColor3 = library.FontColor,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = main,
				}, {
					instancep = "TextColor3",
					tinstance = library.FontColor,
				}, {
					instancep = "Font",
					tinstance = library.Font,
				})

				library:Create("UITextSizeConstraint", {
					MaxTextSize = 13,
					Parent = header,
				})

				library:Create("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
					Color = library.UIstroke,
					Thickness = 1,
					Parent = header,
				}, {
					instancep = "Color",
					tinstance = library.UIstroke,
				})

				local dropdownFrame = library:Create("Frame", {
					Name = "DropdownFrame",
					ZIndex = 10,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = 2,
					BackgroundTransparency = 1,
					ClipsDescendants = false,
					Parent = main,
				})

				library:Create("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 3),
					Parent = dropdownFrame,
				})

				local selectionRow = library:Create("Frame", {
					Name = "SelectionRow",
					ZIndex = 11,
					Size = UDim2.new(1, 0, 0, 20),
					LayoutOrder = 1,
					BackgroundTransparency = 1,
					Parent = dropdownFrame,
				})

				library:Create("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = library.SecondaryColor,
					Thickness = 1,
					Parent = selectionRow,
				}, {
					instancep = "Color",
					tinstance = library.SecondaryColor,
				})

				local selectedLabel = library:Create("TextLabel", {
					Name = "Selected",
					ZIndex = 12,
					Size = UDim2.new(1, -25, 1, 0),
					Position = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = "-",
					Font = library.Font,
					TextColor3 = library.AccentColor,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Parent = selectionRow,
				}, {
					instancep = "TextColor3",
					tinstance = library.AccentColor,
				}, {
					instancep = "Font",
					tinstance = library.Font,
				})

				library:Create("UIPadding", {
					PaddingLeft = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 3),
					Parent = selectedLabel,
				})

				library:Create("UITextSizeConstraint", {
					MaxTextSize = 13,
					Parent = selectedLabel,
				})

				library:Create("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
					Color = library.UIstroke,
					Thickness = 1,
					Parent = selectedLabel,
				}, {
					instancep = "Color",
					tinstance = library.UIstroke,
				})

				local arrow = library:Create("ImageLabel", {
					Name = "DropdownImage",
					ZIndex = 13,
					Size = UDim2.new(0, 15, 0, 15),
					Position = UDim2.new(1, -19, 0.5, -7),
					BackgroundTransparency = 1,
					Image = "rbxassetid://10709767827",
					ScaleType = Enum.ScaleType.Crop,
					Parent = selectionRow,
				})

				local button = library:Create("TextButton", {
					Name = "DropdownButton",
					ZIndex = 14,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					AutoButtonColor = false,
					Parent = selectionRow,
				})

				local holder = library:Create("ScrollingFrame", {
					Name = "Holder",
					ZIndex = 20,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					CanvasSize = UDim2.new(0, 0, 0, 0),
					LayoutOrder = 2,
					BackgroundColor3 = library.MainColor,
					BorderSizePixel = 0,
					ScrollBarThickness = 0,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					Visible = false,
					ClipsDescendants = true,
					Parent = dropdownFrame,
				}, {
					instancep = "BackgroundColor3",
					tinstance = library.MainColor,
				})

				library:Create("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = library.SecondaryColor,
					Thickness = 1,
					Parent = holder,
				})

				library:Create("UIListLayout", {
					Name = "UIListLayout",
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					Padding = UDim.new(0, 4),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = holder,
				})

				library:Create("UIPadding", {
					PaddingLeft = UDim.new(0, 2),
					PaddingRight = UDim.new(0, 2),
					PaddingTop = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 2),
					Parent = holder,
				})

				library:Create("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = library.SecondaryColor,
					Thickness = 1,
					Parent = holder,
				}, {
					instancep = "Color",
					tinstance = library.SecondaryColor,
				})

				local function getValue()
					if opts.Multipick then
						local values = {}

						for i, value in ipairs(opts.Values) do
							if Multipicked[i] then
								table.insert(values, value)
							end
						end

						return values
					end

					return picked
				end

				local function getIndex()
					if opts.Multipick then
						local indices = {}

						for i = 1, #opts.Values do
							if Multipicked[i] then
								table.insert(indices, i)
							end
						end

						return indices
					end

					for i, value in ipairs(opts.Values) do
						if value == picked then
							return i
						end
					end

					return nil
				end

				local function updateSelectedText()
					if opts.Multipick then
						local values = {}

						for i, value in ipairs(opts.Values) do
							if Multipicked[i] then
								table.insert(values, tostring(value))
							end
						end

						selectedLabel.Text = #values > 0
							and table.concat(values, ", ")
							or "-"
					else
						selectedLabel.Text = picked ~= nil
							and tostring(picked)
							or "-"
					end

					-- Accent only when a value is selected; otherwise use the normal font color.
					local hasSelection
					if opts.Multipick then
						hasSelection = next(Multipicked) ~= nil
					else
						hasSelection = picked ~= nil
					end

					selectedLabel.TextColor3 = hasSelection
						and library.AccentColor
						or library.FontColor

					option.Value = getValue()
				end

				local function updateItems()
					for _, item in ipairs(elements) do
						local selected

						if opts.Multipick then
							selected = Multipicked[item.index] == true
						else
							selected = picked == item.name
						end

						item.button.Text = selected
							and ("✓  " .. tostring(item.name))
							or tostring(item.name)

						item.button.TextColor3 = selected
							and library.AccentColor
							or library.FontColor
					end
				end

				local function notifyChanged()
					local value = getValue()

					option.Value = value
					changedEvent:Fire(value)

					if opts.Callback then
						opts.Callback(value)
					end
				end

				local function setValue(value, silent)
					if opts.Multipick then
						table.clear(Multipicked)

						local selections = type(value) == "table"
							and value
							or {value}

						for _, selection in ipairs(selections) do
							local index

							if type(selection) == "number" then
								index = selection
							else
								for i, itemName in ipairs(opts.Values) do
									if itemName == selection then
										index = i
										break
									end
								end
							end

							if index and index >= 1 and index <= #opts.Values then
								Multipicked[index] = true
							end
						end
					else
						local index

						if type(value) == "number" then
							index = value
						else
							for i, itemName in ipairs(opts.Values) do
								if itemName == value then
									index = i
									break
								end
							end
						end

						if index and index >= 1 and index <= #opts.Values then
							picked = opts.Values[index]
						else
							picked = nil
						end
					end

					updateSelectedText()
					updateItems()

					if not silent then
						notifyChanged()
					end
				end

				function option:GetValue()
					return getValue()
				end

				function option:GetIndex()
					return getIndex()
				end

				function option:SetValue(value)
					setValue(value, false)
				end

				function Dropdown:GetValue()
					return getValue()
				end

				function Dropdown:GetIndex()
					return getIndex()
				end

				function Dropdown:SetValue(value)
					option:SetValue(value)
				end

				function Dropdown:GetInstance()
					return selectedLabel
				end

				local function toggleOpen()
					isopen = not isopen
					holder.Visible = isopen
					arrow.Rotation = isopen and 180 or 0
				end

				button.MouseButton1Click:Connect(toggleOpen)

				function Dropdown:AddItem(itemName)
					if #opts.Values >= maxItems then
						warn("Dropdown maximum is 10 items.")
						return nil
					end

					table.insert(opts.Values, itemName)

					local index = #opts.Values
					local item = {
						name = itemName,
						index = index,
					}

					local itemButton = library:Create("TextButton", {
						Name = "Item_" .. index,
						ZIndex = 21,
						Size = UDim2.new(1, 0, 0, 18),
						BackgroundTransparency = 1,
						Text = tostring(itemName),
						TextSize = 13,
						TextColor3 = library.FontColor,
						Font = library.Font,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						LayoutOrder = index,
						AutoButtonColor = false,
						Parent = holder,
					}, {
						instancep = "Font",
						tinstance = library.Font,
					})

					item.button = itemButton
					elements[index] = item

					local itemIndex = index
					itemButton.MouseButton1Click:Connect(function()
						if opts.Multipick then
							-- Clicking an already-selected item must deselect it.
							Multipicked[itemIndex] = not (Multipicked[itemIndex] == true)
						else
							picked = itemName
							isopen = false
							holder.Visible = false
							arrow.Rotation = 0
						end

						updateSelectedText()
						updateItems()
						notifyChanged()
					end)

					updateSelectedText()
					updateItems()

					return item
				end

				function Dropdown:Refresh(values, defaultValue)
					values = values or {}

					-- Copy first: callers may pass opts.Values itself.
					local refreshedValues = {}
					for _, value in ipairs(values) do
						table.insert(refreshedValues, value)
					end
					values = refreshedValues

					if #values > maxItems then
						warn("Dropdown supports a maximum of 10 items.")
						return
					end

					for _, item in ipairs(elements) do
						item.button:Destroy()
					end

					table.clear(elements)
					table.clear(opts.Values)
					table.clear(Multipicked)

					picked = nil

					for _, value in ipairs(values) do
						self:AddItem(value)
					end

					setValue(defaultValue, true)
				end

				for _, value in ipairs(opts.Values) do
					Dropdown:AddItem(value)
				end

				-- Apply defaults without firing callbacks during initialization.
				if opts.Default ~= nil then
					setValue(opts.Default, true)
				else
					updateSelectedText()
					updateItems()
				end

				Dropdown.Instance = selectedLabel
				Dropdown.Holder = holder
				Dropdown.Option = option

				return Dropdown
			end


			function groupbox:AddInput(name, opts)
				opts = opts or {}

				local input = {}

				local initialValue = tostring(opts.Default or "")
				local changedEvent = Instance.new("BindableEvent")

				local option = {
					Type = "Input",
					Name = name,
					Value = initialValue,
					OnChanged = changedEvent.Event,
				}

				library.Options = library.Options or {}
				library.Options[name] = option

				local Holder = library:Create("Frame", {
					Name = "Input",
					Size = UDim2.new(0.95, 0, 0, 20),
					LayoutOrder = #elementsholder:GetChildren(),
					BackgroundColor3 = library.MainColor,
					Parent = elementsholder,
				}, {
					instancep = "BackgroundColor3",
					tinstance = library.MainColor,
				})

				library:Create("UIStroke", {
					Name = "UIStroke",
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = library.SecondaryColor,
					Thickness = 1,
					Parent = Holder,
				}, {
					instancep = "Color",
					tinstance = library.SecondaryColor,
				})

				local text = library:Create("TextBox", {
					Name = "Text",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					ClearTextOnFocus = false,
					MultiLine = false,
					PlaceholderText = name .. "..",
					Text = initialValue,
					TextColor3 = library.FontColor,
					TextSize = 13,
					Font = library.Font,
					TextXAlignment = Enum.TextXAlignment.Center,
					ZIndex = 2,
					Parent = Holder,
				}, {
					instancep = "TextColor3",
					tinstance = library.FontColor,
				}, {
					instancep = "Font",
					tinstance = library.Font,
				})

				library:Create("UIStroke", {
					Name = "TextStroke",
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
					Color = library.UIstroke,
					Thickness = 1,
					Parent = text,
				}, {
					instancep = "Color",
					tinstance = library.UIstroke,
				})

				library:Create("UITextSizeConstraint", {
					Name = "UITextSizeConstraint",
					MaxTextSize = 13,
					Parent = text,
				})

				local updating = false

				local function setValue(value, silent)
					value = tostring(value or "")

					option.Value = value

					if text.Text ~= value then
						updating = true
						text.Text = value
						updating = false
					end

					if not silent then
						changedEvent:Fire(value)

						if opts.Callback then
							opts.Callback(value)
						end
					end
				end

				function option:GetValue()
					return option.Value
				end

				function option:SetValue(value)
					setValue(value, false)
				end

				function input:GetValue()
					return option.Value
				end

				function input:SetValue(value)
					option:SetValue(value)
				end

				function input:GetInstance()
					return text
				end

				text:GetPropertyChangedSignal("Text"):Connect(function()
					if updating then
						return
					end

					local value = text.Text

					if option.Value == value then
						return
					end

					option.Value = value
					changedEvent:Fire(value)

					if opts.Callback then
						opts.Callback(value)
					end
				end)

				input.Instance = text
				input.Holder = Holder
				input.Option = option

				return input
			end

			function groupbox:Divider()
				local divider = {}
				
				local frame = library:Create("Frame", {
					Name = "Divider",
					Size = UDim2.new(0.95, 0, 0, 3),
					BackgroundColor3 = library.MainColor,
					LayoutOrder = #elementsholder:GetChildren(),
					Parent = elementsholder,
				}, {
					instancep = "BackgroundColor3";
					tinstance = library.MainColor;
				})
				
				local uistroke1 = library:Create("UIStroke", {
					Name = "UIStroke",
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = library.SecondaryColor,
					Thickness = 1,
					ZIndex = 2,
					Parent = frame,
				}, {
					instancep = "Color";
					tinstance = library.SecondaryColor;
				})
				
				return divider
			end

			return groupbox
		end
		
		function tab:AddGroupbox(side, opts)
			if side == "left" then
				return self:AddLeftGroupbox(opts)
			end
			return self:AddRightGroupbox(opts)
		end
		
		table.insert(library.Tabs, tab)
		library.TabsCount += 1
		tab.frame = tabpage
		
		if isFirst then
			library.Tab = tab
			tab.visible = true
		end

		function tab:Close()
			tab.frame.Visible = false
			tabframemain.BackgroundColor3 = library.MainColor
		end

		function tab:Open()
			local pickedcolor = library.MainColor:Lerp(Color3.new(1, 1, 1), 0.2)

			library:CloseAllTabs()
			tab.frame.Visible = true
			tabframemain.BackgroundColor3 = pickedcolor
		end

		tabbutton.Activated:Connect(function()
			library.Tab = tab
			tab:Open()
		end)
		
		return tab
	end
	
	-- on drag thing
	local dragging = false
	local dragStart
	local startPos

	local dragclone

	local function update(input)
		local delta = input.Position - dragStart

		local targetPosition = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)

		if dragclone then
			dragclone.Position = targetPosition
		end
	end

	-- Only start dragging when the drag button itself is pressed
	dragbutton.InputBegan:Connect(function(input)
		if configuration.Draggable == false then return end
		if dragging then return end -- ignore extra presses while already dragging

		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPos = mainframe.Position

			-- Create drag preview.
			dragclone = library:Create("Frame", {
				Name = "fakewin";
				Size = mainframe.Size;
				Position = mainframe.Position;
				AnchorPoint = mainframe.AnchorPoint;
				BackgroundTransparency = 1;
				ZIndex = 100;
				Visible = true;
			})

			library:Create("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
				Color = library.AccentColor;
				Thickness = 1;
				Parent = dragclone;
				ZIndex = 100;
			}, {
				instancep = "Color";
				tinstance = library.AccentColor;
			})

			dragclone.Parent = screengui

			-- Hide the actual window while dragging.
			mainframe.Visible = false

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false

					if dragclone then
						-- Snap real frame to the final clone position.
						mainframe.Position = dragclone.Position

						dragclone:Destroy()
						dragclone = nil
					end

					mainframe.Visible = library.visible
				end
			end)
		end
	end)

	table.insert(connections, InputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end))

	window.MainFrame = mainframe
	window.Config = configuration
	library.MainFrame = library.MainFrame or mainframe
	table.insert(library.mainwindows, window)

	if configuration.Center ~= false then
		mainframe.Position = UDim2.new(0.5, 0, 0.5, 0)
	end

	if library.visible then
		mainframe.Visible = true
	end

	if configuration.AutoShow and not library.visible then
		library:Toggle()
	end

	return window
end

function library:Watermark(configuration)
	local wm = {}
	local visible = false
	
	-- creation
	local mainwmframe = library:Create("Frame", {
		Name = "Watermark";
		Size = UDim2.new(0, 338,0, 27);
		Position = UDim2.new(0.425, 0,0.055, 0);
		AnchorPoint = Vector2.new(0, 0);
		BackgroundColor3 = library.MainColor;
		Parent = screengui;
		ZIndex = 1;
		Visible = visible;
	}, {
		instancep = "BackgroundColor3";
		tinstance = library.MainColor;
	})
	
	
	local uistroke1 = library:Create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		Color = library.SecondaryColor;
		LineJoinMode = Enum.LineJoinMode.Miter;
		Thickness = 1;
		Parent = mainwmframe;
		ZIndex = 1;
	},
	{
		instancep = "Color";
		tinstance = library.SecondaryColor;
	})
	
	local uistroke2 = library:Create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		Color = library.MainColor;
		Thickness = 3;
		Parent = mainwmframe;
		ZIndex = 0;
		LineJoinMode = Enum.LineJoinMode.Miter;
	},
	{
		instancep = "Color";
		tinstance = library.MainColor;
	})
	
	local uily = library:Create("UIListLayout", {
		Padding = UDim.new(0, 8);
		FillDirection = Enum.FillDirection.Horizontal;
		HorizontalAlignment = Enum.HorizontalAlignment.Left;
		VerticalAlignment = Enum.VerticalAlignment.Center;
		SortOrder = Enum.SortOrder.LayoutOrder;
		Parent = mainwmframe;
	})
	
	local iconf = library:Create("CanvasGroup", {
		Name = "IconFrame";
		BackgroundTransparency = 1;
		Position = UDim2.new(0, 0, 0, 0);
		Size = UDim2.new(0.097, 0,1, 0);
		LayoutOrder = 1;
		Parent = mainwmframe;
	})
	
	local uilicon = library:Create("UIListLayout", {
		Padding = UDim.new(0, 0);
		FillDirection = Enum.FillDirection.Horizontal;
		HorizontalAlignment = Enum.HorizontalAlignment.Left;
		VerticalAlignment = Enum.VerticalAlignment.Center;
		SortOrder = Enum.SortOrder.LayoutOrder;
		Parent = iconf;
	})
	
	local iconnt = library:Create("ImageLabel", {
		Name = "icon";
		Size = UDim2.new(0, 40,0, 39);
		Position = UDim2.new(0, 0,0, 0);
		BackgroundTransparency = 1;

		ImageColor3 = library.AccentColor;

		Image = "rbxassetid://132964249585974";
		ScaleType = Enum.ScaleType.Crop;
		Parent = iconf;
	}, {
		instancep = "ImageColor3";
		tinstance = library.AccentColor;
	})
	
	local gradient = library:Create("UIGradient", {
		Name = "grad";
		Offset = Vector2.new(0, 0);
		Rotation = 90;
		Parent = iconnt;

		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.new(1,1,1));
			ColorSequenceKeypoint.new(0.4, Color3.new(1,1,1));
			ColorSequenceKeypoint.new(0.498, Color3.new(0.258824, 0.258824, 0.258824));
			ColorSequenceKeypoint.new(.6, Color3.new(1,1,1));
			ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
		};
	})
	
	local textf = library:Create("CanvasGroup", {
		Name = "TextFrame";
		BackgroundTransparency = 1;
		Position = UDim2.new(0, 0, 0, 0);
		Size = UDim2.new(0.879, 0,0.657, 0);
		LayoutOrder = 2;
		Parent = mainwmframe;
	})

	local uilicon = library:Create("UIListLayout", {
		Padding = UDim.new(0, 0);
		FillDirection = Enum.FillDirection.Horizontal;
		HorizontalAlignment = Enum.HorizontalAlignment.Left;
		VerticalAlignment = Enum.VerticalAlignment.Center;
		SortOrder = Enum.SortOrder.LayoutOrder;
		Parent = textf;
	})

	local uipadd1 = library:Create("UIPadding", {
		PaddingLeft = UDim.new(0, 1);
		PaddingRight = UDim.new(0, 0);
		PaddingTop = UDim.new(0, 0);
		PaddingBottom = UDim.new(0, 1);
		Parent = textf;
	})
	
	local textlabel = library:Create("TextLabel", {
		Name = "Text";
		BackgroundTransparency = 1;
		Position = UDim2.new(0, 0, 0, 0);
		Size = UDim2.new(1, 0, 1, 0);
		Text = "placeholder";
		Font = library.Font;
		TextSize = 14;
		TextColor3 = library.FontColor;
		TextXAlignment = Enum.TextXAlignment.Left;
		Parent = textf;
	}, {
		instancep = "TextColor3";
		tinstance = library.FontColor;
	})
	
	local textls = library:Create("UIStroke", {
		Name = "UIStroke";
		ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
		Color = library.UIStroke;
		Thickness = 1;
		Parent = textlabel;
	}, {
		instancep = "Color";
		tinstance = library.UIStroke;
	})
	
	local textts = library:Create("UITextSizeConstraint", {
		Name = "UITextSizeConstraint";
		MaxTextSize = 14;
		Parent = textlabel;
	})
	
	-- functions
	function wm:WatermarkUpdate(text)
		text = text or "Placeholder"
		textlabel.Text = text
	end
	
	function wm:ToggleVisibility(bool)
		if bool then
			mainwmframe.Visible = true
			visible = true
		else
			mainwmframe.Visible = false
			visible = false
		end
	end
	
	-- drag
	-- implement dragging to this to make it draggable use normal dragging to
	local dragging = false
	local dragStart
	local startPos

	local dragclone

	local function update(input)
		local delta = input.Position - dragStart

		local targetPosition = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)

		if dragclone then
			dragclone.Position = targetPosition
		end
	end

	-- Only start dragging when the drag button itself is pressed
	mainwmframe.InputBegan:Connect(function(input)
		if configuration.Draggable == false then return end
		if dragging then return end -- ignore extra presses while already dragging

		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPos = mainwmframe.Position

			-- Create drag preview.
			dragclone = library:Create("Frame", {
				Name = "fakewin";
				Size = mainwmframe.Size;
				Position = mainwmframe.Position;
				AnchorPoint = mainwmframe.AnchorPoint;
				BackgroundTransparency = 1;
				ZIndex = 100;
				Visible = true;
			})

			library:Create("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
				Color = library.AccentColor;
				Thickness = 1;
				Parent = dragclone;
				ZIndex = 100;
			}, {
				instancep = "Color";
				tinstance = library.AccentColor;
			})

			dragclone.Parent = screengui

			-- Hide the actual window while dragging.
			mainwmframe.Visible = false

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false

					if dragclone then
						-- Snap real frame to the final clone position.
						mainwmframe.Position = dragclone.Position

						dragclone:Destroy()
						dragclone = nil
					end

					mainwmframe.Visible = visible
				end
			end)
		end
	end)

	table.insert(connections, InputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end))
	
	return wm
end

function library:Notify(text, time, persistant)
	local notification = {}
	local frame

	local TweenService = game:GetService("TweenService")
	local ContentProvider = game:GetService("ContentProvider")
	local SoundService = game:GetService("SoundService")
	local Debris = game:GetService("Debris")

	if library.NotificationSide == "Left" then
		frame = leftnotifsf
	elseif library.NotificationSide == "Right" then
		frame = rightnotifsf
	else
		frame = rightnotifsf
	end

	local sets = library.notificationsets or {}

	if sets.NotificationSound == true and sets.NotificationSoundID then
		local id = tostring(sets.NotificationSoundID)

		if not id:find("rbxasset") then
			id = "rbxassetid://" .. id
		end

		local sound = Instance.new("Sound")
		sound.Name = "NotificationSound"
		sound.SoundId = id
		sound.Volume = sets.SoundVol or 1
		sound.Parent = SoundService

		sound.Ended:Connect(function()
			sound:Destroy()
		end)

		Debris:AddItem(sound, 15)

		task.spawn(function()
			pcall(function()
				ContentProvider:PreloadAsync({sound})
			end)

			if sound.Parent then
				sound:Play()
			end
		end)
	end

	local mainframe = library:Create("Frame", {
		Name = "Notification";
		Size = UDim2.new(0, 308,0, 28);
		BackgroundColor3 = library.MainColor;
		LayoutOrder = #frame:GetChildren();
		Parent = frame;
	}, {
		instancep = "BackgroundColor3";
		tinstance = library.MainColor;
	})

	local Uis1 = library:Create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		Color = library.AccentColor;
		LineJoinMode = Enum.LineJoinMode.Miter;
		ZIndex = 2;
		Thickness = 1;
		Parent = mainframe;
	}, {
		instancep = "Color";
		tinstance = library.AccentColor;
	})

	local Uis2 = library:Create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		Color = library.SecondaryColor;
		LineJoinMode = Enum.LineJoinMode.Miter;
		Thickness = 4;
		Parent = mainframe;
	}, {
		instancep = "Color";
		tinstance = library.SecondaryColor;
	})

	local UILL = library:Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal;
		HorizontalAlignment = Enum.HorizontalAlignment.Left;
		VerticalAlignment = Enum.VerticalAlignment.Top;
		Padding = UDim.new(0, 8);
		Parent = mainframe;
	})

	local iconf = library:Create("CanvasGroup", {
		Name = "IconFrame";
		BackgroundTransparency = 1;
		Position = UDim2.new(0, 0, 0, 0);
		Size = UDim2.new(0.097, 0,1, 0);
		LayoutOrder = 1;
		Parent = mainframe;
	})

	local iconnt = library:Create("ImageLabel", {
		Name = "icon";
		Size = UDim2.new(1,0,1,0);
		Position = UDim2.new(0, 0,0, 0);
		BackgroundTransparency = 1;

		ImageColor3 = library.AccentColor;

		Image = "rbxassetid://132964249585974";
		ScaleType = Enum.ScaleType.Crop;
		Parent = iconf;
	}, {
		instancep = "ImageColor3";
		tinstance = library.AccentColor;
	})

	local gradient = library:Create("UIGradient", {
		Name = "grad";
		Offset = Vector2.new(0, 0);
		Rotation = 90;
		Parent = iconnt;

		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.new(1,1,1));
			ColorSequenceKeypoint.new(0.4, Color3.new(1,1,1));
			ColorSequenceKeypoint.new(0.498, Color3.new(0.258824, 0.258824, 0.258824));
			ColorSequenceKeypoint.new(.6, Color3.new(1,1,1));
			ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
		};
	})

	local textlabel = library:Create("TextLabel", {
		Name = "Text";
		Size = UDim2.new(1,0,1,0);
		Position = UDim2.new(0, 0,0, 0);
		BackgroundTransparency = 1;
		Text = text;
		Font = library.Font;
		TextColor3 = library.FontColor;
		TextSize = 14;
		TextXAlignment = Enum.TextXAlignment.Left;
		TextYAlignment = Enum.TextYAlignment.Center;
		TextWrapped = true;
		Parent = mainframe;
	}, {
		instancep = "TextColor3";
		tinstance = library.FontColor;
	}, {
		instancep = "Font";
		tinstance = library.Font;
	})

	local uis = library:Create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
		Color = library.UIstroke;
		Thickness = 1;
		Parent = textlabel;
	}, {
		instancep = "Color";
		tinstance = library.UIstroke;
	})

	local uitext = library:Create("UITextSizeConstraint", {
		MaxTextSize = 14;
		Parent = textlabel;
	})

	local fadeinfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local dying = false

	local function fadeout()
		if dying then
			return
		end

		dying = true

		if not mainframe.Parent then
			return
		end

		local targets = {
			{mainframe, {BackgroundTransparency = 1}};
			{Uis1, {Transparency = 1}};
			{Uis2, {Transparency = 1}};
			{iconnt, {ImageTransparency = 1}};
			{textlabel, {TextTransparency = 1}};
			{uis, {Transparency = 1}};
		}

		for _, target in next, targets do
			TweenService:Create(target[1], fadeinfo, target[2]):Play()
		end

		task.wait(fadeinfo.Time)

		if mainframe.Parent then
			mainframe:Destroy()
		end
	end

	function notification:Destroy()
		task.spawn(fadeout)
	end

	if not persistant then
		task.delay(time or 5, function()
			fadeout()
		end)
	end

	return notification
end

function library:CreatePlayermdl(window)
	local music_player = {}
	
end

function library:Unload()
	-- safely disconnect all connections and tweens then remove all instances to unload.
	if library.OnUnloaded then
		library.OnUnloaded(); -- call onunload function if there is one 
	end;

	for i, v in pairs(connections) do
		v:Disconnect();
	end;

	for i, v in pairs(tweens) do
		v:Cancel();
	end;

	if library.blureffect then
		library.blureffect:Destroy();
	end;

	screengui:Destroy();
	library = nil;
	screengui = nil;
end

table.insert(connections, InputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == library.Menukey then
		library:Toggle()
	end
end))

_G.Library = library

return library
