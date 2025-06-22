--[[
    CS50 2D
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Dungeon will be a collection of equally sized rooms starting from
    an assumed bottom position like in the original Legend of Zelda.
    Each room will be a rectangular area that can be filled with entities,
    as well as triggers and other interactive elements (such as treasure chests
    for the problem set).

    The DungeonMaker's generate function will essentially crawl through the
    dungeon and operate like a random stack-based maze generator, where
    it will randomly select a room to create, then randomly select a direction
    to create a new room in, and then continue until it has created a certain
    number of rooms or reached a certain depth.

    The DungeonMaker is also be responsible for ensuring that the rooms
    do not overlap and that they are all connected in some way.
]]

DungeonMaker = Class{}

function DungeonMaker.generate(player, maxRooms)
    -- empty 10x10 grid of rooms to start
    local rooms = {}
    for i = 1, maxRooms do
        rooms[i] = {}
        for j = 1, maxRooms do
            rooms[i][j] = nil
        end
    end

    -- start at 10 so that we can move left and up in generating without
    -- going into negative indices
    local startX = math.min(1, maxRooms / 2)
    local startY = math.min(1, maxRooms / 2)

    local stack = {}
    local visited = {}

    -- push the starting room onto the stack
    table.insert(stack, {x = startX, y = startY})
    visited[startX .. ',' .. startY] = true
    local numRooms = 0

    while #stack > 0 and numRooms < maxRooms do
        -- pop a room from the stack
        local current = table.remove(stack)

        -- if we haven't visited this room yet, create it
        if not rooms[current.y][current.x] then
            rooms[current.y][current.x] = Room(player, current.x, current.y)
            numRooms = numRooms + 1
        end

        -- get the current room
        local room = rooms[current.y][current.x]

        -- randomly shuffle directions to explore
        local directions = {'up', 'down', 'left', 'right'}
        for i = #directions, 2, -1 do
            local j = math.random(i)
            directions[i], directions[j] = directions[j], directions[i]
        end

        -- try to create new rooms in each direction
        for _, direction in ipairs(directions) do
            local newX, newY = current.x, current.y

            if direction == 'up' then
                newY = newY - 1
            elseif direction == 'down' then
                newY = newY + 1
            elseif direction == 'left' then
                newX = newX - 1
            elseif direction == 'right' then
                newX = newX + 1
            end

            -- check if the new room is within bounds and not visited yet
            if newX >= 1 and newX <= 10 and newY >= 1 and newY <= 10 and not visited[newX .. ',' .. newY] then
                visited[newX .. ',' .. newY] = true

                -- push the new room onto the stack for further exploration
                table.insert(stack, {x = newX, y = newY})
            end
        end
    end

    return Dungeon(player, rooms, startX, startY)
end

