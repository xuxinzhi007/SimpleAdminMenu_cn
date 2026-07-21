-- Simple Admin Menu v1.2
-- All player-facing text is loaded from Translate files for UTF-8 compatibility.

if SimpleAdminMenuLoaded then return end
SimpleAdminMenuLoaded = true

require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISContextMenu"

SimpleAdminMenu = ISPanel:derive("SimpleAdminMenu")
SimpleAdminMenu.version = "1.2"

local function text(key) return getText("IGUI_SimpleAdminMenu_"..key) end

SimpleAdminMenu.categoryNames = {"Food", "Medical", "Tools", "Weapons", "Building", "Clothing"}
SimpleAdminMenu.categoryLabels = {Food="Category_Food", Medical="Category_Medical", Tools="Category_Tools", Weapons="Category_Weapons", Building="Category_Building", Clothing="Category_Clothing"}
SimpleAdminMenu.items = {
    Food = {{"Item_CannedSoup","Base.CannedSoup"},{"Item_CannedBeans","Base.CannedBeans"},{"Item_TinnedTuna","Base.TinnedTuna"},{"Item_WaterBottle","Base.WaterBottleFull"},{"Item_Bread","Base.Bread"},{"Item_Cereal","Base.Cereal"},{"Item_Chocolate","Base.Chocolate"},{"Item_Crisps","Base.Crisps"}},
    Medical = {{"Item_Bandage","Base.Bandage"},{"Item_AlcoholBandage","Base.AlcoholBandage"},{"Item_Bandaid","Base.Bandaid"},{"Item_Disinfectant","Base.Disinfectant"},{"Item_Pills","Base.Pills"},{"Item_SutureNeedle","Base.SutureNeedle"},{"Item_Tweezers","Base.Tweezers"}},
    Tools = {{"Item_Hammer","Base.Hammer"},{"Item_Saw","Base.Saw"},{"Item_Axe","Base.Axe"},{"Item_Sledgehammer","Base.Sledgehammer"},{"Item_Screwdriver","Base.Screwdriver"},{"Item_Wrench","Base.Wrench"},{"Item_Crowbar","Base.Crowbar"},{"Item_BlowTorch","Base.BlowTorch"}},
    Weapons = {{"Item_BaseballBat","Base.BaseballBat"},{"Item_BaseballBatNails","Base.BaseballBatNails"},{"Item_KitchenKnife","Base.KitchenKnife"},{"Item_Machete","Base.Machete"},{"Item_Shotgun","Base.Shotgun"},{"Item_Pistol","Base.Pistol"},{"Item_Bullets9mmBox","Base.Bullets9mmBox"},{"Item_ShotgunShellsBox","Base.ShotgunShellsBox"}},
    Building = {{"Item_Plank","Base.Plank"},{"Item_Nails","Base.Nails"},{"Item_Hinge","Base.Hinge"},{"Item_Doorknob","Base.Doorknob"},{"Item_SheetRope","Base.SheetRope"},{"Item_Garbagebag","Base.Garbagebag"},{"Item_WeldingRods","Base.WeldingRods"}},
    Clothing = {{"Item_Schoolbag","Base.Bag_Schoolbag"},{"Item_DuffelBag","Base.Bag_DuffelBag"},{"Item_BigHikingBag","Base.Bag_BigHikingBag"},{"Item_LeatherGloves","Base.Gloves_LeatherGloves"},{"Item_ArmyBoots","Base.Shoes_ArmyBoots"},{"Item_HardHat","Base.Hat_HardHat"}}
}
SimpleAdminMenu.vehicles = {{"Vehicle_StandardCar","Base.CarNormal"},{"Vehicle_Van","Base.Van"},{"Vehicle_SmallCar","Base.SmallCar"},{"Vehicle_PickupTruck","Base.PickUpTruck"},{"Vehicle_PickupVan","Base.PickUpVan"},{"Vehicle_SportsCar","Base.SportsCar"},{"Vehicle_Ambulance","Base.VanAmbulance"},{"Vehicle_PoliceCar","Base.CarLightsPolice"},{"Vehicle_FireVehicle","Base.PickUpTruckLightsFire"},{"Vehicle_RangerCar","Base.CarLights"}}
SimpleAdminMenu.mapObjects = {{"Object_WoodenCrate","carpentry_02_59"},{"Object_WoodenChair","furniture_seating_indoor_01_0"},{"Object_SmallTable","furniture_tables_low_01_0"},{"Object_Counter","fixtures_counters_01_0"},{"Object_Fridge","appliances_refrigeration_01_0"},{"Object_Oven","appliances_cooking_01_0"},{"Object_TrashBin","trashcontainers_01_0"},{"Object_WoodenWall","walls_exterior_wooden_01_0"},{"Object_MetalFence","fencing_01_0"},{"Object_GravelFloor","blends_natural_01_5"},{"Object_WoodFloor","floors_interior_tilesandwood_01_40"}}

local function log(s) print("[SimpleAdminMenu v"..SimpleAdminMenu.version.."] "..tostring(s)) end
local function player() return getSpecificPlayer(0) or getPlayer() end
local function say(s) log(s); local p=player(); if p and p.Say then pcall(function() p:Say(tostring(s)) end) end end
local function safe(label, fn) local ok,err=pcall(fn); if not ok then log(text("Log_Error")..tostring(label)..": "..tostring(err)); say(label..text("Error_FailedSuffix")) end end
local function cycle(v,max,chg) if not max or max<=0 then return 1 end; v=v+chg; if v<1 then return max end; if v>max then return 1 end; return v end
local function labelText(lbl,txt) if lbl then lbl.name=tostring(txt) end end

local function mouseSquare()
    local p=player(); if not p or not ISCoordConversion then return nil end
    local z=p:getZ(); local wx=ISCoordConversion.ToWorldX(getMouseXScaled(),getMouseYScaled(),z); local wy=ISCoordConversion.ToWorldY(getMouseXScaled(),getMouseYScaled(),z)
    if not wx or not wy then return nil end
    return getCell():getGridSquare(math.floor(wx), math.floor(wy), z)
end
local function nearSquare() local p=player(); if not p then return nil end; return getCell():getGridSquare(math.floor(p:getX()+2), math.floor(p:getY()), math.floor(p:getZ())) end
local function enabledText(value) if value then return text("State_Enabled") end; return text("State_Disabled") end
local function toggle(label,getter,setter) local p=player(); if not p then error(text("Error_NoPlayer")) end; if not p[setter] then error(text("Error_MissingMethod")..setter) end; local cur=false; if getter and p[getter] then cur=p[getter](p) end; p[setter](p, not cur); say(label..text("Separator")..enabledText(not cur)) end
local function repairVehicle(v) if not v then error(text("Error_NoVehicle")) end; if v.setGeneralPartCondition then pcall(function() v:setGeneralPartCondition(100,100) end) end; if v.getPartCount and v.getPartByIndex then for i=0,v:getPartCount()-1 do local part=v:getPartByIndex(i); if part and part.setCondition then pcall(function() part:setCondition(100) end) end; if part and part.getInventoryItem then local item=part:getInventoryItem(); if item and item.setCondition then pcall(function() item:setCondition(100) end) end end end end; if v.setRust then pcall(function() v:setRust(0) end) end; if v.updatePartStats then pcall(function() v:updatePartStats() end) end end

function SimpleAdminMenu:new(x,y,w,h)
    local o=ISPanel.new(self,x,y,w,h); setmetatable(o,self); self.__index=self
    o.backgroundColor={r=0.05,g=0.05,b=0.05,a=0.94}; o.borderColor={r=0.75,g=0.75,b=0.75,a=0.8}; o.moveWithMouse=true
    o.categoryIndex=1; o.itemIndex=1; o.vehicleIndex=1; o.objectIndex=1; o.keepVehicleRepaired=false
    return o
end
function SimpleAdminMenu:addLabel(t,x,y,big) local font=UIFont.Small; if big then font=UIFont.Medium end; local l=ISLabel:new(x,y,16,tostring(t),1,1,1,1,font,true); l:initialise(); self:addChild(l); return l end
function SimpleAdminMenu:addBtn(t,x,y,w,h,fn) local b=ISButton:new(x,y,w,h,t,self,function() safe(t,fn) end); b:initialise(); b:instantiate(); self:addChild(b); return b end
function SimpleAdminMenu:getSelectedItem() local c=SimpleAdminMenu.categoryNames[self.categoryIndex] or "Food"; return (SimpleAdminMenu.items[c] or {})[self.itemIndex] end
function SimpleAdminMenu:updateLabels()
    local c=SimpleAdminMenu.categoryNames[self.categoryIndex] or "Food"; local list=SimpleAdminMenu.items[c] or {}; if self.itemIndex>#list then self.itemIndex=1 end
    local item=list[self.itemIndex] or {"None",""}; local veh=SimpleAdminMenu.vehicles[self.vehicleIndex] or {"None",""}; local obj=SimpleAdminMenu.mapObjects[self.objectIndex] or {"None",""}
    labelText(self.categoryLabel,text("Label_Category")..text(SimpleAdminMenu.categoryLabels[c] or "None")); labelText(self.itemLabel,text("Label_Item")..text(item[1])); labelText(self.vehicleLabel,text("Label_Vehicle")..text(veh[1])); labelText(self.objectLabel,text("Label_Object")..text(obj[1])); labelText(self.carModeLabel,text("Label_AutoRepair")..enabledText(self.keepVehicleRepaired))
end
function SimpleAdminMenu:createChildren()
    ISPanel.createChildren(self)
    self:addLabel(text("Title"),16,10,true); self:addLabel(text("Hint"),16,36,false)
    local x1,x2=16,198; local y=64; local bw,bh,gap=170,26,7
    self:addLabel(text("Section_PlayerTools"),16,y,false); y=y+22
    self:addBtn(text("Button_GodMode"),x1,y,bw,bh,function() toggle(text("Button_GodMode"),"isGodMod","setGodMod") end); self:addBtn(text("Button_Invisible"),x2,y,bw,bh,function() toggle(text("Button_Invisible"),"isInvisible","setInvisible") end); y=y+bh+gap
    self:addBtn(text("Button_GhostMode"),x1,y,bw,bh,function() toggle(text("Button_GhostMode"),"isGhostMode","setGhostMode") end); self:addBtn(text("Button_NoClip"),x2,y,bw,bh,function() toggle(text("Button_NoClip"),"isNoClip","setNoClip") end); y=y+bh+gap
    self:addBtn(text("Button_HealPlayer"),x1,y,bw,bh,function() local p=player(); if not p then error(text("Error_NoPlayer")) end; local b=p:getBodyDamage(); if b then if b.RestoreToFullHealth then b:RestoreToFullHealth() end; if b.setOverallBodyHealth then b:setOverallBodyHealth(100) end; if b.setInfected then b:setInfected(false) end end end)
    self:addBtn(text("Button_RefillNeeds"),x2,y,bw,bh,function() local p=player(); if not p then error(text("Error_NoPlayer")) end; local s=p:getStats(); if s then if s.setHunger then s:setHunger(0) end; if s.setThirst then s:setThirst(0) end; if s.setFatigue then s:setFatigue(0) end; if s.setPanic then s:setPanic(0) end; if s.setEndurance then s:setEndurance(1) end end end); y=y+bh+gap
    self:addBtn(text("Button_KillNearby"),x1,y,bw,bh,function() local p=player(); if not p then error(text("Error_NoPlayer")) end; local zeds=p:getCell():getZombieList(); local killed=0; for i=0,zeds:size()-1 do local z=zeds:get(i); if z and not z:isDead() and p:DistTo(z)<=6 then if z.Kill then z:Kill(p) elseif z.setHealth then z:setHealth(0) end; killed=killed+1 end end; say(text("Status_KilledNearby")..killed) end)
    self:addBtn(text("Button_KillCursor"),x2,y,bw,bh,function() local sq=mouseSquare(); if not sq then error(text("Error_NoSquare")) end; local m=sq:getMovingObjects(); for i=0,m:size()-1 do local o=m:get(i); local iz=false; if instanceof then pcall(function() iz=instanceof(o,"IsoZombie") end) end; if not iz and o and o.getObjectName and o:getObjectName()=="Zombie" then iz=true end; if iz then if o.Kill then o:Kill(player()) elseif o.setHealth then o:setHealth(0) end; return end end; error(text("Error_NoZombie")) end); y=y+bh+12
    self:addLabel(text("Section_ItemSpawner"),16,y,false); y=y+20; self.categoryLabel=self:addLabel("",16,y,false); self.itemLabel=self:addLabel("",198,y,false); y=y+22
    self:addBtn(text("Button_PrevCategory"),x1,y,82,bh,function() self.categoryIndex=cycle(self.categoryIndex,#SimpleAdminMenu.categoryNames,-1); self.itemIndex=1; self:updateLabels() end); self:addBtn(text("Button_NextCategory"),x1+88,y,82,bh,function() self.categoryIndex=cycle(self.categoryIndex,#SimpleAdminMenu.categoryNames,1); self.itemIndex=1; self:updateLabels() end); self:addBtn(text("Button_PrevItem"),x2,y,82,bh,function() local c=SimpleAdminMenu.categoryNames[self.categoryIndex]; self.itemIndex=cycle(self.itemIndex,#(SimpleAdminMenu.items[c] or {}),-1); self:updateLabels() end); self:addBtn(text("Button_NextItem"),x2+88,y,82,bh,function() local c=SimpleAdminMenu.categoryNames[self.categoryIndex]; self.itemIndex=cycle(self.itemIndex,#(SimpleAdminMenu.items[c] or {}),1); self:updateLabels() end); y=y+bh+gap
    self:addBtn(text("Button_SpawnSelected"),x1,y,bw,bh,function() local e=self:getSelectedItem(); if not e then error(text("Error_NoItem")) end; player():getInventory():AddItem(e[2]) end); self:addBtn(text("Button_SpawnTen"),x2,y,bw,bh,function() local e=self:getSelectedItem(); if not e then error(text("Error_NoItem")) end; local inv=player():getInventory(); for i=1,10 do inv:AddItem(e[2]) end end); y=y+bh+12
    self:addLabel(text("Section_VehicleTools"),16,y,false); y=y+20; self.vehicleLabel=self:addLabel("",16,y,false); self.carModeLabel=self:addLabel("",198,y,false); y=y+22
    self:addBtn(text("Button_PrevVehicle"),x1,y,bw,bh,function() self.vehicleIndex=cycle(self.vehicleIndex,#SimpleAdminMenu.vehicles,-1); self:updateLabels() end); self:addBtn(text("Button_NextVehicle"),x2,y,bw,bh,function() self.vehicleIndex=cycle(self.vehicleIndex,#SimpleAdminMenu.vehicles,1); self:updateLabels() end); y=y+bh+gap
    self:addBtn(text("Button_SpawnVehicle"),x1,y,bw,bh,function() local e=SimpleAdminMenu.vehicles[self.vehicleIndex]; local sq=nearSquare(); if not e or not sq then error(text("Error_NoVehicleSquare")) end; if addVehicleDebug then addVehicleDebug(e[2],nil,nil,sq) elseif addVehicle then addVehicle(e[2],sq:getX(),sq:getY(),sq:getZ()) else error(text("Error_VehicleSpawnUnavailable")) end end)
    self:addBtn(text("Button_RepairVehicle"),x2,y,bw,bh,function() local p=player(); if not p or not p:getVehicle() then error(text("Error_EnterVehicle")) end; repairVehicle(p:getVehicle()) end); y=y+bh+gap
    self:addBtn(text("Button_ToggleAutoRepair"),x1,y,bw,bh,function() self.keepVehicleRepaired=not self.keepVehicleRepaired; self:updateLabels() end); self:addBtn(text("Button_FuelVehicle"),x2,y,bw,bh,function() local p=player(); if not p or not p:getVehicle() then error(text("Error_EnterVehicle")) end; local v=p:getVehicle(); if v.setFuelAmount then v:setFuelAmount(100) else error(text("Error_FuelUnavailable")) end end); y=y+bh+12
    self:addLabel(text("Section_ObjectEditor"),16,y,false); y=y+20; self.objectLabel=self:addLabel("",16,y,false); y=y+22
    self:addBtn(text("Button_PrevObject"),x1,y,bw,bh,function() self.objectIndex=cycle(self.objectIndex,#SimpleAdminMenu.mapObjects,-1); self:updateLabels() end); self:addBtn(text("Button_NextObject"),x2,y,bw,bh,function() self.objectIndex=cycle(self.objectIndex,#SimpleAdminMenu.mapObjects,1); self:updateLabels() end); y=y+bh+gap
    self:addBtn(text("Button_PlaceObject"),x1,y,bw,bh,function() local e=SimpleAdminMenu.mapObjects[self.objectIndex]; local sq=mouseSquare(); if not e or not sq then error(text("Error_NoObjectSquare")) end; local obj=IsoObject.new(sq,e[2]); sq:AddTileObject(obj); if obj and obj.transmitCompleteItemToServer then obj:transmitCompleteItemToServer() end end)
    self:addBtn(text("Button_RemoveObject"),x2,y,bw,bh,function() local sq=mouseSquare(); if not sq then error(text("Error_NoSquare")) end; local objs=sq:getObjects(); if objs:size()<=0 then error(text("Error_NoObjects")) end; sq:RemoveTileObject(objs:get(objs:size()-1)) end); y=y+bh+gap
    self:addBtn(text("Button_Teleport"),x1,y,bw,bh,function() local p=player(); local sq=mouseSquare(); if not p or not sq then error(text("Error_NoPlayerSquare")) end; p:setX(sq:getX()+0.5); p:setY(sq:getY()+0.5); p:setLx(p:getX()); p:setLy(p:getY()); p:setCurrent(sq) end)
    self:addBtn(text("Button_Close"),x2,y,bw,bh,function() self:removeFromUIManager(); SimpleAdminMenu.instance=nil end)
    self:updateLabels()
end
function SimpleAdminMenu.open()
    safe(text("Action_OpenMenu"),function()
        if SimpleAdminMenu.instance then SimpleAdminMenu.instance:removeFromUIManager(); SimpleAdminMenu.instance=nil; return end
        local core=getCore(); local w,h=386,604; local x,y=80,80; if core then x=(core:getScreenWidth()/2)-(w/2); y=(core:getScreenHeight()/2)-(h/2) end
        local panel=SimpleAdminMenu:new(x,y,w,h); panel:initialise(); panel:instantiate(); panel:addToUIManager(); panel:setVisible(true); SimpleAdminMenu.instance=panel; log(text("Log_MenuOpened"))
    end)
end
SimpleAdminMenuButton = ISButton:derive("SimpleAdminMenuButton")
function SimpleAdminMenuButton:new(x,y,w,h) local o=ISButton.new(self,x,y,w,h,text("Button_Admin"),nil,function() SimpleAdminMenu.open() end); setmetatable(o,self); self.__index=self; return o end
function SimpleAdminMenu.createButton()
    safe(text("Action_CreateButton"),function()
        if SimpleAdminMenu.openButton then return end
        local b=SimpleAdminMenuButton:new(12,260,76,28); b:initialise(); b:instantiate(); b:addToUIManager(); b:setVisible(true); SimpleAdminMenu.openButton=b; log(text("Log_ButtonCreated"))
    end)
end
local function context(playerNum, context, worldobjects, test) if test or not context then return end; log(text("Log_ContextHook")); local opt=context:addOption(text("Context_AdminMenu"),worldobjects,nil); local sub=ISContextMenu:getNew(context); context:addSubMenu(opt,sub); sub:addOption(text("Context_OpenMenu"),worldobjects,function() SimpleAdminMenu.open() end) end
local function hotkey(key) if Keyboard and key==Keyboard.KEY_F6 then log(text("Log_Hotkey")); SimpleAdminMenu.open() end end
local function ready() log(text("Log_PlayerReady")); SimpleAdminMenu.createButton() end
local function autoRepair() if SimpleAdminMenu.instance and SimpleAdminMenu.instance.keepVehicleRepaired then local p=player(); if p and p:getVehicle() then pcall(function() repairVehicle(p:getVehicle()) end) end end end
if Events.OnFillWorldObjectContextMenu then Events.OnFillWorldObjectContextMenu.Add(context) end
if Events.OnKeyPressed then Events.OnKeyPressed.Add(hotkey) end
if Events.OnKeyStartPressed then Events.OnKeyStartPressed.Add(hotkey) end
if Events.OnCreatePlayer then Events.OnCreatePlayer.Add(ready) end
if Events.OnGameStart then Events.OnGameStart.Add(ready) end
if Events.OnPlayerUpdate then Events.OnPlayerUpdate.Add(autoRepair) end
if Events.OnTick then local t=0; local function delayed() t=t+1; if t>120 then SimpleAdminMenu.createButton(); Events.OnTick.Remove(delayed) end end; Events.OnTick.Add(delayed) end
log(text("Log_Loaded"))
