local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local MusicModule = {
    Library = nil,
    SpotifyModule = nil,
    SpotifyLoginModule = nil,
    YouTubeResolver = nil,

    Root = "nocturne.bz/player",
    Show = false,
    PollInterval = 5,
    MaxDownloadBytes = 40 * 1024 * 1024,
    PlaceholderImage = "rbxassetid://11653546524",
}

local activePlayer
local REDIRECT_URI = "http://127.0.0.1:8888/callback"

function MusicModule:SetLibrary(value)
    self.Library = value
    return self
end

function MusicModule:SetSpotifyModule(value)
    self.SpotifyModule = value
    return self
end

function MusicModule:SetSpotifyLoginModule(value)
    assert(
        type(value) == "table" and type(value.new) == "function",
        "Expected the SpotifyLogin module."
    )

    self.SpotifyLoginModule = value
    return self
end

function MusicModule:SetYouTubeResolver(callback)
    assert(
        callback == nil or type(callback) == "function",
        "YouTube resolver must be a function or nil."
    )

    self.YouTubeResolver = callback
    return self
end

local function resolveRequest()
    if type(request) == "function" then
        return request
    elseif type(http_request) == "function" then
        return http_request
    elseif type(syn) == "table" and type(syn.request) == "function" then
        return syn.request
    elseif type(http) == "table" and type(http.request) == "function" then
        return http.request
    end
end

local function resolveAsset()
    if type(getcustomasset) == "function" then
        return getcustomasset
    elseif type(getsynasset) == "function" then
        return getsynasset
    end
end

local function trim(value)
    return tostring(value or ""):match("^%s*(.-)%s*$")
end

local function normalizePath(value)
    return tostring(value or ""):gsub("\\", "/")
end

local function safeName(value)
    local name = trim(value):gsub("[^%w%s_%-]", "_")
    name = name:gsub("%s+", " "):sub(1, 70)

    return name ~= "" and name or "Untitled"
end

local function formatTime(seconds)
    seconds = math.floor(math.max(0, tonumber(seconds) or 0))

    return string.format(
        "%02d:%02d",
        math.floor(seconds / 60),
        seconds % 60
    )
end

local function isYouTubeURL(url)
    local host = url:match("^https?://([^/%?#]+)")
    host = host and host:lower()

    return host == "youtube.com"
        or host == "www.youtube.com"
        or host == "m.youtube.com"
        or host == "music.youtube.com"
        or host == "youtu.be"
        or host == "www.youtu.be"
end

function MusicModule:CreatePlayermdl(window)
    if activePlayer and not activePlayer.Destroyed then
        return activePlayer
    end

    local library = assert(self.Library, "Call SetLibrary first.")
    assert(library.scgo, "library.scgo is missing.")

    local requestFn = resolveRequest()
    local assetFn = resolveAsset()

    local root = normalizePath(self.Root):gsub("/+$", "")
    local mp3Folder = root .. "/mp3"
    local artworkFolder = root .. "/artwork"
    local linksFolder = root .. "/links"
    local playlistsFolder = root .. "/playlists"

    local queueFile = playlistsFolder .. "/default.json"
    local linksFile = linksFolder .. "/saved.json"

    local player = {
        Destroyed = false,
        Window = window,
    }

    local connections = {}
    local queue = {}
    local savedLinks = {}
    local artworkCache = {}

    local destroyed = false
    local source = "local"
    local selected = 0
    local savedIndex = 0

    local downloadBusy = false
    local spotifyBusy = false
    local loginBusy = false

    local sessionVersion = 0
    local audioVersion = 0
    local artworkVersion = 0

    local spotify
    local spotifyAuth
    local spotifyState
    local spotifyReceivedAt = os.clock()
    local currentArtworkURL

    local refreshQueue
    local playTrack

    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
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

    local function border(parent)
        return create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            Thickness = 1,
            Color = library.SecondaryColor,
            Parent = parent,
        }, binding("Color", library.SecondaryColor))
    end

    local function frame(parent, name, position, size, transparent)
        return create("Frame", {
            Name = name,
            Position = position,
            Size = size,
            BackgroundColor3 = library.MainColor,
            BackgroundTransparency = transparent and 1 or 0,
            Parent = parent,
        }, binding("BackgroundColor3", library.MainColor))
    end

    local function label(parent, name, value, position, size, fontSize)
        return create("TextLabel", {
            Name = name,
            Position = position,
            Size = size,
            BackgroundTransparency = 1,
            Font = library.Font,
            TextColor3 = library.FontColor,
            TextSize = fontSize or 13,
            Text = value,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = parent,
        },
            binding("Font", library.Font),
            binding("TextColor3", library.FontColor)
        )
    end

    local function button(parent, name, value, position, size)
        local object = create("TextButton", {
            Name = name,
            Position = position,
            Size = size,
            BackgroundColor3 = library.MainColor,
            Font = library.Font,
            TextColor3 = library.FontColor,
            TextSize = 13,
            Text = value,
            AutoButtonColor = true,
            Parent = parent,
        },
            binding("BackgroundColor3", library.MainColor),
            binding("Font", library.Font),
            binding("TextColor3", library.FontColor)
        )

        border(object)
        return object
    end

    local function input(parent, name, placeholder, position, size)
        local object = create("TextBox", {
            Name = name,
            Position = position,
            Size = size,
            BackgroundColor3 = library.MainColor,
            Font = library.Font,
            TextColor3 = library.FontColor,
            TextSize = 13,
            Text = "",
            PlaceholderText = placeholder,
            PlaceholderColor3 = Color3.fromRGB(125, 125, 125),
            ClearTextOnFocus = false,
            MultiLine = false,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = parent,
        },
            binding("BackgroundColor3", library.MainColor),
            binding("Font", library.Font),
            binding("TextColor3", library.FontColor)
        )

        border(object)

        create("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            Parent = object,
        })

        return object
    end

    -- Window.
    local main = frame(
        library.scgo,
        "MusicPlayer",
        UDim2.fromScale(0.5, 0.5),
        UDim2.fromOffset(588, 431)
    )

    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Visible = self.Show
    main.Active = true
    border(main)

    create("Frame", {
        Name = "Accent",
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = library.AccentColor,
        Parent = main,
    }, binding("BackgroundColor3", library.AccentColor))

    local header = label(
        main, "Header", "Music Player - MP3",
        UDim2.fromOffset(9, 3),
        UDim2.new(1, -44, 0, 21), 14
    )

    local hideButton = button(
        main, "Hide", "x",
        UDim2.new(1, -26, 0, 5),
        UDim2.fromOffset(19, 17)
    )

    local tabs = frame(
        main, "Tabs",
        UDim2.fromOffset(8, 31),
        UDim2.new(1, -16, 0, 24), true
    )

    local localTab = button(
        tabs, "LocalTab", "MP3 / Library",
        UDim2.fromOffset(0, 0),
        UDim2.fromOffset(184, 23)
    )

    local linksTab = button(
        tabs, "LinksTab", "Links / Download",
        UDim2.fromOffset(194, 0),
        UDim2.fromOffset(184, 23)
    )

    local spotifyTab = button(
        tabs, "SpotifyTab", "Spotify",
        UDim2.fromOffset(388, 0),
        UDim2.fromOffset(184, 23)
    )

    -- Song panel.
    local songPanel = frame(
        main, "Song",
        UDim2.fromOffset(8, 66),
        UDim2.new(1, -16, 0, 119)
    )
    border(songPanel)

    local artwork = create("ImageLabel", {
        Name = "Artwork",
        Position = UDim2.fromOffset(12, 13),
        Size = UDim2.fromOffset(90, 90),
        BackgroundTransparency = 1,
        Image = self.PlaceholderImage,
        ScaleType = Enum.ScaleType.Fit,
        Parent = songPanel,
    })
    border(artwork)

    local title = label(
        songPanel, "Title", "No track selected",
        UDim2.fromOffset(115, 10),
        UDim2.new(1, -126, 0, 25), 16
    )

    local artist = label(
        songPanel, "Artist", "Local MP3 player",
        UDim2.fromOffset(115, 37),
        UDim2.new(1, -126, 0, 20), 13
    )

    local timeline = frame(
        songPanel, "Timeline",
        UDim2.fromOffset(115, 67),
        UDim2.new(1, -127, 0, 6)
    )
    border(timeline)

    local progressFill = create("Frame", {
        Name = "Progress",
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = library.AccentColor,
        Parent = timeline,
    }, binding("BackgroundColor3", library.AccentColor))

    local seekButton = create("TextButton", {
        Name = "Seek",
        Position = UDim2.fromOffset(0, -4),
        Size = UDim2.new(1, 0, 1, 8),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 3,
        Parent = timeline,
    })

    local currentLabel = label(
        songPanel, "Current", "00:00",
        UDim2.fromOffset(115, 79),
        UDim2.fromOffset(55, 18), 12
    )

    local durationLabel = label(
        songPanel, "Duration", "00:00",
        UDim2.new(1, -68, 0, 79),
        UDim2.fromOffset(55, 18), 12
    )
    durationLabel.TextXAlignment = Enum.TextXAlignment.Right

    local previousButton = button(
        songPanel, "Previous", "<<",
        UDim2.fromOffset(205, 83),
        UDim2.fromOffset(43, 25)
    )

    local playButton = button(
        songPanel, "PlayPause", ">",
        UDim2.fromOffset(273, 83),
        UDim2.fromOffset(43, 25)
    )

    local nextButton = button(
        songPanel, "Next", ">>",
        UDim2.fromOffset(341, 83),
        UDim2.fromOffset(43, 25)
    )

    -- Pages.
    local pages = frame(
        main, "Pages",
        UDim2.fromOffset(8, 196),
        UDim2.new(1, -16, 0, 191), true
    )

    local localPage = frame(
        pages, "Local",
        UDim2.fromOffset(0, 0),
        UDim2.fromScale(1, 1), true
    )

    local linksPage = frame(
        pages, "Links",
        UDim2.fromOffset(0, 0),
        UDim2.fromScale(1, 1), true
    )
    linksPage.Visible = false

    local spotifyPage = frame(
        pages, "Spotify",
        UDim2.fromOffset(0, 0),
        UDim2.fromScale(1, 1), true
    )
    spotifyPage.Visible = false

    -- Local page.
    local scanButton = button(
        localPage, "Scan", "Scan MP3 folder",
        UDim2.fromOffset(0, 0),
        UDim2.fromOffset(150, 23)
    )

    local clearButton = button(
        localPage, "Clear", "Clear playlist",
        UDim2.fromOffset(160, 0),
        UDim2.fromOffset(130, 23)
    )

    local volumeBox = input(
        localPage, "Volume", "Volume 0-100",
        UDim2.new(1, -130, 0, 0),
        UDim2.fromOffset(130, 23)
    )
    volumeBox.Text = "50"

    local playlist = create("ScrollingFrame", {
        Name = "Playlist",
        Position = UDim2.fromOffset(0, 33),
        Size = UDim2.new(1, 0, 1, -33),
        BackgroundColor3 = library.MainColor,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = library.AccentColor,
        Parent = localPage,
    },
        binding("BackgroundColor3", library.MainColor),
        binding("ScrollBarImageColor3", library.AccentColor)
    )
    border(playlist)

    create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = playlist,
    })

    create("UIPadding", {
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = playlist,
    })

    -- Download page.
    local urlBox = input(
        linksPage, "URL", "Direct HTTPS MP3/OGG URL or YouTube link",
        UDim2.fromOffset(0, 0),
        UDim2.new(1, 0, 0, 25)
    )

    local nameBox = input(
        linksPage, "TrackName", "Track name (optional)",
        UDim2.fromOffset(0, 35),
        UDim2.new(1, 0, 0, 25)
    )

    local downloadButton = button(
        linksPage, "Download", "Download / Add",
        UDim2.fromOffset(0, 72),
        UDim2.fromOffset(180, 25)
    )

    local saveLinkButton = button(
        linksPage, "SaveLink", "Save link",
        UDim2.fromOffset(192, 72),
        UDim2.fromOffset(180, 25)
    )

    local savedLinkButton = button(
        linksPage, "SavedLinks", "Next saved link",
        UDim2.fromOffset(384, 72),
        UDim2.new(1, -384, 0, 25)
    )

    local downloadInfo = label(
        linksPage, "Info",
        "Direct MP3/OGG downloads do not need a converter.\n"
            .. "YouTube downloads need a configured resolver.\n"
            .. "Files: " .. mp3Folder .. "\n"
            .. "Only download audio you have permission to use.",
        UDim2.fromOffset(0, 110),
        UDim2.new(1, 0, 0, 80), 13
    )
    downloadInfo.TextWrapped = true
    downloadInfo.TextTruncate = Enum.TextTruncate.None
    downloadInfo.TextYAlignment = Enum.TextYAlignment.Top

    -- Spotify page.
    label(
        spotifyPage, "ClientLabel", "Client ID",
        UDim2.fromOffset(0, 0),
        UDim2.fromOffset(90, 23), 12
    )

    local clientIdBox = input(
        spotifyPage, "ClientID", "Paste your Spotify app client ID",
        UDim2.fromOffset(95, 0),
        UDim2.new(1, -95, 0, 23)
    )

    label(
        spotifyPage, "RedirectLabel", "Redirect URL",
        UDim2.fromOffset(0, 31),
        UDim2.fromOffset(90, 23), 12
    )

    local redirectBox = input(
        spotifyPage, "RedirectURL", "",
        UDim2.fromOffset(95, 31),
        UDim2.new(1, -95, 0, 23)
    )
    redirectBox.Text = REDIRECT_URI
    redirectBox.TextEditable = false

    local beginLoginButton = button(
        spotifyPage, "BeginLogin", "1. Copy Login Link",
        UDim2.fromOffset(0, 65),
        UDim2.fromOffset(180, 24)
    )

    local copyRedirectButton = button(
        spotifyPage, "CopyRedirect", "Copy Redirect URL",
        UDim2.fromOffset(192, 65),
        UDim2.fromOffset(180, 24)
    )

    local disconnectButton = button(
        spotifyPage, "Disconnect", "Disconnect",
        UDim2.fromOffset(384, 65),
        UDim2.new(1, -384, 0, 24)
    )

    local loginLinkBox = input(
        spotifyPage, "LoginLink",
        "Your login link appears here. Open it in your browser.",
        UDim2.fromOffset(0, 99),
        UDim2.new(1, 0, 0, 23)
    )
    loginLinkBox.TextEditable = false

    local callbackBox = input(
        spotifyPage, "Callback",
        "2. Paste the FULL redirected browser address",
        UDim2.fromOffset(0, 132),
        UDim2.new(1, -190, 0, 24)
    )

    local completeLoginButton = button(
        spotifyPage, "CompleteLogin", "3. Complete Login",
        UDim2.new(1, -180, 0, 132),
        UDim2.fromOffset(180, 24)
    )

    local spotifyInfo = label(
        spotifyPage, "Instructions",
        "Sign in in your browser. Copy the callback address even if its page cannot load.",
        UDim2.fromOffset(0, 165),
        UDim2.new(1, 0, 0, 26), 12
    )
    spotifyInfo.TextWrapped = true
    spotifyInfo.TextTruncate = Enum.TextTruncate.None
    spotifyInfo.TextYAlignment = Enum.TextYAlignment.Top

    local statusLabel = label(
        main, "Status", "Ready.",
        UDim2.fromOffset(9, 396),
        UDim2.new(1, -18, 0, 27), 12
    )
    statusLabel.TextWrapped = true
    statusLabel.TextTruncate = Enum.TextTruncate.None

    local sound = Instance.new("Sound")
    sound.Name = "NocturneMusicPlayer"
    sound.Volume = 0.5
    sound.Parent = SoundService

    local function message(value)
        if not destroyed then
            statusLabel.Text = tostring(value)
        end
    end

    local function showPage(page)
        localPage.Visible = page == "local"
        linksPage.Visible = page == "links"
        spotifyPage.Visible = page == "spotify"
    end

    local function ensureFolders()
        assert(
            type(makefolder) == "function"
                and type(isfolder) == "function",
            "Folder functions are unavailable."
        )

        local path = ""

        for segment in root:gmatch("[^/]+") do
            path = path == "" and segment or path .. "/" .. segment

            if not isfolder(path) then
                makefolder(path)
            end
        end

        for _, folder in ipairs({
            mp3Folder,
            artworkFolder,
            linksFolder,
            playlistsFolder,
        }) do
            if not isfolder(folder) then
                makefolder(folder)
            end
        end
    end

    local function writeJSON(path, value)
        assert(type(writefile) == "function", "writefile unavailable.")
        writefile(path, HttpService:JSONEncode(value))
    end

    local function readJSON(path)
        if type(isfile) ~= "function"
            or type(readfile) ~= "function"
            or not isfile(path)
        then
            return nil
        end

        local ok, result = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)

        if ok and type(result) == "table" then
            return result
        end
    end

    local function validLocalPath(path)
        path = normalizePath(path)

        return path:sub(1, #mp3Folder + 1) == mp3Folder .. "/"
            and not path:find("..", 1, true)
            and (
                path:lower():match("%.mp3$") ~= nil
                or path:lower():match("%.ogg$") ~= nil
            )
    end

    local function saveQueue()
        local ok = pcall(function()
            ensureFolders()
            writeJSON(queueFile, queue)
        end)

        if not ok then
            message("Playlist updated, but saving failed.")
        end
    end

    local function fetchBytes(url, maximum)
        assert(requestFn, "No HTTP request function available.")
        assert(
            type(url) == "string" and url:match("^https://"),
            "A direct HTTPS URL is required."
        )

        local response = requestFn({
            Url = url,
            Method = "GET",
        })

        assert(type(response) == "table", "Invalid HTTP response.")

        local status = tonumber(
            response.StatusCode or response.Status
        )

        assert(
            status == 200,
            "Download failed: HTTP " .. tostring(status)
        )

        local bytes = response.Body

        assert(
            type(bytes) == "string" and #bytes > 0,
            "Empty download."
        )

        -- Checked after the HTTP function returns the response.
        assert(#bytes <= maximum, "Download exceeds the size limit.")

        return bytes
    end

    local function setArtwork(url)
        if currentArtworkURL == url then
            return
        end

        currentArtworkURL = url
        artworkVersion += 1

        local version = artworkVersion
        artwork.Image = self.PlaceholderImage

        if type(url) ~= "string" or not url:match("^https://") then
            return
        end

        if artworkCache[url] then
            artwork.Image = artworkCache[url]
            return
        end

        if not assetFn or type(writefile) ~= "function" then
            return
        end

        task.spawn(function()
            local ok, asset = pcall(function()
                local bytes = fetchBytes(url, 8 * 1024 * 1024)
                local extension

                if bytes:sub(1, 8) == "\137PNG\r\n\26\n" then
                    extension = ".png"
                elseif bytes:sub(1, 3) == "\255\216\255" then
                    extension = ".jpg"
                else
                    error("Unsupported artwork format.")
                end

                if destroyed or version ~= artworkVersion then
                    return nil
                end

                ensureFolders()

                local path = artworkFolder .. "/"
                    .. HttpService:GenerateGUID(false) .. extension

                writefile(path, bytes)
                return assetFn(path)
            end)

            if destroyed or version ~= artworkVersion then
                return
            end

            if ok and type(asset) == "string" and asset ~= "" then
                artworkCache[url] = asset
                artwork.Image = asset
            end
        end)
    end

    local function resetSong()
        title.Text = "No track selected"
        artist.Text = "Local MP3 player"
        playButton.Text = ">"
        currentLabel.Text = "00:00"
        durationLabel.Text = "00:00"
        progressFill.Size = UDim2.fromScale(0, 1)
        setArtwork(nil)
    end

    local function clearLogin()
        if spotifyAuth then
            spotifyAuth:Destroy()
            spotifyAuth = nil
        end

        loginLinkBox.Text = ""
        callbackBox.Text = ""
    end

    local function stopSpotifyPolling()
        if spotify then
            spotify:StopPolling()
        end

        spotifyState = nil
    end

    local function activateLocal()
        sessionVersion += 1
        spotifyBusy = false

        stopSpotifyPolling()

        source = "local"
        header.Text = "Music Player - MP3"
    end

    refreshQueue = function()
        for _, object in ipairs(playlist:GetChildren()) do
            if object:IsA("TextButton") then
                object:Destroy()
            end
        end

        for index, track in ipairs(queue) do
            local row = button(
                playlist,
                "Track_" .. index,
                (index == selected and "> " or "")
                    .. tostring(track.title or "Untitled"),
                UDim2.fromOffset(0, 0),
                UDim2.new(1, -8, 0, 25)
            )

            row.LayoutOrder = index
            row.TextXAlignment = Enum.TextXAlignment.Left

            row.Activated:Connect(function()
                playTrack(index)
            end)
        end
    end

    playTrack = function(index)
        if destroyed then
            return
        end

        if loginBusy then
            message("Wait for Spotify login to finish.")
            return
        end

        local track = queue[index]

        if not track then
            return
        end

        if not assetFn then
            message("Local playback needs getcustomasset/getsynasset.")
            return
        end

        if not validLocalPath(track.path) then
            message("Invalid local audio path.")
            return
        end

        activateLocal()

        audioVersion += 1
        local version = audioVersion

        sound:Stop()
        sound.SoundId = ""
        selected = index

        title.Text = tostring(track.title or "Untitled")
        artist.Text = tostring(track.artist or "Local audio")
        setArtwork(track.artworkUrl)
        refreshQueue()

        local ok = pcall(function()
            if type(isfile) == "function" then
                assert(isfile(track.path), "Audio file is missing.")
            end

            sound.SoundId = assetFn(track.path)
            sound:Play()
        end)

        if not ok then
            message("Could not play the local audio file.")
            return
        end

        message("Loading: " .. title.Text)

        task.delay(10, function()
            if not destroyed
                and version == audioVersion
                and source == "local"
                and not sound.IsLoaded
            then
                message(
                    "Audio did not load. Check the file and custom audio support."
                )
            end
        end)
    end

    local function scanFolder()
        assert(type(listfiles) == "function", "listfiles unavailable.")

        ensureFolders()

        local known = {}

        for _, track in ipairs(queue) do
            known[normalizePath(track.path)] = true
        end

        local files = listfiles(mp3Folder)
        table.sort(files)

        local added = 0

        for _, path in ipairs(files) do
            path = normalizePath(path)

            if validLocalPath(path) and not known[path] then
                local filename = path:match("([^/]+)$") or path

                table.insert(queue, {
                    title = filename:gsub("%.[^.]+$", ""),
                    artist = "Local audio",
                    path = path,
                })

                known[path] = true
                added += 1
            end
        end

        saveQueue()
        refreshQueue()

        message("Scan complete. Added " .. added .. " track(s).")
    end

    local function audioExtension(bytes)
        if bytes:sub(1, 4) == "OggS" then
            return ".ogg"
        end

        if bytes:sub(1, 3) == "ID3" then
            return ".mp3"
        end

        local a, b = bytes:byte(1, 2)

        if a == 255 and b and b >= 224 then
            return ".mp3"
        end

        error("URL did not return recognizable MP3/OGG data.")
    end

    local function downloadTrack(track)
        assert(type(track) == "table", "Invalid track.")
        assert(
            type(track.audioUrl) == "string",
            "Resolver returned a track without audioUrl."
        )

        local bytes = fetchBytes(
            track.audioUrl,
            self.MaxDownloadBytes
        )

        local extension = audioExtension(bytes)

        if destroyed then
            return false
        end

        ensureFolders()

        local name = safeName(track.title or "Downloaded track")

        local path = mp3Folder .. "/" .. name .. "_"
            .. HttpService:GenerateGUID(false) .. extension

        writefile(path, bytes)

        table.insert(queue, {
            title = name,
            artist = tostring(track.artist or "Downloaded audio"),
            path = path,
            artworkUrl = type(track.artworkUrl) == "string"
                and track.artworkUrl or nil,
            sourceUrl = track.sourceUrl or track.audioUrl,
        })

        saveQueue()
        refreshQueue()
        return true
    end

    local function downloadURL()
        if downloadBusy then
            message("A download is already running.")
            return
        end

        local url = trim(urlBox.Text)

        if url == "" then
            message("Paste a link first.")
            return
        end

        local youtube = isYouTubeURL(url)

        if youtube and type(self.YouTubeResolver) ~= "function" then
            message(
                "YouTube resolver is not configured. "
                    .. "Use a direct MP3/OGG link or a local file."
            )
            return
        end

        local requestedName = trim(nameBox.Text)
        downloadBusy = true

        task.spawn(function()
            local added = 0

            local ok, err = pcall(function()
                local tracks

                if youtube then
                    message("Resolving YouTube link...")
                    tracks = self.YouTubeResolver(url)

                    assert(
                        type(tracks) == "table" and #tracks > 0,
                        "Resolver returned no downloadable tracks."
                    )

                    assert(#tracks <= 100, "Playlist exceeds 100 tracks.")
                else
                    tracks = {
                        {
                            title = requestedName ~= ""
                                and requestedName
                                or "Downloaded track",
                            artist = "Downloaded audio",
                            audioUrl = url,
                            sourceUrl = url,
                        },
                    }
                end

                for index, track in ipairs(tracks) do
                    if destroyed then
                        return
                    end

                    message(
                        "Downloading " .. index .. "/" .. #tracks .. "..."
                    )

                    if downloadTrack(track) then
                        added += 1
                    end
                end
            end)

            downloadBusy = false

            if destroyed then
                return
            end

            if not ok then
                message(
                    "Download stopped after " .. added
                        .. " track(s): " .. tostring(err)
                )
                return
            end

            showPage("local")
            message(
                "Added " .. added .. " track(s). Click a track to play."
            )
        end)
    end

    local function updateSpotify(state)
        if destroyed or source ~= "spotify" then
            return
        end

        spotifyState = state
        spotifyReceivedAt = os.clock()

        local item = state and state.item

        if not item then
            title.Text = "No active Spotify track"
            artist.Text = "Open Spotify and start a song."
            playButton.Text = ">"
            setArtwork(nil)
            return
        end

        title.Text = item.name or "Unknown track"

        local artists = {}

        for _, entry in ipairs(item.artists or {}) do
            table.insert(artists, entry.name or "Unknown artist")
        end

        artist.Text = #artists > 0
            and table.concat(artists, ", ")
            or (item.show and item.show.name)
            or "Spotify"

        playButton.Text = state.is_playing and "||" or ">"

        local images = item.album and item.album.images
            or item.images
            or (item.show and item.show.images)

        local image = images and (images[2] or images[1])
        setArtwork(image and image.url or nil)
    end

    local function ensureSpotifyClient()
        if spotify then
            return spotify
        end

        assert(
            self.SpotifyModule
                and type(self.SpotifyModule.new) == "function",
            "Call SetSpotifyModule with your SpotifyAPI module."
        )

        spotify = self.SpotifyModule.new()
        return spotify
    end

    local function connectSpotifyToken(accessToken)
        if destroyed then
            return false, "Player was destroyed."
        end

        if spotifyBusy then
            return false, "Spotify is busy."
        end

        if type(accessToken) ~= "string" or accessToken == "" then
            return false, "Missing Spotify access token."
        end

        local made, result = pcall(ensureSpotifyClient)

        if not made then
            return false, tostring(result)
        end

        sessionVersion += 1
        audioVersion += 1

        local version = sessionVersion
        spotifyBusy = true

        sound:Stop()
        stopSpotifyPolling()

        source = "spotify"
        header.Text = "Music Player - Spotify"
        resetSong()
        artist.Text = "Connecting to Spotify..."
        message("Connecting to Spotify...")

        task.spawn(function()
            local ran, ok, state = pcall(function()
                return spotify:Connect(accessToken)
            end)

            accessToken = nil

            if destroyed or version ~= sessionVersion then
                return
            end

            spotifyBusy = false

            if not ran or not ok then
                message(
                    ran and tostring(state)
                        or "Spotify connection failed."
                )
                return
            end

            updateSpotify(state)
            message("Spotify connected.")

            spotify:StartPolling(function(newState)
                if not destroyed and version == sessionVersion then
                    updateSpotify(newState)
                end
            end, function(err, code)
                if destroyed or version ~= sessionVersion then
                    return
                end

                message(err)

                if code == 401 then
                    spotify:StopPolling()
                    message("Spotify token expired. Sign in again.")
                end
            end, self.PollInterval)
        end)

        return true
    end

    local function spotifyCommand(methodName, ...)
        if not spotify or not spotify.Connected then
            message("Connect Spotify first.")
            return
        end

        if spotifyBusy or loginBusy then
            message("Wait for Spotify's current request.")
            return
        end

        spotifyBusy = true

        local version = sessionVersion
        local arguments = table.pack(...)

        task.spawn(function()
            local ran, ok, err = pcall(function()
                return spotify[methodName](
                    spotify,
                    table.unpack(arguments, 1, arguments.n)
                )
            end)

            if destroyed or version ~= sessionVersion then
                return
            end

            if not ran or not ok then
                message(
                    ran and tostring(err)
                        or "Spotify command failed."
                )
            else
                task.wait(0.5)

                if destroyed or version ~= sessionVersion then
                    return
                end

                local readRan, readOK, state = pcall(function()
                    return spotify:GetPlayback()
                end)

                if not destroyed and version == sessionVersion then
                    if readRan and readOK then
                        updateSpotify(state)
                    end
                end
            end

            if version == sessionVersion then
                spotifyBusy = false
            end
        end)
    end

    -- Spotify login controls.
    connect(copyRedirectButton.Activated, function()
        local copied = false

        if type(setclipboard) == "function" then
            copied = pcall(setclipboard, REDIRECT_URI)
        end

        message(
            copied
                and "Redirect URL copied. Save it in your Spotify app settings."
                or "Select and copy the redirect URL manually."
        )
    end)

    connect(beginLoginButton.Activated, function()
        if loginBusy or spotifyBusy then
            message("Wait for the current Spotify request.")
            return
        end

        local clientId = trim(clientIdBox.Text)

        if clientId == "" then
            message("Paste your Spotify app client ID first.")
            return
        end

        if not self.SpotifyLoginModule then
            message("SpotifyLogin.lua is not connected in your loader.")
            return
        end

        if not self.SpotifyModule then
            message("SpotifyAPI.lua is not connected in your loader.")
            return
        end

        clearLogin()

        local ok, result = pcall(function()
            spotifyAuth = self.SpotifyLoginModule.new({
                ClientId = clientId,
            })

            return spotifyAuth:Begin()
        end)

        if not ok then
            clearLogin()
            message("Could not create login: " .. tostring(result))
            return
        end

        loginLinkBox.Text = result

        local copied = false

        if type(setclipboard) == "function" then
            copied = pcall(setclipboard, result)
        end

        message(
            copied
                and "Login link copied. Paste it into your browser."
                or "Copy the login link above and open it in your browser."
        )
    end)

    connect(completeLoginButton.Activated, function()
        if loginBusy or spotifyBusy then
            message("Wait for the current Spotify request.")
            return
        end

        if not spotifyAuth then
            message("Click '1. Copy Login Link' first.")
            return
        end

        local callbackURL = trim(callbackBox.Text)

        if callbackURL == "" then
            message("Paste the full redirected browser address.")
            return
        end

        local auth = spotifyAuth
        loginBusy = true

        callbackBox.Text = ""
        completeLoginButton.Text = "Connecting..."
        message("Completing Spotify login...")

        task.spawn(function()
            local ran, ok, result = pcall(function()
                return auth:Complete(callbackURL)
            end)

            callbackURL = nil
            loginBusy = false

            if destroyed then
                return
            end

            completeLoginButton.Text = "3. Complete Login"

            if spotifyAuth ~= auth then
                return
            end

            if not ran or not ok then
                message(
                    ran and tostring(result)
                        or "Login failed. Create a new login link."
                )
                return
            end

            local token = result.access_token

            -- Automatic refresh is not implemented in this version.
            result = nil
            clearLogin()

            local connected, reason = connectSpotifyToken(token)
            token = nil

            if not connected then
                message(reason)
            end
        end)
    end)

    local function disconnectSpotify()
        if loginBusy then
            message("Wait for the login request to finish.")
            return false
        end

        sessionVersion += 1
        spotifyBusy = false
        clearLogin()

        if spotify then
            spotify:Disconnect()
        end

        spotifyState = nil

        if source == "spotify" then
            source = "local"
            header.Text = "Music Player - MP3"
            resetSong()
        end

        message("Spotify disconnected.")
        return true
    end

    connect(disconnectButton.Activated, disconnectSpotify)

    -- Tabs.
    connect(localTab.Activated, function()
        showPage("local")
    end)

    connect(linksTab.Activated, function()
        showPage("links")
    end)

    connect(spotifyTab.Activated, function()
        showPage("spotify")
    end)

    -- Library controls.
    connect(scanButton.Activated, function()
        if downloadBusy then
            message("Wait for the download to finish.")
            return
        end

        local ok, err = pcall(scanFolder)

        if not ok then
            message("Scan failed: " .. tostring(err))
        end
    end)

    connect(clearButton.Activated, function()
        if downloadBusy then
            message("Wait for the download to finish.")
            return
        end

        if source == "local" then
            audioVersion += 1
            sound:Stop()
            sound.SoundId = ""
            resetSong()
        end

        selected = 0
        table.clear(queue)

        saveQueue()
        refreshQueue()
        message("Playlist cleared. Audio files were not deleted.")
    end)

    connect(volumeBox.FocusLost, function()
        local value = tonumber(volumeBox.Text)

        if value and value == value
            and value ~= math.huge and value ~= -math.huge
        then
            value = math.clamp(value, 0, 100)
            sound.Volume = value / 100
        end

        volumeBox.Text = tostring(math.floor(sound.Volume * 100))

        if source == "spotify" then
            message("This volume setting affects local audio only.")
        end
    end)

    -- Downloads and saved links.
    connect(downloadButton.Activated, downloadURL)

    connect(saveLinkButton.Activated, function()
        local url = trim(urlBox.Text)

        if not url:match("^https?://") then
            message("Enter an HTTP/HTTPS link.")
            return
        end

        if not table.find(savedLinks, url) then
            table.insert(savedLinks, url)
        end

        local ok = pcall(function()
            ensureFolders()
            writeJSON(linksFile, savedLinks)
        end)

        message(ok and "Link saved." or "Could not save links.")
    end)

    connect(savedLinkButton.Activated, function()
        if #savedLinks == 0 then
            message("No saved links.")
            return
        end

        savedIndex = savedIndex % #savedLinks + 1
        urlBox.Text = savedLinks[savedIndex]
        message("Saved link " .. savedIndex .. "/" .. #savedLinks)
    end)

    -- Playback.
    connect(playButton.Activated, function()
        if source == "spotify" then
            spotifyCommand("TogglePlayback")
            return
        end

        if sound.IsPlaying then
            sound:Pause()
        elseif sound.SoundId ~= "" and selected > 0 then
            if sound.TimeLength > 0
                and sound.TimePosition >= sound.TimeLength - 0.05
            then
                sound.TimePosition = 0
                sound:Play()
            else
                sound:Resume()
            end
        elseif #queue > 0 then
            playTrack(selected > 0 and selected or 1)
        else
            message("Scan your MP3 folder or download an audio file.")
        end
    end)

    connect(previousButton.Activated, function()
        if source == "spotify" then
            spotifyCommand("Previous")
        elseif #queue > 0 then
            playTrack(selected > 1 and selected - 1 or #queue)
        end
    end)

    connect(nextButton.Activated, function()
        if source == "spotify" then
            spotifyCommand("Next")
        elseif #queue > 0 then
            playTrack(selected % #queue + 1)
        end
    end)

    connect(sound.Ended, function()
        if source == "local" and selected < #queue then
            playTrack(selected + 1)
        end
    end)

    connect(sound.Loaded, function()
        if source == "local" then
            message("Loaded: " .. title.Text)
        end
    end)

    connect(seekButton.InputBegan, function(event)
        if event.UserInputType ~= Enum.UserInputType.MouseButton1
            and event.UserInputType ~= Enum.UserInputType.Touch
        then
            return
        end

        if timeline.AbsoluteSize.X <= 0 then
            return
        end

        local alpha = math.clamp(
            (event.Position.X - timeline.AbsolutePosition.X)
                / timeline.AbsoluteSize.X,
            0,
            1
        )

        if source == "spotify" then
            local item = spotifyState and spotifyState.item

            if item and item.duration_ms then
                spotifyCommand(
                    "Seek",
                    math.floor(item.duration_ms * alpha)
                )
            end
        elseif sound.IsLoaded then
            sound.TimePosition = sound.TimeLength * alpha
        end
    end)

    local elapsed = 0

    connect(RunService.Heartbeat, function(delta)
        elapsed += delta

        if elapsed < 0.2 or not main.Visible then
            return
        end

        elapsed = 0

        local position = 0
        local duration = 0

        if source == "spotify" then
            local state = spotifyState
            local item = state and state.item

            duration = item and (item.duration_ms or 0) / 1000 or 0
            position = state and (state.progress_ms or 0) / 1000 or 0

            if state and state.is_playing then
                position += os.clock() - spotifyReceivedAt
            end
        else
            duration = sound.TimeLength
            position = sound.TimePosition
            playButton.Text = sound.IsPlaying and "||" or ">"
        end

        duration = math.max(0, duration)
        position = math.clamp(position, 0, duration)

        currentLabel.Text = formatTime(position)
        durationLabel.Text = formatTime(duration)

        progressFill.Size = UDim2.fromScale(
            duration > 0 and position / duration or 0,
            1
        )
    end)

    -- Header dragging.
    header.Active = true

    local dragging = false
    local dragTouch
    local dragStart
    local initialPosition

    connect(header.InputBegan, function(event)
        if event.UserInputType == Enum.UserInputType.MouseButton1
            or event.UserInputType == Enum.UserInputType.Touch
        then
            dragging = true

            dragTouch = event.UserInputType == Enum.UserInputType.Touch
                and event or nil

            dragStart = event.Position
            initialPosition = main.Position
        end
    end)

    connect(UserInputService.InputChanged, function(event)
        if not dragging then
            return
        end

        if event == dragTouch or (
            not dragTouch
            and event.UserInputType == Enum.UserInputType.MouseMovement
        ) then
            local delta = event.Position - dragStart

            main.Position = UDim2.new(
                initialPosition.X.Scale,
                initialPosition.X.Offset + delta.X,
                initialPosition.Y.Scale,
                initialPosition.Y.Offset + delta.Y
            )
        end
    end)

    connect(UserInputService.InputEnded, function(event)
        if event == dragTouch or (
            not dragTouch
            and event.UserInputType == Enum.UserInputType.MouseButton1
        ) then
            dragging = false
            dragTouch = nil
        end
    end)

    -- Public API.
    function player:SetVisible(value)
        if destroyed then
            return
        end

        MusicModule.Show = value == true
        main.Visible = MusicModule.Show
    end

    function player:ToggleVisibility()
        self:SetVisible(not main.Visible)
    end

    function player:ShowSpotifySetup()
        if destroyed then
            return
        end

        showPage("spotify")
        self:SetVisible(true)
    end

    function player:ConnectSpotifyToken(token)
        return connectSpotifyToken(token)
    end

    function player:Disconnect()
        if not disconnectSpotify() then
            return
        end

        audioVersion += 1
        sound:Stop()
        sound.SoundId = ""

        source = "local"
        header.Text = "Music Player - MP3"
        resetSong()
    end

    function player:ScanFolder()
        if downloadBusy then
            return false, "A download is running."
        end

        return pcall(scanFolder)
    end

    local function cleanup()
        if destroyed then
            return
        end

        destroyed = true
        player.Destroyed = true

        sessionVersion += 1
        audioVersion += 1
        artworkVersion += 1

        clearLogin()

        if spotify then
            pcall(function()
                spotify:Destroy()
            end)
        end

        clientIdBox.Text = ""
        sound:Destroy()

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
        main:Destroy()
    end

    connect(hideButton.Activated, function()
        player:SetVisible(false)
    end)

    connect(main.Destroying, cleanup)

    -- Load local storage without blocking Spotify mode if it fails.
    local initialized, initError = pcall(function()
        ensureFolders()

        local storedQueue = readJSON(queueFile)

        if storedQueue then
            for _, track in ipairs(storedQueue) do
                if type(track) == "table"
                    and type(track.path) == "string"
                    and validLocalPath(track.path)
                then
                    table.insert(queue, {
                        title = tostring(track.title or "Untitled"),
                        artist = tostring(track.artist or "Local audio"),
                        path = normalizePath(track.path),
                        artworkUrl = type(track.artworkUrl) == "string"
                            and track.artworkUrl or nil,
                        sourceUrl = type(track.sourceUrl) == "string"
                            and track.sourceUrl or nil,
                    })
                end
            end
        end

        local storedLinks = readJSON(linksFile)

        if storedLinks then
            for _, url in ipairs(storedLinks) do
                if type(url) == "string" and url:match("^https?://") then
                    table.insert(savedLinks, url)
                end
            end
        end

        if type(listfiles) == "function" then
            scanFolder()
        end
    end)

    refreshQueue()

    if not initialized then
        message("Local storage unavailable: " .. tostring(initError))
    end

    player.MainFrame = main
    player.Artwork = artwork
    player.Sound = sound
    player.ClientIdBox = clientIdBox
    player.RedirectBox = redirectBox
    player.CallbackBox = callbackBox

    activePlayer = player
    return player
end

return MusicModule
