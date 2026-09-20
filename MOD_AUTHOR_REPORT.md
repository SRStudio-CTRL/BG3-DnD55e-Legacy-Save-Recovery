# Mod Author Report

## Existing-save recovery — Wyll/Gale level-up & respec crash

Related upstream report: Yoonmoonsik/dnd2024#695.

A reproducible recovery was found while investigating older saves in which Wyll, and in some saves Gale, could no longer complete normal level-up or Withers respec after progression changes.

This does **not** establish that every report in #695 has the same cause.

### Reproduced findings

- affected legacy Wyll/Gale: level-up/respec lag, freeze or crash
- fresh/current characters under the same current setup: functional
- compatible healthy `LevelUpData` transplanted into both `CCLevelUp.LevelUps` and `LevelUp.LevelUps`: native Withers respec initializes
- first recovery respec **confirmed at level 1**: BG3 reconstructs applied progression state
- rebuilt character survives save/reload and subsequent normal leveling
- later Withers respec can be opened and cancelled normally
- reproduced across multiple older Wyll/Gale saves
- affected character may have fewer entries than donor; copying only the first N compatible entries worked (tested Gale N3 with donor N6)

### Wyll structural observation

Legacy affected state:

```text
L1 Human + Warlock + Fiend
L2 Human + Warlock + Fiend
L3 Human + Warlock + Fiend
```

Native rebuilt state:

```text
L1 Human + Warlock
L2 Human + Warlock
L3 Human + Warlock + Fiend
```

### Safety finding

Please do not treat direct `ProgressionContainer` / `ProgressionMeta` handle copying as the fix. Direct ECS progression manipulation proved unsafe.

The successful boundary was:

```text
compatible LevelUpData
        ↓
native respec initialization
        ↓
CONFIRM level 1
        ↓
BG3 recreates applied progression state
```

### Possible permanent direction

A mod-side migration could potentially detect legacy/incompatible saved `LevelUpData`, translate/reconstruct compatible current choices, validate them, then allow BG3's native respec/reconstruction path to recreate applied progression state.

The repository includes the recovery command, technical notes and migration proposal.

### Credit request

If this recovery method, migration logic, or findings are incorporated into DnD 5.5e, a small credit to **SRStudio-CTRL** for the original legacy-save investigation and Wyll/Gale recovery research would be appreciated.
