--==========================================================================
--  KiciaHook | Rivals  —  Nimbus Glass Shell
--  Kicia tabs, icons, controls wired to KiciaRebuild's reactive store.
--==========================================================================
local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting      = game:GetService("Lighting")

local player = Players.LocalPlayer
if not player then error("Must run from a LocalScript.") end
local playerGui = player:WaitForChild("PlayerGui")

-- Clean up old instances
for _, name in ipairs({"NimbusGlassUI", "NimbusGlassBlur"}) do
    local old = (name == "NimbusGlassBlur") and Lighting:FindFirstChild(name) or playerGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- Kicia store bridge: read/write through KiciaRebuild if present
local function kGet(path)
    local K = getgenv and getgenv().KiciaRebuild
    if not K then return nil end
    local store = K._store
    if not store then return nil end
    local ok, v = pcall(function()
        local t = store.Data
        for i = 1, #path do t = t[path[i]] end
        return t
    end)
    return ok and v or nil
end

local function kSet(path, value)
    local K = getgenv and getgenv().KiciaRebuild
    if not K then return end
    local store = K._store
    if not store then return end
    pcall(function()
        local t = store.Data
        for i = 1, #path - 1 do t = t[path[i]] end
        t[path[#path]] = value
    end)
end

--==========================================================================
--  COLORS
--==========================================================================
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
}

--==========================================================================
--  HELPERS
--==========================================================================
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

local function addStroke(obj, t, color)
    return create("UIStroke", {
        Parent = obj,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = color or COLORS.White,
        Transparency = t,
        Thickness = 1,
    })
end

local function playTween(obj, dur, goals, style, dir, delay)
    local tw = TweenService:Create(obj, TweenInfo.new(
        dur, style or Enum.EasingStyle.Quint,
        dir or Enum.EasingDirection.Out, 0, false, delay or 0
    ), goals)
    tw:Play()
    return tw
end

--==========================================================================
--  KICIA TAB / CARD DEFINITIONS
--  row types: toggle | slider | dropdown | scrollwheel | button
--  Config = {path...} wires to KiciaRebuild store; key = local-only state key
--==========================================================================
local PAGES = {
    ------------------------------------------------------------------
    {
        id    = "combat",
        label = "Combat",
        icon  = "rbxassetid://99199363807265",
        cards = {
            {
                title = "Aimbot",
                icon  = "◎",
                rows  = {
                    { type="toggle",      label="Enable Aimbot",       Config={"Aimbot","Keybind","State"},       key="aimbotEnabled",    value=false },
                    { type="dropdown",    label="Keybind Mode",        Config={"Aimbot","Keybind","Kind"},        key="aimbotMode",       value="Hold",    options={"Always","Toggle","Hold"} },
                    { type="dropdown",    label="Target Bone",         Config={"Aimbot","Bone"},                  key="aimbotBone",       value="Head",    options={"Head","Neck","UpperTorso","LowerTorso"} },
                    { type="slider",      label="FOV Radius",          Config={"Aimbot","Fov"},                   key="aimbotFov",        value=120, min=10,  max=500, step=5,   unit="px" },
                    { type="slider",      label="Smoothing",           Config={"Aimbot","Smoothing"},             key="aimbotSmooth",     value=5,   min=1,   max=50,  step=1,   unit="" },
                    { type="toggle",      label="Visibility Check",    Config={"Aimbot","VisibilityCheck"},       key="aimbotVisCheck",   value=true },
                    { type="toggle",      label="Team Check",          Config={"Aimbot","TeamCheck"},             key="aimbotTeamCheck",  value=true },
                    { type="scrollwheel", label="Priority",            Config={"Aimbot","Priority"},              key="aimbotPriority",   value="Closest",  options={"Closest","LowestHealth","HighestHealth","LeastFOV"} },
                },
            },
            {
                title = "Silent Aim",
                icon  = "◈",
                rows  = {
                    { type="toggle",      label="Enable Silent Aim",   Config={"SilentAim","Keybind","State"},    key="saEnabled",        value=false },
                    { type="dropdown",    label="Keybind Mode",        Config={"SilentAim","Keybind","Kind"},     key="saMode",           value="Hold",    options={"Always","Toggle","Hold"} },
                    { type="slider",      label="Hitchance",           Config={"SilentAim","Hitchance"},          key="saHitchance",      value=100, min=1, max=100, step=1, unit="%" },
                    { type="toggle",      label="Visibility Check",    Config={"SilentAim","VisibilityCheck"},    key="saVisCheck",       value=true },
                    { type="toggle",      label="Team Check",          Config={"SilentAim","TeamCheck"},          key="saTeamCheck",      value=true },
                    { type="scrollwheel", label="Target Bone",         Config={"SilentAim","Bone"},               key="saBone",           value="Head",    options={"Head","Neck","UpperTorso"} },
                },
            },
            {
                title = "Fire Assist",
                icon  = "⊕",
                rows  = {
                    { type="toggle",      label="Triggerbot",          Config={"Triggerbot","Keybind","State"},   key="trigEnabled",      value=false },
                    { type="dropdown",    label="Triggerbot Mode",     Config={"Triggerbot","Keybind","Kind"},    key="trigMode",         value="Hold",    options={"Always","Toggle","Hold"} },
                    { type="slider",      label="Shoot Delay (ms)",    Config={"Triggerbot","Delay"},             key="trigDelay",        value=50,  min=0, max=500, step=5,  unit="ms" },
                    { type="toggle",      label="Team Check",          Config={"Triggerbot","TeamCheck"},         key="trigTeamCheck",    value=true },
                    { type="toggle",      label="Flickbot",            Config={"Flickbot","Enabled"},             key="flickEnabled",     value=false },
                    { type="slider",      label="Flick Duration (ms)", Config={"Flickbot","FlickDuration"},       key="flickDur",         value=110, min=50, max=400, step=10, unit="ms" },
                    { type="slider",      label="Curvature",           Config={"Flickbot","Curvature"},           key="flickCurve",       value=12,  min=0,  max=50,  step=1,  unit="" },
                },
            },
            {
                title = "Weapon Handling",
                icon  = "⊞",
                rows  = {
                    { type="toggle",  label="No Recoil",               key="noRecoil",   value=false },
                    { type="toggle",  label="No Spread",               key="noSpread",   value=false },
                    { type="toggle",  label="Rapid Fire",              key="rapidFire",  value=false },
                    { type="slider",  label="Fire Rate Mult",          key="fireRateMult", value=1, min=1, max=10, step=0.1, unit="x" },
                },
            },
            {
                title = "Hit Feedback",
                icon  = "♦",
                rows  = {
                    { type="toggle",      label="Hit Sound",           key="hitSound",   value=true },
                    { type="scrollwheel", label="Sound Pack",          key="hitSoundPack", value="TF2 HitSound", options={"TF2 HitSound","Csgo","Minecraft","Ding","Osu","Click","Bop"} },
                    { type="toggle",      label="Hit Flash",           key="hitFlash",   value=false },
                    { type="toggle",      label="Notifications",       key="hitNotif",   value=false },
                },
            },
            {
                title = "Ragebot",
                icon  = "⚡",
                rows  = {
                    { type="toggle",      label="Enable Ragebot",      Config={"Ragebot","Enabled"},              key="rageEnabled",      value=false },
                    { type="slider",      label="Stability",           Config={"Ragebot","Stability"},            key="rageStability",    value=15, min=0, max=100, step=1, unit="%" },
                    { type="slider",      label="Shoot Frames",        Config={"Ragebot","ShootFrames"},          key="rageShootFrames",  value=1,  min=1, max=10,  step=1, unit="" },
                    { type="toggle",      label="Prioritize Hackers",  Config={"Ragebot","PrioritizeHackers"},   key="ragePriHackers",   value=false },
                    { type="scrollwheel", label="On Empty Weapon",     Config={"Ragebot","Weapons","OnEmpty"},   key="rageOnEmpty",      value="SwapOrReload", options={"SwapOrReload","Reload","Swap","Nothing"} },
                    { type="dropdown",    label="Evasion Mode",        Config={"Ragebot","Evasion","Mode"},       key="rageEvasionMode",  value="Random", options={"Random","ProjectileBreaker","Translocate"} },
                },
            },
        },
    },
    ------------------------------------------------------------------
    {
        id    = "visuals",
        label = "Visuals",
        icon  = "rbxassetid://127234874352422",
        cards = {
            {
                title = "Player ESP",
                icon  = "□",
                rows  = {
                    { type="toggle",      label="Enable ESP",          Config={"ESP","Main","Keybind","State"},  key="espEnabled",       value=false },
                    { type="dropdown",    label="ESP Mode",            Config={"ESP","Main","Mode"},             key="espMode",          value="Always",  options={"Always","Toggle","Hold"} },
                    { type="dropdown",    label="Box Style",           Config={"ESP","Box","Style"},             key="espBoxStyle",      value="Full",    options={"Full","Corner"} },
                    { type="toggle",      label="Health Bar",          Config={"ESP","HealthBar","Enabled"},     key="espHealthBar",     value=true },
                    { type="toggle",      label="Ammo Bar",            Config={"ESP","AmmoBar","Enabled"},       key="espAmmoBar",       value=false },
                    { type="toggle",      label="Skeleton",            Config={"ESP","Skeleton","Enabled"},      key="espSkeleton",      value=false },
                    { type="toggle",      label="Tracer",              Config={"ESP","Tracer","Enabled"},        key="espTracer",        value=false },
                    { type="dropdown",    label="Tracer Origin",       Config={"ESP","Tracer","Origin"},         key="espTracerOrigin",  value="Bottom",  options={"Bottom","Center","Top","Mouse"} },
                    { type="toggle",      label="Head Marker",         Config={"ESP","HeadMarker","Enabled"},   key="espHeadMarker",    value=false },
                    { type="toggle",      label="Chams",               Config={"ESP","Chams","Enabled"},         key="espChams",         value=false },
                    { type="scrollwheel", label="Chams Kind",          Config={"ESP","Chams","Kind"},            key="espChamsKind",     value="Legacy",  options={"Legacy","Highlight"} },
                    { type="toggle",      label="Team Check",          Config={"ESP","TeamCheck"},               key="espTeamCheck",     value=true },
                    { type="dropdown",    label="Name Font",           Config={"ESP","Settings","Font"},         key="espFont",          value="GothamBold", options={"GothamBold","Gotham","Inconsolata","RobotoMono"} },
                    { type="slider",      label="Font Size",           Config={"ESP","Settings","FontSize"},     key="espFontSize",      value=14, min=8, max=32, step=1, unit="px" },
                    { type="toggle",      label="Scale With Distance", Config={"ESP","Settings","DistanceScaling"}, key="espDistScale",  value=false },
                },
            },
            {
                title = "Crosshair",
                icon  = "⊕",
                rows  = {
                    { type="toggle",      label="Custom Crosshair",    Config={"CustomCrosshair","Enabled"},     key="chEnabled",        value=false },
                    { type="scrollwheel", label="Style",               Config={"CustomCrosshair","Style"},       key="chStyle",          value="Lines",   options={"Lines","Circle","Dot","Cross"} },
                    { type="slider",      label="Length",              Config={"CustomCrosshair","Length"},      key="chLength",         value=12, min=2, max=40, step=1, unit="px" },
                    { type="slider",      label="Thickness",           Config={"CustomCrosshair","Thickness"},   key="chThickness",      value=2,  min=1, max=8,  step=1, unit="px" },
                    { type="slider",      label="Gap",                 Config={"CustomCrosshair","Gap"},         key="chGap",            value=6,  min=0, max=20, step=1, unit="px" },
                    { type="toggle",      label="Outline",             Config={"CustomCrosshair","Outline","Enabled"}, key="chOutline",  value=false },
                    { type="toggle",      label="Rotation",            Config={"CustomCrosshair","Rotation","Enabled"}, key="chRotation", value=false },
                    { type="slider",      label="Rotation Speed",      Config={"CustomCrosshair","Rotation","Speed"}, key="chRotSpeed", value=90, min=10, max=360, step=10, unit="°/s" },
                },
            },
            {
                title = "Weapon Visuals",
                icon  = "⊞",
                rows  = {
                    { type="toggle",  label="No Muzzle Flash",        Config={"Removables","NoMuzzleFlash"},   key="noMuzzle",   value=false },
                    { type="toggle",  label="No Gun Tracers",         Config={"Removables","NoGunTracers"},    key="noTracers",  value=false },
                    { type="toggle",  label="No Hitmarker",           Config={"Removables","NoHitmarker"},     key="noHitmark",  value=false },
                    { type="toggle",  label="No Scope Overlay",       Config={"Removables","NoScopeOverlay"},  key="noScope",    value=false },
                },
            },
            {
                title = "Camera & Screen",
                icon  = "◉",
                rows  = {
                    { type="toggle",   label="Third Person",          Config={"ThirdPerson","Enabled"},        key="thirdPerson",   value=false },
                    { type="toggle",   label="Custom FOV",            Config={"CameraFov","Enabled"},          key="camFovEnabled", value=false },
                    { type="slider",   label="FOV Value",             Config={"CameraFov","Value"},            key="camFov",        value=70, min=30, max=120, step=1, unit="°" },
                    { type="toggle",   label="Stretched Res",         Config={"StretchedResolution","Enabled"}, key="stretchRes",   value=false },
                    { type="toggle",   label="No Flashbang",          Config={"Removables","NoFlashbang"},     key="noFlash",       value=false },
                    { type="toggle",   label="No ADS Vignette",       Config={"Removables","NoAdsVignette"},   key="noAdsVig",      value=false },
                },
            },
            {
                title = "Sound ESP",
                icon  = "♪",
                rows  = {
                    { type="toggle",  label="Enable Sound ESP",       key="soundEspEnabled", value=false },
                    { type="slider",  label="Render Distance",        key="soundEspDist",    value=100, min=10, max=500, step=10, unit="m" },
                    { type="toggle",  label="Show Footsteps",         key="soundEspFootstep", value=true },
                    { type="toggle",  label="Show Shots",             key="soundEspShots",   value=true },
                },
            },
        },
    },
    ------------------------------------------------------------------
    {
        id    = "player",
        label = "Player",
        icon  = "rbxassetid://114567720540659",
        cards = {
            {
                title = "Movement",
                icon  = "↑",
                rows  = {
                    { type="toggle",      label="Walk Speed",          Config={"Movement","WalkSpeed","Enabled"},  key="wsEnabled",     value=false },
                    { type="slider",      label="Speed Multiplier",    Config={"Movement","WalkSpeed","Speed"},    key="wsSpeed",       value=2,   min=1,  max=10,  step=0.1, unit="x" },
                    { type="toggle",      label="Flight",              Config={"Movement","Flight","Enabled"},     key="flyEnabled",    value=false },
                    { type="slider",      label="Flight Speed",        Config={"Movement","Flight","Speed"},       key="flySpeed",      value=100, min=25, max=500, step=5,   unit="" },
                    { type="toggle",      label="Noclip",              Config={"Movement","Noclip","Enabled"},     key="noclipEnabled", value=false },
                    { type="toggle",      label="Jump Power",          Config={"Movement","JumpPower","Enabled"},  key="jpEnabled",     value=false },
                    { type="slider",      label="Jump Multiplier",     Config={"Movement","JumpPower","Speed"},    key="jpSpeed",       value=2,   min=0.1,max=10,  step=0.1, unit="x" },
                    { type="toggle",      label="Long Jump",           Config={"Movement","LongJump","Enabled"},   key="ljEnabled",     value=false },
                    { type="dropdown",    label="Long Jump Mode",      Config={"Movement","LongJump","Mode"},      key="ljMode",        value="Under Feet", options={"Under Feet","Camera Look"} },
                    { type="toggle",      label="Auto Strafe",         Config={"Movement","AutoStrafe","Enabled"}, key="strafeEnabled", value=false },
                    { type="toggle",      label="Sliding Boost",       Config={"Movement","Sliding","Enabled"},    key="slideEnabled",  value=false },
                },
            },
            {
                title = "Character",
                icon  = "☺",
                rows  = {
                    { type="dropdown",    label="Animation",           Config={"AnimationPlayer","Animation"},    key="animName",      value="Cat Girl Bounce", options={"Cat Girl Bounce","None"} },
                    { type="toggle",      label="Custom Animation",    Config={"AnimationPlayer","Enabled"},      key="animEnabled",   value=false },
                    { type="slider",      label="Anim Speed",          Config={"AnimationPlayer","Speed"},        key="animSpeed",     value=1, min=0.1, max=5, step=0.1, unit="x" },
                    { type="toggle",      label="Third Person Char",   Config={"ThirdPerson","ShowReplica"},      key="tpReplica",     value=false },
                },
            },
            {
                title = "Identity Spoofing",
                icon  = "⊘",
                rows  = {
                    { type="toggle",  label="Spoof Name",             Config={"PlayerSpoofer","LocalPlayer","Name","Enabled"},     key="spoofName",    value=false },
                    { type="toggle",  label="Spoof Display Name",     Config={"PlayerSpoofer","LocalPlayer","DisplayName","Enabled"}, key="spoofDisplay", value=false },
                    { type="toggle",  label="Spoof Level",            Config={"PlayerSpoofer","LocalPlayer","Level","Enabled"},    key="spoofLevel",   value=false },
                    { type="toggle",  label="Spoof Ranked ELO",       Config={"PlayerSpoofer","LocalPlayer","RankedElo","Enabled"}, key="spoofElo",    value=false },
                    { type="toggle",  label="Roblox Employee Badge",  Config={"PlayerSpoofer","LocalPlayer","RobloxEmployee","Enabled"}, key="spoofRbxEmp", value=false },
                    { type="toggle",  label="Influencer Badge",       Config={"PlayerSpoofer","LocalPlayer","Influencer","Enabled"}, key="spoofInfl",   value=false },
                    { type="toggle",  label="Spoof Avatar",           Config={"PlayerSpoofer","LocalPlayer","Avatar","Enabled"},   key="spoofAvatar",  value=false },
                },
            },
            {
                title = "Device Spoof",
                icon  = "⊡",
                rows  = {
                    { type="toggle",      label="Enable Device Spoof", Config={"DeviceSpoof","Enabled"},          key="devSpoofEnabled", value=false },
                    { type="scrollwheel", label="Spoof Type",          Config={"DeviceSpoof","SpoofType"},        key="devSpoofType",    value="VR", options={"VR","Mobile","Console"} },
                },
            },
        },
    },
    ------------------------------------------------------------------
    {
        id    = "world",
        label = "World",
        icon  = "rbxassetid://125685532120024",
        cards = {
            {
                title = "Lighting",
                icon  = "☀",
                rows  = {
                    { type="toggle",  label="Override Lighting",   key="lightOverride",   value=false },
                    { type="slider",  label="Brightness",          key="lightBrightness", value=1,   min=0, max=10, step=0.1, unit="" },
                    { type="slider",  label="Ambient Light",       key="lightAmbient",    value=100, min=0, max=255, step=5,   unit="" },
                    { type="toggle",  label="No Fog",              key="lightNoFog",      value=false },
                    { type="toggle",  label="No Shadows",          key="lightNoShadows",  value=false },
                },
            },
            {
                title = "Post Processing",
                icon  = "◈",
                rows  = {
                    { type="toggle",  label="Color Correction",    key="ppColorCorr",  value=false },
                    { type="slider",  label="Saturation",          key="ppSaturation", value=0,  min=-1, max=1,  step=0.05, unit="" },
                    { type="slider",  label="Contrast",            key="ppContrast",   value=0,  min=-1, max=1,  step=0.05, unit="" },
                    { type="toggle",  label="Bloom",               key="ppBloom",      value=false },
                    { type="toggle",  label="Depth of Field",      key="ppDOF",        value=false },
                    { type="toggle",  label="Sun Rays",            key="ppSunRays",    value=false },
                },
            },
            {
                title = "Sky & Weather",
                icon  = "☁",
                rows  = {
                    { type="toggle",      label="Custom Skybox",       Config={"Skybox","Enabled"},    key="skyEnabled",    value=false },
                    { type="scrollwheel", label="Skybox Preset",       Config={"Skybox","Preset"},     key="skyPreset",     value="Space", options={"Space","Galaxy","Nebula","Blizzard","FlamingSunset","PinkArt","Mountains","Dawn","Midnight"} },
                    { type="toggle",      label="Rain",                key="weatherRain",   value=false },
                    { type="toggle",      label="Lightning",           key="weatherLight",  value=false },
                },
            },
        },
    },
    ------------------------------------------------------------------
    {
        id    = "cosmetics",
        label = "Cosmetics",
        icon  = "rbxassetid://128162112866809",
        cards = {
            {
                title = "Overview",
                icon  = "◉",
                rows  = {
                    { type="toggle",  label="Enable Cosmetics",    key="cosmeticsEnabled",  value=false },
                    { type="toggle",  label="Unlock All",          key="cosmeticsUnlock",   value=false },
                    { type="button",  label="Reroll Active Look",  key="cosmeticsReroll",   button="Reroll" },
                },
            },
            {
                title = "Skins",
                icon  = "□",
                rows  = {
                    { type="toggle",      label="Enable Skins",        key="skinsEnabled",   value=false },
                    { type="scrollwheel", label="Active Skin",         key="activeSkin",     value="None",  options={"None","Unselected","Random"} },
                },
            },
            {
                title = "Charms",
                icon  = "♦",
                rows  = {
                    { type="toggle",  label="Enable Charms",       key="charmsEnabled",  value=false },
                    { type="toggle",  label="Override Rank Charm", key="charmOverride",  value=false },
                },
            },
            {
                title = "Finishers",
                icon  = "⊕",
                rows  = {
                    { type="toggle",      label="Enable Finishers",    key="finishersEnabled", value=false },
                    { type="scrollwheel", label="Finisher",            key="activeFinisher",   value="None", options={"None","Random"} },
                },
            },
        },
    },
    ------------------------------------------------------------------
    {
        id    = "automation",
        label = "Automation",
        icon  = "rbxassetid://70979486241131",
        cards = {
            {
                title = "Match Flow",
                icon  = "↻",
                rows  = {
                    { type="toggle",  label="Auto Queue",          key="autoQueue",    value=false },
                    { type="toggle",  label="Auto Vote",           key="autoVote",     value=false },
                    { type="toggle",  label="Auto Respawn",        key="autoRespawn",  value=false },
                    { type="toggle",  label="Auto Ban Skip",       key="autoBanSkip",  value=false },
                },
            },
            {
                title = "In-Match Automation",
                icon  = "⚡",
                rows  = {
                    { type="toggle",  label="Auto Pickup",         key="autoPickup",   value=false },
                    { type="toggle",  label="Auto Counter",        key="autoCounter",  value=false },
                    { type="toggle",  label="Auto Tripmine",       key="autoTripmine", value=false },
                },
            },
            {
                title = "Detection",
                icon  = "◎",
                rows  = {
                    { type="toggle",  label="Hacker Detection",    key="detectHackers",  value=false },
                    { type="toggle",  label="Mod Detection",       key="detectMods",     value=false },
                    { type="toggle",  label="Notify on Detect",    key="detectNotify",   value=true },
                },
            },
            {
                title = "Auto Loadout",
                icon  = "⊞",
                rows  = {
                    { type="toggle",      label="Enable Auto Loadout",  key="autoLoadout",     value=false },
                    { type="scrollwheel", label="Fallback Map",         key="autoLoadoutMap",  value="Arena", options={"Arena","Skybox","Neon"} },
                },
            },
        },
    },
    ------------------------------------------------------------------
    {
        id    = "settings",
        label = "Settings",
        icon  = "rbxassetid://106205298246017",
        cards = {
            {
                title = "General",
                icon  = "⚙",
                rows  = {
                    { type="toggle",   label="Silent Load",           Config={"GeneralState","SilentLoad"},    key="silentLoad",     value=false },
                    { type="toggle",   label="Auto-Load Config",      key="autoLoadCfg",    value=false },
                    { type="button",   label="Unload KiciaHook",      key="unload",         button="Unload" },
                },
            },
            {
                title = "Config Profiles",
                icon  = "≡",
                rows  = {
                    { type="button",  label="Save Config",           key="cfgSave",    button="Save" },
                    { type="button",  label="Load Config",           key="cfgLoad",    button="Load" },
                    { type="button",  label="Reset to Defaults",     key="cfgReset",   button="Reset" },
                },
            },
            {
                title = "Theme",
                icon  = "◉",
                rows  = {
                    { type="theme",  label="UI Theme",  key="theme",  value="glass" },
                    { type="toggle", label="Animations", key="animations", value=true },
                    { type="slider", label="Blur Strength", key="blur", min=0, max=40, step=1, value=24, unit="" },
                    { type="slider", label="UI Scale", key="scale", min=80, max=120, step=5, value=100, unit="%" },
                },
            },
        },
    },
}

--==========================================================================
--  STATE
--==========================================================================
local state    = {}
local defaults = {}
for _, pg in ipairs(PAGES) do
    for _, cd in ipairs(pg.cards) do
        for _, row in ipairs(cd.rows) do
            if row.type ~= "button" and defaults[row.key] == nil then
                defaults[row.key] = row.value
                -- seed from kicia store first
                local v = row.Config and kGet(row.Config)
                state[row.key] = v ~= nil and v or row.value
            end
        end
    end
end
state.theme      = state.theme      or "glass"
state.animations = state.animations ~= false and true or false

--==========================================================================
--  THEME STYLES
--==========================================================================
local THEME_STYLES = {
    glass = {
        interfaceScale = 1,
        accent = COLORS.Accent, knobColor = COLORS.AccentBright,
        panelColor = COLORS.Panel, railColor = COLORS.White, cardColor = COLORS.White,
        edgeColor = COLORS.White,
        panelTransparency = 0.32, railTransparency = 0.965,
        cardTransparency = 0.93, cardHoverTransparency = 0.90,
        cardStrokeTransparency = 0.84, cardHoverStrokeTransparency = 0.76,
        userTransparency = 0.94, sessionTransparency = 0.35,
        pillTransparency = 0.90, backdropTransparency = 0.72, blurSize = 14,
    },
    compact = {
        interfaceScale = 0.92,
        accent = Color3.fromRGB(255,126,136), knobColor = Color3.fromRGB(255,232,234),
        panelColor = Color3.fromRGB(8,7,9), railColor = Color3.fromRGB(10,7,9),
        cardColor = Color3.fromRGB(27,14,17), edgeColor = Color3.fromRGB(255,145,154),
        panelTransparency = 0.08, railTransparency = 0.22,
        cardTransparency = 0.22, cardHoverTransparency = 0.14,
        cardStrokeTransparency = 0.70, cardHoverStrokeTransparency = 0.58,
        userTransparency = 0.72, sessionTransparency = 0.16,
        pillTransparency = 0.76, backdropTransparency = 0.84, blurSize = 4,
    },
}

local function themeStyle() return THEME_STYLES[state.theme] or THEME_STYLES.glass end
local function animEnabled() return state.animations ~= false end
local function motDur(n) return animEnabled() and n or 0.01 end
local function motDel(n) return animEnabled() and n or 0 end

local applyTheme, updateResponsiveScale, refreshCurrentPage

--==========================================================================
--  BLUR + SCREEN
--==========================================================================
local blur = create("BlurEffect", { Parent = Lighting, Name = "NimbusGlassBlur", Size = 0 })
playTween(blur, 0.45, { Size = 14 })

local screenGui = create("ScreenGui", {
    Parent = playerGui, Name = "NimbusGlassUI",
    IgnoreGuiInset = true, ResetOnSpawn = false, DisplayOrder = 40,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local backdrop = create("Frame", {
    Parent = screenGui, Name = "BackdropTint",
    Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.fromRGB(11,20,27),
    BackgroundTransparency = 0.72, BorderSizePixel = 0,
})
create("UIGradient", { Parent = backdrop, Rotation = 90, Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40,74,103)),
    ColorSequenceKeypoint.new(0.48, Color3.fromRGB(21,43,49)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10,21,18)),
}) })

--==========================================================================
--  WINDOW SHELL
--==========================================================================
local shell = create("CanvasGroup", {
    Parent = screenGui, Name = "WindowShell",
    AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5),
    Size = UDim2.fromOffset(1040,650), BackgroundTransparency = 1, BorderSizePixel = 0,
})
local responsiveScale = create("UIScale", { Parent = shell, Scale = 1 })

local shadow = create("Frame", {
    Parent = shell, Name = "Shadow", Position = UDim2.fromOffset(0,18),
    Size = UDim2.fromScale(1,1), BackgroundColor3 = COLORS.Shadow,
    BackgroundTransparency = 0.56, BorderSizePixel = 0,
})
addCorner(shadow, 22)

local panel = create("Frame", {
    Parent = shell, Name = "GlassWindow", Size = UDim2.fromScale(1,1),
    BackgroundColor3 = COLORS.Panel, BackgroundTransparency = 0.32,
    BorderSizePixel = 0, ClipsDescendants = true,
})
local panelCorner  = addCorner(panel, 18)
local panelStroke  = addStroke(panel, 0.78)
local panelGradient = create("UIGradient", { Parent = panel, Rotation = 90, Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, COLORS.PanelTop), ColorSequenceKeypoint.new(1, COLORS.PanelBottom),
}) })

create("Frame", { Parent = panel, Name = "TopHighlight",
    Position = UDim2.fromOffset(18,0), Size = UDim2.new(1,-36,0,1),
    BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.76, BorderSizePixel = 0,
})

--==========================================================================
--  TITLE BAR
--==========================================================================
local titleBar = create("CanvasGroup", {
    Parent = panel, Name = "TitleBar",
    Size = UDim2.new(1,0,0,68), BackgroundTransparency = 1, Active = true,
})
create("TextLabel", { Parent = titleBar, Position = UDim2.fromOffset(24,14),
    Size = UDim2.fromOffset(400,24), BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold, Text = "KiciaHook  ·  Rivals",
    TextColor3 = COLORS.Ink, TextSize = 19, TextXAlignment = Enum.TextXAlignment.Left,
})
create("TextLabel", { Parent = titleBar, Position = UDim2.fromOffset(24,39),
    Size = UDim2.fromOffset(400,16), BackgroundTransparency = 1,
    Font = Enum.Font.Gotham, Text = "Premium Build  ·  Nimbus Shell",
    TextColor3 = COLORS.InkFaint, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
})
create("Frame", { Parent = panel, Position = UDim2.fromOffset(0,67),
    Size = UDim2.new(1,0,0,1), BackgroundColor3 = COLORS.White,
    BackgroundTransparency = 0.92, BorderSizePixel = 0,
})

local function makeWinBtn(text, offset)
    local btn = create("TextButton", {
        Parent = titleBar, AnchorPoint = Vector2.new(1,0),
        Position = UDim2.new(1, offset, 0, 19), Size = UDim2.fromOffset(34,28),
        BackgroundColor3 = COLORS.White, BackgroundTransparency = 1, BorderSizePixel = 0,
        AutoButtonColor = false, Font = Enum.Font.GothamMedium,
        Text = text, TextColor3 = COLORS.InkDim, TextSize = 16,
    })
    addCorner(btn, 8)
    local s = addStroke(btn, 1)
    btn.MouseEnter:Connect(function()
        playTween(btn, 0.16, { BackgroundTransparency = 0.90, TextColor3 = COLORS.Ink })
        playTween(s, 0.16, { Transparency = 0.86 })
    end)
    btn.MouseLeave:Connect(function()
        playTween(btn, 0.16, { BackgroundTransparency = 1, TextColor3 = COLORS.InkDim })
        playTween(s, 0.16, { Transparency = 1 })
    end)
    return btn
end
local minimizeButton = makeWinBtn("—", -58)
local closeButton    = makeWinBtn("×", -18)

--==========================================================================
--  BODY / RAIL / NAV
--==========================================================================
local body = create("Frame", {
    Parent = panel, Name = "Body", Position = UDim2.fromOffset(0,68),
    Size = UDim2.new(1,0,1,-68), BackgroundTransparency = 1, ClipsDescendants = true,
})

local rail = create("CanvasGroup", {
    Parent = body, Name = "Rail", Size = UDim2.new(0,220,1,0),
    BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.965,
    BorderSizePixel = 0, ClipsDescendants = true,
})
create("Frame", { Parent = rail, AnchorPoint = Vector2.new(1,0),
    Position = UDim2.new(1,0,0,0), Size = UDim2.new(0,1,1,0),
    BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.92, BorderSizePixel = 0,
})

local navHolder = create("Frame", {
    Parent = rail, Position = UDim2.fromOffset(14,10),
    Size = UDim2.new(1,-28,0,#PAGES*44+10), BackgroundTransparency = 1,
})

local navPill = create("Frame", {
    Parent = navHolder, Name = "ActivePill",
    Position = UDim2.fromOffset(0,0), Size = UDim2.new(1,0,0,40),
    BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.90, BorderSizePixel = 0,
})
local navPillCorner = addCorner(navPill, 10)
local navPillStroke = addStroke(navPill, 0.84)

-- user card
local userCard = create("TextButton", {
    Parent = rail, Name = "UserCard", AnchorPoint = Vector2.new(0,1),
    Position = UDim2.new(0,14,1,-14), Size = UDim2.new(1,-28,0,54),
    BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.94,
    BorderSizePixel = 0, AutoButtonColor = false, Text = "", ClipsDescendants = true,
})
local userCardCorner = addCorner(userCard, 12)
local userStroke     = addStroke(userCard, 0.90)
local userAvatar     = create("Frame", {
    Parent = userCard, Position = UDim2.fromOffset(11,12), Size = UDim2.fromOffset(30,30),
    BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.87, BorderSizePixel = 0,
})
addCorner(userAvatar, 15); addStroke(userAvatar, 0.86)
create("TextLabel", { Parent = userAvatar, Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium, Text = string.sub(player.Name, 1, 1):upper(),
    TextColor3 = COLORS.InkDim, TextSize = 11,
})
local userNameLabel = create("TextLabel", { Parent = userCard, Position = UDim2.fromOffset(51,10),
    Size = UDim2.new(1,-78,0,18), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
    Text = player.Name, TextColor3 = COLORS.Ink, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
})
create("TextLabel", { Parent = userCard, Position = UDim2.fromOffset(51,28),
    Size = UDim2.new(1,-78,0,15), BackgroundTransparency = 1, Font = Enum.Font.Gotham,
    Text = "KiciaHook session", TextColor3 = COLORS.InkFaint, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
})
userCard.MouseEnter:Connect(function()
    playTween(userCard, motDur(0.18), { BackgroundTransparency = 0.90 })
    playTween(userStroke, motDur(0.18), { Transparency = 0.82 })
end)
userCard.MouseLeave:Connect(function()
    playTween(userCard, motDur(0.18), { BackgroundTransparency = 0.94 })
    playTween(userStroke, motDur(0.18), { Transparency = 0.90 })
end)

--==========================================================================
--  CONTENT AREA
--==========================================================================
local mainScroll = create("ScrollingFrame", {
    Parent = body, Name = "Content", Position = UDim2.fromOffset(220,0),
    Size = UDim2.new(1,-220,1,0), BackgroundTransparency = 1, BorderSizePixel = 0,
    CanvasSize = UDim2.fromOffset(0,0), ScrollBarThickness = 4,
    ScrollBarImageColor3 = COLORS.White, ScrollBarImageTransparency = 0.78,
    ScrollingDirection = Enum.ScrollingDirection.Y,
})
local contentInner = create("Frame", {
    Parent = mainScroll, Name = "CardGrid", Position = UDim2.fromOffset(20,18),
    Size = UDim2.new(1,-40,0,0), BackgroundTransparency = 1,
})
local grid = create("UIGridLayout", {
    Parent = contentInner, CellPadding = UDim2.fromOffset(16,16),
    CellSize = UDim2.new(0.5,-8,0,234), FillDirection = Enum.FillDirection.Horizontal,
    FillDirectionMaxCells = 2, HorizontalAlignment = Enum.HorizontalAlignment.Left,
    SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Top,
})

local function updateCanvas()
    local h = grid.AbsoluteContentSize.Y
    contentInner.Size = UDim2.new(1,-40,0,h)
    mainScroll.CanvasSize = UDim2.fromOffset(0, h+36)
end
grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

--==========================================================================
--  TOAST
--==========================================================================
local toastGroup = create("CanvasGroup", {
    Parent = screenGui, Name = "Toast", AnchorPoint = Vector2.new(0.5,1),
    Position = UDim2.new(0.5,0,1,-20), Size = UDim2.fromOffset(360,42),
    BackgroundColor3 = COLORS.Panel, BackgroundTransparency = 0.28,
    BorderSizePixel = 0, GroupTransparency = 1, Visible = false,
})
addCorner(toastGroup, 12); addStroke(toastGroup, 0.82)
local toastLabel = create("TextLabel", {
    Parent = toastGroup, Size = UDim2.new(1,-24,1,0), Position = UDim2.fromOffset(12,0),
    BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = "",
    TextColor3 = COLORS.InkDim, TextSize = 11,
})
local toastSerial = 0
local function showToast(msg)
    toastSerial += 1; local serial = toastSerial
    toastLabel.Text = msg; toastGroup.Visible = true
    toastGroup.GroupTransparency = 1
    toastGroup.Position = UDim2.new(0.5,0,1,-14)
    playTween(toastGroup, motDur(0.25), { GroupTransparency=0, Position=UDim2.new(0.5,0,1,-26) })
    task.delay(2.2, function()
        if serial ~= toastSerial then return end
        local f = playTween(toastGroup, motDur(0.22), { GroupTransparency=1, Position=UDim2.new(0.5,0,1,-18) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        f.Completed:Once(function() if serial==toastSerial then toastGroup.Visible=false end end)
    end)
end
userCard.Activated:Connect(function() showToast(player.Name.." · KiciaHook session") end)

--==========================================================================
--  PAGE CONNECTIONS
--==========================================================================
local pageConnections = {}
local function trackConn(c) table.insert(pageConnections, c); return c end
local function clearPageConns()
    for _, c in ipairs(pageConnections) do c:Disconnect() end
    table.clear(pageConnections)
end

--==========================================================================
--  ROW WIDGET FACTORIES
--==========================================================================
local function fmtVal(v)
    if math.abs(v - math.floor(v)) < 0.0001 then return tostring(math.floor(v)) end
    return string.format("%.1f", v)
end

local function createToggle(parent, row)
    local toggle = create("TextButton", {
        Parent = parent, AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,-14,0.5,0), Size = UDim2.fromOffset(44,24),
        BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.86,
        BorderSizePixel = 0, AutoButtonColor = false, Text = "",
    })
    addCorner(toggle, 12)
    toggle:SetAttribute("NimbusToggleKey", row.key)
    local tStroke = addStroke(toggle, 0.86)
    local knob = create("Frame", {
        Parent = toggle, Name = "Knob", AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromOffset(12,12), Size = UDim2.fromOffset(17,17),
        BackgroundColor3 = Color3.fromRGB(236,243,249), BackgroundTransparency = 0.05, BorderSizePixel = 0,
    })
    addCorner(knob, 9); addStroke(knob, 0.80)

    local function refresh(instant)
        local en = state[row.key] == true
        local sty = themeStyle()
        local tc = en and sty.accent or COLORS.White
        local tt = en and 0.67 or 0.86
        local ts = en and 0.55 or 0.86
        local tp = en and UDim2.fromOffset(32,12) or UDim2.fromOffset(12,12)
        local kc = en and sty.knobColor or Color3.fromRGB(236,243,249)
        if instant then
            toggle.BackgroundColor3 = tc; toggle.BackgroundTransparency = tt
            tStroke.Transparency = ts; knob.Position = tp; knob.BackgroundColor3 = kc
        else
            playTween(toggle, motDur(0.22), { BackgroundColor3=tc, BackgroundTransparency=tt })
            playTween(tStroke, motDur(0.22), { Transparency=ts })
            playTween(knob, motDur(0.24), { Position=tp, BackgroundColor3=kc }, Enum.EasingStyle.Back)
            if animEnabled() then knob.Size=UDim2.fromOffset(19,19); playTween(knob,0.18,{Size=UDim2.fromOffset(17,17)}) end
        end
    end

    toggle.Activated:Connect(function()
        state[row.key] = not state[row.key]
        if row.Config then kSet(row.Config, state[row.key]) end
        refresh(false)
        if (row.key=="animations" or row.key=="theme") and applyTheme then applyTheme(false) end
    end)
    refresh(true)
end

local function createSlider(parent, row)
    local wrap = create("Frame", {
        Parent = parent, AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,-12,0.5,0), Size = UDim2.fromOffset(178,30), BackgroundTransparency = 1,
    })
    local track = create("Frame", {
        Parent = wrap, Position = UDim2.fromOffset(2,13), Size = UDim2.fromOffset(120,4),
        BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.84, BorderSizePixel = 0,
    })
    addCorner(track, 2)
    local fill = create("Frame", { Parent = track, Name = "AccentFill",
        Size = UDim2.fromScale(0.5,1), BackgroundColor3 = themeStyle().accent,
        BackgroundTransparency = 0.12, BorderSizePixel = 0,
    })
    addCorner(fill, 2)
    local knob = create("Frame", { Parent = track, Name = "AccentKnob",
        AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5),
        Size = UDim2.fromOffset(15,15), BackgroundColor3 = themeStyle().knobColor,
        BackgroundTransparency = 0, BorderSizePixel = 0,
    })
    addCorner(knob, 8); addStroke(knob, 0.58)
    local output = create("TextLabel", {
        Parent = wrap, AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,0,0,0),
        Size = UDim2.fromOffset(48,30), BackgroundTransparency = 1, Font = Enum.Font.Gotham,
        Text = "", TextColor3 = COLORS.InkDim, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right,
    })
    local hit = create("TextButton", { Parent = wrap, Position = UDim2.fromOffset(-4,1),
        Size = UDim2.fromOffset(132,28), BackgroundTransparency = 1, BorderSizePixel = 0,
        AutoButtonColor = false, Text = "",
    })

    local function refresh()
        local v = state[row.key]
        local a = math.clamp((v-row.min)/(row.max-row.min),0,1)
        fill.Size = UDim2.fromScale(a,1); knob.Position = UDim2.fromScale(a,0.5)
        output.Text = fmtVal(v)..(row.unit or "")
    end

    local function setX(sx)
        local w = math.max(track.AbsoluteSize.X,1)
        local a = math.clamp((sx-track.AbsolutePosition.X)/w,0,1)
        local raw = row.min+(row.max-row.min)*a
        local steps = math.floor(((raw-row.min)/row.step)+0.5)
        state[row.key] = math.clamp(row.min+steps*row.step, row.min, row.max)
        if row.Config then kSet(row.Config, state[row.key]) end
        refresh()
    end

    local dragging, dragInput = false, nil
    hit.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragInput=inp; setX(inp.Position.X)
            playTween(knob, motDur(0.12), { Size=UDim2.fromOffset(18,18) })
        end
    end)
    trackConn(UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement or inp==dragInput then setX(inp.Position.X) end
    end))
    trackConn(UserInputService.InputEnded:Connect(function(inp)
        if not dragging then return end
        if inp==dragInput or inp.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=false; dragInput=nil
            playTween(knob, motDur(0.14), { Size=UDim2.fromOffset(15,15) })
        end
    end))
    refresh()
end

-- DROPDOWN — click opens overlay list
local function createDropdown(parent, row)
    local wrap = create("TextButton", {
        Parent = parent, AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,-14,0.5,0), Size = UDim2.fromOffset(140,26),
        BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.92,
        BorderSizePixel = 0, AutoButtonColor = false, Text = "",
    })
    addCorner(wrap, 8); addStroke(wrap, 0.80)

    local valLabel = create("TextLabel", {
        Parent = wrap, Position = UDim2.fromOffset(8,0),
        Size = UDim2.new(1,-26,1,0), BackgroundTransparency = 1, Font = Enum.Font.Gotham,
        Text = tostring(state[row.key]), TextColor3 = COLORS.Ink, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    })
    create("TextLabel", {
        Parent = wrap, AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-6,0.5,0),
        Size = UDim2.fromOffset(14,14), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
        Text = "▾", TextColor3 = COLORS.InkFaint, TextSize = 10,
    })

    -- overlay
    local overlay = create("Frame", {
        Parent = screenGui, BackgroundColor3 = Color3.fromRGB(18,28,38),
        BackgroundTransparency = 0.04, BorderSizePixel = 0, Visible = false,
        ZIndex = 200, Size = UDim2.fromOffset(160, math.min(#row.options,6)*28+6),
    })
    addCorner(overlay, 8); addStroke(overlay, 0.70)
    local listLayout = create("UIListLayout", { Parent = overlay, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,2) })
    create("UIPadding", { Parent = overlay, PaddingTop=UDim.new(0,3), PaddingBottom=UDim.new(0,3), PaddingLeft=UDim.new(0,3), PaddingRight=UDim.new(0,3) })

    local optBtns = {}
    for _, opt in ipairs(row.options) do
        local ob = create("TextButton", {
            Parent = overlay, Size = UDim2.new(1,-6,0,26),
            BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.96,
            BorderSizePixel = 0, AutoButtonColor = false, Font = Enum.Font.Gotham,
            Text = opt, TextColor3 = COLORS.InkDim, TextSize = 11, ZIndex = 201,
        })
        addCorner(ob, 5)
        table.insert(optBtns, ob)
        ob.MouseEnter:Connect(function()
            playTween(ob, 0.12, { BackgroundTransparency=0.88, TextColor3=COLORS.Ink })
        end)
        ob.MouseLeave:Connect(function()
            playTween(ob, 0.12, { BackgroundTransparency=0.96, TextColor3=COLORS.InkDim })
        end)
        ob.Activated:Connect(function()
            state[row.key] = opt
            if row.Config then kSet(row.Config, opt) end
            valLabel.Text = opt
            overlay.Visible = false
            showToast(row.label.." → "..opt)
        end)
    end

    local overlayOpen = false
    wrap.Activated:Connect(function()
        overlayOpen = not overlayOpen
        if overlayOpen then
            local abs = wrap.AbsolutePosition
            local sz  = wrap.AbsoluteSize
            overlay.Position = UDim2.fromOffset(abs.X, abs.Y + sz.Y + 4)
            overlay.Size = UDim2.fromOffset(math.max(160, sz.X), math.min(#row.options,6)*28+6)
            overlay.Visible = true
        else
            overlay.Visible = false
        end
    end)

    -- close on outside click
    trackConn(UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            if overlayOpen then
                overlayOpen = false
                overlay.Visible = false
            end
        end
    end))
end

-- SCROLLWHEEL — left/right arrows to cycle options inline
local function createScrollwheel(parent, row)
    local wrap = create("Frame", {
        Parent = parent, AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,-14,0.5,0), Size = UDim2.fromOffset(166,26),
        BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.92,
        BorderSizePixel = 0,
    })
    addCorner(wrap, 8); addStroke(wrap, 0.80)

    local leftBtn = create("TextButton", {
        Parent = wrap, Size = UDim2.fromOffset(24,26),
        BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false,
        Font = Enum.Font.GothamBold, Text = "‹", TextColor3 = COLORS.InkFaint, TextSize = 14,
    })
    local rightBtn = create("TextButton", {
        Parent = wrap, AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,0,0,0),
        Size = UDim2.fromOffset(24,26), BackgroundTransparency = 1, BorderSizePixel = 0,
        AutoButtonColor = false, Font = Enum.Font.GothamBold, Text = "›",
        TextColor3 = COLORS.InkFaint, TextSize = 14,
    })
    local valLabel = create("TextLabel", {
        Parent = wrap, Position = UDim2.fromOffset(24,0), Size = UDim2.new(1,-48,1,0),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham,
        Text = tostring(state[row.key]), TextColor3 = COLORS.Ink, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd,
    })

    local opts = row.options
    local function currentIdx()
        for i, v in ipairs(opts) do if v == state[row.key] then return i end end
        return 1
    end
    local function apply(idx)
        local clamped = ((idx-1) % #opts)+1
        state[row.key] = opts[clamped]
        if row.Config then kSet(row.Config, opts[clamped]) end
        valLabel.Text = opts[clamped]
    end

    leftBtn.Activated:Connect(function() apply(currentIdx()-1) end)
    rightBtn.Activated:Connect(function() apply(currentIdx()+1) end)
end

local function createThemeSelector(parent, row)
    local wrap = create("Frame", {
        Parent = parent, AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,-14,0.5,0), Size = UDim2.fromOffset(166,30),
        BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.94, BorderSizePixel = 0,
    })
    addCorner(wrap, 9); addStroke(wrap, 0.84)
    local sel = create("Frame", { Parent = wrap, Name = "AccentSelection",
        Position = UDim2.fromOffset(3,3), Size = UDim2.fromOffset(79,24),
        BackgroundColor3 = themeStyle().accent, BackgroundTransparency = 0.70, BorderSizePixel = 0,
    })
    addCorner(sel, 7)
    local selStroke = addStroke(sel, 0.70, themeStyle().accent); selStroke.Name = "AccentStroke"

    local opts = { {id="glass",label="Glass"}, {id="compact",label="Compact"} }
    local btns = {}
    local function refresh(instant)
        local pos = state[row.key]=="compact" and UDim2.fromOffset(84,3) or UDim2.fromOffset(3,3)
        if instant or not animEnabled() then sel.Position=pos
        else playTween(sel,0.30,{Position=pos}) end
        for _, o in ipairs(btns) do
            local c = o.id==state[row.key] and COLORS.Ink or COLORS.InkDim
            if instant then o.btn.TextColor3=c else playTween(o.btn,0.18,{TextColor3=c}) end
        end
    end
    for i, opt in ipairs(opts) do
        local b = create("TextButton", {
            Parent = wrap, Position = UDim2.fromOffset((i-1)*81+3,3),
            Size = UDim2.fromOffset(79,24), BackgroundTransparency = 1, BorderSizePixel = 0,
            AutoButtonColor = false, Font = Enum.Font.GothamMedium,
            Text = opt.label, TextColor3 = COLORS.InkDim, TextSize = 10,
        })
        table.insert(btns, {id=opt.id, btn=b})
        b.Activated:Connect(function()
            if state[row.key]==opt.id then return end
            state[row.key]=opt.id; refresh(false)
            if applyTheme then applyTheme(true) end
            if refreshCurrentPage then refreshCurrentPage() end
            showToast(opt.label.." theme selected.")
        end)
    end
    refresh(true)
end

local function createActionButton(parent, row)
    local btn = create("TextButton", {
        Parent = parent, AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,-14,0.5,0), Size = UDim2.fromOffset(74,30),
        BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.94, BorderSizePixel = 0,
        AutoButtonColor = false, Font = Enum.Font.GothamMedium, Text = row.button,
        TextColor3 = COLORS.InkDim, TextSize = 11,
    })
    addCorner(btn, 8); local bs = addStroke(btn, 0.84)
    btn.MouseEnter:Connect(function()
        playTween(btn,0.16,{BackgroundTransparency=0.88,TextColor3=COLORS.Ink})
        playTween(bs,0.16,{Transparency=0.76})
    end)
    btn.MouseLeave:Connect(function()
        playTween(btn,0.16,{BackgroundTransparency=0.94,TextColor3=COLORS.InkDim})
        playTween(bs,0.16,{Transparency=0.84})
    end)
    btn.Activated:Connect(function()
        if row.key == "unload" then
            local K = getgenv and getgenv().KiciaRebuild
            if K and K.Unload then pcall(K.Unload) end
            showToast("KiciaHook unloaded.")
        elseif row.key == "cfgSave" then
            local K = getgenv and getgenv().KiciaRebuild
            if K then showToast("Config save not yet wired.") end
        elseif row.key == "cfgLoad" then
            showToast("Config load not yet wired.")
        elseif row.key == "cfgReset" then
            for k, v in pairs(defaults) do state[k] = v end
            if applyTheme then applyTheme(true) end
            showToast("Defaults restored.")
        elseif row.key == "cosmeticsReroll" then
            showToast("Reroll: wire to Kicia cosmetics module.")
        else
            showToast(row.label)
        end
    end)
end

--==========================================================================
--  ROW / CARD BUILDERS
--==========================================================================
local function createRow(card, row, rowIdx, animate)
    local r = create("CanvasGroup", {
        Parent = card, Name = "Row_"..row.key,
        Position = UDim2.fromOffset(14, 43+(rowIdx-1)*44),
        Size = UDim2.new(1,-28,0,44), BackgroundTransparency = 1, BorderSizePixel = 0,
        GroupTransparency = animate and 1 or 0,
    })
    if rowIdx > 1 then
        create("Frame", { Parent = r, Position = UDim2.fromOffset(0,0), Size = UDim2.new(1,0,0,1),
            BackgroundColor3 = COLORS.White, BackgroundTransparency = 0.93, BorderSizePixel = 0,
        })
    end
    local inner = create("Frame", {
        Parent = r, Name = "Inner",
        Position = animate and UDim2.fromOffset(-10,0) or UDim2.fromOffset(0,0),
        Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
    })
    create("TextLabel", {
        Parent = inner, Position = UDim2.fromOffset(2,0),
        Size = UDim2.new(1,-202,1,0), BackgroundTransparency = 1, Font = Enum.Font.Gotham,
        Text = row.label, TextColor3 = Color3.fromRGB(218,230,239), TextTransparency = 0.10,
        TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left,
    })
    if     row.type == "toggle"      then createToggle(inner, row)
    elseif row.type == "slider"      then createSlider(inner, row)
    elseif row.type == "dropdown"    then createDropdown(inner, row)
    elseif row.type == "scrollwheel" then createScrollwheel(inner, row)
    elseif row.type == "theme"       then createThemeSelector(inner, row)
    else                                  createActionButton(inner, row)
    end
    return r, inner
end

local currentPage  = "combat"
local currentCards = {}
local transitionSerial = 0
local renderPage, transitionTo

local function createCard(cardData, cardIdx, animate)
    local sty = themeStyle()
    local card = create("CanvasGroup", {
        Parent = contentInner, Name = "Card_"..cardData.title:gsub("%W",""),
        LayoutOrder = cardIdx, BackgroundColor3 = sty.cardColor,
        BackgroundTransparency = sty.cardTransparency, BorderSizePixel = 0,
        GroupTransparency = animate and 1 or 0, Active = true,
    })
    local cCorner = addCorner(card, 14)
    local cStroke = addStroke(card, sty.cardStrokeTransparency, sty.edgeColor)
    create("UIGradient", { Parent = card, Rotation = 90, Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(188,208,220)),
    }) })
    local cScale = create("UIScale", { Parent = card, Scale = animate and 0.965 or 1 })

    local icon = create("TextLabel", {
        Parent = card, Position = UDim2.fromOffset(16,12), Size = UDim2.fromOffset(22,22),
        BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = cardData.icon,
        TextColor3 = sty.accent, TextTransparency = 0.10, TextSize = 16, Name = "Icon",
    })
    create("TextLabel", {
        Parent = card, Position = UDim2.fromOffset(44,10), Size = UDim2.new(1,-60,0,26),
        BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = cardData.title,
        TextColor3 = COLORS.Ink, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    })

    local rows = {}
    for ri, rd in ipairs(cardData.rows) do
        local rg, ri_ = createRow(card, rd, ri, animate)
        table.insert(rows, {group=rg, inner=ri_})
    end

    card.MouseEnter:Connect(function()
        local s = themeStyle()
        playTween(cScale, motDur(0.28), { Scale=1.012 })
        playTween(card,   motDur(0.28), { BackgroundTransparency=s.cardHoverTransparency })
        playTween(cStroke,motDur(0.28), { Transparency=s.cardHoverStrokeTransparency })
    end)
    card.MouseLeave:Connect(function()
        local s = themeStyle()
        playTween(cScale, motDur(0.28), { Scale=1 })
        playTween(card,   motDur(0.28), { BackgroundTransparency=s.cardTransparency })
        playTween(cStroke,motDur(0.28), { Transparency=s.cardStrokeTransparency })
    end)

    return { group=card, scale=cScale, stroke=cStroke, corner=cCorner, icon=icon, rows=rows }
end

local function findPage(id)
    for _, pg in ipairs(PAGES) do if pg.id==id then return pg end end
    return PAGES[1]
end

renderPage = function(pageId, animate)
    clearPageConns()
    for _, ch in ipairs(contentInner:GetChildren()) do
        if ch ~= grid then ch:Destroy() end
    end
    table.clear(currentCards)
    mainScroll.CanvasPosition = Vector2.zero
    local pg = findPage(pageId)
    for ci, cd in ipairs(pg.cards) do
        local info = createCard(cd, ci, animate)
        table.insert(currentCards, info)
        if animate then
            local d = motDel((ci-1)*0.07)
            playTween(info.group, motDur(0.55), {GroupTransparency=0}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, d)
            playTween(info.scale, motDur(0.55), {Scale=1},             Enum.EasingStyle.Quint, Enum.EasingDirection.Out, d)
            for ri, rinfo in ipairs(info.rows) do
                local rd = motDel(d+0.08+(ri-1)*0.04)
                playTween(rinfo.group, motDur(0.45), {GroupTransparency=0}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, rd)
                playTween(rinfo.inner, motDur(0.45), {Position=UDim2.fromOffset(0,0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, rd)
            end
        end
    end
    task.defer(updateCanvas)
end

--==========================================================================
--  NAV ENTRIES — with kicia asset icon images
--==========================================================================
local navEntries = {}
local switchPageFromNav
local refreshNavigation

for idx, pg in ipairs(PAGES) do
    local btn = create("TextButton", {
        Parent = navHolder, Name = "Nav_"..pg.id,
        Position = UDim2.fromOffset(0,(idx-1)*44), Size = UDim2.new(1,0,0,40),
        BackgroundColor3 = COLORS.White, BackgroundTransparency = 1, BorderSizePixel = 0,
        AutoButtonColor = false, Text = "",
    })
    addCorner(btn, 10)

    -- use kicia's actual rbxassetid as ImageLabel
    local iconImg = create("ImageLabel", {
        Parent = btn, Position = UDim2.fromOffset(9,8), Size = UDim2.fromOffset(24,24),
        BackgroundTransparency = 1, Image = pg.icon,
        ImageColor3 = COLORS.InkDim, ImageTransparency = 0,
    })

    local lbl = create("TextLabel", {
        Parent = btn, Position = UDim2.fromOffset(40,0), Size = UDim2.new(1,-50,1,0),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = pg.label,
        TextColor3 = COLORS.InkDim, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
    })

    local entry = { id=pg.id, index=idx, button=btn, icon=iconImg, label=lbl }
    table.insert(navEntries, entry)

    btn.MouseEnter:Connect(function()
        if currentPage ~= pg.id then
            playTween(btn, 0.16, { BackgroundTransparency=0.95 })
            playTween(iconImg, 0.16, { ImageColor3=COLORS.Ink })
            playTween(lbl, 0.16, { TextColor3=COLORS.Ink })
        end
    end)
    btn.MouseLeave:Connect(function()
        playTween(btn, 0.16, { BackgroundTransparency=1 })
        if currentPage ~= pg.id then
            playTween(iconImg, 0.16, { ImageColor3=COLORS.InkDim })
            playTween(lbl, 0.16, { TextColor3=COLORS.InkDim })
        end
    end)
    btn.Activated:Connect(function()
        switchPageFromNav(pg.id)
    end)
end

refreshNavigation = function(animPill)
    local active = navEntries[1]
    for _, e in ipairs(navEntries) do
        local isActive = e.id == currentPage
        if isActive then active = e end
        local c = isActive and COLORS.Ink or COLORS.InkDim
        if animPill then
            playTween(e.icon,  motDur(0.22), { ImageColor3=c })
            playTween(e.label, motDur(0.22), { TextColor3=c })
        else
            e.icon.ImageColor3 = c
            e.label.TextColor3 = c
        end
    end
    local tp = active.button.Position
    local ts = active.button.Size
    if animPill then
        playTween(navPill, motDur(0.48), { Position=tp, Size=ts }, Enum.EasingStyle.Back)
    else
        navPill.Position = tp; navPill.Size = ts
    end
end

local compactExpanded = false
local function setRailLayout(expanded, animate)
    local compact = state.theme == "compact"
    compactExpanded = compact and expanded or false
    local width = compact and (compactExpanded and 204 or 62) or 220
    local inset = compact and (compactExpanded and 10 or 8) or 14
    local labelsVisible = not compact or compactExpanded
    local dur = animate and animEnabled() and 0.56 or 0

    local function setOrTween(obj, goals)
        if dur > 0 then playTween(obj, dur, goals) else for k,v in pairs(goals) do obj[k]=v end end
    end
    local function setLabelVis(lbl)
        local tt = labelsVisible and 0 or 1
        if dur > 0 then
            playTween(lbl, labelsVisible and 0.24 or 0.14, {TextTransparency=tt},
                Enum.EasingStyle.Quad, Enum.EasingDirection.Out, labelsVisible and 0.14 or 0)
        else lbl.TextTransparency = tt end
    end
    local function setIconTrans(img)
        local it = labelsVisible and 0 or 0
        if dur > 0 then playTween(img, 0.2, {ImageTransparency=it}) else img.ImageTransparency=it end
    end

    setOrTween(rail, { Size=UDim2.new(0,width,1,0) })
    setOrTween(mainScroll, { Position=UDim2.fromOffset(width,0), Size=UDim2.new(1,-width,1,0) })
    setOrTween(navHolder,  { Position=UDim2.fromOffset(inset, compact and 8 or 10), Size=UDim2.new(1,-(inset*2),0,#PAGES*44+10) })
    setOrTween(userCard,   { Position=UDim2.new(0,inset,1, compact and -10 or -14), Size=UDim2.new(1,-(inset*2),0,54) })

    setLabelVis(userNameLabel)
    for _, e in ipairs(navEntries) do
        setIconTrans(e.icon)
        setLabelVis(e.label)
        setOrTween(e.icon, { Position = compact and not compactExpanded
            and UDim2.new(0.5,-12,0,8) or UDim2.fromOffset(9,8) })
    end

    refreshNavigation(false)
    task.defer(function() refreshNavigation(false); updateCanvas() end)
end

rail.MouseEnter:Connect(function() if state.theme=="compact" then setRailLayout(true,true) end end)
rail.MouseLeave:Connect(function() if state.theme=="compact" then setRailLayout(false,true) end end)

transitionTo = function(pageId, force)
    if pageId == currentPage and not force then return end
    currentPage = pageId
    transitionSerial += 1
    local serial = transitionSerial
    refreshNavigation(true)

    if not animEnabled() or #currentCards == 0 then
        renderPage(currentPage, animEnabled())
        return
    end
    for i, ci in ipairs(currentCards) do
        local dt = (i-1)*0.025
        playTween(ci.group, 0.16, {GroupTransparency=1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In, dt)
        playTween(ci.scale, 0.16, {Scale=0.985},         Enum.EasingStyle.Quad, Enum.EasingDirection.In, dt)
    end
    local wait = 0.16 + math.max(0, #currentCards-1)*0.025
    task.delay(wait, function()
        if serial == transitionSerial then renderPage(currentPage, true) end
    end)
end

switchPageFromNav = function(id) transitionTo(id, false) end
refreshCurrentPage = function() transitionTo(currentPage, true) end

--==========================================================================
--  MINIMIZE / CLOSE / REOPEN
--==========================================================================
local minimized = false
local closed    = false
local visTransitioning = false
local interfaceTargetScale = 1
local positionBeforeClose = shell.Position
local FULL_SIZE = UDim2.fromOffset(1040,650)
local MIN_SIZE  = UDim2.fromOffset(1040,68)

minimizeButton.Activated:Connect(function()
    if closed or visTransitioning then return end
    minimized = not minimized
    if not minimized then body.Visible = true end
    minimizeButton.Text = minimized and "□" or "—"
    local tw = playTween(shell, motDur(0.34), { Size = minimized and MIN_SIZE or FULL_SIZE })
    if minimized then
        tw.Completed:Once(function() if minimized then body.Visible=false end end)
    end
end)

local reopenGroup = create("CanvasGroup", {
    Parent = screenGui, Name = "Reopen", AnchorPoint = Vector2.new(0.5,1),
    Position = UDim2.new(0.5,0,1,-22), Size = UDim2.fromOffset(210,38),
    BackgroundColor3 = COLORS.Panel, BackgroundTransparency = 0.25,
    BorderSizePixel = 0, GroupTransparency = 1, Visible = false,
})
addCorner(reopenGroup, 19); addStroke(reopenGroup, 0.80)
local reopenButton = create("TextButton", {
    Parent = reopenGroup, Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
    BorderSizePixel = 0, AutoButtonColor = false, Font = Enum.Font.GothamMedium,
    Text = "Reopen KiciaHook  ·  Right Shift", TextColor3 = COLORS.Ink, TextSize = 10,
})

closeButton.Activated:Connect(function()
    if closed or visTransitioning then return end
    closed = true; visTransitioning = true
    positionBeforeClose = shell.Position
    playTween(shell, motDur(0.28), { GroupTransparency=1, Size=UDim2.fromOffset(1040,640) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    playTween(backdrop, motDur(0.28), { BackgroundTransparency=1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    playTween(blur, motDur(0.28), { Size=0 })
    task.delay(motDur(0.28), function()
        shell.Visible = false; backdrop.Visible = false
        visTransitioning = false
        reopenGroup.Visible = true
        playTween(reopenGroup, motDur(0.24), { GroupTransparency=0 })
    end)
end)

reopenButton.Activated:Connect(function()
    if not closed then return end
    closed = false; visTransitioning = true
    shell.Visible = true; backdrop.Visible = true
    shell.GroupTransparency = 1
    shell.Position = positionBeforeClose
    playTween(reopenGroup, motDur(0.18), { GroupTransparency=1 })
    task.delay(motDur(0.18), function()
        reopenGroup.Visible = false
        playTween(shell, motDur(0.38), { GroupTransparency=0 })
        playTween(backdrop, motDur(0.38), { BackgroundTransparency=themeStyle().backdropTransparency })
        playTween(blur, motDur(0.38), { Size=themeStyle().blurSize })
        task.delay(motDur(0.38), function() visTransitioning=false end)
    end)
end)

UserInputService.InputBegan:Connect(function(inp, processed)
    if processed then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        if closed then
            reopenButton.Activated:Fire()
        else
            closeButton.Activated:Fire()
        end
    end
end)

--==========================================================================
--  DRAGGING
--==========================================================================
local draggingWindow = false
local dragStart, shellStart, dragInput

titleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
        draggingWindow=true; dragStart=inp.Position; shellStart=shell.Position
        inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then draggingWindow=false end end)
    end
end)
titleBar.InputChanged:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
        dragInput=inp
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if draggingWindow and inp==dragInput then
        local d = inp.Position-dragStart
        shell.Position = UDim2.new(shellStart.X.Scale, shellStart.X.Offset+d.X, shellStart.Y.Scale, shellStart.Y.Offset+d.Y)
        positionBeforeClose = shell.Position
    end
end)

--==========================================================================
--  APPLY THEME
--==========================================================================
local function setProperties(obj, goals, shouldAnimate)
    if shouldAnimate then playTween(obj, 0.34, goals) else for k,v in pairs(goals) do obj[k]=v end end
end

applyTheme = function(animateChange)
    local sty = themeStyle()
    local anim = animateChange and animEnabled()
    local function sp(obj, g) setProperties(obj, g, anim) end

    sp(panel,     { BackgroundColor3=sty.panelColor, BackgroundTransparency=sty.panelTransparency })
    sp(panelStroke,{Color=sty.edgeColor, Transparency=state.theme=="compact" and 0.72 or 0.78 })
    sp(rail,      { BackgroundColor3=sty.railColor, BackgroundTransparency=sty.railTransparency })
    sp(userCard,  { BackgroundColor3=sty.cardColor, BackgroundTransparency=sty.userTransparency })
    sp(userStroke,{ Color=sty.edgeColor })
    sp(navPill,   { BackgroundColor3=sty.accent, BackgroundTransparency=sty.pillTransparency })
    sp(navPillStroke,{Color=sty.edgeColor})
    sp(mainScroll,{ ScrollBarImageColor3=sty.accent })
    sp(shadow,    { BackgroundTransparency=state.theme=="compact" and 0.66 or 0.56 })
    sp(reopenGroup,{ BackgroundColor3=sty.panelColor, BackgroundTransparency=state.theme=="compact" and 0.14 or 0.25 })

    local compact = state.theme=="compact"
    setRailLayout(compactExpanded, anim)
    panelCorner.CornerRadius  = UDim.new(0, compact and 5 or 18)
    navPillCorner.CornerRadius = UDim.new(0, compact and 3 or 10)
    userCardCorner.CornerRadius = UDim.new(0, compact and 3 or 12)
    grid.CellPadding = compact and UDim2.fromOffset(10,10) or UDim2.fromOffset(16,16)
    grid.CellSize    = compact and UDim2.new(0.5,-5,0,226) or UDim2.new(0.5,-8,0,234)

    panelGradient.Color = compact and ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18,10,12)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(6,5,7)),
    }) or ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.PanelTop),
        ColorSequenceKeypoint.new(1, COLORS.PanelBottom),
    })

    for _, ci in ipairs(currentCards) do
        sp(ci.group,  {BackgroundColor3=sty.cardColor, BackgroundTransparency=sty.cardTransparency})
        sp(ci.stroke, {Color=sty.edgeColor, Transparency=sty.cardStrokeTransparency})
        sp(ci.icon,   {TextColor3=sty.accent})
        ci.corner.CornerRadius = UDim.new(0, compact and 3 or 14)
    end

    for _, d in ipairs(contentInner:GetDescendants()) do
        if d.Name=="AccentFill" or d.Name=="AccentSelection" then
            sp(d, {BackgroundColor3=sty.accent})
        elseif d.Name=="AccentKnob" then
            sp(d, {BackgroundColor3=sty.knobColor})
        elseif d.Name=="AccentStroke" and d:IsA("UIStroke") then
            sp(d, {Color=sty.accent})
        end
        local tk = d:GetAttribute("NimbusToggleKey")
        if tk then
            local en = state[tk]==true
            sp(d, {BackgroundColor3=en and sty.accent or COLORS.White})
            local kn = d:FindFirstChild("Knob")
            if kn then sp(kn, {BackgroundColor3=en and sty.knobColor or Color3.fromRGB(236,243,249)}) end
        end
    end

    if not closed then
        sp(backdrop, {BackgroundTransparency=sty.backdropTransparency})
        sp(blur, {Size=sty.blurSize})
    end

    updateResponsiveScale(anim)
    refreshNavigation(false)
    task.defer(function() refreshNavigation(false) end)
end

--==========================================================================
--  RESPONSIVE SCALE
--==========================================================================
updateResponsiveScale = function(animateChange)
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local fitX = (vp.X-28)/1040; local fitY = (vp.Y-28)/650
    local vs = math.clamp(math.min(fitX,fitY),0.45,1)
    interfaceTargetScale = math.max(0.42, vs * themeStyle().interfaceScale)
    if animateChange and animEnabled() and not closed then
        playTween(responsiveScale, 0.38, {Scale=interfaceTargetScale})
    else
        responsiveScale.Scale = interfaceTargetScale
    end
end

local viewportConn, cameraConn
local function bindCamera()
    if viewportConn then viewportConn:Disconnect(); viewportConn=nil end
    local cam = workspace.CurrentCamera
    if cam then
        viewportConn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale)
    end
    updateResponsiveScale()
end
cameraConn = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
bindCamera()

screenGui.AncestryChanged:Connect(function(_, parent)
    if parent==nil then
        if viewportConn then viewportConn:Disconnect() end
        if cameraConn  then cameraConn:Disconnect() end
        if blur.Parent then blur:Destroy() end
    end
end)

--==========================================================================
--  BOOT
--==========================================================================
refreshNavigation(false)
renderPage(currentPage, true)
applyTheme(false)
