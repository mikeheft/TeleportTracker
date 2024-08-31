local TeleportTracker = CreateFrame("Frame")
local arrowFrame = CreateFrame("Frame", "TeleportArrow", UIParent)
local lastLocation = {}

-- Setup Arrow frame
arrowFrame:SetSize(50, 50)
arrowFrame:SetPoint("CENTER")
arrowFrame.texture = arrowFrame:CreateTexture(nil, "BACKGROUND")
arrowFrame.texture:SetAllPoints()
arrowFrame.texture:SetTexture("Interface\\Addons\\TeleportTracker\\arrow.blend")
arrowFrame:Hide()

local function UpdateArrow()
  if not lastLocation.x then
    arrowFrame:Hide()
    return
  end

  local playerX, playerY = UnitPosition("player")
  local dx = lastLocation.x - playerX
  local dy = lastLocation.y - playerY
  local distance = math.sqrt(dx * dx + dy * dy)

  -- calculate angle to target
  local angle = math.atan2(dy, dx) - GetPlayerFacing()
  arrowFrame:SetRotation(angle)

  -- change color based on distance
  if distance > 40 then
    arrowFrame.texture:SetVertexColor(1, 0, 0) -- Red if far
  elseif distance > 30 then
    arrowFrame.texture:SetVertexColor(1, 1, 0) -- Yellow if mid-range
  else
    arrowFrame.texture:SetVertexColor(0, 1, 0) -- Green if close
  end

  arrowFrame:Show()
end

local function SaveTeleportPosition()
  local x, y = UnitPosition("player")
  lastLocation.x = x
  lastLocation.y = y
end

TeleportTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
TeleportTracker:SetScript("OnEvent", function(self, event, ...)
  local _, subevent, _, sourceGUID, _, _, _, _, _, _, _, spellId = CombatLogGetCurrentEventInfo()

  if subevent == "SPELL_CAST_SUCCESS" and sourceGUID == UnitGUID("player") then
    if spellId == 48018 then -- Warlock Demonic Circle: Summon
      SaveTeleportPosition()
    end
  end
end)

TeleportTracker:SetScript("OnUpdate", UpdateArrow)
