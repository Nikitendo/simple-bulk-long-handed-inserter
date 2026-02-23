local function remap_long_handed_filenames(node)
  if type(node) ~= "table" then
    return
  end

  for key, value in pairs(node) do
    if type(value) == "table" then
      remap_long_handed_filenames(value)
    elseif type(value) == "string" then
      node[key] = value:gsub(
        "__base__/graphics/entity/long%-handed%-inserter/",
        "__simple-bulk-long-handed-inserter__/graphics/entity/long-handed-inserter/"
      )
    end
  end
end

local function parse_energy(value)
  if type(value) ~= "string" then
    return nil
  end

  local num, prefix, unit = value:match("^%s*([%d%.]+)%s*([kMGT]?)%s*([WJ])%s*$")
  if not num then
    return nil
  end

  local multipliers = {[""] = 1, k = 1000, M = 1000000, G = 1000000000, T = 1000000000000}
  return tonumber(num) * multipliers[prefix], unit
end

local function format_energy(value, unit)
  local prefixes = {
    {symbol = "T", value = 1000000000000},
    {symbol = "G", value = 1000000000},
    {symbol = "M", value = 1000000},
    {symbol = "k", value = 1000},
    {symbol = "", value = 1}
  }

  for _, prefix in ipairs(prefixes) do
    if value >= prefix.value then
      return string.format("%.3f%s%s", value / prefix.value, prefix.symbol, unit)
    end
  end

  return string.format("%.3f%s", value, unit)
end

local bulk_inserter = table.deepcopy(data.raw["inserter"]["bulk-inserter"])
local long_handed_inserter = data.raw["inserter"]["long-handed-inserter"]
local stack_offset = settings.startup["sbhli-stack-size-offset"].value
local bulk_long_icon = "__simple-bulk-long-handed-inserter__/graphics/icons/bulk-long-handed-inserter.png"

bulk_inserter.name = "bulk-long-handed-inserter"
bulk_inserter.icon = bulk_long_icon
bulk_inserter.icons = nil
bulk_inserter.minable = {mining_time = 0.1, result = "bulk-long-handed-inserter"}
bulk_inserter.corpse = "bulk-long-handed-inserter-remnants"

for _, field in ipairs({"pickup_position", "insert_position", "hand_size", "starting_distance"}) do
  if long_handed_inserter[field] ~= nil then
    bulk_inserter[field] = table.deepcopy(long_handed_inserter[field])
  end
end

for _, field in ipairs({
  "platform_picture",
  "hand_base_picture",
  "hand_closed_picture",
  "hand_open_picture",
  "hand_base_shadow",
  "hand_closed_shadow",
  "hand_open_shadow",
  "graphics_set"
}) do
  if long_handed_inserter[field] == nil then
    bulk_inserter[field] = nil
  else
    bulk_inserter[field] = table.deepcopy(long_handed_inserter[field])
  end
end

remap_long_handed_filenames(bulk_inserter)

-- Energy consumption
bulk_inserter.energy_source = table.deepcopy(bulk_inserter.energy_source or {})
bulk_inserter.energy_source.drain = "2kW"  -- minimum idle drain

local me, mu = parse_energy(bulk_inserter.energy_per_movement)
if me then bulk_inserter.energy_per_movement = format_energy(me * 1.5, mu) end

local re, ru = parse_energy(bulk_inserter.energy_per_rotation)
if re then bulk_inserter.energy_per_rotation = format_energy(re * 1.5, ru) end

-- Stack size
if type(data.raw["inserter"]["bulk-inserter"].max_belt_stack_size) == "number" then
  bulk_inserter.max_belt_stack_size = math.max(1, data.raw["inserter"]["bulk-inserter"].max_belt_stack_size - stack_offset)
end
if type(data.raw["inserter"]["bulk-inserter"].stack_size_bonus) == "number" then
  bulk_inserter.stack_size_bonus = math.max(0, data.raw["inserter"]["bulk-inserter"].stack_size_bonus - stack_offset)
end

local bulk_long_handed_item = table.deepcopy(data.raw["item"]["bulk-inserter"])
bulk_long_handed_item.name = "bulk-long-handed-inserter"
bulk_long_handed_item.icon = bulk_long_icon
bulk_long_handed_item.icons = nil
bulk_long_handed_item.place_result = "bulk-long-handed-inserter"

local bulk_long_handed_recipe = {
  type = "recipe",
  name = "bulk-long-handed-inserter",
  enabled = false,
  ingredients = {
    {type = "item", name = "bulk-inserter", amount = 1},
    {type = "item", name = "long-handed-inserter", amount = 1}
  },
  results = {
    {type = "item", name = "bulk-long-handed-inserter", amount = 1}
  }
}

local bulk_long_handed_remnants = table.deepcopy(data.raw["corpse"]["long-handed-inserter-remnants"])
bulk_long_handed_remnants.name = "bulk-long-handed-inserter-remnants"
remap_long_handed_filenames(bulk_long_handed_remnants)

data:extend({
  bulk_inserter,
  bulk_long_handed_item,
  bulk_long_handed_recipe,
  bulk_long_handed_remnants
})

local technology = data.raw["technology"]["bulk-inserter"]
if technology and technology.effects then
  table.insert(technology.effects, {type = "unlock-recipe", recipe = "bulk-long-handed-inserter"})
end

