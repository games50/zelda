--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Hitbox = Class{}

function Hitbox:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
end