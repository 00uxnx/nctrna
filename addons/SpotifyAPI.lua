local HttpService = game:GetService("HttpService")

local Spotify = {}
Spotify.__index = Spotify

local API_BASE = "https://api.spotify.com/v1"

local function resolveRequest()
	if type(request) == "function" then
		return request
	end

	if type(http_request) == "function" then
		return http_request
	end

	if type(syn) == "table" and type(syn.request) == "function" then
		return syn.request
	end

	if type(http) == "table" and type(http.request) == "function" then
		return http.request
	end

	return nil
end

local function cleanToken(value)
	local token = tostring(value or "")
	token = token:match("^%s*(.-)%s*$")
	token = token:gsub("^[Bb][Ee][Aa][Rr][Ee][Rr]%s+", "")
	return token
end

local function getHeader(headers, name)
	for key, value in pairs(headers or {}) do
		if tostring(key):lower() == name:lower() then
			return value
		end
	end

	return nil
end

function Spotify.new(options)
	options = options or {}

	local self = setmetatable({}, Spotify)

	self.Request = options.Request or resolveRequest()

	assert(
		type(self.Request) == "function",
		"Spotify: no compatible HTTP request function found."
	)

	self.Token = ""
	self.DeviceId = nil
	self.Connected = false
	self.LastState = nil

	self._destroyed = false
	self._pollVersion = 0
	self._blockedUntil = 0

	return self
end

function Spotify:SetToken(token)
	assert(not self._destroyed, "Spotify client was destroyed.")

	self:StopPolling()

	self.Token = cleanToken(token)
	self.Connected = false
	self.LastState = nil
	self._blockedUntil = 0

	return self
end

function Spotify:SetDevice(deviceId)
	assert(not self._destroyed, "Spotify client was destroyed.")

	if deviceId == nil or deviceId == "" then
		self.DeviceId = nil
	else
		self.DeviceId = tostring(deviceId)
	end

	return self
end

function Spotify:_request(method, path, query, body)
	if self._destroyed then
		return false, "Spotify client was destroyed.", 0
	end

	if self.Token == "" then
		return false, "Enter a Spotify OAuth access token first.", 401
	end

	if os.clock() < self._blockedUntil then
		return false, "Spotify rate limit: wait before requesting again.", 429
	end

	local url = API_BASE .. path
	local parameters = {}

	for key, value in pairs(query or {}) do
		if value ~= nil then
			table.insert(
				parameters,
				HttpService:UrlEncode(tostring(key))
					.. "="
					.. HttpService:UrlEncode(tostring(value))
			)
		end
	end

	table.sort(parameters)

	if #parameters > 0 then
		url ..= "?" .. table.concat(parameters, "&")
	end

	local tokenUsed = self.Token

	local options = {
		Url = url,
		Method = method,

		Headers = {
			Authorization = "Bearer " .. tokenUsed,
			Accept = "application/json",
		},
	}

	if body ~= nil then
		local encoded, result = pcall(function()
			return HttpService:JSONEncode(body)
		end)

		if not encoded then
			return false, "Could not encode request body.", 0
		end

		options.Headers["Content-Type"] = "application/json"
		options.Body = result
	end

	local success, response = pcall(self.Request, options)

	-- Ignore responses from an earlier token/session.
	if self._destroyed or self.Token ~= tokenUsed then
		return false, "Spotify session changed during the request.", 0
	end

	if not success then
		-- Do not echo transport errors that might include headers.
		return false, "Spotify HTTP request failed.", 0
	end

	if type(response) ~= "table" then
		return false, "HTTP function returned an invalid response.", 0
	end

	local status = tonumber(response.StatusCode or response.Status) or 0
	local rawBody = response.Body
	local data = nil

	if type(rawBody) == "string" and rawBody ~= "" then
		local decoded, result = pcall(function()
			return HttpService:JSONDecode(rawBody)
		end)

		if decoded and type(result) == "table" then
			data = result
		end
	end

	if status >= 200 and status < 300 then
		if status ~= 204
			and method == "GET"
			and data == nil
		then
			return false, "Spotify returned an invalid JSON response.", status
		end

		return true, data, status
	end

	local message

	if status == 401 then
		self.Connected = false
		message = "Spotify token expired or is invalid. Authorize again."

	elseif status == 403 then
		message =
			"Spotify denied this action. Check token scopes, account access, and Premium."

	elseif status == 404 then
		message =
			"Spotify resource/device not found. Open Spotify and start a song."

	elseif status == 429 then
		local retryAfter = tonumber(
			getHeader(response.Headers, "Retry-After")
		) or 5

		retryAfter = math.max(1, retryAfter)
		self._blockedUntil = os.clock() + retryAfter

		message = string.format(
			"Spotify rate limit. Retry in %d seconds.",
			math.ceil(retryAfter)
		)

	elseif status == 0 then
		message = "HTTP response did not include a valid status code."

	else
		message = "Spotify request failed: HTTP " .. tostring(status)
	end

	-- Prefer Spotify's detailed message for other API errors.
	if status ~= 401
		and status ~= 403
		and status ~= 404
		and status ~= 429
		and data
	then
		local apiError = data.error

		if type(apiError) == "table"
			and type(apiError.message) == "string"
		then
			message = apiError.message
		elseif type(apiError) == "string" then
			message = apiError
		end
	end

	return false, message, status
end

function Spotify:GetPlayback()
	local ok, data, status = self:_request("GET", "/me/player")

	if not ok then
		return false, data, status
	end

	self.Connected = true

	if status == 204 or not data then
		self.LastState = nil
		return true, nil, status
	end

	self.LastState = data

	return true, data, status
end

function Spotify:Connect(token)
	self:SetToken(token)

	if self.Token == "" then
		return false, "Enter a Spotify OAuth access token.", 401
	end

	-- Verifies access to playback information.
	-- No active playback can still be a successful connection.
	return self:GetPlayback()
end

function Spotify:GetDevices()
	local ok, data, status = self:_request(
		"GET",
		"/me/player/devices"
	)

	if not ok then
		return false, data, status
	end

	return true, data and data.devices or {}, status
end

function Spotify:_command(method, action, extraQuery, body)
	local query = {}

	for key, value in pairs(extraQuery or {}) do
		query[key] = value
	end

	if self.DeviceId then
		query.device_id = self.DeviceId
	end

	return self:_request(
		method,
		"/me/player/" .. action,
		query,
		body
	)
end

function Spotify:Play()
	return self:_command("PUT", "play")
end

function Spotify:Pause()
	return self:_command("PUT", "pause")
end

function Spotify:Next()
	return self:_command("POST", "next")
end

function Spotify:Previous()
	return self:_command("POST", "previous")
end

function Spotify:Seek(positionMs)
	local value = tonumber(positionMs)

	if not value
		or value ~= value
		or value == math.huge
		or value == -math.huge
	then
		return false, "Seek position must be a finite number.", 0
	end

	return self:_command("PUT", "seek", {
		position_ms = math.max(0, math.floor(value)),
	})
end

function Spotify:TogglePlayback()
	-- Read the current state rather than trusting old UI state.
	local ok, state, status = self:GetPlayback()

	if not ok then
		return false, state, status
	end

	if state and state.is_playing then
		return self:Pause()
	end

	return self:Play()
end

function Spotify:StartPolling(onUpdate, onError, interval)
	assert(
		type(onUpdate) == "function",
		"Spotify:StartPolling requires an update callback."
	)

	assert(not self._destroyed, "Spotify client was destroyed.")

	self:StopPolling()

	local seconds = tonumber(interval) or 5

	if seconds ~= seconds or seconds == math.huge then
		seconds = 5
	end

	seconds = math.max(2, seconds)

	local version = self._pollVersion

	task.spawn(function()
		while not self._destroyed
			and version == self._pollVersion
		do
			local ok, stateOrError, status = self:GetPlayback()

			if self._destroyed
				or version ~= self._pollVersion
			then
				break
			end

			if ok then
				local callbackOk = pcall(onUpdate, stateOrError)

				if not callbackOk then
					warn("[Spotify] Playback update callback failed.")
				end
			else
				if type(onError) == "function" then
					local callbackOk = pcall(
						onError,
						stateOrError,
						status
					)

					if not callbackOk then
						warn("[Spotify] Error callback failed.")
					end
				end

				if status == 401 then
					break
				end
			end

			task.wait(
				math.max(
					seconds,
					self._blockedUntil - os.clock()
				)
			)
		end
	end)

	return self
end

function Spotify:StopPolling()
	self._pollVersion += 1
	return self
end

function Spotify:Disconnect()
	self:StopPolling()

	self.Token = ""
	self.DeviceId = nil
	self.Connected = false
	self.LastState = nil
	self._blockedUntil = 0
end

function Spotify:Destroy()
	self:Disconnect()
	self._destroyed = true
end

return Spotify
