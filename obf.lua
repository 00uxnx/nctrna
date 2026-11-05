local expected = "nocturne-productions_adminlicensekey!lolcat_hitz"
local supplied = _G.Key

warn("[Nocturne.bz] DIRECT KEY TEST v3")
warn("[Nocturne.bz] Key type:", type(supplied))
warn("[Nocturne.bz] Already loaded:", _G.LoadedNctrna == true)

if type(supplied) ~= "string" then
    warn("[Nocturne.bz] FAIL: _G.Key is not a string.")
    return
end

local normalized = supplied:match("^%s*(.-)%s*$")

warn("[Nocturne.bz] Supplied length:", #supplied)
warn("[Nocturne.bz] Trimmed length:", #normalized)
warn("[Nocturne.bz] Expected length:", #expected)

if normalized == expected then
    warn("[Nocturne.bz] PASS: the supplied key matches exactly.")
    return
end

for index = 1, math.max(#normalized, #expected) do
    local actualByte = string.byte(normalized, index)
    local expectedByte = string.byte(expected, index)

    if actualByte ~= expectedByte then
        warn(
            "[Nocturne.bz] First mismatch:",
            "position", index,
            "received byte", tostring(actualByte),
            "expected byte", tostring(expectedByte)
        )

        break
    end
end

warn("[Nocturne.bz] FAIL: the supplied value is different.")
