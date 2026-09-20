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

## BG3SE OneShot — single-line console command

> [!CAUTION]
> This is an experimental save-recovery procedure. **Make a separate save backup first.**
> Use a healthy donor from the same companion/current progression setup.
> Only continue if the console prints `FIX READY`.

Replace `REPLACE_WITH_CHARACTER_UUID` with the target companion UUID and ensure `healthy_donor.json` contains the healthy donor data.

```lua
character=Ext.Entity.Get("REPLACE_WITH_CHARACTER_UUID"); cc=character:GetComponent("CCLevelUp"); lu=character:GetComponent("LevelUp"); source=Ext.Json.Parse(Ext.IO.LoadFile("healthy_donor.json")); n=#cc.LevelUps; backup={}; for i=1,n do backup[i]=Ext.Types.Serialize(cc.LevelUps[i]) end; Ext.IO.SaveFile("legacy_backup.json",Ext.Json.Stringify(backup)); ok=(n>0 and #lu.LevelUps==n and #source>=n); if ok then for i=1,n do Ext.Types.Unserialize(cc.LevelUps[i],source[i]); Ext.Types.Unserialize(lu.LevelUps[i],source[i]) end; for i=1,n do if Ext.Json.Stringify(Ext.Types.Serialize(cc.LevelUps[i]))~=Ext.Json.Stringify(source[i]) or Ext.Json.Stringify(Ext.Types.Serialize(lu.LevelUps[i]))~=Ext.Json.Stringify(source[i]) then ok=false end end end; print(ok and "FIX READY - RESPEC AND CONFIRM LEVEL 1" or "FIX ABORTED - DO NOT RESPEC","LEVELS",n,"CC",#cc.LevelUps,"LU",#lu.LevelUps,"DONOR",#source)
```

Known companion UUIDs used during testing:

```text
Wyll: c774d764-4a17-48dc-b470-32ace9ce447d
Gale: ad9af97d-75da-406a-ae13-7071c563f604
```

If the output is:

```text
FIX READY - RESPEC AND CONFIRM LEVEL 1
```

go to Withers, choose **Change Class**, select the intended class, and **CONFIRM level 1**. Rebuild the remaining levels normally.

If the output says:

```text
FIX ABORTED - DO NOT RESPEC
```

stop. Do not use the recovery respec.

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
