-- 1. Datenbank & Hauptvariablen
local function InitializeDB()
    if not DidYouDieDB then
        DidYouDieDB = { count = 0, unlockKey = 1 }
    end
    if not DidYouDieDB.unlockKey then
        DidYouDieDB.unlockKey = 1
    end
end

-- -------------------------------------------------------
-- 2. Das visuelle Warn-Element
-- -------------------------------------------------------
local FRAME_W = 800
local FRAME_H = 180

local deathFrame = CreateFrame("Frame", "DidYouDieDeathFrame", UIParent)
deathFrame:SetSize(FRAME_W, FRAME_H)
deathFrame:SetFrameStrata("TOOLTIP")
deathFrame:Hide()

local deathText = deathFrame:CreateFontString(nil, "OVERLAY")
deathText:SetFont("Fonts\\FRIZQT__.TTF", 72, "OUTLINE, THICKOUTLINE")
deathText:SetPoint("TOP", deathFrame, "TOP", 0, 0)
deathText:SetTextColor(1, 0, 0, 1)

-- Frecher Kommentar in Weiß
local TAUNT_LINES = {
    -- Klassiker
    "Na keinen CD gezogen?",
    "Skill issue.",
    "Touch grass, dann touch Wiederbelebung.",
    "Der Boden ist dein Freund jetzt.",
    "GG EZ.",
    "Hast du den Raidboss um Erlaubnis gefragt?",
    "Dein Heiler weint gerade.",
    "Wenigstens stirbst du konsistent.",
    "Schon wieder? Respekt für die Ausdauer.",
    "Der Friedhof kennt deinen Namen auswendig.",
    "Vielleicht hilft ein neues Talent-Build.",
    "Das nächste Mal einfach nicht sterben.",
    -- Heiler-Witze
    "Dein Heiler war gerade AFK. Natürlich.",
    "Healer: 'Ich hab geheilt!' Du: *tot*",
    "Schon mal überlegt, Heiler zu spielen? Ach nein, die sterben ja auch.",
    "Der Heiler hat dich gesehen. Er hat sich entschieden.",
    "Laut Heiler war das deine Schuld.",
    "Der Heiler postet gerade deinen Tod im Gildenchat.",
    -- Tank-Witze
    "Der Tank fragt: 'Wer hat Aggro?' Antwort: der Boden.",
    "Taunt ist keine Beleidigung, sondern eine Fähigkeit. Benutze sie.",
    "Der Tank dreht sich um: 'Alle da?' Nein.",
    "Vielleicht hättest du den Boss nicht angetanzt.",
    -- DPS-Witze
    "Laut Skada warst du auf Platz 1. Kurz.",
    "Die Schadensanzeige zeigt 0. Weil tot.",
    "Stand in der Fläche UND hat trotzdem nicht voll DPS gemacht.",
    "Meter pushen bis zum Tod. Respekt für die Hingabe.",
    -- Klassische WoW-Momente
    "Leeroy Jenkins hätte das genauso gemacht.",
    "Wenigstens hast du nicht den ganzen Raid mitgerissen. Diesmal.",
    "Das war bestimmt ein Lags.",
    "Diese Fläche war nicht in der Raidführung erwähnt. Oder doch?",
    "Haben wir heute schon den Spiritheiler umarmt? Ja, haben wir.",
    "Du hast den Mechanismus gecheckt. Der Mechanismus hat zurückgecheckt.",
    "Die Bosse respektieren Hartnäckigkeit. Leider auch deine.",
    "Willkommen in der Graveyard-Perspektive.",
    "Schritt 1: Nicht in die Fläche stehen. Schritt 2: existiert nicht mehr.",
    "Feuer am Boden ist immer schlecht. Immer.",
    "Der Raidleiter nimmt tief Luft.",
    "Irgendwo weint gerade ein Classic-Spieler für dich.",
    "Der Spiritheiler sagt: 'Schon wieder du.'",
    "Nicht der MVP. Nicht mal der MIP. Einfach tot.",
    "Voll repariert rein, gebrochen raus.",
    "Deine Ausrüstung ist jetzt auf 0 Haltbarkeit. Gut gemacht.",
    "One shot? One shot.",
    "Der Boss hat nicht mal eine Zwischensequenz gespielt. Du warst so unwichtig.",
    "Laut Warcraftlogs war das 100% vermeidbar.",
    "Haben wir den Enrage schon? Nein, nur du bist tot.",
    "Der Raidleiter öffnet gerade Warcraftlogs.",
    "Die Heiler haben mich ignoriert!",
    "Einfach mal stark sein!",
    "Einfach mal stärker sein.",
    "Einfach Todesstoß drücken.",
    "Mach doch mal die Augen auf.",
    "Schon wieder?",
}

local tauntText = deathFrame:CreateFontString(nil, "OVERLAY")
tauntText:SetFont("Fonts\\FRIZQT__.TTF", 28, "OUTLINE")
tauntText:SetPoint("TOP", deathText, "BOTTOM", 0, -8)
tauntText:SetTextColor(1, 1, 1, 1)

-- -------------------------------------------------------
-- DVD-Bounce Physik
-- -------------------------------------------------------
local SPEED = 180

local posX, posY = 0, 0
local vx, vy     = SPEED, SPEED * 0.7

local function InitBounce()
    posX = 0
    posY = 50
    vx   = SPEED
    vy   = SPEED * 0.7
end

deathFrame:SetScript("OnUpdate", function(self, elapsed)
    local limitX = UIParent:GetWidth()  * 0.5 - FRAME_W * 0.5
    local limitY = UIParent:GetHeight() * 0.5 - FRAME_H * 0.5

    posX = posX + vx * elapsed
    posY = posY + vy * elapsed

    if posX >= limitX then
        posX = limitX
        vx = -math.abs(vx)
    elseif posX <= -limitX then
        posX = -limitX
        vx =  math.abs(vx)
    end

    if posY >= limitY then
        posY = limitY
        vy = -math.abs(vy)
    elseif posY <= -limitY then
        posY = -limitY
        vy =  math.abs(vy)
    end

    self:ClearAllPoints()
    self:SetPoint("CENTER", UIParent, "CENTER", posX, posY)
end)

-- -------------------------------------------------------
-- Blinken-Animation
-- -------------------------------------------------------
local animationGroup = deathFrame:CreateAnimationGroup()

local alphaOut = animationGroup:CreateAnimation("Alpha")
alphaOut:SetFromAlpha(1)
alphaOut:SetToAlpha(0.1)
alphaOut:SetDuration(0.4)
alphaOut:SetOrder(1)
alphaOut:SetSmoothing("IN_OUT")

local alphaIn = animationGroup:CreateAnimation("Alpha")
alphaIn:SetFromAlpha(0.1)
alphaIn:SetToAlpha(1)
alphaIn:SetDuration(0.4)
alphaIn:SetOrder(2)
alphaIn:SetSmoothing("IN_OUT")

animationGroup:SetLooping("REPEAT")

-- -------------------------------------------------------
-- 3. Die "Geist freilassen" Sperre (konfigurierbare Taste)
-- -------------------------------------------------------
local KEY_OPTIONS = {
    { label = "Shift",  check = IsShiftKeyDown                 },
    { label = "Strg",   check = IsControlKeyDown               },
    { label = "Alt",    check = IsAltKeyDown                   },
    { label = "Keine",  check = function() return true end     },
}

local selectedKeyIndex = 1

local function IsUnlockKeyDown()
    return KEY_OPTIONS[selectedKeyIndex].check()
end

local function GetUnlockKeyLabel()
    return KEY_OPTIONS[selectedKeyIndex].label
end

local function LockDeathButton()
    local button = _G["StaticPopup1Button1"]
    if button and button:IsVisible() and StaticPopup1.which == "DEATH" then
        if IsUnlockKeyDown() then
            button:Enable()
            button:SetText("JETZT FREILASSEN")
        else
            button:Disable()
            button:SetText(GetUnlockKeyLabel() .. " HALTEN!")
        end
    end
end

local lockFrame = CreateFrame("Frame")
lockFrame:SetScript("OnUpdate", function(self, elapsed)
    if deathFrame:IsShown() then
        LockDeathButton()
    end
end)

-- -------------------------------------------------------
-- 4. Options-Panel & Reset
-- -------------------------------------------------------
local panel = CreateFrame("Frame", "DidYouDieOptionsPanel", UIParent)
panel.name = "DidYouDie"

-- Titel
local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("DidYouDie Einstellungen")

-- Todesanzahl
local statText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
statText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -20)

local function UpdateMenuText()
    local count = (DidYouDieDB and DidYouDieDB.count) or 0
    statText:SetText("Gesamtanzahl der Tode: |cFFFF0000" .. count .. "|r")
end

-- Reset-Button
local resetButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
resetButton:SetPoint("TOPLEFT", statText, "BOTTOMLEFT", 0, -12)
resetButton:SetText("Zähler zurücksetzen")
resetButton:SetSize(160, 25)
resetButton:SetScript("OnClick", function()
    DidYouDieDB.count = 0
    UpdateMenuText()
end)

-- Abschnitt: Tastenauswahl
local keyHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
keyHeader:SetPoint("TOPLEFT", resetButton, "BOTTOMLEFT", 0, -20)
keyHeader:SetText("Taste zum Freischalten des Geist-Buttons:")

-- Radio-Buttons werden in einer Tabelle gespeichert damit wir sie updaten können
local radioButtons = {}

local function UpdateRadioButtons()
    for i, rb in ipairs(radioButtons) do
        rb:SetChecked(i == selectedKeyIndex)
    end
end

local prevAnchor = keyHeader
for i, option in ipairs(KEY_OPTIONS) do
    local rb = CreateFrame("CheckButton", "DidYouDieKey" .. i, panel, "UIRadioButtonTemplate")
    rb:SetPoint("TOPLEFT", prevAnchor, "BOTTOMLEFT", 0, -8)
    rb.value = i

    -- Label neben dem Radio-Button
    local lbl = rb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    lbl:SetPoint("LEFT", rb, "RIGHT", 4, 0)
    lbl:SetText(option.label)

    rb:SetScript("OnClick", function(self)
        selectedKeyIndex        = self.value
        DidYouDieDB.unlockKey = selectedKeyIndex
        UpdateRadioButtons()
    end)

    radioButtons[i] = rb
    prevAnchor = rb
end

local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
Settings.RegisterAddOnCategory(category)

-- -------------------------------------------------------
-- 5. Event-Handler
-- -------------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("PLAYER_ALIVE")
frame:RegisterEvent("PLAYER_UNGHOST")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "DidYouDie" then
        InitializeDB()
        selectedKeyIndex = DidYouDieDB.unlockKey or 1
        UpdateRadioButtons()
        UpdateMenuText()

    elseif event == "PLAYER_DEAD" then
        DidYouDieDB.count = (DidYouDieDB.count or 0) + 1
        deathText:SetText("Bleib liegen du Pfosten!  (Tod Nr. " .. DidYouDieDB.count .. ")")
        tauntText:SetText(TAUNT_LINES[math.random(#TAUNT_LINES)])
        InitBounce()
        deathFrame:Show()
        animationGroup:Play()
        UpdateMenuText()

    elseif event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST" then
        if not UnitIsDeadOrGhost("player") then
            animationGroup:Stop()
            deathFrame:Hide()
        end
    end
end)
