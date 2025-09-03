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
