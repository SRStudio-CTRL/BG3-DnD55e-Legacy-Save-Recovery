# BG3 DnD 5.5e — Legacy Save Recovery

Experimental recovery research for **Baldur's Gate 3** legacy saves affected by companion **level-up / Withers respec crashes** after progression-table changes.

The recovery method documented here was reproduced on **Wyll and Gale across multiple older saves**. It is not an official fix and does not prove that every similar crash has the same cause.

## Gale & Wyll — OneShot Respec N3/N6

### What was observed

Affected legacy saves could lag, freeze, or crash when Wyll or Gale entered normal level-up or Withers respec, while fresh characters using the current progression setup worked normally.

Inspection through BG3 Script Extender showed legacy `LevelUpData` and applied progression state that differed from a healthy current character.

A particularly useful Wyll comparison was:

```text
Legacy save:
L1 Human + Warlock + Fiend
L2 Human + Warlock + Fiend
L3 Human + Warlock + Fiend

After native reconstruction:
L1 Human + Warlock
L2 Human + Warlock
L3 Human + Warlock + Fiend
```

The reconstructed level-3 Fiend progression observed in testing was:

```text
TYPE        ProgressionSubClass
SOURCE      8866db28-7dda-4fd6-93ed-20eca16314f0
PROGRESSION 428e4841-ff37-4b12-afb8-8bb26577a5c9
LEVEL       3
CLASSLEVEL  3
```

## Recovery principle

The successful procedure does **not** manually repair `ProgressionContainer` or `ProgressionMeta`.

Instead:

1. Export compatible `LevelUpData` from a healthy version of the same companion/current progression setup.
2. Deep-copy the compatible entries into both `CCLevelUp.LevelUps` and `LevelUp.LevelUps`.
3. Open Withers respec.
4. **CONFIRM the first recovery respec at level 1. Do not cancel it.**
5. Let BG3 rebuild its own progression entities through the native respec process.
6. Level normally and verify save/reload.

BG3SE provides the useful deep-copy mechanism:

```lua
Ext.Types.Serialize(LevelUpData)
Ext.Types.Unserialize(existingLevelUpData, serializedTable)
```

### Level-adaptive donor behavior

The donor does not need exactly the same number of entries as the affected character. In one reproduced test:

```text
Affected Gale: 3 LevelUpData entries
Healthy donor: 6 LevelUpData entries
Copied: donor entries 1–3 only
Result: recovery successful
```

The donor must therefore contain **at least N compatible entries**, where N is the number of entries currently present on the affected character.

## BG3SE recovery scripts

> [!CAUTION]
> This is an experimental save-recovery procedure. **Make a separate game save backup first.**
> A JSON file written by the script is useful diagnostic backup data, but it is **not a substitute for an untouched BG3 save**.

The repository now contains guarded scripts for both stages:

- `scripts/export_healthy_donor.lua` — readable donor exporter
- `scripts/DONOR_EXPORT_ONE_LINE.txt` — paste-ready donor exporter for the BG3SE console
- `scripts/oneshot_respec.lua` — readable recovery script
- `scripts/BG3SE_ONE_LINE.txt` — paste-ready recovery command for the BG3SE console

### 1. Export the healthy donor

Use a **healthy save of the same companion under the current progression setup**. The exporter verifies that the companion's `CCLevelUp` and `LevelUp` arrays have the same count and serialize identically before writing `healthy_donor.json`.

Known UUIDs used during testing:

```text
Wyll: c774d764-4a17-48dc-b470-32ace9ce447d
Gale: ad9af97d-75da-406a-ae13-7071c563f604
```

The healthy donor must contain at least as many `LevelUpData` entries as the affected character.

### 2. Run the recovery on the affected save

Use the **same companion UUID** and the donor generated in step 1. The hardened recovery script checks:

- target entity exists
- both level-up components exist
- donor file exists and parses as JSON
- CC/LU entry counts match
- donor has at least N entries
- a character-specific CC+LU diagnostic backup can be written
- both destination arrays match the donor after the deep write

Only proceed if the console prints:

```text
FIX READY - RESPEC AND CONFIRM LEVEL 1
```

Then go to Withers → **Change Class** → choose the intended class → **CONFIRM level 1** → rebuild the remaining levels normally.

> [!IMPORTANT]
> **Do not cancel the first recovery respec.**
>
> If the script reports an error, `FIX ABORTED`, or verification failure, do not enter the recovery respec. If an error occurs after mutation has started, reload the untouched game save.

The exact single-line commands are kept in the `scripts/*_ONE_LINE.txt` files rather than duplicated here, so the README cannot drift away from the maintained console versions.

## Validation

Wyll was rebuilt through the native respec path and subsequently produced:

```text
L1  2 progression entries
L2  2
L3  3  <- Fiend
L4  3
L5  2
L6  2
L7  2
```

Validation performed:

- confirmed native respec: PASS
- rebuild L1 → L6: PASS
- save: PASS
- reload: PASS
- normal L6 → L7 level-up: PASS
- reopen Withers respec: PASS
- cancel a later respec normally: PASS
- no previous lag/crash observed after recovery

The same recovery principle was reproduced on Gale and on additional older Wyll/Gale saves.

## What NOT to copy manually

Do not manually transplant or rewrite:

- `ProgressionContainer` handles
- `ProgressionMeta` entities
- another character's Experience
- another character's AvailableLevel
- another character's Classes
- forced character levels

Direct ECS progression manipulation proved unsafe during investigation. The stable recovery path observed here is to let the **native confirmed respec** recreate progression state.

## Migration hypothesis

The working hypothesis is that some legacy saves retain `LevelUpData` and/or applied progression state generated against older progression tables. The current system can then fail while constructing level-up/respec before the native respec process gets a chance to rebuild that state.

A possible mod-side migration strategy is therefore:

```text
Detect legacy/incompatible LevelUpData
            ↓
Translate/rebuild compatible LevelUpData
            ↓
Allow native respec initialization
            ↓
Let native confirmed respec rebuild progression state
```

This is a **hypothesis based on reproduced save behavior**, not a claim that every level-up/respec crash has the same underlying cause.

## Credits

**Original investigation & recovery method: [SRStudio-CTRL](https://github.com/SRStudio-CTRL)**

**Gale & Wyll — OneShot Respec N3/N6 — Legacy Save Recovery**

If this recovery method, migration logic, or any part of these findings is integrated into another BG3 mod/project, a small credit to **SRStudio-CTRL** for the original legacy-save investigation and Wyll/Gale recovery research would be appreciated.

## Project status

Experimental / reproduced recovery research. Contributions and independent reproduction reports are welcome.
