require "dun-gen"

ROOMS_MIN   = 8     -- Minimum number of rooms generated
ROOMS_MAX   = 12    -- Maximum number of rooms generated
SIZE_MIN    = 4     -- Minimum tiles across in a room
SIZE_MAX    = 8     -- Maximum tiles across in a room

TILE_SIZE = 8       -- Pixel size of each tile

function love.load()
    -- Create and generate a new dungeon
    dun = Dungeon:new(ROOMS_MIN, ROOMS_MAX, SIZE_MIN, SIZE_MAX)
end

function love.keypressed(key, scancode, isrepeat)
    -- Regenerate the dungeon
    if key == "g" then
        dun = Dungeon:new(ROOMS_MIN, ROOMS_MAX, SIZE_MIN, SIZE_MAX)
    end
end

function love.draw()
    -- Print informative text
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Press 'G' to regenerate the dungeon.", 0, 0)
    love.graphics.print("Amount of rooms: ", 0, 12)
    love.graphics.print(#dun.rooms, 0, 24)
    love.graphics.print("Amount of hallways: ", 0, 36)
    love.graphics.print("TODO", 0, 48)

    -- Print the dungeon data from Dungeon:getArray()
    for x, xv in ipairs(dun:getArray()) do
        for y, yv in ipairs(xv) do
            love.graphics.setColor(0, 0, 0, 200)
            love.graphics.rectangle("fill", x*11, y*11 + 60, 11, 11)

            if xv[y] == 0 then
                love.graphics.setColor(60, 60, 220)
            else
                love.graphics.setColor(50, 50, 120)
            end
            love.graphics.print(xv[y], x*11, y*11 + 60)
        end
    end
end
