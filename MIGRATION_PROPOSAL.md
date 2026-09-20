# Migration Proposal

This document describes a possible **mod-side direction**, not a finished implementation.

## Problem model

Some existing saves may contain level-up choices and applied progression state created against an older progression schema. After progression-table changes, the saved state can become incompatible with the current level-up/respec construction path.

## Recovery evidence

On reproduced affected saves, replacing compatible `LevelUpData` in both saved level-up components was sufficient to make the native respec UI initialize. Confirming that respec at level 1 then allowed BG3 to rebuild its own applied progression entities.

## Suggested migration boundary

A robust permanent solution should preferably avoid manufacturing or copying `ProgressionContainer` handles.

Potential flow:

1. Detect a legacy/incompatible `LevelUpData` layout.
2. Reconstruct or translate compatible choices for the current progression tables.
3. Validate the reconstructed `LevelUpData`.
4. Permit the native respec path to initialize.
5. Use the game's own confirmed-respec process to rebuild applied progression state.

## Design goals

- preserve companion identity, origin/story state, inventory and approval
- avoid copying ECS entity handles between characters
- avoid copying Experience, AvailableLevel or Classes from a donor
- fail safely when migration cannot be validated
- make the operation explicit and recoverable from a save backup
- support legacy characters with fewer levels than the donor/current template

## Status

Research proposal based on successful Wyll and Gale recoveries across multiple older saves. Further independent reproduction and mod-author review are needed before treating it as a general migration fix.

## Credit

Original legacy-save investigation and recovery research: **SRStudio-CTRL**.
