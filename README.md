# Simple Bulk Long-handed Inserter

## Overview

This mod adds a new inserter to Factorio 2.0:

- `bulk-long-handed-inserter`

It combines:
- bulk inserter behavior (moves multiple items of the same type),
- long-handed inserter reach.

## Features

- New entity: `bulk-long-handed-inserter`
- New placeable item
- New recipe
- Remnants support
- EN/RU localization
- Configurable stack-size penalty in startup settings (for balance)
- Optional balanced unlock mode for Space Age progression

## Startup Settings

- `sbhli-stack-size-offset` (int, default `4`)
Controls how much stack size is reduced compared to a normal bulk inserter.

- `sbhli-balanced-unlock` (bool, default `false`)
When enabled (and when Space Age content is available), the recipe is moved to a separate technology and recipe cost is increased.

## Unlock Logic

Default mode (`sbhli-balanced-unlock = false`):
- Recipe is unlocked by vanilla `bulk-inserter` technology.

Balanced mode (`sbhli-balanced-unlock = true`):
- Implemented in `data-final-fixes.lua` (after all mods are loaded).
- Removes recipe unlock from `bulk-inserter`.
- Adds a separate technology: `bulk-long-handed-inserter`.
- New technology requires `electromagnetic-science-pack`.
- Recipe gets additional ingredients:
  - `5 x superconductor`
  - `3 x supercapacitor`

If Space Age prototypes are not present, the mod safely keeps default unlock behavior.

## Inserter Behavior Details

Base prototype comes from `bulk-inserter`, then the mod applies:

- Reach and hand geometry from `long-handed-inserter`
- Long-handed sprite remap to local assets in `graphics/entity/long-handed-inserter`
- `energy_source.drain = 2kW`
- `energy_per_movement` and `energy_per_rotation` multiplied by `1.5`
- Prototype stack-related limits reduced by configured offset

At runtime (`control.lua`), the mod sets:
- `inserter_stack_size_override`

This enforces actual transfer size as:
- `max(1, (1 + force.bulk_inserter_capacity_bonus) - offset)`

## UI Note About Capacity Text

Factorio UI may still show the global bulk inserter bonus (`1+N`) in tooltips.
Actual transfer amount for this inserter is controlled by runtime override and can be lower than that displayed value.

## File Structure

- `info.json` - mod metadata
- `settings.lua` - startup settings
- `data.lua` - main data stage entry
- `data-final-fixes.lua` - late-stage balanced unlock adjustments
- `prototypes/bulk-long-handed-inserter.lua` - entity/item/recipe/remnants definitions
- `control.lua` - runtime stack-size override logic
- `graphics/icons/bulk-long-handed-inserter.png` - item/entity icon
- `graphics/technology/bulk-long-handed-inserter.png` - technology icon
- `graphics/entity/long-handed-inserter/*.png` - entity sprites
- `graphics/entity/long-handed-inserter/remnants/long-handed-inserter-remnants.png` - remnants sprite
- `locale/en/locale.cfg` - English locale
- `locale/ru/locale.cfg` - Russian locale
