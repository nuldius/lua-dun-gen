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
    for _, a in ipairs(rooms) do
        for _, b in ipairs(rooms) do
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

-- Makes and returns a new hallway struct from roomA to roomB
-- FIXME: Totally broken/unfinished right now
local function makeHallway(roomA, roomB)
    local h = {}
    h.x = 0
    h.y = 0
    h.w = 0
    h.h = 0

    -- Start with the furthest distance axis
    local xDist = math.abs(roomA.cx - roomB.cx)
    local yDist = math.abs(roomA.cy - roomB.cy)

    if xDist > yDist then
        if roomA.cx < roomB.cx then
            -- Make a hallway going right
            h.x = roomA.x + roomA.w
            h.y = math.floor(roomA.cy)
            h.w = roomB.x - (roomA.x + roomA.w)
            h.h = 1
        else
            -- Make a hallway going left
            h.x = roomA.x
            h.y = math.floor(roomA.cy)
            h.w = roomA.x - (roomB.x + roomB.w)
            h.h = 1
        end
    else
        if roomA.cy > roomB.cy then
            -- Make a hallway going down
            -- TODO
        else
            -- Make a hallway going up
            -- TODO
        end
    end

    return h
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
        for _, a in ipairs(d.rooms) do
            -- Find the first (closest) overlapping room
            for _, b in ipairs(d.rooms) do
                if a ~= b and overlaps(a, b) then
                    -- Move room A away from room B
                    distX = a.cx - b.cx
                    distY = a.cy - b.cy
                    if math.abs(distX) >= math.abs(distY) then
                        -- Reposition to left side
                        if a.x <= 0 then
                            a.x = b.x - a.w - 1
                        -- Reposition to right side
                        else
                            a.x = b.x + b.w + 1
                        end
                    else
                        -- Reposition to top side
                        if a.y <= 0 then
                            a.y = b.y - a.h - 1
                        -- Reposition to bottom side
                        else
                            a.y = b.y + b.h + 1
                        end
                    end
                    -- Break, as the B room has been found and dealt with
                    break
                end
            end
        end
    end

    -- Generate the hallways
    -- This should look more natural due to previous room distance sort!
    d.hallways = {}
    for i, r in ipairs(d.rooms) do
        if i ~= #d.rooms then
            table.insert(d.hallways, makeHallway(d.rooms[i], d.rooms[i+1]))
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
