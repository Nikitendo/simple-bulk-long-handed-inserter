local BULK_LONG_HANDED_NAME = "bulk-long-handed-inserter"

local function get_stack_offset()
  local setting = settings.startup["sbhli-stack-size-offset"]
  if not setting or type(setting.value) ~= "number" then
    return 4
  end

  return math.max(0, setting.value)
end

local function get_target_stack_size(force)
  local bulk_bonus = force.bulk_inserter_capacity_bonus or 0
  local target = (1 + bulk_bonus) - get_stack_offset()
  return math.max(1, target)
end

local function apply_override_to_entity(entity)
  if not (entity and entity.valid and entity.name == BULK_LONG_HANDED_NAME) then
    return
  end

  entity.inserter_stack_size_override = get_target_stack_size(entity.force)
end

local function apply_override_for_force(force)
  local target = get_target_stack_size(force)

  for _, surface in pairs(game.surfaces) do
    local entities = surface.find_entities_filtered{
      name = BULK_LONG_HANDED_NAME,
      force = force
    }

    for _, entity in pairs(entities) do
      entity.inserter_stack_size_override = target
    end
  end
end

local function apply_override_for_all_forces()
  for _, force in pairs(game.forces) do
    apply_override_for_force(force)
  end
end

local function on_entity_created(event)
  local entity = event.entity or event.created_entity or event.destination
  apply_override_to_entity(entity)
end

script.on_init(apply_override_for_all_forces)
script.on_configuration_changed(apply_override_for_all_forces)

script.on_event(defines.events.on_research_finished, function(event)
  if event and event.research and event.research.force then
    apply_override_for_force(event.research.force)
  end
end)

script.on_event(defines.events.on_research_reversed, function(event)
  if event and event.research and event.research.force then
    apply_override_for_force(event.research.force)
  end
end)

script.on_event(defines.events.on_built_entity, on_entity_created)
script.on_event(defines.events.on_robot_built_entity, on_entity_created)
script.on_event(defines.events.script_raised_built, on_entity_created)
script.on_event(defines.events.script_raised_revive, on_entity_created)
script.on_event(defines.events.on_entity_cloned, on_entity_created)
