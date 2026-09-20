-- BG3 DnD 5.5e Legacy Save Recovery
-- Original investigation & recovery method: SRStudio-CTRL
--
-- EXPERIMENTAL. MAKE A SEPARATE GAME SAVE BACKUP FIRST.
-- This readable version is intended for review/file execution.
-- For direct BG3SE console paste, use BG3SE_ONE_LINE.txt.
--
-- The donor must be the SAME companion under the CURRENT progression setup.
-- After FIX READY, the FIRST recovery respec MUST be CONFIRMED at level 1.
-- If anything aborts/errors after mutation, DO NOT RESPEC: reload the untouched game save.

local characterUUID = "REPLACE_WITH_CHARACTER_UUID"
local donorFile = "healthy_donor.json"
local backupFile = "legacy_backup_" .. characterUUID .. ".json"

local character = Ext.Entity.Get(characterUUID)
if character == nil then
    print("FIX ABORTED - CHARACTER NOT FOUND")
    return
end

local cc = character:GetComponent("CCLevelUp")
local lu = character:GetComponent("LevelUp")
if cc == nil or lu == nil or cc.LevelUps == nil or lu.LevelUps == nil then
    print("FIX ABORTED - LEVELUP COMPONENT MISSING")
    return
end

local sourceText = Ext.IO.LoadFile(donorFile)
if sourceText == nil then
    print("FIX ABORTED - DONOR FILE NOT FOUND")
    return
end

local parseOK, source = pcall(Ext.Json.Parse, sourceText)
if not parseOK or type(source) ~= "table" then
    print("FIX ABORTED - INVALID DONOR JSON")
    return
end

local n = #cc.LevelUps
if n == 0 or #lu.LevelUps ~= n or #source < n then
    print("FIX ABORTED - DO NOT RESPEC", "LEVELS", n, "CC", #cc.LevelUps, "LU", #lu.LevelUps, "DONOR", #source)
    return
end

local backup = { CC = {}, LU = {} }
for i = 1, n do
    backup.CC[i] = Ext.Types.Serialize(cc.LevelUps[i])
    backup.LU[i] = Ext.Types.Serialize(lu.LevelUps[i])
end

if not Ext.IO.SaveFile(backupFile, Ext.Json.Stringify(backup)) then
    print("FIX ABORTED - BACKUP WRITE FAILED")
    return
end

local writeOK = pcall(function()
    for i = 1, n do
        Ext.Types.Unserialize(cc.LevelUps[i], source[i])
        Ext.Types.Unserialize(lu.LevelUps[i], source[i])
    end
end)

if not writeOK then
    print("FIX ABORTED - WRITE ERROR - RELOAD YOUR UNTOUCHED GAME SAVE")
    return
end

local ok = true
for i = 1, n do
    if Ext.Json.Stringify(Ext.Types.Serialize(cc.LevelUps[i])) ~= Ext.Json.Stringify(source[i])
    or Ext.Json.Stringify(Ext.Types.Serialize(lu.LevelUps[i])) ~= Ext.Json.Stringify(source[i]) then
        ok = false
        break
    end
end

print(
    ok and "FIX READY - RESPEC AND CONFIRM LEVEL 1"
       or "FIX ABORTED - VERIFICATION FAILED - RELOAD YOUR UNTOUCHED GAME SAVE",
    "LEVELS", n, "CC", #cc.LevelUps, "LU", #lu.LevelUps, "DONOR", #source
)
