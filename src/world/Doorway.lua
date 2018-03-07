--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Doorway = Class{}

function Doorway:init(direction, open, room)
    self.direction = direction
    self.open = open
    self.room = room

    if direction == 'left' then
        self.x = MAP_RENDER_OFFSET_X
        self.y = MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE
        self.height = 32
        self.width = 16
    elseif direction == 'right' then
        self.x = MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE) - TILE_SIZE
        self.y = MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2 * TILE_SIZE) - TILE_SIZE
        self.height = 32
        self.width = 16
    elseif direction == 'top' then
        self.x = MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2 * TILE_SIZE) - TILE_SIZE
        self.y = MAP_RENDER_OFFSET_Y
        self.height = 16
        self.width = 32
    else
        self.x = MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2 * TILE_SIZE) - TILE_SIZE
        self.y = MAP_RENDER_OFFSET_Y + (MAP_HEIGHT * TILE_SIZE) - TILE_SIZE
        self.height = 16
        self.width = 32
    end
end

function Doorway:render(offsetX, offsetY)
    local texture = gTextures['tiles']
    local quads = gFrames['tiles']

    -- used for shifting the doors when sliding rooms
    self.x = self.x + offsetX
    self.y = self.y + offsetY

    if self.direction == 'left' then
        if self.open then
            love.graphics.draw(texture, quads[181], self.x - TILE_SIZE, self.y)
            love.graphics.draw(texture, quads[182], self.x, self.y)
            love.graphics.draw(texture, quads[200], self.x - TILE_SIZE, self.y + TILE_SIZE)
            love.graphics.draw(texture, quads[201], self.x, self.y + TILE_SIZE)
        else
            love.graphics.draw(texture, quads[219], self.x - TILE_SIZE, self.y)
            love.graphics.draw(texture, quads[220], self.x, self.y)
            love.graphics.draw(texture, quads[238], self.x - TILE_SIZE, self.y + TILE_SIZE)
            love.graphics.draw(texture, quads[239], self.x, self.y + TILE_SIZE)
        end
    elseif self.direction == 'right' then
        if self.open then
            love.graphics.draw(texture, quads[172], self.x, self.y)
            love.graphics.draw(texture, quads[173], self.x + TILE_SIZE, self.y)
            love.graphics.draw(texture, quads[191], self.x, self.y + TILE_SIZE)
            love.graphics.draw(texture, quads[192], self.x + TILE_SIZE, self.y + TILE_SIZE)
        else
            love.graphics.draw(texture, quads[174], self.x, self.y)
            love.graphics.draw(texture, quads[175], self.x + TILE_SIZE, self.y)
            love.graphics.draw(texture, quads[193], self.x, self.y + TILE_SIZE)
            love.graphics.draw(texture, quads[194], self.x + TILE_SIZE, self.y + TILE_SIZE)
        end
    elseif self.direction == 'top' then
        if self.open then
            love.graphics.draw(texture, quads[98], self.x, self.y - TILE_SIZE)
            love.graphics.draw(texture, quads[99], self.x + TILE_SIZE, self.y - TILE_SIZE)
            love.graphics.draw(texture, quads[117], self.x, self.y)
            love.graphics.draw(texture, quads[118], self.x + TILE_SIZE, self.y)
        else
            love.graphics.draw(texture, quads[134], self.x, self.y - TILE_SIZE)
            love.graphics.draw(texture, quads[135], self.x + TILE_SIZE, self.y - TILE_SIZE)
            love.graphics.draw(texture, quads[153], self.x, self.y)
            love.graphics.draw(texture, quads[154], self.x + TILE_SIZE, self.y)
        end
    else
        if self.open then
            love.graphics.draw(texture, quads[141], self.x, self.y)
            love.graphics.draw(texture, quads[142], self.x + TILE_SIZE, self.y)
            love.graphics.draw(texture, quads[160], self.x, self.y + TILE_SIZE)
            love.graphics.draw(texture, quads[161], self.x + TILE_SIZE, self.y + TILE_SIZE)
        else
            love.graphics.draw(texture, quads[216], self.x, self.y)
            love.graphics.draw(texture, quads[217], self.x + TILE_SIZE, self.y)
            love.graphics.draw(texture, quads[235], self.x, self.y + TILE_SIZE)
            love.graphics.draw(texture, quads[236], self.x + TILE_SIZE, self.y + TILE_SIZE)
        end
    end

    -- revert to original positions
    self.x = self.x - offsetX
    self.y = self.y - offsetY
end