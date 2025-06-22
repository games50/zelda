--[[
    CS50 2D
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

love.graphics.setDefaultFilter('nearest', 'nearest')
require 'src.Dependencies'

function love.load()
    math.randomseed(os.time())
    love.window.setTitle('Legend of Zelda')

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = 'normal' })

    love.graphics.setFont(gFonts['small'])

    gStateMachine = StateMachine {
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end,
    }
    gStateMachine:change('play')

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push.resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    Timer.update(dt)
    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end

function love.draw()
    push.start()
    gStateMachine:render()
    push.finish()
end