local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
if not player then
    error("Nimbus Glass UI must run from a LocalScript.")
end

local playerGui = player:WaitForChild("PlayerGui")


local previousGui = playerGui:FindFirstChild("NimbusGlassUI")
if previousGui then
    previousGui:Destroy()
end

local previousBlur = Lighting:FindFirstChild("NimbusGlassBlur")
if previousBlur then
    previousBlur:Destroy()
end

local COLORS = {
    Ink = Color3.fromRGB(238, 244, 249),
    InkDim = Color3.fromRGB(190, 202, 212),
    InkFaint = Color3.fromRGB(139, 154, 166),
    Panel = Color3.fromRGB(15, 23, 31),
    PanelTop = Color3.fromRGB(26, 38, 49),
    PanelBottom = Color3.fromRGB(11, 18, 24),
    White = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(148, 208, 255),
    AccentBright = Color3.fromRGB(232, 247, 255),
    Shadow = Color3.fromRGB(0, 0, 0),
}

local function create(className, properties)
    local object = Instance.new(className)
    local parent = properties.Parent

    for property, value in pairs(properties) do
        if property ~= "Parent" then
            object[property] = value
        end
    end

    object.Parent = parent
    return object
end

local function addCorner(object, radius)
    return create("UICorner", {
        Parent = object,
        CornerRadius = UDim.new(0, radius),
    })
end

local function addStroke(object, transparency, color)
    return create("UIStroke", {
        Parent = object,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = color or COLORS.White,
        Transparency = transparency,
        Thickness = 1,
    })
end

local function playTween(object, duration, goals, style, direction, delayTime)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(
            duration,
            style or Enum.EasingStyle.Quint,
            direction or Enum.EasingDirection.Out,
            0,
            false,
            delayTime or 0
        ),
        goals
    )
    tween:Play()
    return tween
end


local PAGES = {
    {
        id = "home",
        label = "Home",
        icon = "⌂",
        cards = {
            {
                title = "Interface",
                icon = "□",
                rows = {
                    { type = "toggle", key = "denseRows", label = "Dense Rows", value = true },
                    { type = "toggle", key = "tooltips", label = "Show Tooltips", value = false },
                    { type = "toggle", key = "railLabels", label = "Sidebar Labels", value = true },
                    { type = "toggle", key = "animations", label = "Animations", value = true },
                },
            },
            {
                title = "Performance",
                icon = "◴",
                rows = {
                    { type = "slider", key = "fps", label = "Frame Rate Cap", min = 30, max = 240, step = 6, value = 144, unit = "" },
                    { type = "toggle", key = "vsync", label = "V-Sync", value = true },
                    { type = "toggle", key = "latency", label = "Low Latency Mode", value = false },
                    { type = "toggle", key = "throttle", label = "Background Throttle", value = true },
                },
            },
            {
                title = "Appearance",
                icon = "◉",
                rows = {
                    { type = "toggle", key = "dark", label = "Dark Mode", value = true },
                    { type = "toggle", key = "glassy", label = "Glass Transparency", value = true },
                    { type = "slider", key = "blur", label = "Blur Strength", min = 0, max = 40, step = 1, value = 24, unit = "" },
                    { type = "slider", key = "scale", label = "UI Scale", min = 80, max = 120, step = 5, value = 100, unit = "%" },
                },
            },
            {
                title = "Audio",
                icon = "♪",
                rows = {
                    { type = "slider", key = "volume", label = "Master Volume", min = 0, max = 100, step = 5, value = 70, unit = "%" },
                    { type = "toggle", key = "music", label = "Music", value = false },
                    { type = "toggle", key = "uiSounds", label = "UI Sounds", value = true },
                    { type = "toggle", key = "duck", label = "Duck When Hidden", value = true },
                },
            },
        },
    },
    {
        id = "interface",
        label = "Interface",
        icon = "□",
        cards = {
            {
                title = "Layout",
                icon = "□",
                rows = {
                    { type = "toggle", key = "denseRows", label = "Dense Rows", value = true },
                    { type = "toggle", key = "railLabels", label = "Sidebar Labels", value = true },
                    { type = "toggle", key = "fullRows", label = "Full-Width Rows", value = false },
                    { type = "toggle", key = "dividers", label = "Row Dividers", value = true },
                },
            },
            {
                title = "Interaction",
                icon = "≡",
                rows = {
                    { type = "slider", key = "animationSpeed", label = "Animation Speed", min = 50, max = 200, step = 10, value = 100, unit = "%" },
                    { type = "toggle", key = "animations", label = "Animations", value = true },
                    { type = "toggle", key = "tooltips", label = "Show Tooltips", value = false },
                    { type = "toggle", key = "haptics", label = "Haptic Feedback", value = false },
                },
            },
        },
    },
    {
        id = "performance",
        label = "Performance",
        icon = "◴",
        cards = {
            {
                title = "Rendering",
                icon = "◴",
                rows = {
                    { type = "slider", key = "fps", label = "Frame Rate Cap", min = 30, max = 240, step = 6, value = 144, unit = "" },
                    { type = "toggle", key = "vsync", label = "V-Sync", value = true },
                    { type = "toggle", key = "latency", label = "Low Latency Mode", value = false },
                },
            },
            {
                title = "Resources",
                icon = "ϟ",
                rows = {
                    { type = "slider", key = "cache", label = "Cache Size", min = 1, max = 8, step = 1, value = 4, unit = " GB" },
                    { type = "toggle", key = "throttle", label = "Background Throttle", value = true },
                    { type = "toggle", key = "autoClean", label = "Auto-Cleanup", value = true },
                },
            },
        },
    },
    {
        id = "appearance",
        label = "Appearance",
        icon = "◉",
        cards = {
            {
                title = "Theme",
                icon = "◉",
                rows = {
                    { type = "toggle", key = "dark", label = "Dark Mode", value = true },
                    { type = "toggle", key = "glassy", label = "Glass Transparency", value = true },
                    { type = "toggle", key = "glow", label = "Accent Glow", value = true },
                    { type = "slider", key = "blur", label = "Blur Strength", min = 0, max = 40, step = 1, value = 24, unit = "" },
                },
            },
            {
                title = "Scale & Contrast",
                icon = "≡",
                rows = {
                    { type = "slider", key = "scale", label = "UI Scale", min = 80, max = 120, step = 5, value = 100, unit = "%" },
                    { type = "toggle", key = "contrast", label = "High Contrast", value = false },
                    { type = "toggle", key = "boldText", label = "Bold Text", value = false },
                },
            },
        },
    },
    {
        id = "audio",
        label = "Audio",
        icon = "♪",
        cards = {
            {
                title = "Levels",
                icon = "♪",
                rows = {
                    { type = "slider", key = "volume", label = "Master Volume", min = 0, max = 100, step = 5, value = 70, unit = "%" },
                    { type = "slider", key = "musicVolume", label = "Music", min = 0, max = 100, step = 5, value = 40, unit = "%" },
                    { type = "slider", key = "effectsVolume", label = "Effects", min = 0, max = 100, step = 5, value = 60, unit = "%" },
                },
            },
            {
                title = "Behavior",
                icon = "♫",
                rows = {
                    { type = "toggle", key = "uiSounds", label = "UI Sounds", value = true },
                    { type = "toggle", key = "music", label = "Music", value = false },
                    { type = "toggle", key = "duck", label = "Duck When Hidden", value = true },
                },
            },
        },
    },
    {
        id = "settings",
        label = "Settings",
        icon = "⚙",
        cards = {
            {
                title = "Profile",
                icon = "⚙",
                rows = {
                    { type = "toggle", key = "autoSave", label = "Auto-Save Layout", value = true },
                    { type = "toggle", key = "sync", label = "Sync Across Devices", value = false },
                    { type = "button", key = "reset", label = "Reset Defaults", button = "Reset" },
                },
            },
            {
                title = "Motion & Theme",
                icon = "◈",
                rows = {
                    { type = "theme", key = "theme", label = "Theme", value = "glass" },
                    { type = "toggle", key = "animations", label = "Animations", value = true },
                    { type = "toggle", key = "snow", label = "Falling Dots", value = true, compactOnly = true },
                    { type = "slider", key = "dissolveSpeed", label = "Dissolve Speed", min = 50, max = 200, step = 10, value = 100, unit = "%", compactOnly = true },
                },
            },
            {
                title = "About This Kit",
                icon = "□",
                rows = {
                    { type = "button", key = "why", label = "What do the controls do?", button = "Explain" },
                    { type = "button", key = "copy", label = "Design notes", button = "Details" },
                },
            },
        },
    },
}

local state = {}
local defaults = {}
for _, pageData in ipairs(PAGES) do
    for _, cardData in ipairs(pageData.cards) do
        for _, rowData in ipairs(cardData.rows) do
            if rowData.type ~= "button" and defaults[rowData.key] == nil then
                defaults[rowData.key] = rowData.value
                state[rowData.key] = rowData.value
            end
        end
    end
end

local THEME_STYLES = {
    glass = {
        interfaceScale = 1,
        accent = COLORS.Accent,
        knobColor = COLORS.AccentBright,
        panelColor = COLORS.Panel,
        railColor = COLORS.White,
        cardColor = COLORS.White,
        edgeColor = COLORS.White,
        panelTransparency = 0.32,
        railTransparency = 0.965,
        cardTransparency = 0.93,
        cardHoverTransparency = 0.90,
        cardStrokeTransparency = 0.84,
        cardHoverStrokeTransparency = 0.76,
        userTransparency = 0.94,
        sessionTransparency = 0.35,
        pillTransparency = 0.90,
        backdropTransparency = 0.72,
        blurSize = 14,
    },
    compact = {
        interfaceScale = 0.86,
        accent = Color3.fromRGB(255, 126, 136),
        knobColor = Color3.fromRGB(255, 232, 234),
        panelColor = Color3.fromRGB(8, 7, 9),
        railColor = Color3.fromRGB(10, 7, 9),
        cardColor = Color3.fromRGB(27, 14, 17),
        edgeColor = Color3.fromRGB(255, 145, 154),
        panelTransparency = 0.08,
        railTransparency = 0.22,
        cardTransparency = 0.22,
        cardHoverTransparency = 0.14,
        cardStrokeTransparency = 0.70,
        cardHoverStrokeTransparency = 0.58,
        userTransparency = 0.72,
        sessionTransparency = 0.16,
        pillTransparency = 0.76,
        backdropTransparency = 0.84,
        blurSize = 4,
    },
}

local function currentThemeStyle()
    return THEME_STYLES[state.theme] or THEME_STYLES.glass
end

local function animationsEnabled()
    return state.animations ~= false
end

local function motionDuration(normalDuration)
    return animationsEnabled() and normalDuration or 0.01
end

local function motionDelay(normalDelay)
    return animationsEnabled() and normalDelay or 0
end

local function dissolveTimeScale()
    local speed = math.clamp(tonumber(state.dissolveSpeed) or 100, 50, 200)
    return 100 / speed
end

local applyTheme
local updateResponsiveScale
local refreshCurrentPage

local blur = create("BlurEffect", {
    Parent = Lighting,
    Name = "NimbusGlassBlur",
    Size = 0,
})
playTween(blur, 0.45, { Size = 14 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local screenGui = create("ScreenGui", {
    Parent = playerGui,
    Name = "NimbusGlassUI",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    DisplayOrder = 40,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local backdrop = create("Frame", {
    Parent = screenGui,
    Name = "BackdropTint",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(11, 20, 27),
    BackgroundTransparency = 0.72,
    BorderSizePixel = 0,
})
create("UIGradient", {
    Parent = backdrop,
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 74, 103)),
        ColorSequenceKeypoint.new(0.48, Color3.fromRGB(21, 43, 49)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 21, 18)),
    }),
})


local sessionChip = create("CanvasGroup", {
    Parent = screenGui,
    Name = "SessionChip",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -20, 0, 18),
    Size = UDim2.fromOffset(390, 36),
    BackgroundColor3 = COLORS.Panel,
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0,
    GroupTransparency = 0,
})
local sessionCorner = addCorner(sessionChip, 10)
local sessionStroke = addStroke(sessionChip, 0.84)

local sessionAvatar = create("Frame", {
    Parent = sessionChip,
    Position = UDim2.fromOffset(10, 8),
    Size = UDim2.fromOffset(18, 18),
    BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.86,
    BorderSizePixel = 0,
})
addCorner(sessionAvatar, 4)
addStroke(sessionAvatar, 0.86)

create("TextLabel", {
    Parent = sessionAvatar,
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Text = string.sub(player.Name, 1, 1):upper(),
    TextColor3 = COLORS.InkDim,
    TextSize = 9,
})

create("TextLabel", {
    Parent = sessionChip,
    Position = UDim2.fromOffset(36, 0),
    Size = UDim2.new(0, 138, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = player.Name,
    TextColor3 = COLORS.InkDim,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local statusDivider = create("Frame", {
    Parent = sessionChip,
    Position = UDim2.fromOffset(180, 9),
    Size = UDim2.fromOffset(1, 18),
    BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.78,
    BorderSizePixel = 0,
})

local statusLabel = create("TextLabel", {
    Parent = sessionChip,
    Name = "LiveStatus",
    Position = UDim2.fromOffset(192, 0),
    Size = UDim2.new(1, -200, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Text = "FPS --  ·  Ping -- ms",
    TextColor3 = COLORS.InkDim,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
})

-- Lightweight live performance readout; remains visible when the main window is closed.
local frameCount = 0
local lastFpsUpdate = os.clock()
local latestFps = 0
RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = os.clock()
    if now - lastFpsUpdate >= 0.5 then
        latestFps = math.floor(frameCount / (now - lastFpsUpdate) + 0.5)
        frameCount = 0
        lastFpsUpdate = now

        local pingText = "--"
        pcall(function()
            local network = Stats.Network
            local serverStats = network:FindFirstChild("ServerStatsItem")
            local dataPing = serverStats and serverStats:FindFirstChild("Data Ping")
            if dataPing then
                pingText = tostring(math.floor(dataPing:GetValue() + 0.5))
            end
        end)
        statusLabel.Text = string.format("FPS %d  ·  Ping %s ms", latestFps, pingText)
    end
end)


local shell = create("CanvasGroup", {
    Parent = screenGui,
    Name = "WindowShell",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(1040, 650),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    GroupTransparency = 0,
})

local responsiveScale = create("UIScale", {
    Parent = shell,
    Scale = 1,
})

local shadow = create("Frame", {
    Parent = shell,
    Name = "Shadow",
    Position = UDim2.fromOffset(0, 8),
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLORS.Shadow,
    BackgroundTransparency = 0.56,
    BorderSizePixel = 0,
})
addCorner(shadow, 18)

local panel = create("Frame", {
    Parent = shell,
    Name = "GlassWindow",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLORS.Panel,
    BackgroundTransparency = 0.32,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})
local panelCorner = addCorner(panel, 18)
local panelStroke = addStroke(panel, 0.78)
local panelGradient = create("UIGradient", {
    Parent = panel,
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.PanelTop),
        ColorSequenceKeypoint.new(1, COLORS.PanelBottom),
    }),
})

create("Frame", {
    Parent = panel,
    Name = "TopHighlight",
    Position = UDim2.fromOffset(18, 0),
    Size = UDim2.new(1, -36, 0, 1),
    BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.76,
    BorderSizePixel = 0,
})

local titleBar = create("CanvasGroup", {
    Parent = panel,
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 68),
    BackgroundColor3 = COLORS.PanelTop,
    BackgroundTransparency = 0.16,
    BorderSizePixel = 0,
    Active = true,
})
-- Keep the header's upper corners aligned with the outer window corners.
addCorner(titleBar, 18)
create("Frame", {
    Parent = titleBar,
    Name = "HeaderLowerCornerFill",
    Position = UDim2.new(0, 0, 1, -18),
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundColor3 = COLORS.PanelTop,
    BackgroundTransparency = 0.16,
    BorderSizePixel = 0,
    ZIndex = 1,
})

create("TextLabel", {
    Parent = titleBar,
    Position = UDim2.fromOffset(24, 14),
    Size = UDim2.fromOffset(300, 24),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "Nimbus",
    TextColor3 = COLORS.Ink,
    TextSize = 19,
    TextXAlignment = Enum.TextXAlignment.Left,
})

create("TextLabel", {
    Parent = titleBar,
    Position = UDim2.fromOffset(24, 39),
    Size = UDim2.fromOffset(360, 16),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "Glass control center · local demo kit",
    TextColor3 = COLORS.InkFaint,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
})

create("Frame", {
    Parent = panel,
    Position = UDim2.fromOffset(0, 67),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.92,
    BorderSizePixel = 0,
})

local function makeWindowButton(text, offset)
    local button = create("TextButton", {
        Parent = titleBar,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, offset, 0, 19),
        Size = UDim2.fromOffset(34, 28),
        BackgroundColor3 = COLORS.White,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextColor3 = COLORS.InkDim,
        TextSize = 16,
    })
    addCorner(button, 8)
    local buttonStroke = addStroke(button, 1)

    button.MouseEnter:Connect(function()
        playTween(button, 0.16, {
            BackgroundTransparency = 0.90,
            TextColor3 = COLORS.Ink,
        })
        playTween(buttonStroke, 0.16, { Transparency = 0.86 })
    end)

    button.MouseLeave:Connect(function()
        playTween(button, 0.16, {
            BackgroundTransparency = 1,
            TextColor3 = COLORS.InkDim,
        })
        playTween(buttonStroke, 0.16, { Transparency = 1 })
    end)

    return button
end

local minimizeButton = makeWindowButton("—", -58)
local closeButton = makeWindowButton("×", -18)

local body = create("Frame", {
    Parent = panel,
    Name = "Body",
    Position = UDim2.fromOffset(0, 68),
    Size = UDim2.new(1, 0, 1, -68),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
})

local rail = create("CanvasGroup", {
    Parent = body,
    Name = "Rail",
    Size = UDim2.new(0, 220, 1, 0),
    BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.965,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})

create("Frame", {
    Parent = rail,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    Size = UDim2.new(0, 1, 1, 0),
    BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.92,
    BorderSizePixel = 0,
})

local navHolder = create("Frame", {
    Parent = rail,
    Position = UDim2.fromOffset(14, 10),
    Size = UDim2.new(1, -28, 0, 264),
    BackgroundTransparency = 1,
})

local navPill = create("Frame", {
    Parent = navHolder,
    Name = "ActivePill",
    Position = UDim2.fromOffset(0, 0),
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.90,
    BorderSizePixel = 0,
})
local navPillCorner = addCorner(navPill, 10)
local navPillStroke = addStroke(navPill, 0.84)


local userCard = create("TextButton", {
    Parent = rail,
    Name = "UserCard",
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 14, 1, -14),
    Size = UDim2.new(1, -28, 0, 54),
    BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.94,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "",
    ClipsDescendants = true,
})
local userCardCorner = addCorner(userCard, 12)
local userStroke = addStroke(userCard, 0.90)

local userAvatar = create("Frame", {
    Parent = userCard,
    Position = UDim2.fromOffset(11, 12),
    Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.87,
    BorderSizePixel = 0,
})
addCorner(userAvatar, 15)
addStroke(userAvatar, 0.86)

create("TextLabel", {
    Parent = userAvatar,
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Text = "G",
    TextColor3 = COLORS.InkDim,
    TextSize = 11,
})

local userNameLabel = create("TextLabel", {
    Parent = userCard,
    Position = UDim2.fromOffset(51, 10),
    Size = UDim2.new(1, -78, 0, 18),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Text = player.Name,
    TextColor3 = COLORS.Ink,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local userSubLabel = create("TextLabel", {
    Parent = userCard,
    Position = UDim2.fromOffset(51, 28),
    Size = UDim2.new(1, -78, 0, 15),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "Roblox account",
    TextColor3 = COLORS.InkFaint,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local userChevron = create("TextLabel", {
    Parent = userCard,
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0),
    Size = UDim2.fromOffset(12, 20),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Text = ">",
    TextColor3 = COLORS.InkFaint,
    TextSize = 13,
})

userCard.MouseEnter:Connect(function()
    local style = currentThemeStyle()
    playTween(userCard, motionDuration(0.18), {
        BackgroundTransparency = math.max(0, style.userTransparency - 0.04),
    })
    playTween(userStroke, motionDuration(0.18), { Transparency = 0.82 })
end)
userCard.MouseLeave:Connect(function()
    local style = currentThemeStyle()
    playTween(userCard, motionDuration(0.18), {
        BackgroundTransparency = style.userTransparency,
    })
    playTween(userStroke, motionDuration(0.18), { Transparency = 0.90 })
end)


local mainScroll = create("ScrollingFrame", {
    Parent = body,
    Name = "Content",
    Position = UDim2.fromOffset(220, 0),
    Size = UDim2.new(1, -220, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    CanvasSize = UDim2.fromOffset(0, 0),
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = COLORS.White,
    ScrollBarImageTransparency = 0.78,
    ScrollingDirection = Enum.ScrollingDirection.Y,
})

local contentInner = create("Frame", {
    Parent = mainScroll,
    Name = "CardGrid",
    Position = UDim2.fromOffset(20, 18),
    Size = UDim2.new(1, -40, 0, 0),
    BackgroundTransparency = 1,
})

local grid = create("UIGridLayout", {
    Parent = contentInner,
    CellPadding = UDim2.fromOffset(16, 16),
    CellSize = UDim2.new(0.5, -8, 0, 234),
    FillDirection = Enum.FillDirection.Horizontal,
    FillDirectionMaxCells = 2,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Top,
})

local function updateCanvas()
    local height = grid.AbsoluteContentSize.Y
    contentInner.Size = UDim2.new(1, -40, 0, height)
    mainScroll.CanvasSize = UDim2.fromOffset(0, height + 36)
end

grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)


local toastGroup = create("CanvasGroup", {
    Parent = screenGui,
    Name = "Toast",
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -20),
    Size = UDim2.fromOffset(360, 42),
    BackgroundColor3 = COLORS.Panel,
    BackgroundTransparency = 0.28,
    BorderSizePixel = 0,
    GroupTransparency = 1,
    Visible = false,
})
addCorner(toastGroup, 12)
addStroke(toastGroup, 0.82)

local toastLabel = create("TextLabel", {
    Parent = toastGroup,
    Size = UDim2.new(1, -24, 1, 0),
    Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "",
    TextColor3 = COLORS.InkDim,
    TextSize = 11,
})

local toastSerial = 0
local function showToast(message)
    toastSerial += 1
    local serial = toastSerial
    toastLabel.Text = message
    toastGroup.Visible = true
    toastGroup.GroupTransparency = 1
    toastGroup.Position = UDim2.new(0.5, 0, 1, -14)

    playTween(toastGroup, motionDuration(0.25), {
        GroupTransparency = 0,
        Position = UDim2.new(0.5, 0, 1, -26),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    task.delay(2.2, function()
        if serial ~= toastSerial then
            return
        end

        local fade = playTween(toastGroup, motionDuration(0.22), {
            GroupTransparency = 1,
            Position = UDim2.new(0.5, 0, 1, -18),
        }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

        fade.Completed:Once(function()
            if serial == toastSerial then
                toastGroup.Visible = false
            end
        end)
    end)
end

userCard.Activated:Connect(function()
    showToast("Local profile — no account and no network connection.")
end)


local pageConnections = {}
local function trackPageConnection(connection)
    table.insert(pageConnections, connection)
    return connection
end

local function clearPageConnections()
    for _, connection in ipairs(pageConnections) do
        connection:Disconnect()
    end
    table.clear(pageConnections)
end

local function formatValue(value)
    if math.abs(value - math.floor(value)) < 0.0001 then
        return tostring(math.floor(value))
    end
    return string.format("%.1f", value)
end

local function createToggle(parent, rowData)
    local toggle = create("TextButton", {
        Parent = parent,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(44, 24),
        BackgroundColor3 = COLORS.White,
        BackgroundTransparency = 0.86,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
    })
    addCorner(toggle, 12)
    toggle:SetAttribute("NimbusToggleKey", rowData.key)
    local toggleStroke = addStroke(toggle, 0.86)

    local knob = create("Frame", {
        Parent = toggle,
        Name = "Knob",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.fromOffset(17, 17),
        BackgroundColor3 = Color3.fromRGB(236, 243, 249),
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
    })
    addCorner(knob, 9)
    addStroke(knob, 0.80)

    local function refresh(instant)
        local enabled = state[rowData.key] == true
        local style = currentThemeStyle()
        local targetPosition = enabled and UDim2.fromOffset(32, 12) or UDim2.fromOffset(12, 12)
        local targetColor = enabled and style.accent or COLORS.White
        local targetTransparency = enabled and 0.67 or 0.86
        local targetStroke = enabled and 0.55 or 0.86

        if instant then
            toggle.BackgroundColor3 = targetColor
            toggle.BackgroundTransparency = targetTransparency
            toggleStroke.Transparency = targetStroke
            knob.Position = targetPosition
            knob.BackgroundColor3 = enabled and style.knobColor or Color3.fromRGB(236, 243, 249)
        else
            playTween(toggle, motionDuration(0.22), {
                BackgroundColor3 = targetColor,
                BackgroundTransparency = targetTransparency,
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            playTween(toggleStroke, motionDuration(0.22), { Transparency = targetStroke })
            playTween(knob, motionDuration(0.24), {
                Position = targetPosition,
                BackgroundColor3 = enabled and style.knobColor or Color3.fromRGB(236, 243, 249),
            }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

            if animationsEnabled() then
                knob.Size = UDim2.fromOffset(19, 19)
                playTween(knob, 0.18, { Size = UDim2.fromOffset(17, 17) })
            end
        end
    end

    toggle.Activated:Connect(function()
        state[rowData.key] = not state[rowData.key]
        refresh(false)
        if (rowData.key == "snow" or rowData.key == "animations") and applyTheme then
            applyTheme(false)
        end
    end)

    refresh(true)
end

local function createSlider(parent, rowData)
    local wrap = create("Frame", {
        Parent = parent,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(178, 30),
        BackgroundTransparency = 1,
    })

    local track = create("Frame", {
        Parent = wrap,
        Position = UDim2.fromOffset(2, 13),
        Size = UDim2.fromOffset(120, 4),
        BackgroundColor3 = COLORS.White,
        BackgroundTransparency = 0.84,
        BorderSizePixel = 0,
    })
    addCorner(track, 2)

    local fill = create("Frame", {
        Parent = track,
        Name = "AccentFill",
        Size = UDim2.fromScale(0.5, 1),
        BackgroundColor3 = currentThemeStyle().accent,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
    })
    addCorner(fill, 2)

    local knob = create("Frame", {
        Parent = track,
        Name = "AccentKnob",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(15, 15),
        BackgroundColor3 = currentThemeStyle().knobColor,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    })
    addCorner(knob, 8)
    addStroke(knob, 0.58)

    local output = create("TextLabel", {
        Parent = wrap,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(48, 30),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = COLORS.InkDim,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
    })

    local hitArea = create("TextButton", {
        Parent = wrap,
        Position = UDim2.fromOffset(-4, 1),
        Size = UDim2.fromOffset(132, 28),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
    })

    local function refresh()
        local value = state[rowData.key]
        local alpha = math.clamp((value - rowData.min) / (rowData.max - rowData.min), 0, 1)
        fill.Size = UDim2.fromScale(alpha, 1)
        knob.Position = UDim2.fromScale(alpha, 0.5)
        output.Text = formatValue(value) .. (rowData.unit or "")
    end

    local function setFromScreenX(screenX)
        local width = math.max(track.AbsoluteSize.X, 1)
        local alpha = math.clamp((screenX - track.AbsolutePosition.X) / width, 0, 1)
        local rawValue = rowData.min + (rowData.max - rowData.min) * alpha
        local steps = math.floor(((rawValue - rowData.min) / rowData.step) + 0.5)
        state[rowData.key] = math.clamp(rowData.min + steps * rowData.step, rowData.min, rowData.max)
        refresh()
    end

    local dragging = false
    local dragInput = nil

    hitArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            setFromScreenX(input.Position.X)
            playTween(knob, motionDuration(0.12), { Size = UDim2.fromOffset(18, 18) })
        end
    end)

    trackPageConnection(UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromScreenX(input.Position.X)
        elseif input == dragInput then
            setFromScreenX(input.Position.X)
        end
    end))

    trackPageConnection(UserInputService.InputEnded:Connect(function(input)
        if not dragging then
            return
        end

        if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            dragInput = nil
            playTween(knob, motionDuration(0.14), { Size = UDim2.fromOffset(15, 15) })
        end
    end))

    refresh()
end

local function createThemeSelector(parent, rowData)
    local wrap = create("Frame", {
        Parent = parent,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(166, 30),
        BackgroundColor3 = COLORS.White,
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
    })
    addCorner(wrap, 9)
    addStroke(wrap, 0.84)

    local selection = create("Frame", {
        Parent = wrap,
        Name = "AccentSelection",
        Position = UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(79, 24),
        BackgroundColor3 = currentThemeStyle().accent,
        BackgroundTransparency = 0.70,
        BorderSizePixel = 0,
    })
    addCorner(selection, 7)
    local selectionStroke = addStroke(selection, 0.70, currentThemeStyle().accent)
    selectionStroke.Name = "AccentStroke"

    local buttons = {}
    local options = {
        { id = "glass", label = "Glass" },
        { id = "compact", label = "Compact" },
    }

    local function refresh(instant)
        local compact = state[rowData.key] == "compact"
        local targetPosition = compact and UDim2.fromOffset(84, 3) or UDim2.fromOffset(3, 3)

        if instant or not animationsEnabled() then
            selection.Position = targetPosition
        else
            playTween(
                selection,
                0.30,
                { Position = targetPosition },
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            )
        end

        for _, option in ipairs(buttons) do
            local selected = option.id == state[rowData.key]
            local color = selected and COLORS.Ink or COLORS.InkDim
            if instant or not animationsEnabled() then
                option.button.TextColor3 = color
            else
                playTween(option.button, 0.18, { TextColor3 = color })
            end
        end
    end

    for index, optionData in ipairs(options) do
        local optionButton = create("TextButton", {
            Parent = wrap,
            Position = UDim2.fromOffset((index - 1) * 81 + 3, 3),
            Size = UDim2.fromOffset(79, 24),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Font = Enum.Font.GothamMedium,
            Text = optionData.label,
            TextColor3 = COLORS.InkDim,
            TextSize = 10,
        })

        local option = {
            id = optionData.id,
            button = optionButton,
        }
        table.insert(buttons, option)

        optionButton.Activated:Connect(function()
            if state[rowData.key] == optionData.id then
                return
            end

            state[rowData.key] = optionData.id
            refresh(false)
            if applyTheme then
                applyTheme(true)
            end
            if refreshCurrentPage then
                refreshCurrentPage()
            end
            showToast(optionData.label .. " theme selected.")
        end)
    end

    refresh(true)
end

local currentPage = "home"
local currentCards = {}
local transitionSerial = 0
local renderPage
local transitionTo

local function createActionButton(parent, rowData)
    local button = create("TextButton", {
        Parent = parent,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(74, 30),
        BackgroundColor3 = COLORS.White,
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.GothamMedium,
        Text = rowData.button,
        TextColor3 = COLORS.InkDim,
        TextSize = 11,
    })
    addCorner(button, 8)
    local buttonStroke = addStroke(button, 0.84)

    button.MouseEnter:Connect(function()
        playTween(button, 0.16, {
            BackgroundTransparency = 0.88,
            TextColor3 = COLORS.Ink,
        })
        playTween(buttonStroke, 0.16, { Transparency = 0.76 })
    end)

    button.MouseLeave:Connect(function()
        playTween(button, 0.16, {
            BackgroundTransparency = 0.94,
            TextColor3 = COLORS.InkDim,
        })
        playTween(buttonStroke, 0.16, { Transparency = 0.84 })
    end)

    button.Activated:Connect(function()
        if rowData.key == "reset" then
            for key, value in pairs(defaults) do
                state[key] = value
            end
            if applyTheme then
                applyTheme(true)
            end
            showToast("Defaults restored locally.")
            transitionTo(currentPage, true)
        elseif rowData.key == "why" then
            showToast("Every control is decorative and only changes local UI state.")
        else
            showToast("One self-contained LocalScript; no data is sent or copied.")
        end
    end)
end

local function createRow(card, rowData, rowIndex, animateRows)
    local row = create("CanvasGroup", {
        Parent = card,
        Name = "Row_" .. rowData.key,
        Position = UDim2.fromOffset(14, 43 + (rowIndex - 1) * 44),
        Size = UDim2.new(1, -28, 0, 44),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        GroupTransparency = animateRows and 1 or 0,
    })

    if rowIndex > 1 then
        create("Frame", {
            Parent = row,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = COLORS.White,
            BackgroundTransparency = 0.93,
            BorderSizePixel = 0,
        })
    end

    local inner = create("Frame", {
        Parent = row,
        Name = "Inner",
        Position = animateRows and UDim2.fromOffset(-10, 0) or UDim2.fromOffset(0, 0),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    })

    create("TextLabel", {
        Parent = inner,
        Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(1, -202, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = rowData.label,
        TextColor3 = Color3.fromRGB(218, 230, 239),
        TextTransparency = 0.10,
        TextSize = 12,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    if rowData.type == "toggle" then
        createToggle(inner, rowData)
    elseif rowData.type == "slider" then
        createSlider(inner, rowData)
    elseif rowData.type == "theme" then
        createThemeSelector(inner, rowData)
    else
        createActionButton(inner, rowData)
    end

    return row, inner
end

local function createCard(cardData, cardIndex, animateCard)
    local style = currentThemeStyle()
    local card = create("CanvasGroup", {
        Parent = contentInner,
        Name = "Card_" .. cardData.title:gsub("%W", ""),
        LayoutOrder = cardIndex,
        BackgroundColor3 = style.cardColor,
        BackgroundTransparency = style.cardTransparency,
        BorderSizePixel = 0,
        GroupTransparency = animateCard and 1 or 0,
        Active = true,
    })
    local cardCorner = addCorner(card, 14)
    local cardStroke = addStroke(card, style.cardStrokeTransparency, style.edgeColor)
    create("UIGradient", {
        Parent = card,
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(188, 208, 220)),
        }),
    })

    local cardScale = create("UIScale", {
        Parent = card,
        Scale = animateCard and 0.965 or 1,
    })

    local icon = create("TextLabel", {
        Parent = card,
        Position = UDim2.fromOffset(16, 12),
        Size = UDim2.fromOffset(22, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = cardData.icon,
        TextColor3 = style.accent,
        TextTransparency = 0.10,
        TextSize = 16,
    })
    icon.Name = "Icon"

    create("TextLabel", {
        Parent = card,
        Position = UDim2.fromOffset(44, 10),
        Size = UDim2.new(1, -60, 0, 26),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = cardData.title,
        TextColor3 = COLORS.Ink,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local visibleRows = {}
    for _, rowData in ipairs(cardData.rows) do
        if not rowData.compactOnly or state.theme == "compact" then
            table.insert(visibleRows, rowData)
        end
    end

    local rows = {}
    for rowIndex, rowData in ipairs(visibleRows) do
        local row, inner = createRow(card, rowData, rowIndex, animateCard)
        table.insert(rows, { group = row, inner = inner })
    end

    card.MouseEnter:Connect(function()
        local activeStyle = currentThemeStyle()
        playTween(cardScale, motionDuration(0.28), { Scale = 1.012 })
        playTween(card, motionDuration(0.28), {
            BackgroundTransparency = activeStyle.cardHoverTransparency,
        })
        playTween(cardStroke, motionDuration(0.28), {
            Transparency = activeStyle.cardHoverStrokeTransparency,
        })
    end)

    card.MouseLeave:Connect(function()
        local activeStyle = currentThemeStyle()
        playTween(cardScale, motionDuration(0.28), { Scale = 1 })
        playTween(card, motionDuration(0.28), {
            BackgroundTransparency = activeStyle.cardTransparency,
        })
        playTween(cardStroke, motionDuration(0.28), {
            Transparency = activeStyle.cardStrokeTransparency,
        })
    end)

    return {
        group = card,
        scale = cardScale,
        stroke = cardStroke,
        corner = cardCorner,
        icon = icon,
        rows = rows,
    }
end

local function findPage(pageId)
    for _, pageData in ipairs(PAGES) do
        if pageData.id == pageId then
            return pageData
        end
    end
    return PAGES[1]
end

renderPage = function(pageId, animateCards)
    clearPageConnections()

    for _, child in ipairs(contentInner:GetChildren()) do
        if child ~= grid then
            child:Destroy()
        end
    end

    table.clear(currentCards)
    mainScroll.CanvasPosition = Vector2.zero

    local pageData = findPage(pageId)
    for cardIndex, cardData in ipairs(pageData.cards) do
        local cardInfo = createCard(cardData, cardIndex, animateCards)
        table.insert(currentCards, cardInfo)

        if animateCards then
            local cardDelay = motionDelay((cardIndex - 1) * 0.07)
            playTween(
                cardInfo.group,
                motionDuration(0.55),
                { GroupTransparency = 0 },
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out,
                cardDelay
            )
            playTween(
                cardInfo.scale,
                motionDuration(0.55),
                { Scale = 1 },
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out,
                cardDelay
            )

            for rowIndex, rowInfo in ipairs(cardInfo.rows) do
                local rowDelay = motionDelay(cardDelay + 0.08 + (rowIndex - 1) * 0.04)
                playTween(
                    rowInfo.group,
                    motionDuration(0.45),
                    { GroupTransparency = 0 },
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.Out,
                    rowDelay
                )
                playTween(
                    rowInfo.inner,
                    motionDuration(0.45),
                    { Position = UDim2.fromOffset(0, 0) },
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.Out,
                    rowDelay
                )
            end
        end
    end

    task.defer(updateCanvas)
end


local navEntries = {}
local switchPageFromNav

for index, pageData in ipairs(PAGES) do
    local button = create("TextButton", {
        Parent = navHolder,
        Name = "Nav_" .. pageData.id,
        Position = UDim2.fromOffset(0, (index - 1) * 44),
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = COLORS.White,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
    })
    addCorner(button, 10)

    local icon = create("TextLabel", {
        Parent = button,
        Position = UDim2.fromOffset(11, 0),
        Size = UDim2.fromOffset(24, 40),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = pageData.icon,
        TextColor3 = COLORS.InkDim,
        TextSize = 16,
    })

    local label = create("TextLabel", {
        Parent = button,
        Position = UDim2.fromOffset(43, 0),
        Size = UDim2.new(1, -52, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = pageData.label,
        TextColor3 = COLORS.InkDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local entry = {
        id = pageData.id,
        index = index,
        button = button,
        icon = icon,
        label = label,
    }
    table.insert(navEntries, entry)

    button.MouseEnter:Connect(function()
        if currentPage ~= pageData.id then
            playTween(button, 0.16, { BackgroundTransparency = 0.95 })
            playTween(icon, 0.16, { TextColor3 = COLORS.Ink })
            playTween(label, 0.16, { TextColor3 = COLORS.Ink })
        end
    end)

    button.MouseLeave:Connect(function()
        playTween(button, 0.16, { BackgroundTransparency = 1 })
        if currentPage ~= pageData.id then
            playTween(icon, 0.16, { TextColor3 = COLORS.InkDim })
            playTween(label, 0.16, { TextColor3 = COLORS.InkDim })
        end
    end)

    button.Activated:Connect(function()
        switchPageFromNav(pageData.id)
    end)
end

local function refreshNavigation(animatePill)
    local activeEntry = navEntries[1]

    for _, entry in ipairs(navEntries) do
        local active = entry.id == currentPage
        if active then
            activeEntry = entry
        end

        local color = active and COLORS.Ink or COLORS.InkDim
        if animatePill then
            playTween(entry.icon, motionDuration(0.22), { TextColor3 = color })
            playTween(entry.label, motionDuration(0.22), { TextColor3 = color })
        else
            entry.icon.TextColor3 = color
            entry.label.TextColor3 = color
        end
    end


    local targetPosition = activeEntry.button.Position
    local targetSize = activeEntry.button.Size
    if animatePill then
        playTween(
            navPill,
            motionDuration(0.48),
            { Position = targetPosition, Size = targetSize },
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out
        )
    else
        navPill.Position = targetPosition
        navPill.Size = targetSize
    end
end

local compactRailExpanded = false
local function setRailLayout(expanded, animateChange)
    local compact = state.theme == "compact"
    compactRailExpanded = compact and expanded or false

    local width
    local inset
    if compact then
        width = compactRailExpanded and 204 or 62
        inset = compactRailExpanded and 10 or 8
    else
        width = 220
        inset = 14
    end

    local labelsVisible = not compact or compactRailExpanded
    local duration = animateChange and animationsEnabled() and 0.56 or 0

    local function setOrTween(object, goals)
        if duration > 0 then
            playTween(
                object,
                duration,
                goals,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            )
        else
            for property, value in pairs(goals) do
                object[property] = value
            end
        end
    end

    local function setLabelVisibility(label)
        local targetTransparency = labelsVisible and 0 or 1
        if duration > 0 then
            playTween(
                label,
                labelsVisible and 0.24 or 0.14,
                { TextTransparency = targetTransparency },
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out,
                labelsVisible and 0.14 or 0
            )
        else
            label.TextTransparency = targetTransparency
        end
    end

    setOrTween(rail, { Size = UDim2.new(0, width, 1, 0) })
    setOrTween(mainScroll, {
        Position = UDim2.fromOffset(width, 0),
        Size = UDim2.new(1, -width, 1, 0),
    })
    setOrTween(navHolder, {
        Position = UDim2.fromOffset(inset, compact and 8 or 10),
        Size = UDim2.new(1, -(inset * 2), 0, 264),
    })
    setOrTween(userCard, {
        Position = UDim2.new(0, inset, 1, compact and -10 or -14),
        Size = UDim2.new(1, -(inset * 2), 0, 54),
    })
    setOrTween(userAvatar, {
        Position = compact and not compactRailExpanded
            and UDim2.new(0.5, -15, 0, 12)
            or UDim2.fromOffset(11, 12),
    })

    setLabelVisibility(userNameLabel)
    setLabelVisibility(userSubLabel)
    setLabelVisibility(userChevron)

    for _, entry in ipairs(navEntries) do
        setOrTween(entry.icon, {
            Position = compact and not compactRailExpanded
                and UDim2.new(0.5, -12, 0, 0)
                or UDim2.fromOffset(11, 0),
        })
        setLabelVisibility(entry.label)
    end

    refreshNavigation(false)
    task.defer(function()
        refreshNavigation(false)
        updateCanvas()
    end)
end

rail.MouseEnter:Connect(function()
    if state.theme == "compact" then
        setRailLayout(true, true)
    end
end)

rail.MouseLeave:Connect(function()
    if state.theme == "compact" then
        setRailLayout(false, true)
    end
end)

transitionTo = function(pageId, force)
    if pageId == currentPage and not force then
        return
    end

    currentPage = pageId
    transitionSerial += 1
    local serial = transitionSerial
    refreshNavigation(true)

    if not animationsEnabled() or #currentCards == 0 then
        renderPage(currentPage, animationsEnabled())
        return
    end

    for index, cardInfo in ipairs(currentCards) do
        local delayTime = (index - 1) * 0.025
        playTween(
            cardInfo.group,
            0.16,
            { GroupTransparency = 1 },
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.In,
            delayTime
        )
        playTween(
            cardInfo.scale,
            0.16,
            { Scale = 0.985 },
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.In,
            delayTime
        )
    end

    local waitTime = 0.16 + math.max(0, #currentCards - 1) * 0.025
    task.delay(waitTime, function()
        if serial == transitionSerial then
            renderPage(currentPage, true)
        end
    end)
end

switchPageFromNav = function(pageId)
    transitionTo(pageId, false)
end

refreshCurrentPage = function()
    transitionTo(currentPage, true)
end


local minimized = false
local closed = false
local visibilityTransitioning = false
local visibilitySerial = 0
local interfaceTargetScale = 1
local positionBeforeClose = shell.Position
local FULL_SIZE = UDim2.fromOffset(1040, 650)
local MIN_SIZE = UDim2.fromOffset(1040, 68)

minimizeButton.Activated:Connect(function()
    if closed or visibilityTransitioning then
        return
    end

    minimized = not minimized

    if not minimized then
        body.Visible = true
    end

    minimizeButton.Text = minimized and "□" or "—"
    local targetSize = minimized and MIN_SIZE or FULL_SIZE
    local resizeTween = playTween(
        shell,
        motionDuration(0.34),
        { Size = targetSize },
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    )

    if minimized then
        resizeTween.Completed:Once(function()
            if minimized then
                body.Visible = false
            end
        end)
    end
end)

local reopenGroup = create("CanvasGroup", {
    Parent = screenGui,
    Name = "Reopen",
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -22),
    Size = UDim2.fromOffset(190, 38),
    BackgroundColor3 = COLORS.Panel,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    GroupTransparency = 1,
    Visible = false,
})
local reopenCorner = addCorner(reopenGroup, 19)
local reopenStroke = addStroke(reopenGroup, 0.80)

local reopenButton = create("TextButton", {
    Parent = reopenGroup,
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamMedium,
    Text = "Reopen panel  ·  Right Shift",
    TextColor3 = COLORS.Ink,
    TextSize = 10,
})


local snowOverlay = create("Frame", {
    Parent = shell,
    Name = "CompactSnowField",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = false,
    ZIndex = 90,
})

local snowRandom = Random.new(4417)
for index = 1, 72 do
    local size = snowRandom:NextInteger(1, 4)
    local startX = snowRandom:NextNumber(0.01, 0.99)
    local startY = snowRandom:NextNumber(-0.25, 0.75)
    local drift = snowRandom:NextNumber(-0.07, 0.07)
    local duration = snowRandom:NextNumber(5.5, 11.5)

    local snowDot = create("Frame", {
        Parent = snowOverlay,
        Name = "SnowDot_" .. index,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(startX, startY),
        Size = UDim2.fromOffset(size, size),
        BackgroundColor3 = Color3.fromRGB(255, 126, 136),
        BackgroundTransparency = snowRandom:NextNumber(0.58, 0.88),
        BorderSizePixel = 0,
        ZIndex = 91,
    })
    addCorner(snowDot, size)

    TweenService:Create(
        snowDot,
        TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0),
        {
            Position = UDim2.fromScale(startX + drift, startY + 1.25),
        }
    ):Play()
end


local particleOverlay = create("Frame", {
    Parent = screenGui,
    Name = "CompactParticleField",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = shell.Position,
    Size = shell.Size,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = false,
    ZIndex = 100,
})

local particleScale = create("UIScale", {
    Parent = particleOverlay,
    Scale = responsiveScale.Scale,
})


local particles = {}
local particleRandom = Random.new(9173)
for index = 1, 280 do
    local size = particleRandom:NextInteger(2, 5)
    local x = particleRandom:NextNumber(0.01, 0.99)
    local y = particleRandom:NextNumber(0.01, 0.99)
    local basePosition = UDim2.fromScale(x, y)
    local openingPosition = UDim2.new(
        x,
        particleRandom:NextInteger(-12, 12),
        y,
        particleRandom:NextInteger(-58, -24)
    )
    local closingPosition = UDim2.new(
        x,
        particleRandom:NextInteger(-12, 12),
        y,
        particleRandom:NextInteger(24, 58)
    )
    local verticalProgress = y
    local jitter = particleRandom:NextNumber(0, 0.07)
    local isRose = particleRandom:NextNumber(0, 1) > 0.42

    local dot = create("Frame", {
        Parent = particleOverlay,
        Name = "DissolveParticle_" .. index,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = basePosition,
        Size = UDim2.fromOffset(size, size),
        BackgroundColor3 = isRose and Color3.fromRGB(255, 126, 136) or Color3.fromRGB(14, 8, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 102,
    })
    addCorner(dot, size)

    table.insert(particles, {
        object = dot,
        size = size,
        basePosition = basePosition,
        openingPosition = openingPosition,
        closingPosition = closingPosition,
        brightTransparency = isRose and particleRandom:NextNumber(0.02, 0.28) or particleRandom:NextNumber(0.10, 0.38),
        openingDelay = verticalProgress * 0.72 + jitter,
        closingDelay = verticalProgress * 0.72 + jitter,
    })
end

local function syncParticleOverlay()
    particleOverlay.Position = shell.Position
    particleOverlay.Size = shell.Size
    particleScale.Scale = responsiveScale.Scale
end

shell:GetPropertyChangedSignal("Position"):Connect(syncParticleOverlay)
shell:GetPropertyChangedSignal("Size"):Connect(syncParticleOverlay)
responsiveScale:GetPropertyChangedSignal("Scale"):Connect(syncParticleOverlay)

local activeVisibilityTweens = {}
local function cancelVisibilityTweens()
    for _, activeTween in ipairs(activeVisibilityTweens) do
        activeTween:Cancel()
    end
    table.clear(activeVisibilityTweens)
end

local function visibilityTween(object, duration, goals, style, direction, delayTime)
    local activeTween = playTween(object, duration, goals, style, direction, delayTime)
    table.insert(activeVisibilityTweens, activeTween)
    return activeTween
end

local function hideParticleField()
    particleOverlay.Visible = false
    for _, particle in ipairs(particles) do
        particle.object.BackgroundTransparency = 1
    end
end

local function showAmbientParticles()
    hideParticleField()
    snowOverlay.Visible = state.theme == "compact"
        and state.snow == true
        and animationsEnabled()
        and not closed
end

local function runDissolve(covering, serial, callback)
    local timeScale = dissolveTimeScale()
    syncParticleOverlay()
    particleOverlay.Visible = true

    for _, particle in ipairs(particles) do
        local dot = particle.object
        local delayTime = (covering and particle.closingDelay or particle.openingDelay) * timeScale
        dot.Position = covering and particle.basePosition or particle.openingPosition
        dot.Size = UDim2.fromOffset(1, 1)
        dot.BackgroundTransparency = 1

        task.delay(delayTime, function()
            if serial ~= visibilitySerial then
                return
            end

            visibilityTween(
                dot,
                0.16 * timeScale,
                {
                    Position = particle.basePosition,
                    Size = UDim2.fromOffset(particle.size + 1, particle.size + 1),
                    BackgroundTransparency = particle.brightTransparency,
                },
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            )

            task.delay(0.17 * timeScale, function()
                if serial ~= visibilitySerial then
                    return
                end
                visibilityTween(
                    dot,
                    0.25 * timeScale,
                    {
                        Position = covering and particle.closingPosition or particle.basePosition,
                        Size = UDim2.fromOffset(1, 1),
                        BackgroundTransparency = 1,
                    },
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.In
                )
            end)
        end)
    end

    task.delay(1.32 * timeScale, function()
        if serial ~= visibilitySerial then
            return
        end
        callback()
    end)
end

local function compactUiTargets()
    local targets = {
        { object = titleBar, progress = 0.05 },
        { object = rail, progress = 0.40 },
    }

    for index, cardInfo in ipairs(currentCards) do
        local row = math.floor((index - 1) / 2)
        local y = row == 0 and 0.34 or 0.72
        table.insert(targets, {
            object = cardInfo.group,
            progress = y,
        })
    end

    return targets
end

local function setCompactUiHidden(hidden)
    local style = currentThemeStyle()
    local groupTransparency = hidden and 1 or 0

    titleBar.GroupTransparency = groupTransparency
    rail.GroupTransparency = groupTransparency
    for _, cardInfo in ipairs(currentCards) do
        cardInfo.group.GroupTransparency = groupTransparency
    end

    panel.BackgroundTransparency = hidden and 1 or style.panelTransparency
    panelStroke.Transparency = hidden and 1 or 0.72
    shadow.BackgroundTransparency = hidden and 1 or 0.66
    mainScroll.ScrollBarImageTransparency = hidden and 1 or 0.78
end

local function animateCompactUi(covering)
    local style = currentThemeStyle()
    local timeScale = dissolveTimeScale()

    if not covering then
        setCompactUiHidden(true)
    end

    for _, target in ipairs(compactUiTargets()) do
        local delayTime = target.progress * 0.72 * timeScale
        visibilityTween(
            target.object,
            0.30 * timeScale,
            { GroupTransparency = covering and 1 or 0 },
            Enum.EasingStyle.Quad,
            covering and Enum.EasingDirection.In or Enum.EasingDirection.Out,
            delayTime
        )
    end

    visibilityTween(
        panel,
        1.10 * timeScale,
        { BackgroundTransparency = covering and 1 or style.panelTransparency },
        Enum.EasingStyle.Quad,
        covering and Enum.EasingDirection.In or Enum.EasingDirection.Out
    )
    visibilityTween(
        panelStroke,
        1.10 * timeScale,
        { Transparency = covering and 1 or 0.72 },
        Enum.EasingStyle.Quad,
        covering and Enum.EasingDirection.In or Enum.EasingDirection.Out
    )
    visibilityTween(
        shadow,
        0.96 * timeScale,
        { BackgroundTransparency = covering and 1 or 0.66 },
        Enum.EasingStyle.Quad,
        covering and Enum.EasingDirection.In or Enum.EasingDirection.Out
    )
    visibilityTween(
        mainScroll,
        0.70 * timeScale,
        { ScrollBarImageTransparency = covering and 1 or 0.78 },
        Enum.EasingStyle.Quad,
        covering and Enum.EasingDirection.In or Enum.EasingDirection.Out
    )
end

local function showReopenControl(serial, animated)
    if serial ~= visibilitySerial or not closed then
        return
    end

    reopenGroup.Visible = true
    if not animated then
        reopenGroup.GroupTransparency = 0
        reopenGroup.Position = UDim2.new(0.5, 0, 1, -24)
        return
    end

    reopenGroup.GroupTransparency = 1
    reopenGroup.Position = UDim2.new(0.5, 0, 1, -16)
    visibilityTween(reopenGroup, 0.26, {
        GroupTransparency = 0,
        Position = UDim2.new(0.5, 0, 1, -24),
    })
end

local function hideReopenControl(serial, animated)
    if not reopenGroup.Visible then
        return
    end

    if not animated then
        reopenGroup.Visible = false
        reopenGroup.GroupTransparency = 1
        return
    end

    visibilityTween(reopenGroup, 0.18, {
        GroupTransparency = 1,
        Position = UDim2.new(0.5, 0, 1, -18),
    }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

    task.delay(0.19, function()
        if serial == visibilitySerial and not closed then
            reopenGroup.Visible = false
        end
    end)
end

local function closePanel()
    if closed or visibilityTransitioning then
        return
    end

    local useAnimations = animationsEnabled()
    closed = true
    visibilityTransitioning = useAnimations
    visibilitySerial += 1
    local serial = visibilitySerial

    cancelVisibilityTweens()
    shell.Active = false
    snowOverlay.Visible = false

    if not useAnimations then
        shell.Visible = false
        shell.GroupTransparency = 1
        sessionChip.GroupTransparency = 0
        backdrop.BackgroundTransparency = 1
        blur.Size = 0
        hideParticleField()
        showReopenControl(serial, false)
        visibilityTransitioning = false
        return
    end

    visibilityTween(sessionChip, 0.22, { GroupTransparency = 0 })
    visibilityTween(backdrop, 0.30, { BackgroundTransparency = 1 })
    visibilityTween(blur, 0.30, { Size = 0 })

    if state.theme == "compact" then
        shell.GroupTransparency = 0
        shell.Position = positionBeforeClose
        animateCompactUi(true)
        runDissolve(true, serial, function()
            if not closed then
                return
            end
            shell.Visible = false
            shell.GroupTransparency = 1
            hideParticleField()
            showReopenControl(serial, true)
            visibilityTransitioning = false
        end)
    else
        hideParticleField()
        visibilityTween(shell, 0.32, {
            GroupTransparency = 1,
            Position = UDim2.new(
                positionBeforeClose.X.Scale,
                positionBeforeClose.X.Offset,
                positionBeforeClose.Y.Scale,
                positionBeforeClose.Y.Offset + 10
            ),
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        visibilityTween(
            responsiveScale,
            0.32,
            { Scale = interfaceTargetScale * 0.96 },
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.In
        )

        task.delay(0.33, function()
            if serial ~= visibilitySerial or not closed then
                return
            end
            shell.Visible = false
            responsiveScale.Scale = interfaceTargetScale
            showReopenControl(serial, true)
            visibilityTransitioning = false
        end)
    end
end

local function reopenPanel()
    if not closed or visibilityTransitioning then
        return
    end

    local useAnimations = animationsEnabled()
    closed = false
    visibilityTransitioning = useAnimations
    visibilitySerial += 1
    local serial = visibilitySerial
    local style = currentThemeStyle()

    cancelVisibilityTweens()
    hideReopenControl(serial, useAnimations)

    shell.Visible = true
    shell.Active = true
    shell.Position = positionBeforeClose
    responsiveScale.Scale = interfaceTargetScale

    if not useAnimations then
        shell.GroupTransparency = 0
        sessionChip.GroupTransparency = 0
        backdrop.BackgroundTransparency = style.backdropTransparency
        blur.Size = style.blurSize
        if state.theme == "compact" then
            showAmbientParticles()
        else
            hideParticleField()
        end
        visibilityTransitioning = false
        return
    end

    visibilityTween(sessionChip, 0.28, { GroupTransparency = 0 })
    visibilityTween(backdrop, 0.34, {
        BackgroundTransparency = style.backdropTransparency,
    })
    visibilityTween(blur, 0.40, { Size = style.blurSize })

    if state.theme == "compact" then
        shell.GroupTransparency = 0
        animateCompactUi(false)
        runDissolve(false, serial, function()
            if closed then
                return
            end
            setCompactUiHidden(false)
            showAmbientParticles()
            visibilityTransitioning = false
        end)
    else
        hideParticleField()
        shell.GroupTransparency = 1
        shell.Position = UDim2.new(
            positionBeforeClose.X.Scale,
            positionBeforeClose.X.Offset,
            positionBeforeClose.Y.Scale,
            positionBeforeClose.Y.Offset + 10
        )
        responsiveScale.Scale = interfaceTargetScale * 0.96

        visibilityTween(shell, 0.42, {
            GroupTransparency = 0,
            Position = positionBeforeClose,
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        visibilityTween(
            responsiveScale,
            0.44,
            { Scale = interfaceTargetScale },
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out
        )
        task.delay(0.46, function()
            if serial == visibilitySerial and not closed then
                visibilityTransitioning = false
            end
        end)
    end
end

closeButton.Activated:Connect(closePanel)
reopenButton.Activated:Connect(reopenPanel)


UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift
        and UserInputService:GetFocusedTextBox() == nil then
        if closed then
            reopenPanel()
        else
            closePanel()
        end
    end
end)

reopenButton.MouseEnter:Connect(function()
    playTween(reopenGroup, motionDuration(0.16), { BackgroundTransparency = 0.16 })
end)
reopenButton.MouseLeave:Connect(function()
    playTween(reopenGroup, motionDuration(0.16), { BackgroundTransparency = 0.25 })
end)


local draggingWindow = false
local dragInput = nil
local dragStart = Vector3.zero
local shellStart = shell.Position

titleBar.InputBegan:Connect(function(input)
    if closed or visibilityTransitioning then
        return
    end

    local localX = input.Position.X - titleBar.AbsolutePosition.X
    if localX > titleBar.AbsoluteSize.X - 104 then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = true
        dragStart = input.Position
        shellStart = shell.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingWindow = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingWindow and input == dragInput then
        local delta = input.Position - dragStart
        shell.Position = UDim2.new(
            shellStart.X.Scale,
            shellStart.X.Offset + delta.X,
            shellStart.Y.Scale,
            shellStart.Y.Offset + delta.Y
        )
        positionBeforeClose = shell.Position
    end
end)


local viewportConnection = nil
local cameraConnection = nil

updateResponsiveScale = function(animateChange)
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local viewport = camera.ViewportSize
    local fitX = (viewport.X - 28) / 1040
    local fitY = (viewport.Y - 28) / 650
    local viewportScale = math.clamp(math.min(fitX, fitY), 0.45, 1)
    interfaceTargetScale = math.max(0.42, viewportScale * currentThemeStyle().interfaceScale)

    if animateChange and animationsEnabled() and not closed then
        playTween(
            responsiveScale,
            0.38,
            { Scale = interfaceTargetScale },
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        )
    else
        responsiveScale.Scale = interfaceTargetScale
    end
end

applyTheme = function(animateChange)
    local style = currentThemeStyle()
    local shouldAnimate = animateChange and animationsEnabled()
    local duration = shouldAnimate and 0.34 or 0

    local function setProperties(object, goals)
        if shouldAnimate then
            playTween(
                object,
                duration,
                goals,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            )
        else
            for property, value in pairs(goals) do
                object[property] = value
            end
        end
    end

    setProperties(panel, {
        BackgroundColor3 = style.panelColor,
        BackgroundTransparency = style.panelTransparency,
    })
    setProperties(panelStroke, {
        Color = style.edgeColor,
        Transparency = state.theme == "compact" and 0.72 or 0.78,
    })
    setProperties(rail, {
        BackgroundColor3 = style.railColor,
        BackgroundTransparency = style.railTransparency,
    })
    setProperties(userCard, {
        BackgroundColor3 = style.cardColor,
        BackgroundTransparency = style.userTransparency,
    })
    setProperties(userStroke, { Color = style.edgeColor })
    setProperties(sessionChip, {
        BackgroundColor3 = style.panelColor,
        BackgroundTransparency = style.sessionTransparency,
    })
    setProperties(sessionStroke, { Color = style.edgeColor })
    setProperties(navPill, {
        BackgroundColor3 = style.accent,
        BackgroundTransparency = style.pillTransparency,
    })
    setProperties(navPillStroke, { Color = style.edgeColor })
    setProperties(mainScroll, { ScrollBarImageColor3 = style.accent })
    setProperties(shadow, {
        BackgroundTransparency = state.theme == "compact" and 0.66 or 0.56,
    })
    setProperties(reopenGroup, {
        BackgroundColor3 = style.panelColor,
        BackgroundTransparency = state.theme == "compact" and 0.14 or 0.25,
    })
    setProperties(reopenStroke, { Color = style.edgeColor })

    local compact = state.theme == "compact"
    setRailLayout(compactRailExpanded, shouldAnimate)
    panelCorner.CornerRadius = UDim.new(0, compact and 3 or 18)
    sessionCorner.CornerRadius = UDim.new(0, compact and 2 or 10)
    sessionChip.Size = compact and UDim2.fromOffset(360, 30) or UDim2.fromOffset(390, 36)
    statusLabel.TextSize = compact and 9 or 10
    statusDivider.Size = compact and UDim2.fromOffset(1, 14) or UDim2.fromOffset(1, 18)
    navPillCorner.CornerRadius = UDim.new(0, compact and 2 or 10)
    userCardCorner.CornerRadius = UDim.new(0, compact and 2 or 12)
    reopenCorner.CornerRadius = UDim.new(0, compact and 3 or 19)
    grid.CellPadding = compact and UDim2.fromOffset(5, 5) or UDim2.fromOffset(16, 16)
    grid.CellSize = compact and UDim2.new(0.5, -2, 0, 196) or UDim2.new(0.5, -8, 0, 234)

    panelGradient.Color = compact and ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 10, 12)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 5, 7)),
    }) or ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.PanelTop),
        ColorSequenceKeypoint.new(1, COLORS.PanelBottom),
    })

    for _, cardInfo in ipairs(currentCards) do
        setProperties(cardInfo.group, {
            BackgroundColor3 = style.cardColor,
            BackgroundTransparency = style.cardTransparency,
        })
        setProperties(cardInfo.stroke, {
            Color = style.edgeColor,
            Transparency = style.cardStrokeTransparency,
        })
        setProperties(cardInfo.icon, { TextColor3 = style.accent })
        cardInfo.corner.CornerRadius = UDim.new(0, compact and 2 or 14)
    end

    for _, descendant in ipairs(contentInner:GetDescendants()) do
        if descendant.Name == "AccentFill" or descendant.Name == "AccentSelection" then
            setProperties(descendant, { BackgroundColor3 = style.accent })
        elseif descendant.Name == "AccentKnob" then
            setProperties(descendant, { BackgroundColor3 = style.knobColor })
        elseif descendant.Name == "AccentStroke" and descendant:IsA("UIStroke") then
            setProperties(descendant, { Color = style.accent })
        end

        local toggleKey = descendant:GetAttribute("NimbusToggleKey")
        if toggleKey then
            local enabled = state[toggleKey] == true
            setProperties(descendant, {
                BackgroundColor3 = enabled and style.accent or COLORS.White,
            })
            local toggleKnob = descendant:FindFirstChild("Knob")
            if toggleKnob then
                setProperties(toggleKnob, {
                    BackgroundColor3 = enabled and style.knobColor or Color3.fromRGB(236, 243, 249),
                })
            end
        end
    end

    if not closed then
        setProperties(backdrop, {
            BackgroundTransparency = style.backdropTransparency,
        })
        setProperties(blur, { Size = style.blurSize })
    end

    updateResponsiveScale(shouldAnimate)
    refreshNavigation(false)
    task.defer(function()
        refreshNavigation(false)
    end)
    if compact and not closed then
        showAmbientParticles()
    else
        hideParticleField()
        snowOverlay.Visible = false
    end
end

local function bindCamera()
    if viewportConnection then
        viewportConnection:Disconnect()
        viewportConnection = nil
    end

    local camera = workspace.CurrentCamera
    if camera then
        viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale)
    end
    updateResponsiveScale()
end

cameraConnection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
bindCamera()


screenGui.AncestryChanged:Connect(function(_, parent)
    if parent == nil then
        if viewportConnection then
            viewportConnection:Disconnect()
        end
        if cameraConnection then
            cameraConnection:Disconnect()
        end
        if blur.Parent then
            blur:Destroy()
        end
    end
end)

refreshNavigation(false)
renderPage(currentPage, true)
applyTheme(false)
