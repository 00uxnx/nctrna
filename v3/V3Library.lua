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
screengui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
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

local function trackConnection(connection)
	table.insert(connections, connection)
	return connection
end

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
		};
		
		NametagUI = "Icon";
		nametag3dConnection = nil;
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
		
		if library.windowinstances.Dropdownbox then
			library.windowinstances.Dropdownbox:Close()
		end
		
		if library.windowinstances.LineGraphBox then
			library.windowinstances.LineGraphBox:Close()
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
    configuration = configuration or {}
    local window = {}

    -- Main window
    local mainWindow = library:Create("CanvasGroup", {
        Name = "MainWindow";
        Size = UDim2.fromOffset(786, 504);
        Position = (configuration.Center ~= false)
            and UDim2.new(0.5, 0, 0.5, 0)
            or UDim2.new(0.4246, 0, 0.296, 0);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Parent = screengui;
        Visible = library.visible;
    })

    library:Create("UICorner", {
        CornerRadius = UDim.new(0, 7);
        Parent = mainWindow;
    })

    -- ══════════════════════════════════════════════════════════
    -- SIDE BAR
    -- ══════════════════════════════════════════════════════════

    local side = library:Create("Frame", {
        Name = "Side";
        Size = UDim2.new(0.2008, 0, 1, 0);
        BackgroundColor3 = library.MainColor;
        BackgroundTransparency = 0.1;
        BorderSizePixel = 0;
        Parent = mainWindow;
    })

    -- Name section (logo / viewport)
    local nameFrame = library:Create("Frame", {
        Name = "Name";
        Size = UDim2.new(1, 0, 0.169, 0);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Parent = side;
    })

    -- Custom viewport (3D tag)
    local customViewport = library:Create("ViewportFrame", {
        Name = "Custom";
        Size = UDim2.new(1, 0, 1, 0);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Visible = (library.ExtraConfiguration.NametagUI == "3d");
        Parent = nameFrame;
    })

    if library.ExtraConfiguration.NametagUI == "3d" then
        local worldModel = Instance.new("WorldModel")
        worldModel.Parent = customViewport
        customViewport.CurrentCamera = Instance.new("Camera")
        customViewport.CurrentCamera.Parent = customViewport
    end

    -- Normal logo image
    local normalImg = library:Create("ImageLabel", {
        Name = "normal";
        AnchorPoint = Vector2.new(0.5, 0.5);
        Position = UDim2.new(0.5, 0, 0.5, 0);
        Size = UDim2.fromOffset(70, 70);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Image = "rbxassetid://115666653528030";
        ScaleType = Enum.ScaleType.Fit;
        Visible = (library.ExtraConfiguration.NametagUI ~= "3d");
		Parent = nameFrame;
		ImageColor3 = library.AccentColor
	}, {
		instancep = "ImageColor3";
		tinstance = library.AccentColor;
	})

    -- Gradient underline
    local nameLine = library:Create("Frame", {
        Position = UDim2.new(0, 0, 0.989, 0);
        Size = UDim2.new(1, 0, 0, 1);
        BackgroundColor3 = library.AccentColor;
        BorderSizePixel = 0;
        Parent = nameFrame;
    }, {
        instancep = "BackgroundColor3";
        tinstance = library.AccentColor;
    })

    library:Create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1);
            NumberSequenceKeypoint.new(0.5, 0);
            NumberSequenceKeypoint.new(1, 1);
        });
        Parent = nameLine;
    })

    -- Drag button
    local dragButton = library:Create("TextButton", {
        Name = "DragButton";
        Size = UDim2.fromOffset(181, 85);
        BackgroundTransparency = 1;
        Text = "";
        ZIndex = 2;
        Parent = side;
    })

    -- Tabs list
    local tabsHolder = library:Create("ScrollingFrame", {
        Name = "Tabs";
        Size = UDim2.new(1, 0, 0, 419);
        Position = UDim2.new(0, 0, 0.169, 0);
        BackgroundTransparency = 1;
        ScrollBarThickness = 0;
        AutomaticCanvasSize = Enum.AutomaticSize.Y;
        CanvasSize = UDim2.new(0, 0, 0, 0);
        ScrollingDirection = Enum.ScrollingDirection.Y;
        Parent = side;
    })

    library:Create("UIListLayout", {
        Padding = UDim.new(0, 20);
        HorizontalAlignment = Enum.HorizontalAlignment.Center;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = tabsHolder;
    })

    library:Create("UIPadding", {
        PaddingTop = UDim.new(0, 5);
        PaddingBottom = UDim.new(0, 5);
        Parent = tabsHolder;
    })

    -- ══════════════════════════════════════════════════════════
    -- HOLDER (content area)
    -- ══════════════════════════════════════════════════════════

    local holder = library:Create("Frame", {
        Name = "Holder";
        Size = UDim2.new(0.7992, 0, 1, 0);
        Position = UDim2.new(0.2008, 0, 0, 0);
        BackgroundColor3 = library.MainColor;
        BorderSizePixel = 0;
        Parent = mainWindow;
    }, {
        instancep = "BackgroundColor3";
        tinstance = library.MainColor;
    })

    local general = library:Create("Frame", {
        Name = "General";
        Size = UDim2.new(1, 0, 1, 0);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Parent = holder;
    })

    local intabsFrame = library:Create("Frame", {
        Name = "intabs";
        Size = UDim2.new(1, 0, 1, 0);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Parent = general;
    })

    -- Vertical divider
    library:Create("Frame", {
        Size = UDim2.new(0, 1, 1, 0);
        Position = UDim2.new(0.2008, 0, 0, 0);
        BackgroundColor3 = library.SecondaryColor;
        BorderSizePixel = 0;
        ZIndex = 2;
        Parent = mainWindow;
    }, {
        instancep = "BackgroundColor3";
        tinstance = library.SecondaryColor;
    })

    -- ══════════════════════════════════════════════════════════
    -- DRAG LOGIC
    -- ══════════════════════════════════════════════════════════

    local dragging = false
    local dragStart
    local startPos

    trackConnection(dragButton.InputBegan:Connect(function(input)
        if configuration.Draggable == false then return end
        if dragging then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPos = mainWindow.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end))

    trackConnection(InputService.InputChanged:Connect(function(input)
        if dragging
            and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainWindow.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end))

    -- ══════════════════════════════════════════════════════════
    -- GROUPBOX FACTORY (kept from original)
	-- ══════════════════════════════════════════════════════════
	local function MakeAPI(holderForAPI)
		local groupbox = { elements = {} }
		local elementsholder = holderForAPI

		---------------------------------------------------------------
		-- Tooltip system
		---------------------------------------------------------------
		local function attachTooltip(target, text)
			if not text or text == "" then return end

			local tooltip
			local hovering = false
			local hoverToken
			local moveConn

			local function buildTooltip()
				if tooltip and tooltip.Parent then return end

				tooltip = library:Create("Frame", {
					Name = "Tooltip";
					Size = UDim2.new(0, 0, 0, 22);
					AutomaticSize = Enum.AutomaticSize.X;
					BackgroundColor3 = library.MainColor;
					BackgroundTransparency = 1;
					BorderSizePixel = 0;
					Visible = true;
					ZIndex = 9999;
					Parent = screengui;
				}, {
					instancep = "BackgroundColor3";
					tinstance = library.MainColor;
				})

				library:Create("UICorner", {
					CornerRadius = UDim.new(0, 4);
					Parent = tooltip;
				})

				local stroke = library:Create("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
					Color = library.SecondaryColor;
					Thickness = 1;
					Parent = tooltip;
				}, {
					instancep = "Color";
					tinstance = library.SecondaryColor;
				})

				library:Create("UIPadding", {
					PaddingLeft = UDim.new(0, 6);
					PaddingRight = UDim.new(0, 6);
					Parent = tooltip;
				})

				local lbl = library:Create("TextLabel", {
					Name = "Text";
					Size = UDim2.new(0, 0, 1, 0);
					AutomaticSize = Enum.AutomaticSize.X;
					BackgroundTransparency = 1;
					Text = text;
					TextColor3 = library.FontColor;
					Font = library.Font;
					TextSize = 12;
					ZIndex = 10000;
					TextTransparency = 1;
					Parent = tooltip;
				}, {
					instancep = "TextColor3";
					tinstance = library.FontColor;
				}, {
					instancep = "Font";
					tinstance = library.Font;
				})

				TweenService:Create(tooltip, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0;
				}):Play()
				TweenService:Create(lbl, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextTransparency = 0;
				}):Play()
			end

			local function killTooltip()
				if not tooltip or not tooltip.Parent then return end
				local frame = tooltip
				tooltip = nil

				local lbl = frame:FindFirstChild("Text")
				TweenService:Create(frame, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
				if lbl then
					TweenService:Create(lbl, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
				end
				task.delay(0.2, function()
					if frame and frame.Parent then frame:Destroy() end
				end)
			end

			moveConn = trackConnection(InputService.InputChanged:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseMovement
					and input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end

				local pos = input.Position
				local absPos = target.AbsolutePosition
				local absSize = target.AbsoluteSize
				local inside = pos.X >= absPos.X and pos.X <= absPos.X + absSize.X
					and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y

				if inside and not hovering then
					hovering = true
					local token = {}
					hoverToken = token
					task.delay(1.2, function()
						if hoverToken ~= token then return end
						if not hovering then return end
						if not target.Parent then return end
						buildTooltip()
						if tooltip then
							tooltip.Position = UDim2.fromOffset(pos.X + 12, pos.Y + 16)
						end
					end)
				elseif not inside and hovering then
					hovering = false
					hoverToken = nil
					killTooltip()
				elseif inside and tooltip then
					tooltip.Position = UDim2.fromOffset(pos.X + 12, pos.Y + 16)
				end
			end))

			target.Destroying:Connect(function()
				hovering = false
				hoverToken = nil
				if moveConn then
					moveConn:Disconnect()
					moveConn = nil
				end
				if tooltip and tooltip.Parent then
					tooltip:Destroy()
					tooltip = nil
				end
			end)
		end

		---------------------------------------------------------------
		-- AddLabel (+ AddColorPicker, + AddKeyPicker)
		---------------------------------------------------------------
		function groupbox:AddLabel(text, opts)
			opts = opts or {}

			local label = {}
			local colorpickers = {}
			local keypicker = nil

			local RestrictedKeypicker = false
			local RestrictedColorpicker = false

			local holder = library:Create("Frame", {
				Name = "Holder";
				Size = UDim2.new(0.95, 0, 0, 20);
				BackgroundTransparency = 1;
				LayoutOrder = #elementsholder:GetChildren();
				Parent = elementsholder;
			})

			local uitext = library:Create("TextLabel", {
				Name = "TextLabel";
				Size = UDim2.new(0.795, 0, 1, 0);
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

			library:Create("UITextSizeConstraint", {
				Name = "UITextSizeConstraint";
				MaxTextSize = 13;
				Parent = uitext;
			})

			library:Create("UIStroke", {
				Name = "UIStroke";
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
				Color = Color3.fromRGB(0, 0, 0);
				Thickness = 1;
				Parent = uitext;
			}, {
				instancep = "Color";
				tinstance = library.UIstroke;
			})

			library:Create("UIListLayout", {
				Name = "UIListLayout";
				FillDirection = Enum.FillDirection.Horizontal;
				HorizontalAlignment = Enum.HorizontalAlignment.Left;
				SortOrder = Enum.SortOrder.LayoutOrder;
				Parent = holder;
			})

			local holder2 = library:Create("Frame", {
				Name = "Holder";
				Size = UDim2.new(0.043, 50, 1, 0);
				BackgroundTransparency = 1;
				LayoutOrder = 2;
				Parent = holder;
			})

			library:Create("UIListLayout", {
				Name = "UIListLayout";
				FillDirection = Enum.FillDirection.Horizontal;
				HorizontalAlignment = Enum.HorizontalAlignment.Right;
				VerticalAlignment = Enum.VerticalAlignment.Center;
				SortOrder = Enum.SortOrder.LayoutOrder;
				Padding = UDim.new(0, 6);
				Parent = holder2;
			})

			function label:AddColorPicker(name, opts)
				opts = opts or {}

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
				library.Options = library.Options or Options
				library.Options[name] = colorpicker
				local opened = false
				local instance
				local followConn
				local outsideConn

				local colorbox = library:Create("Frame", {
					Name = "ColorBox";
					Size = UDim2.new(0, 15, 0, 15);
					BackgroundColor3 = color;
					LayoutOrder = #holder2:GetChildren();
					Parent = holder2;
				})

				library:Create("UIStroke", {
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
					Size = UDim2.new(1, 0, 1, 0);
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
					if opts.Callback then opts.Callback(newcolor, newtransparency) end
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
						Size = UDim2.new(0, 15, 0, 15);
						Position = getPos();
						BackgroundColor3 = Color3.new(1, 1, 1);
						BackgroundTransparency = 1;
						ZIndex = 2;
						Parent = screengui;
					})

					instance = cursorbox

					followConn = colorbox:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
						if instance then instance.Position = getPos() end
					end)

					local framewindow = library:Create("Frame", {
						Name = "Frame";
						Size = UDim2.new(0, 323, 0, 198);
						Position = UDim2.new(1, 0, 1.4, 0);
						BackgroundColor3 = library.MainColor;
						ZIndex = 2;
						Parent = cursorbox;
					}, {
						instancep = "BackgroundColor3";
						tinstance = library.MainColor;
					})

					library:Create("UIStroke", {
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

					library:Create("UIStroke", {
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

					local textlabel = library:Create("TextLabel", {
						Name = "TextLabel";
						Size = UDim2.new(1, 0, 0, 16);
						Position = UDim2.new(0, 0, 0, 0);
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

					library:Create("UIStroke", {
						Name = "UIStroke";
						ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
						Color = library.UIstroke;
						Thickness = 1;
						Parent = textlabel;
					}, {
						instancep = "Color";
						tinstance = library.UIstroke;
					})

					library:Create("UITextSizeConstraint", {
						Name = "UISizeConstraint";
						MaxTextSize = 13;
						Parent = textlabel;
					})

					local colors = library:Create("Frame", {
						Name = "Colors";
						Size = UDim2.new(1, 0, 0, 23);
						Position = UDim2.new(0, 0, 0.879, 0);
						BackgroundTransparency = 1;
						ZIndex = 2;
						Parent = framewindow;
					})

					library:Create("UIListLayout", {
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
						Size = UDim2.new(0, 20, 0, 20);
						BackgroundColor3 = color;
						ZIndex = 2;
						LayoutOrder = 1;
						Parent = colors;
					}, {
						instancep = "BackgroundColor3";
						tinstance = color;
					})

					library:Create("UIStroke", {
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
						Size = UDim2.new(0, 71, 0, 20);
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

					library:Create("UIStroke", {
						Name = "UIStroke";
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
						Color = library.SecondaryColor;
						Thickness = 1;
						Parent = huecoloreditbox;
					}, {
						instancep = "Color";
						tinstance = library.SecondaryColor;
					})

					library:Create("UIStroke", {
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
						Size = UDim2.new(0, 71, 0, 20);
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

					library:Create("UIStroke", {
						Name = "UIStroke";
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
						Color = library.SecondaryColor;
						Thickness = 1;
						Parent = transditbox;
					}, {
						instancep = "Color";
						tinstance = library.SecondaryColor;
					})

					library:Create("UIStroke", {
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
						Name = "hex";
						Size = UDim2.new(0, 71, 0, 20);
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

					library:Create("UIStroke", {
						Name = "UIStroke";
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
						Color = library.SecondaryColor;
						Thickness = 1;
						Parent = hexditbox;
					}, {
						instancep = "Color";
						tinstance = library.SecondaryColor;
					})

					library:Create("UIStroke", {
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
						Size = UDim2.new(1, 0, 0, 158);
						Position = UDim2.new(0, 0, 0.081, 0);
						BackgroundTransparency = 1;
						ZIndex = 2;
						Parent = framewindow;
					})

					library:Create("UIListLayout", {
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
						Size = UDim2.new(0.576, 50, 0.94, 0);
						BackgroundColor3 = Color3.fromHSV(h, 1, 1);
						ZIndex = 2;
						Parent = main;
					})

					local helight = library:Create("Frame", {
						Name = "HueBox2";
						Size = UDim2.new(1, 0, 1, 0);
						BackgroundColor3 = Color3.new(1, 1, 1);
						ZIndex = 3;
						Parent = huebox;
					})

					library:Create("UIGradient", {
						Name = "grad";
						Parent = helight;
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(1, 1),
						})
					})

					local huedark = library:Create("Frame", {
						Name = "HueBox3";
						Size = UDim2.new(1, 0, 1, 0);
						BackgroundColor3 = Color3.new(0, 0, 0);
						ZIndex = 3;
						Parent = huebox;
					})

					library:Create("UIGradient", {
						Name = "grad";
						Parent = huedark;
						Rotation = 90;
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 0),
						})
					})

					local shiftbox = library:Create("Frame", {
						Name = "shiftbox";
						Size = UDim2.new(-0.057, 50, 0.94, 0);
						BackgroundColor3 = Color3.new(1, 1, 1);
						ZIndex = 2;
						LayoutOrder = 2;
						Parent = main;
					})

					local rainbow = {}
					for i = 0, 6 do
						table.insert(rainbow, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
					end

					library:Create("UIGradient", {
						Name = "grad";
						Rotation = 90;
						Color = ColorSequence.new(rainbow);
						Parent = shiftbox;
					})

					local transparencybox = library:Create("Frame", {
						Name = "TransparencyBox";
						Size = UDim2.new(-0.057, 50, 0.94, 0);
						BackgroundColor3 = Color3.new(1, 1, 1);
						ZIndex = 2;
						LayoutOrder = 3;
						Parent = main;
					})

					library:Create("ImageLabel", {
						Name = "ImageLabel";
						Size = UDim2.new(1, 0, 1, 0);
						BackgroundColor3 = Color3.new(1, 1, 1);
						Parent = transparencybox;
						Image = "rbxassetid://155451930";
						ScaleType = Enum.ScaleType.Tile;
						TileSize = UDim2.new(1, 0, 0.3, 0);
					})

					local transfade = library:Create("Frame", {
						Name = "Fade";
						Size = UDim2.new(1, 0, 1, 0);
						BackgroundColor3 = color;
						ZIndex = 3;
						Parent = transparencybox;
					})

					library:Create("UIGradient", {
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
							Size = UDim2.new(1, 4, 0, 3);
							AnchorPoint = Vector2.new(0.5, 0.5);
							Position = UDim2.new(0.5, 0, start, 0);
							BackgroundColor3 = Color3.new(1, 1, 1);
							ZIndex = 5;
							Parent = box;
						})

						library:Create("UIStroke", {
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
							bar.Position = UDim2.new(0.5, 0, a, 0)
							onChange(a)
						end

						trackConnection(box.InputBegan:Connect(function(input)
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
						end))

						return function(a)
							bar.Position = UDim2.new(0.5, 0, a, 0)
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
						Size = UDim2.new(0, 8, 0, 8);
						AnchorPoint = Vector2.new(0.5, 0.5);
						Position = UDim2.new(s, 0, 1 - v, 0);
						BackgroundColor3 = Color3.new(1, 1, 1);
						ZIndex = 6;
						Parent = huebox;
					})

					library:Create("UICorner", {
						CornerRadius = UDim.new(1, 0);
						Parent = cursor;
					})

					library:Create("UIStroke", {
						Name = "UIStroke";
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
						Color = Color3.new(0, 0, 0);
						Thickness = 1;
						Parent = cursor;
					})

					local function setCursor(ns, nv)
						cursor.Position = UDim2.new(ns, 0, 1 - nv, 0)
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

						trackConnection(huedark.InputBegan:Connect(function(input)
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
						end))
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

					outsideConn = trackConnection(InputService.InputBegan:Connect(function(input)
						if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
							return
						end
						local function isInside(gui)
							local pos, size = gui.AbsolutePosition, gui.AbsoluteSize
							local m = input.Position
							return m.X >= pos.X and m.X <= pos.X + size.X and m.Y >= pos.Y and m.Y <= pos.Y + size.Y
						end
						if isInside(framewindow) or isInside(colorbox) then return end
						colorpicker:Close()
					end))
				end

				function colorpicker:Close()
					if not opened then return end
					opened = false
					if followConn then followConn:Disconnect() followConn = nil end
					if outsideConn then outsideConn:Disconnect() outsideConn = nil end
					if instance then instance:Destroy() instance = nil end
				end

				hitbox.Activated:Connect(function()
					if opened then colorpicker:Close() else Createcolorpickerbox() end
				end)

				function colorpicker:AddColorPicker(n, o)
					return label:AddColorPicker(n, o)
				end

				function colorpicker:GetValue()
					return { Color = color, Transparency = transparency }
				end

				function colorpicker:SetValue(value, newTransparency)
					local newColor = value
					if type(value) == "table" then
						newColor = value.Color or value[1]
						if value.Transparency ~= nil then newTransparency = value.Transparency
						elseif value[2] ~= nil then newTransparency = value[2] end
					end
					if type(newColor) == "string" then
						newColor = Color3.fromHex(newColor:gsub("^#", ""))
					elseif type(newColor) == "table" then
						newColor = Color3.new(
							newColor.R or newColor.r or newColor[1],
							newColor.G or newColor.g or newColor[2],
							newColor.B or newColor.b or newColor[3]
						)
					end
					assert(typeof(newColor) == "Color3", "Invalid color")
					local nextTransparency = transparency
					if newTransparency ~= nil then
						assert(tonumber(newTransparency), "Invalid transparency")
						nextTransparency = math.clamp(tonumber(newTransparency), 0, 1)
					end
					local changed = newColor ~= color or nextTransparency ~= transparency
					local reopen = opened
					if reopen then self:Close() end
					color, transparency = newColor, nextTransparency
					colorbox.BackgroundColor3 = color
					self.Color, self.Transparency = color, transparency
					if reopen then Createcolorpickerbox() end
					if changed then OnChange(color, transparency) end
					return self
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
					if typeof(k) == "EnumItem" then return k end
					if type(k) == "string" then
						local ok, res = pcall(function() return Enum.KeyCode[k] end)
						if ok then return res end
					end
					return nil
				end

				local currentkey = resolvekey(opts.Default)
				local Mode = opts.Mode or "Hold"
				local modes = { "Hold", "Toggle", "Always" }

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
					if k then ignoredset[k] = true end
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
				library.Options = library.Options or Options
				library.Options[name] = picker

				local keyframe = library:Create("Frame", {
					Name = "KeyPicker";
					Size = UDim2.new(0, 50, 0, 15);
					LayoutOrder = #holder2:GetChildren();
					BackgroundColor3 = library.MainColor;
					Parent = holder2;
				}, {
					instancep = "BackgroundColor3";
					tinstance = library.MainColor;
				})

				library:Create("UIStroke", {
					Name = "UIStroke";
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
					Color = library.SecondaryColor;
					Thickness = 1;
					Parent = keyframe;
				}, {
					instancep = "Color";
					tinstance = library.SecondaryColor;
				})

				local keybox = library:Create("TextButton", {
					Name = "KeyBox";
					Size = UDim2.new(1, 0, 1, 0);
					BackgroundTransparency = 1;
					Text = "";
					ZIndex = 4;
					Parent = keyframe;
				})

				local keytext = library:Create("TextLabel", {
					Name = "KeyText";
					Size = UDim2.new(1, 0, 1, 0);
					BackgroundTransparency = 1;
					Text = "None";
					TextColor3 = library.FontColor;
					TextSize = 13;
					Font = library.Font;
					TextXAlignment = Enum.TextXAlignment.Center;
					Parent = keyframe;
				}, {
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
					if opts.Callback then opts.Callback(state) end
				end

				local function updatetexts()
					local t
					if waiting_for_key then t = "..."
					elseif currentkey then t = keyshorts[currentkey] or currentkey.Name
					else t = "None" end
					keytext.Text = t
					if winkeytext then winkeytext.Text = t end
					if winmodetext then winmodetext.Text = Mode end
				end

				local function setKey(k)
					currentkey = k
					picker.Key = k
					updatetexts()
					if opts.CallbackKey then opts.CallbackKey(k) end
					picker.OnChanged:Fire(currentkey, Mode)
				end

				local function setMode(m)
					Mode = m
					picker.Mode = m
					updatetexts()
					setState(m == "Always")
					if opts.CallbackMode then opts.CallbackMode(m) end
					picker.OnChanged:Fire(currentkey, Mode)
				end

				function picker:GetValue()
					return { Key = currentkey and currentkey.Name or "None", Mode = Mode }
				end

				function picker:SetValue(value, mode)
					local key = value
					if type(value) == "table" then
						key = value.Key or value[1]
						mode = value.Mode or value[2] or mode
					end
					if mode ~= nil then assert(table.find(modes, mode), "Invalid key picker mode") end
					local resolved = resolvekey(key)
					assert(resolved or key == nil or key == "None" or key == "", "Invalid key")
					setKey(resolved)
					if mode ~= nil then setMode(mode) end
					return self
				end

				local function startbind()
					if waiting_for_key then return end
					waiting_for_key = true
					updatetexts()
					waitkeyconn = trackConnection(InputService.InputBegan:Connect(function(input)
						if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
						if ignoredset[input.KeyCode] then return end
						if waitkeyconn then waitkeyconn:Disconnect() waitkeyconn = nil end
						task.defer(function()
							waiting_for_key = false
							updatetexts()
						end)
						if input.KeyCode == Enum.KeyCode.Backspace then
							setKey(nil)
						else
							setKey(input.KeyCode)
						end
					end))
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
						Size = UDim2.new(0, 15, 0, 15);
						Position = getPos();
						BackgroundColor3 = Color3.new(1, 1, 1);
						BackgroundTransparency = 1;
						ZIndex = 2;
						Parent = screengui;
					})

					instance = cursorbox

					followConn = keyframe:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
						if instance then instance.Position = getPos() end
					end)

					local framewindow = library:Create("Frame", {
						Name = "Frame";
						Size = UDim2.new(0, 323, 0, 93);
						Position = UDim2.new(1, 0, 1.4, 0);
						BackgroundColor3 = library.MainColor;
						ZIndex = 2;
						Parent = cursorbox;
					}, {
						instancep = "BackgroundColor3";
						tinstance = library.MainColor;
					})

					library:Create("UIStroke", {
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

					library:Create("UIStroke", {
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

					local textlabel = library:Create("TextLabel", {
						Name = "TextLabel";
						Size = UDim2.new(1, 0, 0, 16);
						Position = UDim2.new(0, 0, 0, 0);
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

					library:Create("UIStroke", {
						Name = "UIStroke";
						ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
						Color = library.UIstroke;
						Thickness = 1;
						Parent = textlabel;
					}, {
						instancep = "Color";
						tinstance = library.UIstroke;
					})

					library:Create("UITextSizeConstraint", {
						Name = "UISizeConstraint";
						MaxTextSize = 13;
						Parent = textlabel;
					})

					local holder = library:Create("Frame", {
						Name = "Holder";
						Size = UDim2.new(1, 0, -0.228, 96);
						Position = UDim2.new(0, 0, 0.195, 0);
						BackgroundTransparency = 1;
						ZIndex = 2;
						Parent = framewindow;
					})

					library:Create("UIListLayout", {
						Name = "UIListLayout";
						Padding = UDim.new(0, 5);
						SortOrder = Enum.SortOrder.LayoutOrder;
						FillDirection = Enum.FillDirection.Vertical;
						HorizontalAlignment = Enum.HorizontalAlignment.Center;
						VerticalAlignment = Enum.VerticalAlignment.Top;
						Parent = holder;
					})

					library:Create("UIPadding", {
						Name = "UIPadding";
						PaddingTop = UDim.new(0, 3);
						Parent = holder;
					})

					local keysetbind = library:Create("Frame", {
						Name = "KeysetBind";
						Size = UDim2.new(0.95, 0, 0, 20);
						BackgroundTransparency = 1;
						LayoutOrder = 1;
						ZIndex = 2;
						Parent = holder;
					})

					library:Create("UIListLayout", {
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
						Size = UDim2.new(1, -55, 1, 0);
						BackgroundTransparency = 1;
						Text = "Keybind";
						TextColor3 = library.FontColor;
						TextSize = 13;
						TextXAlignment = Enum.TextXAlignment.Left;
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

					library:Create("UIStroke", {
						Name = "UIStroke";
						ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
						Color = library.UIstroke;
						Thickness = 1;
						Parent = keylabelset;
					}, {
						instancep = "Color";
						tinstance = library.UIstroke;
					})

					local winkeyframe = library:Create("Frame", {
						Name = "KeyPicker";
						Size = UDim2.new(0, 50, 0, 15);
						LayoutOrder = 2;
						BackgroundColor3 = library.MainColor;
						ZIndex = 2;
						Parent = keysetbind;
					}, {
						instancep = "BackgroundColor3";
						tinstance = library.MainColor;
					})

					library:Create("UIStroke", {
						Name = "UIStroke";
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
						Color = library.SecondaryColor;
						Thickness = 1;
						Parent = winkeyframe;
					}, {
						instancep = "Color";
						tinstance = library.SecondaryColor;
					})

					local winkeybox = library:Create("TextButton", {
						Name = "KeyBox";
						Size = UDim2.new(1, 0, 1, 0);
						BackgroundTransparency = 1;
						Text = "";
						ZIndex = 3;
						Parent = winkeyframe;
					})

					winkeytext = library:Create("TextLabel", {
						Name = "KeyText";
						Size = UDim2.new(1, 0, 1, 0);
						BackgroundTransparency = 1;
						Text = "None";
						TextColor3 = library.FontColor;
						TextSize = 13;
						Font = library.Font;
						TextXAlignment = Enum.TextXAlignment.Center;
						ZIndex = 2;
						Parent = winkeyframe;
					}, {
						instancep = "TextColor3";
						tinstance = library.FontColor;
					}, {
						instancep = "Font";
						tinstance = library.Font;
					})

					local modesetbind = library:Create("Frame", {
						Name = "ModesetBind";
						Size = UDim2.new(0.95, 0, 0, 20);
						BackgroundTransparency = 1;
						LayoutOrder = 2;
						ZIndex = 2;
						Parent = holder;
					})

					library:Create("UIListLayout", {
						Name = "UIListLayout";
						SortOrder = Enum.SortOrder.LayoutOrder;
						FillDirection = Enum.FillDirection.Horizontal;
						HorizontalAlignment = Enum.HorizontalAlignment.Left;
						VerticalAlignment = Enum.VerticalAlignment.Center;
						Parent = modesetbind;
					})

					local modelabelset = library:Create("TextLabel", {
						Name = "ModeLabel";
						Size = UDim2.new(1, -55, 1, 0);
						BackgroundTransparency = 1;
						Text = "Mode";
						TextColor3 = library.FontColor;
						TextSize = 13;
						TextXAlignment = Enum.TextXAlignment.Left;
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

					local modeframe = library:Create("Frame", {
						Name = "ModePicker";
						Size = UDim2.new(0, 50, 0, 15);
						LayoutOrder = 2;
						BackgroundColor3 = library.MainColor;
						ZIndex = 2;
						Parent = modesetbind;
					}, {
						instancep = "BackgroundColor3";
						tinstance = library.MainColor;
					})

					library:Create("UIStroke", {
						Name = "UIStroke";
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
						Color = library.SecondaryColor;
						Thickness = 1;
						Parent = modeframe;
					}, {
						instancep = "Color";
						tinstance = library.SecondaryColor;
					})

					local Modebox = library:Create("TextButton", {
						Name = "ModeBox";
						Size = UDim2.new(1, 0, 1, 0);
						BackgroundTransparency = 1;
						Text = "";
						ZIndex = 3;
						Parent = modeframe;
					})

					winmodetext = library:Create("TextLabel", {
						Name = "ModeText";
						Size = UDim2.new(1, 0, 1, 0);
						BackgroundTransparency = 1;
						Text = Mode;
						TextColor3 = library.FontColor;
						TextSize = 13;
						Font = library.Font;
						TextXAlignment = Enum.TextXAlignment.Center;
						ZIndex = 2;
						Parent = modeframe;
					}, {
						instancep = "TextColor3";
						tinstance = library.FontColor;
					}, {
						instancep = "Font";
						tinstance = library.Font;
					})

					local unbindbox = library:Create("Frame", {
						Name = "UnbindBox";
						Size = UDim2.new(0.95, 0, 0, 15);
						LayoutOrder = 3;
						BackgroundColor3 = library.MainColor;
						ZIndex = 2;
						Parent = holder;
					}, {
						instancep = "BackgroundColor3";
						tinstance = library.MainColor;
					})

					library:Create("UIStroke", {
						Name = "UIStroke";
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
						Color = library.SecondaryColor;
						Thickness = 1;
						Parent = unbindbox;
					}, {
						instancep = "Color";
						tinstance = library.SecondaryColor;
					})

					local unbindtext = library:Create("TextLabel", {
						Name = "UnbindText";
						Size = UDim2.new(1, 0, 1, 0);
						BackgroundTransparency = 1;
						Text = "Unbind";
						TextColor3 = library.FontColor;
						TextSize = 13;
						Font = library.Font;
						TextXAlignment = Enum.TextXAlignment.Center;
						ZIndex = 2;
						Parent = unbindbox;
					}, {
						instancep = "TextColor3";
						tinstance = library.FontColor;
					}, {
						instancep = "Font";
						tinstance = library.Font;
					})

					local unbindboxt = library:Create("TextButton", {
						Name = "UnbindBoxText";
						Size = UDim2.new(1, 0, 1, 0);
						BackgroundTransparency = 1;
						Text = "";
						ZIndex = 3;
						Parent = unbindbox;
					})

					winkeybox.MouseButton1Click:Connect(startbind)
					Modebox.MouseButton1Click:Connect(function()
						local index = table.find(modes, Mode) or 1
						setMode(modes[index % #modes + 1])
					end)
					unbindboxt.MouseButton1Click:Connect(function() setKey(nil) end)

					updatetexts()

					outsideConn = trackConnection(InputService.InputBegan:Connect(function(input)
						if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
							return
						end
						local function isInside(gui)
							local pos, size = gui.AbsolutePosition, gui.AbsoluteSize
							local m = input.Position
							return m.X >= pos.X and m.X <= pos.X + size.X and m.Y >= pos.Y and m.Y <= pos.Y + size.Y
						end
						if isInside(framewindow) or isInside(keyframe) then return end
						picker:Close()
					end))
				end

				function picker:Close()
					if not opened then return end
					opened = false
					winkeytext = nil
					winmodetext = nil
					if followConn then followConn:Disconnect() followConn = nil end
					if outsideConn then outsideConn:Disconnect() outsideConn = nil end
					if instance then instance:Destroy() instance = nil end
				end

				keybox.MouseButton1Click:Connect(startbind)
				keybox.MouseButton2Click:Connect(function()
					if opened then picker:Close() else openminiwindow() end
				end)

				trackConnection(InputService.InputBegan:Connect(function(input)
					if waiting_for_key then return end
					if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
					if not currentkey or input.KeyCode ~= currentkey then return end
					if Mode == "Toggle" then
						setState(not active)
					elseif Mode == "Hold" then
						setState(true)
					end
				end))

				trackConnection(InputService.InputEnded:Connect(function(input)
					if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
					if not currentkey or input.KeyCode ~= currentkey then return end
					if Mode == "Hold" then setState(false) end
				end))

				updatetexts()
				if Mode == "Always" then setState(true) end

				library.windowinstances.Keybindbox = picker
				return picker
			end

			if opts.Tooltip then attachTooltip(holder, opts.Tooltip) end
			return label
		end

		---------------------------------------------------------------
		-- AddToggle (with keypicker + tooltip)
		---------------------------------------------------------------
		function groupbox:AddToggle(name, opts)
			opts = opts or {}

			local toggle = {}
			local togglename = name
			local toggled = opts.Default

			if toggled == nil then
				toggled = false
			end

			toggle.Value = toggled

			local holder = library:Create("Frame", {
				Name = "Holder";
				Size = UDim2.new(0.95, 0, 0, 20);
				BackgroundTransparency = 1;
				LayoutOrder = #elementsholder:GetChildren();
				Parent = elementsholder;
			})

			local hb = library:Create("TextButton", {
				Name = "Hitbox";
				Size = UDim2.fromScale(1, 1);
				BackgroundTransparency = 1;
				AutoButtonColor = false;
				ZIndex = 2;
				Text = "";
				Parent = holder;
			})

			local elements = library:Create("Frame", {
				Name = "Holder2";
				Size = UDim2.fromScale(1, 1);
				BackgroundTransparency = 1;
				Active = false;
				ZIndex = 3;
				Parent = holder;
			})

			library:Create("UIListLayout", {
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
				Size = UDim2.fromOffset(15, 15);
				BackgroundColor3 = library.AccentColor;
				BackgroundTransparency = toggled and 0 or 1;
				BorderSizePixel = 0;
				LayoutOrder = 1;
				Active = false;
				ZIndex = 3;
				Parent = elements;
			}, {
				instancep = "BackgroundColor3";
				tinstance = library.AccentColor;
			})

			library:Create("UIStroke", {
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
				Size = UDim2.new(1, -15, 1, 0);
				BackgroundTransparency = 1;
				Text = opts.Text or name;
				TextColor3 = library.FontColor;
				Font = library.Font;
				TextSize = 13;
				TextXAlignment = Enum.TextXAlignment.Left;
				TextYAlignment = Enum.TextYAlignment.Center;
				LayoutOrder = 2;
				Active = false;
				ZIndex = 3;
				Parent = elements;
			}, {
				instancep = "TextColor3";
				tinstance = library.FontColor;
			}, {
				instancep = "Font";
				tinstance = library.Font;
			})

			library:Create("UIPadding", {
				Name = "UIPadding";
				PaddingLeft = UDim.new(0, 7);
				Parent = label;
			})

			library:Create("UIStroke", {
				Name = "UIStroke";
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
				Color = library.UIstroke;
				Thickness = 1;
				Parent = label;
			}, {
				instancep = "Color";
				tinstance = library.UIstroke;
			})

			library:Create("UITextSizeConstraint", {
				Name = "UITextSizeConstraint";
				MaxTextSize = 13;
				Parent = label;
			})

			toggle.OnChanged = newSignal()

			function toggle:GetValue()
				return toggled
			end

			function toggle:SetValue(value, silent)
				assert(
					type(value) == "boolean",
					"Toggle:SetValue expects a boolean"
				)

				local changed = toggled ~= value

				toggled = value
				toggle.Value = value
				boxelem.BackgroundTransparency = value and 0 or 1

				if Toggles[togglename] then
					Toggles[togglename].value = value
					Toggles[togglename].Value = value
				end

				if changed and not silent then
					if opts.Callback then
						opts.Callback(value)
					end

					toggle.OnChanged:Fire(value)
				end

				if library.UpdateDependencyBoxes then
					library:UpdateDependencyBoxes()
				end

				return self
			end

			local function togglef()
				toggle:SetValue(not toggled)
			end

			hb.MouseButton1Click:Connect(togglef)

			Toggles[togglename] = {
				value = toggled;
				Value = toggled;
				keypicker = nil;
				OnChanged = toggle.OnChanged;
			}

			Toggles[togglename].SetValue = function(_, ...)
				return toggle:SetValue(...)
			end

			Toggles[togglename].GetValue = function()
				return toggle:GetValue()
			end

			library.Toggles = library.Toggles or Toggles

			function toggle:AddKeyPicker(name, opts)
				if type(name) == "table" then
					opts = name
					name = togglename
				end

				name = name or togglename
				opts = opts or {}

				if Toggles[togglename].keypicker then
					warn("KeyPicker already exists for toggle: " .. togglename)
					return
				end

				local keypicker = {}
				local InputService = game:GetService("UserInputService")
				local GuiService = game:GetService("GuiService")

				local function resolvekey(key)
					if typeof(key) == "EnumItem" then
						if key.EnumType == Enum.KeyCode then
							return key
						end

						return nil
					end

					if type(key) == "string" then
						local ok, result = pcall(function()
							return Enum.KeyCode[key]
						end)

						if ok then
							return result
						end
					end

					return nil
				end

				local currentkey = resolvekey(opts.Default)
				local modes = { "Hold", "Toggle", "Always" }
				local Mode = opts.Mode or "Hold"

				assert(table.find(modes, Mode), "Invalid key picker mode")

				local opened = false
				local destroyed = false
				local instance
				local followConn
				local outsideConn
				local waitkeyconn
				local waiting_for_key = false
				local winkeytext
				local winmodetext
				local keyConnections = {}

				local function connect(signal, fn)
					local connection = trackConnection(signal:Connect(fn))
					table.insert(keyConnections, connection)
					return connection
				end

				local ignoredset = {
					[Enum.KeyCode.Return] = true;
					[Enum.KeyCode.End] = true;
					[Enum.KeyCode.Home] = true;
					[Enum.KeyCode.PageUp] = true;
					[Enum.KeyCode.PageDown] = true;
				}

				local menuKey = resolvekey(library.Menukey)

				if menuKey then
					ignoredset[menuKey] = true
				end

				Toggles[togglename].keypicker = keypicker

				keypicker.Key = currentkey
				keypicker.Mode = Mode
				keypicker.OnChanged = newSignal()

				Options[name] = keypicker
				library.Options = library.Options or Options
				library.Options[name] = keypicker
				library.windowinstances = library.windowinstances or {}

				-- Reserve 55px on the right for the key picker.
				hb.Size = UDim2.new(1, -55, 1, 0)

				-- 15px checkbox + flexible label + 5px gap + 50px key picker.
				label.Size = UDim2.new(1, -70, 1, 0)

				library:Create("Frame", {
					Name = "KeyPickerGap";
					Size = UDim2.new(0, 5, 1, 0);
					BackgroundTransparency = 1;
					LayoutOrder = 998;
					Active = false;
					ZIndex = 3;
					Parent = elements;
				})

				local keyframe = library:Create("Frame", {
					Name = "KeyPicker";
					Size = UDim2.fromOffset(50, 15);
					BackgroundColor3 = library.MainColor;
					BorderSizePixel = 0;
					LayoutOrder = 999;
					ZIndex = 5;
					Parent = elements;
				}, {
					instancep = "BackgroundColor3";
					tinstance = library.MainColor;
				})

				library:Create("UIStroke", {
					Name = "UIStroke";
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
					Color = library.SecondaryColor;
					Thickness = 1;
					Parent = keyframe;
				}, {
					instancep = "Color";
					tinstance = library.SecondaryColor;
				})

				local keytext = library:Create("TextLabel", {
					Name = "KeyText";
					Size = UDim2.fromScale(1, 1);
					BackgroundTransparency = 1;
					Text = "None";
					TextColor3 = library.FontColor;
					TextSize = 13;
					Font = library.Font;
					TextXAlignment = Enum.TextXAlignment.Center;
					Active = false;
					ZIndex = 6;
					Parent = keyframe;
				}, {
					instancep = "TextColor3";
					tinstance = library.FontColor;
				}, {
					instancep = "Font";
					tinstance = library.Font;
				})

				local keybox = library:Create("TextButton", {
					Name = "KeyBox";
					Size = UDim2.fromScale(1, 1);
					BackgroundTransparency = 1;
					Text = "";
					AutoButtonColor = false;
					Active = true;
					ZIndex = 7;
					Parent = keyframe;
				})

				local function setState(state)
					toggle:SetValue(state)
				end

				local function updatetexts()
					if destroyed then
						return
					end

					local text

					if waiting_for_key then
						text = "..."
					elseif currentkey then
						text = (keyshorts and keyshorts[currentkey])
							or currentkey.Name
					else
						text = "None"
					end

					keytext.Text = text

					if winkeytext then
						winkeytext.Text = text
					end

					if winmodetext then
						winmodetext.Text = Mode
					end
				end

				local function setKey(key)
					currentkey = key
					keypicker.Key = key
					updatetexts()

					if opts.CallbackKey then
						opts.CallbackKey(key)
					end

					keypicker.OnChanged:Fire(currentkey, Mode)
				end

				local function setMode(mode)
					Mode = mode
					keypicker.Mode = mode

					updatetexts()
					setState(mode == "Always")

					if opts.CallbackMode then
						opts.CallbackMode(mode)
					end

					keypicker.OnChanged:Fire(currentkey, Mode)
				end

				local function cancelbind()
					if waitkeyconn then
						waitkeyconn:Disconnect()
						waitkeyconn = nil
					end

					waiting_for_key = false
					updatetexts()
				end

				local function startbind()
					if destroyed or waiting_for_key then
						return
					end

					waiting_for_key = true
					updatetexts()

					waitkeyconn = trackConnection(
						InputService.InputBegan:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.Keyboard then
								return
							end

							if ignoredset[input.KeyCode] then
								return
							end

							if waitkeyconn then
								waitkeyconn:Disconnect()
								waitkeyconn = nil
							end

							if input.KeyCode == Enum.KeyCode.Backspace then
								setKey(nil)
							else
								setKey(input.KeyCode)
							end

							-- Keep the binding input from also activating the toggle.
							task.defer(function()
								if destroyed then
									return
								end

								waiting_for_key = false
								updatetexts()
							end)
						end)
					)
				end

				function keypicker:GetValue()
					return {
						Key = currentkey and currentkey.Name or "None";
						Mode = Mode;
					}
				end

				function keypicker:SetValue(value, mode)
					if destroyed then
						return self
					end

					local key = value

					if type(value) == "table" then
						key = value.Key or value[1]
						mode = value.Mode or value[2] or mode
					end

					if mode ~= nil then
						assert(table.find(modes, mode), "Invalid key picker mode")
					end

					local resolved = resolvekey(key)

					assert(
						resolved or key == nil or key == "None" or key == "",
						"Invalid key"
					)

					setKey(resolved)

					if mode ~= nil then
						setMode(mode)
					end

					return self
				end

				function keypicker:Close()
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

					if library.windowinstances.Keybindbox == self then
						library.windowinstances.Keybindbox = nil
					end

					return self
				end

				local function openminiwindow()
					if destroyed or opened then
						return
					end

					local previous = library.windowinstances.Keybindbox

					if previous and previous ~= keypicker
						and type(previous.Close) == "function" then
						previous:Close()
					end

					local dropdown = library.windowinstances.Dropdownbox

					if dropdown and type(dropdown.Close) == "function" then
						dropdown:Close()
					end

					opened = true
					library.windowinstances.Keybindbox = keypicker

					local function getPos()
						local absolute = keyframe.AbsolutePosition
						local base = screengui.AbsolutePosition

						return UDim2.fromOffset(
							absolute.X - base.X,
							absolute.Y - base.Y
						)
					end

					local cursorbox = library:Create("Frame", {
						Name = "CursorBox";
						Size = UDim2.fromOffset(15, 15);
						Position = getPos();
						BackgroundTransparency = 1;
						ZIndex = 30;
						Parent = screengui;
					})

					instance = cursorbox

					followConn = keyframe:GetPropertyChangedSignal(
						"AbsolutePosition"
					):Connect(function()
						if instance then
							instance.Position = getPos()
						end
					end)

					local framewindow = library:Create("Frame", {
						Name = "Frame";
						Size = UDim2.fromOffset(323, 93);
						Position = UDim2.new(1, 0, 1.4, 0);
						BackgroundColor3 = library.MainColor;
						BorderSizePixel = 0;
						ZIndex = 30;
						Parent = cursorbox;
					}, {
						instancep = "BackgroundColor3";
						tinstance = library.MainColor;
					})

					library:Create("UIStroke", {
						Name = "OuterStroke";
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
						Color = library.MainColor;
						Thickness = 4;
						Parent = framewindow;
					}, {
						instancep = "Color";
						tinstance = library.MainColor;
					})

					library:Create("UIStroke", {
						Name = "BorderStroke";
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
						Color = library.SecondaryColor;
						Thickness = 1;
						Parent = framewindow;
					}, {
						instancep = "Color";
						tinstance = library.SecondaryColor;
					})

					local textlabel = library:Create("TextLabel", {
						Name = "TextLabel";
						Size = UDim2.new(1, 0, 0, 16);
						Text = tostring(name);
						TextColor3 = library.FontColor;
						Font = library.Font;
						TextSize = 13;
						BackgroundTransparency = 1;
						ZIndex = 31;
						Parent = framewindow;
					}, {
						instancep = "TextColor3";
						tinstance = library.FontColor;
					}, {
						instancep = "Font";
						tinstance = library.Font;
					})

					library:Create("UIStroke", {
						Name = "UIStroke";
						ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
						Color = library.UIstroke;
						Thickness = 1;
						Parent = textlabel;
					}, {
						instancep = "Color";
						tinstance = library.UIstroke;
					})

					local windowHolder = library:Create("Frame", {
						Name = "Holder";
						Size = UDim2.new(1, 0, -0.228, 96);
						Position = UDim2.new(0, 0, 0.195, 0);
						BackgroundTransparency = 1;
						ZIndex = 31;
						Parent = framewindow;
					})

					library:Create("UIListLayout", {
						Padding = UDim.new(0, 5);
						SortOrder = Enum.SortOrder.LayoutOrder;
						FillDirection = Enum.FillDirection.Vertical;
						HorizontalAlignment = Enum.HorizontalAlignment.Center;
						Parent = windowHolder;
					})

					library:Create("UIPadding", {
						PaddingTop = UDim.new(0, 3);
						Parent = windowHolder;
					})

					local function createPickerRow(rowName, title, order)
						local row = library:Create("Frame", {
							Name = rowName;
							Size = UDim2.new(0.95, 0, 0, 20);
							BackgroundTransparency = 1;
							LayoutOrder = order;
							ZIndex = 31;
							Parent = windowHolder;
						})

						library:Create("UIListLayout", {
							SortOrder = Enum.SortOrder.LayoutOrder;
							FillDirection = Enum.FillDirection.Horizontal;
							VerticalAlignment = Enum.VerticalAlignment.Center;
							Parent = row;
						})

						library:Create("TextLabel", {
							Name = "Label";
							Size = UDim2.new(1, -55, 1, 0);
							BackgroundTransparency = 1;
							Text = title;
							TextColor3 = library.FontColor;
							TextSize = 13;
							TextXAlignment = Enum.TextXAlignment.Left;
							Font = library.Font;
							LayoutOrder = 1;
							ZIndex = 32;
							Parent = row;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local pickerFrame = library:Create("Frame", {
							Name = "Picker";
							Size = UDim2.fromOffset(50, 15);
							LayoutOrder = 2;
							BackgroundColor3 = library.MainColor;
							BorderSizePixel = 0;
							ZIndex = 32;
							Parent = row;
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						})

						library:Create("UIStroke", {
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							Color = library.SecondaryColor;
							Thickness = 1;
							Parent = pickerFrame;
						}, {
							instancep = "Color";
							tinstance = library.SecondaryColor;
						})

						local pickerText = library:Create("TextLabel", {
							Name = "Text";
							Size = UDim2.fromScale(1, 1);
							BackgroundTransparency = 1;
							Text = "";
							TextColor3 = library.FontColor;
							TextSize = 13;
							Font = library.Font;
							TextXAlignment = Enum.TextXAlignment.Center;
							Active = false;
							ZIndex = 33;
							Parent = pickerFrame;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						local pickerButton = library:Create("TextButton", {
							Name = "Hitbox";
							Size = UDim2.fromScale(1, 1);
							BackgroundTransparency = 1;
							Text = "";
							AutoButtonColor = false;
							ZIndex = 34;
							Parent = pickerFrame;
						})

						return pickerButton, pickerText
					end

					local winkeybox
					winkeybox, winkeytext = createPickerRow(
						"KeysetBind",
						"Keybind",
						1
					)

					local modebox
					modebox, winmodetext = createPickerRow(
						"ModesetBind",
						"Mode",
						2
					)

					local unbindbox = library:Create("Frame", {
						Name = "UnbindBox";
						Size = UDim2.new(0.95, 0, 0, 15);
						LayoutOrder = 3;
						BackgroundColor3 = library.MainColor;
						BorderSizePixel = 0;
						ZIndex = 32;
						Parent = windowHolder;
					}, {
						instancep = "BackgroundColor3";
						tinstance = library.MainColor;
					})

					library:Create("UIStroke", {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
						Color = library.SecondaryColor;
						Thickness = 1;
						Parent = unbindbox;
					}, {
						instancep = "Color";
						tinstance = library.SecondaryColor;
					})

					library:Create("TextLabel", {
						Name = "UnbindText";
						Size = UDim2.fromScale(1, 1);
						BackgroundTransparency = 1;
						Text = "Unbind";
						TextColor3 = library.FontColor;
						TextSize = 13;
						Font = library.Font;
						TextXAlignment = Enum.TextXAlignment.Center;
						Active = false;
						ZIndex = 33;
						Parent = unbindbox;
					}, {
						instancep = "TextColor3";
						tinstance = library.FontColor;
					}, {
						instancep = "Font";
						tinstance = library.Font;
					})

					local unbindbutton = library:Create("TextButton", {
						Name = "Hitbox";
						Size = UDim2.fromScale(1, 1);
						BackgroundTransparency = 1;
						Text = "";
						AutoButtonColor = false;
						ZIndex = 34;
						Parent = unbindbox;
					})

					winkeybox.MouseButton1Click:Connect(startbind)

					modebox.MouseButton1Click:Connect(function()
						local index = table.find(modes, Mode) or 1
						setMode(modes[index % #modes + 1])
					end)

					unbindbutton.MouseButton1Click:Connect(function()
						cancelbind()
						setKey(nil)
					end)

					updatetexts()

					outsideConn = trackConnection(
						InputService.InputBegan:Connect(function(input)
							if input.UserInputType
								~= Enum.UserInputType.MouseButton1
								and input.UserInputType
								~= Enum.UserInputType.MouseButton2
								and input.UserInputType
								~= Enum.UserInputType.Touch then
								return
							end

							local point = Vector2.new(
								input.Position.X,
								input.Position.Y
							)

							if not screengui.IgnoreGuiInset then
								local inset = GuiService:GetGuiInset()
								point = point - inset
							end

							local function isInside(gui)
								local position = gui.AbsolutePosition
								local size = gui.AbsoluteSize

								return point.X >= position.X
									and point.X <= position.X + size.X
									and point.Y >= position.Y
									and point.Y <= position.Y + size.Y
							end

							if isInside(framewindow) or isInside(keyframe) then
								return
							end

							keypicker:Close()
						end)
					)
				end

				function keypicker:Open()
					openminiwindow()
					return self
				end

				connect(keybox.MouseButton1Click, startbind)

				connect(keybox.MouseButton2Click, function()
					if opened then
						keypicker:Close()
					else
						keypicker:Open()
					end
				end)

				connect(InputService.InputBegan, function(input, gameProcessed)
					if destroyed or waiting_for_key then
						return
					end

					if gameProcessed or InputService:GetFocusedTextBox() then
						return
					end

					if input.UserInputType ~= Enum.UserInputType.Keyboard then
						return
					end

					if not currentkey or input.KeyCode ~= currentkey then
						return
					end

					if Mode == "Toggle" then
						setState(not toggled)
					elseif Mode == "Hold" then
						setState(true)
					end
				end)

				connect(InputService.InputEnded, function(input)
					if destroyed or waiting_for_key then
						return
					end

					if input.UserInputType ~= Enum.UserInputType.Keyboard then
						return
					end

					if not currentkey or input.KeyCode ~= currentkey then
						return
					end

					if Mode == "Hold" then
						setState(false)
					end
				end)

				local function cleanup()
					if destroyed then
						return
					end

					keypicker:Close()
					cancelbind()
					destroyed = true

					for _, connection in ipairs(keyConnections) do
						connection:Disconnect()
					end

					table.clear(keyConnections)

					if Toggles[togglename]
						and Toggles[togglename].keypicker == keypicker then
						Toggles[togglename].keypicker = nil
					end

					if Options[name] == keypicker then
						Options[name] = nil
					end

					if library.Options[name] == keypicker then
						library.Options[name] = nil
					end
				end

				function keypicker:Destroy()
					if destroyed then
						return
					end

					cleanup()
					keyframe:Destroy()

					local gap = elements:FindFirstChild("KeyPickerGap")
					if gap then
						gap:Destroy()
					end

					hb.Size = UDim2.fromScale(1, 1)
					label.Size = UDim2.new(1, -15, 1, 0)
				end

				connect(holder.Destroying, cleanup)

				keypicker.Instance = keyframe
				keypicker.KeyBox = keybox

				updatetexts()

				if Mode == "Always" then
					setState(true)
				end

				return keypicker
			end

			if opts.Tooltip then
				attachTooltip(holder, opts.Tooltip)
			end

			return toggle
		end

		---------------------------------------------------------------
		-- AddSlider
		---------------------------------------------------------------
		function groupbox:AddSlider(name, opts)
			opts = opts or {}
			local slider = {}
			local UIS = InputService

			local config = {
				Minimum = opts.Minimum or 0;
				Maximum = opts.Maximum or 100;
				DefaultValue = opts.Default or 0;
				Step = opts.Step or 1;
				Format = opts.Format or "";
			}

			local range = config.Maximum - config.Minimum
			if range <= 0 then range = 1 end
			local stepsize = config.Step > 0 and config.Step or 1

			local function decimalsof(n)
				local d = tostring(n):match("%.(%d+)")
				return d and #d or 0
			end

			local decimals = opts.Rounding or math.max(decimalsof(stepsize), decimalsof(config.Minimum))
			local currentvalue = config.Minimum
			local dragging = false

			local mainframe = library:Create("Frame", {
				Name = "Slider";
				Size = UDim2.new(0.95, 0, 0, 15);
				BackgroundTransparency = 1;
				LayoutOrder = #elementsholder:GetChildren();
				Parent = elementsholder;
			})

			if opts.Smaller then
				mainframe.Size = UDim2.new(0.465, 0, 0, 15)
			end

			library:Create("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
				Color = library.SecondaryColor;
				Thickness = 1;
				Parent = mainframe;
			}, {
				instancep = "Color";
				tinstance = library.SecondaryColor;
			})

			local frame = library:Create("Frame", {
				Name = "Frame";
				Size = UDim2.new(0, 0, 1, 0);
				BackgroundColor3 = library.AccentColor;
				Parent = mainframe;
			}, {
				instancep = "BackgroundColor3";
				tinstance = library.AccentColor;
			})

			local hitbox = library:Create("TextButton", {
				Name = "Hitbox";
				Size = UDim2.new(1, 0, 1, 0);
				BackgroundTransparency = 1;
				Text = "";
				ZIndex = 3;
				Parent = mainframe;
			})

			local text = library:Create("TextLabel", {
				Name = "Text";
				Size = UDim2.new(1, 0, 1, 0);
				BackgroundTransparency = 1;
				Text = tostring(opts.Text or name);
				TextColor3 = library.FontColor;
				Font = library.Font;
				TextSize = 13;
				TextXAlignment = Enum.TextXAlignment.Center;
				TextYAlignment = Enum.TextYAlignment.Center;
				ZIndex = 2;
				Parent = mainframe;
			}, {
				instancep = "TextColor3";
				tinstance = library.FontColor;
			}, {
				instancep = "Font";
				tinstance = library.Font;
			})

			library:Create("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
				Color = library.UIstroke;
				Thickness = 1;
				Parent = text;
			}, {
				instancep = "Color";
				tinstance = library.UIstroke;
			})

			library:Create("UITextSizeConstraint", {
				MaxTextSize = 13;
				Parent = text;
			})

			local function fmt(n) return tostring(n) end

			local function refreshui()
				local alpha = (currentvalue - config.Minimum) / range
				frame.Size = UDim2.new(math.clamp(alpha, 0, 1), 0, 1, 0)
				local suffix = ""
				if config.Format ~= "" then 
					suffix = " " .. tostring(config.Format) 
				end
				text.Text = tostring(name) .. ": " .. fmt(currentvalue) .. "/" .. fmt(config.Maximum) .. suffix
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
					if opts.Callback then opts.Callback(v) end
					slider.OnChanged:Fire(v)
				end
			end

			slider.Value = currentvalue
			slider.OnChanged = newSignal()
			Options[name] = slider
			library.Options = library.Options or Options
			library.Options[name] = slider

			function slider:SetValue(v, silent) setvalue(v, silent) end
			function slider:GetValue() return currentvalue end

			setvalue(config.DefaultValue, true)

			local moveConn, endConn
			local function stop()
				dragging = false
				if moveConn then moveConn:Disconnect() moveConn = nil end
				if endConn then endConn:Disconnect() endConn = nil end
			end

			local function drag(input)
				local pos, size = mainframe.AbsolutePosition, mainframe.AbsoluteSize
				local alpha = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
				setvalue(config.Minimum + alpha * range)
			end

			trackConnection(hitbox.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					stop()
					dragging = true
					drag(input)
					moveConn = trackConnection(UIS.InputChanged:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
							drag(i)
						end
					end))
					endConn = trackConnection(UIS.InputEnded:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
							stop()
						end
					end))
				end
			end))

			if opts.Tooltip then attachTooltip(mainframe, opts.Tooltip) end
			return slider
		end

		---------------------------------------------------------------
		-- AddButton
		---------------------------------------------------------------
		function groupbox:AddButton(name, opts)
			opts = opts or {}
			local button = {}

			local warnclick = opts.WarnClick or opts.Warn or false
			local smaller = opts.Smaller or opts.Small or false
			local armed = false
			local armtoken = 0

			local Holder = library:Create("Frame", {
				Name = "Button";
				Size = smaller and UDim2.new(0.465, 0, 0, 15) or UDim2.new(0.95, 0, 0, 15);
				LayoutOrder = #elementsholder:GetChildren();
				BackgroundColor3 = library.MainColor;
				Parent = elementsholder;
			}, {
				instancep = "BackgroundColor3";
				tinstance = library.MainColor;
			})

			library:Create("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
				Color = library.SecondaryColor;
				Thickness = 1;
				Parent = Holder;
			}, {
				instancep = "Color";
				tinstance = library.SecondaryColor;
			})

			local text = library:Create("TextLabel", {
				Name = "text";
				Size = UDim2.new(1, 0, 1, 0);
				BackgroundTransparency = 1;
				Text = name;
				TextColor3 = library.FontColor;
				TextSize = 13;
				Font = library.Font;
				TextXAlignment = Enum.TextXAlignment.Center;
				ZIndex = 2;
				Parent = Holder;
			}, {
				instancep = "TextColor3";
				tinstance = library.FontColor;
			}, {
				instancep = "Font";
				tinstance = library.Font;
			})

			library:Create("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
				Color = library.UIstroke;
				Thickness = 1;
				Parent = text;
			}, {
				instancep = "Color";
				tinstance = library.UIstroke;
			})

			library:Create("UITextSizeConstraint", {
				MaxTextSize = 13;
				Parent = text;
			})

			local Textbutton = library:Create("TextButton", {
				Name = "Boxhit";
				Size = UDim2.new(1, 0, 1, 0);
				BackgroundTransparency = 1;
				Text = "";
				ZIndex = 3;
				Parent = Holder;
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
						if armed and armtoken == mytoken then disarm() end
					end)
					return
				end
				if armed then disarm() end
				if opts.Callback then opts.Callback() end
			end)

			if opts.Tooltip then attachTooltip(Holder, opts.Tooltip) end
			return button
		end

		---------------------------------------------------------------
		-- AddDependencyBox
		---------------------------------------------------------------
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

			library:Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal;
				Wraps = true;
				HorizontalAlignment = Enum.HorizontalAlignment.Center;
				SortOrder = Enum.SortOrder.LayoutOrder;
				Padding = UDim.new(0, 5);
				Parent = Frame;
			})

			local order = 0
			local function wrap(fname)
				if typeof(groupbox[fname]) ~= "function" then return end
				dependencybox[fname] = function(_, ...)
					local before = {}
					for _, child in ipairs(Container:GetChildren()) do before[child] = true end
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

			for _, fname in ipairs({
				"AddLabel", "AddToggle", "AddSlider", "AddButton",
				"AddInput", "AddDropdown", "AddDependencyBox", "Divider"
				}) do
				wrap(fname)
			end

			function dependencybox:Update()
				for _, dep in next, dependencybox.Dependencies do
					local Element = dep[1]
					local Value = dep[2]
					local current = Element.Value
					if current == nil then current = Element.value end
					if current ~= Value then
						Holder.Visible = false
						return
					end
				end
				Holder.Visible = true
			end

			function dependencybox:SetupDependencies(Dependencies)
				for _, dep in next, Dependencies do
					assert(typeof(dep) == "table", "SetupDependencies: Dependency is not of type `table`.")
					assert(dep[1], "SetupDependencies: Dependency is missing element argument.")
					assert(dep[2] ~= nil, "SetupDependencies: Dependency is missing value argument.")
				end
				dependencybox.Dependencies = Dependencies
				dependencybox:Update()
			end

			table.insert(groupbox.elements, dependencybox)
			table.insert(library.DependencyBoxes, dependencybox)
			return dependencybox
		end

		---------------------------------------------------------------
		-- Divider
		---------------------------------------------------------------
		function groupbox:Divider()
			local divider = {}

			library:Create("Frame", {
				Name = "Divider";
				Size = UDim2.new(0.95, 0, 0, 3);
				BackgroundColor3 = library.MainColor;
				LayoutOrder = #elementsholder:GetChildren();
				Parent = elementsholder;
			}, {
				instancep = "BackgroundColor3";
				tinstance = library.MainColor;
			})

			return divider
		end

		---------------------------------------------------------------
		-- AddDropdown — v2 layout (label + mini pill on the right)
		---------------------------------------------------------------
		function groupbox:AddDropdown(name, opts)
    opts = opts or {}

    library.Options = library.Options or {}
    library.windowinstances = library.windowinstances or {}

    local UserInputService = game:GetService("UserInputService")
    local GuiService = game:GetService("GuiService")

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

    local Dropdown = {}
    local values = {}
    local elements = {}
    local selectedIndices = {}
    local connections = {}
    local popupConnections = {}

    local picked = nil
    local isOpen = false
    local destroyed = false
    local multi = opts.Multipick == true
    local callback = opts.Callback

    local popupHolder = nil
    local holder = nil

    local rowHeight = 20
    local rowGap = 4
    local innerPadding = 4
    local outerPadding = 2
    local scrollingWidth = 205

    local requestedVisible = tonumber(opts.MaxVisibleItems) or 10

    if requestedVisible ~= requestedVisible then
        requestedVisible = 10
    end

    local maxVisibleItems = math.clamp(
        math.floor(requestedVisible),
        1,
        30
    )

    local regularFont = Font.new(
        "rbxasset://fonts/families/GothamSSm.json",
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )

    local changedEvent = Instance.new("BindableEvent")

    local option = {
        Type = "Dropdown";
        Name = name;
        Value = multi and {} or nil;
        Values = values;
        OnChanged = changedEvent.Event;
        Controller = Dropdown;
    }

    library.Options[name] = option

    local function connect(signal, fn)
        local connection = signal:Connect(fn)
        table.insert(connections, connection)
        return connection
    end

    local function connectPopup(signal, fn)
        local connection = signal:Connect(fn)
        table.insert(popupConnections, connection)
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

    -- Main row.

    local main = library:Create("Frame", {
        Name = "Dropdown";
        Size = UDim2.new(0.95, 0, 0, 20);
        BackgroundTransparency = 1;
        LayoutOrder = #elementsholder:GetChildren();
        Parent = elementsholder;
    })

    local holder2 = library:Create("Frame", {
        Name = "Holder2";
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        Parent = main;
    })

    library:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal;
        VerticalAlignment = Enum.VerticalAlignment.Center;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = holder2;
    })

    local label = library:Create("TextLabel", {
        Name = "Label";
        Size = UDim2.new(0.7936, 0, 1, 0);
        BackgroundTransparency = 1;

        -- Only opts.Text is displayed, never the internal name.
        Text = tostring(opts.Text or "");

        TextColor3 = library.FontColor;
        Font = library.Font;
        TextSize = 13;
        TextXAlignment = Enum.TextXAlignment.Left;
        LayoutOrder = 1;
        Parent = holder2;
    }, {
        instancep = "TextColor3";
        tinstance = library.FontColor;
    }, {
        instancep = "Font";
        tinstance = library.Font;
    })

    library:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 7);
        Parent = label;
    })

    library:Create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
        Color = library.UIstroke;
        Thickness = 1;
        Parent = label;
    }, {
        instancep = "Color";
        tinstance = library.UIstroke;
    })

    local mini = library:Create("Frame", {
        Name = "mini";
        Size = UDim2.new(0.03, 50, 1, 0);
        BackgroundColor3 = library.AccentColor;
        BorderSizePixel = 0;
        LayoutOrder = 2;
        Parent = holder2;
    }, {
        instancep = "BackgroundColor3";
        tinstance = library.AccentColor;
    })

    library:Create("UICorner", {
        CornerRadius = UDim.new(0, 4);
        Parent = mini;
    })

    library:Create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        Color = library.SecondaryColor;
        Thickness = 1;
        Parent = mini;
    }, {
        instancep = "Color";
        tinstance = library.SecondaryColor;
    })

    local selectedLabel = library:Create("TextLabel", {
        Name = "selected";
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        Text = "-";
        TextColor3 = library.FontColor;
        Font = library.Font;
        TextSize = 14;
        TextWrapped = true;
        TextScaled = true;
        Parent = mini;
    }, {
        instancep = "TextColor3";
        tinstance = library.FontColor;
    }, {
        instancep = "Font";
        tinstance = library.Font;
    })

    library:Create("UITextSizeConstraint", {
        MaxTextSize = 14;
        Parent = selectedLabel;
    })

    local button = library:Create("TextButton", {
        Name = "Hitbox";
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        Text = "";
        AutoButtonColor = false;
        ZIndex = 3;
        Parent = mini;
    })

    local function heightFor(rows)
        if rows == 0 then
            return 0
        end

        return innerPadding * 2
            + rows * rowHeight
            + math.max(0, rows - 1) * rowGap
    end

    local function positionHolder()
        if destroyed or not popupHolder or not popupHolder.Parent then
            return
        end

        local basePosition = screengui.AbsolutePosition
        local screenSize = screengui.AbsoluteSize
        local triggerPosition = mini.AbsolutePosition
        local triggerSize = mini.AbsoluteSize

        local width = popupHolder.Size.X.Offset
        local height = popupHolder.Size.Y.Offset

        local x = triggerPosition.X - basePosition.X + triggerSize.X
        local y = triggerPosition.Y - basePosition.Y + triggerSize.Y

        if y + height > screenSize.Y then
            y = triggerPosition.Y - basePosition.Y - height
        end

        x = math.clamp(x, 0, math.max(0, screenSize.X - width))
        y = math.clamp(y, 0, math.max(0, screenSize.Y - height))

        popupHolder.Position = UDim2.fromOffset(x, y)
    end

    local function destroyItems()
        for _, item in ipairs(elements) do
            if item.connection then
                item.connection:Disconnect()
            end

            item.button:Destroy()
        end

        table.clear(elements)
    end

    local function destroyPopup()
        for _, connection in ipairs(popupConnections) do
            connection:Disconnect()
        end

        table.clear(popupConnections)
        destroyItems()

        if popupHolder then
            popupHolder:Destroy()
        end

        popupHolder = nil
        holder = nil

        Dropdown.Popup = nil
        Dropdown.Holder = nil
    end

    local function updateSelectedText()
        local current = getValue()
        local text = "-"

        if multi then
            local display = {}

            for _, value in ipairs(current) do
                table.insert(display, tostring(value))
            end

            if #display > 0 then
                text = table.concat(display, ", ")
            end
        elseif current ~= nil then
            text = tostring(current)
        end

        -- Truncate only the mini-frame text.
        local length = utf8.len(text)

        if length and length > 4 then
            local cutoff = utf8.offset(text, 5)
            text = string.sub(text, 1, cutoff - 1) .. "..."
        elseif not length and #text > 4 then
            text = string.sub(text, 1, 4) .. "..."
        end

        selectedLabel.Text = text
        option.Value = current
    end

    local function updateItems()
        for index, item in ipairs(elements) do
            local selected = (
                multi and selectedIndices[index] == true
            ) or (
                not multi and picked == item.name
            )

            item.button.Text = tostring(item.name)

            if selected then
                item.button.Font = library.Font
            else
                item.button.FontFace = regularFont
            end
        end
    end

    local function updateHolderSize()
        if destroyed or not popupHolder or not holder then
            return
        end

        if #values == 0 then
            Dropdown:Close()
            return
        end

        local visibleRows = math.min(#values, maxVisibleItems)
        local holderHeight = heightFor(visibleRows)

        holder.Size = UDim2.fromOffset(scrollingWidth, holderHeight)
        holder.CanvasSize = UDim2.fromOffset(0, heightFor(#values))
        holder.ScrollingEnabled = #values > maxVisibleItems

        popupHolder.Size = UDim2.fromOffset(
            scrollingWidth + outerPadding * 2,
            holderHeight + outerPadding * 2
        )

        positionHolder()
    end

    local function updateUI()
        updateSelectedText()

        if isOpen then
            updateItems()
            updateHolderSize()
        end
    end

    local function notifyChanged()
        local value = getValue()
        option.Value = value

        changedEvent:Fire(
            type(value) == "table" and table.clone(value) or value
        )

        if type(callback) == "function" then
            pcall(
                callback,
                type(value) == "table" and table.clone(value) or value
            )
        end
    end

    local function buildItems()
        if not holder then
            return
        end

        for index, itemName in ipairs(values) do
            local item = {
                name = itemName;
                index = index;
            }

            local itemButton = library:Create("TextButton", {
                Name = "TextLabel_" .. tostring(index);
                FontFace = regularFont;
                TextColor3 = library.FontColor;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                Text = tostring(itemName);
                BackgroundTransparency = 1;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                Size = UDim2.new(1, 0, 0, rowHeight);
                BorderSizePixel = 0;
                ZIndex = 22;
                TextSize = 14;
                TextXAlignment = Enum.TextXAlignment.Center;
                TextYAlignment = Enum.TextYAlignment.Center;
                TextWrapped = false;
                TextScaled = false;
                TextTruncate = Enum.TextTruncate.AtEnd;
                AutomaticSize = Enum.AutomaticSize.None;
                AutoButtonColor = false;
                LayoutOrder = index;
                Parent = holder;
            }, {
                instancep = "TextColor3";
                tinstance = library.FontColor;
            })

            library:Create("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
                Color = library.UIstroke;
                Thickness = 1;
                Parent = itemButton;
            }, {
                instancep = "Color";
                tinstance = library.UIstroke;
            })

            library:Create("UITextSizeConstraint", {
                MaxTextSize = 42;
                Parent = itemButton;
            })

            item.button = itemButton
            elements[index] = item

            item.connection = itemButton.Activated:Connect(function()
                if destroyed or not isOpen then
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
                    Dropdown:Close()
                end

                updateUI()

                if not equalValues(previous, getValue()) then
                    notifyChanged()
                end
            end)
        end
    end

    local function pointInside(guiObject, point)
        if not guiObject or not guiObject.Parent or not guiObject.Visible then
            return false
        end

        local position = guiObject.AbsolutePosition
        local size = guiObject.AbsoluteSize

        return point.X >= position.X
            and point.X <= position.X + size.X
            and point.Y >= position.Y
            and point.Y <= position.Y + size.Y
    end

    local function createPopup()
        if popupHolder or destroyed then
            return
        end

        popupHolder = library:Create("Frame", {
            Name = "holder";
            BackgroundColor3 = library.MainColor;
            BorderColor3 = Color3.fromRGB(0, 0, 0);
            BorderSizePixel = 0;
            Size = UDim2.fromOffset(48, 0);
            AutomaticSize = Enum.AutomaticSize.None;
            ZIndex = 20;
            Visible = false;
            Parent = screengui;
        }, {
            instancep = "BackgroundColor3";
            tinstance = library.MainColor;
        })

        library:Create("UICorner", {
            CornerRadius = UDim.new(0, 4);
            Parent = popupHolder;
        })

        library:Create("UIPadding", {
            PaddingTop = UDim.new(0, outerPadding);
            PaddingBottom = UDim.new(0, outerPadding);
            PaddingRight = UDim.new(0, outerPadding);
            PaddingLeft = UDim.new(0, outerPadding);
            Parent = popupHolder;
        })

        library:Create("UIStroke", {
            Color = library.SecondaryColor;
            Thickness = 1;
            Parent = popupHolder;
        }, {
            instancep = "Color";
            tinstance = library.SecondaryColor;
        })

        holder = library:Create("ScrollingFrame", {
            Name = "ScrollingFrame";
            Active = true;
            ScrollingDirection = Enum.ScrollingDirection.Y;
            ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0);
            ScrollBarThickness = 0;
            BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            BackgroundTransparency = 1;
            BorderColor3 = Color3.fromRGB(0, 0, 0);
            BorderSizePixel = 0;
            Size = UDim2.fromOffset(scrollingWidth, 44);
            AutomaticCanvasSize = Enum.AutomaticSize.None;
            AutomaticSize = Enum.AutomaticSize.None;
            CanvasSize = UDim2.fromOffset(0, 0);
            ClipsDescendants = true;
            ZIndex = 21;
            Parent = popupHolder;
        })

        library:Create("UIListLayout", {
            Padding = UDim.new(0, rowGap);
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = holder;
        })

        library:Create("UIPadding", {
            PaddingTop = UDim.new(0, innerPadding);
            PaddingBottom = UDim.new(0, innerPadding);
            PaddingRight = UDim.new(0, innerPadding);
            PaddingLeft = UDim.new(0, innerPadding);
            Parent = holder;
        })

        Dropdown.Popup = popupHolder
        Dropdown.Holder = holder

        buildItems()
        updateItems()
        updateHolderSize()

        connectPopup(
            mini:GetPropertyChangedSignal("AbsolutePosition"),
            positionHolder
        )

        connectPopup(
            mini:GetPropertyChangedSignal("AbsoluteSize"),
            positionHolder
        )

        connectPopup(
            screengui:GetPropertyChangedSignal("AbsolutePosition"),
            positionHolder
        )

        connectPopup(
            screengui:GetPropertyChangedSignal("AbsoluteSize"),
            positionHolder
        )

        connectPopup(UserInputService.InputBegan, function(input)
            if destroyed or not isOpen then
                return
            end

            local inputType = input.UserInputType

            if inputType ~= Enum.UserInputType.MouseButton1
                and inputType ~= Enum.UserInputType.MouseButton2
                and inputType ~= Enum.UserInputType.Touch then
                return
            end

            local point = Vector2.new(input.Position.X, input.Position.Y)

            if not screengui.IgnoreGuiInset then
                local inset = GuiService:GetGuiInset()
                point = point - inset
            end

            if pointInside(mini, point)
                or pointInside(popupHolder, point) then
                return
            end

            Dropdown:Close()
        end)

        if popupHolder then
            popupHolder.Visible = true
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
            -- Never fall back to the internal name.
            label.Text = tostring(text or "")
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

    function Dropdown:Open()
        if destroyed or #values == 0 then
            return self
        end

        local previous = library.windowinstances.Dropdownbox

        if previous and previous ~= self
            and type(previous.Close) == "function" then
            previous:Close()
        end

        library.windowinstances.Dropdownbox = self

        if isOpen then
            updateUI()
            return self
        end

        isOpen = true
        createPopup()

        return self
    end

    function Dropdown:Close()
        isOpen = false

        if library.windowinstances.Dropdownbox == self then
            library.windowinstances.Dropdownbox = nil
        end

        destroyPopup()
        return self
    end

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

        if isOpen and holder then
            buildItems()
            updateUI()

            if holder then
                holder.CanvasPosition = Vector2.zero
            end
        end

        if silent == false and not equalValues(previous, getValue()) then
            notifyChanged()
        end

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

        local index = table.find(values, itemName)

        if not index then
            local updated = table.clone(values)
            table.insert(updated, itemName)

            self:Refresh(updated)
            index = table.find(values, itemName)
        end

        if not index then
            return nil
        end

        return elements[index] or {
            name = values[index];
            index = index;
        }
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

    local function cleanup()
        if destroyed then
            return
        end

        Dropdown:Close()
        destroyed = true

        for _, connection in ipairs(connections) do
            connection:Disconnect()
        end

        table.clear(connections)

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

    connect(button.Activated, function()
        if destroyed then
            return
        end

        if isOpen then
            Dropdown:Close()
        else
            Dropdown:Open()
        end
    end)

    local forwarded = {
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

    for _, methodName in ipairs(forwarded) do
        local method = Dropdown[methodName]

        option[methodName] = function(_, ...)
            return method(Dropdown, ...)
        end
    end

    Dropdown.Instance = selectedLabel
    Dropdown.Main = main
    Dropdown.Header = label
    Dropdown.Option = option
    Dropdown.OnChanged = changedEvent.Event

    Dropdown:Refresh(opts.Values or {}, opts.Default, true)

    if opts.Tooltip then
        attachTooltip(main, opts.Tooltip)
    end

    return Dropdown
end

		---------------------------------------------------------------
		-- AddInput
		---------------------------------------------------------------
		function groupbox:AddInput(name, opts)
			opts = opts or {}
			local input = {}

			local initialValue = tostring(opts.Default or "")
			local changedEvent = Instance.new("BindableEvent")
			local option = {
				Type = "Input";
				Name = name;
				Value = initialValue;
				OnChanged = changedEvent.Event;
			}
			library.Options = library.Options or {}
			library.Options[name] = option

			local Holder = library:Create("Frame", {
				Name = "Input";
				Size = UDim2.new(0.95, 0, 0, 20);
				LayoutOrder = #elementsholder:GetChildren();
				BackgroundColor3 = library.MainColor;
				Parent = elementsholder;
			}, {
				instancep = "BackgroundColor3";
				tinstance = library.MainColor;
			})

			library:Create("UIStroke", {
				Name = "UIStroke";
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
				Color = library.SecondaryColor;
				Thickness = 1;
				Parent = Holder;
			}, {
				instancep = "Color";
				tinstance = library.SecondaryColor;
			})

			local text = library:Create("TextBox", {
				Name = "Text";
				Size = UDim2.new(1, 0, 1, 0);
				BackgroundTransparency = 1;
				ClearTextOnFocus = false;
				MultiLine = false;
				PlaceholderText = (opts.Text or name) .. "..";
				Text = initialValue;
				TextColor3 = library.FontColor;
				TextSize = 13;
				Font = library.Font;
				TextXAlignment = Enum.TextXAlignment.Center;
				ZIndex = 2;
				Parent = Holder;
			}, {
				instancep = "TextColor3";
				tinstance = library.FontColor;
			}, {
				instancep = "Font";
				tinstance = library.Font;
			})

			library:Create("UIStroke", {
				Name = "TextStroke";
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
				Color = library.UIstroke;
				Thickness = 1;
				Parent = text;
			}, {
				instancep = "Color";
				tinstance = library.UIstroke;
			})

			library:Create("UITextSizeConstraint", {
				Name = "UITextSizeConstraint";
				MaxTextSize = 13;
				Parent = text;
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
					if opts.Callback then opts.Callback(value) end
				end
			end

			function option:GetValue() return option.Value end
			function option:SetValue(value, silent) setValue(value, silent == true) end
			function input:GetValue() return option.Value end
			function input:SetValue(value, silent) option:SetValue(value, silent) end
			function input:GetInstance() return text end

			text:GetPropertyChangedSignal("Text"):Connect(function()
				if updating then return end
				local value = text.Text
				if option.Value == value then return end
				option.Value = value
				changedEvent:Fire(value)
				if opts.Callback then opts.Callback(value) end
			end)

			input.Instance = text
			input.Holder = Holder
			input.Option = option

			if opts.Tooltip then attachTooltip(Holder, opts.Tooltip) end
			return input
		end

		---------------------------------------------------------------
		-- AddLineGraph
		---------------------------------------------------------------
		function groupbox:AddLineGraph(text, opts)
			opts = opts or {}

			local linegraph = {}
			local graphsets = {}
			local curvePoints = 0
			local opened = false
			local destroyed = false

			local instance
			local followConn
			local outsideConn
			local buttonConnection
			local openConnections = {}
			local pointFrames = {}
			local pointConnections = {}
			local curveFrames = {}

			local UIS = game:GetService("UserInputService")

			local selectedPreset = opts.Preset or "Linear"
			local draggingPoint
			local dragMoveConn
			local dragEndConn

			local presets = {
				"Linear",
				"Smooth",
				"Exponential",
				"Ease In",
				"Ease Out",
				"Ease In Out"
			}

			local function addConnection(signal, callback)
				local connection = signal:Connect(callback)
				if trackConnection then trackConnection(connection) end
				table.insert(openConnections, connection)
				return connection
			end

			local function disconnectConnection(connection)
				if connection then connection:Disconnect() end
			end

			local function clearPointConnections()
				for _, connection in ipairs(pointConnections) do
					disconnectConnection(connection)
				end
				table.clear(pointConnections)
			end

			local function clearOpenConnections()
				for _, connection in ipairs(openConnections) do
					disconnectConnection(connection)
				end
				table.clear(openConnections)
				clearPointConnections()
				disconnectConnection(followConn)
				disconnectConnection(outsideConn)
				disconnectConnection(dragMoveConn)
				disconnectConnection(dragEndConn)
				followConn = nil
				outsideConn = nil
				dragMoveConn = nil
				dragEndConn = nil
				draggingPoint = nil
			end

			local function clearList(list)
				for _, object in ipairs(list) do
					if object then object:Destroy() end
				end
				table.clear(list)
			end

			local function copyPoints(values)
				local result = {}
				for _, point in ipairs(values or {}) do
					local x = tonumber(point.X or point.x or point[1]) or 0
					local y = tonumber(point.Y or point.y or point[2]) or 0
					table.insert(result, {
						X = math.clamp(x, 0, 1),
						Y = math.clamp(y, 0, 1)
					})
				end
				table.sort(result, function(a, b) return a.X < b.X end)
				return result
			end

			graphsets = copyPoints(opts.default or opts.Default or {})
			curvePoints = #graphsets

			local function getData()
				local result = {}
				for i, point in ipairs(graphsets) do
					result[i] = { X = point.X, Y = point.Y }
				end
				return result
			end

			local function notifyChanged()
				curvePoints = #graphsets
				if linegraph.OnChanged then linegraph.OnChanged:Fire(getData()) end
				if type(opts.Callback) == "function" then opts.Callback(getData()) end
			end

			local holder = library:Create("Frame", {
				Name = "Holder";
				Size = UDim2.new(0.95, 0, 0, 20);
				BackgroundTransparency = 1;
				LayoutOrder = #elementsholder:GetChildren();
				Parent = elementsholder;
			})

			local uitext = library:Create("TextLabel", {
				Name = "TextLabel";
				Size = UDim2.new(0.937, 0, 1, 0);
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
			}, {
				instancep = "Font";
				tinstance = library.Font;
			})

			library:Create("UITextSizeConstraint", {
				Name = "UITextSizeConstraint";
				MaxTextSize = 13;
				Parent = uitext;
			})

			library:Create("UIStroke", {
				Name = "UIStroke";
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
				Color = Color3.fromRGB(0, 0, 0);
				Thickness = 1;
				Parent = uitext;
			}, {
				instancep = "Color";
				tinstance = library.UIstroke;
			})

			library:Create("UIListLayout", {
				Name = "UIListLayout";
				FillDirection = Enum.FillDirection.Horizontal;
				HorizontalAlignment = Enum.HorizontalAlignment.Left;
				SortOrder = Enum.SortOrder.LayoutOrder;
				Parent = holder;
			})

			local buttonopen = library:Create("ImageButton", {
				Name = "ButtonOpen";
				Size = UDim2.new(0, 19, 0, 19);
				LayoutOrder = 2;
				BackgroundTransparency = 1;
				Image = "rbxassetid://10734950309";
				ImageColor3 = library.AccentColor;
				Parent = holder;
			}, {
				instancep = "ImageColor3";
				tinstance = library.AccentColor;
			})

			local function getPopupPosition()
				local absolute = buttonopen.AbsolutePosition
				local base = screengui.AbsolutePosition
				return UDim2.fromOffset(absolute.X - base.X, absolute.Y - base.Y)
			end

			local closeGraph

			local function openGraph()
				if opened or destroyed then return end
				opened = true

				local lineG = library:Create("Frame", {
					Name = "CursorBox";
					Size = UDim2.fromOffset(15, 15);
					Position = getPopupPosition();
					BackgroundTransparency = 1;
					ZIndex = 2;
					Parent = screengui;
				})

				instance = lineG

				followConn = buttonopen:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
					if opened and instance and instance.Parent then
						instance.Position = getPopupPosition()
					end
				end)
				if trackConnection then trackConnection(followConn) end

				local framewindow = library:Create("Frame", {
					Name = "Frame";
					Size = UDim2.fromOffset(323, 246);
					Position = UDim2.new(1, 0, 1.4, 0);
					BackgroundColor3 = library.MainColor;
					BorderSizePixel = 0;
					ZIndex = 2;
					Parent = lineG;
				}, {
					instancep = "BackgroundColor3";
					tinstance = library.MainColor;
				})

				library:Create("UIStroke", {
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

				library:Create("UIStroke", {
					Name = "OuterStroke";
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
					LineJoinMode = Enum.LineJoinMode.Miter;
					Color = library.MainColor;
					Thickness = 4;
					ZIndex = 2;
					Parent = framewindow;
				}, {
					instancep = "Color";
					tinstance = library.MainColor;
				})

				local title = library:Create("TextLabel", {
					Name = "TextLabel";
					Size = UDim2.new(1, 0, 0, 18);
					Position = UDim2.fromOffset(0, 0);
					BackgroundTransparency = 1;
					Text = text or "Line Graph";
					TextColor3 = library.FontColor;
					Font = library.Font;
					TextSize = 13;
					TextXAlignment = Enum.TextXAlignment.Left;
					ZIndex = 3;
					Parent = framewindow;
				}, {
					instancep = "TextColor3";
					tinstance = library.FontColor;
				}, {
					instancep = "Font";
					tinstance = library.Font;
				})

				library:Create("UIPadding", {
					PaddingLeft = UDim.new(0, 6);
					Parent = title;
				})

				library:Create("UIStroke", {
					Name = "UIStroke";
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
					Color = library.UIstroke;
					Thickness = 1;
					Parent = title;
				}, {
					instancep = "Color";
					tinstance = library.UIstroke;
				})

				local GraphHolder = library:Create("Frame", {
					Name = "GraphHolder";
					Position = UDim2.fromOffset(4, 24);
					Size = UDim2.fromOffset(315, 168);
					BackgroundTransparency = 1;
					BorderSizePixel = 0;
					ClipsDescendants = false;
					Active = true;
					ZIndex = 2;
					Parent = framewindow;
				})

				library:Create("UIStroke", {
					Color = library.SecondaryColor;
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
					Parent = GraphHolder;
				}, {
					instancep = "Color";
					tinstance = library.SecondaryColor;
				})

				local grid = library:Create("Frame", {
					Name = "Grid";
					Size = UDim2.fromScale(1, 1);
					BackgroundTransparency = 1;
					ZIndex = 2;
					Parent = GraphHolder;
				})

				local curveLayer = library:Create("Frame", {
					Name = "CurveLines";
					Size = UDim2.fromScale(1, 1);
					BackgroundTransparency = 1;
					ZIndex = 3;
					Parent = GraphHolder;
				})

				local pointLayer = library:Create("Frame", {
					Name = "Points";
					Size = UDim2.fromScale(1, 1);
					BackgroundTransparency = 1;
					ZIndex = 5;
					Parent = GraphHolder;
				})

				for i = 1, 4 do
					library:Create("Frame", {
						Name = "HorizontalLine";
						Position = UDim2.fromScale(0, i / 5);
						Size = UDim2.new(1, 0, 0, 1);
						BorderSizePixel = 0;
						BackgroundColor3 = library.SecondaryColor;
						ZIndex = 2;
						Parent = grid;
					}, {
						instancep = "BackgroundColor3";
						tinstance = library.SecondaryColor;
					})
				end

				for i = 1, 7 do
					library:Create("Frame", {
						Name = "VerticalLine";
						Position = UDim2.fromScale(i / 8, 0);
						Size = UDim2.new(0, 1, 1, 0);
						BorderSizePixel = 0;
						BackgroundColor3 = library.SecondaryColor;
						ZIndex = 2;
						Parent = grid;
					}, {
						instancep = "BackgroundColor3";
						tinstance = library.SecondaryColor;
					})
				end

				local function toPixels(point)
					local size = GraphHolder.AbsoluteSize
					return Vector2.new(point.X * size.X, (1 - point.Y) * size.Y)
				end

				local function createSegment(a, b)
					local delta = b - a
					local length = delta.Magnitude
					if length < 0.5 then return end
					local segment = library:Create("Frame", {
						Name = "CurveSegment";
						AnchorPoint = Vector2.new(0, 0.5);
						Position = UDim2.fromOffset(a.X, a.Y);
						Size = UDim2.fromOffset(length, 2);
						Rotation = math.deg(math.atan2(delta.Y, delta.X));
						BorderSizePixel = 0;
						BackgroundColor3 = library.AccentColor;
						ZIndex = 3;
						Parent = curveLayer;
					}, {
						instancep = "BackgroundColor3";
						tinstance = library.AccentColor;
					})
					table.insert(curveFrames, segment)
				end

				local function catmullRom(p0, p1, p2, p3, t)
					local t2 = t * t
					local t3 = t2 * t
					return Vector2.new(
						0.5 * (2 * p1.X + (-p0.X + p2.X) * t + (2*p0.X - 5*p1.X + 4*p2.X - p3.X) * t2 + (-p0.X + 3*p1.X - 3*p2.X + p3.X) * t3),
						0.5 * (2 * p1.Y + (-p0.Y + p2.Y) * t + (2*p0.Y - 5*p1.Y + 4*p2.Y - p3.Y) * t2 + (-p0.Y + 3*p1.Y - 3*p2.Y + p3.Y) * t3)
					)
				end

				local function interpolateY(a, b, t)
					if selectedPreset == "Exponential" or selectedPreset == "Ease In" then
						t = t * t
					elseif selectedPreset == "Ease Out" then
						t = 1 - (1 - t) * (1 - t)
					elseif selectedPreset == "Ease In Out" then
						if t < 0.5 then t = 2 * t * t
						else t = 1 - ((-2 * t + 2) ^ 2) / 2 end
					end
					return a + (b - a) * t
				end

				local renderGraph

				local function drawCurve()
					clearList(curveFrames)
					if #graphsets < 2 then return end
					local points = {}
					for i, point in ipairs(graphsets) do points[i] = toPixels(point) end
					for i = 1, #points - 1 do
						local p1 = points[i]
						local p2 = points[i + 1]
						if selectedPreset == "Smooth" then
							local p0 = points[math.max(1, i - 1)]
							local p3 = points[math.min(#points, i + 2)]
							local previous = p1
							for step = 1, 20 do
								local nextPoint = catmullRom(p0, p1, p2, p3, step / 20)
								createSegment(previous, nextPoint)
								previous = nextPoint
							end
						else
							local previous = p1
							for step = 1, 20 do
								local t = step / 20
								local nextPoint = Vector2.new(
									p1.X + (p2.X - p1.X) * t,
									interpolateY(p1.Y, p2.Y, t)
								)
								createSegment(previous, nextPoint)
								previous = nextPoint
							end
						end
					end
				end

				local function endDrag()
					draggingPoint = nil
					disconnectConnection(dragMoveConn)
					disconnectConnection(dragEndConn)
					dragMoveConn = nil
					dragEndConn = nil
					table.sort(graphsets, function(a, b) return a.X < b.X end)
					if opened then
						renderGraph()
						notifyChanged()
					end
				end

				local function startDrag(point)
					disconnectConnection(dragMoveConn)
					disconnectConnection(dragEndConn)
					draggingPoint = point

					dragMoveConn = UIS.InputChanged:Connect(function(input)
						if not draggingPoint or not opened or destroyed then return end
						if input.UserInputType ~= Enum.UserInputType.MouseMovement
							and input.UserInputType ~= Enum.UserInputType.Touch then return end
						local position = input.Position
						local origin = GraphHolder.AbsolutePosition
						local size = GraphHolder.AbsoluteSize
						if size.X <= 0 or size.Y <= 0 then return end
						draggingPoint.X = math.clamp((position.X - origin.X) / size.X, 0, 1)
						draggingPoint.Y = math.clamp(1 - (position.Y - origin.Y) / size.Y, 0, 1)
						renderGraph()
						notifyChanged()
					end)

					dragEndConn = UIS.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1
							or input.UserInputType == Enum.UserInputType.Touch then
							endDrag()
						end
					end)

					if trackConnection then
						trackConnection(dragMoveConn)
						trackConnection(dragEndConn)
					end
				end

				renderGraph = function()
					clearPointConnections()
					clearList(pointFrames)

					for _, point in ipairs(graphsets) do
						local pixel = toPixels(point)
						local dot = library:Create("TextButton", {
							Name = "CurveDot";
							AnchorPoint = Vector2.new(0.5, 0.5);
							Position = UDim2.fromOffset(pixel.X, pixel.Y);
							Size = UDim2.fromOffset(10, 10);
							BackgroundColor3 = library.AccentColor;
							BorderSizePixel = 0;
							Text = "";
							AutoButtonColor = false;
							Active = true;
							ZIndex = 5;
							Parent = pointLayer;
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.AccentColor;
						})

						library:Create("UICorner", {
							CornerRadius = UDim.new(1, 0);
							Parent = dot;
						})

						library:Create("TextLabel", {
							Name = "PointValue";
							AnchorPoint = Vector2.new(0.5, 1);
							Position = UDim2.new(0.5, 0, 0, -3);
							Size = UDim2.fromOffset(90, 14);
							BackgroundTransparency = 1;
							Text = string.format("%.2f, %.2f", point.X, point.Y);
							TextColor3 = library.FontColor;
							Font = library.Font;
							TextSize = 10;
							ZIndex = 6;
							Parent = dot;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						table.insert(pointFrames, dot)

						local connection = dot.InputBegan:Connect(function(input)
							if not opened or destroyed then return end
							if input.UserInputType == Enum.UserInputType.MouseButton1
								or input.UserInputType == Enum.UserInputType.Touch then
								startDrag(point)
							end
						end)
						table.insert(pointConnections, connection)
						if trackConnection then trackConnection(connection) end
					end

					drawCurve()
				end

				addConnection(GraphHolder.InputBegan, function(input)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1
						and input.UserInputType ~= Enum.UserInputType.Touch then return end
					if not opened or destroyed then return end
					local position = input.Position
					local origin = GraphHolder.AbsolutePosition
					local size = GraphHolder.AbsoluteSize
					if size.X <= 0 or size.Y <= 0 then return end
					local x = math.clamp((position.X - origin.X) / size.X, 0, 1)
					local y = math.clamp(1 - (position.Y - origin.Y) / size.Y, 0, 1)
					table.insert(graphsets, { X = x, Y = y })
					table.sort(graphsets, function(a, b) return a.X < b.X end)
					renderGraph()
					notifyChanged()
				end)

				if opts.Presets == true then
					local presetButton = library:Create("TextButton", {
						Name = "PresetButton";
						Position = UDim2.fromOffset(6, 197);
						Size = UDim2.new(1, -12, 0, 20);
						BackgroundColor3 = library.MainColor;
						Text = "Curve: " .. selectedPreset .. "  v";
						TextColor3 = library.FontColor;
						Font = library.Font;
						TextSize = 12;
						BorderSizePixel = 0;
						ZIndex = 10;
						Parent = framewindow;
					}, {
						instancep = "BackgroundColor3";
						tinstance = library.MainColor;
					}, {
						instancep = "TextColor3";
						tinstance = library.FontColor;
					}, {
						instancep = "Font";
						tinstance = library.Font;
					})

					local menu = library:Create("Frame", {
						Name = "PresetMenu";
						Position = UDim2.new(0, 6, 1, -48 - (#presets * 20));
						Size = UDim2.new(1, -12, 0, #presets * 20);
						BackgroundColor3 = library.MainColor;
						BorderSizePixel = 0;
						Visible = false;
						ZIndex = 20;
						Parent = framewindow;
					}, {
						instancep = "BackgroundColor3";
						tinstance = library.MainColor;
					})

					library:Create("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder;
						Parent = menu;
					})

					for i, preset in ipairs(presets) do
						local option = library:Create("TextButton", {
							Name = preset;
							Size = UDim2.new(1, 0, 0, 20);
							BackgroundColor3 = library.MainColor;
							BorderSizePixel = 0;
							Text = preset;
							TextColor3 = library.FontColor;
							Font = library.Font;
							TextSize = 12;
							LayoutOrder = i;
							ZIndex = 21;
							Parent = menu;
						}, {
							instancep = "BackgroundColor3";
							tinstance = library.MainColor;
						}, {
							instancep = "TextColor3";
							tinstance = library.FontColor;
						}, {
							instancep = "Font";
							tinstance = library.Font;
						})

						addConnection(option.Activated, function()
							selectedPreset = preset
							presetButton.Text = "Curve: " .. preset .. "  v"
							menu.Visible = false
							renderGraph()
							notifyChanged()
						end)
					end

					addConnection(presetButton.Activated, function()
						menu.Visible = not menu.Visible
					end)
				end

				local resetButton = library:Create("TextButton", {
					Name = "ResetGraph";
					Position = UDim2.new(0, 6, 1, -25);
					Size = UDim2.new(1, -12, 0, 20);
					BackgroundColor3 = library.MainColor;
					Text = "Reset Graph";
					TextColor3 = library.FontColor;
					Font = library.Font;
					TextSize = 12;
					BorderSizePixel = 0;
					ZIndex = 10;
					Parent = framewindow;
				}, {
					instancep = "BackgroundColor3";
					tinstance = library.MainColor;
				}, {
					instancep = "TextColor3";
					tinstance = library.FontColor;
				}, {
					instancep = "Font";
					tinstance = library.Font;
				})

				addConnection(resetButton.Activated, function()
					table.clear(graphsets)
					renderGraph()
					notifyChanged()
				end)

				addConnection(GraphHolder:GetPropertyChangedSignal("AbsoluteSize"), function()
					if opened then renderGraph() end
				end)

				outsideConn = UIS.InputBegan:Connect(function(input)
					if not opened or not instance or not instance.Parent then return end
					if input.UserInputType ~= Enum.UserInputType.MouseButton1
						and input.UserInputType ~= Enum.UserInputType.Touch then return end
					local position = input.Position
					local topLeft = framewindow.AbsolutePosition
					local bottomRight = topLeft + framewindow.AbsoluteSize
					local inWindow =
						position.X >= topLeft.X and position.X <= bottomRight.X
						and position.Y >= topLeft.Y and position.Y <= bottomRight.Y
					local buttonPos = buttonopen.AbsolutePosition
					local buttonSize = buttonopen.AbsoluteSize
					local inButton =
						position.X >= buttonPos.X and position.X <= buttonPos.X + buttonSize.X
						and position.Y >= buttonPos.Y and position.Y <= buttonPos.Y + buttonSize.Y
					if not inWindow and not inButton then
						closeGraph()
					end
				end)

				if trackConnection then trackConnection(outsideConn) end

				task.defer(function()
					if opened and GraphHolder.Parent then
						renderGraph()
					end
				end)
			end

			closeGraph = function()
				if not opened then return end
				opened = false
				clearOpenConnections()
				if instance then
					instance:Destroy()
					instance = nil
				end
			end

			buttonConnection = buttonopen.Activated:Connect(function()
				if destroyed then return end
				if opened then closeGraph() else openGraph() end
			end)

			if trackConnection then trackConnection(buttonConnection) end

			-- Public API
			function linegraph:Get() return getData() end

			function linegraph:Set(values)
				if destroyed then return end
				graphsets = copyPoints(values)
				curvePoints = #graphsets
				if opened then closeGraph() openGraph() end
				notifyChanged()
			end

			function linegraph:Reset()
				if destroyed then return end
				graphsets = {}
				curvePoints = 0
				if opened then closeGraph() openGraph() end
				notifyChanged()
			end

			function linegraph:SetPreset(preset)
				if destroyed then return false end
				for _, name in ipairs(presets) do
					if name == preset then
						selectedPreset = name
						if opened then closeGraph() openGraph() end
						notifyChanged()
						return true
					end
				end
				return false
			end

			-- Called by library:Toggle() to shut the popup when the menu hides
			function linegraph:Close()
				if opened then closeGraph() end
				return self
			end

			function linegraph:Destroy()
				if destroyed then return end
				destroyed = true
				closeGraph()
				disconnectConnection(buttonConnection)
				buttonConnection = nil
				clearOpenConnections()
				clearPointConnections()
				if holder then
					holder:Destroy()
					holder = nil
				end
			end

			function linegraph:GetValue() return getData() end
			function linegraph:SetValue(values) self:Set(values) return self end

			linegraph.Type = "LineGraph"
			linegraph.OnChanged = newSignal()
			library.Options = library.Options or Options or {}
			library.Options[text] = linegraph
			if Options then Options[text] = linegraph end

			-- Register so library:Toggle() can close it
			library.windowinstances.LineGraphBox = linegraph

			if opts.Tooltip then attachTooltip(holder, opts.Tooltip) end

			return linegraph
		end

		return groupbox
	end
	
    local function MakeGroupbox(holderForGroupbox, title)
        local groupboxf = library:Create("Frame", {
            Name = "Groupbox";
            Size = UDim2.new(0.95, 0, 0, 0);
            Position = UDim2.new(0, 0, 0, 0);
            BackgroundColor3 = library.MainColor;
            AutomaticSize = Enum.AutomaticSize.Y;
            LayoutOrder = #holderForGroupbox:GetChildren();
            Parent = holderForGroupbox;
        }, {
            instancep = "BackgroundColor3";
            tinstance = library.MainColor;
        })

        library:Create("UIStroke", {
            Name = "UIStroke";
            Parent = groupboxf;
            Thickness = 1;
            Color = library.SecondaryColor;
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        }, {
            instancep = "Color";
            tinstance = library.SecondaryColor;
        })

        library:Create("UIListLayout", {
            Name = "uil";
            FillDirection = Enum.FillDirection.Vertical;
            Padding = UDim.new(0, 1);
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = groupboxf;
        })

        library:Create("UIPadding", {
            Name = "uip";
            PaddingBottom = UDim.new(0, 4);
            Parent = groupboxf;
        })

        library:Create("UICorner", {
            Name = "UICorner";
            CornerRadius = UDim.new(0, 3);
            Parent = groupboxf;
        })

        local titleLabel = library:Create("TextLabel", {
            Name = "Title";
            Size = UDim2.new(1, 0, 0, 20);
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

        library:Create("UIStroke", {
            Name = "UIStroke";
            Parent = titleLabel;
            Thickness = 1;
            Color = library.UIstroke;
        }, {
            instancep = "Color";
            tinstance = library.UIstroke;
        })

        library:Create("UITextSizeConstraint", {
            Name = "uit";
            MaxTextSize = 14;
            Parent = titleLabel;
        })

        library:Create("UIPadding", {
            Name = "uip";
            PaddingTop = UDim.new(0, 3);
            Parent = titleLabel;
        })

        local elementsholder = library:Create("Frame", {
            Name = "elem";
            Size = UDim2.new(1, 0, 0, 0);
            BackgroundTransparency = 1;
            LayoutOrder = 1;
            AutomaticSize = Enum.AutomaticSize.Y;
            Parent = groupboxf;
        })

        library:Create("UIListLayout", {
            Name = "UIListLayout";
            FillDirection = Enum.FillDirection.Horizontal;
            Wraps = true;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Padding = UDim.new(0, 5);
            Parent = elementsholder;
        })

        library:Create("UIPadding", {
            Name = "UIPadding";
            PaddingTop = UDim.new(0, 3);
            Parent = elementsholder;
        })

        
        return MakeAPI(elementsholder)
    end

    -- ══════════════════════════════════════════════════════════
    -- NEW TAB
    -- ══════════════════════════════════════════════════════════

    local tabs = {}
    local currentTab = nil

    function window:NewTab(name, image, desc)
        local tab = {}

        -- Tab button (v3 layout)
        local tabButton = library:Create("Frame", {
            Name = name;
            Size = UDim2.fromOffset(146, 83);
            BackgroundTransparency = 1;
            LayoutOrder = #tabsHolder:GetChildren();
            Parent = tabsHolder;
        })

        local tabIcon = library:Create("ImageLabel", {
            Name = "ImageLabel";
            Size = UDim2.new(0.435, 0, 0.6, 0);
            Position = UDim2.new(0.283, 0, 0.092, 0);
            BackgroundTransparency = 1;
            ScaleType = Enum.ScaleType.Fit;
            Image = image or "";
            ImageColor3 = library.AccentColor;
            Parent = tabButton;
        }, {
            instancep = "ImageColor3";
            tinstance = library.AccentColor;
        })

        local tabLabel = library:Create("TextLabel", {
            Name = "TextLabel";
            Size = UDim2.new(1, 0, 0.22, 0);
            Position = UDim2.new(0, 0, 0.76, 0);
            BackgroundTransparency = 1;
            Text = name;
            TextColor3 = library.FontColor;
            Font = library.Font;
            TextSize = 15;
            TextScaled = true;
            TextWrapped = true;
            Parent = tabButton;
        }, {
            instancep = "TextColor3";
            tinstance = library.FontColor;
        }, {
            instancep = "Font";
            tinstance = library.Font;
        })

        library:Create("UITextSizeConstraint", {
            MaxTextSize = 15;
            Parent = tabLabel;
        })

        local tabHitbox = library:Create("TextButton", {
            Name = "button";
            Size = UDim2.new(1, 0, 1, 0);
            BackgroundTransparency = 1;
            Text = "";
            ZIndex = 2;
            Parent = tabButton;
        })

        -- Page
        local page = library:Create("Frame", {
            Name = name;
            Size = UDim2.new(1, 0, 1, 0);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Visible = false;
            Parent = intabsFrame;
        })

        local intabsF = library:Create("Frame", {
            Name = "intabs";
            Size = UDim2.new(1, 0, 1, 0);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Parent = page;
        })

        -- normalmain
        local normalMain = library:Create("Frame", {
            Name = "normalmain";
            Size = UDim2.new(1, 0, 1, 0);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Parent = intabsF;
        })

        -- Header
        local headerFrame = library:Create("Frame", {
            Name = "Header";
            Size = UDim2.new(1, 0, 0, 37);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
			Parent = intabsF;
        })

        library:Create("UIListLayout", {
            VerticalAlignment = Enum.VerticalAlignment.Center;
            FillDirection = Enum.FillDirection.Horizontal;
            Padding = UDim.new(0, 12);
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = headerFrame;
        })

        library:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 15);
            Parent = headerFrame;
        })

        local headerIcon = library:Create("ImageLabel", {
            Name = "tabicon";
            Size = UDim2.fromOffset(20, 20);
            BackgroundTransparency = 1;
            ScaleType = Enum.ScaleType.Fit;
            Image = image or "";
            ImageColor3 = library.AccentColor;
            Parent = headerFrame;
        }, {
            instancep = "ImageColor3";
            tinstance = library.AccentColor;
        })

        local headerName = library:Create("TextLabel", {
            Name = "tabname";
            Size = UDim2.fromOffset(0, 20);
            AutomaticSize = Enum.AutomaticSize.X;
            BackgroundTransparency = 1;
            Text = name;
            TextColor3 = library.FontColor;
            Font = library.Font;
            TextSize = 14;
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            Parent = headerFrame;
        }, {
            instancep = "TextColor3";
            tinstance = library.FontColor;
        }, {
            instancep = "Font";
            tinstance = library.Font;
        })

        library:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 3);
            PaddingRight = UDim.new(0, 3);
            Parent = headerName;
        })

        library:Create("UITextSizeConstraint", {
            MaxTextSize = 14;
            Parent = headerName;
        })

        local headerDesc = library:Create("TextLabel", {
            Name = "tabdesc";
            LayoutOrder = 2;
            Size = UDim2.fromOffset(0, 20);
            AutomaticSize = Enum.AutomaticSize.X;
            BackgroundTransparency = 1;
            Text = desc or "";
            TextColor3 = Color3.fromRGB(110, 110, 110);
            Font = library.Font;
            TextSize = 12;
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            Parent = headerFrame;
        })

        library:Create("UITextSizeConstraint", {
            MaxTextSize = 12;
            Parent = headerDesc;
        })

        -- Left/Right
        local leftCol = library:Create("ScrollingFrame", {
            Name = "Left";
            Size = UDim2.new(0.5, 0, 0.851, 0);
            Position = UDim2.new(0, 0, 0.069, 0);
            BackgroundTransparency = 1;
            ScrollBarThickness = 0;
            AutomaticCanvasSize = Enum.AutomaticSize.Y;
            CanvasSize = UDim2.new(0, 0, 0, 0);
            ScrollingDirection = Enum.ScrollingDirection.Y;
            Parent = normalMain;
        })

        library:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 2);
            PaddingRight = UDim.new(0, 2);
            PaddingTop = UDim.new(0, 10);
            PaddingBottom = UDim.new(0, 10);
            Parent = leftCol;
        })

        library:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Padding = UDim.new(0, 4);
            Parent = leftCol;
        })

        local rightCol = library:Create("ScrollingFrame", {
            Name = "Right";
            Size = UDim2.new(0.5, 0, 0.851, 0);
            Position = UDim2.new(0.5, 0, 0.069, 0);
            BackgroundTransparency = 1;
            ScrollBarThickness = 0;
            AutomaticCanvasSize = Enum.AutomaticSize.Y;
            CanvasSize = UDim2.new(0, 0, 0, 0);
            ScrollingDirection = Enum.ScrollingDirection.Y;
            Parent = normalMain;
        })

        library:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 2);
            PaddingRight = UDim.new(0, 2);
            PaddingTop = UDim.new(0, 10);
            PaddingBottom = UDim.new(0, 10);
            Parent = rightCol;
        })

        library:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Padding = UDim.new(0, 4);
            Parent = rightCol;
        })

        -- Bottom intab scroller
        local intabsScroll = library:Create("ScrollingFrame", {
            Name = "Intabsscroll";
            Size = UDim2.new(1, 0, 0, 35);
            Position = UDim2.new(0, 0, 0.92, 0);
            BackgroundTransparency = 1;
            ScrollBarThickness = 0;
            AutomaticCanvasSize = Enum.AutomaticSize.X;
            CanvasSize = UDim2.new(0, 0, 0, 0);
            ScrollingDirection = Enum.ScrollingDirection.X;
            Parent = intabsF;
        })

        library:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal;
            VerticalAlignment = Enum.VerticalAlignment.Center;
            Padding = UDim.new(0, 4);
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = intabsScroll;
        })

        library:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 8);
            PaddingRight = UDim.new(0, 8);
            PaddingTop = UDim.new(0, 8);
            PaddingBottom = UDim.new(0, 8);
            Parent = intabsScroll;
        })

        -- Main intab button
        local mainIntabBtn = library:Create("Frame", {
            Name = "Main";
            Size = UDim2.fromOffset(90, 27);
            BackgroundTransparency = 1;
            AutomaticSize = Enum.AutomaticSize.X;
            LayoutOrder = 1;
            Parent = intabsScroll;
        })

        library:Create("UICorner", {
            CornerRadius = UDim.new(0, 11);
            Parent = mainIntabBtn;
        })

        library:Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            Thickness = 1;
            Color = library.SecondaryColor;
            Parent = mainIntabBtn;
        }, {
            instancep = "Color";
            tinstance = library.SecondaryColor;
        })

        local mainIntabShadow = library:Create("UIShadow", {
            Color = library.AccentColor;
            Transparency = 0.88;
            BlurRadius = UDim.new(0, 15);
            Enabled = true;
            Parent = mainIntabBtn;
        }, {
            instancep = "Color";
            tinstance = library.AccentColor;
        })

        local mainIntabButton = library:Create("TextButton", {
            Name = "IntabButton";
            Size = UDim2.new(1, 0, 1, 0);
            BackgroundTransparency = 1;
            Text = "";
            ZIndex = 2;
            Parent = mainIntabBtn;
        })

        local mainIntabTitle = library:Create("TextLabel", {
            Name = "IntabName";
            Size = UDim2.new(1, -16, 1, 0);
            Position = UDim2.new(0, 8, 0, 0);
            BackgroundTransparency = 1;
            Text = "Main";
            TextColor3 = library.FontColor;
            Font = library.Font;
            TextSize = 15;
            TextXAlignment = Enum.TextXAlignment.Center;
            Parent = mainIntabBtn;
        }, {
            instancep = "TextColor3";
            tinstance = library.FontColor;
        }, {
            instancep = "Font";
            tinstance = library.Font;
        })

        -- Intab registry + selection
        local intabs = {}
        local currentIntab = normalMain

        mainIntabButton.Activated:Connect(function()
            if currentIntab == normalMain then return end
            currentIntab = normalMain
            normalMain.Visible = true
            mainIntabShadow.Enabled = true
            for _, other in pairs(intabs) do
                other.Frame.Visible = false
                other.Shadow.Enabled = false
            end
        end)

        -- Tab:Intab
        function tab:Intab(intabName, intabImage)
            local intab = {}

            local intabBtnFrame = library:Create("Frame", {
                Name = intabName;
                Size = UDim2.new(0.206, 0, -0.2, 33);
                BackgroundTransparency = 1;
                AutomaticSize = Enum.AutomaticSize.X;
                LayoutOrder = #intabsScroll:GetChildren();
                Parent = intabsScroll;
            })

            library:Create("UICorner", {
                CornerRadius = UDim.new(0, 11);
                Parent = intabBtnFrame;
            })

            library:Create("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Thickness = 1;
                Color = library.SecondaryColor;
                Parent = intabBtnFrame;
            }, {
                instancep = "Color";
                tinstance = library.SecondaryColor;
            })

            local intabShadow = library:Create("UIShadow", {
                Color = library.AccentColor;
                Transparency = 0.88;
                BlurRadius = UDim.new(0, 15);
                Enabled = false;
                Parent = intabBtnFrame;
            }, {
                instancep = "Color";
                tinstance = library.AccentColor;
            })

            local intabBtn = library:Create("TextButton", {
                Name = "IntabButton";
                Size = UDim2.new(1, 0, 1, 0);
                BackgroundTransparency = 1;
                Text = "";
                ZIndex = 2;
                Parent = intabBtnFrame;
            })

            local intabBtnHolder = library:Create("Frame", {
                Name = "IntabHolder";
                Size = UDim2.new(1, 0, 1, 0);
                BackgroundTransparency = 1;
                AutomaticSize = Enum.AutomaticSize.X;
                Parent = intabBtnFrame;
            })

            library:Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                VerticalAlignment = Enum.VerticalAlignment.Center;
                Padding = UDim.new(0, 8);
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = intabBtnHolder;
            })

            library:Create("ImageLabel", {
                Name = "Icon";
                Size = UDim2.fromOffset(20, 20);
                BackgroundTransparency = 1;
                LayoutOrder = 1;
                Image = intabImage or "";
                ImageColor3 = library.AccentColor;
                Parent = intabBtnHolder;
            }, {
                instancep = "ImageColor3";
                tinstance = library.AccentColor;
            })

            local intabLabel = library:Create("TextLabel", {
                Name = "IntabName";
                Size = UDim2.fromOffset(0, 20);
                AutomaticSize = Enum.AutomaticSize.X;
                BackgroundTransparency = 1;
                LayoutOrder = 2;
                Text = intabName;
                TextColor3 = library.FontColor;
                Font = library.Font;
                TextSize = 15;
                TextXAlignment = Enum.TextXAlignment.Center;
                Parent = intabBtnHolder;
            }, {
                instancep = "TextColor3";
                tinstance = library.FontColor;
            }, {
                instancep = "Font";
                tinstance = library.Font;
            })

            library:Create("UITextSizeConstraint", {
                MaxTextSize = 15;
                Parent = intabLabel;
            })

            -- Intab page
            local intabPage = library:Create("Frame", {
                Name = intabName;
                Size = UDim2.new(1, 0, 1, 0);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Visible = false;
                Parent = intabsF;
            })

            local intabLeft = library:Create("ScrollingFrame", {
                Name = "Left";
                Size = UDim2.new(0.5, 0, 0.851, 0);
                Position = UDim2.new(0, 0, 0.069, 0);
                BackgroundTransparency = 1;
                ScrollBarThickness = 0;
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                CanvasSize = UDim2.new(0, 0, 0, 0);
                ScrollingDirection = Enum.ScrollingDirection.Y;
                Parent = intabPage;
            })

            library:Create("UIPadding", {
                PaddingLeft = UDim.new(0, 2);
                PaddingRight = UDim.new(0, 2);
                PaddingTop = UDim.new(0, 10);
                PaddingBottom = UDim.new(0, 10);
                Parent = intabLeft;
            })

            library:Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                Padding = UDim.new(0, 4);
                Parent = intabLeft;
            })

            local intabRight = library:Create("ScrollingFrame", {
                Name = "Right";
                Size = UDim2.new(0.5, 0, 0.851, 0);
                Position = UDim2.new(0.5, 0, 0.069, 0);
                BackgroundTransparency = 1;
                ScrollBarThickness = 0;
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                CanvasSize = UDim2.new(0, 0, 0, 0);
                ScrollingDirection = Enum.ScrollingDirection.Y;
                Parent = intabPage;
            })

            library:Create("UIPadding", {
                PaddingLeft = UDim.new(0, 2);
                PaddingRight = UDim.new(0, 2);
                PaddingTop = UDim.new(0, 10);
                PaddingBottom = UDim.new(0, 10);
                Parent = intabRight;
            })

            library:Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                Padding = UDim.new(0, 4);
                Parent = intabRight;
            })

            intabBtn.Activated:Connect(function()
                if currentIntab == intab then return end
                normalMain.Visible = false
                mainIntabShadow.Enabled = false
                intabPage.Visible = true
                intabShadow.Enabled = true
                currentIntab = intab
                for _, other in pairs(intabs) do
                    if other ~= intab then
                        other.Frame.Visible = false
                        other.Shadow.Enabled = false
                    end
                end
            end)

            intab.Frame = intabPage
            intab.Shadow = intabShadow
            intabs[intabName] = intab

            function intab:AddLeftGroupbox(t)
                return MakeGroupbox(intabLeft, t)
            end

            function intab:AddRightGroupbox(t)
                return MakeGroupbox(intabRight, t)
            end

            return intab
        end

        -- Tab methods
        function tab:AddLeftGroupbox(t)
            return MakeGroupbox(leftCol, t)
        end

        function tab:AddRightGroupbox(t)
            return MakeGroupbox(rightCol, t)
        end

        function tab:Open()
            if currentTab == tab then return end
            page.Visible = true
            currentTab = tab
            for _, other in pairs(tabs) do
                if other ~= tab then
                    other:Close()
                end
            end
        end

        function tab:Close()
            page.Visible = false
            if currentTab == tab then
                currentTab = nil
            end
        end

        tabs[name] = tab

        tabHitbox.Activated:Connect(function()
            tab:Open()
        end)

        -- Auto-open the very first tab
        local tabCount = 0
        for _, child in ipairs(tabsHolder:GetChildren()) do
            if child:GetAttribute("NocturneTab") then
                tabCount = tabCount + 1
            end
        end
        tabButton:SetAttribute("NocturneTab", true)

        if tabCount == 0 then
            tab:Open()
        end

        return tab
    end

    -- Register window
    window.MainFrame = mainWindow
    window.Config = configuration
    library.MainFrame = library.MainFrame or mainWindow
    table.insert(library.mainwindows, window)

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

	trackConnection(mainwmframe.InputBegan:Connect(function(input)
		if configuration.Draggable == false then return end
		if dragging then return end

		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPos = mainwmframe.Position

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
	end))

	trackConnection(InputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end))

	return wm
end

function library:Hotkeys(configuration)
	configuration = configuration or {}

	local hotkeys = {}
	local UIS = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")

	local visible = configuration.Visible == true
	local activeOnly = configuration.ActiveOnly == true
	local destroyed = false
	local connections = {}
	local rows = {}

	local width = math.max(160, tonumber(configuration.Width) or 260)
	local rowHeight = 20
	local headerHeight = 27
	local refreshInterval = 0.05

	local dragging = false
	local dragInput
	local dragStart
	local startPosition
	local dragclone

	local function connect(signal, callback)
		local connection = signal:Connect(callback)
		table.insert(connections, connection)

		if trackConnection then
			trackConnection(connection)
		end

		return connection
	end

	local main = library:Create("Frame", {
		Name = "Hotkeys";
		Size = UDim2.fromOffset(width, headerHeight);
		Position = configuration.Position
			or UDim2.new(0, 20, 0.35, 0);
		AnchorPoint = Vector2.new(0, 0);
		BackgroundColor3 = library.MainColor;
		BorderSizePixel = 0;
		Visible = visible;
		ZIndex = 20;
		Parent = screengui;
	}, {
		instancep = "BackgroundColor3";
		tinstance = library.MainColor;
	})

	local outerStroke = library:Create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode = Enum.LineJoinMode.Miter;
		Color = library.MainColor;
		Thickness = 3;
		Parent = main;
	})

	local borderStroke = library:Create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode = Enum.LineJoinMode.Miter;
		Color = library.SecondaryColor;
		Thickness = 1;
		Parent = main;
	})

	local accent = library:Create("Frame", {
		Name = "Accent";
		Size = UDim2.new(1, 0, 0, 1);
		BackgroundColor3 = library.AccentColor;
		BorderSizePixel = 0;
		ZIndex = 22;
		Parent = main;
	})

	local header = library:Create("TextButton", {
		Name = "Header";
		Size = UDim2.new(1, 0, 0, headerHeight);
		BackgroundTransparency = 1;
		AutoButtonColor = false;
		Active = true;
		Text = tostring(configuration.Title or "Hotkeys");
		TextSize = 14;
		Font = library.Font;
		TextColor3 = library.FontColor;
		ZIndex = 21;
		Parent = main;
	})

	local headerStroke = library:Create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
		Color = library.UIstroke
			or library.UIStroke
			or library.SecondaryColor;
		Thickness = 1;
		Parent = header;
	})

	local separator = library:Create("Frame", {
		Name = "Separator";
		Position = UDim2.fromOffset(0, headerHeight - 1);
		Size = UDim2.new(1, 0, 0, 1);
		BackgroundColor3 = library.SecondaryColor;
		BorderSizePixel = 0;
		Visible = false;
		ZIndex = 21;
		Parent = main;
	})

	local body = library:Create("Frame", {
		Name = "Entries";
		Position = UDim2.fromOffset(8, headerHeight + 3);
		Size = UDim2.new(1, -16, 0, 0);
		BackgroundTransparency = 1;
		ZIndex = 21;
		Parent = main;
	})

	local shortcuts = {
		LeftControl = "LCtrl",
		RightControl = "RCtrl",
		LeftShift = "LShift",
		RightShift = "RShift",
		LeftAlt = "LAlt",
		RightAlt = "RAlt",
		MouseButton1 = "M1",
		MouseButton2 = "M2",
		MouseButton3 = "M3",
	}

	local function keyText(key)
		if key == nil then
			return "None"
		end

		local name

		if typeof(key) == "EnumItem" then
			name = key.Name
		else
			name = tostring(key):match("([^%.]+)$")
		end

		return shortcuts[name] or name or "None"
	end

	local function isBound(key)
		local name = keyText(key)

		return name ~= "None"
			and name ~= "Unknown"
			and name ~= ""
	end

	local function collectEntries()
		local entries = {}
		local owners = {}
		local seen = {}

		-- A toggle keypicker's active state belongs to its toggle.
		local function scanToggles(registry)
			if type(registry) ~= "table" then
				return
			end

			for name, toggle in pairs(registry) do
				if type(toggle) == "table" then
					local picker = toggle.keypicker or toggle.KeyPicker

					if type(picker) == "table" then
						owners[picker] = {
							Name = tostring(name),
							Toggle = toggle,
						}
					end
				end
			end
		end

		scanToggles(Toggles)
		scanToggles(library.Toggles)

		local function addPicker(name, picker)
			if type(picker) ~= "table" or seen[picker] then
				return
			end

			-- Distinguish keypickers from sliders/other options.
			if picker.Mode == nil then
				return
			end

			seen[picker] = true

			if not isBound(picker.Key) then
				return
			end

			local owner = owners[picker]
			local active

			if owner then
				local value = owner.Toggle.Value

				if value == nil then
					value = owner.Toggle.value
				end

				active = value == true
			else
				active = picker.Value == true
					or picker.Mode == "Always"
			end

			if activeOnly and not active then
				return
			end

			table.insert(entries, {
				Picker = picker,
				Name = owner and owner.Name or tostring(name),
				Key = keyText(picker.Key),
				Mode = string.lower(tostring(picker.Mode)),
				Active = active,
			})
		end

		-- Include attached pickers even if an option name was reused.
		for picker, owner in pairs(owners) do
			addPicker(owner.Name, picker)
		end

		local function scanOptions(registry)
			if type(registry) ~= "table" then
				return
			end

			for name, option in pairs(registry) do
				addPicker(name, option)
			end
		end

		scanOptions(Options)
		scanOptions(library.Options)

		table.sort(entries, function(a, b)
			local left = string.lower(a.Name)
			local right = string.lower(b.Name)

			if left == right then
				if a.Key == b.Key then
					return a.Mode < b.Mode
				end

				return a.Key < b.Key
			end

			return left < right
		end)

		return entries
	end

	local function createRow()
		local label = library:Create("TextLabel", {
			Name = "Hotkey";
			Size = UDim2.new(1, 0, 0, rowHeight);
			BackgroundTransparency = 1;
			Text = "";
			TextSize = 13;
			Font = library.Font;
			TextColor3 = library.FontColor;
			TextXAlignment = Enum.TextXAlignment.Left;
			TextTruncate = Enum.TextTruncate.AtEnd;
			ZIndex = 21;
			Parent = body;
		})

		local stroke = library:Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
			Color = library.UIstroke
				or library.UIStroke
				or library.SecondaryColor;
			Thickness = 1;
			Parent = label;
		})

		return {
			Label = label,
			Stroke = stroke,
		}
	end

	local function refresh()
		if destroyed then
			return
		end

		local entries = collectEntries()
		local strokeColor = library.UIstroke
			or library.UIStroke
			or library.SecondaryColor

		main.BackgroundColor3 = library.MainColor
		outerStroke.Color = library.MainColor
		borderStroke.Color = library.SecondaryColor
		accent.BackgroundColor3 = library.AccentColor
		separator.BackgroundColor3 = library.SecondaryColor
		separator.Visible = #entries > 0

		header.Font = library.Font
		header.TextColor3 = library.FontColor
		headerStroke.Color = strokeColor

		for index, entry in ipairs(entries) do
			local row = rows[index]

			if not row then
				row = createRow()
				rows[index] = row
			end

			local label = row.Label

			label.Visible = true
			label.Position = UDim2.fromOffset(
				0,
				(index - 1) * rowHeight
			)

			label.Text = string.format(
				"%s [%s] [%s]",
				entry.Name,
				entry.Key,
				entry.Mode
			)

			label.Font = library.Font
			label.TextColor3 = entry.Active
				and library.AccentColor
				or library.FontColor

			row.Stroke.Color = strokeColor
		end

		-- Remove surplus UI instead of keeping unused rows.
		for index = #rows, #entries + 1, -1 do
			rows[index].Label:Destroy()
			rows[index] = nil
		end

		local bodyHeight = #entries * rowHeight
		local height = headerHeight

		if #entries > 0 then
			height = height + bodyHeight + 6
		end

		body.Size = UDim2.new(1, -16, 0, bodyHeight)
		main.Size = UDim2.fromOffset(width, height)

		if dragclone then
			dragclone.Size = main.Size
		end
	end

	local function finishDrag(commit)
		if not dragging then
			return
		end

		dragging = false
		dragInput = nil

		if dragclone then
			if commit then
				main.Position = dragclone.Position
			end

			dragclone:Destroy()
			dragclone = nil
		end

		if not destroyed then
			main.Visible = visible
		end
	end

	connect(header.InputBegan, function(input)
		if destroyed
			or not visible
			or dragging
			or configuration.Draggable == false then
			return
		end

		local inputType = input.UserInputType

		if inputType ~= Enum.UserInputType.MouseButton1
			and inputType ~= Enum.UserInputType.Touch then
			return
		end

		dragging = true
		dragInput = input
		dragStart = input.Position
		startPosition = main.Position

		dragclone = library:Create("Frame", {
			Name = "HotkeysDragPreview";
			Size = main.Size;
			Position = main.Position;
			AnchorPoint = main.AnchorPoint;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			ZIndex = 100;
			Parent = screengui;
		})

		library:Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			Color = library.AccentColor;
			Thickness = 1;
			Parent = dragclone;
		})

		main.Visible = false
	end)

	connect(UIS.InputChanged, function(input)
		if not dragging or not dragclone then
			return
		end

		local touchDrag = dragInput.UserInputType
			== Enum.UserInputType.Touch

		if touchDrag then
			if input ~= dragInput then
				return
			end
		elseif input.UserInputType
			~= Enum.UserInputType.MouseMovement then
			return
		end

		local delta = input.Position - dragStart

		dragclone.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)

	connect(UIS.InputEnded, function(input)
		if not dragging then
			return
		end

		if input == dragInput
			or (
				dragInput.UserInputType
					== Enum.UserInputType.MouseButton1
					and input.UserInputType
					== Enum.UserInputType.MouseButton1
			) then
			finishDrag(true)
		end
	end)

	connect(UIS.WindowFocusReleased, function()
		finishDrag(true)
	end)

	function hotkeys:ToggleVisibility(value)
		if destroyed then
			return self
		end

		if value == nil then
			visible = not visible
		else
			visible = value == true
		end

		if not visible then
			finishDrag(true)
		else
			refresh()
		end

		main.Visible = visible and not dragging
		return self
	end

	function hotkeys:SetVisibility(value)
		return self:ToggleVisibility(value)
	end

	function hotkeys:GetVisibility()
		return visible
	end

	function hotkeys:SetPosition(position)
		if destroyed then
			return self
		end

		assert(
			typeof(position) == "UDim2",
			"Hotkeys:SetPosition expects a UDim2"
		)

		finishDrag(false)
		main.Position = position
		return self
	end

	function hotkeys:GetPosition()
		return main.Position
	end

	function hotkeys:SetTitle(text)
		if not destroyed then
			header.Text = tostring(text or "Hotkeys")
		end

		return self
	end

	function hotkeys:SetActiveOnly(value)
		if not destroyed then
			activeOnly = value == true
			refresh()
		end

		return self
	end

	function hotkeys:Refresh()
		refresh()
		return self
	end

	local function cleanup()
		if destroyed then
			return
		end

		destroyed = true
		visible = false
		finishDrag(false)

		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		table.clear(connections)
		table.clear(rows)
	end

	function hotkeys:Destroy()
		if destroyed then
			return
		end

		cleanup()
		main:Destroy()
	end

	connect(main.Destroying, cleanup)

	local elapsed = 0

	connect(RunService.Heartbeat, function(deltaTime)
		if destroyed or not visible then
			return
		end

		elapsed = elapsed + deltaTime

		if elapsed >= refreshInterval then
			elapsed = 0
			refresh()
		end
	end)

	hotkeys.Instance = main

	refresh()
	return hotkeys
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

--==========================================================
-- FULL LIBRARY UNLOAD
--==========================================================
function library:Unload()
	if not library or library._unloaded then
		return
	end

	library._unloaded = true

	if type(library.OnUnloaded) == "function" then
		pcall(library.OnUnloaded)
	end

	for _, key in ipairs({
		"Colorbox",
		"Keybindbox",
		"Dropdown",
		}) do
		local item = library.windowinstances
			and library.windowinstances[key]

		if item and type(item.Close) == "function" then
			pcall(function()
				item:Close()
			end)
		end
	end

	for key, connection in pairs(connections) do
		if typeof(connection) == "RBXScriptConnection" then
			pcall(function()
				connection:Disconnect()
			end)
		end

		connections[key] = nil
	end

	for key, tween in pairs(tweens) do
		pcall(function()
			tween:Cancel()
		end)

		tweens[key] = nil
	end

	if library.extraeff then
		if type(library.extraeff.frames) == "table" then
			for _, frame in pairs(library.extraeff.frames) do
				pcall(function()
					frame:Destroy()
				end)
			end

			table.clear(library.extraeff.frames)
		end
	end

	for _, property in ipairs({
		"blureffect",
		"toggledbackground",
		}) do
		local instance = library[property]

		if instance then
			pcall(function()
				instance:Destroy()
			end)

			library[property] = nil
		end
	end

	for _, tab in pairs(library.Tabs or {}) do
		if tab and type(tab.Close) == "function" then
			pcall(function()
				tab:Close()
			end)
		end
	end

	table.clear(library.Tabs or {})
	table.clear(library.Registry or {})
	table.clear(library.DependencyBoxes or {})
	table.clear(library.windowinstances or {})
	table.clear(library.mainwindows or {})
	table.clear(library.otherwindows or {})

	if screengui then
		pcall(function()
			screengui:Destroy()
		end)
	end

	if _G.Library == library then
		_G.Library = nil
	end

	screengui = nil
end

trackConnection(InputService.InputBegan:Connect(function(input)
	if input.KeyCode == library.Menukey then
		library:Toggle()
	end
end))

_G.Library = library

return library
