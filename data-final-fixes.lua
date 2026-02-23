if not settings.startup["sbhli-balanced-unlock"].value then
  return
end

local recipe = data.raw.recipe["bulk-long-handed-inserter"]
local bulk_technology = data.raw.technology["bulk-inserter"]
local has_space_age_content = data.raw.item["superconductor"]
  and data.raw.item["supercapacitor"]
  and data.raw.technology["electromagnetic-science-pack"]

if not (recipe and bulk_technology and has_space_age_content) then
  return
end

local function has_ingredient(list, item_name)
  for _, ingredient in pairs(list or {}) do
    if ingredient.name == item_name then
      return true
    end
  end
  return false
end

local function add_ingredient_if_missing(list, item_name, amount)
  if not has_ingredient(list, item_name) then
    table.insert(list, {type = "item", name = item_name, amount = amount})
  end
end

add_ingredient_if_missing(recipe.ingredients, "superconductor", 5)
add_ingredient_if_missing(recipe.ingredients, "supercapacitor", 3)

if bulk_technology.effects then
  for i = #bulk_technology.effects, 1, -1 do
    local effect = bulk_technology.effects[i]
    if effect.type == "unlock-recipe" and effect.recipe == "bulk-long-handed-inserter" then
      table.remove(bulk_technology.effects, i)
    end
  end
end

if not data.raw.technology["bulk-long-handed-inserter"] then
  data:extend({
    {
      type = "technology",
      name = "bulk-long-handed-inserter",
      icon = "__simple-bulk-long-handed-inserter__/graphics/technology/bulk-long-handed-inserter.png",
      icon_size = 256,
      effects = {
        {type = "unlock-recipe", recipe = "bulk-long-handed-inserter"}
      },
      prerequisites = {"bulk-inserter", "electromagnetic-science-pack"},
      unit = {
        count = 500,
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1},
          {"electromagnetic-science-pack", 1}
        },
        time = 30
      },
      order = "c-o-a"
    }
  })
end

