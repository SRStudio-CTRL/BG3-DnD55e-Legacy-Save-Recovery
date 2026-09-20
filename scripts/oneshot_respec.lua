-- BG3 DnD 5.5e Legacy Save Recovery
-- Gale & Wyll — OneShot Respec N3/N6
-- Original investigation & recovery method: SRStudio-CTRL
--
-- EXPERIMENTAL. BACK UP YOUR SAVE FIRST.
-- Run through BG3 Script Extender server Lua console.
-- Use a healthy donor JSON from the same companion/current progression setup.
-- After FIX READY, the FIRST recovery respec must be CONFIRMED at level 1.
-- DO NOT cancel that first recovery respec.

local characterUUID = "REPLACE_WITH_CHARACTER_UUID"
local donorFile = "healthy_donor.json"
local backupFile = "legacy_backup.json"

local character = Ext.Entity.Get(characterUUID)
if character == nil then
    print("FIX ABORTED - CHARACTER NOT FOUND")
    return
end

local cc = character:GetComponent("CCLevelUp")
local lu = character:GetComponent("LevelUp")

if cc == nil or lu == nil then
    print("FIX ABORTED - LEVELUP COMPONENT MISSING")
    return
end

local sourceText = Ext.IO.LoadFile(donorFile)
if sourceText == nil then
    print("FIX ABORTED - DONOR FILE NOT FOUND")
    return
end

local source = Ext.Json.Parse(sourceText)
local n = #cc.LevelUps
local backup = {}

for i = 1, n do
    backup[i] = Ext.Types.Serialize(cc.LevelUps[i])
end

Ext.IO.SaveFile(backupFile, Ext.Json.Stringify(backup))

local ok = (n > 0 and #lu.LevelUps == n and #source >= n)

if ok then
    for i = 1, n do
        Ext.Types.Unserialize(cc.LevelUps[i], source[i])
        Ext.Types.Unserialize(lu.LevelUps[i], source[i])
    end

    for i = 1, n do
        if Ext.Json.Stringify(Ext.Types.Serialize(cc.LevelUps[i])) ~= Ext.Json.Stringify(source[i])
        or Ext.Json.Stringify(Ext.Types.Serialize(lu.LevelUps[i])) ~= Ext.Json.Stringify(source[i]) then
            ok = false
        end
    end
end

print(
    ok and "FIX READY - RESPEC AND CONFIRM LEVEL 1" or "FIX ABORTED - DO NOT RESPEC",
    "LEVELS", n,
    "CC", #cc.LevelUps,
    "LU", #lu.LevelUps,
    "DONOR", #source
)
