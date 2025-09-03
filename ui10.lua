--// UI Library
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local GlobalColors = {
    ButtonBGColor = Color3.fromRGB(0, 22, 46)
}

local Library = {}
Library.Tabs = {}

local function loadIcons(url)
    local success, result =
        pcall(
        function()
            return game:HttpGet(url, true)
        end
    )

    if not success then
        return {}
    elseif not result then
        return {}
    end

    local chunk, err = loadstring(result)
    if not chunk then
        return {}
    end

    local ok, data = pcall(chunk)
    if not ok then
        return {}
    elseif not data then
        return {}
    end

    local function getTableKeys(tbl)
        local keys = {}
        for k, _ in pairs(tbl) do
            table.insert(keys, k)
        end
        return keys
    end
    return data
end

local Icons = loadIcons("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua")

local function getIcon(name)
    if not Icons or not Icons["48px"] then
        return nil
    end

    name = string.match(string.lower(name), "^%s*(.-)%s*$") or ""

    local r = Icons["48px"][name]
    if not r then
        return nil
    end

    local id, sizeTbl, offsetTbl = r[1], r[2], r[3]

    if type(id) ~= "number" or type(sizeTbl) ~= "table" or type(offsetTbl) ~= "table" then
        return nil
    end

    return {
        id = id,
        imageRectSize = Vector2.new(sizeTbl[1], sizeTbl[2]),
        imageRectOffset = Vector2.new(offsetTbl[1], offsetTbl[2])
    }
end

local function getAssetUri(id)
    if type(id) ~= "number" then
        return "rbxassetid://0"
    end
    return "rbxassetid://" .. id
end

local function createIconButton(iconName, parent)
    local icon = getIcon(iconName)
    if not icon then
        warn("[DEBUG] Cannot create icon button, icon not found:", iconName)
        return nil
    end

    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 20, 0, 20)
    btn.BackgroundTransparency = 1
    btn.Image = getAssetUri(icon.id)
    btn.ImageRectSize = icon.imageRectSize
    btn.ImageRectOffset = icon.imageRectOffset
    btn.Parent = parent
    btn.ZIndex = parent.ZIndex + 1

    return btn
end

--// Gui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "mys_client_ui"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 5
ScreenGui.Parent = CoreGui

local function roundify(obj, radius)
    if not obj:FindFirstChildOfClass("UICorner") then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius)
        corner.Parent = obj
    end
end

--// Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
roundify(MainFrame, 10)

--// TopBar (floating above MainFrame)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(0, 450, 0, 35)
TopBar.Position = UDim2.new(0.5, -230, 0.5, -240)
TopBar.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
TopBar.BorderSizePixel = 0
TopBar.Parent = ScreenGui
roundify(TopBar, 6)

--// Dragging
local dragging, dragInput, dragStart, mainStartPos, topbarStartPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        mainStartPos = MainFrame.Position
        topbarStartPos = TopBar.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X, mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y)
        TopBar.Position = UDim2.new(topbarStartPos.X.Scale, topbarStartPos.X.Offset + delta.X, topbarStartPos.Y.Scale, topbarStartPos.Y.Offset + delta.Y)
    end
end)

--// Title + Version
local Title = Instance.new("TextLabel", TopBar)
Title.Text = "mys.client"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(0, 200, 0, 25)
Title.Position = UDim2.new(0.5, -100, 0, 5)

local Version = Instance.new("TextLabel", TopBar)
Version.Text = "V7.6.1"
Version.Font = Enum.Font.SourceSans
Version.TextSize = 13
Version.TextColor3 = Color3.fromRGB(200, 200, 200)
Version.BackgroundTransparency = 1
Version.Position = UDim2.new(0.5, 60, 0, 8)

--// Minimize & Close
local Minimize = Instance.new("TextButton", TopBar)
Minimize.Size = UDim2.new(0, 25, 0, 25)
Minimize.Position = UDim2.new(1, -55, 0.5, -12)
Minimize.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Minimize.Text = "-"
Minimize.Font = Enum.Font.SourceSansBold
Minimize.TextSize = 24
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
roundify(Minimize, 6)

local Close = Instance.new("TextButton", TopBar)
Close.Size = UDim2.new(0, 25, 0, 25)
Close.Position = UDim2.new(1, -30, 0.5, -12)
Close.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
Close.Text = "X"
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 24
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
roundify(Close, 6)

--// Sidebar (floating style, but parented to MainFrame)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 40, 0, 300)
Sidebar.Position = UDim2.new(0, -45, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
roundify(Sidebar, 6)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.Parent = Sidebar
roundify(ScrollFrame, 6)

local ScrollLayout = Instance.new("UIListLayout", ScrollFrame)
ScrollLayout.Padding = UDim.new(0, 6)

--// Minimize + Close logic
local minimized = false
Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    MainFrame.Visible = not minimized
end)

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

function Library:CreateTab(options)
    if not options or type(options) ~= "table" then
        warn("Invalid options for CreateTab")
        options = { Name = "New Tab" }
    end

    local Tab = {}
    Tab.Name = options.Name or "New Tab"

    -- Page inside MainFrame
    local Page = Instance.new("ScrollingFrame")
    Page.Name = Tab.Name
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Position = UDim2.new(0, 0, 0, 0)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.ScrollBarThickness = 6
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = MainFrame

    -- Add padding to the ScrollingFrame
    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingLeft = UDim.new(0, 5)
    PagePadding.PaddingRight = UDim.new(0, 5)
    PagePadding.PaddingTop = UDim.new(0, 5)
    PagePadding.PaddingBottom = UDim.new(0, 5)
    PagePadding.Parent = Page

    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0, 6)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Sidebar button
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 35)
    TabButton.BackgroundColor3 = GlobalColors.ButtonBGColor
    TabButton.BackgroundTransparency = 0
    TabButton.Text = ""
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.TextSize = 16
    TabButton.Font = Enum.Font.SourceSansBold
    roundify(TabButton, 6)
    TabButton.Parent = ScrollFrame

    -- Default icon mappings if none provided
    local defaultTabIcons = {
        ["Home"] = "home",
        ["Settings"] = "settings",
        ["Profile"] = "user"
    }
    local tabIcons = options.IconMap or defaultTabIcons

    -- Handle icon or text
    if options.Icon and type(options.Icon) == "string" then
        local iconSource = options.Icon
        if iconSource:match("^lucide://") then
            local iconName = tabIcons[Tab.Name] or "circle"
            local iconData = getIcon(iconName)
            if iconData then
                local iconLabel = Instance.new("ImageLabel")
                iconLabel.Size = UDim2.new(0, 20, 0, 20)
                iconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                iconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                iconLabel.BackgroundTransparency = 1
                iconLabel.Image = getAssetUri(iconData.id)
                iconLabel.ImageRectSize = iconData.imageRectSize
                iconLabel.ImageRectOffset = iconData.imageRectOffset
                iconLabel.ZIndex = 3
                iconLabel.Parent = TabButton
            else
                warn("Failed to create icon for tab: " .. Tab.Name .. " (Icon: " .. iconName .. ")")
                -- Fallback to text
                local TextLabel = Instance.new("TextLabel")
                TextLabel.Size = UDim2.new(1, 0, 1, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.Text = Tab.Name
                TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextLabel.TextSize = 16
                TextLabel.Font = Enum.Font.SourceSansBold
                TextLabel.TextXAlignment = Enum.TextXAlignment.Center
                TextLabel.Parent = TabButton
            end
        elseif iconSource:match("^rbxasset://") then
            local IconLabel = Instance.new("ImageLabel")
            IconLabel.Size = UDim2.new(0, 24, 0, 24)
            IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
            IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            IconLabel.BackgroundTransparency = 1
            IconLabel.Image = iconSource
            IconLabel.Parent = TabButton
        else
            -- Fallback to text if icon is invalid
            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(1, 0, 1, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Text = Tab.Name
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.TextSize = 16
            TextLabel.Font = Enum.Font.SourceSansBold
            TextLabel.TextXAlignment = Enum.TextXAlignment.Center
            TextLabel.Parent = TabButton
        end
    else
        -- Use text if no icon is provided
        local TextLabel = Instance.new("TextLabel")
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.Text = Tab.Name
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextSize = 16
        TextLabel.Font = Enum.Font.SourceSansBold
        TextLabel.TextXAlignment = Enum.TextXAlignment.Center
        TextLabel.Parent = TabButton
    end

    -- Update ScrollFrame CanvasSize
    local function updateScrollFrameSize()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollLayout.AbsoluteContentSize.Y)
    end
    ScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollFrameSize)
    updateScrollFrameSize()

    -- Tab button behavior
    TabButton.MouseButton1Click:Connect(function()
        for _, otherTab in ipairs(Library.Tabs) do
            if otherTab.Page then
                otherTab.Page.Visible = false
            end
            if otherTab.Button then
                TweenService:Create(otherTab.Button, TweenInfo.new(0.2), {BackgroundColor3 = GlobalColors.ButtonBGColor}):Play()
            end
        end
        Page.Visible = true
        TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 39, 82)}):Play()
    end)

    Tab.Page = Page
    Tab.Button = TabButton

    -- Button creation inside page
    local buttons = {}
    function Tab:CreateButton(options)
        if not options or type(options) ~= "table" then
            warn("Invalid options for CreateButton")
            return
        end

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 35)
        button.BackgroundTransparency = 0
        button.BackgroundColor3 = GlobalColors.ButtonBGColor
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 18
        button.Text = options.Name or "New Button"
        button.Font = Enum.Font.SourceSans
        button.TextXAlignment = Enum.TextXAlignment.Center
        roundify(button, 6)

        button.MouseEnter:Connect(function()
            local hoverColor = Color3.fromRGB(0, 39, 82)
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = GlobalColors.ButtonBGColor}):Play()
        end)

        button.MouseButton1Click:Connect(function()
            if typeof(options.Callback) == "function" then
                options.Callback()
            end
        end)

        button.Parent = Page
        table.insert(buttons, button)

        -- Update Page CanvasSize
        Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
        return button
    end

    table.insert(Library.Tabs, Tab)

    -- Auto-activate first tab
    if #Library.Tabs == 1 then
        Page.Visible = true
        TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 39, 82)}):Play()
    end

    return Tab
end

return Library
