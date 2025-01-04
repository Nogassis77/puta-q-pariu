setDefaultTab("PVP")

-- Define a validade do script (até 31 de dezembro de 2025)
local expirationDate = os.time({year=2025, month=12, day=31})
local hasSpoken = false
local macrosVisible = false -- Variável para controlar a visibilidade dos macros

-- Função para verificar a validade do script
local function checkValidity()
    if hasSpoken then
        return false
    end

    local currentDate = os.time()
    if currentDate <= expirationDate then
        g_game.talk("")
        hasSpoken = true
        return true
    else
        g_game.talk("fechado")
        hasSpoken = true
        return false
    end
end

-- Criação da interface principal com um único botão
local ui = setupUI([[
Panel
  height: 40

  Button
    id: checkButton
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 10
    height: 30
    text: 'COMPILADO'
    font: verdana-11px-rounded
]])

ui:show()

-- Função do botão para verificar a validade e alternar a visibilidade dos macros
ui.checkButton.onClick = function(widget)
    if checkValidity() then
        macrosVisible = not macrosVisible
        if macrosVisible then
		setDefaultTab("PVP")
local leaders = {"Nogzin"} -- Lista de líderes a serem seguidos
local currentLeaderIndex = 1 -- Índice do líder atual
local previousLeaderPos = nil -- Posição anterior do líder

macro(1, "Movimentacao", "Shift+F1", function()
    local leaderName = leaders[currentLeaderIndex]
    local leader = getCreatureByName(leaderName)
    
    if not leader then
        -- Se o líder atual não for encontrado, muda para o próximo líder na lista
        currentLeaderIndex = currentLeaderIndex % #leaders + 1
        leaderName = leaders[currentLeaderIndex]
        leader = getCreatureByName(leaderName)
    end

    if leader then
        local currentLeaderPos = leader:getPosition()
        local leaderDir = leader:getDirection()
        
        -- Vira para a mesma direção que o líder
        if player:getDirection() ~= leaderDir then
            turn(leaderDir)
        end

        -- Verifica se a posição do líder mudou
        if previousLeaderPos and (currentLeaderPos.x ~= previousLeaderPos.x or currentLeaderPos.y ~= previousLeaderPos.y) then
            local newPos = nil
            if leaderDir == 0 then
                -- Norte
                newPos = {x=pos().x, y=pos().y-1, z=pos().z}
            elseif leaderDir == 1 then
                -- Leste
                newPos = {x=pos().x+1, y=pos().y, z=pos().z}
            elseif leaderDir == 2 then
                -- Sul
                newPos = {x=pos().x, y=pos().y+1, z=pos().z}
            elseif leaderDir == 3 then
                -- Oeste
                newPos = {x=pos().x-1, y=pos().y, z=pos().z}
            end

            -- Verifica se a nova posição é acessível usando findPath
            if newPos then
                autoWalk(newPos)
            end
        end
        
        -- Atualiza a posição anterior do líder
        previousLeaderPos = currentLeaderPos
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Nomes dos personagens para o follow, em ordem de prioridade
local followPriority = {"Nogzin"}

-- Variável para armazenar a última posição conhecida
local lastPos = nil

-- Variável para armazenar o líder atual
local currentLeaderName = nil

-- Função para obter o líder com maior prioridade disponível
local function getHighestPriorityLeader()
    for _, name in ipairs(followPriority) do
        local leader = getCreatureByName(name)
        if leader and not leader:isDead() then
            return name, leader
        end
    end
    return nil, nil
end

-- Macro para seguir o líder sem interferir nos ataques
macro(1, "Follow Pica", "Shift + F1", function()
    -- Verifica se o personagem está atacando
    local isAttacking = g_game.getAttackingCreature() and not g_game.getAttackingCreature():isDead()

    -- Obtém o líder com maior prioridade disponível
    local leaderName, leader = getHighestPriorityLeader()

    if leaderName then
        -- Se o líder mudou ou o follow não está correto, atualiza o follow
        if not isAttacking and (currentLeaderName ~= leaderName or g_game.getFollowingCreature() ~= leader) then
            currentLeaderName = leaderName
            g_game.follow(leader)
        end
    else
        -- Se nenhum líder estiver disponível, caminha para a última posição conhecida
        if lastPos then
            player:autoWalk(lastPos)
            currentLeaderName = nil
        end
    end
end)

-- Evento para rastrear a posição do líder
onCreaturePositionChange(function(creature, newPos, oldPos)
    if not newPos then return end

    for _, name in ipairs(followPriority) do
        if creature:getName() == name then
            lastPos = newPos
            return
        end
    end
end)
--------------------------------------------------------------------------------------------------------------------------
-- Lista de líderes a seguir em ordem de prioridade
local followPriority = {"Nogzin"}

-- Armazena a posição dos líderes por andar
local toFollowPos = {}

-- Variável para armazenar o nome do líder atual
local currentLeaderName = nil

-- Função para obter o líder com maior prioridade disponível
local function getHighestPriorityLeader()
    for _, name in ipairs(followPriority) do
        local leader = getCreatureByName(name)
        if leader and not leader:isDead() then
            return name, leader
        end
    end
    return nil, nil
end

-- Botão para ativar/desativar o macro de seguir
local followMacro = macro(1, "Follow Pica", "Shift + F1", function()
    -- Obtém o líder com maior prioridade disponível
    local leaderName, leader = getHighestPriorityLeader()

    -- Atualiza o nome do líder atual
    if leaderName and (currentLeaderName ~= leaderName or not toFollowPos[leader:getPosition().z]) then
        currentLeaderName = leaderName
    end

    -- Atualiza a posição do líder atual
    if leader then
        local tpos = leader:getPosition()
        if tpos then
            toFollowPos[tpos.z] = tpos
        end
    end

    -- Move-se para a posição do líder atual
    if player:isWalking() then return end
    local p = currentLeaderName and toFollowPos[posz()]
    if not p then return end
    if autoWalk(p, 20, {ignoreNonPathable = true, precision = 1}) then
        delay(100)
    end
end)

-- Atualiza a posição do líder sempre que ele se mover
onCreaturePositionChange(function(creature, oldPos, newPos)
    for _, name in ipairs(followPriority) do
        if creature:getName() == name then
            if newPos then  -- Verifica se newPos não é nil
                toFollowPos[newPos.z] = newPos
            end
            return
        end
    end
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function calculateDistance(pos1, pos2)
    return math.abs(pos1.x - pos2.x) + math.abs(pos1.y - pos2.y)
end

local function isValidTile(tile)
    if not tile then
        return false
    end
    local topThing = tile:getTopUseThing()
    return topThing and not tile:hasCreature()
end

local function getNeighborTiles(pos)
    local directions = {
        {x = 0, y = -1},   -- Norte
        {x = 0, y = 1},    -- Sul
        {x = -1, y = 0},   -- Oeste
        {x = 1, y = 0},    -- Leste
        {x = -1, y = -1},  -- Noroeste
        {x = 1, y = -1},   -- Nordeste
        {x = 1, y = 1},    -- Sudeste
        {x = -1, y = 1}    -- Sudoeste
    }
    local neighbors = {}
    for _, dir in ipairs(directions) do
        local neighborPos = {x = pos.x + dir.x, y = pos.y + dir.y, z = pos.z}
        local neighborTile = g_map.getTile(neighborPos)
        if neighborTile and isValidTile(neighborTile) then
            table.insert(neighbors, neighborTile)
        end
    end
    return neighbors
end

local function getPassageTiles(target)
    local targetPos = target:getPosition()
    local validTiles = getNeighborTiles(targetPos)

    if #validTiles == 2 then
        return validTiles
    end

    table.sort(validTiles, function(a, b)
        local distA = calculateDistance(a:getPosition(), targetPos)
        local distB = calculateDistance(b:getPosition(), targetPos)
        return distA < distB
    end)

    return validTiles
end

local lastPosition = nil

trapzera = macro(1," ", "F2", function()
    local target = g_game.getAttackingCreature()
    if not target then return end

    local currentPosition = target:getPosition()

    if lastPosition and calculateDistance(lastPosition, currentPosition) > 0 then
        local direction = target:getDirection()
        local mwPos = {x = currentPosition.x, y = currentPosition.y, z = currentPosition.z}

        if direction == 0 then
            mwPos.y = mwPos.y - 3 -- Norte
        elseif direction == 1 then
            mwPos.x = mwPos.x + 3 -- Leste
        elseif direction == 2 then
            mwPos.y = mwPos.y + 3 -- Sul
        elseif direction == 3 then
            mwPos.x = mwPos.x - 3 -- Oeste
        end

        local mwTile = g_map.getTile(mwPos)
        if mwTile then
            g_game.useInventoryItemWith(3180, mwTile:getTopUseThing())
        end
    else
        local passageTiles = getPassageTiles(target)
        for _, tile in ipairs(passageTiles) do
            local topThing = tile:getTopUseThing()
            if topThing then
                g_game.useInventoryItemWith(3180, topThing)
            end
        end
    end

    lastPosition = currentPosition
end)


addIcon("TRAP", {item=2128, text="TRAP"},trapzera)
---------------------------------------------------------------------------------------------------------------------------------------
local function calculateDistance(pos1, pos2)
    return math.abs(pos1.x - pos2.x) + math.abs(pos1.y - pos2.y)
end

local function isValidTile(tile)
    if not tile then
        return false
    end
    local topThing = tile:getTopUseThing()
    return topThing and not tile:hasCreature()
end

local function getNeighborTiles(pos)
    local directions = {
        {x = 0, y = -1},   -- Norte
        {x = 0, y = 1},    -- Sul
        {x = -1, y = 0},   -- Oeste
        {x = 1, y = 0},    -- Leste
        {x = -1, y = -1},  -- Noroeste
        {x = 1, y = -1},   -- Nordeste
        {x = 1, y = 1},    -- Sudeste
        {x = -1, y = 1}    -- Sudoeste
    }
    local neighbors = {}
    for _, dir in ipairs(directions) do
        local neighborPos = {x = pos.x + dir.x, y = pos.y + dir.y, z = pos.z}
        local neighborTile = g_map.getTile(neighborPos)
        if neighborTile and isValidTile(neighborTile) then
            table.insert(neighbors, neighborTile)
        end
    end
    return neighbors
end

local function getPassageTiles(target)
    local targetPos = target:getPosition()
    local validTiles = getNeighborTiles(targetPos)

    if #validTiles == 2 then
        return validTiles
    end

    table.sort(validTiles, function(a, b)
        local distA = calculateDistance(a:getPosition(), targetPos)
        local distB = calculateDistance(b:getPosition(), targetPos)
        return distA < distB
    end)

    return validTiles
end

local lastPosition = nil

trapzeraa = macro(1," ", "F3", function()
    local target = g_game.getAttackingCreature()
    if not target then return end

    local currentPosition = target:getPosition()

    if lastPosition and calculateDistance(lastPosition, currentPosition) > 0 then
        local direction = target:getDirection()
        local mwPos = {x = currentPosition.x, y = currentPosition.y, z = currentPosition.z}

        if direction == 0 then
            mwPos.y = mwPos.y - 3 -- Norte
        elseif direction == 1 then
            mwPos.x = mwPos.x + 3 -- Leste
        elseif direction == 2 then
            mwPos.y = mwPos.y + 3 -- Sul
        elseif direction == 3 then
            mwPos.x = mwPos.x - 3 -- Oeste
        end

        local mwTile = g_map.getTile(mwPos)
        if mwTile then
            g_game.useInventoryItemWith(3156, mwTile:getTopUseThing())
        end
    else
        local passageTiles = getPassageTiles(target)
        for _, tile in ipairs(passageTiles) do
            local topThing = tile:getTopUseThing()
            if topThing then
                g_game.useInventoryItemWith(3156, topThing)
            end
        end
    end

    lastPosition = currentPosition
end)


addIcon("TRAP 2", {item=2130, text="TRAP 2"},trapzeraa)
---------------------------------------------------------------------------------------------------------------------------------------
local function checkPos(x, y)
 xyz = g_game.getLocalPlayer():getPosition()
 xyz.x = xyz.x + x
 xyz.y = xyz.y + y
 tile = g_map.getTile(xyz)
 if tile then
  return g_game.use(tile:getTopUseThing())  
 else
  return false
 end
end


macro(1, 'Bug Map', function() 
 if modules.corelib.g_keyboard.isKeyPressed('w') then
  checkPos(0, -5)
 elseif modules.corelib.g_keyboard.isKeyPressed('e') then
  checkPos(3, -3)
 elseif modules.corelib.g_keyboard.isKeyPressed('d') then
  checkPos(5, 0)
 elseif modules.corelib.g_keyboard.isKeyPressed('c') then
  checkPos(3, 3)
 elseif modules.corelib.g_keyboard.isKeyPressed('s') then
  checkPos(0, 5)
 elseif modules.corelib.g_keyboard.isKeyPressed('z') then
  checkPos(-3, 3)
 elseif modules.corelib.g_keyboard.isKeyPressed('a') then
  checkPos(-5, 0)
 elseif modules.corelib.g_keyboard.isKeyPressed('q') then
  checkPos(-3, -3)
 end
end)
---------------------------------------------------------------------------------------------------------------------------------------
spellPosition = macro(100, "SIO GUILD", function()
    local hpThreshold = 98

    for _, spec in ipairs(getSpectators(false)) do
        if spec:isPlayer() and spec:getEmblem() == 1 and spec:getHealthPercent() < hpThreshold then
            say("exura sio \"" .. spec:getName())
            return
        end
    end
end)
---------------------------------------------------------------------------------------------------------------------------------------
macro(1, "ANTI-PARALYZE", function()
    if isParalyzed() then
        say("utani brutox hur")
    end
end)
---------------------------------------------------------------------------------------------------------------------------------------
local paralyzeRuneId = 3165 -- ID da Paralyze Rune

macro(10, "ATK PARALYZE", function()
  -- Verifica se você está atacando algo
  local target = g_game.getAttackingCreature()
  if target then
    -- Obtém o nome e verifica se o alvo é válido
    local targetName = target:getName()
    if target:isPlayer() or target:isMonster() then
      -- Usa a runa de Paralyze no alvo
      useWith(paralyzeRuneId, target)
   return
  delay(100)
    end
  end
end)
---------------------------------------------------------------------------------------------------------------------------------------
local showhp = macro(1000, function() end)
onCreatureHealthPercentChange(function(creature, healthPercent)
    if showhp:isOff() then  return end
    if creature:isMonster() and creature:getPosition() and pos() then
        if getDistanceBetween(pos(), creature:getPosition()) <= 10 then
            creature:setText(healthPercent .. "%")
        else
            creature:clearText()
        end
    end
end)
---------------------------------------------------------------------------------------------------------------------------------------
if not storage.NewComboLeader then
  storage.NewComboLeader = {}
end

local settings = storage.NewComboLeader

if settings.enabled == nil then
  settings.enabled = true
end

if not settings.sdMissle then
  settings.sdMissle = 32
end

if not settings.AttackEnemiesHK then
  settings.AttackEnemiesHK = "f5"
end

g_ui.loadUIFromString([[
NewComboLeaderTextEdit < Panel
  height: 40

  UIWidget
    id: text
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center
    
  TextEdit
    id: textEdit
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    minimum: 0
    maximum: 10
    step: 1
    text-align: center

NewComboLeaderItem < Panel
  height: 34
  margin-top: 7
  margin-left: 25
  margin-right: 25

  UIWidget
    id: text
    anchors.left: parent.left
    anchors.verticalCenter: next.verticalCenter

  BotItem
    id: item
    anchors.top: parent.top
    anchors.right: parent.right


NewComboLeaderWindow < MainWindow
  !text: tr('NewComboLeader')
  size: 440 360
  padding: 25

  Label
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    anchors.top: parent.top
    text-align: center

  Label
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center

  VerticalScrollBar
    id: contentScroll
    anchors.top: prev.bottom
    margin-top: 3
    anchors.right: parent.right
    anchors.bottom: separator.top
    step: 28
    pixels-scroll: true
    margin-right: -10
    margin-top: 5
    margin-bottom: 5

  ScrollablePanel
    id: content
    anchors.top: prev.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: separator.top
    vertical-scrollbar: contentScroll
    margin-bottom: 10
      
    Panel
      id: left
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.horizontalCenter
      margin-top: 5
      margin-left: 10
      margin-right: 10
      layout:
        type: verticalBox
        fit-children: true

    Panel
      id: right
      anchors.top: parent.top
      anchors.left: parent.horizontalCenter
      anchors.right: parent.right
      margin-top: 5
      margin-left: 10
      margin-right: 10
      layout:
        type: verticalBox
        fit-children: true

    VerticalSeparator
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.left: parent.horizontalCenter

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 8

  ResizeBorder
    id: bottomResizeBorder
    anchors.fill: separator
    height: 3
    minimum: 260
    maximum: 600
    margin-left: 3
    margin-right: 3
    background: #ffffff88    

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
    margin-right: 5
]])

-- basic elements
NewComboLeaderWindow = UI.createWindow('NewComboLeaderWindow', rootWidget)
NewComboLeaderWindow:hide()
NewComboLeaderWindow.closeButton.onClick = function(widget)
  NewComboLeaderWindow:hide()
end

NewComboLeaderWindow:setHeight(350)
NewComboLeaderWindow:setWidth(450)
NewComboLeaderWindow:setText("New Combo Leader")

local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('New Combo Leader')

  Button
    id: push
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup

]])

ui.title:setOn(settings.enabled)
ui.title.onClick = function(widget)
  settings.enabled = not settings.enabled
  widget:setOn(settings.enabled)
end

ui.push.onClick = function(widget)
  NewComboLeaderWindow:show()
  NewComboLeaderWindow:raise()
  NewComboLeaderWindow:focus()
end

-- available options for dest param
local rightPanel = NewComboLeaderWindow.content.right
local leftPanel = NewComboLeaderWindow.content.left

-- objects made by Kondrah - taken from creature editor, minor changes to adapt
local addItem = function(id, title, defaultItem, dest, tooltip)
  local widget = UI.createWidget('NewComboLeaderItem', dest)
  widget.text:setText(title)
  widget.text:setTooltip(tooltip)
  widget.item:setTooltip(tooltip)
  widget.item:setItemId(settings[id] or defaultItem)
  widget.item.onItemChange = function(widget)
    settings[id] = widget:getItemId()
  end
  settings[id] = settings[id] or defaultItem
end

local addTextEdit = function(id, title, defaultValue, dest, tooltip)
  local widget = UI.createWidget('NewComboLeaderTextEdit', dest)
  widget.text:setText(title)
  widget.textEdit:setText(settings[id] or defaultValue or "")
  widget.text:setTooltip(tooltip)
  widget.textEdit.onTextChange = function(widget,text)
    settings[id] = text
  end
  settings[id] = settings[id] or defaultValue or ""
end

local m_leaderTarget = macro(10000, "Leader Target", function() end, leftPanel)
local m_comboSD = macro(10000, "Combo Rune", function() end, leftPanel)
local m_comboSpell = macro(10000, "Combo UE", function() end, leftPanel)

hotkey(settings.AttackEnemiesHK, "Attack Enemy Listed",function()
  if g_game.isAttacking() then return end
  
  local enemies = {}
  for _, enemyName in ipairs(storage.playerList.enemyList) do
    local enemy = getCreatureByName(enemyName)
    if enemy then
      local enemyT = g_map.getTile(enemy:getPosition())
      if enemyT:canShoot() then
        table.insert(enemies, enemy)
      end
    end
  end
  
  table.sort(enemies, function(a, b)
    local distA = getDistanceBetween(a:getPosition(), pos())
    local distB = getDistanceBetween(b:getPosition(), pos())
    return distA < distB
  end)
  
  local t = enemies[1]
  if t then
    g_game.attack(t)
  end
end, leftPanel)

addTextEdit("LeaderName", "Leader Name",settings.LeaderName or "name", rightPanel)

addTextEdit("LeaderSpell", "Leader UE",settings.LeaderSpell or "exevo gran mas frigo", rightPanel)

addTextEdit("UE", "Your UE",settings.UE or "exevo gran mas frigo", rightPanel)

addTextEdit("AttackEnemiesHK", "Attack Enemies HK", "f5", rightPanel)

addItem("SD", "Rune", 3155, leftPanel, "")

local m_configRune = macro(10000, "Config Rune", function() end, leftPanel)

addLabel("","to configure the rune combo, enable the 'Config Rune' macro, and ask the leader to use the rune in any target, DO NOT ATTACK, only rune :)", leftPanel)

addButton("", "", function()
  g_platform.openUrl("")
end, leftPanel)

--inspired by vbot 4.8 combo
onMissle(function(missle)
  if not settings.enabled then return end
  local src = missle:getSource()
  if src.z ~= posz() then return end
  
  local from = g_map.getTile(src)
  local to = g_map.getTile(missle:getDestination())
  if not from or not to then return end
  
  local fromCreatures = from:getCreatures()
  local toCreatures = to:getCreatures()
  if #fromCreatures ~= 1 or #toCreatures ~= 1 then return end
  
  local c1 = fromCreatures[1]
  local t1 = toCreatures[1]
  
  if t1:getName():lower() == settings.LeaderName:lower() then return end
  if table.find(storage.playerList.friendList, t1:getName(), true) then return end
  
  if c1:getName():lower() == settings.LeaderName:lower() then
    if m_configRune.isOn() then
      settings.sdMissle = missle:getId()      
      modules.game_textmessage.displayGameMessage("Rune Combo Configured.")
      m_configRune:setOff()
    else
      if m_leaderTarget:isOn() then
        local target = g_game.getAttackingCreature()
        if not target or target ~= t1 then
          g_game.attack(t1)
          schedule(1000, function()
            g_game.cancelAttackAndFollow()
          end)
        end
      end
      if m_comboSD.isOn() and missle:getId() == settings.sdMissle then
        useWith(settings.SD, t1)
      end
    end
  end
end)

onTalk(function(name, level, mode, text, channelId, pos) 
  if not settings.enabled then return end
  if m_comboSpell.isOn() and name:lower() == settings.LeaderName:lower() and text:lower() == settings.LeaderSpell:lower() then
    say(settings.UE)
  end
end)
        else
            -- Aqui você pode adicionar código para desativar os macros, se necessário
        end
    end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------
