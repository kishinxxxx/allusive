if _G._bbfarm then return end
_G._bbfarm = true

local cloneref = cloneref or function(x) return x end
local game = game
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UIS = cloneref(game:GetService("UserInputService"))
local RS = cloneref(game:GetService("ReplicatedStorage"))
local WS = cloneref(game:GetService("Workspace"))
local Stats = cloneref(game:GetService("Stats"))
local Debris = cloneref(game:GetService("Debris"))
local HTTP = cloneref(game:GetService("HttpService"))
local TweenService = cloneref(game:GetService("TweenService"))
local TextService = cloneref(game:GetService("TextService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local VIM = Instance.new("VirtualInputManager")

local lp = Players.LocalPlayer
local cam = WS.CurrentCamera
local hb = RunService.Heartbeat
local preSim = RunService.PreSimulation
local postSim = RunService.PostSimulation
local renderStep = RunService.RenderStepped

WS:GetPropertyChangedSignal("CurrentCamera"):Connect(function() cam = WS.CurrentCamera end)
repeat task.wait() until game:IsLoaded()

local remotes = RS:WaitForChild("Remotes", 10)
local balls = WS:WaitForChild("Balls", 10)
local runtime = WS:FindFirstChild("Runtime")
local dataPing = Stats.Network.ServerStatsItem["Data Ping"]
local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled


local FOLDER = "nothing"
local FILE = FOLDER .. "/config.json"

pcall(function()
    if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
        if not isfolder(FOLDER) then makefolder(FOLDER) end
    end
end)

local cfg = {
    auto_parry = false,
    accuracy = 50,
    orbit = false,
    orbit_speed = 50,
    orbit_dist = 15,
    orbit_height = 5,
    orbit_stick = false,
    no_render = false,
    ability_module = false,
    ability_round = false,
    ability_continuous = false,
    simple_tp = false,
    simple_tp_continuous = false,
    simple_tp_round = false,
    randomize_accuracy = false,
    random_accuracy_min = 30,
    random_accuracy_max = 70,
    curve_mode = "camera",
    random_target = false,
    target_closest = false,
    toggle_key = "RightControl",
    hide_minimized = false,
    bg_transparency = 0.04,
    keybinds = {},
    _gui_colors = {},
}

local function saveCfg()
    pcall(function()
        if typeof(writefile) == "function" then
            writefile(FILE, HTTP:JSONEncode(cfg))
        end
    end)
end

local function loadCfg()
    pcall(function()
        if typeof(readfile) == "function" and typeof(isfile) == "function" and isfile(FILE) then
            local d = HTTP:JSONDecode(readfile(FILE))
            for k, v in d do
                if cfg[k] ~= nil and typeof(v) == typeof(cfg[k]) then cfg[k] = v end
            end
        end
    end)
end

loadCfg()
task.spawn(function() while _G._bbfarm do task.wait(1); saveCfg() end end)


local Colors = {
    Bg = Color3.fromRGB(11, 11, 17),
    Card = Color3.fromRGB(17, 17, 24),
    CardDeep = Color3.fromRGB(13, 13, 20),
    Stroke = Color3.fromRGB(36, 40, 58),
    StrokeHot = Color3.fromRGB(72, 76, 130),
    Accent = Color3.fromRGB(99, 102, 241),
    AccentDim = Color3.fromRGB(55, 58, 190),
    AccentSoft = Color3.fromRGB(172, 178, 255),
    Text = Color3.fromRGB(235, 235, 245),
    SubText = Color3.fromRGB(148, 152, 185),
    Danger = Color3.fromRGB(240, 70, 70),
    Success = Color3.fromRGB(72, 210, 140),
}

local function getGuiParent()
    local ok, hui = pcall(function() return typeof(gethui) == "function" and gethui() end)
    if ok and hui then return hui end
    return CoreGui
end

local function tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local function create(class, props)
    local inst = Instance.new(class)
    for k, v in props do
        if k ~= "Parent" then inst[k] = v end
    end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

pcall(function()
    for _, g in getGuiParent():GetChildren() do
        if g:IsA("ScreenGui") and g:GetAttribute("_bbfarm") then g:Destroy() end
    end
end)

local screenGui = create("ScreenGui", {
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    Parent = getGuiParent(),
})
screenGui:SetAttribute("_bbfarm", true)

local notifHolder = create("Frame", {
    Size = UDim2.new(0, 330, 1, -40),
    Position = UDim2.new(0, 18, 1, -20),
    AnchorPoint = Vector2.new(0, 1),
    BackgroundTransparency = 1,
    Parent = screenGui,
})
create("UIListLayout", { VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 10), Parent = notifHolder })

local function notify(title, text, duration)
    duration = duration or 3
    local wrap = create("Frame", { Size = UDim2.new(1, 0, 0, 56), BackgroundTransparency = 1, Parent = notifHolder })
    local card = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(16, 16, 25), BorderSizePixel = 0,
        ClipsDescendants = true, Parent = wrap,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = card })
    create("UIStroke", { Color = Colors.StrokeHot, Transparency = 0.64, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = card })
    create("TextLabel", {
        Text = title, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
        TextSize = 13, TextColor3 = Colors.Text, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 8), Size = UDim2.new(1, -28, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
    })
    create("TextLabel", {
        Text = text, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular),
        TextSize = 11, TextColor3 = Colors.SubText, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 26), Size = UDim2.new(1, -28, 0, 22),
        TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = card,
    })
    card.Position = UDim2.new(-1.1, 0, 0, 0)
    tween(card, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) })
    task.delay(duration, function()
        tween(card, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(-1.1, 0, 0, 0) })
        task.delay(0.4, function() wrap:Destroy() end)
    end)
end

local container = create("Frame", {
    Name = "Container", ClipsDescendants = true,
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Colors.Bg, BackgroundTransparency = 0.04,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 0, 0, 0),
    Active = true, BorderSizePixel = 0,
    Parent = screenGui,
})
create("UICorner", { CornerRadius = UDim.new(0, 18), Parent = container })
create("UIStroke", { Color = Colors.StrokeHot, Transparency = 0.6, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = container })

local uiScale = create("UIScale", { Parent = container })

if isMobile then
    local function rescale()
        local s = math.clamp(cam.ViewportSize.X / 1400 * 0.97, 0.68, 0.9)
        uiScale.Scale = s
    end
    rescale()
    cam:GetPropertyChangedSignal("ViewportSize"):Connect(rescale)
end

local handler = create("Frame", {
    BackgroundTransparency = 1, Size = UDim2.new(0, 698, 0, 479), BorderSizePixel = 0, Parent = container,
})

local dragging, dragStart, containerPos = false, nil, nil

handler.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; containerPos = container.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local d = input.Position - dragStart
    tween(container, TweenInfo.new(0.18), {
        Position = UDim2.new(containerPos.X.Scale, containerPos.X.Offset + d.X, containerPos.Y.Scale, containerPos.Y.Offset + d.Y)
    })
end)

local logoIcon = create("ImageLabel", {
    ScaleType = Enum.ScaleType.Fit, AnchorPoint = Vector2.new(0, 0.5),
    Image = "rbxassetid://6723684733", BackgroundTransparency = 1,
    Position = UDim2.new(0.025, 0, 0.055, 0), Size = UDim2.fromOffset(18, 18),
    BorderSizePixel = 0, ImageColor3 = Colors.AccentSoft, Parent = handler,
})
create("TextLabel", {
    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
    TextColor3 = Colors.Accent, Text = "nothing", TextSize = 15,
    Size = UDim2.new(0, 80, 0, 14), Position = UDim2.new(0.056, 0, 0.055, 0),
    BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = handler,
})

local function addDivider(pos, size)
    local d = create("Frame", {
        BackgroundTransparency = 0.38, BorderSizePixel = 0, BackgroundColor3 = Colors.Stroke,
        Position = pos, Size = size, Parent = handler,
    })
    create("UIGradient", {
        Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0), NumberSequenceKeypoint.new(0.7, 0), NumberSequenceKeypoint.new(1, 1) }),
        Parent = d,
    })
end
addDivider(UDim2.new(0.23, 0, 0.12, 0), UDim2.new(0, 450, 0, 1))
addDivider(UDim2.new(0, 0, 0.12, 0), UDim2.new(0, 157, 0, 1))

local vertDiv = create("Frame", {
    BackgroundTransparency = 0.48, BorderSizePixel = 0, BackgroundColor3 = Colors.Stroke,
    Position = UDim2.new(0.225, 0, 0.13, 0), Size = UDim2.new(0, 1, 0.78, 0), Parent = handler,
})
create("UIGradient", {
    Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.15, 0), NumberSequenceKeypoint.new(0.85, 0), NumberSequenceKeypoint.new(1, 1) }),
    Rotation = 90, Parent = vertDiv,
})

local tabsList = create("ScrollingFrame", {
    ScrollBarImageTransparency = 1, ScrollBarThickness = 0,
    Size = UDim2.new(0, 129, 0, 440), Selectable = false,
    AutomaticCanvasSize = Enum.AutomaticSize.XY,
    BackgroundTransparency = 1, Position = UDim2.new(0.026, 0, 0.16, 0),
    BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0.5, 0), Parent = handler,
})
create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tabsList })

local sectionsFolder = create("Folder", { Name = "Sections", Parent = handler })

local minimizeBtn = create("TextButton", {
    Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
    Position = UDim2.new(0.02, 0, 0.029, 0), Size = UDim2.new(0, 24, 0, 24),
    BorderSizePixel = 0, Parent = handler,
})

local uiOpen = true
local activeTabRef = nil

local function changeVisibility(open)
    if not open and cfg.hide_minimized then
        tween(uiScale, TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Scale = 0.04 })
        task.delay(0.36, function()
            if not uiOpen then
                screenGui.Enabled = false
                uiScale.Scale = 1
            end
        end)
        return
    end
    if open then
        screenGui.Enabled = true
        if cfg.hide_minimized then
            uiScale.Scale = 0.04
            tween(uiScale, TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = 1 })
        end
    end
    tween(container, TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = open and UDim2.fromOffset(698, 479) or UDim2.fromOffset(105, 52)
    })
end

minimizeBtn.MouseButton1Click:Connect(function()
    uiOpen = not uiOpen
    changeVisibility(uiOpen)
end)

local toggleKey = Enum.KeyCode.RightControl
pcall(function()
    for _, kc in Enum.KeyCode:GetEnumItems() do
        if kc.Name == cfg.toggle_key then toggleKey = kc; break end
    end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == toggleKey then
        uiOpen = not uiOpen
        changeVisibility(uiOpen)
    end
end)


local tabIndex = 0

local function updateTabs(active)
    activeTabRef = active
    for _, btn in tabsList:GetChildren() do
        if btn.Name ~= "Tab" then continue end
        local lbl = btn:FindFirstChildOfClass("TextLabel")
        local ind = btn:FindFirstChild("Indicator")
        if btn == active then
            tween(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { BackgroundTransparency = 0.82 })
            if lbl then tween(lbl, TweenInfo.new(0.3), { TextTransparency = 0, TextColor3 = Colors.Accent }) end
            if ind then tween(ind, TweenInfo.new(0.35, Enum.EasingStyle.Back), { BackgroundTransparency = 0, Size = UDim2.new(0, 3, 0, 22) }) end
        else
            tween(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { BackgroundTransparency = 1 })
            if lbl then tween(lbl, TweenInfo.new(0.25), { TextTransparency = 0.42, TextColor3 = Colors.Text }) end
            if ind then tween(ind, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { BackgroundTransparency = 1, Size = UDim2.new(0, 3, 0, 10) }) end
        end
    end
end

local function updateSections(left, right)
    for _, s in sectionsFolder:GetChildren() do
        s.Visible = (s == left or s == right)
    end
end

local function createSection(xScale)
    local s = create("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.XY, ScrollBarThickness = 0, ScrollBarImageTransparency = 1,
        Size = UDim2.new(0, 243, 0, 360), Selectable = false,
        BackgroundTransparency = 1, Position = UDim2.new(xScale, 0, 0.16, 0),
        BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0.5, 0), Visible = false, Parent = sectionsFolder,
    })
    create("UIListLayout", { Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = s })
    create("UIPadding", { PaddingTop = UDim.new(0, 1), PaddingBottom = UDim.new(0, 8), Parent = s })
    return s
end

local function createTab(title, icon)
    local isFirst = not tabsList:FindFirstChild("Tab")
    local btn = create("TextButton", {
        Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
        Name = "Tab", Size = UDim2.new(0, 129, 0, 38), BorderSizePixel = 0,
        BackgroundColor3 = Colors.CardDeep, LayoutOrder = tabIndex, Parent = tabsList,
    })
    tabIndex += 1
    create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
    local ind = create("Frame", {
        Name = "Indicator", Size = UDim2.new(0, 3, 0, 10),
        Position = UDim2.new(0, 2, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Colors.Accent, BackgroundTransparency = 1, BorderSizePixel = 0, Parent = btn,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = ind })
    if icon then
        create("ImageLabel", {
            Name = "Icon", Image = icon, BackgroundTransparency = 1,
            ImageColor3 = Colors.Text, ImageTransparency = 0.45, ScaleType = Enum.ScaleType.Fit,
            Size = UDim2.new(0, 13, 0, 13), AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0.1, 0, 0.5, 0), BorderSizePixel = 0, Parent = btn,
        })
    end
    create("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        TextColor3 = Colors.Text, TextTransparency = 0.38, Text = title, TextSize = 13,
        Size = UDim2.new(0, 90, 0, 16), AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(icon and 0.24 or 0.1, 0, 0.5, 0), BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = btn,
    })

    local leftSec = createSection(0.23)
    local rightSec = createSection(0.6)

    if isFirst then
        updateTabs(btn)
        updateSections(leftSec, rightSec)
    end

    btn.MouseButton1Click:Connect(function()
        updateTabs(btn)
        updateSections(leftSec, rightSec)
    end)


    local tab = {}
    tab._left = leftSec
    tab._right = rightSec
    local moduleOrder = 0

    function tab:AddModule(opts)
        moduleOrder += 1
        local section = opts.side == "right" and rightSec or leftSec
        local modState = false
        local optSize = 0
        local optMult = 0
        local optCount = 0

        local card = create("Frame", {
            ClipsDescendants = true, BorderSizePixel = 0, BackgroundTransparency = 0.68,
            Size = UDim2.new(1, -8, 0, 93), BackgroundColor3 = Colors.Card,
            LayoutOrder = moduleOrder, Parent = section,
        })
        create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = card })
        local cardStroke = create("UIStroke", { Color = Colors.Stroke, Transparency = 0.32, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = card })

        local header = create("TextButton", {
            Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 93), BorderSizePixel = 0, Parent = card,
        })

        create("Frame", {
            Name = "AccentBar", Size = UDim2.new(0, 2, 0, 50),
            Position = UDim2.new(0, 2, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Colors.AccentDim, BackgroundTransparency = 0.45,
            BorderSizePixel = 0, ZIndex = 3, Parent = header,
        })

        create("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
            TextColor3 = Colors.Text, TextTransparency = 0.06, Text = opts.title or "Module",
            Size = UDim2.new(0, 180, 0, 14), AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0.073, 0, 0.24, 0), BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left, TextSize = 13, Parent = header,
        })
        create("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular),
            TextColor3 = Colors.SubText, TextTransparency = 0.1, Text = opts.desc or "",
            Size = UDim2.new(0, 150, 0, 13), AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0.073, 0, 0.42, 0), BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left, TextSize = 10, Parent = header,
        })

       
        local toggleBg = create("Frame", {
            BackgroundTransparency = 0.6, Position = UDim2.new(0.82, 0, 0.757, 0),
            Size = UDim2.new(0, 26, 0, 13), BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(8, 8, 14), Parent = header,
        })
        create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = toggleBg })
        create("UIStroke", { Color = Colors.Stroke, Transparency = 0.25, Parent = toggleBg })
        local toggleCircle = create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 0.1,
            Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.new(0, 9, 0, 9),
            BorderSizePixel = 0, BackgroundColor3 = Colors.SubText, Parent = toggleBg,
        })
        create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = toggleCircle })

       
        for _, yScale in { 0.62, 1 } do
            create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 0.12,
                Position = UDim2.new(0.5, 0, yScale, 0), Size = UDim2.new(0, 220, 0, 1),
                BorderSizePixel = 0, BackgroundColor3 = Colors.Stroke, Parent = header,
            })
        end

       
        local options = create("Frame", {
            Name = "Options", BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 93), Size = UDim2.new(1, 0, 0, 8),
            BorderSizePixel = 0, Parent = card,
        })
        create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10), Parent = options })
        create("UIListLayout", { Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = options })

        local function resizeCard()
            options.Size = UDim2.new(1, -8, 0, optSize + optMult)
            if modState then
                tween(card, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -8, 0, 93 + optSize + optMult + 16) })
            end
        end

        local function changeState(state)
            modState = state
            if state then
                tween(card, TweenInfo.new(0.5, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -8, 0, 93 + optSize + optMult + 16) })
                tween(toggleBg, TweenInfo.new(0.45, Enum.EasingStyle.Quint), { BackgroundColor3 = Colors.Accent, BackgroundTransparency = 0.3 })
                tween(toggleCircle, TweenInfo.new(0.35, Enum.EasingStyle.Quint), { Position = UDim2.new(1, -11, 0.5, 0), BackgroundColor3 = Colors.Bg })
                tween(cardStroke, TweenInfo.new(0.45), { Color = Colors.Accent, Transparency = 0.68 })
            else
                tween(card, TweenInfo.new(0.5, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -8, 0, 93) })
                tween(toggleBg, TweenInfo.new(0.45, Enum.EasingStyle.Quint), { BackgroundColor3 = Color3.fromRGB(8, 8, 14), BackgroundTransparency = 0.6 })
                tween(toggleCircle, TweenInfo.new(0.35, Enum.EasingStyle.Quint), { Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = Colors.SubText })
                tween(cardStroke, TweenInfo.new(0.45), { Color = Colors.Stroke, Transparency = 0.32 })
            end
            if opts.callback then opts.callback(state) end
        end

        header.MouseButton1Click:Connect(function() changeState(not modState) end)

        local keybindLabel = create("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
            TextSize = 9, TextColor3 = Colors.SubText, TextTransparency = 0.3,
            Text = "", Size = UDim2.new(0, 50, 0, 12), AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(0.95, 0, 0.12, 0), BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Right, Parent = header,
        })

        local choosingBind = false
        local bindConn = nil

        if opts.flag and cfg.keybinds and cfg.keybinds[opts.flag] then
            keybindLabel.Text = "[" .. cfg.keybinds[opts.flag] .. "]"
        end

        if opts.flag then
            local kbFlag = opts.flag
            header.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseButton3 then return end
                if choosingBind then return end
                choosingBind = true
                keybindLabel.Text = "[...]"
                keybindLabel.TextColor3 = Colors.Danger
                bindConn = UIS.InputBegan:Connect(function(inp, gpe)
                    if gpe then return end
                    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if inp.KeyCode == Enum.KeyCode.Unknown then return end
                    if bindConn then bindConn:Disconnect(); bindConn = nil end
                    choosingBind = false
                    if inp.KeyCode == Enum.KeyCode.Backspace then
                        if not cfg.keybinds then cfg.keybinds = {} end
                        cfg.keybinds[kbFlag] = nil
                        keybindLabel.Text = ""
                        keybindLabel.TextColor3 = Colors.SubText
                        saveCfg()
                        return
                    end
                    if not cfg.keybinds then cfg.keybinds = {} end
                    cfg.keybinds[kbFlag] = inp.KeyCode.Name
                    keybindLabel.Text = "[" .. inp.KeyCode.Name .. "]"
                    keybindLabel.TextColor3 = Colors.SubText
                    saveCfg()
                end)
            end)

            UIS.InputBegan:Connect(function(input, gpe)
                if gpe or choosingBind then return end
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                if not cfg.keybinds or not cfg.keybinds[kbFlag] then return end
                if input.KeyCode.Name == cfg.keybinds[kbFlag] then
                    changeState(not modState)
                end
            end)
        end

        if opts.flag and cfg[opts.flag] == true then
            modState = true
            toggleBg.BackgroundColor3 = Colors.Accent; toggleBg.BackgroundTransparency = 0.3
            toggleCircle.Position = UDim2.new(1, -11, 0.5, 0); toggleCircle.BackgroundColor3 = Colors.Bg
            cardStroke.Color = Colors.Accent; cardStroke.Transparency = 0.68
            task.delay(0.3, function()
                if opts.callback then opts.callback(true) end
                card.Size = UDim2.new(1, -8, 0, 93 + optSize + optMult + 16)
            end)
        end

        local mod = {}

        function mod:AddSlider(sliderOpts)
            optCount += 1
            if optSize == 0 then optSize = 11 end
            optSize += 28
            resizeCard()

            local row = create("TextButton", {
                Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
                Size = UDim2.new(0, 207, 0, 22), BorderSizePixel = 0,
                LayoutOrder = optCount, Parent = options,
            })
            create("TextLabel", {
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                TextSize = 11, TextColor3 = Colors.Text, TextTransparency = 0.16,
                Text = sliderOpts.title, Size = UDim2.new(0, 153, 0, 13),
                Position = UDim2.new(0, 0, 0.05, 0), BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
            })
            local valLabel = create("TextLabel", {
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                TextColor3 = Color3.fromRGB(235, 235, 245), TextTransparency = 0.2,
                Text = "0", Size = UDim2.new(0, 42, 0, 13),
                AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right, TextSize = 10, Parent = row,
            })
            local drag = create("Frame", {
                AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 0.78,
                Position = UDim2.new(0.5, 0, 0.95, 0), Size = UDim2.new(0, 207, 0, 4),
                BorderSizePixel = 0, BackgroundColor3 = Colors.Stroke, Parent = row,
            })
            create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = drag })
            local fill = create("Frame", {
                AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 0.05,
                Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(0, 1, 0, 4),
                BorderSizePixel = 0, BackgroundColor3 = Colors.Accent, Parent = drag,
            })
            create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = fill })
            local circle = create("Frame", {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 7, 0, 7), BorderSizePixel = 0,
                BackgroundColor3 = Colors.AccentSoft, Parent = fill,
            })
            create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = circle })

            local min, max = sliderOpts.min, sliderOpts.max
            local slider = {}

            function slider:Set(val)
                val = math.clamp(math.floor(val + 0.5), min, max)
                local pct = math.clamp((val - min) / (max - min), 0.02, 1)
                valLabel.Text = tostring(val)
                tween(fill, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Size = UDim2.fromOffset(pct * drag.Size.X.Offset, 4) })
                if sliderOpts.callback then sliderOpts.callback(val) end
            end

            local mouse = lp:GetMouse()
            local sliding = false

            row.MouseButton1Down:Connect(function()
                sliding = true
                local v = min + (max - min) * math.clamp((mouse.X - drag.AbsolutePosition.X) / drag.Size.X.Offset, 0, 1)
                slider:Set(v)
            end)

            local moveConn, endConn
            row.MouseButton1Down:Connect(function()
                if moveConn then moveConn:Disconnect() end
                if endConn then endConn:Disconnect() end
                moveConn = mouse.Move:Connect(function()
                    if not sliding then return end
                    local v = min + (max - min) * math.clamp((mouse.X - drag.AbsolutePosition.X) / drag.Size.X.Offset, 0, 1)
                    slider:Set(v)
                end)
                endConn = UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                        if moveConn then moveConn:Disconnect() end
                        if endConn then endConn:Disconnect() end
                        saveCfg()
                    end
                end)
            end)

            slider:Set(sliderOpts.default or min)
            return slider
        end

        function mod:AddCheckbox(cbOpts)
            optCount += 1
            if optSize == 0 then optSize = 11 end
            optSize += 21
            resizeCard()

            local cbState = cfg[cbOpts.flag] or false
            local row = create("TextButton", {
                Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
                Size = UDim2.new(0, 207, 0, 15), BorderSizePixel = 0,
                LayoutOrder = optCount, Parent = options,
            })
            create("TextLabel", {
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                TextSize = 11, TextColor3 = Colors.Text, TextTransparency = 0.16,
                Text = cbOpts.title, Size = UDim2.new(0, 170, 0, 13),
                AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
            })
            local box = create("Frame", {
                AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 0.86,
                Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0, 15, 0, 15),
                BorderSizePixel = 0, BackgroundColor3 = Colors.Accent, Parent = row,
            })
            create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = box })
            create("UIStroke", { Color = Colors.StrokeHot, Transparency = 0.3, Parent = box })
            local fillBox = create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 0.08,
                Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.fromOffset(0, 0),
                BorderSizePixel = 0, BackgroundColor3 = Colors.Accent, Parent = box,
            })
            create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = fillBox })

            local function setCb(state)
                cbState = state
                tween(box, TweenInfo.new(0.45, Enum.EasingStyle.Quint), { BackgroundTransparency = state and 0.62 or 0.86 })
                tween(fillBox, TweenInfo.new(0.45, Enum.EasingStyle.Quint), { Size = state and UDim2.fromOffset(9, 9) or UDim2.fromOffset(0, 0) })
                cfg[cbOpts.flag] = state
                saveCfg()
                if cbOpts.callback then cbOpts.callback(state) end
            end

            if cbState then setCb(true) end
            row.MouseButton1Click:Connect(function() setCb(not cbState) end)
        end

        function mod:AddDivider(divOpts)
            optCount += 1
            if optSize == 0 then optSize = 11 end
            optSize += 22
            resizeCard()

            local row = create("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(0, 207, 0, 16),
                LayoutOrder = optCount, Parent = options,
            })
            if divOpts and divOpts.title then
                create("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
                    TextSize = 10, TextColor3 = Colors.SubText, TextTransparency = 0.3,
                    Text = string.upper(divOpts.title), Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
                })
            end
            create("Frame", {
                AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Colors.Stroke,
                BackgroundTransparency = 0.7, BorderSizePixel = 0, Parent = row,
            })
        end

        function mod:AddDropdown(ddOpts)
            optCount += 1
            if optSize == 0 then optSize = 11 end
            optSize += 24
            resizeCard()

            local selected = ddOpts.default or ddOpts.options[1]
            local row = create("TextButton", {
                Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
                Size = UDim2.new(0, 207, 0, 18), BorderSizePixel = 0,
                LayoutOrder = optCount, Parent = options,
            })
            create("TextLabel", {
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                TextSize = 11, TextColor3 = Colors.Text, TextTransparency = 0.16,
                Text = ddOpts.title, Size = UDim2.new(0, 110, 0, 13),
                AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
            })
            local valLabel = create("TextLabel", {
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                TextSize = 10, TextColor3 = Colors.AccentSoft, TextTransparency = 0,
                Text = tostring(selected), Size = UDim2.new(0, 90, 0, 13),
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
                BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
            })

            local idx = 1
            for i, v in ddOpts.options do if v == selected then idx = i; break end end

            row.MouseButton1Click:Connect(function()
                idx = idx % #ddOpts.options + 1
                selected = ddOpts.options[idx]
                valLabel.Text = tostring(selected)
                if ddOpts.callback then ddOpts.callback(selected) end
            end)
        end

        function mod:AddDoubleSlider(dsOpts)
            optCount += 1
            if optSize == 0 then optSize = 11 end
            optSize += 32
            resizeCard()

            local minVal = dsOpts.defaultMin or dsOpts.min or 1
            local maxVal = dsOpts.defaultMax or dsOpts.max or 100
            local sMin, sMax = dsOpts.min or 1, dsOpts.max or 100
            local range = sMax - sMin

            local row = create("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(0, 207, 0, 26),
                LayoutOrder = optCount, Parent = options,
            })
            local label = create("TextLabel", {
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                TextSize = 11, TextColor3 = Colors.Text, TextTransparency = 0.16,
                Text = dsOpts.title, Size = UDim2.new(0, 100, 0, 13),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
            })
            local valText = create("TextLabel", {
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                TextSize = 10, TextColor3 = Colors.AccentSoft, TextTransparency = 0,
                Text = tostring(minVal) .. " - " .. tostring(maxVal),
                Size = UDim2.new(0, 90, 0, 13), AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
            })
            local track = create("Frame", {
                AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(1, 0, 0, 4), BackgroundColor3 = Colors.Stroke,
                BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = row,
            })
            create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
            local fill = create("Frame", {
                Position = UDim2.new((minVal - sMin) / range, 0, 0, 0),
                Size = UDim2.new((maxVal - minVal) / range, 0, 1, 0),
                BackgroundColor3 = Colors.Accent, BackgroundTransparency = 0.18,
                BorderSizePixel = 0, Parent = track,
            })
            create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

            local dragging = nil
            track.InputBegan:Connect(function(inp)
                if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and inp.UserInputType ~= Enum.UserInputType.Touch then return end
                local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local v = math.floor(sMin + rel * range + 0.5)
                if math.abs(v - minVal) <= math.abs(v - maxVal) then dragging = "min" else dragging = "max" end
            end)
            UIS.InputChanged:Connect(function(inp)
                if not dragging then return end
                if inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Touch then return end
                local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local v = math.floor(sMin + rel * range + 0.5)
                if dragging == "min" then
                    minVal = math.min(v, maxVal)
                else
                    maxVal = math.max(v, minVal)
                end
                fill.Position = UDim2.new((minVal - sMin) / range, 0, 0, 0)
                fill.Size = UDim2.new((maxVal - minVal) / range, 0, 1, 0)
                valText.Text = tostring(minVal) .. " - " .. tostring(maxVal)
                if dsOpts.callback then dsOpts.callback(minVal, maxVal) end
            end)
            UIS.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = nil
                end
            end)
        end

        return mod
    end

    return tab
end

tween(container, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(698, 479) })


local _token = nil
local function findToken()
    for _, Function in getgc(true) do
        if type(Function) ~= "function" then continue end
        local okSrc, src = pcall(function()
            return debug.info(Function, "s")
        end)
        if okSrc and src and tostring(src):find("PRY", 1, true) then
            local okUps, ups = pcall(function()
                return debug.getupvalues(Function)
            end)
            if okUps and type(ups) == "table" then
                for _, value in ups do
                    if type(value) == "function" then
                        return value
                    end
                end
            end
        end
    end
    return nil
end

_token = findToken()
task.spawn(function()
    local tries = 0
    while not _token and tries < 40 do
        tries += 1
        task.wait(1)
        if not _token then _token = findToken() end
    end
end)

local function tokenize(remoteUid)
    if not _token then return nil end
    local time = tostring(math.floor(WS:GetServerTimeNow() * 100))
    local ok, key = pcall(_token, remoteUid, "TIME")
    if not ok or not key then return nil end
    local characters = table.create(#time)
    for index = 1, #time do
        characters[index] = string.char(bit32.bxor(
            (string.byte(time, index) + index) % 256,
            string.byte(key, (index - 1) % #key + 1)
        ))
    end
    return table.concat(characters)
end

local _reverted = {}
local _original = {}

local function isValidParryArgs(args)
    return #args == 8 and type(args[2]) == "string" and type(args[3]) == "string"
        and type(args[4]) == "number" and typeof(args[5]) == "CFrame"
        and type(args[6]) == "table" and type(args[7]) == "table"
        and type(args[8]) == "boolean"
end

local function hookRemote(remote)
    local mt = getrawmetatable(remote)
    if not mt or _original[mt] then return end
    _original[mt] = true
    setreadonly(mt, false)
    local oldIndex = mt.__index
    mt.__index = function(self, key)
        if (key == "FireServer" and self:IsA("RemoteEvent"))
        or (key == "InvokeServer" and self:IsA("RemoteFunction")) then
            return function(_, ...)
                local arguments = {...}
                if isValidParryArgs(arguments) then
                    if not _reverted[self] then
                        _reverted[self] = arguments
                    end
                end
                return oldIndex(self, key)(_, unpack(arguments))
            end
        end
        return oldIndex(self, key)
    end
    setreadonly(mt, true)
end

for _, remote in pairs(RS:GetDescendants()) do
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
        hookRemote(remote)
    end
end
RS.DescendantAdded:Connect(function(d)
    if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
        hookRemote(d)
    end
end)

local function fireParryInput()
    if mouse1click then
        pcall(mouse1click)
        return true
    end
    if mouse1press and mouse1release then
        pcall(function()
            mouse1press()
            task.wait(0.02)
            mouse1release()
        end)
        return true
    end
    -- Single fallback: F key via VIM (never send both mouse and F)
    local ok = pcall(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.02)
        VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
    return ok
end

local function getPing()
    local ok, v = pcall(function() return dataPing:GetValue() end)
    return ok and v or 50
end

local function getRoot()
    local c = lp.Character
    return c and (c.PrimaryPart or c:FindFirstChild("HumanoidRootPart"))
end

local function getBall()
    local bFolder = WS:FindFirstChild("Balls")
    if not bFolder then return nil end
    for _, ball in bFolder:GetChildren() do
        if ball:GetAttribute("realBall") then
            return ball
        end
    end
    for _, ball in bFolder:GetChildren() do
        if ball:IsA("BasePart") then
            return ball
        end
    end
    return nil
end

local function getBalls()
    local bFolder = WS:FindFirstChild("Balls")
    if not bFolder then return {} end
    local list = {}
    for _, ball in bFolder:GetChildren() do
        if ball:GetAttribute("realBall") then
            table.insert(list, ball)
        end
    end
    if #list == 0 then
        for _, ball in bFolder:GetChildren() do
            if ball:IsA("BasePart") then
                table.insert(list, ball)
            end
        end
    end
    return list
end

local currentTarget = nil
local recentlyPicked = {}

local function selectTargetByMouse()
    local livingPlayers = {}
    local alive = WS:FindFirstChild("Alive")
    if alive then
        for _, char in alive:GetChildren() do
            if char.Name ~= lp.Name and char.PrimaryPart then
                table.insert(livingPlayers, char)
            end
        end
    end

    local camera = WS.CurrentCamera
    local mouse = UIS:GetMouseLocation()
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, char in livingPlayers do
        local screenPos, onScreen = camera:WorldToViewportPoint(char.PrimaryPart.Position)
        if onScreen then
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouse).Magnitude
            if dist < closestDistance then
                closestDistance = dist
                closestPlayer = char
            end
        end
    end

    currentTarget = closestPlayer
    return closestPlayer
end

local function selectClosestPlayer()
    local livingPlayers = {}
    local alive = WS:FindFirstChild("Alive")
    if alive then
        for _, char in alive:GetChildren() do
            if char.Name ~= lp.Name and char.PrimaryPart then
                table.insert(livingPlayers, char)
            end
        end
    end

    local hrp = getRoot()
    if not hrp then return nil end

    local closestPlayer = nil
    local closestDistance = math.huge

    for _, char in livingPlayers do
        local dist = (char.PrimaryPart.Position - hrp.Position).Magnitude
        if dist < closestDistance then
            closestDistance = dist
            closestPlayer = char
        end
    end

    currentTarget = closestPlayer
    return closestPlayer
end

local function pickRandomTarget()
    local alive = WS:FindFirstChild("Alive")
    if not alive then return end
    local living = {}
    for _, char in alive:GetChildren() do
        if char.Name ~= lp.Name and char.PrimaryPart then
            table.insert(living, char)
        end
    end
    if #living == 0 then currentTarget = nil; return end
    if #living == 1 then currentTarget = living[1]; return end
    local cands = {}
    for _, char in living do
        if not recentlyPicked[char.Name] then table.insert(cands, char) end
    end
    if #cands == 0 then
        recentlyPicked = {}
        for _, char in living do
            if not currentTarget or char.Name ~= currentTarget.Name then
                table.insert(cands, char)
            end
        end
        if #cands == 0 then cands = living end
    end
    local picked = cands[math.random(1, #cands)]
    recentlyPicked[picked.Name] = true
    currentTarget = picked
end

local function getCurveCFrame()
    local camera = WS.CurrentCamera
    local hrp = getRoot()
    if not hrp then return camera.CFrame end

    local method = cfg.curve_mode or "Camera"
    local target = currentTarget
    local targetPos = (target and target.PrimaryPart and target.PrimaryPart.Position)
        or (hrp.Position + camera.CFrame.LookVector * 1000)
    local toTarget = (targetPos - hrp.Position).Unit

    local m = method:lower()
    if m == "dot" then
        return CFrame.lookAt(hrp.Position, targetPos + Vector3.new(0, 1.75, 0))
    elseif m == "backwards" or m == "back" then
        return CFrame.new(hrp.Position, hrp.Position + (-toTarget) * 1000)
    elseif m == "slow" then
        return CFrame.new(hrp.Position, hrp.Position + (-toTarget) * 1000)
    elseif m == "random" then
        local rX = math.random(-360, 360)
        local rY = math.random(-360, 360)
        local rZ = math.random(-360, 360)
        return CFrame.Angles(math.rad(rX), math.rad(rY), math.rad(rZ))
    elseif m == "upwards" or m == "up" then
        return CFrame.new(hrp.Position, hrp.Position + Vector3.new(0, 1000, 0))
    elseif m == "down" then
        return CFrame.new(hrp.Position, hrp.Position + Vector3.new(0, -1000, 0))
    end
    return camera.CFrame
end

local function getScreenPositions()
    local screenPositions = {}
    local alive = WS:FindFirstChild("Alive")
    if alive then
        for _, char in alive:GetChildren() do
            if char.PrimaryPart then
                local ok, screenPt = pcall(function()
                    return WS.CurrentCamera:WorldToScreenPoint(char.PrimaryPart.Position)
                end)
                if ok then
                    screenPositions[char.Name] = screenPt
                end
            end
        end
    end
    return screenPositions
end

local function getMouseLoc()
    if (cfg.random_target or cfg.target_closest) and currentTarget and currentTarget.PrimaryPart then
        local viewportPt = WS.CurrentCamera:WorldToViewportPoint(currentTarget.PrimaryPart.Position)
        return { viewportPt.X, viewportPt.Y }
    end
    local mp = UIS:GetMouseLocation()
    return { mp.X, mp.Y }
end

local parryActive = false
local parryCount = 0
local lastParryTime = 0

local function executeParry()
    -- Strict anti-double-click debounce: prevent firing within 0.2s of last parry
    local now = tick()
    if now - lastParryTime < 0.2 then return false end
    if parryCount > 7 then return false end

    lastParryTime = now
    parryCount += 1
    task.delay(0.5, function() if parryCount > 0 then parryCount -= 1 end end)

    if cfg.target_closest then
        selectClosestPlayer()
    elseif not cfg.random_target then
        selectTargetByMouse()
    end

    local curveCF = getCurveCFrame()
    local mouseLoc = getMouseLoc()
    local screenPos = getScreenPositions()

    local fired = false
    if _token and _reverted and next(_reverted) ~= nil then
        for remote, originalArgs in pairs(_reverted) do
            if type(originalArgs) == "table" and originalArgs[1] ~= nil then
                local tk = tokenize(originalArgs[2])
                if tk then
                    local ok = pcall(function()
                        remote:FireServer(
                            originalArgs[1],
                            originalArgs[2],
                            tk,
                            0.5,
                            curveCF,
                            screenPos,
                            mouseLoc,
                            false
                        )
                    end)
                    if ok then
                        fired = true
                        break -- Fire only ONE remote per parry (prevents multi-remote spam)
                    end
                end
            end
        end
    end

    if not fired then
        fireParryInput()
    end

    return true
end

local curveState = { AerodynamicTime = tick(), LastWarping = tick(), LerpRadians = 0, Curving = tick() }

local function linearPredict(a, b, t) return a + (b - a) * t end

local function isCurved(ball)
    local zoomies = ball:FindFirstChild("zoomies")
    if not zoomies then return false end

    local char = lp.Character
    if not char or not char.PrimaryPart then return false end

    local velocity = zoomies.VectorVelocity
    local velUnit = velocity.Unit
    local toMe = (char.PrimaryPart.Position - ball.Position).Unit
    local dotProduct = toMe:Dot(velUnit)
    local speed = velocity.Magnitude
    local speedFactor = math.min(speed / 100, 40)
    local accelDir = (velUnit - velocity).Unit
    local crossDot = toMe:Dot(accelDir)
    local dotDifference = dotProduct - crossDot
    local distance = (char.PrimaryPart.Position - ball.Position).Magnitude
    local pingMs = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    local pingThreshold = 0.5 - (pingMs / 1000)
    local timeToImpact = distance / speed - (pingMs / 1000)
    local minDistance = 15 - math.min(distance / 1000, 15) + speedFactor
    local clampedDot = math.clamp(dotProduct, -1, 1)
    local angleRad = math.rad(math.asin(clampedDot))

    curveState.LerpRadians = linearPredict(curveState.LerpRadians, angleRad, 0.8)

    if speed > 100 and timeToImpact > pingMs / 10 then
        minDistance = math.max(minDistance - 15, 15)
    end

    if distance < minDistance then return false end
    if dotDifference < pingThreshold then return true end

    if curveState.LerpRadians < 0.018 then
        curveState.LastWarping = tick()
    end

    if (tick() - curveState.LastWarping) < (timeToImpact / 1.5) then return true end
    if (tick() - curveState.Curving) < (timeToImpact / 1.5) then return true end

    return dotProduct < pingThreshold
end

local function checkTornado(ball)
    if ball:FindFirstChild("AeroDynamicSlashVFX") then
        Debris:AddItem(ball.AeroDynamicSlashVFX, 0)
        curveState.AerodynamicTime = tick()
    end
    if runtime and runtime:FindFirstChild("Tornado") then
        local tt = runtime.Tornado:GetAttribute("TornadoTime") or 1
        if tick() - curveState.AerodynamicTime < tt + 0.314159 then return true end
    end
    return false
end

local function calcSpeedDivisorBase(speed)
    return 2.2 + 0.9 * math.log(1 + speed / 80)
end

local function getSpeedDivisorMultiplier()
    local accVal = math.clamp(tonumber(cfg.accuracy) or 100, 1, 100)
    return 0.7 + (accVal - 1) * 0.0035353535353535
end

local apConn = nil

local function startAutoParry()
    if apConn then return end
    apConn = preSim:Connect(function()
        if not cfg.auto_parry then return end
        local char = lp.Character
        if not char or not char.PrimaryPart then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end

        local realBall = getBall()
        local allBalls = getBalls()

        for _, ball in allBalls do
            if not ball then return end
            local zoomies = ball:FindFirstChild("zoomies")
            if not zoomies then return end

            ball:GetAttributeChangedSignal("target"):Once(function()
                parryActive = false
                if cfg.random_target then pickRandomTarget() end
            end)

            if parryActive then return end

            local ballTarget = ball:GetAttribute("target")
            local realBallTarget = realBall and realBall:GetAttribute("target")
            local velocity = zoomies.VectorVelocity
            local distance = (char.PrimaryPart.Position - ball.Position).Magnitude
            local pingMs = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 10
            local pingThreshold = math.clamp(pingMs / 8, 4, 25)
            local rawSpeed = velocity.Magnitude
            local speedDivisor = calcSpeedDivisorBase(rawSpeed) * getSpeedDivisorMultiplier()
            local speedFactor = 1
            if rawSpeed > 200 then
                speedFactor = 1 + math.min((rawSpeed - 200) / 1000, 0.3)
            end
            local targetDistance = pingThreshold + math.max(rawSpeed / speedDivisor, 9.5) * speedFactor

            if checkTornado(ball) then return end

            local isCurving = isCurved(ball)
            if realBallTarget == lp.Name and isCurving then return end

            if ballTarget == lp.Name and distance <= targetDistance then
                if tick() - lastParryTime >= 0.2 then
                    executeParry()
                    parryActive = true
                end
            end

            local startTime = tick()
            repeat preSim:Wait() until (tick() - startTime) >= 1 or not parryActive
            parryActive = false
        end
    end)
end

local function stopAutoParry()
    if apConn then apConn:Disconnect(); apConn = nil end
    parryActive = false
end

if balls then
    balls.ChildAdded:Connect(function(ball)
        task.spawn(function()
            if not ball:GetAttribute("realBall") and not ball:WaitForChild("zoomies", 3) then return end
            ball:GetAttributeChangedSignal("target"):Connect(function()
                if cfg.random_target then pickRandomTarget() end
            end)
        end)
        if cfg.random_target then pickRandomTarget() end
    end)
    balls.ChildRemoved:Connect(function()
        parryCount = 0
        parryActive = false
        currentTarget = nil
        recentlyPicked = {}
    end)
    for _, ball in balls:GetChildren() do
        task.spawn(function()
            ball:GetAttributeChangedSignal("target"):Connect(function()
                if cfg.random_target then pickRandomTarget() end
            end)
        end)
    end
end

pcall(function()
    remotes.ParrySuccess.OnClientEvent:Connect(function()
        -- In Angeli 1:1, ParrySuccess only stops the client animation track and does NOT reset parryActive,
        -- because resetting parryActive while the ball is still in distance causes an instant double-click!
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local anim = hum and hum:FindFirstChildOfClass("Animator")
        if anim then
            for _, track in ipairs(anim:GetPlayingAnimationTracks()) do
                if track.Name:find("Parry") or track.Name:find("Slash") then
                    pcall(function() track:Stop() end)
                end
            end
        end
    end)
end)

pcall(function()
    remotes.ParrySuccessAll.OnClientEvent:Connect(function(_, parrier)
        local hrp = getRoot()
        if not hrp then return end
        if not parrier then return end
        local myChar = lp.Character
        -- If LocalPlayer is the parrier (or parrier is part of LocalPlayer), do NOT parry again!
        if parrier == myChar or parrier == hrp or (parrier.Parent and parrier.Parent == myChar) then return end
        local alive = WS:FindFirstChild("Alive")
        if alive and parrier.Parent and parrier.Parent.Parent ~= alive then return end

        local ball = getBall()
        if not ball then return end

        local zoomies = ball:FindFirstChild("zoomies")
        if not zoomies then return end

        local speed = zoomies.VectorVelocity.Magnitude
        local distance = (hrp.Position - ball.Position).Magnitude
        local pingMs = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        local speedFactor = math.min(speed / 100, 40)
        local timeToImpact = distance / speed - (pingMs / 1000)
        local isFast = speed > 100
        local minDistance = 15 - math.min(distance / 1000, 15) + speedFactor

        if isFast and timeToImpact > pingMs / 10 then
            minDistance = math.max(minDistance - 15, 15)
        end

        if parrier ~= hrp and distance > minDistance then
            curveState.Curving = tick()
        end

        if currentTarget and currentTarget.PrimaryPart then
            local distTarget = (hrp.Position - currentTarget.PrimaryPart.Position).Magnitude
            local distBall = (hrp.Position - ball.Position).Magnitude
            local toBall = (hrp.Position - ball.Position).Unit
            local dot = toBall:Dot(ball.AssemblyLinearVelocity.Unit)
            local curving = isCurved(ball)

            if distTarget < 15 and distBall < 15 and dot > -0.25 then
                if curving and (tick() - lastParryTime >= 0.2) then
                    executeParry()
                end
            end
        end
    end)
end)

if cfg.auto_parry then startAutoParry() end



local orbitAngle = 0
local orbitConn = nil

local function startOrbit()
    if orbitConn then return end
    orbitAngle = 0
    orbitConn = hb:Connect(function(dt)
        if not cfg.orbit then return end
        local char = lp.Character
        if not char then return end
        local alive = WS:FindFirstChild("Alive")
        if not alive or char.Parent ~= alive then return end

        local ball
        if balls then
            for _, b in balls:GetChildren() do
                if b:GetAttribute("realBall") then ball = b; break end
            end
        end
        if not ball then return end
        local hrp = getRoot()
        if not hrp then return end

        if cfg.orbit_stick then
            hrp.CFrame = CFrame.new(ball.Position)
            hrp.AssemblyLinearVelocity = Vector3.zero
        else
            orbitAngle += math.rad(cfg.orbit_speed) * dt
            local x = math.cos(orbitAngle) * cfg.orbit_dist
            local z = math.sin(orbitAngle) * cfg.orbit_dist
            hrp.CFrame = CFrame.new(ball.Position + Vector3.new(x, cfg.orbit_height, z), ball.Position)
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

local function stopOrbit()
    if orbitConn then orbitConn:Disconnect(); orbitConn = nil end
end


local roundSpamConn = nil
local continuousRunning = false

local function fireAbility()
    pcall(function() remotes.AbilityButtonPress:Fire() end)
end

local function startRoundSpam()
    if roundSpamConn then roundSpamConn:Disconnect() end
    if not balls then return end
    roundSpamConn = balls.ChildAdded:Connect(function()
        if not cfg.ability_round then return end
        task.wait(0.1)
        fireAbility()
    end)
end

local function stopRoundSpam()
    if roundSpamConn then roundSpamConn:Disconnect(); roundSpamConn = nil end
end

local function startContinuous()
    if continuousRunning then return end
    continuousRunning = true
    task.spawn(function()
        while continuousRunning and cfg.ability_continuous and _G._bbfarm do
            fireAbility()
            task.wait(0.15)
        end
        continuousRunning = false
    end)
end

local function stopContinuous()
    continuousRunning = false
    cfg.ability_continuous = false
end

local simpleTpRoundConn = nil
local continuousTpConn = nil

local function doSimpleTp()
    local char = lp.Character
    if not char then return false end
    local alive = WS:FindFirstChild("Alive")
    if not alive or char.Parent ~= alive then return false end

    local ball = nil
    if balls then
        for _, b in balls:GetChildren() do
            if b:GetAttribute("realBall") then ball = b; break end
        end
    end
    if not ball then return false end
    local hrp = getRoot()
    if not hrp then return false end

    hrp.CFrame = CFrame.new(ball.Position)
    hrp.AssemblyLinearVelocity = Vector3.zero
    return true
end

local function startContinuousTp()
    if continuousTpConn then return end
    continuousTpConn = hb:Connect(function()
        if not cfg.simple_tp or not cfg.simple_tp_continuous then return end
        doSimpleTp()
    end)
end

local function stopContinuousTp()
    if continuousTpConn then
        continuousTpConn:Disconnect()
        continuousTpConn = nil
    end
end

local function startSimpleTpRound()
    if simpleTpRoundConn then simpleTpRoundConn:Disconnect(); simpleTpRoundConn = nil end
    if not balls then return end
    simpleTpRoundConn = balls.ChildAdded:Connect(function()
        if not cfg.simple_tp or not cfg.simple_tp_round then return end
        task.spawn(function()
            for i = 1, 15 do
                task.wait(0.1)
                if not cfg.simple_tp or not cfg.simple_tp_round then break end
                if doSimpleTp() then break end
            end
        end)
    end)
end

local function stopSimpleTpRound()
    if simpleTpRoundConn then
        simpleTpRoundConn:Disconnect()
        simpleTpRoundConn = nil
    end
end

local function onSimpleTp(state)
    cfg.simple_tp = state
    if state then
        if cfg.simple_tp_round then
            startSimpleTpRound()
        end
        if cfg.simple_tp_continuous then
            startContinuousTp()
        else
            if not cfg.simple_tp_round then
                doSimpleTp()
            end
        end
    else
        stopContinuousTp()
        stopSimpleTpRound()
    end
end


local noRenderConns = {}
local savedLighting = {}
local savedTerrain = {}

local function nukeVisual(obj)
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
        or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles")
        or obj:IsA("Explosion") or obj:IsA("PointLight") or obj:IsA("SpotLight")
        or obj:IsA("SurfaceLight") or obj:IsA("Highlight") or obj:IsA("BillboardGui")
        or obj:IsA("Decal") or obj:IsA("Texture") then
        pcall(function() obj:Destroy() end)
        return true
    end
    if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
        pcall(function() obj.TextureID = "" end)
    end
    return false
end

local function startNoRender()
    pcall(function() lp.PlayerScripts.EffectScripts.ClientFX.Disabled = true end)

    pcall(function()
        local lighting = game:GetService("Lighting")
        savedLighting = {
            GlobalShadows = lighting.GlobalShadows,
            FogEnd = lighting.FogEnd,
            Brightness = lighting.Brightness,
            ClockTime = lighting.ClockTime,
            disabledEffects = {},
        }
        lighting.GlobalShadows = false
        lighting.FogEnd = 1e10
        lighting.Brightness = 1
        lighting.ClockTime = 12
        for _, e in lighting:GetChildren() do
            if e:IsA("BloomEffect") or e:IsA("BlurEffect") or e:IsA("ColorCorrectionEffect")
                or e:IsA("DepthOfFieldEffect") or e:IsA("SunRaysEffect") then
                if e.Enabled then
                    table.insert(savedLighting.disabledEffects, e)
                    pcall(function() e.Enabled = false end)
                end
            end
        end
    end)

    pcall(function()
        local t = WS.Terrain
        savedTerrain = {
            WaterWaveSize = t.WaterWaveSize,
            WaterWaveSpeed = t.WaterWaveSpeed,
            WaterReflectance = t.WaterReflectance,
            WaterTransparency = t.WaterTransparency,
            Decoration = t.Decoration,
        }
        t.WaterWaveSize = 0
        t.WaterWaveSpeed = 0
        t.WaterReflectance = 0
        t.WaterTransparency = 0
        t.Decoration = false
    end)

    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    for _, d in WS:GetDescendants() do
        if d:IsA("Sound") or d:IsA("SoundGroup") then continue end
        pcall(function() nukeVisual(d) end)
    end

    table.insert(noRenderConns, WS.DescendantAdded:Connect(function(d)
        if not cfg.no_render then return end
        if d:IsA("Sound") or d:IsA("SoundGroup") then return end
        task.defer(function() pcall(function() nukeVisual(d) end) end)
    end))

    if runtime then
        for _, child in runtime:GetChildren() do
            if not child:IsA("Sound") and not child:IsA("SoundGroup") then
                pcall(function() Debris:AddItem(child, 0) end)
            end
        end
        table.insert(noRenderConns, runtime.ChildAdded:Connect(function(child)
            if not cfg.no_render then return end
            if child:IsA("Sound") or child:IsA("SoundGroup") then return end
            Debris:AddItem(child, 0)
        end))
    end
end

local function stopNoRender()
    pcall(function() lp.PlayerScripts.EffectScripts.ClientFX.Disabled = false end)
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
    pcall(function()
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = savedLighting.GlobalShadows ~= nil and savedLighting.GlobalShadows or true
        lighting.FogEnd = savedLighting.FogEnd or 100000
        lighting.Brightness = savedLighting.Brightness or 2
        lighting.ClockTime = savedLighting.ClockTime or 14
        if savedLighting.disabledEffects then
            for _, e in savedLighting.disabledEffects do
                pcall(function() e.Enabled = true end)
            end
        end
    end)
    pcall(function()
        local t = WS.Terrain
        if next(savedTerrain) then
            t.WaterWaveSize = savedTerrain.WaterWaveSize
            t.WaterWaveSpeed = savedTerrain.WaterWaveSpeed
            t.WaterReflectance = savedTerrain.WaterReflectance
            t.WaterTransparency = savedTerrain.WaterTransparency
            t.Decoration = savedTerrain.Decoration
        end
    end)
    for _, c in noRenderConns do c:Disconnect() end
    noRenderConns = {}
    savedLighting = {}
    savedTerrain = {}
end


local farmTab = createTab("Farm", "rbxassetid://18604510750")

local apMod = farmTab:AddModule({
    title = "Auto Parry", desc = "automatic deflection",
    side = "left", flag = "auto_parry",
    callback = function(state)
        cfg.auto_parry = state
        if state then startAutoParry() else stopAutoParry() end
        saveCfg()
    end
})

local accSlider = apMod:AddSlider({ title = "Accuracy", min = 0, max = 100, callback = function(v)
    cfg.accuracy = v
    saveCfg()
end })
accSlider:Set(cfg.accuracy or 100)
apMod:AddDivider({ title = "Curve" })
apMod:AddDropdown({ title = "Curve Mode", options = {"Camera", "Dot", "Backwards", "Upwards", "Random"}, default = ({camera = "Camera", dot = "Dot", backwards = "Backwards", upwards = "Upwards", random = "Random"})[cfg.curve_mode] or "Camera", callback = function(v)
    cfg.curve_mode = v:lower()
end })
apMod:AddCheckbox({ title = "Random Target", flag = "random_target", callback = function(v) cfg.random_target = v end })
apMod:AddCheckbox({ title = "Target Closest", flag = "target_closest", callback = function(v)
    cfg.target_closest = v
    saveCfg()
end })

local orbitMod = farmTab:AddModule({
    title = "Ball Orbit", desc = "orbit character around the ball",
    side = "left", flag = "orbit",
    callback = function(state)
        cfg.orbit = state
        if state then startOrbit() else stopOrbit() end
        saveCfg()
    end
})

orbitMod:AddSlider({ title = "Speed", min = 0, max = 1000, default = cfg.orbit_speed, callback = function(v)
    cfg.orbit_speed = v
    saveCfg()
end })
orbitMod:AddSlider({ title = "Distance", min = 0, max = 50, default = cfg.orbit_dist, callback = function(v) cfg.orbit_dist = v end })
orbitMod:AddSlider({ title = "Height", min = -20, max = 20, default = cfg.orbit_height, callback = function(v) cfg.orbit_height = v end })
orbitMod:AddCheckbox({ title = "Stick on Ball", flag = "orbit_stick", callback = function(v) cfg.orbit_stick = v end })

local abilityMod = farmTab:AddModule({
    title = "Auto Ability", desc = "automatically uses ability",
    side = "right", flag = "ability_module",
    callback = function() end
})

abilityMod:AddCheckbox({ title = "Start Round Spam", flag = "ability_round", callback = function(state)
    cfg.ability_round = state
    if state then startRoundSpam() else stopRoundSpam() end
end })

abilityMod:AddCheckbox({ title = "Continuous Spam", flag = "ability_continuous", callback = function(state)
    cfg.ability_continuous = state
    if state then startContinuous() else stopContinuous() end
end })

local simpleTpMod = farmTab:AddModule({
    title = "Simple Teleport", desc = "teleport character to the ball",
    side = "right", flag = "simple_tp",
    callback = function(state)
        onSimpleTp(state)
        saveCfg()
    end
})

simpleTpMod:AddCheckbox({ title = "Continuous TP", flag = "simple_tp_continuous", callback = function(state)
    cfg.simple_tp_continuous = state
    if state and cfg.simple_tp then
        startContinuousTp()
    else
        stopContinuousTp()
    end
    saveCfg()
end })

simpleTpMod:AddCheckbox({ title = "Start Round TP", flag = "simple_tp_round", callback = function(state)
    cfg.simple_tp_round = state
    if state and cfg.simple_tp then
        startSimpleTpRound()
    else
        stopSimpleTpRound()
    end
    saveCfg()
end })

local miscTab = createTab("Misc", "rbxassetid://7072718362")

miscTab:AddModule({
    title = "No Render", desc = "potato graphics, max fps/ping boost",
    side = "left", flag = "no_render",
    callback = function(state)
        cfg.no_render = state
        if state then startNoRender() else stopNoRender() end
        saveCfg()
    end
})

local guiTab = createTab("GUI", "rbxassetid://7059346373")

do
    local guiLeft = guiTab._left
    local guiRight = guiTab._right

    local function makeSettingsCard(parent, title, layoutOrder)
        local card = create("Frame", {
            Name = "GUICard", BackgroundColor3 = Colors.Card, BackgroundTransparency = 0.68,
            BorderSizePixel = 0, Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = layoutOrder, Parent = parent,
        })
        create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = card })
        create("UIStroke", { Color = Colors.Stroke, Transparency = 0.35, Parent = card })
        create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 12), Parent = card })
        create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = card })
        create("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16),
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
            TextSize = 12, TextColor3 = Colors.AccentSoft, TextTransparency = 0.1,
            TextXAlignment = Enum.TextXAlignment.Left, Text = title, LayoutOrder = 0, Parent = card,
        })
        return card
    end

    local interCard = makeSettingsCard(guiLeft, "Interaction", 1)

    local kbRow = create("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 1, Parent = interCard,
    })
    create("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        TextSize = 11, TextColor3 = Colors.Text, TextTransparency = 0.14,
        Text = "Toggle UI", Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = kbRow,
    })
    local kbBtn = create("TextButton", {
        Size = UDim2.new(0, 72, 0, 20), AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = Colors.CardDeep,
        BackgroundTransparency = 0.35, Text = "", AutoButtonColor = false, Parent = kbRow,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = kbBtn })
    create("UIStroke", { Color = Colors.StrokeHot, Transparency = 0.45, Parent = kbBtn })
    local kbLabel = create("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -6, 1, 0), Position = UDim2.new(0, 3, 0, 0),
        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold),
        TextSize = 10, TextColor3 = Colors.AccentSoft, Text = cfg.toggle_key or "RightControl", Parent = kbBtn,
    })
    local kbListening = false
    kbBtn.MouseButton1Click:Connect(function()
        if kbListening then return end
        kbListening = true
        kbLabel.Text = "..."
        kbLabel.TextColor3 = Colors.Danger
        local conn
        conn = UIS.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode.Unknown then return end
            conn:Disconnect()
            kbListening = false
            if input.KeyCode == Enum.KeyCode.Backspace then
                toggleKey = Enum.KeyCode.RightControl
                cfg.toggle_key = "RightControl"
                kbLabel.Text = "RightControl"
            else
                toggleKey = input.KeyCode
                cfg.toggle_key = input.KeyCode.Name
                kbLabel.Text = input.KeyCode.Name
            end
            kbLabel.TextColor3 = Colors.AccentSoft
            saveCfg()
        end)
    end)

    local hideRow = create("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 2, Parent = interCard,
    })
    create("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        TextSize = 11, TextColor3 = Colors.Text, TextTransparency = 0.14,
        Text = "Hide When Minimized", Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = hideRow,
    })
    if not isMobile then hideRow.Visible = true end

    local hideToggleBg = create("TextButton", {
        Size = UDim2.new(0, 36, 0, 18), AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = Color3.fromRGB(8, 8, 14),
        BackgroundTransparency = 0.6, Text = "", AutoButtonColor = false, Parent = hideRow,
    })
    create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = hideToggleBg })
    local hideCircle = create("Frame", {
        Size = UDim2.new(0, 9, 0, 9), Position = UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Colors.SubText,
        BorderSizePixel = 0, Parent = hideToggleBg,
    })
    create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = hideCircle })

    local hideMinimized = cfg.hide_minimized or false

    local function setHideMin(state)
        hideMinimized = state
        cfg.hide_minimized = state
        saveCfg()
        tween(hideToggleBg, TweenInfo.new(0.35), {
            BackgroundColor3 = state and Colors.Accent or Color3.fromRGB(8, 8, 14),
            BackgroundTransparency = state and 0.3 or 0.6,
        })
        tween(hideCircle, TweenInfo.new(0.3), {
            Position = state and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            BackgroundColor3 = state and Colors.Bg or Colors.SubText,
        })
    end
    if hideMinimized then setHideMin(true) end
    hideToggleBg.MouseButton1Click:Connect(function() setHideMin(not hideMinimized) end)

    local trRow = create("TextButton", {
        Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 3, Parent = interCard,
    })
    create("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        TextSize = 11, TextColor3 = Colors.Text, TextTransparency = 0.16,
        Text = "Window Transparency", Size = UDim2.new(0, 153, 0, 13),
        Position = UDim2.new(0, 0, 0.05, 0), BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = trRow,
    })
    local trValLabel = create("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        TextColor3 = Colors.Text, TextTransparency = 0.2, Text = "0.04",
        Size = UDim2.new(0, 42, 0, 13), AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Right, TextSize = 10, Parent = trRow,
    })
    local trDrag = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 0.78,
        Position = UDim2.new(0.5, 0, 0.95, 0), Size = UDim2.new(1, 0, 0, 4),
        BorderSizePixel = 0, BackgroundColor3 = Colors.Stroke, Parent = trRow,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = trDrag })
    local trFill = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 0.05,
        Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(0, 1, 0, 4),
        BorderSizePixel = 0, BackgroundColor3 = Colors.Accent, Parent = trDrag,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = trFill })
    local trCircle = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 7, 0, 7), BorderSizePixel = 0,
        BackgroundColor3 = Colors.AccentSoft, Parent = trFill,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = trCircle })

    local currentTr = cfg.bg_transparency or 0.04

    local function setTransparency(v)
        v = math.clamp(v, 0, 1)
        cfg.bg_transparency = v
        container.BackgroundTransparency = v
        trFill.Size = UDim2.new(math.clamp(v, 0.02, 1), 0, 1, 0)
        trValLabel.Text = string.format("%.2f", v)
    end
    setTransparency(currentTr)

    local trSliding = false
    local mouse = lp:GetMouse()
    trRow.MouseButton1Down:Connect(function()
        trSliding = true
        local pct = math.clamp((mouse.X - trDrag.AbsolutePosition.X) / math.max(trDrag.AbsoluteSize.X, 1), 0, 1)
        setTransparency(pct)
    end)
    UIS.InputChanged:Connect(function(input)
        if not trSliding then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local pct = math.clamp((input.Position.X - trDrag.AbsolutePosition.X) / math.max(trDrag.AbsoluteSize.X, 1), 0, 1)
        setTransparency(pct)
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if trSliding then trSliding = false; saveCfg() end
        end
    end)

    local themeCard = makeSettingsCard(guiRight, "Theme", 1)

    local themeColors = {
        { name = "Main Color", key = "Bg" },
        { name = "Secondary", key = "Card" },
        { name = "Accent", key = "Accent" },
        { name = "Stroke", key = "Stroke" },
        { name = "Text", key = "Text" },
        { name = "SubText", key = "SubText" },
    }

    if not cfg._gui_colors then cfg._gui_colors = {} end

    local function applyThemeColor(key, col)
        Colors[key] = col
        if key == "Stroke" then
            Colors.StrokeHot = Color3.new(
                math.clamp(col.R * 1.2 + 0.05, 0, 1),
                math.clamp(col.G * 1.2 + 0.05, 0, 1),
                math.clamp(col.B * 1.22 + 0.06, 0, 1)
            )
        end
        if key == "Accent" then
            Colors.AccentSoft = Color3.new(
                math.clamp(col.R * 0.55 + 0.42, 0, 1),
                math.clamp(col.G * 0.55 + 0.42, 0, 1),
                math.clamp(col.B * 0.58 + 0.45, 0, 1)
            )
            Colors.AccentDim = Color3.new(
                math.clamp(col.R * 0.42, 0, 1),
                math.clamp(col.G * 0.42, 0, 1),
                math.clamp(col.B * 0.48, 0, 1)
            )
        end
        if key == "Card" then
            Colors.CardDeep = Color3.new(col.R * 0.78, col.G * 0.78, col.B * 0.8)
        end

        local colorMap = {
            Bg = "BackgroundColor3",
            Card = "BackgroundColor3",
            CardDeep = "BackgroundColor3",
            Accent = "BackgroundColor3",
            AccentDim = "BackgroundColor3",
            AccentSoft = "BackgroundColor3",
        }

        for _, desc in screenGui:GetDescendants() do
            pcall(function()
                if desc:IsA("Frame") or desc:IsA("TextButton") or desc:IsA("ScrollingFrame") or desc:IsA("ImageLabel") then
                    if desc.BackgroundTransparency < 1 then
                        if desc.BackgroundColor3 == col then return end
                        for cKey, cVal in Colors do
                            if desc.BackgroundColor3 == cVal then return end
                        end
                    end
                end
            end)
        end

        local function recolor(inst)
            pcall(function()
                if inst:IsA("UIStroke") then
                    for _, cKey in {"Stroke", "StrokeHot"} do
                        local old = nil
                        if cKey == key or (key == "Stroke" and cKey == "StrokeHot") then
                            inst.Color = Colors[cKey]
                        end
                    end
                end
                if inst:IsA("Frame") or inst:IsA("TextButton") or inst:IsA("ScrollingFrame") then
                    if inst.BackgroundTransparency < 1 then
                        if key == "Bg" and inst == container then
                            inst.BackgroundColor3 = Colors.Bg
                        end
                    end
                end
                if inst:IsA("TextLabel") or inst:IsA("TextButton") then
                    if key == "Text" or key == "SubText" then
                        if inst.TextColor3 == Colors.Text or inst.TextColor3 == Colors.SubText then end
                    end
                    if key == "Accent" then
                        if inst.TextColor3 == Colors.Accent or inst.TextColor3 == Colors.AccentSoft then end
                    end
                end
                if inst:IsA("ImageLabel") and key == "Accent" then
                    if inst.ImageColor3 == Colors.AccentSoft or inst.ImageColor3 == Colors.Accent then
                        inst.ImageColor3 = Colors[key == "Accent" and "AccentSoft" or key]
                    end
                end
            end)
        end

        for _, desc in screenGui:GetDescendants() do
            recolor(desc)
        end
    end

    for i, tc in themeColors do
        local hsvState = { h = 0, s = 1, v = 1 }
        local saved = cfg._gui_colors[tc.key]
        if saved then
            hsvState.h = saved.H or 0
            hsvState.s = saved.S or 1
            hsvState.v = saved.V or 1
        else
            local h, s, v = Color3.toHSV(Colors[tc.key])
            hsvState.h = h; hsvState.s = s; hsvState.v = v
            cfg._gui_colors[tc.key] = { H = h, S = s, V = v }
        end

        local row = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false, LayoutOrder = i * 2, Parent = themeCard,
        })
        create("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
            TextSize = 11, TextColor3 = Colors.Text, TextTransparency = 0.14,
            Text = tc.name, Size = UDim2.new(0, 130, 1, 0),
            BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
        })
        local swatch = create("Frame", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(44, 14), BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromHSV(hsvState.h, hsvState.s, hsvState.v), Parent = row,
        })
        create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = swatch })
        create("UIStroke", { Color = Colors.StrokeHot, Transparency = 0.64, Parent = swatch })
        local arrow = create("TextLabel", {
            Text = "›", FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
            TextSize = 14, TextColor3 = Colors.Accent, BackgroundTransparency = 1,
            Size = UDim2.new(0, 12, 1, 0), AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -50, 0.5, 0), Rotation = 90, Parent = row,
        })

        local pickerWrap = create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true,
            BorderSizePixel = 0, LayoutOrder = i * 2 + 1, Parent = themeCard,
        })

        local svBox = create("Frame", {
            Size = UDim2.new(1, 0, 0, 62), Position = UDim2.new(0, 0, 0, 4),
            BorderSizePixel = 0, BackgroundColor3 = Color3.fromHSV(hsvState.h, 1, 1),
            ClipsDescendants = true, Parent = pickerWrap,
        })
        create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = svBox })

        local whiteLayer = create("Frame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0, ZIndex = 2, Parent = svBox,
        })
        create("UIGradient", {
            Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }),
            Parent = whiteLayer,
        })

        local blackLayer = create("Frame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0, ZIndex = 3, Parent = svBox,
        })
        create("UIGradient", {
            Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }),
            Rotation = 90, Parent = blackLayer,
        })

        local svCursor = create("Frame", {
            Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0,
            ZIndex = 5, Visible = false, Position = UDim2.new(hsvState.s, 0, 1 - hsvState.v, 0), Parent = svBox,
        })
        create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = svCursor })
        local svInner = create("Frame", {
            Size = UDim2.fromOffset(8, 8), AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0, ZIndex = 6, Parent = svCursor,
        })
        create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = svInner })

        local hueBar = create("Frame", {
            Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 0, 72),
            BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Parent = pickerWrap,
        })
        create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = hueBar })
        create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
                ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
                ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
                ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 1, 1)),
            }), Parent = hueBar,
        })

        local hueCursor = create("Frame", {
            Size = UDim2.new(0, 6, 1, 4), AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(hsvState.h, 0, 0.5, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0, ZIndex = 4, Visible = false, Parent = hueBar,
        })
        create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = hueCursor })
        local hueInner = create("Frame", {
            Size = UDim2.new(0, 4, 1, 0), AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0, ZIndex = 5, Parent = hueCursor,
        })
        create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = hueInner })

        local function updateVisuals()
            swatch.BackgroundColor3 = Color3.fromHSV(hsvState.h, hsvState.s, hsvState.v)
            svBox.BackgroundColor3 = Color3.fromHSV(hsvState.h, 1, 1)
            svCursor.Position = UDim2.new(hsvState.s, 0, 1 - hsvState.v, 0)
            hueCursor.Position = UDim2.new(hsvState.h, 0, 0.5, 0)
        end

        local function saveColor()
            cfg._gui_colors[tc.key] = { H = hsvState.h, S = hsvState.s, V = hsvState.v }
            applyThemeColor(tc.key, Color3.fromHSV(hsvState.h, hsvState.s, hsvState.v))
            saveCfg()
        end

        local svDragging = false
        local hueDragging = false

        svBox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                svDragging = true
            end
        end)

        hueBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                hueDragging = true
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
            if svDragging then
                hsvState.s = math.clamp((input.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
                hsvState.v = 1 - math.clamp((input.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                updateVisuals()
                saveColor()
            end
            if hueDragging then
                hsvState.h = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                updateVisuals()
                saveColor()
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                svDragging = false
                hueDragging = false
            end
        end)

        local pickerOpen = false
        row.MouseButton1Click:Connect(function()
            pickerOpen = not pickerOpen
            svCursor.Visible = pickerOpen
            hueCursor.Visible = pickerOpen
            tween(pickerWrap, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, pickerOpen and 90 or 0)
            })
            tween(arrow, TweenInfo.new(0.3), { Rotation = pickerOpen and -90 or 90 })
        end)

        updateVisuals()
    end

end

if cfg.orbit then startOrbit() end
if cfg.ability_round then startRoundSpam() end
if cfg.ability_continuous then startContinuous() end
if cfg.no_render then startNoRender() end
if cfg.simple_tp then
    if cfg.simple_tp_continuous then
        startContinuousTp()
    end
    if cfg.simple_tp_round then
        startSimpleTpRound()
    end
end

notify("nothing", "loaded", 3)
