Config = {}

-- auto, qb, esx or standalone
Config.Framework = 'auto'
Config.CurrencySymbol = '£'
Config.Command = 'clothingstore'
Config.OpenKey = 'F6'
Config.InteractDistance = 2.0
Config.DrawDistance = 15.0

Config.Shops = {
  { label = 'Blackpool Threads', coords = vector3(72.3, -1399.1, 29.4) },
  { label = 'Suburban', coords = vector3(-1192.9, -772.3, 17.3) }
}

-- V1.1 automatically scans every drawable and texture available on the
-- player's CURRENT ped model whenever the shop opens.
Config.AutoScan = true
Config.Scan = {
  -- Standard GTA freemode component slots
  { category='Masks',       type='component', component=1,  price=55 },
  { category='Hair',        type='component', component=2,  price=40 },
  { category='Arms',        type='component', component=3,  price=25 },
  { category='Trousers',    type='component', component=4,  price=90 },
  { category='Bags',        type='component', component=5,  price=110 },
  { category='Shoes',       type='component', component=6,  price=145 },
  { category='Accessories', type='component', component=7,  price=60 },
  { category='Undershirts', type='component', component=8,  price=45 },
  { category='Armour',      type='component', component=9,  price=200 },
  { category='Decals',      type='component', component=10, price=25 },
  { category='Tops',        type='component', component=11, price=120 },
  -- Standard GTA prop slots
  { category='Hats',        type='prop', component=0, price=40 },
  { category='Glasses',     type='prop', component=1, price=65 },
  { category='Ears',        type='prop', component=2, price=35 },
  { category='Watches',     type='prop', component=6, price=85 },
  { category='Bracelets',   type='prop', component=7, price=55 }
}

-- Safety/performance controls. Set either to 0 for no limit.
Config.MaxDrawablesPerCategory = 0
Config.MaxTexturesPerDrawable = 0


-- Admin catalogue controls
Config.AdminCommand = 'clothingadmin'
Config.AdminAce = 'blackpoolthreads.admin'
Config.AdminGroups = { admin = true, god = true }
Config.ShowRestrictedToUnauthorised = true
Config.RestrictedPreview = false

Config.Features = { wardrobe=true, outfits=true, persistence=true, admin=true, audit=true, compatibility=true, confirmations=true }
Config.WardrobeCommand='wardrobe'
Config.RestrictedVisibility='badge'
Config.MaxBasketItems=20
