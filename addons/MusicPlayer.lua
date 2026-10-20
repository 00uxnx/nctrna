local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local MusicModule = {
    Library = nil,
    SpotifyModule = nil,
    YouTubeResolver = nil,

    Show = false,
    PollInterval = 5,

    Root = "nocturne.bz/player",
    PlaceholderImage = "rbxassetid://11653546524",

    MaxDownloadBytes = 40 * 1024 * 1024,
}

local activePlayer

function MusicModule:SetLibrary(value)
    self.Library = value
    return self
end

function MusicModule:SetSpotifyModule(value)
    self.SpotifyModule = value
    return self
end

-- Optional integration contract:
-- resolver(url) -> array of:
-- {
--     title = "Track",
--     artist = "Artist",
--     audioUrl = "https://.../authorized-audio.mp3",
--     artworkUrl = "https://.../cover.jpg", -- optional
-- }
--
-- The resolver must supply actual downloadable audio URLs.
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

local function safeName(value)
    local name = trim(value):gsub("[^%w%s_%-]", "_")
    name = name:gsub("%s+", " "):sub(1, 70)
    return name ~= "" and name or "Untitled"
end

local function timeText(seconds)
    seconds = math.floor(math.max(0, tonumber(seconds) or 0))

    return string.format(
        "%02d:%02d",
        math.floor(seconds / 60),
        seconds % 60
    )
end

local function normalizePath(path)
    return tostring(path):gsub("\\", "/")
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

    local root = self.Root
    local mp3Folder = root .. "/mp3"
    local linksFolder = root .. "/links"
    local playlistsFolder = root .. "/playlists"
    local artworkFolder = root .. "/artwork"

    local queueFile = playlistsFolder .. "/default.json"
    local linksFile = linksFolder .. "/saved.json"

    local player = {
        Destroyed = false,
        Window = window,
    }

    local connections = {}
    local queue = {}
    local savedLinks = {}

    local selected = 0
    local source = "local"
    local destroyed = false
    local busy = false
    local operation = 0
    local audioVersion = 0
    local artVersion = 0

    local spotify
    local spotifyState
    local spotifyReceivedAt = os.clock()

    local artCache = {}
    local currentArt
    local refreshQueue
    local playTrack

    local strokeColor = library.UIstroke
        or library.UIStroke
        or Color3.new(0, 0, 0)

    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
    end

    local function create(class, properties, ...)
        return library:Create(class, properties, ...)
    end

    local function bind(property, value)
        return {
            instancep = property,
            tinstance = value,
        }
    end

    local function outline(parent)
        return create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            Color = library.SecondaryColor,
            Thickness = 1,
            Parent = parent,
        }, bind("Color", library.SecondaryColor))
    end

    local function frame(parent, name, position, size, transparent)
        return create("Frame", {
            Name = name,
            Position = position,
            Size = size,
            BackgroundColor3 = library.MainColor,
            BackgroundTransparency = transparent and 1 or 0,
            Parent = parent,
        }, bind("BackgroundColor3", library.MainColor))
    end

    local function text(parent, name, value, position, size, fontSize)
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
            bind("Font", library.Font),
            bind("TextColor3", library.FontColor)
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
            Parent = parent,
        },
            bind("BackgroundColor3", library.MainColor),
            bind("Font", library.Font),
            bind("TextColor3", library.FontColor)
        )

        outline(object)
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
            PlaceholderColor3 = Color3.fromRGB(130, 130, 130),
            ClearTextOnFocus = false,
            MultiLine = false,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = parent,
        },
            bind("BackgroundColor3", library.MainColor),
            bind("Font", library.Font),
            bind("TextColor3", library.FontColor)
        )

        outline(object)

        create("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            Parent = object,
        })

        return object
    end

    local main = frame(
        library.scgo,
        "MusicPlayer",
        UDim2.fromScale(0.5, 0.5),
        UDim2.fromOffset(588, 431)
    )

    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Visible = self.Show
    main.Active = true
    outline(main)

    create("Frame", {
        Name = "Accent",
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = library.AccentColor,
        Parent = main,
    }, bind("BackgroundColor3", library.AccentColor))

    local header = text(
        main, "Header", "Music Player",
        UDim2.fromOffset(9, 3),
        UDim2.new(1, -40, 0, 21), 14
    )

    local close = button(
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
        tabs, "MP3", "MP3 / Library",
        UDim2.fromOffset(0, 0),
        UDim2.fromOffset(184, 23)
    )

    local linksTab = button(
        tabs, "Links", "Links / Download",
        UDim2.fromOffset(194, 0),
        UDim2.fromOffset(184, 23)
    )

    local spotifyTab = button(
        tabs, "Spotify", "Spotify",
        UDim2.fromOffset(388, 0),
        UDim2.fromOffset(184, 23)
    )

    local songPanel = frame(
        main, "Song",
        UDim2.fromOffset(8, 66),
        UDim2.new(1, -16, 0, 119)
    )
    outline(songPanel)

    local artwork = create("ImageLabel", {
        Name = "Artwork",
        Position = UDim2.fromOffset(12, 13),
        Size = UDim2.fromOffset(90, 90),
        BackgroundTransparency = 1,
        Image = self.PlaceholderImage,
        ScaleType = Enum.ScaleType.Fit,
        Parent = songPanel,
    })
    outline(artwork)

    local title = text(
        songPanel, "Title", "No track selected",
        UDim2.fromOffset(115, 10),
        UDim2.new(1, -126, 0, 25), 16
    )

    local artist = text(
        songPanel, "Artist", "Local MP3 player",
        UDim2.fromOffset(115, 37),
        UDim2.new(1, -126, 0, 20), 13
    )

    local timeline = frame(
        songPanel, "Timeline",
        UDim2.fromOffset(115, 67),
        UDim2.new(1, -127, 0, 6)
    )
    outline(timeline)

    local fill = create("Frame", {
        Name = "Progress",
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = library.AccentColor,
        Parent = timeline,
    }, bind("BackgroundColor3", library.AccentColor))

    local seek = create("TextButton", {
        Name = "Seek",
        Position = UDim2.fromOffset(0, -4),
        Size = UDim2.new(1, 0, 1, 8),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 3,
        Parent = timeline,
    })

    local currentLabel = text(
        songPanel, "Current", "00:00",
        UDim2.fromOffset(115, 79),
        UDim2.fromOffset(55, 18), 12
    )

    local durationLabel = text(
        songPanel, "Duration", "00:00",
        UDim2.new(1, -68, 0, 79),
        UDim2.fromOffset(55, 18), 12
    )
    durationLabel.TextXAlignment = Enum.TextXAlignment.Right

    local previous = button(
        songPanel, "Previous", "<<",
        UDim2.fromOffset(205, 83),
        UDim2.fromOffset(43, 25)
    )

    local play = button(
        songPanel, "PlayPause", ">",
        UDim2.fromOffset(273, 83),
        UDim2.fromOffset(43, 25)
    )

    local nextButton = button(
        songPanel, "Next", ">>",
        UDim2.fromOffset(341, 83),
        UDim2.fromOffset(43, 25)
    )

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

    local scan = button(
        localPage, "Scan", "Scan MP3 folder",
        UDim2.fromOffset(0, 0),
        UDim2.fromOffset(150, 23)
    )

    local clear = button(
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

    local list = create("ScrollingFrame", {
        Name = "Playlist",
        Position = UDim2.fromOffset(0, 33),
        Size = UDim2.new(1, 0, 1, -33),
        BackgroundColor3 = library.MainColor,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        Parent = localPage,
    }, bind("BackgroundColor3", library.MainColor))
    outline(list)

    create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = list,
    })

    create("UIPadding", {
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = list,
    })

    local urlBox = input(
        linksPage, "URL", "Direct HTTPS MP3/OGG URL or YouTube link",
        UDim2.fromOffset(0, 0),
        UDim2.new(1, 0, 0, 25)
    )

    local nameBox = input(
        linksPage, "Name", "Track name (optional)",
        UDim2.fromOffset(0, 35),
        UDim2.new(1, 0, 0, 25)
    )

    local download = button(
        linksPage, "Download", "Download / Add",
        UDim2.fromOffset(0, 72),
        UDim2.fromOffset(180, 25)
    )

    local saveLink = button(
        linksPage, "SaveLink", "Save link",
        UDim2.fromOffset(192, 72),
        UDim2.fromOffset(180, 25)
    )

    local nextSaved = button(
        linksPage, "SavedLinks", "Next saved link",
        UDim2.fromOffset(384, 72),
        UDim2.new(1, -384, 0, 25)
    )

    local linkInfo = text(
        linksPage, "Info",
        "Direct audio downloads work without a converter.\n"
            .. "YouTube downloads require a configured resolver.\n"
            .. "Files: " .. mp3Folder .. "\n"
            .. "Only download audio you have permission to use.",
        UDim2.fromOffset(0, 110),
        UDim2.new(1, 0, 0, 80), 13
    )
    linkInfo.TextWrapped = true
    linkInfo.TextTruncate = Enum.TextTruncate.None
    linkInfo.TextYAlignment = Enum.TextYAlignment.Top

    local tokenBox = input(
        spotifyPage, "Token", "Spotify OAuth access token",
        UDim2.fromOffset(0, 0),
        UDim2.new(1, 0, 0, 25)
    )

    local spotifyConnect = button(
        spotifyPage, "Connect", "Connect Spotify",
        UDim2.fromOffset(0, 37),
        UDim2.fromOffset(180, 25)
    )

    local spotifyDisconnect = button(
        spotifyPage, "Disconnect", "Disconnect",
        UDim2.fromOffset(192, 37),
        UDim2.fromOffset(180, 25)
    )

    local spotifyInfo = text(
        spotifyPage, "Info",
        "Optional Spotify mode uses your existing Spotify API module.\n"
            .. "Spotify account/API restrictions still apply.\n"
            .. "Local MP3 playback does not need Spotify.",
        UDim2.fromOffset(0, 77),
        UDim2.new(1, 0, 0, 80), 13
    )
    spotifyInfo.TextWrapped = true
    spotifyInfo.TextTruncate = Enum.TextTruncate.None
    spotifyInfo.TextYAlignment = Enum.TextYAlignment.Top

    local status = text(
        main, "Status", "Ready.",
        UDim2.fromOffset(9, 396),
        UDim2.new(1, -18, 0, 27), 12
    )
    status.TextWrapped = true
    status.TextTruncate = Enum.TextTruncate.None

    local sound = Instance.new("Sound")
    sound.Name = "NocturneMusicPlayer"
    sound.Volume = 0.5
    sound.Parent = SoundService

    local function message(value)
        if not destroyed then
            status.Text = tostring(value)
        end
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
            mp3Folder, linksFolder, playlistsFolder, artworkFolder,
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

        local ok, value = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)

        return ok and type(value) == "table" and value or nil
    end

    local function saveQueue()
        local ok = pcall(function()
            ensureFolders()
            writeJSON(queueFile, queue)
        end)

        if not ok then
            message("Playlist changed, but could not be saved.")
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
        assert(
            tonumber(response.StatusCode or response.Status) == 200,
            "Download failed: HTTP "
                .. tostring(response.StatusCode or response.Status)
        )

        local body = response.Body

        assert(type(body) == "string" and #body > 0, "Empty download.")
        assert(#body <= maximum, "Download exceeds the size limit.")

        return body
    end

    local function setArtwork(url)
        if currentArt == url then
            return
        end

        currentArt = url
        artVersion += 1

        local version = artVersion
        artwork.Image = self.PlaceholderImage

        if type(url) ~= "string" or not url:match("^https://") then
            return
        end

        if artCache[url] then
            artwork.Image = artCache[url]
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

                if destroyed or version ~= artVersion then
                    return nil
                end

                ensureFolders()

                local path = artworkFolder .. "/"
                    .. HttpService:GenerateGUID(false) .. extension

                writefile(path, bytes)
                return assetFn(path)
            end)

            if destroyed or version ~= artVersion then
                return
            end

            if ok and type(asset) == "string" then
                artCache[url] = asset
                artwork.Image = asset
            end
        end)
    end

    local function stopSpotify()
        if spotify then
            spotify:StopPolling()
        end

        spotifyState = nil
    end

    local function activateLocal()
        if source ~= "local" then
            operation += 1
            busy = false
            stopSpotify()
            source = "local"

            title.Text = "No track selected"
            artist.Text = "Local MP3 player"
            play.Text = ">"
            setArtwork(nil)
        end

        header.Text = "Music Player - MP3"
    end

    local function showPage(page)
        localPage.Visible = page == "local"
        linksPage.Visible = page == "links"
        spotifyPage.Visible = page == "spotify"
    end

    local function validLocalPath(path)
        path = normalizePath(path)

        return path:sub(1, #mp3Folder + 1) == mp3Folder .. "/"
            and not path:find("..", 1, true)
            and (
                path:lower():match("%.mp3$")
                or path:lower():match("%.ogg$")
            )
    end

    refreshQueue = function()
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for index, track in ipairs(queue) do
            local row = button(
                list,
                "Track_" .. index,
                (index == selected and "> " or "")
                    .. tostring(track.title or "Untitled"),
                UDim2.fromOffset(0, 0),
                UDim2.new(1, -8, 0, 25)
            )
            row.LayoutOrder = index
            row.TextXAlignment = Enum.TextXAlignment.Left

            -- This connection dies with its row.
            row.Activated:Connect(function()
                playTrack(index)
            end)
        end
    end

    playTrack = function(index)
        if destroyed then
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
            message("Track path is outside the MP3 folder or unsupported.")
            return
        end

        activateLocal()

        audioVersion += 1
        local version = audioVersion

        sound:Stop()
        selected = index

        title.Text = tostring(track.title or "Untitled")
        artist.Text = tostring(track.artist or "Local audio")
        setArtwork(track.artworkUrl)
        refreshQueue()

        local ok = pcall(function()
            if type(isfile) == "function" then
                assert(isfile(track.path), "File missing.")
            end

            sound.SoundId = assetFn(track.path)
            sound:Play()
        end)

        if not ok then
            message("Could not play this local audio file.")
            return
        end

        message("Loading: " .. title.Text)

        task.delay(10, function()
            if not destroyed and version == audioVersion
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
                local name = path:match("([^/]+)$") or path

                table.insert(queue, {
                    title = name:gsub("%.[^.]+$", ""),
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

        error("URL did not return recognizable MP3/OGG audio.")
    end

    local function downloadTrack(track, version)
        assert(type(track) == "table", "Invalid track.")
        assert(type(track.audioUrl) == "string", "Missing audio URL.")

        local bytes = fetchBytes(track.audioUrl, self.MaxDownloadBytes)
        local extension = audioExtension(bytes)

        if destroyed or version ~= operation then
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
            artworkUrl = track.artworkUrl,
            sourceUrl = track.sourceUrl or track.audioUrl,
        })

        return true
    end

    local function doDownload()
        if busy then
            message("Another operation is running.")
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
                "YouTube downloading is not configured. "
                    .. "Use a direct MP3/OGG link or local file."
            )
            return
        end

        busy = true
        operation += 1

        local version = operation
        local firstNew = #queue + 1

        task.spawn(function()
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
                            title = trim(nameBox.Text) ~= ""
                                and trim(nameBox.Text)
                                or "Downloaded track",
                            audioUrl = url,
                            sourceUrl = url,
                        },
                    }
                end

                for index, track in ipairs(tracks) do
                    if destroyed or version ~= operation then
                        return
                    end

                    message(
                        "Downloading " .. index .. "/" .. #tracks .. "..."
                    )

                    downloadTrack(track, version)

                    if destroyed or version ~= operation then
                        return
                    end

                    saveQueue()
                    refreshQueue()
                end
            end)

            if destroyed or version ~= operation then
                return
            end

            busy = false

            if not ok then
                message("Download failed: " .. tostring(err))
                return
            end

            showPage("local")
            message("Download complete.")

            if queue[firstNew] then
                playTrack(firstNew)
            end
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
            play.Text = ">"
            setArtwork(nil)
            return
        end

        title.Text = item.name or "Unknown track"

        local names = {}

        for _, entry in ipairs(item.artists or {}) do
            table.insert(names, entry.name or "Unknown")
        end

        artist.Text = #names > 0
            and table.concat(names, ", ")
            or (item.show and item.show.name)
            or "Spotify"

        play.Text = state.is_playing and "||" or ">"

        local images = item.album and item.album.images
            or item.images
            or (item.show and item.show.images)

        local image = images and (images[2] or images[1])
        setArtwork(image and image.url or nil)
    end

    local function connectSpotify()
        if busy then
            return
        end

        if not self.SpotifyModule then
            message("Call SetSpotifyModule before using Spotify.")
            return
        end

        local token = trim(tokenBox.Text)

        if token == "" then
            message("Paste a Spotify OAuth access token.")
            return
        end

        local made, result = pcall(function()
            return spotify or self.SpotifyModule.new()
        end)

        if not made then
            message("Spotify module could not initialize.")
            return
        end

        spotify = result

        operation += 1
        audioVersion += 1

        local version = operation
        busy = true

        sound:Stop()
        stopSpotify()
        source = "spotify"
        header.Text = "Music Player - Spotify"
        message("Connecting to Spotify...")

        task.spawn(function()
            local ran, ok, state = pcall(function()
                return spotify:Connect(token)
            end)

            if destroyed or version ~= operation then
                return
            end

            busy = false

            if not ran or not ok then
                message(
                    ran and tostring(state)
                        or "Spotify connection failed."
                )
                return
            end

            tokenBox.Text = ""
            updateSpotify(state)
            message("Spotify connected.")

            spotify:StartPolling(function(newState)
                if version == operation then
                    updateSpotify(newState)
                end
            end, function(err, code)
                if destroyed or version ~= operation then
                    return
                end

                message(err)

                if code == 401 then
                    spotify:StopPolling()
                end
            end, self.PollInterval)
        end)
    end

    local function spotifyCommand(method, ...)
        if not spotify or not spotify.Connected then
            message("Connect Spotify first.")
            return
        end

        if busy then
            return
        end

        busy = true
        local version = operation
        local args = table.pack(...)

        task.spawn(function()
            local ran, ok, err = pcall(function()
                return spotify[method](
                    spotify,
                    table.unpack(args, 1, args.n)
                )
            end)

            if destroyed or version ~= operation then
                return
            end

            if not ran or not ok then
                message(ran and tostring(err) or "Spotify command failed.")
            else
                task.wait(0.5)

                if destroyed or version ~= operation then
                    return
                end

                local refreshed, state = spotify:GetPlayback()

                if refreshed and not destroyed
                    and version == operation
                then
                    updateSpotify(state)
                end
            end

            if version == operation then
                busy = false
            end
        end)
    end

    connect(localTab.Activated, function()
        showPage("local")
    end)

    connect(linksTab.Activated, function()
        showPage("links")
    end)

    connect(spotifyTab.Activated, function()
        showPage("spotify")
    end)

    connect(scan.Activated, function()
        local ok, err = pcall(scanFolder)

        if not ok then
            message("Scan failed: " .. tostring(err))
        end
    end)

    connect(clear.Activated, function()
        if busy then
            message("Wait for the current operation first.")
            return
        end

        if source == "local" then
            audioVersion += 1
            sound:Stop()
            title.Text = "No track selected"
            artist.Text = "Local MP3 player"
            setArtwork(nil)
        end

        selected = 0
        table.clear(queue)

        saveQueue()
        refreshQueue()
        message("Playlist cleared. Audio files were not deleted.")
    end)

    connect(volumeBox.FocusLost, function()
        local value = tonumber(volumeBox.Text)

        if value then
            value = math.clamp(value, 0, 100)
            sound.Volume = value / 100
            volumeBox.Text = tostring(math.floor(value))
        else
            volumeBox.Text = tostring(math.floor(sound.Volume * 100))
        end
    end)

    connect(download.Activated, doDownload)

    connect(saveLink.Activated, function()
        local url = trim(urlBox.Text)

        if not url:match("^https?://") then
            message("Enter a valid HTTP/HTTPS link.")
            return
        end

        if not table.find(savedLinks, url) then
            table.insert(savedLinks, url)
        end

        local ok = pcall(function()
            ensureFolders()
            writeJSON(linksFile, savedLinks)
        end)

        message(
            ok and "Link saved."
                or "Could not save links to disk."
        )
    end)

    local savedIndex = 0

    connect(nextSaved.Activated, function()
        if #savedLinks == 0 then
            message("No saved links.")
            return
        end

        savedIndex = savedIndex % #savedLinks + 1
        urlBox.Text = savedLinks[savedIndex]

        message("Saved link " .. savedIndex .. "/" .. #savedLinks)
    end)

    connect(spotifyConnect.Activated, connectSpotify)

    connect(spotifyDisconnect.Activated, function()
        operation += 1
        busy = false

        if spotify then
            spotify:Disconnect()
        end

        source = "local"
        spotifyState = nil
        tokenBox.Text = ""

        title.Text = "No track selected"
        artist.Text = "Local MP3 player"
        play.Text = ">"
        header.Text = "Music Player - MP3"

        setArtwork(nil)
        message("Spotify disconnected.")
    end)

    connect(play.Activated, function()
        if source == "spotify" then
            spotifyCommand("TogglePlayback")
            return
        end

        if sound.IsPlaying then
            sound:Pause()
        elseif sound.SoundId ~= "" and selected > 0 then
            sound:Resume()
        elseif #queue > 0 then
            playTrack(selected > 0 and selected or 1)
        else
            message("Scan your MP3 folder or download a direct audio link.")
        end
    end)

    connect(previous.Activated, function()
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
            message("Playing: " .. title.Text)
        end
    end)

    connect(seek.InputBegan, function(event)
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
            0, 1
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

    local tickElapsed = 0

    connect(RunService.Heartbeat, function(dt)
        tickElapsed += dt

        if tickElapsed < 0.2 or not main.Visible then
            return
        end

        tickElapsed = 0

        local position, duration = 0, 0

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
            play.Text = sound.IsPlaying and "||" or ">"
        end

        position = math.clamp(position, 0, duration)

        currentLabel.Text = timeText(position)
        durationLabel.Text = timeText(duration)

        fill.Size = UDim2.fromScale(
            duration > 0 and position / duration or 0, 1
        )
    end)

    -- Header dragging.
    header.Active = true

    local dragging = false
    local dragInput
    local dragStart
    local initialPosition

    connect(header.InputBegan, function(event)
        if event.UserInputType == Enum.UserInputType.MouseButton1
            or event.UserInputType == Enum.UserInputType.Touch
        then
            dragging = true

            dragInput = event.UserInputType == Enum.UserInputType.Touch
                and event or nil

            dragStart = event.Position
            initialPosition = main.Position
        end
    end)

    connect(UserInputService.InputChanged, function(event)
        if not dragging then
            return
        end

        if event == dragInput or (
            not dragInput
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
        if event == dragInput or (
            not dragInput
            and event.UserInputType == Enum.UserInputType.MouseButton1
        ) then
            dragging = false
            dragInput = nil
        end
    end)

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

    function player:Disconnect()
        if spotify then
            spotify:Disconnect()
        end

        operation += 1
        audioVersion += 1
        busy = false

        sound:Stop()
        source = "local"
        spotifyState = nil
        tokenBox.Text = ""

        title.Text = "No track selected"
        artist.Text = "Local MP3 player"
        header.Text = "Music Player - MP3"
        setArtwork(nil)
    end

    function player:ScanFolder()
        return pcall(scanFolder)
    end

    local function cleanup()
        if destroyed then
            return
        end

        destroyed = true
        player.Destroyed = true

        operation += 1
        audioVersion += 1
        artVersion += 1

        if spotify then
            spotify:Destroy()
        end

        tokenBox.Text = ""
        sound:Destroy()

        for _, connection in ipairs(connections) do
            connection:Disconnect()
        end

        table.clear(connections)
        table.clear(artCache)

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

    connect(close.Activated, function()
        player:SetVisible(false)
    end)

    connect(main.Destroying, cleanup)

    -- Load only valid entries from the stored playlist.
    local initialized, initError = pcall(function()
        ensureFolders()

        local stored = readJSON(queueFile)

        if stored then
            for _, track in ipairs(stored) do
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
        message("Storage initialization failed: " .. tostring(initError))
    end

    player.MainFrame = main
    player.Artwork = artwork
    player.Sound = sound
    player.TokenBox = tokenBox

    activePlayer = player
    return player
end

return MusicModule
