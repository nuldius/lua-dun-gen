require "dun-gen"

ROOMS_MIN   = 9     -- Minimum number of rooms generated
ROOMS_MAX   = 15    -- Maximum number of rooms generated
SIZE_MIN    = 5     -- Minimum tiles across in a room
SIZE_MAX    = 7     -- Maximum tiles across in a room

TILE_SIZE = 8       -- Pixel size of each tile

function love.load()
    dun = Dungeon:new(ROOMS_MIN, ROOMS_MAX, SIZE_MIN, SIZE_MAX)

    -- TODO Test/print Dungeon:getBinary() array thing to console
end

function love.keypressed(key, scancode, isrepeat)
    -- regenerate the room
    if key == "g" then
        dun = Dungeon:new(ROOMS_MIN, ROOMS_MAX, SIZE_MIN, SIZE_MAX)
    end
end

function love.draw()
    -- Draw the rooms
    for i, v in ipairs(dun.rooms) do
        -- Scale up by TILE_SIZE so we can see the rooms better
        local finalX = (v.x * TILE_SIZE) + love.graphics.getWidth()/2
        local finalY = (v.y * TILE_SIZE) + love.graphics.getHeight()/2
        local finalW = v.w * TILE_SIZE
        local finalH = v.h * TILE_SIZE

        -- Draw the room fill
        love.graphics.setColor(0, 255, 0)
        love.graphics.rectangle("fill", finalX, finalY, finalW, finalH)

        -- Draw grid lines so individual tiles are visible
        love.graphics.setColor(50, 50, 50)
        local x = finalX
        while x < finalX + finalW do
            love.graphics.line(x, finalY, x, finalY + finalH)
            x = x + TILE_SIZE
        end
        local y = finalY
        while y < finalY + finalH do
            love.graphics.line(finalX, y, finalX + finalW, y)
            y = y + TILE_SIZE
        end

        -- Draw the room outline
        love.graphics.setColor(200, 200, 200)
        love.graphics.rectangle("line", finalX, finalY, finalW, finalH)
    end

    -- Draw the hallways
    for i, v in ipairs(dun.hallways) do
        local finalX = (v.x * TILE_SIZE) + love.graphics.getWidth()/2
        local finalY = (v.y * TILE_SIZE) + love.graphics.getHeight()/2
        local finalW = v.w * TILE_SIZE
        local finalH = v.h * TILE_SIZE

        -- Draw the hallway fill
        love.graphics.setColor(127, 127, 255)
        love.graphics.rectangle("fill", finalX, finalY, finalW, finalH)
    end

    -- Draw informative text
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Press 'G' to regenerate the dungeon.", 0, 0)
    love.graphics.print("Amount of rooms: ", 0, 12)
    love.graphics.print(#dun.rooms, 0, 24)
    love.graphics.print("Amount of hallways: ", 0, 36)
    love.graphics.print("TODO", 0, 48)

    -- Draw the 2D array output of Dungeon:getBinary()
    love.graphics.setColor(255, 0, 0, 200)
    for x, xv in ipairs(dun:getBinary()) do
        for y, yv in ipairs(xv) do
            love.graphics.print(xv[y], x*11, y*11 + 60)
        end
    end
end
