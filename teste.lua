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
        else
            -- Aqui você pode adicionar código para desativar os macros, se necessário
        end
    end
end
