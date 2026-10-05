local isOpen = false
local originalAppearance = {}
local currentShop = nil
local previewCam = nil
local shopHeading = nil
local cameraCategory = 'Tops'

local function buildAutomaticCatalogue()
  local ped = PlayerPedId()
  local catalogue = {}

  for _, slot in ipairs(Config.Scan or {}) do
    local drawableCount
    if slot.type == 'prop' then
      drawableCount = GetNumberOfPedPropDrawableVariations(ped, slot.component)
    else
      drawableCount = GetNumberOfPedDrawableVariations(ped, slot.component)
    end

    if Config.MaxDrawablesPerCategory and Config.MaxDrawablesPerCategory > 0 then
      drawableCount = math.min(drawableCount, Config.MaxDrawablesPerCategory)
    end

    catalogue[#catalogue + 1] = {
      id=('none_%s_%s'):format(slot.type,slot.component), name='None', category=slot.category,
      type=slot.type, component=slot.component, drawable=-1, textures={0}, colours={'None'}, price=0, isNone=true
    }
    for drawable = 0, drawableCount - 1 do
      local textureCount
      if slot.type == 'prop' then
        textureCount = GetNumberOfPedPropTextureVariations(ped, slot.component, drawable)
      else
        textureCount = GetNumberOfPedTextureVariations(ped, slot.component, drawable)
      end
      textureCount = math.max(textureCount, 1)
      if Config.MaxTexturesPerDrawable and Config.MaxTexturesPerDrawable > 0 then
        textureCount = math.min(textureCount, Config.MaxTexturesPerDrawable)
      end

      local textures, colours = {}, {}
      for texture = 0, textureCount - 1 do
        textures[#textures + 1] = texture
        colours[#colours + 1] = ('Texture %02d'):format(texture + 1)
      end

      catalogue[#catalogue + 1] = {
        id = ('%s_%s_%s'):format(slot.type, slot.component, drawable),
        name = ('%s %03d'):format(slot.category, drawable + 1),
        category = slot.category,
        type = slot.type,
        component = slot.component,
        drawable = drawable,
        textures = textures,
        colours = colours,
        price = slot.price
      }
    end
  end

  return catalogue
end

local cameraViews = {
  Masks={distance=1.55,targetZ=0.66,fov=38.0}, Hair={distance=1.60,targetZ=0.72,fov=39.0}, Hats={distance=1.65,targetZ=0.76,fov=40.0},
  Glasses={distance=1.45,targetZ=0.67,fov=36.0}, Ears={distance=1.48,targetZ=0.67,fov=36.0}, Tops={distance=2.55,targetZ=0.20,fov=48.0},
  Arms={distance=2.55,targetZ=0.16,fov=48.0}, Undershirts={distance=2.45,targetZ=0.20,fov=46.0}, Accessories={distance=2.30,targetZ=0.22,fov=44.0},
  Decals={distance=2.35,targetZ=0.22,fov=45.0}, Armour={distance=2.45,targetZ=0.18,fov=46.0}, Bags={distance=2.70,targetZ=0.18,fov=50.0},
  Trousers={distance=2.65,targetZ=-0.42,fov=48.0}, Shoes={distance=2.10,targetZ=-0.88,fov=42.0}, Watches={distance=2.25,targetZ=-0.02,fov=42.0}, Bracelets={distance=2.25,targetZ=-0.08,fov=42.0}
}
local function positionPreviewCamera(category,instant)
  if not previewCam or not DoesCamExist(previewCam) then return end
  local ped=PlayerPedId(); local view=cameraViews[category] or cameraViews.Tops
  local target=GetOffsetFromEntityInWorldCoords(ped,0.0,0.0,view.targetZ)
  local pos=GetOffsetFromEntityInWorldCoords(ped,0.0,view.distance,view.targetZ+0.03)
  SetCamCoord(previewCam,pos.x,pos.y,pos.z); PointCamAtCoord(previewCam,target.x,target.y,target.z); SetCamFov(previewCam,view.fov); SetCamNearClip(previewCam,0.15)
end
local function startPreviewCamera(category)
  local ped=PlayerPedId(); shopHeading=GetEntityHeading(ped); cameraCategory=category or 'Tops'; ClearPedTasksImmediately(ped); FreezeEntityPosition(ped,true)
  previewCam=CreateCam('DEFAULT_SCRIPTED_CAMERA',true); positionPreviewCamera(cameraCategory,true); SetCamActive(previewCam,true); RenderScriptCams(true,true,300,true,true)
end
local function stopPreviewCamera()
  local ped=PlayerPedId(); RenderScriptCams(false,true,250,true,false)
  if previewCam and DoesCamExist(previewCam) then DestroyCam(previewCam,false) end
  previewCam=nil; if shopHeading then SetEntityHeading(ped,shopHeading) end; FreezeEntityPosition(ped,false); ClearFocus()
end

local function snapshotPed()
  local ped = PlayerPedId()
  originalAppearance = { components = {}, props = {} }
  for i = 0, 11 do
    originalAppearance.components[i] = {
      drawable = GetPedDrawableVariation(ped, i),
      texture = GetPedTextureVariation(ped, i)
    }
  end
  for i = 0, 7 do
    originalAppearance.props[i] = {
      drawable = GetPedPropIndex(ped, i),
      texture = GetPedPropTextureIndex(ped, i)
    }
  end
end

local function restorePed()
  local ped = PlayerPedId()
  for component, data in pairs(originalAppearance.components or {}) do
    SetPedComponentVariation(ped, component, data.drawable, data.texture, 0)
  end
  for component, data in pairs(originalAppearance.props or {}) do
    if data.drawable == -1 then ClearPedProp(ped, component)
    else SetPedPropIndex(ped, component, data.drawable, data.texture, true) end
  end
end

local function setFocus(enabled)
  SetNuiFocus(enabled, enabled)
  SetNuiFocusKeepInput(false)
end

local requestCounter, pendingRequests = 0, {}
local function serverRequest(eventName, payload, cb, timeoutMs)
  requestCounter = requestCounter + 1
  local id = requestCounter
  pendingRequests[id] = cb
  TriggerServerEvent(eventName, id, payload)
  SetTimeout(timeoutMs or 5000, function()
    local pending = pendingRequests[id]
    if pending then pendingRequests[id] = nil; pending(nil, 'timeout') end
  end)
end
RegisterNetEvent('mj-clothing:response', function(id, data)
  local cb = pendingRequests[id]
  if cb then pendingRequests[id] = nil; cb(data) end
end)

local function pedModelName()
  local model = GetEntityModel(PlayerPedId())
  if model == joaat('mp_m_freemode_01') then return 'mp_m_freemode_01' end
  if model == joaat('mp_f_freemode_01') then return 'mp_f_freemode_01' end
  return tostring(model)
end

local function openShop(label)
  if isOpen then return end
  snapshotPed()
  local catalogue = Config.AutoScan and buildAutomaticCatalogue() or {}
  local initialCategory = catalogue[1] and catalogue[1].category or 'Tops'
  startPreviewCamera(initialCategory)
  isOpen = true
  currentShop = label or 'Clothing Store'
  setFocus(true)
  SendNUIMessage({action='open', mode='shop', shop=currentShop, catalogue=catalogue, pedModel=pedModelName(), currency=Config.CurrencySymbol, showRestricted=Config.ShowRestrictedToUnauthorised})
  -- Access rules enrich the already-open shop. A database/server callback failure no longer blocks the UI.
  -- Availability enforcement remains server-side at purchase. Sending the entire scanned catalogue
  -- through a normal net event can exceed the event payload and stall the response.
  TriggerServerEvent('mj-clothing:requestRuleSummary', pedModelName())
end

local function openAdmin()
  if isOpen then TriggerEvent('chat:addMessage',{args={'Blackpool Threads','Close the clothing shop before opening admin.'}}); return end
  TriggerEvent('chat:addMessage',{args={'Blackpool Threads','Checking admin access...'}})
  snapshotPed()
  local catalogue = buildAutomaticCatalogue()
  serverRequest('mj-clothing:getAdminCatalogue', {pedModel=pedModelName()}, function(result, err)
    if err == 'timeout' then
      TriggerEvent('chat:addMessage', {args={'Blackpool Threads', 'Admin service did not respond. Check server console and SQL import.'}})
      return
    end
    if not result or not result.allowed then
      TriggerEvent('chat:addMessage', {args={'Blackpool Threads', result and result.message or 'No permission'}})
      return
    end
    local initialCategory = catalogue[1] and catalogue[1].category or 'Tops'
    startPreviewCamera(initialCategory)
    isOpen = true
    currentShop = 'Blackpool Threads Admin'
    setFocus(true)
    SendNUIMessage({action='open', mode='admin', shop=currentShop, catalogue=catalogue, rules=result.rules or {}, jobs=result.jobs or {}, pedModel=pedModelName(), currency=Config.CurrencySymbol})
  end)
end

local function closeShop(restore)
  if not isOpen then return end
  if restore then restorePed() end
  stopPreviewCamera()
  isOpen = false
  currentShop = nil
  setFocus(false)
  SendNUIMessage({ action='close' })
end

RegisterCommand(Config.Command, function() print('[Blackpool Threads] /clothingstore invoked'); openShop('Blackpool Threads') end, false)
RegisterCommand(Config.AdminCommand, function() print('[Blackpool Threads] /clothingadmin invoked'); openAdmin() end, false)
RegisterCommand(Config.WardrobeCommand or 'wardrobe', function()
  if isOpen then return end
  snapshotPed()
  serverRequest('mj-clothing:getWardrobe', {}, function(result, err)
    if err == 'timeout' then return TriggerEvent('chat:addMessage',{args={'Blackpool Threads','Wardrobe did not respond.'}}) end
    local items=(result and result.items) or {}
    startPreviewCamera(items[1] and items[1].category or 'Tops')
    isOpen=true;currentShop='Wardrobe';setFocus(true)
    SendNUIMessage({action='open',mode='wardrobe',shop='Wardrobe',catalogue=items,pedModel=pedModelName(),currency=Config.CurrencySymbol})
  end,8000)
end, false)
RegisterKeyMapping(Config.Command, 'Open clothing shop', 'keyboard', Config.OpenKey)

RegisterNUICallback('preview', function(data,cb)
  local ped=PlayerPedId(); local item=data.item
  if not item then cb({ok=false}); return end
  local texture=tonumber((item.textures or {})[(tonumber(data.textureIndex) or 0)+1]) or tonumber(item.texture) or 0
  if item.isNone or tonumber(item.drawable)==-1 then
    if item.type=='prop' then ClearPedProp(ped,tonumber(item.component)) else SetPedComponentVariation(ped,tonumber(item.component),0,0,0) end
  elseif item.type=='prop' then SetPedPropIndex(ped,tonumber(item.component),tonumber(item.drawable),texture,true)
  else SetPedComponentVariation(ped,tonumber(item.component),tonumber(item.drawable),texture,0) end
  cb({ok=true})
end)

RegisterNUICallback('rotate', function(data, cb)
  local ped = PlayerPedId()
  SetEntityHeading(ped, GetEntityHeading(ped) + (tonumber(data.amount) or 0.0))
  cb({ ok=true })
end)

RegisterNUICallback('cameraCategory', function(data, cb)
  cameraCategory = tostring(data.category or 'Tops')
  positionPreviewCamera(cameraCategory, false)
  cb({ ok=true })
end)

RegisterNUICallback('resetPreview', function(_, cb) restorePed(); cb({ok=true}) end)
RegisterNUICallback('close', function(_, cb) closeShop(true); cb({ok=true}) end)

RegisterNUICallback('purchase', function(data, cb)
  TriggerServerEvent('mj-clothing:purchase', data.cart)
  cb({ ok=true })
end)

RegisterNetEvent('mj-clothing:purchaseResult', function(ok, message, purchased)
  SendNUIMessage({ action='purchaseResult', ok=ok, message=message, purchased=purchased or {} })
  if ok then snapshotPed() end
end)

RegisterNetEvent('mj-clothing:openWardrobe', function(items)
  SendNUIMessage({ action='wardrobe', items=items or {} })
end)

CreateThread(function()
  while true do
    local wait = 1000
    local pos = GetEntityCoords(PlayerPedId())
    for _, shop in ipairs(Config.Shops) do
      local distance = #(pos - shop.coords)
      if distance < Config.DrawDistance then
        wait = 0
        DrawMarker(2, shop.coords.x, shop.coords.y, shop.coords.z + 0.2, 0,0,0, 0,0,0, 0.22,0.22,0.22, 163,230,53,180, false,true,2,false)
        if distance < Config.InteractDistance then
          BeginTextCommandDisplayHelp('STRING')
          AddTextComponentSubstringPlayerName(('Press ~INPUT_CONTEXT~ to browse %s'):format(shop.label))
          EndTextCommandDisplayHelp(0, false, true, -1)
          if IsControlJustReleased(0, 38) then openShop(shop.label) end
        end
      end
    end
    Wait(wait)
  end
end)

CreateThread(function()
  while true do
    if isOpen and IsControlJustReleased(0, 200) then closeShop(true) end
    Wait(isOpen and 0 or 500)
  end
end)


RegisterNUICallback('adminSaveRule', function(data, cb)
  serverRequest('mj-clothing:adminSaveRule', {pedModel=pedModelName(), rule=data}, function(result)
    SendNUIMessage({action='adminSaveResult', result=result})
  end)
  cb({ok=true})
end)

RegisterNUICallback('adminBulkSave', function(data, cb)
  serverRequest('mj-clothing:adminBulkSave', {pedModel=pedModelName(), rules=data.rules}, function(result)
    SendNUIMessage({action='adminSaveResult', result=result})
  end)
  cb({ok=true})
end)
RegisterNUICallback('openWardrobe',function(_,cb)
  closeShop(true)
  SetTimeout(100,function() ExecuteCommand(Config.WardrobeCommand or 'wardrobe') end)
  cb({ok=true})
end)
