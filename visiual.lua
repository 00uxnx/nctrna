local Library = {
	Font = Enum.Font.RobotoCondensed,
	Rainbow = false,
	Tracers = false,
	Unloaded = false,
	ShowDistance = false,
	MatchColors = true,
	Arrows = false,
	TextTransparency = 0,
	TracerOrigin = "Bottom",
	FillTransparency = 0.75,
	OutlineTransparency = 0,
	TextOutlineTransparency = 0,
	FadeTime = 0,
	RenderLimit = 240,
	TracerSize = 0.5,
	ArrowRadius = 200,
	TextSize = 20,
	DistanceSizeRatio = 1,
	OutlineColor = Color3.fromRGB(255, 255, 255),
	RainbowColor = Color3.fromRGB(255, 255, 255),

	-- Added visual configuration.
	VisualStyle = {
		Enabled = true,
		BackgroundColor = Color3.fromRGB(18, 22, 32),
		BackgroundTransparency = 0.12,
		BorderColor = Color3.fromRGB(100, 190, 255),
		BorderTransparency = 0.12,
		BorderThickness = 1,
		CornerRadius = 5,
		PanelWidth = 220,
		PanelHeight = 42,
		PanelPadding = 8,
		GradientEnabled = true,
		GradientColor1 = Color3.fromRGB(28, 35, 49),
		GradientColor2 = Color3.fromRGB(16, 20, 30),
		TextStrokeColor = Color3.fromRGB(0, 0, 0),
		DistanceColor = Color3.fromRGB(190, 205, 225),
		TracerMinimumThickness = 0.5,
		TracerMaximumThickness = 4,
	},

	ElementsEnabled = {},
	TransparencyEnabled = {},
	Highlights = {},
	Labels = {},
	Frames = {},
	Lines = {},
	ArrowsTable = {},
	ColorTable = {},
	TextTable = {},
	ConnectionsTable = {},
	Objects = {},
	TotalObjects = {},
}

local RainbowState = {
	HueSetup = 0,
	Hue = 0,
	Step = 0,
	Color = Color3.new(),
}

local CloneReference = cloneref or function(O)
	return O
end

local Players = CloneReference(game:GetService("Players"))
local CoreGui = getgenv
	and CloneReference(game:GetService("CoreGui"))
	or Players.LocalPlayer.PlayerGui

local Workspace = CloneReference(workspace)
local RunService = CloneReference(game:GetService("RunService"))
local TweenService = CloneReference(game:GetService("TweenService"))
local UserInputService = CloneReference(game:GetService("UserInputService"))
local Debris = CloneReference(game:GetService("Debris"))
local LocalPlayer = Players.LocalPlayer

local RainbowConnection
local CameraConnection

local function GetHiddenUI()
	if gethui then
		return gethui()
	end

	local Folder = Instance.new("Folder", CoreGui)
	Folder.Name = ("%032x"):format(math.random(0, 2^31))
	return Folder
end

function Library:GenerateRandomString()
	local Chars = {}
	local Pool = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local PoolLen = #Pool

	for I = 1, 24 do
		local Idx = math.random(1, PoolLen)
		Chars[I] = Pool:sub(Idx, Idx)
	end

	return table.concat(Chars)
end

local HiddenUI = GetHiddenUI()
local Camera = Workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Name = Library:GenerateRandomString()
ScreenGui.Parent = HiddenUI

local HighlightsFolder = Instance.new("Folder")
HighlightsFolder.Name = Library:GenerateRandomString()
HighlightsFolder.Parent = ScreenGui

local BillboardsFolder = Instance.new("Folder")
BillboardsFolder.Name = Library:GenerateRandomString()
BillboardsFolder.Parent = ScreenGui

local TracersFrame = Instance.new("Frame")
TracersFrame.Size = UDim2.new(1, 0, 1, 0)
TracersFrame.BackgroundTransparency = 1
TracersFrame.Visible = false
TracersFrame.Name = Library:GenerateRandomString()
TracersFrame.Parent = ScreenGui

local ArrowsFrame = Instance.new("Frame")
ArrowsFrame.Size = UDim2.new(1, 0, 1, 0)
ArrowsFrame.BackgroundTransparency = 1
ArrowsFrame.Visible = false
ArrowsFrame.Name = Library:GenerateRandomString()
ArrowsFrame.Parent = ScreenGui

local ArrowTemplate = Instance.new("ImageLabel")
ArrowTemplate.Image = "rbxassetid://16368985219"
ArrowTemplate.Size = UDim2.new(0, 34, 0, 34)
ArrowTemplate.AnchorPoint = Vector2.new(0.5, 0.5)
ArrowTemplate.BackgroundTransparency = 1
ArrowTemplate.ImageTransparency = 1

local ArrowConstraint = Instance.new("UIAspectRatioConstraint")
ArrowConstraint.AspectRatio = 1
ArrowConstraint.Name = Library:GenerateRandomString()
ArrowConstraint.Parent = ArrowTemplate

local function MakeTween(Instance_, Props)
	local Info = TweenInfo.new(
		math.max(0, Library.FadeTime),
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	return TweenService:Create(Instance_, Info, Props)
end

local function PlayTween(Instance_, Props)
	if Instance_ and Instance_.Parent then
		MakeTween(Instance_, Props):Play()
	end
end

--==============================================================
-- VISUAL HELPERS
--==============================================================

local function ApplyLabelStyle(Frame, Label, Color)
	local Style = Library.VisualStyle

	Frame.Size = UDim2.fromOffset(
		Style.PanelWidth,
		Style.PanelHeight
	)

	Frame.BackgroundColor3 = Style.BackgroundColor
	Frame.BackgroundTransparency = Style.BackgroundTransparency
	Frame.BorderSizePixel = 0
	Frame.ClipsDescendants = false

	local Corner = Instance.new("UICorner")
	Corner.Name = "BradarCorner"
	Corner.CornerRadius = UDim.new(0, Style.CornerRadius)
	Corner.Parent = Frame

	local Border = Instance.new("UIStroke")
	Border.Name = "BradarBorder"
	Border.Color = Color or Style.BorderColor
	Border.Thickness = Style.BorderThickness
	Border.Transparency = Style.BorderTransparency
	Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Border.Parent = Frame

	if Style.GradientEnabled then
		local Gradient = Instance.new("UIGradient")
		Gradient.Name = "BradarGradient"
		Gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(
				0,
				Style.GradientColor1
			),
			ColorSequenceKeypoint.new(
				1,
				Style.GradientColor2
			),
		})
		Gradient.Rotation = 90
		Gradient.Parent = Frame
	end

	local Padding = Instance.new("UIPadding")
	Padding.Name = "BradarPadding"
	Padding.PaddingLeft = UDim.new(0, Style.PanelPadding)
	Padding.PaddingRight = UDim.new(0, Style.PanelPadding)
	Padding.Parent = Label

	Label.BackgroundTransparency = 1
	Label.BorderSizePixel = 0
	Label.Size = UDim2.fromScale(1, 1)
	Label.Position = UDim2.fromScale(0, 0)
	Label.Font = Library.Font
	Label.TextSize = Library.TextSize
	Label.TextColor3 = Color or Color3.new(1, 1, 1)
	Label.TextStrokeColor3 = Style.TextStrokeColor
	Label.TextStrokeTransparency = Style.Enabled
		and 0.35
		or Library.TextOutlineTransparency
	Label.TextXAlignment = Enum.TextXAlignment.Center
	Label.TextYAlignment = Enum.TextYAlignment.Center
	Label.TextWrapped = false
	Label.RichText = true

	return Border
end

local function UpdateLabelStyle(Object)
	local Frame = Library.Frames[Object]
	local Label = Library.Labels[Object]

	if not Frame or not Label then
		return
	end

	local Style = Library.VisualStyle
	local Border = Frame:FindFirstChild("BradarBorder")

	Frame.Size = UDim2.fromOffset(
		Style.PanelWidth,
		Style.PanelHeight
	)

	Frame.BackgroundColor3 = Style.BackgroundColor
	Frame.BackgroundTransparency = Style.BackgroundTransparency

	if Border and Border:IsA("UIStroke") then
		Border.Color = Style.BorderColor
		Border.Transparency = Style.BorderTransparency
		Border.Thickness = Style.BorderThickness
	end
end

--==============================================================
-- OBJECT CLEANUP
--==============================================================

local function DestroyObjectData(Object)
	local Highlight = Library.Highlights[Object]
	if Highlight then
		Highlight:Destroy()
		Library.Highlights[Object] = nil
	end

	local Frame = Library.Frames[Object]
	if Frame then
		Frame:Destroy()
		Library.Frames[Object] = nil
	end

	local LineData = Library.Lines[Object]
	if LineData then
		if LineData[1] then
			LineData[1]:Destroy()
		end

		Library.Lines[Object] = nil
	end

	local Arrow = Library.ArrowsTable[Object]
	if Arrow then
		Arrow:Destroy()
		Library.ArrowsTable[Object] = nil
	end

	local Conns = Library.ConnectionsTable[Object]
	if Conns then
		for _, Conn in ipairs(Conns) do
			if Conn.Connected then
				Conn:Disconnect()
			end
		end

		Library.ConnectionsTable[Object] = nil
	end

	Library.Labels[Object] = nil
	Library.ColorTable[Object] = nil
	Library.TextTable[Object] = nil
	Library.ElementsEnabled[Object] = nil
	Library.TransparencyEnabled[Object] = nil
	Library.Objects[Object] = nil

	for Idx = #Library.TotalObjects, 1, -1 do
		if Library.TotalObjects[Idx] == Object then
			table.remove(Library.TotalObjects, Idx)
			break
		end
	end
end

--==============================================================
-- ADD ESP
--==============================================================

function Library:AddESP(Parameters)
	if Library.Unloaded then
		return
	end

	if type(Parameters) ~= "table" then
		return
	end

	local Object = Parameters.Object

	if not Object or not Object:IsA("Instance") then
		return
	end

	if Library.ElementsEnabled[Object] == true then
		return
	end

	if not Object:IsA("BasePart") and not Object:IsA("Model") then
		return
	end

	if not Camera then
		Camera = Workspace.CurrentCamera
	end

	if not Camera then
		return
	end

	Library.ElementsEnabled[Object] = true
	Library.TransparencyEnabled[Object] = false
	Library.ConnectionsTable[Object] =
		Library.ConnectionsTable[Object] or {}

	-- Highlight.
	if Library.Highlights[Object] then
		Library.Highlights[Object]:Destroy()
		Library.Highlights[Object] = nil
	end

	local Highlight = Instance.new("Highlight")
	Highlight.FillTransparency = 1
	Highlight.OutlineTransparency = 1
	Highlight.Name = Library:GenerateRandomString()
	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	Highlight.Adornee = Object
	Highlight.Parent = HighlightsFolder

	Library.Highlights[Object] = Highlight

	-- Label panel.
	local TextFrame = Instance.new("Frame")
	TextFrame.Visible = false
	TextFrame.Name = Library:GenerateRandomString()
	TextFrame.BackgroundTransparency = 1
	TextFrame.BorderSizePixel = 0
	TextFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	TextFrame.Parent = BillboardsFolder

	local TextLabel = Instance.new("TextLabel")
	TextLabel.Name = Library:GenerateRandomString()
	TextLabel.Text = tostring(Parameters.Text or "")
	TextLabel.TextTransparency = 1
	TextLabel.TextStrokeTransparency = 1
	TextLabel.Parent = TextFrame

	ApplyLabelStyle(
		TextFrame,
		TextLabel,
		Parameters.Color or Color3.new(1, 1, 1)
	)

	Library.Frames[Object] = TextFrame
	Library.Labels[Object] = TextLabel
	Library.ColorTable[Object] =
		Parameters.Color or Color3.new(1, 1, 1)
	Library.TextTable[Object] = tostring(Parameters.Text or "")
	Library.Objects[Object] = Object

	table.insert(Library.TotalObjects, Object)

	PlayTween(Highlight, {
		FillTransparency = Library.FillTransparency,
	})

	PlayTween(Highlight, {
		OutlineTransparency = Library.OutlineTransparency,
	})

	local TextFadeIn = MakeTween(TextLabel, {
		TextTransparency = Library.TextTransparency,
		TextStrokeTransparency = Library.TextOutlineTransparency,
	})

	TextFadeIn.Completed:Once(function()
		if Library.ElementsEnabled[Object] == true then
			Library.TransparencyEnabled[Object] = true
		end
	end)

	TextFadeIn:Play()

	-- Tracer.
	local LineFrame = Instance.new("Frame")
	LineFrame.Size = UDim2.new(0, 0, 0, 0)
	LineFrame.BackgroundTransparency = 1
	LineFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	LineFrame.Name = Library:GenerateRandomString()
	LineFrame.BorderSizePixel = 0
	LineFrame.Parent = TracersFrame

	local Stroke = Instance.new("UIStroke")
	Stroke.Thickness = Library.TracerSize
	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Stroke.Transparency = 1
	Stroke.Name = Library:GenerateRandomString()
	Stroke.Parent = LineFrame

	Library.Lines[Object] = { LineFrame, Stroke }

	--==========================================================
	-- RENDER LOOP
	--==========================================================

	task.spawn(function()
		local Last = 0

		local function Render()
			if Library.Unloaded then
				return
			end

			if not Object:IsDescendantOf(game) then
				Library:RemoveESP(Object)
				return
			end

			Camera = Workspace.CurrentCamera

			if not Camera then
				return
			end

			local Success, ObjectPivot = pcall(function()
				return Object:GetPivot()
			end)

			if not Success then
				return
			end

			local ObjectPos = ObjectPivot.Position
			local ScreenPoint, OnScreen =
				Camera:WorldToViewportPoint(ObjectPos)

			local Frame = Library.Frames[Object]
			local Label = Library.Labels[Object]
			local CachedHighlight = Library.Highlights[Object]
			local LineData = Library.Lines[Object]

			local IsVisible = OnScreen and ScreenPoint.Z > 0

			-- Label placement.
			if Frame then
				Frame.Visible = IsVisible

				if IsVisible then
					Frame.Position = UDim2.fromOffset(
						ScreenPoint.X,
						ScreenPoint.Y
					)
				end
			end

			-- Tracer visibility.
			if LineData and LineData[1] then
				LineData[1].Visible =
					Library.Tracers and IsVisible
			end

			-- Recreate the highlight if necessary.
			if not IsVisible then
				if CachedHighlight then
					CachedHighlight:Destroy()
					Library.Highlights[Object] = nil
					CachedHighlight = nil
				end
			elseif Library.ElementsEnabled[Object] == true
				and not CachedHighlight then

				CachedHighlight = Instance.new("Highlight")
				CachedHighlight.FillTransparency = 1
				CachedHighlight.OutlineTransparency = 1
				CachedHighlight.Name = Library:GenerateRandomString()
				CachedHighlight.DepthMode =
					Enum.HighlightDepthMode.AlwaysOnTop
				CachedHighlight.Adornee = Object
				CachedHighlight.Parent = HighlightsFolder

				Library.Highlights[Object] = CachedHighlight
			end

			local BaseColor = Library.ColorTable[Object]
				or Color3.new(1, 1, 1)

			local ActiveColor = Library.Rainbow
				and RainbowState.Color
				or BaseColor

			-- Text appearance.
			if Label then
				Label.TextColor3 = ActiveColor

				local Border = Frame
					and Frame:FindFirstChild("BradarBorder")

				if Border and Border:IsA("UIStroke") then
					Border.Color = Library.VisualStyle.BorderColor
				end
			end

			if CachedHighlight then
				local Distance = math.floor(
					(Camera.CFrame.Position - ObjectPos).Magnitude
				)

				local DistanceText = Library.ShowDistance
					and (
						"\n"
						.. '<font color="#'
						.. string.format(
							"%02X%02X%02X",
							math.floor(
								Library.VisualStyle.DistanceColor.R * 255
							),
							math.floor(
								Library.VisualStyle.DistanceColor.G * 255
							),
							math.floor(
								Library.VisualStyle.DistanceColor.B * 255
							)
						)
						.. '" size="'
						.. math.max(
							8,
							math.round(
								Library.TextSize
								* Library.DistanceSizeRatio
							)
						)
						.. '">['
						.. Distance
						.. "]</font>"
					)
					or ""

				if Label then
					Label.Text = Library.TextTable[Object] .. DistanceText
				end

				CachedHighlight.Enabled = true
				CachedHighlight.FillColor = ActiveColor

				CachedHighlight.OutlineColor =
					Library.MatchColors
					and ActiveColor
					or Library.OutlineColor

				if Library.TransparencyEnabled[Object] == true then
					CachedHighlight.FillTransparency =
						Library.FillTransparency

					CachedHighlight.OutlineTransparency =
						Library.OutlineTransparency

					if Label then
						Label.TextTransparency =
							Library.TextTransparency

						Label.TextStrokeTransparency =
							Library.TextOutlineTransparency
					end
				end
			end

			-- Tracer rendering.
			if LineData
				and LineData[1]
				and LineData[2]
				and Library.Tracers
				and IsVisible then

				local ScreenSize = Camera.ViewportSize
				local Origin

				if Library.TracerOrigin == "Center" then
					Origin = Vector2.new(
						ScreenSize.X / 2,
						ScreenSize.Y / 2
					)
				elseif Library.TracerOrigin == "Top" then
					Origin = Vector2.new(ScreenSize.X / 2, 0)
				elseif Library.TracerOrigin == "Mouse" then
					local MouseLoc =
						UserInputService:GetMouseLocation()

					Origin = Vector2.new(
						MouseLoc.X,
						MouseLoc.Y
					)
				else
					Origin = Vector2.new(
						ScreenSize.X / 2,
						ScreenSize.Y
					)
				end

				local Destination = Vector2.new(
					ScreenPoint.X,
					ScreenPoint.Y
				)

				local MidPoint = (Origin + Destination) / 2

				local Rotation = math.deg(math.atan2(
					Destination.Y - Origin.Y,
					Destination.X - Origin.X
				))

				local Length = (Origin - Destination).Magnitude
				local LF = LineData[1]
				local SK = LineData[2]

				LF.Position = UDim2.fromOffset(
					MidPoint.X,
					MidPoint.Y
				)

				LF.Size = UDim2.fromOffset(Length, 1)
				LF.Rotation = Rotation
				LF.BackgroundColor3 = ActiveColor
				LF.BorderSizePixel = 0
				LF.BackgroundTransparency = 0
				LF.Visible = true

				SK.Color = ActiveColor
				SK.Thickness = math.clamp(
					Library.TracerSize,
					Library.VisualStyle.TracerMinimumThickness,
					Library.VisualStyle.TracerMaximumThickness
				)

				SK.Transparency = 0
			elseif LineData and LineData[1] then
				LineData[1].Visible = false
			end

			-- Directional arrows.
			if Library.Arrows then
				local Arrow = Library.ArrowsTable[Object]

				if Arrow == nil
					and Library.ElementsEnabled[Object] == true then

					Arrow = ArrowTemplate:Clone()
					Arrow.Name = Library:GenerateRandomString()
					Arrow.Parent = ArrowsFrame

					Library.ArrowsTable[Object] = Arrow

					PlayTween(Arrow, {
						ImageTransparency = 0,
					})
				end

				if Arrow
					and Library.ElementsEnabled[Object] == true then

					if IsVisible then
						Arrow.Visible = false
					else
						local ScreenSize = Camera.ViewportSize

						local ScreenCenter = Vector2.new(
							ScreenSize.X / 2,
							ScreenSize.Y / 2
						)

						local ToObj =
							ObjectPos - Camera.CFrame.Position

						local Dir =
							Vector2.new(
								ScreenPoint.X,
								ScreenPoint.Y
							) - ScreenCenter

						if Camera.CFrame.LookVector:Dot(
							ToObj.Unit
						) < 0 then
							Dir = -Dir
						end

						if Dir.Magnitude < 0.001 then
							Dir = Vector2.new(0, -1)
						end

						local Angle = math.atan2(Dir.Y, Dir.X)

						local Radius = math.clamp(
							Library.ArrowRadius,
							30,
							math.min(
								ScreenSize.X,
								ScreenSize.Y
							) / 2
						)

						local ArrowPos =
							ScreenCenter + Dir.Unit * Radius

						Arrow.Position = UDim2.fromOffset(
							ArrowPos.X,
							ArrowPos.Y
						)

						Arrow.Rotation = math.deg(Angle) - 90
						Arrow.Visible = true

						Arrow.ImageColor3 = Library.Rainbow
							and Library.RainbowColor
							or BaseColor
					end
				end
			else
				local Arrow = Library.ArrowsTable[Object]

				if Arrow then
					Arrow.Visible = false
				end
			end
		end

		local Connection

		Connection = RunService.Heartbeat:Connect(function(Delta)
			if Library.Unloaded then
				Connection:Disconnect()
				return
			end

			local RenderLimit = math.max(
				1,
				Library.RenderLimit
			)

			Last = Last + Delta

			if Last >= 1 / RenderLimit then
				Last = 0

				if Library.ElementsEnabled[Object] ~= true then
					Connection:Disconnect()
					return
				end

				Render()
			end
		end)

		table.insert(
			Library.ConnectionsTable[Object],
			Connection
		)
	end)
end

--==============================================================
-- REMOVE ESP
--==============================================================

function Library:RemoveESP(Object)
	if Library.Unloaded then
		return
	end

	if Library.ElementsEnabled[Object] ~= true then
		return
	end

	Library.ElementsEnabled[Object] = false
	Library.TransparencyEnabled[Object] = false

	local Label = Library.Labels[Object]

	if Label then
		PlayTween(Label, {
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		})
	end

	local LineData = Library.Lines[Object]

	if LineData then
		if LineData[1] then
			PlayTween(LineData[1], {
				BackgroundTransparency = 1,
			})
		end

		if LineData[2] then
			PlayTween(LineData[2], {
				Transparency = 1,
			})
		end
	end

	local Highlight = Library.Highlights[Object]

	if Highlight then
		PlayTween(Highlight, {
			FillTransparency = 1,
		})

		PlayTween(Highlight, {
			OutlineTransparency = 1,
		})
	end

	local Arrow = Library.ArrowsTable[Object]

	if Arrow then
		PlayTween(Arrow, {
			ImageTransparency = 1,
		})
	end

	local FadeTime = math.max(0, Library.FadeTime)

	task.delay(FadeTime + 0.05, function()
		if Library.ElementsEnabled[Object] == false then
			DestroyObjectData(Object)
		end
	end)
end

--==============================================================
-- OBJECT TEXT AND COLOR
--==============================================================

function Library:UpdateObjectText(Object, Text)
	if Library.TextTable[Object] ~= nil then
		Library.TextTable[Object] = tostring(Text)
	end
end

function Library:UpdateObjectColor(Object, Color)
	Library.ColorTable[Object] = Color

	if Library.Labels[Object] and Library.Rainbow ~= true then
		Library.Labels[Object].TextColor3 = Color
	end

	local Border = Library.Frames[Object]
		and Library.Frames[Object]:FindFirstChild("BradarBorder")

	if Border and Border:IsA("UIStroke") then
		Border.Color = Color
	end
end

function Library:SetColorTable(Name, Color)
	Library.ColorTable[Name] = Color
end

--==============================================================
-- EXISTING CONFIGURATION METHODS
--==============================================================

function Library:SetFadeTime(Number)
	Library.FadeTime = math.max(0, Number)
end

function Library:SetRenderLimit(Number)
	Library.RenderLimit = math.max(1, Number)
end

function Library:SetTextTransparency(Number)
	Library.TextTransparency = math.clamp(Number, 0, 1)

	for _, Label in pairs(Library.Labels) do
		Label.TextTransparency = Library.TextTransparency
	end
end

function Library:SetFillTransparency(Number)
	Library.FillTransparency = math.clamp(Number, 0, 1)

	for _, Highlight in pairs(Library.Highlights) do
		if Highlight:IsA("Highlight") then
			Highlight.FillTransparency = Library.FillTransparency
		end
	end
end

function Library:SetOutlineTransparency(Number)
	Library.OutlineTransparency = math.clamp(Number, 0, 1)

	for _, Highlight in pairs(Library.Highlights) do
		if Highlight:IsA("Highlight") then
			Highlight.OutlineTransparency =
				Library.OutlineTransparency
		end
	end
end

function Library:SetTextSize(Number)
	Library.TextSize = math.clamp(Number, 8, 48)

	for _, Label in pairs(Library.Labels) do
		Label.TextSize = Library.TextSize
	end
end

function Library:SetTextOutlineTransparency(Number)
	Library.TextOutlineTransparency = math.clamp(Number, 0, 1)

	for _, Label in pairs(Library.Labels) do
		Label.TextStrokeTransparency =
			Library.TextOutlineTransparency
	end
end

function Library:SetFont(Font)
	Library.Font = Font

	for _, Label in pairs(Library.Labels) do
		Label.Font = Font
	end
end

function Library:SetOutlineColor(Color)
	Library.OutlineColor = Color
end

function Library:SetRainbow(Value)
	Library.Rainbow = Value == true
end

function Library:SetShowDistance(Value)
	Library.ShowDistance = Value == true
end

function Library:SetMatchColors(Value)
	Library.MatchColors = Value == true
end

function Library:SetTracers(Value)
	Library.Tracers = Value == true
	TracersFrame.Visible = Library.Tracers
end

function Library:SetArrows(Value)
	Library.Arrows = Value == true
	ArrowsFrame.Visible = Library.Arrows

	if not Library.Arrows then
		for _, Arrow in pairs(Library.ArrowsTable) do
			Arrow.Visible = false
		end
	end
end

function Library:SetArrowRadius(Value)
	Library.ArrowRadius = math.max(30, Value)
end

function Library:SetTracerOrigin(Value)
	local ValidOrigins = {
		Bottom = true,
		Top = true,
		Center = true,
		Mouse = true,
	}

	if ValidOrigins[Value] then
		Library.TracerOrigin = Value
	end
end

function Library:SetDistanceSizeRatio(Value)
	Library.DistanceSizeRatio = math.max(0.1, Value)
end

function Library:SetTracerSize(Value)
	Library.TracerSize = math.clamp(
		0.5 * Value,
		Library.VisualStyle.TracerMinimumThickness,
		Library.VisualStyle.TracerMaximumThickness
	)
end

--==============================================================
-- ADDITIONAL VISUAL CONFIGURATION
--==============================================================

function Library:SetVisualBackground(Color, Transparency)
	if typeof(Color) == "Color3" then
		Library.VisualStyle.BackgroundColor = Color
	end

	if Transparency ~= nil then
		Library.VisualStyle.BackgroundTransparency =
			math.clamp(Transparency, 0, 1)
	end

	for Object in pairs(Library.Frames) do
		UpdateLabelStyle(Object)
	end
end

function Library:SetVisualBorder(Color, Transparency)
	if typeof(Color) == "Color3" then
		Library.VisualStyle.BorderColor = Color
	end

	if Transparency ~= nil then
		Library.VisualStyle.BorderTransparency =
			math.clamp(Transparency, 0, 1)
	end

	for Object in pairs(Library.Frames) do
		UpdateLabelStyle(Object)
	end
end

function Library:SetVisualSize(Width, Height)
	Library.VisualStyle.PanelWidth = math.clamp(Width, 100, 400)
	Library.VisualStyle.PanelHeight = math.clamp(Height, 24, 100)

	for Object in pairs(Library.Frames) do
		UpdateLabelStyle(Object)
	end
end

function Library:SetVisualGradient(Value)
	Library.VisualStyle.GradientEnabled = Value == true

	for _, Frame in pairs(Library.Frames) do
		local Gradient = Frame:FindFirstChild("BradarGradient")

		if Library.VisualStyle.GradientEnabled and not Gradient then
			Gradient = Instance.new("UIGradient")
			Gradient.Name = "BradarGradient"
			Gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(
					0,
					Library.VisualStyle.GradientColor1
				),
				ColorSequenceKeypoint.new(
					1,
					Library.VisualStyle.GradientColor2
				),
			})
			Gradient.Rotation = 90
			Gradient.Parent = Frame
		elseif not Library.VisualStyle.GradientEnabled and Gradient then
			Gradient:Destroy()
		end
	end
end

function Library:SetVisualCornerRadius(Number)
	Library.VisualStyle.CornerRadius = math.clamp(Number, 0, 20)

	for _, Frame in pairs(Library.Frames) do
		local Corner = Frame:FindFirstChild("BradarCorner")

		if Corner and Corner:IsA("UICorner") then
			Corner.CornerRadius = UDim.new(
				0,
				Library.VisualStyle.CornerRadius
			)
		end
	end
end

function Library:SetVisualPanelTransparency(Number)
	Library.VisualStyle.BackgroundTransparency =
		math.clamp(Number, 0, 1)

	for _, Frame in pairs(Library.Frames) do
		Frame.BackgroundTransparency =
			Library.VisualStyle.BackgroundTransparency
	end
end

--==============================================================
-- UNLOAD
--==============================================================

function Library:Unload()
	if Library.Unloaded then
		return
	end

	Library.Unloaded = true

	if RainbowConnection then
		RainbowConnection:Disconnect()
	end

	if CameraConnection then
		CameraConnection:Disconnect()
	end

	for _, Conns in pairs(Library.ConnectionsTable) do
		for _, Conn in ipairs(Conns) do
			if Conn.Connected then
				Conn:Disconnect()
			end
		end
	end

	for _, Object in ipairs(Library.TotalObjects) do
		DestroyObjectData(Object)
	end

	Library.TotalObjects = {}

	if ScreenGui then
		ScreenGui.Enabled = false
		ScreenGui:Destroy()
	end
end

--==============================================================
-- RAINBOW COLOR UPDATE
--==============================================================

RainbowConnection = RunService.RenderStepped:Connect(function(Delta)
	if Library.Unloaded then
		return
	end

	RainbowState.Step = RainbowState.Step + Delta

	if RainbowState.Step >= (1 / 60) then
		RainbowState.Step = 0
		RainbowState.HueSetup =
			RainbowState.HueSetup + (1 / 400)

		if RainbowState.HueSetup > 1 then
			RainbowState.HueSetup = 0
		end

		RainbowState.Hue = RainbowState.HueSetup

		RainbowState.Color = Color3.fromHSV(
			RainbowState.Hue,
			0.8,
			1
		)

		Library.RainbowColor = RainbowState.Color
	end
end)

--==============================================================
-- CAMERA UPDATE
--==============================================================

CameraConnection =
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		Camera = Workspace.CurrentCamera
	end)

--==============================================================
-- EXISTING GLOBAL EXPORT
--==============================================================

if getgenv then
	getgenv().ESPLibrary = Library
end

return Library
