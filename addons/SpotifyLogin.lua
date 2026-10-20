local HttpService = game:GetService("HttpService")

local SpotifyLogin = {}
SpotifyLogin.__index = SpotifyLogin

local REDIRECT_URI = "http://127.0.0.1:8888/callback"
local BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function trim(value)
    return tostring(value or ""):match("^%s*(.-)%s*$")
end

local function base64Encode(bytes)
    local output = {}

    for index = 1, #bytes, 3 do
        local a = bytes:byte(index)
        local b = bytes:byte(index + 1)
        local c = bytes:byte(index + 2)

        local combined = a * 65536 + (b or 0) * 256 + (c or 0)

        local p1 = math.floor(combined / 262144) % 64
        local p2 = math.floor(combined / 4096) % 64
        local p3 = math.floor(combined / 64) % 64
        local p4 = combined % 64

        table.insert(output, BASE64:sub(p1 + 1, p1 + 1))
        table.insert(output, BASE64:sub(p2 + 1, p2 + 1))
        table.insert(output, b and BASE64:sub(p3 + 1, p3 + 1) or "=")
        table.insert(output, c and BASE64:sub(p4 + 1, p4 + 1) or "=")
    end

    return table.concat(output)
end

local function base64Decode(value)
    assert(
        type(value) == "string"
            and value:match("^[A-Za-z0-9+/=]+$")
            and #value % 4 == 0,
        "Random-byte provider returned invalid Base64."
    )

    local output = {}
    local buffer = 0
    local bits = 0

    for index = 1, #value do
        local char = value:sub(index, index)

        if char == "=" then
            break
        end

        local position = BASE64:find(char, 1, true)
        assert(position, "Invalid Base64 character.")

        buffer = buffer * 64 + position - 1
        bits += 6

        if bits >= 8 then
            bits -= 8

            local divisor = 2 ^ bits
            table.insert(output, string.char(math.floor(buffer / divisor)))
            buffer %= divisor
        end
    end

    return table.concat(output)
end

local function base64URL(bytes)
    return (
        base64Encode(bytes)
            :gsub("%+", "-")
            :gsub("/", "_")
            :gsub("=+$", "")
    )
end

local function hexToBytes(hex)
    assert(
        type(hex) == "string"
            and #hex == 64
            and hex:match("^%x+$"),
        "SHA-256 function must return a 64-character hexadecimal digest."
    )

    return (hex:gsub("%x%x", function(pair)
        return string.char(tonumber(pair, 16))
    end))
end

local function encodeForm(values)
    local output = {}

    for key, value in pairs(values) do
        table.insert(
            output,
            HttpService:UrlEncode(tostring(key))
                .. "="
                .. HttpService:UrlEncode(tostring(value))
        )
    end

    table.sort(output)
    return table.concat(output, "&")
end

local function decodeURLComponent(value)
    value = value:gsub("%+", " ")

    return (value:gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end))
end

local function parseCallback(url)
    local base, query = url:match("^([^?]+)%?([^#]*)")

    assert(
        base == REDIRECT_URI and query,
        "Paste the complete callback URL beginning with " .. REDIRECT_URI
    )

    local parameters = {}

    for pair in query:gmatch("[^&]+") do
        local key, value = pair:match("^([^=]+)=(.*)$")

        if key then
            key = decodeURLComponent(key)

            assert(parameters[key] == nil, "Duplicate callback parameter.")

            parameters[key] = decodeURLComponent(value)
        end
    end

    return parameters
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

function SpotifyLogin.new(options)
    options = options or {}

    local self = setmetatable({}, SpotifyLogin)

    self.ClientId = trim(options.ClientId)
    self.Request = options.Request or resolveRequest()

    self.Scopes = options.Scopes
        or "user-read-playback-state user-modify-playback-state"

    self._pending = nil
    self._busy = false
    self._destroyed = false

    assert(self.ClientId ~= "", "Set your Spotify ClientId.")
    assert(type(self.Request) == "function", "No HTTP request function.")

    -- Custom function contract:
    -- RandomBytes(count) returns exactly count raw random bytes.
    self.RandomBytes = options.RandomBytes

    if not self.RandomBytes then
        local crypto = crypt

        if type(crypto) ~= "table"
            and type(syn) == "table"
        then
            crypto = syn.crypt
        end

        assert(
            type(crypto) == "table"
                and type(crypto.generatebytes) == "function",
            "A secure RandomBytes provider is required."
        )

        -- This adapter expects the common Base64-returning API.
        self.RandomBytes = function(count)
            return base64Decode(crypto.generatebytes(count))
        end
    end

    -- Custom function contract:
    -- SHA256Hex(text) returns a hexadecimal SHA-256 digest.
    self.SHA256Hex = options.SHA256Hex

    if not self.SHA256Hex then
        local crypto = crypt

        if type(crypto) ~= "table"
            and type(syn) == "table"
        then
            crypto = syn.crypt
        end

        assert(
            type(crypto) == "table"
                and type(crypto.hash) == "function",
            "A SHA256Hex provider is required."
        )

        self.SHA256Hex = function(value)
            return crypto.hash(value, "sha256")
        end
    end

    -- Validate the hash function before producing login challenges.
    local digest = self.SHA256Hex("abc")

    assert(
        type(digest) == "string"
            and digest:lower()
                == "ba7816bf8f01cfea414140de5dae2223"
                    .. "b00361a396177a9cb410ff61f20015ad",
        "SHA-256 provider is incompatible."
    )

    return self
end

function SpotifyLogin:_random(count)
    local bytes = self.RandomBytes(count)

    assert(
        type(bytes) == "string" and #bytes == count,
        "RandomBytes must return exactly the requested number of raw bytes."
    )

    return bytes
end

function SpotifyLogin:Begin()
    assert(not self._destroyed, "Login object was destroyed.")
    assert(not self._busy, "A token exchange is already running.")

    local verifier = base64URL(self:_random(32))
    local state = base64URL(self:_random(32))

    local challenge = base64URL(
        hexToBytes(self.SHA256Hex(verifier))
    )

    self._pending = {
        verifier = verifier,
        state = state,
        created = os.clock(),
    }

    return "https://accounts.spotify.com/authorize?"
        .. encodeForm({
            response_type = "code",
            client_id = self.ClientId,
            redirect_uri = REDIRECT_URI,
            scope = self.Scopes,
            state = state,
            code_challenge_method = "S256",
            code_challenge = challenge,
        })
end

function SpotifyLogin:Complete(callbackURL)
    if self._destroyed then
        return false, "Login object was destroyed."
    end

    if self._busy then
        return false, "A token exchange is already running."
    end

    local pending = self._pending

    if not pending then
        return false, "Click Create Login Link first."
    end

    if os.clock() - pending.created > 600 then
        self._pending = nil
        return false, "Login expired. Create a new login link."
    end

    local parsed, parameters = pcall(
        parseCallback,
        trim(callbackURL)
    )

    if not parsed then
        return false, tostring(parameters)
    end

    if parameters.state ~= pending.state then
        return false, "Login state mismatch. Use this window's latest login link."
    end

    if parameters.error then
        self._pending = nil
        return false, "Spotify authorization: " .. parameters.error
    end

    if not parameters.code or parameters.code == "" then
        return false, "The callback URL contains no authorization code."
    end

    -- Each authorization attempt is consumed once.
    self._pending = nil
    self._busy = true

    local sent, response = pcall(self.Request, {
        Url = "https://accounts.spotify.com/api/token",
        Method = "POST",

        Headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
            Accept = "application/json",
        },

        Body = encodeForm({
            grant_type = "authorization_code",
            client_id = self.ClientId,
            redirect_uri = REDIRECT_URI,
            code = parameters.code,
            code_verifier = pending.verifier,
        }),
    })

    self._busy = false

    if self._destroyed then
        return false, "Login was cancelled."
    end

    if not sent or type(response) ~= "table" then
        return false, "Token request failed. Create a new login link and retry."
    end

    local decoded, data = pcall(function()
        return HttpService:JSONDecode(response.Body or "")
    end)

    if not decoded or type(data) ~= "table" then
        return false, "Spotify returned an invalid token response."
    end

    local status = tonumber(response.StatusCode or response.Status)

    if status ~= 200 or type(data.access_token) ~= "string" then
        return false, tostring(
            data.error_description
                or data.error
                or ("Token exchange failed: HTTP " .. tostring(status))
        )
    end

    return true, data
end

function SpotifyLogin:CreateWindow(library, onAuthenticated)
    assert(not self._destroyed, "Login object was destroyed.")
    assert(library and library.scgo, "Library ScreenGui is missing.")
    assert(type(onAuthenticated) == "function", "Missing login callback.")

    if self.Frame then
        self.Frame.Visible = true
        return self.Frame
    end

    local function create(class, properties)
        return library:Create(class, properties)
    end

    local frame = create("Frame", {
        Name = "SpotifyLogin",
        Size = UDim2.fromOffset(550, 300),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = library.MainColor,
        ZIndex = 30,
        Parent = library.scgo,
    })

    create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = library.SecondaryColor,
        Thickness = 1,
        Parent = frame,
    })

    local function label(value, y, height)
        return create("TextLabel", {
            Position = UDim2.fromOffset(12, y),
            Size = UDim2.new(1, -24, 0, height),
            BackgroundTransparency = 1,
            Font = library.Font,
            TextSize = 13,
            TextColor3 = library.FontColor,
            Text = value,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 31,
            Parent = frame,
        })
    end

    local function box(placeholder, y)
        return create("TextBox", {
            Position = UDim2.fromOffset(12, y),
            Size = UDim2.new(1, -24, 0, 28),
            BackgroundColor3 = library.SecondaryColor,
            Font = library.Font,
            TextSize = 13,
            TextColor3 = library.FontColor,
            Text = "",
            PlaceholderText = placeholder,
            ClearTextOnFocus = false,
            MultiLine = false,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 31,
            Parent = frame,
        })
    end

    local function button(value, x, y, width)
        return create("TextButton", {
            Position = UDim2.fromOffset(x, y),
            Size = UDim2.fromOffset(width, 27),
            BackgroundColor3 = library.SecondaryColor,
            Font = library.Font,
            TextSize = 13,
            TextColor3 = library.FontColor,
            Text = value,
            ZIndex = 31,
            Parent = frame,
        })
    end

    label("Connect Spotify", 10, 20)

    label(
        "1. Create and open a login link in your browser.\n"
            .. "2. Sign in on Spotify and approve access.\n"
            .. "3. Copy the complete callback URL, even if the page fails to load.",
        38,
        57
    )

    local beginButton = button("Create Login Link", 12, 101, 170)
    local hideButton = button("Hide", 446, 101, 92)

    local loginURL = box("Your Spotify login link appears here", 140)
    loginURL.TextEditable = false

    local callbackBox = box(
        "Paste http://127.0.0.1:8888/callback?code=...&state=...",
        179
    )

    local completeButton = button("Complete Login", 12, 218, 170)
    local status = label("Ready.", 258, 33)

    local uiBusy = false

    beginButton.Activated:Connect(function()
        if uiBusy then
            return
        end

        local ok, result = pcall(function()
            return self:Begin()
        end)

        if not ok then
            status.Text = "Could not create login: " .. tostring(result)
            return
        end

        loginURL.Text = result
        callbackBox.Text = ""

        local copied = false

        if type(setclipboard) == "function" then
            copied = pcall(setclipboard, result)
        end

        status.Text = copied
            and "Login link copied. Paste it into your browser."
            or "Copy the login link above and open it in your browser."
    end)

    hideButton.Activated:Connect(function()
        frame.Visible = false
    end)

    completeButton.Activated:Connect(function()
        if uiBusy then
            return
        end

        uiBusy = true
        completeButton.Text = "Connecting..."
        status.Text = "Exchanging the authorization code..."

        local callbackURL = callbackBox.Text
        callbackBox.Text = ""

        task.spawn(function()
            local ran, ok, result = pcall(function()
                return self:Complete(callbackURL)
            end)

            if self._destroyed or not frame.Parent then
                return
            end

            uiBusy = false
            completeButton.Text = "Complete Login"

            if not ran or not ok then
                status.Text = ran
                    and tostring(result)
                    or "Login failed. Create a new login link."

                return
            end

            -- Pass the token response directly to the player.
            -- No tokens are written to disk or printed.
            local applied = pcall(onAuthenticated, result)

            loginURL.Text = ""

            status.Text = applied
                and "Authorized. Check the music player's connection status."
                or "Authorized, but the player connection callback failed."
        end)
    end)

    frame.Destroying:Connect(function()
        if self.Frame == frame then
            self.Frame = nil
        end
    end)

    self.Frame = frame
    return frame
end

function SpotifyLogin:Destroy()
    if self._destroyed then
        return
    end

    self._destroyed = true
    self._pending = nil

    if self.Frame then
        self.Frame:Destroy()
        self.Frame = nil
    end
end

return SpotifyLogin
