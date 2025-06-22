--[[
    CS50 2D
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Dungeon = Class{}

function Dungeon:init(player, rooms, startX, startY)
    self.player = player

    -- container we could use to store rooms in a static dungeon, but unused here
    self.rooms = rooms or {}

    -- current room we're operating in
    self.currentRoom = rooms[startY][startX]

    -- room we're moving camera to during a shift; becomes active room afterwards
    self.nextRoom = nil

    -- love.graphics.translate values, only when shifting screens and reset to 0 afterwards
    self.cameraX = 0
    self.cameraY = 0
end

function Dungeon:update(dt)
    self.player:update(dt)
end

function Dungeon:render()
    self.currentRoom:render()
end