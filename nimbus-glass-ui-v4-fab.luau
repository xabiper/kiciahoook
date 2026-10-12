local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
if not player then
    error("Nimbus Glass UI must run from a LocalScript.")
end

local playerGui = player:WaitForChild("PlayerGui")

-- ── Mobile detection via UserInputService.PreferredInput ──────────────────
-- Enum.PreferredInput.Touch = phone/tablet with no keyboard/mouse/gamepad connected.
-- This is the officially recommended method (Roblox docs 2025).
-- Falls back to _G.NimbusForceMobile for the /mobile chat override.
local isMobile = (UserInputService.PreferredInput == Enum.PreferredInput.Touch)
    or (_G.NimbusForceMobile == true)

-- /mobile chat command still works for manual override
Players.LocalPlayer.Chatted:Connect(function(msg)
    if msg:lower() == "/mobile" then
        _G.NimbusForceMobile = not (_G.NimbusForceMobile == true)
        local gui = playerGui:FindFirstChild("NimbusGlassUI")
        if gui then gui:Destroy() end
        local lb = Lighting:FindFirstChild("NimbusGlassBlur")
        if lb then lb:Destroy() end
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xabiper/kiciahoook/refs/heads/main/nimbus-glass-ui-mobile.luau"))()
    end
end)

local previousGui = playerGui:FindFirstChild("NimbusGlassUI")
if previousGui then previousGui:Destroy() end
local previousBlur = Lighting:FindFirstChild("NimbusGlassBlur")
if previousBlur then previousBlur:Destroy() end

-- ── Color palettes ─────────────────────────────────────────────────────────
-- Dark palette (original)
local COLORS = {
    Ink        = Color3.fromRGB(238, 244, 249),
    InkDim     = Color3.fromRGB(190, 202, 212),
    InkFaint   = Color3.fromRGB(139, 154, 166),
    Panel      = Color3.fromRGB(15, 23, 31),
    PanelTop   = Color3.fromRGB(26, 38, 49),
    PanelBottom= Color3.fromRGB(11, 18, 24),
    White      = Color3.fromRGB(255, 255, 255),
    Accent     = Color3.fromRGB(148, 208, 255),
    AccentBright = Color3.fromRGB(232, 247, 255),
    Shadow     = Color3.fromRGB(0, 0, 0),
}

-- Light palette — inverted text, white panels, grey accents
local COLORS_LIGHT = {
    Ink        = Color3.fromRGB(18, 24, 32),
    InkDim     = Color3.fromRGB(80, 90, 100),
    InkFaint   = Color3.fromRGB(130, 140, 150),
    Panel      = Color3.fromRGB(255, 255, 255),
    PanelTop   = Color3.fromRGB(248, 250, 252),
    PanelBottom= Color3.fromRGB(235, 240, 245),
    White      = Color3.fromRGB(255, 255, 255),
    Accent     = Color3.fromRGB(90, 100, 115),   -- slate-grey accent for light
    AccentBright = Color3.fromRGB(40, 50, 62),
    Shadow     = Color3.fromRGB(0, 0, 0),
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
    return create("UICorner", { Parent = object, CornerRadius = UDim.new(0, radius) })
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
            0, false, delayTime or 0
        ),
        goals
    )
    tween:Play()
    return tween
end

-- ── Pages ──────────────────────────────────────────────────────────────────
local PAGES = {
    {
        id = "home", label = "Home", icon = "⌂",
        cards = {
            {
                title = "Interface", icon = "□",
                rows = {
                    { type = "toggle", key = "denseRows",   label = "Dense Rows",        value = true  },
                    { type = "toggle", key = "tooltips",    label = "Show Tooltips",      value = false },
                    { type = "toggle", key = "railLabels",  label = "Sidebar Labels",     value = true  },
                    { type = "toggle", key = "animations",  label = "Animations",         value = true  },
                },
            },
            {
                title = "Performance", icon = "◴",
                rows = {
                    { type = "slider", key = "fps",     label = "Frame Rate Cap",     min = 30, max = 240, step = 6,  value = 144, unit = "" },
                    { type = "toggle", key = "vsync",   label = "V-Sync",             value = true  },
                    { type = "toggle", key = "latency", label = "Low Latency Mode",   value = false },
                    { type = "toggle", key = "throttle",label = "Background Throttle",value = true  },
                },
            },
            {
                title = "Appearance", icon = "◉",
                rows = {
                    { type = "toggle", key = "glassy",  label = "Glass Transparency", value = true  },
                    { type = "slider", key = "blur",    label = "Blur Strength",      min = 0, max = 40, step = 1, value = 24, unit = "" },
                    { type = "slider", key = "scale",   label = "UI Scale",           min = 80, max = 120, step = 5, value = 100, unit = "%" },
                },
            },
            {
                title = "Audio", icon = "♪",
                rows = {
                    { type = "slider", key = "volume",   label = "Master Volume",    min = 0, max = 100, step = 5, value = 70, unit = "%" },
                    { type = "toggle", key = "music",    label = "Music",            value = false },
                    { type = "toggle", key = "uiSounds", label = "UI Sounds",        value = true  },
                    { type = "toggle", key = "duck",     label = "Duck When Hidden", value = true  },
                },
            },
        },
    },
    {
        id = "interface", label = "Interface", icon = "□",
        cards = {
            {
                title = "Layout", icon = "□",
                rows = {
                    { type = "toggle", key = "denseRows",  label = "Dense Rows",      value = true  },
                    { type = "toggle", key = "railLabels", label = "Sidebar Labels",  value = true  },
                    { type = "toggle", key = "fullRows",   label = "Full-Width Rows", value = false },
                    { type = "toggle", key = "dividers",   label = "Row Dividers",    value = true  },
                },
            },
            {
                title = "Interaction", icon = "≡",
                rows = {
                    { type = "slider", key = "animationSpeed", label = "Animation Speed", min = 50, max = 200, step = 10, value = 100, unit = "%" },
                    { type = "toggle", key = "animations", label = "Animations",           value = true  },
                    { type = "toggle", key = "tooltips",   label = "Show Tooltips",        value = false },
                    { type = "toggle", key = "haptics",    label = "Haptic Feedback",      value = false },
                },
            },
        },
    },
    {
        id = "performance", label = "Performance", icon = "◴",
        cards = {
            {
                title = "Rendering", icon = "◴",
                rows = {
                    { type = "slider", key = "fps",     label = "Frame Rate Cap",   min = 30, max = 240, step = 6, value = 144, unit = "" },
                    { type = "toggle", key = "vsync",   label = "V-Sync",           value = true  },
                    { type = "toggle", key = "latency", label = "Low Latency Mode", value = false },
                },
            },
            {
                title = "Resources", icon = "ϟ",
                rows = {
                    { type = "slider", key = "cache",      label = "Cache Size",        min = 1, max = 8, step = 1, value = 4, unit = " GB" },
                    { type = "toggle", key = "throttle",   label = "Background Throttle", value = true },
                    { type = "toggle", key = "autoClean",  label = "Auto-Cleanup",      value = true },
                },
            },
        },
    },
    {
        id = "appearance", label = "Appearance", icon = "◉",
        cards = {
            {
                title = "Theme", icon = "◉",
                rows = {
                    { type = "toggle", key = "glassy", label = "Glass Transparency", value = true  },
                    { type = "toggle", key = "glow",   label = "Accent Glow",        value = true  },
                    { type = "slider", key = "blur",   label = "Blur Strength",      min = 0, max = 40, step = 1, value = 24, unit = "" },
                },
            },
            {
                title = "Scale & Contrast", icon = "≡",
                rows = {
                    { type = "slider", key = "scale",    label = "UI Scale",      min = 80, max = 120, step = 5, value = 100, unit = "%" },
                    { type = "toggle", key = "contrast", label = "High Contrast", value = false },
                    { type = "toggle", key = "boldText", label = "Bold Text",     value = false },
                },
            },
        },
    },
    {
        id = "audio", label = "Audio", icon = "♪",
        cards = {
            {
                title = "Levels", icon = "♪",
                rows = {
                    { type = "slider", key = "volume",        label = "Master Volume", min = 0, max = 100, step = 5, value = 70, unit = "%" },
                    { type = "slider", key = "musicVolume",   label = "Music",         min = 0, max = 100, step = 5, value = 40, unit = "%" },
                    { type = "slider", key = "effectsVolume", label = "Effects",       min = 0, max = 100, step = 5, value = 60, unit = "%" },
                },
            },
            {
                title = "Behavior", icon = "♫",
                rows = {
                    { type = "toggle", key = "uiSounds", label = "UI Sounds",        value = true  },
                    { type = "toggle", key = "music",    label = "Music",            value = false },
                    { type = "toggle", key = "duck",     label = "Duck When Hidden", value = true  },
                },
            },
        },
    },
    {
        id = "settings", label = "Settings", icon = "⚙",
        cards = {
            {
                title = "Profile", icon = "⚙",
                rows = {
                    { type = "toggle", key = "autoSave", label = "Auto-Save Layout",    value = true  },
                    { type = "toggle", key = "sync",     label = "Sync Across Devices", value = false },
                    { type = "button", key = "reset",    label = "Reset Defaults",      button = "Reset" },
                },
            },
            {
                title = "Motion & Theme", icon = "◈",
                rows = {
                    { type = "theme",  key = "theme",        label = "Theme",          value = "glass" },
                    { type = "toggle", key = "animations",   label = "Animations",     value = true  },
                    { type = "toggle", key = "snow",         label = "Falling Dots",   value = true,  compactOnly = true },
                    { type = "slider", key = "dissolveSpeed",label = "Dissolve Speed", min = 50, max = 200, step = 10, value = 100, unit = "%", compactOnly = true },
                },
            },
            {
                title = "About This Kit", icon = "□",
                rows = {
                    { type = "button", key = "why",  label = "What do the controls do?", button = "Explain" },
                    { type = "button", key = "copy", label = "Design notes",              button = "Details" },
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

-- ── Theme style table ──────────────────────────────────────────────────────
-- Four themes: glass (dark), glass_light (white/grey), compact (dark), compact_light (white/grey)
local THEME_STYLES = {
    glass = {
        isDark           = true,
        isCompact        = false,
        palette          = COLORS,
        interfaceScale   = 1,
        accent           = Color3.fromRGB(148, 208, 255),
        knobColor        = Color3.fromRGB(232, 247, 255),
        panelColor       = Color3.fromRGB(15, 23, 31),
        railColor        = Color3.fromRGB(255, 255, 255),
        cardColor        = Color3.fromRGB(255, 255, 255),
        edgeColor        = Color3.fromRGB(255, 255, 255),
        panelTransparency        = 0.32,
        railTransparency         = 0.965,
        cardTransparency         = 0.93,
        cardHoverTransparency    = 0.90,
        cardStrokeTransparency   = 0.84,
        cardHoverStrokeTransparency = 0.76,
        userTransparency         = 0.94,
        sessionTransparency      = 0.35,
        pillTransparency         = 0.90,
        backdropTransparency     = 0.72,
        blurSize                 = 14,
        panelGradientTop         = Color3.fromRGB(26, 38, 49),
        panelGradientBottom      = Color3.fromRGB(11, 18, 24),
        backdropColor            = Color3.fromRGB(11, 20, 27),
        backdropGradient         = {
            Color3.fromRGB(40, 74, 103),
            Color3.fromRGB(21, 43, 49),
            Color3.fromRGB(10, 21, 18),
        },
    },
    glass_light = {
        isDark           = false,
        isCompact        = false,
        palette          = COLORS_LIGHT,
        interfaceScale   = 1,
        accent           = Color3.fromRGB(90, 100, 115),
        knobColor        = Color3.fromRGB(40, 50, 62),
        panelColor       = Color3.fromRGB(255, 255, 255),
        railColor        = Color3.fromRGB(60, 70, 80),
        cardColor        = Color3.fromRGB(60, 70, 80),
        edgeColor        = Color3.fromRGB(160, 170, 180),
        panelTransparency        = 0.38,   -- more glass
        railTransparency         = 0.96,
        cardTransparency         = 0.91,
        cardHoverTransparency    = 0.87,
        cardStrokeTransparency   = 0.76,
        cardHoverStrokeTransparency = 0.62,
        userTransparency         = 0.91,
        sessionTransparency      = 0.30,
        pillTransparency         = 0.88,
        backdropTransparency     = 0.62,
        blurSize                 = 18,
        panelGradientTop         = Color3.fromRGB(248, 250, 252),
        panelGradientBottom      = Color3.fromRGB(232, 238, 244),
        backdropColor            = Color3.fromRGB(220, 228, 236),
        backdropGradient         = {
            Color3.fromRGB(210, 222, 234),
            Color3.fromRGB(225, 232, 238),
            Color3.fromRGB(235, 240, 244),
        },
    },
    compact = {
        isDark           = true,
        isCompact        = true,
        palette          = COLORS,
        interfaceScale   = 0.92,
        accent           = Color3.fromRGB(255, 126, 136),
        knobColor        = Color3.fromRGB(255, 232, 234),
        panelColor       = Color3.fromRGB(8, 7, 9),
        railColor        = Color3.fromRGB(10, 7, 9),
        cardColor        = Color3.fromRGB(27, 14, 17),
        edgeColor        = Color3.fromRGB(255, 145, 154),
        panelTransparency        = 0.08,
        railTransparency         = 0.22,
        cardTransparency         = 0.22,
        cardHoverTransparency    = 0.14,
        cardStrokeTransparency   = 0.70,
        cardHoverStrokeTransparency = 0.58,
        userTransparency         = 0.72,
        sessionTransparency      = 0.16,
        pillTransparency         = 0.76,
        backdropTransparency     = 0.84,
        blurSize                 = 4,
        panelGradientTop         = Color3.fromRGB(18, 10, 12),
        panelGradientBottom      = Color3.fromRGB(6, 5, 7),
        backdropColor            = Color3.fromRGB(8, 7, 9),
        backdropGradient         = {
            Color3.fromRGB(22, 10, 14),
            Color3.fromRGB(12, 8, 10),
            Color3.fromRGB(6, 5, 7),
        },
    },
    compact_light = {
        isDark           = false,
        isCompact        = true,
        palette          = COLORS_LIGHT,
        interfaceScale   = 0.92,
        accent           = Color3.fromRGB(90, 100, 115),
        knobColor        = Color3.fromRGB(40, 50, 62),
        panelColor       = Color3.fromRGB(255, 255, 255),
        railColor        = Color3.fromRGB(245, 247, 250),
        cardColor        = Color3.fromRGB(245, 247, 250),
        edgeColor        = Color3.fromRGB(180, 188, 198),
        panelTransparency        = 0.20,   -- more glass
        railTransparency         = 0.38,
        cardTransparency         = 0.34,
        cardHoverTransparency    = 0.26,
        cardStrokeTransparency   = 0.68,
        cardHoverStrokeTransparency = 0.54,
        userTransparency         = 0.82,
        sessionTransparency      = 0.28,
        pillTransparency         = 0.84,
        backdropTransparency     = 0.68,
        blurSize                 = 8,
        panelGradientTop         = Color3.fromRGB(250, 252, 255),
        panelGradientBottom      = Color3.fromRGB(235, 240, 246),
        backdropColor            = Color3.fromRGB(215, 222, 230),
        backdropGradient         = {
            Color3.fromRGB(210, 220, 232),
            Color3.fromRGB(222, 230, 238),
            Color3.fromRGB(232, 238, 244),
        },
    },
}

local function currentThemeStyle()
    return THEME_STYLES[state.theme] or THEME_STYLES.glass
end

local function currentPalette()
    return currentThemeStyle().palette
end

local function animationsEnabled()
    return state.animations ~= false
end

local function motionDuration(d) return animationsEnabled() and d or 0.01 end
local function motionDelay(d)    return animationsEnabled() and d or 0    end

local function dissolveTimeScale()
    local speed = math.clamp(tonumber(state.dissolveSpeed) or 100, 50, 200)
    return 100 / speed
end

local applyTheme
local updateResponsiveScale
local refreshCurrentPage

-- ── BlurEffect ─────────────────────────────────────────────────────────────
local blur = create("BlurEffect", { Parent = Lighting, Name = "NimbusGlassBlur", Size = 0 })
playTween(blur, 0.45, { Size = 14 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local screenGui = create("ScreenGui", {
    Parent = playerGui,
    Name = "NimbusGlassUI",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    DisplayOrder = 40,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

-- ── Backdrop ───────────────────────────────────────────────────────────────
local backdrop = create("Frame", {
    Parent = screenGui,
    Name = "BackdropTint",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(11, 20, 27),
    BackgroundTransparency = 0.72,
    BorderSizePixel = 0,
})
local backdropGradient = create("UIGradient", {
    Parent = backdrop,
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(40, 74, 103)),
        ColorSequenceKeypoint.new(0.48, Color3.fromRGB(21, 43, 49)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(10, 21, 18)),
    }),
})

-- ── Session chip (desktop only) ────────────────────────────────────────────
local sessionChip = create("CanvasGroup", {
    Parent = screenGui,
    Name = "SessionChip",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -20, 0, 18),
    Size = UDim2.fromOffset(178, 34),
    BackgroundColor3 = COLORS.Panel,
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0,
    GroupTransparency = isMobile and 1 or 0,
    Visible = not isMobile,
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
addCorner(sessionAvatar, 9)
addStroke(sessionAvatar, 0.86)

create("TextLabel", {
    Parent = sessionAvatar,
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Text = "G",
    TextColor3 = COLORS.InkDim,
    TextSize = 9,
})

create("TextLabel", {
    Parent = sessionChip,
    Position = UDim2.fromOffset(36, 0),
    Size = UDim2.new(1, -44, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "guest · local session",
    TextColor3 = COLORS.InkDim,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
})

-- ── Shell ──────────────────────────────────────────────────────────────────
local SHELL_SIZE = isMobile and UDim2.fromOffset(390, 580) or UDim2.fromOffset(1040, 650)

local shell = create("CanvasGroup", {
    Parent = screenGui,
    Name = "WindowShell",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = SHELL_SIZE,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    GroupTransparency = 0,
})

local responsiveScale = create("UIScale", { Parent = shell, Scale = 1 })

local shadow = create("Frame", {
    Parent = shell,
    Name = "Shadow",
    Position = UDim2.fromOffset(0, 18),
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLORS.Shadow,
    BackgroundTransparency = 0.56,
    BorderSizePixel = 0,
})
addCorner(shadow, 22)

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
    BackgroundTransparency = 1,
    Active = true,
})

local titleLabel = create("TextLabel", {
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

local subtitleLabel = create("TextLabel", {
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
        playTween(button, 0.16, { BackgroundTransparency = 0.90, TextColor3 = COLORS.Ink })
        playTween(buttonStroke, 0.16, { Transparency = 0.86 })
    end)
    button.MouseLeave:Connect(function()
        playTween(button, 0.16, { BackgroundTransparency = 1, TextColor3 = COLORS.InkDim })
        playTween(buttonStroke, 0.16, { Transparency = 1 })
    end)

    return button
end

local minimizeButton = makeWindowButton("—", -58)
local closeButton    = makeWindowButton("×", -18)

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
    Text = "Guest",
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
    Text = "Local profile",
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
    playTween(userCard, motionDuration(0.18), { BackgroundTransparency = math.max(0, style.userTransparency - 0.04) })
    playTween(userStroke, motionDuration(0.18), { Transparency = 0.82 })
end)
userCard.MouseLeave:Connect(function()
    local style = currentThemeStyle()
    playTween(userCard, motionDuration(0.18), { BackgroundTransparency = style.userTransparency })
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
    CellPadding = isMobile and UDim2.fromOffset(10, 10) or UDim2.fromOffset(16, 16),
    CellSize   = isMobile and UDim2.new(1, 0, 0, 220) or UDim2.new(0.5, -8, 0, 234),
    FillDirection = Enum.FillDirection.Horizontal,
    FillDirectionMaxCells = isMobile and 1 or 2,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Top,
})

local function updateCanvas()
    local h = grid.AbsoluteContentSize.Y
    contentInner.Size = UDim2.new(1, -40, 0, h)
    mainScroll.CanvasSize = UDim2.fromOffset(0, h + 36)
end
grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

-- ── Toast ──────────────────────────────────────────────────────────────────
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
        if serial ~= toastSerial then return end
        local fade = playTween(toastGroup, motionDuration(0.22), {
            GroupTransparency = 1,
            Position = UDim2.new(0.5, 0, 1, -18),
        }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        fade.Completed:Once(function()
            if serial == toastSerial then toastGroup.Visible = false end
        end)
    end)
end

userCard.Activated:Connect(function()
    showToast("Local profile — no account and no network connection.")
end)

-- ── Page connection tracking ────────────────────────────────────────────────
local pageConnections = {}
local function trackPageConnection(c) table.insert(pageConnections, c); return c end
local function clearPageConnections()
    for _, c in ipairs(pageConnections) do c:Disconnect() end
    table.clear(pageConnections)
end

local function formatValue(value)
    if math.abs(value - math.floor(value)) < 0.0001 then return tostring(math.floor(value)) end
    return string.format("%.1f", value)
end

-- ── Row widgets ────────────────────────────────────────────────────────────
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
        local targetColor = enabled and style.accent or (style.isDark and COLORS.White or Color3.fromRGB(200, 208, 218))
        local targetTransparency = enabled and 0.67 or 0.86
        local targetStroke = enabled and 0.55 or 0.86
        local knobOffColor = style.isDark and Color3.fromRGB(236, 243, 249) or Color3.fromRGB(180, 188, 198)

        if instant then
            toggle.BackgroundColor3 = targetColor
            toggle.BackgroundTransparency = targetTransparency
            toggleStroke.Transparency = targetStroke
            knob.Position = targetPosition
            knob.BackgroundColor3 = enabled and style.knobColor or knobOffColor
        else
            playTween(toggle, motionDuration(0.22), {
                BackgroundColor3 = targetColor,
                BackgroundTransparency = targetTransparency,
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            playTween(toggleStroke, motionDuration(0.22), { Transparency = targetStroke })
            playTween(knob, motionDuration(0.24), {
                Position = targetPosition,
                BackgroundColor3 = enabled and style.knobColor or knobOffColor,
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
    local dragInputRef = nil

    hitArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInputRef = input
            setFromScreenX(input.Position.X)
            playTween(knob, motionDuration(0.12), { Size = UDim2.fromOffset(18, 18) })
        end
    end)

    trackPageConnection(UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromScreenX(input.Position.X)
        elseif input == dragInputRef then
            setFromScreenX(input.Position.X)
        end
    end))

    trackPageConnection(UserInputService.InputEnded:Connect(function(input)
        if not dragging then return end
        if input == dragInputRef or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            dragInputRef = nil
            playTween(knob, motionDuration(0.14), { Size = UDim2.fromOffset(15, 15) })
        end
    end))

    refresh()
end

-- ── Theme selector — 4 options ─────────────────────────────────────────────
local function createThemeSelector(parent, rowData)
    -- 4 options, each button 72px wide, total ~300px
    local OPTS = {
        { id = "glass",         label = "Glass"    },
        { id = "glass_light",   label = "Light"    },
        { id = "compact",       label = "Compact"  },
        { id = "compact_light", label = "C·Light"  },
    }
    local BTN_W = 68
    local BTN_PAD = 3
    local TOTAL_W = BTN_PAD + #OPTS * (BTN_W + BTN_PAD)  -- 3+4*(68+3) = 287

    local wrap = create("Frame", {
        Parent = parent,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(TOTAL_W, 30),
        BackgroundColor3 = COLORS.White,
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
    })
    addCorner(wrap, 9)
    addStroke(wrap, 0.84)

    local selection = create("Frame", {
        Parent = wrap,
        Name = "AccentSelection",
        Position = UDim2.fromOffset(BTN_PAD, BTN_PAD),
        Size = UDim2.fromOffset(BTN_W, 24),
        BackgroundColor3 = currentThemeStyle().accent,
        BackgroundTransparency = 0.70,
        BorderSizePixel = 0,
    })
    addCorner(selection, 7)
    local selectionStroke = addStroke(selection, 0.70, currentThemeStyle().accent)
    selectionStroke.Name = "AccentStroke"

    local buttons = {}

    local function refresh(instant)
        local currentId = state[rowData.key]
        local targetIdx = 1
        for i, opt in ipairs(OPTS) do
            if opt.id == currentId then targetIdx = i; break end
        end
        local targetPos = UDim2.fromOffset(BTN_PAD + (targetIdx - 1) * (BTN_W + BTN_PAD), BTN_PAD)

        if instant or not animationsEnabled() then
            selection.Position = targetPos
        else
            playTween(selection, 0.30, { Position = targetPos }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        end

        for _, entry in ipairs(buttons) do
            local selected = entry.id == currentId
            local col = selected and COLORS.Ink or COLORS.InkDim
            if instant or not animationsEnabled() then
                entry.button.TextColor3 = col
            else
                playTween(entry.button, 0.18, { TextColor3 = col })
            end
        end
    end

    for i, optData in ipairs(OPTS) do
        local btn = create("TextButton", {
            Parent = wrap,
            Position = UDim2.fromOffset(BTN_PAD + (i - 1) * (BTN_W + BTN_PAD), BTN_PAD),
            Size = UDim2.fromOffset(BTN_W, 24),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Font = Enum.Font.GothamMedium,
            Text = optData.label,
            TextColor3 = COLORS.InkDim,
            TextSize = 9,
        })
        table.insert(buttons, { id = optData.id, button = btn })

        btn.Activated:Connect(function()
            if state[rowData.key] == optData.id then return end
            state[rowData.key] = optData.id
            refresh(false)
            if applyTheme then applyTheme(true) end
            if refreshCurrentPage then refreshCurrentPage() end
            showToast(optData.label .. " theme selected.")
        end)
    end

    refresh(true)
end

local currentPage  = "home"
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
        playTween(button, 0.16, { BackgroundTransparency = 0.88, TextColor3 = COLORS.Ink })
        playTween(buttonStroke, 0.16, { Transparency = 0.76 })
    end)
    button.MouseLeave:Connect(function()
        playTween(button, 0.16, { BackgroundTransparency = 0.94, TextColor3 = COLORS.InkDim })
        playTween(buttonStroke, 0.16, { Transparency = 0.84 })
    end)

    button.Activated:Connect(function()
        if rowData.key == "reset" then
            for key, value in pairs(defaults) do state[key] = value end
            if applyTheme then applyTheme(true) end
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

    local pal = currentPalette()
    create("TextLabel", {
        Parent = inner,
        Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(1, -202, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = rowData.label,
        TextColor3 = pal.Ink,
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
    local pal   = style.palette
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

    -- gradient tint on card
    if style.isDark then
        create("UIGradient", {
            Parent = card,
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(188, 208, 220)),
            }),
        })
    else
        create("UIGradient", {
            Parent = card,
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(228, 234, 242)),
            }),
        })
    end

    local cardScale = create("UIScale", { Parent = card, Scale = animateCard and 0.965 or 1 })

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
        TextColor3 = pal.Ink,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local visibleRows = {}
    for _, rowData in ipairs(cardData.rows) do
        local isCompactRow = rowData.compactOnly
        local themeIsCompact = (state.theme == "compact" or state.theme == "compact_light")
        if not isCompactRow or themeIsCompact then
            table.insert(visibleRows, rowData)
        end
    end

    local rows = {}
    for rowIndex, rowData in ipairs(visibleRows) do
        local row, inner = createRow(card, rowData, rowIndex, animateCard)
        table.insert(rows, { group = row, inner = inner })
    end

    card.MouseEnter:Connect(function()
        local s = currentThemeStyle()
        playTween(cardScale, motionDuration(0.28), { Scale = 1.012 })
        playTween(card, motionDuration(0.28), { BackgroundTransparency = s.cardHoverTransparency })
        playTween(cardStroke, motionDuration(0.28), { Transparency = s.cardHoverStrokeTransparency })
    end)
    card.MouseLeave:Connect(function()
        local s = currentThemeStyle()
        playTween(cardScale, motionDuration(0.28), { Scale = 1 })
        playTween(card, motionDuration(0.28), { BackgroundTransparency = s.cardTransparency })
        playTween(cardStroke, motionDuration(0.28), { Transparency = s.cardStrokeTransparency })
    end)

    return { group = card, scale = cardScale, stroke = cardStroke, corner = cardCorner, icon = icon, rows = rows }
end

local function findPage(pageId)
    for _, p in ipairs(PAGES) do if p.id == pageId then return p end end
    return PAGES[1]
end

renderPage = function(pageId, animateCards)
    clearPageConnections()
    for _, child in ipairs(contentInner:GetChildren()) do
        if child ~= grid then child:Destroy() end
    end
    table.clear(currentCards)
    mainScroll.CanvasPosition = Vector2.zero

    local pageData = findPage(pageId)
    for cardIndex, cardData in ipairs(pageData.cards) do
        local cardInfo = createCard(cardData, cardIndex, animateCards)
        table.insert(currentCards, cardInfo)

        if animateCards then
            local cd = motionDelay((cardIndex - 1) * 0.07)
            playTween(cardInfo.group,  motionDuration(0.55), { GroupTransparency = 0 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, cd)
            playTween(cardInfo.scale,  motionDuration(0.55), { Scale = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, cd)
            for rowIndex, rowInfo in ipairs(cardInfo.rows) do
                local rd = motionDelay(cd + 0.08 + (rowIndex - 1) * 0.04)
                playTween(rowInfo.group, motionDuration(0.45), { GroupTransparency = 0 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, rd)
                playTween(rowInfo.inner, motionDuration(0.45), { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, rd)
            end
        end
    end
    task.defer(updateCanvas)
end

-- ── Nav ────────────────────────────────────────────────────────────────────
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

    local entry = { id = pageData.id, index = index, button = button, icon = icon, label = label }
    table.insert(navEntries, entry)

    button.MouseEnter:Connect(function()
        if currentPage ~= pageData.id then
            playTween(button, 0.16, { BackgroundTransparency = 0.95 })
            playTween(icon,   0.16, { TextColor3 = COLORS.Ink })
            playTween(label,  0.16, { TextColor3 = COLORS.Ink })
        end
    end)
    button.MouseLeave:Connect(function()
        playTween(button, 0.16, { BackgroundTransparency = 1 })
        if currentPage ~= pageData.id then
            playTween(icon,  0.16, { TextColor3 = COLORS.InkDim })
            playTween(label, 0.16, { TextColor3 = COLORS.InkDim })
        end
    end)
    button.Activated:Connect(function() switchPageFromNav(pageData.id) end)
end

local function refreshNavigation(animatePill)
    local activeEntry = navEntries[1]
    local pal = currentPalette()

    for _, entry in ipairs(navEntries) do
        local active = entry.id == currentPage
        if active then activeEntry = entry end
        local color = active and pal.Ink or pal.InkDim
        if animatePill then
            playTween(entry.icon,  motionDuration(0.22), { TextColor3 = color })
            playTween(entry.label, motionDuration(0.22), { TextColor3 = color })
        else
            entry.icon.TextColor3  = color
            entry.label.TextColor3 = color
        end
    end

    local targetPosition = activeEntry.button.Position
    local targetSize     = activeEntry.button.Size
    if animatePill then
        playTween(navPill, motionDuration(0.48), { Position = targetPosition, Size = targetSize }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        navPill.Position = targetPosition
        navPill.Size     = targetSize
    end
end

local compactRailExpanded = false
local function setRailLayout(expanded, animateChange)
    local isCompact = (state.theme == "compact" or state.theme == "compact_light")
    compactRailExpanded = isCompact and expanded or false

    local width, inset
    if isCompact then
        width = compactRailExpanded and 204 or 62
        inset = compactRailExpanded and 10 or 8
    else
        width = 220
        inset = 14
    end

    local labelsVisible = not isCompact or compactRailExpanded
    local duration = animateChange and animationsEnabled() and 0.56 or 0

    local function setOrTween(object, goals)
        if duration > 0 then
            playTween(object, duration, goals, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        else
            for p, v in pairs(goals) do object[p] = v end
        end
    end

    local function setLabelVis(lbl)
        local t = labelsVisible and 0 or 1
        if duration > 0 then
            playTween(lbl, labelsVisible and 0.24 or 0.14, { TextTransparency = t }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, labelsVisible and 0.14 or 0)
        else
            lbl.TextTransparency = t
        end
    end

    setOrTween(rail, { Size = UDim2.new(0, width, 1, 0) })
    setOrTween(mainScroll, { Position = UDim2.fromOffset(width, 0), Size = UDim2.new(1, -width, 1, 0) })
    setOrTween(navHolder, { Position = UDim2.fromOffset(inset, isCompact and 8 or 10), Size = UDim2.new(1, -(inset * 2), 0, 264) })
    setOrTween(userCard, { Position = UDim2.new(0, inset, 1, isCompact and -10 or -14), Size = UDim2.new(1, -(inset * 2), 0, 54) })
    setOrTween(userAvatar, {
        Position = isCompact and not compactRailExpanded
            and UDim2.new(0.5, -15, 0, 12) or UDim2.fromOffset(11, 12),
    })

    setLabelVis(userNameLabel)
    setLabelVis(userSubLabel)
    setLabelVis(userChevron)

    for _, entry in ipairs(navEntries) do
        setOrTween(entry.icon, {
            Position = isCompact and not compactRailExpanded
                and UDim2.new(0.5, -12, 0, 0) or UDim2.fromOffset(11, 0),
        })
        setLabelVis(entry.label)
    end

    refreshNavigation(false)
    task.defer(function() refreshNavigation(false); updateCanvas() end)
end

rail.MouseEnter:Connect(function()
    if state.theme == "compact" or state.theme == "compact_light" then setRailLayout(true, true) end
end)
rail.MouseLeave:Connect(function()
    if state.theme == "compact" or state.theme == "compact_light" then setRailLayout(false, true) end
end)

transitionTo = function(pageId, force)
    if pageId == currentPage and not force then return end
    currentPage = pageId
    transitionSerial += 1
    local serial = transitionSerial
    refreshNavigation(true)

    if not animationsEnabled() or #currentCards == 0 then
        renderPage(currentPage, animationsEnabled())
        return
    end

    for index, cardInfo in ipairs(currentCards) do
        local d = (index - 1) * 0.025
        playTween(cardInfo.group, 0.16, { GroupTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, d)
        playTween(cardInfo.scale, 0.16, { Scale = 0.985 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, d)
    end

    local waitTime = 0.16 + math.max(0, #currentCards - 1) * 0.025
    task.delay(waitTime, function()
        if serial == transitionSerial then renderPage(currentPage, true) end
    end)
end

switchPageFromNav = function(pageId) transitionTo(pageId, false) end
refreshCurrentPage = function() transitionTo(currentPage, true) end

-- ── Minimize / close ───────────────────────────────────────────────────────
local minimized = false
local closed    = false
local visibilityTransitioning = false
local visibilitySerial = 0
local interfaceTargetScale = 1
local positionBeforeClose = shell.Position
local FULL_SIZE = isMobile and UDim2.fromOffset(390, 580) or UDim2.fromOffset(1040, 650)
local MIN_SIZE  = isMobile and UDim2.fromOffset(390, 68)  or UDim2.fromOffset(1040, 68)

minimizeButton.Activated:Connect(function()
    if closed or visibilityTransitioning then return end
    minimized = not minimized
    if not minimized then body.Visible = true end
    minimizeButton.Text = minimized and "□" or "—"
    local targetSize = minimized and MIN_SIZE or FULL_SIZE
    local t = playTween(shell, motionDuration(0.34), { Size = targetSize }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    if minimized then
        t.Completed:Once(function() if minimized then body.Visible = false end end)
    end
end)

-- ── Reopen pill (desktop only) ─────────────────────────────────────────────
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
    Visible = not isMobile,   -- FAB replaces this on mobile
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

-- ── Mobile FAB ─────────────────────────────────────────────────────────────
-- Draggable circular button. Replaces the reopen pill on mobile.
-- Detection: built with isMobile; also created if the script detects joystick
-- controls at runtime (see detectMobile above).
local mobileFab       = nil
local mobFabDragging  = false
local mobFabDragInput = nil
local mobFabDragStart = Vector3.zero
local mobFabPosStart  = UDim2.new(1, -72, 1, -88)

if isMobile then
    local fabGlow = create("Frame", {
        Parent = screenGui,
        Name = "MobileFabGlow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -56, 1, -88),
        Size = UDim2.fromOffset(64, 64),
        BackgroundColor3 = COLORS.Accent,
        BackgroundTransparency = 0.75,
        BorderSizePixel = 0,
        ZIndex = 200,
    })
    addCorner(fabGlow, 32)

    local fabBody = create("CanvasGroup", {
        Parent = screenGui,
        Name = "MobileFab",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -56, 1, -88),
        Size = UDim2.fromOffset(54, 54),
        BackgroundColor3 = Color3.fromRGB(14, 20, 28),
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        ZIndex = 201,
        GroupTransparency = 0,
    })
    addCorner(fabBody, 27)
    local fabStroke = addStroke(fabBody, 0.55, COLORS.Accent)

    create("UIGradient", {
        Parent = fabBody,
        Rotation = 135,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 60, 80)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 16, 22)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.05),
            NumberSequenceKeypoint.new(1, 0.30),
        }),
    })

    local fabIcon = create("TextLabel", {
        Parent = fabBody,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "N",
        TextColor3 = COLORS.AccentBright,
        TextSize = 22,
        ZIndex = 202,
    })

    local fabDot = create("Frame", {
        Parent = fabBody,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 7),
        Size = UDim2.fromOffset(5, 5),
        BackgroundColor3 = COLORS.Accent,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        ZIndex = 203,
    })
    addCorner(fabDot, 3)

    local fabButton = create("TextButton", {
        Parent = fabBody,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 204,
    })

    mobileFab = { body = fabBody, glow = fabGlow, icon = fabIcon, stroke = fabStroke, button = fabButton }
    mobFabPosStart = fabBody.Position

    local function pulseFabGlow()
        if not closed then return end
        playTween(fabGlow, 0.9, { BackgroundTransparency = 0.55 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.delay(0.9, function()
            if not closed then return end
            playTween(fabGlow, 0.9, { BackgroundTransparency = 0.82 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.delay(0.9, pulseFabGlow)
        end)
    end

    fabButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            mobFabDragging  = true
            mobFabDragInput = input
            mobFabDragStart = input.Position
            mobFabPosStart  = fabBody.Position
        end
    end)

    local fabDragMoved = false

    UserInputService.InputChanged:Connect(function(input)
        if mobFabDragging and input == mobFabDragInput then
            local delta = input.Position - mobFabDragStart
            if delta.Magnitude > 6 then fabDragMoved = true end
            local newPos = UDim2.new(
                mobFabPosStart.X.Scale, mobFabPosStart.X.Offset + delta.X,
                mobFabPosStart.Y.Scale, mobFabPosStart.Y.Offset + delta.Y
            )
            fabBody.Position = newPos
            fabGlow.Position = newPos
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == mobFabDragInput then
            mobFabDragging  = false
            mobFabDragInput = nil
            fabDragMoved    = false
        end
    end)

    fabButton.Activated:Connect(function()
        if fabDragMoved then return end
        if closed then reopenPanel() else closePanel() end
    end)

    fabButton.MouseEnter:Connect(function()
        playTween(fabBody,   motionDuration(0.14), { BackgroundTransparency = 0.0  })
        playTween(fabStroke, motionDuration(0.14), { Transparency = 0.30 })
    end)
    fabButton.MouseLeave:Connect(function()
        playTween(fabBody,   motionDuration(0.14), { BackgroundTransparency = 0.08 })
        playTween(fabStroke, motionDuration(0.14), { Transparency = 0.55 })
    end)

    -- watch closed state to update FAB appearance
    local lastClosedState = closed
    task.spawn(function()
        while fabBody.Parent do
            if closed ~= lastClosedState then
                lastClosedState = closed
                if closed then
                    fabIcon.Text = "N"
                    fabGlow.Visible = true
                    pulseFabGlow()
                else
                    fabGlow.Visible = false
                    playTween(fabGlow, 0.12, { BackgroundTransparency = 0.75 })
                end
            end
            task.wait(0.05)
        end
    end)
end

-- ── Snow overlay (compact themes) ──────────────────────────────────────────
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
    local size   = snowRandom:NextInteger(1, 4)
    local startX = snowRandom:NextNumber(0.01, 0.99)
    local startY = snowRandom:NextNumber(-0.25, 0.75)
    local drift  = snowRandom:NextNumber(-0.07, 0.07)
    local dur    = snowRandom:NextNumber(5.5, 11.5)

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
        TweenInfo.new(dur, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0),
        { Position = UDim2.fromScale(startX + drift, startY + 1.25) }
    ):Play()
end

-- ── Particle overlay (compact open/close dissolve) ─────────────────────────
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

local particleScale = create("UIScale", { Parent = particleOverlay, Scale = responsiveScale.Scale })

local particles = {}
local particleRandom = Random.new(9173)
for index = 1, 280 do
    local size = particleRandom:NextInteger(2, 5)
    local x    = particleRandom:NextNumber(0.01, 0.99)
    local y    = particleRandom:NextNumber(0.01, 0.99)
    local basePosition    = UDim2.fromScale(x, y)
    local openingPosition = UDim2.new(x, particleRandom:NextInteger(-12, 12), y, particleRandom:NextInteger(-58, -24))
    local closingPosition = UDim2.new(x, particleRandom:NextInteger(-12, 12), y, particleRandom:NextInteger(24, 58))
    local isLight = particleRandom:NextNumber(0, 1) > 0.42

    local dot = create("Frame", {
        Parent = particleOverlay,
        Name = "DissolveParticle_" .. index,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = basePosition,
        Size = UDim2.fromOffset(size, size),
        BackgroundColor3 = isLight and Color3.fromRGB(180, 188, 200) or Color3.fromRGB(14, 8, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 102,
    })
    addCorner(dot, size)

    table.insert(particles, {
        object = dot, size = size,
        basePosition = basePosition, openingPosition = openingPosition, closingPosition = closingPosition,
        brightTransparency = isLight and particleRandom:NextNumber(0.02, 0.28) or particleRandom:NextNumber(0.10, 0.38),
        openingDelay = y * 0.72 + particleRandom:NextNumber(0, 0.07),
        closingDelay = y * 0.72 + particleRandom:NextNumber(0, 0.07),
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
    for _, t in ipairs(activeVisibilityTweens) do t:Cancel() end
    table.clear(activeVisibilityTweens)
end
local function visibilityTween(object, duration, goals, style, direction, delayTime)
    local t = playTween(object, duration, goals, style, direction, delayTime)
    table.insert(activeVisibilityTweens, t)
    return t
end

local function hideParticleField()
    particleOverlay.Visible = false
    for _, p in ipairs(particles) do p.object.BackgroundTransparency = 1 end
end

local function showAmbientParticles()
    hideParticleField()
    local isCompact = (state.theme == "compact" or state.theme == "compact_light")
    snowOverlay.Visible = isCompact and state.snow == true and animationsEnabled() and not closed
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
            if serial ~= visibilitySerial then return end
            visibilityTween(dot, 0.16 * timeScale, {
                Position = particle.basePosition,
                Size = UDim2.fromOffset(particle.size + 1, particle.size + 1),
                BackgroundTransparency = particle.brightTransparency,
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

            task.delay(0.17 * timeScale, function()
                if serial ~= visibilitySerial then return end
                visibilityTween(dot, 0.25 * timeScale, {
                    Position = covering and particle.closingPosition or particle.basePosition,
                    Size = UDim2.fromOffset(1, 1),
                    BackgroundTransparency = 1,
                }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            end)
        end)
    end

    task.delay(1.32 * timeScale, function()
        if serial ~= visibilitySerial then return end
        callback()
    end)
end

local function compactUiTargets()
    local targets = {
        { object = titleBar, progress = 0.05 },
        { object = rail,     progress = 0.40 },
    }
    for index, cardInfo in ipairs(currentCards) do
        local row = math.floor((index - 1) / 2)
        table.insert(targets, { object = cardInfo.group, progress = row == 0 and 0.34 or 0.72 })
    end
    return targets
end

local function setCompactUiHidden(hidden)
    local style = currentThemeStyle()
    local gt = hidden and 1 or 0
    titleBar.GroupTransparency = gt
    rail.GroupTransparency = gt
    for _, ci in ipairs(currentCards) do ci.group.GroupTransparency = gt end
    panel.BackgroundTransparency = hidden and 1 or style.panelTransparency
    panelStroke.Transparency = hidden and 1 or 0.72
    shadow.BackgroundTransparency = hidden and 1 or 0.66
    mainScroll.ScrollBarImageTransparency = hidden and 1 or 0.78
end

local function animateCompactUi(covering)
    local style = currentThemeStyle()
    local timeScale = dissolveTimeScale()
    if not covering then setCompactUiHidden(true) end

    for _, target in ipairs(compactUiTargets()) do
        local d = target.progress * 0.72 * timeScale
        visibilityTween(target.object, 0.30 * timeScale, { GroupTransparency = covering and 1 or 0 },
            Enum.EasingStyle.Quad, covering and Enum.EasingDirection.In or Enum.EasingDirection.Out, d)
    end

    visibilityTween(panel,      1.10 * timeScale, { BackgroundTransparency = covering and 1 or style.panelTransparency }, Enum.EasingStyle.Quad, covering and Enum.EasingDirection.In or Enum.EasingDirection.Out)
    visibilityTween(panelStroke,1.10 * timeScale, { Transparency = covering and 1 or 0.72 }, Enum.EasingStyle.Quad, covering and Enum.EasingDirection.In or Enum.EasingDirection.Out)
    visibilityTween(shadow,     0.96 * timeScale, { BackgroundTransparency = covering and 1 or 0.66 }, Enum.EasingStyle.Quad, covering and Enum.EasingDirection.In or Enum.EasingDirection.Out)
    visibilityTween(mainScroll, 0.70 * timeScale, { ScrollBarImageTransparency = covering and 1 or 0.78 }, Enum.EasingStyle.Quad, covering and Enum.EasingDirection.In or Enum.EasingDirection.Out)
end

-- ── Reopen control helpers ─────────────────────────────────────────────────
local function showReopenControl(serial, animated)
    if isMobile then return end
    if serial ~= visibilitySerial or not closed then return end
    reopenGroup.Visible = true
    if not animated then
        reopenGroup.GroupTransparency = 0
        reopenGroup.Position = UDim2.new(0.5, 0, 1, -24)
        return
    end
    reopenGroup.GroupTransparency = 1
    reopenGroup.Position = UDim2.new(0.5, 0, 1, -16)
    visibilityTween(reopenGroup, 0.26, { GroupTransparency = 0, Position = UDim2.new(0.5, 0, 1, -24) })
end

local function hideReopenControl(serial, animated)
    if isMobile then return end
    if not reopenGroup.Visible then return end
    if not animated then
        reopenGroup.Visible = false
        reopenGroup.GroupTransparency = 1
        return
    end
    visibilityTween(reopenGroup, 0.18, { GroupTransparency = 1, Position = UDim2.new(0.5, 0, 1, -18) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    task.delay(0.19, function()
        if serial == visibilitySerial and not closed then reopenGroup.Visible = false end
    end)
end

-- ── closePanel / reopenPanel ───────────────────────────────────────────────
local isCompactTheme = function()
    return state.theme == "compact" or state.theme == "compact_light"
end

closePanel = function()
    if closed or visibilityTransitioning then return end
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
        sessionChip.GroupTransparency = 1
        backdrop.BackgroundTransparency = 1
        blur.Size = 0
        hideParticleField()
        showReopenControl(serial, false)
        visibilityTransitioning = false
        return
    end

    visibilityTween(sessionChip, 0.22, { GroupTransparency = 1 })
    visibilityTween(backdrop, 0.30, { BackgroundTransparency = 1 })
    visibilityTween(blur, 0.30, { Size = 0 })

    if isCompactTheme() then
        shell.GroupTransparency = 0
        shell.Position = positionBeforeClose
        animateCompactUi(true)
        runDissolve(true, serial, function()
            if not closed then return end
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
            Position = UDim2.new(positionBeforeClose.X.Scale, positionBeforeClose.X.Offset, positionBeforeClose.Y.Scale, positionBeforeClose.Y.Offset + 10),
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        visibilityTween(responsiveScale, 0.32, { Scale = interfaceTargetScale * 0.96 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

        task.delay(0.33, function()
            if serial ~= visibilitySerial or not closed then return end
            shell.Visible = false
            responsiveScale.Scale = interfaceTargetScale
            showReopenControl(serial, true)
            visibilityTransitioning = false
        end)
    end
end

reopenPanel = function()
    if not closed or visibilityTransitioning then return end
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
        if isCompactTheme() then showAmbientParticles() else hideParticleField() end
        visibilityTransitioning = false
        return
    end

    visibilityTween(sessionChip, 0.28, { GroupTransparency = 0 })
    visibilityTween(backdrop, 0.34, { BackgroundTransparency = style.backdropTransparency })
    visibilityTween(blur, 0.40, { Size = style.blurSize })

    if isCompactTheme() then
        shell.GroupTransparency = 0
        animateCompactUi(false)
        runDissolve(false, serial, function()
            if closed then return end
            setCompactUiHidden(false)
            showAmbientParticles()
            visibilityTransitioning = false
        end)
    else
        hideParticleField()
        shell.GroupTransparency = 1
        shell.Position = UDim2.new(positionBeforeClose.X.Scale, positionBeforeClose.X.Offset, positionBeforeClose.Y.Scale, positionBeforeClose.Y.Offset + 10)
        responsiveScale.Scale = interfaceTargetScale * 0.96

        visibilityTween(shell, 0.42, { GroupTransparency = 0, Position = positionBeforeClose }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        visibilityTween(responsiveScale, 0.44, { Scale = interfaceTargetScale }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        task.delay(0.46, function()
            if serial == visibilitySerial and not closed then visibilityTransitioning = false end
        end)
    end
end

closeButton.Activated:Connect(closePanel)
reopenButton.Activated:Connect(reopenPanel)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift and UserInputService:GetFocusedTextBox() == nil then
        if closed then reopenPanel() else closePanel() end
    end
end)

reopenButton.MouseEnter:Connect(function() playTween(reopenGroup, motionDuration(0.16), { BackgroundTransparency = 0.16 }) end)
reopenButton.MouseLeave:Connect(function() playTween(reopenGroup, motionDuration(0.16), { BackgroundTransparency = 0.25 }) end)

-- ── Top-center FAB (open/close toggle, draggable) ─────────────────────────
local fab = create("CanvasGroup", {
    Parent = screenGui,
    Name   = "NimbusFab",
    AnchorPoint = Vector2.new(0.5, 0),
    Position    = UDim2.new(0.5, 0, 0, 14),
    Size        = UDim2.fromOffset(54, 54),
    BackgroundColor3    = Color3.fromRGB(14, 20, 28),
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    GroupTransparency = 0,
    ZIndex = 201,
})
addCorner(fab, 8)
addStroke(fab, 0.55, COLORS.Accent)

create("TextLabel", {
    Parent = fab,
    Size   = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Font   = Enum.Font.GothamBold,
    Text   = "N",
    TextColor3 = COLORS.AccentBright,
    TextSize   = 22,
    ZIndex = 202,
})

local fabBtn = create("TextButton", {
    Parent = fab,
    Size   = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text   = "",
    ZIndex = 203,
})

do
    local fabDragging  = false
    local fabDragInput = nil
    local fabDragStart = Vector3.zero
    local fabPosStart  = fab.Position
    local fabMoved     = false

    fabBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            fabDragging  = true
            fabDragInput = input
            fabDragStart = input.Position
            fabPosStart  = fab.Position
            fabMoved     = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if fabDragging and input == fabDragInput then
            local delta = input.Position - fabDragStart
            if delta.Magnitude > 6 then fabMoved = true end
            fab.Position = UDim2.new(
                fabPosStart.X.Scale, fabPosStart.X.Offset + delta.X,
                fabPosStart.Y.Scale, fabPosStart.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == fabDragInput then
            fabDragging  = false
            fabDragInput = nil
        end
    end)

    fabBtn.Activated:Connect(function()
        if fabMoved then fabMoved = false; return end
        if closed then reopenPanel() else closePanel() end
    end)
end

-- ── Window drag ────────────────────────────────────────────────────────────
local draggingWindow = false
local dragInputRef   = nil
local dragStart      = Vector3.zero
local shellStart     = shell.Position

titleBar.InputBegan:Connect(function(input)
    if closed or visibilityTransitioning then return end
    local localX = input.Position.X - titleBar.AbsolutePosition.X
    if localX > titleBar.AbsoluteSize.X - 104 then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = true
        dragStart   = input.Position
        shellStart  = shell.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingWindow = false end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInputRef = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingWindow and input == dragInputRef then
        local delta = input.Position - dragStart
        shell.Position = UDim2.new(shellStart.X.Scale, shellStart.X.Offset + delta.X, shellStart.Y.Scale, shellStart.Y.Offset + delta.Y)
        positionBeforeClose = shell.Position
    end
end)

-- ── Responsive scale ───────────────────────────────────────────────────────
local viewportConnection = nil
local cameraConnection   = nil

updateResponsiveScale = function(animateChange)
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local fitX, fitY
    if isMobile then
        fitX = (viewport.X - 16) / 390
        fitY = (viewport.Y - 16) / 580
    else
        fitX = (viewport.X - 28) / 1040
        fitY = (viewport.Y - 28) / 650
    end
    local viewportScale = math.clamp(math.min(fitX, fitY), isMobile and 0.55 or 0.45, 1)
    interfaceTargetScale = math.max(0.42, viewportScale * currentThemeStyle().interfaceScale)

    if animateChange and animationsEnabled() and not closed then
        playTween(responsiveScale, 0.38, { Scale = interfaceTargetScale }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    else
        responsiveScale.Scale = interfaceTargetScale
    end
end

-- ── applyTheme ─────────────────────────────────────────────────────────────
applyTheme = function(animateChange)
    local style = currentThemeStyle()
    local pal   = style.palette
    local shouldAnimate = animateChange and animationsEnabled()
    local duration = shouldAnimate and 0.34 or 0

    local function set(object, goals)
        if shouldAnimate then
            playTween(object, duration, goals, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        else
            for p, v in pairs(goals) do object[p] = v end
        end
    end

    -- backdrop
    set(backdrop, { BackgroundColor3 = style.backdropColor, BackgroundTransparency = closed and 1 or style.backdropTransparency })
    backdropGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    style.backdropGradient[1]),
        ColorSequenceKeypoint.new(0.48, style.backdropGradient[2]),
        ColorSequenceKeypoint.new(1,    style.backdropGradient[3]),
    })

    -- panel
    set(panel, { BackgroundColor3 = style.panelColor, BackgroundTransparency = style.panelTransparency })
    set(panelStroke, { Color = style.edgeColor, Transparency = isCompactTheme() and 0.72 or 0.78 })
    panelGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, style.panelGradientTop),
        ColorSequenceKeypoint.new(1, style.panelGradientBottom),
    })

    -- rail / nav
    set(rail, { BackgroundColor3 = style.railColor, BackgroundTransparency = style.railTransparency })
    set(navPill, { BackgroundColor3 = style.accent, BackgroundTransparency = style.pillTransparency })
    set(navPillStroke, { Color = style.edgeColor })
    set(mainScroll, { ScrollBarImageColor3 = style.accent })

    -- user card
    set(userCard, { BackgroundColor3 = style.cardColor, BackgroundTransparency = style.userTransparency })
    set(userStroke, { Color = style.edgeColor })
    userNameLabel.TextColor3 = pal.Ink
    userSubLabel.TextColor3  = pal.InkFaint
    userChevron.TextColor3   = pal.InkFaint

    -- title bar text
    titleLabel.TextColor3    = pal.Ink
    subtitleLabel.TextColor3 = pal.InkFaint

    -- session chip
    set(sessionChip, { BackgroundColor3 = style.panelColor, BackgroundTransparency = style.sessionTransparency })
    set(sessionStroke, { Color = style.edgeColor })

    -- shadow
    set(shadow, { BackgroundTransparency = isCompactTheme() and 0.66 or 0.56 })

    -- reopen pill (desktop)
    if not isMobile then
        set(reopenGroup, { BackgroundColor3 = style.panelColor, BackgroundTransparency = isCompactTheme() and 0.14 or 0.25 })
        set(reopenStroke, { Color = style.edgeColor })
        reopenButton.TextColor3 = pal.Ink
    end

    -- corner radii
    local c = isCompactTheme()
    panelCorner.CornerRadius    = UDim.new(0, c and 5  or 18)
    sessionCorner.CornerRadius  = UDim.new(0, c and 3  or 10)
    navPillCorner.CornerRadius  = UDim.new(0, c and 3  or 10)
    userCardCorner.CornerRadius = UDim.new(0, c and 3  or 12)
    reopenCorner.CornerRadius   = UDim.new(0, c and 3  or 19)
    grid.CellPadding = c and UDim2.fromOffset(10, 10) or UDim2.fromOffset(16, 16)
    grid.CellSize    = c and UDim2.new(0.5, -5, 0, 226) or UDim2.new(0.5, -8, 0, 234)

    -- current cards
    for _, cardInfo in ipairs(currentCards) do
        set(cardInfo.group, { BackgroundColor3 = style.cardColor, BackgroundTransparency = style.cardTransparency })
        set(cardInfo.stroke, { Color = style.edgeColor, Transparency = style.cardStrokeTransparency })
        set(cardInfo.icon, { TextColor3 = style.accent })
        cardInfo.corner.CornerRadius = UDim.new(0, c and 3 or 14)
    end

    -- walk descendants for accent/knob/toggle updates
    for _, desc in ipairs(contentInner:GetDescendants()) do
        if desc.Name == "AccentFill" or desc.Name == "AccentSelection" then
            set(desc, { BackgroundColor3 = style.accent })
        elseif desc.Name == "AccentKnob" then
            set(desc, { BackgroundColor3 = style.knobColor })
        elseif desc.Name == "AccentStroke" and desc:IsA("UIStroke") then
            set(desc, { Color = style.accent })
        end

        local toggleKey = desc:GetAttribute("NimbusToggleKey")
        if toggleKey then
            local enabled = state[toggleKey] == true
            local offColor = style.isDark and COLORS.White or Color3.fromRGB(200, 208, 218)
            set(desc, { BackgroundColor3 = enabled and style.accent or offColor })
            local knob = desc:FindFirstChild("Knob")
            if knob then
                local knobOffColor = style.isDark and Color3.fromRGB(236, 243, 249) or Color3.fromRGB(180, 188, 198)
                set(knob, { BackgroundColor3 = enabled and style.knobColor or knobOffColor })
            end
        end

        -- row label text colour
        if desc.Name == "Inner" and desc:IsA("Frame") then
            for _, child in ipairs(desc:GetChildren()) do
                if child:IsA("TextLabel") and child ~= child.Parent then  -- the row label
                    child.TextColor3 = pal.Ink
                end
            end
        end
    end

    if not closed then
        set(backdrop, { BackgroundTransparency = style.backdropTransparency })
        set(blur, { Size = style.blurSize })
    end

    setRailLayout(compactRailExpanded, shouldAnimate)
    updateResponsiveScale(shouldAnimate)
    refreshNavigation(false)
    task.defer(function() refreshNavigation(false) end)

    if isCompactTheme() and not closed then
        showAmbientParticles()
    else
        hideParticleField()
        snowOverlay.Visible = false
    end
end

local function bindCamera()
    if viewportConnection then viewportConnection:Disconnect(); viewportConnection = nil end
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
        if viewportConnection then viewportConnection:Disconnect() end
        if cameraConnection then cameraConnection:Disconnect() end
        if blur.Parent then blur:Destroy() end
    end
end)

refreshNavigation(false)
renderPage(currentPage, true)
applyTheme(false)
