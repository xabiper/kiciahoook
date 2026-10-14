-- UE core + Neko skin · skin button opens UE skin changer
local UE_URL   = "https://raw.githubusercontent.com/xabiper/kiciahoook/refs/heads/main/UeCrack%20(1).txt"
local NEKO_URL = "https://raw.githubusercontent.com/xabiper/kiciahoook/refs/heads/main/neko"

local function grab(url)
	local ok, src = pcall(game.HttpGet, game, url)
	assert(ok and src and #src > 100, "fetch failed: " .. tostring(url))
	return src
end
local function run(src, name)
	local fn, err = loadstring(src)
	assert(fn, (name or "?") .. " compile: " .. tostring(err))
	local ok, res = pcall(fn)
	if not ok then warn(name, res) end
end

local env = getgenv and getgenv() or _G

print("[1/4] UE…")
run(grab(UE_URL), "UE")
task.wait(1.2)

local Lib = env.Library
local Toggles = env.Toggles or {}
local Options = env.Options or {}
local SM = Lib and Lib.SaveManager

local function hideUE()
	pcall(function()
		if type(Lib) == "table" and typeof(Lib.ScreenGui) == "Instance" then
			Lib.ScreenGui.Enabled = false
		end
	end)
	local function scan(parent)
		if not parent then return end
		for _, c in ipairs(parent:GetChildren()) do
			local n = (c.Name or ""):lower()
			if n:find("unnamed") or n:find("linoria") or n:find("obels") or n:find("enhancement") then
				pcall(function() if c:IsA("ScreenGui") then c.Enabled = false end end)
			end
		end
	end
	scan(game:GetService("CoreGui"))
	pcall(function() scan(gethui and gethui()) end)
end
hideUE()

local function showUE()
	pcall(function()
		if type(Lib) == "table" and typeof(Lib.ScreenGui) == "Instance" then
			Lib.ScreenGui.Enabled = true
		end
	end)
	local function scan(parent)
		if not parent then return end
		for _, c in ipairs(parent:GetChildren()) do
			local n = (c.Name or ""):lower()
			if n:find("unnamed") or n:find("linoria") or n:find("obels") or n:find("enhancement") then
				pcall(function() if c:IsA("ScreenGui") then c.Enabled = true end end)
			end
		end
	end
	scan(game:GetService("CoreGui"))
	pcall(function() scan(gethui and gethui()) end)
end

env.UE_OpenSkinChanger = function()
	showUE()
	print("[skin] UE menu open — use Skin / Cosmetics tab")
end
env.UE_HideMenu = hideUE

env.UE_ImportClipboard = function()
	if not SM then return warn("no SaveManager") end
	local clip = type(getclipboard) == "function" and getclipboard() or nil
	if type(clip) ~= "string" or #clip < 2 then return warn("clipboard empty") end
	if type(SM.InstallFromJson) == "function" then print(SM:InstallFromJson(clip)) end
end
env.UE_ExportClipboard = function()
	if SM and type(SM.ExportToJson) == "function" then
		local j = SM:ExportToJson()
		if type(setclipboard) == "function" then setclipboard(j) end
		print("[export] ok")
		return j
	end
	local dump = { toggles = {}, options = {} }
	for k, t in pairs(Toggles) do if type(t) == "table" and t.Value ~= nil then dump.toggles[k] = t.Value end end
	for k, o in pairs(Options) do if type(o) == "table" and o.Value ~= nil then dump.options[k] = o.Value end end
	local j = game:GetService("HttpService"):JSONEncode(dump)
	if type(setclipboard) == "function" then setclipboard(j) end
	print("[export] fallback")
	return j
end

print("[3/4] Neko…")
do
	local src = grab(NEKO_URL)
	src = src:gsub("local Flags = {}", "local Flags = {}\nif getgenv then getgenv().Flags = Flags end", 1)
	run(src, "Neko")
end
task.wait(0.5)

print("[4/4] bridge…")
task.spawn(function()
	local last = {}
	while true do
		local F = env.Flags
		if type(F) == "table" then
			for id, v in pairs(F) do
				if last[id] ~= v then
					last[id] = v
					local t, o = Toggles[id], Options[id]
					if type(t) == "table" then
						if type(t.SetValue) == "function" then pcall(t.SetValue, t, v == true)
						elseif t.Value ~= nil then t.Value = (v == true) end
					elseif type(o) == "table" then
						if type(o.SetValue) == "function" then pcall(o.SetValue, o, v)
						elseif o.Value ~= nil then o.Value = v end
					end
				end
			end
		end
		task.wait(0.12)
	end
end)

do
	local parent = (gethui and gethui()) or game:GetService("CoreGui")
	local old = parent:FindFirstChild("NekoUEBridgeHUD")
	if old then old:Destroy() end
	local gui = Instance.new("ScreenGui")
	gui.Name = "NekoUEBridgeHUD"
	gui.ResetOnSpawn = false
	gui.Parent = parent

	local function mk(text, y, color, fn)
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(148, 32)
		b.Position = UDim2.new(1, -160, 0, y)
		b.BackgroundColor3 = color
		b.BorderSizePixel = 0
		b.Text = text
		b.Font = Enum.Font.GothamBold
		b.TextSize = 12
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Parent = gui
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
		b.MouseButton1Click:Connect(fn)
	end

	mk("Skin Changer", 60, Color3.fromRGB(236, 72, 153), function() env.UE_OpenSkinChanger() end)
	mk("Hide UE Menu", 98, Color3.fromRGB(60, 60, 70), function() hideUE() end)
	mk("Import Config", 136, Color3.fromRGB(59, 130, 246), function() env.UE_ImportClipboard() end)
	mk("Export Config", 174, Color3.fromRGB(16, 185, 129), function() env.UE_ExportClipboard() end)
end

print("[combined] ready · RightShift = Neko · Skin Changer = top-right pink")
