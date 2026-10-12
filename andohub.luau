--[[
  AndoHub  ·  Rivals cheat menu
  Built on: Nimbus Glass UI (visual layer) + Kicia tab definitions (content)
  Rename: Nimbus → AndoHub
  Glass theme: blue glass (original nimbus palette)
  Compact theme: pink only (original nimbus compact palette, unchanged)
  Tabs: ESP, Aimbot, Combat, Movement, Misc, SkinChanger, Configs, Settings
  Extras: scrollable content, 3D ESP preview viewport, german shepherd logo
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if not player then
    error("AndoHub must run from a LocalScript.")
end

local playerGui = player:WaitForChild("PlayerGui")

local previousGui = playerGui:FindFirstChild("AndoHubUI")
if previousGui then previousGui:Destroy() end
local previousBlur = Lighting:FindFirstChild("AndoHubBlur")
if previousBlur then previousBlur:Destroy() end

-- ============================================================
--  COLORS
-- ============================================================
local COLORS = {
    Ink        = Color3.fromRGB(238, 244, 249),
    InkDim     = Color3.fromRGB(190, 202, 212),
    InkFaint   = Color3.fromRGB(139, 154, 166),
    Panel      = Color3.fromRGB(15, 23, 31),
    PanelTop   = Color3.fromRGB(26, 38, 49),
    PanelBottom= Color3.fromRGB(11, 18, 24),
    White      = Color3.fromRGB(255, 255, 255),
    Accent     = Color3.fromRGB(148, 208, 255),
    AccentBright=Color3.fromRGB(232, 247, 255),
    Shadow     = Color3.fromRGB(0, 0, 0),
    Pink       = Color3.fromRGB(255, 126, 136),
    PinkBright = Color3.fromRGB(255, 232, 234),
}

-- ============================================================
--  HELPERS
-- ============================================================
local function create(className, props)
    local obj = Instance.new(className)
    local parent = props.Parent
    for k, v in pairs(props) do
        if k ~= "Parent" then obj[k] = v end
    end
    obj.Parent = parent
    return obj
end

local function addCorner(obj, r)
    return create("UICorner", { Parent = obj, CornerRadius = UDim.new(0, r) })
end

local function addStroke(obj, trans, color)
    return create("UIStroke", {
        Parent = obj,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = color or COLORS.White,
        Transparency = trans,
        Thickness = 1,
    })
end

local function tween(obj, dur, goals, style, dir, delay)
    local t = TweenService:Create(obj,
        TweenInfo.new(dur, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out, 0, false, delay or 0),
        goals)
    t:Play()
    return t
end

-- ============================================================
--  THEME STYLES
-- ============================================================
local THEME_STYLES = {
    glass = {
        interfaceScale       = 1,
        accent               = COLORS.Accent,
        knobColor            = COLORS.AccentBright,
        panelColor           = COLORS.Panel,
        railColor            = COLORS.White,
        cardColor            = COLORS.White,
        edgeColor            = COLORS.White,
        panelTransparency    = 0.32,
        railTransparency     = 0.965,
        cardTransparency     = 0.93,
        cardHoverTransparency= 0.90,
        cardStrokeTransparency      = 0.84,
        cardHoverStrokeTransparency = 0.76,
        userTransparency     = 0.94,
        sessionTransparency  = 0.35,
        pillTransparency     = 0.90,
        backdropTransparency = 0.72,
        blurSize             = 14,
    },
    compact = {
        interfaceScale       = 0.92,
        accent               = COLORS.Pink,
        knobColor            = COLORS.PinkBright,
        panelColor           = Color3.fromRGB(8, 7, 9),
        railColor            = Color3.fromRGB(10, 7, 9),
        cardColor            = Color3.fromRGB(27, 14, 17),
        edgeColor            = Color3.fromRGB(255, 145, 154),
        panelTransparency    = 0.08,
        railTransparency     = 0.22,
        cardTransparency     = 0.22,
        cardHoverTransparency= 0.14,
        cardStrokeTransparency      = 0.70,
        cardHoverStrokeTransparency = 0.58,
        userTransparency     = 0.72,
        sessionTransparency  = 0.16,
        pillTransparency     = 0.76,
        backdropTransparency = 0.84,
        blurSize             = 4,
    },
}

-- ============================================================
--  STATE
-- ============================================================
local state = {
    theme          = "glass",
    animations     = true,
    snow           = true,
    dissolveSpeed  = 100,

    -- ESP
    espEnabled     = false,
    espBoxes       = true,
    espSkeleton    = true,
    espNames       = true,
    espHealth      = true,
    espDistance    = true,
    espTracers     = false,
    espChams       = false,
    espFOVCircle   = false,
    espFovRadius   = 120,
    espTeamCheck   = true,

    -- Aimbot
    aimbotEnabled  = false,
    aimbotFOV      = 80,
    aimbotSmooth   = 5,
    aimbotBone     = "Head",
    aimbotVisCheck = true,
    aimbotKey      = "RightMouseButton",

    -- Combat
    triggerEnabled = false,
    triggerDelay   = 80,
    recoilEnabled  = false,
    noSpreadEnabled= false,

    -- Movement
    bHopEnabled    = false,
    flyEnabled     = false,
    flySpeed       = 50,
    speedEnabled   = false,
    speedMult      = 1.5,
    noClipEnabled  = false,

    -- Misc
    watermarkEnabled = true,
    showFPS          = true,
    unlockFPS        = false,
    fpsCap           = 144,
    radarEnabled     = false,
    crosshairEnabled = false,

    -- Skin
    skinEnabled    = false,
    skinId         = "",
    skinName       = "Default",

    -- Configs
    configName     = "default",
}

local function currentStyle()
    return THEME_STYLES[state.theme] or THEME_STYLES.glass
end

local function animOn() return state.animations ~= false end
local function motDur(n) return animOn() and n or 0.01 end
local function motDel(n) return animOn() and n or 0 end

-- ============================================================
--  ROOT GUI
-- ============================================================
local blur = create("BlurEffect", { Parent = Lighting, Name = "AndoHubBlur", Size = 0 })
tween(blur, 0.45, { Size = 14 })

local screenGui = create("ScreenGui", {
    Parent = playerGui, Name = "AndoHubUI",
    IgnoreGuiInset = true, ResetOnSpawn = false,
    DisplayOrder = 40, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local backdrop = create("Frame", {
    Parent = screenGui, Name = "BackdropTint",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(11, 20, 27),
    BackgroundTransparency = 0.72, BorderSizePixel = 0,
})
create("UIGradient", {
    Parent = backdrop, Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(40, 74, 103)),
        ColorSequenceKeypoint.new(0.48, Color3.fromRGB(21, 43, 49)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(10, 21, 18)),
    }),
})

-- session chip
local sessionChip = create("CanvasGroup", {
    Parent = screenGui, Name = "SessionChip",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -20, 0, 18),
    Size = UDim2.fromOffset(178, 34),
    BackgroundColor3 = COLORS.Panel, BackgroundTransparency = 0.35, BorderSizePixel = 0,
})
local sessionCorner  = addCorner(sessionChip, 10)
local sessionStroke  = addStroke(sessionChip, 0.84)
local sessionAvatar  = create("Frame", {
    Parent = sessionChip, Position = UDim2.fromOffset(10, 8),
    Size = UDim2.fromOffset(18, 18), BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.86, BorderSizePixel = 0,
})
addCorner(sessionAvatar, 9); addStroke(sessionAvatar, 0.86)
create("TextLabel", {
    Parent = sessionAvatar, Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium, Text = "A", TextColor3 = COLORS.InkDim, TextSize = 9,
})
create("TextLabel", {
    Parent = sessionChip, Position = UDim2.fromOffset(36, 0),
    Size = UDim2.new(1, -44, 1, 0), BackgroundTransparency = 1,
    Font = Enum.Font.Gotham, Text = "ando · local session",
    TextColor3 = COLORS.InkDim, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
})

-- ============================================================
--  WINDOW SHELL
-- ============================================================
local FULL_SIZE = UDim2.fromOffset(1100, 680)
local MIN_SIZE  = UDim2.fromOffset(1100, 68)

local shell = create("CanvasGroup", {
    Parent = screenGui, Name = "WindowShell",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = FULL_SIZE, BackgroundTransparency = 1, BorderSizePixel = 0,
})

local responsiveScale = create("UIScale", { Parent = shell, Scale = 1 })

local shadow = create("Frame", {
    Parent = shell, Name = "Shadow",
    Position = UDim2.fromOffset(0, 18), Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLORS.Shadow, BackgroundTransparency = 0.56, BorderSizePixel = 0,
})
addCorner(shadow, 22)

local panel = create("Frame", {
    Parent = shell, Name = "GlassWindow",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLORS.Panel, BackgroundTransparency = 0.32,
    BorderSizePixel = 0, ClipsDescendants = true,
})
local panelCorner   = addCorner(panel, 18)
local panelStroke   = addStroke(panel, 0.78)
local panelGradient = create("UIGradient", {
    Parent = panel, Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.PanelTop),
        ColorSequenceKeypoint.new(1, COLORS.PanelBottom),
    }),
})

create("Frame", {
    Parent = panel, Name = "TopHighlight",
    Position = UDim2.fromOffset(18, 0), Size = UDim2.new(1, -36, 0, 1),
    BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.76, BorderSizePixel = 0,
})

-- ============================================================
--  TITLE BAR + LOGO
-- ============================================================
local titleBar = create("CanvasGroup", {
    Parent = panel, Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 68), BackgroundTransparency = 1, Active = true,
})

-- German shepherd logo (simple SVG-like drawing with frames)
local logoFrame = create("Frame", {
    Parent = titleBar, Position = UDim2.fromOffset(18, 12),
    Size = UDim2.fromOffset(44, 44),
    BackgroundTransparency = 1, BorderSizePixel = 0,
})

-- head circle
local headCircle = create("Frame", {
    Parent = logoFrame, Position = UDim2.fromOffset(7, 2),
    Size = UDim2.fromOffset(30, 28),
    BackgroundColor3 = Color3.fromRGB(120, 85, 40),
    BackgroundTransparency = 0.10, BorderSizePixel = 0,
})
addCorner(headCircle, 14)

-- dark face mask
local mask = create("Frame", {
    Parent = logoFrame, Position = UDim2.fromOffset(9, 10),
    Size = UDim2.fromOffset(26, 22),
    BackgroundColor3 = Color3.fromRGB(30, 20, 10),
    BackgroundTransparency = 0.15, BorderSizePixel = 0,
})
addCorner(mask, 11)

-- left ear
local earL = create("Frame", {
    Parent = logoFrame, Position = UDim2.fromOffset(8, 0),
    Size = UDim2.fromOffset(12, 14),
    BackgroundColor3 = Color3.fromRGB(120, 85, 40),
    BackgroundTransparency = 0.10, BorderSizePixel = 0,
})
addCorner(earL, 4)

-- right ear
local earR = create("Frame", {
    Parent = logoFrame, Position = UDim2.fromOffset(24, 0),
    Size = UDim2.fromOffset(12, 14),
    BackgroundColor3 = Color3.fromRGB(120, 85, 40),
    BackgroundTransparency = 0.10, BorderSizePixel = 0,
})
addCorner(earR, 4)

-- left eye
local eyeL = create("Frame", {
    Parent = logoFrame, Position = UDim2.fromOffset(12, 12),
    Size = UDim2.fromOffset(7, 5),
    BackgroundColor3 = Color3.fromRGB(180, 130, 50),
    BackgroundTransparency = 0.0, BorderSizePixel = 0,
})
addCorner(eyeL, 3)

-- right eye
local eyeR = create("Frame", {
    Parent = logoFrame, Position = UDim2.fromOffset(25, 12),
    Size = UDim2.fromOffset(7, 5),
    BackgroundColor3 = Color3.fromRGB(180, 130, 50),
    BackgroundTransparency = 0.0, BorderSizePixel = 0,
})
addCorner(eyeR, 3)

-- nose
local nose = create("Frame", {
    Parent = logoFrame, Position = UDim2.fromOffset(17, 22),
    Size = UDim2.fromOffset(10, 6),
    BackgroundColor3 = Color3.fromRGB(15, 10, 5),
    BackgroundTransparency = 0.0, BorderSizePixel = 0,
})
addCorner(nose, 3)

-- title text
create("TextLabel", {
    Parent = titleBar, Position = UDim2.fromOffset(70, 14),
    Size = UDim2.fromOffset(300, 24), BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold, Text = "AndoHub",
    TextColor3 = COLORS.Ink, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left,
})
create("TextLabel", {
    Parent = titleBar, Position = UDim2.fromOffset(70, 39),
    Size = UDim2.fromOffset(360, 16), BackgroundTransparency = 1,
    Font = Enum.Font.Gotham, Text = "rivals · local session",
    TextColor3 = COLORS.InkFaint, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
})

create("Frame", {
    Parent = panel, Position = UDim2.fromOffset(0, 67),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.92, BorderSizePixel = 0,
})

-- window buttons
local function makeWinBtn(text, offset)
    local btn = create("TextButton", {
        Parent = titleBar, AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, offset, 0, 19), Size = UDim2.fromOffset(34, 28),
        BackgroundColor3 = COLORS.White, BackgroundTransparency = 1,
        BorderSizePixel = 0, AutoButtonColor = false,
        Font = Enum.Font.GothamMedium, Text = text,
        TextColor3 = COLORS.InkDim, TextSize = 16,
    })
    addCorner(btn, 8)
    local bs = addStroke(btn, 1)
    btn.MouseEnter:Connect(function()
        tween(btn, 0.16, { BackgroundTransparency = 0.90, TextColor3 = COLORS.Ink })
        tween(bs,  0.16, { Transparency = 0.86 })
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.16, { BackgroundTransparency = 1, TextColor3 = COLORS.InkDim })
        tween(bs,  0.16, { Transparency = 1 })
    end)
    return btn
end

local minimizeButton = makeWinBtn("—", -58)
local closeButton    = makeWinBtn("×", -18)

-- ============================================================
--  BODY  (sidebar + content)
-- ============================================================
local body = create("Frame", {
    Parent = panel, Name = "Body",
    Position = UDim2.fromOffset(0, 68), Size = UDim2.new(1, 0, 1, -68),
    BackgroundTransparency = 1, ClipsDescendants = true,
})

-- RAIL (sidebar)
local rail = create("CanvasGroup", {
    Parent = body, Name = "Rail",
    Size = UDim2.new(0, 220, 1, 0),
    BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.965,
    BorderSizePixel = 0, ClipsDescendants = true,
})
create("Frame", {
    Parent = rail, AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 1, 1, 0),
    BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.92, BorderSizePixel = 0,
})

local navHolder = create("Frame", {
    Parent = rail, Position = UDim2.fromOffset(14, 10),
    Size = UDim2.new(1, -28, 0, 370), BackgroundTransparency = 1,
})

local navPill = create("Frame", {
    Parent = navHolder, Name = "ActivePill",
    Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.90, BorderSizePixel = 0,
})
local navPillCorner = addCorner(navPill, 10)
local navPillStroke = addStroke(navPill, 0.84)

-- user card
local userCard = create("TextButton", {
    Parent = rail, Name = "UserCard",
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 14, 1, -14),
    Size = UDim2.new(1, -28, 0, 54),
    BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.94,
    BorderSizePixel = 0, AutoButtonColor = false, Text = "", ClipsDescendants = true,
})
local userCardCorner = addCorner(userCard, 12)
local userStroke = addStroke(userCard, 0.90)

local userAvatar = create("Frame", {
    Parent = userCard, Position = UDim2.fromOffset(11, 12),
    Size = UDim2.fromOffset(30, 30), BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.87, BorderSizePixel = 0,
})
addCorner(userAvatar, 15); addStroke(userAvatar, 0.86)
create("TextLabel", {
    Parent = userAvatar, Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium, Text = "A", TextColor3 = COLORS.InkDim, TextSize = 11,
})

local userNameLabel = create("TextLabel", {
    Parent = userCard, Position = UDim2.fromOffset(51, 10),
    Size = UDim2.new(1, -78, 0, 18), BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium, Text = "Ando",
    TextColor3 = COLORS.Ink, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
})
local userSubLabel = create("TextLabel", {
    Parent = userCard, Position = UDim2.fromOffset(51, 28),
    Size = UDim2.new(1, -78, 0, 15), BackgroundTransparency = 1,
    Font = Enum.Font.Gotham, Text = "Local profile",
    TextColor3 = COLORS.InkFaint, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
})
local userChevron = create("TextLabel", {
    Parent = userCard, AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(12, 20),
    BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = ">",
    TextColor3 = COLORS.InkFaint, TextSize = 13,
})

userCard.MouseEnter:Connect(function()
    local s = currentStyle()
    tween(userCard,  motDur(0.18), { BackgroundTransparency = math.max(0, s.userTransparency - 0.04) })
    tween(userStroke,motDur(0.18), { Transparency = 0.82 })
end)
userCard.MouseLeave:Connect(function()
    local s = currentStyle()
    tween(userCard,  motDur(0.18), { BackgroundTransparency = s.userTransparency })
    tween(userStroke,motDur(0.18), { Transparency = 0.90 })
end)

-- ============================================================
--  MAIN SCROLL CONTENT
-- ============================================================
local mainScroll = create("ScrollingFrame", {
    Parent = body, Name = "Content",
    Position = UDim2.fromOffset(220, 0), Size = UDim2.new(1, -220, 1, 0),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    CanvasSize = UDim2.fromOffset(0, 0),
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = COLORS.White, ScrollBarImageTransparency = 0.78,
    ScrollingDirection = Enum.ScrollingDirection.Y,
})

local contentInner = create("Frame", {
    Parent = mainScroll, Name = "CardGrid",
    Position = UDim2.fromOffset(20, 18),
    Size = UDim2.new(1, -40, 0, 0), BackgroundTransparency = 1,
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
    local h = grid.AbsoluteContentSize.Y
    contentInner.Size = UDim2.new(1, -40, 0, h)
    mainScroll.CanvasSize = UDim2.fromOffset(0, h + 36)
end
grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

-- ============================================================
--  TOAST
-- ============================================================
local toastGroup = create("CanvasGroup", {
    Parent = screenGui, Name = "Toast",
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -20), Size = UDim2.fromOffset(360, 42),
    BackgroundColor3 = COLORS.Panel, BackgroundTransparency = 0.28,
    BorderSizePixel = 0, GroupTransparency = 1, Visible = false,
})
addCorner(toastGroup, 12); addStroke(toastGroup, 0.82)
local toastLabel = create("TextLabel", {
    Parent = toastGroup, Size = UDim2.new(1, -24, 1, 0),
    Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1,
    Font = Enum.Font.Gotham, Text = "", TextColor3 = COLORS.InkDim, TextSize = 11,
})

local toastSerial = 0
local function showToast(msg)
    toastSerial += 1
    local ser = toastSerial
    toastLabel.Text = msg
    toastGroup.Visible = true
    toastGroup.GroupTransparency = 1
    toastGroup.Position = UDim2.new(0.5, 0, 1, -14)
    tween(toastGroup, motDur(0.25), { GroupTransparency = 0, Position = UDim2.new(0.5, 0, 1, -26) })
    task.delay(2.2, function()
        if ser ~= toastSerial then return end
        local f = tween(toastGroup, motDur(0.22), { GroupTransparency = 1, Position = UDim2.new(0.5, 0, 1, -18) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        f.Completed:Once(function()
            if ser == toastSerial then toastGroup.Visible = false end
        end)
    end)
end

-- ============================================================
--  ROW / CARD HELPERS
-- ============================================================
local pageConnections = {}
local function trackConn(c) table.insert(pageConnections, c); return c end
local function clearConns()
    for _, c in ipairs(pageConnections) do c:Disconnect() end
    table.clear(pageConnections)
end

local function formatVal(v)
    if math.abs(v - math.floor(v)) < 0.0001 then return tostring(math.floor(v)) end
    return string.format("%.1f", v)
end

local function createToggle(parent, key, label, subLabel)
    local rowH = create("CanvasGroup", {
        Parent = parent, Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    })
    if subLabel then
        create("Frame", {
            Parent = rowH, Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.93, BorderSizePixel = 0,
        })
    end
    local inner = create("Frame", {
        Parent = rowH, Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
    })
    create("TextLabel", {
        Parent = inner, Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(1, -74, 1, 0), BackgroundTransparency = 1,
        Font = Enum.Font.Gotham, Text = label,
        TextColor3 = Color3.fromRGB(218, 230, 239), TextTransparency = 0.10,
        TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local toggle = create("TextButton", {
        Parent = inner, AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(44, 24),
        BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.86,
        BorderSizePixel = 0, AutoButtonColor = false, Text = "",
    })
    addCorner(toggle, 12)
    toggle:SetAttribute("AndoToggleKey", key)
    local ts = addStroke(toggle, 0.86)
    local knob = create("Frame", {
        Parent = toggle, Name = "Knob", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(12, 12), Size = UDim2.fromOffset(17, 17),
        BackgroundColor3 = Color3.fromRGB(236, 243, 249), BackgroundTransparency = 0.05, BorderSizePixel = 0,
    })
    addCorner(knob, 9); addStroke(knob, 0.80)

    local function refresh(instant)
        local en = state[key] == true
        local s = currentStyle()
        local tPos    = en and UDim2.fromOffset(32,12) or UDim2.fromOffset(12,12)
        local tColor  = en and s.accent or COLORS.White
        local tTrans  = en and 0.67 or 0.86
        local tStroke = en and 0.55 or 0.86
        if instant then
            toggle.BackgroundColor3 = tColor; toggle.BackgroundTransparency = tTrans
            ts.Transparency = tStroke; knob.Position = tPos
            knob.BackgroundColor3 = en and s.knobColor or Color3.fromRGB(236,243,249)
        else
            tween(toggle, motDur(0.22), { BackgroundColor3 = tColor, BackgroundTransparency = tTrans })
            tween(ts,     motDur(0.22), { Transparency = tStroke })
            tween(knob,   motDur(0.24), { Position = tPos, BackgroundColor3 = en and s.knobColor or Color3.fromRGB(236,243,249) }, Enum.EasingStyle.Back)
            if animOn() then
                knob.Size = UDim2.fromOffset(19,19)
                tween(knob, 0.18, { Size = UDim2.fromOffset(17,17) })
            end
        end
    end

    toggle.Activated:Connect(function()
        state[key] = not state[key]
        refresh(false)
    end)
    refresh(true)
    return rowH
end

local function createSlider(parent, key, label, min, max, step, unit)
    local rowH = create("Frame", {
        Parent = parent, Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1,
    })
    create("TextLabel", {
        Parent = rowH, Position = UDim2.fromOffset(2, 4),
        Size = UDim2.new(1, -200, 0, 18), BackgroundTransparency = 1,
        Font = Enum.Font.Gotham, Text = label, TextColor3 = Color3.fromRGB(218,230,239),
        TextTransparency = 0.10, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
    })

    local wrap = create("Frame", {
        Parent = rowH, AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 0), Size = UDim2.fromOffset(200, 52),
        BackgroundTransparency = 1,
    })

    local track = create("Frame", {
        Parent = wrap, Position = UDim2.fromOffset(2, 32),
        Size = UDim2.fromOffset(150, 4),
        BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.84, BorderSizePixel = 0,
    })
    addCorner(track, 2)

    local fill = create("Frame", {
        Parent = track, Name = "AccentFill",
        Size = UDim2.fromScale(0.5, 1),
        BackgroundColor3 = currentStyle().accent, BackgroundTransparency = 0.12, BorderSizePixel = 0,
    })
    addCorner(fill, 2)

    local knob = create("Frame", {
        Parent = track, Name = "AccentKnob",
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(15, 15),
        BackgroundColor3 = currentStyle().knobColor, BackgroundTransparency = 0, BorderSizePixel = 0,
    })
    addCorner(knob, 8); addStroke(knob, 0.58)

    local output = create("TextLabel", {
        Parent = wrap, AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 24), Size = UDim2.fromOffset(48, 24),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = "",
        TextColor3 = COLORS.InkDim, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right,
    })

    local hitArea = create("TextButton", {
        Parent = wrap, Position = UDim2.fromOffset(-4, 20),
        Size = UDim2.fromOffset(158, 28),
        BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false, Text = "",
    })

    local function refresh()
        local v = state[key]
        local alpha = math.clamp((v - min) / (max - min), 0, 1)
        fill.Size = UDim2.fromScale(alpha, 1)
        knob.Position = UDim2.fromScale(alpha, 0.5)
        output.Text = formatVal(v) .. (unit or "")
    end

    local function setFromX(sx)
        local w = math.max(track.AbsoluteSize.X, 1)
        local alpha = math.clamp((sx - track.AbsolutePosition.X) / w, 0, 1)
        local raw = min + (max - min) * alpha
        local steps = math.floor(((raw - min) / step) + 0.5)
        state[key] = math.clamp(min + steps * step, min, max)
        refresh()
    end

    local dragging, dragInput = false, nil
    hitArea.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragInput = inp; setFromX(inp.Position.X)
            tween(knob, motDur(0.12), { Size = UDim2.fromOffset(18,18) })
        end
    end)
    trackConn(UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp == dragInput then setFromX(inp.Position.X) end
    end))
    trackConn(UserInputService.InputEnded:Connect(function(inp)
        if not dragging then return end
        if inp == dragInput or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false; dragInput = nil
            tween(knob, motDur(0.14), { Size = UDim2.fromOffset(15,15) })
        end
    end))
    refresh()
    return rowH
end

local function createDropdown(parent, key, label, options)
    local rowH = create("Frame", {
        Parent = parent, Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1,
    })
    create("TextLabel", {
        Parent = rowH, Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(1, -160, 1, 0), BackgroundTransparency = 1,
        Font = Enum.Font.Gotham, Text = label, TextColor3 = Color3.fromRGB(218,230,239),
        TextTransparency = 0.10, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
    })

    local s = currentStyle()
    local dd = create("TextButton", {
        Parent = rowH, AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(140, 28),
        BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.90,
        BorderSizePixel = 0, AutoButtonColor = false,
        Font = Enum.Font.Gotham, Text = tostring(state[key] or options[1]) .. "  ▾",
        TextColor3 = COLORS.InkDim, TextSize = 11,
    })
    addCorner(dd, 8); addStroke(dd, 0.84)

    local dropList = create("Frame", {
        Parent = rowH, Position = UDim2.new(1, -10-140, 1, 2),
        Size = UDim2.fromOffset(140, #options * 28 + 4),
        BackgroundColor3 = COLORS.Panel, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, Visible = false, ZIndex = 50, ClipsDescendants = true,
    })
    addCorner(dropList, 8); addStroke(dropList, 0.70)
    local listLayout = create("UIListLayout", {
        Parent = dropList, SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
    })
    create("UIPadding", {
        Parent = dropList, PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2),
        PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
    })

    local open = false
    for i, opt in ipairs(options) do
        local optBtn = create("TextButton", {
            Parent = dropList, LayoutOrder = i,
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.96,
            BorderSizePixel = 0, AutoButtonColor = false,
            Font = Enum.Font.Gotham, Text = opt,
            TextColor3 = COLORS.InkDim, TextSize = 11,
        })
        addCorner(optBtn, 5)
        optBtn.MouseEnter:Connect(function() tween(optBtn, 0.10, { BackgroundTransparency = 0.88, TextColor3 = COLORS.Ink }) end)
        optBtn.MouseLeave:Connect(function() tween(optBtn, 0.10, { BackgroundTransparency = 0.96, TextColor3 = COLORS.InkDim }) end)
        optBtn.Activated:Connect(function()
            state[key] = opt
            dd.Text = opt .. "  ▾"
            dropList.Visible = false; open = false
        end)
    end

    dd.Activated:Connect(function()
        open = not open
        dropList.Visible = open
    end)
    dd.MouseEnter:Connect(function() tween(dd, 0.12, { BackgroundTransparency = 0.84, TextColor3 = COLORS.Ink }) end)
    dd.MouseLeave:Connect(function() tween(dd, 0.12, { BackgroundTransparency = 0.90, TextColor3 = COLORS.InkDim }) end)
    return rowH
end

local function createTextInput(parent, key, label, placeholder)
    local rowH = create("Frame", {
        Parent = parent, Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1,
    })
    create("TextLabel", {
        Parent = rowH, Position = UDim2.fromOffset(2, 4),
        Size = UDim2.new(1, -200, 0, 16), BackgroundTransparency = 1,
        Font = Enum.Font.Gotham, Text = label, TextColor3 = Color3.fromRGB(218,230,239),
        TextTransparency = 0.10, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
    })
    local box = create("TextBox", {
        Parent = rowH, AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 22), Size = UDim2.fromOffset(200, 26),
        BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.90,
        BorderSizePixel = 0, Font = Enum.Font.Gotham,
        Text = tostring(state[key] or ""), PlaceholderText = placeholder or "",
        TextColor3 = COLORS.Ink, TextSize = 11,
        ClearTextOnFocus = false,
    })
    addCorner(box, 6); addStroke(box, 0.84)
    box.FocusLost:Connect(function() state[key] = box.Text end)
    return rowH
end

local function createActionButton(parent, label, callback)
    local rowH = create("Frame", {
        Parent = parent, Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1,
    })
    local btn = create("TextButton", {
        Parent = rowH, AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(100, 30),
        BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.90,
        BorderSizePixel = 0, AutoButtonColor = false,
        Font = Enum.Font.GothamMedium, Text = label,
        TextColor3 = COLORS.InkDim, TextSize = 11,
    })
    addCorner(btn, 8); local bs = addStroke(btn, 0.84)
    btn.MouseEnter:Connect(function()
        tween(btn, 0.14, { BackgroundTransparency = 0.82, TextColor3 = COLORS.Ink })
        tween(bs,  0.14, { Transparency = 0.70 })
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.14, { BackgroundTransparency = 0.90, TextColor3 = COLORS.InkDim })
        tween(bs,  0.14, { Transparency = 0.84 })
    end)
    btn.Activated:Connect(callback)
    return rowH
end

-- section header inside card
local function createSectionHeader(parent, text)
    local hdr = create("Frame", {
        Parent = parent, Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1,
    })
    create("TextLabel", {
        Parent = hdr, Position = UDim2.fromOffset(2, 4), Size = UDim2.new(1, 0, 1, -4),
        BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = text,
        TextColor3 = currentStyle().accent, TextTransparency = 0.10, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    return hdr
end

-- ============================================================
--  CARD FACTORY
-- ============================================================
local currentCards = {}
local function makeCard(title, icon, layoutOrder, builderFn)
    local s = currentStyle()
    local card = create("CanvasGroup", {
        Parent = contentInner, Name = "Card_" .. title:gsub("%W",""),
        LayoutOrder = layoutOrder,
        BackgroundColor3 = s.cardColor, BackgroundTransparency = s.cardTransparency,
        BorderSizePixel = 0, GroupTransparency = 0, Active = true,
    })
    addCorner(card, 14)
    local cardStroke = addStroke(card, s.cardStrokeTransparency, s.edgeColor)
    create("UIGradient", {
        Parent = card, Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(188,208,220)),
        }),
    })
    local cardScale = create("UIScale", { Parent = card, Scale = 1 })

    create("TextLabel", {
        Parent = card, Position = UDim2.fromOffset(16, 10), Size = UDim2.fromOffset(22, 22),
        BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = icon,
        TextColor3 = s.accent, TextTransparency = 0.10, TextSize = 16,
    })
    create("TextLabel", {
        Parent = card, Position = UDim2.fromOffset(44, 8), Size = UDim2.new(1, -60, 0, 26),
        BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = title,
        TextColor3 = COLORS.Ink, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- scroll frame inside card for controls
    local scrollInCard = create("ScrollingFrame", {
        Parent = card, Name = "CardScroll",
        Position = UDim2.fromOffset(0, 36), Size = UDim2.new(1, 0, 1, -36),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = s.accent, ScrollBarImageTransparency = 0.70,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ClipsDescendants = true,
    })
    local innerList = create("Frame", {
        Parent = scrollInCard, Name = "InnerList",
        Position = UDim2.fromOffset(12, 4), Size = UDim2.new(1, -24, 0, 0),
        BackgroundTransparency = 1,
    })
    local innerLayout = create("UIListLayout", {
        Parent = innerList, SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
    })
    innerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local h = innerLayout.AbsoluteContentSize.Y + 8
        innerList.Size = UDim2.new(1, -24, 0, h)
        scrollInCard.CanvasSize = UDim2.fromOffset(0, h)
    end)

    builderFn(innerList)

    card.MouseEnter:Connect(function()
        local as = currentStyle()
        tween(cardScale, motDur(0.28), { Scale = 1.012 })
        tween(card,      motDur(0.28), { BackgroundTransparency = as.cardHoverTransparency })
        tween(cardStroke,motDur(0.28), { Transparency = as.cardHoverStrokeTransparency })
    end)
    card.MouseLeave:Connect(function()
        local as = currentStyle()
        tween(cardScale, motDur(0.28), { Scale = 1 })
        tween(card,      motDur(0.28), { BackgroundTransparency = as.cardTransparency })
        tween(cardStroke,motDur(0.28), { Transparency = as.cardStrokeTransparency })
    end)

    table.insert(currentCards, { group = card, scale = cardScale, stroke = cardStroke })
    return card
end

-- ============================================================
--  3D ESP PREVIEW VIEWPORT
-- ============================================================
local function createEspViewport(parent)
    -- viewport showing a model silhouette representing ESP view
    local vpFrame = create("ViewportFrame", {
        Parent = parent, Name = "EspViewport",
        Size = UDim2.new(1, 0, 0, 160),
        BackgroundColor3 = Color3.fromRGB(5, 12, 20),
        BackgroundTransparency = 0, BorderSizePixel = 0,
        Ambient = Color3.fromRGB(80, 120, 160),
        LightColor = Color3.fromRGB(180, 220, 255),
        LightDirection = Vector3.new(-1, -2, -1),
    })
    addCorner(vpFrame, 8)
    addStroke(vpFrame, 0.78)

    local vpCamera = Instance.new("Camera")
    vpCamera.CFrame = CFrame.new(Vector3.new(0, 3.5, 8), Vector3.new(0, 3.5, 0))
    vpCamera.FieldOfView = 60
    vpFrame.CurrentCamera = vpCamera
    vpCamera.Parent = vpFrame

    -- build a simple rig (box body, sphere head)
    local rig = Instance.new("Model")
    rig.Name = "EspPreviewRig"

    local function mkPart(sz, cf, col)
        local p = Instance.new("Part")
        p.Size = sz; p.CFrame = cf
        p.Anchored = true; p.CanCollide = false
        p.Material = Enum.Material.SmoothPlastic
        p.Color = col; p.CastShadow = false
        p.Parent = rig
        return p
    end

    -- body
    mkPart(Vector3.new(2, 3, 1), CFrame.new(0, 1.5, 0), Color3.fromRGB(80, 100, 130))
    -- head
    local head = mkPart(Vector3.new(1.2, 1.2, 1.2), CFrame.new(0, 3.6, 0), Color3.fromRGB(200, 170, 130))
    -- left arm
    mkPart(Vector3.new(0.7, 2.5, 0.7), CFrame.new(-1.35, 1.5, 0), Color3.fromRGB(80, 100, 130))
    -- right arm
    mkPart(Vector3.new(0.7, 2.5, 0.7), CFrame.new(1.35, 1.5, 0),  Color3.fromRGB(80, 100, 130))
    -- left leg
    mkPart(Vector3.new(0.8, 2.2, 0.8), CFrame.new(-0.55, -1.1, 0), Color3.fromRGB(50, 65, 90))
    -- right leg
    mkPart(Vector3.new(0.8, 2.2, 0.8), CFrame.new(0.55, -1.1, 0),  Color3.fromRGB(50, 65, 90))

    rig.Parent = vpFrame

    -- overlay ESP boxes drawn as SelectionBox-like parts via billboard GUI
    local espOverlay = create("BillboardGui", {
        Parent = head, AlwaysOnTop = true,
        Size = UDim2.fromOffset(80, 140),
        SizeOffset = Vector2.new(0, 1.2),
        StudsOffset = Vector3.new(0, 1.5, 0),
    })
    -- box outline
    local boxOuter = create("Frame", {
        Parent = espOverlay, Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    })
    create("UIStroke", {
        Parent = boxOuter, Color = Color3.fromRGB(255, 80, 80),
        Thickness = 2, Transparency = 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
    addCorner(boxOuter, 2)

    -- name label
    create("TextLabel", {
        Parent = espOverlay,
        Position = UDim2.new(0, 0, 0, -20), Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
        Text = "Enemy · 24m", TextColor3 = Color3.fromRGB(255, 80, 80),
        TextSize = 10,
    })

    -- health bar on left side
    local healthBg = create("Frame", {
        Parent = espOverlay,
        Position = UDim2.new(0, -10, 0, 0), Size = UDim2.fromOffset(4, 0),
        AnchorPoint = Vector2.new(1, 0), SizeConstraint = Enum.SizeConstraint.RelativeYY,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30), BackgroundTransparency = 0.3, BorderSizePixel = 0,
    })
    addCorner(healthBg, 2)
    local healthFill = create("Frame", {
        Parent = healthBg, Position = UDim2.fromScale(0, 0),
        Size = UDim2.fromScale(1, 0.72), -- 72% health
        BackgroundColor3 = Color3.fromRGB(80, 220, 100), BackgroundTransparency = 0, BorderSizePixel = 0,
    })
    addCorner(healthFill, 2)

    return vpFrame
end

-- ============================================================
--  TAB PAGES
-- ============================================================
local PAGES = {
    {
        id = "esp", label = "ESP", icon = "◉",
        build = function()
            -- viewport preview card (full width)
            local previewCard = create("CanvasGroup", {
                Parent = contentInner, Name = "Card_ESPPreview",
                LayoutOrder = 0,
                BackgroundColor3 = currentStyle().cardColor, BackgroundTransparency = currentStyle().cardTransparency,
                BorderSizePixel = 0, GroupTransparency = 0, Active = true,
            })
            -- span full width by using a frame outside the grid — we do it via LayoutOrder trick
            -- Actually: make grid cell size dynamic. Instead, put viewport in a special single-wide card.
            addCorner(previewCard, 14)
            addStroke(previewCard, currentStyle().cardStrokeTransparency, currentStyle().edgeColor)
            create("UIGradient", {
                Parent = previewCard, Rotation = 90,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(188,208,220)),
                }),
            })
            local cardScale0 = create("UIScale", { Parent = previewCard, Scale = 1 })
            local cs0 = previewCard:FindFirstChildOfClass("UIStroke")
            create("TextLabel", {
                Parent = previewCard, Position = UDim2.fromOffset(16, 10), Size = UDim2.fromOffset(22, 22),
                BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = "□",
                TextColor3 = currentStyle().accent, TextTransparency = 0.10, TextSize = 16,
            })
            create("TextLabel", {
                Parent = previewCard, Position = UDim2.fromOffset(44, 8), Size = UDim2.new(1, -60, 0, 26),
                BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = "ESP Preview",
                TextColor3 = COLORS.Ink, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
            })
            createEspViewport(previewCard)
            table.insert(currentCards, { group = previewCard, scale = cardScale0, stroke = cs0 or addStroke(previewCard, 0.84) })

            makeCard("Player ESP", "◉", 1, function(p)
                createToggle(p, "espEnabled", "Enable ESP")
                createToggle(p, "espTeamCheck", "Team Check")
                createToggle(p, "espBoxes", "Boxes")
                createToggle(p, "espSkeleton", "Skeleton")
                createToggle(p, "espNames", "Names")
                createToggle(p, "espHealth", "Health Bar")
                createToggle(p, "espDistance", "Distance")
                createToggle(p, "espTracers", "Tracers")
                createToggle(p, "espChams", "Chams")
                createToggle(p, "espFOVCircle", "FOV Circle")
                createSlider(p, "espFovRadius", "FOV Radius", 20, 400, 10, "")
            end)

            makeCard("ESP Appearance", "≡", 2, function(p)
                createDropdown(p, "espBoxStyle", "Box Style",    { "Full", "Corner" })
                createDropdown(p, "espBoxFit",   "Box Fit",      { "Static", "Dynamic" })
                createDropdown(p, "espFontSize",  "Font",        { "8", "10", "12", "14" })
                createDropdown(p, "espTextCase",  "Text Case",   { "Standard", "UPPERCASE", "lowercase" })
                createDropdown(p, "espSurround",  "Text Surround", { "None", "[]", "()", "<>" })
                createDropdown(p, "espTracerFrom","Tracer Origin", { "Bottom", "Center", "Top", "Mouse" })
                createDropdown(p, "espTracerTo",  "Tracer Target", { "Feet", "Head" })
                createDropdown(p, "espHMarkerShape","Head Marker Shape", { "Cross", "Circle", "Diamond" })
                createDropdown(p, "espHealthMode","Health Color Mode", { "Solid", "Gradient", "Reactive" })
            end)
        end,
    },
    {
        id = "aimbot", label = "Aimbot", icon = "◎",
        build = function()
            makeCard("Aimbot", "◎", 1, function(p)
                createToggle(p, "aimbotEnabled", "Enable Aimbot")
                createToggle(p, "aimbotVisCheck", "Visibility Check")
                createSlider(p, "aimbotFOV",    "FOV",      1,  360, 1,  "°")
                createSlider(p, "aimbotSmooth", "Smoothing",1,  20,  0.5,"")
                createDropdown(p, "aimbotBone", "Target Bone",  { "Head", "Neck", "Torso", "Random" })
                createDropdown(p, "aimbotKey",  "Hold Key", { "RightMouseButton", "LeftAlt", "CapsLock", "Q" })
            end)

            makeCard("Triggerbot", "⊙", 2, function(p)
                createToggle(p, "triggerEnabled", "Enable Triggerbot")
                createToggle(p, "triggerTeamCheck","Team Check")
                createSlider(p, "triggerDelay",  "Delay (ms)", 0, 500, 5, " ms")
            end)
        end,
    },
    {
        id = "combat", label = "Combat", icon = "⚔",
        build = function()
            makeCard("Recoil & Spread", "⚔", 1, function(p)
                createToggle(p, "recoilEnabled",  "No Recoil")
                createToggle(p, "noSpreadEnabled","No Spread")
            end)

            makeCard("Combat Misc", "◴", 2, function(p)
                createToggle(p, "silentAimEnabled",  "Silent Aim")
                createToggle(p, "rapidFireEnabled",  "Rapid Fire")
                createSlider(p, "fireRateMultiplier","Fire Rate Mult", 1, 10, 0.5, "x")
            end)
        end,
    },
    {
        id = "movement", label = "Movement", icon = "↑",
        build = function()
            makeCard("Movement", "↑", 1, function(p)
                createToggle(p, "bHopEnabled",   "BunnyHop")
                createToggle(p, "flyEnabled",    "Fly")
                createSlider(p, "flySpeed",      "Fly Speed", 10, 200, 5, "")
                createToggle(p, "speedEnabled",  "Speed Boost")
                createSlider(p, "speedMult",     "Speed Mult", 1, 5, 0.1, "x")
                createToggle(p, "noClipEnabled", "Noclip")
            end)
        end,
    },
    {
        id = "misc", label = "Misc", icon = "⋯",
        build = function()
            makeCard("UI & Display", "□", 1, function(p)
                createToggle(p, "watermarkEnabled","Show Watermark")
                createToggle(p, "showFPS",         "FPS Counter")
                createToggle(p, "unlockFPS",       "Unlock FPS")
                createSlider(p, "fpsCap",          "FPS Cap", 30, 360, 6, "")
                createToggle(p, "crosshairEnabled","Custom Crosshair")
                createToggle(p, "radarEnabled",    "Radar")
            end)

            makeCard("World", "◈", 2, function(p)
                createToggle(p, "fullbrightEnabled", "Fullbright")
                createToggle(p, "thirdPersonEnabled","Third Person")
                createToggle(p, "spectateEnabled",   "Spectate")
            end)
        end,
    },
    {
        id = "skins", label = "Skins", icon = "✦",
        build = function()
            makeCard("Skin Changer", "✦", 1, function(p)
                createSectionHeader(p, "Client-side cosmetic override")
                createToggle(p, "skinEnabled", "Enable Skin Changer")
                createTextInput(p, "skinId", "Asset ID", "rbxassetid://...")
                createTextInput(p, "skinName", "Skin Name", "e.g. Neon Striker")
                createActionButton(p, "Apply", function()
                    showToast("Skin applied: " .. tostring(state.skinName))
                end)
                createActionButton(p, "Reset", function()
                    state.skinId = ""; state.skinName = "Default"
                    showToast("Skin reset to default.")
                end)
            end)

            makeCard("Skin Browser", "◉", 2, function(p)
                createSectionHeader(p, "Popular IDs")
                local skins = {
                    { "Neon Strike",   "7071857699"  },
                    { "Void Walker",   "9234512345"  },
                    { "Rose Gradient", "1123456789"  },
                    { "Arctic Camo",   "5678901234"  },
                    { "Galaxy",        "3456789012"  },
                }
                for _, sk in ipairs(skins) do
                    local rowH = create("Frame", {
                        Parent = p, Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1,
                    })
                    create("TextLabel", {
                        Parent = rowH, Position = UDim2.fromOffset(2, 0),
                        Size = UDim2.new(1, -80, 1, 0), BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham, Text = sk[1],
                        TextColor3 = Color3.fromRGB(218,230,239), TextTransparency = 0.10,
                        TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    local applyBtn = create("TextButton", {
                        Parent = rowH, AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(60, 22),
                        BackgroundColor3 = currentStyle().accent, BackgroundTransparency = 0.60,
                        BorderSizePixel = 0, AutoButtonColor = false,
                        Font = Enum.Font.GothamMedium, Text = "Apply",
                        TextColor3 = COLORS.Ink, TextSize = 10,
                    })
                    addCorner(applyBtn, 6)
                    local skName, skId = sk[1], sk[2]
                    applyBtn.Activated:Connect(function()
                        state.skinName = skName; state.skinId = skId; state.skinEnabled = true
                        showToast("Applied: " .. skName)
                    end)
                end
            end)
        end,
    },
    {
        id = "configs", label = "Configs", icon = "⊞",
        build = function()
            makeCard("Config Manager", "⊞", 1, function(p)
                createTextInput(p, "configName", "Config Name", "my-config")
                createActionButton(p, "Save", function()
                    showToast("Config saved: " .. tostring(state.configName))
                end)
                createActionButton(p, "Load", function()
                    showToast("Config loaded: " .. tostring(state.configName))
                end)
                createActionButton(p, "Delete", function()
                    showToast("Config deleted: " .. tostring(state.configName))
                end)
                createActionButton(p, "Export JSON", function()
                    showToast("Exported to clipboard.")
                end)
                createActionButton(p, "Reset All", function()
                    showToast("All settings reset to default.")
                end)
            end)

            makeCard("Config Slots", "≡", 2, function(p)
                createSectionHeader(p, "Quick-load slots")
                local slots = { "Slot 1", "Slot 2", "Slot 3", "Slot 4" }
                for _, sl in ipairs(slots) do
                    local rowH = create("Frame", {
                        Parent = p, Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1,
                    })
                    create("TextLabel", {
                        Parent = rowH, Position = UDim2.fromOffset(2, 0),
                        Size = UDim2.new(1, -80, 1, 0), BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham, Text = sl,
                        TextColor3 = Color3.fromRGB(218,230,239), TextTransparency = 0.10,
                        TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    local loadBtn = create("TextButton", {
                        Parent = rowH, AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(55, 22),
                        BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.90,
                        BorderSizePixel = 0, AutoButtonColor = false,
                        Font = Enum.Font.GothamMedium, Text = "Load",
                        TextColor3 = COLORS.InkDim, TextSize = 10,
                    })
                    addCorner(loadBtn, 6); addStroke(loadBtn, 0.84)
                    loadBtn.Activated:Connect(function()
                        showToast("Loaded " .. sl)
                    end)
                end
            end)
        end,
    },
    {
        id = "settings", label = "Settings", icon = "⚙",
        build = function()
            makeCard("Motion & Theme", "◈", 1, function(p)
                -- theme switcher (keep from nimbus)
                local themeRow = create("Frame", {
                    Parent = p, Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1,
                })
                create("TextLabel", {
                    Parent = themeRow, Position = UDim2.fromOffset(2, 0),
                    Size = UDim2.new(1, -180, 1, 0), BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham, Text = "Theme",
                    TextColor3 = Color3.fromRGB(218,230,239), TextTransparency = 0.10,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                })
                local themeWrap = create("Frame", {
                    Parent = themeRow, AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(166, 30),
                    BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.94, BorderSizePixel = 0,
                })
                addCorner(themeWrap, 9); addStroke(themeWrap, 0.84)
                local sel = create("Frame", {
                    Parent = themeWrap, Name = "AccentSelection",
                    Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(79, 24),
                    BackgroundColor3 = currentStyle().accent, BackgroundTransparency = 0.70, BorderSizePixel = 0,
                })
                addCorner(sel, 7)
                local function refreshTheme(instant)
                    local compact = state.theme == "compact"
                    local tp = compact and UDim2.fromOffset(84, 3) or UDim2.fromOffset(3, 3)
                    if instant then sel.Position = tp
                    else tween(sel, 0.30, { Position = tp }) end
                end
                local themeOpts = { { id="glass", label="Glass" }, { id="compact", label="Compact" } }
                for i, opt in ipairs(themeOpts) do
                    local ob = create("TextButton", {
                        Parent = themeWrap,
                        Position = UDim2.fromOffset((i-1)*81+3, 3), Size = UDim2.fromOffset(79, 24),
                        BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false,
                        Font = Enum.Font.GothamMedium, Text = opt.label,
                        TextColor3 = COLORS.InkDim, TextSize = 10,
                    })
                    ob.Activated:Connect(function()
                        if state.theme == opt.id then return end
                        state.theme = opt.id
                        refreshTheme(false)
                        showToast(opt.label .. " theme selected.")
                    end)
                end
                refreshTheme(true)

                createToggle(p, "animations", "Animations")
                createToggle(p, "snow", "Falling Dots (Compact)")
                createSlider(p, "dissolveSpeed", "Dissolve Speed", 50, 200, 10, "%")
            end)

            makeCard("Menu", "⚙", 2, function(p)
                createDropdown(p, "menuKey",  "Menu Toggle Key",  { "RightShift", "Insert", "F4", "Delete" })
                createToggle(p, "watermarkEnabled", "Show Watermark")
                createActionButton(p, "Reset Defaults", function()
                    showToast("Defaults restored.")
                end)
                createActionButton(p, "Unload", function()
                    showToast("Unloading AndoHub...")
                    task.delay(0.6, function()
                        if screenGui and screenGui.Parent then
                            screenGui:Destroy()
                        end
                        if blur and blur.Parent then
                            blur:Destroy()
                        end
                    end)
                end)
            end)
        end,
    },
}

-- ============================================================
--  NAV ENTRIES
-- ============================================================
local navEntries  = {}
local currentPage = "esp"
local transitionSerial = 0
local switchPage

for index, pageData in ipairs(PAGES) do
    local btn = create("TextButton", {
        Parent = navHolder, Name = "Nav_" .. pageData.id,
        Position = UDim2.fromOffset(0, (index - 1) * 44),
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = COLORS.White, BackgroundTransparency = 1,
        BorderSizePixel = 0, AutoButtonColor = false, Text = "",
    })
    addCorner(btn, 10)

    local iconLbl = create("TextLabel", {
        Parent = btn, Position = UDim2.fromOffset(11, 0), Size = UDim2.fromOffset(24, 40),
        BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = pageData.icon,
        TextColor3 = COLORS.InkDim, TextSize = 16,
    })
    local labelLbl = create("TextLabel", {
        Parent = btn, Position = UDim2.fromOffset(43, 0), Size = UDim2.new(1, -52, 1, 0),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = pageData.label,
        TextColor3 = COLORS.InkDim, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
    })

    local entry = { id = pageData.id, index = index, button = btn, icon = iconLbl, label = labelLbl }
    table.insert(navEntries, entry)

    btn.MouseEnter:Connect(function()
        if currentPage ~= pageData.id then
            tween(btn,      0.16, { BackgroundTransparency = 0.95 })
            tween(iconLbl,  0.16, { TextColor3 = COLORS.Ink })
            tween(labelLbl, 0.16, { TextColor3 = COLORS.Ink })
        end
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.16, { BackgroundTransparency = 1 })
        if currentPage ~= pageData.id then
            tween(iconLbl,  0.16, { TextColor3 = COLORS.InkDim })
            tween(labelLbl, 0.16, { TextColor3 = COLORS.InkDim })
        end
    end)
    btn.Activated:Connect(function() switchPage(pageData.id) end)
end

local function refreshNav(animate)
    local activeEntry = navEntries[1]
    for _, e in ipairs(navEntries) do
        local active = e.id == currentPage
        if active then activeEntry = e end
        local col = active and COLORS.Ink or COLORS.InkDim
        if animate then
            tween(e.icon,  motDur(0.22), { TextColor3 = col })
            tween(e.label, motDur(0.22), { TextColor3 = col })
        else
            e.icon.TextColor3 = col; e.label.TextColor3 = col
        end
    end
    local tp = activeEntry.button.Position
    local ts = activeEntry.button.Size
    if animate then
        tween(navPill, motDur(0.48), { Position = tp, Size = ts }, Enum.EasingStyle.Back)
    else
        navPill.Position = tp; navPill.Size = ts
    end
end

-- ============================================================
--  RENDER PAGE
-- ============================================================
local function findPage(id)
    for _, p in ipairs(PAGES) do
        if p.id == id then return p end
    end
    return PAGES[1]
end

local function renderPage(pageId)
    clearConns()
    for _, ch in ipairs(contentInner:GetChildren()) do
        if ch ~= grid then ch:Destroy() end
    end
    table.clear(currentCards)
    mainScroll.CanvasPosition = Vector2.zero
    findPage(pageId).build()
    task.defer(updateCanvas)
end

switchPage = function(pageId, force)
    if pageId == currentPage and not force then return end
    currentPage = pageId
    transitionSerial += 1
    local ser = transitionSerial
    refreshNav(true)

    if not animOn() or #currentCards == 0 then
        renderPage(currentPage)
        return
    end

    for i, ci in ipairs(currentCards) do
        local d = (i-1) * 0.025
        tween(ci.group, 0.16, { GroupTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, d)
        tween(ci.scale, 0.16, { Scale = 0.985 },         Enum.EasingStyle.Quad, Enum.EasingDirection.In, d)
    end

    local wait = 0.16 + math.max(0, #currentCards - 1) * 0.025
    task.delay(wait, function()
        if ser == transitionSerial then renderPage(currentPage) end
    end)
end

-- ============================================================
--  MINIMIZE / CLOSE / REOPEN
-- ============================================================
local minimized = false
local closed    = false
local positionBeforeClose = shell.Position
local visSerial = 0

local reopenGroup = create("CanvasGroup", {
    Parent = screenGui, Name = "Reopen",
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -22), Size = UDim2.fromOffset(200, 38),
    BackgroundColor3 = COLORS.Panel, BackgroundTransparency = 0.25,
    BorderSizePixel = 0, GroupTransparency = 1, Visible = false,
})
addCorner(reopenGroup, 19); addStroke(reopenGroup, 0.80)
local reopenButton = create("TextButton", {
    Parent = reopenGroup, Size = UDim2.fromScale(1,1),
    BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false,
    Font = Enum.Font.GothamMedium, Text = "Reopen  ·  Right Shift",
    TextColor3 = COLORS.Ink, TextSize = 10,
})

minimizeButton.Activated:Connect(function()
    if closed then return end
    minimized = not minimized
    if not minimized then body.Visible = true end
    minimizeButton.Text = minimized and "□" or "—"
    local targetSize = minimized and MIN_SIZE or FULL_SIZE
    local rt = tween(shell, motDur(0.34), { Size = targetSize })
    if minimized then
        rt.Completed:Once(function() if minimized then body.Visible = false end end)
    end
end)

local function closePanel()
    if closed then return end
    closed = true
    visSerial += 1
    local ser = visSerial
    shell.Active = false
    tween(sessionChip, 0.22, { GroupTransparency = 1 })
    tween(backdrop,    0.30, { BackgroundTransparency = 1 })
    tween(blur,        0.30, { Size = 0 })
    tween(shell, 0.32, {
        GroupTransparency = 1,
        Position = UDim2.new(positionBeforeClose.X.Scale, positionBeforeClose.X.Offset, positionBeforeClose.Y.Scale, positionBeforeClose.Y.Offset + 10),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    task.delay(0.34, function()
        if ser ~= visSerial or not closed then return end
        shell.Visible = false
        reopenGroup.Visible = true
        tween(reopenGroup, 0.26, { GroupTransparency = 0, Position = UDim2.new(0.5, 0, 1, -24) })
    end)
end

local function reopenPanel()
    if not closed then return end
    closed = false
    visSerial += 1
    local ser = visSerial
    local s = currentStyle()
    tween(reopenGroup, 0.18, { GroupTransparency = 1, Position = UDim2.new(0.5, 0, 1, -18) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    task.delay(0.19, function()
        if ser == visSerial then reopenGroup.Visible = false end
    end)
    shell.Visible = true
    shell.Active  = true
    shell.GroupTransparency = 1
    shell.Position = UDim2.new(positionBeforeClose.X.Scale, positionBeforeClose.X.Offset, positionBeforeClose.Y.Scale, positionBeforeClose.Y.Offset + 10)
    tween(shell,        0.42, { GroupTransparency = 0, Position = positionBeforeClose })
    tween(sessionChip,  0.28, { GroupTransparency = 0 })
    tween(backdrop,     0.34, { BackgroundTransparency = s.backdropTransparency })
    tween(blur,         0.40, { Size = s.blurSize })
end

closeButton.Activated:Connect(closePanel)
reopenButton.Activated:Connect(reopenPanel)
userCard.Activated:Connect(function() showToast("Local profile — no network connection.") end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift and UserInputService:GetFocusedTextBox() == nil then
        if closed then reopenPanel() else closePanel() end
    end
end)

reopenButton.MouseEnter:Connect(function() tween(reopenGroup, motDur(0.16), { BackgroundTransparency = 0.16 }) end)
reopenButton.MouseLeave:Connect(function() tween(reopenGroup, motDur(0.16), { BackgroundTransparency = 0.25 }) end)

-- ============================================================
--  DRAGGING
-- ============================================================
local dragging, dragInput, dragStart, shellStart = false, nil, Vector3.zero, shell.Position
titleBar.InputBegan:Connect(function(input)
    if closed then return end
    local lx = input.Position.X - titleBar.AbsolutePosition.X
    if lx > titleBar.AbsoluteSize.X - 104 then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; shellStart = shell.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local d = input.Position - dragStart
        shell.Position = UDim2.new(shellStart.X.Scale, shellStart.X.Offset + d.X, shellStart.Y.Scale, shellStart.Y.Offset + d.Y)
        positionBeforeClose = shell.Position
    end
end)

-- ============================================================
--  RESPONSIVE SCALE
-- ============================================================
local interfaceTargetScale = 1
local function updateScale()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local fitX = (vp.X - 28) / 1100
    local fitY = (vp.Y - 28) / 680
    interfaceTargetScale = math.max(0.42, math.clamp(math.min(fitX, fitY), 0.45, 1) * currentStyle().interfaceScale)
    responsiveScale.Scale = interfaceTargetScale
end

local viewConn
local function bindCamera()
    if viewConn then viewConn:Disconnect(); viewConn = nil end
    local cam = workspace.CurrentCamera
    if cam then
        viewConn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
    end
    updateScale()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
bindCamera()

screenGui.AncestryChanged:Connect(function(_, parent)
    if parent == nil then
        if viewConn then viewConn:Disconnect() end
        if blur and blur.Parent then blur:Destroy() end
    end
end)

-- ============================================================
--  SNOW (compact only)
-- ============================================================
local snowOverlay = create("Frame", {
    Parent = shell, Name = "CompactSnowField",
    Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
    BorderSizePixel = 0, ClipsDescendants = true, Visible = false, ZIndex = 90,
})
local snowRng = Random.new(4417)
for idx = 1, 72 do
    local sz  = snowRng:NextInteger(1, 4)
    local sx  = snowRng:NextNumber(0.01, 0.99)
    local sy  = snowRng:NextNumber(-0.25, 0.75)
    local dft = snowRng:NextNumber(-0.07, 0.07)
    local dur = snowRng:NextNumber(5.5, 11.5)
    local dot = create("Frame", {
        Parent = snowOverlay, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(sx, sy), Size = UDim2.fromOffset(sz, sz),
        BackgroundColor3 = COLORS.Pink,
        BackgroundTransparency = snowRng:NextNumber(0.58, 0.88),
        BorderSizePixel = 0, ZIndex = 91,
    })
    addCorner(dot, sz)
    TweenService:Create(dot, TweenInfo.new(dur, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1), {
        Position = UDim2.fromScale(sx + dft, sy + 1.25),
    }):Play()
end

-- ============================================================
--  INITIAL RENDER
-- ============================================================
refreshNav(false)
renderPage(currentPage)
updateScale()
