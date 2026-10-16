--[[ luxxs v6.1 | DrHub | MM2 | Delta-ready | Aimbot + AutoWin + KillAura + Skins(hand+backpack) + Stretch + HSV + Escape toggle ]]
local __LX_ok,__LX_err = xpcall(function()

local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local Lighting     = game:GetService("Lighting")
local HttpService  = game:GetService("HttpService")
local VU           = game:GetService("VirtualUser")
local LP           = Players.LocalPlayer

if not LP then
    repeat task.wait(0.1) until Players.LocalPlayer
    LP = Players.LocalPlayer
end

local __errs = {}
local function __safe(name, f)
    local ok, e = xpcall(f, function(m) return tostring(m).."\n"..tostring(debug.traceback()) end)
    if not ok then
        __errs[#__errs+1] = name..": "..tostring(e)
        warn("[luxxs] module '"..name.."' failed: "..tostring(e))
    end
end

local FOLDER = "luxxs"
local TELEGRAM_LINK = "https://t.me/NurHuboffical"
local hasFS = type(writefile)=="function" and type(readfile)=="function" and type(isfile)=="function"
local function ensureFolder()
    if type(makefolder)=="function" and type(isfolder)=="function" and not isfolder(FOLDER) then
        pcall(makefolder, FOLDER)
    end
end

-- ========================= THEME =========================
local ACCENTS = {
    Lime   = Color3.fromRGB(196,255,61),
    Coral  = Color3.fromRGB(255,104,84),
    Ice    = Color3.fromRGB(110,214,255),
    Violet = Color3.fromRGB(158,110,255),
    Gold   = Color3.fromRGB(255,196,70),
    Rose   = Color3.fromRGB(255,96,160)
}
local ACCENT_NAMES = {"Lime","Coral","Ice","Violet","Gold","Rose"}
local ACC_NAME = "Lime"
if hasFS then
    pcall(function()
        local p = FOLDER.."/accent.txt"
        if isfile(p) then
            local n = readfile(p)
            if ACCENTS[n] then ACC_NAME = n end
        end
    end)
end
local ACC = ACCENTS[ACC_NAME]

local C = {
    bg    = Color3.fromRGB(11,11,14),
    panel = Color3.fromRGB(16,16,20),
    row   = Color3.fromRGB(24,24,30),
    line  = Color3.fromRGB(40,40,48),
    off   = Color3.fromRGB(58,58,68),
    text  = Color3.fromRGB(232,232,226),
    dim   = Color3.fromRGB(122,122,136)
}
local WHITE    = Color3.fromRGB(255,255,255)
local AIM_RED  = Color3.fromRGB(255,64,64)
local BODY_GRAY = Color3.fromRGB(196,196,206)
local F_HEAD = Enum.Font.Michroma
local F_BODY = Enum.Font.SourceSansSemibold
local F_MONO = Enum.Font.RobotoMono
local F_SEC  = Enum.Font.Oswald

local themed = {}
local function T(o, p, fn)
    themed[#themed+1] = {o, p, fn}
    o[p] = fn and fn(ACC) or ACC
end
local function setAccent(c)
    ACC = c
    for _, t in ipairs(themed) do
        pcall(function() t[1][t[2]] = t[3] and t[3](ACC) or ACC end)
    end
end

-- ========================= HSV CUSTOM COLOR =========================
-- Глобальные HSV значения для "Custom" цвета
local HSV = {h = 120/360, s = 0.85, v = 1.0}
local function customColor()
    return Color3.fromHSV(HSV.h, HSV.s, HSV.v)
end
local function hueSeq()
    local kp = {}
    for k = 0, 6 do
        kp[#kp+1] = ColorSequenceKeypoint.new(k/6, Color3.fromHSV(k/6, 1, 1))
    end
    return ColorSequence.new(kp)
end
local function satSeq()
    return ColorSequence.new(Color3.fromHSV(HSV.h, 0, HSV.v), Color3.fromHSV(HSV.h, 1, HSV.v))
end
local function valSeq()
    return ColorSequence.new(Color3.new(0,0,0), Color3.fromHSV(HSV.h, HSV.s, 1))
end

-- Цветовые пресеты
local PALETTE = {
    Lime   = ACCENTS.Lime,
    Coral  = ACCENTS.Coral,
    Ice    = ACCENTS.Ice,
    Violet = ACCENTS.Violet,
    Gold   = ACCENTS.Gold,
    Red    = Color3.fromRGB(255,60,60),
    Green  = Color3.fromRGB(70,230,110),
    Blue   = Color3.fromRGB(70,110,255),
    Pink   = Color3.fromRGB(255,110,200),
    White  = WHITE
}
local COLOR_NAMES  = {"Rainbow","Custom","Lime","Coral","Ice","Violet","Gold","Red","Green","Blue","Pink","White"}
local WING_COLORS  = {"Custom","White","Gold","Rainbow","Ice","Violet","Pink","Coral"}
local ROLE_COLORS  = {
    Murderer = Color3.fromRGB(255,60,60),
    Sheriff  = Color3.fromRGB(70,130,255),
    Innocent = Color3.fromRGB(70,230,110)
}
local ROLE_NAMES = {"Murderer","Sheriff","Innocent"}
local HAT_COLORS = {"Custom","Rainbow","Lime","Coral","Ice","Violet","Gold","Red","Green","Blue","Pink","White"}
local QB_POSITIONS   = {"Left","Right","Bottom","Top","Left-Top","Left-Bottom","Right-Top","Right-Bottom"}
local SCREEN_RATIOS  = {"Default","16:9","16:10","4:3","21:9","1:1"}
local STRETCH_PRESETS= {"Default","16:9","16:10","4:3","21:9","1:1","Custom"}

local function getColor(n, t, o)
    if n == "Rainbow" then
        return Color3.fromHSV((((t or 0)*0.2)+(o or 0)) % 1, 0.85, 1)
    end
    if n == "Custom" then
        return customColor()
    end
    return PALETTE[n] or ACC
end

-- ========================= UTIL =========================
local connections = {}
local function track(c) connections[#connections+1] = c; return c end

local function tween(o, ti, p, s, d)
    local tw = TweenService:Create(o, TweenInfo.new(ti, s or Enum.EasingStyle.Quint, d or Enum.EasingDirection.Out), p)
    tw:Play()
    return tw
end
local function corner(o, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = o; return c
end
local function stroke(o, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col
    s.Thickness = th or 1
    s.Transparency = tr or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = o
    return s
end
local function gradient(f, rot, seq, tseq)
    local g = Instance.new("UIGradient")
    g.Rotation = rot or 0
    if seq then g.Color = seq end
    if tseq then g.Transparency = tseq end
    g.Parent = f
    return g
end

local GradRefresh = {}
local Flags, Setters, Defaults = {}, {}, {}
local function register(k, d, s)
    Flags[k] = d
    Defaults[k] = d
    Setters[k] = s
end

-- ========================= PARENT GUI (Delta-safe) =========================
local function getParentGui()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then
        local ok2 = pcall(function() return cg:GetChildren() end)
        if ok2 then return cg end
    end
    return LP:WaitForChild("PlayerGui", 10) or LP:FindFirstChildOfClass("PlayerGui")
end

local gui = Instance.new("ScreenGui")
gui.Name = "luxxs"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true

local parent = getParentGui()
pcall(function() if parent:FindFirstChild("luxxs") then parent.luxxs:Destroy() end end)
pcall(function() if parent:FindFirstChild("luxxsKey") then parent.luxxsKey:Destroy() end end)
pcall(function() if parent:FindFirstChild("luxxsFPS") then parent.luxxsFPS:Destroy() end end)
gui.Parent = parent
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

for _, e in ipairs(Lighting:GetChildren()) do
    pcall(function()
        if e:IsA("BlurEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled = false end
        if e.Name:sub(1,6) == "luxxs_" then e:Destroy() end
    end)
end

print("[luxxs] v6.1 loaded (Delta-ready)")

-- ========================= LOADING SCREEN =========================
__safe("loading", function()
    local sg = Instance.new("ScreenGui")
    sg.Name = "luxxsKey"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999
    sg.Parent = parent

    local root = Instance.new("CanvasGroup")
    root.Size = UDim2.new(1,0,1,0)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.Parent = sg

    local bgf = Instance.new("Frame")
    bgf.Size = UDim2.new(1,0,1,0)
    bgf.BackgroundColor3 = WHITE
    bgf.BorderSizePixel = 0
    bgf.ZIndex = 0
    bgf.Parent = root
    gradient(bgf, 90, ColorSequence.new(Color3.fromRGB(22,22,28), Color3.fromRGB(8,8,10)))

    local word = "LUXXS"
    local LW = 62
    local total = LW * #word
    local holder = Instance.new("Frame")
    holder.AnchorPoint = Vector2.new(0.5,0.5)
    holder.Position = UDim2.new(0.5,0,0.36,0)
    holder.Size = UDim2.new(0,total,0,84)
    holder.BackgroundTransparency = 1
    holder.ClipsDescendants = true
    holder.Parent = root

    local letters = {}
    for i = 1, #word do
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Size = UDim2.new(0,LW,0,84)
        l.Position = UDim2.new(0,(i-1)*LW,0,98)
        l.Font = F_HEAD
        l.TextSize = 52
        l.Text = word:sub(i,i)
        l.TextColor3 = C.text
        l.Parent = holder
        letters[i] = l
    end

    local ul = Instance.new("Frame")
    ul.AnchorPoint = Vector2.new(0.5,0)
    ul.Position = UDim2.new(0.5,0,0.36,52)
    ul.Size = UDim2.new(0,0,0,2)
    ul.BorderSizePixel = 0
    ul.Parent = root
    T(ul, "BackgroundColor3")

    local statusLbl = Instance.new("TextLabel")
    statusLbl.BackgroundTransparency = 1
    statusLbl.AnchorPoint = Vector2.new(0.5,0)
    statusLbl.Position = UDim2.new(0.5,0,0.58,0)
    statusLbl.Size = UDim2.new(0,400,0,18)
    statusLbl.Font = F_MONO
    statusLbl.TextSize = 13
    statusLbl.TextColor3 = C.dim
    statusLbl.Text = "INITIALIZING"
    statusLbl.TextTransparency = 1
    statusLbl.Parent = root

    local barBg = Instance.new("Frame")
    barBg.AnchorPoint = Vector2.new(0.5,0)
    barBg.Position = UDim2.new(0.5,0,0.64,0)
    barBg.Size = UDim2.new(0,320,0,3)
    barBg.BackgroundColor3 = C.off
    barBg.BorderSizePixel = 0
    barBg.Parent = root
    corner(barBg, 2)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0,0,1,0)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg
    corner(barFill, 2)
    T(barFill, "BackgroundColor3")

    task.spawn(function()
        task.wait(0.15)
        for i, l in ipairs(letters) do
            tween(l, 0.6, {Position = UDim2.new(0,(i-1)*LW,0,0)})
            task.wait(0.06)
        end
        task.wait(0.2)
        tween(ul, 0.5, {Size = UDim2.new(0,total,0,2)})
        task.wait(0.25)
        tween(statusLbl, 0.3, {TextTransparency = 0})
        local steps = {
            {"Loading modules...", 0.35},
            {"Connecting...", 0.7},
            {"Access granted", 1.0}
        }
        for _, s in ipairs(steps) do
            statusLbl.Text = s[1]
            tween(barFill, 0.3, {Size = UDim2.new(s[2],0,1,0)})
            task.wait(0.3)
        end
        T(statusLbl, "TextColor3")
        task.wait(0.3)
        tween(root, 0.4, {GroupTransparency = 1})
        task.wait(0.45)
        sg:Destroy()
    end)
end)

task.wait(2.8)
print("[luxxs] loading done, building UI")

-- ========================= NOTIFY =========================
local function notify(text)
    local f = Instance.new("Frame")
    f.AnchorPoint = Vector2.new(1,1)
    f.Size = UDim2.new(0,250,0,34)
    f.Position = UDim2.new(1,280,1,-20)
    f.BackgroundColor3 = C.panel
    f.BorderSizePixel = 0
    f.ZIndex = 20
    f.Parent = gui
    stroke(f, C.line, 1, 0)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0,3,1,0)
    bar.BorderSizePixel = 0
    bar.BackgroundColor3 = ACC
    bar.ZIndex = 21
    bar.Parent = f

    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1,-20,1,0)
    l.Position = UDim2.new(0,14,0,0)
    l.Font = F_MONO
    l.TextSize = 12
    l.TextColor3 = C.text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = text
    l.ZIndex = 21
    l.Parent = f

    tween(f, 0.4, {Position = UDim2.new(1,-20,1,-20)})
    task.delay(2.6, function()
        tween(f, 0.3, {Position = UDim2.new(1,280,1,-20)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.35, function() pcall(function() f:Destroy() end) end)
    end)
end

-- ========================= DRAGGABLE =========================
local function makeDraggable(handle, target, onClick)
    local dragging, startPos, startInput, moved = false, nil, nil, false
    track(handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            startInput = input.Position
            startPos = target.Position
            local c2
            c2 = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    c2:Disconnect()
                    if not moved and onClick then onClick() end
                end
            end)
        end
    end))
    track(UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            if delta.Magnitude > 5 then moved = true end
            if moved then
                tween(target, 0.08, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, Enum.EasingStyle.Linear)
            end
        end
    end))
end

-- ========================= COSMETICS =========================
local Cos = {}
local function destroyCos(n)
    if Cos[n] then
        for _, o in ipairs(Cos[n].objs) do pcall(function() o:Destroy() end) end
        Cos[n] = nil
    end
end
local function newPart(sz, p)
    local pt = Instance.new("Part")
    pt.Size = sz
    pt.CanCollide = false
    pt.CanQuery = false
    pt.CanTouch = false
    pt.Massless = true
    pt.Anchored = false
    pt.Parent = p
    return pt
end

local function buildWings()
    destroyCos("wings")
    local char = LP.Character
    local torso = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
    if not torso then return end
    local model = Instance.new("Model"); model.Name = "luxxsWings"
    local feathers = {}
    for _, side in ipairs({-1, 1}) do
        for i = 1, 6 do
            local len = 4.2 - i*0.35
            local p = newPart(Vector3.new(len, 0.5, 0.08), model)
            p.Material = Enum.Material.Neon
            local w = Instance.new("Weld")
            w.Part0 = torso
            w.Part1 = p
            w.Parent = p
            feathers[#feathers+1] = {part = p, weld = w, side = side, i = i, len = len}
        end
    end
    model.Parent = char
    Cos.wings = {objs = {model}, model = model, feathers = feathers}
end

local function buildHat()
    destroyCos("hat")
    local char = LP.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return end
    local model = Instance.new("Model"); model.Name = "luxxsHat"
    local slices = {}
    local N = 30
    for i = 1, N do
        local k = (i-1)/N
        local r = 2.4 * (1-k)^1.05 + 0.05
        local p = newPart(Vector3.new(0.07, r*2, r*2), model)
        p.Shape = Enum.PartType.Cylinder
        p.Material = Enum.Material.SmoothPlastic
        p.CastShadow = false
        local w = Instance.new("Weld")
        w.Part0 = head
        w.Part1 = p
        w.C0 = CFrame.new(0, 0.52 + (i-1)*0.036, 0) * CFrame.Angles(0, 0, math.pi/2)
        w.Parent = p
        slices[i] = p
    end
    model.Parent = char
    Cos.hat = {objs = {model}, model = model, slices = slices}
end

local function buildTrail()
    destroyCos("trail")
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local a0 = Instance.new("Attachment"); a0.Name = "luxxsA0"; a0.Parent = hrp
    local a1 = Instance.new("Attachment"); a1.Name = "luxxsA1"; a1.Parent = hrp
    local tr = Instance.new("Trail")
    tr.Attachment0 = a0
    tr.Attachment1 = a1
    tr.LightEmission = 1
    tr.FaceCamera = true
    tr.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 1)
    })
    tr.Parent = hrp
    Cos.trail = {objs = {a0, a1, tr}, a0 = a0, a1 = a1, trail = tr}
end

local function colorSeq(name, t)
    if name == "Rainbow" then
        local kp = {}
        for k = 0, 6 do
            kp[#kp+1] = ColorSequenceKeypoint.new(k/6, getColor(name, t, -k/6 * 0.8))
        end
        return ColorSequence.new(kp)
    end
    return ColorSequence.new(getColor(name))
end

track(RunService.Heartbeat:Connect(function()
    local t = os.clock()
    local w = Cos.wings
    if w and w.model.Parent then
        local flap = math.sin(t * (Flags["Visuals/Wing Speed"] or 3)) * 0.2
        for _, f in ipairs(w.feathers) do
            local a = math.rad(10 + f.i*12) + flap*(0.5 + f.i*0.12)
            local theta = (f.side == 1) and a or (math.pi - a)
            f.weld.C0 = CFrame.new(f.side*0.5, 0.45, 0.6)
                * CFrame.Angles(0, f.side*-0.35, 0)
                * CFrame.Angles(0, 0, theta)
                * CFrame.new(f.len/2, 0, 0)
            f.part.Color = getColor(Flags["Visuals/Wing Color"], t, f.i*0.05)
        end
    end

    local h = Cos.hat
    if h and h.model.Parent then
        local htr = (Flags["Visuals/Hat Transparency"] or 35) / 100
        for i, sl in ipairs(h.slices) do
            sl.Color = getColor(Flags["Visuals/Hat Color"], t, i*0.02)
            sl.Transparency = htr
        end
    end

    local tr = Cos.trail
    if tr and tr.trail.Parent then
        local width = (Flags["Visuals/Trail Width"] or 4) * 0.4
        tr.a0.Position = Vector3.new(0, width/2, 0)
        tr.a1.Position = Vector3.new(0, -width/2, 0)
        tr.trail.Lifetime = math.max(0.1, (Flags["Visuals/Trail Length"] or 10) / 10)
        tr.trail.Color = colorSeq(Flags["Visuals/Trail Color"], t)
    end
end))

-- ========================= SCREEN RATIO =========================
local ScreenRes = {Bars = {}}
do
    local barsFolder = Instance.new("Frame")
    barsFolder.Name = "luxxsScreenBars"
    barsFolder.Size = UDim2.new(1,0,1,0)
    barsFolder.BackgroundTransparency = 1
    barsFolder.ZIndex = 0
    barsFolder.Parent = gui

    local topBar = Instance.new("Frame")
    topBar.Position = UDim2.new(0,0,0,0)
    topBar.Size = UDim2.new(1,0,0,0)
    topBar.BackgroundColor3 = Color3.new(0,0,0)
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 0
    topBar.Parent = barsFolder

    local botBar = Instance.new("Frame")
    botBar.AnchorPoint = Vector2.new(0,1)
    botBar.Position = UDim2.new(0,0,1,0)
    botBar.Size = UDim2.new(1,0,0,0)
    botBar.BackgroundColor3 = Color3.new(0,0,0)
    botBar.BorderSizePixel = 0
    botBar.ZIndex = 0
    botBar.Parent = barsFolder

    ScreenRes.Bars = {top = topBar, bot = botBar, folder = barsFolder}

    local RATIOS = {["16:9"]=16/9, ["16:10"]=16/10, ["4:3"]=4/3, ["21:9"]=21/9, ["1:1"]=1.0}

    function ScreenRes.apply(mode, animate)
        local cam = workspace.CurrentCamera
        if not cam then return end
        local vp = cam.ViewportSize
        local ti = animate and 0.35 or 0.001
        if mode == "Default" then
            tween(ScreenRes.Bars.top, ti, {Size = UDim2.new(1,0,0,0)})
            tween(ScreenRes.Bars.bot, ti, {Size = UDim2.new(1,0,0,0)})
            return
        end
        local targetRatio = RATIOS[mode]
        if not targetRatio then return end
        local currentRatio = vp.X / vp.Y
        local barH = 0
        if currentRatio > targetRatio then
            local targetH = vp.X / targetRatio
            barH = (vp.Y - targetH) / 2
        end
        if barH < 0 then barH = 0 end
        tween(ScreenRes.Bars.top, ti, {Size = UDim2.new(1,0,0,barH)})
        tween(ScreenRes.Bars.bot, ti, {Size = UDim2.new(1,0,0,barH)})
    end
end

-- ========================= STRETCH (FOV) =========================
local Stretch = {Preset = "Default", H = 100, V = 100, FOV = 70, SavedFOV = nil}
do
    local cam = workspace.CurrentCamera
    Stretch.SavedFOV = cam and cam.FieldOfView or 70

    function Stretch.apply()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local h = math.clamp((tonumber(Stretch.H) or 100) / 100, 0.5, 2.0)
        local v = math.clamp((tonumber(Stretch.V) or 100) / 100, 0.5, 2.0)
        local base = tonumber(Stretch.FOV) or 70
        local target = math.clamp(base * (1/v), 1, 179)
        local ratio = 1 + (h - 1) * 0.5
        cam.FieldOfView = math.clamp(target / ratio, 1, 179)
    end

    function Stretch.setPreset(name)
        Stretch.Preset = name
        if name == "Default" then
            Stretch.H = 100
            Stretch.V = 100
            local cam = workspace.CurrentCamera
            if cam then cam.FieldOfView = Stretch.SavedFOV or 70 end
            if Setters["Stretch/Horizontal"] then Setters["Stretch/Horizontal"](100) end
            if Setters["Stretch/Vertical"]   then Setters["Stretch/Vertical"](100)   end
            return
        end
        if name == "Custom" then return end
        local map = {
            ["16:9"]  = {h = 112, v = 100},
            ["16:10"] = {h = 106, v = 100},
            ["4:3"]   = {h = 124, v = 100},
            ["21:9"]  = {h = 94,  v = 100},
            ["1:1"]   = {h = 134, v = 100}
        }
        local m = map[name] or {h = 100, v = 100}
        Stretch.H = m.h
        Stretch.V = m.v
        if Setters["Stretch/Horizontal"] then Setters["Stretch/Horizontal"](m.h) end
        if Setters["Stretch/Vertical"]   then Setters["Stretch/Vertical"](m.v)   end
        Stretch.apply()
    end
end

-- ========================= WINDOW =========================
local W, H = 972, 460
local main = Instance.new("CanvasGroup")
main.AnchorPoint = Vector2.new(0.5,0.5)
main.Position = UDim2.new(0.5,0,0.5,0)
main.Size = UDim2.new(0,W,0,H)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.GroupTransparency = 1
main.Visible = false
main.Parent = gui
corner(main, 16)
T(stroke(main, ACC, 1.5, 0.35), "Color")
main.BackgroundColor3 = Color3.fromRGB(12,11,17)

do
    local bgF = Instance.new("Frame")
    bgF.Size = UDim2.new(1,0,1,0)
    bgF.BackgroundColor3 = WHITE
    bgF.BorderSizePixel = 0
    bgF.ZIndex = 0
    bgF.Parent = main
    gradient(bgF, 125, ColorSequence.new(Color3.fromRGB(24,19,36), Color3.fromRGB(10,10,14)))
end

local scale = Instance.new("UIScale")
scale.Scale = 0.9
scale.Parent = main

-- Top bar
local top = Instance.new("Frame")
top.Size = UDim2.new(1,0,0,44)
top.BackgroundColor3 = WHITE
top.BorderSizePixel = 0
top.Parent = main
gradient(top, 0, ColorSequence.new(Color3.fromRGB(34,26,48), Color3.fromRGB(15,15,21)))

do
    local topLine = Instance.new("Frame")
    topLine.Position = UDim2.new(0,0,1,-1)
    topLine.Size = UDim2.new(1,0,0,1)
    topLine.BackgroundColor3 = C.line
    topLine.BorderSizePixel = 0
    topLine.Parent = top

    local mark = Instance.new("Frame")
    mark.Position = UDim2.new(0,16,0,18)
    mark.Size = UDim2.new(0,8,0,8)
    mark.Rotation = 45
    mark.BorderSizePixel = 0
    mark.Parent = top
    T(mark, "BackgroundColor3")

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0,34,0,0)
    title.Size = UDim2.new(0,90,1,0)
    title.Font = F_HEAD
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = C.text
    title.Text = "LUXXS"
    title.Parent = top

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.new(0,130,0,2)
    sub.Size = UDim2.new(0,120,1,0)
    sub.Font = F_MONO
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.TextColor3 = C.dim
    sub.Text = "by DrHub"
    sub.Parent = top

    local ver = Instance.new("TextLabel")
    ver.BackgroundTransparency = 1
    ver.AnchorPoint = Vector2.new(1,0)
    ver.Position = UDim2.new(1,-52,0,0)
    ver.Size = UDim2.new(0,160,1,0)
    ver.Font = F_MONO
    ver.TextSize = 11
    ver.TextXAlignment = Enum.TextXAlignment.Right
    ver.TextColor3 = C.dim
    ver.Text = "v6.1 // MM2"
    ver.Parent = top
end

local closeBtn = Instance.new("TextButton")
closeBtn.AnchorPoint = Vector2.new(1,0.5)
closeBtn.Position = UDim2.new(1,-10,0.5,0)
closeBtn.Size = UDim2.new(0,28,0,28)
closeBtn.BackgroundColor3 = C.row
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.Font = F_MONO
closeBtn.TextSize = 13
closeBtn.TextColor3 = C.dim
closeBtn.AutoButtonColor = false
closeBtn.Parent = top

-- Side bar
local side = Instance.new("Frame")
side.Position = UDim2.new(0,0,0,44)
side.Size = UDim2.new(0,150,0,H-44-24)
side.BackgroundColor3 = C.panel
side.BorderSizePixel = 0
side.Parent = main
do
    local sideLine = Instance.new("Frame")
    sideLine.Position = UDim2.new(1,-1,0,0)
    sideLine.Size = UDim2.new(0,1,1,0)
    sideLine.BackgroundColor3 = C.line
    sideLine.BorderSizePixel = 0
    sideLine.Parent = side
end

local sideList = Instance.new("Frame")
sideList.BackgroundTransparency = 1
sideList.Position = UDim2.new(0,0,0,12)
sideList.Size = UDim2.new(1,-1,1,-12)
sideList.Parent = side

local indicator = Instance.new("Frame")
indicator.Size = UDim2.new(0,2,0,22)
indicator.Position = UDim2.new(0,0,0,18)
indicator.BorderSizePixel = 0
indicator.ZIndex = 3
indicator.Parent = side
T(indicator, "BackgroundColor3")

-- Footer
local foot = Instance.new("Frame")
foot.Position = UDim2.new(0,0,1,-24)
foot.Size = UDim2.new(1,0,0,24)
foot.BackgroundColor3 = C.panel
foot.BorderSizePixel = 0
foot.Parent = main
do
    local footL = Instance.new("TextLabel")
    footL.BackgroundTransparency = 1
    footL.Position = UDim2.new(0,14,0,0)
    footL.Size = UDim2.new(0.6,0,1,0)
    footL.Font = F_MONO
    footL.TextSize = 10
    footL.TextXAlignment = Enum.TextXAlignment.Left
    footL.TextColor3 = C.dim
    footL.Text = "ESC or RIGHTSHIFT = TOGGLE   |   t.me/NurHuboffical"
    footL.Parent = foot
end

local footR = Instance.new("TextLabel")
footR.BackgroundTransparency = 1
footR.AnchorPoint = Vector2.new(1,0)
footR.Position = UDim2.new(1,-14,0,0)
footR.Size = UDim2.new(0.4,0,1,0)
footR.Font = F_MONO
footR.TextSize = 10
footR.TextXAlignment = Enum.TextXAlignment.Right
footR.TextColor3 = C.dim
footR.Text = "ROLE  INNOCENT"
footR.Parent = foot

-- Pages
local pages = Instance.new("Frame")
pages.BackgroundTransparency = 1
pages.Position = UDim2.new(0,162,0,54)
pages.Size = UDim2.new(0,542,0,H-24-54-10)
pages.ClipsDescendants = true
pages.Parent = main

local previewPanel = Instance.new("Frame")
previewPanel.Position = UDim2.new(0,712,0,54)
previewPanel.Size = UDim2.new(0,252,0,372)
previewPanel.BorderSizePixel = 0
previewPanel.Parent = main

local tabs = {}
local currentTab = nil
local switching = false

local function restyleTabs()
    for _, t in ipairs(tabs) do
        local on = (t == currentTab)
        t.nm.TextColor3 = on and C.text or C.dim
        t.num.TextColor3 = on and ACC or C.dim
        t.button.BackgroundColor3 = on and ACC or C.row
        t.button.BackgroundTransparency = on and 0.82 or 1
    end
end

local function selectTab(tab)
    if currentTab == tab or switching then return end
    switching = true
    local old = currentTab
    currentTab = tab
    tween(indicator, 0.3, {Position = UDim2.new(0,0,0,18 + tab.index*36)})
    restyleTabs()
    if old then
        tween(old.page, 0.15, {GroupTransparency = 1})
        task.delay(0.15, function() old.page.Visible = false end)
    end
    task.delay(old and 0.12 or 0, function()
        tab.page.GroupTransparency = 1
        tab.page.Visible = true
        tween(tab.page, 0.25, {GroupTransparency = 0})
        task.delay(0.25, function() switching = false end)
    end)
end

local function hairline(parentFrame, y)
    local f = Instance.new("Frame")
    f.Position = UDim2.new(0,0,1,y or -1)
    f.Size = UDim2.new(1,0,0,1)
    f.BackgroundColor3 = C.line
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Parent = parentFrame
    return f
end

-- ========================= CREATE TAB =========================
local function createTab(name)
    local index = #tabs

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1,-16,0,34)
    button.Position = UDim2.new(0,8,0,index*36 + 6)
    button.BackgroundColor3 = C.row
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = sideList
    corner(button, 8)

    local num = Instance.new("TextLabel")
    num.BackgroundTransparency = 1
    num.Position = UDim2.new(0,16,0,0)
    num.Size = UDim2.new(0,24,1,0)
    num.Font = F_MONO
    num.TextSize = 11
    num.TextXAlignment = Enum.TextXAlignment.Left
    num.TextColor3 = C.dim
    num.Text = string.format("%02d", index+1)
    num.Parent = button

    local nm = Instance.new("TextLabel")
    nm.BackgroundTransparency = 1
    nm.Position = UDim2.new(0,46,0,0)
    nm.Size = UDim2.new(1,-50,1,0)
    nm.Font = F_SEC
    nm.TextSize = 16
    nm.TextXAlignment = Enum.TextXAlignment.Left
    nm.TextColor3 = C.dim
    nm.Text = string.upper(name)
    nm.Parent = button

    local page = Instance.new("CanvasGroup")
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.GroupTransparency = 1
    page.Parent = pages

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 2
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = page
    T(scroll, "ScrollBarImageColor3")

    local function mkCol(xs, xo)
        local f = Instance.new("Frame")
        f.BackgroundTransparency = 1
        f.Position = UDim2.new(xs, xo, 0, 0)
        f.Size = UDim2.new(0.5,-4,0,0)
        f.AutomaticSize = Enum.AutomaticSize.Y
        f.Parent = scroll
        local l = Instance.new("UIListLayout")
        l.Padding = UDim.new(0,2)
        l.SortOrder = Enum.SortOrder.LayoutOrder
        l.Parent = f
        return f
    end

    local colL = mkCol(0, 0)
    local colR = mkCol(0.5, 4)
    local hL, hR = 0, 0
    local COLH = H - 24 - 54 - 10 - 12

    local function slot(h)
        if hL + h <= COLH then hL = hL + h + 2; return colL end
        if hR + h <= COLH then hR = hR + h + 2; return colR end
        if hR < hL then hR = hR + h + 2; return colR end
        hL = hL + h + 2; return colL
    end

    local pad = Instance.new("UIPadding")
    pad.PaddingRight = UDim.new(0,8)
    pad.PaddingTop = UDim.new(0,2)
    pad.PaddingBottom = UDim.new(0,10)
    pad.Parent = scroll

    local tab = {button = button, page = page, scroll = scroll, index = index, name = name, num = num, nm = nm}
    table.insert(tabs, tab)

    button.MouseButton1Click:Connect(function() selectTab(tab) end)
    button.MouseEnter:Connect(function() if currentTab ~= tab then tween(nm, 0.15, {TextColor3 = C.text}) end end)
    button.MouseLeave:Connect(function() if currentTab ~= tab then tween(nm, 0.15, {TextColor3 = C.dim}) end end)

    function tab:Label(text)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1,0,0,30)
        f.BackgroundTransparency = 1
        f.Parent = slot(30)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Position = UDim2.new(0,0,0,6)
        l.Size = UDim2.new(1,0,0,18)
        l.Font = F_SEC
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextColor3 = C.dim
        l.Text = string.upper(text)
        l.Parent = f
        hairline(f, -3)
        local ac = Instance.new("Frame")
        ac.Position = UDim2.new(0,0,1,-3)
        ac.Size = UDim2.new(0,28,0,1)
        ac.BorderSizePixel = 0
        ac.Parent = f
        T(ac, "BackgroundColor3")
    end

    function tab:Label2(text, font, size, color)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1,0,0,(#text > 36) and 28 or 18)
        l.TextWrapped = true
        l.BackgroundTransparency = 1
        l.Font = font or F_MONO
        l.TextSize = size or 11
        l.TextColor3 = color or C.dim
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Text = text
        l.Parent = slot(l.Size.Y.Offset)
        return l
    end

    function tab:Frame(h)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1,0,0,h)
        f.BackgroundTransparency = 1
        f.Parent = slot(h)
        return f
    end

    function tab:Toggle(text, default, callback)
        local key = name.."/"..text
        local state = default or false
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1,0,0,34)
        row.BackgroundColor3 = C.row
        row.BackgroundTransparency = 0.55
        corner(row, 8)
        row.BorderSizePixel = 0
        row.AutoButtonColor = false
        row.Text = ""
        row.Parent = slot(34)
        hairline(row)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Position = UDim2.new(0,10,0,0)
        lbl.Size = UDim2.new(1,-60,1,0)
        lbl.Font = F_BODY
        lbl.TextSize = 14
        lbl.TextColor3 = C.text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = text
        lbl.Parent = row

        local box = Instance.new("Frame")
        box.AnchorPoint = Vector2.new(1,0.5)
        box.Position = UDim2.new(1,-10,0.5,0)
        box.Size = UDim2.new(0,36,0,18)
        box.BackgroundColor3 = state and ACC or C.off
        box.BorderSizePixel = 0
        box.Parent = row
        corner(box, 9)
        T(box, "BackgroundColor3", function(a) return state and a or C.off end)

        local inner = Instance.new("Frame")
        inner.AnchorPoint = Vector2.new(0,0.5)
        inner.Position = UDim2.new(0, state and 20 or 2, 0.5, 0)
        inner.Size = UDim2.new(0,14,0,14)
        inner.BackgroundColor3 = WHITE
        inner.BorderSizePixel = 0
        inner.Parent = box
        corner(inner, 7)

        local function paint()
            tween(box, 0.18, {BackgroundColor3 = state and ACC or C.off})
            tween(inner, 0.18, {Position = UDim2.new(0, state and 20 or 2, 0.5, 0)})
        end

        register(key, state, function(v)
            state = v and true or false
            Flags[key] = state
            paint()
            if callback then task.spawn(callback, state) end
        end)

        row.MouseButton1Click:Connect(function() Setters[key](not state) end)
        row.MouseEnter:Connect(function() tween(row, 0.12, {BackgroundTransparency = 0.3}) end)
        row.MouseLeave:Connect(function() tween(row, 0.12, {BackgroundTransparency = 0.55}) end)
    end

    function tab:Button(text, callback)
        local wrap = Instance.new("Frame")
        wrap.Size = UDim2.new(1,0,0,38)
        wrap.BackgroundTransparency = 1
        wrap.Parent = slot(38)
        local b = Instance.new("TextButton")
        b.Position = UDim2.new(0,10,0,4)
        b.Size = UDim2.new(1,-20,0,30)
        b.BackgroundColor3 = ACC
        b.BackgroundTransparency = 0.88
        corner(b, 8)
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.Font = F_MONO
        b.TextSize = 12
        b.Text = string.upper(text)
        b.Parent = wrap
        T(b, "TextColor3")
        local bs = stroke(b, ACC, 1, 0.4)
        T(bs, "Color")
        b.MouseEnter:Connect(function()
            b.BackgroundColor3 = ACC
            tween(b, 0.12, {BackgroundTransparency = 0})
            b.TextColor3 = C.bg
        end)
        b.MouseLeave:Connect(function()
            tween(b, 0.12, {BackgroundTransparency = 0.88})
            b.TextColor3 = ACC
        end)
        b.MouseButton1Click:Connect(function() if callback then task.spawn(callback) end end)
    end

    function tab:Input(text, default, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,0,0,38)
        row.BackgroundColor3 = C.row
        row.BackgroundTransparency = 0.55
        corner(row, 8)
        row.Parent = slot(38)
        hairline(row)

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Position = UDim2.new(0,10,0,0)
        lbl.Size = UDim2.new(0.5,-10,1,0)
        lbl.Font = F_BODY
        lbl.TextSize = 14
        lbl.TextColor3 = C.text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = text
        lbl.Parent = row

        local boxF = Instance.new("Frame")
        boxF.AnchorPoint = Vector2.new(1,0.5)
        boxF.Position = UDim2.new(1,-10,0.5,0)
        boxF.Size = UDim2.new(0.5,-10,0,26)
        boxF.BackgroundColor3 = C.bg
        boxF.BorderSizePixel = 0
        boxF.Parent = row
        local bs = stroke(boxF, ACC, 1, 0.4)
        T(bs, "Color")

        local tb = Instance.new("TextBox")
        tb.BackgroundTransparency = 1
        tb.Size = UDim2.new(1,-12,1,0)
        tb.Position = UDim2.new(0,6,0,0)
        tb.Font = F_MONO
        tb.TextSize = 13
        tb.TextColor3 = C.text
        tb.PlaceholderColor3 = C.dim
        tb.PlaceholderText = "value"
        tb.Text = tostring(default or "")
        tb.ClearTextOnFocus = false
        tb.TextXAlignment = Enum.TextXAlignment.Center
        tb.Parent = boxF
        tb.FocusLost:Connect(function()
            if callback then task.spawn(callback, tb.Text, tb) end
        end)
        return tb
    end

    function tab:Slider(text, min, max, default, callback, gradFn)
        local key = name.."/"..text
        local value = default or min
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,0,0,46)
        row.BackgroundColor3 = C.row
        row.BackgroundTransparency = 0.55
        corner(row, 8)
        row.Parent = slot(46)
        hairline(row)

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Position = UDim2.new(0,10,0,4)
        lbl.Size = UDim2.new(0.6,0,0,20)
        lbl.Font = F_BODY
        lbl.TextSize = 14
        lbl.TextColor3 = C.text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = text
        lbl.Parent = row

        local val = Instance.new("TextLabel")
        val.BackgroundTransparency = 1
        val.AnchorPoint = Vector2.new(1,0)
        val.Position = UDim2.new(1,-10,0,4)
        val.Size = UDim2.new(0,100,0,20)
        val.Font = F_MONO
        val.TextSize = 13
        val.TextXAlignment = Enum.TextXAlignment.Right
        val.Text = tostring(value)
        val.Parent = row
        T(val, "TextColor3")

        local bar = Instance.new("Frame")
        bar.Position = UDim2.new(0,10,0,33)
        bar.Size = UDim2.new(1,-20,0,5)
        bar.BackgroundColor3 = C.off
        bar.BorderSizePixel = 0
        bar.Parent = row

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
        fill.BorderSizePixel = 0
        fill.Parent = bar
        T(fill, "BackgroundColor3")

        local gradObj
        if gradFn then
            bar.Size = UDim2.new(1,-20,0,8)
            bar.Position = UDim2.new(0,10,0,31)
            bar.BackgroundColor3 = WHITE
            fill.BackgroundTransparency = 1
            gradObj = Instance.new("UIGradient")
            gradObj.Color = gradFn()
            gradObj.Parent = bar
            GradRefresh[key] = function() gradObj.Color = gradFn() end
        end

        local knob = Instance.new("Frame")
        knob.AnchorPoint = Vector2.new(0.5,0.5)
        knob.Position = UDim2.new((value-min)/(max-min), 0, 0.5, 0)
        knob.Size = UDim2.new(0,14,0,14)
        knob.BackgroundColor3 = WHITE
        knob.BorderSizePixel = 0
        knob.ZIndex = 3
        knob.Parent = bar
        corner(bar, 3)
        corner(fill, 3)
        corner(knob, 7)
        T(stroke(knob, ACC, 2, 0), "Color")

        register(key, value, function(v)
            v = math.clamp(math.floor((tonumber(v) or min)+0.5), min, max)
            value = v
            Flags[key] = v
            val.Text = tostring(v)
            local r = (v - min) / (max - min)
            fill.Size = UDim2.new(r, 0, 1, 0)
            knob.Position = UDim2.new(r, 0, 0.5, 0)
            if callback then task.spawn(callback, v) end
        end)

        local hit = Instance.new("TextButton")
        hit.BackgroundTransparency = 1
        hit.Text = ""
        hit.Position = UDim2.new(0,0,0,22)
        hit.Size = UDim2.new(1,0,0,24)
        hit.Parent = row
        local sliding = false
        local function update(x)
            local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            Setters[key](min + (max-min) * rel)
        end
        hit.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                scroll.ScrollingEnabled = false
                update(i.Position.X)
            end
        end)
        track(UIS.InputEnded:Connect(function(i)
            if sliding and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
                sliding = false
                scroll.ScrollingEnabled = true
            end
        end))
        track(UIS.InputChanged:Connect(function(i)
            if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                update(i.Position.X)
            end
        end))
    end

    function tab:Choice(text, options, default, callback)
        local key = name.."/"..text
        local idx = table.find(options, default) or 1
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1,0,0,34)
        row.BackgroundColor3 = C.row
        row.BackgroundTransparency = 0.55
        corner(row, 8)
        row.BorderSizePixel = 0
        row.AutoButtonColor = false
        row.Text = ""
        row.Parent = slot(34)
        hairline(row)

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Position = UDim2.new(0,10,0,0)
        lbl.Size = UDim2.new(0.5,-10,1,0)
        lbl.Font = F_BODY
        lbl.TextSize = 14
        lbl.TextColor3 = C.text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = text
        lbl.Parent = row

        local val = Instance.new("TextLabel")
        val.BackgroundTransparency = 1
        val.AnchorPoint = Vector2.new(1,0)
        val.Position = UDim2.new(1,-10,0,0)
        val.Size = UDim2.new(0.5,-10,1,0)
        val.Font = F_MONO
        val.TextSize = 13
        val.TextXAlignment = Enum.TextXAlignment.Right
        val.Text = "< "..options[idx].." >"
        val.Parent = row
        T(val, "TextColor3")

        register(key, options[idx], function(v)
            local i = table.find(options, v)
            if not i then return end
            idx = i
            Flags[key] = options[i]
            val.Text = "< "..options[i].." >"
            if callback then task.spawn(callback, options[i]) end
        end)

        row.MouseButton1Click:Connect(function() Setters[key](options[idx % #options + 1]) end)
        row.MouseButton2Click:Connect(function() Setters[key](options[(idx - 2) % #options + 1]) end)
        row.MouseEnter:Connect(function() tween(row, 0.12, {BackgroundTransparency = 0.3}) end)
        row.MouseLeave:Connect(function() tween(row, 0.12, {BackgroundTransparency = 0.55}) end)
    end

    function tab:List(text, items, default, callback)
        local key = name.."/"..text
        local lf = Instance.new("Frame")
        lf.Size = UDim2.new(1,0,0,180)
        lf.BackgroundTransparency = 1
        lf.Parent = slot(180)

        local header = Instance.new("TextLabel")
        header.BackgroundTransparency = 1
        header.Position = UDim2.new(0,0,0,0)
        header.Size = UDim2.new(1,0,0,16)
        header.Font = F_SEC
        header.TextSize = 13
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.TextColor3 = C.text
        header.Text = string.upper(text)
        header.Parent = lf

        local sf = Instance.new("ScrollingFrame")
        sf.Position = UDim2.new(0,0,0,18)
        sf.Size = UDim2.new(1,0,1,-18)
        sf.BackgroundColor3 = C.row
        sf.BackgroundTransparency = 0.45
        sf.BorderSizePixel = 0
        sf.ScrollBarThickness = 3
        sf.CanvasSize = UDim2.new(0,0,0,#items*28+10)
        sf.Parent = lf
        corner(sf, 8)
        T(sf, "ScrollBarImageColor3")

        local ll = Instance.new("UIListLayout")
        ll.Padding = UDim.new(0,2)
        ll.SortOrder = Enum.SortOrder.LayoutOrder
        ll.Parent = sf

        local pd = Instance.new("UIPadding")
        pd.PaddingTop = UDim.new(0,4)
        pd.PaddingLeft = UDim.new(0,4)
        pd.PaddingRight = UDim.new(0,6)
        pd.PaddingBottom = UDim.new(0,4)
        pd.Parent = sf

        local btns = {}
        local current = default or items[1]

        local function paint()
            for n, b in pairs(btns) do
                local on = (n == current)
                b.BackgroundColor3 = on and ACC or C.bg
                b.BackgroundTransparency = on and 0.55 or 0.45
                b.TextColor3 = on and C.text or C.dim
            end
        end

        register(key, current, function(v)
            current = v
            Flags[key] = v
            paint()
            if callback then task.spawn(callback, v) end
        end)

        for i, nameItem in ipairs(items) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1,0,0,26)
            b.BorderSizePixel = 0
            b.AutoButtonColor = false
            b.Font = F_BODY
            b.TextSize = 14
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Text = "  "..nameItem
            b.LayoutOrder = i
            b.Parent = sf
            corner(b, 6)
            b.MouseButton1Click:Connect(function() Setters[key](nameItem) end)
            b.MouseEnter:Connect(function() if nameItem ~= current then b.BackgroundTransparency = 0.15 end end)
            b.MouseLeave:Connect(function() if nameItem ~= current then b.BackgroundTransparency = 0.45 end end)
            btns[nameItem] = b
        end
        paint()
    end

    return tab
end

-- ========================= OPEN / CLOSE MENU =========================
local function fitScale()
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1280,720)
    return math.min(1, (vp.X-20)/W, (vp.Y-20)/H)
end

local isOpen = false
local busy = false
local MenuAlpha = 0.94
local MenuScale = 1

local function openMenu()
    if busy or isOpen then return end
    busy = true
    isOpen = true
    main.Visible = true
    local fit = fitScale()
    scale.Scale = fit * 0.94 * MenuScale
    main.GroupTransparency = 1
    tween(scale, 0.35, {Scale = fit * MenuScale})
    tween(main, 0.3, {GroupTransparency = 1 - MenuAlpha})
    task.delay(0.35, function() busy = false end)
end

local function closeMenu()
    if busy or not isOpen then return end
    busy = true
    isOpen = false
    tween(scale, 0.25, {Scale = fitScale() * 0.94 * MenuScale}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(main, 0.25, {GroupTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    task.delay(0.26, function()
        main.Visible = false
        busy = false
    end)
end

local function toggleMenu()
    if isOpen then closeMenu() else openMenu() end
end

closeBtn.MouseButton1Click:Connect(closeMenu)
closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, 0.12, {BackgroundColor3 = Color3.fromRGB(190,56,56)})
    closeBtn.TextColor3 = WHITE
end)
closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, 0.12, {BackgroundColor3 = C.row})
    closeBtn.TextColor3 = C.dim
end)

makeDraggable(top, main)

-- ========================= KEYS (ESC + RIGHTSHIFT) =========================
track(UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Escape then
        toggleMenu()
    end
end))

-- ========================= HOME BAR =========================
__safe("homebar", function()
    local hit = Instance.new("TextButton")
    hit.Name = "luxxsHomeBar"
    hit.AnchorPoint = Vector2.new(0.5,1)
    hit.Position = UDim2.new(0.5,0,1,0)
    hit.Size = UDim2.new(0,260,0,38)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.AutoButtonColor = false
    hit.ZIndex = 30
    hit.Parent = gui

    local pill = Instance.new("Frame")
    pill.AnchorPoint = Vector2.new(0.5,1)
    pill.Position = UDim2.new(0.5,0,1,-8)
    pill.Size = UDim2.new(0,140,0,5)
    pill.BackgroundColor3 = WHITE
    pill.BackgroundTransparency = 0.35
    pill.BorderSizePixel = 0
    pill.ZIndex = 31
    pill.Parent = hit
    corner(pill, 3)
    stroke(pill, Color3.new(0,0,0), 1, 0.75)

    local pressing = false
    local startX, startY, moved = 0, 0, 0

    local function rest()
        tween(pill, 0.25, {Size = UDim2.new(0,140,0,5), Position = UDim2.new(0.5,0,1,-8), BackgroundTransparency = 0.35})
    end

    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            pressing = true
            startX = i.Position.X
            startY = i.Position.Y
            moved = 0
            tween(pill, 0.12, {Size = UDim2.new(0,175,0,6), BackgroundTransparency = 0.05})
        end
    end)
    track(UIS.InputChanged:Connect(function(i)
        if not pressing then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
        local dy = i.Position.Y - startY
        moved = math.max(moved, math.abs(dy), math.abs(i.Position.X - startX))
        pill.Position = UDim2.new(0.5, 0, 1, -8 + math.clamp(dy, -26, 10) * 0.6)
    end))
    track(UIS.InputEnded:Connect(function(i)
        if not pressing then return end
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
        pressing = false
        local dy = i.Position.Y - startY
        if dy < -22 then openMenu()
        elseif dy > 22 then closeMenu()
        elseif moved < 10 then toggleMenu() end
        rest()
    end))
end)

-- ========================= ROLE DETECTION =========================
local function scanName(name)
    local n = string.lower(name)
    if n == "knife" or n:find("knife") or n:find("murderknife") then return "Murderer" end
    if n == "gun" or n == "revolver" or n == "sheriff gun" or n:find("revolver")
        or (n:find("gun") and not n:find("shotgun") and not n:find("stun")) then
        return "Sheriff"
    end
    return nil
end

local function scanContainer(container, deep)
    if not container then return nil end
    local list = deep and container:GetDescendants() or container:GetChildren()
    for _, obj in ipairs(list) do
        if obj:IsA("Tool") or obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
            local r = scanName(obj.Name)
            if r then return r end
        end
    end
    return nil
end

local function getRole(plr)
    local char = plr.Character
    if not char then return "Innocent" end
    if plr.Team then
        local tl = string.lower(plr.Team.Name)
        if tl == "murderer" then return "Murderer" end
        if tl == "sheriff" then return "Sheriff" end
        if tl == "innocent" then return "Innocent" end
    end
    for _, src in ipairs({plr, char}) do
        for _, attr in ipairs({"Role","MM2Role","MurderRole","PlayerRole","Team","role","mm2role"}) do
            local v = src:GetAttribute(attr)
            if v ~= nil then
                local rl = string.lower(tostring(v))
                if rl == "murderer" or rl == "murder" then return "Murderer" end
                if rl == "sheriff" then return "Sheriff" end
                if rl == "innocent" then return "Innocent" end
            end
        end
    end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then
            local r = scanName(obj.Name)
            if r then return r end
        end
    end
    local r = scanContainer(char, true)
    if r then return r end
    local bp = plr:FindFirstChildOfClass("Backpack") or plr:FindFirstChild("Backpack")
    if bp then
        for _, obj in ipairs(bp:GetChildren()) do
            if obj:IsA("Tool") then
                local rr = scanName(obj.Name)
                if rr then return rr end
            end
        end
        r = scanContainer(bp, true)
        if r then return r end
    end
    return "Innocent"
end

local roleCache = {}
local function getRoleCached(plr)
    local c = roleCache[plr]
    local now = os.clock()
    if c and now - c.t < 0.3 then return c.r end
    local r = getRole(plr)
    roleCache[plr] = {r = r, t = now}
    return r
end
Players.PlayerRemoving:Connect(function(p) roleCache[p] = nil end)

-- ========================= ESP =========================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "luxxsESP"
ESPFolder.Parent = gui

local espData = {}

local function setLine(f, p1, p2, thick)
    local dx, dy = p2.X - p1.X, p2.Y - p1.Y
    f.Position = UDim2.new(0, (p1.X + p2.X) * 0.5, 0, (p1.Y + p2.Y) * 0.5)
    f.Size = UDim2.new(0, math.sqrt(dx*dx + dy*dy), 0, thick)
    f.Rotation = math.deg(math.atan2(dy, dx))
end

local BONES = {
    {"Head","UpperTorso"},
    {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},
    {"LeftUpperArm","LeftLowerArm"},
    {"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},
    {"RightUpperArm","RightLowerArm"},
    {"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},
    {"LeftUpperLeg","LeftLowerLeg"},
    {"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},
    {"RightUpperLeg","RightLowerLeg"},
    {"RightLowerLeg","RightFoot"},
    {"Head","Torso"},
    {"Torso","Left Arm"},
    {"Torso","Right Arm"},
    {"Torso","Left Leg"},
    {"Torso","Right Leg"}
}

local function createESP(plr)
    if espData[plr] or plr == LP then return end
    local d = {}
    d.box = Instance.new("Frame")
    d.box.BackgroundTransparency = 1
    d.box.BorderSizePixel = 0
    d.box.ZIndex = 2
    d.box.Parent = ESPFolder
    d.boxStroke = stroke(d.box, ACC, 1.2, 0)

    local function mkLabel(size, font)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Font = font or F_MONO
        l.TextSize = size
        l.TextColor3 = WHITE
        l.TextStrokeTransparency = 0.4
        l.TextStrokeColor3 = Color3.new(0,0,0)
        l.Size = UDim2.new(0, 260, 0, size+2)
        l.TextXAlignment = Enum.TextXAlignment.Center
        l.ZIndex = 4
        l.Parent = ESPFolder
        return l
    end

    d.role = mkLabel(13, F_SEC)
    d.name = mkLabel(12)
    d.dist = mkLabel(11)

    d.tracer = Instance.new("Frame")
    d.tracer.AnchorPoint = Vector2.new(0.5,0.5)
    d.tracer.BorderSizePixel = 0
    d.tracer.ZIndex = 2
    d.tracer.Parent = ESPFolder

    d.hpBg = Instance.new("Frame")
    d.hpBg.BackgroundColor3 = Color3.fromRGB(14,14,16)
    d.hpBg.BorderSizePixel = 0
    d.hpBg.ZIndex = 3
    d.hpBg.Parent = ESPFolder

    d.hpFill = Instance.new("Frame")
    d.hpFill.AnchorPoint = Vector2.new(0,1)
    d.hpFill.BackgroundColor3 = Color3.fromRGB(70,230,110)
    d.hpFill.BorderSizePixel = 0
    d.hpFill.Size = UDim2.new(1,0,1,0)
    d.hpFill.Position = UDim2.new(0,0,1,0)
    d.hpFill.ZIndex = 4
    d.hpFill.Parent = d.hpBg

    d.skeleton = {}
    for i = 1, #BONES do
        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5,0.5)
        f.BorderSizePixel = 0
        f.BackgroundColor3 = WHITE
        f.Visible = false
        f.ZIndex = 3
        f.Parent = ESPFolder
        d.skeleton[i] = f
    end
    espData[plr] = d
end

local function removeESP(plr)
    local d = espData[plr]
    if not d then return end
    for k, v in pairs(d) do
        if typeof(v) == "Instance" then
            pcall(function() v:Destroy() end)
        elseif type(v) == "table" then
            for _, o in pairs(v) do pcall(function() o:Destroy() end) end
        end
    end
    espData[plr] = nil
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LP then createESP(plr) end
end
Players.PlayerAdded:Connect(function(plr)
    task.wait(0.2)
    createESP(plr)
end)
Players.PlayerRemoving:Connect(function(plr) removeESP(plr) end)

local function espAnyOn()
    return Flags["Visuals/ESP Box"]
        or Flags["Visuals/Role"]
        or Flags["Visuals/Name"]
        or Flags["Visuals/Health"]
        or Flags["Visuals/Distance"]
        or Flags["Visuals/Tracers"]
        or Flags["Visuals/Skeleton"]
        or Flags["Visuals/Chams"]
        or Flags["Visuals/Glow"]
end

track(RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local t = os.clock()
    local anyOn = espAnyOn()

    for plr, d in pairs(espData) do
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local visible = false
        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge

        if char and hum and hrp and hum.Health > 0 and anyOn then
            for _, p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") then
                    local sp, onS = cam:WorldToViewportPoint(p.Position)
                    if onS and sp.Z > 0 then
                        visible = true
                        minX = math.min(minX, sp.X - 10)
                        maxX = math.max(maxX, sp.X + 10)
                        minY = math.min(minY, sp.Y - 10)
                        maxY = math.max(maxY, sp.Y + 10)
                    end
                end
            end
        end

        if visible then
            local role = getRoleCached(plr)
            local rcol = ROLE_COLORS[role] or WHITE
            local ecol = Flags["Visuals/Color by Role"] and rcol or getColor(Flags["Visuals/ESP Color"], t, 0)
            local w, h = maxX - minX, maxY - minY
            local cx = (minX + maxX) * 0.5

            d.box.Visible = Flags["Visuals/ESP Box"]
            d.box.Position = UDim2.new(0, minX, 0, minY)
            d.box.Size = UDim2.new(0, w, 0, h)
            d.boxStroke.Color = ecol

            d.role.Visible = Flags["Visuals/Role"]
            d.role.Text = string.upper(role)
            d.role.TextColor3 = rcol
            d.role.Position = UDim2.new(0, cx - 130, 0, minY - 48)

            d.name.Visible = Flags["Visuals/Name"]
            d.name.Text = plr.Name
            d.name.TextColor3 = ecol
            d.name.Position = UDim2.new(0, cx - 130, 0, minY - 32)

            local dist = (hrp.Position - cam.CFrame.Position).Magnitude
            d.dist.Visible = Flags["Visuals/Distance"]
            d.dist.Text = "["..math.floor(dist).."m]"
            d.dist.Position = UDim2.new(0, cx - 130, 0, minY + h + 2)

            d.hpBg.Visible = Flags["Visuals/Health"]
            d.hpBg.Position = UDim2.new(0, minX - 6, 0, minY)
            d.hpBg.Size = UDim2.new(0, 3, 0, h)
            d.hpFill.Size = UDim2.new(1,0, math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0)

            d.tracer.Visible = Flags["Visuals/Tracers"]
            if d.tracer.Visible then
                d.tracer.BackgroundColor3 = ecol
                setLine(d.tracer, Vector2.new(vp.X * 0.5, vp.Y), Vector2.new(cx, minY + h), 1)
            end

            local skelOn = Flags["Visuals/Skeleton"]
            for i, bone in ipairs(BONES) do
                local ln = d.skeleton[i]
                if skelOn then
                    local p1 = char:FindFirstChild(bone[1])
                    local p2 = char:FindFirstChild(bone[2])
                    if p1 and p2 then
                        local s1, o1 = cam:WorldToViewportPoint(p1.Position)
                        local s2, o2 = cam:WorldToViewportPoint(p2.Position)
                        if o1 and o2 and s1.Z > 0 and s2.Z > 0 then
                            ln.Visible = true
                            ln.BackgroundColor3 = ecol
                            setLine(ln, Vector2.new(s1.X, s1.Y), Vector2.new(s2.X, s2.Y), 1.5)
                        else
                            ln.Visible = false
                        end
                    else
                        ln.Visible = false
                    end
                else
                    ln.Visible = false
                end
            end
        else
            d.box.Visible = false
            d.role.Visible = false
            d.name.Visible = false
            d.dist.Visible = false
            d.hpBg.Visible = false
            d.tracer.Visible = false
            for _, ln in ipairs(d.skeleton) do ln.Visible = false end
        end
    end
end))

-- ========================= CHAMS / GLOW =========================
do
    local chamsMap = {}
    local function dropCham(plr)
        local h = chamsMap[plr]
        if h then pcall(function() h:Destroy() end); chamsMap[plr] = nil end
    end
    Players.PlayerRemoving:Connect(dropCham)

    track(RunService.Heartbeat:Connect(function()
        local chams = Flags["Visuals/Chams"]
        local glow = Flags["Visuals/Glow"]
        local t = os.clock()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local char = plr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if (chams or glow) and char and hum and hum.Health > 0 then
                    local h = chamsMap[plr]
                    if not h or not h.Parent or h.Adornee ~= char then
                        if h then pcall(function() h:Destroy() end) end
                        h = Instance.new("Highlight")
                        h.Name = "luxxsCham"
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Adornee = char
                        local ok = pcall(function() h.Parent = char end)
                        if not ok or not h.Parent then h.Parent = ESPFolder end
                        chamsMap[plr] = h
                    end
                    local col
                    if Flags["Visuals/Color by Role"] then
                        col = ROLE_COLORS[getRoleCached(plr)] or WHITE
                    else
                        col = getColor(Flags["Visuals/ESP Color"], t, 0)
                    end
                    h.FillColor = col
                    h.OutlineColor = col
                    h.FillTransparency = chams and math.clamp((Flags["Visuals/Chams Fill"] or 50)/100, 0, 1) or 1
                    h.OutlineTransparency = glow and 0.1 or (chams and 0.55 or 1)
                    h.Enabled = true
                else
                    dropCham(plr)
                end
            end
        end
    end))
end

-- ========================= GUN ESP =========================
local GunESP, GunFolder, dropGunVisual
do
    GunESP = {set = {}, vis = {}}
    GunFolder = Instance.new("Folder")
    GunFolder.Name = "luxxsGun"
    GunFolder.Parent = gui

    local GUN_DROP_NAMES = {GunDrop = true, ["Gun Drop"] = true, DroppedGun = true, SheriffGun = true}

    local function gunPartOf(o)
        if o:IsA("BasePart") and GUN_DROP_NAMES[o.Name] then return o end
        if o:IsA("Tool") and o.Parent == workspace and scanName(o.Name) == "Sheriff" then
            return o:FindFirstChild("Handle") or o:FindFirstChildWhichIsA("BasePart")
        end
        return nil
    end

    local function gunStillValid(p)
        if not p or not p.Parent then return false end
        if GUN_DROP_NAMES[p.Name] then return p:IsDescendantOf(workspace) end
        local tool = p.Parent
        return tool:IsA("Tool") and tool.Parent == workspace
    end

    local function addGun(o)
        local p = gunPartOf(o)
        if p then GunESP.set[p] = true end
    end

    function dropGunVisual(p)
        local v = GunESP.vis[p]
        if not v then return end
        pcall(function() v.hl:Destroy() end)
        pcall(function() v.bb:Destroy() end)
        GunESP.vis[p] = nil
    end

    for _, o in ipairs(workspace:GetDescendants()) do addGun(o) end
    track(workspace.DescendantAdded:Connect(addGun))
    track(workspace.DescendantRemoving:Connect(function(o)
        if GunESP.set[o] then
            GunESP.set[o] = nil
            dropGunVisual(o)
        end
    end))

    local function nearestGun()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local best, bd = nil, math.huge
        for p in pairs(GunESP.set) do
            if gunStillValid(p) then
                local d = (p.Position - hrp.Position).Magnitude
                if d < bd then best, bd = p, d end
            end
        end
        return best
    end

    track(RunService.RenderStepped:Connect(function()
        local on = Flags["Visuals/Gun ESP"]
        local cam = workspace.CurrentCamera
        local t = os.clock()
        for p in pairs(GunESP.set) do
            if not gunStillValid(p) then
                GunESP.set[p] = nil
                dropGunVisual(p)
            elseif on then
                local v = GunESP.vis[p]
                if not v then
                    local hl = Instance.new("Highlight")
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.FillTransparency = 0.35
                    hl.OutlineTransparency = 0
                    hl.Adornee = p
                    hl.Parent = GunFolder

                    local bb = Instance.new("BillboardGui")
                    bb.AlwaysOnTop = true
                    bb.Size = UDim2.new(0,120,0,34)
                    bb.StudsOffset = Vector3.new(0,2.5,0)
                    bb.Adornee = p
                    bb.Parent = GunFolder

                    local l = Instance.new("TextLabel")
                    l.BackgroundTransparency = 1
                    l.Size = UDim2.new(1,0,1,0)
                    l.Font = F_MONO
                    l.TextSize = 13
                    l.TextStrokeTransparency = 0.3
                    l.TextStrokeColor3 = Color3.new(0,0,0)
                    l.Text = "GUN"
                    l.Parent = bb

                    v = {hl = hl, bb = bb, lbl = l}
                    GunESP.vis[p] = v
                end
                local col = getColor(Flags["Visuals/Gun Color"] or "Gold", t, 0)
                v.hl.FillColor = col
                v.hl.OutlineColor = col
                v.lbl.TextColor3 = col
                local dist = cam and math.floor((p.Position - cam.CFrame.Position).Magnitude) or 0
                v.lbl.Text = "GUN ["..dist.."m]"
            else
                dropGunVisual(p)
            end
        end
    end))

    function teleportToGun()
        local p = nearestGun()
        if not p then notify("Gun not found") return end
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = CFrame.new(p.Position + Vector3.new(0,3,0))
        hrp.AssemblyLinearVelocity = Vector3.zero
        notify("Teleported to gun")
    end
end

-- ========================= AIM PARTS =========================
local AIM_PARTS_DATA = {
    {name = "Head",     x=33, y=12,  w=24, h=24, r=12, dx=45, dy=24},
    {name = "Chest",    x=27, y=43,  w=36, h=30, r=4,  dx=45, dy=58},
    {name = "Stomach",  x=30, y=73,  w=30, h=30, r=3,  dx=45, dy=88},
    {name = "Left Arm", x=12, y=45,  w=13, h=60, r=5,  dx=18, dy=75},
    {name = "Right Arm",x=65, y=45,  w=13, h=60, r=5,  dx=72, dy=75},
    {name = "Left Leg", x=25, y=104, w=18, h=62, r=5,  dx=34, dy=135},
    {name = "Right Leg",x=47, y=104, w=18, h=62, r=5,  dx=56, dy=135}
}
local AIM_NAMES = {}
for i, a in ipairs(AIM_PARTS_DATA) do AIM_NAMES[i] = a.name end

local function resolveBodyPart(char, name)
    if not char then return nil end
    if name == "Head" then return char:FindFirstChild("Head") end
    if name == "Chest" then return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") end
    if name == "Stomach" then return char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso") end
    if name == "Left Arm" then return char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm") end
    if name == "Right Arm" then return char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm") end
    if name == "Left Leg" then return char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg") end
    if name == "Right Leg" then return char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg") end
    return char:FindFirstChild("Head")
end

local function hasWeapon()
    local char = LP.Character
    if not char then return false end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then
            local n = string.lower(obj.Name)
            if n:find("knife") or n:find("murder") or n:find("gun")
                or n:find("revolver") or n:find("pistol") or n:find("sheriff") then
                return true
            end
        end
    end
    return false
end

local rayParams = RaycastParams.new()
pcall(function() rayParams.FilterType = Enum.RaycastFilterType.Exclude end)
local function hasLineOfSight(fromPos, targetChar, targetPos)
    rayParams.FilterDescendantsInstances = {LP.Character}
    local result = workspace:Raycast(fromPos, targetPos - fromPos, rayParams)
    if not result then return true end
    return result.Instance:IsDescendantOf(targetChar)
end

-- ========================= AIMBOT =========================
local Shoot = {}
do
    local VIM = nil
    pcall(function() VIM = game:GetService("VirtualInputManager") end)

    local fovCircle = Instance.new("Frame")
    fovCircle.AnchorPoint = Vector2.new(0.5,0.5)
    fovCircle.Position = UDim2.new(0.5,0,0.5,0)
    fovCircle.BackgroundTransparency = 1
    fovCircle.BorderSizePixel = 0
    fovCircle.Visible = false
    fovCircle.ZIndex = 2
    fovCircle.Parent = gui
    corner(fovCircle, 9999)
    local fovStroke = stroke(fovCircle, ACC, 2, 0.1)
    T(fovStroke, "Color")
    fovCircle.BackgroundColor3 = ACC
    fovCircle.BackgroundTransparency = 0.93

    local fovLbl = Instance.new("TextLabel")
    fovLbl.BackgroundTransparency = 1
    fovLbl.AnchorPoint = Vector2.new(0.5,1)
    fovLbl.Position = UDim2.new(0.5,0,0,-4)
    fovLbl.Size = UDim2.new(0,180,0,14)
    fovLbl.Font = F_MONO
    fovLbl.TextSize = 11
    fovLbl.TextColor3 = WHITE
    fovLbl.TextStrokeTransparency = 0.4
    fovLbl.Parent = fovCircle

    local function getFovRadiusPx()
        local cam = workspace.CurrentCamera
        if not cam then return 200 end
        return ((Flags["Aimbot/FOV"] or 120) / 180) * math.min(cam.ViewportSize.X, cam.ViewportSize.Y)
    end

    local function findAimbotTarget()
        local cam = workspace.CurrentCamera
        if not cam then return nil end
        local center = Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5)
        local radius = getFovRadiusPx()
        local partName = Flags["Aimbot/Body Part"] or "Head"
        local best, bestDist = nil, math.huge
        local origin = cam.CFrame.Position
        local skipInno = Flags["Aimbot/Skip Innocents"]
        local wall = Flags["Aimbot/Wall Check"]
        local myRole = getRoleCached(LP)

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local char = plr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if char and hum and hum.Health > 0 then
                    local ok = true
                    if skipInno then
                        local r = getRoleCached(plr)
                        if r == "Innocent" or r == myRole then ok = false end
                    end
                    if ok then
                        local part = resolveBodyPart(char, partName)
                        if part then
                            local sp = cam:WorldToViewportPoint(part.Position)
                            if sp.Z > 0 then
                                local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                if dist <= radius and dist < bestDist then
                                    if (not wall) or hasLineOfSight(origin, char, part.Position) then
                                        best, bestDist = {player = plr, part = part, char = char}, dist
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return best
    end

    local aimLastShot = 0
    local function clickCenter()
        if UIS.TouchEnabled or not VIM then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local vp = cam.ViewportSize
        pcall(function() VIM:SendMouseButtonEvent(vp.X*0.5, vp.Y*0.5, 0, true, game, 0) end)
        task.wait(0.01)
        pcall(function() VIM:SendMouseButtonEvent(vp.X*0.5, vp.Y*0.5, 0, false, game, 0) end)
    end

    local function getEquippedWeaponTool()
        local char = LP.Character
        if not char then return nil end
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then
                local n = string.lower(t.Name)
                if n:find("knife") or n:find("murder") or n:find("gun")
                    or n:find("revolver") or n:find("pistol") or n:find("sheriff") then
                    return t
                end
            end
        end
        return nil
    end

    track(RunService.RenderStepped:Connect(function(dt)
        local cam = workspace.CurrentCamera
        if not cam then return end

        local showFov = Flags["Aimbot/Enable"] and Flags["Aimbot/Show FOV"]
        fovCircle.Visible = showFov and true or false
        if showFov then
            local rr = getFovRadiusPx()
            fovCircle.Size = UDim2.new(0, rr*2, 0, rr*2)
            fovCircle.BackgroundColor3 = ACC
            fovLbl.Text = "AIM FOV  r="..math.floor(rr).."px"
        end

        if not Flags["Aimbot/Enable"] then return end
        if Flags["Aimbot/Weapon Only"] and not hasWeapon() then return end

        local target = findAimbotTarget()
        if target then
            local smooth = math.clamp(Flags["Aimbot/Smoothness"] or 30, 1, 100) / 100
            local alpha = math.clamp(1 - smooth, 0.03, 1) * math.min(1, dt * 60)
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.part.Position), alpha)

            if Flags["Aimbot/Auto Shoot"] then
                local tool = getEquippedWeaponTool()
                if tool then
                    local tn = string.lower(tool.Name)
                    local isKnife = tn:find("knife") or tn:find("murder")
                    local now = os.clock()
                    local delay = (Flags["Aimbot/Shoot Delay (ms)"] or 100) / 1000
                    if now - aimLastShot >= delay then
                        aimLastShot = now
                        pcall(function() tool:Activate() end)
                        if not isKnife then clickCenter() end
                    end
                end
            end
        end
    end))
end

-- ========================= KILL AURA =========================
local KillAura = {
    Enabled = false,
    Range = 25,
    DamageDelay = 80,
    AutoEquip = true,
    Teleport = true,
    IgnoreInnocents = true,
    WallCheck = false,
    Thread = nil,
    Status = "idle"
}

do
    local function isWeaponTool(t)
        local n = string.lower(t.Name)
        return n:find("knife") or n:find("murder") or n:find("gun")
            or n:find("revolver") or n:find("pistol") or n:find("sheriff")
    end
    local function isKnife(t)
        local n = string.lower(t.Name)
        return n:find("knife") or n:find("murder")
    end
    local function equipped()
        local char = LP.Character
        if not char then return nil end
        local t = char:FindFirstChildOfClass("Tool")
        if t and isWeaponTool(t) then return t end
        return nil
    end
    local function equip()
        local char = LP.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return nil end
        local cur = equipped()
        if cur then return cur end
        local bp = LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack")
        if not bp then return nil end
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and isWeaponTool(t) then
                pcall(function() hum:EquipTool(t) end)
                task.wait(0.15)
                return equipped() or t
            end
        end
        return nil
    end
    local function alive(plr)
        local c = plr and plr.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if c and h and r and h.Health > 0 then return c, h, r end
        return nil
    end
    local ray = RaycastParams.new()
    pcall(function() ray.FilterType = Enum.RaycastFilterType.Exclude end)
    local function los(from, char, to)
        ray.FilterDescendantsInstances = {LP.Character}
        local r = workspace:Raycast(from, to - from, ray)
        if not r then return true end
        return r.Instance:IsDescendantOf(char)
    end
    local function pickTarget()
        local _, _, my = alive(LP)
        if not my then return nil end
        local myRole = getRoleCached(LP)
        local range = tonumber(KillAura.Range) or 25
        local best, bd = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local c, h, r = alive(plr)
                if c and r then
                    local role = getRoleCached(plr)
                    local skip = false
                    if KillAura.IgnoreInnocents and (role == "Innocent" or role == myRole) then skip = true end
                    if not skip then
                        local d = (r.Position - my.Position).Magnitude
                        if d <= range and d < bd then
                            if (not KillAura.WallCheck) or los(my.Position, c, r.Position) then
                                best, bd = {plr = plr, char = c, hum = h, root = r, role = role}, d
                            end
                        end
                    end
                end
            end
        end
        return best
    end
    local function fireAll(tool, pos, targetChar)
        local cf = CFrame.new(pos)
        for _, d in ipairs(tool:GetDescendants()) do
            if d:IsA("RemoteEvent") then
                pcall(function() d:FireServer(cf) end)
                pcall(function() d:FireServer(pos) end)
                pcall(function() d:FireServer(1, cf, "AH2") end)
                pcall(function() d:FireServer(1, pos, "AH2") end)
                pcall(function() d:FireServer(targetChar) end)
                pcall(function() d:FireServer(1) end)
                pcall(function() d:FireServer(tool.Handle and tool.Handle.CFrame or cf) end)
            elseif d:IsA("RemoteFunction") then
                task.spawn(function()
                    pcall(function() d:InvokeServer(cf) end)
                    pcall(function() d:InvokeServer(pos) end)
                    pcall(function() d:InvokeServer(1, cf, "AH2") end)
                end)
            end
        end
    end
    local function touchKill(tool, targetChar)
        if type(firetouchinterest) ~= "function" then return end
        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
        if not handle then return end
        for _, p in ipairs(targetChar:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(firetouchinterest, handle, p, 0)
                pcall(firetouchinterest, handle, p, 1)
            end
        end
    end
    local function aimCam(pos)
        local cam = workspace.CurrentCamera
        if not cam then return end
        cam.CFrame = CFrame.lookAt(cam.CFrame.Position, pos)
    end
    local function step()
        local _, _, hrp = alive(LP)
        if not hrp then KillAura.Status = "no char"; return end
        local target = pickTarget()
        if not target then KillAura.Status = "no target"; return end
        local tool = KillAura.AutoEquip and equip() or equipped()
        if not tool then KillAura.Status = "no weapon"; return end
        local tRoot = target.root
        local tHead = target.char:FindFirstChild("Head") or tRoot
        local knife = isKnife(tool)
        KillAura.Status = "hit "..target.plr.Name

        if KillAura.Teleport then
            if knife then
                hrp.CFrame = tRoot.CFrame * CFrame.new(0, 0, 1.6)
            else
                hrp.CFrame = CFrame.lookAt((tRoot.CFrame * CFrame.new(0, 0.5, 5)).Position, tHead.Position)
            end
            hrp.AssemblyLinearVelocity = Vector3.zero
            task.wait(0.03)
        end
        aimCam(tHead.Position)

        if knife then
            touchKill(tool, target.char)
            pcall(function() tool:Activate() end)
            fireAll(tool, tRoot.Position, target.char)
            task.wait(0.03)
            touchKill(tool, target.char)
            pcall(function() tool:Activate() end)
            fireAll(tool, tRoot.Position, target.char)
        else
            pcall(function() tool:Activate() end)
            fireAll(tool, tHead.Position, target.char)
            task.wait(0.03)
            pcall(function() tool:Activate() end)
            fireAll(tool, tHead.Position, target.char)
            task.wait(0.03)
            local h = target.char:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then fireAll(tool, tHead.Position, target.char) end
        end
    end
    local function loop()
        while KillAura.Enabled do
            local ok, err = pcall(step)
            if not ok then KillAura.Status = "err: "..tostring(err) end
            task.wait(math.max(0.03, (tonumber(KillAura.DamageDelay) or 80) / 1000))
        end
        KillAura.Status = "idle"
    end
    function KillAura.start()
        if KillAura.Thread then return end
        KillAura.Enabled = true
        KillAura.Thread = task.spawn(loop)
    end
    function KillAura.stop()
        KillAura.Enabled = false
        if KillAura.Thread then
            pcall(function() task.cancel(KillAura.Thread) end)
            KillAura.Thread = nil
        end
        KillAura.Status = "idle"
    end
end

-- ========================= FARM =========================
local Farm = {
    Enabled = false,
    Mode = "Teleport",
    Speed = 80,
    TeleportDelay = 0.15,
    AntiAFK = false,
    ReturnOnFinish = false,
    ReturnPos = nil,
    LoopThread = nil,
    Collected = 0,
    Status = "idle"
}
local setAntiAFK, disableFly, enableFly, setNoclip, startFarm, stopFarm
do
    local antiAfkConn = nil
    function setAntiAFK(on)
        if antiAfkConn then antiAfkConn:Disconnect(); antiAfkConn = nil end
        if not on then return end
        antiAfkConn = LP.Idled:Connect(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
    end
    local coinSet, coinConns = {}, {}
    local function isCoin(o)
        return o:IsA("BasePart") and (o.Name == "Coin" or o.Name:find("Coin") or o.Name:find("coin"))
    end
    local function startCoinCache()
        for _, c in ipairs(coinConns) do c:Disconnect() end
        coinConns = {}
        coinSet = {}
        for _, o in ipairs(workspace:GetDescendants()) do
            if isCoin(o) then coinSet[o] = true end
        end
        coinConns[1] = workspace.DescendantAdded:Connect(function(o)
            if isCoin(o) then coinSet[o] = true end
        end)
        coinConns[2] = workspace.DescendantRemoving:Connect(function(o)
            if coinSet[o] then
                coinSet[o] = nil
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if Farm.Enabled and hrp and (hrp.Position - o.Position).Magnitude < 12 then
                    Farm.Collected = Farm.Collected + 1
                end
            end
        end)
    end
    local function getNearestCoin(pos, skip)
        local best, bestDist, now = nil, math.huge, os.clock()
        for p in pairs(coinSet) do
            if p.Parent and not (skip[p] and skip[p] > now) then
                local d = (p.Position - pos).Magnitude
                if d < bestDist then best, bestDist = p, d end
            end
        end
        return best
    end
    local flyConn, flyBodyVel, flyBodyGyro = nil, nil, nil
    function disableFly()
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        local char = LP.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
                if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
            end
        end
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
    function enableFly()
        disableFly()
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        flyBodyVel = Instance.new("BodyVelocity")
        flyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBodyVel.Velocity = Vector3.zero
        flyBodyVel.Parent = hrp
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBodyGyro.P = 2000
        flyBodyGyro.CFrame = hrp.CFrame
        flyBodyGyro.Parent = hrp
        hum.PlatformStand = true
        flyConn = RunService.RenderStepped:Connect(function()
            if not Farm.Enabled or not hrp or not hrp.Parent then return end
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.zero
            local look = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + look end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - look end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - right end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + right end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end
            if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
            flyBodyVel.Velocity = moveDir * Farm.Speed
            flyBodyGyro.CFrame = cam.CFrame
        end)
    end
    local noclipConn = nil
    function setNoclip(on)
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        if not on then
            local char = LP.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        pcall(function() p.CanCollide = true end)
                    end
                end
            end
            return
        end
        noclipConn = RunService.Stepped:Connect(function()
            if not Farm.Enabled then return end
            local char = LP.Character
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    pcall(function() p.CanCollide = false end)
                end
            end
        end)
    end
    local function teleportTo(pos)
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
        return true
    end
    function startFarm()
        if Farm.LoopThread then return end
        local hrp0 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if Farm.ReturnOnFinish and hrp0 then Farm.ReturnPos = hrp0.CFrame end
        Farm.LoopThread = task.spawn(function()
            startCoinCache()
            local skip = {}
            local lastCollect = 0
            while Farm.Enabled do
                local dt = RunService.Heartbeat:Wait()
                local now = os.clock()
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local tooFast = Farm.Mode == "Teleport" and (now - lastCollect) < 0.13
                    if tooFast then
                        Farm.Status = "cooldown"
                        task.wait(0.05)
                    else
                        local coin = getNearestCoin(hrp.Position, skip)
                        if coin then
                            Farm.Status = "to coin"
                            local target = coin.Position
                            if Farm.Mode == "Teleport" then
                                hrp.CFrame = CFrame.new(target)
                                hrp.AssemblyLinearVelocity = Vector3.zero
                                if type(firetouchinterest) == "function" then
                                    pcall(firetouchinterest, hrp, coin, 0)
                                    pcall(firetouchinterest, hrp, coin, 1)
                                end
                                if Farm.TeleportDelay > 0 then task.wait(Farm.TeleportDelay) end
                                lastCollect = os.clock()
                            else
                                local d = target - hrp.Position
                                local step = Farm.Speed * dt
                                if d.Magnitude <= step then
                                    hrp.CFrame = CFrame.new(target)
                                else
                                    hrp.CFrame = CFrame.new(hrp.Position + d.Unit * step)
                                end
                                hrp.AssemblyLinearVelocity = Vector3.zero
                            end
                            if (hrp.Position - target).Magnitude < 4 then
                                skip[coin] = os.clock() + 8
                            end
                        else
                            Farm.Status = "no coins"
                            task.wait(0.2)
                        end
                    end
                end
            end
            if Farm.ReturnOnFinish and Farm.ReturnPos then
                teleportTo(Farm.ReturnPos.Position)
            end
            Farm.Status = "idle"
        end)
    end
    function stopFarm()
        Farm.Enabled = false
        if Farm.LoopThread then
            pcall(function() task.cancel(Farm.LoopThread) end)
            Farm.LoopThread = nil
        end
        for _, c in ipairs(coinConns) do c:Disconnect() end
        coinConns = {}
        disableFly()
        setNoclip(false)
    end
end

-- ========================= MOVE (Fly + Noclip) =========================
local Move = {Fly = false, Speed = 60, Noclip = false}
local flyUpBtn, flyDownBtn, disableFlyMove, setNoclipMove
do
    local mvConn, mvVel, mvGyro, mvControls = nil, nil, nil, nil
    local upHeld, downHeld = false, false

    local function mkFlyBtn(txt, yOff)
        local b = Instance.new("TextButton")
        b.AnchorPoint = Vector2.new(1,0.5)
        b.Position = UDim2.new(1, -24, 0.5, yOff)
        b.Size = UDim2.new(0,54,0,44)
        b.BackgroundColor3 = C.bg
        b.BackgroundTransparency = 0.1
        b.BorderSizePixel = 0
        b.Text = txt
        b.Font = F_MONO
        b.TextSize = 14
        b.TextColor3 = C.text
        b.AutoButtonColor = false
        b.Visible = false
        b.ZIndex = 5
        b.Parent = gui
        local s = stroke(b, ACC, 1.5, 0)
        T(s, "Color")
        return b
    end
    flyUpBtn, flyDownBtn = mkFlyBtn("UP", -28), mkFlyBtn("DN", 28)

    local function bindHold(b, setter)
        b.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                setter(true)
                b.BackgroundColor3 = ACC
                b.TextColor3 = C.bg
            end
        end)
        b.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                setter(false)
                b.BackgroundColor3 = C.bg
                b.TextColor3 = C.text
            end
        end)
    end
    bindHold(flyUpBtn, function(v) upHeld = v end)
    bindHold(flyDownBtn, function(v) downHeld = v end)

    local function getMoveVector()
        if mvControls then
            local ok, v = pcall(function() return mvControls:GetMoveVector() end)
            if ok and typeof(v) == "Vector3" then return v end
        end
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        local cam = workspace.CurrentCamera
        if hum and cam then return cam.CFrame:VectorToObjectSpace(hum.MoveDirection) end
        return Vector3.zero
    end

    function disableFlyMove()
        if mvConn then mvConn:Disconnect(); mvConn = nil end
        if mvVel then pcall(function() mvVel:Destroy() end); mvVel = nil end
        if mvGyro then pcall(function() mvGyro:Destroy() end); mvGyro = nil end
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
    end

    enableFlyMove = function()
        disableFlyMove()
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if not mvControls then
            pcall(function()
                local pm = LP:FindFirstChild("PlayerScripts") and LP.PlayerScripts:FindFirstChild("PlayerModule")
                if pm then mvControls = require(pm):GetControls() end
            end)
        end
        mvVel = Instance.new("BodyVelocity")
        mvVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        mvVel.Velocity = Vector3.zero
        mvVel.Parent = hrp
        mvGyro = Instance.new("BodyGyro")
        mvGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        mvGyro.P = 9e4
        mvGyro.D = 800
        mvGyro.CFrame = hrp.CFrame
        mvGyro.Parent = hrp
        hum.PlatformStand = true

        mvConn = RunService.RenderStepped:Connect(function()
            if not hrp.Parent then return end
            local cam = workspace.CurrentCamera
            if not cam then return end
            local mv = getMoveVector()
            local dir = cam.CFrame:VectorToWorldSpace(Vector3.new(mv.X, 0, mv.Z))
            if UIS:IsKeyDown(Enum.KeyCode.W) and mv.Magnitude == 0 then dir = dir + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.E) or upHeld then dir = dir + Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.Q) or downHeld then dir = dir - Vector3.new(0,1,0) end
            if dir.Magnitude > 1 then dir = dir.Unit end
            mvVel.Velocity = dir * Move.Speed
            local look = cam.CFrame.LookVector
            if Vector3.new(look.X, 0, look.Z).Magnitude > 0.01 then
                mvGyro.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + Vector3.new(look.X, 0, look.Z))
            end
        end)
    end

    local ncConn, ncTouched = nil, {}
    function setNoclipMove(on)
        if ncConn then ncConn:Disconnect(); ncConn = nil end
        if on then
            ncConn = RunService.Stepped:Connect(function()
                local char = LP.Character
                if not char then return end
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then
                        ncTouched[p] = true
                        p.CanCollide = false
                    end
                end
            end)
        else
            for p in pairs(ncTouched) do
                if p.Parent then pcall(function() p.CanCollide = true end) end
            end
            ncTouched = {}
        end
    end
end

-- ========================= AUTO WIN =========================
local AutoWin = {
    Enabled = false,
    Teleport = true,
    AutoEquip = true,
    Delay = 0.2,
    Thread = nil,
    Status = "idle"
}
local startAutoWin, stopAutoWin
do
    local VIM = nil
    pcall(function() VIM = game:GetService("VirtualInputManager") end)

    local function isWeaponTool(t)
        local n = string.lower(t.Name)
        return n:find("knife") or n:find("gun") or n:find("revolver")
            or n:find("pistol") or n:find("sheriff") or n:find("murder")
    end
    local function isKnife(t)
        local n = string.lower(t.Name)
        return n:find("knife") or n:find("murder")
    end
    local function getEq()
        local char = LP.Character
        if not char then return nil end
        local t = char:FindFirstChildOfClass("Tool")
        if t and isWeaponTool(t) then return t end
        return nil
    end
    local function equip()
        local char = LP.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return nil end
        local c = getEq()
        if c then return c end
        local bp = LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack")
        if not bp then return nil end
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and isWeaponTool(t) then
                pcall(function() hum:EquipTool(t) end)
                task.wait(0.2)
                return getEq() or t
            end
        end
        return nil
    end
    local function isAlive(plr)
        local c = plr and plr.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if c and h and r and h.Health > 0 then return c, h, r end
        return nil
    end
    local function findTarget(myRole)
        local _, _, myRoot = isAlive(LP)
        if not myRoot then return nil end
        local best, bestScore = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local c, h, r = isAlive(plr)
                if c then
                    local role = getRoleCached(plr)
                    local score = nil
                    if myRole == "Murderer" then
                        score = (role == "Sheriff") and 0 or 1
                    elseif myRole == "Sheriff" then
                        if role == "Murderer" then score = 0 end
                    end
                    if score then
                        local combined = score * 100000 + (r.Position - myRoot.Position).Magnitude
                        if combined < bestScore then
                            bestScore = combined
                            best = {plr = plr, char = c, hum = h, root = r, role = role}
                        end
                    end
                end
            end
        end
        return best
    end
    local function fireRemotes(tool, pos, targetChar)
        local cf = CFrame.new(pos)
        for _, d in ipairs(tool:GetDescendants()) do
            if d:IsA("RemoteEvent") then
                pcall(function() d:FireServer(cf) end)
                pcall(function() d:FireServer(pos) end)
                pcall(function() d:FireServer(1, cf, "AH2") end)
                pcall(function() d:FireServer(1, pos, "AH2") end)
                pcall(function() d:FireServer(targetChar) end)
                pcall(function() d:FireServer(tool.Handle.CFrame) end)
            elseif d:IsA("RemoteFunction") then
                task.spawn(function()
                    pcall(function() d:InvokeServer(cf) end)
                    pcall(function() d:InvokeServer(pos) end)
                end)
            end
        end
    end
    local function touchKill(tool, targetChar)
        if type(firetouchinterest) ~= "function" then return end
        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
        if not handle then return end
        for _, p in ipairs(targetChar:GetChildren()) do
            if p:IsA("BasePart") then
                pcall(firetouchinterest, handle, p, 0)
                pcall(firetouchinterest, handle, p, 1)
            end
        end
    end
    local function clickAt(vec2)
        if not VIM or UIS.TouchEnabled then return end
        pcall(function() VIM:SendMouseButtonEvent(vec2.X, vec2.Y, 0, true, game, 0) end)
        task.wait(0.01)
        pcall(function() VIM:SendMouseButtonEvent(vec2.X, vec2.Y, 0, false, game, 0) end)
    end
    local function aimAt(target)
        local cam = workspace.CurrentCamera
        if not cam then return end
        cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target)
    end
    local function step()
        local _, _, hrp = isAlive(LP)
        if not hrp then AutoWin.Status = "waiting"; return end
        local myRole = getRoleCached(LP)
        if myRole ~= "Murderer" and myRole ~= "Sheriff" then AutoWin.Status = "innocent"; return end
        local target = findTarget(myRole)
        if not target then AutoWin.Status = "no targets"; return end
        local tool = AutoWin.AutoEquip and equip() or getEq()
        if not tool then AutoWin.Status = "no weapon"; return end
        local cam = workspace.CurrentCamera
        local tRoot = target.root
        local tHead = target.char:FindFirstChild("Head") or tRoot
        local knife = isKnife(tool)
        AutoWin.Status = (myRole == "Sheriff" and "shoot " or "stab ")..target.plr.Name

        if AutoWin.Teleport then
            if knife then
                hrp.CFrame = tRoot.CFrame * CFrame.new(0, 0, 1.8)
            else
                hrp.CFrame = CFrame.lookAt((tRoot.CFrame * CFrame.new(0, 0.5, 6)).Position, tHead.Position)
            end
            hrp.AssemblyLinearVelocity = Vector3.zero
            task.wait(0.05)
        end
        aimAt(tHead.Position)
        task.wait(0.02)

        if knife then
            touchKill(tool, target.char)
            pcall(function() tool:Activate() end)
            fireRemotes(tool, tRoot.Position, target.char)
            task.wait(0.05)
            local hum = target.char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                touchKill(tool, target.char)
                pcall(function() tool:Activate() end)
            end
        else
            pcall(function() tool:Activate() end)
            fireRemotes(tool, tHead.Position, target.char)
            if cam then
                local vp = cam.ViewportSize
                clickAt(Vector2.new(vp.X*0.5, vp.Y*0.5))
            end
            task.wait(0.02)
            fireRemotes(tool, tHead.Position, target.char)
            pcall(function() tool:Activate() end)
            task.wait(0.05)
            local hum = target.char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and cam then
                local vp = cam.ViewportSize
                clickAt(Vector2.new(vp.X*0.5, vp.Y*0.5))
                fireRemotes(tool, tHead.Position, target.char)
            end
        end
        task.wait(0.15)
    end
    local function autoWinLoop()
        while AutoWin.Enabled do
            local ok, err = pcall(step)
            if not ok then AutoWin.Status = "err: "..tostring(err) end
            task.wait(AutoWin.Delay)
        end
        AutoWin.Status = "idle"
    end
    function startAutoWin()
        AutoWin.Enabled = true
        if not AutoWin.Thread then AutoWin.Thread = task.spawn(autoWinLoop) end
    end
    function stopAutoWin()
        AutoWin.Enabled = false
        if AutoWin.Thread then
            pcall(function() task.cancel(AutoWin.Thread) end)
            AutoWin.Thread = nil
        end
        AutoWin.Status = "idle"
    end
    Shoot.fireRemotes = fireRemotes
    Shoot.touchKill = touchKill
end

-- ========================= WALKSPEED + SPIN =========================
local Move2 = {WalkSpeed = 16, SpinSpeed = 0, SpinEnabled = false}
local applyWalkSpeed, startSpin, stopSpin
do
    local spinAngle = 0
    local spinThread = nil

    function applyWalkSpeed(v)
        v = tonumber(v) or 16
        Move2.WalkSpeed = v
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end

    track(LP.CharacterAdded:Connect(function(c)
        local hum = c:WaitForChild("Humanoid", 10)
        if hum then
            task.wait(0.4)
            hum.WalkSpeed = Move2.WalkSpeed
        end
    end))

    local function spinLoop()
        while Move2.SpinEnabled do
            local dt = RunService.RenderStepped:Wait()
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                spinAngle = spinAngle + math.rad(Move2.SpinSpeed) * dt
                if spinAngle > math.pi * 2 then spinAngle = spinAngle - math.pi * 2 end
                hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, spinAngle, 0)
            end
        end
    end
    function startSpin()
        if spinThread then return end
        Move2.SpinEnabled = true
        spinThread = task.spawn(spinLoop)
    end
    function stopSpin()
        Move2.SpinEnabled = false
        if spinThread then
            pcall(function() task.cancel(spinThread) end)
            spinThread = nil
        end
    end
end

-- ========================= BUNNYHOP =========================
local BHop = {Enabled = false, Accel = 40, Max = 120, Boost = 4, lastJump = 0, vel = nil}
do
    track(UIS.JumpRequest:Connect(function() BHop.lastJump = os.clock() end))
    track(RunService.Heartbeat:Connect(function(dt)
        if not BHop.Enabled or Move.Fly then BHop.vel = nil; return end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp or hum.Health <= 0 then BHop.vel = nil; return end
        local held = UIS:IsKeyDown(Enum.KeyCode.Space) or (os.clock() - BHop.lastJump < 0.25)
        local wish = hum.MoveDirection
        local grounded = hum.FloorMaterial ~= Enum.Material.Air
        if not held or wish.Magnitude < 0.1 then
            if grounded then BHop.vel = nil end
            return
        end
        wish = wish.Unit
        local v = hrp.AssemblyLinearVelocity
        local h = BHop.vel or Vector3.new(v.X, 0, v.Z)
        if grounded then
            local spd = math.min(math.max(h.Magnitude, hum.WalkSpeed) + BHop.Boost, BHop.Max)
            h = wish * spd
            local jy = hum.UseJumpPower and hum.JumpPower or math.sqrt(2 * workspace.Gravity * hum.JumpHeight)
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            hrp.AssemblyLinearVelocity = Vector3.new(h.X, jy, h.Z)
        else
            local spd = h.Magnitude
            if spd > 0.1 then
                local d = h.Unit:Lerp(wish, math.clamp(dt*4, 0, 1))
                if d.Magnitude > 0.01 then h = d.Unit * spd end
            else
                h = wish * hum.WalkSpeed
            end
            h = h + wish * BHop.Accel * dt
            if h.Magnitude > BHop.Max then h = h.Unit * BHop.Max end
            hrp.AssemblyLinearVelocity = Vector3.new(h.X, v.Y, h.Z)
        end
        BHop.vel = h
    end))
end

-- ========================= SKINS =========================
local Skin, SKIN_NAMES
do
    Skin = {
        orig = setmetatable({}, {__mode = "k"}),
        applied = setmetatable({}, {__mode = "k"}),
        live = {},
        cfg = {KnifeMesh = "", KnifeTex = "", GunMesh = "", GunTex = ""}
    }
    local MAT = Enum.Material
    local SKINS = {
        ["Chroma"]     = {a=Color3.fromRGB(255,0,0), b=Color3.fromRGB(255,255,0), mat=MAT.Neon, rainbow=true, trail=true, spark=true},
        ["Chroma Dark"]= {a=Color3.fromRGB(40,0,60), b=Color3.fromRGB(255,0,180), mat=MAT.Neon, rainbow=true, trail=true, spark=true},
        ["Ice Shard"]  = {a=Color3.fromRGB(150,225,255), b=Color3.fromRGB(235,250,255), mat=MAT.Ice, trail=true, spark=true},
        ["Frostbite"]  = {a=Color3.fromRGB(80,180,255), b=Color3.fromRGB(255,255,255), mat=MAT.Plastic, trail=true, spark=true},
        ["Harvester"]  = {a=Color3.fromRGB(35,12,50), b=Color3.fromRGB(255,120,20), t=Color3.fromRGB(255,120,20), mat=MAT.Metal, trail=true, spark=true},
        ["Heartblade"] = {a=Color3.fromRGB(255,50,110), b=Color3.fromRGB(255,200,220), mat=MAT.Neon, trail=true, spark=true},
        ["Gingerblade"]= {a=Color3.fromRGB(210,120,50), b=Color3.fromRGB(255,255,255), mat=MAT.SmoothPlastic},
        ["Corrupt"]    = {a=Color3.fromRGB(20,20,20), b=Color3.fromRGB(190,0,0), t=Color3.fromRGB(190,0,0), mat=MAT.Metal, trail=true},
        ["Lightbringer"]={a=Color3.fromRGB(255,235,150), b=Color3.fromRGB(255,255,255), mat=MAT.Neon, trail=true, spark=true},
        ["Batwing"]    = {a=Color3.fromRGB(25,20,35), b=Color3.fromRGB(130,60,220), t=Color3.fromRGB(130,60,220), mat=MAT.Metal, trail=true},
        ["Slasher"]    = {a=Color3.fromRGB(90,0,0), b=Color3.fromRGB(255,40,40), mat=MAT.Neon, trail=true, spark=true},
        ["Shadow"]     = {a=Color3.fromRGB(0,0,0), b=Color3.fromRGB(60,60,60), t=Color3.fromRGB(60,60,60), mat=MAT.Metal, trail=true},
        ["Candy"]      = {a=Color3.fromRGB(255,180,220), b=Color3.fromRGB(255,255,255), mat=MAT.Neon, trail=true, spark=true},
        ["Toxic"]      = {a=Color3.fromRGB(50,255,50), b=Color3.fromRGB(180,255,50), t=Color3.fromRGB(120,255,80), mat=MAT.Neon, trail=true, spark=true},
        ["Lava"]       = {a=Color3.fromRGB(180,30,0), b=Color3.fromRGB(255,180,0), t=Color3.fromRGB(255,120,0), mat=MAT.Neon, trail=true, spark=true},
        ["Plasma"]     = {a=Color3.fromRGB(180,0,255), b=Color3.fromRGB(80,180,255), t=Color3.fromRGB(180,80,255), mat=MAT.Neon, trail=true, spark=true},
        ["Void"]       = {a=Color3.fromRGB(10,0,30), b=Color3.fromRGB(60,0,100), t=Color3.fromRGB(60,0,120), mat=MAT.Neon, trail=true, spark=true},
        ["Royal"]      = {a=Color3.fromRGB(180,140,20), b=Color3.fromRGB(255,220,80), t=Color3.fromRGB(255,200,60), mat=MAT.Metal, trail=true, spark=true},
        ["Emerald"]    = {a=Color3.fromRGB(20,180,60), b=Color3.fromRGB(180,255,200), mat=MAT.Neon, trail=true, spark=true},
        ["Sapphire"]   = {a=Color3.fromRGB(20,60,200), b=Color3.fromRGB(150,220,255), mat=MAT.Neon, trail=true, spark=true},
        ["Ruby"]       = {a=Color3.fromRGB(180,20,60), b=Color3.fromRGB(255,180,200), mat=MAT.Neon, trail=true, spark=true},
        ["Amethyst"]   = {a=Color3.fromRGB(130,50,220), b=Color3.fromRGB(220,180,255), mat=MAT.Neon, trail=true, spark=true},
        ["Ghost"]      = {a=Color3.fromRGB(200,220,255), b=Color3.fromRGB(255,255,255), mat=MAT.Neon, trail=true, spark=true},
        ["Neon Pink"]  = {a=Color3.fromRGB(255,0,120), b=Color3.fromRGB(255,180,255), mat=MAT.Neon, trail=true, spark=true},
        ["Neon Blue"]  = {a=Color3.fromRGB(0,180,255), b=Color3.fromRGB(180,240,255), mat=MAT.Neon, trail=true, spark=true},
        ["Neon Green"] = {a=Color3.fromRGB(0,255,80), b=Color3.fromRGB(180,255,180), mat=MAT.Neon, trail=true, spark=true},
        ["Gold"]       = {a=Color3.fromRGB(220,180,20), b=Color3.fromRGB(255,240,180), t=Color3.fromRGB(255,220,60), mat=MAT.Metal, trail=true, spark=true},
        ["Silver"]     = {a=Color3.fromRGB(180,180,200), b=Color3.fromRGB(255,255,255), mat=MAT.Metal, trail=true, spark=true},
        ["Bronze"]     = {a=Color3.fromRGB(150,90,30), b=Color3.fromRGB(220,180,120), mat=MAT.Metal},
        ["Blood"]      = {a=Color3.fromRGB(80,0,0), b=Color3.fromRGB(180,0,0), t=Color3.fromRGB(180,0,0), mat=MAT.Metal, trail=true, spark=true},
        ["Aqua"]       = {a=Color3.fromRGB(0,180,180), b=Color3.fromRGB(150,255,255), mat=MAT.Neon, trail=true, spark=true}
    }
    SKIN_NAMES = {"Off"}
    for name in pairs(SKINS) do SKIN_NAMES[#SKIN_NAMES+1] = name end
    table.sort(SKIN_NAMES, function(a, b)
        if a == b then return false end
        if a == "Off" then return true end
        if b == "Off" then return false end
        return a < b
    end)

    local function toolKind(t)
        local r = scanName(t.Name)
        if r == "Murderer" then return "Knife"
        elseif r == "Sheriff" then return "Gun"
        end
        return nil
    end
    local function assetId(v)
        local x = tostring(v or ""):gsub("%s+","")
        if x == "" then return "" end
        if x:match("^%d+$") then return "rbxassetid://"..x end
        return x
    end
    local function saveProps(tool)
        if Skin.orig[tool] then return end
        local o = {}
        for _, d in ipairs(tool:GetDescendants()) do
            if d:IsA("BasePart") then
                local e = {Color = d.Color, Material = d.Material, Transparency = d.Transparency}
                if d:IsA("MeshPart") then e.TextureID = d.TextureID end
                o[d] = e
            elseif d:IsA("SpecialMesh") then
                o[d] = {TextureId = d.TextureId, VertexColor = d.VertexColor}
            end
        end
        Skin.orig[tool] = o
    end
    local function restoreTool(tool)
        for _, d in ipairs(tool:GetDescendants()) do
            if d.Name == "luxxsFx" or d.Name == "luxxsCustom" then
                pcall(function() d:Destroy() end)
            end
        end
        local o = Skin.orig[tool]
        if o then
            for inst, e in pairs(o) do
                if inst.Parent then
                    for k, v in pairs(e) do
                        pcall(function() inst[k] = v end)
                    end
                end
            end
        end
        Skin.applied[tool] = nil
        Skin.live[tool] = nil
    end
    local function applyTool(tool, kind)
        local skinName = Flags["Skins/"..kind.." Skin"] or "Off"
        local def = SKINS[skinName]
        local mesh = assetId(Skin.cfg[kind.."Mesh"])
        local tex = assetId(Skin.cfg[kind.."Tex"])
        local scl = (Flags["Skins/Mesh Scale %"] or 100) / 100
        local sig = skinName.."|"..mesh.."|"..tex.."|"..scl
        if Skin.applied[tool] == sig then return end
        restoreTool(tool)
        Skin.applied[tool] = sig
        if not def and mesh == "" and tex == "" then return end
        saveProps(tool)
        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart", true)
        local parts = {}
        if def then
            local i = 0
            for _, d in ipairs(tool:GetDescendants()) do
                if d:IsA("BasePart") then
                    i = i + 1
                    parts[#parts+1] = d
                    d.Material = def.mat
                    d.Color = (i % 2 == 0) and (def.b or def.a) or def.a
                    if d:IsA("MeshPart") then d.TextureID = "" end
                elseif d:IsA("SpecialMesh") then
                    d.TextureId = ""
                    d.VertexColor = Vector3.new(1,1,1)
                end
            end
        end
        if mesh ~= "" and handle then
            for _, d in ipairs(tool:GetDescendants()) do
                if d:IsA("BasePart") then d.Transparency = 1 end
            end
            local cp = Instance.new("Part")
            cp.Name = "luxxsCustom"
            cp.Size = Vector3.new(1,1,1)
            cp.CanCollide = false
            cp.CanQuery = false
            cp.CanTouch = false
            cp.Massless = true
            if def then cp.Color = def.a; cp.Material = def.mat end
            local sm = Instance.new("SpecialMesh")
            sm.MeshType = Enum.MeshType.FileMesh
            sm.MeshId = mesh
            sm.TextureId = tex
            sm.Scale = Vector3.new(scl, scl, scl)
            sm.Parent = cp
            local w = Instance.new("Weld")
            w.Part0 = handle
            w.Part1 = cp
            w.Parent = cp
            cp.Parent = tool
            parts[#parts+1] = cp
        elseif tex ~= "" then
            for _, d in ipairs(tool:GetDescendants()) do
                if d:IsA("MeshPart") then d.TextureID = tex
                elseif d:IsA("SpecialMesh") then d.TextureId = tex end
            end
        end
        local tr, pe
        if def and handle then
            local col = def.t or def.a
            if def.trail then
                local sz = handle.Size
                local m = math.max(sz.X, sz.Y, sz.Z)
                local ax = (sz.X == m) and Vector3.new(1,0,0) or ((sz.Y == m) and Vector3.new(0,1,0) or Vector3.new(0,0,1))
                local a0 = Instance.new("Attachment"); a0.Name = "luxxsFx"; a0.Position = ax*(m/2); a0.Parent = handle
                local a1 = Instance.new("Attachment"); a1.Name = "luxxsFx"; a1.Position = -ax*(m/2); a1.Parent = handle
                tr = Instance.new("Trail")
                tr.Name = "luxxsFx"
                tr.Attachment0 = a0
                tr.Attachment1 = a1
                tr.Lifetime = 0.4
                tr.LightEmission = 0.8
                tr.FaceCamera = true
                tr.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.2),
                    NumberSequenceKeypoint.new(1, 1)
                })
                tr.Color = ColorSequence.new(col)
                tr.Parent = handle
            end
            if def.spark then
                pe = Instance.new("ParticleEmitter")
                pe.Name = "luxxsFx"
                pe.Rate = 18
                pe.Lifetime = NumberRange.new(0.4, 0.8)
                pe.Speed = NumberRange.new(1, 3)
                pe.LightEmission = 1
                pe.Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.2),
                    NumberSequenceKeypoint.new(1, 0)
                })
                pe.Color = ColorSequence.new(col)
                pe.Parent = handle
            end
        end
        if def and def.rainbow then
            Skin.live[tool] = {parts = parts, tr = tr, pe = pe}
        end
    end
    local function skinRoots()
        local r = {}
        if LP.Character then r[#r+1] = LP.Character end
        local bp = LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack")
        if bp then r[#r+1] = bp end
        return r
    end
    function Skin.refresh()
        local on = Flags["Skins/Enable"]
        for _, root in ipairs(skinRoots()) do
            for _, t in ipairs(root:GetChildren()) do
                if t:IsA("Tool") then
                    local k = toolKind(t)
                    if k then
                        if on then applyTool(t, k)
                        elseif Skin.applied[t] then restoreTool(t) end
                    end
                end
            end
        end
    end
    function Skin.restoreAll()
        for _, root in ipairs(skinRoots()) do
            for _, t in ipairs(root:GetChildren()) do
                if t:IsA("Tool") then pcall(restoreTool, t) end
            end
        end
    end
    track(RunService.Heartbeat:Connect(function()
        if next(Skin.live) == nil then return end
        local hue = (os.clock() * 0.35) % 1
        for tool, l in pairs(Skin.live) do
            if not tool.Parent then
                Skin.live[tool] = nil
            else
                for i, p in ipairs(l.parts) do
                    if p.Parent then p.Color = Color3.fromHSV((hue + i*0.07) % 1, 0.85, 1) end
                end
                local c = Color3.fromHSV(hue, 0.85, 1)
                if l.tr and l.tr.Parent then l.tr.Color = ColorSequence.new(c) end
                if l.pe and l.pe.Parent then l.pe.Color = ColorSequence.new(c) end
            end
        end
    end))
    task.spawn(function()
        while gui.Parent do
            task.wait(0.25)
            pcall(Skin.refresh)
            if Flags["Skins/Enable"] then
                local char = LP.Character
                if char then
                    for _, t in ipairs(char:GetChildren()) do
                        if t:IsA("Tool") then
                            local k = toolKind(t)
                            if k then pcall(applyTool, t, k) end
                        end
                    end
                end
                local bp = LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack")
                if bp then
                    for _, t in ipairs(bp:GetChildren()) do
                        if t:IsA("Tool") then
                            local k = toolKind(t)
                            if k then pcall(applyTool, t, k) end
                        end
                    end
                end
            end
        end
    end)
end

-- ========================= FPS =========================
local FPS = {Enabled = false, Target = 10000, Current = 0}
local originalFpsCap = nil
local function applyFpsCap(cap)
    if type(setfpscap) == "function" then pcall(setfpscap, cap) end
    FPS.Current = cap
end
local function enableFps()
    if type(getfpscap) == "function" then
        local ok, cur = pcall(getfpscap)
        if ok then originalFpsCap = cur end
    end
    applyFpsCap(FPS.Target)
    notify("FPS unlocked to "..FPS.Target)
end
local function disableFps()
    if originalFpsCap then applyFpsCap(originalFpsCap) else applyFpsCap(60) end
end
local fpsGui = Instance.new("ScreenGui")
fpsGui.Name = "luxxsFPS"
fpsGui.ResetOnSpawn = false
fpsGui.IgnoreGuiInset = true
fpsGui.DisplayOrder = 100
fpsGui.Parent = parent

local fpsFrame = Instance.new("Frame")
fpsFrame.AnchorPoint = Vector2.new(1,0)
fpsFrame.Position = UDim2.new(1,-12,0,12)
fpsFrame.Size = UDim2.new(0,84,0,24)
fpsFrame.BackgroundColor3 = C.bg
fpsFrame.BackgroundTransparency = 0.1
fpsFrame.BorderSizePixel = 0
fpsFrame.ZIndex = 5
fpsFrame.Parent = fpsGui
stroke(fpsFrame, C.line, 1, 0)

local fpsNum = Instance.new("TextLabel")
fpsNum.BackgroundTransparency = 1
fpsNum.Position = UDim2.new(0,10,0,0)
fpsNum.Size = UDim2.new(1,-12,1,0)
fpsNum.Font = F_MONO
fpsNum.TextSize = 12
fpsNum.TextColor3 = C.text
fpsNum.TextXAlignment = Enum.TextXAlignment.Left
fpsNum.Text = "0 FPS"
fpsNum.ZIndex = 6
fpsNum.Parent = fpsFrame

local FpsCounter = {Avg = 0, Max = 0, Frames = 0, Last = tick()}
task.spawn(function()
    while fpsGui.Parent do
        RunService.RenderStepped:Wait()
        FpsCounter.Frames = FpsCounter.Frames + 1
        local elapsed = tick() - FpsCounter.Last
        if elapsed >= 0.25 then
            local fps = math.floor(FpsCounter.Frames / elapsed + 0.5)
            FpsCounter.Frames = 0
            FpsCounter.Last = tick()
            FpsCounter.Avg = FpsCounter.Avg == 0 and fps or (FpsCounter.Avg * 0.9 + fps * 0.1)
            if fps > FpsCounter.Max then FpsCounter.Max = fps end
            fpsNum.Text = tostring(fps).." FPS"
        end
    end
end)
makeDraggable(fpsFrame, fpsFrame)

-- ========================= QUICK BAR =========================
local setQuickBarVisible, applyQbPosition, refreshQuickBar
local teleportToGunRef
__safe("quickbar", function()
    local QB_COLORS = {"Accent","Rainbow","Custom","Lime","Coral","Ice","Violet","Gold","Red","Green","Blue","Pink","White"}
    local QB_ACTIONS = {
        {label="Aimbot",      flag="Aimbot/Enable",         icon="AIM", def=true},
        {label="Auto Shoot",  flag="Aimbot/Auto Shoot",     icon="SHT", def=true},
        {label="Kill Aura",   flag="KillAura/Enable",       icon="KLA", def=true},
        {label="Fly",         flag="Move/Fly",              icon="FLY", def=true},
        {label="Noclip",      flag="Move/Noclip",           icon="NLP", def=true},
        {label="Bunnyhop",    flag="Move/Bunnyhop",         icon="BHP", def=true},
        {label="Auto Win",    flag="Aimbot/Auto Win",       icon="AWN", def=true},
        {label="Auto Farm",   flag="Farm/Enable Farm",      icon="FRM", def=true},
        {label="TP Gun",      flag="__tpgun",               icon="TPG", def=true, action=function() if teleportToGunRef then teleportToGunRef() end end},
        {label="Spin",        flag="Move/Spin",             icon="SPN", def=false},
        {label="ESP Box",     flag="Visuals/ESP Box",       icon="BOX", def=false},
        {label="Chams",       flag="Visuals/Chams",         icon="CHM", def=false},
        {label="Skeleton",    flag="Visuals/Skeleton",      icon="SKL", def=false},
        {label="Tracers",     flag="Visuals/Tracers",       icon="TRC", def=false},
        {label="Gun ESP",     flag="Visuals/Gun ESP",       icon="GUN", def=false},
        {label="Wings",       flag="Visuals/Wings",         icon="WNG", def=false},
        {label="Chinese Hat", flag="Visuals/Chinese Hat",   icon="HAT", def=false},
        {label="Trail",       flag="Visuals/Trail",         icon="TRL", def=false},
    }

    local QuickBar = Instance.new("CanvasGroup")
    QuickBar.AnchorPoint = Vector2.new(0,0.5)
    QuickBar.Position = UDim2.new(0, 24, 0.5, 0)
    QuickBar.Size = UDim2.new(0,80,0,0)
    QuickBar.AutomaticSize = Enum.AutomaticSize.Y
    QuickBar.BackgroundColor3 = C.bg
    QuickBar.BackgroundTransparency = 0.1
    QuickBar.GroupTransparency = 1
    QuickBar.BorderSizePixel = 0
    QuickBar.ZIndex = 6
    QuickBar.Visible = false
    QuickBar.Parent = gui
    corner(QuickBar, 14)
    local qbStroke = stroke(QuickBar, ACC, 1.5, 0.35)
    T(qbStroke, "Color")

    local qbHandle = Instance.new("Frame")
    qbHandle.Size = UDim2.new(1,0,0,16)
    qbHandle.BackgroundColor3 = WHITE
    qbHandle.BackgroundTransparency = 0.9
    qbHandle.BorderSizePixel = 0
    qbHandle.ZIndex = 8
    qbHandle.Parent = QuickBar
    corner(qbHandle, 8)

    local qbLayout = Instance.new("UIListLayout")
    qbLayout.Padding = UDim.new(0,4)
    qbLayout.SortOrder = Enum.SortOrder.LayoutOrder
    qbLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    qbLayout.Parent = QuickBar

    local qbPad = Instance.new("UIPadding")
    qbPad.PaddingTop = UDim.new(0,20)
    qbPad.PaddingBottom = UDim.new(0,8)
    qbPad.PaddingLeft = UDim.new(0,7)
    qbPad.PaddingRight = UDim.new(0,7)
    qbPad.Parent = QuickBar

    local qbToggle = Instance.new("TextButton")
    qbToggle.Size = UDim2.new(0,22,0,44)
    qbToggle.BackgroundColor3 = C.bg
    qbToggle.BackgroundTransparency = 0.15
    qbToggle.BorderSizePixel = 0
    qbToggle.Text = "‹"
    qbToggle.Font = F_MONO
    qbToggle.TextSize = 18
    qbToggle.TextColor3 = C.text
    qbToggle.AutoButtonColor = false
    qbToggle.ZIndex = 7
    qbToggle.Visible = false
    qbToggle.Parent = gui
    corner(qbToggle, 10)
    stroke(qbToggle, C.line, 1, 0.3)

    local qbPositions = {
        ["Left"] = function()
            QuickBar.AnchorPoint = Vector2.new(0,0.5)
            QuickBar.Position = UDim2.new(0, 24, 0.5, 0)
            qbToggle.AnchorPoint = Vector2.new(0,0.5)
            qbToggle.Position = UDim2.new(0, 4, 0.5, 0)
        end,
        ["Right"] = function()
            QuickBar.AnchorPoint = Vector2.new(1,0.5)
            QuickBar.Position = UDim2.new(1, -24, 0.5, 0)
            qbToggle.AnchorPoint = Vector2.new(1,0.5)
            qbToggle.Position = UDim2.new(1, -4, 0.5, 0)
        end,
        ["Bottom"] = function()
            QuickBar.AnchorPoint = Vector2.new(0.5,1)
            QuickBar.Position = UDim2.new(0.5, 0, 1, -24)
            qbToggle.AnchorPoint = Vector2.new(0.5,1)
            qbToggle.Position = UDim2.new(0.5, 0, 1, -4)
        end,
        ["Top"] = function()
            QuickBar.AnchorPoint = Vector2.new(0.5,0)
            QuickBar.Position = UDim2.new(0.5, 0, 0, 24)
            qbToggle.AnchorPoint = Vector2.new(0.5,0)
            qbToggle.Position = UDim2.new(0.5, 0, 0, 4)
        end,
        ["Left-Top"] = function()
            QuickBar.AnchorPoint = Vector2.new(0,0)
            QuickBar.Position = UDim2.new(0, 24, 0, 80)
            qbToggle.AnchorPoint = Vector2.new(0,0)
            qbToggle.Position = UDim2.new(0, 4, 0, 80)
        end,
        ["Left-Bottom"] = function()
            QuickBar.AnchorPoint = Vector2.new(0,1)
            QuickBar.Position = UDim2.new(0, 24, 1, -80)
            qbToggle.AnchorPoint = Vector2.new(0,1)
            qbToggle.Position = UDim2.new(0, 4, 1, -80)
        end,
        ["Right-Top"] = function()
            QuickBar.AnchorPoint = Vector2.new(1,0)
            QuickBar.Position = UDim2.new(1, -24, 0, 80)
            qbToggle.AnchorPoint = Vector2.new(1,0)
            qbToggle.Position = UDim2.new(1, -4, 0, 80)
        end,
        ["Right-Bottom"] = function()
            QuickBar.AnchorPoint = Vector2.new(1,1)
            QuickBar.Position = UDim2.new(1, -24, 1, -80)
            qbToggle.AnchorPoint = Vector2.new(1,1)
            qbToggle.Position = UDim2.new(1, -4, 1, -80)
        end,
    }

    local currentQbPos = "Left"
    local qbEnabled, qbExpanded = false, false
    local qbShown = UDim2.new(0, 24, 0.5, 0)
    local qbToken = 0
    local qbAnimUntil = 0

    local function qbArrowFor(pos, expanded)
        local d
        if pos:find("Left") then d = "L"
        elseif pos:find("Right") then d = "R"
        elseif pos == "Top" then d = "T"
        else d = "B" end
        local closeArrow = {L = "‹", R = "›", T = "▲", B = "▼"}
        local openArrow = {L = "›", R = "‹", T = "▼", B = "▲"}
        return expanded and closeArrow[d] or openArrow[d]
    end
    local function qbSetArrow() qbToggle.Text = qbArrowFor(currentQbPos, qbExpanded) end
    local function qbHiddenFrom(p)
        local o = 140
        if currentQbPos:find("Left") then
            return UDim2.new(p.X.Scale, p.X.Offset - o, p.Y.Scale, p.Y.Offset)
        elseif currentQbPos:find("Right") then
            return UDim2.new(p.X.Scale, p.X.Offset + o, p.Y.Scale, p.Y.Offset)
        elseif currentQbPos == "Top" then
            return UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset - o)
        else
            return UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset + o)
        end
    end
    local function qbExpand()
        qbToken = qbToken + 1
        qbExpanded = true
        QuickBar.Visible = true
        if QuickBar.GroupTransparency > 0.95 then QuickBar.Position = qbHiddenFrom(qbShown) end
        qbAnimUntil = os.clock() + 0.55
        tween(QuickBar, 0.5, {Position = qbShown, GroupTransparency = 0}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        qbSetArrow()
    end
    local function qbCollapse()
        qbToken = qbToken + 1
        local my = qbToken
        if qbExpanded and os.clock() > qbAnimUntil then qbShown = QuickBar.Position end
        qbExpanded = false
        tween(QuickBar, 0.4, {Position = qbHiddenFrom(qbShown), GroupTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        qbSetArrow()
        task.delay(0.42, function()
            if qbToken == my and not qbExpanded then QuickBar.Visible = false end
        end)
    end
    function applyQbPosition(pos, animate)
        if not qbPositions[pos] then pos = "Left" end
        currentQbPos = pos
        qbPositions[pos]()
        qbShown = QuickBar.Position
        qbSetArrow()
        if not qbEnabled then
            QuickBar.Position = qbHiddenFrom(qbShown)
            return
        end
        if qbExpanded then
            if animate then
                QuickBar.Position = qbHiddenFrom(qbShown)
                qbAnimUntil = os.clock() + 0.55
                tween(QuickBar, 0.45, {Position = qbShown}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            end
        else
            QuickBar.Position = qbHiddenFrom(qbShown)
        end
    end
    function setQuickBarVisible(on)
        on = on and true or false
        if qbEnabled == on then return end
        qbEnabled = on
        if on then
            qbPositions[currentQbPos]()
            qbShown = QuickBar.Position
            qbToggle.Visible = true
            qbToggle.BackgroundTransparency = 1
            tween(qbToggle, 0.4, {BackgroundTransparency = 0.15}, Enum.EasingStyle.Quint)
            qbExpand()
        else
            qbCollapse()
            tween(qbToggle, 0.35, {BackgroundTransparency = 1}, Enum.EasingStyle.Quint)
            task.delay(0.45, function()
                if not qbEnabled then qbToggle.Visible = false end
            end)
        end
    end

    makeDraggable(qbHandle, QuickBar, nil)
    qbToggle.MouseButton1Click:Connect(function()
        if not qbEnabled then return end
        if qbExpanded then qbCollapse() else qbExpand() end
    end)
    qbToggle.MouseEnter:Connect(function() tween(qbToggle, 0.15, {BackgroundTransparency = 0}) end)
    qbToggle.MouseLeave:Connect(function() if qbEnabled then tween(qbToggle, 0.15, {BackgroundTransparency = 0.15}) end end)

    local function qbCurrentColor()
        local n = Flags["Misc/Quick Bar Color"] or "Accent"
        if n == "Accent" then return ACC end
        return getColor(n, os.clock(), 0)
    end

    local quickButtons = {}
    local function makeQuickButton(label, flagKey, iconText, defVisible, action)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1,0,0,42)
        b.BackgroundColor3 = C.row
        b.BackgroundTransparency = 0.4
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.Font = F_MONO
        b.TextSize = 11
        b.TextColor3 = C.dim
        b.Text = iconText or label
        b.LayoutOrder = #quickButtons+1
        b.Parent = QuickBar
        corner(b, 9)
        local bs = stroke(b, C.line, 1, 0.4)
        local function paint()
            local on = Flags[flagKey]
            if action then on = false end
            local qc = qbCurrentColor()
            b.BackgroundColor3 = on and qc or C.row
            b.BackgroundTransparency = on and 0.2 or 0.4
            b.TextColor3 = action and qc or (on and C.bg or C.dim)
            bs.Color = (on or action) and qc or C.line
            bs.Transparency = on and 0 or 0.4
        end
        b.MouseButton1Click:Connect(function()
            if action then pcall(action); return end
            local newVal = not Flags[flagKey]
            if Setters[flagKey] then Setters[flagKey](newVal)
            else Flags[flagKey] = newVal end
            paint()
            notify((newVal and "ON  " or "OFF ")..label)
        end)
        b.MouseEnter:Connect(function() if not Flags[flagKey] then b.BackgroundTransparency = 0.15 end end)
        b.MouseLeave:Connect(paint)
        quickButtons[#quickButtons+1] = {btn = b, flag = flagKey, paint = paint, label = label, def = defVisible}
        paint()
        return b
    end
    for _, act in ipairs(QB_ACTIONS) do
        makeQuickButton(act.label, act.flag, act.icon, act.def, act.action)
    end

    function refreshQuickBar()
        local qc = qbCurrentColor()
        qbStroke.Color = qc
        for _, qb in ipairs(quickButtons) do
            local v = Flags["Misc/QB "..qb.label]
            if v == nil then v = qb.def end
            qb.btn.Visible = v and true or false
            qb.paint()
        end
    end
    refreshQuickBar()
    task.spawn(function()
        while gui.Parent do
            task.wait(0.25)
            refreshQuickBar()
        end
    end)
end)

teleportToGunRef = teleportToGun

-- ========================= TABS =========================
local visTab = createTab("Visuals")
visTab:Label("ESP")
visTab:Toggle("ESP Box", false)
visTab:Toggle("Role", false)
visTab:Toggle("Color by Role", false)
visTab:Toggle("Name", false)
visTab:Toggle("Health", false)
visTab:Toggle("Distance", false)
visTab:Toggle("Tracers", false)
visTab:Toggle("Skeleton", false)
visTab:Toggle("Chams", false)
visTab:Toggle("Glow", false)
visTab:Slider("Chams Fill", 0, 100, 50)
visTab:Choice("ESP Color", COLOR_NAMES, "Lime")
visTab:Label("Gun ESP")
visTab:Toggle("Gun ESP", false)
visTab:Choice("Gun Color", COLOR_NAMES, "Gold")
visTab:Button("Teleport to Gun", teleportToGun)
visTab:Label("Wings")
visTab:Toggle("Wings", false, function(s) if s then buildWings() else destroyCos("wings") end end)
visTab:Choice("Wing Color", WING_COLORS, "White")
visTab:Slider("Wing Speed", 1, 10, 3)
visTab:Label("Chinese Hat")
visTab:Toggle("Chinese Hat", false, function(s) if s then buildHat() else destroyCos("hat") end end)
visTab:Choice("Hat Color", HAT_COLORS, "Custom")
visTab:Slider("Hat Transparency", 0, 100, 35)
visTab:Label("Trail")
visTab:Toggle("Trail", false, function(s) if s then buildTrail() else destroyCos("trail") end end)
visTab:Choice("Trail Color", COLOR_NAMES, "Rainbow")
visTab:Slider("Trail Length", 1, 30, 10)
visTab:Slider("Trail Width", 1, 10, 4)

-- ========================= CUSTOM COLOR TAB (HSV) =========================
do
    local colorTab = createTab("Custom Color")
    colorTab:Label("HSV Color Picker")
    local colorPreview = colorTab:Frame(60)
    colorPreview.BackgroundColor3 = customColor()
    corner(colorPreview, 8)
    stroke(colorPreview, WHITE, 1, 0.5)
    local pLbl = Instance.new("TextLabel")
    pLbl.BackgroundTransparency = 1
    pLbl.Size = UDim2.new(1,0,1,0)
    pLbl.Font = F_MONO
    pLbl.TextSize = 13
    pLbl.TextColor3 = WHITE
    pLbl.TextStrokeTransparency = 0.3
    pLbl.TextStrokeColor3 = Color3.new(0,0,0)
    pLbl.Text = "CUSTOM COLOR PREVIEW"
    pLbl.Parent = colorPreview

    local function updatePreview()
        colorPreview.BackgroundColor3 = customColor()
    end
    local function refreshGrads()
        for _, k in ipairs({"Color/Hue","Color/Saturation","Color/Brightness"}) do
            local f = GradRefresh[k]
            if f then f() end
        end
    end

    colorTab:Slider("Hue", 0, 360, 120,
        function(v)
            HSV.h = v / 360
            updatePreview()
            refreshGrads()
        end,
        hueSeq)

    colorTab:Slider("Saturation", 0, 100, 85,
        function(v)
            HSV.s = v / 100
            updatePreview()
            refreshGrads()
        end,
        satSeq)

    colorTab:Slider("Brightness", 0, 100, 100,
        function(v)
            HSV.v = v / 100
            updatePreview()
            refreshGrads()
        end,
        valSeq)

    colorTab:Button("Apply Custom to everything", function()
        local keys = {
            "Visuals/ESP Color",
            "Visuals/Wing Color",
            "Visuals/Gun Color",
            "Visuals/Hat Color",
            "Visuals/Trail Color",
            "Misc/Quick Bar Color"
        }
        for _, k in ipairs(keys) do
            if Setters[k] then Setters[k]("Custom") end
        end
        Skin.refresh()
        notify("Custom applied everywhere")
    end)

    colorTab:Label2("Выбери 'Custom' в любом Choice цвета, чтобы использовать этот HSV.", F_MONO, 10, C.dim)
end

-- ========================= AIMBOT TAB =========================
do
    local aimTab = createTab("Aimbot")
    aimTab:Label("Aim")
    aimTab:Toggle("Enable", false)
    aimTab:Toggle("Auto Shoot", true)
    aimTab:Slider("Shoot Delay (ms)", 10, 500, 100)
    aimTab:Toggle("Skip Innocents", true)
    aimTab:Toggle("Weapon Only", true)
    aimTab:Toggle("Wall Check", true)
    aimTab:Choice("Body Part", AIM_NAMES, "Head")
    aimTab:Slider("FOV", 10, 360, 120)
    aimTab:Slider("Smoothness", 1, 100, 30)
    aimTab:Toggle("Show FOV", true)
    aimTab:Label("Auto Win")
    aimTab:Toggle("Auto Win", false, function(s) if s then startAutoWin() else stopAutoWin() end end)
    aimTab:Toggle("Auto Teleport", true, function(s) AutoWin.Teleport = s end)
    aimTab:Toggle("Auto Equip Weapon", true, function(s) AutoWin.AutoEquip = s end)
    aimTab:Slider("Auto Win Delay (ms)", 50, 600, 200, function(v) AutoWin.Delay = (tonumber(v) or 200) / 1000 end)
    aimTab:Button("Show AutoWin Status", function() notify("AutoWin: "..AutoWin.Status) end)
end

-- ========================= KILL AURA TAB =========================
do
    local kaTab = createTab("Kill Aura")
    kaTab:Label("Kill Aura")
    kaTab:Toggle("Enable", false, function(s)
        if s then KillAura.start() else KillAura.stop() end
    end)
    kaTab:Slider("Range (studs)", 3, 60, 25, function(v) KillAura.Range = v end)
    kaTab:Slider("Hit Delay (ms)", 10, 500, 80, function(v) KillAura.DamageDelay = v end)
    kaTab:Toggle("Auto Equip Weapon", true, function(s) KillAura.AutoEquip = s end)
    kaTab:Toggle("Ignore Innocents", true, function(s) KillAura.IgnoreInnocents = s end)
    kaTab:Toggle("Wall Check", false, function(s) KillAura.WallCheck = s end)
    kaTab:Toggle("Teleport to Target", true, function(s) KillAura.Teleport = s end)
    kaTab:Button("Show Kill Aura Status", function() notify("KillAura: "..KillAura.Status) end)
end

-- ========================= STRETCH TAB =========================
do
    local stTab = createTab("Stretch")
    stTab:Label("Растяг (Aspect / FOV)")
    stTab:Choice("Preset", STRETCH_PRESETS, "Default", function(v)
        Stretch.setPreset(v)
    end)
    stTab:Slider("Horizontal %", 50, 200, 100, function(v)
        Stretch.H = v
        if Stretch.Preset ~= "Custom" then Stretch.Preset = "Custom" end
        Stretch.apply()
    end)
    stTab:Slider("Vertical %", 50, 200, 100, function(v)
        Stretch.V = v
        if Stretch.Preset ~= "Custom" then Stretch.Preset = "Custom" end
        Stretch.apply()
    end)
    stTab:Slider("Base FOV", 40, 120, 70, function(v)
        Stretch.FOV = v
        Stretch.apply()
    end)
    stTab:Button("Apply Stretch", function() Stretch.apply(); notify("Stretch applied") end)
    stTab:Button("Reset Stretch", function() Stretch.setPreset("Default"); notify("Stretch reset") end)
end

-- ========================= MOVE TAB =========================
do
    local moveTab = createTab("Move")
    moveTab:Label("Fly")
    moveTab:Toggle("Fly", false, function(state)
        Move.Fly = state
        if state then enableFlyMove() else disableFlyMove() end
        local show = state and UIS.TouchEnabled
        flyUpBtn.Visible = show
        flyDownBtn.Visible = show
        notify(state and "Fly ON" or "Fly OFF")
    end)
    moveTab:Slider("Fly Speed", 10, 300, 60, function(v) Move.Speed = v end)
    moveTab:Label("Noclip")
    moveTab:Toggle("Noclip", false, function(state)
        Move.Noclip = state
        setNoclipMove(state)
        notify(state and "Noclip ON" or "Noclip OFF")
    end)
    moveTab:Label("Teleport")
    moveTab:Button("Teleport to Gun", teleportToGun)
    moveTab:Label("Walkspeed & Spin")
    moveTab:Slider("WalkSpeed", 16, 1000, 16, function(v) applyWalkSpeed(v) end)
    moveTab:Button("Reset WalkSpeed (16)", function()
        applyWalkSpeed(16)
        local s = Setters["Move/WalkSpeed"]
        if s then s(16) end
    end)
    moveTab:Toggle("Spin", false, function(s) if s then startSpin() else stopSpin() end end)
    moveTab:Slider("Spin Speed", 0, 1000, 0, function(v) Move2.SpinSpeed = v end)
    moveTab:Button("Reset Spin (0)", function()
        Move2.SpinSpeed = 0
        local s = Setters["Move/Spin Speed"]
        if s then s(0) end
    end)
    moveTab:Label("Bunnyhop")
    moveTab:Toggle("Bunnyhop", false, function(s)
        BHop.Enabled = s
        notify(s and "Bhop ON" or "Bhop OFF")
    end)
    moveTab:Slider("Bhop Accel", 0, 300, 40, function(v) BHop.Accel = v end)
    moveTab:Slider("Bhop Boost/hop", 0, 30, 4, function(v) BHop.Boost = v end)
    moveTab:Slider("Bhop Max Speed", 20, 400, 120, function(v) BHop.Max = v end)
end

-- ========================= FARM TAB =========================
do
    local farmTab = createTab("Farm")
    farmTab:Label("Coin auto-farm")
    farmTab:Toggle("Enable Farm", false, function(state)
        Farm.Enabled = state
        if state then
            startFarm()
            if Farm.Mode == "Fly" or Farm.Mode == "Noclip" then setNoclip(true) end
            notify("Farm ON ("..Farm.Mode..")")
        else
            stopFarm()
            notify("Farm OFF")
        end
    end)
    farmTab:Choice("Mode", {"Teleport","Fly","Noclip"}, "Teleport", function(v)
        Farm.Mode = v
        if Farm.Enabled then
            disableFly()
            setNoclip(v == "Fly" or v == "Noclip")
        end
    end)
    farmTab:Slider("Speed (safe)", 5, 400, 80, function(v) Farm.Speed = v end)
    farmTab:Slider("Teleport Delay (ms)", 0, 500, 150, function(v) Farm.TeleportDelay = (tonumber(v) or 0) / 1000 end)
    farmTab:Toggle("Anti-AFK", false, function(state)
        Farm.AntiAFK = state
        setAntiAFK(state)
    end)
    farmTab:Toggle("Return to Start", false, function(state) Farm.ReturnOnFinish = state end)
    farmTab:Button("Reset Counter", function()
        Farm.Collected = 0
        notify("Counter reset")
    end)
    farmTab:Button("Show Status", function()
        notify("Collected: "..Farm.Collected.." | "..Farm.Status)
    end)
end

-- ========================= MISC TAB =========================
do
    local miscTab = createTab("Misc")
    local function charOf(plr)
        local c = plr and plr.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if c and h and r and h.Health > 0 then return c, h, r end
        return nil
    end
    local function tpToRole(role)
        local _, _, me = charOf(LP)
        if not me then notify("No character"); return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and getRoleCached(plr) == role then
                local _, _, r = charOf(plr)
                if r then
                    me.CFrame = r.CFrame * CFrame.new(0,0,3)
                    me.AssemblyLinearVelocity = Vector3.zero
                    notify("TP to "..role)
                    return
                end
            end
        end
        notify(role.." not found")
    end
    miscTab:Label("Teleport")
    miscTab:Button("Teleport to Murderer", function() tpToRole("Murderer") end)
    miscTab:Button("Teleport to Sheriff", function() tpToRole("Sheriff") end)

    miscTab:Label("Quick Bar")
    miscTab:Toggle("Quick Bar", false, function(s)
        setQuickBarVisible(s)
        notify(s and "Quick Bar ON" or "Quick Bar OFF")
    end)
    miscTab:Choice("Quick Bar Position", QB_POSITIONS, "Left", function(v)
        applyQbPosition(v, true)
        notify("QB: "..v)
    end)
    miscTab:Choice("Quick Bar Color", {"Accent","Rainbow","Custom","Lime","Coral","Ice","Violet","Gold","Red","Green","Blue","Pink","White"}, "Accent", function() refreshQuickBar() end)
    miscTab:Label("Quick Bar Buttons")
    local QB_NAMES = {"Aimbot","Auto Shoot","Kill Aura","Fly","Noclip","Bunnyhop","Auto Win","Auto Farm","TP Gun","Spin","ESP Box","Chams","Skeleton","Tracers","Gun ESP","Wings","Chinese Hat","Trail"}
    for _, n in ipairs(QB_NAMES) do
        miscTab:Toggle("QB "..n, true, function() refreshQuickBar() end)
    end
    miscTab:Label("Screen")
    miscTab:Choice("Aspect Ratio", SCREEN_RATIOS, "Default", function(v)
        ScreenRes.apply(v, true)
        notify("Screen: "..v)
    end)
end

-- ========================= INFO TAB =========================
do
    local setTab = createTab("Info")
    setTab:Label("About luxxs")
    setTab:Label2("luxxs v6.1 - crafted by DrHub", F_MONO, 12, C.text)
    setTab:Label2("Telegram: "..TELEGRAM_LINK, F_MONO, 11, C.dim)
    setTab:Button("Copy Telegram link", function()
        if type(setclipboard) == "function" then
            pcall(setclipboard, TELEGRAM_LINK)
            notify("Link copied!")
        else
            notify(TELEGRAM_LINK)
        end
    end)
    setTab:Label("Interface")
    setTab:Choice("Accent", ACCENT_NAMES, ACC_NAME, function(n)
        setAccent(ACCENTS[n])
        restyleTabs()
        refreshQuickBar()
        if hasFS then
            ensureFolder()
            pcall(function() writefile(FOLDER.."/accent.txt", n) end)
        end
    end)
    setTab:Label("Appearance")
    setTab:Slider("Menu Opacity %", 20, 100, 94, function(v)
        MenuAlpha = math.clamp(v/100, 0, 1)
        if isOpen then main.GroupTransparency = 1 - MenuAlpha end
    end)
    setTab:Slider("Menu Scale %", 70, 130, 100, function(v)
        MenuScale = math.clamp((tonumber(v) or 100)/100, 0.5, 2)
        if isOpen then scale.Scale = fitScale() * MenuScale end
    end)
    setTab:Label("Configs")
    do
        local SLOTS = {"1","2","3","4","5"}
        local function cfgPath(s) return FOLDER.."/config_"..s..".json" end
        local function saveConfig(slot)
            if not hasFS then notify("FS not available"); return end
            ensureFolder()
            local data = {}
            for k, v in pairs(Flags) do data[k] = v end
            local ok = pcall(function() writefile(cfgPath(slot), HttpService:JSONEncode(data)) end)
            notify(ok and ("Saved slot "..slot) or "Save error")
        end
        local function loadConfig(slot)
            if not hasFS then notify("FS not available"); return end
            local path = cfgPath(slot)
            if not isfile(path) then notify("Slot "..slot.." empty"); return end
            local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
            if not ok or type(data) ~= "table" then notify("Read error"); return end
            for k, v in pairs(data) do
                if Setters[k] then Setters[k](v) end
            end
            notify("Loaded slot "..slot)
        end
        setTab:Choice("Config Slot", SLOTS, "1")
        setTab:Button("Save Config", function() saveConfig(Flags["Info/Config Slot"] or "1") end)
        setTab:Button("Load Config", function() loadConfig(Flags["Info/Config Slot"] or "1") end)
        setTab:Button("Reset All", function()
            for k, d in pairs(Defaults) do
                if Setters[k] then Setters[k](d) end
            end
            notify("Settings reset")
        end)
    end
    setTab:Button("Close Menu", closeMenu)
    setTab:Button("Unload luxxs", function()
        for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
        destroyCos("wings"); destroyCos("hat"); destroyCos("trail")
        for plr in pairs(espData) do removeESP(plr) end
        for p in pairs(GunESP.vis) do dropGunVisual(p) end
        pcall(function() GunFolder:Destroy() end)
        pcall(disableFlyMove)
        pcall(setNoclipMove, false)
        pcall(stopAutoWin)
        pcall(stopSpin)
        pcall(KillAura.stop)
        BHop.Enabled = false
        pcall(Skin.restoreAll)
        stopFarm()
        disableFps()
        gui:Destroy()
        fpsGui:Destroy()
    end)
end

-- ========================= SKINS TAB =========================
do
    local skinTab = createTab("Skins")
    skinTab:Label("Weapon skins (visual, hand + backpack)")
    skinTab:Toggle("Enable", false, function() Skin.refresh() end)
    skinTab:Label2("Knife skin:", F_MONO, 10, C.dim)
    skinTab:List("Knife Skin", SKIN_NAMES, "Off", function()
        task.spawn(function() task.wait(0.05); Skin.refresh() end)
    end)
    skinTab:Label2("Gun skin:", F_MONO, 10, C.dim)
    skinTab:List("Gun Skin", SKIN_NAMES, "Off", function()
        task.spawn(function() task.wait(0.05); Skin.refresh() end)
    end)
    skinTab:Label("Custom mesh")
    skinTab:Input("Knife MeshId", "", function(txt) Skin.cfg.KnifeMesh = txt; Skin.refresh() end)
    skinTab:Input("Knife TextureId", "", function(txt) Skin.cfg.KnifeTex = txt; Skin.refresh() end)
    skinTab:Input("Gun MeshId", "", function(txt) Skin.cfg.GunMesh = txt; Skin.refresh() end)
    skinTab:Input("Gun TextureId", "", function(txt) Skin.cfg.GunTex = txt; Skin.refresh() end)
    skinTab:Slider("Mesh Scale %", 10, 500, 100, function() Skin.refresh() end)
    skinTab:Button("Remove all skins", function()
        if Setters["Skins/Knife Skin"] then Setters["Skins/Knife Skin"]("Off") end
        if Setters["Skins/Gun Skin"] then Setters["Skins/Gun Skin"]("Off") end
        Skin.cfg.KnifeMesh = ""
        Skin.cfg.KnifeTex = ""
        Skin.cfg.GunMesh = ""
        Skin.cfg.GunTex = ""
        Skin.refresh()
        notify("Skins removed")
    end)
end

-- ========================= FPS TAB =========================
do
    local fpsTab = createTab("FPS")
    fpsTab:Toggle("Enable Unlock", false, function(state)
        FPS.Enabled = state
        if state then enableFps() else disableFps() end
    end)
    fpsTab:Slider("Target FPS", 60, 10000, 10000, function(v)
        FPS.Target = v
        if FPS.Enabled then applyFpsCap(v) end
    end)
    fpsTab:Toggle("Show Counter", true, function(state) fpsFrame.Visible = state end)
    fpsTab:Toggle("Remove Shadows", false, function(state) Lighting.GlobalShadows = not state end)
    fpsTab:Toggle("Remove Fog", false, function(state) Lighting.FogEnd = state and 1e6 or 100000 end)
end

-- ========================= PROFILE TAB =========================
local profUser, profRole, profSession, profCoins
do
    local profileTab = createTab("Profile")
    profileTab:Label("Player")
    profUser = profileTab:Label2("USER      "..LP.Name, F_MONO, 13, C.text)
    profRole = profileTab:Label2("ROLE      Innocent", F_MONO, 13, C.text)
    profSession = profileTab:Label2("SESSION   00:00:00", F_MONO, 12, C.dim)
    profCoins = profileTab:Label2("COINS     0", F_MONO, 12, C.dim)
end

-- ========================= PREVIEW PANEL =========================
do
    local function solid(p, x, y, w, h, color, z, r)
        local f = Instance.new("Frame")
        f.Position = UDim2.new(0,x,0,y)
        f.Size = UDim2.new(0,w,0,h)
        f.BackgroundColor3 = color
        f.BorderSizePixel = 0
        f.ZIndex = z or 1
        f.Parent = p
        if r and r > 0 then corner(f, r) end
        return f
    end
    previewPanel.BackgroundColor3 = WHITE
    previewPanel.ClipsDescendants = true
    corner(previewPanel, 14)
    gradient(previewPanel, 90, ColorSequence.new(Color3.fromRGB(34,24,50), Color3.fromRGB(8,8,12)))
    T(stroke(previewPanel, ACC, 1.5, 0.4), "Color")

    local cap = Instance.new("TextLabel")
    cap.BackgroundTransparency = 1
    cap.Position = UDim2.new(0,12,0,3)
    cap.Size = UDim2.new(0,200,0,18)
    cap.Font = F_MONO
    cap.TextSize = 10
    cap.TextColor3 = C.dim
    cap.TextXAlignment = Enum.TextXAlignment.Left
    cap.Text = "PREVIEW // LIVE"
    cap.ZIndex = 9
    cap.Parent = previewPanel

    local body = solid(previewPanel, 101, 60, 50, 220, BODY_GRAY, 3, 4)
    gradient(body, 90, ColorSequence.new(WHITE, Color3.fromRGB(140,140,150)))

    local roleTag = Instance.new("TextLabel")
    roleTag.BackgroundTransparency = 1
    roleTag.Position = UDim2.new(0,10,0,230)
    roleTag.Size = UDim2.new(1,-20,0,14)
    roleTag.Font = F_MONO
    roleTag.TextSize = 10
    roleTag.TextColor3 = C.dim
    roleTag.TextXAlignment = Enum.TextXAlignment.Left
    roleTag.ZIndex = 9
    roleTag.Parent = previewPanel
    roleTag.Text = "ROLE: MURDERER"

    task.spawn(function()
        while gui.Parent do
            task.wait(0.1)
            if isOpen then
                local t = os.clock()
                local ecol = Flags["Visuals/Color by Role"] and ROLE_COLORS.Murderer or getColor(Flags["Visuals/ESP Color"], t, 0)
                body.BackgroundColor3 = Flags["Visuals/Chams"] and ecol or BODY_GRAY
                local role = getRoleCached(LP)
                roleTag.Text = "ROLE: "..string.upper(role)
                roleTag.TextColor3 = ROLE_COLORS[role] or C.dim
            end
        end
    end)
end

selectTab(visTab)
print("[luxxs] UI built, ready")

-- ========================= CHARACTER RESPAWN =========================
track(LP.CharacterAdded:Connect(function(c)
    c:WaitForChild("HumanoidRootPart", 10)
    c:WaitForChild("Head", 10)
    task.wait(0.3)
    if Flags["Visuals/Wings"] then buildWings() end
    if Flags["Visuals/Chinese Hat"] then buildHat() end
    if Flags["Visuals/Trail"] then buildTrail() end
    if Flags["Move/Fly"] and enableFlyMove then enableFlyMove() end
end))

-- ========================= PROFILE UPDATER =========================
task.spawn(function()
    local startTick = tick()
    while gui.Parent do
        task.wait(1)
        local s = math.floor(tick() - startTick)
        local hh = math.floor(s/3600)
        local mm = math.floor((s%3600)/60)
        local ss = s % 60
        local role = getRoleCached(LP)
        profSession.Text = string.format("SESSION   %02d:%02d:%02d", hh, mm, ss)
        profRole.Text = "ROLE      "..role
        profCoins.Text = "COINS     "..Farm.Collected
        footR.Text = "ROLE  "..string.upper(role)
        footR.TextColor3 = (role ~= "Innocent") and (ROLE_COLORS[role] or C.dim) or C.dim
    end
end)

-- ========================= MOBILE JOYSTICK KEEP-ALIVE =========================
task.spawn(function()
    while gui.Parent do
        task.wait(0.4)
        if UIS.TouchEnabled and not UIS.KeyboardEnabled
            and (Flags["Aimbot/Enable"] or Flags["Aimbot/Auto Win"] or Flags["KillAura/Enable"]) then
            pcall(function()
                local pg = LP:FindFirstChildOfClass("PlayerGui")
                local tg = pg and pg:FindFirstChild("TouchGui")
                if not tg then return end
                if not tg.Enabled then tg.Enabled = true end
                local f = tg:FindFirstChild("TouchControlFrame")
                if f then
                    if not f.Visible then f.Visible = true end
                    for _, n in ipairs({"DynamicThumbstickFrame","ThumbstickFrame"}) do
                        local t = f:FindFirstChild(n)
                        if t and not t.Visible then t.Visible = true end
                    end
                end
            end)
        end
    end
end)

-- ========================= AUTO OPEN =========================
task.spawn(function()
    local t0 = os.clock()
    while parent:FindFirstChild("luxxsKey") and os.clock() - t0 < 8 do
        task.wait(0.1)
    end
    task.wait(0.2)
    openMenu()
end)

if #__errs > 0 then
    notify("Module error (see console): "..__errs[1]:sub(1,70))
end
notify("luxxs v6.1 // ESC or RIGHTSHIFT")

end, function(e) return tostring(e).."\n"..tostring(debug.traceback()) end)

-- ========================= CRASH HANDLER =========================
if not __LX_ok then
    warn("[luxxs] CRASH: "..tostring(__LX_err))
    pcall(function()
        local host = (gethui and gethui()) or game:GetService("CoreGui")
        local sg = Instance.new("ScreenGui")
        sg.Name = "luxxsError"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.DisplayOrder = 1000
        sg.Parent = host

        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5,0.5)
        f.Position = UDim2.new(0.5,0,0.5,0)
        f.Size = UDim2.new(0.9,0,0.6,0)
        f.BackgroundColor3 = Color3.fromRGB(20,14,16)
        f.BorderSizePixel = 0
        f.Parent = sg
        Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)

        local st = Instance.new("UIStroke")
        st.Color = Color3.fromRGB(255,84,84)
        st.Thickness = 2
        st.Parent = f

        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.Position = UDim2.new(0,12,0,8)
        t.Size = UDim2.new(1,-24,0,24)
        t.Font = Enum.Font.RobotoMono
        t.TextSize = 16
        t.TextColor3 = Color3.fromRGB(255,120,120)
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Text = "luxxs crashed - send this text to the developer"
        t.Parent = f

        local box = Instance.new("TextBox")
        box.Position = UDim2.new(0,12,0,40)
        box.Size = UDim2.new(1,-24,1,-96)
        box.BackgroundColor3 = Color3.fromRGB(10,8,10)
        box.BorderSizePixel = 0
        box.ClearTextOnFocus = false
        box.TextEditable = false
        box.MultiLine = true
        box.TextWrapped = true
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.TextYAlignment = Enum.TextYAlignment.Top
        box.Font = Enum.Font.RobotoMono
        box.TextSize = 13
        box.TextColor3 = Color3.fromRGB(235,235,235)
        box.Text = tostring(__LX_err)
        box.Parent = f

        local b1 = Instance.new("TextButton")
        b1.AnchorPoint = Vector2.new(0,1)
        b1.Position = UDim2.new(0,12,1,-10)
        b1.Size = UDim2.new(0,130,0,32)
        b1.BackgroundColor3 = Color3.fromRGB(60,30,34)
        b1.BorderSizePixel = 0
        b1.Font = Enum.Font.RobotoMono
        b1.TextSize = 14
        b1.TextColor3 = Color3.fromRGB(255,255,255)
        b1.Text = "COPY"
        b1.Parent = f
        Instance.new("UICorner", b1).CornerRadius = UDim.new(0,8)
        b1.MouseButton1Click:Connect(function()
            if setclipboard then pcall(setclipboard, tostring(__LX_err)); t.Text = "copied!" end
        end)

        local b2 = Instance.new("TextButton")
        b2.AnchorPoint = Vector2.new(0,1)
        b2.Position = UDim2.new(0,152,1,-10)
        b2.Size = UDim2.new(0,130,0,32)
        b2.BackgroundColor3 = Color3.fromRGB(60,30,34)
        b2.BorderSizePixel = 0
        b2.Font = Enum.Font.RobotoMono
        b2.TextSize = 14
        b2.TextColor3 = Color3.fromRGB(255,255,255)
        b2.Text = "CLOSE"
        b2.Parent = f
        Instance.new("UICorner", b2).CornerRadius = UDim.new(0,8)
        b2.MouseButton1Click:Connect(function() sg:Destroy() end)
    end)
end
