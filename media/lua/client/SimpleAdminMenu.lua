-- 简易管理员菜单 v1.2 强制打开补丁
-- 使用“管理”按钮、右键菜单或 F6 打开。

if SimpleAdminMenuLoaded then return end
SimpleAdminMenuLoaded = true

require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISContextMenu"

SimpleAdminMenu = ISPanel:derive("SimpleAdminMenu")
SimpleAdminMenu.version = "1.2"

SimpleAdminMenu.categoryNames = {"Food", "Medical", "Tools", "Weapons", "Building", "Clothing"}
SimpleAdminMenu.categoryLabels = {Food="食物", Medical="医疗", Tools="工具", Weapons="武器", Building="建筑", Clothing="服装"}
SimpleAdminMenu.items = {
    Food = {{"罐装汤","Base.CannedSoup"},{"罐装豆","Base.CannedBeans"},{"金枪鱼罐头","Base.TinnedTuna"},{"瓶装水","Base.WaterBottleFull"},{"面包","Base.Bread"},{"麦片","Base.Cereal"},{"巧克力","Base.Chocolate"},{"薯片","Base.Crisps"}},
    Medical = {{"绷带","Base.Bandage"},{"消毒绷带","Base.AlcoholBandage"},{"创可贴","Base.Bandaid"},{"消毒剂","Base.Disinfectant"},{"止痛药","Base.Pills"},{"缝合针","Base.SutureNeedle"},{"镊子","Base.Tweezers"}},
    Tools = {{"锤子","Base.Hammer"},{"锯子","Base.Saw"},{"斧头","Base.Axe"},{"大锤","Base.Sledgehammer"},{"螺丝刀","Base.Screwdriver"},{"扳手","Base.Wrench"},{"撬棍","Base.Crowbar"},{"丙烷喷灯","Base.BlowTorch"}},
    Weapons = {{"棒球棍","Base.BaseballBat"},{"钉头棒球棍","Base.BaseballBatNails"},{"厨刀","Base.KitchenKnife"},{"砍刀","Base.Machete"},{"霰弹枪","Base.Shotgun"},{"手枪","Base.Pistol"},{"9毫米弹药盒","Base.Bullets9mmBox"},{"霰弹枪弹药盒","Base.ShotgunShellsBox"}},
    Building = {{"木板","Base.Plank"},{"钉子","Base.Nails"},{"门铰链","Base.Hinge"},{"门把手","Base.Doorknob"},{"床单绳","Base.SheetRope"},{"垃圾袋","Base.Garbagebag"},{"焊条","Base.WeldingRods"}},
    Clothing = {{"书包","Base.Bag_Schoolbag"},{"旅行包","Base.Bag_DuffelBag"},{"大型背包","Base.Bag_BigHikingBag"},{"皮手套","Base.Gloves_LeatherGloves"},{"军靴","Base.Shoes_ArmyBoots"},{"安全帽","Base.Hat_HardHat"}}
}
SimpleAdminMenu.vehicles = {{"标准轿车","Base.CarNormal"},{"厢式货车","Base.Van"},{"小型轿车","Base.SmallCar"},{"皮卡","Base.PickUpTruck"},{"厢式皮卡","Base.PickUpVan"},{"跑车","Base.SportsCar"},{"救护车","Base.VanAmbulance"},{"警车","Base.CarLightsPolice"},{"消防车","Base.PickUpTruckLightsFire"},{"巡护车","Base.CarLights"}}
SimpleAdminMenu.mapObjects = {{"木箱","carpentry_02_59"},{"木椅","furniture_seating_indoor_01_0"},{"小桌子","furniture_tables_low_01_0"},{"柜台","fixtures_counters_01_0"},{"冰箱","appliances_refrigeration_01_0"},{"烤箱","appliances_cooking_01_0"},{"垃圾桶","trashcontainers_01_0"},{"木墙组件","walls_exterior_wooden_01_0"},{"金属栅栏组件","fencing_01_0"},{"砾石地面","blends_natural_01_5"},{"木地板","floors_interior_tilesandwood_01_40"}}

local function log(s) print("[SimpleAdminMenu v"..SimpleAdminMenu.version.."] "..tostring(s)) end
local function player() return getSpecificPlayer(0) or getPlayer() end
local function say(s) log(s); local p=player(); if p and p.Say then pcall(function() p:Say(tostring(s)) end) end end
local function safe(label, fn) local ok,err=pcall(fn); if not ok then log("执行错误："..tostring(label).."："..tostring(err)); say(label.."失败，请检查 console.txt") end end
local function cycle(v,max,chg) if not max or max<=0 then return 1 end; v=v+chg; if v<1 then return max end; if v>max then return 1 end; return v end
local function labelText(lbl,txt) if lbl then lbl.name=tostring(txt) end end

local function mouseSquare()
    local p=player(); if not p or not ISCoordConversion then return nil end
    local z=p:getZ(); local wx=ISCoordConversion.ToWorldX(getMouseXScaled(),getMouseYScaled(),z); local wy=ISCoordConversion.ToWorldY(getMouseXScaled(),getMouseYScaled(),z)
    if not wx or not wy then return nil end
    return getCell():getGridSquare(math.floor(wx), math.floor(wy), z)
end
local function nearSquare() local p=player(); if not p then return nil end; return getCell():getGridSquare(math.floor(p:getX()+2), math.floor(p:getY()), math.floor(p:getZ())) end
local function enabledText(value) if value then return "已开启" end; return "已关闭" end
local function toggle(label,getter,setter) local p=player(); if not p then error("未找到玩家") end; if not p[setter] then error("缺少方法 "..setter) end; local cur=false; if getter and p[getter] then cur=p[getter](p) end; p[setter](p, not cur); say(label.."："..enabledText(not cur)) end
local function repairVehicle(v) if not v then error("未找到载具") end; if v.setGeneralPartCondition then pcall(function() v:setGeneralPartCondition(100,100) end) end; if v.getPartCount and v.getPartByIndex then for i=0,v:getPartCount()-1 do local part=v:getPartByIndex(i); if part and part.setCondition then pcall(function() part:setCondition(100) end) end; if part and part.getInventoryItem then local item=part:getInventoryItem(); if item and item.setCondition then pcall(function() item:setCondition(100) end) end end end end; if v.setRust then pcall(function() v:setRust(0) end) end; if v.updatePartStats then pcall(function() v:updatePartStats() end) end end

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
    local item=list[self.itemIndex] or {"无",""}; local veh=SimpleAdminMenu.vehicles[self.vehicleIndex] or {"无",""}; local obj=SimpleAdminMenu.mapObjects[self.objectIndex] or {"无",""}
    labelText(self.categoryLabel,"类别："..(SimpleAdminMenu.categoryLabels[c] or c)); labelText(self.itemLabel,"物品："..item[1]); labelText(self.vehicleLabel,"载具："..veh[1]); labelText(self.objectLabel,"物件："..obj[1]); labelText(self.carModeLabel,"自动维修："..enabledText(self.keepVehicleRepaired))
end
function SimpleAdminMenu:createChildren()
    ISPanel.createChildren(self)
    self:addLabel("简易管理员菜单 v1.2",16,10,true); self:addLabel("点击“管理”按钮、右键点击地面或按 F6",16,36,false)
    local x1,x2=16,198; local y=64; local bw,bh,gap=170,26,7
    self:addLabel("玩家工具",16,y,false); y=y+22
    self:addBtn("无敌模式",x1,y,bw,bh,function() toggle("无敌模式","isGodMod","setGodMod") end); self:addBtn("隐身",x2,y,bw,bh,function() toggle("隐身","isInvisible","setInvisible") end); y=y+bh+gap
    self:addBtn("幽灵模式",x1,y,bw,bh,function() toggle("幽灵模式","isGhostMode","setGhostMode") end); self:addBtn("穿墙模式",x2,y,bw,bh,function() toggle("穿墙模式","isNoClip","setNoClip") end); y=y+bh+gap
    self:addBtn("治疗玩家",x1,y,bw,bh,function() local p=player(); if not p then error("未找到玩家") end; local b=p:getBodyDamage(); if b then if b.RestoreToFullHealth then b:RestoreToFullHealth() end; if b.setOverallBodyHealth then b:setOverallBodyHealth(100) end; if b.setInfected then b:setInfected(false) end end end)
    self:addBtn("补满生存需求",x2,y,bw,bh,function() local p=player(); if not p then error("未找到玩家") end; local s=p:getStats(); if s then if s.setHunger then s:setHunger(0) end; if s.setThirst then s:setThirst(0) end; if s.setFatigue then s:setFatigue(0) end; if s.setPanic then s:setPanic(0) end; if s.setEndurance then s:setEndurance(1) end end end); y=y+bh+gap
    self:addBtn("击杀附近僵尸",x1,y,bw,bh,function() local p=player(); if not p then error("未找到玩家") end; local zeds=p:getCell():getZombieList(); local killed=0; for i=0,zeds:size()-1 do local z=zeds:get(i); if z and not z:isDead() and p:DistTo(z)<=6 then if z.Kill then z:Kill(p) elseif z.setHealth then z:setHealth(0) end; killed=killed+1 end end; say("已击杀附近僵尸："..killed) end)
    self:addBtn("击杀光标下的僵尸",x2,y,bw,bh,function() local sq=mouseSquare(); if not sq then error("光标下没有地块") end; local m=sq:getMovingObjects(); for i=0,m:size()-1 do local o=m:get(i); local iz=false; if instanceof then pcall(function() iz=instanceof(o,"IsoZombie") end) end; if not iz and o and o.getObjectName and o:getObjectName()=="Zombie" then iz=true end; if iz then if o.Kill then o:Kill(player()) elseif o.setHealth then o:setHealth(0) end; return end end; error("光标下没有僵尸") end); y=y+bh+12
    self:addLabel("物品生成器",16,y,false); y=y+20; self.categoryLabel=self:addLabel("类别：食物",16,y,false); self.itemLabel=self:addLabel("物品：罐装汤",198,y,false); y=y+22
    self:addBtn("< 类别",x1,y,82,bh,function() self.categoryIndex=cycle(self.categoryIndex,#SimpleAdminMenu.categoryNames,-1); self.itemIndex=1; self:updateLabels() end); self:addBtn("类别 >",x1+88,y,82,bh,function() self.categoryIndex=cycle(self.categoryIndex,#SimpleAdminMenu.categoryNames,1); self.itemIndex=1; self:updateLabels() end); self:addBtn("< 物品",x2,y,82,bh,function() local c=SimpleAdminMenu.categoryNames[self.categoryIndex]; self.itemIndex=cycle(self.itemIndex,#(SimpleAdminMenu.items[c] or {}),-1); self:updateLabels() end); self:addBtn("物品 >",x2+88,y,82,bh,function() local c=SimpleAdminMenu.categoryNames[self.categoryIndex]; self.itemIndex=cycle(self.itemIndex,#(SimpleAdminMenu.items[c] or {}),1); self:updateLabels() end); y=y+bh+gap
    self:addBtn("生成所选物品",x1,y,bw,bh,function() local e=self:getSelectedItem(); if not e then error("未选择物品") end; player():getInventory():AddItem(e[2]) end); self:addBtn("生成10个所选物品",x2,y,bw,bh,function() local e=self:getSelectedItem(); if not e then error("未选择物品") end; local inv=player():getInventory(); for i=1,10 do inv:AddItem(e[2]) end end); y=y+bh+12
    self:addLabel("载具工具",16,y,false); y=y+20; self.vehicleLabel=self:addLabel("载具：标准轿车",16,y,false); self.carModeLabel=self:addLabel("自动维修：已关闭",198,y,false); y=y+22
    self:addBtn("< 载具",x1,y,bw,bh,function() self.vehicleIndex=cycle(self.vehicleIndex,#SimpleAdminMenu.vehicles,-1); self:updateLabels() end); self:addBtn("载具 >",x2,y,bw,bh,function() self.vehicleIndex=cycle(self.vehicleIndex,#SimpleAdminMenu.vehicles,1); self:updateLabels() end); y=y+bh+gap
    self:addBtn("生成载具",x1,y,bw,bh,function() local e=SimpleAdminMenu.vehicles[self.vehicleIndex]; local sq=nearSquare(); if not e or not sq then error("未找到载具或地块") end; if addVehicleDebug then addVehicleDebug(e[2],nil,nil,sq) elseif addVehicle then addVehicle(e[2],sq:getX(),sq:getY(),sq:getZ()) else error("当前版本不支持生成载具") end end)
    self:addBtn("修复当前载具",x2,y,bw,bh,function() local p=player(); if not p or not p:getVehicle() then error("请先进入一辆载具") end; repairVehicle(p:getVehicle()) end); y=y+bh+gap
    self:addBtn("切换载具自动维修",x1,y,bw,bh,function() self.keepVehicleRepaired=not self.keepVehicleRepaired; self:updateLabels() end); self:addBtn("加满当前载具燃油",x2,y,bw,bh,function() local p=player(); if not p or not p:getVehicle() then error("请先进入一辆载具") end; local v=p:getVehicle(); if v.setFuelAmount then v:setFuelAmount(100) else error("当前版本不支持设置燃油") end end); y=y+bh+12
    self:addLabel("地图 / 物件编辑器",16,y,false); y=y+20; self.objectLabel=self:addLabel("物件：木箱",16,y,false); y=y+22
    self:addBtn("< 物件",x1,y,bw,bh,function() self.objectIndex=cycle(self.objectIndex,#SimpleAdminMenu.mapObjects,-1); self:updateLabels() end); self:addBtn("物件 >",x2,y,bw,bh,function() self.objectIndex=cycle(self.objectIndex,#SimpleAdminMenu.mapObjects,1); self:updateLabels() end); y=y+bh+gap
    self:addBtn("在光标处放置物件",x1,y,bw,bh,function() local e=SimpleAdminMenu.mapObjects[self.objectIndex]; local sq=mouseSquare(); if not e or not sq then error("未找到物件或地块") end; local obj=IsoObject.new(sq,e[2]); sq:AddTileObject(obj); if obj and obj.transmitCompleteItemToServer then obj:transmitCompleteItemToServer() end end)
    self:addBtn("移除最上层物件",x2,y,bw,bh,function() local sq=mouseSquare(); if not sq then error("光标下没有地块") end; local objs=sq:getObjects(); if objs:size()<=0 then error("光标下没有物件") end; sq:RemoveTileObject(objs:get(objs:size()-1)) end); y=y+bh+gap
    self:addBtn("传送到光标位置",x1,y,bw,bh,function() local p=player(); local sq=mouseSquare(); if not p or not sq then error("未找到玩家或地块") end; p:setX(sq:getX()+0.5); p:setY(sq:getY()+0.5); p:setLx(p:getX()); p:setLy(p:getY()); p:setCurrent(sq) end)
    self:addBtn("关闭",x2,y,bw,bh,function() self:removeFromUIManager(); SimpleAdminMenu.instance=nil end)
    self:updateLabels()
end
function SimpleAdminMenu.open()
    safe("打开菜单",function()
        if SimpleAdminMenu.instance then SimpleAdminMenu.instance:removeFromUIManager(); SimpleAdminMenu.instance=nil; return end
        local core=getCore(); local w,h=386,604; local x,y=80,80; if core then x=(core:getScreenWidth()/2)-(w/2); y=(core:getScreenHeight()/2)-(h/2) end
        local panel=SimpleAdminMenu:new(x,y,w,h); panel:initialise(); panel:instantiate(); panel:addToUIManager(); panel:setVisible(true); SimpleAdminMenu.instance=panel; log("菜单已打开")
    end)
end
SimpleAdminMenuButton = ISButton:derive("SimpleAdminMenuButton")
function SimpleAdminMenuButton:new(x,y,w,h) local o=ISButton.new(self,x,y,w,h,"管理",nil,function() SimpleAdminMenu.open() end); setmetatable(o,self); self.__index=self; return o end
function SimpleAdminMenu.createButton()
    safe("创建管理按钮",function()
        if SimpleAdminMenu.openButton then return end
        local b=SimpleAdminMenuButton:new(12,260,76,28); b:initialise(); b:instantiate(); b:addToUIManager(); b:setVisible(true); SimpleAdminMenu.openButton=b; log("管理按钮已创建")
    end)
end
local function context(playerNum, context, worldobjects, test) if test or not context then return end; log("右键菜单事件已触发"); local opt=context:addOption("管理员菜单",worldobjects,nil); local sub=ISContextMenu:getNew(context); context:addSubMenu(opt,sub); sub:addOption("打开管理员菜单",worldobjects,function() SimpleAdminMenu.open() end) end
local function hotkey(key) if Keyboard and key==Keyboard.KEY_F6 then log("F6 快捷键已触发"); SimpleAdminMenu.open() end end
local function ready() log("玩家加载事件已触发"); SimpleAdminMenu.createButton() end
local function autoRepair() if SimpleAdminMenu.instance and SimpleAdminMenu.instance.keepVehicleRepaired then local p=player(); if p and p:getVehicle() then pcall(function() repairVehicle(p:getVehicle()) end) end end end
if Events.OnFillWorldObjectContextMenu then Events.OnFillWorldObjectContextMenu.Add(context) end
if Events.OnKeyPressed then Events.OnKeyPressed.Add(hotkey) end
if Events.OnKeyStartPressed then Events.OnKeyStartPressed.Add(hotkey) end
if Events.OnCreatePlayer then Events.OnCreatePlayer.Add(ready) end
if Events.OnGameStart then Events.OnGameStart.Add(ready) end
if Events.OnPlayerUpdate then Events.OnPlayerUpdate.Add(autoRepair) end
if Events.OnTick then local t=0; local function delayed() t=t+1; if t>120 then SimpleAdminMenu.createButton(); Events.OnTick.Remove(delayed) end end; Events.OnTick.Add(delayed) end
log("模组已加载，进入存档后应显示“管理”按钮。")
