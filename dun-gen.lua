-- UTILITY FUNCTIONS --

-- Returns the distance between two vectors
local function dist(x1, y1, x2, y2)
    local v1 = (x1 - x2) * (x1 - x2)
    local v2 = (y1 - y2) * (y1 - y2)
    return math.sqrt(v1 + v2)
end

-- Returns if the two rooms are overlapping
local function overlaps(a, b)
    return (a.x < b.x + b.w and -- FIXME Error: ./dun-gen.lua:12: attempt to index local 'a' (a number value)
        a.x + a.w > b.x and
        a.y < b.y + b.h and
        a.y + a.h > b.y)
end

-- Returns a bool of whether rooms are done with placement
local function roomsDone(rooms)
    local noOverlaps = true
    for a in pairs(rooms) do
        for b in pairs(rooms) do
            if a ~= b and overlaps(a, b) then
                noOverlaps = false
            end
        end
    end
    return noOverlaps
end

-- Makes and returns a new room struct
local function makeRoom(sizeMin, sizeMax)
    local r = {}
    -- x/y/width/height/centerX/centerY
    r.x = math.random(-2, 2)
    r.y = math.random(-2, 2)
    r.w = math.random(sizeMin, sizeMax)
    r.h = math.random(sizeMin, sizeMax)
    r.cx = r.x + r.w/2
    r.cy = r.y + r.y/2
    return r
end

-- DUNGEON CLASS --

Dungeon = {}
Dungeon.__index = Dungeon

-- Generates and returns a new dungeon
function Dungeon:new(roomsMin, roomsMax, sizeMin, sizeMax)
    local d = {}
    setmetatable(d, Dungeon)

    -- Seed random
    math.randomseed(os.time())

    -- Spawn rooms
    d.rooms = {}
    for i = 0, math.random(roomsMin, roomsMax) do
        table.insert(d.rooms, makeRoom(sizeMin, sizeMax))
    end

    -- Position rooms
    while not roomsDone(d.rooms) do
        -- Sort room array by distance to center
        for _ = 0, (#d.rooms * #d.rooms) do
            for i, r in ipairs(d.rooms) do
                if i <= #d.rooms - 2 then
                    local this = dist(d.rooms[i].x, d.rooms[i].y, 0, 0)
                    local next = dist(d.rooms[i+1].x, d.rooms[i+1].y, 0, 0)
                    if this < next then
                        local temp = d.rooms[i]
                        d.rooms[i] = d.rooms[i+1]
                        d.rooms[i+1] = temp
                    end
                end
            end
        end

        -- Systematically reposition the rooms apart
        -- For each room...
        for a in pairs(d.rooms) do
            -- Find the first (closest) overlapping room
            for b in pairs(d.rooms) do
                if a ~= b and overlaps(a, b) then
                    -- Move room A away from room B
                    distX = a.cx - b.cx
                    distY = a.cy - b.cy
                    if math.abs(distX) >= math.abs(distY) then
                        -- Reposition to left side
                        if a.x <= 0 then
                            a.x = b.x - a.w
                        -- Reposition to right side
                        else
                            a.x = b.x + b.w
                        end
                    else
                        -- Reposition to top side
                        if a.y <= 0 then
                            a.y = b.y - a.h
                        -- Reposition to bottom side
                        else
                            a.y = b.y + b.h
                        end
                    end
                    -- Break, as the B room has been found and dealt with
                    break
                end
            end
        end
    end

    return d
end

-- Returns a 2D number array where 0 = walkable and 1 = non-walkable
function Dungeon:getBinary()
    -- TODO
end

-- Returns details of what tiles are in what rooms
function Dungeon:getRooms()
    -- TODO
end

-- Returns details of what tiles are in what hallways
function Dungeon:getHallways()
    -- TODO
end
