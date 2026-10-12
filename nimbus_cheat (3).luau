-- Ando Universal Cheat
-- Toggle: Right Shift

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
if not player then error("Run as LocalScript.") end
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local camera = Workspace.CurrentCamera

-- cleanup previous instance
local prev = playerGui:FindFirstChild("AndoCheat")
if prev then prev:Destroy() end
local prevBlur = Lighting:FindFirstChild("AndoCheatBlur")
if prevBlur then prevBlur:Destroy() end

-- ─────────────────────────────────────────────
-- CHEAT STATE
-- ─────────────────────────────────────────────
local CHEAT = {
    espEnabled      = false,
    espBoxes        = true,
    espNames        = true,
    espHealth       = true,
    espDistance     = true,
    espTeamCheck    = true,

    aimbotEnabled   = false,
    aimbotKey       = Enum.KeyCode.RightAlt,
    aimbotFov       = 120,
    aimbotSmooth    = 8,
    aimbotBone      = "Head",
    aimbotVisCheck  = true,

    triggerbotEnabled = false,
    triggerbotDelay   = 80,  -- ms
    triggerbotTeamCheck = true,

    noclipEnabled   = false,
    infiniteJump    = false,
    walkSpeed       = 16,
    jumpHeight      = 7.2,
    flyEnabled      = false,
    flySpeed        = 40,

    espHighlightMode = false, -- highlight instead of box
}

-- ─────────────────────────────────────────────
-- COLORS / HELPERS
-- ─────────────────────────────────────────────
local COLORS = {
    Ink         = Color3.fromRGB(238, 244, 249),
    InkDim      = Color3.fromRGB(190, 202, 212),
    InkFaint    = Color3.fromRGB(139, 154, 166),
    Panel       = Color3.fromRGB(15, 23, 31),
    PanelTop    = Color3.fromRGB(26, 38, 49),
    PanelBottom = Color3.fromRGB(11, 18, 24),
    White       = Color3.fromRGB(255, 255, 255),
    Accent      = Color3.fromRGB(148, 208, 255),
    AccentBright= Color3.fromRGB(232, 247, 255),
    Shadow      = Color3.fromRGB(0, 0, 0),
    -- compact accent
    Pink        = Color3.fromRGB(255, 126, 136),
    PinkBright  = Color3.fromRGB(255, 232, 234),
}

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

local function addStroke(obj, transparency, color)
    return create("UIStroke", {
        Parent = obj,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = color or COLORS.White,
        Transparency = transparency,
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

-- ─────────────────────────────────────────────
-- THEME
-- ─────────────────────────────────────────────
local themeState = "glass" -- "glass" | "compact"

local THEME_STYLES = {
    glass = {
        interfaceScale  = 1,
        accent          = COLORS.Accent,
        knobColor       = COLORS.AccentBright,
        panelColor      = COLORS.Panel,
        railColor       = COLORS.White,
        cardColor       = COLORS.White,
        edgeColor       = COLORS.White,
        panelTransparency = 0.32,
        railTransparency  = 0.965,
        cardTransparency  = 0.93,
        cardHoverTransparency = 0.90,
        cardStrokeTransparency = 0.84,
        cardHoverStrokeTransparency = 0.76,
        userTransparency = 0.94,
        sessionTransparency = 0.35,
        pillTransparency = 0.90,
        backdropTransparency = 0.72,
        blurSize = 14,
        panelCornerRadius = 18,
        scrollBarColor = COLORS.White,
        scrollBarTransparency = 0.72,
    },
    compact = {
        interfaceScale  = 0.92,
        accent          = COLORS.Pink,
        knobColor       = COLORS.PinkBright,
        panelColor      = Color3.fromRGB(8, 7, 9),
        railColor       = Color3.fromRGB(10, 7, 9),
        cardColor       = Color3.fromRGB(27, 14, 17),
        edgeColor       = COLORS.Pink,
        panelTransparency = 0.08,
        railTransparency  = 0.22,
        cardTransparency  = 0.22,
        cardHoverTransparency = 0.14,
        cardStrokeTransparency = 0.70,
        cardHoverStrokeTransparency = 0.58,
        userTransparency = 0.72,
        sessionTransparency = 0.16,
        pillTransparency = 0.76,
        backdropTransparency = 0.84,
        blurSize = 4,
        panelCornerRadius = 5,
        scrollBarColor = COLORS.Pink,
        scrollBarTransparency = 0.60,
    },
}

local function style()
    return THEME_STYLES[themeState]
end

local animationsOn = true
local function motionDur(d) return animationsOn and d or 0.01 end

-- ─────────────────────────────────────────────
-- BLUR + SCREEN GUI
-- ─────────────────────────────────────────────
local blur = create("BlurEffect", {
    Parent = Lighting, Name = "AndoCheatBlur", Size = 0,
})
tween(blur, 0.45, { Size = 14 })

local screenGui = create("ScreenGui", {
    Parent = playerGui, Name = "AndoCheat",
    IgnoreGuiInset = true, ResetOnSpawn = false,
    DisplayOrder = 40, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

-- backdrop tint
local backdrop = create("Frame", {
    Parent = screenGui, Name = "BackdropTint",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(11, 20, 27),
    BackgroundTransparency = 0.72, BorderSizePixel = 0,
})
create("UIGradient", {
    Parent = backdrop, Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 74, 103)),
        ColorSequenceKeypoint.new(0.48, Color3.fromRGB(21, 43, 49)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 21, 18)),
    }),
})

-- ─────────────────────────────────────────────
-- SHELL (draggable window)
-- ─────────────────────────────────────────────
local shell = create("CanvasGroup", {
    Parent = screenGui, Name = "WindowShell",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(900, 600),
    BackgroundTransparency = 1, BorderSizePixel = 0,
})

local responsiveScale = create("UIScale", { Parent = shell, Scale = 1 })

local shadow = create("Frame", {
    Parent = shell, Name = "Shadow",
    Position = UDim2.fromOffset(0, 18),
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLORS.Shadow,
    BackgroundTransparency = 0.56, BorderSizePixel = 0,
})
addCorner(shadow, 22)

-- main panel — corner radius updated on theme change
local panel = create("Frame", {
    Parent = shell, Name = "GlassWindow",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLORS.Panel,
    BackgroundTransparency = 0.32,
    BorderSizePixel = 0, ClipsDescendants = true,
})
local panelCorner = addCorner(panel, 18)
local panelStroke = addStroke(panel, 0.78)
local panelGradient = create("UIGradient", {
    Parent = panel, Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.PanelTop),
        ColorSequenceKeypoint.new(1, COLORS.PanelBottom),
    }),
})

-- top highlight line — sits just below the corner so it looks flush
create("Frame", {
    Parent = panel, Name = "TopHighlight",
    Position = UDim2.fromOffset(18, 1),
    Size = UDim2.new(1, -36, 0, 1),
    BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.74, BorderSizePixel = 0,
})

-- ─────────────────────────────────────────────
-- TITLE BAR  (single unified block, no double-round gap)
-- ─────────────────────────────────────────────
-- The original had panel (rounded) → titleBar CanvasGroup → two TextLabels stacked.
-- Because ClipsDescendants was on the panel, the titleBar's top was squared off
-- producing the "second rounded strip" look. Fix: no CanvasGroup wrapper,
-- just children directly on the panel so the panel's corner clips them cleanly.

local titleBar = create("Frame", {
    Parent = panel, Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 60),
    BackgroundTransparency = 1, Active = true,
})

create("TextLabel", {
    Parent = titleBar,
    Position = UDim2.fromOffset(24, 12),
    Size = UDim2.fromOffset(300, 24),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "Ando",
    TextColor3 = COLORS.Ink, TextSize = 19,
    TextXAlignment = Enum.TextXAlignment.Left,
})
create("TextLabel", {
    Parent = titleBar,
    Position = UDim2.fromOffset(24, 36),
    Size = UDim2.fromOffset(400, 14),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "ando · " .. player.Name,
    TextColor3 = COLORS.InkFaint, TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
})

-- thin separator below title
create("Frame", {
    Parent = panel, Name = "TitleSep",
    Position = UDim2.fromOffset(0, 60),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.92, BorderSizePixel = 0,
})

-- window buttons
local function makeWinBtn(text, xOffset)
    local btn = create("TextButton", {
        Parent = titleBar,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, xOffset, 0, 16),
        Size = UDim2.fromOffset(34, 28),
        BackgroundColor3 = COLORS.White,
        BackgroundTransparency = 1,
        BorderSizePixel = 0, AutoButtonColor = false,
        Font = Enum.Font.GothamMedium,
        Text = text, TextColor3 = COLORS.InkDim, TextSize = 16,
    })
    addCorner(btn, 8)
    local s = addStroke(btn, 1)
    btn.MouseEnter:Connect(function()
        tween(btn, 0.16, { BackgroundTransparency = 0.90, TextColor3 = COLORS.Ink })
        tween(s, 0.16, { Transparency = 0.86 })
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.16, { BackgroundTransparency = 1, TextColor3 = COLORS.InkDim })
        tween(s, 0.16, { Transparency = 1 })
    end)
    return btn
end

local minimizeBtn = makeWinBtn("—", -58)
local closeBtn    = makeWinBtn("×", -18)

-- ─────────────────────────────────────────────
-- BODY
-- ─────────────────────────────────────────────
local body = create("Frame", {
    Parent = panel, Name = "Body",
    Position = UDim2.fromOffset(0, 61),
    Size = UDim2.new(1, 0, 1, -61),
    BackgroundTransparency = 1, ClipsDescendants = true,
})

-- RAIL — single nav entry "Settings" but kept for visual consistency
local rail = create("CanvasGroup", {
    Parent = body, Name = "Rail",
    Size = UDim2.new(0, 200, 1, 0),
    BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.965,
    BorderSizePixel = 0, ClipsDescendants = true,
})
create("Frame", { -- right border line
    Parent = rail,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    Size = UDim2.new(0, 1, 1, 0),
    BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.92, BorderSizePixel = 0,
})

-- nav tabs
local PAGES = {
    { id = "player",   label = "Player",   icon = "⚡" },
    { id = "combat",   label = "Combat",   icon = "◎" },
    { id = "visual",   label = "Visual",   icon = "◈" },
    { id = "settings", label = "Settings", icon = "⚙" },
}

local navHolder = create("Frame", {
    Parent = rail,
    Position = UDim2.fromOffset(14, 10),
    Size = UDim2.new(1, -28, 0, #PAGES * 44),
    BackgroundTransparency = 1,
})

local navPill = create("Frame", {
    Parent = navHolder, Name = "ActivePill",
    Position = UDim2.fromOffset(0, 0),
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.90, BorderSizePixel = 0,
})
local navPillCorner = addCorner(navPill, 10)
local navPillStroke = addStroke(navPill, 0.84)

-- user card (bottom of rail)
local userCard = create("CanvasGroup", {
    Parent = rail, Name = "UserCard",
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 14, 1, -14),
    Size = UDim2.new(1, -28, 0, 46),
    BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.94, BorderSizePixel = 0,
})
addCorner(userCard, 12)
addStroke(userCard, 0.90)

local avatarFrame = create("Frame", {
    Parent = userCard,
    Position = UDim2.fromOffset(11, 8),
    Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.87, BorderSizePixel = 0,
})
addCorner(avatarFrame, 15)
addStroke(avatarFrame, 0.86)
create("TextLabel", {
    Parent = avatarFrame, Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
    Text = string.upper(string.sub(player.Name, 1, 1)),
    TextColor3 = COLORS.InkDim, TextSize = 11,
})
create("TextLabel", {
    Parent = userCard,
    Position = UDim2.fromOffset(50, 6),
    Size = UDim2.new(1, -62, 0, 18),
    BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
    Text = player.Name, TextColor3 = COLORS.Ink, TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
})
create("TextLabel", {
    Parent = userCard,
    Position = UDim2.fromOffset(50, 24),
    Size = UDim2.new(1, -62, 0, 14),
    BackgroundTransparency = 1, Font = Enum.Font.Gotham,
    Text = "ando cheat", TextColor3 = COLORS.InkFaint, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
})

-- ─────────────────────────────────────────────
-- SCROLL AREA
-- ─────────────────────────────────────────────
local mainScroll = create("ScrollingFrame", {
    Parent = body, Name = "Content",
    Position = UDim2.fromOffset(200, 0),
    Size = UDim2.new(1, -200, 1, 0),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    CanvasSize = UDim2.fromOffset(0, 0),
    ScrollBarThickness = 5,
    ScrollBarImageColor3 = COLORS.Accent,
    ScrollBarImageTransparency = 0.72,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ScrollingEnabled = true,
})

-- Glass-styled scrollbar overlay (decorative bar on right side matching theme)
local scrollTrack = create("Frame", {
    Parent = mainScroll,
    Name = "ScrollTrack",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -2, 0, 4),
    Size = UDim2.new(0, 5, 1, -8),
    BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.92, BorderSizePixel = 0,
    ZIndex = 5,
})
addCorner(scrollTrack, 3)

local contentInner = create("Frame", {
    Parent = mainScroll, Name = "CardGrid",
    Position = UDim2.fromOffset(16, 14),
    Size = UDim2.new(1, -32, 0, 0),
    BackgroundTransparency = 1,
})

local listLayout = create("UIListLayout", {
    Parent = contentInner,
    Padding = UDim.new(0, 12),
    FillDirection = Enum.FillDirection.Vertical,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Top,
})

local function updateCanvas()
    local h = listLayout.AbsoluteContentSize.Y
    contentInner.Size = UDim2.new(1, -32, 0, h)
    mainScroll.CanvasSize = UDim2.fromOffset(0, h + 28)
end
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

-- ─────────────────────────────────────────────
-- TOAST
-- ─────────────────────────────────────────────
local toastGroup = create("CanvasGroup", {
    Parent = screenGui, Name = "Toast",
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -20),
    Size = UDim2.fromOffset(320, 38),
    BackgroundColor3 = COLORS.Panel,
    BackgroundTransparency = 0.28, BorderSizePixel = 0,
    GroupTransparency = 1, Visible = false,
})
addCorner(toastGroup, 12)
addStroke(toastGroup, 0.82)
local toastLabel = create("TextLabel", {
    Parent = toastGroup,
    Size = UDim2.new(1, -24, 1, 0),
    Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1, Font = Enum.Font.Gotham,
    Text = "", TextColor3 = COLORS.InkDim, TextSize = 11,
})

local toastSerial = 0
local function showToast(msg)
    toastSerial += 1
    local s = toastSerial
    toastLabel.Text = msg
    toastGroup.Visible = true
    toastGroup.GroupTransparency = 1
    toastGroup.Position = UDim2.new(0.5, 0, 1, -14)
    tween(toastGroup, 0.25, { GroupTransparency = 0, Position = UDim2.new(0.5, 0, 1, -26) })
    task.delay(2.2, function()
        if s ~= toastSerial then return end
        local f = tween(toastGroup, 0.22, { GroupTransparency = 1, Position = UDim2.new(0.5, 0, 1, -18) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        f.Completed:Once(function()
            if s == toastSerial then toastGroup.Visible = false end
        end)
    end)
end

-- ─────────────────────────────────────────────
-- CARD / ROW BUILDERS
-- ─────────────────────────────────────────────
local trackedCards = {}

local function makeCard(title, icon, layoutOrder)
    local s = style()
    local card = create("CanvasGroup", {
        Parent = contentInner,
        Name = "Card_" .. title:gsub("%W", ""),
        LayoutOrder = layoutOrder or 0,
        BackgroundColor3 = s.cardColor,
        BackgroundTransparency = s.cardTransparency,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38), -- grows below via rowHolder callback
    })
    local cardCorner = addCorner(card, 14)
    local cardStroke = addStroke(card, s.cardStrokeTransparency, s.edgeColor)
    create("UIGradient", {
        Parent = card, Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(188, 208, 220)),
        }),
    })

    create("TextLabel", {
        Parent = card,
        Position = UDim2.fromOffset(44, 10),
        Size = UDim2.new(1, -60, 0, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = title, TextColor3 = COLORS.Ink,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    })
    local iconLabel = create("TextLabel", {
        Parent = card,
        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.fromOffset(22, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = icon, TextColor3 = s.accent,
        TextSize = 15, Name = "Icon",
    })

    local rowHolder = create("Frame", {
        Parent = card, Name = "Rows",
        Position = UDim2.fromOffset(0, 38),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
    })
    local rowList = create("UIListLayout", {
        Parent = rowHolder,
        Padding = UDim.new(0, 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    -- resize card when rows change
    rowList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local rowH = rowList.AbsoluteContentSize.Y + 8 -- 8px bottom pad
        rowHolder.Size = UDim2.new(1, 0, 0, rowH)
        card.Size = UDim2.new(1, 0, 0, 38 + rowH)
    end)

    local cardScale = create("UIScale", { Parent = card, Scale = 1 })

    card.MouseEnter:Connect(function()
        local cs = style()
        tween(cardScale, 0.28, { Scale = 1.012 })
        tween(card, 0.28, { BackgroundTransparency = cs.cardHoverTransparency })
        tween(cardStroke, 0.28, { Transparency = cs.cardHoverStrokeTransparency })
    end)
    card.MouseLeave:Connect(function()
        local cs = style()
        tween(cardScale, 0.28, { Scale = 1 })
        tween(card, 0.28, { BackgroundTransparency = cs.cardTransparency })
        tween(cardStroke, 0.28, { Transparency = cs.cardStrokeTransparency })
    end)

    local entry = {
        group = card, corner = cardCorner,
        stroke = cardStroke, icon = iconLabel,
        scale = cardScale, rowHolder = rowHolder,
    }
    table.insert(trackedCards, entry)
    return rowHolder, entry
end

local function addSeparator(parent, index)
    if index > 1 then
        create("Frame", {
            Parent = parent, LayoutOrder = index,
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = COLORS.White,
            BackgroundTransparency = 0.93, BorderSizePixel = 0,
        })
    end
end

-- TOGGLE ROW
local function makeToggleRow(parent, label, cheatKey, index, onToggle)
    addSeparator(parent, index * 2 - 1)
    local row = create("Frame", {
        Parent = parent, Name = "Row_" .. cheatKey,
        LayoutOrder = index * 2,
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
    })
    create("TextLabel", {
        Parent = row,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -80, 1, 0),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham,
        Text = label, TextColor3 = Color3.fromRGB(218, 230, 239),
        TextTransparency = 0.10, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local s = style()
    local toggle = create("TextButton", {
        Parent = row,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(44, 24),
        BackgroundColor3 = COLORS.White,
        BackgroundTransparency = 0.86, BorderSizePixel = 0,
        AutoButtonColor = false, Text = "",
    })
    addCorner(toggle, 12)
    local tStroke = addStroke(toggle, 0.86)

    local knob = create("Frame", {
        Parent = toggle, Name = "Knob",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.fromOffset(17, 17),
        BackgroundColor3 = Color3.fromRGB(236, 243, 249),
        BackgroundTransparency = 0.05, BorderSizePixel = 0,
    })
    addCorner(knob, 9)
    addStroke(knob, 0.80)

    local function refreshToggle(instant)
        local enabled = CHEAT[cheatKey]
        local cs = style()
        local pos  = enabled and UDim2.fromOffset(32, 12) or UDim2.fromOffset(12, 12)
        local col  = enabled and cs.accent or COLORS.White
        local trans = enabled and 0.67 or 0.86
        local strokeT = enabled and 0.55 or 0.86
        if instant then
            toggle.BackgroundColor3 = col
            toggle.BackgroundTransparency = trans
            tStroke.Transparency = strokeT
            knob.Position = pos
            knob.BackgroundColor3 = enabled and cs.knobColor or Color3.fromRGB(236, 243, 249)
        else
            tween(toggle, motionDur(0.22), { BackgroundColor3 = col, BackgroundTransparency = trans })
            tween(tStroke, motionDur(0.22), { Transparency = strokeT })
            tween(knob, motionDur(0.24), { Position = pos,
                BackgroundColor3 = enabled and cs.knobColor or Color3.fromRGB(236, 243, 249) },
                Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end

    toggle.Activated:Connect(function()
        CHEAT[cheatKey] = not CHEAT[cheatKey]
        refreshToggle(false)
        if onToggle then onToggle(CHEAT[cheatKey]) end
    end)

    refreshToggle(true)
    return refreshToggle
end

-- SLIDER ROW
local function makeSliderRow(parent, label, cheatKey, min, max, step, unit, index, onChange)
    addSeparator(parent, index * 2 - 1)
    local row = create("Frame", {
        Parent = parent, Name = "Row_" .. cheatKey,
        LayoutOrder = index * 2,
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
    })
    create("TextLabel", {
        Parent = row,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(0.38, 0, 1, 0),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham,
        Text = label, TextColor3 = Color3.fromRGB(218, 230, 239),
        TextTransparency = 0.10, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    local wrap = create("Frame", {
        Parent = row,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(200, 30),
        BackgroundTransparency = 1,
    })

    local track = create("Frame", {
        Parent = wrap,
        Position = UDim2.fromOffset(2, 13),
        Size = UDim2.fromOffset(140, 4),
        BackgroundColor3 = COLORS.White,
        BackgroundTransparency = 0.84, BorderSizePixel = 0,
    })
    addCorner(track, 2)

    local fill = create("Frame", {
        Parent = track, Name = "AccentFill",
        Size = UDim2.fromScale(0.5, 1),
        BackgroundColor3 = style().accent,
        BackgroundTransparency = 0.12, BorderSizePixel = 0,
    })
    addCorner(fill, 2)

    local knob = create("Frame", {
        Parent = track, Name = "AccentKnob",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(15, 15),
        BackgroundColor3 = style().knobColor,
        BackgroundTransparency = 0, BorderSizePixel = 0,
    })
    addCorner(knob, 8)
    addStroke(knob, 0.58)

    local output = create("TextLabel", {
        Parent = wrap,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(54, 30),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham,
        Text = "", TextColor3 = COLORS.InkDim,
        TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right,
    })

    local hitArea = create("TextButton", {
        Parent = wrap,
        Position = UDim2.fromOffset(-4, 1),
        Size = UDim2.fromOffset(152, 28),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        AutoButtonColor = false, Text = "",
    })

    local function refreshSlider()
        local v = CHEAT[cheatKey]
        local alpha = math.clamp((v - min) / (max - min), 0, 1)
        fill.Size = UDim2.fromScale(alpha, 1)
        knob.Position = UDim2.fromScale(alpha, 0.5)
        local dispVal = math.abs(v - math.floor(v)) < 0.0001 and tostring(math.floor(v)) or string.format("%.1f", v)
        output.Text = dispVal .. (unit or "")
    end

    local function setFromX(screenX)
        local w = math.max(track.AbsoluteSize.X, 1)
        local alpha = math.clamp((screenX - track.AbsolutePosition.X) / w, 0, 1)
        local raw = min + (max - min) * alpha
        local steps = math.floor(((raw - min) / step) + 0.5)
        CHEAT[cheatKey] = math.clamp(min + steps * step, min, max)
        refreshSlider()
        if onChange then onChange(CHEAT[cheatKey]) end
    end

    local dragging = false
    local dInput = nil

    hitArea.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dInput = inp
            setFromX(inp.Position.X)
            tween(knob, 0.12, { Size = UDim2.fromOffset(18, 18) })
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp == dInput then
            setFromX(inp.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if not dragging then return end
        if inp == dInput or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            dInput = nil
            tween(knob, 0.14, { Size = UDim2.fromOffset(15, 15) })
        end
    end)

    refreshSlider()
end

-- THEME SELECTOR ROW (glass / compact)
local function makeThemeRow(parent, index)
    addSeparator(parent, index * 2 - 1)
    local row = create("Frame", {
        Parent = parent, Name = "Row_theme",
        LayoutOrder = index * 2,
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
    })
    create("TextLabel", {
        Parent = row,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(0.38, 0, 1, 0),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham,
        Text = "Theme", TextColor3 = Color3.fromRGB(218, 230, 239),
        TextTransparency = 0.10, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local wrap = create("Frame", {
        Parent = row,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(166, 30),
        BackgroundColor3 = COLORS.White,
        BackgroundTransparency = 0.94, BorderSizePixel = 0,
    })
    addCorner(wrap, 9)
    addStroke(wrap, 0.84)

    local selection = create("Frame", {
        Parent = wrap, Name = "AccentSelection",
        Position = UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(79, 24),
        BackgroundColor3 = style().accent,
        BackgroundTransparency = 0.70, BorderSizePixel = 0,
    })
    addCorner(selection, 7)
    local selStroke = addStroke(selection, 0.70, style().accent)
    selStroke.Name = "AccentStroke"

    local opts = { { id = "glass", label = "Glass" }, { id = "compact", label = "Compact" } }

    local function refreshThemeSel(instant)
        local isCompact = themeState == "compact"
        local pos = isCompact and UDim2.fromOffset(84, 3) or UDim2.fromOffset(3, 3)
        if instant or not animationsOn then
            selection.Position = pos
        else
            tween(selection, 0.30, { Position = pos })
        end
    end

    for i, opt in ipairs(opts) do
        local ob = create("TextButton", {
            Parent = wrap,
            Position = UDim2.fromOffset((i - 1) * 81 + 3, 3),
            Size = UDim2.fromOffset(79, 24),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            AutoButtonColor = false, Font = Enum.Font.GothamMedium,
            Text = opt.label, TextColor3 = COLORS.InkDim, TextSize = 10,
        })
        ob.Activated:Connect(function()
            if themeState == opt.id then return end
            themeState = opt.id
            refreshThemeSel(false)
            applyTheme(true)
            showToast(opt.label .. " theme selected.")
        end)
    end

    refreshThemeSel(true)
end

-- ─────────────────────────────────────────────
-- BUILD PAGES
-- ─────────────────────────────────────────────
local toggleRefreshers = {}
local currentPage = "player"
local navEntries   = {}

local function clearCards()
    for _, child in ipairs(contentInner:GetChildren()) do
        if child ~= listLayout and child:IsA("GuiObject") then child:Destroy() end
    end
    table.clear(trackedCards)
end

-- forward declarations
local applyTheme
local renderPage

-- render pages
local PAGE_DEFS = {
    player = function()
        local rows, _ = makeCard("Movement", "⚡", 1)
        makeToggleRow(rows, "No-Clip", "noclipEnabled", 1, function(v)
            showToast(v and "NoClip ON" or "NoClip OFF")
        end)
        makeToggleRow(rows, "Infinite Jump", "infiniteJump", 2)
        makeToggleRow(rows, "Fly", "flyEnabled", 3, function(v)
            showToast(v and "Fly ON" or "Fly OFF")
        end)
        makeSliderRow(rows, "Walk Speed", "walkSpeed", 4, 200, 1, "", 4, function(v)
            local hr = character:FindFirstChild("Humanoid")
            if hr then hr.WalkSpeed = v end
        end)
        makeSliderRow(rows, "Jump Height", "jumpHeight", 1, 50, 0.5, "", 5, function(v)
            local hr = character:FindFirstChild("Humanoid")
            if hr then hr.JumpHeight = v end
        end)
        makeSliderRow(rows, "Fly Speed", "flySpeed", 5, 500, 5, "", 6)
    end,
    combat = function()
        local rows, _ = makeCard("Aimbot", "◎", 1)
        makeToggleRow(rows, "Aimbot", "aimbotEnabled", 1)
        makeToggleRow(rows, "Visibility Check", "aimbotVisCheck", 2)
        makeToggleRow(rows, "Team Check", "espTeamCheck", 3)
        makeSliderRow(rows, "FOV", "aimbotFov", 10, 360, 5, "°", 4)
        makeSliderRow(rows, "Smoothing", "aimbotSmooth", 1, 30, 1, "", 5)

        local rows2, _ = makeCard("Triggerbot", "◉", 2)
        makeToggleRow(rows2, "Triggerbot", "triggerbotEnabled", 1)
        makeToggleRow(rows2, "Team Check", "triggerbotTeamCheck", 2)
        makeSliderRow(rows2, "Delay (ms)", "triggerbotDelay", 0, 500, 10, "ms", 3)
    end,
    visual = function()
        local rows, _ = makeCard("ESP", "◈", 1)
        makeToggleRow(rows, "ESP", "espEnabled", 1, function(v)
            showToast(v and "ESP ON" or "ESP OFF")
        end)
        makeToggleRow(rows, "Boxes", "espBoxes", 2)
        makeToggleRow(rows, "Names", "espNames", 3)
        makeToggleRow(rows, "Health", "espHealth", 4)
        makeToggleRow(rows, "Distance", "espDistance", 5)
        makeToggleRow(rows, "Team Check", "espTeamCheck", 6)
        makeToggleRow(rows, "Highlight Mode", "espHighlightMode", 7)
    end,
    settings = function()
        local rows, _ = makeCard("Appearance", "◈", 1)
        makeThemeRow(rows, 1)
        makeToggleRow(rows, "Animations", "animationsOn_placeholder", 2, function(v)
            animationsOn = v
        end)
    end,
}

-- init animationsOn toggle state in CHEAT so makeToggleRow can read it
CHEAT.animationsOn_placeholder = true

renderPage = function(pageId)
    clearCards()
    local def = PAGE_DEFS[pageId]
    if def then def() end
    task.defer(updateCanvas)
end

-- ─────────────────────────────────────────────
-- NAV WIRING
-- ─────────────────────────────────────────────
local switchPage

for i, pg in ipairs(PAGES) do
    local btn = create("TextButton", {
        Parent = navHolder, Name = "Nav_" .. pg.id,
        Position = UDim2.fromOffset(0, (i - 1) * 44),
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        AutoButtonColor = false, Text = "",
    })
    addCorner(btn, 10)

    local iconLbl = create("TextLabel", {
        Parent = btn,
        Position = UDim2.fromOffset(11, 0),
        Size = UDim2.fromOffset(24, 40),
        BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
        Text = pg.icon, TextColor3 = COLORS.InkDim, TextSize = 15,
    })
    local lbl = create("TextLabel", {
        Parent = btn,
        Position = UDim2.fromOffset(42, 0),
        Size = UDim2.new(1, -52, 1, 0),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham,
        Text = pg.label, TextColor3 = COLORS.InkDim,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
    })

    table.insert(navEntries, { id = pg.id, index = i, button = btn, icon = iconLbl, label = lbl })

    btn.MouseEnter:Connect(function()
        if currentPage ~= pg.id then
            tween(btn, 0.16, { BackgroundTransparency = 0.95 })
            tween(iconLbl, 0.16, { TextColor3 = COLORS.Ink })
            tween(lbl, 0.16, { TextColor3 = COLORS.Ink })
        end
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.16, { BackgroundTransparency = 1 })
        if currentPage ~= pg.id then
            tween(iconLbl, 0.16, { TextColor3 = COLORS.InkDim })
            tween(lbl, 0.16, { TextColor3 = COLORS.InkDim })
        end
    end)
    btn.Activated:Connect(function()
        switchPage(pg.id)
    end)
end

local function refreshNav(animate)
    for _, e in ipairs(navEntries) do
        local active = e.id == currentPage
        local col = active and COLORS.Ink or COLORS.InkDim
        if animate then
            tween(e.icon, 0.22, { TextColor3 = col })
            tween(e.label, 0.22, { TextColor3 = col })
        else
            e.icon.TextColor3 = col
            e.label.TextColor3 = col
        end
    end
    for _, e in ipairs(navEntries) do
        if e.id == currentPage then
            if animate then
                tween(navPill, 0.48, { Position = e.button.Position, Size = e.button.Size }, Enum.EasingStyle.Back)
            else
                navPill.Position = e.button.Position
                navPill.Size = e.button.Size
            end
            break
        end
    end
end

switchPage = function(pageId)
    if pageId == currentPage then return end
    currentPage = pageId
    refreshNav(true)
    renderPage(pageId)
    mainScroll.CanvasPosition = Vector2.zero
end

-- ─────────────────────────────────────────────
-- APPLY THEME
-- ─────────────────────────────────────────────
local applyingTheme = false
applyTheme = function(animate)
    if applyingTheme then return end
    applyingTheme = true
    local s = style()
    local dur = animate and animationsOn and 0.34 or 0

    local function set(obj, goals)
        if dur > 0 then tween(obj, dur, goals)
        else for k, v in pairs(goals) do obj[k] = v end end
    end

    set(panel, { BackgroundColor3 = s.panelColor, BackgroundTransparency = s.panelTransparency })
    set(panelStroke, { Color = s.edgeColor, Transparency = themeState == "compact" and 0.72 or 0.78 })
    set(rail, { BackgroundColor3 = s.railColor, BackgroundTransparency = s.railTransparency })
    set(navPill, { BackgroundColor3 = s.accent, BackgroundTransparency = s.pillTransparency })
    set(navPillStroke, { Color = s.edgeColor })
    set(shadow, { BackgroundTransparency = themeState == "compact" and 0.66 or 0.56 })
    set(mainScroll, { ScrollBarImageColor3 = s.scrollBarColor, ScrollBarImageTransparency = s.scrollBarTransparency })

    panelCorner.CornerRadius = UDim.new(0, s.panelCornerRadius)
    navPillCorner.CornerRadius = UDim.new(0, themeState == "compact" and 3 or 10)

    panelGradient.Color = themeState == "compact" and ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 10, 12)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 5, 7)),
    }) or ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.PanelTop),
        ColorSequenceKeypoint.new(1, COLORS.PanelBottom),
    })

    -- scrolltrack color
    set(scrollTrack, {
        BackgroundColor3 = s.scrollBarColor,
        BackgroundTransparency = themeState == "compact" and 0.82 or 0.92,
    })

    for _, c in ipairs(trackedCards) do
        set(c.group, { BackgroundColor3 = s.cardColor, BackgroundTransparency = s.cardTransparency })
        set(c.stroke, { Color = s.edgeColor, Transparency = s.cardStrokeTransparency })
        set(c.icon, { TextColor3 = s.accent })
        c.corner.CornerRadius = UDim.new(0, themeState == "compact" and 3 or 14)
    end

    -- re-color all accent fills/knobs/strokes + active toggle backgrounds
    for _, d in ipairs(contentInner:GetDescendants()) do
        if d.Name == "AccentFill" or d.Name == "AccentSelection" then
            set(d, { BackgroundColor3 = s.accent })
        elseif d.Name == "AccentKnob" then
            set(d, { BackgroundColor3 = s.knobColor })
        elseif d.Name == "AccentStroke" and d:IsA("UIStroke") then
            set(d, { Color = s.accent })
        end
        local toggleKey = d:GetAttribute("NimbusToggleKey")
        if toggleKey then
            local enabled = CHEAT[toggleKey] == true
            set(d, { BackgroundColor3 = enabled and s.accent or COLORS.White })
            local knob = d:FindFirstChild("Knob")
            if knob then
                set(knob, { BackgroundColor3 = enabled and s.knobColor or Color3.fromRGB(236, 243, 249) })
            end
        end
    end

    if not closed then
        set(backdrop, { BackgroundTransparency = s.backdropTransparency })
        set(blur, { Size = s.blurSize })
    end

    refreshNav(false)
    -- re-render so new card instances pick up fresh theme colors
    if renderPage then
        renderPage(currentPage)
    end
    applyingTheme = false
end

-- ─────────────────────────────────────────────
-- CLOSE / REOPEN
-- ─────────────────────────────────────────────
local closed = false
local visTransitioning = false
local visSerial = 0
local posBeforeClose = shell.Position
local FULL_SIZE = UDim2.fromOffset(900, 600)
local MIN_SIZE  = UDim2.fromOffset(900, 61)

-- no reopen popup; RightShift toggles silently

local function showReopen() end
local function hideReopen() end

local function closePanel()
    if closed or visTransitioning then return end
    closed = true
    visTransitioning = animationsOn
    visSerial += 1
    local s = visSerial
    shell.Active = false

    if not animationsOn then
        shell.Visible = false
        shell.GroupTransparency = 1
        sessionChip_dummy = nil
        backdrop.BackgroundTransparency = 1
        blur.Size = 0
        visTransitioning = false
        return
    end

    tween(backdrop, 0.30, { BackgroundTransparency = 1 })
    tween(blur, 0.30, { Size = 0 })
    tween(shell, 0.32, {
        GroupTransparency = 1,
        Position = UDim2.new(posBeforeClose.X.Scale, posBeforeClose.X.Offset,
            posBeforeClose.Y.Scale, posBeforeClose.Y.Offset + 10),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

    task.delay(0.33, function()
        if s ~= visSerial or not closed then return end
        shell.Visible = false
        visTransitioning = false
    end)
end

local function openPanel()
    if not closed or visTransitioning then return end
    local s_style = style()
    closed = false
    visTransitioning = animationsOn
    visSerial += 1
    local s = visSerial
    shell.Visible = true
    shell.Active = true
    shell.Position = posBeforeClose

    if not animationsOn then
        shell.GroupTransparency = 0
        backdrop.BackgroundTransparency = s_style.backdropTransparency
        blur.Size = s_style.blurSize
        visTransitioning = false
        return
    end

    tween(backdrop, 0.34, { BackgroundTransparency = s_style.backdropTransparency })
    tween(blur, 0.40, { Size = s_style.blurSize })
    shell.GroupTransparency = 1
    shell.Position = UDim2.new(posBeforeClose.X.Scale, posBeforeClose.X.Offset,
        posBeforeClose.Y.Scale, posBeforeClose.Y.Offset + 10)
    tween(shell, 0.42, { GroupTransparency = 0, Position = posBeforeClose },
        Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    task.delay(0.46, function()
        if s == visSerial and not closed then visTransitioning = false end
    end)
end

closeBtn.Activated:Connect(closePanel)

-- minimize
local minimized = false
minimizeBtn.Activated:Connect(function()
    if closed or visTransitioning then return end
    minimized = not minimized
    minimizeBtn.Text = minimized and "□" or "—"
    local targetSize = minimized and MIN_SIZE or FULL_SIZE
    local res = tween(shell, motionDur(0.34), { Size = targetSize })
    if minimized then
        body.Visible = false
    else
        body.Visible = true
    end
end)

-- KEYBIND: Insert to toggle
UserInputService.InputBegan:Connect(function(inp)
    if inp.KeyCode == Enum.KeyCode.RightShift and UserInputService:GetFocusedTextBox() == nil then
        if closed then openPanel() else closePanel() end
    end
end)

-- ─────────────────────────────────────────────
-- DRAG
-- ─────────────────────────────────────────────
local dragging = false
local dragInput2 = nil
local dragStart2 = Vector3.zero
local shellStart2 = shell.Position

titleBar.InputBegan:Connect(function(inp)
    if closed or visTransitioning then return end
    local localX = inp.Position.X - titleBar.AbsolutePosition.X
    if localX > titleBar.AbsoluteSize.X - 104 then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart2 = inp.Position
        shellStart2 = shell.Position
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
titleBar.InputChanged:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
        dragInput2 = inp
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and inp == dragInput2 then
        local delta = inp.Position - dragStart2
        shell.Position = UDim2.new(shellStart2.X.Scale, shellStart2.X.Offset + delta.X,
            shellStart2.Y.Scale, shellStart2.Y.Offset + delta.Y)
        posBeforeClose = shell.Position
    end
end)

-- ─────────────────────────────────────────────
-- ESP
-- ─────────────────────────────────────────────
local espGui = create("ScreenGui", {
    Parent = playerGui, Name = "NimbusESP",
    IgnoreGuiInset = true, ResetOnSpawn = false,
    DisplayOrder = 50, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local espHighlights = {} -- player → Highlight

local function worldToViewport(pos)
    local cam = Workspace.CurrentCamera
    local screenPos, onScreen = cam:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local espFrames = {}

local function getPlayerModel(p)
    return p.Character
end

local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
end

local function getHead(char)
    return char and char:FindFirstChild("Head")
end

local function getHumanoid(char)
    return char and char:FindFirstChildWhichIsA("Humanoid")
end

local function isSameTeam(p)
    return p.Team ~= nil and player.Team ~= nil and p.Team == player.Team
end

local function updateESP()
    -- clear frames for gone players
    for p, frame in pairs(espFrames) do
        if not Players:FindFirstChild(p.Name) then
            frame:Destroy()
            espFrames[p] = nil
        end
    end

    if not CHEAT.espEnabled then
        for _, f in pairs(espFrames) do f.Visible = false end
        for p, h in pairs(espHighlights) do
            h:Destroy()
            espHighlights[p] = nil
        end
        return
    end

    local cam = Workspace.CurrentCamera
    local myChar = player.Character

    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        if CHEAT.espTeamCheck and isSameTeam(p) then
            if espFrames[p] then espFrames[p].Visible = false end
            continue
        end

        local char = getPlayerModel(p)
        if not char then
            if espFrames[p] then espFrames[p].Visible = false end
            continue
        end

        local root = getRoot(char)
        local head = getHead(char)
        local hum  = getHumanoid(char)

        if not root or not head then
            if espFrames[p] then espFrames[p].Visible = false end
            continue
        end

        -- highlight mode
        if CHEAT.espHighlightMode then
            if not espHighlights[p] then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(255, 60, 60)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0
                hl.Adornee = char
                hl.Parent = char
                espHighlights[p] = hl
            end
            if espFrames[p] then espFrames[p].Visible = false end
        else
            -- destroy highlight if mode switched off
            if espHighlights[p] then
                espHighlights[p]:Destroy()
                espHighlights[p] = nil
            end
        end

        -- box / text ESP
        if not CHEAT.espHighlightMode then
            local headPos2D, headOnScreen, _ = worldToViewport(head.Position + Vector3.new(0, 0.7, 0))
            local rootPos2D, rootOnScreen, rootDepth = worldToViewport(root.Position - Vector3.new(0, 2.5, 0))

            if not headOnScreen and not rootOnScreen then
                if espFrames[p] then espFrames[p].Visible = false end
                continue
            end

            if not espFrames[p] then
                local f = create("Frame", {
                    Parent = espGui, Name = "ESP_" .. p.Name,
                    BackgroundTransparency = 1, BorderSizePixel = 0,
                    Size = UDim2.fromOffset(0, 0),
                })

                local box = create("Frame", {
                    Parent = f, Name = "Box",
                    BackgroundTransparency = 1, BorderSizePixel = 0,
                    Size = UDim2.fromOffset(0, 0),
                })
                create("UIStroke", {
                    Parent = box, Color = Color3.fromRGB(255, 60, 60),
                    Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                })

                create("TextLabel", {
                    Parent = f, Name = "NameLabel",
                    BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextStrokeTransparency = 0.4, TextStrokeColor3 = Color3.fromRGB(0,0,0),
                    TextSize = 11, Text = p.Name,
                    Size = UDim2.fromOffset(100, 14),
                    AnchorPoint = Vector2.new(0.5, 1),
                })

                create("TextLabel", {
                    Parent = f, Name = "HealthLabel",
                    BackgroundTransparency = 1, Font = Enum.Font.Gotham,
                    TextColor3 = Color3.fromRGB(100, 255, 100),
                    TextStrokeTransparency = 0.4, TextStrokeColor3 = Color3.fromRGB(0,0,0),
                    TextSize = 10, Text = "",
                    Size = UDim2.fromOffset(100, 14),
                    AnchorPoint = Vector2.new(0.5, 0),
                })

                create("TextLabel", {
                    Parent = f, Name = "DistLabel",
                    BackgroundTransparency = 1, Font = Enum.Font.Gotham,
                    TextColor3 = Color3.fromRGB(220, 220, 220),
                    TextStrokeTransparency = 0.4, TextStrokeColor3 = Color3.fromRGB(0,0,0),
                    TextSize = 10, Text = "",
                    Size = UDim2.fromOffset(100, 14),
                    AnchorPoint = Vector2.new(0, 0.5),
                })

                espFrames[p] = f
            end

            local f = espFrames[p]
            f.Visible = true

            local top    = math.min(headPos2D.Y, rootPos2D.Y)
            local bottom = math.max(headPos2D.Y, rootPos2D.Y)
            local height = math.max(bottom - top, 10)
            local width  = height * 0.45

            local centerX = (headPos2D.X + rootPos2D.X) / 2

            local box = f:FindFirstChild("Box")
            box.Visible = CHEAT.espBoxes
            box.Position = UDim2.fromOffset(centerX - width / 2, top)
            box.Size = UDim2.fromOffset(width, height)

            local nameLbl = f:FindFirstChild("NameLabel")
            nameLbl.Visible = CHEAT.espNames
            nameLbl.Position = UDim2.fromOffset(centerX, top - 2)
            nameLbl.Text = p.Name

            local hpLbl = f:FindFirstChild("HealthLabel")
            hpLbl.Visible = CHEAT.espHealth
            if hum then
                local hp = math.floor((hum.Health / math.max(hum.MaxHealth, 1)) * 100)
                hpLbl.Text = hp .. "%"
                hpLbl.TextColor3 = Color3.fromRGB(math.floor((100 - hp) * 2.55), math.floor(hp * 2.55), 60)
            end
            hpLbl.Position = UDim2.fromOffset(centerX, bottom + 2)

            local distLbl = f:FindFirstChild("DistLabel")
            distLbl.Visible = CHEAT.espDistance
            if myChar then
                local myRoot = getRoot(myChar)
                if myRoot then
                    local dist = math.floor((myRoot.Position - root.Position).Magnitude)
                    distLbl.Text = dist .. "m"
                    distLbl.Position = UDim2.fromOffset(centerX + width / 2 + 4, (top + bottom) / 2)
                end
            end
        end
    end
end

-- ─────────────────────────────────────────────
-- AIMBOT
-- ─────────────────────────────────────────────
local function getBestTarget()
    local cam = Workspace.CurrentCamera
    local myChar = player.Character
    local bestDist = math.huge
    local bestTarget = nil

    local fovRad = math.rad(CHEAT.aimbotFov / 2)
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        if CHEAT.espTeamCheck and isSameTeam(p) then continue end
        local char = p.Character
        if not char then continue end
        local target = char:FindFirstChild(CHEAT.aimbotBone) or char:FindFirstChild("Head")
        if not target then continue end

        if CHEAT.aimbotVisCheck then
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = { myChar, char }
            params.FilterType = Enum.RaycastFilterType.Exclude
            local ray = Workspace:Raycast(cam.CFrame.Position, (target.Position - cam.CFrame.Position), params)
            if ray then continue end
        end

        local screenPos, onScreen = cam:WorldToViewportPoint(target.Position)
        if not onScreen then continue end

        local screenVec = Vector2.new(screenPos.X, screenPos.Y)
        local angleDist = (screenVec - center).Magnitude

        -- convert pixel dist to rough angle
        local halfFovPx = math.tan(math.rad(cam.FieldOfView / 2)) * cam.ViewportSize.Y / 2
        local angleRad = math.atan(angleDist / halfFovPx)

        if angleRad < fovRad and angleRad < bestDist then
            bestDist = angleRad
            bestTarget = target
        end
    end

    return bestTarget
end

-- ─────────────────────────────────────────────
-- NOCLIP
-- ─────────────────────────────────────────────
local noclipConn = nil

local function enableNoclip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        if not CHEAT.noclipEnabled then return end
        local char = player.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end
enableNoclip()

-- ─────────────────────────────────────────────
-- INFINITE JUMP
-- ─────────────────────────────────────────────
UserInputService.JumpRequest:Connect(function()
    if not CHEAT.infiniteJump then return end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- ─────────────────────────────────────────────
-- FLY
-- ─────────────────────────────────────────────
local flyBodyVelocity = nil
local flyBodyGyro    = nil

local function startFly()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBodyVelocity.Velocity = Vector3.zero
    flyBodyVelocity.Parent = root

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBodyGyro.P = 9e4
    flyBodyGyro.Parent = root
end

local function stopFly()
    if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
    if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
end

-- ─────────────────────────────────────────────
-- TRIGGERBOT
-- ─────────────────────────────────────────────
local lastTrigger = 0

local function checkTrigger()
    if not CHEAT.triggerbotEnabled then return end
    local cam = Workspace.CurrentCamera
    local myChar = player.Character
    if not myChar then return end

    local unitRay = cam:ScreenPointToRay(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { myChar }
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)

    if result and result.Instance then
        local hitModel = result.Instance:FindFirstAncestorWhichIsA("Model")
        if hitModel then
            local hitPlayer = Players:GetPlayerFromCharacter(hitModel)
            if hitPlayer and hitPlayer ~= player then
                if CHEAT.triggerbotTeamCheck and isSameTeam(hitPlayer) then return end
                local now = tick()
                if now - lastTrigger > (CHEAT.triggerbotDelay / 1000) then
                    lastTrigger = now
                    -- fire tool
                    local tool = myChar:FindFirstChildWhichIsA("Tool")
                    if tool then
                        local remote = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChildWhichIsA("RemoteEvent")
                        -- generic mouse click simulation via UIS isn't available server-side;
                        -- for game-specific triggerbot, fire the tool's remote here.
                        -- FILL: fire tool:Activate() or game-specific remote
                        tool:Activate()
                    end
                end
            end
        end
    end
end

-- ─────────────────────────────────────────────
-- WALK SPEED / JUMP HEIGHT APPLY ON SPAWN
-- ─────────────────────────────────────────────
local function applyCharacterStats(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum.WalkSpeed = CHEAT.walkSpeed
        hum.JumpHeight = CHEAT.jumpHeight
    end
end

player.CharacterAdded:Connect(function(char)
    character = char
    applyCharacterStats(char)
    if CHEAT.flyEnabled then
        task.delay(1, startFly)
    end
end)
if character then applyCharacterStats(character) end

-- ─────────────────────────────────────────────
-- MAIN LOOP
-- ─────────────────────────────────────────────
RunService.RenderStepped:Connect(function(dt)
    -- ESP
    updateESP()

    -- Aimbot
    if CHEAT.aimbotEnabled and UserInputService:IsKeyDown(CHEAT.aimbotKey) then
        local target = getBestTarget()
        if target then
            local cam = Workspace.CurrentCamera
            local targetPos = target.Position
            local currentCF = cam.CFrame
            local targetCF = CFrame.lookAt(currentCF.Position, targetPos)
            local smooth = math.clamp(CHEAT.aimbotSmooth, 1, 30)
            cam.CFrame = currentCF:Lerp(targetCF, dt * (30 / smooth))
        end
    end

    -- Triggerbot
    checkTrigger()

    -- Fly
    if CHEAT.flyEnabled then
        if not flyBodyVelocity or not flyBodyVelocity.Parent then
            startFly()
        end
        if flyBodyVelocity and flyBodyGyro then
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local cam = Workspace.CurrentCamera
                    flyBodyGyro.CFrame = cam.CFrame
                    local dir = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
                    flyBodyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * CHEAT.flySpeed or Vector3.zero
                end
            end
        end
    else
        stopFly()
    end
end)

-- ─────────────────────────────────────────────
-- INIT
-- ─────────────────────────────────────────────
renderPage(currentPage)
refreshNav(false)
applyTheme(false)

showToast("Ando loaded · Right Shift to toggle")
