require "dun-gen"

ROOMS_MIN   = 10    -- Minimum number of rooms generated
ROOMS_MAX   = 20    -- Maximum number of rooms generated
SIZE_MIN    = 6     -- Minimum tiles across in a room
SIZE_MAX    = 8     -- Maximum tiles across in a room

function love.load()
    dun = Dungeon:new(ROOMS_MIN, ROOMS_MAX, SIZE_MIN, SIZE_MAX)

    -- TODO Print dungeon array to console
end

function love.update(dt)
    --
end

function love.draw()
    --
end
