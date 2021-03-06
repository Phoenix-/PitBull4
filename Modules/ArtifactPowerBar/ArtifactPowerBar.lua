
local PitBull4 = _G.PitBull4
local L = PitBull4.L

local EXAMPLE_VALUE = 0.3

local PitBull4_ArtifactPowerBar = PitBull4:NewModule("ArtifactPowerBar", "AceEvent-3.0")

local bfa_800 = select(4, GetBuildInfo()) >= 80000

PitBull4_ArtifactPowerBar:SetModuleType("bar")
PitBull4_ArtifactPowerBar:SetName(L["Artifact power bar"])
PitBull4_ArtifactPowerBar:SetDescription(L["Show an artifact power bar."])
PitBull4_ArtifactPowerBar:SetDefaults({
	size = 1,
	position = 8,
})

local C_ArtifactUI = _G.C_ArtifactUI

local function GetArtifactXP()
	if HasArtifactEquipped() then
		local _, _, _, _, artifactXP, pointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI.GetEquippedArtifactInfo()
		local xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent, artifactTier)
		while artifactXP >= xpForNextPoint and xpForNextPoint > 0 do
			artifactXP = artifactXP - xpForNextPoint
			pointsSpent = pointsSpent + 1
			xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent, artifactTier)
		end
		return artifactXP, xpForNextPoint
	elseif bfa_800 then
		local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
		if azeriteItemLocation then
			return C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
		end
	end
end

function PitBull4_ArtifactPowerBar:OnEnable()
	self:RegisterEvent("ARTIFACT_XP_UPDATE")
	if bfa_800 then
		self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED", "ARTIFACT_XP_UPDATE")
	end
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ARTIFACT_XP_UPDATE")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED") -- handle (un)equip
end

function PitBull4_ArtifactPowerBar:ARTIFACT_XP_UPDATE()
	self:UpdateForUnitID("player")
end

function PitBull4_ArtifactPowerBar:PLAYER_EQUIPMENT_CHANGED(_, slot)
	if slot == 16 or slot == 17 or slot == 2 then -- weapon slots (legion)/neck (bfa)
		self:UpdateForUnitID("player")
	end
end

function PitBull4_ArtifactPowerBar:GetValue(frame)
	if frame.unit ~= "player" then
		return
	end

	local value, max = GetArtifactXP()
	if value then
		return value / max
	end
end
function PitBull4_ArtifactPowerBar:GetExampleValue(frame)
	if frame and frame.unit ~= "player" then
		return nil
	end
	return EXAMPLE_VALUE
end

function PitBull4_ArtifactPowerBar:GetColor(frame, value)
	return .901, .8, .601
end
