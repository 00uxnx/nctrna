-- services
warn("init")

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
	gui.Parent = game.CoreGui
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

local Overlaygui = Instance.new("ScreenGui")
Overlaygui.DisplayOrder = 100
Overlaygui.Enabled = true
Overlaygui.Parent = screengui

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
	AccentColor = Color3.fromRGB(129, 184, 255);
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
	local mainframe = library:Create("CanvasGroup", {
		Name = "Window";
		Size = UDim2.new(0, 815,0, 489);
		Position = UDim2.new(0.5, 0, 0.5, 0);
		AnchorPoint = Vector2.new(0.5,0.5);

		BackgroundColor3 = library.MainColor;
		BackgroundTransparency = 0.2;

		ZIndex = 1;
		Visible = false;

		Parent = screengui;
	},
	{
		instancep = "BackgroundColor3";
		tinstance = library.MainColor;
	})

	local imageUrl = "https://raw.githubusercontent.com/00uxnx/nctrna/main/v2ui2026/images/nate_redo.png"
	local imagePath = "nate_redo.png"

	local success, err = pcall(function()
		local imageData = game:HttpGet(imageUrl)
		writefile(imagePath, imageData)
	end)

	if success then
		local assetSuccess, imageAsset = pcall(function()
			return getcustomasset(imagePath)
		end)

		if not assetSuccess then
			assetSuccess, imageAsset = pcall(function()
				return getsynasset(imagePath)
			end)
		end

		if assetSuccess then
			local bg = library:Create("ImageLabel", {
				Name = "Shadow",
				Size = UDim2.new(0.419, 0, 0.862, 0),
				Position = UDim2.new(0.581, 0, 0.138, 0),
				BackgroundTransparency = 1,
				Image = imageAsset,
				ScaleType = Enum.ScaleType.Stretch,
				ZIndex = 0,
				Parent = mainframe,
			})
		else
			warn("Image asset loading failed:", imageAsset)
		end
	else
		warn("Image download failed:", err)
	end

	library:Create("UIShadow", {
		Parent = mainframe;
		BlurRadius = UDim.new(0, 20);
		Transparency = 0.1;
		Color = Color3.fromRGB(0, 0, 0);
	})

	library:Create("UICorner", {
		Parent = mainframe;
		CornerRadius = UDim.new(0, 11);
	})

	library:Create("Frame", {
		Name = "s1";
		Size = UDim2.new(0, 1, 1, 0);
		Position = UDim2.new(.218, 0, 0, 0);
		BackgroundColor3 = library.SecondaryColor;
		ZIndex = 1;
		Parent = mainframe;
	}, {
		instancep = "BackgroundColor3";
		tinstance = library.SecondaryColor;
	})

	library:Create("Frame", {
		Name = "s2";
		Size = UDim2.new(1, 0, 0, 1);
		Position = UDim2.new(0, 0, 0.108, 0);
		BackgroundColor3 = library.SecondaryColor;
		ZIndex = 1;
		Parent = mainframe;
	}, {
		instancep = "BackgroundColor3";
		tinstance = library.SecondaryColor;
	})

	local namef = library:Create("Frame", {
		Name = "NameFrame";
		Size = UDim2.new(0.218, 0,0.108, 0);
		Position = UDim2.new(0, 0, 0, 0);
		BackgroundTransparency = 1;
		Parent = mainframe;
	})

	local dragbutton = library:Create("TextButton", {
		Name = "DragButton";
		Size = UDim2.new(0.218, 0,0.108, 0);
		Position = UDim2.new(0, 0, 0, 0);
		BackgroundTransparency = 1;
		Parent = mainframe;
		Text = "";
		ZIndex = 2;
	})

	library:Create("UIListLayout", {
		Parent = namef;
		SortOrder = Enum.SortOrder.LayoutOrder;
		FillDirection = Enum.FillDirection.Horizontal;
		VerticalAlignment = Enum.VerticalAlignment.Center;
		HorizontalAlignment = Enum.HorizontalAlignment.Left;
		Padding = UDim.new(0, 5);
	})

	library:Create("UIPadding", {
		Parent = namef;
		PaddingLeft = UDim.new(0, 2);
	})

	library:Create("ImageLabel", {
		Name = "Icon";
		LayoutOrder = 0;
		Size = UDim2.new(0, 50, 0, 50);
		Position = UDim2.new(0, 0, 0, 0);
		BackgroundTransparency = 1;
		Image = "rbxassetid://112723756161303";
		ScaleType = Enum.ScaleType.Fit;
		Parent = namef;
	})

	local t = library:Create("TextLabel", {
		Name = "Title";
		Size = UDim2.new(0.652, 0,0.588, 0);
		Position = UDim2.new(0, 0, 0, 0);
		BackgroundTransparency = 1;
		Text = "Sigion.pex";
		Font = library.Font;
		TextColor3 = library.AccentColor;
		TextSize = 20;
		TextXAlignment = Enum.TextXAlignment.Left;
		TextYAlignment = Enum.TextYAlignment.Center;
		Parent = namef;
		LayoutOrder = 1;
	}, {
		instancep = "TextColor3";
		tinstance = library.AccentColor;
	}, {
		instancep = "Font";
		tinstance = library.Font;
	})

	library:Create("UIStroke", {
		Parent = t;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
		Color = library.UIstroke;
		Thickness = 1;
	}, {
		instancep = "Color";
		tinstance = library.UIstroke;
	})

	library:Create("UITextSizeConstraint", {
		Parent = t;
		MaxTextSize = 20;
	})

	-- search bar
	local searchbar = library:Create("Frame", {
		Name = "SearchBar";
		Size = UDim2.new(0.779, 0,0.11, 0);
		Position = UDim2.new(0.22, 0,0, 0);
		BackgroundTransparency = 1;
		Parent = mainframe;
	})

	library:Create("UIListLayout", {
		Parent = searchbar;
		SortOrder = Enum.SortOrder.LayoutOrder;
		FillDirection = Enum.FillDirection.Horizontal;
		VerticalAlignment = Enum.VerticalAlignment.Center;
		HorizontalAlignment = Enum.HorizontalAlignment.Left;
		Padding = UDim.new(0, 15);
	})

	library:Create("UIPadding", {
		Parent = searchbar;
		PaddingLeft = UDim.new(0, 10);
		PaddingTop = UDim.new(0, 3);
	})

	local sbar = library:Create("TextBox", {
		Name = "SearchBar";
		BackgroundTransparency = 1;
		Size = UDim2.new(0.924, 0, 0.65, 0);
		Font = library.Font;
		TextColor3 = library.FontColor;
		TextSize = 15;
		Text = "";
		PlaceholderText = "Search here.";
		MultiLine = false;
		ClearTextOnFocus = false;
		TextXAlignment = Enum.TextXAlignment.Left;
		TextYAlignment = Enum.TextYAlignment.Center;
		LayoutOrder = 1;
		Parent = searchbar;
	}, {
		instancep = "TextColor3";
		tinstance = library.FontColor;
	}, {
		instancep = "Font";
		tinstance = library.Font;
	})

	library:Create("UICorner", {
		Parent = sbar;
		CornerRadius = UDim.new(0, 11);
	})

	library:Create("UIPadding", {
		Parent = sbar;
		PaddingLeft = UDim.new(0, 5);
	})

	library:Create("UIStroke", {
		Parent = sbar;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
		Color = library.UIstroke;
		Thickness = 1;
	}, {
		instancep = "Color";
		tinstance = library.UIstroke;
	})

	library:Create("UIStroke", {
		Parent = sbar;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		Color = library.SecondaryColor;
		Thickness = 1;
	}, {
		instancep = "Color";
		tinstance = library.SecondaryColor;
	})

	library:Create("UITextSizeConstraint", {
		Parent = sbar;
		MaxTextSize = 15;
	})

	library:Create("ImageLabel", {
		Name = "Icon";
		Size = UDim2.new(0, 25, 0, 25);
		BackgroundTransparency = 1;
		Image = "rbxassetid://10734943674";
		ImageColor3 = library.SecondaryColor;
		ScaleType = Enum.ScaleType.Crop;
		LayoutOrder = 0;
		Parent = searchbar;
	}, {
		instancep = "ImageColor3";
		tinstance = library.SecondaryColor;
	})

	-- Tabs Buttons Holder
	local tabbuttonHolder = library:Create("ScrollingFrame", {
		Name = "TabButtonsHolder";
		Size = UDim2.new(0, 178,0, 436);
		Position = UDim2.new(0, 0, 0.108, 0);
		BackgroundTransparency = 1;
		AutomaticCanvasSize = Enum.AutomaticSize.Y;
		CanvasSize = UDim2.new(0, 0, 0, 0);
		ScrollBarThickness = 0;
		ScrollingDirection = Enum.ScrollingDirection.Y;
		Parent = mainframe;
	})

	library:Create("UIListLayout", {
		Parent = tabbuttonHolder;
		FillDirection = Enum.FillDirection.Vertical;
		SortOrder = Enum.SortOrder.LayoutOrder;
		VerticalAlignment = Enum.VerticalAlignment.Top;
		HorizontalAlignment = Enum.HorizontalAlignment.Center;
		Padding = UDim.new(0, 7);
	})

	library:Create("UIPadding", {
		Parent = tabbuttonHolder;	
		PaddingTop = UDim.new(0, 12);
		PaddingBottom = UDim.new(0, 12);
	})

	-- TabPage Holder
	local PageHolder = library:Create("Frame", {
		Name = "PageHolder";
		Size = UDim2.new(0, 637,0, 436);
		Position = UDim2.new(0.218, 0,0.108, 0);
		BackgroundTransparency = 1;
		Parent = mainframe;
	})

	-- Creation api
	function window:CreateSection(name, i)
		local section = {}
		local tabs = {}
		local expanded = true

		-- creation
		local maincontainer = library:Create("Frame", {
			Name = name;
			Size = UDim2.new(0, 163,0, 25);
			Position = UDim2.new(0, 0,0, 0);
			BackgroundTransparency = 1;
			AutomaticSize = Enum.AutomaticSize.Y;
			LayoutOrder = #tabbuttonHolder:GetChildren();
			Parent = tabbuttonHolder;
		})

		local expandsize = library:Create("TextButton", {
			Name = "Expand";
			Size = UDim2.new(0, 163,0, 25);
			Position = UDim2.new(0, 0,0, 0);
			ZIndex = 2;
			BackgroundTransparency = 1;
			Text = "";
			Parent = maincontainer;
		})

		local Container = library:Create("Frame", {
			Name = "Container";
			Size = UDim2.new(1,0,1,0);
			Position = UDim2.new(0, 0,0, 0);
			BackgroundTransparency = 1;
			AutomaticSize = Enum.AutomaticSize.Y;
			Parent = maincontainer;
		})

		library:Create("UIListLayout", {
			Parent = Container;
			FillDirection = Enum.FillDirection.Horizontal;
			SortOrder = Enum.SortOrder.LayoutOrder;
			VerticalAlignment = Enum.VerticalAlignment.Center;
			HorizontalAlignment = Enum.HorizontalAlignment.Center;
			Padding = UDim.new(0, 3);
			Wraps = true;
		})

		library:Create("ImageLabel", {
			Name = "icon";
			Size = UDim2.new(0, 20,0, 20);
			LayoutOrder = 1;
			BackgroundTransparency = 1;
			Image = i;
			ScaleType = Enum.ScaleType.Crop;
			ImageColor3 = library.AccentColor;
			Parent = Container;
		}, {
			instancep = "ImageColor3";
			tinstance = library.AccentColor;
		})

		local t2 = library:Create("TextLabel", {
			Name = "title";
			Size = UDim2.new(0.842, 0,0, 25);
			LayoutOrder = 2;
			BackgroundTransparency = 1;
			Text = name;
			Font = library.Font;
			TextColor3 = library.FontColor;
			TextXAlignment = Enum.TextXAlignment.Center;
			TextYAlignment = Enum.TextYAlignment.Center;

			TextSize = 15;
			Parent = Container;
		}, {
			instancep = "Font";
			tinstance = library.Font;
		}, {
			instancep = "TextColor3";
			tinstance = library.FontColor;
		})

		library:Create("UIStroke", {
			Parent = t2;
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
			Thickness = 1;
			Color = library.UIstroke;		
		}, {
			instancep = "Color";
			tinstance = library.UIstroke;
		})

		library:Create("UITextSizeConstraint", {
			Parent = t2;
			MaxTextSize = 15;
		})

		local maincontainer2 = library:Create("Frame", {
			Name = "maincontainer2";
			Size = UDim2.new(1,0,0,25);
			Position = UDim2.new(0, 0,0, 0);
			BackgroundTransparency = 1;
			AutomaticSize = Enum.AutomaticSize.Y;
			LayoutOrder = 4;
			Parent = Container;
		})

		library:Create("UIPadding", {
			Parent = maincontainer2;

			PaddingTop = UDim.new(0, 5);
			PaddingBottom = UDim.new(0, 5);
		})

		library:Create("UIListLayout", {
			Parent = maincontainer2;
			FillDirection = Enum.FillDirection.Horizontal;
			SortOrder = Enum.SortOrder.LayoutOrder;
			VerticalAlignment = Enum.VerticalAlignment.Top;
			HorizontalAlignment = Enum.HorizontalAlignment.Center;
			Padding = UDim.new(0, 5);
			Wraps = true;
		})

		-- tab creation
		function section:NewTab(name)
			local tab = {}
			local intabs = {}

			local currentintab = nil

			-- creation
			local buttontab = library:Create("Frame", {
				Name = name;
				Size = UDim2.new(1,0,0,33);
				Position = UDim2.new(0, 0,0, 0);
				BackgroundTransparency = 1;
				LayoutOrder = #maincontainer2:GetChildren();
				Parent = maincontainer2;
			})

			local button = library:Create("TextButton", {
				Name = "button";
				Size = UDim2.new(1,0,1,0);
				ZIndex = 2;
				BackgroundTransparency = 1;
				Text = "";
				Parent = buttontab
			})

			library:Create("UICorner", {
				Parent = buttontab;
				CornerRadius = UDim.new(0, 11);
			})

			library:Create("UIStroke", {
				Parent = buttontab;
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
				Thickness = 1;
				Color = library.SecondaryColor;	
			}, {
				instancep = "Color";
				tinstance = library.SecondaryColor;
			})

			local selectedshadow = library:Create("UIShadow", {
				Parent = buttontab;
				Color = library.AccentColor;
				Transparency = 0.88;
				BlurRadius = UDim.new(0, 15);
				Enabled = false;
			}, {
				instancep = "Color";
				tinstance = library.AccentColor;
			})

			local texttitle = library:Create("TextLabel", {
				Name = "texttitle";
				Size = UDim2.new(1,0,1,0);
				BackgroundTransparency = 1;
				TextColor3 = library.FontColor;
				Font = library.Font;
				Text = name;
				TextSize = 15;
				TextXAlignment = Enum.TextXAlignment.Left;
				TextYAlignment = Enum.TextYAlignment.Center;
				ZIndex = 1;
				Parent = buttontab
			}, {
				instancep = "TextColor3";
				tinstance = library.FontColor;
			}, {
				instancep = "Font";
				tinstance = library.Font;
			})

			library:Create("UIStroke", {
				Parent = texttitle;
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
				Thickness = 1;
				Color = library.UIstroke;	
			}, {
				instancep = "Color";
				tinstance = library.UIstroke;	
			})

			library:Create("UITextSizeConstraint", {
				Parent = texttitle;
				MaxTextSize = 15;
			})

			library:Create("UIPadding", {
				Parent = texttitle;
				PaddingLeft = UDim.new(0, 10);
			})

			-- page
			local page = library:Create("Frame", {
				Name = name;
				Size = UDim2.new(1,0,1,0);
				Position = UDim2.new(0, 0,0, 0);
				BackgroundTransparency = 1;
				Parent = PageHolder;
				Visible = false;
			})

			local intabsf = library:Create("Frame", {
				Name = "intabs";
				Size = UDim2.new(1,0,1,0);
				BackgroundTransparency = 1;
				Parent = page;
				Visible = true;
			})

			-- Main intab
			local normalmain = library:Create("Frame", {
				Name = "normalmain";
				Size = UDim2.new(1,0,1,0);
				BackgroundTransparency = 1;
				Parent = intabsf;
				Visible = true;
			})

			local Right = library:Create("ScrollingFrame", {
				Name = "Right";
				Size = UDim2.new(0.5, 0,0.92, 0);
				Position = UDim2.new(0.5, 0,0, 0);
				BackgroundTransparency = 1;
				ScrollBarThickness = 0;
				AutomaticCanvasSize = Enum.AutomaticSize.Y;
				CanvasSize = UDim2.new(0, 0,0, 0);
				ScrollingDirection = Enum.ScrollingDirection.Y;
				ZIndex = 1;
				Parent = normalmain;
			})

			library:Create("UIPadding", {
				Parent = Right;
				PaddingRight = UDim.new(0, 10);
				PaddingLeft = UDim.new(0, 10);
				PaddingTop = UDim.new(0, 10);
				PaddingBottom = UDim.new(0, 10);
			})

			library:Create("UIListLayout", {
				Parent = Right;
				FillDirection = Enum.FillDirection.Vertical;
				SortOrder = Enum.SortOrder.LayoutOrder;
				VerticalAlignment = Enum.VerticalAlignment.Top;
				HorizontalAlignment = Enum.HorizontalAlignment.Center;
				Padding = UDim.new(0, 4);
			})

			local Left = library:Create("ScrollingFrame", {
				Name = "Left";
				Size = UDim2.new(0.5, 0,0.92, 0);
				Position = UDim2.new(0, 0,0, 0);
				BackgroundTransparency = 1;
				ScrollBarThickness = 0;
				AutomaticCanvasSize = Enum.AutomaticSize.Y;
				CanvasSize = UDim2.new(0, 0,0, 0);
				ScrollingDirection = Enum.ScrollingDirection.Y;
				ZIndex = 1;
				Parent = normalmain;
			})

			library:Create("UIPadding", {
				Parent = Left;
				PaddingRight = UDim.new(0, 10);
				PaddingLeft = UDim.new(0, 10);
				PaddingTop = UDim.new(0, 10);
				PaddingBottom = UDim.new(0, 10);
			})

			library:Create("UIListLayout", {
				Parent = Left;
				FillDirection = Enum.FillDirection.Vertical;
				SortOrder = Enum.SortOrder.LayoutOrder;
				VerticalAlignment = Enum.VerticalAlignment.Top;
				HorizontalAlignment = Enum.HorizontalAlignment.Center;
				Padding = UDim.new(0, 4);
			})

			local Intabsscroll = library:Create("ScrollingFrame", {
				Name = "Intabsscroll";
				Size = UDim2.new(1,0,0,35);
				Position = UDim2.new(0, 0,0.92, 0);
				BackgroundTransparency = 1;
				ScrollBarThickness = 0;
				AutomaticCanvasSize = Enum.AutomaticSize.X;
				CanvasSize = UDim2.new(0, 0,0, 0);
				ScrollingDirection = Enum.ScrollingDirection.X;
				ZIndex = 1;
				Parent = page;
			})

			library:Create("UIListLayout", {
				Parent = Intabsscroll;
				FillDirection = Enum.FillDirection.Horizontal;
				SortOrder = Enum.SortOrder.LayoutOrder;
				VerticalAlignment = Enum.VerticalAlignment.Center;
				HorizontalAlignment = Enum.HorizontalAlignment.Left;
				Padding = UDim.new(0, 4);
			})

			library:Create("UIPadding", {
				Parent = Intabsscroll;
				PaddingRight = UDim.new(0, 8);
				PaddingLeft = UDim.new(0, 8);
				PaddingTop = UDim.new(0, 8);
				PaddingBottom = UDim.new(0, 8);
			})

			local mainintabbuttonframe = library:Create("Frame", {
				Name = "Main";
				Size = UDim2.new(0, 90, 0, 27);
				BackgroundTransparency = 1;
				AutomaticSize = Enum.AutomaticSize.X;
				Parent = Intabsscroll;
				LayoutOrder = 1;
			})

			library:Create("UICorner", {
				Parent = mainintabbuttonframe;
				CornerRadius = UDim.new(0, 11);
			})

			library:Create("UIStroke", {
				Parent = mainintabbuttonframe;
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
				Thickness = 1;
				Color = library.SecondaryColor;
			}, {
				instancep = "Color";
				tinstance = library.SecondaryColor;
			})

			local mainintabshadow = library:Create("UIShadow", {
				Parent = mainintabbuttonframe;
				Color = library.AccentColor;
				Transparency = 0.88;
				BlurRadius = UDim.new(0, 15);
				Enabled = true;
			}, {
				instancep = "Color";
				tinstance = library.AccentColor;
			})

			local mainintabbutton = library:Create("TextButton", {
				Name = "IntabButton";
				Size = UDim2.new(1, 0, 1, 0);
				BackgroundTransparency = 1;
				Text = "";
				ZIndex = 2;
				Parent = mainintabbuttonframe;
			})

			local mainintabtitle = library:Create("TextLabel", {
				Name = "IntabName";
				Size = UDim2.new(1, -16, 1, 0);
				Position = UDim2.new(0, 8, 0, 0);
				BackgroundTransparency = 1;
				Text = "Main";
				Font = library.Font;
				TextXAlignment = Enum.TextXAlignment.Center;
				TextYAlignment = Enum.TextYAlignment.Center;
				TextColor3 = library.FontColor;
				TextSize = 15;
				Parent = mainintabbuttonframe;
			}, {
				instancep = "TextColor3";
				tinstance = library.FontColor;
			}, {
				instancep = "Font";
				tinstance = library.Font;
			})

			mainintabbutton.Activated:Connect(function()
				if currentintab == normalmain then return end

				currentintab = normalmain
				normalmain.Visible = true
				mainintabshadow.Enabled = true

				for _, otherintab in pairs(intabs) do
					otherintab.Frame.Visible = false
					otherintab.SelectedShadow.Enabled = false
				end
			end)

			-- intab main creation
			-- make a intab for the normalmain page so u can have a intab and if u wanna go back u click on that intab

			-- intabs
			function tab:Intab(name, image)
				local Intab = {}

				-- ui creation
				local intabframebutton = library:Create("Frame", {
					Name = name;
					Size = UDim2.new(0.206, 0,-0.2, 33);
					Position = UDim2.new(0, 0,0, 0);
					BackgroundTransparency = 1;
					AutomaticSize = Enum.AutomaticSize.X;
					Parent = Intabsscroll;
					LayoutOrder = #Intabsscroll:GetChildren();
				})

				library:Create("UICorner", {
					Parent = intabframebutton;
					CornerRadius = UDim.new(0, 11);
				})

				library:Create("UIStroke", {
					Parent = intabframebutton;
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
					Thickness = 1;
					Color = library.SecondaryColor;
				}, {
					instancep = "Color";
					tinstance = library.SecondaryColor;
				})

				local selectedshadowint = library:Create("UIShadow", {
					Parent = intabframebutton;
					Color = library.AccentColor;
					Transparency = 0.88;
					BlurRadius = UDim.new(0, 15);
					Enabled = false;
				}, {
					instancep = "Color";
					tinstance = library.AccentColor;
				})

				local intabbutton = library:Create("TextButton", {
					Name = "IntabButton";
					Size = UDim2.new(1, 0,1, 0);
					Position = UDim2.new(0, 0,0, 0);
					BackgroundTransparency = 1;
					Text = "";
					ZIndex = 2;
					Parent = intabframebutton;
				})

				local intabholder = library:Create("Frame", {
					Name = "IntabHolder";
					Size = UDim2.new(1, 0,1, 0);
					Position = UDim2.new(0, 0,0, 0);
					BackgroundTransparency = 1;
					ZIndex = 1;
					AutomaticSize = Enum.AutomaticSize.X;
					Parent = intabframebutton;
				})

				library:Create("UIListLayout", {
					Parent = intabholder;
					FillDirection = Enum.FillDirection.Horizontal;
					HorizontalAlignment = Enum.HorizontalAlignment.Center;
					VerticalAlignment = Enum.VerticalAlignment.Center;
					SortOrder = Enum.SortOrder.LayoutOrder;
					Padding = UDim.new(0, 8);
				})

				library:Create("ImageLabel", {
					Name = "Icon";
					Size = UDim2.new(0, 20,0, 20);
					BackgroundTransparency = 1;
					LayoutOrder = 1;
					Image = image;
					ImageColor3 = library.AccentColor;
					Parent = intabholder;
				}, {
					instancep = "ImageColor3";
					tinstance = library.AccentColor;
				})

				local ttt = library:Create("TextLabel", {
					Name = "IntabName";
					Size = UDim2.new(0, 0,1, 0);
					BackgroundTransparency = 1;
					LayoutOrder = 2;
					Text = name;
					Font = library.Font;
					TextXAlignment = Enum.TextXAlignment.Center;
					TextYAlignment = Enum.TextYAlignment.Center;
					AutomaticSize = Enum.AutomaticSize.X;
					TextColor3 = library.FontColor;
					TextSize = 15;
					Parent = intabholder
				})

				library:Create("UIStroke", {
					Parent = ttt;
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
					Color = library.UIstroke;
					Thickness = 1;			
				}, {
					instancep = "Color";
					tinstance = library.UIstroke;
				})

				library:Create("UITextSizeConstraint", {
					Parent = ttt;
					MaxTextSize = 15;
				})

				-- page creation
				local IntabFrame = library:Create("Frame", {
					Name = name;
					Size = UDim2.new(1,0,1,0);
					BackgroundTransparency = 1;
					Parent = intabsf;
					Visible = false;
				})

				local Rightin = library:Create("ScrollingFrame", {
					Name = "Right";
					Size = UDim2.new(0.5, 0,0.92, 0);
					Position = UDim2.new(0.5, 0,0, 0);
					BackgroundTransparency = 1;
					ScrollBarThickness = 0;
					AutomaticCanvasSize = Enum.AutomaticSize.Y;
					CanvasSize = UDim2.new(0, 0,0, 0);
					ScrollingDirection = Enum.ScrollingDirection.Y;
					ZIndex = 1;
					Parent = IntabFrame;
				})

				library:Create("UIPadding", {
					Parent = Rightin;
					PaddingRight = UDim.new(0, 10);
					PaddingLeft = UDim.new(0, 10);
					PaddingTop = UDim.new(0, 10);
					PaddingBottom = UDim.new(0, 10);
				})

				library:Create("UIListLayout", {
					Parent = Rightin;
					FillDirection = Enum.FillDirection.Vertical;
					SortOrder = Enum.SortOrder.LayoutOrder;
					VerticalAlignment = Enum.VerticalAlignment.Top;
					HorizontalAlignment = Enum.HorizontalAlignment.Center;
					Padding = UDim.new(0, 4);
				})

				local Leftin = library:Create("ScrollingFrame", {
					Name = "Left";
					Size = UDim2.new(0.5, 0,0.92, 0);
					Position = UDim2.new(0, 0,0, 0);
					BackgroundTransparency = 1;
					ScrollBarThickness = 0;
					AutomaticCanvasSize = Enum.AutomaticSize.Y;
					CanvasSize = UDim2.new(0, 0,0, 0);
					ScrollingDirection = Enum.ScrollingDirection.Y;
					ZIndex = 1;
					Parent = IntabFrame;
				})

				library:Create("UIPadding", {
					Parent = Leftin;
					PaddingRight = UDim.new(0, 10);
					PaddingLeft = UDim.new(0, 10);
					PaddingTop = UDim.new(0, 10);
					PaddingBottom = UDim.new(0, 10);
				})

				library:Create("UIListLayout", {
					Parent = Leftin;
					FillDirection = Enum.FillDirection.Vertical;
					SortOrder = Enum.SortOrder.LayoutOrder;
					VerticalAlignment = Enum.VerticalAlignment.Top;
					HorizontalAlignment = Enum.HorizontalAlignment.Center;
					Padding = UDim.new(0, 4);
				})

				-- creation
				function Intab:AddLeftGroupbox(title)
					local groupbox = {
						elements = {};
					}

					local groupboxf = library:Create("Frame", {
						Name = "Groupbox";
						Size = UDim2.new(0.95, 0,0, 0);
						Position = UDim2.new(0, 0,0, 0);
						BackgroundColor3 = library.MainColor;
						AutomaticSize = Enum.AutomaticSize.Y;
						LayoutOrder = #Leftin:GetChildren();
						Parent = Leftin;
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
								Size = UDim2.new(0, 15,0, 15);
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

						--==========================================================
						-- REUSE AN EXISTING DROPDOWN
						--==========================================================

						local existing = library.Options[name]

						if existing then
							if existing.Type == "Dropdown"
								and existing.Controller
								and type(existing.Controller.Refresh) == "function" then

								local controller = existing.Controller

								if opts.Text ~= nil then
									controller:SetText(opts.Text)
								end

								if opts.Callback ~= nil then
									controller:SetCallback(opts.Callback)
								end

								if opts.Values ~= nil then
									controller:Refresh(opts.Values, opts.Default)
								elseif opts.Default ~= nil then
									controller:SetValue(opts.Default, true)
								end

								return controller
							end

							warn("An option named '" .. tostring(name) .. "' already exists.")
							return nil
						end

						--==========================================================
						-- STATE
						--==========================================================

						local Dropdown = {}

						local values = {}
						local elements = {}
						local selectedIndices = {}
						local connections = {}

						local picked = nil
						local isOpen = false
						local destroyed = false

						local multi = opts.Multipick == true
						local callback = opts.Callback

						local rowHeight = 20
						local rowGap = 3
						local padding = 4

						local requestedVisible = tonumber(opts.MaxVisibleItems) or 10

						if requestedVisible ~= requestedVisible then
							requestedVisible = 10
						end

						local maxVisibleItems = math.clamp(
							math.floor(requestedVisible),
							1,
							30
						)

						local changedEvent = Instance.new("BindableEvent")

						local option = {
							Type = "Dropdown",
							Name = name,
							Value = multi and {} or nil,
							Values = values,
							OnChanged = changedEvent.Event,
							Controller = Dropdown,
						}

						library.Options[name] = option

						local function connect(signal, fn)
							local connection = signal:Connect(fn)
							table.insert(connections, connection)
							return connection
						end

						local function copyUnique(source)
							local result = {}
							local seen = {}

							if type(source) ~= "table" then
								return result
							end

							for _, value in ipairs(source) do
								local supported = type(value) == "string"
									or (
										type(value) == "number"
										and value == value
										and value > -math.huge
										and value < math.huge
									)

								if supported and not seen[value] then
									seen[value] = true
									table.insert(result, value)
								end
							end

							return result
						end

						local function findIndex(value)
							if type(value) == "number" then
								if value % 1 == 0 and value >= 1 and value <= #values then
									return value
								end

								return nil
							end

							return table.find(values, value)
						end

						local function getValue()
							if not multi then
								return picked
							end

							local selected = {}

							for index, value in ipairs(values) do
								if selectedIndices[index] then
									table.insert(selected, value)
								end
							end

							return selected
						end

						local function equalValues(a, b)
							if type(a) ~= type(b) then
								return false
							end

							if type(a) ~= "table" then
								return a == b
							end

							if #a ~= #b then
								return false
							end

							for index, value in ipairs(a) do
								if b[index] ~= value then
									return false
								end
							end

							return true
						end

						--==========================================================
						-- MAIN UI
						--==========================================================

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
							Text = tostring(opts.Text or name),
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
							Size = UDim2.new(1, 0, 0, 22),
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
							BackgroundTransparency = 1,
							Text = "-",
							Font = library.Font,
							TextColor3 = library.FontColor,
							TextSize = 12,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextTruncate = Enum.TextTruncate.AtEnd,
							Parent = selectionRow,
						}, {
							instancep = "Font",
							tinstance = library.Font,
						}, {
							instancep = "TextColor3",
							tinstance = library.FontColor,
						})

						library:Create("UIPadding", {
							PaddingLeft = UDim.new(0, 6),
							PaddingRight = UDim.new(0, 3),
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
							Size = UDim2.fromOffset(15, 15),
							Position = UDim2.new(1, -19, 0.5, -7),
							BackgroundTransparency = 1,
							Image = "rbxassetid://10709767827",
							ScaleType = Enum.ScaleType.Crop,
							Parent = selectionRow,
						})

						local button = library:Create("TextButton", {
							Name = "DropdownButton",
							ZIndex = 14,
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							Text = "",
							AutoButtonColor = false,
							Parent = selectionRow,
						})

						-- Fixed viewport height; canvas grows to fit every item.
						local holder = library:Create("ScrollingFrame", {
							Name = "Holder",
							ZIndex = 20,
							Size = UDim2.new(1, 0, 0, 0),
							AutomaticSize = Enum.AutomaticSize.None,
							AutomaticCanvasSize = Enum.AutomaticSize.None,
							CanvasSize = UDim2.fromOffset(0, 0),
							CanvasPosition = Vector2.zero,
							LayoutOrder = 2,
							BackgroundColor3 = library.MainColor,
							BorderSizePixel = 0,
							ScrollBarThickness = 3,
							ScrollBarImageColor3 = library.AccentColor,
							ScrollingDirection = Enum.ScrollingDirection.Y,
							Visible = false,
							ClipsDescendants = true,
							Parent = dropdownFrame,
						}, {
							instancep = "BackgroundColor3",
							tinstance = library.MainColor,
						}, {
							instancep = "ScrollBarImageColor3",
							tinstance = library.AccentColor,
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

						library:Create("UIListLayout", {
							FillDirection = Enum.FillDirection.Vertical,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Top,
							Padding = UDim.new(0, rowGap),
							SortOrder = Enum.SortOrder.LayoutOrder,
							Parent = holder,
						})

						library:Create("UIPadding", {
							PaddingLeft = UDim.new(0, padding),
							PaddingRight = UDim.new(0, padding),
							PaddingTop = UDim.new(0, padding),
							PaddingBottom = UDim.new(0, padding),
							Parent = holder,
						})

						--==========================================================
						-- TOP-LEVEL DROPDOWN OVERLAY
						--==========================================================

						local overlayRoot

						local sourceScreenGui = main:FindFirstAncestorOfClass("ScreenGui")
						local player = LocalPlayer
						local playerGui = (sourceScreenGui and sourceScreenGui.Parent)
							or (player and player:FindFirstChildOfClass("PlayerGui"))

						if playerGui then
							local highestDisplayOrder = 0

							for _, child in ipairs(playerGui:GetChildren()) do
								if child:IsA("ScreenGui") then
									highestDisplayOrder = math.max(highestDisplayOrder, child.DisplayOrder)
								end
							end

							overlayRoot = Instance.new("Frame")
							overlayRoot.Name = "OverlayRoot"
							overlayRoot.BackgroundTransparency = 1
							overlayRoot.BorderSizePixel = 0
							overlayRoot.Size = UDim2.fromScale(1, 1)
							overlayRoot.Position = UDim2.fromScale(0, 0)
							overlayRoot.Parent = Overlaygui

							holder.Parent = overlayRoot
						end

						local function positionHolder()
							if not overlayRoot or not holder or not holder.Parent then
								return
							end

							local rootPosition = overlayRoot.AbsolutePosition
							local rootSize = overlayRoot.AbsoluteSize
							local rowPosition = selectionRow.AbsolutePosition
							local rowSize = selectionRow.AbsoluteSize
							local width = math.max(0, rowSize.X)
							local height = holder.Size.Y.Offset
							local x = rowPosition.X - rootPosition.X
							local y = rowPosition.Y - rootPosition.Y + rowSize.Y + 3

							if y + height > rootSize.Y then
								y = rowPosition.Y - rootPosition.Y - height - 3
							end

							x = math.clamp(x, 0, math.max(0, rootSize.X - width))
							y = math.clamp(y, 0, math.max(0, rootSize.Y - height))

							holder.Position = UDim2.fromOffset(x, y)
							holder.Size = UDim2.fromOffset(width, height)
						end

						--==========================================================
						-- UI UPDATES
						--==========================================================

						local function updateHolderSize()
							local count = #values
							local visibleRows = math.min(count, maxVisibleItems)

							local function heightFor(rows)
								if rows == 0 then
									return 0
								end

								return padding * 2
									+ rows * rowHeight
									+ math.max(0, rows - 1) * rowGap
							end

							local holderHeight = heightFor(visibleRows)

							if overlayRoot then
								holder.Size = UDim2.fromOffset(selectionRow.AbsoluteSize.X, holderHeight)
							else
								holder.Size = UDim2.new(1, 0, 0, holderHeight)
							end

							holder.CanvasSize = UDim2.fromOffset(0, heightFor(count))
							holder.ScrollingEnabled = count > maxVisibleItems

							if count == 0 then
								isOpen = false
							end

							holder.Visible = isOpen and count > 0
							arrow.Rotation = holder.Visible and 180 or 0
							positionHolder()
						end

						local function updateSelectedText()
							local current = getValue()
							local hasSelection

							if multi then
								local display = {}

								for _, value in ipairs(current) do
									table.insert(display, tostring(value))
								end

								hasSelection = #display > 0
								selectedLabel.Text = hasSelection
									and table.concat(display, ", ")
									or "-"
							else
								hasSelection = current ~= nil
								selectedLabel.Text = hasSelection and tostring(current) or "-"
							end

							selectedLabel.TextColor3 = hasSelection
								and library.AccentColor
								or library.FontColor

							option.Value = current
						end

						local function updateItems()
							for index, item in ipairs(elements) do
								local selected = multi
									and selectedIndices[index] == true
									or (not multi and picked == item.name)

								item.button.Text = selected
									and ("✓  " .. tostring(item.name))
									or tostring(item.name)

								item.button.TextColor3 = selected
									and library.AccentColor
									or library.FontColor
							end
						end

						local function updateUI()
							updateSelectedText()
							updateItems()
							updateHolderSize()
						end

						-- Reapply current theme values to already-created instances.
						local function refreshTheme()
							if destroyed then
								return
							end

							local strokeColor = library.UIstroke or library.UIStroke or library.SecondaryColor

							header.TextColor3 = library.FontColor
							header.Font = library.Font
							selectedLabel.Font = library.Font
							holder.BackgroundColor3 = library.MainColor
							holder.ScrollBarImageColor3 = library.AccentColor

							if typeof(library.FontFace) == "Font" then
								header.FontFace = library.FontFace
								selectedLabel.FontFace = library.FontFace
							end

							for _, root in ipairs({ main, holder }) do
								for _, descendant in ipairs(root:GetDescendants()) do
									if descendant:IsA("UIStroke") then
										if descendant.Parent == selectionRow or descendant.Parent == holder then
											descendant.Color = library.SecondaryColor
										else
											descendant.Color = strokeColor
										end
									elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
										descendant.Font = library.Font

										if typeof(library.FontFace) == "Font" then
											descendant.FontFace = library.FontFace
										end
									end
								end
							end

							updateSelectedText()
							updateItems()
						end

						local function readThemeSnapshot()
							return {
								MainColor = library.MainColor,
								SecondaryColor = library.SecondaryColor,
								AccentColor = library.AccentColor,
								FontColor = library.FontColor,
								UIstroke = library.UIstroke,
								UIStroke = library.UIStroke,
								Font = library.Font,
								FontFace = library.FontFace,
							}
						end

						local function themeSnapshotChanged(previous, current)
							for key, value in pairs(previous) do
								if current[key] ~= value then
									return true
								end
							end

							return false
						end

						local function notifyChanged()
							local value = getValue()

							option.Value = value

							changedEvent:Fire(
								type(value) == "table" and table.clone(value) or value
							)

							if type(callback) == "function" then
								local ok, err = pcall(
									callback,
									type(value) == "table" and table.clone(value) or value
								)

								if not ok then
									warn(
										"[Dropdown:" .. tostring(name) .. "] Callback failed:",
										err
									)
								end
							end
						end

						local function setValue(value, silent)
							if destroyed then
								return false
							end

							local previous = getValue()

							if multi then
								table.clear(selectedIndices)

								local selections

								if type(value) == "table" then
									selections = value
								elseif value ~= nil then
									selections = { value }
								else
									selections = {}
								end

								for _, selection in ipairs(selections) do
									local index = findIndex(selection)

									if index then
										selectedIndices[index] = true
									end
								end
							else
								local index = findIndex(value)
								picked = index and values[index] or nil
							end

							updateUI()

							local changed = not equalValues(previous, getValue())

							if changed and not silent then
								notifyChanged()
							end

							return changed
						end

						--==========================================================
						-- ITEM CREATION / DELETION
						--==========================================================

						local function destroyItems()
							for _, item in ipairs(elements) do
								if item.connection then
									item.connection:Disconnect()
								end

								item.button:Destroy()
							end

							table.clear(elements)
						end

						local function buildItems()
							for index, itemName in ipairs(values) do
								local item = {
									name = itemName,
									index = index,
								}

								local itemButton = library:Create("TextButton", {
									Name = "Item_" .. tostring(index),
									ZIndex = 21,
									Size = UDim2.new(1, -4, 0, rowHeight),
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
								}, {
									instancep = "TextColor3",
									tinstance = library.FontColor,
								})

								library:Create("UIStroke", {
									ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
									Color = library.UIstroke or library.UIStroke or library.SecondaryColor,
									Thickness = 1,
									Parent = itemButton,
								}, {
									instancep = "Color",
									tinstance = library.UIstroke or library.UIStroke or library.SecondaryColor,
								})

								if typeof(library.FontFace) == "Font" then
									itemButton.FontFace = library.FontFace
								end

								item.button = itemButton
								elements[index] = item

								item.connection = itemButton.MouseButton1Click:Connect(function()
									if destroyed then
										return
									end

									local previous = getValue()

									if multi then
										if selectedIndices[index] then
											selectedIndices[index] = nil
										else
											selectedIndices[index] = true
										end
									else
										picked = itemName
										isOpen = false
									end

									updateUI()

									if not equalValues(previous, getValue()) then
										notifyChanged()
									end
								end)
							end
						end

						--==========================================================
						-- PUBLIC VALUE METHODS
						--==========================================================

						function Dropdown:GetValue()
							return getValue()
						end

						function Dropdown:GetIndex()
							if multi then
								local indices = {}

								for index in ipairs(values) do
									if selectedIndices[index] then
										table.insert(indices, index)
									end
								end

								return indices
							end

							return picked ~= nil and table.find(values, picked) or nil
						end

						function Dropdown:GetValues()
							return table.clone(values)
						end

						function Dropdown:SetValue(value, silent)
							return setValue(value, silent == true)
						end

						function Dropdown:GetInstance()
							return selectedLabel
						end

						function Dropdown:SetText(text)
							if not destroyed then
								header.Text = tostring(text or name)
							end

							return self
						end

						function Dropdown:SetCallback(fn)
							assert(
								fn == nil or type(fn) == "function",
								"Dropdown:SetCallback expects a function or nil"
							)

							callback = fn
							return self
						end

						--==========================================================
						-- REFRESH / CLEAR / REMOVE
						--==========================================================

						function Dropdown:Refresh(newValues, defaultValue, silent)
							if destroyed then
								return self
							end

							local refreshed = copyUnique(newValues)
							local previous = getValue()

							destroyItems()
							table.clear(values)
							table.clear(selectedIndices)
							picked = nil

							for _, value in ipairs(refreshed) do
								table.insert(values, value)
							end

							buildItems()

							if defaultValue ~= nil then
								setValue(defaultValue, true)
							else
								if multi then
									for _, oldValue in ipairs(previous) do
										local index = table.find(values, oldValue)

										if index then
											selectedIndices[index] = true
										end
									end
								elseif previous ~= nil and table.find(values, previous) then
									picked = previous
								end

								updateUI()
							end

							holder.CanvasPosition = Vector2.zero

							if silent == false and not equalValues(previous, getValue()) then
								notifyChanged()
							end

							refreshTheme()

							return self
						end

						function Dropdown:SetValues(newValues, defaultValue, silent)
							return self:Refresh(newValues, defaultValue, silent)
						end

						function Dropdown:Clear(silent)
							return self:Refresh({}, nil, silent)
						end

						function Dropdown:AddItem(itemName)
							if destroyed then
								return nil
							end

							local existingIndex = table.find(values, itemName)

							if existingIndex then
								return elements[existingIndex]
							end

							local updated = table.clone(values)
							table.insert(updated, itemName)

							self:Refresh(updated)

							local index = table.find(values, itemName)
							return index and elements[index] or nil
						end

						function Dropdown:RemoveItem(itemName, silent)
							if destroyed then
								return false
							end

							local index = table.find(values, itemName)

							if not index then
								return false
							end

							local updated = table.clone(values)
							table.remove(updated, index)

							self:Refresh(updated, nil, silent)

							return true
						end

						function Dropdown:Open()
							if not destroyed and #values > 0 then
								isOpen = true
								updateHolderSize()
							end

							return self
						end

						function Dropdown:Close()
							if not destroyed then
								isOpen = false
								updateHolderSize()
							end

							return self
						end

						--==========================================================
						-- OVERLAY TRACKING + LIVE THEME WATCHER
						--==========================================================

						if overlayRoot then
							connect(selectionRow:GetPropertyChangedSignal("AbsolutePosition"), positionHolder)
							connect(selectionRow:GetPropertyChangedSignal("AbsoluteSize"), positionHolder)
							connect(overlayRoot:GetPropertyChangedSignal("AbsoluteSize"), positionHolder)
						end

						local themeSnapshot = readThemeSnapshot()

						connect(game:GetService("RunService").Heartbeat, function()
							if destroyed then
								return
							end

							local currentSnapshot = readThemeSnapshot()

							if themeSnapshotChanged(themeSnapshot, currentSnapshot) then
								themeSnapshot = currentSnapshot
								refreshTheme()
							end
						end)

						--==========================================================
						-- CLEANUP
						--==========================================================

						local function cleanup()
							if destroyed then
								return
							end

							destroyed = true

							destroyItems()

							for _, connection in ipairs(connections) do
								connection:Disconnect()
							end

							table.clear(connections)

							if overlayGui then
								overlayGui:Destroy()
								overlayGui = nil
								overlayRoot = nil
							end

							if library.Options[name] == option then
								library.Options[name] = nil
							end

							option.Controller = nil
							changedEvent:Destroy()
						end

						function Dropdown:Destroy()
							if destroyed then
								return
							end

							cleanup()
							main:Destroy()
						end

						connect(main.Destroying, cleanup)

						connect(button.MouseButton1Click, function()
							if destroyed then
								return
							end

							isOpen = not isOpen
							updateHolderSize()
						end)

						--==========================================================
						-- OPTION API
						--==========================================================

						local forwardedMethods = {
							"GetValue",
							"GetIndex",
							"GetValues",
							"SetValue",
							"SetValues",
							"Refresh",
							"Clear",
							"AddItem",
							"RemoveItem",
							"GetInstance",
							"SetText",
							"SetCallback",
							"Open",
							"Close",
							"Destroy",
						}

						for _, methodName in ipairs(forwardedMethods) do
							local method = Dropdown[methodName]

							option[methodName] = function(_, ...)
								return method(Dropdown, ...)
							end
						end

						--==========================================================
						-- INITIALIZATION
						--==========================================================

						Dropdown.Instance = selectedLabel
						Dropdown.Main = main
						Dropdown.Header = header
						Dropdown.Holder = holder
						Dropdown.Option = option
						Dropdown.OnChanged = changedEvent.Event

						if typeof(library.FontFace) == "Font" then
							header.FontFace = library.FontFace
							selectedLabel.FontFace = library.FontFace
						end

						Dropdown:Refresh(opts.Values or {}, opts.Default, true)
						refreshTheme()
						positionHolder()

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

				function Intab:AddRightGroupbox(title)
					local groupbox = {
						elements = {};
					}

					local groupboxf = library:Create("Frame", {
						Name = "Groupbox";
						Size = UDim2.new(0.95, 0,0, 0);
						Position = UDim2.new(0, 0,0, 0);
						BackgroundColor3 = library.MainColor;
						AutomaticSize = Enum.AutomaticSize.Y;
						LayoutOrder = #Rightin:GetChildren();
						Parent = Rightin;
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
								Size = UDim2.new(0, 15,0, 15);
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

						--==========================================================
						-- REUSE AN EXISTING DROPDOWN
						--==========================================================

						local existing = library.Options[name]

						if existing then
							if existing.Type == "Dropdown"
								and existing.Controller
								and type(existing.Controller.Refresh) == "function" then

								local controller = existing.Controller

								if opts.Text ~= nil then
									controller:SetText(opts.Text)
								end

								if opts.Callback ~= nil then
									controller:SetCallback(opts.Callback)
								end

								if opts.Values ~= nil then
									controller:Refresh(opts.Values, opts.Default)
								elseif opts.Default ~= nil then
									controller:SetValue(opts.Default, true)
								end

								return controller
							end

							warn("An option named '" .. tostring(name) .. "' already exists.")
							return nil
						end

						--==========================================================
						-- STATE
						--==========================================================

						local Dropdown = {}

						local values = {}
						local elements = {}
						local selectedIndices = {}
						local connections = {}

						local picked = nil
						local isOpen = false
						local destroyed = false

						local multi = opts.Multipick == true
						local callback = opts.Callback

						local rowHeight = 20
						local rowGap = 3
						local padding = 4

						local requestedVisible = tonumber(opts.MaxVisibleItems) or 10

						if requestedVisible ~= requestedVisible then
							requestedVisible = 10
						end

						local maxVisibleItems = math.clamp(
							math.floor(requestedVisible),
							1,
							30
						)

						local changedEvent = Instance.new("BindableEvent")

						local option = {
							Type = "Dropdown",
							Name = name,
							Value = multi and {} or nil,
							Values = values,
							OnChanged = changedEvent.Event,
							Controller = Dropdown,
						}

						library.Options[name] = option

						local function connect(signal, fn)
							local connection = signal:Connect(fn)
							table.insert(connections, connection)
							return connection
						end

						local function copyUnique(source)
							local result = {}
							local seen = {}

							if type(source) ~= "table" then
								return result
							end

							for _, value in ipairs(source) do
								local supported = type(value) == "string"
									or (
										type(value) == "number"
										and value == value
										and value > -math.huge
										and value < math.huge
									)

								if supported and not seen[value] then
									seen[value] = true
									table.insert(result, value)
								end
							end

							return result
						end

						local function findIndex(value)
							if type(value) == "number" then
								if value % 1 == 0 and value >= 1 and value <= #values then
									return value
								end

								return nil
							end

							return table.find(values, value)
						end

						local function getValue()
							if not multi then
								return picked
							end

							local selected = {}

							for index, value in ipairs(values) do
								if selectedIndices[index] then
									table.insert(selected, value)
								end
							end

							return selected
						end

						local function equalValues(a, b)
							if type(a) ~= type(b) then
								return false
							end

							if type(a) ~= "table" then
								return a == b
							end

							if #a ~= #b then
								return false
							end

							for index, value in ipairs(a) do
								if b[index] ~= value then
									return false
								end
							end

							return true
						end

						--==========================================================
						-- MAIN UI
						--==========================================================

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
							Text = tostring(opts.Text or name),
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
							Size = UDim2.new(1, 0, 0, 22),
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
							BackgroundTransparency = 1,
							Text = "-",
							Font = library.Font,
							TextColor3 = library.FontColor,
							TextSize = 12,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextTruncate = Enum.TextTruncate.AtEnd,
							Parent = selectionRow,
						}, {
							instancep = "Font",
							tinstance = library.Font,
						}, {
							instancep = "TextColor3",
							tinstance = library.FontColor,
						})

						library:Create("UIPadding", {
							PaddingLeft = UDim.new(0, 6),
							PaddingRight = UDim.new(0, 3),
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
							Size = UDim2.fromOffset(15, 15),
							Position = UDim2.new(1, -19, 0.5, -7),
							BackgroundTransparency = 1,
							Image = "rbxassetid://10709767827",
							ScaleType = Enum.ScaleType.Crop,
							Parent = selectionRow,
						})

						local button = library:Create("TextButton", {
							Name = "DropdownButton",
							ZIndex = 14,
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							Text = "",
							AutoButtonColor = false,
							Parent = selectionRow,
						})

						-- Fixed viewport height; canvas grows to fit every item.
						local holder = library:Create("ScrollingFrame", {
							Name = "Holder",
							ZIndex = 20,
							Size = UDim2.new(1, 0, 0, 0),
							AutomaticSize = Enum.AutomaticSize.None,
							AutomaticCanvasSize = Enum.AutomaticSize.None,
							CanvasSize = UDim2.fromOffset(0, 0),
							CanvasPosition = Vector2.zero,
							LayoutOrder = 2,
							BackgroundColor3 = library.MainColor,
							BorderSizePixel = 0,
							ScrollBarThickness = 3,
							ScrollBarImageColor3 = library.AccentColor,
							ScrollingDirection = Enum.ScrollingDirection.Y,
							Visible = false,
							ClipsDescendants = true,
							Parent = dropdownFrame,
						}, {
							instancep = "BackgroundColor3",
							tinstance = library.MainColor,
						}, {
							instancep = "ScrollBarImageColor3",
							tinstance = library.AccentColor,
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

						library:Create("UIListLayout", {
							FillDirection = Enum.FillDirection.Vertical,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Top,
							Padding = UDim.new(0, rowGap),
							SortOrder = Enum.SortOrder.LayoutOrder,
							Parent = holder,
						})

						library:Create("UIPadding", {
							PaddingLeft = UDim.new(0, padding),
							PaddingRight = UDim.new(0, padding),
							PaddingTop = UDim.new(0, padding),
							PaddingBottom = UDim.new(0, padding),
							Parent = holder,
						})

						--==========================================================
						-- TOP-LEVEL DROPDOWN OVERLAY
						--==========================================================

						local overlayRoot

						local sourceScreenGui = main:FindFirstAncestorOfClass("ScreenGui")
						local player = LocalPlayer
						local playerGui = (sourceScreenGui and sourceScreenGui.Parent)
							or (player and player:FindFirstChildOfClass("PlayerGui"))

						if playerGui then
							local highestDisplayOrder = 0

							for _, child in ipairs(playerGui:GetChildren()) do
								if child:IsA("ScreenGui") then
									highestDisplayOrder = math.max(highestDisplayOrder, child.DisplayOrder)
								end
							end

							overlayRoot = Instance.new("Frame")
							overlayRoot.Name = "OverlayRoot"
							overlayRoot.BackgroundTransparency = 1
							overlayRoot.BorderSizePixel = 0
							overlayRoot.Size = UDim2.fromScale(1, 1)
							overlayRoot.Position = UDim2.fromScale(0, 0)
							overlayRoot.Parent = Overlaygui

							holder.Parent = overlayRoot
						end

						local function positionHolder()
							if not overlayRoot or not holder or not holder.Parent then
								return
							end

							local rootPosition = overlayRoot.AbsolutePosition
							local rootSize = overlayRoot.AbsoluteSize
							local rowPosition = selectionRow.AbsolutePosition
							local rowSize = selectionRow.AbsoluteSize
							local width = math.max(0, rowSize.X)
							local height = holder.Size.Y.Offset
							local x = rowPosition.X - rootPosition.X
							local y = rowPosition.Y - rootPosition.Y + rowSize.Y + 3

							if y + height > rootSize.Y then
								y = rowPosition.Y - rootPosition.Y - height - 3
							end

							x = math.clamp(x, 0, math.max(0, rootSize.X - width))
							y = math.clamp(y, 0, math.max(0, rootSize.Y - height))

							holder.Position = UDim2.fromOffset(x, y)
							holder.Size = UDim2.fromOffset(width, height)
						end

						--==========================================================
						-- UI UPDATES
						--==========================================================

						local function updateHolderSize()
							local count = #values
							local visibleRows = math.min(count, maxVisibleItems)

							local function heightFor(rows)
								if rows == 0 then
									return 0
								end

								return padding * 2
									+ rows * rowHeight
									+ math.max(0, rows - 1) * rowGap
							end

							local holderHeight = heightFor(visibleRows)

							if overlayRoot then
								holder.Size = UDim2.fromOffset(selectionRow.AbsoluteSize.X, holderHeight)
							else
								holder.Size = UDim2.new(1, 0, 0, holderHeight)
							end

							holder.CanvasSize = UDim2.fromOffset(0, heightFor(count))
							holder.ScrollingEnabled = count > maxVisibleItems

							if count == 0 then
								isOpen = false
							end

							holder.Visible = isOpen and count > 0
							arrow.Rotation = holder.Visible and 180 or 0
							positionHolder()
						end

						local function updateSelectedText()
							local current = getValue()
							local hasSelection

							if multi then
								local display = {}

								for _, value in ipairs(current) do
									table.insert(display, tostring(value))
								end

								hasSelection = #display > 0
								selectedLabel.Text = hasSelection
									and table.concat(display, ", ")
									or "-"
							else
								hasSelection = current ~= nil
								selectedLabel.Text = hasSelection and tostring(current) or "-"
							end

							selectedLabel.TextColor3 = hasSelection
								and library.AccentColor
								or library.FontColor

							option.Value = current
						end

						local function updateItems()
							for index, item in ipairs(elements) do
								local selected = multi
									and selectedIndices[index] == true
									or (not multi and picked == item.name)

								item.button.Text = selected
									and ("✓  " .. tostring(item.name))
									or tostring(item.name)

								item.button.TextColor3 = selected
									and library.AccentColor
									or library.FontColor
							end
						end

						local function updateUI()
							updateSelectedText()
							updateItems()
							updateHolderSize()
						end

						-- Reapply current theme values to already-created instances.
						local function refreshTheme()
							if destroyed then
								return
							end

							local strokeColor = library.UIstroke or library.UIStroke or library.SecondaryColor

							header.TextColor3 = library.FontColor
							header.Font = library.Font
							selectedLabel.Font = library.Font
							holder.BackgroundColor3 = library.MainColor
							holder.ScrollBarImageColor3 = library.AccentColor

							if typeof(library.FontFace) == "Font" then
								header.FontFace = library.FontFace
								selectedLabel.FontFace = library.FontFace
							end

							for _, root in ipairs({ main, holder }) do
								for _, descendant in ipairs(root:GetDescendants()) do
									if descendant:IsA("UIStroke") then
										if descendant.Parent == selectionRow or descendant.Parent == holder then
											descendant.Color = library.SecondaryColor
										else
											descendant.Color = strokeColor
										end
									elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
										descendant.Font = library.Font

										if typeof(library.FontFace) == "Font" then
											descendant.FontFace = library.FontFace
										end
									end
								end
							end

							updateSelectedText()
							updateItems()
						end

						local function readThemeSnapshot()
							return {
								MainColor = library.MainColor,
								SecondaryColor = library.SecondaryColor,
								AccentColor = library.AccentColor,
								FontColor = library.FontColor,
								UIstroke = library.UIstroke,
								UIStroke = library.UIStroke,
								Font = library.Font,
								FontFace = library.FontFace,
							}
						end

						local function themeSnapshotChanged(previous, current)
							for key, value in pairs(previous) do
								if current[key] ~= value then
									return true
								end
							end

							return false
						end

						local function notifyChanged()
							local value = getValue()

							option.Value = value

							changedEvent:Fire(
								type(value) == "table" and table.clone(value) or value
							)

							if type(callback) == "function" then
								local ok, err = pcall(
									callback,
									type(value) == "table" and table.clone(value) or value
								)

								if not ok then
									warn(
										"[Dropdown:" .. tostring(name) .. "] Callback failed:",
										err
									)
								end
							end
						end

						local function setValue(value, silent)
							if destroyed then
								return false
							end

							local previous = getValue()

							if multi then
								table.clear(selectedIndices)

								local selections

								if type(value) == "table" then
									selections = value
								elseif value ~= nil then
									selections = { value }
								else
									selections = {}
								end

								for _, selection in ipairs(selections) do
									local index = findIndex(selection)

									if index then
										selectedIndices[index] = true
									end
								end
							else
								local index = findIndex(value)
								picked = index and values[index] or nil
							end

							updateUI()

							local changed = not equalValues(previous, getValue())

							if changed and not silent then
								notifyChanged()
							end

							return changed
						end

						--==========================================================
						-- ITEM CREATION / DELETION
						--==========================================================

						local function destroyItems()
							for _, item in ipairs(elements) do
								if item.connection then
									item.connection:Disconnect()
								end

								item.button:Destroy()
							end

							table.clear(elements)
						end

						local function buildItems()
							for index, itemName in ipairs(values) do
								local item = {
									name = itemName,
									index = index,
								}

								local itemButton = library:Create("TextButton", {
									Name = "Item_" .. tostring(index),
									ZIndex = 21,
									Size = UDim2.new(1, -4, 0, rowHeight),
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
								}, {
									instancep = "TextColor3",
									tinstance = library.FontColor,
								})

								library:Create("UIStroke", {
									ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
									Color = library.UIstroke or library.UIStroke or library.SecondaryColor,
									Thickness = 1,
									Parent = itemButton,
								}, {
									instancep = "Color",
									tinstance = library.UIstroke or library.UIStroke or library.SecondaryColor,
								})

								if typeof(library.FontFace) == "Font" then
									itemButton.FontFace = library.FontFace
								end

								item.button = itemButton
								elements[index] = item

								item.connection = itemButton.MouseButton1Click:Connect(function()
									if destroyed then
										return
									end

									local previous = getValue()

									if multi then
										if selectedIndices[index] then
											selectedIndices[index] = nil
										else
											selectedIndices[index] = true
										end
									else
										picked = itemName
										isOpen = false
									end

									updateUI()

									if not equalValues(previous, getValue()) then
										notifyChanged()
									end
								end)
							end
						end

						--==========================================================
						-- PUBLIC VALUE METHODS
						--==========================================================

						function Dropdown:GetValue()
							return getValue()
						end

						function Dropdown:GetIndex()
							if multi then
								local indices = {}

								for index in ipairs(values) do
									if selectedIndices[index] then
										table.insert(indices, index)
									end
								end

								return indices
							end

							return picked ~= nil and table.find(values, picked) or nil
						end

						function Dropdown:GetValues()
							return table.clone(values)
						end

						function Dropdown:SetValue(value, silent)
							return setValue(value, silent == true)
						end

						function Dropdown:GetInstance()
							return selectedLabel
						end

						function Dropdown:SetText(text)
							if not destroyed then
								header.Text = tostring(text or name)
							end

							return self
						end

						function Dropdown:SetCallback(fn)
							assert(
								fn == nil or type(fn) == "function",
								"Dropdown:SetCallback expects a function or nil"
							)

							callback = fn
							return self
						end

						--==========================================================
						-- REFRESH / CLEAR / REMOVE
						--==========================================================

						function Dropdown:Refresh(newValues, defaultValue, silent)
							if destroyed then
								return self
							end

							local refreshed = copyUnique(newValues)
							local previous = getValue()

							destroyItems()
							table.clear(values)
							table.clear(selectedIndices)
							picked = nil

							for _, value in ipairs(refreshed) do
								table.insert(values, value)
							end

							buildItems()

							if defaultValue ~= nil then
								setValue(defaultValue, true)
							else
								if multi then
									for _, oldValue in ipairs(previous) do
										local index = table.find(values, oldValue)

										if index then
											selectedIndices[index] = true
										end
									end
								elseif previous ~= nil and table.find(values, previous) then
									picked = previous
								end

								updateUI()
							end

							holder.CanvasPosition = Vector2.zero

							if silent == false and not equalValues(previous, getValue()) then
								notifyChanged()
							end

							refreshTheme()

							return self
						end

						function Dropdown:SetValues(newValues, defaultValue, silent)
							return self:Refresh(newValues, defaultValue, silent)
						end

						function Dropdown:Clear(silent)
							return self:Refresh({}, nil, silent)
						end

						function Dropdown:AddItem(itemName)
							if destroyed then
								return nil
							end

							local existingIndex = table.find(values, itemName)

							if existingIndex then
								return elements[existingIndex]
							end

							local updated = table.clone(values)
							table.insert(updated, itemName)

							self:Refresh(updated)

							local index = table.find(values, itemName)
							return index and elements[index] or nil
						end

						function Dropdown:RemoveItem(itemName, silent)
							if destroyed then
								return false
							end

							local index = table.find(values, itemName)

							if not index then
								return false
							end

							local updated = table.clone(values)
							table.remove(updated, index)

							self:Refresh(updated, nil, silent)

							return true
						end

						function Dropdown:Open()
							if not destroyed and #values > 0 then
								isOpen = true
								updateHolderSize()
							end

							return self
						end

						function Dropdown:Close()
							if not destroyed then
								isOpen = false
								updateHolderSize()
							end

							return self
						end

						--==========================================================
						-- OVERLAY TRACKING + LIVE THEME WATCHER
						--==========================================================

						if overlayRoot then
							connect(selectionRow:GetPropertyChangedSignal("AbsolutePosition"), positionHolder)
							connect(selectionRow:GetPropertyChangedSignal("AbsoluteSize"), positionHolder)
							connect(overlayRoot:GetPropertyChangedSignal("AbsoluteSize"), positionHolder)
						end

						local themeSnapshot = readThemeSnapshot()

						connect(game:GetService("RunService").Heartbeat, function()
							if destroyed then
								return
							end

							local currentSnapshot = readThemeSnapshot()

							if themeSnapshotChanged(themeSnapshot, currentSnapshot) then
								themeSnapshot = currentSnapshot
								refreshTheme()
							end
						end)

						--==========================================================
						-- CLEANUP
						--==========================================================

						local function cleanup()
							if destroyed then
								return
							end

							destroyed = true

							destroyItems()

							for _, connection in ipairs(connections) do
								connection:Disconnect()
							end

							table.clear(connections)

							if overlayGui then
								overlayGui:Destroy()
								overlayGui = nil
								overlayRoot = nil
							end

							if library.Options[name] == option then
								library.Options[name] = nil
							end

							option.Controller = nil
							changedEvent:Destroy()
						end

						function Dropdown:Destroy()
							if destroyed then
								return
							end

							cleanup()
							main:Destroy()
						end

						connect(main.Destroying, cleanup)

						connect(button.MouseButton1Click, function()
							if destroyed then
								return
							end

							isOpen = not isOpen
							updateHolderSize()
						end)

						--==========================================================
						-- OPTION API
						--==========================================================

						local forwardedMethods = {
							"GetValue",
							"GetIndex",
							"GetValues",
							"SetValue",
							"SetValues",
							"Refresh",
							"Clear",
							"AddItem",
							"RemoveItem",
							"GetInstance",
							"SetText",
							"SetCallback",
							"Open",
							"Close",
							"Destroy",
						}

						for _, methodName in ipairs(forwardedMethods) do
							local method = Dropdown[methodName]

							option[methodName] = function(_, ...)
								return method(Dropdown, ...)
							end
						end

						--==========================================================
						-- INITIALIZATION
						--==========================================================

						Dropdown.Instance = selectedLabel
						Dropdown.Main = main
						Dropdown.Header = header
						Dropdown.Holder = holder
						Dropdown.Option = option
						Dropdown.OnChanged = changedEvent.Event

						if typeof(library.FontFace) == "Font" then
							header.FontFace = library.FontFace
							selectedLabel.FontFace = library.FontFace
						end

						Dropdown:Refresh(opts.Values or {}, opts.Default, true)
						refreshTheme()
						positionHolder()

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

				intabbutton.Activated:Connect(function()
					if currentintab == Intab then return end

					normalmain.Visible = false
					mainintabshadow.Enabled = false
					IntabFrame.Visible = true
					selectedshadowint.Enabled = true
					currentintab = Intab

					for _, otherintab in pairs(intabs) do
						if otherintab ~= Intab then
							otherintab.Frame.Visible = false
							otherintab.SelectedShadow.Enabled = false
						end
					end
				end)

				Intab.Frame = IntabFrame
				Intab.SelectedShadow = selectedshadowint
				intabs[name] = Intab
				return Intab
			end

			-- Mainintab creation
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
					LayoutOrder = #Left:GetChildren();
					Parent = Left;
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
							Size = UDim2.new(0, 15,0, 15);
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

					--==========================================================
					-- REUSE AN EXISTING DROPDOWN
					--==========================================================

					local existing = library.Options[name]

					if existing then
						if existing.Type == "Dropdown"
							and existing.Controller
							and type(existing.Controller.Refresh) == "function" then

							local controller = existing.Controller

							if opts.Text ~= nil then
								controller:SetText(opts.Text)
							end

							if opts.Callback ~= nil then
								controller:SetCallback(opts.Callback)
							end

							if opts.Values ~= nil then
								controller:Refresh(opts.Values, opts.Default)
							elseif opts.Default ~= nil then
								controller:SetValue(opts.Default, true)
							end

							return controller
						end

						warn("An option named '" .. tostring(name) .. "' already exists.")
						return nil
					end

					--==========================================================
					-- STATE
					--==========================================================

					local Dropdown = {}

					local values = {}
					local elements = {}
					local selectedIndices = {}
					local connections = {}

					local picked = nil
					local isOpen = false
					local destroyed = false

					local multi = opts.Multipick == true
					local callback = opts.Callback

					local rowHeight = 20
					local rowGap = 3
					local padding = 4

					local requestedVisible = tonumber(opts.MaxVisibleItems) or 10

					if requestedVisible ~= requestedVisible then
						requestedVisible = 10
					end

					local maxVisibleItems = math.clamp(
						math.floor(requestedVisible),
						1,
						30
					)

					local changedEvent = Instance.new("BindableEvent")

					local option = {
						Type = "Dropdown",
						Name = name,
						Value = multi and {} or nil,
						Values = values,
						OnChanged = changedEvent.Event,
						Controller = Dropdown,
					}

					library.Options[name] = option

					local function connect(signal, fn)
						local connection = signal:Connect(fn)
						table.insert(connections, connection)
						return connection
					end

					local function copyUnique(source)
						local result = {}
						local seen = {}

						if type(source) ~= "table" then
							return result
						end

						for _, value in ipairs(source) do
							local supported = type(value) == "string"
								or (
									type(value) == "number"
									and value == value
									and value > -math.huge
									and value < math.huge
								)

							if supported and not seen[value] then
								seen[value] = true
								table.insert(result, value)
							end
						end

						return result
					end

					local function findIndex(value)
						if type(value) == "number" then
							if value % 1 == 0 and value >= 1 and value <= #values then
								return value
							end

							return nil
						end

						return table.find(values, value)
					end

					local function getValue()
						if not multi then
							return picked
						end

						local selected = {}

						for index, value in ipairs(values) do
							if selectedIndices[index] then
								table.insert(selected, value)
							end
						end

						return selected
					end

					local function equalValues(a, b)
						if type(a) ~= type(b) then
							return false
						end

						if type(a) ~= "table" then
							return a == b
						end

						if #a ~= #b then
							return false
						end

						for index, value in ipairs(a) do
							if b[index] ~= value then
								return false
							end
						end

						return true
					end

					--==========================================================
					-- MAIN UI
					--==========================================================

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
						Text = tostring(opts.Text or name),
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
						Size = UDim2.new(1, 0, 0, 22),
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
						BackgroundTransparency = 1,
						Text = "-",
						Font = library.Font,
						TextColor3 = library.FontColor,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						Parent = selectionRow,
					}, {
						instancep = "Font",
						tinstance = library.Font,
					}, {
						instancep = "TextColor3",
						tinstance = library.FontColor,
					})

					library:Create("UIPadding", {
						PaddingLeft = UDim.new(0, 6),
						PaddingRight = UDim.new(0, 3),
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
						Size = UDim2.fromOffset(15, 15),
						Position = UDim2.new(1, -19, 0.5, -7),
						BackgroundTransparency = 1,
						Image = "rbxassetid://10709767827",
						ScaleType = Enum.ScaleType.Crop,
						Parent = selectionRow,
					})

					local button = library:Create("TextButton", {
						Name = "DropdownButton",
						ZIndex = 14,
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						Text = "",
						AutoButtonColor = false,
						Parent = selectionRow,
					})

					-- Fixed viewport height; canvas grows to fit every item.
					local holder = library:Create("ScrollingFrame", {
						Name = "Holder",
						ZIndex = 20,
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.None,
						AutomaticCanvasSize = Enum.AutomaticSize.None,
						CanvasSize = UDim2.fromOffset(0, 0),
						CanvasPosition = Vector2.zero,
						LayoutOrder = 2,
						BackgroundColor3 = library.MainColor,
						BorderSizePixel = 0,
						ScrollBarThickness = 3,
						ScrollBarImageColor3 = library.AccentColor,
						ScrollingDirection = Enum.ScrollingDirection.Y,
						Visible = false,
						ClipsDescendants = true,
						Parent = dropdownFrame,
					}, {
						instancep = "BackgroundColor3",
						tinstance = library.MainColor,
					}, {
						instancep = "ScrollBarImageColor3",
						tinstance = library.AccentColor,
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

					library:Create("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						Padding = UDim.new(0, rowGap),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = holder,
					})

					library:Create("UIPadding", {
						PaddingLeft = UDim.new(0, padding),
						PaddingRight = UDim.new(0, padding),
						PaddingTop = UDim.new(0, padding),
						PaddingBottom = UDim.new(0, padding),
						Parent = holder,
					})

					--==========================================================
					-- TOP-LEVEL DROPDOWN OVERLAY
					--==========================================================

					local overlayRoot

					local sourceScreenGui = main:FindFirstAncestorOfClass("ScreenGui")
					local player = LocalPlayer
					local playerGui = (sourceScreenGui and sourceScreenGui.Parent)
						or (player and player:FindFirstChildOfClass("PlayerGui"))

					if playerGui then
						local highestDisplayOrder = 0

						for _, child in ipairs(playerGui:GetChildren()) do
							if child:IsA("ScreenGui") then
								highestDisplayOrder = math.max(highestDisplayOrder, child.DisplayOrder)
							end
						end

						overlayRoot = Instance.new("Frame")
						overlayRoot.Name = "OverlayRoot"
						overlayRoot.BackgroundTransparency = 1
						overlayRoot.BorderSizePixel = 0
						overlayRoot.Size = UDim2.fromScale(1, 1)
						overlayRoot.Position = UDim2.fromScale(0, 0)
						overlayRoot.Parent = Overlaygui

						holder.Parent = overlayRoot
					end

					local function positionHolder()
						if not overlayRoot or not holder or not holder.Parent then
							return
						end

						local rootPosition = overlayRoot.AbsolutePosition
						local rootSize = overlayRoot.AbsoluteSize
						local rowPosition = selectionRow.AbsolutePosition
						local rowSize = selectionRow.AbsoluteSize
						local width = math.max(0, rowSize.X)
						local height = holder.Size.Y.Offset
						local x = rowPosition.X - rootPosition.X
						local y = rowPosition.Y - rootPosition.Y + rowSize.Y + 3

						if y + height > rootSize.Y then
							y = rowPosition.Y - rootPosition.Y - height - 3
						end

						x = math.clamp(x, 0, math.max(0, rootSize.X - width))
						y = math.clamp(y, 0, math.max(0, rootSize.Y - height))

						holder.Position = UDim2.fromOffset(x, y)
						holder.Size = UDim2.fromOffset(width, height)
					end

					--==========================================================
					-- UI UPDATES
					--==========================================================

					local function updateHolderSize()
						local count = #values
						local visibleRows = math.min(count, maxVisibleItems)

						local function heightFor(rows)
							if rows == 0 then
								return 0
							end

							return padding * 2
								+ rows * rowHeight
								+ math.max(0, rows - 1) * rowGap
						end

						local holderHeight = heightFor(visibleRows)

						if overlayRoot then
							holder.Size = UDim2.fromOffset(selectionRow.AbsoluteSize.X, holderHeight)
						else
							holder.Size = UDim2.new(1, 0, 0, holderHeight)
						end

						holder.CanvasSize = UDim2.fromOffset(0, heightFor(count))
						holder.ScrollingEnabled = count > maxVisibleItems

						if count == 0 then
							isOpen = false
						end

						holder.Visible = isOpen and count > 0
						arrow.Rotation = holder.Visible and 180 or 0
						positionHolder()
					end

					local function updateSelectedText()
						local current = getValue()
						local hasSelection

						if multi then
							local display = {}

							for _, value in ipairs(current) do
								table.insert(display, tostring(value))
							end

							hasSelection = #display > 0
							selectedLabel.Text = hasSelection
								and table.concat(display, ", ")
								or "-"
						else
							hasSelection = current ~= nil
							selectedLabel.Text = hasSelection and tostring(current) or "-"
						end

						selectedLabel.TextColor3 = hasSelection
							and library.AccentColor
							or library.FontColor

						option.Value = current
					end

					local function updateItems()
						for index, item in ipairs(elements) do
							local selected = multi
								and selectedIndices[index] == true
								or (not multi and picked == item.name)

							item.button.Text = selected
								and ("✓  " .. tostring(item.name))
								or tostring(item.name)

							item.button.TextColor3 = selected
								and library.AccentColor
								or library.FontColor
						end
					end

					local function updateUI()
						updateSelectedText()
						updateItems()
						updateHolderSize()
					end

					-- Reapply current theme values to already-created instances.
					local function refreshTheme()
						if destroyed then
							return
						end

						local strokeColor = library.UIstroke or library.UIStroke or library.SecondaryColor

						header.TextColor3 = library.FontColor
						header.Font = library.Font
						selectedLabel.Font = library.Font
						holder.BackgroundColor3 = library.MainColor
						holder.ScrollBarImageColor3 = library.AccentColor

						if typeof(library.FontFace) == "Font" then
							header.FontFace = library.FontFace
							selectedLabel.FontFace = library.FontFace
						end

						for _, root in ipairs({ main, holder }) do
							for _, descendant in ipairs(root:GetDescendants()) do
								if descendant:IsA("UIStroke") then
									if descendant.Parent == selectionRow or descendant.Parent == holder then
										descendant.Color = library.SecondaryColor
									else
										descendant.Color = strokeColor
									end
								elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
									descendant.Font = library.Font

									if typeof(library.FontFace) == "Font" then
										descendant.FontFace = library.FontFace
									end
								end
							end
						end

						updateSelectedText()
						updateItems()
					end

					local function readThemeSnapshot()
						return {
							MainColor = library.MainColor,
							SecondaryColor = library.SecondaryColor,
							AccentColor = library.AccentColor,
							FontColor = library.FontColor,
							UIstroke = library.UIstroke,
							UIStroke = library.UIStroke,
							Font = library.Font,
							FontFace = library.FontFace,
						}
					end

					local function themeSnapshotChanged(previous, current)
						for key, value in pairs(previous) do
							if current[key] ~= value then
								return true
							end
						end

						return false
					end

					local function notifyChanged()
						local value = getValue()

						option.Value = value

						changedEvent:Fire(
							type(value) == "table" and table.clone(value) or value
						)

						if type(callback) == "function" then
							local ok, err = pcall(
								callback,
								type(value) == "table" and table.clone(value) or value
							)

							if not ok then
								warn(
									"[Dropdown:" .. tostring(name) .. "] Callback failed:",
									err
								)
							end
						end
					end

					local function setValue(value, silent)
						if destroyed then
							return false
						end

						local previous = getValue()

						if multi then
							table.clear(selectedIndices)

							local selections

							if type(value) == "table" then
								selections = value
							elseif value ~= nil then
								selections = { value }
							else
								selections = {}
							end

							for _, selection in ipairs(selections) do
								local index = findIndex(selection)

								if index then
									selectedIndices[index] = true
								end
							end
						else
							local index = findIndex(value)
							picked = index and values[index] or nil
						end

						updateUI()

						local changed = not equalValues(previous, getValue())

						if changed and not silent then
							notifyChanged()
						end

						return changed
					end

					--==========================================================
					-- ITEM CREATION / DELETION
					--==========================================================

					local function destroyItems()
						for _, item in ipairs(elements) do
							if item.connection then
								item.connection:Disconnect()
							end

							item.button:Destroy()
						end

						table.clear(elements)
					end

					local function buildItems()
						for index, itemName in ipairs(values) do
							local item = {
								name = itemName,
								index = index,
							}

							local itemButton = library:Create("TextButton", {
								Name = "Item_" .. tostring(index),
								ZIndex = 21,
								Size = UDim2.new(1, -4, 0, rowHeight),
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
							}, {
								instancep = "TextColor3",
								tinstance = library.FontColor,
							})

							library:Create("UIStroke", {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
								Color = library.UIstroke or library.UIStroke or library.SecondaryColor,
								Thickness = 1,
								Parent = itemButton,
							}, {
								instancep = "Color",
								tinstance = library.UIstroke or library.UIStroke or library.SecondaryColor,
							})

							if typeof(library.FontFace) == "Font" then
								itemButton.FontFace = library.FontFace
							end

							item.button = itemButton
							elements[index] = item

							item.connection = itemButton.MouseButton1Click:Connect(function()
								if destroyed then
									return
								end

								local previous = getValue()

								if multi then
									if selectedIndices[index] then
										selectedIndices[index] = nil
									else
										selectedIndices[index] = true
									end
								else
									picked = itemName
									isOpen = false
								end

								updateUI()

								if not equalValues(previous, getValue()) then
									notifyChanged()
								end
							end)
						end
					end

					--==========================================================
					-- PUBLIC VALUE METHODS
					--==========================================================

					function Dropdown:GetValue()
						return getValue()
					end

					function Dropdown:GetIndex()
						if multi then
							local indices = {}

							for index in ipairs(values) do
								if selectedIndices[index] then
									table.insert(indices, index)
								end
							end

							return indices
						end

						return picked ~= nil and table.find(values, picked) or nil
					end

					function Dropdown:GetValues()
						return table.clone(values)
					end

					function Dropdown:SetValue(value, silent)
						return setValue(value, silent == true)
					end

					function Dropdown:GetInstance()
						return selectedLabel
					end

					function Dropdown:SetText(text)
						if not destroyed then
							header.Text = tostring(text or name)
						end

						return self
					end

					function Dropdown:SetCallback(fn)
						assert(
							fn == nil or type(fn) == "function",
							"Dropdown:SetCallback expects a function or nil"
						)

						callback = fn
						return self
					end

					--==========================================================
					-- REFRESH / CLEAR / REMOVE
					--==========================================================

					function Dropdown:Refresh(newValues, defaultValue, silent)
						if destroyed then
							return self
						end

						local refreshed = copyUnique(newValues)
						local previous = getValue()

						destroyItems()
						table.clear(values)
						table.clear(selectedIndices)
						picked = nil

						for _, value in ipairs(refreshed) do
							table.insert(values, value)
						end

						buildItems()

						if defaultValue ~= nil then
							setValue(defaultValue, true)
						else
							if multi then
								for _, oldValue in ipairs(previous) do
									local index = table.find(values, oldValue)

									if index then
										selectedIndices[index] = true
									end
								end
							elseif previous ~= nil and table.find(values, previous) then
								picked = previous
							end

							updateUI()
						end

						holder.CanvasPosition = Vector2.zero

						if silent == false and not equalValues(previous, getValue()) then
							notifyChanged()
						end

						refreshTheme()

						return self
					end

					function Dropdown:SetValues(newValues, defaultValue, silent)
						return self:Refresh(newValues, defaultValue, silent)
					end

					function Dropdown:Clear(silent)
						return self:Refresh({}, nil, silent)
					end

					function Dropdown:AddItem(itemName)
						if destroyed then
							return nil
						end

						local existingIndex = table.find(values, itemName)

						if existingIndex then
							return elements[existingIndex]
						end

						local updated = table.clone(values)
						table.insert(updated, itemName)

						self:Refresh(updated)

						local index = table.find(values, itemName)
						return index and elements[index] or nil
					end

					function Dropdown:RemoveItem(itemName, silent)
						if destroyed then
							return false
						end

						local index = table.find(values, itemName)

						if not index then
							return false
						end

						local updated = table.clone(values)
						table.remove(updated, index)

						self:Refresh(updated, nil, silent)

						return true
					end

					function Dropdown:Open()
						if not destroyed and #values > 0 then
							isOpen = true
							updateHolderSize()
						end

						return self
					end

					function Dropdown:Close()
						if not destroyed then
							isOpen = false
							updateHolderSize()
						end

						return self
					end

					--==========================================================
					-- OVERLAY TRACKING + LIVE THEME WATCHER
					--==========================================================

					if overlayRoot then
						connect(selectionRow:GetPropertyChangedSignal("AbsolutePosition"), positionHolder)
						connect(selectionRow:GetPropertyChangedSignal("AbsoluteSize"), positionHolder)
						connect(overlayRoot:GetPropertyChangedSignal("AbsoluteSize"), positionHolder)
					end

					local themeSnapshot = readThemeSnapshot()

					connect(game:GetService("RunService").Heartbeat, function()
						if destroyed then
							return
						end

						local currentSnapshot = readThemeSnapshot()

						if themeSnapshotChanged(themeSnapshot, currentSnapshot) then
							themeSnapshot = currentSnapshot
							refreshTheme()
						end
					end)

					--==========================================================
					-- CLEANUP
					--==========================================================

					local function cleanup()
						if destroyed then
							return
						end

						destroyed = true

						destroyItems()

						for _, connection in ipairs(connections) do
							connection:Disconnect()
						end

						table.clear(connections)

						if overlayGui then
							overlayGui:Destroy()
							overlayGui = nil
							overlayRoot = nil
						end

						if library.Options[name] == option then
							library.Options[name] = nil
						end

						option.Controller = nil
						changedEvent:Destroy()
					end

					function Dropdown:Destroy()
						if destroyed then
							return
						end

						cleanup()
						main:Destroy()
					end

					connect(main.Destroying, cleanup)

					connect(button.MouseButton1Click, function()
						if destroyed then
							return
						end

						isOpen = not isOpen
						updateHolderSize()
					end)

					--==========================================================
					-- OPTION API
					--==========================================================

					local forwardedMethods = {
						"GetValue",
						"GetIndex",
						"GetValues",
						"SetValue",
						"SetValues",
						"Refresh",
						"Clear",
						"AddItem",
						"RemoveItem",
						"GetInstance",
						"SetText",
						"SetCallback",
						"Open",
						"Close",
						"Destroy",
					}

					for _, methodName in ipairs(forwardedMethods) do
						local method = Dropdown[methodName]

						option[methodName] = function(_, ...)
							return method(Dropdown, ...)
						end
					end

					--==========================================================
					-- INITIALIZATION
					--==========================================================

					Dropdown.Instance = selectedLabel
					Dropdown.Main = main
					Dropdown.Header = header
					Dropdown.Holder = holder
					Dropdown.Option = option
					Dropdown.OnChanged = changedEvent.Event

					if typeof(library.FontFace) == "Font" then
						header.FontFace = library.FontFace
						selectedLabel.FontFace = library.FontFace
					end

					Dropdown:Refresh(opts.Values or {}, opts.Default, true)
					refreshTheme()
					positionHolder()

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
					LayoutOrder = #Right:GetChildren();
					Parent = Right;
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
							Size = UDim2.new(0, 15,0, 15);
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

					--==========================================================
					-- REUSE AN EXISTING DROPDOWN
					--==========================================================

					local existing = library.Options[name]

					if existing then
						if existing.Type == "Dropdown"
							and existing.Controller
							and type(existing.Controller.Refresh) == "function" then

							local controller = existing.Controller

							if opts.Text ~= nil then
								controller:SetText(opts.Text)
							end

							if opts.Callback ~= nil then
								controller:SetCallback(opts.Callback)
							end

							if opts.Values ~= nil then
								controller:Refresh(opts.Values, opts.Default)
							elseif opts.Default ~= nil then
								controller:SetValue(opts.Default, true)
							end

							return controller
						end

						warn("An option named '" .. tostring(name) .. "' already exists.")
						return nil
					end

					--==========================================================
					-- STATE
					--==========================================================

					local Dropdown = {}

					local values = {}
					local elements = {}
					local selectedIndices = {}
					local connections = {}

					local picked = nil
					local isOpen = false
					local destroyed = false

					local multi = opts.Multipick == true
					local callback = opts.Callback

					local rowHeight = 20
					local rowGap = 3
					local padding = 4

					local requestedVisible = tonumber(opts.MaxVisibleItems) or 10

					if requestedVisible ~= requestedVisible then
						requestedVisible = 10
					end

					local maxVisibleItems = math.clamp(
						math.floor(requestedVisible),
						1,
						30
					)

					local changedEvent = Instance.new("BindableEvent")

					local option = {
						Type = "Dropdown",
						Name = name,
						Value = multi and {} or nil,
						Values = values,
						OnChanged = changedEvent.Event,
						Controller = Dropdown,
					}

					library.Options[name] = option

					local function connect(signal, fn)
						local connection = signal:Connect(fn)
						table.insert(connections, connection)
						return connection
					end

					local function copyUnique(source)
						local result = {}
						local seen = {}

						if type(source) ~= "table" then
							return result
						end

						for _, value in ipairs(source) do
							local supported = type(value) == "string"
								or (
									type(value) == "number"
									and value == value
									and value > -math.huge
									and value < math.huge
								)

							if supported and not seen[value] then
								seen[value] = true
								table.insert(result, value)
							end
						end

						return result
					end

					local function findIndex(value)
						if type(value) == "number" then
							if value % 1 == 0 and value >= 1 and value <= #values then
								return value
							end

							return nil
						end

						return table.find(values, value)
					end

					local function getValue()
						if not multi then
							return picked
						end

						local selected = {}

						for index, value in ipairs(values) do
							if selectedIndices[index] then
								table.insert(selected, value)
							end
						end

						return selected
					end

					local function equalValues(a, b)
						if type(a) ~= type(b) then
							return false
						end

						if type(a) ~= "table" then
							return a == b
						end

						if #a ~= #b then
							return false
						end

						for index, value in ipairs(a) do
							if b[index] ~= value then
								return false
							end
						end

						return true
					end

					--==========================================================
					-- MAIN UI
					--==========================================================

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
						Text = tostring(opts.Text or name),
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
						Size = UDim2.new(1, 0, 0, 22),
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
						BackgroundTransparency = 1,
						Text = "-",
						Font = library.Font,
						TextColor3 = library.FontColor,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						Parent = selectionRow,
					}, {
						instancep = "Font",
						tinstance = library.Font,
					}, {
						instancep = "TextColor3",
						tinstance = library.FontColor,
					})

					library:Create("UIPadding", {
						PaddingLeft = UDim.new(0, 6),
						PaddingRight = UDim.new(0, 3),
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
						Size = UDim2.fromOffset(15, 15),
						Position = UDim2.new(1, -19, 0.5, -7),
						BackgroundTransparency = 1,
						Image = "rbxassetid://10709767827",
						ScaleType = Enum.ScaleType.Crop,
						Parent = selectionRow,
					})

					local button = library:Create("TextButton", {
						Name = "DropdownButton",
						ZIndex = 14,
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						Text = "",
						AutoButtonColor = false,
						Parent = selectionRow,
					})

					-- Fixed viewport height; canvas grows to fit every item.
					local holder = library:Create("ScrollingFrame", {
						Name = "Holder",
						ZIndex = 20,
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.None,
						AutomaticCanvasSize = Enum.AutomaticSize.None,
						CanvasSize = UDim2.fromOffset(0, 0),
						CanvasPosition = Vector2.zero,
						LayoutOrder = 2,
						BackgroundColor3 = library.MainColor,
						BorderSizePixel = 0,
						ScrollBarThickness = 3,
						ScrollBarImageColor3 = library.AccentColor,
						ScrollingDirection = Enum.ScrollingDirection.Y,
						Visible = false,
						ClipsDescendants = true,
						Parent = dropdownFrame,
					}, {
						instancep = "BackgroundColor3",
						tinstance = library.MainColor,
					}, {
						instancep = "ScrollBarImageColor3",
						tinstance = library.AccentColor,
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

					library:Create("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						Padding = UDim.new(0, rowGap),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = holder,
					})

					library:Create("UIPadding", {
						PaddingLeft = UDim.new(0, padding),
						PaddingRight = UDim.new(0, padding),
						PaddingTop = UDim.new(0, padding),
						PaddingBottom = UDim.new(0, padding),
						Parent = holder,
					})

					--==========================================================
					-- TOP-LEVEL DROPDOWN OVERLAY
					--==========================================================

					local overlayRoot

					local sourceScreenGui = main:FindFirstAncestorOfClass("ScreenGui")
					local player = LocalPlayer
					local playerGui = (sourceScreenGui and sourceScreenGui.Parent)
						or (player and player:FindFirstChildOfClass("PlayerGui"))

					if playerGui then
						local highestDisplayOrder = 0

						for _, child in ipairs(playerGui:GetChildren()) do
							if child:IsA("ScreenGui") then
								highestDisplayOrder = math.max(highestDisplayOrder, child.DisplayOrder)
							end
						end

						overlayRoot = Instance.new("Frame")
						overlayRoot.Name = "OverlayRoot"
						overlayRoot.BackgroundTransparency = 1
						overlayRoot.BorderSizePixel = 0
						overlayRoot.Size = UDim2.fromScale(1, 1)
						overlayRoot.Position = UDim2.fromScale(0, 0)
						overlayRoot.Parent = Overlaygui

						holder.Parent = overlayRoot
					end

					local function positionHolder()
						if not overlayRoot or not holder or not holder.Parent then
							return
						end

						local rootPosition = overlayRoot.AbsolutePosition
						local rootSize = overlayRoot.AbsoluteSize
						local rowPosition = selectionRow.AbsolutePosition
						local rowSize = selectionRow.AbsoluteSize
						local width = math.max(0, rowSize.X)
						local height = holder.Size.Y.Offset
						local x = rowPosition.X - rootPosition.X
						local y = rowPosition.Y - rootPosition.Y + rowSize.Y + 3

						if y + height > rootSize.Y then
							y = rowPosition.Y - rootPosition.Y - height - 3
						end

						x = math.clamp(x, 0, math.max(0, rootSize.X - width))
						y = math.clamp(y, 0, math.max(0, rootSize.Y - height))

						holder.Position = UDim2.fromOffset(x, y)
						holder.Size = UDim2.fromOffset(width, height)
					end

					--==========================================================
					-- UI UPDATES
					--==========================================================

					local function updateHolderSize()
						local count = #values
						local visibleRows = math.min(count, maxVisibleItems)

						local function heightFor(rows)
							if rows == 0 then
								return 0
							end

							return padding * 2
								+ rows * rowHeight
								+ math.max(0, rows - 1) * rowGap
						end

						local holderHeight = heightFor(visibleRows)

						if overlayRoot then
							holder.Size = UDim2.fromOffset(selectionRow.AbsoluteSize.X, holderHeight)
						else
							holder.Size = UDim2.new(1, 0, 0, holderHeight)
						end

						holder.CanvasSize = UDim2.fromOffset(0, heightFor(count))
						holder.ScrollingEnabled = count > maxVisibleItems

						if count == 0 then
							isOpen = false
						end

						holder.Visible = isOpen and count > 0
						arrow.Rotation = holder.Visible and 180 or 0
						positionHolder()
					end

					local function updateSelectedText()
						local current = getValue()
						local hasSelection

						if multi then
							local display = {}

							for _, value in ipairs(current) do
								table.insert(display, tostring(value))
							end

							hasSelection = #display > 0
							selectedLabel.Text = hasSelection
								and table.concat(display, ", ")
								or "-"
						else
							hasSelection = current ~= nil
							selectedLabel.Text = hasSelection and tostring(current) or "-"
						end

						selectedLabel.TextColor3 = hasSelection
							and library.AccentColor
							or library.FontColor

						option.Value = current
					end

					local function updateItems()
						for index, item in ipairs(elements) do
							local selected = multi
								and selectedIndices[index] == true
								or (not multi and picked == item.name)

							item.button.Text = selected
								and ("✓  " .. tostring(item.name))
								or tostring(item.name)

							item.button.TextColor3 = selected
								and library.AccentColor
								or library.FontColor
						end
					end

					local function updateUI()
						updateSelectedText()
						updateItems()
						updateHolderSize()
					end

					-- Reapply current theme values to already-created instances.
					local function refreshTheme()
						if destroyed then
							return
						end

						local strokeColor = library.UIstroke or library.UIStroke or library.SecondaryColor

						header.TextColor3 = library.FontColor
						header.Font = library.Font
						selectedLabel.Font = library.Font
						holder.BackgroundColor3 = library.MainColor
						holder.ScrollBarImageColor3 = library.AccentColor

						if typeof(library.FontFace) == "Font" then
							header.FontFace = library.FontFace
							selectedLabel.FontFace = library.FontFace
						end

						for _, root in ipairs({ main, holder }) do
							for _, descendant in ipairs(root:GetDescendants()) do
								if descendant:IsA("UIStroke") then
									if descendant.Parent == selectionRow or descendant.Parent == holder then
										descendant.Color = library.SecondaryColor
									else
										descendant.Color = strokeColor
									end
								elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
									descendant.Font = library.Font

									if typeof(library.FontFace) == "Font" then
										descendant.FontFace = library.FontFace
									end
								end
							end
						end

						updateSelectedText()
						updateItems()
					end

					local function readThemeSnapshot()
						return {
							MainColor = library.MainColor,
							SecondaryColor = library.SecondaryColor,
							AccentColor = library.AccentColor,
							FontColor = library.FontColor,
							UIstroke = library.UIstroke,
							UIStroke = library.UIStroke,
							Font = library.Font,
							FontFace = library.FontFace,
						}
					end

					local function themeSnapshotChanged(previous, current)
						for key, value in pairs(previous) do
							if current[key] ~= value then
								return true
							end
						end

						return false
					end

					local function notifyChanged()
						local value = getValue()

						option.Value = value

						changedEvent:Fire(
							type(value) == "table" and table.clone(value) or value
						)

						if type(callback) == "function" then
							local ok, err = pcall(
								callback,
								type(value) == "table" and table.clone(value) or value
							)

							if not ok then
								warn(
									"[Dropdown:" .. tostring(name) .. "] Callback failed:",
									err
								)
							end
						end
					end

					local function setValue(value, silent)
						if destroyed then
							return false
						end

						local previous = getValue()

						if multi then
							table.clear(selectedIndices)

							local selections

							if type(value) == "table" then
								selections = value
							elseif value ~= nil then
								selections = { value }
							else
								selections = {}
							end

							for _, selection in ipairs(selections) do
								local index = findIndex(selection)

								if index then
									selectedIndices[index] = true
								end
							end
						else
							local index = findIndex(value)
							picked = index and values[index] or nil
						end

						updateUI()

						local changed = not equalValues(previous, getValue())

						if changed and not silent then
							notifyChanged()
						end

						return changed
					end

					--==========================================================
					-- ITEM CREATION / DELETION
					--==========================================================

					local function destroyItems()
						for _, item in ipairs(elements) do
							if item.connection then
								item.connection:Disconnect()
							end

							item.button:Destroy()
						end

						table.clear(elements)
					end

					local function buildItems()
						for index, itemName in ipairs(values) do
							local item = {
								name = itemName,
								index = index,
							}

							local itemButton = library:Create("TextButton", {
								Name = "Item_" .. tostring(index),
								ZIndex = 21,
								Size = UDim2.new(1, -4, 0, rowHeight),
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
							}, {
								instancep = "TextColor3",
								tinstance = library.FontColor,
							})

							library:Create("UIStroke", {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
								Color = library.UIstroke or library.UIStroke or library.SecondaryColor,
								Thickness = 1,
								Parent = itemButton,
							}, {
								instancep = "Color",
								tinstance = library.UIstroke or library.UIStroke or library.SecondaryColor,
							})

							if typeof(library.FontFace) == "Font" then
								itemButton.FontFace = library.FontFace
							end

							item.button = itemButton
							elements[index] = item

							item.connection = itemButton.MouseButton1Click:Connect(function()
								if destroyed then
									return
								end

								local previous = getValue()

								if multi then
									if selectedIndices[index] then
										selectedIndices[index] = nil
									else
										selectedIndices[index] = true
									end
								else
									picked = itemName
									isOpen = false
								end

								updateUI()

								if not equalValues(previous, getValue()) then
									notifyChanged()
								end
							end)
						end
					end

					--==========================================================
					-- PUBLIC VALUE METHODS
					--==========================================================

					function Dropdown:GetValue()
						return getValue()
					end

					function Dropdown:GetIndex()
						if multi then
							local indices = {}

							for index in ipairs(values) do
								if selectedIndices[index] then
									table.insert(indices, index)
								end
							end

							return indices
						end

						return picked ~= nil and table.find(values, picked) or nil
					end

					function Dropdown:GetValues()
						return table.clone(values)
					end

					function Dropdown:SetValue(value, silent)
						return setValue(value, silent == true)
					end

					function Dropdown:GetInstance()
						return selectedLabel
					end

					function Dropdown:SetText(text)
						if not destroyed then
							header.Text = tostring(text or name)
						end

						return self
					end

					function Dropdown:SetCallback(fn)
						assert(
							fn == nil or type(fn) == "function",
							"Dropdown:SetCallback expects a function or nil"
						)

						callback = fn
						return self
					end

					--==========================================================
					-- REFRESH / CLEAR / REMOVE
					--==========================================================

					function Dropdown:Refresh(newValues, defaultValue, silent)
						if destroyed then
							return self
						end

						local refreshed = copyUnique(newValues)
						local previous = getValue()

						destroyItems()
						table.clear(values)
						table.clear(selectedIndices)
						picked = nil

						for _, value in ipairs(refreshed) do
							table.insert(values, value)
						end

						buildItems()

						if defaultValue ~= nil then
							setValue(defaultValue, true)
						else
							if multi then
								for _, oldValue in ipairs(previous) do
									local index = table.find(values, oldValue)

									if index then
										selectedIndices[index] = true
									end
								end
							elseif previous ~= nil and table.find(values, previous) then
								picked = previous
							end

							updateUI()
						end

						holder.CanvasPosition = Vector2.zero

						if silent == false and not equalValues(previous, getValue()) then
							notifyChanged()
						end

						refreshTheme()

						return self
					end

					function Dropdown:SetValues(newValues, defaultValue, silent)
						return self:Refresh(newValues, defaultValue, silent)
					end

					function Dropdown:Clear(silent)
						return self:Refresh({}, nil, silent)
					end

					function Dropdown:AddItem(itemName)
						if destroyed then
							return nil
						end

						local existingIndex = table.find(values, itemName)

						if existingIndex then
							return elements[existingIndex]
						end

						local updated = table.clone(values)
						table.insert(updated, itemName)

						self:Refresh(updated)

						local index = table.find(values, itemName)
						return index and elements[index] or nil
					end

					function Dropdown:RemoveItem(itemName, silent)
						if destroyed then
							return false
						end

						local index = table.find(values, itemName)

						if not index then
							return false
						end

						local updated = table.clone(values)
						table.remove(updated, index)

						self:Refresh(updated, nil, silent)

						return true
					end

					function Dropdown:Open()
						if not destroyed and #values > 0 then
							isOpen = true
							updateHolderSize()
						end

						return self
					end

					function Dropdown:Close()
						if not destroyed then
							isOpen = false
							updateHolderSize()
						end

						return self
					end

					--==========================================================
					-- OVERLAY TRACKING + LIVE THEME WATCHER
					--==========================================================

					if overlayRoot then
						connect(selectionRow:GetPropertyChangedSignal("AbsolutePosition"), positionHolder)
						connect(selectionRow:GetPropertyChangedSignal("AbsoluteSize"), positionHolder)
						connect(overlayRoot:GetPropertyChangedSignal("AbsoluteSize"), positionHolder)
					end

					local themeSnapshot = readThemeSnapshot()

					connect(game:GetService("RunService").Heartbeat, function()
						if destroyed then
							return
						end

						local currentSnapshot = readThemeSnapshot()

						if themeSnapshotChanged(themeSnapshot, currentSnapshot) then
							themeSnapshot = currentSnapshot
							refreshTheme()
						end
					end)

					--==========================================================
					-- CLEANUP
					--==========================================================

					local function cleanup()
						if destroyed then
							return
						end

						destroyed = true

						destroyItems()

						for _, connection in ipairs(connections) do
							connection:Disconnect()
						end

						table.clear(connections)

						if overlayGui then
							overlayGui:Destroy()
							overlayGui = nil
							overlayRoot = nil
						end

						if library.Options[name] == option then
							library.Options[name] = nil
						end

						option.Controller = nil
						changedEvent:Destroy()
					end

					function Dropdown:Destroy()
						if destroyed then
							return
						end

						cleanup()
						main:Destroy()
					end

					connect(main.Destroying, cleanup)

					connect(button.MouseButton1Click, function()
						if destroyed then
							return
						end

						isOpen = not isOpen
						updateHolderSize()
					end)

					--==========================================================
					-- OPTION API
					--==========================================================

					local forwardedMethods = {
						"GetValue",
						"GetIndex",
						"GetValues",
						"SetValue",
						"SetValues",
						"Refresh",
						"Clear",
						"AddItem",
						"RemoveItem",
						"GetInstance",
						"SetText",
						"SetCallback",
						"Open",
						"Close",
						"Destroy",
					}

					for _, methodName in ipairs(forwardedMethods) do
						local method = Dropdown[methodName]

						option[methodName] = function(_, ...)
							return method(Dropdown, ...)
						end
					end

					--==========================================================
					-- INITIALIZATION
					--==========================================================

					Dropdown.Instance = selectedLabel
					Dropdown.Main = main
					Dropdown.Header = header
					Dropdown.Holder = holder
					Dropdown.Option = option
					Dropdown.OnChanged = changedEvent.Event

					if typeof(library.FontFace) == "Font" then
						header.FontFace = library.FontFace
						selectedLabel.FontFace = library.FontFace
					end

					Dropdown:Refresh(opts.Values or {}, opts.Default, true)
					refreshTheme()
					positionHolder()

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

			function tab:Open()
				if library.Tab == tab then return end
				selectedshadow.Enabled = true
				page.Visible = true
				library.Tab = tab

				for _, other in pairs(library.Tabs) do
					if other ~= tab then
						other:Close()
					end
				end
			end

			function tab:Close()
				selectedshadow.Enabled = false
				page.Visible = false

				if library.Tab == tab then
					library.Tab = nil
				end
			end

			page.Visible = false
			library.Tabs[name] = tab
			library.TabsCount = library.TabsCount + 1

			currentintab = normalmain
			normalmain.Visible = true

			if library.TabsCount == 1 then
				tab:Open()	
			end

			button.Activated:Connect(function()
				tab:Open()
			end)

			return tab
		end

		expandsize.Activated:Connect(function()
			expanded = not expanded

			if expanded then
				maincontainer2.Visible = true
			elseif not expanded then
				maincontainer2.Visible = false
			end
		end)

		return section
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

			library:Create("UICorner", {
				Parent = dragclone;
				CornerRadius = UDim.new(0, 11);
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
