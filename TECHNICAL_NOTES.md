# Technical Notes

## Scope

These notes document observations made while investigating legacy Baldur's Gate 3 saves in which Wyll and Gale could no longer complete normal level-up or Withers respec after progression changes.

## Relevant ECS data

The investigation focused on:

- `character_creation::LevelUpComponent`
- `progression::LevelUpComponent`
- `progression::ContainerComponent`
- `progression::MetaComponent`

Both `CCLevelUp.LevelUps` and `LevelUp.LevelUps` contain arrays of `LevelUpData`.

`ProgressionContainer.Progressions` contains arrays of entity handles referencing applied progression meta entities.

## Deep-copy mechanism

BG3SE serialization was experimentally verified as a way to obtain an independent Lua representation of `LevelUpData`:

```lua
data = Ext.Types.Serialize(levelUpData)
```

and to write that representation into an existing native object:

```lua
Ext.Types.Unserialize(existingLevelUpData, data)
```

Round-trip serialization checks matched during testing.

## Native reconstruction experiment

Opening and then cancelling a respec on a healthy character preserved progression entity handles.

A genuinely confirmed respec followed by rebuilding the character caused the progression handles to be recreated. This is why the recovery method deliberately avoids copying progression handles and instead uses the native confirmed respec as the reconstruction boundary.

## Failed / unsafe route

Direct edits to legacy progression-related state were tested during investigation and produced an unrecoverable game freeze requiring restart. They are intentionally not part of the published recovery procedure.

## Important limitation

The successful transplant demonstrates a recovery mechanism and provides evidence consistent with stale/legacy progression data. It does not by itself establish the exact engine-level root cause, nor prove that every externally reported Wyll/Gale crash is the same defect.
