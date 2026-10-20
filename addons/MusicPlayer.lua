local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local MusicModule = {}

MusicModule.Library = nil
MusicModule.SpotifyModule = nil
MusicModule.Show = false

MusicModule.PlaceholderImage = "rbxassetid://11653546524"
MusicModule.PollInterval = 5

local activePlayer = nil

function MusicModule:SetLibrary(newLibrary)
	assert(
		type(newLibrary) == "table",
		"MusicModule:SetLibrary expects your UI library."
	)

	self.Library = newLibrary
	return self
end

function MusicModule:SetSpotifyModule(module)
	assert(
		type(module) == "table"
			and type(module.new) == "function",
		"MusicModule:SetSpotifyModule expects the Spotify HTTP module."
	)

	self.SpotifyModule = module
	return self
end

local function resolveRequest()
	if type(request) == "function" then
		return request
	elseif type(http_request) == "function" then
		return http_request
	elseif type(syn) == "table"
		and type(syn.request) == "function"
	then
		return syn.request
	elseif type(http) == "table"
		and type(http.request) == "function"
	then
		return http.request
	end
end

local function resolveAssetLoader()
	if type(getcustomasset) == "function" then
		return getcustomasset
	elseif type(getsynasset) == "function" then
		return getsynasset
	end
end

local function formatTime(milliseconds)
	local seconds = math.floor(
		math.max(0, tonumber(milliseconds) or 0) / 1000
	)

	return string.format(
		"%02d:%02d",
		math.floor(seconds / 60),
		seconds % 60
	)
end

function MusicModule:CreatePlayermdl(window)
	if activePlayer and not activePlayer.Destroyed then
		return activePlayer
	end

	local library = self.Library
	local Spotify = self.SpotifyModule

	assert(library, "Set your library before creating the music player.")
	assert(Spotify, "Set the Spotify HTTP module first.")
	assert(library.scgo, "Your library.scgo is missing.")

	local spotify = Spotify.new()
	local player = {
		Destroyed = false,
		Spotify = spotify,
		Window = window,
	}

	local connections = {}
	local destroyed = false
	local linked = false
	local connecting = false
	local commandBusy = false
	local sessionVersion = 0

	local currentState = nil
	local stateReceivedAt = os.clock()

	local artworkVersion = 0
	local artworkURL = nil
	local artworkCache = {}
	local artworkWarningShown = false

	local assetLoader = resolveAssetLoader()
	local artworkRequest = resolveRequest()
	local artworkFolder = "SpotifyPlayerArtwork"

	local strokeColor = library.UIstroke
		or library.UIStroke
		or Color3.new(0, 0, 0)

	local function connect(signal, callback)
		local connection = signal:Connect(callback)
		table.insert(connections, connection)
		return connection
	end

	local function notify(message)
		if destroyed then
			return
		end

		if type(library.Notify) == "function" then
			local ok = pcall(function()
				library:Notify(tostring(message))
			end)

			if ok then
				return
			end
		end

		warn("[Music Player] " .. tostring(message))
	end

	local function create(class, properties, ...)
		return library:Create(class, properties, ...)
	end

	local function binding(property, value)
		return {
			instancep = property,
			tinstance = value,
		}
	end

	local function border(parent, thickness, color)
		color = color or library.SecondaryColor

		return create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Thickness = thickness or 1,
			Color = color,
			Parent = parent,
		}, binding("Color", color))
	end

	local function label(parent, name, text, size, position, textSize)
		local object = create("TextLabel", {
			Name = name,
			BackgroundTransparency = 1,
			Size = size,
			Position = position or UDim2.fromOffset(0, 0),
			Text = text,
			TextSize = textSize or 13,
			Font = library.Font,
			TextColor3 = library.FontColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = parent,
		},
		binding("TextColor3", library.FontColor),
		binding("Font", library.Font)
		)

		create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			Color = strokeColor,
			Thickness = 1,
			Parent = object,
		}, binding("Color", strokeColor))

		return object
	end

	local function button(parent, name, text, size, position)
		local object = create("TextButton", {
			Name = name,
			Size = size,
			Position = position or UDim2.fromOffset(0, 0),
			BackgroundColor3 = library.MainColor,
			AutoButtonColor = true,
			Text = text,
			TextSize = 14,
			Font = library.Font,
			TextColor3 = library.FontColor,
			Parent = parent,
		},
		binding("BackgroundColor3", library.MainColor),
		binding("TextColor3", library.FontColor),
		binding("Font", library.Font)
		)

		border(object)
		return object
	end

	local mainframe = create("Frame", {
		Name = "MusicPlayer",
		Size = UDim2.fromOffset(588, 341),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = library.MainColor,
		Visible = self.Show,
		Active = true,
		Parent = library.scgo,
	}, binding("BackgroundColor3", library.MainColor))

	border(mainframe, 4, library.MainColor)
	border(mainframe, 1, library.SecondaryColor)

	create("Frame", {
		Name = "Accent",
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = library.AccentColor,
		ZIndex = 2,
		Parent = mainframe,
	}, binding("BackgroundColor3", library.AccentColor))

	local header = label(
		mainframe,
		"Header",
		"Music Player (not linked)",
		UDim2.new(1, -60, 0, 21),
		UDim2.fromOffset(30, 2),
		14
	)
	header.TextXAlignment = Enum.TextXAlignment.Center

	local hideButton = button(
		mainframe,
		"Hide",
		"x",
		UDim2.fromOffset(20, 16),
		UDim2.new(1, -25, 0, 4)
	)

	local content = create("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(0, 23),
		Size = UDim2.new(1, 0, 1, -23),
		BackgroundTransparency = 1,
		Parent = mainframe,
	})

	local loginHolder = create("Frame", {
		Name = "LOGIN",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = true,
		Parent = content,
	})

	local playerHolder = create("Frame", {
		Name = "PLAYER",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = content,
	})

	-- Setup page.
	local setup = create("Frame", {
		Name = "Setup",
		Position = UDim2.fromOffset(8, 3),
		Size = UDim2.new(1, -16, 1, -10),
		BackgroundColor3 = library.MainColor,
		Parent = loginHolder,
	}, binding("BackgroundColor3", library.MainColor))

	border(setup)

	create("Frame", {
		Name = "Accent",
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = library.AccentColor,
		Parent = setup,
	}, binding("BackgroundColor3", library.AccentColor))

	local setupTitle = label(
		setup,
		"Title",
		"Setup",
		UDim2.new(1, 0, 0, 23),
		UDim2.fromOffset(0, 2),
		14
	)
	setupTitle.TextXAlignment = Enum.TextXAlignment.Center

	local tokenBox = create("TextBox", {
		Name = "APIToken",
		Position = UDim2.fromOffset(14, 34),
		Size = UDim2.new(1, -28, 0, 24),
		BackgroundColor3 = library.MainColor,
		Text = "",
		PlaceholderText = "Spotify OAuth access token",
		PlaceholderColor3 = Color3.fromRGB(125, 125, 125),
		TextColor3 = library.FontColor,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = library.Font,
		ClearTextOnFocus = false,
		MultiLine = false,
		Parent = setup,
	},
	binding("BackgroundColor3", library.MainColor),
	binding("TextColor3", library.FontColor),
	binding("Font", library.Font)
	)

	border(tokenBox)

	create("UIPadding", {
		PaddingLeft = UDim.new(0, 7),
		PaddingRight = UDim.new(0, 7),
		Parent = tokenBox,
	})

	local loginButton = button(
		setup,
		"Login",
		"Login",
		UDim2.new(1, -28, 0, 24),
		UDim2.fromOffset(14, 69)
	)

	local instructions = label(
		setup,
		"Instructions",
		"Paste a Spotify user access token with playback read/control permissions.\n\n"
			.. "Open Spotify on your phone or computer and start a song before using playback controls.\n\n"
			.. "The token is kept in memory by this module. Do not share it or use a Spotify password here.",
		UDim2.new(1, -28, 0, 135),
		UDim2.fromOffset(14, 104),
		13
	)
	instructions.TextWrapped = true
	instructions.TextTruncate = Enum.TextTruncate.None
	instructions.TextYAlignment = Enum.TextYAlignment.Top

	local statusLabel = label(
		setup,
		"Status",
		"Not connected.",
		UDim2.new(1, -28, 0, 34),
		UDim2.fromOffset(14, 254),
		13
	)
	statusLabel.TextWrapped = true
	statusLabel.TextTruncate = Enum.TextTruncate.None

	-- Player page.
	local songPanel = create("Frame", {
		Name = "Song",
		Position = UDim2.fromOffset(7, 6),
		Size = UDim2.new(1, -14, 0, 119),
		BackgroundColor3 = library.MainColor,
		Parent = playerHolder,
	}, binding("BackgroundColor3", library.MainColor))

	border(songPanel)

	local artwork = create("ImageLabel", {
		Name = "Artwork",
		Position = UDim2.fromOffset(14, 14),
		Size = UDim2.fromOffset(90, 90),
		BackgroundTransparency = 1,
		Image = self.PlaceholderImage,
		ScaleType = Enum.ScaleType.Fit,
		Parent = songPanel,
	})
	border(artwork)

	local songLabel = label(
		songPanel,
		"Song",
		"No active song",
		UDim2.new(1, -126, 0, 27),
		UDim2.fromOffset(116, 12),
		16
	)

	local artistLabel = label(
		songPanel,
		"Artist",
		"Spotify",
		UDim2.new(1, -126, 0, 19),
		UDim2.fromOffset(116, 39),
		14
	)

	local timeline = create("Frame", {
		Name = "Timeline",
		Position = UDim2.fromOffset(116, 71),
		Size = UDim2.new(1, -126, 0, 6),
		BackgroundColor3 = library.MainColor,
		Parent = songPanel,
	}, binding("BackgroundColor3", library.MainColor))
	border(timeline)

	local progressFill = create("Frame", {
		Name = "Progress",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = library.AccentColor,
		Parent = timeline,
	}, binding("BackgroundColor3", library.AccentColor))

	local seekButton = create("TextButton", {
		Name = "Seek",
		Position = UDim2.fromOffset(0, -5),
		Size = UDim2.new(1, 0, 1, 10),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 3,
		Parent = timeline,
	})

	local currentLabel = label(
		songPanel,
		"Current",
		"00:00",
		UDim2.fromOffset(55, 14),
		UDim2.fromOffset(116, 81),
		12
	)

	local durationLabel = label(
		songPanel,
		"Duration",
		"00:00",
		UDim2.fromOffset(55, 14),
		UDim2.new(1, -65, 0, 81),
		12
	)
	durationLabel.TextXAlignment = Enum.TextXAlignment.Right

	local controls = create("Frame", {
		Name = "Controls",
		Position = UDim2.fromOffset(178, 84),
		Size = UDim2.new(1, -254, 0, 28),
		BackgroundTransparency = 1,
		Parent = songPanel,
	})

	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 25),
		Parent = controls,
	})

	local previousButton = button(
		controls, "Previous", "<<", UDim2.fromOffset(43, 25)
	)
	previousButton.LayoutOrder = 1

	local playButton = button(
		controls, "PlayPause", ">", UDim2.fromOffset(43, 25)
	)
	playButton.LayoutOrder = 2

	local nextButton = button(
		controls, "Next", ">>", UDim2.fromOffset(43, 25)
	)
	nextButton.LayoutOrder = 3

	local lyricsPanel = create("Frame", {
		Name = "Lyrics",
		Position = UDim2.fromOffset(7, 136),
		Size = UDim2.new(1, -14, 0, 175),
		BackgroundColor3 = library.MainColor,
		Parent = playerHolder,
	}, binding("BackgroundColor3", library.MainColor))
	border(lyricsPanel)

	label(
		lyricsPanel,
		"Title",
		"Lyrics - Music Player",
		UDim2.new(1, -115, 0, 23),
		UDim2.fromOffset(7, 0),
		13
	)

	local disconnectButton = button(
		lyricsPanel,
		"Disconnect",
		"Disconnect",
		UDim2.fromOffset(92, 19),
		UDim2.new(1, -99, 0, 3)
	)

	local lyricsHolder = create("ScrollingFrame", {
		Name = "Holder",
		Position = UDim2.fromOffset(7, 26),
		Size = UDim2.new(1, -14, 1, -57),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = library.AccentColor,
		Parent = lyricsPanel,
	}, binding("ScrollBarImageColor3", library.AccentColor))

	local lyricsLabel = label(
		lyricsHolder,
		"LyricsText",
		"Lyrics are not connected.\nA separate lyrics provider is required.",
		UDim2.new(1, -8, 0, 0),
		UDim2.fromOffset(0, 0),
		13
	)
	lyricsLabel.AutomaticSize = Enum.AutomaticSize.Y
	lyricsLabel.TextWrapped = true
	lyricsLabel.TextTruncate = Enum.TextTruncate.None
	lyricsLabel.TextYAlignment = Enum.TextYAlignment.Top

	local spotifyLink = create("TextBox", {
		Name = "SpotifyLink",
		Position = UDim2.new(0, 7, 1, -25),
		Size = UDim2.new(1, -14, 0, 19),
		BackgroundTransparency = 1,
		Text = "https://open.spotify.com",
		TextEditable = false,
		ClearTextOnFocus = false,
		TextSize = 12,
		Font = library.Font,
		TextColor3 = library.FontColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = lyricsPanel,
	},
	binding("Font", library.Font),
	binding("TextColor3", library.FontColor)
	)

	local function artworkWarning()
		if artworkWarningShown then
			return
		end

		artworkWarningShown = true
		notify(
			"Artwork needs writefile and getcustomasset/getsynasset. "
				.. "Using the placeholder."
		)
	end

	local function setArtwork(url)
		if url == artworkURL then
			return
		end

		artworkURL = url
		artworkVersion += 1

		local version = artworkVersion
		artwork.Image = self.PlaceholderImage

		if type(url) ~= "string" or url == "" then
			return
		end

		-- Restrict downloads to Spotify's image CDN.
		local imageId = url:match(
			"^https://i%.scdn%.co/image/([%w]+)$"
		)

		if not imageId then
			return
		end

		if artworkCache[url] then
			artwork.Image = artworkCache[url]
			return
		end

		if not artworkRequest
			or not assetLoader
			or type(writefile) ~= "function"
		then
			artworkWarning()
			return
		end

		task.spawn(function()
			-- Public artwork request: no Authorization header.
			local ok, response = pcall(artworkRequest, {
				Url = url,
				Method = "GET",
			})

			if destroyed or version ~= artworkVersion then
				return
			end

			if not ok or type(response) ~= "table" then
				return
			end

			local status = tonumber(
				response.StatusCode or response.Status
			)

			if status ~= 200
				or type(response.Body) ~= "string"
				or response.Body == ""
			then
				return
			end

			local bytes = response.Body
			local extension

			if bytes:sub(1, 8) == "\137PNG\r\n\26\n" then
				extension = ".png"
			elseif bytes:sub(1, 3) == "\255\216\255" then
				extension = ".jpg"
			else
				-- Do not save HTML/error responses as artwork.
				return
			end

			local path = "SpotifyArtwork_" .. imageId .. extension

			local loaded, asset = pcall(function()
				if type(makefolder) == "function"
					and type(isfolder) == "function"
				then
					if not isfolder(artworkFolder) then
						makefolder(artworkFolder)
					end

					path = artworkFolder .. "/" .. imageId .. extension
				end

				writefile(path, bytes)
				return assetLoader(path)
			end)

			if destroyed or version ~= artworkVersion then
				return
			end

			if loaded and type(asset) == "string" and asset ~= "" then
				artworkCache[url] = asset
				artwork.Image = asset
			end
		end)
	end

	local function renderProgress()
		local item = currentState and currentState.item
		local duration = item and tonumber(item.duration_ms) or 0
		local position = currentState
			and tonumber(currentState.progress_ms)
			or 0

		position = position or 0
		duration = duration or 0

		if currentState and currentState.is_playing then
			position += (os.clock() - stateReceivedAt) * 1000
		end

		position = math.clamp(position, 0, duration)

		currentLabel.Text = formatTime(position)
		durationLabel.Text = formatTime(duration)

		progressFill.Size = UDim2.fromScale(
			duration > 0 and position / duration or 0,
			1
		)
	end

	local function updatePlayer(state)
		if destroyed then
			return
		end

		currentState = state
		stateReceivedAt = os.clock()

		local item = state and state.item

		if not item then
			songLabel.Text = "No active song"
			artistLabel.Text = "Open Spotify and start playing."
			playButton.Text = ">"
			spotifyLink.Text = "https://open.spotify.com"
			setArtwork(nil)
			renderProgress()
			return
		end

		songLabel.Text = item.name or "Unknown title"

		local names = {}

		for _, artist in ipairs(item.artists or {}) do
			table.insert(names, artist.name or "Unknown artist")
		end

		artistLabel.Text = #names > 0
			and table.concat(names, ", ")
			or (item.show and item.show.name)
			or "Spotify"

		playButton.Text = state.is_playing and "||" or ">"

		spotifyLink.Text = (
			item.external_urls and item.external_urls.spotify
		) or "https://open.spotify.com"

		local images = item.album and item.album.images
			or item.images
			or (item.show and item.show.images)

		-- Prefer medium artwork when available.
		local image = images and (images[2] or images[1])
		setArtwork(image and image.url or nil)

		renderProgress()
	end

	local function showLogin(message)
		linked = false
		currentState = nil
		spotify:StopPolling()

		header.Text = "Music Player (not linked)"
		loginHolder.Visible = true
		playerHolder.Visible = false
		statusLabel.Text = message or "Not connected."

		setArtwork(nil)
	end

	local function beginPolling()
		local version = sessionVersion

		spotify:StartPolling(function(state)
			if destroyed or version ~= sessionVersion then
				return
			end

			updatePlayer(state)
		end, function(message, status)
			if destroyed or version ~= sessionVersion then
				return
			end

			if status == 401 then
				showLogin(message)
				notify(message)
			end
		end, self.PollInterval)
	end

	local function login()
		if destroyed or connecting then
			return
		end

		local token = tokenBox.Text:match("^%s*(.-)%s*$")

		if token == "" then
			statusLabel.Text = "Enter a Spotify access token."
			return
		end

		connecting = true
		sessionVersion += 1

		local version = sessionVersion

		loginButton.Text = "Connecting..."
		statusLabel.Text = "Connecting to Spotify..."

		task.spawn(function()
			local ok, stateOrError = spotify:Connect(token)

			if destroyed or version ~= sessionVersion then
				return
			end

			connecting = false
			loginButton.Text = "Login"

			if not ok then
				statusLabel.Text = tostring(stateOrError)
				notify(stateOrError)
				return
			end

			linked = true
			tokenBox.Text = ""
			statusLabel.Text = "Connected."

			header.Text = "Music Player (Spotify)"
			loginHolder.Visible = false
			playerHolder.Visible = true

			updatePlayer(stateOrError)
			beginPolling()
		end)
	end

	local function runCommand(callback)
		if destroyed or not linked or commandBusy then
			return
		end

		commandBusy = true
		local version = sessionVersion

		task.spawn(function()
			local ok, message, status = callback()

			if destroyed or version ~= sessionVersion then
				return
			end

			if not ok then
				if status == 401 then
					showLogin(message)
				end

				notify(message)
			else
				-- Playback commands can take a moment to appear.
				task.wait(0.4)

				if not destroyed and version == sessionVersion then
					local refreshed, state = spotify:GetPlayback()

					if refreshed and not destroyed
						and version == sessionVersion
					then
						updatePlayer(state)
					end
				end
			end

			commandBusy = false
		end)
	end

	connect(loginButton.Activated, login)

	connect(tokenBox.FocusLost, function(enterPressed)
		if enterPressed then
			login()
		end
	end)

	connect(previousButton.Activated, function()
		runCommand(function()
			return spotify:Previous()
		end)
	end)

	connect(playButton.Activated, function()
		runCommand(function()
			return spotify:TogglePlayback()
		end)
	end)

	connect(nextButton.Activated, function()
		runCommand(function()
			return spotify:Next()
		end)
	end)

	connect(seekButton.InputBegan, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		local item = currentState and currentState.item
		local duration = item and tonumber(item.duration_ms)

		if not duration or duration <= 0
			or timeline.AbsoluteSize.X <= 0
		then
			return
		end

		local alpha = math.clamp(
			(input.Position.X - timeline.AbsolutePosition.X)
				/ timeline.AbsoluteSize.X,
			0,
			1
		)

		runCommand(function()
			return spotify:Seek(math.floor(duration * alpha))
		end)
	end)

	function player:Disconnect()
		if destroyed then
			return
		end

		sessionVersion += 1
		connecting = false
		commandBusy = false

		spotify:Disconnect()
		tokenBox.Text = ""
		loginButton.Text = "Login"

		showLogin("Disconnected.")
	end

	connect(disconnectButton.Activated, function()
		player:Disconnect()
	end)

	function player:SetVisible(visible)
		if destroyed then
			return
		end

		MusicModule.Show = visible == true
		mainframe.Visible = MusicModule.Show
	end

	function player:ToggleVisibility()
		self:SetVisible(not mainframe.Visible)
	end

	connect(hideButton.Activated, function()
		player:SetVisible(false)
	end)

	-- Drag using the header.
	header.Active = true

	local dragging = false
	local dragTouch = nil
	local dragStart = nil
	local startPosition = nil

	connect(header.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			dragTouch = input.UserInputType == Enum.UserInputType.Touch
				and input
				or nil

			dragStart = input.Position
			startPosition = mainframe.Position
		end
	end)

	connect(UserInputService.InputChanged, function(input)
		if not dragging then
			return
		end

		local valid = dragTouch and input == dragTouch
			or (
				not dragTouch
				and input.UserInputType == Enum.UserInputType.MouseMovement
			)

		if valid then
			local delta = input.Position - dragStart

			mainframe.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end)

	connect(UserInputService.InputEnded, function(input)
		if input == dragTouch
			or (
				not dragTouch
					and input.UserInputType == Enum.UserInputType.MouseButton1
			)
		then
			dragging = false
			dragTouch = nil
		end
	end)

	local elapsed = 0

	connect(RunService.Heartbeat, function(delta)
		elapsed += delta

		if elapsed < 0.2 then
			return
		end

		elapsed = 0

		if linked and mainframe.Visible then
			renderProgress()
		end
	end)

	local function cleanup()
		if destroyed then
			return
		end

		destroyed = true
		player.Destroyed = true

		sessionVersion += 1
		artworkVersion += 1

		spotify:Destroy()

		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		table.clear(connections)
		table.clear(artworkCache)

		if activePlayer == player then
			activePlayer = nil
			MusicModule.Show = false
		end
	end

	function player:Destroy()
		if destroyed then
			return
		end

		cleanup()
		mainframe:Destroy()
	end

	connect(mainframe.Destroying, cleanup)

	player.MainFrame = mainframe
	player.LoginHolder = loginHolder
	player.PlayerHolder = playerHolder
	player.TokenBox = tokenBox
	player.Artwork = artwork
	player.SongLabel = songLabel
	player.ArtistLabel = artistLabel
	player.LyricsLabel = lyricsLabel

	activePlayer = player

	return player
end

return MusicModule
