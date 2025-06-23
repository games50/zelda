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

function DungeonMaker.generateGen(player, maxRooms)
    return coroutine.wrap(function()
        -- empty 10x10 grid of rooms to start
        local rooms = {}
        for i = 1, maxRooms do
            rooms[i] = {}
            for j = 1, maxRooms do
                rooms[i][j] = false
            end
        end

        -- start at 10 so that we can move left and up in generating without
        -- going into negative indices
        local startX = math.max(1, maxRooms / 2)
        local startY = maxRooms

        local queue = { { x = startX, y = startY } }
        local head = 1
        local visited = { [startX .. ',' .. startY] = true }
        local numRooms = 0

        while head <= #queue and numRooms < maxRooms do
            -- pop a room from the queue
            local current = queue[head]
            head = head + 1

            local cx, cy = current.x, current.y

            -- if we haven't visited this room yet, create it
            if not rooms[cy][cx] then
                rooms[cy][cx] = Room(player, cx, cy)
                numRooms = numRooms + 1
                rooms[cy][cx].order = numRooms
            end

            visited[cx .. ',' .. cy] = true  -- ensure this room isn't enqueued again

            -- pause after visiting a room
            coroutine.yield {
                phase = 'visit',
                current = current,
                queue = queue,
                rooms = rooms,
                visited = visited,
                head = head
            }

            -- get the current room
            local room = rooms[cy][cx]

            -- randomly shuffle directions to explore
            local directions = {'up', 'down', 'left', 'right'}
            for i = #directions, 2, -1 do
                local j = math.random(i)
                directions[i], directions[j] = directions[j], directions[i]
            end

            -- try to create new rooms in each direction
            for _, dir in ipairs(directions) do
                -- chance to skip a direction
                if math.random() < 0.4 then
                    goto continue
                end

                local nx, ny = cx, cy

                if     dir == 'up'    then ny = ny - 1
                elseif dir == 'down'  then ny = ny + 1
                elseif dir == 'left'  then nx = nx - 1
                elseif dir == 'right' then nx = nx + 1 end

                -- check if the new room is within bounds and not visited yet
                local key = nx .. ',' .. ny
                if nx >= 1 and nx <= maxRooms and ny >= 1 and ny <= maxRooms
                    and not visited[key] then
                    visited[key] = true
                    queue[#queue + 1] = { x = nx, y = ny }
                end

                ::continue::
            end

            coroutine.yield {
                phase = 'push',
                current = current,
                queue = queue,
                rooms = rooms,
                visited = visited,
                head = head
            }
        end

        -- after generating rooms, we need to generate doorway connections
        -- using the surrounding room information
        for y = 1, maxRooms do
            for x = 1, maxRooms do
                if rooms[y][x] then
                    rooms[y][x]:generateDoorways(rooms, x, y)
                    coroutine.yield {
                        phase = 'doorways',
                        current = {x = x, y = y},
                        rooms = rooms,
                        visited = visited,
                        queue = queue,
                        head = head
                    }
                end
            end
        end

        coroutine.yield {
            phase = 'done',
            dungeon = Dungeon(player, rooms, startX, startY),
            rooms = rooms,
            visited = visited,
            queue = queue,
            current = {x = startX, y = startY},
            head = head
        }
    end)
end

function DungeonMaker.generate(player, maxRooms)
    -- empty 10x10 grid of rooms to start
    local rooms = {}
    for i = 1, maxRooms do
        rooms[i] = {}
        for j = 1, maxRooms do
            rooms[i][j] = false
        end
    end

    -- start at 10 so that we can move left and up in generating without
    -- going into negative indices
    local startX = math.max(1, maxRooms / 2)
    local startY = maxRooms

    local queue = { { x = startX, y = startY } }
    local head = 1
    local visited = { [startX .. ',' .. startY] = true }
    local numRooms = 0

    while head <= #queue and numRooms < maxRooms do
        -- pop a room from the queue
        local current = queue[head]
        head = head + 1

        local cx, cy = current.x, current.y

        -- if we haven't visited this room yet, create it
        if not rooms[cy][cx] then
            rooms[cy][cx] = Room(player, cx, cy)
            numRooms = numRooms + 1
            rooms[cy][cx].order = numRooms
        end

        visited[cx .. ',' .. cy] = true  -- ensure this room isn't enqueued again

        -- get the current room
        local room = rooms[cy][cx]

        -- randomly shuffle directions to explore
        local directions = {'up', 'down', 'left', 'right'}
        for i = #directions, 2, -1 do
            local j = math.random(i)
            directions[i], directions[j] = directions[j], directions[i]
        end

        -- try to create new rooms in each direction
        for _, dir in ipairs(directions) do
            -- chance to skip a direction
            if math.random() < 0.4 then
                goto continue
            end

            local nx, ny = cx, cy

            if     dir == 'up'    then ny = ny - 1
            elseif dir == 'down'  then ny = ny + 1
            elseif dir == 'left'  then nx = nx - 1
            elseif dir == 'right' then nx = nx + 1 end

            -- check if the new room is within bounds and not visited yet
            local key = nx .. ',' .. ny
            if nx >= 1 and nx <= maxRooms and ny >= 1 and ny <= maxRooms
                and not visited[key] then
                visited[key] = true
                queue[#queue + 1] = { x = nx, y = ny }
            end

            ::continue::
        end
    end

    -- after generating rooms, we need to generate doorway connections
    -- using the surrounding room information
    for y = 1, maxRooms do
        for x = 1, maxRooms do
            if rooms[y][x] then
                rooms[y][x]:generateDoorways(rooms, x, y)
            end
        end
    end

    return Dungeon(player, rooms, startX, startY)
end