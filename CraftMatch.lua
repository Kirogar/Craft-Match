-- Craft-Match Mini-Test (Schritt 0)
-- Prueft drei Annahmen, bevor Scanner/Store/Sync/Matcher/UI gebaut werden:
--   1) Rezepte lesen beim Oeffnen des Berufsfensters
--   2) Rezept-IDs per Addon-Nachricht an die Gilde senden
--   3) Item-Daten (Itemlevel, Slot, Mindestlevel) fuer das Ergebnis-Item abfragen
-- Da unklar ist, welches Event/API fuer Interface 16001 tatsaechlich greift,
-- loggt dieser Test mehrere Kandidaten gleichzeitig, statt eines zu raten.

local ADDON_PREFIX = "CRAFTMATCH"

local function Print(msg)
    print("|cff33ff99Craft-Match|r: " .. tostring(msg))
end

local hookedProfessionsFrame = false

local function HookProfessionsFrameIfPresent()
    if hookedProfessionsFrame then return end
    if ProfessionsFrame then
        ProfessionsFrame:HookScript("OnShow", function()
            Print("Signal: ProfessionsFrame OnShow.")
            CraftMatch_ScanRecipes()
        end)
        hookedProfessionsFrame = true
        Print("ProfessionsFrame gefunden, OnShow gehookt.")
    end
end

function CraftMatch_ScanRecipes()
    if not C_TradeSkillUI or not C_TradeSkillUI.GetAllRecipeIDs then
        Print("C_TradeSkillUI.GetAllRecipeIDs ist nicht verfuegbar.")
        return
    end

    local ids = C_TradeSkillUI.GetAllRecipeIDs()
    if not ids or #ids == 0 then
        Print("Keine Rezepte gefunden (Berufsfenster evtl. noch nicht bereit).")
        return
    end

    Print(("%d Rezepte gefunden."):format(#ids))
    for i = 1, math.min(3, #ids) do
        local recipeID = ids[i]
        local info = C_TradeSkillUI.GetRecipeInfo(recipeID)
        Print(("  Rezept %d: %s (recipeID %d)"):format(i, info and info.name or "?", recipeID))
    end

    -- Item-Daten fuer das erste Rezept mit einem Ergebnis-Item
    for _, recipeID in ipairs(ids) do
        local outputData = C_TradeSkillUI.GetRecipeOutputItemData
            and C_TradeSkillUI.GetRecipeOutputItemData(recipeID)
        local itemID = outputData and outputData.itemID
        if itemID then
            local item = Item:CreateFromItemID(itemID)
            item:ContinueOnItemLoad(function()
                local name, _, _, itemLevel, itemMinLevel, _, _, _, itemEquipLoc =
                    C_Item.GetItemInfo(itemID)
                Print(("  Item-Test: %s | Slot=%s | ItemLevel=%s | MinLevel=%s"):format(
                    name or "?", tostring(itemEquipLoc), tostring(itemLevel), tostring(itemMinLevel)))
            end)
            break
        end
    end

    CraftMatch_SendRecipeIDs(ids)
end

function CraftMatch_SendRecipeIDs(ids)
    if not C_ChatInfo or not C_ChatInfo.SendAddonMessage then
        Print("C_ChatInfo.SendAddonMessage ist nicht verfuegbar.")
        return
    end

    local sendIDs = {}
    for i = 1, math.min(#ids, 40) do
        sendIDs[i] = ids[i]
    end
    local payload = "RECIPES:" .. table.concat(sendIDs, ",")

    local channel
    if IsInGuild() then
        channel = "GUILD"
    elseif IsInGroup() then
        channel = "PARTY"
    end

    if not channel then
        Print("Nicht in Gilde oder Gruppe, Sync-Test wird nicht gesendet.")
        return
    end

    local result = C_ChatInfo.SendAddonMessage(ADDON_PREFIX, payload, channel)
    Print(("Sync-Test gesendet an %s (%d IDs), Ergebniscode=%s"):format(channel, #sendIDs, tostring(result)))
end

local frame = CreateFrame("Frame", "CraftMatchFrame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("TRADE_SKILL_SHOW")
frame:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
frame:RegisterEvent("TRADE_SKILL_UPDATE")
frame:RegisterEvent("CHAT_MSG_ADDON")

frame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "Blizzard_Professions"
            or addonName == "Blizzard_TradeSkillUI"
            or addonName == "Blizzard_ProfessionsCustomerOrders" then
            Print("ADDON_LOADED: " .. addonName)
            HookProfessionsFrameIfPresent()
        end
    elseif event == "PLAYER_LOGIN" then
        C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)
        HookProfessionsFrameIfPresent()
        Print("Mini-Test geladen. Berufsfenster oeffnen oder /cm eingeben.")
    elseif event == "TRADE_SKILL_SHOW" then
        Print("Signal: Event TRADE_SKILL_SHOW.")
        CraftMatch_ScanRecipes()
    elseif event == "TRADE_SKILL_LIST_UPDATE" then
        Print("Signal: Event TRADE_SKILL_LIST_UPDATE.")
    elseif event == "TRADE_SKILL_UPDATE" then
        Print("Signal: Event TRADE_SKILL_UPDATE.")
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, message, _, sender = ...
        if prefix == ADDON_PREFIX then
            local idList = message:match("^RECIPES:(.+)$")
            if idList then
                local count = 0
                for _ in idList:gmatch("[^,]+") do
                    count = count + 1
                end
                Print(("Nachricht von %s: %d Rezept-IDs empfangen."):format(sender, count))
            else
                Print(("Nachricht von %s: %s"):format(sender, message))
            end
        end
    end
end)

SLASH_CRAFTMATCH1 = "/cm"
SlashCmdList["CRAFTMATCH"] = function()
    Print("Status: Mini-Test aktiv. ProfessionsFrame gehookt: " .. tostring(hookedProfessionsFrame))
    HookProfessionsFrameIfPresent()
    if ProfessionsFrame and ProfessionsFrame:IsShown() then
        CraftMatch_ScanRecipes()
    else
        Print("Berufsfenster ist nicht offen. Oeffnen und /cm erneut eingeben.")
    end
end
