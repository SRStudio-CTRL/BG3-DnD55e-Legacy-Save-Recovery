-- Healthy LevelUpData donor exporter
-- Original investigation & recovery method: SRStudio-CTRL
--
-- Run this on a HEALTHY save using the SAME companion and CURRENT progression setup.
-- For direct console paste, see DONOR_EXPORT_ONE_LINE.txt.

local characterUUID = "REPLACE_WITH_CHARACTER_UUID"
local outputFile = "healthy_donor.json"

local character = Ext.Entity.Get(characterUUID)
if character == nil then
    print("DONOR EXPORT ABORTED - CHARACTER NOT FOUND")
    return
end

local cc = character:GetComponent("CCLevelUp")
local lu = character:GetComponent("LevelUp")
if cc == nil or lu == nil or cc.LevelUps == nil or lu.LevelUps == nil then
    print("DONOR EXPORT ABORTED - LEVELUP COMPONENT MISSING")
    return
end

local n = #cc.LevelUps
if n == 0 or #lu.LevelUps ~= n then
    print("DONOR EXPORT ABORTED - CC/LU COUNT MISMATCH", "CC", #cc.LevelUps, "LU", #lu.LevelUps)
    return
end

local donor = {}
for i = 1, n do
    local ccData = Ext.Types.Serialize(cc.LevelUps[i])
    local luData = Ext.Types.Serialize(lu.LevelUps[i])
    if Ext.Json.Stringify(ccData) ~= Ext.Json.Stringify(luData) then
        print("DONOR EXPORT ABORTED - CC/LU DATA MISMATCH AT LEVEL", i)
        return
    end
    donor[i] = ccData
end

if Ext.IO.SaveFile(outputFile, Ext.Json.Stringify(donor)) then
    print("DONOR EXPORTED", outputFile, "LEVELS", #donor)
else
    print("DONOR EXPORT ABORTED - FILE WRITE FAILED")
end
