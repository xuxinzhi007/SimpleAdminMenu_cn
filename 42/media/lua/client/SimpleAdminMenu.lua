-- Simple Admin Menu v1.7.2 (Build 42)

if SimpleAdminMenuLoaded then return end

require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISContextMenu"
require "ISUI/ISTextEntryBox"
require "ISUI/ISScrollingListBox"
require "ISUI/ISTickBox"
require "ISUI/ISImage"

SimpleAdminMenu = ISCollapsableWindow:derive("SimpleAdminMenu")
SimpleAdminMenu.version = "1.7.2"
SimpleAdminMenu.keepVehicleRepaired = false
SimpleAdminMenu.autoHeal = false
SimpleAdminMenu.activeTab = 1
SimpleAdminMenu.lastSquare = nil
SimpleAdminMenu.modeState = SimpleAdminMenu.modeState or {}

local DATA_KEY = "SimpleAdminMenuData"

-- Charcoal + brass: readable in-game, not generic purple UI.
local COLOR = {
    panelBg = { r = 0.09, g = 0.095, b = 0.10, a = 0.97 },
    panelBorder = { r = 0.62, g = 0.52, b = 0.30, a = 0.92 },
    header = { r = 0.93, g = 0.78, b = 0.38, a = 1 },
    muted = { r = 0.68, g = 0.66, b = 0.60, a = 1 },
    white = { r = 0.96, g = 0.95, b = 0.92, a = 1 },
    tabBar = { r = 0.07, g = 0.075, b = 0.08, a = 0.95 },
    tabIdle = { r = 0.15, g = 0.145, b = 0.13, a = 1 },
    tabActive = { r = 0.30, g = 0.24, b = 0.12, a = 1 },
    tabHover = { r = 0.24, g = 0.20, b = 0.12, a = 1 },
    card = { r = 0.13, g = 0.125, b = 0.11, a = 0.88 },
    cardBorder = { r = 0.42, g = 0.36, b = 0.22, a = 0.70 },
    btn = { r = 0.17, g = 0.165, b = 0.15, a = 1 },
    btnBorder = { r = 0.48, g = 0.42, b = 0.28, a = 1 },
    btnHover = { r = 0.24, g = 0.22, b = 0.16, a = 1 },
    on = { r = 0.14, g = 0.32, b = 0.18, a = 1 },
    onBorder = { r = 0.45, g = 0.78, b = 0.48, a = 1 },
    danger = { r = 0.34, g = 0.13, b = 0.12, a = 1 },
    dangerBorder = { r = 0.82, g = 0.40, b = 0.32, a = 1 },
    dangerHover = { r = 0.42, g = 0.18, b = 0.15, a = 1 },
    accent = { r = 0.30, g = 0.24, b = 0.11, a = 1 },
    accentBorder = { r = 0.86, g = 0.68, b = 0.30, a = 1 },
    accentHover = { r = 0.38, g = 0.30, b = 0.14, a = 1 },
    statusOk = { r = 0.45, g = 0.78, b = 0.48, a = 1 },
    statusWarn = { r = 0.90, g = 0.55, b = 0.30, a = 1 },
}

local HOTKEY_NAMES = { "F6", "F7", "F8", "F9" }

local function hotkeyCode(name)
    if not Keyboard then return nil end
    if name == "F6" then return Keyboard.KEY_F6 end
    if name == "F7" then return Keyboard.KEY_F7 end
    if name == "F8" then return Keyboard.KEY_F8 end
    if name == "F9" then return Keyboard.KEY_F9 end
    return Keyboard.KEY_F6
end

local BUTTON_POS = { "bottomLeft", "midLeft", "bottomRight" }
local UI_SCALES = { "standard", "large" }
local FAST_READ_MULTS = { 1, 2, 5, 10 }

local function text(key)
    return getText("IGUI_SimpleAdminMenu_" .. key)
end

SimpleAdminMenu.tabs = { "Tab_Player", "Tab_Items", "Tab_Vehicles", "Tab_World", "Tab_More", "Tab_Settings" }
SimpleAdminMenu.categoryNames = { "Favorites", "Food", "Medical", "Tools", "Weapons", "Building", "Clothing", "Ammo", "Misc" }
SimpleAdminMenu.categoryLabels = {
    Favorites = "Category_Favorites",
    Food = "Category_Food",
    Medical = "Category_Medical",
    Tools = "Category_Tools",
    Weapons = "Category_Weapons",
    Building = "Category_Building",
    Clothing = "Category_Clothing",
    Ammo = "Category_Ammo",
    Misc = "Category_Misc",
}

-- B42 renamed/removed many B41 IDs; keep aliases for resolveItemType().
local ITEM_ALIASES = {
    ["Base.Cigarettes"] = { "Base.CigarettePack", "Base.CigaretteSingle" },
    ["Base.WaterBottleFull"] = { "Base.WaterBottle" },
    ["Base.Matches"] = { "Base.Matchbox", "Base.Matches" },
    ["Base.Sleepingbag"] = { "Base.SleepingBag_Green_Packed", "Base.SleepingBag_Green", "Base.SleepingBag_BluePlaid_Packed" },
    ["Base.CampingTentKit"] = { "Base.CampingTentKit2", "Base.CampingTentKit2_Packed", "Base.ImprovisedTentKit" },
    -- B42 often uses Gasoline / EmptyGasoline; prefer those first.
    ["Base.PetrolCan"] = { "Base.Gasoline", "Base.PetrolCan" },
    ["Base.EmptyPetrolCan"] = { "Base.EmptyGasoline", "Base.EmptyPetrolCan" },
    ["Base.Gasoline"] = { "Base.Gasoline", "Base.PetrolCan" },
    ["Base.EmptyGasoline"] = { "Base.EmptyGasoline", "Base.EmptyPetrolCan" },
    ["Base.Radio.WalkieTalkieMakeShift"] = { "Base.WalkieTalkieMakeShift", "Base.Radio.WalkieTalkieMakeShift", "Radio.WalkieTalkieMakeShift" },
}

SimpleAdminMenu.items = {
    Favorites = {},
    Food = {
        { "Item_CannedSoup", "Base.CannedSoup" },
        { "Item_CannedBeans", "Base.CannedBeans" },
        { "Item_TinnedTuna", "Base.TinnedTuna" },
        { "Item_WaterBottle", "Base.WaterBottle" },
        { "Item_Bread", "Base.Bread" },
        { "Item_Cereal", "Base.Cereal" },
        { "Item_Chocolate", "Base.Chocolate" },
        { "Item_Crisps", "Base.Crisps" },
        { "Item_CannedCornedBeef", "Base.CannedCornedBeef" },
        { "Item_Apple", "Base.Apple" },
        { "Item_CigarettePack", "Base.CigarettePack" },
        { "Item_CigaretteSingle", "Base.CigaretteSingle" },
    },
    Medical = {
        { "Item_Bandage", "Base.Bandage" },
        { "Item_AlcoholBandage", "Base.AlcoholBandage" },
        { "Item_Bandaid", "Base.Bandaid" },
        { "Item_Disinfectant", "Base.Disinfectant" },
        { "Item_Pills", "Base.Pills" },
        { "Item_PillsBeta", "Base.PillsBeta" },
        { "Item_SutureNeedle", "Base.SutureNeedle" },
        { "Item_Tweezers", "Base.Tweezers" },
        { "Item_Antibiotics", "Base.Antibiotics" },
        { "Item_FirstAidKit", "Base.FirstAidKit" },
    },
    Tools = {
        { "Item_Hammer", "Base.Hammer" },
        { "Item_Saw", "Base.Saw" },
        { "Item_Axe", "Base.Axe" },
        { "Item_Sledgehammer", "Base.Sledgehammer" },
        { "Item_Screwdriver", "Base.Screwdriver" },
        { "Item_Wrench", "Base.Wrench" },
        { "Item_Crowbar", "Base.Crowbar" },
        { "Item_BlowTorch", "Base.BlowTorch" },
        { "Item_WeldingMask", "Base.WeldingMask" },
        { "Item_TirePump", "Base.TirePump" },
        { "Item_Jack", "Base.Jack" },
        { "Item_LugWrench", "Base.LugWrench" },
    },
    Weapons = {
        { "Item_BaseballBat", "Base.BaseballBat" },
        { "Item_BaseballBatNails", "Base.BaseballBatNails" },
        { "Item_KitchenKnife", "Base.KitchenKnife" },
        { "Item_Machete", "Base.Machete" },
        { "Item_Katana", "Base.Katana" },
        { "Item_Shotgun", "Base.Shotgun" },
        { "Item_Pistol", "Base.Pistol" },
        { "Item_AssaultRifle", "Base.AssaultRifle" },
        { "Item_HuntingRifle", "Base.VarmintRifle" },
        { "Item_Axe", "Base.Axe" },
    },
    Building = {
        { "Item_Plank", "Base.Plank" },
        { "Item_Nails", "Base.Nails" },
        { "Item_NailsBox", "Base.NailsBox" },
        { "Item_Hinge", "Base.Hinge" },
        { "Item_Doorknob", "Base.Doorknob" },
        { "Item_SheetRope", "Base.SheetRope" },
        { "Item_Garbagebag", "Base.Garbagebag" },
        { "Item_WeldingRods", "Base.WeldingRods" },
        { "Item_MetalPipe", "Base.MetalPipe" },
        { "Item_SheetMetal", "Base.SheetMetal" },
        { "Item_ScrewsBox", "Base.ScrewsBox" },
        { "Item_DuctTape", "Base.DuctTape" },
    },
    Clothing = {
        { "Item_Schoolbag", "Base.Bag_Schoolbag" },
        { "Item_DuffelBag", "Base.Bag_DuffelBag" },
        { "Item_BigHikingBag", "Base.Bag_BigHikingBag" },
        { "Item_LeatherGloves", "Base.Gloves_LeatherGloves" },
        { "Item_ArmyBoots", "Base.Shoes_ArmyBoots" },
        { "Item_HardHat", "Base.Hat_HardHat" },
        { "Item_BulletproofVest", "Base.Vest_BulletCivilian" },
        { "Item_Holster", "Base.HolsterSimple" },
    },
    Ammo = {
        { "Item_Bullets9mmBox", "Base.Bullets9mmBox" },
        { "Item_ShotgunShellsBox", "Base.ShotgunShellsBox" },
        { "Item_223Box", "Base.223Box" },
        { "Item_308Box", "Base.308Box" },
        { "Item_556Box", "Base.556Box" },
        { "Item_Bullets38Box", "Base.Bullets38Box" },
        { "Item_Bullets44Box", "Base.Bullets44Box" },
        { "Item_Bullets45Box", "Base.Bullets45Box" },
        { "Item_Mag9mm", "Base.9mmClip" },
        { "Item_Mag45", "Base.45Clip" },
        { "Item_Mag44", "Base.44Clip" },
        { "Item_Mag38", "Base.38SpecialClip" },
        { "Item_Mag223", "Base.223Clip" },
        { "Item_Mag308", "Base.308Clip" },
        { "Item_Mag556", "Base.556Clip" },
        { "Item_MagShotgun", "Base.ShotgunShells" },
    },
    Misc = {
        { "Item_Torch", "Base.Torch" },
        { "Item_Battery", "Base.Battery" },
        { "Item_Lighter", "Base.Lighter" },
        { "Item_Matches", "Base.Matchbox" },
        { "Item_Radio", "Base.WalkieTalkieMakeShift" },
        { "Item_Generator", "Base.Generator" },
        { "Item_Petrol", "Base.Gasoline" },
        { "Item_EmptyPetrol", "Base.EmptyGasoline" },
        { "Item_TentKit", "Base.CampingTentKit2" },
        { "Item_SleepingBag", "Base.SleepingBag_Green_Packed" },
    },
}

SimpleAdminMenu.vehicles = {
    { "Vehicle_StandardCar", "Base.CarNormal" },
    { "Vehicle_Van", "Base.Van" },
    { "Vehicle_SmallCar", "Base.SmallCar" },
    { "Vehicle_PickupTruck", "Base.PickUpTruck" },
    { "Vehicle_PickupVan", "Base.PickUpVan" },
    { "Vehicle_SportsCar", "Base.SportsCar" },
    { "Vehicle_Ambulance", "Base.VanAmbulance" },
    { "Vehicle_PoliceCar", "Base.CarLightsPolice" },
    { "Vehicle_FireVehicle", "Base.PickUpTruckLightsFire" },
    { "Vehicle_RangerCar", "Base.CarLights" },
    { "Vehicle_ModernCar", "Base.ModernCar" },
    { "Vehicle_SUV", "Base.SUV" },
}

SimpleAdminMenu.mapObjects = {
    { "Object_WoodenCrate", "carpentry_02_59" },
    { "Object_WoodenChair", "furniture_seating_indoor_01_0" },
    { "Object_SmallTable", "furniture_tables_low_01_0" },
    { "Object_Counter", "fixtures_counters_01_0" },
    { "Object_Fridge", "appliances_refrigeration_01_0" },
    { "Object_Oven", "appliances_cooking_01_0" },
    { "Object_TrashBin", "trashcontainers_01_0" },
    { "Object_WoodenWall", "walls_exterior_wooden_01_0" },
    { "Object_MetalFence", "fencing_01_0" },
    { "Object_GravelFloor", "blends_natural_01_5" },
    { "Object_WoodFloor", "floors_interior_tilesandwood_01_40" },
    { "Object_SandbagWall", "constructedobjects_01_32" },
}

local function log(s)
    print("[SimpleAdminMenu v" .. SimpleAdminMenu.version .. "] " .. tostring(s))
end

local function player()
    return getSpecificPlayer(0) or getPlayer()
end

local function say(s)
    log(s)
    local p = player()
    if p and p.Say then
        pcall(function() p:Say(tostring(s)) end)
    end
end

local function safe(label, fn)
    local ok, err = pcall(fn)
    if not ok then
        log(text("Log_Error") .. tostring(label) .. ": " .. tostring(err))
        say(label .. text("Error_FailedSuffix"))
    end
end

local function cycle(v, max, chg)
    if not max or max <= 0 then return 1 end
    v = v + chg
    if v < 1 then return max end
    if v > max then return 1 end
    return v
end

local function labelText(lbl, txt)
    if lbl then lbl.name = tostring(txt) end
end

local function copyColor(c, a)
    return { r = c.r, g = c.g, b = c.b, a = a or c.a or 1 }
end

local function styleButton(btn, bg, border, hover)
    if not btn then return end
    btn.backgroundColor = copyColor(bg)
    btn.borderColor = copyColor(border)
    btn.backgroundColorMouseOver = copyColor(hover or COLOR.btnHover)
end

local function styleByKind(btn, kind)
    if kind == "danger" then
        styleButton(btn, COLOR.danger, COLOR.dangerBorder, COLOR.dangerHover)
    elseif kind == "accent" then
        styleButton(btn, COLOR.accent, COLOR.accentBorder, COLOR.accentHover)
    elseif kind == "tab" then
        styleButton(btn, COLOR.tabIdle, COLOR.btnBorder, COLOR.tabHover)
    else
        styleButton(btn, COLOR.btn, COLOR.btnBorder, COLOR.btnHover)
    end
    if btn then btn._samKind = kind or "normal" end
end

local function getModData()
    local data
    if ModData and ModData.getOrCreate then
        data = ModData.getOrCreate(DATA_KEY)
    else
        SimpleAdminMenu._localData = SimpleAdminMenu._localData or {}
        data = SimpleAdminMenu._localData
    end
    if not data.waypoints then data.waypoints = {} end
    if not data.favorites then data.favorites = {} end
    if not data.settings then data.settings = {} end
    -- carryBoost: nil = off; number = forced MaxWeightBase (B42 recalculates from base each tick)
    local s = data.settings
    if s.hotkey == nil then s.hotkey = "F6" end
    if s.showButton == nil then s.showButton = true end
    if s.buttonPos == nil then s.buttonPos = "bottomLeft" end
    if s.uiScale == nil then s.uiScale = "large" end
    if s.fastReadingMult == nil then s.fastReadingMult = 1 end
    local fr = tonumber(s.fastReadingMult) or 1
    if fr < 1 then fr = 1 end
    s.fastReadingMult = fr
    return data
end

local function saveModData()
    if ModData and ModData.transmit then
        pcall(function() ModData.transmit(DATA_KEY) end)
    end
end

local function getSettings()
    return getModData().settings
end

local function getWaypoints()
    return getModData().waypoints
end

local function getFavorites()
    return getModData().favorites
end

local function favoriteEntries()
    local out = {}
    for _, fav in ipairs(getFavorites()) do
        local label = fav.label or fav[1] or fav.type or fav[2] or "?"
        local typ = fav.type or fav[2] or ""
        if typ ~= "" then
            table.insert(out, { label, typ, true })
        end
    end
    return out
end

--- Flat list of preset categories only (no full-game ScriptManager scan).
local function buildFlatItems()
    local flat = {}
    local seen = {}
    local function add(entry)
        if entry and entry[2] and not seen[entry[2]] then
            seen[entry[2]] = true
            table.insert(flat, entry)
        end
    end
    for _, fav in ipairs(favoriteEntries()) do add(fav) end
    for _, cat in ipairs(SimpleAdminMenu.categoryNames) do
        if cat ~= "Favorites" then
            for _, entry in ipairs(SimpleAdminMenu.items[cat] or {}) do add(entry) end
        end
    end
    return flat
end

local function rememberSquare(sq)
    if sq then SimpleAdminMenu.lastSquare = sq end
    return sq
end

local function squareAhead(p, steps)
    if not p then return nil end
    steps = steps or 2
    local sq = nil
    if p.getCurrentSquare then sq = p:getCurrentSquare() end
    if not sq then
        local cell = getCell()
        if cell then
            sq = cell:getGridSquare(math.floor(p:getX()), math.floor(p:getY()), math.floor(p:getZ()))
        end
    end
    if not sq then return nil end
    local dir = p.getDir and p:getDir() or nil
    if not dir then return sq end
    local cur = sq
    for i = 1, steps do
        local nextSq = nil
        if cur.getTileInDirection then
            pcall(function() nextSq = cur:getTileInDirection(dir) end)
        end
        if (not nextSq) and cur.getAdjacentSquare then
            pcall(function() nextSq = cur:getAdjacentSquare(dir) end)
        end
        if not nextSq then break end
        cur = nextSq
    end
    return cur
end

local function mouseSquare()
    local p = player()
    if not p then return nil end
    local cell = getCell()
    if not cell then return nil end
    local z = math.floor(p:getZ())
    local mx = (getMouseXScaled and getMouseXScaled()) or (getMouseX and getMouseX()) or 0
    local my = (getMouseYScaled and getMouseYScaled()) or (getMouseY and getMouseY()) or 0

    if ISCoordConversion and ISCoordConversion.ToWorldX and ISCoordConversion.ToWorldY then
        local wx, wy = nil, nil
        local ok = pcall(function()
            wx = ISCoordConversion.ToWorldX(mx, my, z)
            wy = ISCoordConversion.ToWorldY(mx, my, z)
        end)
        if ok and wx and wy then
            local sq = cell:getGridSquare(math.floor(wx), math.floor(wy), z)
            if sq then return rememberSquare(sq) end
        end
    end
    if SimpleAdminMenu.lastSquare then return SimpleAdminMenu.lastSquare end
    local ahead = squareAhead(p, 2)
    if ahead then return rememberSquare(ahead) end
    return rememberSquare(cell:getGridSquare(math.floor(p:getX()), math.floor(p:getY()), z))
end

local function nearSquare()
    local p = player()
    if not p then return nil end
    return squareAhead(p, 2) or mouseSquare()
end

local function getScriptManagerSafe()
    if getScriptManager then
        local ok, sm = pcall(function() return getScriptManager() end)
        if ok and sm then return sm end
    end
    if ScriptManager and ScriptManager.instance then return ScriptManager.instance end
    return nil
end

local function itemScriptExists(itemType)
    if not itemType or itemType == "" then return false end
    local sm = getScriptManagerSafe()
    if not sm then return true end
    local ok, script = pcall(function()
        if sm.getItem then return sm:getItem(itemType) end
        if sm.FindItem then return sm:FindItem(itemType) end
        return nil
    end)
    return ok and script ~= nil
end

local function resolveItemType(itemType)
    itemType = tostring(itemType or "")
    if itemType == "" then return itemType end
    local candidates = { itemType }
    local aliases = ITEM_ALIASES[itemType]
    if aliases then
        for _, a in ipairs(aliases) do table.insert(candidates, a) end
    end
    for _, id in ipairs(candidates) do
        if itemScriptExists(id) then return id end
    end
    return itemType
end

local function getItemTexture(itemType)
    itemType = resolveItemType(itemType)
    local tex = nil
    pcall(function()
        local sm = getScriptManagerSafe()
        local script = nil
        if sm and sm.getItem then script = sm:getItem(itemType) end
        if (not script) and sm and sm.FindItem then script = sm:FindItem(itemType) end
        if script then
            if script.getNormalTexture then tex = script:getNormalTexture() end
            if (not tex) and script.getIcon then
                local icon = script:getIcon()
                if icon and getTexture then
                    tex = getTexture("Item_" .. tostring(icon))
                    if not tex then tex = getTexture(tostring(icon)) end
                end
            end
        end
        if (not tex) and instanceItem then
            local item = instanceItem(itemType)
            if item and item.getTex then tex = item:getTex() end
        end
    end)
    return tex
end

local function fitTextWidth(str, maxW, font)
    str = tostring(str or "")
    if maxW <= 8 then return "" end
    local tm = getTextManager and getTextManager() or nil
    if not tm or not tm.MeasureStringX then return str end
    if tm:MeasureStringX(font, str) <= maxW then return str end
    local ell = "..."
    local out = str
    while #out > 0 do
        out = string.sub(out, 1, #out - 1)
        if tm:MeasureStringX(font, out .. ell) <= maxW then
            return out .. ell
        end
    end
    return ell
end

local function spawnItemType(itemType, count)
    local p = player()
    if not p then error(text("Error_NoPlayer")) end
    local inv = p:getInventory()
    if not inv then error(text("Error_NoInventory")) end
    local resolved = resolveItemType(itemType)
    count = count or 1
    local added = 0
    for i = 1, count do
        local item = nil
        if instanceItem then
            local ok, created = pcall(function() return instanceItem(resolved) end)
            if ok then item = created end
        end
        if not item and InventoryItemFactory and InventoryItemFactory.CreateItem then
            local ok, created = pcall(function() return InventoryItemFactory.CreateItem(resolved) end)
            if ok then item = created end
        end
        if item then
            local ok = pcall(function() inv:AddItem(item) end)
            if ok then added = added + 1 end
        else
            local ok, created = pcall(function() return inv:AddItem(resolved) end)
            if ok and created then added = added + 1 end
        end
    end
    if added <= 0 then
        error(text("Error_SpawnItemFailed") .. tostring(itemType) .. " -> " .. tostring(resolved))
    end
    return added
end

--- Prefer silent remove (no combat/noise). Kill() is fallback only.
local function removeZombie(z, p)
    if not z then return false end
    local ok = false
    pcall(function()
        if z.removeFromWorld then z:removeFromWorld(); ok = true end
    end)
    if not ok then
        pcall(function()
            if z.removeFromSquare then z:removeFromSquare(); ok = true end
        end)
    end
    if not ok and z.Kill then ok = pcall(function() z:Kill(p) end) end
    if not ok and z.setHealth then ok = pcall(function() z:setHealth(0) end) end
    if not ok and z.setDead then ok = pcall(function() z:setDead(true) end) end
    return ok
end

local function enabledText(value)
    if value then return text("State_Enabled") end
    return text("State_Disabled")
end

local function toBool(v)
    if v == true or v == 1 then return true end
    if v == false or v == 0 or v == nil then return false end
    if type(v) == "string" then
        local s = string.lower(v)
        if s == "true" or s == "1" or s == "yes" then return true end
        if s == "false" or s == "0" or s == "no" or s == "" then return false end
    end
    return false
end

-- IMPORTANT: On this Kahlua build, wrong Java arity still prints ERROR even inside pcall.
-- Only call cheat setters with a single boolean argument.
local function callPlayer1(p, methodName, arg1)
    if not p or not methodName then return false, nil end
    local fn = p[methodName]
    if not fn then return false, nil end
    if arg1 == nil then return pcall(fn, p) end
    return pcall(fn, p, arg1)
end

local function getToggle(getter, stateKey)
    if stateKey and SimpleAdminMenu.modeState[stateKey] ~= nil then
        return SimpleAdminMenu.modeState[stateKey] and true or false
    end
    local p = player()
    if not p or not getter then return false end
    local ok, cur = callPlayer1(p, getter)
    if not ok then return false end
    return toBool(cur)
end

local function setPlayerBool(p, setter, value)
    value = value and true or false
    if callPlayer1(p, setter, value) then return true end
    local alts = {
        setGodMod = { "setGodMode", "setInvincible" },
        setGodMode = { "setGodMod", "setInvincible" },
        setNoClip = { "setNoClip" },
        setGhostMode = { "setGhostMode", "setZombiesDontAttack" },
        setInvisible = { "setInvisible" },
        setZombiesDontAttack = { "setGhostMode" },
        setInvincible = { "setGodMod", "setGodMode" },
    }
    for _, name in ipairs(alts[setter] or {}) do
        if callPlayer1(p, name, value) then return true end
    end
    return false
end

local function toggle(label, getter, setter)
    local p = player()
    if not p then error(text("Error_NoPlayer")) end
    local key = setter or getter or label
    local cur = getToggle(getter, key)
    local newVal = not cur
    if not setPlayerBool(p, setter, newVal) then
        error(text("Error_MissingMethod") .. tostring(setter))
    end
    SimpleAdminMenu.modeState[key] = newVal
    say(label .. text("Separator") .. enabledText(newVal))
end

local function syncAutoRepairButton(btn)
    if not btn then return end
    local on = SimpleAdminMenu.keepVehicleRepaired and true or false
    if on then
        btn:setTitle(text("Button_AutoRepairOn"))
        styleButton(btn, COLOR.on, COLOR.onBorder, COLOR.on)
    else
        btn:setTitle(text("Button_AutoRepairOff"))
        styleByKind(btn, "normal")
    end
end

local function syncAutoHealButton(btn)
    if not btn then return end
    local on = SimpleAdminMenu.autoHeal and true or false
    if on then
        btn:setTitle(text("Button_AutoHealOn"))
        styleButton(btn, COLOR.on, COLOR.onBorder, COLOR.on)
    else
        btn:setTitle(text("Button_AutoHealOff"))
        styleByKind(btn, "accent")
    end
end

local function repairVehicle(v)
    if not v then error(text("Error_NoVehicle")) end
    if v.setGeneralPartCondition then pcall(function() v:setGeneralPartCondition(100, 100) end) end
    if v.getPartCount and v.getPartByIndex then
        for i = 0, v:getPartCount() - 1 do
            local part = v:getPartByIndex(i)
            if part and part.setCondition then pcall(function() part:setCondition(100) end) end
            if part and part.getInventoryItem then
                local item = part:getInventoryItem()
                if item and item.setCondition then pcall(function() item:setCondition(100) end) end
            end
            if part and part.setContainerContentAmount and part.getContainerCapacity then
                pcall(function()
                    local cap = part:getContainerCapacity()
                    if cap and cap > 0 then part:setContainerContentAmount(cap) end
                end)
            end
        end
    end
    if v.setRust then pcall(function() v:setRust(0) end) end
    if v.updatePartStats then pcall(function() v:updatePartStats() end) end
end

local function applyHeal(p)
    p = p or player()
    if not p then return false end
    local b = nil
    if p.getBodyDamage then b = p:getBodyDamage() end
    if b then
        if b.RestoreToFullHealth then b:RestoreToFullHealth() end
        if b.setOverallBodyHealth then b:setOverallBodyHealth(100) end
        if b.setInfected then b:setInfected(false) end
        if b.setIsFakeInfected then b:setIsFakeInfected(false) end
        if b.setFoodSicknessLevel then b:setFoodSicknessLevel(0) end
        if b.setColdStrength then b:setColdStrength(0) end
        if b.setWetness then b:setWetness(0) end
        if b.setTemperature then b:setTemperature(37) end
    end
    return true
end

local function healPlayer()
    if not applyHeal(player()) then error(text("Error_NoPlayer")) end
    say(text("Status_Healed"))
end

local function setGameStat(stats, setterName, fieldName, value)
    if not stats then return end
    local ok = false
    pcall(function()
        local fn = stats[setterName]
        if fn then fn(stats, value); ok = true end
    end)
    if not ok and fieldName then
        pcall(function() stats[fieldName] = value end)
    end
end

local function applyNeeds(p)
    p = p or player()
    if not p then return false end
    local s = nil
    pcall(function()
        if p.getStats then s = p:getStats() end
    end)
    setGameStat(s, "setHunger", "hunger", 0)
    setGameStat(s, "setThirst", "thirst", 0)
    setGameStat(s, "setFatigue", "fatigue", 0)
    setGameStat(s, "setPanic", "panic", 0)
    setGameStat(s, "setEndurance", "endurance", 1)
    setGameStat(s, "setStress", "stress", 0)
    setGameStat(s, "setBoredom", "boredom", 0)
    setGameStat(s, "setAnger", "anger", 0)
    setGameStat(s, "setPain", "pain", 0)
    return true
end

local function refillNeeds()
    if not applyNeeds(player()) then error(text("Error_NoPlayer")) end
    say(text("Status_NeedsFilled"))
end

local function toggleAutoHeal()
    SimpleAdminMenu.autoHeal = not SimpleAdminMenu.autoHeal
    if SimpleAdminMenu.autoHeal then
        pcall(function() applyHeal(player()) end)
        pcall(function() applyNeeds(player()) end)
    end
    say(text("Label_AutoHeal") .. text("Separator") .. enabledText(SimpleAdminMenu.autoHeal))
end

local function killNearby(radius)
    local p = player()
    if not p then error(text("Error_NoPlayer")) end
    local zeds = p:getCell():getZombieList()
    local killed = 0
    radius = radius or 6
    for i = zeds:size() - 1, 0, -1 do
        local z = zeds:get(i)
        if z and (not z.isDead or not z:isDead()) and p:DistTo(z) <= radius then
            if removeZombie(z, p) then killed = killed + 1 end
        end
    end
    say(text("Status_KilledNearby") .. killed)
end

local function killCursor()
    local p = player()
    local sq = mouseSquare()
    if not sq then error(text("Error_NoSquare")) end
    local m = sq:getMovingObjects()
    for i = m:size() - 1, 0, -1 do
        local o = m:get(i)
        local iz = false
        if instanceof then pcall(function() iz = instanceof(o, "IsoZombie") end) end
        if not iz and o and o.getObjectName and o:getObjectName() == "Zombie" then iz = true end
        if iz and removeZombie(o, p) then
            say(text("Status_KilledCursor"))
            return
        end
    end
    local zeds = p and p:getCell() and p:getCell():getZombieList() or nil
    if zeds then
        local best, bestDist = nil, 3
        for i = 0, zeds:size() - 1 do
            local z = zeds:get(i)
            if z and (not z.isDead or not z:isDead()) then
                local d = p:DistTo(z)
                if d < bestDist then best, bestDist = z, d end
            end
        end
        if best and removeZombie(best, p) then
            say(text("Status_KilledCursor"))
            return
        end
    end
    error(text("Error_NoZombie"))
end

local function teleportToSquare(sq)
    local p = player()
    if not p or not sq then error(text("Error_NoPlayerSquare")) end
    local x = sq:getX() + 0.5
    local y = sq:getY() + 0.5
    local z = sq:getZ()
    local ok = false
    if p.teleportTo then ok = pcall(function() p:teleportTo(x, y, z) end) end
    if not ok then
        pcall(function()
            p:setX(x); p:setY(y); p:setZ(z)
            if p.setLx then p:setLx(x) end
            if p.setLy then p:setLy(y) end
            if p.setLz then p:setLz(z) end
            if p.setCurrent then p:setCurrent(sq) end
        end)
    end
    rememberSquare(sq)
end

local function teleportToCursor()
    local sq = mouseSquare()
    if not sq then error(text("Error_NoSquare")) end
    teleportToSquare(sq)
    say(text("Status_Teleported"))
end

local function parseXY(raw)
    if raw == nil then return nil end
    local s = tostring(raw):gsub("%s+", "")
    if s == "" then return nil end
    local xs, ys = s:match("^(%-?%d+),(%-?%d+)$")
    if not xs then xs, ys = s:match("^(%-?%d+);(%-?%d+)$") end
    if not xs then return nil end
    return tonumber(xs), tonumber(ys)
end

local function teleportToXY(raw)
    local x, y = parseXY(raw)
    if not x or not y then error(text("Error_BadCoords")) end
    local p = player()
    local z = 0
    if p and p.getZ then z = math.floor(p:getZ()) end
    local cell = getCell and getCell() or nil
    if not cell then error(text("Error_NoPlayerSquare")) end
    local sq = cell:getGridSquare(x, y, z)
    if not sq and z ~= 0 then sq = cell:getGridSquare(x, y, 0) end
    if not sq then error(text("Error_NoPlayerSquare")) end
    teleportToSquare(sq)
    say(text("Status_Teleported") .. string.format(" [%d,%d,%d]", x, y, math.floor(sq:getZ())))
end

local function squareFromObject(o)
    if not o then return nil end
    local sq = nil
    pcall(function()
        if o.getSquare then sq = o:getSquare() end
    end)
    return sq
end

local function squareFromWorldObjects(worldobjects)
    if clickedSquare then
        return rememberSquare(clickedSquare)
    end
    if worldobjects then
        local o0 = worldobjects[0] or worldobjects[1]
        local sq = squareFromObject(o0)
        if sq then return rememberSquare(sq) end
        if worldobjects.size then
            local size = 0
            pcall(function() size = worldobjects:size() end)
            for i = 0, size - 1 do
                local o = nil
                pcall(function() o = worldobjects:get(i) end)
                sq = squareFromObject(o)
                if sq then return rememberSquare(sq) end
            end
        else
            for i = 1, #worldobjects do
                sq = squareFromObject(worldobjects[i])
                if sq then return rememberSquare(sq) end
            end
        end
    end
    if SimpleAdminMenu.lastSquare then return SimpleAdminMenu.lastSquare end
    return mouseSquare()
end

--- Teleport to the tile that was right-clicked (context menu), not current mouse pos.
local function teleportToContext(worldobjects)
    local sq = squareFromWorldObjects(worldobjects)
    if not sq then error(text("Error_NoSquare")) end
    teleportToSquare(sq)
    say(text("Status_Teleported"))
end

local function setTimeHours(h)
    local gt = getGameTime and getGameTime() or nil
    if not gt then error(text("Error_NoGameTime")) end
    if gt.setTimeOfDay then gt:setTimeOfDay(h)
    elseif gt.setHour then gt:setHour(h)
    else error(text("Error_TimeUnavailable")) end
    say(text("Status_TimeSet") .. tostring(h) .. ":00")
end

local function clearWeather()
    local cm = getClimateManager and getClimateManager() or nil
    if not cm then error(text("Error_WeatherUnavailable")) end
    local ok = false
    if cm.stopWeatherAndThunder then
        ok = pcall(function() cm:stopWeatherAndThunder() end) or ok
    end
    if cm.transmitStopWeather then
        ok = pcall(function() cm:transmitStopWeather() end) or ok
    end
    if cm.transmitServerStopWeather then
        ok = pcall(function() cm:transmitServerStopWeather() end) or ok
    end
    -- Best-effort fog wipe (B42 admin climate path varies by build).
    pcall(function() cm.fogIntensity = 0 end)
    pcall(function()
        if ClimateManager and ClimateManager.FLOAT_FOG_INTENSITY and cm.getClimateFloat then
            local fog = cm:getClimateFloat(ClimateManager.FLOAT_FOG_INTENSITY)
            if fog then
                if fog.setEnableAdmin then fog:setEnableAdmin(true) end
                if fog.setAdminValue then fog:setAdminValue(0) end
                if fog.setFinalValue then fog:setFinalValue(0) end
            end
        end
    end)
    if not ok then error(text("Error_WeatherUnavailable")) end
    say(text("Status_WeatherCleared"))
end

local function parseCarryInput(raw)
    if raw == nil then return nil end
    local s = tostring(raw):gsub("%s+", "")
    if s == "" then return nil end
    local n = tonumber(s)
    if not n then
        n = tonumber(s:match("(%d+)"))
    end
    if not n then return nil end
    n = math.floor(n + 0.5)
    if n < 1 then n = 1 end
    if n > 99999 then n = 99999 end
    return n
end

local function applyCarryBoost(p)
    p = p or player()
    if not p then return false end
    local data = getModData()
    local boost = tonumber(data.carryBoost)
    if not boost or boost <= 0 then return false end
    local ok = false
    -- B42: capacity is derived from MaxWeightBase; setMaxWeight alone is overwritten.
    pcall(function()
        if p.setMaxWeightBase then p:setMaxWeightBase(boost); ok = true end
    end)
    pcall(function()
        if p.setMaxWeightBackup then p:setMaxWeightBackup(boost) end
    end)
    pcall(function()
        if p.setMaxWeight then p:setMaxWeight(boost) end
    end)
    return ok
end

local function applyCarryFromInput(raw)
    local p = player()
    if not p then error(text("Error_NoPlayer")) end
    local value = parseCarryInput(raw)
    if not value then error(text("Error_BadCarry")) end
    local data = getModData()
    if data.carryBoostPrev == nil then
        local prev = 8
        pcall(function()
            if p.getMaxWeightBase then prev = p:getMaxWeightBase() or 8 end
        end)
        data.carryBoostPrev = prev
    end
    data.carryBoost = value
    saveModData()
    if not applyCarryBoost(p) then
        error(text("Error_MissingMethod") .. "setMaxWeightBase")
    end
    say(text("Status_MaxCarry") .. tostring(value))
end

local function resetCarryBoost()
    local p = player()
    if not p then error(text("Error_NoPlayer")) end
    local data = getModData()
    local prev = tonumber(data.carryBoostPrev) or 8
    data.carryBoost = nil
    data.carryBoostPrev = nil
    saveModData()
    pcall(function()
        if p.setMaxWeightBase then p:setMaxWeightBase(prev) end
    end)
    say(text("Status_MaxCarryOff") .. tostring(prev))
end

local function reapplyModeState(p)
    p = p or player()
    if not p or not SimpleAdminMenu.modeState then return end
    for setter, val in pairs(SimpleAdminMenu.modeState) do
        if val ~= nil and type(setter) == "string" and string.sub(setter, 1, 3) == "set" then
            setPlayerBool(p, setter, val and true or false)
        end
    end
end

local function repairEquipped()
    local p = player()
    if not p then error(text("Error_NoPlayer")) end
    local inv = p:getInventory()
    if not inv then error(text("Error_NoInventory")) end
    local items = inv:getItems()
    local count = 0
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item and item.setCondition and item.getConditionMax then
            pcall(function()
                item:setCondition(item:getConditionMax())
                count = count + 1
            end)
        end
    end
    say(text("Status_ItemsRepaired") .. count)
end

local function maxAllSkills()
    local p = player()
    if not p then error(text("Error_NoPlayer")) end
    local count = 0
    if PerkFactory and PerkFactory.PerkList then
        local list = PerkFactory.PerkList
        for i = 0, list:size() - 1 do
            local perk = list:get(i)
            if perk and p.getPerkLevel and p.LevelPerk then
                pcall(function()
                    while p:getPerkLevel(perk) < 10 do p:LevelPerk(perk) end
                    if p.getXp and p:getXp() and p:getXp().setXPToLevel then
                        p:getXp():setXPToLevel(perk, p:getPerkLevel(perk))
                    end
                    count = count + 1
                end)
            end
        end
    else
        error(text("Error_SkillsUnavailable"))
    end
    say(text("Status_SkillsMaxed") .. count)
end

local function learnAllRecipes()
    local p = player()
    if not p then error(text("Error_NoPlayer")) end
    local sm = getScriptManager and getScriptManager() or nil
    if not sm or not sm.getAllRecipes then error(text("Error_RecipesUnavailable")) end
    local recipes = sm:getAllRecipes()
    local learned = 0
    for i = 0, recipes:size() - 1 do
        local recipe = recipes:get(i)
        if recipe then
            local known = false
            if p.isRecipeKnown then pcall(function() known = p:isRecipeKnown(recipe) end) end
            if not known and p.learnRecipe then
                local ok = pcall(function() p:learnRecipe(recipe) end)
                if ok then learned = learned + 1 end
            end
        end
    end
    say(text("Status_RecipesLearned") .. learned)
end

local function clearCorpses(radius)
    local p = player()
    if not p then error(text("Error_NoPlayer")) end
    radius = radius or 12
    local px, py, pz = math.floor(p:getX()), math.floor(p:getY()), math.floor(p:getZ())
    local removed = 0
    for x = px - radius, px + radius do
        for y = py - radius, py + radius do
            local sq = getCell():getGridSquare(x, y, pz)
            if sq then
                if sq.getDeadBodys then
                    local bodies = sq:getDeadBodys()
                    if bodies then
                        for i = bodies:size() - 1, 0, -1 do
                            local body = bodies:get(i)
                            if body then
                                pcall(function()
                                    if body.removeFromWorld then body:removeFromWorld() end
                                    if body.removeFromSquare then body:removeFromSquare() end
                                    removed = removed + 1
                                end)
                            end
                        end
                    end
                end
                if sq.getStaticMovingObjects then
                    local objs = sq:getStaticMovingObjects()
                    for i = objs:size() - 1, 0, -1 do
                        local o = objs:get(i)
                        local isBody = false
                        if instanceof then pcall(function() isBody = instanceof(o, "IsoDeadBody") end) end
                        if isBody then
                            pcall(function()
                                if o.removeFromWorld then o:removeFromWorld() end
                                removed = removed + 1
                            end)
                        end
                    end
                end
            end
        end
    end
    say(text("Status_CorpsesCleared") .. removed)
end

local function extinguishFire(radius)
    local p = player()
    if not p then error(text("Error_NoPlayer")) end
    radius = radius or 10
    local px, py, pz = math.floor(p:getX()), math.floor(p:getY()), math.floor(p:getZ())
    local count = 0
    for x = px - radius, px + radius do
        for y = py - radius, py + radius do
            local sq = getCell():getGridSquare(x, y, pz)
            if sq then
                if IsoFireManager and IsoFireManager.RemoveAllOnSquare then
                    pcall(function() IsoFireManager.RemoveAllOnSquare(sq) end)
                    count = count + 1
                elseif sq.stopFire then
                    pcall(function() sq:stopFire() end)
                    count = count + 1
                end
            end
        end
    end
    say(text("Status_FireCleared") .. count)
end

local function unlockDoorsOnSquare(sq)
    if not sq or not sq.getObjects then return 0 end
    local objs = sq:getObjects()
    local unlocked = 0
    for i = 0, objs:size() - 1 do
        local o = objs:get(i)
        local isDoor = false
        if instanceof then
            pcall(function() isDoor = instanceof(o, "IsoDoor") end)
            if not isDoor then
                pcall(function()
                    if instanceof(o, "IsoThumpable") and o.isDoor and o:isDoor() then isDoor = true end
                end)
            end
        end
        if isDoor then
            pcall(function() if o.setLocked then o:setLocked(false) end end)
            pcall(function() if o.setLockedByKey then o:setLockedByKey(false) end end)
            pcall(function() if o.setLockedByPadlock then o:setLockedByPadlock(false) end end)
            unlocked = unlocked + 1
        end
    end
    return unlocked
end

local function unlockCursorDoor()
    local sq = mouseSquare()
    if not sq then error(text("Error_NoSquare")) end
    local unlocked = unlockDoorsOnSquare(sq)
    if unlocked <= 0 then error(text("Error_NoDoor")) end
    say(text("Status_DoorUnlocked") .. unlocked)
end

local function unlockContextDoor(worldobjects)
    local sq = squareFromWorldObjects(worldobjects)
    if not sq then error(text("Error_NoSquare")) end
    local unlocked = unlockDoorsOnSquare(sq)
    if unlocked <= 0 then error(text("Error_NoDoor")) end
    say(text("Status_DoorUnlocked") .. unlocked)
end

local function unlockNearbyDoors(radius)
    local p = player()
    if not p then error(text("Error_NoPlayer")) end
    radius = radius or 8
    local px, py, pz = math.floor(p:getX()), math.floor(p:getY()), math.floor(p:getZ())
    local unlocked = 0
    for x = px - radius, px + radius do
        for y = py - radius, py + radius do
            local sq = getCell():getGridSquare(x, y, pz)
            if sq then unlocked = unlocked + unlockDoorsOnSquare(sq) end
        end
    end
    if unlocked <= 0 then error(text("Error_NoDoor")) end
    say(text("Status_DoorUnlocked") .. unlocked)
end

local function showCoords()
    local p = player()
    if not p then error(text("Error_NoPlayer")) end
    say(string.format("%s%d, %d, %d", text("Status_Coords"), math.floor(p:getX()), math.floor(p:getY()), math.floor(p:getZ())))
end

local function isBaseVehicle(obj)
    if not obj then return false end
    local ok = false
    if instanceof then
        pcall(function() ok = instanceof(obj, "BaseVehicle") end)
        if not ok then pcall(function() ok = instanceof(obj, "IsoVehicle") end) end
    end
    return ok
end

--- Current vehicle, or nearest vehicle within radius (stand next to car is enough).
local function resolveTargetVehicle(radius)
    local p = player()
    if not p then return nil end
    local v = nil
    pcall(function()
        if p.getVehicle then v = p:getVehicle() end
    end)
    if v then return v end
    pcall(function()
        if p.getNearVehicle then v = p:getNearVehicle() end
    end)
    if v then return v end

    radius = radius or 8
    local cell = getCell()
    if not cell then return nil end
    local best, bestDist = nil, radius + 0.01
    pcall(function()
        if cell.getVehicles then
            local list = cell:getVehicles()
            if list and list.size then
                for i = 0, list:size() - 1 do
                    local cand = list:get(i)
                    if cand and p.DistTo then
                        local d = p:DistTo(cand)
                        if d < bestDist then
                            best, bestDist = cand, d
                        end
                    end
                end
            end
        end
    end)
    if best then return best end

    local px, py, pz = math.floor(p:getX()), math.floor(p:getY()), math.floor(p:getZ())
    for x = px - radius, px + radius do
        for y = py - radius, py + radius do
            local sq = cell:getGridSquare(x, y, pz)
            if sq and sq.getMovingObjects then
                local objs = nil
                pcall(function() objs = sq:getMovingObjects() end)
                if objs and objs.size then
                    for i = 0, objs:size() - 1 do
                        local o = objs:get(i)
                        if isBaseVehicle(o) then
                            local d = radius
                            pcall(function() d = p:DistTo(o) end)
                            if d < bestDist then
                                best, bestDist = o, d
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function deleteCurrentVehicle()
    local p = player()
    local v = resolveTargetVehicle(8)
    if not p or not v then error(text("Error_EnterVehicle")) end
    if p.getVehicle and p:getVehicle() == v and p.setVehicle then
        pcall(function() p:setVehicle(nil) end)
    end
    if v.permanentlyRemove then v:permanentlyRemove()
    elseif v.removeFromWorld then v:removeFromWorld()
    else error(text("Error_VehicleDeleteUnavailable")) end
    say(text("Status_VehicleDeleted"))
end

local function fuelVehicle(v)
    v = v or resolveTargetVehicle(8)
    if not v then return false end
    local fueled = false
    if v.setFuelAmount then
        pcall(function() v:setFuelAmount(100) end)
        fueled = true
    end
    if v.getPartById then
        local gas = v:getPartById("GasTank")
        if gas and gas.setContainerContentAmount and gas.getContainerCapacity then
            pcall(function() gas:setContainerContentAmount(gas:getContainerCapacity()) end)
            fueled = true
        end
    end
    return fueled
end

local function giveVehicleKey(quiet)
    local p = player()
    local v = resolveTargetVehicle(8)
    if not p or not v then error(text("Error_EnterVehicle")) end
    local inv = p:getInventory()
    if not inv then error(text("Error_NoInventory")) end

    -- Vanilla mechanic cheat path (handles MP/SP correctly when present).
    if ISVehicleMechanics and ISVehicleMechanics.onCheatGetKey then
        local ok = pcall(function() ISVehicleMechanics.onCheatGetKey(p, v) end)
        if ok then
            local keyId = nil
            if v.getKeyId then pcall(function() keyId = v:getKeyId() end) end
            if not quiet then
                say(text("Status_VehicleKey") .. (keyId ~= nil and (" #" .. tostring(keyId)) or ""))
            end
            return
        end
    end

    local keyId = nil
    if v.getKeyId then pcall(function() keyId = v:getKeyId() end) end

    local key = nil
    local tried = {}

    local function remember(k, via)
        if k then
            key = k
            table.insert(tried, via .. "=ok")
            return true
        end
        table.insert(tried, via .. "=nil")
        return false
    end

    local okCv, createdCv = pcall(function()
        if v.createVehicleKey then return v:createVehicleKey() end
        return nil
    end)
    if okCv then remember(createdCv, "createVehicleKey") else table.insert(tried, "createVehicleKey=err") end

    if not key then
        local okCk, createdCk = pcall(function()
            if v.createKey then return v:createKey() end
            return nil
        end)
        if okCk then remember(createdCk, "createKey") else table.insert(tried, "createKey=err") end
    end

    if (not key) and VehicleUtils and VehicleUtils.createVehicleKey then
        local ok, created = pcall(function() return VehicleUtils.createVehicleKey(v) end)
        if ok then remember(created, "VehicleUtils") else table.insert(tried, "VehicleUtils=err") end
    end

    local keyTypes = { "Base.CarKey", "Base.VehicleKey", "Base.Key" }
    for _, kt in ipairs(keyTypes) do
        if key then break end
        if instanceItem then
            local ok, created = pcall(function() return instanceItem(kt) end)
            if ok and created then remember(created, "instance:" .. kt) end
        end
        if (not key) and InventoryItemFactory and InventoryItemFactory.CreateItem then
            local ok, created = pcall(function() return InventoryItemFactory.CreateItem(kt) end)
            if ok and created then remember(created, "factory:" .. kt) end
        end
    end

    if not key then
        error(text("Error_VehicleKeyUnavailable") .. " [" .. table.concat(tried, ", ") .. "]")
    end

    if keyId ~= nil then
        if key.setKeyId then pcall(function() key:setKeyId(keyId) end) end
        if key.setNumber then pcall(function() key:setNumber(keyId) end) end
    end
    if v.setKeyId and keyId == nil and key.getKeyId then
        pcall(function() v:setKeyId(key:getKeyId()) end)
    end

    local inInv = false
    if key.getContainer then
        local c = nil
        pcall(function() c = key:getContainer() end)
        if c ~= nil then inInv = true end
    end
    if not inInv then
        local okAdd = pcall(function() inv:AddItem(key) end)
        if not okAdd then
            error(text("Error_VehicleKeyUnavailable") .. " (AddItem)")
        end
    end
    if not quiet then
        say(text("Status_VehicleKey") .. (keyId ~= nil and (" #" .. tostring(keyId)) or ""))
    end
end

local function prepVehicle()
    local v = resolveTargetVehicle(8)
    if not v then error(text("Error_EnterVehicle")) end
    repairVehicle(v)
    if not fuelVehicle(v) then error(text("Error_FuelUnavailable")) end
    giveVehicleKey(true)
    say(text("Status_VehicleReady"))
end

local function hotkeyIndex(name)
    for i, h in ipairs(HOTKEY_NAMES) do
        if h == name then return i end
    end
    return 1
end

local function buttonPosIndex(name)
    for i, p in ipairs(BUTTON_POS) do
        if p == name then return i end
    end
    return 1
end

local function uiScaleIndex(name)
    for i, s in ipairs(UI_SCALES) do
        if s == name then return i end
    end
    return 2
end

local function fastReadIndex(mult)
    mult = tonumber(mult) or 1
    for i, m in ipairs(FAST_READ_MULTS) do
        if m == mult then return i end
    end
    return 1
end

local function fastReadLabel(mult)
    mult = tonumber(mult) or 1
    if mult <= 1 then return text("FastRead_Off") end
    return tostring(mult) .. "x"
end

--- Apply Fast Reading (like FastReading 10x mod), without replacing vanilla ISReadABook.
local function applyFastReading()
    local s = getSettings()
    local mult = tonumber(s.fastReadingMult) or 1
    if mult < 1 then mult = 1 end

    if SandboxVars then
        if SimpleAdminMenu._baseMinutesPerPage == nil then
            local cur = SandboxVars.MinutesPerPage
            if cur == nil then cur = 2.0 end
            SimpleAdminMenu._baseMinutesPerPage = tonumber(cur) or 2.0
        end
        if mult <= 1 then
            SandboxVars.MinutesPerPage = SimpleAdminMenu._baseMinutesPerPage
        else
            SandboxVars.MinutesPerPage = math.max(0.01, SimpleAdminMenu._baseMinutesPerPage / mult)
        end
    end

    if SimpleAdminMenu._fastReadHooked then return end
    if type(ISReadABook) ~= "table" or not ISReadABook.new then return end

    local oldNew = ISReadABook.new
    function ISReadABook:new(character, item, time)
        local o = oldNew(self, character, item, time)
        local m = tonumber(getSettings().fastReadingMult) or 1
        if m > 1 and o and type(o.maxTime) == "number" and o.maxTime > 1 then
            local usedSandbox = false
            if SandboxVars and o.minutesPerPage ~= nil and SandboxVars.MinutesPerPage ~= nil then
                if math.abs((tonumber(o.minutesPerPage) or 0) - (tonumber(SandboxVars.MinutesPerPage) or 0)) < 0.001 then
                    usedSandbox = true
                end
            end
            if not usedSandbox then
                o.maxTime = math.max(1, o.maxTime / m)
            end
        end
        return o
    end
    SimpleAdminMenu._fastReadHooked = true
    log(text("Log_FastReadHooked"))
end

local function buttonScreenPos()
    local s = getSettings()
    local core = getCore()
    local sw = core and core:getScreenWidth() or 1280
    local sh = core and core:getScreenHeight() or 720
    local bw, bh = 120, 40
    local pos = s.buttonPos or "bottomLeft"
    if pos == "midLeft" then return 16, math.floor(sh * 0.45), bw, bh end
    if pos == "bottomRight" then return sw - bw - 16, sh - bh - 80, bw, bh end
    return 16, sh - bh - 100, bw, bh
end

function SimpleAdminMenu.applyButtonLayout()
    local s = getSettings()
    if not s.showButton then
        if SimpleAdminMenu.openButton then
            SimpleAdminMenu.openButton:setVisible(false)
            SimpleAdminMenu.openButton:removeFromUIManager()
            SimpleAdminMenu.openButton = nil
        end
        return
    end
    local x, y, w, h = buttonScreenPos()
    if SimpleAdminMenu.openButton then
        SimpleAdminMenu.openButton:setX(x)
        SimpleAdminMenu.openButton:setY(y)
        SimpleAdminMenu.openButton:setWidth(w)
        SimpleAdminMenu.openButton:setHeight(h)
        SimpleAdminMenu.openButton:setVisible(true)
    else
        SimpleAdminMenu.createButton()
    end
end

function SimpleAdminMenu:new(x, y, w, h)
    local o = ISCollapsableWindow.new(self, x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = { r = COLOR.panelBorder.r, g = COLOR.panelBorder.g, b = COLOR.panelBorder.b, a = COLOR.panelBorder.a }
    o.backgroundColor = { r = COLOR.panelBg.r, g = COLOR.panelBg.g, b = COLOR.panelBg.b, a = COLOR.panelBg.a }
    o.resizable = false
    o.pin = true
    o.categoryIndex = 1
    o.vehicleIndex = 1
    o.objectIndex = 1
    o.selectedItemEntry = nil
    o.filteredItems = {}
    o.tabIndex = SimpleAdminMenu.activeTab or 1
    o.toggleButtons = {}
    o.tabButtons = {}
    o.tabPages = {}
    o.statTick = 0
    return o
end

function SimpleAdminMenu:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle(text("Title"))
end

function SimpleAdminMenu:close()
    self:setVisible(false)
    self:removeFromUIManager()
    SimpleAdminMenu.instance = nil
end

function SimpleAdminMenu:addLabel(t, x, y, big, color)
    local font = UIFont.Medium
    if not big then font = UIFont.Small end
    local c = color or COLOR.white
    local h = big and 24 or 20
    local l = ISLabel:new(x, y, h, tostring(t), c.r, c.g, c.b, c.a or 1, font, true)
    l:initialise()
    self:addChild(l)
    return l
end

function SimpleAdminMenu:addBtn(t, x, y, w, h, fn, kind)
    local b = ISButton:new(x, y, w, h, t, self, function()
        safe(t, fn)
        if self.refreshToggleStyles then self:refreshToggleStyles() end
        if self.updateLabels then self:updateLabels() end
        if self.refreshSettingsLabels then self:refreshSettingsLabels() end
    end)
    b:initialise()
    b:instantiate()
    styleByKind(b, kind)
    self:addChild(b)
    return b
end

function SimpleAdminMenu:addToggleBtn(t, x, y, w, h, getter, setter)
    local key = setter or getter or t
    if SimpleAdminMenu.modeState[key] == nil then
        SimpleAdminMenu.modeState[key] = getToggle(getter, nil)
    end
    local b = self:addBtn(t, x, y, w, h, function()
        toggle(t, getter, setter)
    end)
    table.insert(self.toggleButtons, { btn = b, getter = getter, setter = setter, key = key, label = t })
    return b
end

function SimpleAdminMenu:getSearchText()
    if self.searchBox and self.searchBox.getText then
        return string.lower(tostring(self.searchBox:getText() or ""))
    end
    return ""
end

function SimpleAdminMenu:getVisibleItems()
    local q = self:getSearchText()
    if q ~= "" then
        local filtered = {}
        for _, entry in ipairs(buildFlatItems()) do
            local nameKey = entry[1]
            local display = entry[3] and tostring(nameKey) or text(nameKey)
            local name = string.lower(display)
            local id = string.lower(entry[2] or "")
            if string.find(name, q, 1, true) or string.find(id, q, 1, true) then
                table.insert(filtered, entry)
            end
        end
        self.filteredItems = filtered
        return filtered
    end
    local c = SimpleAdminMenu.categoryNames[self.categoryIndex] or "Food"
    if c == "Favorites" then return favoriteEntries() end
    return SimpleAdminMenu.items[c] or {}
end

function SimpleAdminMenu:itemDisplayName(entry)
    if not entry then return text("None") end
    if entry[3] then return tostring(entry[1]) end
    return text(entry[1])
end

function SimpleAdminMenu:populateItemList(keepSelection)
    if not self.itemList then return end
    local prevId = nil
    if keepSelection then
        local cur = self:getSelectedItem()
        if cur then prevId = cur[2] end
    end
    self.itemList:clear()
    local list = self:getVisibleItems()
    local selectIndex = 1
    for i, entry in ipairs(list) do
        local label = self:itemDisplayName(entry)
        self.itemList:addItem(label, entry)
        if prevId and entry[2] == prevId then selectIndex = i end
    end
    if #list > 0 then
        self.itemList.selected = selectIndex
        local row = self.itemList.items[selectIndex]
        if row then self.selectedItemEntry = row.item end
    else
        self.itemList.selected = 0
        self.selectedItemEntry = nil
    end
    self:refreshItemPreview()
end

function SimpleAdminMenu:drawItemListItem(y, item, alt)
    local list = self
    local h = list.itemheight or 40
    local w = list:getWidth()
    local padL = 6
    local iconSize = 28
    local entry = item.item
    local selected = list.selected == item.index

    if selected then
        list:drawRect(0, y, w, h - 1, 0.62, COLOR.tabActive.r, COLOR.tabActive.g, COLOR.tabActive.b)
        list:drawRect(0, y, 3, h - 1, 1, COLOR.accentBorder.r, COLOR.accentBorder.g, COLOR.accentBorder.b)
    elseif alt then
        list:drawRect(0, y, w, h - 1, 0.22, COLOR.card.r, COLOR.card.g, COLOR.card.b)
    end
    list:drawRectBorder(0, y, w, h, 0.40, COLOR.cardBorder.r, COLOR.cardBorder.g, COLOR.cardBorder.b)

    local tex = nil
    if entry and entry[2] then tex = getItemTexture(entry[2]) end
    local textX = padL
    if tex then
        list:drawTextureScaledAspect(tex, padL, y + math.floor((h - iconSize) / 2), iconSize, iconSize, 1, 1, 1, 1)
        textX = padL + iconSize + 8
    end

    local name = ""
    local id = ""
    if entry then
        if entry[3] then name = tostring(entry[1]) else name = text(entry[1]) end
        id = tostring(entry[2] or "")
    else
        name = tostring(item.text or "")
    end

    local font = list.font or UIFont.Medium
    local maxW = w - textX - 14
    if list.vscroll and list.vscroll:getIsVisible() then maxW = maxW - 14 end
    local nameDraw = fitTextWidth(name, maxW, font)
    local idDraw = fitTextWidth(id, maxW, UIFont.Small)
    list:drawText(nameDraw, textX, y + 3, 1, 1, 1, 1, font)
    list:drawText(idDraw, textX, y + 20, 0.70, 0.70, 0.66, 1, UIFont.Small)
    return y + h
end

function SimpleAdminMenu:refreshItemPreview()
    if not self.itemPreview then return end
    local entry = self:getSelectedItem()
    local tex = nil
    if entry and entry[2] then tex = getItemTexture(entry[2]) end
    self.itemPreview.texture = tex
    if self.itemPreview.setVisible then
        self.itemPreview:setVisible(self.tabIndex == 2)
    end
end

function SimpleAdminMenu:onItemListClick(item)
    self.selectedItemEntry = item
    self:refreshItemPreview()
    self:updateLabels()
end

function SimpleAdminMenu:getSelectedItem()
    if self.itemList and self.itemList.items and self.itemList.selected and self.itemList.selected > 0 then
        local row = self.itemList.items[self.itemList.selected]
        if row and row.item then return row.item end
    end
    return self.selectedItemEntry
end

function SimpleAdminMenu:populateWaypointList()
    if not self.waypointList then return end
    self.waypointList:clear()
    local list = getWaypoints()
    for i, wp in ipairs(list) do
        local label = string.format("%s  (%d, %d, %d)", tostring(wp.name or text("None")), wp.x or 0, wp.y or 0, wp.z or 0)
        self.waypointList:addItem(label, i)
    end
    if #list > 0 then
        if not self.waypointList.selected or self.waypointList.selected < 1 or self.waypointList.selected > #list then
            self.waypointList.selected = 1
        end
    else
        self.waypointList.selected = 0
    end
end

function SimpleAdminMenu:getSelectedWaypointIndex()
    if not self.waypointList or not self.waypointList.selected or self.waypointList.selected < 1 then return nil end
    local row = self.waypointList.items[self.waypointList.selected]
    if row and row.item then return row.item end
    return self.waypointList.selected
end

function SimpleAdminMenu:onWaypointListClick()
    self:updateLabels()
end

function SimpleAdminMenu:setTab(index)
    self.tabIndex = index
    SimpleAdminMenu.activeTab = index
    for i, btn in ipairs(self.tabButtons) do
        if i == index then
            styleButton(btn, COLOR.tabActive, COLOR.accentBorder, COLOR.tabHover)
        else
            styleButton(btn, COLOR.tabIdle, COLOR.btnBorder, COLOR.tabHover)
        end
    end
    for i, page in ipairs(self.tabPages) do
        local visible = (i == index)
        for _, child in ipairs(page) do
            if child and child.setVisible then child:setVisible(visible) end
        end
    end
    if index == 2 then self:populateItemList(true) end
    if index == 4 then self:populateWaypointList() end
    if index == 6 then self:refreshSettingsLabels() end
    self:updateLabels()
    self:refreshPlayerStats()
end

function SimpleAdminMenu:track(page, child)
    table.insert(self.tabPages[page], child)
    return child
end

function SimpleAdminMenu:refreshToggleStyles()
    for _, entry in ipairs(self.toggleButtons) do
        local on = false
        if entry.isOn then
            on = entry.isOn() and true or false
        else
            on = getToggle(entry.getter, entry.key or entry.setter)
        end
        if on then
            styleButton(entry.btn, COLOR.on, COLOR.onBorder, COLOR.on)
            if entry.btn and entry.btn.setTitle then entry.btn:setTitle(entry.label .. text("Suffix_On")) end
        else
            styleByKind(entry.btn, entry.btn._samKind or "normal")
            if entry.btn and entry.btn.setTitle then entry.btn:setTitle(entry.label .. text("Suffix_Off")) end
        end
    end
    syncAutoRepairButton(self.autoRepairBtn)
    syncAutoHealButton(self.autoHealBtn)
end

function SimpleAdminMenu:buildStatusText()
    local parts = {}
    if SimpleAdminMenu.autoHeal then table.insert(parts, text("Chip_AutoHeal")) end
    if getToggle("isBuildCheat", "setBuildCheat") then table.insert(parts, text("Chip_Build")) end
    if SimpleAdminMenu.keepVehicleRepaired then table.insert(parts, text("Chip_AutoRepair")) end
    if #parts == 0 then return text("Status_NoModes") end
    return text("Status_ActiveModes") .. table.concat(parts, " · ")
end

function SimpleAdminMenu:refreshPlayerStats()
    if not self.statHealth then return end
    local p = player()
    if not p then
        labelText(self.statHealth, text("Stat_Health") .. "-")
        labelText(self.statInfect, text("Stat_Infect") .. "-")
        labelText(self.statWeight, text("Stat_Weight") .. "-")
        labelText(self.statCoords, text("Stat_Coords") .. "-")
        labelText(self.statVehicle, text("Stat_Vehicle") .. "-")
        return
    end

    local health = "-"
    local infect = text("State_No")
    local b = nil
    pcall(function()
        if p.getBodyDamage then b = p:getBodyDamage() end
    end)
    if b then
        pcall(function()
            if b.getOverallBodyHealth then
                health = string.format("%.0f", b:getOverallBodyHealth())
            elseif b.getHealth then
                health = string.format("%.0f", b:getHealth())
            end
        end)
        local infected = false
        pcall(function()
            if b.isInfected then infected = b:isInfected() end
        end)
        if infected then infect = text("State_Yes") end
    end

    local weight = "-"
    pcall(function()
        if p.getInventoryWeight and p.getMaxWeight then
            weight = string.format("%.1f / %.1f", p:getInventoryWeight(), p:getMaxWeight())
            local boost = getModData().carryBoost
            if boost then weight = weight .. " [" .. text("Chip_CarryBoost") .. "]" end
        end
    end)
    local coords = string.format("%d, %d, %d", math.floor(p:getX()), math.floor(p:getY()), math.floor(p:getZ()))
    local vehText = text("State_None")
    pcall(function()
        if p.getVehicle and p:getVehicle() then
            local v = p:getVehicle()
            local name = "Vehicle"
            if v.getScript and v:getScript() and v:getScript().getName then
                name = v:getScript():getName()
            end
            vehText = tostring(name)
        end
    end)

    labelText(self.statHealth, text("Stat_Health") .. health)
    labelText(self.statInfect, text("Stat_Infect") .. infect)
    labelText(self.statWeight, text("Stat_Weight") .. weight)
    labelText(self.statCoords, text("Stat_Coords") .. coords)
    labelText(self.statVehicle, text("Stat_Vehicle") .. vehText)
end

function SimpleAdminMenu:refreshSettingsLabels()
    local s = getSettings()
    labelText(self.setHotkeyLabel, text("Settings_Hotkey") .. tostring(s.hotkey))
    labelText(self.setButtonPosLabel, text("Settings_ButtonPos") .. text("Pos_" .. tostring(s.buttonPos)))
    labelText(self.setScaleLabel, text("Settings_UiScale") .. text("Scale_" .. tostring(s.uiScale)))
    labelText(self.setFastReadLabel, text("Settings_FastReading") .. fastReadLabel(s.fastReadingMult))
    labelText(self.setFavCountLabel, text("Settings_FavoritesCount") .. tostring(#getFavorites()))
    if self.showButtonTick then
        self.showButtonTick.selected[1] = s.showButton and true or false
    end
end

function SimpleAdminMenu:updateLabels()
    local item = self:getSelectedItem()
    local list = self:getVisibleItems()
    local q = self:getSearchText()
    if q ~= "" then
        labelText(self.categoryLabel, text("Label_Search") .. q .. "  (" .. tostring(#list) .. ")")
    else
        local c = SimpleAdminMenu.categoryNames[self.categoryIndex] or "Food"
        labelText(self.categoryLabel, text("Label_Category") .. text(SimpleAdminMenu.categoryLabels[c] or "None") .. "  (" .. tostring(#list) .. ")")
    end
    if item then
        local resolved = resolveItemType(item[2])
        local idText = tostring(item[2])
        if resolved ~= item[2] then idText = idText .. " -> " .. resolved end
        labelText(self.itemLabel, text("Label_Item") .. self:itemDisplayName(item) .. "  [" .. idText .. "]")
    else
        labelText(self.itemLabel, text("Label_Item") .. text("None"))
    end
    self:refreshItemPreview()
    local veh = SimpleAdminMenu.vehicles[self.vehicleIndex] or { "None", "" }
    local obj = SimpleAdminMenu.mapObjects[self.objectIndex] or { "None", "" }
    labelText(self.statusLabel, self:buildStatusText())
    labelText(self.vehicleLabel, text("Label_Vehicle") .. text(veh[1]) .. "  (" .. tostring(self.vehicleIndex) .. "/" .. tostring(#SimpleAdminMenu.vehicles) .. ")")
    labelText(self.objectLabel, text("Label_Object") .. text(obj[1]) .. "  (" .. tostring(self.objectIndex) .. "/" .. tostring(#SimpleAdminMenu.mapObjects) .. ")")
    labelText(self.carModeLabel, text("Label_AutoRepair") .. enabledText(SimpleAdminMenu.keepVehicleRepaired))
    local wpIndex = self:getSelectedWaypointIndex()
    local wps = getWaypoints()
    if wpIndex and wps[wpIndex] then
        local wp = wps[wpIndex]
        labelText(self.waypointLabel, text("Label_Waypoint") .. tostring(wp.name) .. string.format(" (%d,%d,%d)", wp.x, wp.y, wp.z))
    else
        labelText(self.waypointLabel, text("Label_Waypoint") .. text("None"))
    end
    self:refreshToggleStyles()
    self:refreshPlayerStats()
end

function SimpleAdminMenu:update()
    if ISCollapsableWindow.update then ISCollapsableWindow.update(self) end
    self.statTick = (self.statTick or 0) + 1
    if self.statTick >= 20 then
        self.statTick = 0
        if self.tabIndex == 1 then
            pcall(function()
                self:refreshPlayerStats()
                labelText(self.statusLabel, self:buildStatusText())
                self:refreshToggleStyles()
            end)
        end
    end
end

function SimpleAdminMenu:prerender()
    ISCollapsableWindow.prerender(self)
    local th = 0
    if self.titleBarHeight then th = self:titleBarHeight() end
    local tabH = 44
    local tabBottom = th + tabH

    -- Left brass edge + tab bar wash.
    self:drawRect(0, 0, 3, self.height, 0.85, COLOR.accentBorder.r, COLOR.accentBorder.g, COLOR.accentBorder.b)
    self:drawRect(0, th, self.width, tabH, COLOR.tabBar.a, COLOR.tabBar.r, COLOR.tabBar.g, COLOR.tabBar.b)
    self:drawRect(0, tabBottom, self.width, 2, 0.95, COLOR.accentBorder.r, COLOR.accentBorder.g, COLOR.accentBorder.b)

    local active = self.tabButtons and self.tabButtons[self.tabIndex]
    if active then
        self:drawRect(active:getX(), tabBottom - 3, active:getWidth(), 3, 1, COLOR.header.r, COLOR.header.g, COLOR.header.b)
    end

    -- Soft content cards (player tab status / tools).
    if self.tabIndex == 1 then
        local function drawCard(card)
            if not card then return end
            self:drawRect(card.x, card.y, card.w, card.h, COLOR.card.a, COLOR.card.r, COLOR.card.g, COLOR.card.b)
            self:drawRectBorder(card.x, card.y, card.w, card.h, COLOR.cardBorder.a, COLOR.cardBorder.r, COLOR.cardBorder.g, COLOR.cardBorder.b)
        end
        drawCard(self.cardStatus)
        drawCard(self.cardTools)
    end
end

function SimpleAdminMenu:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = 16
    if self.titleBarHeight then th = self:titleBarHeight() end
    local pad = 18
    local tabY, tabH, tabGap = th + 6, 32, 4
    local tabCount = #SimpleAdminMenu.tabs
    local tabW = math.floor((self.width - pad * 2 - tabGap * (tabCount - 1)) / tabCount)
    local colGap = 12
    local bw = math.floor((self.width - pad * 2 - colGap) / 2)
    local x1, x2 = pad, pad + bw + colGap
    local bh, gap = 34, 8
    local page, y

    for i, key in ipairs(SimpleAdminMenu.tabs) do
        local bx = pad + (i - 1) * (tabW + tabGap)
        local btn = self:addBtn(text(key), bx, tabY, tabW, tabH, function()
            self:setTab(i)
        end, "tab")
        self.tabButtons[i] = btn
        self.tabPages[i] = {}
    end

    local contentY = th + 52
    self.statusLabel = self:addLabel("", pad, contentY, false, COLOR.header)
    contentY = contentY + 24

    -- Player
    page = 1
    local cardPad = 10
    local statusTop = contentY
    self:track(page, self:addLabel(text("Section_PlayerStatus"), pad + cardPad, contentY + 8, true, COLOR.header))
    y = contentY + 34
    self.statHealth = self:track(page, self:addLabel("", pad + cardPad, y, false, COLOR.white))
    self.statInfect = self:track(page, self:addLabel("", x2, y, false, COLOR.white))
    y = y + 20
    self.statWeight = self:track(page, self:addLabel("", pad + cardPad, y, false, COLOR.muted))
    self.statVehicle = self:track(page, self:addLabel("", x2, y, false, COLOR.muted))
    y = y + 20
    self.statCoords = self:track(page, self:addLabel("", pad + cardPad, y, false, COLOR.header))
    y = y + 28
    self.cardStatus = {
        x = pad - 2,
        y = statusTop,
        w = self.width - pad * 2 + 4,
        h = y - statusTop + 4,
    }

    local toolsTop = y + 8
    self:track(page, self:addLabel(text("Section_PlayerTools"), pad + cardPad, toolsTop + 8, true, COLOR.header))
    y = toolsTop + 32
    self:track(page, self:addBtn(text("Button_HealPlayer"), x1, y, bw, bh, healPlayer, "accent"))
    self:track(page, self:addBtn(text("Button_RefillNeeds"), x2, y, bw, bh, refillNeeds, "accent"))
    y = y + bh + gap
    self.autoHealBtn = self:track(page, self:addBtn(text("Button_AutoHealOff"), x1, y, bw * 2 + colGap, bh, function()
        toggleAutoHeal()
        syncAutoHealButton(self.autoHealBtn)
        self:updateLabels()
    end, "accent"))
    syncAutoHealButton(self.autoHealBtn)
    y = y + bh + gap
    self:track(page, self:addLabel(text("Label_CarryHint"), pad + cardPad, y, false, COLOR.muted))
    y = y + 18
    local carryDefault = tostring(getModData().carryBoost or 50)
    self.carryBox = ISTextEntryBox:new(carryDefault, x1, y, bw, bh)
    self.carryBox:initialise()
    self.carryBox:instantiate()
    if self.carryBox.setOnlyNumbers then self.carryBox:setOnlyNumbers(true) end
    self:addChild(self.carryBox)
    self:track(page, self.carryBox)
    local halfCarry = math.floor((bw - 8) / 2)
    self:track(page, self:addBtn(text("Button_ApplyCarry"), x2, y, halfCarry, bh, function()
        local raw = self.carryBox and self.carryBox:getText() or ""
        applyCarryFromInput(raw)
        if self.carryBox and getModData().carryBoost then
            self.carryBox:setText(tostring(getModData().carryBoost))
        end
        self:refreshPlayerStats()
    end, "accent"))
    self:track(page, self:addBtn(text("Button_ResetCarry"), x2 + halfCarry + 8, y, halfCarry, bh, function()
        resetCarryBoost()
        if self.carryBox then self.carryBox:setText("50") end
        self:refreshPlayerStats()
    end))
    y = y + bh + gap
    self:track(page, self:addBtn(text("Button_RepairItems"), x1, y, bw * 2 + colGap, bh, repairEquipped))
    y = y + bh + gap
    self:track(page, self:addBtn(text("Button_KillNearby"), x1, y, bw, bh, function() killNearby(6) end, "danger"))
    self:track(page, self:addBtn(text("Button_KillWide"), x2, y, bw, bh, function() killNearby(20) end, "danger"))
    y = y + bh + gap
    self:track(page, self:addBtn(text("Button_KillCursor"), x1, y, bw, bh, killCursor, "danger"))
    self:track(page, self:addBtn(text("Button_Teleport"), x2, y, bw, bh, teleportToCursor, "accent"))
    y = y + bh + 12
    self.cardTools = {
        x = pad - 2,
        y = toolsTop,
        w = self.width - pad * 2 + 4,
        h = y - toolsTop,
    }

    -- Items
    page = 2
    self:track(page, self:addLabel(text("Section_ItemSpawner"), pad, contentY, true, COLOR.header))
    y = contentY + 24
    self:track(page, self:addLabel(text("Label_SearchHint"), pad, y, false, COLOR.muted))
    y = y + 20
    local searchW = self.width - pad * 2 - 220
    self.searchBox = ISTextEntryBox:new("", pad, y, searchW, 28)
    self.searchBox:initialise(); self.searchBox:instantiate()
    self:addChild(self.searchBox); self:track(page, self.searchBox)
    self:track(page, self:addBtn(text("Button_Search"), pad + searchW + 8, y, 100, 28, function()
        self:populateItemList(false)
    end, "accent"))
    self:track(page, self:addBtn(text("Button_ClearSearch"), pad + searchW + 116, y, 100, 28, function()
        if self.searchBox then self.searchBox:setText("") end
        self:populateItemList(false)
    end))
    y = y + 34
    self:track(page, self:addLabel(text("Label_CustomId"), pad, y, false, COLOR.muted))
    y = y + 20
    -- Keep custom ID spawn (needed for mod items); drop "favorite this ID" (use list favorites).
    local customBtnW = 208
    local customBoxW = self.width - pad * 2 - customBtnW - 8
    self.customIdBox = ISTextEntryBox:new("Base.", pad, y, customBoxW, 28)
    self.customIdBox:initialise(); self.customIdBox:instantiate()
    self:addChild(self.customIdBox); self:track(page, self.customIdBox)
    self:track(page, self:addBtn(text("Button_SpawnCustom"), pad + customBoxW + 8, y, customBtnW, 28, function()
        local id = self.customIdBox and self.customIdBox:getText() or ""
        id = tostring(id):gsub("^%s+", ""):gsub("%s+$", "")
        if id == "" or id == "Base." then error(text("Error_BadItemId")) end
        local added = spawnItemType(id, 1)
        say(text("Status_SpawnedItem") .. id .. " x" .. tostring(added))
    end, "accent"))
    y = y + 36
    local previewSize = 52
    self.itemPreview = ISImage:new(pad, y, previewSize, previewSize, nil)
    self.itemPreview:initialise()
    self.itemPreview:instantiate()
    self.itemPreview.scaledWidth = previewSize
    self.itemPreview.scaledHeight = previewSize
    self:addChild(self.itemPreview)
    self:track(page, self.itemPreview)
    self.categoryLabel = self:track(page, self:addLabel("", pad + previewSize + 10, y + 4, false, COLOR.muted))
    self.itemLabel = self:track(page, self:addLabel("", pad + previewSize + 10, y + 24, false, COLOR.white))
    y = y + previewSize + 10
    local half = math.floor((bw - 8) / 2)
    self:track(page, self:addBtn(text("Button_PrevCategory"), x1, y, half, bh, function()
        self.categoryIndex = cycle(self.categoryIndex, #SimpleAdminMenu.categoryNames, -1)
        if self.searchBox then self.searchBox:setText("") end
        self:populateItemList(false)
    end))
    self:track(page, self:addBtn(text("Button_NextCategory"), x1 + half + 8, y, half, bh, function()
        self.categoryIndex = cycle(self.categoryIndex, #SimpleAdminMenu.categoryNames, 1)
        if self.searchBox then self.searchBox:setText("") end
        self:populateItemList(false)
    end))
    self:track(page, self:addBtn(text("Button_AddFavorite"), x2, y, half, bh, function()
        local e = self:getSelectedItem()
        if not e then error(text("Error_NoItem")) end
        local favs = getFavorites()
        for _, f in ipairs(favs) do
            if (f.type or f[2]) == e[2] then error(text("Error_FavoriteExists")) end
        end
        table.insert(favs, { label = self:itemDisplayName(e), type = e[2] })
        saveModData()
        say(text("Status_FavoriteAdded") .. self:itemDisplayName(e))
        self:populateItemList(true)
        self:refreshSettingsLabels()
    end, "accent"))
    self:track(page, self:addBtn(text("Button_RemoveFavorite"), x2 + half + 8, y, half, bh, function()
        local e = self:getSelectedItem()
        if not e then error(text("Error_NoItem")) end
        local favs = getFavorites()
        local removed = false
        for i = #favs, 1, -1 do
            if (favs[i].type or favs[i][2]) == e[2] then
                table.remove(favs, i)
                removed = true
            end
        end
        if not removed then error(text("Error_FavoriteMissing")) end
        saveModData()
        say(text("Status_FavoriteRemoved") .. self:itemDisplayName(e))
        self:populateItemList(false)
        self:refreshSettingsLabels()
    end, "danger"))
    y = y + bh + 8
    local listH = math.max(180, self.height - y - 90)
    local listW = self.width - pad * 2
    self.itemList = ISScrollingListBox:new(pad, y, listW, listH)
    self.itemList:initialise(); self.itemList:instantiate()
    self.itemList.itemheight = 40
    self.itemList.selected = 0
    self.itemList.font = UIFont.Medium
    self.itemList.drawBorder = true
    self.itemList.backgroundColor = copyColor(COLOR.card, 0.96)
    self.itemList.borderColor = copyColor(COLOR.accentBorder, 0.88)
    self.itemList.doDrawItem = SimpleAdminMenu.drawItemListItem
    self.itemList:setOnMouseDownFunction(self, self.onItemListClick)
    self:addChild(self.itemList); self:track(page, self.itemList)
    y = y + listH + 10
    local function spawnCount(n)
        local e = self:getSelectedItem()
        if not e then error(text("Error_NoItem")) end
        local added = spawnItemType(e[2], n)
        say(text("Status_SpawnedItem") .. self:itemDisplayName(e) .. " x" .. tostring(added))
    end
    local third = math.floor((listW - 16) / 3)
    self:track(page, self:addBtn(text("Button_SpawnSelected"), pad, y, third, bh, function() spawnCount(1) end, "accent"))
    self:track(page, self:addBtn(text("Button_SpawnFive"), pad + third + 8, y, third, bh, function() spawnCount(5) end))
    self:track(page, self:addBtn(text("Button_SpawnTen"), pad + (third + 8) * 2, y, third, bh, function() spawnCount(10) end))
    self:populateItemList(false)

    -- Vehicles
    page = 3
    self:track(page, self:addLabel(text("Section_VehicleTools"), pad, contentY, true, COLOR.header))
    y = contentY + 28
    self.vehicleLabel = self:track(page, self:addLabel("", pad, y, false, COLOR.white))
    self.carModeLabel = self:track(page, self:addLabel("", pad, y + 22, false, COLOR.muted))
    y = y + 52
    self:track(page, self:addBtn(text("Button_PrevVehicle"), x1, y, bw, bh, function()
        self.vehicleIndex = cycle(self.vehicleIndex, #SimpleAdminMenu.vehicles, -1)
    end))
    self:track(page, self:addBtn(text("Button_NextVehicle"), x2, y, bw, bh, function()
        self.vehicleIndex = cycle(self.vehicleIndex, #SimpleAdminMenu.vehicles, 1)
    end))
    y = y + bh + gap
    self:track(page, self:addBtn(text("Button_SpawnVehicle"), x1, y, bw, bh, function()
        local e = SimpleAdminMenu.vehicles[self.vehicleIndex]
        local sq = nearSquare()
        if not e or not sq then error(text("Error_NoVehicleSquare")) end
        if addVehicleDebug then addVehicleDebug(e[2], nil, nil, sq)
        elseif addVehicle then addVehicle(e[2], sq:getX(), sq:getY(), sq:getZ())
        else error(text("Error_VehicleSpawnUnavailable")) end
        say(text("Status_SpawnedVehicle") .. text(e[1]))
    end, "accent"))
    self:track(page, self:addBtn(text("Button_RepairVehicle"), x2, y, bw, bh, function()
        local v = resolveTargetVehicle(8)
        if not v then error(text("Error_EnterVehicle")) end
        repairVehicle(v)
        say(text("Status_VehicleRepaired"))
    end, "accent"))
    y = y + bh + gap
    self.autoRepairBtn = self:track(page, self:addBtn(text("Button_AutoRepairOff"), x1, y, bw, bh, function()
        SimpleAdminMenu.keepVehicleRepaired = not SimpleAdminMenu.keepVehicleRepaired
        syncAutoRepairButton(self.autoRepairBtn)
        say(text("Label_AutoRepair") .. enabledText(SimpleAdminMenu.keepVehicleRepaired))
    end))
    syncAutoRepairButton(self.autoRepairBtn)
    self:track(page, self:addBtn(text("Button_FuelVehicle"), x2, y, bw, bh, function()
        if not fuelVehicle() then error(text("Error_FuelUnavailable")) end
        say(text("Status_Fueled"))
    end))
    y = y + bh + gap
    self:track(page, self:addBtn(text("Button_VehicleKey"), x1, y, bw, bh, function() giveVehicleKey(false) end, "accent"))
    self:track(page, self:addBtn(text("Button_DeleteVehicle"), x2, y, bw, bh, deleteCurrentVehicle, "danger"))
    y = y + bh + gap
    self:track(page, self:addBtn(text("Button_PrepVehicle"), x1, y, bw * 2 + colGap, bh, prepVehicle, "accent"))

    -- World
    page = 4
    self:track(page, self:addLabel(text("Section_Waypoints"), pad, contentY, true, COLOR.header))
    y = contentY + 26
    self:track(page, self:addLabel(text("Label_WaypointName"), pad, y, false, COLOR.muted))
    y = y + 20
    local nameW = math.floor(bw * 0.95)
    self.waypointNameBox = ISTextEntryBox:new(text("Waypoint_DefaultName"), pad, y, nameW, 28)
    self.waypointNameBox:initialise(); self.waypointNameBox:instantiate()
    self:addChild(self.waypointNameBox); self:track(page, self.waypointNameBox)
    local halfBtn = math.floor((bw - 8) / 2)
    self:track(page, self:addBtn(text("Button_SaveWaypoint"), x2, y, halfBtn, 28, function()
        local p = player()
        if not p then error(text("Error_NoPlayer")) end
        local name = self.waypointNameBox and self.waypointNameBox:getText() or ""
        if name == "" then name = text("Waypoint_DefaultName") end
        local list = getWaypoints()
        table.insert(list, { name = name, x = math.floor(p:getX()), y = math.floor(p:getY()), z = math.floor(p:getZ()) })
        saveModData()
        self:populateWaypointList()
        if self.waypointList then self.waypointList.selected = #list end
        say(text("Status_WaypointSaved") .. name)
    end, "accent"))
    self:track(page, self:addBtn(text("Button_DeleteWaypoint"), x2 + halfBtn + 8, y, halfBtn, 28, function()
        local idx = self:getSelectedWaypointIndex()
        local list = getWaypoints()
        if not idx or not list[idx] then error(text("Error_NoWaypoint")) end
        local name = list[idx].name
        table.remove(list, idx)
        saveModData()
        self:populateWaypointList()
        say(text("Status_WaypointDeleted") .. tostring(name))
    end, "danger"))
    y = y + 38
    self.waypointLabel = self:track(page, self:addLabel("", pad, y, false, COLOR.white))
    y = y + 20
    self.waypointList = ISScrollingListBox:new(pad, y, self.width - pad * 2, 88)
    self.waypointList:initialise(); self.waypointList:instantiate()
    self.waypointList.itemheight = 28
    self.waypointList.selected = 0
    self.waypointList.font = UIFont.Medium
    self.waypointList.drawBorder = true
    self.waypointList.backgroundColor = { r = 0.10, g = 0.11, b = 0.12, a = 0.95 }
    self.waypointList.borderColor = { r = COLOR.accentBorder.r, g = COLOR.accentBorder.g, b = COLOR.accentBorder.b, a = 0.85 }
    self.waypointList:setOnMouseDownFunction(self, self.onWaypointListClick)
    self:addChild(self.waypointList); self:track(page, self.waypointList)
    y = y + 98
    self:track(page, self:addBtn(text("Button_TeleportWaypoint"), x1, y, bw, bh, function()
        local idx = self:getSelectedWaypointIndex()
        local list = getWaypoints()
        local wp = idx and list[idx] or nil
        if not wp then error(text("Error_NoWaypoint")) end
        local sq = getCell():getGridSquare(wp.x, wp.y, wp.z or 0)
        if not sq then error(text("Error_NoPlayerSquare")) end
        teleportToSquare(sq)
        say(text("Status_Teleported") .. " [" .. tostring(wp.name) .. "]")
    end, "accent"))
    self:track(page, self:addBtn(text("Button_Teleport"), x2, y, bw, bh, teleportToCursor))
    y = y + bh + gap
    self:track(page, self:addLabel(text("Label_TeleportXY"), pad, y, false, COLOR.muted))
    y = y + 18
    self.xyBox = ISTextEntryBox:new("10000,10000", x1, y, bw, bh)
    self.xyBox:initialise()
    self.xyBox:instantiate()
    self:addChild(self.xyBox)
    self:track(page, self.xyBox)
    self:track(page, self:addBtn(text("Button_TeleportXY"), x2, y, bw, bh, function()
        teleportToXY(self.xyBox and self.xyBox:getText() or "")
    end, "accent"))
    y = y + bh + gap
    self:track(page, self:addLabel(text("Section_WorldTools"), pad, y, true, COLOR.header))
    y = y + 26
    self:track(page, self:addBtn(text("Button_TimeNoon"), x1, y, bw, bh, function() setTimeHours(12) end))
    self:track(page, self:addBtn(text("Button_TimeMidnight"), x2, y, bw, bh, function() setTimeHours(0) end))
    y = y + bh + gap
    self:track(page, self:addBtn(text("Button_TimeDawn"), x1, y, bw, bh, function() setTimeHours(6) end))
    self:track(page, self:addBtn(text("Button_TimeDusk"), x2, y, bw, bh, function() setTimeHours(18) end))
    y = y + bh + gap
    self:track(page, self:addBtn(text("Button_ClearWeather"), x1, y, bw, bh, clearWeather, "accent"))
    self:track(page, self:addBtn(text("Button_ClearCorpses"), x2, y, bw, bh, function() clearCorpses(12) end, "danger"))
    y = y + bh + gap
    self:track(page, self:addBtn(text("Button_ExtinguishFire"), x1, y, bw, bh, function() extinguishFire(10) end, "accent"))
    self:track(page, self:addBtn(text("Button_UnlockNearbyDoors"), x2, y, bw, bh, function() unlockNearbyDoors(8) end))
    y = y + bh + gap
    self.objectLabel = self:track(page, self:addLabel("", pad, y, false, COLOR.muted))
    y = y + 20
    local halfObj = math.floor((bw - 8) / 2)
    self:track(page, self:addBtn(text("Button_PrevObject"), x1, y, halfObj, bh, function()
        self.objectIndex = cycle(self.objectIndex, #SimpleAdminMenu.mapObjects, -1)
    end))
    self:track(page, self:addBtn(text("Button_NextObject"), x1 + halfObj + 8, y, halfObj, bh, function()
        self.objectIndex = cycle(self.objectIndex, #SimpleAdminMenu.mapObjects, 1)
    end))
    self:track(page, self:addBtn(text("Button_PlaceObject"), x2, y, halfObj, bh, function()
        local e = SimpleAdminMenu.mapObjects[self.objectIndex]
        local sq = mouseSquare()
        if not e or not sq then error(text("Error_NoObjectSquare")) end
        local obj = IsoObject.new(sq, e[2])
        sq:AddTileObject(obj)
        if obj and obj.transmitCompleteItemToServer then obj:transmitCompleteItemToServer() end
        say(text("Status_ObjectPlaced") .. text(e[1]))
    end, "accent"))
    self:track(page, self:addBtn(text("Button_RemoveObject"), x2 + halfObj + 8, y, halfObj, bh, function()
        local sq = mouseSquare()
        if not sq then error(text("Error_NoSquare")) end
        local objs = sq:getObjects()
        if objs:size() <= 0 then error(text("Error_NoObjects")) end
        sq:RemoveTileObject(objs:get(objs:size() - 1))
        say(text("Status_ObjectRemoved"))
    end, "danger"))
    self:populateWaypointList()

    -- More
    page = 5
    self:track(page, self:addLabel(text("Section_SkillsRecipes"), pad, contentY, true, COLOR.header))
    y = contentY + 28
    self:track(page, self:addBtn(text("Button_MaxSkills"), x1, y, bw, bh, maxAllSkills, "accent"))
    self:track(page, self:addBtn(text("Button_LearnRecipes"), x2, y, bw, bh, learnAllRecipes, "accent"))
    y = y + bh + gap + 4
    self:track(page, self:addLabel(text("Section_CheatFlags"), pad, y, true, COLOR.header))
    y = y + 28
    self:track(page, self:addToggleBtn(text("Button_BuildCheat"), x1, y, bw, bh, "isBuildCheat", "setBuildCheat"))
    self:track(page, self:addToggleBtn(text("Button_FarmingCheat"), x2, y, bw, bh, "isFarmingCheat", "setFarmingCheat"))
    y = y + bh + gap
    self:track(page, self:addToggleBtn(text("Button_MechanicsCheat"), x1, y, bw, bh, "isMechanicsCheat", "setMechanicsCheat"))
    self:track(page, self:addToggleBtn(text("Button_HealthCheat"), x2, y, bw, bh, "isHealthCheat", "setHealthCheat"))
    y = y + bh + gap
    self:track(page, self:addToggleBtn(text("Button_MovablesCheat"), x1, y, bw, bh, "isMovablesCheat", "setMovablesCheat"))
    self:track(page, self:addToggleBtn(text("Button_InstantActions"), x2, y, bw, bh, "isTimedActionInstantCheat", "setTimedActionInstantCheat"))
    y = y + bh + gap + 4
    self:track(page, self:addLabel(text("Section_FastReading"), pad, y, true, COLOR.header))
    y = y + 28
    self.moreFastReadLabel = self:track(page, self:addLabel("", pad, y, false, COLOR.muted))
    y = y + 22
    self:track(page, self:addBtn(text("Button_PrevFastRead"), x1, y, bw, bh, function()
        local s = getSettings()
        local idx = fastReadIndex(s.fastReadingMult)
        idx = cycle(idx, #FAST_READ_MULTS, -1)
        s.fastReadingMult = FAST_READ_MULTS[idx]
        saveModData()
        applyFastReading()
        say(text("Settings_FastReading") .. fastReadLabel(s.fastReadingMult))
        labelText(self.moreFastReadLabel, text("Settings_FastReading") .. fastReadLabel(s.fastReadingMult))
    end))
    self:track(page, self:addBtn(text("Button_NextFastRead"), x2, y, bw, bh, function()
        local s = getSettings()
        local idx = fastReadIndex(s.fastReadingMult)
        idx = cycle(idx, #FAST_READ_MULTS, 1)
        s.fastReadingMult = FAST_READ_MULTS[idx]
        saveModData()
        applyFastReading()
        say(text("Settings_FastReading") .. fastReadLabel(s.fastReadingMult))
        labelText(self.moreFastReadLabel, text("Settings_FastReading") .. fastReadLabel(s.fastReadingMult))
    end, "accent"))
    labelText(self.moreFastReadLabel, text("Settings_FastReading") .. fastReadLabel(getSettings().fastReadingMult))
    y = y + bh + gap + 4
    self:track(page, self:addLabel(text("Section_QuickCleanup"), pad, y, true, COLOR.header))
    y = y + 22
    self:track(page, self:addLabel(text("Label_MoreCleanupHint"), pad, y, false, COLOR.muted))
    y = y + 24
    -- Unique extras only; corpse/fire clear live on World tab to avoid duplicate buttons.
    self:track(page, self:addBtn(text("Button_KillWide"), x1, y, bw, bh, function() killNearby(40) end, "danger"))
    self:track(page, self:addBtn(text("Button_UnlockNearbyDoors"), x2, y, bw, bh, function() unlockNearbyDoors(12) end))
    y = y + bh + gap
    self:track(page, self:addBtn(text("Button_ShowCoords"), x1, y, bw, bh, showCoords))

    -- Settings
    page = 6
    self:track(page, self:addLabel(text("Section_Settings"), pad, contentY, true, COLOR.header))
    y = contentY + 28
    self:track(page, self:addLabel(text("Settings_Hint"), pad, y, false, COLOR.muted))
    y = y + 28
    self.setHotkeyLabel = self:track(page, self:addLabel("", pad, y, false, COLOR.white))
    y = y + 24
    self:track(page, self:addBtn(text("Button_PrevHotkey"), x1, y, bw, bh, function()
        local s = getSettings()
        local idx = hotkeyIndex(s.hotkey)
        idx = cycle(idx, #HOTKEY_NAMES, -1)
        s.hotkey = HOTKEY_NAMES[idx]
        saveModData()
        say(text("Settings_Hotkey") .. s.hotkey)
    end))
    self:track(page, self:addBtn(text("Button_NextHotkey"), x2, y, bw, bh, function()
        local s = getSettings()
        local idx = hotkeyIndex(s.hotkey)
        idx = cycle(idx, #HOTKEY_NAMES, 1)
        s.hotkey = HOTKEY_NAMES[idx]
        saveModData()
        say(text("Settings_Hotkey") .. s.hotkey)
    end))
    y = y + bh + gap
    self.setButtonPosLabel = self:track(page, self:addLabel("", pad, y, false, COLOR.white))
    y = y + 24
    self:track(page, self:addBtn(text("Button_PrevButtonPos"), x1, y, bw, bh, function()
        local s = getSettings()
        local idx = buttonPosIndex(s.buttonPos)
        idx = cycle(idx, #BUTTON_POS, -1)
        s.buttonPos = BUTTON_POS[idx]
        saveModData()
        SimpleAdminMenu.applyButtonLayout()
        say(text("Settings_ButtonPos") .. text("Pos_" .. s.buttonPos))
    end))
    self:track(page, self:addBtn(text("Button_NextButtonPos"), x2, y, bw, bh, function()
        local s = getSettings()
        local idx = buttonPosIndex(s.buttonPos)
        idx = cycle(idx, #BUTTON_POS, 1)
        s.buttonPos = BUTTON_POS[idx]
        saveModData()
        SimpleAdminMenu.applyButtonLayout()
        say(text("Settings_ButtonPos") .. text("Pos_" .. s.buttonPos))
    end))
    y = y + bh + gap
    self.setScaleLabel = self:track(page, self:addLabel("", pad, y, false, COLOR.white))
    y = y + 24
    self:track(page, self:addBtn(text("Button_PrevScale"), x1, y, bw, bh, function()
        local s = getSettings()
        local idx = uiScaleIndex(s.uiScale)
        idx = cycle(idx, #UI_SCALES, -1)
        s.uiScale = UI_SCALES[idx]
        saveModData()
        say(text("Settings_UiScale") .. text("Scale_" .. s.uiScale) .. text("Settings_ScaleHint"))
    end))
    self:track(page, self:addBtn(text("Button_NextScale"), x2, y, bw, bh, function()
        local s = getSettings()
        local idx = uiScaleIndex(s.uiScale)
        idx = cycle(idx, #UI_SCALES, 1)
        s.uiScale = UI_SCALES[idx]
        saveModData()
        say(text("Settings_UiScale") .. text("Scale_" .. s.uiScale) .. text("Settings_ScaleHint"))
    end))
    y = y + bh + gap
    self.setFastReadLabel = self:track(page, self:addLabel("", pad, y, false, COLOR.white))
    y = y + 24
    self:track(page, self:addBtn(text("Button_PrevFastRead"), x1, y, bw, bh, function()
        local s = getSettings()
        local idx = fastReadIndex(s.fastReadingMult)
        idx = cycle(idx, #FAST_READ_MULTS, -1)
        s.fastReadingMult = FAST_READ_MULTS[idx]
        saveModData()
        applyFastReading()
        say(text("Settings_FastReading") .. fastReadLabel(s.fastReadingMult))
    end))
    self:track(page, self:addBtn(text("Button_NextFastRead"), x2, y, bw, bh, function()
        local s = getSettings()
        local idx = fastReadIndex(s.fastReadingMult)
        idx = cycle(idx, #FAST_READ_MULTS, 1)
        s.fastReadingMult = FAST_READ_MULTS[idx]
        saveModData()
        applyFastReading()
        say(text("Settings_FastReading") .. fastReadLabel(s.fastReadingMult))
    end, "accent"))
    y = y + bh + gap + 6
    self.showButtonTick = ISTickBox:new(pad, y, 20, 20, "", nil, nil)
    self.showButtonTick:initialise()
    self.showButtonTick:instantiate()
    self.showButtonTick:addOption(text("Settings_ShowButton"))
    self.showButtonTick.selected[1] = getSettings().showButton and true or false
    self:addChild(self.showButtonTick)
    self:track(page, self.showButtonTick)
    y = y + 36
    self:track(page, self:addBtn(text("Button_ApplyShowButton"), x1, y, bw, bh, function()
        local s = getSettings()
        s.showButton = self.showButtonTick and self.showButtonTick.selected[1] and true or false
        saveModData()
        SimpleAdminMenu.applyButtonLayout()
        say(text("Settings_ShowButton") .. text("Separator") .. enabledText(s.showButton))
    end, "accent"))
    self:track(page, self:addBtn(text("Button_ClearFavorites"), x2, y, bw, bh, function()
        getModData().favorites = {}
        saveModData()
        self:populateItemList(false)
        say(text("Status_FavoritesCleared"))
    end, "danger"))
    y = y + bh + gap
    self.setFavCountLabel = self:track(page, self:addLabel("", pad, y, false, COLOR.muted))
    y = y + 28
    self:track(page, self:addLabel(text("Settings_Tip"), pad, y, false, COLOR.muted))

    self:setTab(self.tabIndex or 1)
    self:refreshSettingsLabels()
end

function SimpleAdminMenu.windowSize()
    local s = getSettings()
    local core = getCore()
    local sw = core and core:getScreenWidth() or 1280
    local sh = core and core:getScreenHeight() or 720
    local w, h
    if s.uiScale == "standard" then
        w = math.min(700, math.max(620, math.floor(sw * 0.40)))
        h = math.min(760, math.max(640, math.floor(sh * 0.72)))
    else
        w = math.min(820, math.max(700, math.floor(sw * 0.50)))
        h = math.min(900, math.max(740, math.floor(sh * 0.84)))
    end
    local x = (sw / 2) - (w / 2)
    local y = math.max(20, (sh / 2) - (h / 2))
    return x, y, w, h
end

function SimpleAdminMenu.open()
    safe(text("Action_OpenMenu"), function()
        if SimpleAdminMenu.instance then
            SimpleAdminMenu.instance:close()
            return
        end
        local x, y, w, h = SimpleAdminMenu.windowSize()
        local panel = SimpleAdminMenu:new(x, y, w, h)
        panel:initialise()
        panel:instantiate()
        panel:addToUIManager()
        panel:setVisible(true)
        if panel.setResizable then panel:setResizable(false) end
        SimpleAdminMenu.instance = panel
        log(text("Log_MenuOpened"))
    end)
end

SimpleAdminMenuButton = ISButton:derive("SimpleAdminMenuButton")

function SimpleAdminMenuButton:new(x, y, w, h)
    local o = ISButton.new(self, x, y, w, h, text("Button_Admin"), nil, function()
        SimpleAdminMenu.open()
    end)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = copyColor(COLOR.accent, 0.96)
    o.borderColor = copyColor(COLOR.accentBorder)
    o.backgroundColorMouseOver = copyColor(COLOR.accentHover)
    return o
end

function SimpleAdminMenu.createButton()
    safe(text("Action_CreateButton"), function()
        local s = getSettings()
        if not s.showButton then return end
        if SimpleAdminMenu.openButton then
            SimpleAdminMenu.applyButtonLayout()
            return
        end
        local x, y, w, h = buttonScreenPos()
        local b = SimpleAdminMenuButton:new(x, y, w, h)
        b:initialise()
        b:instantiate()
        b:addToUIManager()
        b:setVisible(true)
        SimpleAdminMenu.openButton = b
        log(text("Log_ButtonCreated"))
    end)
end

local function context(playerNum, context, worldobjects, test)
    if test or not context then return end
    local clickSq = squareFromWorldObjects(worldobjects)
    if clickSq then rememberSquare(clickSq) end

    -- Top-level: teleport to the right-clicked tile (most used admin action).
    context:addOption(text("Context_TeleportHere"), worldobjects, function()
        safe(text("Context_TeleportHere"), function() teleportToContext(worldobjects) end)
    end)

    local opt = context:addOption(text("Context_AdminMenu"), worldobjects, nil)
    local sub = ISContextMenu:getNew(context)
    context:addSubMenu(opt, sub)
    sub:addOption(text("Context_OpenMenu"), worldobjects, function() SimpleAdminMenu.open() end)
    sub:addOption(text("Context_TeleportHere"), worldobjects, function()
        safe(text("Context_TeleportHere"), function() teleportToContext(worldobjects) end)
    end)
    sub:addOption(text("Button_HealPlayer"), worldobjects, function() safe(text("Button_HealPlayer"), healPlayer) end)
    sub:addOption(text("Button_KillNearby"), worldobjects, function() safe(text("Button_KillNearby"), function() killNearby(6) end) end)
    sub:addOption(text("Button_UnlockDoor"), worldobjects, function()
        safe(text("Button_UnlockDoor"), function() unlockContextDoor(worldobjects) end)
    end)
    sub:addOption(text("Button_UnlockNearbyDoors"), worldobjects, function()
        safe(text("Button_UnlockNearbyDoors"), function() unlockNearbyDoors(8) end)
    end)
    sub:addOption(text("Button_ClearCorpses"), worldobjects, function() safe(text("Button_ClearCorpses"), function() clearCorpses(12) end) end)
    sub:addOption(text("Button_SaveWaypointHere"), worldobjects, function()
        safe(text("Button_SaveWaypointHere"), function()
            local p = player()
            if not p then error(text("Error_NoPlayer")) end
            local list = getWaypoints()
            local name = text("Waypoint_QuickName") .. tostring(#list + 1)
            table.insert(list, {
                name = name,
                x = math.floor(p:getX()),
                y = math.floor(p:getY()),
                z = math.floor(p:getZ()),
            })
            saveModData()
            if SimpleAdminMenu.instance and SimpleAdminMenu.instance.populateWaypointList then
                SimpleAdminMenu.instance:populateWaypointList()
            end
            say(text("Status_WaypointSaved") .. name)
        end)
    end)
end

local function hotkey(key)
    local s = getSettings()
    local want = hotkeyCode(s.hotkey or "F6")
    if want and key == want then
        log(text("Log_Hotkey"))
        SimpleAdminMenu.open()
    end
end

local function ready()
    log(text("Log_PlayerReady"))
    getModData()
    applyFastReading()
    SimpleAdminMenu.createButton()
end

local function autoRepair()
    if not SimpleAdminMenu.keepVehicleRepaired then return end
    local p = player()
    if p and p:getVehicle() then
        pcall(function() repairVehicle(p:getVehicle()) end)
    end
end

local _boostTick = 0
local function onPlayerUpdateBoosts()
    autoRepair()
    _boostTick = _boostTick + 1
    if _boostTick < 30 then return end
    _boostTick = 0
    local p = player()
    if not p then return end
    applyCarryBoost(p)
    reapplyModeState(p)
    if SimpleAdminMenu.autoHeal then
        pcall(function() applyHeal(p) end)
        pcall(function() applyNeeds(p) end)
    end
end

if Events.OnFillWorldObjectContextMenu then Events.OnFillWorldObjectContextMenu.Add(context) end
-- Only OnKeyPressed: also hooking OnKeyStartPressed opens then immediately closes the menu.
if Events.OnKeyPressed then Events.OnKeyPressed.Add(hotkey) end
if Events.OnCreatePlayer then Events.OnCreatePlayer.Add(ready) end
if Events.OnGameStart then Events.OnGameStart.Add(ready) end
if Events.OnPlayerUpdate then Events.OnPlayerUpdate.Add(onPlayerUpdateBoosts) end
if Events.OnTick then
    local t = 0
    local function delayed()
        t = t + 1
        if t > 120 then
            SimpleAdminMenu.createButton()
            Events.OnTick.Remove(delayed)
        end
    end
    Events.OnTick.Add(delayed)
end

SimpleAdminMenuLoaded = true
log(text("Log_Loaded"))
