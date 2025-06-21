--[[
    CS50 2D
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.player = Player {
        animations = ENTITY_DEFS['player'].animations,
        walkSpeed = ENTITY_DEFS['player'].walkSpeed,
        
        x = VIRTUAL_WIDTH / 2 - 8,
        y = VIRTUAL_HEIGHT / 2 - 11,
        
        width = 16,
        height = 22,

        -- one heart == 2 health
        health = 6,

        -- rendering and collision offset for spaced sprites
        offsetY = 5
    }

    self.dungeon = DungeonMaker.generate(self.player, 10)
    self.currentRoom = Room(self.player)
    
    self.player.stateMachine = StateMachine {
        ['walk'] = function() return PlayerWalkState(self.player, self.dungeon) end,
        ['idle'] = function() return PlayerIdleState(self.player) end,
        ['swing-sword'] = function() return PlayerSwingSwordState(self.player, self.dungeon) end
    }
    self.player:changeState('idle')
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    self.dungeon:update(dt)
end

function PlayState:render()
    -- render dungeon and all entities separate from hearts GUI
    love.graphics.push()
    self.dungeon:render()
    love.graphics.pop()

    -- draw player hearts, top of screen
    local healthLeft = self.player.health
    local heartFrame = 1

    for i = 1, 3 do
        if healthLeft > 1 then
            heartFrame = 5
        elseif healthLeft == 1 then
            heartFrame = 3
        else
            heartFrame = 1
        end

        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][heartFrame],
            (i - 1) * (TILE_SIZE + 1), 2)
        
        healthLeft = healthLeft - 2
    end

    -- draw the map of the dungeon
    love.graphics.setColor(1, 1, 1, 1)
    self:drawTransparentMap()
    
    -- print the X, Y coordinates of the player's room
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print('Room: ' .. self.dungeon.currentRoom.x .. ', ' .. self.dungeon.currentRoom.y,
        2, VIRTUAL_HEIGHT - 10)
end

--[[
    Simple small version of the map drawn as a grid, but only drawing
    the rooms that exist in the dungeon 2D grid.
]]
function PlayState:drawTransparentMap()
    love.graphics.setColor(0, 1, 0, 0.5) -- set transparency
    for y = 1, #self.dungeon.rooms do
        for x = 1, #self.dungeon.rooms[y] do
            local room = self.dungeon.rooms[y][x]
            if room then
                -- set color to yellow if it's the room we're currently in
                if room == self.dungeon.currentRoom then
                    love.graphics.setColor(1, 1, 0, 0.5)
                else
                    love.graphics.setColor(0, 1, 0, 0.5)
                end
                love.graphics.rectangle('line', (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
            end
        end
    end
    love.graphics.setColor(1, 1, 1, 1) -- reset transparency
end