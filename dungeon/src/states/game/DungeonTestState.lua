DungeonTestState = Class { __includes = BaseState }

local COLORS = {
    grid =    { 1, 1, 1, 0.2 },
    carved =  { 0.3, 0.8, 0.3, 1 },
    queue =   { 0.95, 0.85, 0.2, 1 },
    visited = { 0.4, 0.4, 0.4, 0.6 },
    current = { 1, 0.25, 0.25, 1 }
}

function DungeonTestState:init()
    self.phase = 'start'
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
    self.gen = DungeonMaker.generate(self.player, 10)
    self.lastYield = nil
    self.queue = {}
    self.rooms = {}
    self.current = nil
    self.dungeon = nil
    self.visited = {}
    self.head = 1
    self.size = 10
end

local function print_rooms(rooms)
    -- print rooms in grid format, where nil is space
    -- and a room is "R"
    for y = 1, #rooms do
        local row = {}
        for x = 1, #rooms[y] do
            if rooms[y][x] then
                table.insert(row, '[R]')
            else
                table.insert(row, '[ ]')
            end
        end
        print(table.concat(row, ''))
    end
    print('---')
end

function DungeonTestState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    if love.keyboard.wasPressed('r') then
        self.phase = 'start'
        self.gen = DungeonMaker.generate(self.player, 10)
        self.lastYield = nil
        self.queue = {}
        self.rooms = {}
        self.current = nil
        self.dungeon = nil
        self.visited = {}
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        print_rooms(self.rooms)
        if self.phase == 'done' then
            gStateMachine:change('play', {
                player = self.player,
                dungeon = self.dungeon
            })
            return
        end

        self.lastYield = self.gen()
        self.phase = self.lastYield.phase or 'done'

        if self.lastYield then
            self.queue = self.lastYield.queue or {}
            self.rooms = self.lastYield.rooms or {}
            self.current = self.lastYield.current or nil
            self.visited = self.lastYield.visited or {}
            self.head = self.lastYield.head or 1

            if self.lastYield.dungeon then
                self.dungeon = self.lastYield.dungeon
            end
        else
            self.phase = 'done'
        end
    end
end

local function setColor(c) love.graphics.setColor(c[1], c[2], c[3], c[4]) end
local CELL = 16
local OFFSET = 128
local OFFSET_Y = 24

function DungeonTestState:render()
    setColor { 1, 1, 1, 1 }

    love.graphics.print('Phase: ' .. self.phase, 10, 10)
    love.graphics.print('Press Enter to continue', VIRTUAL_WIDTH - 150, 10)

    -- print grid Xs and Ys along the top and left
    for i = 1, self.size do
        love.graphics.print(i, OFFSET + (i - 1) * CELL + 4, OFFSET_Y + 4)
    end
    for i = 1, self.size do
        love.graphics.print(i, OFFSET + 4 - CELL, (i - 1) * CELL + 4 + CELL + OFFSET_Y)
    end

    -- draw background grid
    setColor(COLORS.grid)
    for y = 0, (self.size - 1) do
        for x = 0, (self.size - 1) do
            love.graphics.rectangle('line',
                OFFSET + x * CELL, 16 + y * CELL + OFFSET_Y, CELL, CELL)
        end
    end

    -- draw visited cells that are not in queue nor current
    for key, _ in pairs(self.visited) do
        local x, y = key:match("(%d+),(%d+)")
        x, y = tonumber(x), tonumber(y)
        local inQueue = false
        for i = 1, #self.queue do
            if self.queue[i].x == x and self.queue[i].y == y then
                inQueue = true
                break
            end
        end

        local isCurrent = (self.current and self.current.x == x and self.current.y == y)
        if not inQueue and not isCurrent then
            setColor(COLORS.visited)
            love.graphics.rectangle('fill',
                OFFSET + (x - 1) * CELL, 16 + (y - 1) * CELL + OFFSET_Y, CELL, CELL)
        end
    end

    -- draw queue so that it's visible
    for i = self.head, #self.queue do
        local r = self.queue[i]
        setColor(COLORS.queue)
        love.graphics.rectangle('fill',
            OFFSET + (r.x - 1) * CELL, 16 + (r.y - 1) * CELL + OFFSET_Y, CELL, CELL)
    end

    -- draw carved rooms
    setColor(COLORS.carved)
    for y = 1, #self.rooms do
        for x = 1, #self.rooms[y] do
            local room = self.rooms[y][x]
            if room then
                setColor(COLORS.carved)
                love.graphics.rectangle('fill',
                    OFFSET + (x - 1) * CELL, 16 + (y - 1) * CELL + OFFSET_Y, CELL, CELL)
                setColor { 0, 0, 0, 1 }
                love.graphics.print(room.order or '?', OFFSET + (x - 1) * CELL + 2, 16 + (y - 1) * CELL + 2 + OFFSET_Y)
            end
        end
    end

    -- highlight current room with red border
    if self.current then
        setColor(COLORS.current)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle('line',
            OFFSET + (self.current.x - 1) * CELL, 16 + (self .current.y - 1) * CELL + OFFSET_Y, CELL, CELL)
        love.graphics.setLineWidth(1)
    end

    -- print queue starting from bottom left, growing up
    setColor { 1, 1, 1, 1 }
    local textY = VIRTUAL_HEIGHT - 20
    for i = self.head, #self.queue do
        local r = self.queue[i]
        love.graphics.print(('(%d, %d)'):format(r.x, r.y), 10, textY)
        textY = textY - 12
    end

    -- current x and y bottom right
    if self.current then
        love.graphics.print(('Current: (%d, %d)'):format(self.current.x, self.current.y),
            VIRTUAL_WIDTH - 150, VIRTUAL_HEIGHT - 20)
    end

    -- draw visited from bottom right, growing upwards
    local counter = 0
    for key, _ in pairs(self.visited) do
        local x, y = key:match("(%d+),(%d+)")
        x, y = tonumber(x), tonumber(y)
        local visitedText = string.format('Visited: (%d, %d)', x, y)
        love.graphics.print(visitedText, VIRTUAL_WIDTH - 60, VIRTUAL_HEIGHT - 10 - counter * 12)
        counter = counter + 1
    end

    -- print head
    love.graphics.print('Head: ' .. self.head, 60, VIRTUAL_HEIGHT - 20)

    -- print length of queue beneath head
    love.graphics.print('Queue length: ' .. #self.queue, 60, VIRTUAL_HEIGHT - 10)
end