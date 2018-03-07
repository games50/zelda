--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerSwingSwordState = Class{__includes = BaseState}

function PlayerSwingSwordState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite
    self.player.offsetY = 5
    self.player.offsetX = 8

    -- create hurtbox based on where the player is and facing
    local direction = self.player.direction
    
    local hurtboxX, hurtboxY, hurtboxWidth, hurtboxHeight

    if direction == 'left' then
        hurtboxWidth = 8
        hurtboxHeight = 16
        hurtboxX = self.player.x - hurtboxWidth
        hurtboxY = self.player.y + 2
    elseif direction == 'right' then
        hurtboxWidth = 8
        hurtboxHeight = 16
        hurtboxX = self.player.x + self.player.width
        hurtboxY = self.player.y + 2
    elseif direction == 'up' then
        hurtboxWidth = 16
        hurtboxHeight = 8
        hurtboxX = self.player.x
        hurtboxY = self.player.y - hurtboxHeight
    else
        hurtboxWidth = 16
        hurtboxHeight = 8
        hurtboxX = self.player.x
        hurtboxY = self.player.y + self.player.height
    end

    self.swordHurtbox = Hurtbox(hurtboxX, hurtboxY, hurtboxWidth, hurtboxHeight)
    self.player:changeAnimation('sword-' .. self.player.direction)
end

function PlayerSwingSwordState:enter(params)
    gSounds['sword']:stop()
    gSounds['sword']:play()

    -- restart sword swing animation
    self.player.currentAnimation:refresh()
end

function PlayerSwingSwordState:update(dt)
    -- check if hurtbox collides with any entities in the scene
    for k, entity in pairs(self.dungeon.currentRoom.entities) do
        if entity:collides(self.swordHurtbox) then
            entity:damage(1)
            gSounds['hit-enemy']:play()
        end
    end

    if self.player.currentAnimation.timesPlayed > 0 then
        self.player.currentAnimation.timesPlayed = 0
        self.player:changeState('idle')
    end

    if love.keyboard.wasPressed('space') then
        self.player:changeState('swing-sword')
    end
end

function PlayerSwingSwordState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))

    -- debug for player and hurtbox collision rects
    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.player.x, self.player.y, self.player.width, self.player.height)
    -- love.graphics.rectangle('line', self.swordHurtbox.x, self.swordHurtbox.y,
    --     self.swordHurtbox.width, self.swordHurtbox.height)
    -- love.graphics.setColor(255, 255, 255, 255)
end